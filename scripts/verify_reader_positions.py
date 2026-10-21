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


def verify_native(folder):
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    pattern = r"^Test Case '-\[XianxiaReaderTests\.([^ ]+) ([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed \([^\n]+\)\.)$"
    events = re.findall(pattern, log, re.MULTILINE)
    expected = Counter({name: 1 for name in NATIVE_TESTS})
    started = Counter(f"{cls}/{name}" for cls, name, result in events if result == "started.")
    passed = Counter(f"{cls}/{name}" for cls, name, result in events if result.startswith("passed"))
    if started != expected or passed != expected or any(result.startswith("failed") for _, _, result in events):
        raise ValueError("Original native position cases must each start and pass exactly once")
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    if any(summary.get(key) != value for key, value in {
        "totalTestCount": len(NATIVE_TESTS), "passedTests": len(NATIVE_TESTS),
        "failedTests": 0, "skippedTests": 0, "testFailures": [],
    }.items()):
        raise ValueError("Native xcresult summary must match the exact successful selection")
    return dict(cases=sorted(passed), passed=len(passed), failed=0, skipped=0, appHostUsed=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=["logic", "native"])
    parser.add_argument("folder", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    result = (verify_logic if args.kind == "logic" else verify_native)(args.folder)
    result.update(recordedAtUTC=datetime.now(timezone.utc).isoformat(), validationKind=f"reader_positions_{args.kind}",
                  releaseAccepted=False, deviceAccepted=False)
    args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"PASS reader positions {args.kind}: {result['passed']} exact contracts; not release/device acceptance")


if __name__ == "__main__":
    main()
