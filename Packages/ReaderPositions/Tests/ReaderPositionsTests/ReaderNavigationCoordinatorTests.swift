import Foundation
import XCTest
import XianxiaCore
@testable import ReaderPositions

final class ReaderNavigationCoordinatorTests: XCTestCase {
    @MainActor func testFirstFullOriginSurvivesExcursionAndReturnOrStay() async throws {
        let c = Context()
        let origin = c.value
        var beforeChanges: [(ReadingPosition?, Bool)] = []
        c.navigation.onStateWillChange = { [weak c] in
            guard let c else { return }
            beforeChanges.append((c.navigation.returnPosition, c.navigation.inProgress))
        }
        try await c.run()
        guard beforeChanges.count == 3 else { return XCTFail("Expected the original three pre-change notifications") }
        XCTAssertNil(beforeChanges[0].0); XCTAssertFalse(beforeChanges[0].1)
        XCTAssertNil(beforeChanges[1].0); XCTAssertTrue(beforeChanges[1].1)
        XCTAssertEqual(beforeChanges[2].0, origin); XCTAssertTrue(beforeChanges[2].1)
        XCTAssertEqual(c.events, ["pause", "capture", "operation", "success"])
        XCTAssertEqual(c.navigation.returnPosition, origin)
        XCTAssertEqual(c.successOrigin, origin)
        XCTAssertTrue(c.successWasBusy, "Origin and menu completion publish before request cleanup/async return")
        XCTAssertFalse(c.navigation.inProgress)
        c.value = c.position(9)
        try await c.run()
        XCTAssertEqual(c.captures, 1)
        XCTAssertEqual(c.navigation.returnPosition?.locatorData, origin.locatorData)
        XCTAssertEqual(c.navigation.returnPosition?.locatorVersion, 7)
        try await c.run(returning: true)
        XCTAssertNil(c.navigation.returnPosition)
        XCTAssertEqual(c.captures, 1)
        XCTAssertFalse(c.navigation.inProgress)
        try await c.run()
        XCTAssertEqual(c.navigation.returnPosition, c.value)
        c.navigation.stay()
        XCTAssertNil(c.navigation.returnPosition)
    }

    @MainActor func testFailedCaptureAndForeignOriginNeverNavigate() async {
        let c = Context()
        c.captureFailure = Failure()
        guard case .failure(let error) = await c.result() else { return XCTFail("Capture must fail") }
        XCTAssertTrue(error is Failure)
        XCTAssertEqual(c.captures, 1); XCTAssertEqual(c.operations, 0)
        XCTAssertFalse(c.navigation.inProgress); XCTAssertNil(c.navigation.returnPosition)
        c.captureFailure = nil
        c.value = ReadingPosition(bookID: UUID(), engineID: "foreign", locatorData: Data([255]))
        guard case .failure(let foreign) = await c.result() else { return XCTFail("Foreign origin must fail") }
        XCTAssertTrue(foreign is ReaderNavigationError)
        XCTAssertEqual(c.captures, 2, "Navigation keeps one capture per attempt, without the save retry loop")
        XCTAssertEqual(c.operations, 0); XCTAssertNil(c.navigation.returnPosition)
        XCTAssertFalse(c.navigation.inProgress)
    }

    @MainActor func testNavigationAndReturnFailureKeepOriginForRetry() async throws {
        let c = Context()
        c.operationFailure = Failure()
        guard case .failure = await c.result() else { return XCTFail("Jump must fail") }
        XCTAssertNil(c.navigation.returnPosition); XCTAssertEqual(c.successes, 0)
        XCTAssertFalse(c.navigation.inProgress)
        c.operationFailure = nil
        try await c.run()
        let origin = c.navigation.returnPosition
        c.operationFailure = Failure()
        guard case .failure = await c.result(returning: true) else { return XCTFail("Return must fail") }
        XCTAssertEqual(c.navigation.returnPosition, origin); XCTAssertEqual(c.successes, 1)
        XCTAssertFalse(c.navigation.inProgress)
        c.operationFailure = nil
        try await c.run(returning: true)
        XCTAssertNil(c.navigation.returnPosition); XCTAssertEqual(c.successes, 2)
    }

    @MainActor func testExternalRequestSharesBusyLockAndStayCannotClearWhileBusy() async throws {
        let c = Context()
        try await c.run()
        let origin = c.navigation.returnPosition, external = UUID()
        c.navigation.beginExternal(external)
        c.navigation.stay()
        XCTAssertEqual(c.navigation.returnPosition, origin)
        guard case .failure(let error) = await c.result() else { return XCTFail("External lock must reject navigation") }
        XCTAssertEqual(error.localizedDescription, "正在跳转，请稍候。")
        XCTAssertEqual(c.captures, 1); XCTAssertEqual(c.operations, 1)
        c.navigation.endExternal(UUID()); XCTAssertTrue(c.navigation.inProgress)
        c.navigation.endExternal(external); XCTAssertFalse(c.navigation.inProgress)
        c.blocked = true
        guard case .failure = await c.result() else { return XCTFail("Font preparation must also reject navigation") }
        XCTAssertEqual(c.captures, 1); XCTAssertEqual(c.operations, 1)
        c.navigation.close()
        XCTAssertFalse(c.navigation.inProgress); XCTAssertNil(c.navigation.returnPosition)
    }

    @MainActor func testLateCaptureCannotNavigateOrEndNewRequest() async throws {
        let c = Context()
        c.holdCapture = true
        let started = expectation(description: "capture held")
        c.onCapture = { started.fulfill() }
        let old = Task { await c.result() }
        await fulfillment(of: [started], timeout: 2)
        if case .success = await c.result() { XCTFail("Concurrent jump must fail") }
        XCTAssertEqual(c.captures, 1)
        c.navigation.close(); c.session = UUID()
        let next = UUID(); c.navigation.beginExternal(next)
        c.releaseCapture()
        let result = await old.value
        assertCancelled(result)
        XCTAssertEqual(c.operations, 0); XCTAssertEqual(c.successes, 0)
        XCTAssertTrue(c.navigation.inProgress); XCTAssertNil(c.navigation.returnPosition)
        c.navigation.endExternal(next)
        XCTAssertFalse(c.navigation.inProgress)
    }

    @MainActor func testLateOperationCannotPublishAcrossSessions() async {
        for fail in [false, true] {
            let c = Context()
            c.holdOperation = true
            let started = expectation(description: "operation held \(fail)")
            c.onOperation = { started.fulfill() }
            let old = Task { await c.result() }
            await fulfillment(of: [started], timeout: 2)
            c.navigation.close(); c.session = UUID()
            let next = UUID(); c.navigation.beginExternal(next)
            c.releaseOperation(error: fail ? Failure() : nil)
            let result = await old.value
            if fail {
                guard case .failure(let error) = result else { return XCTFail("Original operation failure must propagate") }
                XCTAssertTrue(error is Failure)
            } else { assertCancelled(result) }
            XCTAssertNil(c.navigation.returnPosition); XCTAssertEqual(c.successes, 0)
            XCTAssertTrue(c.navigation.inProgress, "Old defer cannot release the new owner's lock")
            c.navigation.endExternal(next)
        }
    }

    @MainActor func testCancellationKeepsUnpublishedOrExistingOrigin() async throws {
        let c = Context()
        c.holdCapture = true
        let captured = expectation(description: "cancel capture")
        c.onCapture = { captured.fulfill() }
        let first = Task { await c.result() }
        await fulfillment(of: [captured], timeout: 2)
        first.cancel(); c.releaseCapture()
        let firstResult = await first.value
        assertCancelled(firstResult)
        XCTAssertEqual(c.operations, 0); XCTAssertNil(c.navigation.returnPosition)
        XCTAssertFalse(c.navigation.inProgress)
        c.holdCapture = false; c.onCapture = nil
        try await c.run()
        let origin = c.navigation.returnPosition
        c.holdOperation = true
        let moved = expectation(description: "cancel return")
        c.onOperation = { moved.fulfill() }
        let returning = Task { await c.result(returning: true) }
        await fulfillment(of: [moved], timeout: 2)
        returning.cancel(); c.releaseOperation()
        let returnResult = await returning.value
        assertCancelled(returnResult)
        XCTAssertEqual(c.navigation.returnPosition, origin); XCTAssertEqual(c.successes, 1)
        XCTAssertFalse(c.navigation.inProgress)
    }

    @MainActor func testObsoleteEntryCannotSampleNavigateOrPublish() async {
        let c = Context(), oldSession = UUID()
        let result = await c.result(expectedSession: oldSession)
        assertCancelled(result)
        XCTAssertTrue(c.events.isEmpty); XCTAssertEqual(c.captures, 0)
        XCTAssertEqual(c.operations, 0); XCTAssertFalse(c.navigation.inProgress)
        c.session = nil
        let closed = await c.result(expectedSession: oldSession)
        assertCancelled(closed)
        XCTAssertEqual(c.successes, 0); XCTAssertNil(c.navigation.returnPosition)
    }

    private func assertCancelled(_ result: Result<Bool, Error>, file: StaticString = #filePath, line: UInt = #line) {
        guard case .failure(let error) = result else { return XCTFail("Expected cancellation", file: file, line: line) }
        XCTAssertTrue(error is CancellationError, file: file, line: line)
    }

    private struct Failure: LocalizedError { var errorDescription: String? { "controlled navigation failure" } }

    @MainActor private final class Context {
        let bookID = UUID(), navigation = ReaderNavigationCoordinator()
        var session: UUID? = UUID(), blocked = false
        lazy var value = position(1)
        var events: [String] = []
        var captures = 0, operations = 0, successes = 0
        var successOrigin: ReadingPosition?, successWasBusy = false
        var captureFailure: Error?, operationFailure: Error?
        var holdCapture = false, holdOperation = false
        var onCapture: (() -> Void)?, onOperation: (() -> Void)?
        private var pendingCapture: CheckedContinuation<ReadingPosition, Error>?
        private var pendingOperation: CheckedContinuation<Void, Error>?

        func position(_ byte: UInt8) -> ReadingPosition {
            ReadingPosition(bookID: bookID, engineID: "opaque", locatorVersion: 7, locatorData: Data([byte, 0, 255]),
                            updatedAt: Date(timeIntervalSince1970: Double(byte)))
        }

        func run(returning: Bool = false, expectedSession: UUID? = nil) async throws {
            guard let owner = expectedSession ?? session else { throw CancellationError() }
            try await navigation.navigate(bookID: bookID, session: owner, sessionID: { self.session },
                isBlocked: { self.blocked }, pause: { self.events.append("pause") }, capture: { try await self.capture() },
                onSuccess: {
                    self.events.append("success"); self.successes += 1
                    self.successOrigin = self.navigation.returnPosition; self.successWasBusy = self.navigation.inProgress
                }, operation: { try await self.move() }, returning: returning)
        }

        func result(returning: Bool = false, expectedSession: UUID? = nil) async -> Result<Bool, Error> {
            do { try await run(returning: returning, expectedSession: expectedSession); return .success(true) }
            catch { return .failure(error) }
        }

        private func capture() async throws -> ReadingPosition {
            events.append("capture"); captures += 1
            if holdCapture { return try await withCheckedThrowingContinuation { pendingCapture = $0; onCapture?() } }
            onCapture?()
            if let captureFailure { throw captureFailure }
            return value
        }

        private func move() async throws {
            events.append("operation"); operations += 1
            if holdOperation { try await withCheckedThrowingContinuation { pendingOperation = $0; onOperation?() } }
            else { onOperation?() }
            if let operationFailure { throw operationFailure }
        }

        func releaseCapture() { let c = pendingCapture; pendingCapture = nil; c?.resume(returning: value) }
        func releaseOperation(error: Error? = nil) {
            let c = pendingOperation; pendingOperation = nil
            if let error { c?.resume(throwing: error) } else { c?.resume() }
        }
    }
}
