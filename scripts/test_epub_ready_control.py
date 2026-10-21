from copy import deepcopy
import json
from pathlib import Path
import tempfile
import unittest

from verify_epub_ready_control import CASES, CONTROL, MARKER, verify


class EpubReadyEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "logs").mkdir()

    def fixture(self, phase):
        old = phase == "baseline"
        cases = {CONTROL} if old else CASES
        summary = dict(result="Failed" if old else "Passed", totalTestCount=len(cases),
                       passedTests=len(cases) - int(old), failedTests=int(old), skippedTests=0,
                       testFailures=[dict(testIdentifierString=CONTROL + "()", failureText=MARKER)] if old else [])
        lines = []
        for name in sorted(cases):
            cls, method = name.split("/")
            prefix = f"Test Case '-[XianxiaReaderTests.{cls} {method}]' "
            lines.extend([prefix + "started.", prefix + ("failed" if old else "passed") + " (1.000 seconds)."])
        rows = []
        for label in (["prepared", "failed"] if old else ["prepared", "ready", "released"]):
            ready = label in {"ready", "released"}
            rows.append(dict(phase=label, alpha=1 if ready else 0, attached=True, keyWindow=True, loading=False,
                             reportedHref="OEBPS/one.xhtml" if ready else "OEBPS/cover.xhtml", fullDOMAnchor=ready,
                             queryStartedUptime=1, queryFinishedUptime=2,
                             dom=dict(href="/OEBPS/one.xhtml", ready="complete", gate=dict(
                                 pending=0 if label == "released" else 1, sources=["()=>post('spreadLoaded')"])) ))
        return summary, lines, rows

    def check(self, phase, value=None, status=None):
        summary, lines, rows = value or self.fixture(phase)
        (self.root / "test-results-summary.json").write_text(json.dumps(summary))
        (self.root / "logs/reader-diagnostic.log").write_text("\n".join(lines + [
            "EPUB_NATIVE_READY_CONTROL_EVIDENCE " + json.dumps(row) for row in rows]) + "\n")
        return verify(self.root, phase, (65 if phase == "baseline" else 0) if status is None else status)

    def test_old_failure_and_new_success_require_different_real_outcomes(self):
        self.assertTrue(self.check("baseline")["qualifiedNegative"])
        self.assertEqual(self.check("patched")["passed"], 6)
        with self.assertRaises(ValueError): self.check("baseline", status=0)
        with self.assertRaises(ValueError): self.check("patched", status=65)

    def test_unqualified_old_failures_are_rejected(self):
        for kind in ["other-assertion", "visible", "wrong-position"]:
            summary, lines, rows = self.fixture("baseline")
            if kind == "other-assertion": summary["testFailures"][0]["failureText"] = "Unrelated timeout"
            elif kind == "visible": rows[-1]["alpha"] = 1
            else: rows[-1]["reportedHref"] = "OEBPS/one.xhtml"
            with self.subTest(kind=kind), self.assertRaises(ValueError): self.check("baseline", (summary, lines, rows))

    def test_target_bridge_and_native_preconditions_cannot_be_omitted(self):
        mutations = [lambda r: r.update(attached=False), lambda r: r.update(keyWindow=False),
                     lambda r: r.update(loading=True), lambda r: r["dom"].update(href="/OEBPS/cover.xhtml"),
                     lambda r: r["dom"].update(ready="loading"), lambda r: r["dom"]["gate"].update(pending=0),
                     lambda r: r["dom"]["gate"].update(sources=["unrelated callback"])]
        for phase in ["baseline", "patched"]:
            for mutate in mutations:
                value = self.fixture(phase); mutate(value[2][0])
                with self.subTest(phase=phase, mutate=mutate), self.assertRaises(ValueError): self.check(phase, value)

    def test_candidate_requires_visible_full_position_before_and_after_release(self):
        for kind in ["hidden", "cover", "percentage", "still-held", "missing-record"]:
            value = self.fixture("patched"); row = value[2][1]
            if kind == "hidden": row["alpha"] = 0
            elif kind == "cover": row["reportedHref"] = "OEBPS/cover.xhtml"
            elif kind == "percentage": row["fullDOMAnchor"] = False
            elif kind == "still-held": value[2][-1]["dom"]["gate"]["pending"] = 1
            else: value[2].pop()
            with self.subTest(kind=kind), self.assertRaises(ValueError): self.check("patched", value)

    def test_exact_cases_reject_retry_missing_failure_or_skip(self):
        for kind in ["duplicate", "missing", "failed", "skipped"]:
            summary, lines, rows = deepcopy(self.fixture("patched"))
            if kind == "duplicate": lines += lines
            elif kind == "missing": lines = lines[2:]
            elif kind == "failed": summary["failedTests"] = 1
            else: summary["skippedTests"] = 1
            with self.subTest(kind=kind), self.assertRaises(ValueError): self.check("patched", (summary, lines, rows))
