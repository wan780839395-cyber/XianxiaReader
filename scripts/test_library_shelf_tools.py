from collections import Counter
import json
from pathlib import Path
import re
import tempfile
import unittest
import xml.etree.ElementTree as ET

from check_architecture import ROOT, yaml
from verify_library_shelf import LOGIC_TESTS, NATIVE_TESTS, verify_logic, verify_native


class LibraryEvidenceTests(unittest.TestCase):
    def test_logic_rejects_missing_duplicate_skipped_and_wrong_dependency(self):
        with tempfile.TemporaryDirectory() as value:
            folder = Path(value)
            def prepare():
                root = ET.Element("testsuite", tests=str(len(LOGIC_TESTS)), failures="0")
                for name in sorted(LOGIC_TESTS):
                    ET.SubElement(root, "testcase", classname="LibraryShelfTests.LibraryCollectionTests", name=name)
                (folder / "dependencies.json").write_text(json.dumps(dict(name="LibraryShelf", dependencies=[dict(name="XianxiaCore", dependencies=[])])))
                return root
            for mode in ["pass", "missing", "duplicate", "skip", "dependency"]:
                root = prepare()
                if mode == "missing": root.remove(root[0])
                if mode == "duplicate": root[-1].set("name", root[0].get("name"))
                if mode == "skip": ET.SubElement(root[0], "skipped")
                if mode == "dependency": (folder / "dependencies.json").write_text(json.dumps(dict(name="LibraryShelf", dependencies=[])))
                ET.ElementTree(root).write(folder / "tests.xml")
                if mode == "pass": self.assertEqual(verify_logic(folder)["passed"], 6)
                else:
                    with self.assertRaises(ValueError): verify_logic(folder)

    def test_native_rejects_missing_events_wrong_exit_and_skip(self):
        with tempfile.TemporaryDirectory() as value:
            folder = Path(value); (folder / "logs").mkdir()
            text = "".join(f"Test Case '-[XianxiaReaderTests.{name.replace('/', ' ')}]' {outcome}\n" for name in sorted(NATIVE_TESTS) for outcome in ["started.", "passed (0.001 seconds)."])
            (folder / "logs/reader-diagnostic.log").write_text(text, encoding="utf-8")
            summary = dict(totalTestCount=17, passedTests=17, failedTests=0, skippedTests=0, result="Passed")
            file = folder / "test-results-summary.json"; file.write_text(json.dumps(summary))
            self.assertEqual(verify_native(folder)["passed"], 17)
            with self.assertRaises(ValueError): verify_native(folder, 65)
            summary["skippedTests"] = 1; file.write_text(json.dumps(summary))
            with self.assertRaises(ValueError): verify_native(folder)
            file.write_text(json.dumps(dict(summary, skippedTests=0)))
            (folder / "logs/reader-diagnostic.log").write_text(text.split("\n", 1)[1], encoding="utf-8")
            with self.assertRaises(ValueError): verify_native(folder)

    def test_selection_matches_original_three_suites_and_exact_cases(self):
        actual = set()
        for name in ["LibraryTests", "LibraryRemovalTests", "BookCoverTests"]:
            text = (ROOT / f"Tests/iOS/{name}.swift").read_text(encoding="utf-8")
            actual.update(name + "/" + method for method in re.findall(r"func (test\w+)\(", text))
        self.assertEqual(actual, NATIVE_TESTS)
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  library-isolation)", 1)[1].split(";;", 1)[0]
        self.assertEqual(Counter(re.findall(r"-only-testing:(\S+)", block)), Counter(dict.fromkeys(["XianxiaReaderTests/" + n for n in ["LibraryTests", "LibraryRemovalTests", "BookCoverTests"]], 1)))

    def test_workflow_routes_library_only_to_targeted_job(self):
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("library-isolation", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        self.assertIn("== 'library-isolation'", jobs["reader-positions"]["if"])
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'library-isolation'", jobs[name]["if"])
        self.assertNotIn("library-isolation", jobs["ios"]["if"])
        self.assertIn("== 'full'", jobs["ios"]["if"])
        step = next(s for s in jobs["reader-positions"]["steps"] if "bash scripts/test_library_shelf.sh" in s.get("run", ""))
        self.assertIn("library-isolation", step["if"])
        self.assertIn("set -euo pipefail", step["run"])
        self.assertIn("verify_library_shelf.py native", step["run"])


if __name__ == "__main__":
    unittest.main()
