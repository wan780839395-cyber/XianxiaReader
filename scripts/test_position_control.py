"""Exercise the real control driver with disposable Git trees and test receipts."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipIf(os.name == "nt", "CI control fixture requires native POSIX Git/Bash/Python paths")
class PositionControlTests(unittest.TestCase):
    def test_specified_red_then_green_and_reject_wrong_or_missing_controls(self):
        for mode, expected in [("success", 0), ("baseline-green", 1), ("wrong-failure", 1), ("patched-failure", 65)]:
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as folder:
                root = Path(folder) / "origin"
                root.mkdir()
                def git(*args):
                    return subprocess.check_output(["git", "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", *args], cwd=root, stderr=subprocess.DEVNULL)
                git("init")
                for name in ["Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift", "Vendor/ReadiumToolkit/UPSTREAM.json"]:
                    path = root/name; path.parent.mkdir(parents=True, exist_ok=True); path.write_text("old\n")
                (root/"scripts").mkdir()
                shutil.copyfile(ROOT/"scripts/ci_position_offset_control.sh", root/"scripts/ci_position_offset_control.sh")
                (root/"scripts/verify_vendor.py").write_text("# Stand-in for vendor integrity after the real driver restores exact Git blobs.\n")
                fake = '''#!/bin/bash
set -euo pipefail
mkdir -p build/logs build/ReaderSnapshots build/DiagnosticTests.xcresult
printf '%s\\n' "$1" > build/logs/phase.log
python3 - "$1" <<'PY'
from pathlib import Path
import json, os, sys
phase, mode = sys.argv[1], os.environ['CONTROL_FIXTURE_MODE']
baseline = phase == 'position-control-baseline'
failed = (baseline and mode != 'baseline-green') or (not baseline and mode == 'patched-failure')
marker = 'wrong failure' if mode == 'wrong-failure' else 'LATE_CANONICAL_VIEWPORT_OFFSET'
total = 1 if baseline else 5
result = dict(result='Failed' if failed else 'Passed', totalTestCount=total, failedTests=1 if failed else 0, passedTests=total-1 if failed else total, skippedTests=0, testFailures=[dict(failureText=marker, testIdentifierString='ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes()')] if failed else [])
Path('build/test-results-summary.json').write_text(json.dumps(result))
Path('build/fixture-exit.txt').write_text('65' if failed else '0')
PY
exit "$(cat build/fixture-exit.txt)"
'''
                (root/"scripts/ci_reader_diagnostic.sh").write_text(fake)
                git("add", "."); git("commit", "-qm", "baseline")
                for name in ["Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift", "Vendor/ReadiumToolkit/UPSTREAM.json"]:
                    (root/name).write_text("new\n")
                git("add", "."); git("commit", "-qm", "patched")
                checkout = Path(folder)/"checkout"
                subprocess.run(["git", "clone", "--depth=1", root.as_uri(), str(checkout)], check=True, capture_output=True)
                result = subprocess.run(["bash", "scripts/ci_position_offset_control.sh"], cwd=checkout,
                    env=dict(os.environ, CONTROL_FIXTURE_MODE=mode), capture_output=True, timeout=40)
                self.assertEqual(result.returncode, expected, result.stdout.decode()+result.stderr.decode())
                receipt = checkout/"build/PositionControl/receipt.json"
                self.assertEqual(receipt.exists(), mode == "success")
                if mode == "success":
                    data = json.loads(receipt.read_text())
                    self.assertEqual(data["baseline"]["originalTestExit"], 65)
                    self.assertEqual(data["patchedPassed"], 5)
                    self.assertFalse(data["newIPA"])
                elif mode in {"baseline-green", "wrong-failure"}:
                    self.assertFalse((checkout/"build/PositionControl/patched-inputs.json").exists())


if __name__ == "__main__":
    unittest.main()
