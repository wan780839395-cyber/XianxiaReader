"""Exercise the real CI shell control flow without claiming an iOS build."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class CIFailurePathTests(unittest.TestCase):
    def run_section(self, test_exit, export_exit, summary_exit=0):
        script = (Path(__file__).parent / "ci_ios.sh").read_text(encoding="utf-8")
        section = script[script.index("test_status=0\n"):script.index("\nxcodebuild build ")]
        git_bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
        bash = str(git_bash) if os.name == "nt" and git_bash.is_file() else shutil.which("bash")
        self.assertIsNotNone(bash, "Bash required to verify CI failure propagation")
        harness = """set -euo pipefail
SIMULATOR_ID=test
xcodebuild() { echo TEST; return "$XR_TEST_EXIT"; }
xcrun() {
  if [[ "$1 $2 $3" == "xcresulttool get test-results" ]]; then echo SUMMARY; return "$XR_SUMMARY_EXIT"; fi
  echo EXPORT; return "$XR_EXPORT_EXIT";
}
""" + section + "\necho RELEASE\n"
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / "build").mkdir()
            return subprocess.run([bash, "-c", harness], text=True, capture_output=True, cwd=directory,
                                  env={**os.environ, "XR_TEST_EXIT": str(test_exit), "XR_EXPORT_EXIT": str(export_exit),
                                       "XR_SUMMARY_EXIT": str(summary_exit)})

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

    def test_summary_failure_keeps_original_test_exit_and_blocks_false_release(self):
        failed = self.run_section(65, 0, summary_exit=47)
        self.assertEqual(failed.returncode, 65, failed.stderr)
        self.assertIn("EXPORT", failed.stdout)
        self.assertNotIn("RELEASE", failed.stdout)
        failed = self.run_section(0, 0, summary_exit=47)
        self.assertEqual(failed.returncode, 47, failed.stderr)
        self.assertNotIn("RELEASE", failed.stdout)
