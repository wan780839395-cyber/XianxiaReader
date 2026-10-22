from collections import Counter
import json
from pathlib import Path
import re
import tempfile
import unittest
import xml.etree.ElementTree as ET

from check_architecture import ROOT, yaml
from verify_book_imports import LOGIC_TESTS, NATIVE_TESTS, verify_logic, verify_native


class ImportEvidenceTests(unittest.TestCase):
    def test_logic_rejects_missing_duplicate_skipped_and_wrong_dependency(self):
        with tempfile.TemporaryDirectory() as value:
            folder = Path(value)
            def prepare():
                root = ET.Element("testsuite", tests=str(len(LOGIC_TESTS)), failures="0")
                for name in sorted(LOGIC_TESTS):
                    ET.SubElement(root, "testcase", classname="BookImportsTests.BookImportServiceTests", name=name)
                (folder / "dependencies.json").write_text(json.dumps(dict(name="BookImports", dependencies=[dict(name="XianxiaCore", dependencies=[])])))
                return root
            for mode in ["pass", "missing", "duplicate", "skip", "dependency"]:
                root = prepare()
                if mode == "missing": root.remove(root[0])
                if mode == "duplicate": root[-1].set("name", root[0].get("name"))
                if mode == "skip": ET.SubElement(root[0], "skipped")
                if mode == "dependency": (folder / "dependencies.json").write_text(json.dumps(dict(name="BookImports", dependencies=[])))
                ET.ElementTree(root).write(folder / "tests.xml")
                if mode == "pass": self.assertEqual(verify_logic(folder)["passed"], 8)
                else:
                    with self.assertRaises(ValueError): verify_logic(folder)

    def test_native_rejects_missing_events_wrong_exit_and_skip(self):
        with tempfile.TemporaryDirectory() as value:
            folder = Path(value); (folder / "logs").mkdir()
            text = "".join(f"Test Case '-[XianxiaReaderTests.{name.replace('/', ' ')}]' {outcome}\n" for name in sorted(NATIVE_TESTS) for outcome in ["started.", "passed (0.001 seconds)."])
            (folder / "logs/reader-diagnostic.log").write_text(text, encoding="utf-8")
            summary = dict(totalTestCount=14, passedTests=14, failedTests=0, skippedTests=0, result="Passed")
            file = folder / "test-results-summary.json"; file.write_text(json.dumps(summary))
            self.assertEqual(verify_native(folder)["passed"], 14)
            with self.assertRaises(ValueError): verify_native(folder, 65)
            summary["skippedTests"] = 1; file.write_text(json.dumps(summary))
            with self.assertRaises(ValueError): verify_native(folder)
            file.write_text(json.dumps(dict(summary, skippedTests=0)))
            (folder / "logs/reader-diagnostic.log").write_text(text.split("\n", 1)[1], encoding="utf-8")
            with self.assertRaises(ValueError): verify_native(folder)

    def test_selection_has_only_the_fourteen_declared_import_cases(self):
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  import-isolation)", 1)[1].split(";;", 1)[0]
        self.assertEqual(set(re.findall(r"-only-testing:XianxiaReaderTests/(\S+)", block)), NATIVE_TESTS)
        for case in NATIVE_TESTS:
            cls, name = case.split("/")
            self.assertIn("func " + name + "(", (ROOT / f"Tests/iOS/{cls}.swift").read_text(encoding="utf-8"))
        self.assertEqual(len(NATIVE_TESTS), 14)

    def test_workflow_routes_imports_to_package_and_targeted_native_steps(self):
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("import-isolation", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        self.assertIn("== 'import-isolation'", jobs["reader-positions"]["if"])
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'import-isolation'", jobs[name]["if"])
        self.assertNotIn("import-isolation", jobs["ios"]["if"])
        steps=jobs["reader-positions"]["steps"]
        logic=next(s for s in steps if s.get("run", "") == "bash scripts/test_book_imports.sh")
        native=next(s for s in steps if "verify_book_imports.py native" in s.get("run", ""))
        self.assertIn("import-isolation",logic["if"]);self.assertIn("import-isolation",native["if"])
        self.assertIn("set -euo pipefail",native["run"])
        self.assertIn("\"$selection\" == 'import-isolation'",(ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8"))

if __name__ == "__main__":
    unittest.main()
