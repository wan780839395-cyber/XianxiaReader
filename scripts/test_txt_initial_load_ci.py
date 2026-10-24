"""Protect the one original TXT native selection and exact executed receipt."""
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

import check_repository  # Existing cached validation dependencies, including YAML.
import yaml
from verify_reader_positions import verify_native

ROOT = Path(__file__).resolve().parents[1]
CASE = "TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen"
SELECTION = "txt-initial-load"
SHELL_BRANCH = "  txt-initial-load)\n    cases=(-only-testing:XianxiaReaderTests/" + CASE + ")\n    ;;\n"
RECEIPT_BLOCK = '''          if [[ "$DIAGNOSTIC_SELECTION" == 'txt-initial-load' ]]; then
            python3 - <<'TXT_INITIAL_LOAD_RECEIPT'
          from pathlib import Path
          import json, os, sys
          sys.path.insert(0, "scripts")
          from verify_reader_positions import verify_native
          case = "TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen"
          receipt = verify_native(Path("build"), expected_tests={case})
          receipt.update(selection="txt-initial-load", source=os.environ["GITHUB_SHA"], nativeCompiled=True)
          Path("build/txt-initial-load-receipt.json").write_text(json.dumps(receipt, indent=2) + "\\n")
          print("TXT_INITIAL_LOAD_RECEIPT " + json.dumps(receipt, sort_keys=True))
          TXT_INITIAL_LOAD_RECEIPT
          fi
'''


def txt_cases(source):
    branch = re.search(r"^  txt-initial-load\)\n(.*?)^    ;;\n", source, re.M | re.S)
    if not branch:
        raise ValueError("Missing TXT-only branch")
    assignment = re.fullmatch(r"    cases=\(([^\n]*)\)\n", branch.group(1))
    if not assignment:
        raise ValueError("TXT branch must contain only the explicit cases array")
    cases = shlex.split(assignment.group(1))
    if cases != ["-only-testing:XianxiaReaderTests/" + CASE]:
        raise ValueError("Only the original TXT method may execute")
    return cases


class TXTInitialLoadCITests(unittest.TestCase):
    def test_only_original_method_and_unchanged_native_driver(self):
        source = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        self.assertEqual(len(txt_cases(source)), 1)
        self.assertEqual(source.count(SHELL_BRANCH), 1)
        # e15f8ef6: exactly reverse the new branch; preserve all old flags,
        # awaits/budgets, exit handling and the driver's no-packaging path.
        old = source.replace(SHELL_BRANCH, "", 1)
        self.assertEqual(hashlib.sha256(old.encode()).hexdigest(), "860a68772c1834becee2d3cadf50905ddcd2b435839e222c5de24529e36afb68")
        for changed in [source.replace(SHELL_BRANCH, ""),
                        source.replace(SHELL_BRANCH, SHELL_BRANCH.replace(CASE, "ReaderRenderingTests/testOther")),
                        source.replace(SHELL_BRANCH, SHELL_BRANCH.replace(")\n", " -only-testing:XianxiaReaderTests/ReaderRenderingTests)\n", 1)),
                        source.replace(SHELL_BRANCH, SHELL_BRANCH.replace("    ;;", "    echo extra\n    ;;"))]:
            with self.assertRaises(ValueError):
                txt_cases(changed)

    def test_workflow_keeps_existing_prerequisites_and_no_release_route(self):
        source = (ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        workflow = yaml.load(source, Loader=yaml.BaseLoader)
        options = workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"]
        self.assertEqual(options.count(SELECTION), 1)
        jobs = workflow["jobs"]
        self.assertEqual(jobs["reading-diagnostic"]["needs"], ["repository-checks", "core-tests"])
        self.assertNotIn(SELECTION, jobs["ios"]["if"])
        self.assertNotIn(SELECTION, jobs["reader-positions"]["if"])
        self.assertNotIn(SELECTION, jobs["core-tests"]["if"])
        self.assertNotIn(SELECTION, jobs["reading-diagnostic"]["if"])
        self.assertEqual(source.count(RECEIPT_BLOCK), 1)
        receipt_path = "            build/txt-initial-load-receipt.json\n"
        self.assertEqual(source.count(receipt_path), 1)
        upload = next(step for step in jobs["reading-diagnostic"]["steps"] if step.get("name") == "Preserve diagnostic logs and original test result")
        self.assertEqual(upload["if"], "always()")
        self.assertIn("build/txt-initial-load-receipt.json", upload["with"]["path"].splitlines())
        old = source.replace(", txt-initial-load]", "]", 1).replace(RECEIPT_BLOCK, "", 1).replace(receipt_path, "", 1)
        # e15f8ef6 exact old workflow, CRLF normalized by read_text; raw
        # baseline remains 4b67339c5efdedf20edfd3a2eacf9659fa9ffc5e19809d21137efe159226172f.
        self.assertEqual(hashlib.sha256(old.encode()).hexdigest(), "2625c84aeb7102c6246267b79a07786905effdf2552db176ae48bf15055ff2a1")

    def fixture(self, root, cases=(CASE,), summary=None):
        (root / "logs").mkdir(exist_ok=True)
        events = []
        for case in cases:
            cls, name = case.split("/")
            events.extend([f"Test Case '-[XianxiaReaderTests.{cls} {name}]' started.",
                           f"Test Case '-[XianxiaReaderTests.{cls} {name}]' passed (1.000 seconds)."])
        (root / "logs/reader-diagnostic.log").write_text("\n".join(events) + "\n", encoding="utf-8")
        value = dict(totalTestCount=len(cases), passedTests=len(cases), failedTests=0, skippedTests=0, testFailures=[])
        if summary:
            value.update(summary)
        (root / "test-results-summary.json").write_text(json.dumps(value), encoding="utf-8")

    def test_existing_receipt_rejects_wrong_extra_repeated_missing_skipped_and_failure(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            self.fixture(root)
            self.assertEqual(verify_native(root, {CASE})["passed"], 1)
            bad = [(("ReaderRenderingTests/testOther",), None),
                   ((CASE, "ReaderRenderingTests/testOther"), None),
                   ((CASE, CASE), None), ((), None),
                   ((CASE,), {"skippedTests": 1}),
                   ((CASE,), {"failedTests": 1, "passedTests": 0}),
                   ((CASE,), {"testFailures": [{"failureText": "original failure"}]})]
            for cases, summary in bad:
                self.fixture(root, cases, summary)
                with self.assertRaises(ValueError):
                    verify_native(root, {CASE})
            self.fixture(root)
            with self.assertRaises(ValueError):
                verify_native(root, {CASE}, status=65)

    def test_actual_workflow_receipt_block_success_and_fail_closed(self):
        source = (ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        self.assertEqual(source.count(RECEIPT_BLOCK), 1)
        block = RECEIPT_BLOCK.split("<<'TXT_INITIAL_LOAD_RECEIPT'\n", 1)[1].split("          TXT_INITIAL_LOAD_RECEIPT\n", 1)[0]
        script = "\n".join(line[10:] for line in block.splitlines())
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder); (root / "scripts").mkdir(); (root / "build").mkdir()
            (root / "scripts/verify_reader_positions.py").write_bytes((ROOT / "scripts/verify_reader_positions.py").read_bytes())
            self.fixture(root / "build")
            env = os.environ.copy(); env["GITHUB_SHA"] = "1" * 40
            result = subprocess.run([sys.executable, "-c", script], cwd=root, env=env, capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stderr.decode(errors="replace"))
            receipt = json.loads((root / "build/txt-initial-load-receipt.json").read_text())
            self.assertEqual(receipt["cases"], [CASE]); self.assertEqual(receipt["source"], "1" * 40)
            (root / "build/txt-initial-load-receipt.json").unlink()
            self.fixture(root / "build", ("ReaderRenderingTests/testOther",))
            result = subprocess.run([sys.executable, "-c", script], cwd=root, env=env, capture_output=True, timeout=20)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse((root / "build/txt-initial-load-receipt.json").exists())


if __name__ == "__main__":
    unittest.main()
