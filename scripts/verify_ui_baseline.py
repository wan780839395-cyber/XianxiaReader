"""Reuse only real, complete UI coverage with identical protected inputs."""
from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

PROTECTED_INPUTS = (
    "App", "Packages", "Vendor", "Tests/UI", "Tests/Fixtures", "project.yml",
    "Package.resolved", ".gitattributes", "scripts/select_simulator.py",
    "scripts/resolve_local_readium.sh",
)


def check_metadata(metadata: dict, revision: str) -> None:
    if metadata.get("status") != "completed" or metadata.get("headSha") != revision:
        raise ValueError("UI baseline is incomplete or belongs to another revision")
    if metadata.get("conclusion") not in {"success", "failure"}:
        raise ValueError("Cancelled or interrupted runs cannot establish UI coverage")


def check_ui_log(log: str, expected: set[tuple[str, str]]) -> None:
    entries = re.findall(
        r"Test Case '-\[XianxiaReaderUITests\.([^ ]+) ([^\]]+)\]' (passed|failed|skipped)",
        log,
    )
    passed = [(cls, method) for cls, method, result in entries if result == "passed"]
    if any(result != "passed" for _, _, result in entries):
        raise ValueError("UI baseline includes a failure or skip; a later pass does not erase it")
    if set(passed) != expected or any(count != 1 for count in Counter(passed).values()):
        raise ValueError("UI baseline has missing, extra or repeated cases")


def check_protected_inputs(baseline: str, revision: str | None) -> None:
    revisions = [baseline, revision] if revision else [baseline]
    subprocess.run(["git", "diff", "--exit-code", *revisions, "--", *PROTECTED_INPUTS],
                   check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def check_environment(environment: str, devices: dict, simulator_id: str, baseline: dict) -> None:
    lines = environment.splitlines()
    if lines[:2] != [baseline["xcode"], baseline["xcodeBuild"]] or baseline["hostTarget"] not in lines:
        raise ValueError("UI baseline uses a different Xcode/SDK toolchain or host architecture")
    selected = [(runtime, device) for runtime, items in devices.items() for device in items
                if device["udid"] == simulator_id]
    suffix = "iOS-" + baseline["simulatorOS"].replace(".", "-")
    if len(selected) != 1 or not selected[0][0].endswith(suffix) or selected[0][1]["name"] != baseline["simulatorModel"]:
        raise ValueError("UI baseline uses a different simulator OS or model")


def check_unit_summary(summary: dict) -> None:
    if not (summary.get("result") == "Passed" and not summary.get("testFailures")
            and summary.get("totalTestCount") == summary.get("passedTests") == 163
            and summary.get("failedTests") == summary.get("skippedTests") == 0):
        raise ValueError("All 163 current unit/integration tests must pass without skips before Release")


def check_full_summary(summary: dict) -> None:
    if not (summary.get("result") == "Passed" and not summary.get("testFailures")
            and summary.get("totalTestCount") == summary.get("passedTests") == 192
            and summary.get("failedTests") == summary.get("skippedTests") == 0):
        raise ValueError("All 192 current integration/UI tests must pass without skips before Release")


def capture(command: list[str], stem: str) -> bytes:
    folder = Path("build/logs")
    folder.mkdir(parents=True, exist_ok=True)
    for attempt in range(1, 3):
        try:
            result = subprocess.run(command, capture_output=True, timeout=45)
        except subprocess.TimeoutExpired as error:
            (folder / f"{stem}-{attempt}.stderr.log").write_bytes(
                (error.stderr or b"") + b"\nGitHub baseline request timed out\n")
            if attempt == 2:
                raise
            continue
        (folder / f"{stem}-{attempt}.stderr.log").write_bytes(result.stderr)
        if result.returncode == 0:
            return result.stdout
        if attempt == 2:
            raise subprocess.CalledProcessError(result.returncode, command, result.stdout, result.stderr)
    raise RuntimeError("UI baseline fetch did not complete")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gh", default="gh")
    parser.add_argument("--revision", default=os.environ.get("GITHUB_SHA", "HEAD"))
    parser.add_argument("--simulator-id")
    parser.add_argument("--unit-summary", type=Path)
    parser.add_argument("--full-summary", type=Path)
    args = parser.parse_args()
    if args.full_summary:
        check_full_summary(json.loads(args.full_summary.read_text(encoding="utf-8")))
        print("Current full coverage verified: 192/192, failed/skipped 0.")
        return
    if args.unit_summary:
        check_unit_summary(json.loads(args.unit_summary.read_text(encoding="utf-8")))
        print("Current unit/integration coverage verified: 163/163, failed/skipped 0.")
        return
    if not args.simulator_id:
        parser.error("--simulator-id is required to verify prior UI coverage")
    baseline = json.loads(Path("Documentation/ValidationLogs/reader-ui-baseline-build30.json").read_text(encoding="utf-8"))
    revision = baseline["baselineRevision"]
    repository = baseline["repository"]
    if os.environ.get("GITHUB_REPOSITORY", repository) != repository:
        raise ValueError("Establish a UI baseline in this repository before reusing coverage")
    if subprocess.run(["git", "cat-file", "-e", revision + "^{commit}"], capture_output=True).returncode:
        subprocess.run(["git", "fetch", "--no-tags", "--depth=1", "origin", revision], check=True)
    check_protected_inputs(revision, args.revision)
    environment = Path("build/build-environment.txt").read_text(encoding="utf-8")
    devices = json.loads(Path("build/devices.json").read_text(encoding="utf-8"))["devices"]
    check_environment(environment, devices, args.simulator_id, baseline)
    run = str(baseline["baselineRun"])
    metadata = json.loads(capture([args.gh, "run", "view", run, "--repo", repository,
                                   "--json", "headSha,status,conclusion"], "ui-baseline-metadata"))
    check_metadata(metadata, revision)
    log = capture([args.gh, "run", "view", run, "--repo", repository, "--log"], "ui-baseline-log")
    Path(f"build/logs/ui-baseline-{run}.log").write_bytes(log)
    expected = {tuple(case) for case in baseline["uiCases"]}
    if len(expected) != baseline["uiCount"] or len(expected) != 28:
        raise ValueError("The audited baseline must include every one of the 28 UI-target cases")
    check_ui_log(log.decode("utf-8"), expected)
    receipt = dict(baselineRun=int(run), baselineRevision=revision, currentRevision=args.revision,
                   baselineOverallConclusion=metadata["conclusion"], uiPassed=28, uiFailed=0,
                   protectedInputs=list(PROTECTED_INPUTS), protectedInputsIdentical=True,
                   xcode=baseline["xcode"], simulatorOS=baseline["simulatorOS"],
                   logSHA256=hashlib.sha256(log).hexdigest(), unitTestsRequiredInCurrentJob=True)
    Path("build/ui-baseline-receipt.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(f"Verified prior UI coverage: 28/28 from {run}/{revision}; protected inputs identical.")
    print("Prior overall failure remains recorded; all unit/integration tests must pass in this job before Release.")


if __name__ == "__main__":
    main()
