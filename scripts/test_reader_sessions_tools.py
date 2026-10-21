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
from verify_reader_sessions import CONTROL, LOGIC_TESTS, NATIVE_TESTS, verify_logic, verify_native


class SessionEvidenceTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.root = Path(folder.name)
        self.suite = ET.Element("testsuite", tests=str(len(LOGIC_TESTS)), errors="0", failures="0")
        for name in sorted(LOGIC_TESTS):
            ET.SubElement(self.suite, "testcase", classname="ReaderSessionsTests.ReaderSessionStateTests", name=name)
        (self.root / "dependencies.json").write_text(json.dumps(dict(name="ReaderSessions", dependencies=[])))

    def logic(self, suite=None):
        tree = ET.Element("testsuites"); tree.append(self.suite if suite is None else suite)
        ET.ElementTree(tree).write(self.root / "tests.xml")
        return verify_logic(self.root)

    def test_logic_requires_exact_contracts_and_no_external_dependencies(self):
        self.assertEqual(self.logic()["passed"], 6)
        for mode in ["missing", "duplicate", "extra", "wrong-class", "failed", "skipped"]:
            suite = deepcopy(self.suite)
            if mode == "missing": suite.remove(suite[0])
            elif mode == "duplicate": suite.append(deepcopy(suite[0]))
            elif mode == "extra": ET.SubElement(suite, "testcase", name="testOther")
            elif mode == "wrong-class": suite[0].set("classname", "Other")
            else: ET.SubElement(suite[0], "failure" if mode == "failed" else "skipped")
            with self.subTest(mode=mode), self.assertRaises(ValueError): self.logic(suite)
        for module in ["ReadiumToolkit", "XianxiaCore"]:
            (self.root / "dependencies.json").write_text(json.dumps(dict(name="ReaderSessions", dependencies=[dict(name=module)])))
            with self.subTest(module=module), self.assertRaises(ValueError): self.logic()

    def native(self, baseline=False):
        (self.root / "logs").mkdir(exist_ok=True)
        lines = []
        for case in sorted({CONTROL} if baseline else NATIVE_TESTS):
            cls, name = case.split("/")
            prefix = f"Test Case '-[XianxiaReaderTests.{cls} {name}]' "
            lines.extend([prefix + "started.", prefix + ("failed" if baseline else "passed") + " (0.01 seconds)."])
        if baseline: lines.append("READER_SESSION_CONTROL_READY sameModelReopened=true currentPositionStored=true")
        log = "\n".join(lines) + "\n"
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        count = 1 if baseline else len(NATIVE_TESTS)
        summary = dict(result="Failed" if baseline else "Passed", totalTestCount=count,
                       passedTests=0 if baseline else count, failedTests=1 if baseline else 0, skippedTests=0,
                       testFailures=[dict(testIdentifierString=CONTROL + "()", failureText="STALE_SESSION_CALLBACK position")] if baseline else [])
        (self.root / "test-results-summary.json").write_text(json.dumps(summary))
        return log, summary

    def test_native_requires_exact_cases_summary_and_original_exit(self):
        log, summary = self.native()
        self.assertEqual(verify_native(self.root, False, 0)["passed"], len(NATIVE_TESTS))
        for bad in [log + log, log.replace("passed", "failed", 1), "\n".join(log.splitlines()[2:])]:
            (self.root / "logs/reader-diagnostic.log").write_text(bad)
            with self.assertRaises(ValueError): verify_native(self.root, False, 0)
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        with self.assertRaises(ValueError): verify_native(self.root, False, 65)
        for key in ["totalTestCount", "passedTests", "failedTests", "skippedTests"]:
            bad = dict(summary); bad[key] += 1
            (self.root / "test-results-summary.json").write_text(json.dumps(bad))
            with self.assertRaises(ValueError): verify_native(self.root, False, 0)

    def test_old_control_must_reach_ownership_assertion_after_successful_reopen(self):
        log, summary = self.native(True)
        self.assertTrue(verify_native(self.root, True, 65)["qualifiedNegative"])
        for text in ["precondition failed", "timed out", ""]:
            bad = deepcopy(summary); bad["testFailures"][0]["failureText"] = text
            (self.root / "test-results-summary.json").write_text(json.dumps(bad))
            with self.assertRaises(ValueError): verify_native(self.root, True, 65)
        (self.root / "test-results-summary.json").write_text(json.dumps(summary))
        (self.root / "logs/reader-diagnostic.log").write_text(log.split("READER_SESSION_CONTROL_READY")[0])
        with self.assertRaises(ValueError): verify_native(self.root, True, 65)

    def test_selection_names_match_real_methods_without_broad_class_filters(self):
        script = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        for selection, expected in [("session-owner-baseline", {CONTROL}), ("session-isolation", NATIVE_TESTS)]:
            block = script.split("  " + selection + ")", 1)[1].split("    ;;", 1)[0]
            selected = re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block)
            self.assertEqual(Counter(selected), Counter({n: 1 for n in expected}))
            for case in selected:
                cls, name = case.split("/")
                self.assertIn("func " + name + "(", (ROOT / f"Tests/iOS/{cls}.swift").read_text(encoding="utf-8"))

    @unittest.skipIf(os.name == "nt", "POSIX executable fixture validated on Linux CI")
    def test_shell_preserves_swift_failure_and_refuses_prior_evidence(self):
        self.logic()
        (self.root / "scripts").mkdir(); (self.root / "fakebin").mkdir()
        for name in ["test_reader_sessions.sh", "verify_reader_sessions.py"]:
            shutil.copyfile(ROOT / "scripts" / name, self.root / "scripts" / name)
        fake = self.root / "fakebin/swift"
        fake.write_text('#!/bin/bash\nset -eu\ncase "$1" in\n--version) echo fixture;;\npackage) cat dependencies.json;;\ntest) while [[ "$1" != --xunit-output ]]; do shift; done; shift; cp tests.xml "$1"; exit "$SESSION_TEST_EXIT";;\n*) exit 97;;\nesac\n')
        fake.chmod(0o755)
        for mode, expected in [("success", 0), ("failure", 65), ("stale", 2)]:
            output = "build/" + mode
            if mode == "stale": (self.root / output).mkdir(parents=True)
            result = subprocess.run(["bash", "-c", f'PATH="$PWD/fakebin:$PATH" bash scripts/test_reader_sessions.sh {output}'],
                cwd=self.root, env=dict(os.environ, SESSION_TEST_EXIT="65" if mode == "failure" else "0"), capture_output=True)
            self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
