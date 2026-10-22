"""Require exact executed position contracts; never grant release acceptance."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
import math
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


def verify_viewport_pair_arm(folder, mode, status=0):
    """Validate one local paired-mode transcript; no CI route or cross-build acceptance."""
    if mode not in ["paired-safe", "paired-conflict"] or status not in [0, 65]:
        raise ValueError("Require a known pair arm and its real original test exit")
    log = (folder / "logs/reader-diagnostic.log").read_text(encoding="utf-8")
    cls, name = next(iter(VIEWPORT_SMOKE_TESTS)).split("/")
    prefix = f"Test Case '-[XianxiaReaderTests.{cls} {name}]' "
    cases = [line for line in log.splitlines() if line.startswith("Test Case '")]
    result_word = "passed" if status == 0 else "failed"
    if (len(cases) != 2 or cases[0] != prefix + "started."
            or not re.fullmatch(re.escape(prefix) + result_word + r" \([\d.]+ seconds\)\.", cases[1])):
        raise ValueError("Pair arm must execute only the original case exactly once")
    summary = json.loads((folder / "test-results-summary.json").read_text(encoding="utf-8"))
    if (any(summary.get(k) != v for k, v in dict(totalTestCount=1, passedTests=int(status == 0),
            failedTests=int(status != 0), skippedTests=0, result="Passed" if status == 0 else "Failed").items())
            or bool(summary.get("testFailures")) != bool(status)):
        raise ValueError("Original pair exit and xcresult summary disagree")
    marker = f"CONTINUOUS_VIEWPORT_PAIR_MECHANICS mode={mode} passed=2 liveSDKReceiptsRequired=true"
    if log.splitlines().count(marker) != 1:
        raise ValueError("Require the separate paired controller mechanism checks")
    rows = [json.loads(line.removeprefix("CONTINUOUS_VIEWPORT_PAIR ")) for line in log.splitlines()
            if line.startswith("CONTINUOUS_VIEWPORT_PAIR ")]
    if len(rows) != 1:
        raise ValueError("Require one real paired SDK cleanup record")
    row = rows[0]
    if (row.get("pairMode") != mode or row.get("pairPhase") != "visible" or row.get("stage") != 4
            or row.get("failure") != "none"
            or any(row.get(k) != [] for k in ["active", "tasks", "waiters", "queued", "running"])):
        raise ValueError("Pair fixture did not complete its bounded preparation and cleanup")
    events = row.get("events", [])
    if (not row.get("nonce") or not 1 <= len(events) <= 128
            or [e.get("sequence") for e in events] != [str(i + 1) for i in range(len(events))]
            or any(e.get("nonce") != row["nonce"] or not e.get("requestID") for e in events)):
        raise ValueError("Pair receipts need bounded, ordered, same-instance identities")
    seq = lambda e: int(e["sequence"])
    def event(request, kind):
        values = [e for e in events if e["kind"] == kind and (request is None or e["requestID"] == request)]
        if len(values) != 1: raise ValueError(f"Missing or repeated pair {kind}")
        return values[0]
    def number(value):
        try: result = float(value)
        except (ValueError, TypeError) as exc: raise ValueError("Missing numeric pair evidence") from exc
        if not math.isfinite(result): raise ValueError("Non-finite pair evidence")
        return result
    sid, mid = row.get("pairSampleID"), row.get("pairMeasureID")
    if not sid or not mid or sid == mid: raise ValueError("Separate selected S/M identities are required")
    arm, seal, resize = event(None, "admission-armed"), event(sid, "pair-sealed"), event(None, "pair-resize")
    closing, abort = event(None, "closing"), event(None, "abort-issued")
    if not seq(arm) < seq(seal) < seq(resize) < seq(closing) < seq(abort) or abort.get("count") != "0":
        raise ValueError("Pair seal, real resize and terminal cleanup order is invalid")
    origin = row.get("pairOrigin", {})
    required_origin = ["href", "selector", "textNodeIndex", "charOffset", "viewportOffset", "windowWidth",
                       "windowHeight", "targetWidth", "targetHeight", "sampleSource"]
    if (seal.get("mode") != mode or any(not origin.get(k) or seal.get(k) != origin[k] for k in required_origin)
            or number(origin["charOffset"]) <= 100 or number(origin["textNodeIndex"]) < 0
            or any(number(origin[k]) <= 0 for k in ["windowWidth", "windowHeight", "targetWidth", "targetHeight"])
            or not abs(number(resize.get("width")) - number(origin["targetWidth"])) < 2
            or not abs(number(resize.get("height")) - number(origin["targetHeight"])) < 2
            or resize.get("mode") != mode or resize.get("attached") != "true"):
        raise ValueError("Pair origin or physical window geometry is unqualified")
    number(origin["viewportOffset"])
    before_s, release_s = event(sid, "sample-before-read"), event(sid, "released")
    if not seq(event(sid, "work-start")) < seq(event(sid, "sample-start")) < seq(before_s):
        raise ValueError("Selected S lacks its pre-seal actual SDK lifetime")
    held_s, end_s, exit_s = event(sid, "held"), event(sid, "sample-finished"), event(sid, "work-finished")
    before_m, release_m = event(mid, "measure-before-commit"), event(mid, "released")
    held_m, decision = event(mid, "held"), event(mid, "measure-guard")
    end_m, exit_m = event(mid, "measure-finished"), event(mid, "work-finished")
    if (held_s.get("gate") != "sample-before-read" or held_m.get("gate") != "measure-before-commit"
            or len([e for e in events if e["kind"] == "held"]) != 2
            or release_s.get("point") != "sample-before-read" or release_m.get("point") != "measure-before-commit"
            or release_s.get("disposition") != "run" or release_m.get("disposition") != "run"
            or not seq(before_s) < seq(held_s) < seq(seal)
            or not seq(before_m) < seq(held_m) < seq(release_m) < seq(decision) < seq(end_m) < seq(exit_m)
            or not seq(release_s) < seq(end_s) < seq(exit_s) < seq(release_m)
            or end_m.get("outcome") != "committed" or exit_s.get("captured") != "true"):
        raise ValueError("Pair gates and real domain/work termination receipts disagree")
    if mode == "paired-safe":
        if not seq(seal) < seq(release_s) < seq(exit_s) < seq(resize) < seq(before_m):
            raise ValueError("Safe S must actually exit before resize")
    elif not seq(resize) < seq(held_m) < seq(release_s):
        raise ValueError("Conflict S may read only after primary M is held")
    owner_keys = ["reader", "epoch", "slot", "webView", "index"]
    if (any(not arm.get(k) or before_s.get(k) != arm[k] or before_m.get(k) != arm[k] for k in owner_keys)
            or any(before_s.get(k) != arm.get(k) for k in ["revision", "localTop", "nativeWidth", "nativeHeight"])
            or before_s.get("source") != origin["sampleSource"] or before_m.get("anchor") != arm.get("anchor")
            or arm.get("anchor") in [None, "nil", "serialization-error"]
            or not abs(number(before_m.get("dom.width")) - number(origin["targetWidth"])) < 2
            or number(before_m.get("result.height")) <= 0):
        raise ValueError("Pair selected contexts/result did not preserve qualified A and F0/F1")
    number(before_m.get("result.anchorY"))
    captures = [e for e in events if e["kind"] == "sample-finished" and e.get("source") == "original-capture"
                and e.get("anchor") == arm["anchor"] and e.get("outcome") in ["committed", "cached"]
                and seq(held_s) < seq(e) < seq(seal)]
    if not captures: raise ValueError("Pair A lacks its original capture receipt")
    provenance = False
    for terminal in [e for e in events if e["kind"] == "sample-finished" and e.get("outcome") == "committed"
                     and e.get("anchor") == arm["anchor"] and e["requestID"] != sid and seq(e) < seq(seal)]:
        rid=terminal["requestID"]
        old_reads=[e for e in events if e["requestID"]==rid and e["kind"]=="sample-dom"]
        old_exits=[e for e in events if e["requestID"]==rid and e["kind"]=="work-finished"]
        if (old_reads and old_exits and seq(terminal)<seq(old_exits[0])<seq(seal)
                and all(terminal.get(k)==arm[k] for k in owner_keys)
                and abs(number(old_reads[-1].get("dom.width"))-number(before_s.get("nativeWidth")))<2):
            provenance=True
    if not provenance: raise ValueError("A lacks a completed real old-DOM sample")
    reads = [e for e in events if e["requestID"] == sid and e["kind"] == "sample-dom"]
    decisions = [e for e in events if e["requestID"] == sid and e["kind"] == "sample-decision"]
    old_width = number(before_s.get("nativeWidth")); new_width = number(origin["targetWidth"])
    if (not 1 <= len(reads) <= 3 or len(decisions) != len(reads)
            or [e.get("attempt") for e in reads] != [str(i) for i in range(len(reads))]
            or [e.get("attempt") for e in decisions] != [e["attempt"] for e in reads]):
        raise ValueError("Require each original bounded S attempt and actual decision")
    contexts = ["notCancelled", "epochMatches", "indexMatches", "slotMatches", "movingMatches", "notPositioning", "revisionMatches", "localMatches", "viewportMatches"]
    for read, verdict in zip(reads, decisions):
        if (not seq(release_s) < seq(read) < seq(verdict) < seq(end_s)
                or not abs(number(read.get("dom.width")) - (old_width if mode == "paired-safe" else new_width)) < 2
                or any(verdict.get(k) != "true" for k in contexts)):
            raise ValueError("S used the wrong DOM size or had an unrelated context invalidation")
        if (number(read.get("clipTop")) != number(before_s.get("clipTop"))
                or number(read.get("dom.visibleTop")) != number(before_s.get("clipTop"))
                or abs(number(read.get("dom.documentTop"))-number(read.get("dom.scrollY"))-number(read.get("dom.visibleTop")))>=1e-7):
            raise ValueError("S frozen clipping and same-evaluation documentTop disagree")
        if verdict.get("snapshotAvailable")=="true":
            delta=number(verdict.get("documentTop"))-max(0,number(before_s.get("localTop")))
            if (number(verdict.get("documentTop"))!=number(read.get("dom.documentTop"))
                    or number(verdict.get("expectedDocumentTop"))!=max(0,number(before_s.get("localTop")))
                    or abs(number(verdict.get("documentTopDelta"))-delta)>=1e-7
                    or verdict.get("documentTopMatches")!=str(abs(delta)<1).lower()):
                raise ValueError("S same-snapshot diagnostic values disagree")
        elif verdict.get("reason")!="snapshot-unavailable": raise ValueError("S omitted its actual snapshot decision")
        if verdict.get("reason")=="committed" and verdict.get("documentTopMatches")!="true":
            raise ValueError("S committed despite a mismatched original documentTop diagnostic")
    if decisions[-1].get("reason") != end_s.get("reason"):
        raise ValueError("The actual S exit reason was not retained")
    effect = row.get("pairEffect")
    if end_s.get("outcome") == "committed" and end_s.get("reason") == "committed":
        expected_effect = "unchanged" if end_s.get("anchor") == arm["anchor"] else "anchor-replaced"
        if effect != expected_effect: raise ValueError("S cache effect was misclassified")
    elif (mode == "paired-conflict" and end_s.get("outcome") == "rejected"
          and {"document-top-mismatch-exhausted":"blocked", "snapshot-unavailable":"read-unavailable"}.get(end_s.get("reason")) == effect):
        pass
    else: raise ValueError("S did not follow a supported original terminal branch")
    if mode == "paired-safe" and effect != "unchanged": raise ValueError("Safe S changed A")
    flags = ["ownerMatches", "indexMatches", "anchorCurrentAtStart", "anchorCurrentNow", "revisionMatches", "localMatches"]
    replaced = effect == "anchor-replaced"
    if (any(decision.get(k) != "true" for k in flags) or decision.get("positioning") != "false"
            or decision.get("anchor") != end_s.get("anchor")
            or decision.get("anchorEqual") != str(not replaced).lower()
            or decision.get("mayRestore") != str(not replaced).lower()):
        raise ValueError("M was confounded or skipped for a reason other than the selected S cache effect")
    effect_event = event(mid, "pair-effect")
    if not seq(exit_m) < seq(effect_event) or effect_event.get("effect") != effect:
        raise ValueError("Pair effect must follow actual M completion")
    # All other work remains single-file admission, including requests queued while S/M overlap.
    queued = [e for e in events if e["kind"] == "queued"]
    records = {}
    for queue in queued:
        rid, point = queue["requestID"], queue.get("gate")
        if point not in ["measure-before-capture", "sample-before-capture"] or rid in records:
            raise ValueError("Pair admission is not a unique pre-capture gate")
        kind = "measure" if point.startswith("measure") else "sample"
        start, entry, admitted = event(rid, "work-start"), event(rid, point), event(rid, "admitted")
        captured, terminal, exited = event(rid, kind+"-start"), event(rid, kind+"-finished"), event(rid, "work-finished")
        if (not seq(seal) < seq(start) < seq(entry) < seq(queue) < seq(admitted) < seq(captured) < seq(terminal) < seq(exited) < seq(closing)
                or admitted.get("point") != point or admitted.get("disposition") != "run" or exited.get("captured") != "true"
                or any(entry.get(k) != captured.get(k) or not entry.get(k) for k in owner_keys)
                or any(captured.get(k) != arm[k] for k in ["reader", "epoch"])):
            raise ValueError("Pair work bypassed fresh capture or its actual terminal receipt")
        records[rid] = dict(queued=queue, admitted=admitted, exited=exited)
    ordered = sorted(records, key=lambda rid:seq(records[rid]["admitted"]))
    target = [q["requestID"] for q in queued if q.get("gate")=="measure-before-capture"
              and all(event(q["requestID"],"measure-before-capture").get(k)==arm[k] for k in ["slot","webView","index"])]
    if not target or target[0]!=mid: raise ValueError("Primary M was selected after another target M")
    if not ordered or ordered[0] != mid or ordered[1:] != sorted((rid for rid in records if rid != mid), key=lambda rid:seq(records[rid]["queued"])):
        raise ValueError("Primary selection or subsequent FIFO drain changed")
    previous = max(seq(exit_s), seq(exit_m))
    for rid in ordered[1:]:
        if seq(records[rid]["admitted"]) <= previous: raise ValueError("Non-selected work overlapped S/M or previous drain work")
        previous = seq(records[rid]["exited"])
    registered = set(records) | {sid}
    for e in events:
        if seq(seal) < seq(e) < seq(closing) and e["kind"] in ["work-start", "measure-start", "sample-start", "work-finished", "admitted"] and e["requestID"] not in registered:
            raise ValueError("Unregistered SDK work crossed the paired interval")
    drained = [e for e in events if e["kind"] == "pair-drained"]
    if (not drained or seq(drained[-1]) < previous or seq(drained[-1]) >= seq(closing)
            or any(e.get(k) != "0" for e in drained for k in ["queued", "running", "waiters"])):
        raise ValueError("Pair did not record real bounded drain before the original predicate")
    pending = set()
    for e in events:
        if e["kind"] in ["queued", "held"]:
            key=(e["requestID"],e.get("gate"))
            if key in pending: raise ValueError("Duplicate pair continuation")
            pending.add(key)
            if len(pending)>32: raise ValueError("Pair shared waiter budget exceeded")
        elif e["kind"] in ["admitted", "released"]:
            key=(e["requestID"],e.get("point"))
            if key not in pending: raise ValueError("Wrong pair gate permission")
            pending.remove(key)
        if e["kind"] in ["pair-drained", "closing"] and pending: raise ValueError("Pair completion hid pending work")
        if seq(e)>seq(closing) and e.get("outcome")=="committed": raise ValueError("Pair committed after close")
    if pending: raise ValueError("Pair cleanup left a continuation")
    predicate = row.get("pairPredicate", {})
    if number(predicate.get("afterSequence")) < seq(drained[-1]): raise ValueError("Original predicate predates the latest drain")
    joint = (predicate.get("point")=="DOM" and all(predicate.get(k)=="true" for k in ["sameWebView","attached","widthMatches","valid"])
             and number(predicate.get("alpha"))>0.99 and number(predicate.get("loaded"))<=12)
    resize_rows=[json.loads(line.removeprefix("CONTINUOUS_RESIZE_EVIDENCE ")) for line in log.splitlines() if line.startswith("CONTINUOUS_RESIZE_EVIDENCE ")]
    phases=[v.get("phase") for v in resize_rows]
    for sample in resize_rows:
        original=sample.get("origin",{}); locations=original.get("locations",{}); point=locations.get("domRange",{}).get("start",{})
        if (original.get("href")!=origin["href"] or any(str(point.get(k))!=origin[k] for k in ["textNodeIndex","charOffset"])
                or point.get("cssSelector")!=origin["selector"]
                or abs(number(locations.get("xianxiaViewportOffset"))-number(origin["viewportOffset"]))>=0.5):
            raise ValueError("Original business predicate used a different saved Locator")
    wide, narrow=int(number(origin["targetWidth"])),int(number(origin["windowWidth"]))
    if status==0:
        if not joint or predicate.get("visible")!="true" or predicate.get("accepted")!="true" or phases!=["before-resize",f"passed-{wide}",f"passed-{narrow}"]:
            raise ValueError("Pair pass lacks unchanged original visibility and both directions")
        classification="state-interleaving-only" if replaced else effect
    elif joint and predicate.get("visible")==predicate.get("accepted")=="false" and phases==["before-resize",f"failed-{wide}"]:
        classification="candidate-controlled-word-failure" if replaced else "other-original-failure"
    else: classification="other-original-failure"
    return dict(mode=mode, originalExit=status, originalPassed=status==0, classification=classification, effect=effect,
                origin=origin, nativeContext={k:before_s[k] for k in ["localTop","nativeWidth","nativeHeight"]},
                actualDomainAndWorkReceipts=True, serialDrainVerified=True, cleanupEmpty=True,
                matchedBuildVerified=False, oldFullRootCauseProven=False, fixture=row)


def compare_viewport_pair_receipts(safe, conflict):
    """Semantic compatibility only; the later CI driver must prove shared build/provenance."""
    if safe.get("mode")!="paired-safe" or not safe.get("originalPassed") or conflict.get("mode")!="paired-conflict":
        raise ValueError("Require a fresh successful paired-safe arm before the conflict arm")
    for key in ["href","selector","textNodeIndex","charOffset","windowWidth","windowHeight","targetWidth","targetHeight","sampleSource"]:
        if safe["origin"].get(key)!=conflict["origin"].get(key): raise ValueError("Pair semantic origin/configuration mismatch")
    for key in ["viewportOffset"]:
        if abs(float(safe["origin"][key])-float(conflict["origin"][key]))>=0.5: raise ValueError("Pair original viewport mismatch")
    for key in ["localTop","nativeWidth","nativeHeight"]:
        if abs(float(safe["nativeContext"][key])-float(conflict["nativeContext"][key]))>=0.5: raise ValueError("Pair physical context mismatch")
    return dict(semanticPairCompatible=True, originalExits=[safe["originalExit"],conflict["originalExit"]],
                candidateObservation=conflict["classification"], matchedBuildVerified=False, matchedPairAccepted=False,
                oldFullRootCauseProven=False, releaseAccepted=False)


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
