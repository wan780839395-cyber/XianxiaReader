"""Require exact executed position contracts; never grant release acceptance."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

STATE_TESTS = {
    "testOpaquePositionAndEveryEventAreRetained",
    "testSupersededRequestAndOldCleanupCannotTouchNewSave",
    "testCloseAndReopenedSessionRejectOldResult",
    "testChangedOwnerRejectsResultEvenBeforeInvalidation",
    "testFailurePreservesFullPositionAndRetryClearsVisibleError",
    "testAbsentSessionCannotCommitAndInvalidationPreservesState",
}
PERSISTENCE_TESTS = {
    "testFreshCaptureStoresFullLocatorBeforePublishingResult",
    "testFixedLayoutUsesCompletePageWithoutSampling",
    "testUnavailableCaptureRetriesThenPreservesFullLocator",
    "testUnavailableDeadlineKeepsOriginalPositionAndBudget",
    "testCaptureAndStorageFailuresKeepOldPositionAndRetryClearsError",
    "testObsoleteOrCancelledCaptureCannotWrite",
    "testLateStorageCompletionCannotPublishAcrossSessions",
    "testAbsentObsoleteOrCancelledEntryDoesNotSample",
    "testEmittedPositionsKeepEveryFullWriteAfterRequestInvalidation",
    "testEmittedFailureReportsOriginalMessageWithoutChangingExplicitSaveState",
}
NAVIGATION_TESTS = {
    "testFirstFullOriginSurvivesExcursionAndReturnOrStay",
    "testFailedCaptureAndForeignOriginNeverNavigate",
    "testNavigationAndReturnFailureKeepOriginForRetry",
    "testExternalRequestSharesBusyLockAndStayCannotClearWhileBusy",
    "testLateCaptureCannotNavigateOrEndNewRequest",
    "testLateOperationCannotPublishAcrossSessions",
    "testCancellationKeepsUnpublishedOrExistingOrigin",
    "testObsoleteEntryCannotSampleNavigateOrPublish",
}
TEST_CLASSES = {
    **dict.fromkeys(STATE_TESTS, "ReaderPositionStateTests"),
    **dict.fromkeys(PERSISTENCE_TESTS, "ReaderPositionPersistenceTests"),
    **dict.fromkeys(NAVIGATION_TESTS, "ReaderNavigationCoordinatorTests"),
}
LOGIC_TESTS = set(TEST_CLASSES)
NATIVE_TESTS = {
    "ReaderLifecycleTests/" + name for name in [
        "testPositionBurstPublishesOnlyProgressAndPreservesLatestFullLocator",
        "testSettingsCommitDoesNotSampleCoveredPageAndFreshPositionFailureStillPreservesProgress",
        "testSaveNowUsesFreshFullAnchorInsteadOfDelayedCachedChapterHead",
        "testSaveNowWaitsForReflowSamplingAndKeepsTheCompleteLocator",
        "testLateSaveCaptureCannotOverwriteProgressAfterCloseAndReopen",
        "testFailedFreshSaveKeepsStoredProgressAndRetryIsVisible",
        "testSupersededAndCancelledSaveCapturesCannotOverwriteNewerProgress",
        "testLatePositionAfterCloseIsNotPersisted",
        "testReturnPointRetainsFirstFullAnchorAcrossContentsBookmarkSearchAndStay",
        "testReturnPointFailureRetryAndClosePreserveCurrentProgressWithoutPersistingOrigin",
        "testReturnCaptureCloseReopenLateResultCannotNavigateOrClearNewRequest",
        "testReturnCaptureFailureAndCancellationNeverPublishOrNavigate",
        "testLateChapterNavigationCannotHideReopenedReadersMenu",
        "testLateBookmarkFailureAfterCloseCannotShowError",
    ]
} | {
    "ReaderProgressTests/testSummaryChangesDoNotDiscardOpaquePositionOrPublishEquivalentDisplay",
    "ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes",
    "ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord",
    "ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes",
    "TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen",
}


ACCEPTANCE_TESTS = NATIVE_TESTS | {
    "ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews",
    "ReaderRenderingTests/testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge",
    "ReaderRenderingTests/testPagedNativeLoadDoesNotWaitForAnimationFrameBridge",
    "ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord",
}

CLOSE_TESTS = {"ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews"}
VIEWPORT_SMOKE_TESTS = {"ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView"}


def verify_logic(folder):
    tree = ET.parse(folder / "tests.xml").getroot()
    suites = list(tree.iter("testsuite"))
    if len(suites) != 1 or any(int(suites[0].get(key, "0")) for key in ["errors", "failures", "skipped"]):
        raise ValueError("Position contracts contain failed/skipped or unexpected suites")
    names = Counter()
    for case in tree.iter("testcase"):
        name = case.get("name", "").removesuffix("()")
        expected_class = TEST_CLASSES.get(name)
        if expected_class is None or case.get("classname") not in {expected_class, "ReaderPositionsTests." + expected_class}:
            raise ValueError("Unexpected position contract class")
        if any(child.tag in {"failure", "error", "skipped"} for child in case.iter()):
            raise ValueError("Position contract failed or skipped")
        names[name] += 1
    if names != Counter({name: 1 for name in LOGIC_TESTS}) or int(suites[0].get("tests", "-1")) != len(LOGIC_TESTS):
        raise ValueError("Every position contract must execute exactly once")
    dependencies = json.loads((folder / "dependencies.json").read_text(encoding="utf-8"))
    children = dependencies["dependencies"]
    if (dependencies["name"] != "ReaderPositions" or len(children) != 1
            or children[0]["name"] != "XianxiaCore" or children[0]["dependencies"]):
        raise ValueError("Position logic must depend only on the local Core product")
    return dict(cases=sorted(names), passed=len(names), failed=0, skipped=0, appHostUsed=False, readiumResolved=False)


def verify_native(folder, expected_tests=NATIVE_TESTS, status=0):
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    pattern = r"^Test Case '-\[XianxiaReaderTests\.([^ ]+) ([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed \([^\n]+\)\.)$"
    events = re.findall(pattern, log, re.MULTILINE)
    expected = Counter({name: 1 for name in expected_tests})
    started = Counter(f"{cls}/{name}" for cls, name, result in events if result == "started.")
    passed = Counter(f"{cls}/{name}" for cls, name, result in events if result.startswith("passed"))
    if status != 0 or started != expected or passed != expected or any(result.startswith("failed") for _, _, result in events):
        raise ValueError("Original native position cases must each start and pass exactly once")
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    if any(summary.get(key) != value for key, value in {
        "totalTestCount": len(expected_tests), "passedTests": len(expected_tests),
        "failedTests": 0, "skippedTests": 0, "testFailures": [],
    }.items()):
        raise ValueError("Native xcresult summary must match the exact successful selection")
    return dict(cases=sorted(passed), passed=len(passed), failed=0, skipped=0, appHostUsed=True)


def verify_acceptance(folder, status=0):
    result = verify_native(folder, ACCEPTANCE_TESTS, status)
    if json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8")).get("result") != "Passed":
        raise ValueError("The 23-case acceptance summary must report Passed")
    return result


def verify_close(folder, status=0):
    result = verify_native(folder, CLOSE_TESTS, status)
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    if summary.get("result") != "Passed":
        raise ValueError("Close probe summary must report Passed")
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    rows = [json.loads(line.removeprefix("CLOSE_INITIALIZATION_PROBE "))
            for line in log.splitlines() if line.startswith("CLOSE_INITIALIZATION_PROBE ")]
    phases = Counter((row.get("mode"), row.get("phase")) for row in rows)
    if phases != Counter({(mode, phase): 1 for mode in ["paged", "continuous"]
                          for phase in ["prepared", "closed", "gate-cleanup"]}):
        raise ValueError("Both close modes need exactly one prepared, closed and cleanup record")
    for row in rows:
        value = row["values"]
        if row["phase"] == "prepared":
            probe = value.get("probe", {})
            if (not value.get("href", "").endswith("/cover.xhtml")
                    or value.get("started") is not True or value.get("nativeFontState") != "pending"
                    or probe.get("installed") is not True or probe.get("nativeReady") is not True
                    or probe.get("released") is not False or probe.get("settledCalls") != 0
                    or probe.get("instanceCalls", 0) + probe.get("prototypeCalls", 0) < 1
                    or probe.get("installError") or probe.get("nativeError")):
                raise ValueError("Close must enter the real font wait while its explicit barrier is held")
        elif row["phase"] == "closed":
            if (value.get("retiredCount", 0) < 1 or value.get("delegatesDisconnected") is not True
                    or value.get("remainingWebViews") != 0 or value.get("remainingChildren") != 0):
                raise ValueError("Close must disconnect and detach the retained old views")
        elif value.get("released") is not True and not value.get("contextUnavailableAfterClose"):
            raise ValueError("Close gate cleanup outcome is missing")
    return dict(result, closeProbe=rows)


def verify_viewport_smoke(folder, status=0):
    result = verify_native(folder, VIEWPORT_SMOKE_TESTS, status)
    if json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8")).get("result") != "Passed":
        raise ValueError("Smoke xcresult summary must report Passed")
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    if log.splitlines().count("CONTINUOUS_FIXTURE_MECHANICS passed=6 liveSDKReceiptsRequired=true") != 1:
        raise ValueError("All six controller mechanism checks must complete once")
    rows = [json.loads(line.removeprefix("CONTINUOUS_VIEWPORT_FIXTURE "))
            for line in log.splitlines() if line.startswith("CONTINUOUS_VIEWPORT_FIXTURE ")]
    if len(rows) != 1:
        raise ValueError("Require exactly one real smoke cleanup record, not an ordinary case pass")
    row = rows[0]
    if (row.get("stage") != 4 or row.get("failure") != "none"
            or any(row.get(key) != [] for key in ["active", "tasks", "waiters", "queued", "running"])):
        raise ValueError("Smoke must finish its safe sequence and clean all registered work")
    events = row.get("events", [])
    if (not row.get("nonce") or not 1 <= len(events) <= 128
            or [e.get("sequence") for e in events] != [str(i + 1) for i in range(len(events))]
            or any(e.get("nonce") != row["nonce"] or not e.get("requestID") for e in events)):
        raise ValueError("Require bounded, ordered, same-instance event receipts")

    def event(request, kind):
        found = [e for e in events if e["requestID"] == request and e.get("kind") == kind]
        if len(found) != 1:
            raise ValueError(f"Missing or repeated {kind} receipt for {request}")
        return found[0]

    held = [e for e in events if e.get("kind") == "held"]
    samples = [e for e in held if e.get("gate") == "sample-before-read"]
    measures = [e for e in held if e.get("gate") == "measure-before-commit"]
    if len(samples) != 1 or not 1 <= len(measures) <= 32 or len(held) != 1 + len(measures):
        raise ValueError("Require a real cache-miss S and the qualifying M group")
    sample_finished = None
    for entry in samples + measures:
        request = entry["requestID"]
        before = event(request, entry["gate"])
        release = event(request, "released")
        finished_kind = "sample-finished" if entry in samples else "measure-finished"
        finished = event(request, finished_kind)
        if (release.get("disposition") != "run" or finished.get("outcome") != "committed"
                or not int(before["sequence"]) < int(entry["sequence"]) < int(release["sequence"]) < int(finished["sequence"])):
            raise ValueError("Gate entry, release and real terminal receipt must agree")
        if entry in samples:
            sample_finished = finished
        elif int(sample_finished["sequence"]) >= int(entry["sequence"]):
            raise ValueError("This scope requires safe S completion before M is held")
    decision = event(measures[0]["requestID"], "measure-guard")
    if any(decision.get(key) != "true" for key in ["ownerMatches", "anchorEqual", "anchorCurrentAtStart",
                                                  "anchorCurrentNow", "revisionMatches", "localMatches", "mayRestore"]):
        raise ValueError("The first real M must retain the original safe-order guards")
    closing = [e for e in events if e.get("kind") == "closing"]
    abort = [e for e in events if e.get("kind") == "abort-issued"]
    if (len(closing) != 1 or len(abort) != 1 or abort[0].get("count") != "0"
            or int(closing[0]["sequence"]) >= int(abort[0]["sequence"])):
        raise ValueError("Require explicit terminal close and abort cleanup receipts")
    seq = lambda e: int(e["sequence"])
    armed = [e for e in events if e.get("kind") == "admission-armed"]
    complete = [e for e in events if e.get("kind") == "admission-complete"]
    if (len(armed) != 1 or len(complete) != 1 or len(measures) != 1
            or not seq(sample_finished) < seq(armed[0]) < seq(complete[0]) < seq(closing[0])
            or any(complete[0].get(k) != "0" for k in ["queued", "running", "waiters"])):
        raise ValueError("Require one primary M and a completed admission interval after S")
    arm, end = armed[0], complete[0]
    primary = measures[0]["requestID"]
    owner_keys = ["reader", "epoch", "slot", "webView", "index", "anchor"]
    before_m = event(primary, "measure-before-commit")
    if (any(not arm.get(k) or before_m.get(k) != arm[k] for k in owner_keys)
            or not float(arm.get("targetWidth", "nan")) > 0
            or not abs(float(before_m.get("dom.width", "nan")) - float(arm["targetWidth"])) < 2):
        raise ValueError("Primary M must use the original owner/anchor and the real target DOM")
    controlled = [e for e in events if seq(arm) < seq(e) < seq(end)]
    starts = [e for e in controlled if e.get("kind") == "work-start"]
    if not starts or len({e["requestID"] for e in starts}) != len(starts):
        raise ValueError("Every controlled SDK work request needs one lifetime start")
    records = {}
    for start in starts:
        request = start["requestID"]
        queued = event(request, "queued")
        point = queued.get("gate")
        if point not in ["measure-before-capture", "sample-before-capture"]:
            raise ValueError("Admission must precede context capture")
        entry = event(request, point)
        admitted = event(request, "admitted")
        kind = "measure" if point == "measure-before-capture" else "sample"
        captured = event(request, kind + "-start")
        terminal = event(request, kind + "-finished")
        finished = event(request, "work-finished")
        if (not seq(arm) < seq(start) < seq(entry) < seq(queued) < seq(admitted) < seq(captured)
                < seq(terminal) < seq(finished) < seq(end)
                or admitted.get("point") != point or admitted.get("disposition") != "run"
                or finished.get("captured") != "true"
                or any(entry.get(k) != arm[k] or captured.get(k) != arm[k] for k in ["reader", "epoch"])):
            raise ValueError("Need entry permission before capture and the actual SDK terminal receipt")
        if (any(not entry.get(k) or entry.get(k) != captured.get(k) for k in ["reader", "epoch", "slot", "webView", "index"])
                or request == primary and any(captured.get(k) != arm[k] for k in owner_keys)):
            raise ValueError("Captured owner must match the admitted request and primary anchor")
        records[request] = dict(queued=queued, admitted=admitted, finished=finished)
    if primary not in records:
        raise ValueError("The primary M may not bypass admission")
    # No admitted/queued/domain-start/work-finished may hide outside a work lifetime.
    controlled_kinds = {"queued", "admitted", "measure-start", "sample-start", "work-finished",
                        "measure-before-capture", "sample-before-capture"}
    if any(e["requestID"] not in records for e in controlled if e.get("kind") in controlled_kinds):
        raise ValueError("Unregistered work bypassed the controlled interval")
    ordered = sorted(records, key=lambda request: seq(records[request]["admitted"]))
    expected = [primary] + sorted((request for request in records if request != primary),
                                  key=lambda request: seq(records[request]["queued"]))
    if ordered != expected or any(seq(records[a]["finished"]) >= seq(records[b]["admitted"])
                                  for a, b in zip(ordered, ordered[1:])):
        raise ValueError("Drain must admit one fresh request after the previous SDK work finishes")
    pending = set()
    for e in events:
        kind, request = e.get("kind"), e["requestID"]
        if kind in ["queued", "admitted"] and not seq(arm) < seq(e) < seq(end):
            raise ValueError("Entry permissions escaped the controlled interval")
        if kind in ["queued", "held"]:
            key = (request, e.get("gate"))
            if key in pending: raise ValueError("Repeated continuation registration")
            pending.add(key)
            if len(pending) > 32: raise ValueError("Shared entry/commit waiter budget exceeded")
        elif kind in ["admitted", "released"]:
            point = e.get("point")
            if point is None and kind == "released":
                point = "sample-before-read" if request == samples[0]["requestID"] else "measure-before-commit"
            key = (request, point)
            if key not in pending: raise ValueError("Permission did not match the registered gate point")
            pending.remove(key)
        if kind in ["admission-complete", "closing"] and pending:
            raise ValueError("Admission or cleanup declared completion with pending continuations")
        if seq(e) > seq(closing[0]) and e.get("outcome") == "committed":
            raise ValueError("SDK committed after terminal close")
    if pending: raise ValueError("Unreleased continuation remains")
    return dict(result, mechanismChecks=6, sdkSampleHeld=1, sdkMeasuresHeld=len(measures),
                realTerminalReceipts=len(held), cleanupEmpty=True, fixture=row,
                admissionRequests=len(records), serialDrainVerified=True,
                conflictReplayExecuted=False, oldFullRootCauseProven=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=["logic", "native", "acceptance", "close", "viewport-smoke"])
    parser.add_argument("folder", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--status", type=int, default=0)
    args = parser.parse_args()
    validators = {"native": verify_native, "acceptance": verify_acceptance, "close": verify_close,
                  "viewport-smoke": verify_viewport_smoke}
    result = (verify_logic(args.folder) if args.kind == "logic" else
              validators[args.kind](args.folder, status=args.status))
    result.update(recordedAtUTC=datetime.now(timezone.utc).isoformat(), validationKind=f"reader_positions_{args.kind}",
                  releaseAccepted=False, deviceAccepted=False)
    args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"PASS reader positions {args.kind}: {result['passed']} exact contracts; not release/device acceptance")


if __name__ == "__main__":
    main()
