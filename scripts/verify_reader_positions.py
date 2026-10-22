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
            or any(row.get(key) != [] for key in ["active", "tasks", "waiters"])):
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
    return dict(result, mechanismChecks=6, sdkSampleHeld=1, sdkMeasuresHeld=len(measures),
                realTerminalReceipts=len(held), cleanupEmpty=True, fixture=row,
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
