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

from check_architecture import ROOT, yaml
from verify_reader_positions import LOGIC_TESTS, STATE_TESTS, TEST_CLASSES, NATIVE_TESTS, ACCEPTANCE_TESTS, CLOSE_TESTS, verify_logic, verify_native, verify_acceptance, verify_close


class PositionEvidenceTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.root = Path(folder.name)
        self.suite = ET.Element("testsuite", tests=str(len(LOGIC_TESTS)), errors="0", failures="0")
        for name in sorted(LOGIC_TESTS):
            cls = TEST_CLASSES[name]
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

    def native_fixture(self, tests=NATIVE_TESTS):
        (self.root / "logs").mkdir()
        lines = []
        for case in sorted(tests):
            cls, name = case.split("/")
            prefix = f"Test Case '-[XianxiaReaderTests.{cls} {name}]' "
            lines.extend([prefix + "started.", prefix + "passed (1.000 seconds)."])
        log = "\n".join(lines) + "\n"
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        summary = dict(totalTestCount=len(tests), passedTests=len(tests), failedTests=0, skippedTests=0, testFailures=[], result="Passed")
        (self.root / "test-results-summary.json").write_text(json.dumps(summary))
        return log, summary

    def test_original_native_cases_and_summary_must_agree_without_retries(self):
        log, summary = self.native_fixture()
        self.assertEqual(verify_native(self.root)["passed"], len(NATIVE_TESTS))
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

    def test_acceptance_requires_all_23_events_summary_and_true_exit_without_retry(self):
        log, summary = self.native_fixture(ACCEPTANCE_TESTS)
        self.assertEqual(verify_acceptance(self.root)["passed"], 23)
        with self.assertRaises(ValueError): verify_acceptance(self.root, status=65)
        for bad in [log.replace("passed", "failed", 1), log + log, "\n".join(log.splitlines()[2:]), ""]:
            (self.root / "logs/reader-diagnostic.log").write_text(bad)
            with self.assertRaises(ValueError): verify_acceptance(self.root)
        (self.root / "logs/reader-diagnostic.log").write_text(log)
        for bad in [dict(summary, result="Failed"), dict(summary, skippedTests=1),
                    dict(summary, totalTestCount=22), dict(summary, passedTests=22),
                    dict(summary, testFailures=["earlier crash"])]:
            (self.root / "test-results-summary.json").write_text(json.dumps(bad))
            with self.assertRaises(ValueError): verify_acceptance(self.root)

    def test_acceptance_selector_and_workflow_match_the_audited_23_only(self):
        audit = json.loads((ROOT / "Documentation/ValidationLogs/project-isolation-i6-audit.json").read_text(encoding="utf-8"))
        self.assertEqual(ACCEPTANCE_TESTS, set(audit["nextNativeGate"]["cases"]))
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  position-acceptance)", 1)[1].split("    ;;", 1)[0]
        selected = re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block)
        self.assertEqual(Counter(selected), Counter(dict.fromkeys(ACCEPTANCE_TESTS, 1)))
        self.assertEqual(len(selected), 23)
        for case in selected:
            cls, name = case.split("/")
            self.assertIn(f"func {name}(", (ROOT / f"Tests/iOS/{cls}.swift").read_text(encoding="utf-8"))
        self.assertIn('"$selection" == \'position-acceptance\' ||', shell)
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("position-acceptance", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        self.assertIn("== 'position-acceptance'", jobs["reader-positions"]["if"])
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'position-acceptance'", jobs[name]["if"])
        self.assertNotIn("position-acceptance", jobs["ios"]["if"])
        steps = [s for s in jobs["reader-positions"]["steps"] if "verify_reader_positions.py acceptance" in s.get("run", "")]
        self.assertEqual(len(steps), 1)
        self.assertIn("set -euo pipefail", steps[0]["run"])
        self.assertNotIn("test_reader_positions.sh", steps[0]["run"])

    def test_close_requires_pending_barrier_and_disconnection_in_both_modes(self):
        log, _ = self.native_fixture(CLOSE_TESTS)
        rows = []
        for mode in ["paged", "continuous"]:
            values = {"href": "/OEBPS/cover.xhtml", "started": True, "nativeFontState": "pending",
                      "probe": {"installed": True, "nativeReady": True, "released": False,
                                "settledCalls": 0, "instanceCalls": 0, "prototypeCalls": 1}}
            rows.extend([dict(mode=mode, phase="prepared", values=values),
                         dict(mode=mode, phase="closed", values=dict(retiredCount=2,
                              delegatesDisconnected=True, remainingWebViews=0, remainingChildren=0)),
                         dict(mode=mode, phase="gate-cleanup", values=dict(released=True))])
        def write(records):
            (self.root / "logs/reader-diagnostic.log").write_text(
                log + "\n" + "\n".join("CLOSE_INITIALIZATION_PROBE " + json.dumps(r) for r in records))
        write(rows)
        self.assertEqual(verify_close(self.root)["passed"], 1)
        with self.assertRaises(ValueError): verify_close(self.root, status=65)
        for bad in [rows[:3], rows + rows[:1]]:
            write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)
        for key, value in [("installed", False), ("nativeReady", False), ("released", True),
                           ("settledCalls", 1), ("prototypeCalls", 0), ("installError", "broken hook")]:
            bad = deepcopy(rows); bad[0]["values"]["probe"][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)
        for key, value in [("nativeFontState", "ready"), ("href", "/hidden/one.xhtml")]:
            bad = deepcopy(rows); bad[0]["values"][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)
        for key, value in [("delegatesDisconnected", False), ("remainingWebViews", 1), ("remainingChildren", 1)]:
            bad = deepcopy(rows); bad[1]["values"][key] = value; write(bad)
            with self.assertRaises(ValueError): verify_close(self.root)

    def test_initialization_close_route_never_selects_other_cases_or_jobs(self):
        shell = (ROOT / "scripts/ci_reader_diagnostic.sh").read_text(encoding="utf-8")
        block = shell.split("  initialization-close)", 1)[1].split("    ;;", 1)[0]
        self.assertEqual(re.findall(r"-only-testing:XianxiaReaderTests/(\w+/\w+)", block), sorted(CLOSE_TESTS))
        workflow = yaml.load((ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        self.assertIn("initialization-close", workflow["on"]["workflow_dispatch"]["inputs"]["diagnostic_selection"]["options"])
        jobs = workflow["jobs"]
        for name in ["core-tests", "reading-diagnostic"]:
            self.assertIn("!= 'initialization-close'", jobs[name]["if"])
        self.assertNotIn("initialization-close", jobs["ios"]["if"])
        self.assertIn("== 'initialization-close'", jobs["reader-positions"]["if"])
        steps = [s for s in jobs["reader-positions"]["steps"] if "verify_reader_positions.py close" in s.get("run", "")]
        self.assertEqual(len(steps), 1)
        self.assertIn("set -euo pipefail", steps[0]["run"])
        self.assertIn("ci_reader_diagnostic.sh initialization-close", steps[0]["run"])
        self.assertNotIn("test_reader_positions.sh", steps[0]["run"])

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
