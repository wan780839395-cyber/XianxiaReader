from collections import Counter
from copy import deepcopy
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

from check_architecture import ROOT
from verify_reader_positions import LOGIC_TESTS, STATE_TESTS, NATIVE_TESTS, verify_logic, verify_native


class PositionEvidenceTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.root = Path(folder.name)
        self.suite = ET.Element("testsuite", tests=str(len(LOGIC_TESTS)), errors="0", failures="0")
        for name in sorted(LOGIC_TESTS):
            cls = "ReaderPositionStateTests" if name in STATE_TESTS else "ReaderPositionPersistenceTests"
            ET.SubElement(self.suite, "testcase", classname="ReaderPositionsTests." + cls, name=name)
        (self.root / "dependencies.json").write_text(json.dumps({"name": "ReaderPositions", "dependencies": [{"name": "XianxiaCore", "dependencies": []}]}))

    def logic(self, suite=None):
        tree = ET.Element("testsuites")
        tree.append(self.suite if suite is None else suite)
        ET.ElementTree(tree).write(self.root / "tests.xml")
        return verify_logic(self.root)

    def test_all_contracts_require_exact_identity_without_external_packages(self):
        self.assertEqual(self.logic()["passed"], len(LOGIC_TESTS))
        for dependencies in [{"name": "Other", "dependencies": []},
                             {"name": "ReaderPositions", "dependencies": []},
                             {"name": "ReaderPositions", "dependencies": [{"name": "ReadiumToolkit", "dependencies": []}]},
                             {"name": "ReaderPositions", "dependencies": [{"name": "XianxiaCore", "dependencies": [{"name": "ReadiumToolkit"}]}]}]:
            with self.subTest(dependencies=dependencies):
                (self.root / "dependencies.json").write_text(json.dumps(dependencies))
                with self.assertRaises(ValueError): self.logic()

    def test_missing_duplicate_extra_wrong_failed_and_skipped_logic_is_rejected(self):
        for mode in ["missing", "duplicate", "extra", "wrong-class", "moved-class", "failure", "skipped", "empty"]:
            with self.subTest(mode=mode):
                suite = deepcopy(self.suite)
                if mode == "missing": suite.remove(suite[0])
                elif mode == "duplicate": suite.append(deepcopy(suite[0]))
                elif mode == "extra": ET.SubElement(suite, "testcase", classname="ReaderPositionStateTests", name="testOther")
                elif mode == "wrong-class": suite[0].set("classname", "Other")
                elif mode == "moved-class":
                    other = "ReaderPositionPersistenceTests" if suite[0].get("name") in STATE_TESTS else "ReaderPositionStateTests"
                    suite[0].set("classname", "ReaderPositionsTests." + other)
                elif mode in {"failure", "skipped"}: ET.SubElement(suite[0], mode)
                else: suite.clear()
                with self.assertRaises(ValueError): self.logic(suite)

    def native_fixture(self):
        (self.root / "logs").mkdir()
        lines = []
        for case in sorted(NATIVE_TESTS):
            cls, name = case.split("/")
            prefix = f"Test Case '-[XianxiaReaderTests.{cls} {name}]' "
            lines.extend([prefix + "started.", prefix + "passed (1.000 seconds)."])
        log = "\n".join(lines) + "\n"
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        summary = dict(totalTestCount=13, passedTests=13, failedTests=0, skippedTests=0, testFailures=[])
        (self.root / "test-results-summary.json").write_text(json.dumps(summary))
        return log, summary

    def test_original_native_cases_and_summary_must_agree_without_retries(self):
        log, summary = self.native_fixture()
        self.assertEqual(verify_native(self.root)["passed"], 13)
        for bad in [log.replace("passed", "failed", 1), log + log, "\n".join(log.splitlines()[2:]), ""]:
            (self.root / "logs/reader-diagnostic.log").write_text(bad)
            with self.assertRaises(ValueError): verify_native(self.root)
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        for key in ["passedTests", "totalTestCount", "failedTests", "skippedTests"]:
            bad = dict(summary); bad[key] += 1
            (self.root / "test-results-summary.json").write_text(json.dumps(bad))
            with self.assertRaises(ValueError): verify_native(self.root)

    def test_native_selection_matches_exact_existing_methods(self):
        script = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = script.split("  position-isolation)", 1)[1].split("    ;;", 1)[0]
        selected = re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block)
        self.assertEqual(Counter(selected), Counter({name: 1 for name in NATIVE_TESTS}))
        for case in selected:
            cls, name = case.split("/")
            source = (ROOT / f"Tests/iOS/{cls}.swift").read_text(encoding="utf-8")
            self.assertIn(f"func {name}(", source)

    @unittest.skipIf(os.name == "nt", "POSIX executable fixture validated on Linux CI")
    def test_shell_preserves_swift_failure_and_rejects_stale_evidence(self):
        self.logic()
        (self.root / "scripts").mkdir()
        (self.root / "fakebin").mkdir()
        for name in ["test_reader_positions.sh", "verify_reader_positions.py"]:
            shutil.copyfile(ROOT / "scripts" / name, self.root / "scripts" / name)
        helpers = {
            "swift": '#!/bin/bash\nset -eu\ncase "$1" in\n--version) echo fixture;;\npackage) cat dependencies.json;;\ntest) while [[ "$1" != --xunit-output ]]; do shift; done; shift; cp tests.xml "$1"; exit "$POSITION_TEST_EXIT";;\n*) exit 97;;\nesac\n',
        }
        for name, content in helpers.items():
            path = self.root / "fakebin" / name
            path.write_text(content); path.chmod(0o755)
        for mode, expected in [("success", 0), ("swift-failure", 65), ("stale", 2)]:
            with self.subTest(mode=mode):
                output = f"build/{mode}"
                if mode == "stale": (self.root / output).mkdir(parents=True)
                env = dict(os.environ, POSITION_TEST_EXIT="65" if mode == "swift-failure" else "0")
                result = subprocess.run(["bash", "-c", f'PATH="$PWD/fakebin:$PATH" bash scripts/test_reader_positions.sh {output}'],
                                        cwd=self.root, env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
                self.assertEqual((self.root / output / "receipt.json").exists(), mode == "success")
