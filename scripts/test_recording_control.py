"""The on/off experiment must preserve the original failure and both results."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest


@unittest.skipIf(os.name == 'nt', 'POSIX signal fixture runs in repository-checks on Linux')
class RecordingControlTests(unittest.TestCase):
    def run_control(self, statuses):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'scripts').mkdir()
            (root/'tools').mkdir()
            (root/'sdk/Platforms/iPhoneOS.platform').mkdir(parents=True)
            shutil.copyfile(Path(__file__).with_name('ci_recording_control.sh'), root/'scripts/ci_recording_control.sh')
            (root/'scripts/select_simulator.py').write_text("print('test-device')\n")
            xcrun = root/'tools/xcrun'
            xcrun.write_text("""#!/usr/bin/env python3
import pathlib, signal, sys, time
if 'recordVideo' in sys.argv:
    pathlib.Path(sys.argv[-1]).write_bytes(b'fixture')
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    while True: time.sleep(.02)
else: print('{}')
""")
            xcrun.chmod(0o755)
            (root/'scripts/ci_reader_diagnostic.sh').write_text("""#!/bin/bash
set -euo pipefail
test "$1" = reader-session
mkdir -p build/DiagnosticTests.xcresult build/ReaderSnapshots build/logs
printf 'original-result' > build/test-results-summary.json
printf 'sample' > build/logs/native-resources.jsonl
if [[ -f build/first-finished ]]; then exit "$SECOND_EXIT"; fi
touch build/first-finished
sleep .1
exit "$FIRST_EXIT"
""")
            env = dict(os.environ, PATH=str(root/'tools')+os.pathsep+os.environ['PATH'],
                       DEVELOPER_DIR=str(root/'sdk'), FIRST_EXIT=str(statuses[0]), SECOND_EXIT=str(statuses[1]))
            result = subprocess.run(['bash', 'scripts/ci_recording_control.sh'], cwd=root, env=env,
                                    capture_output=True, text=True, timeout=10)
            for condition, status in zip(['recording-on', 'recording-off'], statuses):
                folder = root/'build/RecordingControl'/condition
                self.assertEqual((folder/'diagnostic-exit.txt').read_text().strip(), str(status))
                self.assertEqual((folder/'recording-exit.txt').read_text().strip(), '0')
                self.assertTrue((folder/'DiagnosticTests.xcresult').is_dir())
                self.assertEqual((folder/'test-results-summary.json').read_text(), 'original-result')
                self.assertTrue((folder/'native-resources.jsonl').is_file())
            return result.returncode, result.stderr

    def test_first_failure_survives_later_success(self):
        self.assertEqual(self.run_control((65, 0))[0], 65)

    def test_second_failure_is_not_hidden(self):
        self.assertEqual(self.run_control((0, 23))[0], 23)

    def test_both_successes_keep_separate_results(self):
        self.assertEqual(self.run_control((0, 0))[0], 0)
