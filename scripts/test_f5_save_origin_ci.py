from test_f5_first_open_observation import without_first_open_ui, without_first_open_driver
"""Protect the exact F5 UI route; also supply its narrowly scoped CI receipt."""
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile
import unittest
from layout_sample_evidence import without_layout_sample_upload
from test_book_progress_visibility import without_progress_workflow, without_progress_driver

ROOT = Path(__file__).resolve().parents[1]
SELECTION = "f5-save-origin"
CASE = "ReadingExperienceUITests/testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection"
MODULE = "XianxiaReaderUITests"
SELECTOR = MODULE + "/" + CASE
SHELL_BRANCH = "  f5-save-origin)\n    cases=(-only-testing:" + SELECTOR + ")\n    ;;\n"
OLD_PREDICATE = '\'eventMessage BEGINSWITH "XRReadingLifecycle" OR eventMessage BEGINSWITH "XRPresentation"\''
PREDICATE_SETUP = "lifecycle_predicate=" + OLD_PREDICATE + "\nif sys.argv[2] == 'f5-save-origin': lifecycle_predicate += ' OR eventMessage BEGINSWITH \"XRSave\"'\n"
RECEIPT_BLOCK = '''          if [[ "$DIAGNOSTIC_SELECTION" == 'f5-save-origin' ]]; then
            python3 - <<'F5_SAVE_ORIGIN_RECEIPT'
          from pathlib import Path
          import json, os, sys
          sys.path.insert(0, "scripts")
          from test_f5_save_origin_ci import verify_f5_native
          receipt = verify_f5_native(Path("build"))
          receipt.update(selection="f5-save-origin", source=os.environ["GITHUB_SHA"], nativeCompiled=True)
          Path("build/f5-save-origin-receipt.json").write_text(json.dumps(receipt, indent=2) + "\\n")
          print("F5_SAVE_ORIGIN_RECEIPT " + json.dumps(receipt, sort_keys=True))
          F5_SAVE_ORIGIN_RECEIPT
          fi
'''
RECEIPT_PATH = "            build/f5-save-origin-receipt.json\n"


def replace_exact(text, old, new):
    if text.count(old) != 1:
        raise ValueError("Named F5 wiring block missing or duplicated")
    return text.replace(old, new, 1)


def restore_pre_f5_workflow(text):
    text = without_progress_workflow(text)
    text = without_layout_sample_upload(text)
    text = replace_exact(text, ", f5-save-origin]", "]")
    text = replace_exact(text, RECEIPT_BLOCK, "")
    return replace_exact(text, RECEIPT_PATH, "")


def restore_pre_f5_driver(text):
    text = without_progress_driver(text)
    text = replace_exact(text, SHELL_BRANCH, "")
    text = replace_exact(text, "if [[ \"$selection\" == 'f5-save-origin' || \"$selection\" == 'panels'", "if [[ \"$selection\" == 'panels'")
    text = replace_exact(text, 'if python3 - "$SIMULATOR_ID" "$selection" <<\'XR_CONTEXT\'', 'if python3 - "$SIMULATOR_ID" <<\'XR_CONTEXT\'')
    text = replace_exact(text, PREDICATE_SETUP, "")
    return replace_exact(text, '"--predicate",lifecycle_predicate', '"--predicate",' + OLD_PREDICATE)


def f5_cases(text):
    match = re.search(r"^  f5-save-origin\)\n(.*?)^    ;;\n", text, re.M | re.S)
    if not match or len(re.findall(r"^  f5-save-origin\)", text, re.M)) != 1:
        raise ValueError("F5 must have exactly one branch")
    assignment = re.fullmatch(r"    cases=\(([^\n]*)\)\n", match.group(1))
    if not assignment or shlex.split(assignment.group(1)) != ["-only-testing:" + SELECTOR]:
        raise ValueError("F5 branch may only select the exact original method")
    return ["-only-testing:" + SELECTOR]


def verify_f5_native(folder, status=0):
    if type(status) is not int or status != 0:
        raise ValueError("Original native exit must be zero")
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    if "F5_FIRST_OPEN_ONLY" in log:
        raise ValueError("First-open-only evidence cannot establish full F5 save acceptance")
    pattern = r"^Test Case '-\[([^ .]+)\.([^ ]+) ([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed \([^\n]+\)\.|skipped[^\n]*)$"
    events = re.findall(pattern, log, re.M)
    wanted = (MODULE, *CASE.split("/"))
    if len(events) != 2 or [v[:3] for v in events] != [wanted, wanted] or events[0][3] != "started." or not events[1][3].startswith("passed ("):
        raise ValueError("Exactly one original UI start/pass required; no other module/case/failure/skip")
    raw = re.findall(r"^DIAGNOSTIC ONLY: f5-save-origin; test=(\d+) summary=(\d+) export=(\d+); no device Release or IPA$", log, re.M)
    if raw != [("0", "0", "0")]:
        raise ValueError("Original test/summary/export exits must be present once and zero")
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    for key, value in {"totalTestCount": 1, "passedTests": 1, "failedTests": 0, "skippedTests": 0}.items():
        if type(summary.get(key)) is not int or summary[key] != value:
            raise ValueError("UI xcresult must count exactly one passed/no skipped")
    if summary.get("testFailures") != [] or summary.get("result") != "Passed":
        raise ValueError("UI xcresult must report Passed with no failures")
    save_log = folder / "logs/reading-lifecycle.log"
    save_rows = re.findall(r'\bXRSave t=\d+ owner=\S+ session=\S+ request=\d+ source=\S+ phase=(?:begin|end)', save_log.read_text(encoding="utf-8", errors="replace")) if save_log.exists() else []
    return dict(module=MODULE, cases=[CASE], started=1, passed=1, failed=0, skipped=0,
                testExit=0, summaryExit=0, exportExit=0,
                saveObservation=dict(logPresent=save_log.exists(), rows=len(save_rows), completeCorrelationVerified=False))


class F5SaveOriginCITests(unittest.TestCase):
    def fixture(self, root):
        (root / "logs").mkdir(parents=True, exist_ok=True)
        cls, method = CASE.split("/")
        prefix = "Test Case '-[" + MODULE + "." + cls + " " + method + "]' "
        log = prefix + "started.\n" + prefix + "passed (1.000 seconds).\nDIAGNOSTIC ONLY: f5-save-origin; test=0 summary=0 export=0; no device Release or IPA\n"
        (root / "logs/reader-diagnostic.log").write_text(log, encoding="utf-8")
        summary = dict(totalTestCount=1, passedTests=1, failedTests=0, skippedTests=0, testFailures=[], result="Passed")
        (root / "test-results-summary.json").write_text(json.dumps(summary), encoding="utf-8")
        return log, summary

    def test_only_original_ui_method_and_no_widened_branch(self):
        text = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        self.assertEqual(f5_cases(text), ["-only-testing:" + SELECTOR])
        for bad in [text.replace(SHELL_BRANCH, ""), text + SHELL_BRANCH,
                    text.replace(SHELL_BRANCH, SHELL_BRANCH.replace(SELECTOR, MODULE + "/ReadingExperienceUITests")),
                    text.replace(SHELL_BRANCH, SHELL_BRANCH.replace(")\n", " -only-testing:XianxiaReaderTests/TXTReadingTests)\n", 1)),
                    text.replace(SHELL_BRANCH, SHELL_BRANCH.replace("    ;;", "    echo extra\n    ;;"))]:
            with self.assertRaises(ValueError): f5_cases(bad)

    def test_exact_old_driver_workflow_and_dark_log_contract(self):
        driver = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        workflow = (ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        self.assertEqual(hashlib.sha256(restore_pre_f5_driver(driver).encode()).hexdigest(), DRIVER_SHA)
        self.assertEqual(hashlib.sha256(restore_pre_f5_workflow(workflow).encode()).hexdigest(), WORKFLOW_SHA)
        self.assertEqual(driver.count('"log","show","--last","20m"'), 1)
        self.assertEqual(driver.count(PREDICATE_SETUP), 1)
        self.assertIn("if [[ \"$selection\" == 'f5-save-origin' || \"$selection\" == 'panels'", without_first_open_driver(driver))
        self.assertIn('appearance dark; fi', driver)
        for bad in [driver.replace('"XRSave"', '"XRWrong"'), driver.replace("sys.argv[2] == 'f5-save-origin'", 'True')]:
            with self.assertRaises(ValueError): restore_pre_f5_driver(bad)

    def test_route_keeps_repo_core_and_excludes_release_jobs(self):
        from check_architecture import yaml
        text = (ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        workflow = yaml.load(text, Loader=yaml.BaseLoader)
        self.assertEqual(workflow['on']['workflow_dispatch']['inputs']['diagnostic_selection']['options'].count(SELECTION), 1)
        jobs = workflow['jobs']
        self.assertEqual(jobs['reading-diagnostic']['needs'], ['repository-checks', 'core-tests'])
        for name in ['core-tests','reading-diagnostic','ios','reader-positions']:
            self.assertNotIn(SELECTION, jobs[name]['if'])
        self.assertEqual(text.count(RECEIPT_BLOCK), 1)
        self.assertEqual(text.count(RECEIPT_PATH), 1)
        upload = next(s for s in jobs['reading-diagnostic']['steps'] if s.get('name') == 'Preserve diagnostic logs and original test result')
        self.assertEqual(upload['if'], 'always()')
        self.assertIn('build/logs/', upload['with']['path'].splitlines())
        self.assertIn('build/f5-save-origin-receipt.json', upload['with']['path'].splitlines())

    def test_real_ui_module_exact_once_and_observation_gap_explicit(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d); self.fixture(root)
            value = verify_f5_native(root)
            self.assertEqual(value['module'], MODULE)
            self.assertEqual(value['cases'], [CASE])
            self.assertEqual(value['saveObservation'], dict(logPresent=False, rows=0, completeCorrelationVerified=False))
            (root/'logs/reading-lifecycle.log').write_text('XRSave t=123 owner=abc session=xyz request=1 source=returnToLibrary phase=end\n')
            self.assertEqual(verify_f5_native(root)['saveObservation']['rows'], 1)

    def test_missing_duplicate_extra_wrong_module_failure_skip_status_rejected(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d); log, summary = self.fixture(root)
            for bad in [log.replace(MODULE, 'XianxiaReaderTests'), log+log, '\n'.join(log.splitlines()[1:]),
                        log.replace('passed (', 'failed ('), log.replace('passed (1.000 seconds).', 'skipped (1.000 seconds).'),
                        log.replace('test=0', 'test=65'), log.replace('summary=0', 'summary=1'), log.replace('export=0', 'export=1'),
                        log + "Test Case '-[XianxiaReaderUITests.Other testOther]' passed (1.0 seconds).\n"]:
                (root/'logs/reader-diagnostic.log').write_text(bad, encoding='utf-8')
                with self.assertRaises(ValueError): verify_f5_native(root)
            (root/'logs/reader-diagnostic.log').write_text(log, encoding='utf-8')
            for key, bad in [('totalTestCount',2),('passedTests',0),('passedTests',True),('failedTests',1),('skippedTests',1),('testFailures',[{}]),('result','Failed')]:
                mutated = dict(summary); mutated[key] = bad
                (root/'test-results-summary.json').write_text(json.dumps(mutated))
                with self.assertRaises(ValueError): verify_f5_native(root)
            for bad in [65, True, None]:
                with self.assertRaises(ValueError): verify_f5_native(root, status=bad)

    def test_exact_workflow_payload_and_no_false_success_receipt(self):
        body = '\n'.join(line[10:] for line in RECEIPT_BLOCK.splitlines()[2:-2])
        with tempfile.TemporaryDirectory() as d:
            root = Path(d); self.fixture(root/'build')
            env = dict(os.environ, PYTHONPATH=str(ROOT/'scripts'), GITHUB_SHA='1'*40)
            p = subprocess.run([sys.executable,'-c',body], cwd=root, env=env, capture_output=True, timeout=20)
            self.assertEqual(p.returncode,0,p.stderr.decode(errors='replace'))
            receipt = root/'build/f5-save-origin-receipt.json'
            self.assertEqual(json.loads(receipt.read_text())['cases'],[CASE]); receipt.unlink()
            path=root/'build/logs/reader-diagnostic.log';path.write_text(path.read_text().replace(MODULE,'XianxiaReaderTests'))
            p=subprocess.run([sys.executable,'-c',body],cwd=root,env=env,capture_output=True,timeout=20)
            self.assertNotEqual(p.returncode,0);self.assertFalse(receipt.exists())

    def test_original_ui_test_source_unchanged(self):
        text=(ROOT/'Tests/UI/ReadingExperienceUITests.swift').read_text(encoding='utf-8')
        self.assertEqual(hashlib.sha256(without_first_open_ui(text).encode()).hexdigest(), UI_SHA)


DRIVER_SHA = 'f04fe17c71a6e3121fa2b0b95bccc4e236cf908686050c4b139dbddebbd68527'
WORKFLOW_SHA = 'eaaf921059a6a8f12b3235fedd37c93bf04cf0d26fb694697575d1bb2e560312'
UI_SHA = 'ff913cacba3decc2a880c716d5b09f6ea6bc6c5ecb5a6631011c751fc2b0d4cd'

if __name__ == "__main__":
    unittest.main()
