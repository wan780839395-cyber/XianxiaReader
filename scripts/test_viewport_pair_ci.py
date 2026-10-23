"""Exercise pair routing, source/build proof and real exit handling without Xcode/CI."""
import copy
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import ci_viewport_pair as pair
import test_reader_positions_tools as fixtures

ROOT = Path(__file__).resolve().parents[1]
DEV = "/Applications/Xcode_16.4.app/Contents/Developer"
VERSIONS = {"xcode-version": "Xcode 16.4\nBuild version 16F6\n", "swift-version": "Apple Swift version 6.1.2\nTarget: x86_64-apple-macosx15.5\n", "os-version": "ProductName: macOS\nProductVersion: 15.5\nBuildVersion: 24F74\n"}


# Exact bytes from run 39886254329, attempt 1, source 978816c9:
# diagnostic/build-environment.txt and ViewportPair/paired-safe/logs/*-version.log.
# These small samples remain usable without downloading historical artifacts.
CAPTURED_ENVIRONMENT = (
    "Xcode 16.4\nBuild version 16F6\n"
    "Apple Swift version 6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5)\n"
    "Target: x86_64-apple-macosx15.0\n"
    "ProductName:\t\tmacOS\nProductVersion:\t\t15.7.9\nBuildVersion:\t\t24G830\n"
)
CAPTURED_VERSIONS = {
    "xcode-version": "Xcode 16.4\nBuild version 16F6\n",
    "swift-version": (
        "swift-driver version: 1.120.5 Apple Swift version 6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5)\n"
        "Target: x86_64-apple-macosx15.0\n"
    ),
    "os-version": "ProductName:\t\tmacOS\nProductVersion:\t\t15.7.9\nBuildVersion:\t\t24G830\n",
}


class VersionFieldsTests(unittest.TestCase):
    def test_real_stdout_and_merged_samples_keep_all_seven_fields(self):
        samples = {"environment": CAPTURED_ENVIRONMENT, **CAPTURED_VERSIONS}
        hashes = {
            "environment": "0e2e3b1bfdd7e49b6b4f2c8586123362e50845e8b379bb2aabfe5bd0c8b9e99b",
            "xcode-version": "a8be4f9af0a29137fe7e59b9928056d4a0df297bb46ba40f80eaa6b0ae982f12",
            "swift-version": "c787cdae4c1e5c4b19cdea9e1e6ba7f1064fae1dbbe4dc8f9a1bf952b1a7a087",
            "os-version": "31fd674ddb951680692d7b68cafdeab5baa6b3e82aae843269dad73b53f25fc5",
        }
        self.assertEqual({k: hashlib.sha256(v.encode()).hexdigest() for k, v in samples.items()}, hashes)
        expected = {
            "Xcode ": "16.4", "Build version ": "16F6",
            "Apple Swift version ": "6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5)",
            "Target:": "x86_64-apple-macosx15.0", "ProductName:": "macOS",
            "ProductVersion:": "15.7.9", "BuildVersion:": "24G830",
        }
        self.assertEqual(pair.version_fields(CAPTURED_ENVIRONMENT), expected)
        self.assertEqual(pair.version_fields("".join(CAPTURED_VERSIONS.values())), expected)

    def test_missing_empty_duplicate_or_conflicting_fields_are_rejected(self):
        lines = CAPTURED_ENVIRONMENT.splitlines(keepends=True)
        for index, line in enumerate(lines):
            prefix = next(p for p in pair.version_fields(CAPTURED_ENVIRONMENT) if line.startswith(p))
            for label, text in {
                "missing": "".join(lines[:index] + lines[index + 1:]),
                "empty": CAPTURED_ENVIRONMENT.replace(line, prefix + "\n"),
                "duplicate": CAPTURED_ENVIRONMENT + line,
                "conflict": CAPTURED_ENVIRONMENT + line.rstrip() + "-different\n",
            }.items():
                with self.subTest(field=prefix, kind=label), self.assertRaises(ValueError):
                    pair.version_fields(text)

    def test_prefixed_and_plain_compiler_rows_cannot_hide_duplicates(self):
        merged = "".join(CAPTURED_VERSIONS.values())
        plain = CAPTURED_ENVIRONMENT.splitlines(keepends=True)[2]
        prefixed = CAPTURED_VERSIONS["swift-version"].splitlines(keepends=True)[0]
        for extra in [plain, prefixed, plain.replace("6.1.2.1.2", "6.1.2.1.3")]:
            with self.subTest(extra=extra), self.assertRaises(ValueError):
                pair.version_fields(merged + extra)

    def test_unknown_driver_shapes_are_not_arbitrarily_stripped(self):
        merged = "".join(CAPTURED_VERSIONS.values())
        prefix = "swift-driver version: 1.120.5 "
        for unknown in ["swift-driver version: unknown ", "swift-driver version: 1.120 ",
                        "swift-driver version: 1.120.5 extra ", "warning: " + prefix]:
            with self.subTest(prefix=unknown), self.assertRaises(ValueError):
                pair.version_fields(merged.replace(prefix, unknown))
        with self.assertRaises(ValueError):
            pair.version_fields(CAPTURED_ENVIRONMENT + "swift-driver version: unknown\n")


class ViewportPairCITests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(); self.addCleanup(temp.cleanup); self.root = Path(temp.name)
        self.folder = self.root / "build/ViewportPair"
        for name in ["App/App.swift", "Tests/iOS/ReaderRenderingTests.swift", "Tests/Fixtures/reader-layout.epub", "Package.resolved", "project.yml"]:
            path = self.root / name; path.parent.mkdir(parents=True, exist_ok=True); path.write_text("original\n", encoding="utf-8", newline="\n")
        def git(*args):
            return subprocess.check_output(["git", *args], cwd=self.root, stderr=subprocess.DEVNULL)
        git("init", "-q"); git("add", "App", "Tests", "Package.resolved", "project.yml")
        git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", "commit", "-qm", "fixture source")
        self.env = patch.dict(os.environ, {"DEVELOPER_DIR": DEV, "GITHUB_SHA": git("rev-parse", "HEAD").decode().strip()})
        self.env.start(); self.addCleanup(self.env.stop)
        (self.root / "build").mkdir()
        (self.root / "build/build-environment.txt").write_text("".join(VERSIONS.values()), encoding="utf-8")
        pair.prepare(self.root)
        self.products = self.root / "build/DerivedData/Build/Products"
        self.products.mkdir(parents=True)
        for name in ["Debug-iphonesimulator/App.app/App", "Debug-iphonesimulator/App.app/PlugIns/XianxiaReaderTests.xctest/test"]:
            path = self.products / name; path.parent.mkdir(parents=True, exist_ok=True); path.write_bytes(b"compiled fixture")
        self.base = {"__xctestrun_metadata__": {"FormatVersion": 1}, "XianxiaReaderTests": {
            "TestHostPath": "__TESTROOT__/Debug-iphonesimulator/App.app/App",
            "TestBundlePath": "__TESTHOST__/PlugIns/XianxiaReaderTests.xctest", "EnvironmentVariables": {"EXISTING": "kept"}}}
        (self.products / "original.xctestrun").write_bytes(plistlib.dumps(self.base))
        self.calls = []; self.status = {m: 0 for m in pair.MODES}; self.export_exit = 0
        self.mutate = None; self.bad_safe = False; self.duplicate_pid = False; self.duplicate_nonce = False; self.version_drift = False
        self.versions = VERSIONS.copy()

    def runner(self, command, log, env=None):
        mode = log.relative_to(self.folder).parts[0]; self.calls.append((mode, command))
        log.parent.mkdir(parents=True, exist_ok=True); raw = 0; body = "fixture command\n"
        if log.stem in VERSIONS:
            body = self.versions[log.stem]
            if self.version_drift and mode == pair.MODES[1]:
                body = body.replace("16F6", "16F7")
        elif command[:4] == ["xcrun", "simctl", "list", "devices"]:
            body = json.dumps({"devices": {"com.apple.CoreSimulator.SimRuntime.iOS-18-5": [dict(udid="SIM", name="iPhone", deviceTypeIdentifier="iPhone-type", isAvailable=True, state="Shutdown" if mode == pair.MODES[0] else "Booted")]}})
        elif command[:2] == ["xcodebuild", "test-without-building"]:
            self.assertEqual(command.count("-only-testing:" + pair.CASE), 1)
            self.assertNotIn(pair.KEY, env); self.assertNotIn("TEST_RUNNER_" + pair.KEY, env)
            self.assertEqual(plistlib.loads(Path(command[command.index("-xctestrun") + 1]).read_bytes()), pair.arm_plan(self.base, mode))
            self.assertIn("-test-iterations", command); self.assertNotIn("-retry-tests-on-failure", command)
            raw = self.status[mode]
            sample = fixtures.PositionEvidenceTests.pair_fixture(None, mode, status=raw)
            row, base, summary, resize = sample
            row["nonce"] = "duplicate" if self.duplicate_nonce else mode
            for e in row["events"]:
                e["nonce"] = row["nonce"]
            body = base + "CONTINUOUS_VIEWPORT_PAIR " + json.dumps(row) + "\n" + "".join("CONTINUOUS_RESIZE_EVIDENCE " + json.dumps(r) + "\n" for r in resize)
            if self.bad_safe and mode == pair.MODES[0]:
                body = base
            result = Path(command[command.index("-resultBundlePath") + 1]); result.mkdir()
            (result / "original-result").write_text(str(raw))
        elif command[:5] == ["xcrun", "xcresulttool", "get", "test-results", "summary"]:
            body = json.dumps(fixtures.PositionEvidenceTests.pair_fixture(None, mode, status=self.status[mode])[2])
        elif command[:3] == ["xcrun", "xcresulttool", "export"]:
            raw = self.export_exit
            path = Path(command[-1]); path.mkdir(); (path / "original.txt").write_text("kept even after 65")
            if self.mutate:
                self.mutate(mode)
        log.write_text(body, encoding="utf-8")
        return dict(command=command, rawExit=raw, pid=123 if self.duplicate_pid else 1000 + len(self.calls))

    def run_driver(self):
        status = pair.run_pair(self.root, "SIM", runner=self.runner)
        return status, json.loads((self.folder / "result.json").read_text())

    def captured_versions(self):
        self.versions = CAPTURED_VERSIONS.copy()
        (self.root / "build/build-environment.txt").write_text(CAPTURED_ENVIRONMENT, encoding="utf-8")
        prepared = json.loads((self.folder / "prepared.json").read_text())
        prepared.update(environment=CAPTURED_ENVIRONMENT, versions=pair.version_fields(CAPTURED_ENVIRONMENT))
        pair.save(self.folder / "prepared.json", prepared)

    def test_real_prefixed_versions_pass_both_local_driver_arms(self):
        self.captured_versions()
        status, report = self.run_driver()
        self.assertEqual(status, 0); self.assertEqual(report["originalExits"], [0, 0])
        self.assertTrue(report["matchedBuildVerified"])
        self.assertEqual((self.folder / "paired-safe/logs/swift-version.log").read_text(), CAPTURED_VERSIONS["swift-version"])

    def test_real_prefixed_compiler_build_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["swift-version"] = self.versions["swift-version"].replace("6.1.2.1.2", "6.1.2.1.3")
        self.assert_version_rejected_before_safe_test()

    def test_real_prefixed_target_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["swift-version"] = self.versions["swift-version"].replace("x86_64", "arm64")
        self.assert_version_rejected_before_safe_test()

    def test_real_xcode_version_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["xcode-version"] = self.versions["xcode-version"].replace("16.4", "16.3")
        self.assert_version_rejected_before_safe_test("Require actual Xcode 16.4")

    def test_real_xcode_build_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["xcode-version"] = self.versions["xcode-version"].replace("16F6", "16F7")
        self.assert_version_rejected_before_safe_test()

    def test_real_os_product_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["os-version"] = self.versions["os-version"].replace("macOS", "otherOS")
        self.assert_version_rejected_before_safe_test()

    def test_real_os_version_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["os-version"] = self.versions["os-version"].replace("15.7.9", "15.7.8")
        self.assert_version_rejected_before_safe_test()

    def test_real_os_build_drift_stops_before_safe_test(self):
        self.captured_versions()
        self.versions["os-version"] = self.versions["os-version"].replace("24G830", "24G831")
        self.assert_version_rejected_before_safe_test()

    def assert_version_rejected_before_safe_test(self, message="Actual Xcode/Swift/OS"):
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertEqual(report["originalExits"], [None, None])
        self.assertFalse(report["matchedBuildVerified"])
        self.assertIn(message, report["driverError"])
        self.assertFalse(any(c[0] == "xcrun" or c[:2] == ["xcodebuild", "test-without-building"] for _, c in self.calls))
        self.assertFalse(any(mode == pair.MODES[1] for mode, _ in self.calls))

    def test_fresh_two_arms_share_products_and_only_mode_differs(self):
        status, report = self.run_driver()
        self.assertEqual(status, 0); self.assertEqual(report["originalExits"], [0, 0])
        self.assertTrue(report["matchedBuildVerified"]); self.assertTrue(report["semanticPairCompatible"])
        self.assertFalse(report["releaseAccepted"]); self.assertFalse(report["oldFullRootCauseProven"])
        commands = [c for _, c in self.calls]
        self.assertEqual(sum(c[:2] == ["xcodebuild", "test-without-building"] for c in commands), 2)
        self.assertFalse(any("build-for-testing" in c or "test" in c for c in commands))
        self.assertEqual(sum(c[:3] == ["xcrun", "simctl", "shutdown"] for c in commands), 1)
        self.assertEqual(sum(c[:3] == ["xcrun", "simctl", "bootstatus"] for c in commands), 2)
        self.assertNotEqual(report["arms"][pair.MODES[0]]["testProcessPID"], report["arms"][pair.MODES[1]]["testProcessPID"])
        with self.assertRaises(ValueError):
            pair.run_pair(self.root, "SIM", runner=self.runner)

    def test_safe_failure_never_starts_conflict_and_keeps_native_65(self):
        self.status[pair.MODES[0]] = 65
        status, report = self.run_driver()
        self.assertEqual(status, 65); self.assertEqual(report["originalExits"], [65, None])
        self.assertEqual(set(report["arms"]), {pair.MODES[0]})
        self.assertFalse(any(mode == pair.MODES[1] for mode, _ in self.calls))
        self.assertTrue((self.folder / "paired-safe/DiagnosticTests.xcresult/original-result").is_file())
        self.assertTrue((self.folder / "paired-safe/ReaderSnapshots/original.txt").is_file())

    def test_conflict_65_is_a_failed_driver_even_for_qualified_word_fault(self):
        self.status[pair.MODES[1]] = 65
        status, report = self.run_driver()
        self.assertEqual(status, 65); self.assertEqual(report["originalExits"], [0, 65])
        self.assertTrue(report["matchedBuildVerified"])
        self.assertEqual(report["candidateObservation"], "candidate-controlled-word-failure")
        self.assertFalse(report["testsPassed"]); self.assertFalse(report["releaseAccepted"])

    def test_failed_safe_evidence_or_export_stops_even_if_original_exit_zero(self):
        self.bad_safe = True
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertEqual(report["originalExits"], [0, None])
        self.assertTrue(report["arms"][pair.MODES[0]]["validationErrors"])
        self.assertFalse(report["matchedBuildVerified"])

    def test_export_error_does_not_replace_original_65(self):
        self.status[pair.MODES[0]] = 65; self.export_exit = 23
        status, report = self.run_driver()
        self.assertEqual(status, 65); self.assertEqual(report["originalExits"], [65, None])
        self.assertEqual(report["arms"][pair.MODES[0]]["commands"][-1]["rawExit"], 23)

    def test_export_failure_after_native_pass_also_stops_conflict(self):
        self.export_exit = 23
        status, report = self.run_driver()
        self.assertEqual(status, 23); self.assertEqual(report["originalExits"], [0, None])
        self.assertFalse(report["matchedBuildVerified"])

    def test_actual_environment_drift_stops_before_conflict_test(self):
        text = "".join(VERSIONS.values())
        self.assertEqual(pair.version_fields(text + "unrelated warning\n"), pair.version_fields(text))
        with self.assertRaises(ValueError): pair.version_fields(text.replace("Xcode 16.4", "Xcode 26"))
        self.version_drift = True
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertEqual(report["originalExits"], [0, None])
        self.assertIn("Actual Xcode/Swift/OS", report["driverError"])

    def test_reused_process_identity_is_not_fresh_pair_evidence(self):
        self.duplicate_pid = True
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertFalse(report["matchedBuildVerified"])

    def test_product_or_plan_mutation_is_rejected_before_conflict(self):
        self.mutate = lambda mode: (self.products / "Debug-iphonesimulator/App.app/App").write_bytes(b"changed")
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertEqual(report["originalExits"], [0, None])
        self.assertFalse(report["matchedBuildVerified"])

    def test_source_mutation_is_not_hidden_by_stable_declared_commit(self):
        self.mutate = lambda mode: (self.root / "Tests/Fixtures/reader-layout.epub").write_text("different book")
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertEqual(report["originalExits"], [0, None])
        self.assertIn("Source differs", report["driverError"])

    def test_same_fixture_nonce_cannot_qualify_as_two_fresh_instances(self):
        self.duplicate_nonce = True
        status, report = self.run_driver()
        self.assertEqual(status, 2); self.assertFalse(report["matchedBuildVerified"])

    def test_run_plans_support_two_known_formats_and_reject_extra_overrides(self):
        for base in [self.base, {"__xctestrun_metadata__": {"FormatVersion": 2}, "TestConfigurations": [{"TestTargets": [dict(self.base["XianxiaReaderTests"], BlueprintName="XianxiaReaderTests")]}]}]:
            untouched = copy.deepcopy(base)
            for mode in pair.MODES:
                plan = pair.arm_plan(base, mode)
                self.assertEqual(pair.target(plan)["EnvironmentVariables"].pop(pair.KEY), mode)
                self.assertEqual(plan, base)
            self.assertEqual(base, untouched)
        bad = copy.deepcopy(self.base); bad["__xctestrun_metadata__"]["FormatVersion"] = 3
        with self.assertRaises(ValueError): pair.arm_plan(bad, pair.MODES[0])
        bad = pair.arm_plan(self.base, pair.MODES[0])
        with self.assertRaises(ValueError): pair.arm_plan(bad, pair.MODES[1])
        bad = copy.deepcopy(self.base); bad["XianxiaReaderTests"]["TestingEnvironmentVariables"] = {pair.KEY: "smoke"}
        with self.assertRaises(ValueError): pair.arm_plan(bad, pair.MODES[0])

    def test_raw_subprocess_exit_is_persisted_without_shell_masking(self):
        for raw in [0, 65, 23]:
            log = self.root / ("child-" + str(raw) + ".log")
            result = pair.execute([sys.executable, "-c", "print('raw child');raise SystemExit(" + str(raw) + ")"], log)
            self.assertEqual(result["rawExit"], raw)
            self.assertEqual(json.loads(log.with_suffix(".command.json").read_text())["rawExit"], raw)

    def test_only_explicit_pair_route_runs_and_always_uploads_original_evidence(self):
        from check_repository import yaml
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        selection = "continuous-resize-pair"; jobs = workflow["jobs"]
        self.assertIn(selection, workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= '" + selection + "'", jobs[name]["if"])
        self.assertNotIn("== '" + selection + "'", jobs["ios"]["if"])
        self.assertIn("== '" + selection + "'", jobs["reader-positions"]["if"])
        steps = [s for s in jobs["reader-positions"]["steps"] if s.get("name") == "Run matched viewport arms from one build and keep original exits"]
        self.assertEqual(len(steps), 1); self.assertIn("set -euo pipefail", steps[0]["run"])
        upload = next(s for s in jobs["reader-positions"]["steps"] if s.get("uses", "").startswith("actions/upload-artifact"))
        self.assertEqual(upload["if"], "always()"); self.assertIn("build/ViewportPair/", upload["with"]["path"])
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        self.assertIn('exec python3 scripts/ci_viewport_pair.py run "$SIMULATOR_ID"', shell)
        self.assertEqual(shell.count("xcodebuild build-for-testing"), 1)
        bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
        executable = str(bash) if os.name == "nt" and bash.is_file() else shutil.which("bash")
        self.assertIsNotNone(executable)
        subprocess.run([executable, "-n", "scripts/ci_reader_diagnostic.sh"], cwd=ROOT, check=True, capture_output=True)


if __name__ == "__main__":
    unittest.main()
