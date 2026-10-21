import Foundation
import ReaderSessions
import XCTest

final class ReaderSessionStateTests: XCTestCase {
    @MainActor func testAdmissionRetainsFailedOpenUntilCloseAndRejectsDuplicateOpen() async throws {
        let state = ReaderSessionState(), book = UUID()
        let owner = try XCTUnwrap(state.begin(bookID: book))
        XCTAssertTrue(state.started)
        XCTAssertNil(state.begin(bookID: UUID()))
        XCTAssertEqual(state.requestID, owner)
        var events = ["before"]
        XCTAssertTrue(state.accept(owner, bookID: book) { events.append("publish") })
        events.append("after")
        XCTAssertEqual(events, ["before", "publish", "after"])
    }

    @MainActor func testForeignBookCannotPublishWithinCurrentSession() async throws {
        let state = ReaderSessionState(), book = UUID()
        let owner = try XCTUnwrap(state.begin(bookID: book))
        var published = false
        XCTAssertFalse(state.accept(owner, bookID: UUID()) { published = true })
        XCTAssertFalse(state.accept(UUID(), bookID: book) { published = true })
        XCTAssertFalse(published)
        XCTAssertTrue(state.accept(owner, bookID: book) { published = true })
        XCTAssertTrue(published)
    }

    @MainActor func testCapturedCallbacksCannotPublishAfterCloseOrSameBookReopen() async throws {
        let state = ReaderSessionState(), book = UUID()
        let old = try XCTUnwrap(state.begin(bookID: book))
        var values = [String]()
        let oldCallback = { state.accept(old) { values.append("old") } }
        state.invalidate()
        XCTAssertFalse(oldCallback())
        let new = try XCTUnwrap(state.begin(bookID: book))
        XCTAssertNotEqual(new, old)
        XCTAssertFalse(oldCallback())
        XCTAssertTrue(state.accept(new) { values.append("new") })
        XCTAssertEqual(values, ["new"])
    }

    @MainActor func testFinalSynchronousPositionIsAcceptedBeforeInvalidation() async throws {
        let state = ReaderSessionState(), book = UUID()
        let owner = try XCTUnwrap(state.begin(bookID: book))
        var events = [String]()
        let finalPosition = { state.accept(owner, bookID: book) { events.append("final-position") } }
        XCTAssertTrue(finalPosition())
        state.invalidate()
        state.invalidate()
        XCTAssertFalse(finalPosition())
        XCTAssertFalse(state.started)
        XCTAssertNil(state.requestID)
        XCTAssertEqual(events, ["final-position"])
    }

    @MainActor func testAcceptedWorkFinishesButLateErrorCannotPublishIntoReopenedSession() async throws {
        let state = ReaderSessionState(), book = UUID()
        let owner = try XCTUnwrap(state.begin(bookID: book))
        let fence = Fence()
        var stored = false, errors = [String]()
        let work = Task { @MainActor in
            await fence.wait()
            stored = true
            state.accept(owner) { errors.append("old failure") }
        }
        await fence.waitUntilSuspended()
        state.invalidate()
        let new = try XCTUnwrap(state.begin(bookID: book))
        fence.release()
        await work.value
        XCTAssertTrue(stored)
        XCTAssertTrue(errors.isEmpty)
        state.accept(new) { errors.append("current failure") }
        XCTAssertEqual(errors, ["current failure"])
    }

    @MainActor func testFailedFontRebuildAllowsOpeningWithoutPrematurelyDroppingOwner() async throws {
        let state = ReaderSessionState(), book = UUID()
        let old = try XCTUnwrap(state.begin(bookID: book))
        state.allowReopening()
        XCTAssertFalse(state.started)
        XCTAssertEqual(state.requestID, old)
        XCTAssertTrue(state.accept(old) {})
        let new = try XCTUnwrap(state.begin(bookID: book))
        XCTAssertNotEqual(old, new)
        XCTAssertFalse(state.accept(old) {})
        XCTAssertTrue(state.accept(new, bookID: book) {})
    }

    @MainActor private final class Fence {
        private var pending: CheckedContinuation<Void, Never>?
        private var observer: CheckedContinuation<Void, Never>?
        func wait() async {
            await withCheckedContinuation { pending = $0; observer?.resume(); observer = nil }
        }
        func waitUntilSuspended() async {
            if pending != nil { return }
            await withCheckedContinuation { observer = $0 }
        }
        func release() { let continuation = pending; pending = nil; continuation?.resume() }
    }
}
