"""One build, two isolated viewport arms. Keep real exits; never grant Release acceptance."""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import plistlib
import subprocess
import sys

from verify_reader_positions import VIEWPORT_SMOKE_TESTS, verify_viewport_pair_arm, compare_viewport_pair_receipts

ROOTS = ["App", "Packages", "Vendor", "Tests", "scripts", ".github", "project.yml", "Package.resolved", ".gitattributes"]
CASE = "XianxiaReaderTests/" + next(iter(VIEWPORT_SMOKE_TESTS))
KEY = "XIANXIA_VIEWPORT_FIXTURE"
MODES = ("paired-safe", "paired-conflict")


def digest(value):
    return hashlib.sha256(plistlib.dumps(value, sort_keys=True)).hexdigest()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, sort_keys=True, indent=2) + "\n", encoding="utf-8")


def version_fields(text):
    # Retain full logs, but unrelated stderr warnings are not version changes.
    prefixes = ["Xcode ", "Build version ", "Apple Swift version ", "Target:", "ProductName:", "ProductVersion:", "BuildVersion:"]
    values = {}
    for prefix in prefixes:
        rows = [line[len(prefix):].strip() for line in text.splitlines() if line.startswith(prefix)]
        if len(rows) != 1 or not rows[0]:
            raise ValueError("Missing or ambiguous tool version: " + prefix)
        values[prefix] = rows[0]
    if values["Xcode "] != "16.4":
        raise ValueError("Require actual Xcode 16.4, not just its directory name")
    return values


def source_inputs(root):
    def git(*args):
        return subprocess.check_output(["git", *args], cwd=root)
    revision = git("rev-parse", "HEAD").decode().strip()
    if os.environ.get("GITHUB_SHA", revision) != revision:
        raise ValueError("Workflow SHA does not match this checkout")
    if git("ls-files", "--others", "--exclude-standard", "--", *ROOTS).strip():
        raise ValueError("Untracked runtime inputs are outside the selected source commit")
    files = []
    for row in git("ls-tree", "-rz", revision, "--", *ROOTS).split(b"\0"):
        if not row:
            continue
        meta, name = row.split(b"\t", 1)
        path = name.decode("utf-8"); data = (root / path).read_bytes()
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if meta.split()[0] != b"100644" and meta.split()[0] != b"100755":
            raise ValueError("Unexpected source entry: " + path)
        if blob != meta.split()[2].decode():
            raise ValueError("Source differs from the selected commit: " + path)
        files.append(dict(path=path, gitBlob=blob, sha256=hashlib.sha256(data).hexdigest()))
    required = {"Package.resolved", "project.yml", "Tests/Fixtures/reader-layout.epub", "Tests/iOS/ReaderRenderingTests.swift"}
    if not required.issubset({f["path"] for f in files}):
        raise ValueError("Missing lock, project, original book or test source provenance")
    return dict(revision=revision, files=files)


def prepare(root):
    folder = root / "build/ViewportPair"
    folder.mkdir(parents=True, exist_ok=False)  # Never consume or overwrite an old pair.
    if KEY in os.environ or "TEST_RUNNER_" + KEY in os.environ:
        raise ValueError("Pair modes must come only from the explicit per-arm run plans")
    frozen = dict(source=source_inputs(root), environment=(root / "build/build-environment.txt").read_text(),
                  developerDir=os.environ.get("DEVELOPER_DIR"),
                  workflow={k: os.environ.get(k) for k in ["GITHUB_RUN_ID", "GITHUB_RUN_ATTEMPT", "GITHUB_JOB"]},
                  testCase=CASE, configuration="Debug")
    if not frozen["developerDir"] or not frozen["developerDir"].endswith("Xcode_16.4.app/Contents/Developer"):
        raise ValueError("Require the pinned Xcode 16.4 developer directory")
    frozen["versions"] = version_fields(frozen["environment"])
    save(folder / "prepared.json", frozen)


def target(plan):
    version = plan.get("__xctestrun_metadata__", {}).get("FormatVersion", 1)
    if version == 1:
        targets = [value for key, value in plan.items() if key == "XianxiaReaderTests" and isinstance(value, dict)]
    elif version == 2:
        targets = [value for config in plan.get("TestConfigurations", []) for value in config.get("TestTargets", [])
                   if value.get("BlueprintName") == "XianxiaReaderTests"]
    else:
        raise ValueError("Unreviewed xctestrun format")
    if len(targets) != 1 or not all(targets[0].get(k) for k in ["TestHostPath", "TestBundlePath"]):
        raise ValueError("Require exactly one hosted XianxiaReaderTests target")
    return targets[0]


def arm_plan(base, mode):
    if mode not in MODES:
        raise ValueError("Unknown pair mode")
    result = copy.deepcopy(base)
    selected = target(result)
    for name in ["EnvironmentVariables", "TestingEnvironmentVariables"]:
        if any(key in selected.get(name, {}) for key in [KEY, "TEST_RUNNER_" + KEY]):
            raise ValueError("Build run plan already contains a fixture override")
    env = selected.setdefault("EnvironmentVariables", {})
    env[KEY] = mode
    return result


def product_files(products, run_files):
    files = []
    for path in sorted(products.rglob("*")):
        if path in run_files or path.is_dir() and not path.is_symlink():
            continue
        name = path.relative_to(products).as_posix()
        if path.is_symlink():
            resolved = path.resolve(strict=True)
            if not resolved.is_relative_to(products.resolve()):
                raise ValueError("Product symlink escapes the frozen tree: " + name)
            files.append(dict(path=name, link=os.readlink(path)))
        else:
            files.append(dict(path=name, sha256=sha(path)))
    if not any(".app/" in f["path"] for f in files) or not any(".xctest/" in f["path"] for f in files):
        raise ValueError("Missing compiled App or XCTest products")
    return files


def execute(command, log, env=None):
    """Stream full output and persist the child's raw exit, independently of callers."""
    log.parent.mkdir(parents=True, exist_ok=True)
    receipt = dict(command=list(map(str, command)), startedUTC=datetime.now(timezone.utc).isoformat(), rawExit=None)
    save(log.with_suffix(".command.json"), receipt)
    with log.open("wb") as output:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
        receipt["pid"] = process.pid
        try:
            for line in process.stdout:
                output.write(line); output.flush()
                sys.stdout.buffer.write(line); sys.stdout.buffer.flush()
            process.wait()
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill(); process.wait()
            receipt.update(rawExit=process.returncode, endedUTC=datetime.now(timezone.utc).isoformat())
            process.stdout.close()
            save(log.with_suffix(".command.json"), receipt)
    return receipt


def code(raw):
    return raw if raw >= 0 else 128 - raw


def run_pair(root, simulator, runner=execute):
    folder = root / "build/ViewportPair"
    prepared = json.loads((folder / "prepared.json").read_text())
    result = dict(testCase=CASE, arms={}, originalExits=[None, None], matchedBuildVerified=False,
                  semanticPairCompatible=False, oldFullRootCauseProven=False, releaseAccepted=False)
    if (folder / "result.json").exists():
        raise ValueError("Pair driver has already run; no automatic retry")
    products = root / "build/DerivedData/Build/Products"
    candidates = list(products.glob("*.xctestrun"))
    if len(candidates) != 1:
        raise ValueError("Require exactly one original build-for-testing run plan")
    original = candidates[0]; base = plistlib.loads(original.read_bytes()); target(base)
    plans = {mode: products / ("XianxiaReader-" + mode + ".xctestrun") for mode in MODES}
    for mode, path in plans.items():
        path.write_bytes(plistlib.dumps(arm_plan(base, mode)))
        (folder / (mode + ".xctestrun")).write_bytes(path.read_bytes())
    (folder / "original.xctestrun").write_bytes(original.read_bytes())
    run_files = {original, *plans.values()}
    frozen = dict(prepared=prepared, products=product_files(products, run_files), originalPlanSHA256=sha(original),
                  normalizedPlanSHA256=digest(base), simulatorID=simulator,
                  planSHA256={mode: sha(path) for mode, path in plans.items()})
    save(folder / "build-manifest.json", frozen)

    def state():
        return dict(source=source_inputs(root), products=product_files(products, run_files),
                    originalPlanSHA256=sha(original), planSHA256={m: sha(p) for m, p in plans.items()},
                    environment=(root / "build/build-environment.txt").read_text(),
                    developerDir=os.environ.get("DEVELOPER_DIR"))

    expected = dict(source=prepared["source"], products=frozen["products"], originalPlanSHA256=frozen["originalPlanSHA256"],
                    planSHA256=frozen["planSHA256"], environment=prepared["environment"], developerDir=prepared["developerDir"])
    proofs = []
    try:
        for index, mode in enumerate(MODES):
            arm = folder / mode; arm.mkdir()
            row = dict(mode=mode, executed=False, originalExit=None, commands=[], validationErrors=[])
            result["arms"][mode] = row
            def command(args, name, env=None):
                receipt = runner(list(map(str, args)), arm / "logs" / (name + ".log"), env)
                row["commands"].append(receipt)
                save(arm / "exits.json", row)
                return receipt
            def checked(args, name):
                receipt = command(args, name)
                if receipt["rawExit"] != 0:
                    raise ValueError(name + " failed: " + str(receipt["rawExit"]))

            row["before"] = state(); save(arm / "before.json", row["before"])
            if row["before"] != expected:
                raise ValueError("Frozen source/build inputs drifted before " + mode)
            if plistlib.loads(plans[mode].read_bytes()) != arm_plan(base, mode):
                raise ValueError("Arm plan changed beyond its fixture mode")
            for name, args in [("xcode-version", ["xcodebuild", "-version"]),
                               ("swift-version", ["swift", "--version"]), ("os-version", ["sw_vers"])]:
                checked(args, name)
            environment = "".join((arm / ("logs/" + name + ".log")).read_text()
                                  for name in ["xcode-version", "swift-version", "os-version"])
            if version_fields(environment) != prepared["versions"]:
                raise ValueError("Actual Xcode/Swift/OS differs from the build environment")
            checked(["xcrun", "simctl", "list", "devices", "available", "--json"], "devices-before")
            inventory = json.loads((arm / "logs/devices-before.log").read_text())
            devices = [dict(d, runtime=runtime) for runtime, ds in inventory.get("devices", {}).items() for d in ds if d.get("udid") == simulator]
            if len(devices) != 1 or not devices[0].get("isAvailable") or not devices[0]["runtime"].endswith("iOS-18-5"):
                raise ValueError("Selected simulator configuration is unavailable")
            row["device"] = {k: devices[0].get(k) for k in ["udid", "name", "deviceTypeIdentifier", "runtime"]}
            if index and row["device"] != result["arms"][MODES[0]]["device"]:
                raise ValueError("Simulator configuration changed between arms")
            if devices[0]["state"] == "Booted":
                checked(["xcrun", "simctl", "shutdown", simulator], "shutdown")
            elif devices[0]["state"] != "Shutdown":
                raise ValueError("Unexpected simulator state; no retry")
            checked(["xcrun", "simctl", "bootstatus", simulator, "-b"], "boot")
            checked(["xcrun", "simctl", "ui", simulator, "appearance", "light"], "appearance")
            env = dict(os.environ); env.pop(KEY, None); env.pop("TEST_RUNNER_" + KEY, None)
            test = command(["xcodebuild", "test-without-building", "-xctestrun", plans[mode],
                            "-destination", "platform=iOS Simulator,id=" + simulator,
                            "-parallel-testing-enabled", "NO", "-test-iterations", "1",
                            "-resultBundlePath", arm / "DiagnosticTests.xcresult", "-only-testing:" + CASE], "reader-diagnostic", env)
            row.update(executed=True, originalExit=test["rawExit"], testProcessPID=test["pid"])
            result["originalExits"][index] = test["rawExit"]
            save(arm / "exits.json", row)  # The native exit survives even failed extraction/validation.
            summary = command(["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", arm / "DiagnosticTests.xcresult"], "summary")
            (arm / "test-results-summary.json").write_bytes((arm / "logs/summary.log").read_bytes())
            exported = command(["xcrun", "xcresulttool", "export", "attachments", "--path", arm / "DiagnosticTests.xcresult",
                                "--output-path", arm / "ReaderSnapshots"], "export")
            row["after"] = state(); save(arm / "after.json", row["after"])
            if row["after"] != expected:
                row["validationErrors"].append("Frozen source/build inputs drifted during the original test")
            if summary["rawExit"] == exported["rawExit"] == 0 and not row["validationErrors"]:
                try:
                    proof = verify_viewport_pair_arm(arm, mode, status=test["rawExit"])
                    proofs.append(proof)
                    save(arm / "fixture-receipt.json", proof)
                except (ValueError, KeyError, OSError) as error:
                    row["validationErrors"].append(str(error))
            save(arm / "exits.json", row)
            failure = next((code(x) for x in [test["rawExit"], summary["rawExit"], exported["rawExit"]] if x), 0)
            if row["validationErrors"]:
                failure = failure or 2
            if index == 0 and failure:
                result["stopReason"] = "Safe arm failed; conflict not started"
                return failure
            if index == 1:
                if len(proofs) == 2:
                    safe, conflict = (result["arms"][m] for m in MODES)
                    if safe["testProcessPID"] == conflict["testProcessPID"] or proofs[0]["fixture"]["nonce"] == proofs[1]["fixture"]["nonce"]:
                        raise ValueError("Require distinct test invocations and fixture instances")
                    compatible = compare_viewport_pair_receipts(*proofs)
                    result.update(semanticPairCompatible=compatible["semanticPairCompatible"], matchedBuildVerified=True,
                                  candidateObservation=compatible["candidateObservation"], testsPassed=not failure)
                return failure
        raise ValueError("Missing pair arm")
    except (ValueError, KeyError, OSError) as error:
        result["driverError"] = str(error)
        # A failed original test remains authoritative over later driver errors.
        return next((code(x) for x in result["originalExits"] if x), 2)
    finally:
        save(folder / "result.json", result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=["prepare", "run"])
    parser.add_argument("simulator", nargs="?")
    args = parser.parse_args()
    try:
        if args.phase == "prepare":
            prepare(Path.cwd()); return 0
        if not args.simulator:
            raise ValueError("run requires the selected simulator ID")
        return run_pair(Path.cwd(), args.simulator)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print("Viewport pair driver: " + str(error), file=sys.stderr)
        folder = Path.cwd() / "build/ViewportPair"
        if folder.is_dir():
            save(folder / "driver-error.json", dict(error=str(error), phase=args.phase))
        return code(error.returncode) if isinstance(error, subprocess.CalledProcessError) else 2


if __name__ == "__main__":
    sys.exit(main())
