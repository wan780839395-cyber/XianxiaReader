from copy import deepcopy
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET
import json
import os
import shutil
import subprocess
import sys

from check_architecture import ROOT
from plan_validation import plan
from verify_reader_logic import EXPECTED_TESTS, verify


class ReaderLogicEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        self.xml = self.root / "tests.xml"
        self.dependencies = self.root / "dependencies.json"
        self.dependencies.write_text(json.dumps({"name": "ReaderSettings", "dependencies": [{"name": "XianxiaCore", "dependencies": []}]}), encoding="utf-8")
        self.suite = ET.Element("testsuite", tests="7", errors="0", failures="0")
        for name in sorted(EXPECTED_TESTS):
            ET.SubElement(self.suite, "testcase", classname="ReaderSettingsTests.ReaderSettingsPersistenceTests", name=name)

    def run_report(self, suite=None):
        tree = ET.Element("testsuites")
        tree.append(self.suite if suite is None else suite)
        ET.ElementTree(tree).write(self.xml)
        return verify(self.xml, self.dependencies)

    def test_all_seven_real_contract_identities_are_required(self):
        report = self.run_report()
        self.assertEqual(report["passed"], 7)
        self.assertFalse(report["releaseAccepted"])
        self.assertFalse(report["iOSIntegrationAccepted"])

    def test_missing_duplicate_extra_failed_and_skipped_cases_are_rejected(self):
        for mode in ["missing", "duplicate", "extra", "failure", "skipped", "wrong-class", "zero"]:
            with self.subTest(mode=mode):
                suite = deepcopy(self.suite)
                if mode == "missing": suite.remove(suite[0])
                elif mode == "duplicate": suite.append(deepcopy(suite[0]))
                elif mode == "extra": ET.SubElement(suite, "testcase", classname="ReaderSettingsPersistenceTests", name="testUnexpected")
                elif mode in {"failure", "skipped"}: ET.SubElement(suite[0], mode)
                elif mode == "wrong-class": suite[0].set("classname", "OtherTests")
                elif mode == "zero": suite.clear()
                with self.assertRaises(ValueError): self.run_report(suite)

    def test_readium_or_any_additional_package_is_rejected(self):
        for name in ["ReadiumToolkit", "UnexpectedPackage"]:
            with self.subTest(name=name):
                self.dependencies.write_text(json.dumps({"name": "ReaderSettings", "dependencies": [{"name": "XianxiaCore", "dependencies": []}, {"name": name, "dependencies": []}]}), encoding="utf-8")
                with self.assertRaises(ValueError): self.run_report()


class ValidationPlanTests(unittest.TestCase):
    def test_settings_source_selects_logic_first_and_keeps_integration_and_release(self):
        result = plan(["Packages/ReaderSettings/Sources/ReaderSettings/ReaderSettingsPersistence.swift"])
        names = [entry["name"] for entry in result["checksInOrder"]]
        self.assertLess(names.index("reader-logic"), names.index("ios-integration"))
        self.assertIn("XianxiaReader", result["affectedTargets"])
        self.assertFalse(result["acceptanceGranted"])
        self.assertTrue(result["releaseGate"]["unchanged"])

    def test_position_source_selects_independent_contracts_and_retains_app_integration(self):
        result = plan(["Packages/XianxiaCore/Sources/ReaderPositions/ReaderPositionState.swift"])
        checks = [entry["name"] for entry in result["checksInOrder"]]
        self.assertIn("position-logic", checks)
        self.assertIn("ios-integration", checks)
        self.assertIn("ReaderPositionsTests", result["affectedTargets"])
        self.assertFalse(result["acceptanceGranted"])
        self.assertTrue(result["releaseGate"]["unchanged"])

    def test_shared_test_changes_include_both_test_targets(self):
        result = plan(["Packages/ReaderSettings/Tests/ReaderSettingsTests/ReaderSettingsPersistenceTests.swift"])
        self.assertIn("ReaderSettingsTests", result["affectedTargets"])
        self.assertIn("XianxiaReaderTests", result["affectedTargets"])

    def test_core_change_propagates_to_settings_adapter_and_app(self):
        result = plan(["Packages/XianxiaCore/Sources/XianxiaCore/Models/Book.swift"])
        self.assertTrue({"ReaderSettings", "ReadiumAdapter", "XianxiaReader"} <= set(result["affectedTargets"]))

    def test_unknown_deleted_resource_and_configuration_inputs_fall_back(self):
        for file in ["App/Removed.swift", "project.yml", "Package.resolved", "Tests/Fixtures/new.epub", "App/Resources/Fonts/new.otf"]:
            with self.subTest(file=file):
                result = plan([file])
                self.assertTrue(result["conservativeFallback"])
                self.assertIn("native-ui", [entry["name"] for entry in result["checksInOrder"]])

    def test_docs_and_python_tools_do_not_request_a_native_build(self):
        for file, expected in [("Documentation/PROJECT_ISOLATION_PLAN.md", ["repository"]), ("scripts/check_architecture.py", ["repository", "tooling"])]:
            with self.subTest(file=file):
                self.assertEqual([entry["name"] for entry in plan([file])["checksInOrder"]], expected)

    def test_paths_cannot_escape_the_repository(self):
        for file in ["../Other/App.swift", "/tmp/App.swift", "C:/Other/App.swift"]:
            with self.assertRaises(ValueError): plan([file])


class ReaderLogicShellTests(unittest.TestCase):
    def test_real_shell_preserves_failure_and_refuses_stale_evidence(self):
        git_bash = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe"
        bash = str(git_bash) if os.name == "nt" and git_bash.is_file() else shutil.which("bash")
        self.assertIsNotNone(bash)
        for mode, expected in [("success", 0), ("swift-failure", 65), ("bad-dependencies", 1), ("stale", 2)]:
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as folder:
                root = Path(folder)
                (root / "scripts").mkdir()
                (root / "fakebin").mkdir()
                for name in ["test_reader_logic.sh", "verify_reader_logic.py"]:
                    shutil.copyfile(ROOT / "scripts" / name, root / "scripts" / name)
                suite = ET.Element("testsuite", tests="7", errors="0", failures="0")
                for name in sorted(EXPECTED_TESTS):
                    ET.SubElement(suite, "testcase", classname="ReaderSettingsPersistenceTests", name=name)
                tree = ET.Element("testsuites"); tree.append(suite)
                ET.ElementTree(tree).write(root / "fixture.xml")
                children = [{"name": "XianxiaCore", "dependencies": []}]
                if mode == "bad-dependencies": children.append({"name": "ReadiumToolkit", "dependencies": []})
                (root / "fixture-dependencies.json").write_text(json.dumps({"name": "ReaderSettings", "dependencies": children}), encoding="utf-8")
                helpers = {
                    "uname": '#!/bin/bash\necho Darwin\n',
                    "xcodebuild": '#!/bin/bash\necho "Xcode 16.4"\n',
                    "sw_vers": '#!/bin/bash\necho "fixture only"\n',
                    "python3": '#!/bin/bash\nexec "$READER_FIXTURE_PYTHON" "$@"\n',
                    "swift": '#!/bin/bash\nset -eu\ncase "$1" in\n--version) echo "Swift 6.1.2 fixture";;\npackage) cat fixture-dependencies.json;;\ntest) while [[ "$1" != --xunit-output ]]; do shift; done; shift; cp fixture.xml "$1"; exit "$READER_FIXTURE_TEST_EXIT";;\n*) exit 97;;\nesac\n',
                }
                for name, content in helpers.items():
                    path = root / "fakebin" / name
                    path.write_text(content, encoding="utf-8", newline="\n")
                    path.chmod(0o755)
                if mode == "stale":
                    (root / "build/ReaderLogic").mkdir(parents=True)
                environment = dict(os.environ, READER_FIXTURE_PYTHON=Path(sys.executable).as_posix(), READER_FIXTURE_TEST_EXIT="65" if mode == "swift-failure" else "0")
                result = subprocess.run([bash, "-c", 'PATH="$PWD/fakebin:$PATH" bash scripts/test_reader_logic.sh'], cwd=root, env=environment, capture_output=True, text=True)
                self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
                self.assertEqual((root / "build/ReaderLogic/receipt.json").exists(), mode == "success")


if __name__ == "__main__":
    unittest.main()
