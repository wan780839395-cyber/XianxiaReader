import Foundation
import ReaderPositions
import XCTest
import XianxiaCore

final class ReaderPositionStateTests: XCTestCase {
    @MainActor func testOpaquePositionAndEveryEventAreRetained() async {
        let state = ReaderPositionState()
        let full = ReadingPosition(bookID: UUID(), engineID: "opaque", locatorVersion: 9,
            locatorData: Data([0, 255, 17, 4]), chapterTitle: "Current", progression: 0.43,
            updatedAt: Date(timeIntervalSince1970: 123))
        var events: [ReadingPosition?] = []
        state.onPositionChanged = { events.append($0) }
        state.update(full); state.update(full); state.update(nil)
        XCTAssertEqual(events, [full, full, nil]); XCTAssertNil(state.position)
    }

    @MainActor func testSupersededRequestAndOldCleanupCannotTouchNewSave() async {
        let state = ReaderPositionState(), owner = UUID()
        let old = state.beginSave(sessionID: owner)
        let current = state.beginSave(sessionID: owner)
        state.endSave(old)
        XCTAssertFalse(state.isCurrent(old, sessionID: owner))
        XCTAssertTrue(state.isCurrent(current, sessionID: owner))
        let full = ReadingPosition(bookID: UUID(), engineID: "opaque", locatorData: Data([7]))
        XCTAssertFalse(state.saved(full, request: old, sessionID: owner))
        XCTAssertFalse(state.failed("old", request: old, sessionID: owner))
        XCTAssertNil(state.position); XCTAssertNil(state.saveFailure)
        XCTAssertTrue(state.saved(full, request: current, sessionID: owner))
        XCTAssertEqual(state.position, full)
        state.endSave(current)
        XCTAssertFalse(state.isCurrent(current, sessionID: owner))
    }

    @MainActor func testCloseAndReopenedSessionRejectOldResult() async {
        let state = ReaderPositionState(), oldOwner = UUID(), newOwner = UUID()
        let old = state.beginSave(sessionID: oldOwner)
        state.invalidateSave()
        XCTAssertFalse(state.isCurrent(old, sessionID: oldOwner))
        let current = state.beginSave(sessionID: newOwner)
        let full = ReadingPosition(bookID: UUID(), engineID: "txt", locatorVersion: 3, locatorData: Data([6, 2]))
        XCTAssertFalse(state.saved(full, request: old, sessionID: newOwner))
        XCTAssertFalse(state.failed("late", request: old, sessionID: newOwner))
        state.endSave(old)
        XCTAssertTrue(state.isCurrent(current, sessionID: newOwner))
        XCTAssertTrue(state.saved(full, request: current, sessionID: newOwner))
        XCTAssertEqual(state.position, full); XCTAssertNil(state.saveFailure)
    }

    @MainActor func testChangedOwnerRejectsResultEvenBeforeInvalidation() async {
        let state = ReaderPositionState(), owner = UUID()
        let request = state.beginSave(sessionID: owner)
        let full = ReadingPosition(bookID: UUID(), engineID: "opaque", locatorData: Data([2]))
        XCTAssertFalse(state.isCurrent(request, sessionID: nil))
        XCTAssertFalse(state.saved(full, request: request, sessionID: UUID()))
        XCTAssertFalse(state.failed("late", request: request, sessionID: nil))
        XCTAssertNil(state.position); XCTAssertNil(state.saveFailure)
    }

    @MainActor func testFailurePreservesFullPositionAndRetryClearsVisibleError() async {
        let state = ReaderPositionState(), owner = UUID()
        let full = ReadingPosition(bookID: UUID(), engineID: "opaque", locatorVersion: 8, locatorData: Data([1, 8, 9]))
        state.update(full)
        var previousFailures: [String?] = []
        state.onSaveFailureWillChange = { previousFailures.append(state.saveFailure) }
        let request = state.beginSave(sessionID: owner)
        XCTAssertTrue(state.failed("failed", request: request, sessionID: owner))
        XCTAssertEqual(state.position, full); XCTAssertEqual(state.saveFailure, "failed")
        let retry = state.beginSave(sessionID: owner)
        XCTAssertTrue(state.saved(full, request: retry, sessionID: owner))
        XCTAssertEqual(state.position, full); XCTAssertNil(state.saveFailure)
        XCTAssertEqual(previousFailures, [nil, "failed"])
        state.onSaveFailureWillChange = nil
    }

    @MainActor func testAbsentSessionCannotCommitAndInvalidationPreservesState() async {
        let state = ReaderPositionState(), owner = UUID()
        let full = ReadingPosition(bookID: UUID(), engineID: "opaque", locatorData: Data([3]))
        let valid = state.beginSave(sessionID: owner)
        state.update(full); state.failed("visible", request: valid, sessionID: owner)
        state.invalidateSave()
        XCTAssertEqual(state.position, full); XCTAssertEqual(state.saveFailure, "visible")
        let absent = state.beginSave(sessionID: nil)
        XCTAssertFalse(state.saved(full, request: absent, sessionID: nil))
        XCTAssertFalse(state.failed("hidden", request: absent, sessionID: nil))
        XCTAssertEqual(state.saveFailure, "visible")
        state.clearSaveFailure(); XCTAssertNil(state.saveFailure)
    }
}
