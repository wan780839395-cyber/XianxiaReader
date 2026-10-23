"""Exercise the real CI shell control flow without claiming an iOS build."""
import os
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


class CIFailurePathTests(unittest.TestCase):
    def test_preflights_propagate_failure_and_preserve_separate_success_evidence(self):
        from check_repository import yaml, ROOT
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        git_bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
        bash = str(git_bash) if os.name == "nt" and git_bash.is_file() else shutil.which("bash")
        self.assertIsNotNone(bash)
        specifications = [
            ("Targeted font race preflight before full validation", "font-preflight.log", "FontPreflightSnapshots", "font-preflight-summary.json"),
            ("Targeted continuous rotation preflight before full validation", "continuous-rotation-preflight.log", "ContinuousRotationPreflightSnapshots", "continuous-rotation-preflight-summary.json"),
        ]
        for name, log, snapshots, success_summary in specifications:
            preflight, = [step["run"] for step in workflow["jobs"]["ios"]["steps"] if step.get("name") == name]
            for code in (0, 65, 23):
                with self.subTest(preflight=name, exit=code), tempfile.TemporaryDirectory() as folder:
                    root = Path(folder)
                    (root / "scripts").mkdir()
                    (root / "scripts/ci_reader_diagnostic.sh").write_text(
                        "mkdir -p build/ReaderSnapshots\n"
                        "echo original-summary > build/test-results-summary.json\n"
                        "echo original-attachment > build/ReaderSnapshots/native.txt\n"
                        f"echo ORIGINAL-TEST-EXIT-{code}\nexit {code}\n", encoding="utf-8", newline="\n")
                    result = subprocess.run([bash, "-c", preflight + "\necho FULL-AND-RELEASE\n"],
                                            cwd=root, text=True, capture_output=True)
                    self.assertEqual(result.returncode, code, result.stderr)
                    self.assertIn(f"ORIGINAL-TEST-EXIT-{code}", (root / "build/logs" / log).read_text())
                    prefix = snapshots if code == 0 else "ReaderSnapshots"
                    self.assertEqual((root / "build" / prefix / "native.txt").read_text().strip(), "original-attachment")
                    summary = success_summary if code == 0 else "test-results-summary.json"
                    self.assertEqual((root / "build" / summary).read_text().strip(), "original-summary")
                    self.assertEqual("FULL-AND-RELEASE" in result.stdout, code == 0)

    def run_section(self, test_exit, export_exit, summary_exit=0, video_exit=0, skipped_tests=0,
                    stop_after=0, source_drift=False, scope="full"):
        script = (Path(__file__).parent / "ci_ios.sh").read_text(encoding="utf-8")
        section = script[script.index("test_status=0\n"):script.index("\nxcodebuild build ")]
        boundary = script[script.index("# Integration-only is opt-in."):script.index("\nxcodebuild -version")]
        git_bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
        bash = str(git_bash) if os.name == "nt" and git_bash.is_file() else shutil.which("bash")
        self.assertIsNotNone(bash, "Bash required to verify CI failure propagation")
        harness = """set -euo pipefail
SIMULATOR_ID=test
video_pid=test
stop_simulator_recording() { return "$XR_VIDEO_EXIT"; }
xcodebuild() {
  echo TEST
  if [[ "$XR_SOURCE_DRIFT" == 1 ]]; then echo changed >> Tests/iOS/ReaderRenderingTests.swift; fi
  return "$XR_TEST_EXIT"
}
python3() { "$XR_FIXTURE_PYTHON" "$@"; }
xcrun() {
  if [[ "$1 $2 $3" == "xcresulttool get test-results" ]]; then
    printf '{"result":"Passed","totalTestCount":192,"passedTests":%d,"failedTests":0,"skippedTests":%d}\n' "$((192-XR_SKIPPED_TESTS))" "$XR_SKIPPED_TESTS"
    return "$XR_SUMMARY_EXIT"
  fi
  echo EXPORT; return "$XR_EXPORT_EXIT";
}
""" + boundary + "\n" + section + "\necho RELEASE\n"
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / "scripts").mkdir()
            shutil.copyfile(Path(__file__).parent / "verify_ui_baseline.py", Path(directory) / "scripts/verify_ui_baseline.py")
            (Path(directory) / "build").mkdir()
            (Path(directory) / "build/InteractionVideo").mkdir()
            (Path(directory) / "build/InteractionVideo/library-interactions.mp4").write_bytes(b"control-flow fixture, not a real recording")
            (Path(directory) / "build/build-environment.txt").write_text("control-flow fixture, not native toolchain evidence\n")
            fixture_env = {k:v for k,v in os.environ.items() if k not in ["GIT_INDEX_FILE", "GIT_DIR", "GIT_WORK_TREE", "GITHUB_SHA"]}
            if str(stop_after) == "1" and scope == "full":
                for name in ["ci_viewport_pair.py", "verify_reader_positions.py"]:
                    shutil.copyfile(Path(__file__).parent/name,Path(directory)/"scripts"/name)
                for name in ["Package.resolved", "project.yml", "Tests/Fixtures/reader-layout.epub", "Tests/iOS/ReaderRenderingTests.swift"]:
                    path=Path(directory)/name;path.parent.mkdir(parents=True,exist_ok=True)
                    path.write_bytes(b"original control-flow fixture\n")
                (Path(directory)/".gitattributes").write_bytes(b"* -text\n")
                (Path(directory)/".gitignore").write_bytes(b"__pycache__/\nbuild/\n")
                for command in [["git","init","--quiet"],["git","add","."],
                                ["git","-c","user.name=Fixture","-c","user.email=fixture@example.invalid","commit","--quiet","-m","fixture"]]:
                    subprocess.run(command,cwd=directory,env=fixture_env,check=True,capture_output=True)
            result = subprocess.run([bash, "-c", harness], text=True, capture_output=True, cwd=directory,
                                  env={**fixture_env, "XR_TEST_EXIT": str(test_exit), "XR_EXPORT_EXIT": str(export_exit),
                                       "XR_SUMMARY_EXIT": str(summary_exit), "XR_VIDEO_EXIT": str(video_exit),
                                       "XR_SKIPPED_TESTS": str(skipped_tests), "IOS_TEST_SCOPE": scope,
                                       "IOS_STOP_AFTER_FULL_TESTS": str(stop_after), "XR_SOURCE_DRIFT":str(int(source_drift)),
                                       "XR_FIXTURE_PYTHON": Path(sys.executable).as_posix()})
            receipt=Path(directory)/"build/I6Integration/acceptance.json"
            result.acceptance=json.loads(receipt.read_text()) if receipt.exists() else None
            return result

    def test_full_integration_stops_only_after_real_original_gates(self):
        result=self.run_section(0,0,stop_after=1)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertNotIn("RELEASE",result.stdout.replace("NO_DEVICE_RELEASE",""))
        self.assertIn("FULL_INTEGRATION_ACCEPTED_NO_DEVICE_RELEASE",result.stdout)
        self.assertEqual(result.acceptance["kind"],"full-integration-only")
        self.assertEqual(result.acceptance["summary"]["passedTests"],192)
        self.assertTrue(result.acceptance["inputsMatched"])
        self.assertFalse(result.acceptance["deviceReleaseExecuted"])
        self.assertFalse(result.acceptance["ipaProduced"])

    def test_full_integration_failures_keep_original_exits_and_block_success_receipt(self):
        for test,export,summary,video in [(65,23,47,29),(0,23,0,0),(0,0,47,0),(0,0,0,29)]:
            with self.subTest(exits=(test,export,summary,video)):
                result=self.run_section(test,export,summary_exit=summary,video_exit=video,stop_after=1)
                self.assertEqual(result.returncode,test or export or summary or video,result.stderr)
                self.assertNotIn("FULL_INTEGRATION_ACCEPTED",result.stdout)
                self.assertNotIn("RELEASE",result.stdout)
                self.assertIsNone(result.acceptance)
        skipped=self.run_section(0,0,skipped_tests=1,stop_after=1)
        self.assertNotEqual(skipped.returncode,0)
        self.assertIn("All 192",skipped.stderr)
        self.assertIsNone(skipped.acceptance)

    def test_full_integration_source_drift_blocks_success_but_not_original_failure(self):
        for test in [0,65]:
            result=self.run_section(test,0,stop_after=1,source_drift=True)
            self.assertNotEqual(result.returncode,0)
            if test:self.assertEqual(result.returncode,test)
            self.assertIn("Source differs from the selected commit",result.stderr)
            self.assertIsNone(result.acceptance)
            self.assertNotIn("RELEASE",result.stdout)

    def test_full_integration_flag_cannot_select_partial_scope_or_unknown_mode(self):
        for flag,scope in [("invalid","full"),(1,"unit-release")]:
            result=self.run_section(0,0,stop_after=flag,scope=scope)
            self.assertEqual(result.returncode,2,result.stderr)
            self.assertNotIn("TEST",result.stdout)
            self.assertNotIn("RELEASE",result.stdout)

    def test_workflow_stop_flag_is_opt_in_and_blocks_IPA_upload(self):
        from check_repository import yaml,ROOT
        workflow=yaml.load((ROOT/".github/workflows/ios-build.yml").read_text(encoding="utf-8"),Loader=yaml.BaseLoader)
        flag=workflow["on"]["workflow_dispatch"]["inputs"]["stop_after_full_tests"]
        self.assertEqual(flag["type"],"boolean");self.assertEqual(flag["default"],"false")
        self.assertIn("inputs.stop_after_full_tests",workflow["jobs"]["ios"]["env"]["IOS_STOP_AFTER_FULL_TESTS"])
        upload=next(s for s in workflow["jobs"]["ios"]["steps"] if s.get("name")=="Upload unsigned device IPA")
        self.assertEqual(upload["if"],"${{ success() && !inputs.stop_after_full_tests }}")
        diagnostics=next(s for s in workflow["jobs"]["ios"]["steps"] if s.get("name","").startswith("Upload build logs"))
        self.assertEqual(diagnostics["if"],"always()")
        self.assertIn("build/I6Integration/",diagnostics["with"]["path"])

    def test_recording_failure_blocks_release_and_preserves_original_test_failure(self):
        for test_exit in (0,65):
            with self.subTest(test_exit=test_exit):
                result = self.run_section(test_exit, 0, video_exit=29)
                self.assertEqual(result.returncode, test_exit or 29, result.stderr)
                self.assertIn("EXPORT", result.stdout)
                self.assertNotIn("RELEASE", result.stdout)

    def test_failed_tests_export_attachments_and_keep_original_exit(self):
        for export_exit in (0, 23):
            with self.subTest(export_exit=export_exit):
                result = self.run_section(65, export_exit)
                self.assertEqual(result.returncode, 65, result.stderr)
                self.assertIn("EXPORT", result.stdout)
                self.assertNotIn("RELEASE", result.stdout)

    def test_failed_attachment_export_blocks_release(self):
        result = self.run_section(0, 23)
        self.assertEqual(result.returncode, 23, result.stderr)
        self.assertNotIn("RELEASE", result.stdout)

    def test_successful_tests_and_export_reach_release(self):
        result = self.run_section(0, 0)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("EXPORT", result.stdout)
        self.assertIn("RELEASE", result.stdout)

    def test_skipped_case_blocks_release_even_when_xcode_and_exports_succeed(self):
        result = self.run_section(0, 0, skipped_tests=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("All 192", result.stderr)
        self.assertNotIn("RELEASE", result.stdout)

    def test_summary_failure_keeps_original_test_exit_and_blocks_false_release(self):
        failed = self.run_section(65, 0, summary_exit=47)
        self.assertEqual(failed.returncode, 65, failed.stderr)
        self.assertIn("EXPORT", failed.stdout)
        self.assertNotIn("RELEASE", failed.stdout)
        failed = self.run_section(0, 0, summary_exit=47)
        self.assertEqual(failed.returncode, 47, failed.stderr)
        self.assertNotIn("RELEASE", failed.stdout)
