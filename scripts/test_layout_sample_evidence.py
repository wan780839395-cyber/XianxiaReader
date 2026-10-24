"""Controlled receipt tests; no Swift compiler, Docker, native test or 60s wait."""
import ast
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import test_readium_provenance as provenance
from layout_sample_evidence import LayoutSampleEvidence, OUTPUT_BYTES, UPLOAD_STEP, bounded_output, without_layout_sample_upload

ROOT = Path(__file__).resolve().parents[1]
METHOD = "test_layout_generation_actual_sample_and_restore_behavior"
SOURCE = (ROOT / "Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift").read_text(encoding="utf-8")


def completed(stdout="", stderr="", code=0):
    return subprocess.CompletedProcess([], code, stdout, stderr)


def successful():
    return [completed(), completed("Swift version controlled\nTarget: fixture\n"),
            completed("LAYOUT_SAMPLE_BASELINE_CONFIRMED\n"), completed(),
            completed("LAYOUT_SAMPLE_SWIFT_PASS\n")]


class LayoutSampleEvidenceTests(unittest.TestCase):
    def simulate(self, root, responses, *, docker=False):
        seen = []
        responses = iter(responses)

        def run(command, **kwargs):
            receipt = json.loads((root / ".cache/layout-sample/behavior.json").read_text(encoding="utf-8"))
            self.assertEqual(receipt["phases"][-1]["outcome"], "started")
            seen.append((command, kwargs, receipt["phases"][-1]["phase"]))
            value = next(responses)
            if isinstance(value, BaseException):
                raise value
            return value

        which = (lambda name: None if name == "swiftc" else "controlled-docker") if docker else (lambda name: "controlled-swiftc")
        case = provenance.ReadiumProvenanceTests(METHOD)
        with patch.object(provenance, "ROOT", root), \
             patch.object(provenance.ReadiumProvenanceTests, "inner_sources", return_value={"EPUBInfiniteScrollView.swift": SOURCE}), \
             patch.object(provenance.shutil, "which", side_effect=which), \
             patch("layout_sample_evidence.subprocess.run", side_effect=run):
            getattr(case, METHOD)()
        return seen

    def receipt(self, root):
        return json.loads((root / ".cache/layout-sample/behavior.json").read_text(encoding="utf-8"))

    def test_actual_entry_success_preserves_commands_budgets_markers_and_fixture_hashes(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            seen = self.simulate(root, successful())
            self.assertEqual([x[2] for x in seen], ["baseline-compile", "compiler-version", "baseline-run", "current-compile", "current-run"])
            self.assertEqual([x[1]["timeout"] for x in seen], [60, 5, 30, 60, 90])
            self.assertEqual(seen[0][0][1:4], ["-swift-version", "6", "-parse-as-library"])
            self.assertEqual(seen[3][0][1:4], ["-swift-version", "6", "-parse-as-library"])
            self.assertTrue(all(x[1] == dict(capture_output=True, text=True, encoding="utf-8", timeout=t)
                                for x, t in zip(seen, [60, 5, 30, 60, 90])))
            record = self.receipt(root)
            self.assertTrue(record["passed"]); self.assertTrue(record["executed"])
            self.assertTrue(record["compiler"]["probeAfterLegacyCompile"])
            self.assertEqual(record["compiler"]["path"], "controlled-swiftc")
            self.assertIn("Swift version controlled", record["compiler"]["version"])
            for key, name in [("baselineHarnessSHA256", "baseline.swift"), ("harnessSHA256", "harness.swift")]:
                self.assertEqual(record[key], hashlib.sha256((root / ".cache/layout-sample" / name).read_bytes()).hexdigest())
            self.assertTrue(all(x["elapsedSeconds"] >= 0 and x["outcome"] == "returned" for x in record["phases"]))

    def test_actual_entry_nonzero_compile_remains_assertion_failure(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            with self.assertRaises(AssertionError):
                self.simulate(root, [completed(stderr="token=controlled-private", code=7), completed("Swift version controlled")])
            record = self.receipt(root)
            self.assertFalse(record["passed"]); self.assertEqual(record["failurePhase"], "baseline-compile")
            self.assertEqual(record["baselineCompileExit"], 7)
            self.assertEqual(len(record["phases"]), 2)
            self.assertNotIn("controlled-private", json.dumps(record))

    def test_actual_entry_missing_success_marker_cannot_mark_receipt_passed(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d); results = successful(); results[-1] = completed("marker absent")
            with self.assertRaises(AssertionError):
                self.simulate(root, results)
            self.assertFalse(self.receipt(root)["passed"])

    def test_each_original_timeout_is_preserved_with_partial_bytes_and_no_following_phase(self):
        for index, phase, timeout in [(0, "baseline-compile", 60), (2, "baseline-run", 30),
                                      (3, "current-compile", 60), (4, "current-run", 90)]:
            with self.subTest(phase=phase), tempfile.TemporaryDirectory() as d:
                root = Path(d)
                error = subprocess.TimeoutExpired(["controlled"], timeout, output=b"partial-\xff", stderr=b"stderr token=controlled-private")
                results = successful()[:index] + [error]
                if index == 0:
                    results.append(completed("Swift version controlled"))
                with self.assertRaises(subprocess.TimeoutExpired) as caught:
                    self.simulate(root, results)
                self.assertIs(caught.exception, error)
                record = self.receipt(root)
                self.assertFalse(record["passed"])
                self.assertEqual(record["failurePhase"], phase)
                event = next(x for x in record["phases"] if x["phase"] == phase)
                self.assertEqual(event["outcome"], "timeout"); self.assertEqual(event["timeoutSeconds"], timeout)
                self.assertIn("partial-", event["stdout"]["text"]); self.assertIn("stderr", event["stderr"]["text"])
                self.assertNotIn("controlled-private", json.dumps(record))
                self.assertEqual(len(record["phases"]), 2 if index == 0 else index + 1)

    def test_optional_version_timeout_does_not_replace_the_original_compile_timeout(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            original = subprocess.TimeoutExpired(["compile"], 60)
            metadata = subprocess.TimeoutExpired(["version"], 5)
            with self.assertRaises(subprocess.TimeoutExpired) as caught:
                self.simulate(root, [original, metadata])
            self.assertIs(caught.exception, original)
            record = self.receipt(root)
            self.assertEqual(record["failurePhase"], "baseline-compile")
            self.assertFalse(record["diagnosticsComplete"])
            self.assertIsNone(record["compiler"]["version"])

    def test_optional_version_failure_is_explicit_without_changing_original_success_checks(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d); results = successful(); results[1] = completed(code=9)
            self.simulate(root, results)
            record = self.receipt(root)
            self.assertTrue(record["passed"]); self.assertFalse(record["diagnosticsComplete"])
            self.assertEqual(record["phases"][1]["returncode"], 9)
            self.assertIsNone(record["compiler"]["version"])

    def test_docker_route_keeps_existing_inspect20_and_combined90_without_environment_dump(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            image = dict(Id="controlled-image", RepoDigests=["controlled-digest"], Config=dict(Env=["PRIVATE=not-recorded"]))
            seen = self.simulate(root, [completed(json.dumps([image]).encode(), b""),
                                       completed("Swift version controlled\nLAYOUT_SAMPLE_BASELINE_CONFIRMED\nLAYOUT_SAMPLE_SWIFT_PASS\n")], docker=True)
            self.assertEqual([x[1]["timeout"] for x in seen], [20, 90])
            self.assertEqual(seen[0][1], dict(capture_output=True, timeout=20))
            self.assertIn("--rm", seen[1][0]); self.assertIn("--pull=never", seen[1][0]); self.assertIn("--network=none", seen[1][0])
            self.assertIn("swiftc --version", seen[1][0][-1])
            record = self.receipt(root)
            self.assertTrue(record["passed"]); self.assertNotIn("not-recorded", json.dumps(record))
            self.assertEqual(record["compiler"]["version"], "Swift version controlled")

    def test_output_caps_redaction_and_ci_context_allowlist(self):
        value = bounded_output(("山" * 20000) + "\nAuthorization: Bearer controlled-private\ntoken=another-private")
        self.assertTrue(value["truncated"]); self.assertTrue(value["redacted"])
        self.assertLessEqual(len(value["text"].encode()), OUTPUT_BYTES)
        self.assertNotIn("controlled-private", value["text"]); self.assertNotIn("another-private", value["text"])
        with tempfile.TemporaryDirectory() as d, patch.dict(os.environ, {"GITHUB_SHA": "a" * 40, "GITHUB_RUN_ID": "123",
                                                                       "GITHUB_RUN_ATTEMPT": "1", "UNRELATED_SECRET": "not-recorded"}):
            evidence = LayoutSampleEvidence(Path(d) / "behavior.json", {})
            self.assertEqual(evidence.record["context"], dict(GITHUB_SHA="a" * 40, GITHUB_RUN_ID="123", GITHUB_RUN_ATTEMPT="1"))
            self.assertNotIn("not-recorded", evidence.receipt.read_text())

    def test_receipt_write_error_cannot_replace_original_timeout(self):
        with tempfile.TemporaryDirectory() as d:
            evidence = LayoutSampleEvidence(Path(d) / "behavior.json", {})
            error = subprocess.TimeoutExpired(["controlled"], 60, output=b"partial")
            with patch.object(evidence, "persist", side_effect=[None, OSError("controlled save failure")]), \
                 patch("layout_sample_evidence.subprocess.run", side_effect=error):
                with self.assertRaises(subprocess.TimeoutExpired) as caught:
                    evidence.run("baseline-compile", ["controlled"], timeout=60)
            self.assertIs(caught.exception, error)
            self.assertIn("Layout receipt write failed", error.__notes__[0])

    def test_lightweight_real_process_success_and_failure_keep_original_exit_codes(self):
        with tempfile.TemporaryDirectory() as d:
            evidence = LayoutSampleEvidence(Path(d) / "behavior.json", {})
            for code in [0, 7]:
                result = evidence.run("baseline-compile",
                                      [sys.executable, "-c", "import sys; print('controlled output'); sys.exit(" + str(code) + ")"],
                                      timeout=10)
                self.assertEqual(result.returncode, code)
            self.assertEqual(evidence.record["phases"][-1]["returncode"], 7)

    def test_upload_whitelist_and_original_gate_operands_generator_are_preserved(self):
        from check_architecture import yaml
        workflow = (ROOT / ".github/workflows/ios-build.yml").read_text(encoding="utf-8")
        self.assertEqual(workflow.count(UPLOAD_STEP), 1)
        step = next(x for x in yaml.load(workflow, Loader=yaml.BaseLoader)["jobs"]["repository-checks"]["steps"]
                    if x.get("name") == "Preserve bounded layout sample evidence")
        self.assertEqual(step["if"], "always()"); self.assertEqual(step["uses"], "actions/upload-artifact@v4")
        self.assertEqual(step["with"]["include-hidden-files"], "true")
        self.assertEqual(step["with"]["path"].splitlines(), [".cache/layout-sample/baseline.swift",
                                                            ".cache/layout-sample/harness.swift",
                                                            ".cache/layout-sample/behavior.json"])
        self.assertNotIn("continue-on-error", step)
        with self.assertRaises(ValueError): without_layout_sample_upload(workflow + UPLOAD_STEP)
        source = (ROOT / "scripts/test_readium_provenance.py").read_text(encoding="utf-8")
        tree = ast.parse(source)
        method = next(n for n in ast.walk(tree) if isinstance(n, ast.FunctionDef) and n.name == METHOD)
        operands = [ast.dump(ast.Tuple(elts=n.args[:2], ctx=ast.Load()), include_attributes=False)
                    for n in ast.walk(method) if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute) and n.func.attr.startswith("assert")]
        self.assertEqual(operands, ORIGINAL_ASSERTION_OPERANDS)
        generator = next(n for n in ast.walk(tree) if isinstance(n, ast.FunctionDef) and n.name == "layout_sample_harness")
        text = "".join(source.splitlines(keepends=True)[generator.lineno - 1:generator.end_lineno])
        self.assertEqual(hashlib.sha256(text.encode()).hexdigest(), ORIGINAL_GENERATOR_SHA256)


ORIGINAL_ASSERTION_OPERANDS = ["Tuple(elts=[Attribute(value=Name(id='result', ctx=Load()), attr='returncode', ctx=Load()), Constant(value=0)], ctx=Load())", "Tuple(elts=[Constant(value='LAYOUT_SAMPLE_SWIFT_PASS'), Attribute(value=Name(id='result', ctx=Load()), attr='stdout', ctx=Load())], ctx=Load())", "Tuple(elts=[Attribute(value=Name(id='old_compile', ctx=Load()), attr='returncode', ctx=Load()), Constant(value=0)], ctx=Load())", "Tuple(elts=[Attribute(value=Name(id='old_run', ctx=Load()), attr='returncode', ctx=Load()), Constant(value=0)], ctx=Load())", "Tuple(elts=[Constant(value='LAYOUT_SAMPLE_BASELINE_CONFIRMED'), Attribute(value=Name(id='old_run', ctx=Load()), attr='stdout', ctx=Load())], ctx=Load())", "Tuple(elts=[Attribute(value=Name(id='compiled', ctx=Load()), attr='returncode', ctx=Load()), Constant(value=0)], ctx=Load())", "Tuple(elts=[Constant(value='LAYOUT_SAMPLE_BASELINE_CONFIRMED'), Attribute(value=Name(id='result', ctx=Load()), attr='stdout', ctx=Load())], ctx=Load())"]
ORIGINAL_GENERATOR_SHA256 = '4d26b64bd85380352d82f57fb906f1799a1d0d08fc41efad06badf94808ddf1b'

if __name__ == "__main__":
    unittest.main()
