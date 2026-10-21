"""Mutate disposable source/project fixtures to prove the real boundary guard rejects drift."""
from contextlib import contextmanager
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from check_architecture import BoundaryError, ROOT, check_architecture, yaml


class ArchitectureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.template = tempfile.TemporaryDirectory()
        cls.template_root = Path(cls.template.name)
        paths = [ROOT / "project.yml", ROOT / "Documentation/architecture-boundaries.json"]
        for base in ["App", "Packages", "Tests"]:
            paths.extend(path for path in (ROOT / base).rglob("*.swift") if not any(part in {".build", ".swiftpm"} for part in path.parts))
        for path in paths:
            destination = cls.template_root / path.relative_to(ROOT)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, destination)
        policy = json.loads((cls.template_root / "Documentation/architecture-boundaries.json").read_text(encoding="utf-8"))
        for package in policy["packages"].values():
            for target in package["targets"].values():
                # Native C target paths exist in the real project; this static
                # fixture does not compile their headers or duplicate assets.
                (cls.template_root / package["path"] / target["path"]).mkdir(parents=True, exist_ok=True)

    @classmethod
    def tearDownClass(cls):
        cls.template.cleanup()

    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name) / "project"
        shutil.copytree(self.template_root, self.root)

    @contextmanager
    def change(self, relative, transform):
        path = self.root / relative
        original = path.read_text(encoding="utf-8")
        replacement = transform(original)
        self.assertNotEqual(original, replacement, "Fault injection did not change its input")
        path.write_text(replacement, encoding="utf-8")
        try:
            yield
        finally:
            path.write_text(original, encoding="utf-8")

    def blocked(self, message):
        with self.assertRaisesRegex(BoundaryError, message):
            check_architecture(self.root)

    def test_real_repository_and_disposable_fixture_pass_with_honest_scope(self):
        real = check_architecture(ROOT)
        fixture = check_architecture(self.root)
        self.assertGreater(real["swiftFiles"], 0)
        self.assertEqual(real, fixture)
        self.assertFalse(real["swiftCompiled"])
        self.assertFalse(real["sameTargetTypeAccessIsolated"])

    def test_core_ui_import_is_rejected_in_all_supported_import_forms(self):
        file = "Packages/XianxiaCore/Sources/XianxiaCore/Models/Book.swift"
        for statement in ["import UIKit", "    import UIKit", "@preconcurrency import UIKit",
                          "@_exported import UIKit", "import class UIKit.UIView",
                          "#if os(iOS)\nimport UIKit\n#endif"]:
            with self.subTest(statement=statement), self.change(file, lambda text: text + "\n" + statement + "\n"):
                self.blocked("Core must not import UIKit")

    def test_comments_and_strings_are_not_imports(self):
        file = "Packages/XianxiaCore/Sources/XianxiaCore/Models/Book.swift"
        text = '\n// import UIKit\n/* outer /* import WebKit */ still comment */\nlet boundaryExample = #"import ReadiumShared"#\n'
        with self.change(file, lambda original: original + text):
            check_architecture(self.root)

    def test_reader_cannot_borrow_another_files_readium_exception(self):
        with self.change("App/Reader/ReaderViewModel.swift", lambda text: text + "\nimport ReadiumAdapter\n"):
            self.blocked("Reader must not import ReadiumAdapter")

    def test_settings_storage_cannot_acquire_reader_or_ui_dependencies(self):
        for module in ["ReadingInterfaces", "SwiftUI", "UIKit"]:
            with self.subTest(module=module), self.change("Packages/ReaderSettings/Sources/ReaderSettings/ReaderSettingsPersistence.swift", lambda text: text + f"\nimport {module}\n"):
                self.blocked(f"must not import {module}")

    def test_font_coordination_cannot_acquire_app_or_engine_implementation_dependencies(self):
        file = "Packages/XianxiaReading/Sources/ReaderFonts/ReaderFontCoordinator.swift"
        for module in ["XianxiaReader", "ReadiumAdapter", "ReadiumNavigator", "UIKit", "SwiftUI"]:
            with self.subTest(module=module), self.change(file, lambda text: text + f"\nimport {module}\n"):
                self.blocked(f"Font coordination must not import {module}")

    def test_position_state_cannot_acquire_ui_or_engine_dependencies(self):
        file = "Packages/XianxiaCore/Sources/ReaderPositions/ReaderPositionState.swift"
        for module in ["ReadingInterfaces", "ReaderFonts", "ReadiumAdapter", "ReadiumNavigator", "UIKit", "SwiftUI"]:
            with self.subTest(module=module), self.change(file, lambda text: text + f"\nimport {module}\n"):
                self.blocked(f"Position state must not import {module}")

    def test_native_ui_tests_cannot_import_app_business_modules(self):
        file = next((self.root / "Tests/UI").glob("*.swift")).relative_to(self.root).as_posix()
        with self.change(file, lambda text: text + "\nimport XianxiaCore\n"):
            self.blocked("Native UI tests must not import XianxiaCore")

    def test_new_feature_requires_explicit_ownership(self):
        path = self.root / "App/NewFeature/Feature.swift"
        path.parent.mkdir()
        path.write_text("import Foundation\n", encoding="utf-8")
        self.blocked("new features need an owner")

    def test_registered_target_outside_usual_roots_still_requires_an_owner(self):
        project_path = self.root / "project.yml"
        project = yaml.load(project_path.read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        project["targets"]["NewFeature"] = {"type": "framework", "sources": [{"path": "NewFeature"}], "dependencies": []}
        project_path.write_text(yaml.safe_dump(project), encoding="utf-8")
        policy_path = self.root / "Documentation/architecture-boundaries.json"
        policy = json.loads(policy_path.read_text(encoding="utf-8"))
        policy["projectTargets"]["NewFeature"] = {"kind": "framework", "sources": ["NewFeature"], "dependencies": []}
        policy_path.write_text(json.dumps(policy), encoding="utf-8")
        path = self.root / "NewFeature/Feature.swift"
        path.parent.mkdir()
        path.write_text("import Foundation\n", encoding="utf-8")
        self.blocked("new features need an owner")

    def test_new_source_cannot_use_sdk_imports_outside_its_allowance(self):
        path = self.root / "App/Search/NewSearch.swift"
        path.write_text("import WebKit\n", encoding="utf-8")
        self.blocked("Search must not import WebKit")

    def test_existing_target_reverse_dependency_cycle_is_rejected(self):
        file = "Packages/XianxiaReading/Package.swift"
        with self.change(file, lambda text: text.replace('name: "ReadingInterfaces", dependencies: [', 'name: "ReadingInterfaces", dependencies: ["ReadiumAdapter", ', 1)):
            self.blocked("Dependency cycle: .*ReadingInterfaces.*ReadiumAdapter")

    def test_new_swiftpm_target_is_not_silently_accepted(self):
        file = "Packages/XianxiaReading/Package.swift"
        with self.change(file, lambda text: text.replace("    targets: [", '    targets: [\n        .target(name: "NewFeature"),', 1)):
            self.blocked("Target dependencies/type/source paths changed")

    def test_new_package_and_dynamic_manifest_statements_need_review(self):
        path = self.root / "Packages/Other/Package.swift"
        path.parent.mkdir()
        path.write_text("import PackageDescription\n", encoding="utf-8")
        self.blocked("Unregistered or missing first-party Package.swift")
        path.unlink()
        with self.change("Packages/XianxiaReading/Package.swift", lambda text: text + '\npackage.targets.append(.target(name: "Other"))\n'):
            self.blocked("dynamic manifest statements require review")

    def test_product_package_identity_cannot_be_swapped(self):
        with self.change("Packages/XianxiaReading/Package.swift", lambda text: text.replace('name: "XianxiaCore", package: "XianxiaCore"', 'name: "XianxiaCore", package: "ReadiumToolkit"', 1)):
            self.blocked("unregistered product ReadiumToolkit/XianxiaCore")

    def test_nonliteral_dependency_array_is_rejected(self):
        file = "Packages/XianxiaReading/Package.swift"
        with self.change(file, lambda text: text.replace('dependencies: [.product(name: "XianxiaCore", package: "XianxiaCore")]', 'dependencies: injectedDependencies', 1)):
            self.blocked("expected a literal array")

    def test_package_cycle_is_rejected_even_without_a_target_cycle(self):
        policy_path = self.root / "Documentation/architecture-boundaries.json"
        policy = json.loads(policy_path.read_text(encoding="utf-8"))
        policy["packages"]["XianxiaCore"]["packagePaths"] = ["../XianxiaReading"]
        policy_path.write_text(json.dumps(policy), encoding="utf-8")
        with self.change("Packages/XianxiaCore/Package.swift", lambda text: text.replace("    targets: [", '    dependencies: [.package(path: "../XianxiaReading")],\n    targets: [', 1)):
            self.blocked("Dependency cycle: .*XianxiaCore -> XianxiaReading -> XianxiaCore")

    def test_xcodegen_new_target_reverse_edge_and_source_redirect_are_rejected(self):
        path = self.root / "project.yml"
        original = path.read_text(encoding="utf-8")
        for mode in ["new", "edge", "source"]:
            with self.subTest(mode=mode):
                project = yaml.load(original, Loader=yaml.BaseLoader)
                if mode == "new":
                    project["targets"]["NewFeature"] = dict(project["targets"]["XianxiaReader"])
                elif mode == "edge":
                    project["targets"]["XianxiaReader"]["dependencies"].append({"target": "XianxiaReaderTests"})
                else:
                    project["targets"]["XianxiaReader"]["sources"][0]["path"] = "Tests/iOS"
                path.write_text(yaml.safe_dump(project), encoding="utf-8")
                self.blocked("Unregistered or missing XcodeGen target|Dependency cycle|Target dependencies/type/source paths changed")
        path.write_text(original, encoding="utf-8")

    def test_unused_exception_must_be_removed(self):
        policy = json.loads((self.root / "Documentation/architecture-boundaries.json").read_text(encoding="utf-8"))
        exception = policy["exceptions"][0]
        with self.change(exception["file"], lambda text: text.replace("import " + exception["import"], "// removed import", 1)):
            self.blocked("Stale architecture exception")

    def test_excluding_owned_source_cannot_hide_it_from_the_build(self):
        path = self.root / "project.yml"
        project = yaml.load(path.read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        project["targets"]["XianxiaReader"]["sources"][0]["excludes"].append("Reader")
        path.write_text(yaml.safe_dump(project), encoding="utf-8")
        self.blocked("compile source ownership mismatch")

    def test_two_registered_targets_cannot_compile_the_same_source(self):
        project_path = self.root / "project.yml"
        project = yaml.load(project_path.read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
        project["targets"]["XianxiaReaderUITests"]["sources"] = [{"path": "Tests/iOS"}]
        project_path.write_text(yaml.safe_dump(project), encoding="utf-8")
        policy_path = self.root / "Documentation/architecture-boundaries.json"
        policy = json.loads(policy_path.read_text(encoding="utf-8"))
        policy["projectTargets"]["XianxiaReaderUITests"]["sources"] = ["Tests/iOS"]
        policy_path.write_text(json.dumps(policy), encoding="utf-8")
        self.blocked("compile source ownership mismatch")

    def test_only_the_exact_contract_test_source_can_be_shared(self):
        report = check_architecture(self.root)
        shared = [source for source in report["sources"] if len(source["compiledTargets"]) > 1]
        self.assertEqual(len(shared), 1)
        self.assertEqual(shared[0]["compiledTargets"], ["ReaderSettingsTests", "XianxiaReaderTests"])

    def test_production_cannot_use_the_shared_test_allowance(self):
        path = self.root / "Documentation/architecture-boundaries.json"
        policy = json.loads(path.read_text(encoding="utf-8"))
        policy["sharedTestSources"]["App/AppServices.swift"] = {"targets": ["XianxiaReader", "XianxiaReaderTests"], "reason": "Invalid production sharing"}
        path.write_text(json.dumps(policy), encoding="utf-8")
        self.blocked("shared source allowance is test-only")

    def test_unparsed_source_is_a_failure_not_an_empty_import_list(self):
        with self.change("App/Reader/ReaderViewModel.swift", lambda text: text + "\nfunc incomplete( {\n"):
            self.blocked("unparsed Swift syntax")


if __name__ == "__main__":
    unittest.main()
