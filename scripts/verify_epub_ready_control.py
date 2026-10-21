"""Require a real held bridge, the qualified old failure and exact native cases."""
from collections import Counter
import argparse
import json
from pathlib import Path
import re

CONTROL = "ReaderRenderingTests/testPagedNativeLoadDoesNotWaitForAnimationFrameBridge"
CASES = {CONTROL} | {"ReaderRenderingTests/" + name for name in [
    "testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes",
    "testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge",
    "testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews",
    "testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord",
    "testSameWidthBodyResizeDoesNotOverwritePendingPagedWord",
]}
MARKER = "PAGED_NATIVE_READY_MUST_PUBLISH"


def verify(folder: Path, phase: str, status: int):
    summary = json.loads((folder / "test-results-summary.json").read_text())
    log = (folder / "logs/reader-diagnostic.log").read_text()
    expected = {CONTROL} if phase == "baseline" else CASES
    starts = Counter(f"{c}/{n}" for c, n in re.findall(r"^Test Case '-\[XianxiaReaderTests\.([^ ]+) ([^\]]+)\]' started\.$", log, re.M))
    ends = [(f"{c}/{n}", outcome) for c, n, outcome in re.findall(r"^Test Case '-\[XianxiaReaderTests\.([^ ]+) ([^\]]+)\]' (passed|failed) \([^\n]+\)\.$", log, re.M)]
    exact = Counter({name: 1 for name in expected})
    if starts != exact or Counter(name for name, _ in ends) != exact:
        raise ValueError("Exact selected identities must each start/end once")
    baseline = phase == "baseline"
    failed = 1 if baseline else 0
    if (status != (65 if baseline else 0) or summary.get("totalTestCount") != len(expected)
            or summary.get("passedTests") != len(expected) - failed or summary.get("failedTests") != failed
            or summary.get("skippedTests") != 0 or summary.get("result") != ("Failed" if baseline else "Passed")):
        raise ValueError("Native summary/exit does not match the original expected outcome")
    if {name for name, result in ends if result == "failed"} != ({CONTROL} if baseline else set()):
        raise ValueError("Only the qualified old control may fail")
    failures = summary.get("testFailures", [])
    if baseline:
        if not failures or not all(f.get("testIdentifierString") == CONTROL + "()" for f in failures) or not any(MARKER in f.get("failureText", "") for f in failures):
            raise ValueError("Old failure must reach the specific native-readiness assertion")
    elif failures:
        raise ValueError("Candidate has test failures")
    rows = [json.loads(line.split("EPUB_NATIVE_READY_CONTROL_EVIDENCE ", 1)[1]) for line in log.splitlines() if line.startswith("EPUB_NATIVE_READY_CONTROL_EVIDENCE ")]
    if [r.get("phase") for r in rows] != (["prepared", "failed"] if baseline else ["prepared", "ready", "released"]):
        raise ValueError("Missing, duplicate or reordered control evidence")
    for row in rows:
        dom = row.get("dom", {}); gate = dom.get("gate", {})
        if (dom.get("href") != "/OEBPS/one.xhtml" or dom.get("ready") != "complete"
                or row.get("attached") is not True or row.get("keyWindow") is not True or row.get("loading") is not False
                or not gate.get("sources") or not all("spreadLoaded" in s for s in gate["sources"])
                or row.get("queryFinishedUptime", -1) < row.get("queryStartedUptime", 0)):
            raise ValueError("Control must enter the real target document and actual bridge")
        pending = gate.get("pending", -1)
        if (row["phase"] == "released" and pending != 0) or (row["phase"] != "released" and pending < 1):
            raise ValueError("Bridge must remain held through readiness, then explicitly release")
    last = rows[-1]
    if baseline:
        if last.get("alpha", 1) >= 0.1 or last.get("reportedHref") != "OEBPS/cover.xhtml":
            raise ValueError("Old failure must retain the hidden target and cover report")
    else:
        if any(r.get("alpha", 0) <= 0.99 or r.get("reportedHref") != "OEBPS/one.xhtml" or r.get("fullDOMAnchor") is not True for r in rows[1:]):
            raise ValueError("Ready and released candidate must retain the real full text position")
    return dict(phase=phase, originalExit=status, passed=len(expected)-failed, failed=failed, skipped=0,
                qualifiedNegative=baseline, evidence=rows, summary=summary, fullGateExecuted=False, deviceAccepted=False)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("phase", choices=["baseline", "patched"])
    p.add_argument("folder", type=Path)
    p.add_argument("status", type=int)
    p.add_argument("report", type=Path)
    args = p.parse_args()
    result = verify(args.folder, args.phase, args.status)
    args.report.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {args.phase}: {result['passed']} pass/{result['failed']} failure; not release acceptance")
