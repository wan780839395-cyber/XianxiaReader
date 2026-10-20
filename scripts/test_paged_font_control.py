"""Keep original failure exits and reject unreviewed or unrelated runtime inputs."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VENDOR = ['Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift','Vendor/ReadiumToolkit/UPSTREAM.json']


@unittest.skipIf(os.name == 'nt', 'Staged native control requires POSIX Git/Bash paths')
class PagedFontControlTests(unittest.TestCase):
    def test_baseline_failure_candidate_parent_and_real_positive_exit(self):
        for mode, expected in [('success',0),('baseline-green',0),('wrong-failure',1),('wrong-parent',1),('patched-failure',65)]:
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as folder:
                origin=Path(folder)/'origin';origin.mkdir()
                def git(*args):
                    return subprocess.check_output(['git','-c','user.name=Fixture','-c','user.email=fixture@example.invalid',*args],cwd=origin,stderr=subprocess.DEVNULL)
                git('init')
                for name in VENDOR:
                    p=origin/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('old\n')
                (origin/'scripts').mkdir()
                shutil.copyfile(ROOT/'scripts/ci_paged_font_control.sh',origin/'scripts/ci_paged_font_control.sh')
                (origin/'scripts/verify_vendor.py').write_text('# Fixture integrity is proved by exact Git blobs in the real driver.\n')
                fake='''#!/bin/bash
set -euo pipefail
mkdir -p build/logs build/DiagnosticTests.xcresult build/ReaderSnapshots
python3 - "$1" <<'PY'
import json,os,sys
from pathlib import Path
mode=os.environ['CONTROL_FIXTURE_MODE'];baseline=sys.argv[1]=='paged-font'
failed=(baseline and mode!='baseline-green') or (not baseline and mode=='patched-failure')
total=2 if baseline else 8
name='wrong' if mode=='wrong-failure' else 'ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord()'
d=dict(result='Failed' if failed else 'Passed',totalTestCount=total,passedTests=total-int(failed),failedTests=int(failed),skippedTests=0,testFailures=[dict(testIdentifierString=name,failureText='original fixture failure')] if failed else [])
Path('build/test-results-summary.json').write_text(json.dumps(d))
Path('build/fixture-exit.txt').write_text('65' if failed else '0')
PY
exit "$(cat build/fixture-exit.txt)"
'''
                (origin/'scripts/ci_reader_diagnostic.sh').write_text(fake)
                git('add','.');git('commit','-qm','baseline');git('branch','baseline')
                if mode=='wrong-parent':
                    (origin/'extra.txt').write_text('unreviewed');git('add','.');git('commit','-qm','unrelated parent')
                for name in VENDOR:(origin/name).write_text('new\n')
                git('add','.');git('commit','-qm','candidate');git('branch','codex/fix-paged-font-restore-stage2')
                checkout=Path(folder)/'checkout'
                subprocess.run(['git','clone','--depth=1','--branch','baseline',origin.as_uri(),str(checkout)],check=True,capture_output=True)
                env=dict(os.environ,CONTROL_FIXTURE_MODE=mode)
                first=subprocess.run(['bash','scripts/ci_paged_font_control.sh','baseline'],cwd=checkout,env=env,capture_output=True,timeout=40)
                self.assertEqual(first.returncode,1 if mode=='wrong-failure' else 0,first.stdout.decode()+first.stderr.decode())
                if first.returncode:continue
                result=subprocess.run(['bash','scripts/ci_paged_font_control.sh','patched'],cwd=checkout,env=env,capture_output=True,timeout=40)
                self.assertEqual(result.returncode,expected,result.stdout.decode()+result.stderr.decode())
                receipt=checkout/'build/PagedFontControl/receipt.json'
                self.assertEqual(receipt.exists(),mode in {'success','baseline-green'})
                if receipt.exists():
                    d=json.loads(receipt.read_text());self.assertEqual(d['baselineOriginalExit'],0 if mode=='baseline-green' else 65);self.assertEqual(d['baselineWasNegative'],mode!='baseline-green');self.assertEqual(d['passed'],8);self.assertFalse(d['newIPA'])


if __name__=='__main__':
    unittest.main()
