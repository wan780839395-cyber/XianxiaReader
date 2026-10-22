"""Exact isolated shelf contracts and the original shelf/cover native selection."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

LOGIC_TESTS = {
    "testLatestRefreshOwnsBothListsAndOldFailureIsRejected",
    "testCommittedRenameAndCoverRetainReadingSummaryAndRejectOldSnapshot",
    "testTrashAndRestoreKeepSummaryOrderAndRejectPrecommitRefresh",
    "testMissingCommitDoesNotInventBookAndStillInvalidatesRefresh",
    "testChangeNotificationPrecedesEachListMutationSynchronously",
    "testFreshPostcommitSnapshotCanReconcileBothLists",
}

# Enumerate names independently of the current source so lost cases cannot pass by count.
NATIVE_TESTS = {cls + "/" + name for cls, names in {
    "LibraryTests": [
        "testLayoutSortPreferencesPersistAndInvalidValuesFallBack",
        "testMetadataOnlyFilteringNumericSortAndReadingProgress",
        "testRenameThroughShelfPersistsOriginalAndCompleteReadingPosition",
        "testRefreshOverlappingCommittedRenameKeepsLatestTitle",
        "testNativeShelfGridListFilterAndRenameErrorSnapshots"],
    "LibraryRemovalTests": [
        "testTXTAndEPUBRemovalSurvivesRealAppStartupRecoveryAndRestoresRelatedData",
        "testConfirmationCancelMissingBookErrorAndRecoveryRetryKeepShelfTruthful",
        "testOverlappingRefreshDoesNotBringBackRemovedBookOrHideRestoredBook",
        "testNativeRemovalConfirmationTrashAndEmptySnapshots"],
    "BookCoverTests": [
        "testBackgroundDownsamplingAppliesEXIFOnceAndRetainsOriginalBytes",
        "testMissingThumbnailUsesOriginalWithWarningAndBothFailuresRemainVisible",
        "testRealTXTAndEPUBCoverSaveStartupTrashRestoreAndDefaultPreserveRelatedData",
        "testRealDatabaseFailureKeepsDraftForRetryAndRefreshKeepsLatestMetadata",
        "testLateCancelledLoadAndClosedEditorCannotReplaceNewDraftOrSession",
        "testFirstFileDelegateCallbackSurvivesWrapperAndInvalidSelectionCanRetry",
        "testPhotoFileTransferCopiesBeforeProviderDisappearsAndCancellationPreservesBook",
        "testNativeCoverPreviewErrorSavedShelfAndRestoreDefaultSnapshots"]
}.items() for name in names}


def verify_logic(folder):
    xml = ET.parse(folder / "tests.xml").getroot()
    suites = list(xml.iter("testsuite"))
    if len(suites) != 1 or int(suites[0].get("tests", "-1")) != len(LOGIC_TESTS):
        raise ValueError("Exact shelf suite required")
    for key in ["errors", "failures", "skipped"]:
        if int(suites[0].get(key, "0")):
            raise ValueError("Shelf contracts failed or skipped")
    names = Counter()
    for case in xml.iter("testcase"):
        name = case.get("name", "").removesuffix("()")
        if (case.get("classname") not in {"LibraryCollectionTests", "LibraryShelfTests.LibraryCollectionTests"}
                or any(n.tag in {"failure", "error", "skipped"} for n in case.iter())):
            raise ValueError("Shelf contract class/outcome mismatch")
        names[name] += 1
    if names != Counter(dict.fromkeys(LOGIC_TESTS, 1)):
        raise ValueError("Every shelf contract must execute once")
    graph = json.loads((folder / "dependencies.json").read_text(encoding="utf-8"))
    dependencies = graph.get("dependencies", [])
    if graph.get("name") != "LibraryShelf" or len(dependencies) != 1 or dependencies[0].get("name") != "XianxiaCore" or dependencies[0].get("dependencies") != []:
        raise ValueError("Shelf must depend only on Core")
    return dict(passed=len(names), failed=0, skipped=0, cases=sorted(names), appHostUsed=False)


def verify_native(folder, status=0):
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    events = re.findall(r"^Test Case '-\[XianxiaReaderTests\.([^ ]+) ([^\]]+)\]' (started\.|passed \([^\n]+\)\.|failed \([^\n]+\)\.)$", log, re.M)
    expected = Counter(dict.fromkeys(NATIVE_TESTS, 1))
    starts = Counter(c + "/" + n for c, n, result in events if result == "started.")
    ends = Counter(c + "/" + n for c, n, result in events if result.startswith("passed"))
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    required = dict(totalTestCount=len(expected), passedTests=len(expected), failedTests=0, skippedTests=0, result="Passed")
    if status != 0 or starts != expected or ends != expected or any(summary.get(k) != v for k, v in required.items()) or summary.get("testFailures"):
        raise ValueError("Original native shelf selection must pass exactly once with true exit zero")
    return dict(passed=len(expected), failed=0, skipped=0, cases=sorted(expected), appHostUsed=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=["logic", "native"])
    parser.add_argument("folder", type=Path)
    parser.add_argument("--status", type=int, default=0)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    result = verify_logic(args.folder) if args.kind == "logic" else verify_native(args.folder, args.status)
    result.update(fullGateExecuted=False, releaseAccepted=False, deviceAccepted=False)
    args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Verified library {args.kind}: {result['passed']} pass, no full/device acceptance")
