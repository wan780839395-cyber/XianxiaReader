import Foundation
import ReaderPositions
import XCTest
import XianxiaCore

final class ReaderPositionPersistenceTests: XCTestCase {
    @MainActor func testFreshCaptureStoresFullLocatorBeforePublishingResult() async {
        let c = Context(), request = UUID()
        c.owner.id = request
        let token = c.state.beginSave(sessionID: request)
        var order: [String] = []
        c.source.onCapture = { order.append("capture") }
        c.storage.onSaved = {
            XCTAssertNil(c.state.position)
            order.append("stored")
        }
        c.state.onPositionChanged = { position in
            XCTAssertEqual(c.storage.saved, [position!])
            order.append("position")
        }
        c.state.onSaveFailureWillChange = { order.append("error") }
        await c.persistence.captureAndSave(from: c.source, request: token) { c.owner.id }
        order.append("returned")
        XCTAssertEqual(order, ["capture", "stored", "position", "error", "returned"])
        XCTAssertEqual(c.state.position, c.source.value)
        XCTAssertEqual(c.storage.saved.first?.locatorVersion, 9)
        XCTAssertEqual(c.storage.saved.first?.locatorData, Data([0, 255, 4, 17]))
    }

    @MainActor func testFixedLayoutUsesCompletePageWithoutSampling() async {
        let c = Context(); c.source.supportsTextCapture = false
        c.source.currentPosition = c.source.value
        await c.save()
        XCTAssertEqual(c.storage.saved, [c.source.value!]); XCTAssertEqual(c.source.calls, 0)
        let old = c.state.position
        c.source.currentPosition = nil
        await c.save()
        XCTAssertEqual(c.source.calls, 0); XCTAssertEqual(c.storage.saved.count, 1)
        XCTAssertEqual(c.state.position, old)
        XCTAssertEqual(c.state.saveFailure, "阅读进度尚未保存：当前位置尚未稳定，请稍后再试。")
    }

    @MainActor func testUnavailableCaptureRetriesThenPreservesFullLocator() async {
        let c = Context(); c.source.unavailable = 2
        await c.save()
        XCTAssertEqual(c.source.calls, 3)
        XCTAssertEqual(c.storage.saved, [c.source.value!]); XCTAssertEqual(c.state.position, c.source.value)
        XCTAssertNil(c.state.saveFailure)
    }

    @MainActor func testUnavailableDeadlineKeepsOriginalPositionAndBudget() async {
        let c = Context(), old = position(1)
        c.state.update(old); c.source.value = nil
        let started = Date()
        await c.save()
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(started), 3)
        XCTAssertGreaterThan(c.source.calls, 1); XCTAssertTrue(c.storage.attempts.isEmpty)
        XCTAssertEqual(c.state.position, old)
        XCTAssertEqual(c.state.saveFailure, "阅读进度尚未保存：当前位置尚未稳定，请稍后再试。")
    }

    @MainActor func testCaptureAndStorageFailuresKeepOldPositionAndRetryClearsError() async {
        for failingCapture in [true, false] {
            let c = Context(), old = position(2)
            c.state.update(old)
            if failingCapture { c.source.failure = Failure() } else { c.storage.failure = Failure() }
            await c.save()
            XCTAssertEqual(c.state.position, old); XCTAssertTrue(c.storage.saved.isEmpty)
            XCTAssertEqual(c.state.saveFailure, "阅读进度尚未保存：controlled failure")
            c.source.failure = nil; c.storage.failure = nil
            await c.save()
            XCTAssertEqual(c.state.position, c.source.value)
            XCTAssertEqual(c.storage.saved, [c.source.value!]); XCTAssertNil(c.state.saveFailure)
        }
    }

    @MainActor func testObsoleteOrCancelledCaptureCannotWrite() async {
        for action in ["superseded", "reopened", "cancelled"] {
            let c = Context(); c.source.hold = true
            let token = c.state.beginSave(sessionID: c.owner.id)
            let began = expectation(description: "capture held \(action)")
            c.source.onCapture = { began.fulfill() }
            let task = Task { await c.persistence.captureAndSave(from: c.source, request: token) { c.owner.id } }
            await fulfillment(of: [began], timeout: 2)
            if action == "reopened" { c.state.invalidateSave(); c.owner.id = UUID() }
            if action != "cancelled" { _ = c.state.beginSave(sessionID: c.owner.id) }
            else { task.cancel() }
            c.source.release()
            await task.value
            XCTAssertTrue(c.storage.attempts.isEmpty); XCTAssertNil(c.state.position)
            XCTAssertNil(c.state.saveFailure)
        }
    }

    @MainActor func testLateStorageCompletionCannotPublishAcrossSessions() async {
        for failure in [false, true] {
            let c = Context(); c.storage.hold = true
            let token = c.state.beginSave(sessionID: c.owner.id)
            let began = expectation(description: "storage held \(failure)")
            c.storage.onSave = { began.fulfill() }
            let task = Task { await c.persistence.captureAndSave(from: c.source, request: token) { c.owner.id } }
            await fulfillment(of: [began], timeout: 2)
            c.state.invalidateSave(); c.owner.id = UUID()
            let current = c.state.beginSave(sessionID: c.owner.id), newer = position(7)
            c.state.update(newer)
            c.state.failed("new owner failure", request: current, sessionID: c.owner.id)
            c.storage.release(error: failure ? Failure() : nil)
            await task.value
            c.state.endSave(token)
            XCTAssertEqual(c.state.position, newer); XCTAssertEqual(c.state.saveFailure, "new owner failure")
            XCTAssertTrue(c.state.isCurrent(current, sessionID: c.owner.id))
            XCTAssertEqual(c.storage.attempts, [c.source.value!], "Already-entered writes retain the Core repository's original semantics")
        }
    }

    @MainActor func testAbsentObsoleteOrCancelledEntryDoesNotSample() async {
        for action in ["absent", "obsolete", "cancelled"] {
            let c = Context()
            if action == "absent" { c.owner.id = nil }
            let token = c.state.beginSave(sessionID: c.owner.id)
            if action == "obsolete" { c.state.invalidateSave() }
            let task = Task { await c.persistence.captureAndSave(from: c.source, request: token) { c.owner.id } }
            if action == "cancelled" { task.cancel() }
            await task.value
            XCTAssertEqual(c.source.calls, 0); XCTAssertTrue(c.storage.attempts.isEmpty)
            XCTAssertNil(c.state.saveFailure)
        }
    }

    @MainActor func testEmittedPositionsKeepEveryFullWriteAfterRequestInvalidation() async {
        let c = Context(), first = position(4), second = position(5)
        c.state.invalidateSave(); c.owner.id = nil
        var failures: [String] = []
        await c.persistence.persistEmitted(first) { failures.append($0) }
        await c.persistence.persistEmitted(first) { failures.append($0) }
        await c.persistence.persistEmitted(second) { failures.append($0) }
        XCTAssertEqual(c.storage.attempts, [first, first, second])
        XCTAssertEqual(c.storage.saved, [first, first, second]); XCTAssertTrue(failures.isEmpty)
        XCTAssertNil(c.state.position, "The caller publishes each event synchronously before starting its original Task")
    }

    @MainActor func testEmittedFailureReportsOriginalMessageWithoutChangingExplicitSaveState() async {
        let c = Context(), full = position(6)
        c.state.update(full); c.storage.failure = Failure()
        var messages: [String] = []
        await c.persistence.persistEmitted(full) { messages.append($0) }
        XCTAssertEqual(messages, ["阅读进度未能写入：controlled failure"])
        XCTAssertEqual(c.state.position, full); XCTAssertNil(c.state.saveFailure)
    }

    private func position(_ byte: UInt8) -> ReadingPosition {
        ReadingPosition(bookID: UUID(), engineID: "opaque", locatorVersion: 9, locatorData: Data([byte, 255]),
                        updatedAt: Date(timeIntervalSince1970: Double(byte)))
    }

    private struct Failure: LocalizedError { var errorDescription: String? { "controlled failure" } }

    @MainActor private final class Owner { var id: UUID? = UUID() }
    @MainActor private final class Context {
        let owner = Owner(), state = ReaderPositionState(), source = Source(), storage = Storage()
        lazy var persistence = ReaderPositionPersistence(state: state, storage: storage)
        func save() async {
            let token = state.beginSave(sessionID: owner.id)
            defer { state.endSave(token) }
            await persistence.captureAndSave(from: source, request: token) { self.owner.id }
        }
    }
    @MainActor private final class Source: ReaderPositionSource {
        var supportsTextCapture = true
        var currentPosition: ReadingPosition?
        var value: ReadingPosition? = ReadingPosition(bookID: UUID(), engineID: "opaque", locatorVersion: 9,
            locatorData: Data([0, 255, 4, 17]), updatedAt: Date(timeIntervalSince1970: 42))
        var calls = 0, unavailable = 0
        var failure: Error?, hold = false
        var onCapture: (() -> Void)?
        private var pending: CheckedContinuation<ReadingPosition?, Error>?
        func captureCurrentPosition() async throws -> ReadingPosition? {
            calls += 1
            if hold {
                return try await withCheckedThrowingContinuation { pending = $0; onCapture?() }
            }
            onCapture?()
            if let failure { throw failure }
            if unavailable > 0 { unavailable -= 1; return nil }
            return value
        }
        func release() { let continuation = pending; pending = nil; continuation?.resume(returning: value) }
    }
    @MainActor private final class Storage: ReaderPositionStorage {
        var attempts: [ReadingPosition] = [], saved: [ReadingPosition] = []
        var failure: Error?, hold = false
        var onSave: (() -> Void)?, onSaved: (() -> Void)?
        private var pending: CheckedContinuation<Void, Error>?
        func save(_ position: ReadingPosition) async throws {
            attempts.append(position)
            if hold { try await withCheckedThrowingContinuation { pending = $0; onSave?() } }
            else { onSave?() }
            if let failure { throw failure }
            saved.append(position); onSaved?()
        }
        func release(error: Error?) {
            let continuation = pending; pending = nil
            if let error { continuation?.resume(throwing: error) } else { continuation?.resume() }
        }
    }
}
