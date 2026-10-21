"""Require exact session contracts and a qualified old-callback negative control."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

LOGIC_TESTS = {
    "testAdmissionRetainsFailedOpenUntilCloseAndRejectsDuplicateOpen",
    "testForeignBookCannotPublishWithinCurrentSession",
    "testCapturedCallbacksCannotPublishAfterCloseOrSameBookReopen",
    "testFinalSynchronousPositionIsAcceptedBeforeInvalidation",
    "testAcceptedWorkFinishesButLateErrorCannotPublishIntoReopenedSession",
    "testFailedFontRebuildAllowsOpeningWithoutPrematurelyDroppingOwner",
}
CONTROL = "ReaderLifecycleTests/testClosedAndReopenedSessionRejectsCapturedOldCallbacks"
NATIVE_TESTS = {CONTROL} | {"ReaderLifecycleTests/" + name for name in [
    "testClosedSessionRejectsEventsAndPreservesFinalEmittedPosition",
    "testPositionBurstPublishesOnlyProgressAndPreservesLatestFullLocator",
    "testCloseDuringOpenCannotReturnReaderToReadyState",
    "testFailedOpenCanRetryAndBecomeReady",
    "testLatePositionAfterCloseIsNotPersisted",
    "testOldSettingsFailureCannotPublishIntoSameModelReopenedSession",
    "testLateSaveCaptureCannotOverwriteProgressAfterCloseAndReopen",
    "testReturnCaptureCloseReopenLateResultCannotNavigateOrClearNewRequest",
    "testLateChapterNavigationCannotHideReopenedReadersMenu",
    "testLateBookmarkFailureAfterCloseCannotShowError",
    "testInteractionRestoresSerialEditsAndLateGesturesCannotHideMenuAfterClose",
    "testAutomaticScrollExplicitStartSpeedPersistenceBackgroundPauseAndStaticReopen",
]}


def verify_logic(folder):
    root = ET.parse(folder / "tests.xml").getroot()
    suites = list(root.iter("testsuite"))
    if len(suites) != 1 or any(int(suites[0].get(k, "0")) for k in ["errors", "failures", "skipped"]):
        raise ValueError("Session contracts contain unexpected/failed/skipped suites")
    names = Counter()
    for case in root.iter("testcase"):
        name = case.get("name", "").removesuffix("()")
        if (case.get("classname") not in {"ReaderSessionStateTests", "ReaderSessionsTests.ReaderSessionStateTests"}
                or any(n.tag in {"failure", "error", "skipped"} for n in case.iter())):
            raise ValueError("Session contract has wrong class or did not pass")
        names[name] += 1
    if names != Counter({n: 1 for n in LOGIC_TESTS}) or int(suites[0].get("tests", "-1")) != len(LOGIC_TESTS):
        raise ValueError("Every session contract must execute exactly once")
    graph = json.loads((folder / "dependencies.json").read_text(encoding="utf-8"))
    if graph.get("name") != "ReaderSessions" or graph.get("dependencies") != []:
        raise ValueError("Session logic must have no package dependencies")
    return dict(passed=len(names), failed=0, skipped=0, cases=sorted(names), appHostUsed=False)


def verify_native(folder, baseline, status):
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    events = re.findall(r"^Test Case '-\[XianxiaReaderTests\.([^ ]+) ([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed \([^\n]+\)\.)$", log, re.M)
    expected = Counter({n: 1 for n in ({CONTROL} if baseline else NATIVE_TESTS)})
    starts = Counter(f"{c}/{n}" for c, n, result in events if result == "started.")
    ends = [(f"{c}/{n}", result) for c, n, result in events if result != "started."]
    if starts != expected or Counter(n for n, _ in ends) != expected:
        raise ValueError("Exact selected session cases must each start/end once")
    failures = {n for n, result in ends if result.startswith("failed")}
    if failures != ({CONTROL} if baseline else set()):
        raise ValueError("Only the designated old session control may fail")
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    failed = 1 if baseline else 0
    required = dict(totalTestCount=len(expected), passedTests=len(expected)-failed,
                    failedTests=failed, skippedTests=0, result="Failed" if baseline else "Passed")
    if status != (65 if baseline else 0) or any(summary.get(k) != v for k, v in required.items()):
        raise ValueError("Session xcresult summary and true exit must match selected outcomes")
    details = summary.get("testFailures", [])
    if baseline:
        if (log.count("READER_SESSION_CONTROL_READY sameModelReopened=true currentPositionStored=true") != 1
                or not details or not all(f.get("testIdentifierString") == CONTROL + "()"
                                         and "STALE_SESSION_CALLBACK" in f.get("failureText", "") for f in details)):
            raise ValueError("Old control must reopen/store successfully and fail only at stale callback assertions")
    elif details:
        raise ValueError("Candidate session cases contain failures")
    return dict(passed=len(expected)-failed, failed=failed, skipped=0, cases=sorted(expected),
                qualifiedNegative=baseline, originalExit=status, appHostUsed=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=["logic", "baseline", "candidate"])
    parser.add_argument("folder", type=Path)
    parser.add_argument("--status", type=int, default=0)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    result = verify_logic(args.folder) if args.kind == "logic" else verify_native(args.folder, args.kind == "baseline", args.status)
    result.update(fullGateExecuted=False, releaseAccepted=False, deviceAccepted=False)
    args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Verified reader sessions {args.kind}: {result['passed']} pass/{result['failed']} fail; no full/device acceptance")
