"""Exercise the real CI shell control flow without claiming an iOS build."""
import os
from pathlib import Path
import shutil
import subprocess
import unittest


class CIFailurePathTests(unittest.TestCase):
    def run_section(self, test_exit, export_exit):
        script = (Path(__file__).parent / "ci_ios.sh").read_text(encoding="utf-8")
        section = script[script.index("test_status=0\n"):script.index("\nxcodebuild build ")]
        git_bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
        bash = str(git_bash) if os.name == "nt" and git_bash.is_file() else shutil.which("bash")
        self.assertIsNotNone(bash, "Bash required to verify CI failure propagation")
        harness = """set -euo pipefail
SIMULATOR_ID=test
xcodebuild() { echo TEST; return "$XR_TEST_EXIT"; }
xcrun() { echo EXPORT; return "$XR_EXPORT_EXIT"; }
""" + section + "\necho RELEASE\n"
        return subprocess.run([bash, "-c", harness], text=True, capture_output=True,
                              env={**os.environ, "XR_TEST_EXIT": str(test_exit), "XR_EXPORT_EXIT": str(export_exit)})

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
