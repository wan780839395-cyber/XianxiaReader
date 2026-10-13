import json
import os
from pathlib import Path
import plistlib
import stat
import tempfile
import unittest
from zipfile import ZipFile

from package_ipa import package
from select_simulator import select_device


class BuildToolingTests(unittest.TestCase):
    def test_selects_only_available_pinned_runtime_iphone(self):
        inventory = {"devices": {
            "com.apple.CoreSimulator.SimRuntime.iOS-18-4": [{"name": "iPhone 16", "isAvailable": True, "udid": "old"}],
            "com.apple.CoreSimulator.SimRuntime.iOS-18-5": [
                {"name": "iPad", "isAvailable": True, "udid": "tablet"},
                {"name": "iPhone 16", "isAvailable": False, "udid": "unavailable"},
                {"name": "iPhone 16 Pro", "isAvailable": True, "udid": "correct"}
            ]}}
        self.assertEqual(select_device(inventory), "correct")

    def test_missing_runtime_fails_instead_of_skipping_tests(self):
        with self.assertRaisesRegex(RuntimeError, "No available"):
            select_device({"devices": {}})

    def test_ipa_has_payload_executable_resources_and_unix_modes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            app = root / "XianxiaReader.app"
            app.mkdir()
            (app / "Info.plist").write_bytes(plistlib.dumps({"CFBundleSupportedPlatforms": ["iPhoneOS"], "CFBundleExecutable": "XianxiaReader"}))
            binary = app / "XianxiaReader"
            binary.write_bytes(b"test executable bytes")
            binary.chmod(0o755)
            (app / "Nested.bundle").mkdir()
            (app / "Nested.bundle/data.json").write_text(json.dumps({"resource": True}))
            if os.name != "nt":
                (app / "resource-link").symlink_to("Nested.bundle/data.json")
            output = root / "test.ipa"
            package(app, output)
            with ZipFile(output) as archive:
                self.assertEqual(archive.read("Payload/XianxiaReader.app/XianxiaReader"), b"test executable bytes")
                self.assertIn("Payload/XianxiaReader.app/Nested.bundle/data.json", archive.namelist())
                if os.name != "nt":
                    mode = archive.getinfo("Payload/XianxiaReader.app/XianxiaReader").external_attr >> 16
                    self.assertTrue(mode & stat.S_IXUSR)
                    link = archive.getinfo("Payload/XianxiaReader.app/resource-link")
                    self.assertTrue(stat.S_ISLNK(link.external_attr >> 16))

    def test_simulator_app_cannot_be_packaged_as_device_ipa(self):
        with tempfile.TemporaryDirectory() as directory:
            app = Path(directory) / "XianxiaReader.app"
            app.mkdir()
            (app / "Info.plist").write_bytes(plistlib.dumps({"CFBundleSupportedPlatforms": ["iPhoneSimulator"], "CFBundleExecutable": "XianxiaReader"}))
            (app / "XianxiaReader").write_bytes(b"test")
            with self.assertRaisesRegex(ValueError, "simulator"):
                package(app, Path(directory) / "invalid.ipa")

    def test_missing_application_executable_cannot_produce_ipa(self):
        with tempfile.TemporaryDirectory() as directory:
            app = Path(directory) / "XianxiaReader.app"
            app.mkdir()
            (app / "Info.plist").write_bytes(plistlib.dumps({"CFBundleSupportedPlatforms": ["iPhoneOS"], "CFBundleExecutable": "XianxiaReader"}))
            with self.assertRaisesRegex(ValueError, "executable is missing"):
                package(app, Path(directory) / "invalid.ipa")

    def test_executable_outside_bundle_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            app = Path(directory) / "XianxiaReader.app"
            app.mkdir()
            (app / "Info.plist").write_bytes(plistlib.dumps({"CFBundleSupportedPlatforms": ["iPhoneOS"], "CFBundleExecutable": "../outside"}))
            with self.assertRaisesRegex(ValueError, "bundle-local"):
                package(app, Path(directory) / "invalid.ipa")


if __name__ == "__main__":
    unittest.main()
