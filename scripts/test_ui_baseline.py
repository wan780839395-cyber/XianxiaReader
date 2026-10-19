import subprocess
import tempfile
from pathlib import Path
import unittest

from verify_ui_baseline import check_environment, check_metadata, check_protected_inputs, check_ui_log, check_unit_summary


class UIBaselineTests(unittest.TestCase):
    expected = {("ReaderTests", "testOne"), ("ReaderTests", "testTwo")}

    def log(self, method, result="passed"):
        return f"Test Case '-[XianxiaReaderUITests.ReaderTests {method}]' {result} (0.1 seconds).\n"

    def test_complete_real_ui_log_is_accepted(self):
        check_ui_log(self.log("testOne") + self.log("testTwo"), self.expected)

    def test_missing_extra_and_repeated_cases_are_rejected(self):
        for value in [self.log("testOne"), self.log("testOne") + self.log("testTwo") + self.log("testThree"),
                      self.log("testOne") * 2 + self.log("testTwo")]:
            with self.subTest(log=value), self.assertRaises(ValueError):
                check_ui_log(value, self.expected)

    def test_failure_then_pass_and_skips_are_not_hidden(self):
        for result in ["failed", "skipped"]:
            with self.subTest(result=result), self.assertRaises(ValueError):
                check_ui_log(self.log("testOne", result) + self.log("testOne") + self.log("testTwo"), self.expected)

    def test_unrelated_unit_failure_does_not_fabricate_a_ui_failure(self):
        check_ui_log("Test Case '-[XianxiaReaderTests.Renderer testLoad]' failed (0.1 seconds).\n"
                     + self.log("testOne") + self.log("testTwo"), self.expected)

    def test_metadata_requires_completed_matching_source(self):
        check_metadata(dict(status="completed", headSha="abc", conclusion="failure"), "abc")
        for metadata in [dict(status="in_progress", headSha="abc", conclusion=""),
                         dict(status="completed", headSha="other", conclusion="success"),
                         dict(status="completed", headSha="abc", conclusion="cancelled")]:
            with self.subTest(metadata=metadata), self.assertRaises(ValueError):
                check_metadata(metadata, "abc")

    def test_toolchain_runtime_model_and_host_architecture_must_match(self):
        baseline = dict(xcode="Xcode 16.4", xcodeBuild="Build version 16F6", hostTarget="Target: arm64",
                        simulatorOS="18.5", simulatorModel="iPhone 16 Pro")
        environment = "Xcode 16.4\nBuild version 16F6\nTarget: arm64\n"
        devices = {"SimRuntime.iOS-18-5": [dict(udid="device", name="iPhone 16 Pro")]}
        check_environment(environment, devices, "device", baseline)
        variants = [(environment.replace("16.4", "16.3"), devices, "device"),
                    (environment.replace("arm64", "x86_64"), devices, "device"),
                    (environment, {"SimRuntime.iOS-18-4": devices["SimRuntime.iOS-18-5"]}, "device"),
                    (environment, {"SimRuntime.iOS-18-5": [dict(udid="device", name="iPad")]}, "device"),
                    (environment, devices, "missing")]
        for value in variants:
            with self.subTest(value=value), self.assertRaises(ValueError):
                check_environment(*value, baseline)

    def test_current_unit_gate_rejects_failure_skip_or_missing_test(self):
        check_unit_summary(dict(result="Passed", totalTestCount=145, passedTests=145, failedTests=0, skippedTests=0))
        for value in [dict(result="Failed", totalTestCount=145, passedTests=144, failedTests=1, skippedTests=0),
                      dict(result="Passed", totalTestCount=145, passedTests=144, failedTests=0, skippedTests=1),
                      dict(result="Passed", totalTestCount=144, passedTests=144, failedTests=0, skippedTests=0),
                      dict(result="Failed", totalTestCount=145, passedTests=145, failedTests=0, skippedTests=0),
                      dict(result="Passed", totalTestCount=145, passedTests=145, failedTests=0, skippedTests=0,
                           testFailures=["an inconsistent failure must not be hidden"])]:
            with self.subTest(summary=value), self.assertRaises(ValueError):
                check_unit_summary(value)

    def test_git_guard_allows_unit_harness_change_but_rejects_app_or_ui_change(self):
        previous = Path.cwd()
        with tempfile.TemporaryDirectory(prefix="xr-ui-baseline-") as folder:
            import os
            os.chdir(folder)
            try:
                subprocess.run(["git", "init", "--quiet"], check=True)
                subprocess.run(["git", "config", "core.autocrlf", "false"], check=True)
                for name in ["App/Reader.swift", "Tests/UI/ReaderTests.swift", "Tests/iOS/Renderer.swift"]:
                    path = Path(name); path.parent.mkdir(parents=True, exist_ok=True); path.write_text("original\n")
                subprocess.run(["git", "add", "."], check=True)
                subprocess.run(["git", "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                                "commit", "--quiet", "-m", "fixture"], check=True)
                Path("Tests/iOS/Renderer.swift").write_text("changed unit harness\n")
                check_protected_inputs("HEAD", None)
                for name in ["App/Reader.swift", "Tests/UI/ReaderTests.swift"]:
                    Path(name).write_text("changed protected input\n")
                    with self.assertRaises(subprocess.CalledProcessError):
                        check_protected_inputs("HEAD", None)
                    Path(name).write_text("original\n")
            finally:
                os.chdir(previous)


if __name__ == "__main__":
    unittest.main()
