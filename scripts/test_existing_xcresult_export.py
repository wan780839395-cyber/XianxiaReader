import json
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import export_existing_xcresult as export


class ExistingResultExportTests(unittest.TestCase):
    def metadata(self):
        return {"id": export.ARTIFACT_ID, "name": export.ARTIFACT_NAME,
                "digest": export.DIGEST, "expired": False,
                "workflow_run": {"id": export.RUN_ID, "head_sha": export.SOURCE_SHA}}

    def test_exact_original_artifact_only(self):
        export.validate_source(self.metadata())
        for key, value in [("id", 1), ("digest", "sha256:other"), ("expired", True)]:
            meta = self.metadata()
            meta[key] = value
            with self.assertRaises(ValueError):
                export.validate_source(meta)
        meta = self.metadata()
        meta["workflow_run"]["head_sha"] = "other"
        with self.assertRaises(ValueError):
            export.validate_source(meta)

    def test_extract_original_bundle_without_other_artifact_content(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive = root / "source.zip"
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("DiagnosticTests.xcresult/Info.plist", "fixture")
                bundle.writestr("DiagnosticTests.xcresult/database.sqlite3", "fixture")
                bundle.writestr("ReaderSnapshots/video.mp4", "do not extract")
            result = export.extract_result(archive, root / "input")
            self.assertTrue((result / "Info.plist").exists())
            self.assertFalse((root / "input/ReaderSnapshots").exists())
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("DiagnosticTests.xcresult/../escape", "bad")
            with self.assertRaises(ValueError):
                export.extract_result(archive, root / "unsafe")

    def test_existing_stdout_and_events_are_selected_without_device_logs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            raw, output = root / "raw", root / "result"
            raw.mkdir()
            output.mkdir()
            (raw / "StandardOutputAndStandardError.txt").write_text("XRPresentation reader.appeared\n", encoding="utf-8")
            (raw / "system.log").write_text("unrelated existing diagnostics", encoding="utf-8")
            (raw / "binary").write_bytes(b"\0other")
            result = export.select_existing_text(raw, output)
            self.assertEqual(len(result["files"]), 1)
            self.assertEqual(result["files"][0]["counts"]["reader.appeared"], 1)
            self.assertFalse((output / "existing-text/system.log").exists())
            self.assertIn("does not prove", result["limitation"])

    def test_original_failure_and_timeout_partial_output_remain_failures(self):
        for result in [subprocess.CompletedProcess(["fixture"], 7, b"out", b"err"),
                       subprocess.TimeoutExpired(["fixture"], 1, output=b"partial", stderr=b"partial-error")]:
            with self.subTest(result=type(result).__name__), tempfile.TemporaryDirectory() as directory:
                output = Path(directory)
                options = {"side_effect": result} if isinstance(result, Exception) else {"return_value": result}
                with patch.object(export.subprocess, "run", **options), self.assertRaises(RuntimeError):
                    export.command(["fixture"], "original", output, 1)
                receipt = json.loads((output / "original.json").read_text())
                self.assertEqual(receipt["exitCode"], None if isinstance(result, Exception) else 7)
                self.assertEqual((output / "original.stdout.txt").read_bytes(), b"partial" if isinstance(result, Exception) else b"out")

    def test_export_mode_runs_no_existing_build_or_test_job(self):
        workflow = (Path(__file__).resolve().parents[1] / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        chunks = re.split(r"^  ([a-z][a-z-]+):\s*$", workflow.split("\njobs:\n", 1)[1], flags=re.M)
        active = []
        for name, body in zip(chunks[1::2], chunks[2::2]):
            expression = re.search(r"^    if: \$\{\{ (.*?) \}\}$", body, re.M)
            self.assertIsNotNone(expression, name)
            value = expression.group(1).replace("inputs.diagnostic_selection", repr("xcresult-export"))
            value = value.replace("github.event_name", repr("workflow_dispatch"))
            value = value.replace("&&", " and ").replace("||", " or ")
            value = re.sub(r"!(?!=)", " not ", value)
            if eval(value.strip(), {"__builtins__": {}}, {}):
                active.append(name)
        self.assertEqual(active, ["existing-result-export"])
        job = chunks[-1]
        self.assertNotIn("needs:", job)
        self.assertIn("retention-days: 1", job)
        self.assertIn("persist-credentials: false", job)
        self.assertEqual(workflow.count("python3 scripts/export_existing_xcresult.py"), 1)
        self.assertNotIn("xcodebuild test", job)
        self.assertNotIn("simctl", job)


if __name__ == "__main__":
    unittest.main()
