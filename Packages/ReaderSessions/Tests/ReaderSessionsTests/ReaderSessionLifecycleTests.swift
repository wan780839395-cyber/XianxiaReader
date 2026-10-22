import Foundation
import ReaderSessions
import XCTest

final class ReaderSessionLifecycleTests: XCTestCase {
    @MainActor func testOpeningPublishesInOriginalStageAndAwaitOrder() async {
        let state = ReaderSessionState(), host = Host()
        let lifecycle = ReaderSessionLifecycle(state: state, host: host)
        await lifecycle.open()
        XCTAssertEqual(host.events, ["begin", "stage.settings", "clear-save", "appearance", "stage.fonts",
            "fonts", "commit-fonts", "apply-appearance.11", "stage.position", "interaction",
            "apply-interaction.22", "position", "chapters", "publish-chapters", "bookmarks",
            "publish-bookmarks", "stage.layout", "resolve-file", "engine", "ready.22"])
        XCTAssertEqual(host.enginePosition, 33)
        XCTAssertEqual(host.readyCount, 1)
        XCTAssertNotNil(state.requestID)
        XCTAssertNil(host.failure)
    }

    @MainActor func testOrdinaryOpenFailureKeepsOwnerAndRetryClosesBeforeClearingFailure() async throws {
        for phase in ["appearance", "interaction", "position", "chapters", "bookmarks", "apply-appearance", "apply-interaction", "resolve-file", "engine"] {
            let state = ReaderSessionState(), host = Host()
            let lifecycle = ReaderSessionLifecycle(state: state, host: host)
            host.failurePhase = phase
            await lifecycle.open()
            let failedOwner = try XCTUnwrap(state.requestID)
            XCTAssertEqual(host.failure, phase)
            XCTAssertEqual(host.readyCount, 0)
            XCTAssertEqual(host.engineCloses, 0)
            host.failurePhase = nil; host.events = []
            await lifecycle.retryOpen()
            XCTAssertNotEqual(state.requestID, failedOwner)
            XCTAssertEqual(Array(host.events.prefix(7)), ["invalidate-position", "close-fonts", "close-navigation",
                "close-engine", "closed", "clear-open-failure", "begin"])
            XCTAssertEqual(host.readyCount, 1)
            XCTAssertNil(host.failure)
        }
    }

    @MainActor func testFontFailureFallsBackButFontCancellationDoesNot() async {
        for cancel in [false, true] {
            let state = ReaderSessionState(), host = Host()
            host.failurePhase = "fonts"; host.cancelFailure = cancel
            await ReaderSessionLifecycle(state: state, host: host).open()
            XCTAssertEqual(host.events.contains("font-failure.fonts"), !cancel)
            XCTAssertEqual(host.readyCount, cancel ? 0 : 1)
            XCTAssertEqual(host.engineCloses, cancel ? 1 : 0)
            XCTAssertEqual(state.requestID == nil, cancel)
            XCTAssertNil(host.failure)
        }
    }

    @MainActor func testDuplicateOpenAndMissingEngineDoNotStartAnotherRequest() async throws {
        let state = ReaderSessionState(), host = Host()
        let lifecycle = ReaderSessionLifecycle(state: state, host: host)
        host.engineAvailable = false; host.failure = "factory failure"
        await lifecycle.open(); await lifecycle.retryOpen()
        XCTAssertTrue(host.events.isEmpty); XCTAssertNil(state.requestID)
        XCTAssertEqual(host.failure, "factory failure")
        host.engineAvailable = true
        await lifecycle.open()
        let owner = try XCTUnwrap(state.requestID), count = host.events.count
        await ReaderSessionLifecycle(state: state, host: host).open()
        XCTAssertEqual(state.requestID, owner); XCTAssertEqual(host.events.count, count)
    }

    @MainActor func testCloseDuringEachSuspensionCannotReadyOrInvalidateReopenedSession() async {
        for phase in ["appearance", "fonts", "interaction", "position", "chapters", "bookmarks", "engine"] {
            let state = ReaderSessionState(), host = Host()
            let lifecycle = ReaderSessionLifecycle(state: state, host: host)
            let entered = expectation(description: "held \(phase)")
            let gate = Gate { entered.fulfill() }
            host.gatePhase = phase; host.gate = gate
            let old = Task { await lifecycle.open() }
            await fulfillment(of: [entered], timeout: 2)
            if !gate.entered {
                gate.release(); old.cancel(); await old.value
                continue // fulfillment already recorded the preparation failure.
            }
            lifecycle.close()
            XCTAssertNil(state.requestID)
            await ReaderSessionLifecycle(state: state, host: host).open()
            let newOwner = state.requestID
            gate.release(); await old.value
            XCTAssertNotNil(newOwner, phase)
            XCTAssertEqual(state.requestID, newOwner, phase)
            XCTAssertEqual(host.readyCount, 1, phase)
            XCTAssertEqual(host.engineCloses, 1, phase)
            XCTAssertNil(host.failure, phase)
        }
    }

    @MainActor func testCallerCancellationClosesOnlyItsOwnedEngine() async {
        let state = ReaderSessionState(), host = Host()
        let lifecycle = ReaderSessionLifecycle(state: state, host: host)
        let entered = expectation(description: "caller cancellation reaches original appearance await")
        let gate = Gate { entered.fulfill() }
        host.gatePhase = "appearance"; host.gate = gate
        let opening = Task { await lifecycle.open() }
        await fulfillment(of: [entered], timeout: 2)
        opening.cancel(); gate.release(); await opening.value
        XCTAssertEqual(host.events, ["begin", "stage.settings", "clear-save", "appearance", "close-engine"])
        XCTAssertNil(state.requestID); XCTAssertNil(host.failure)
        XCTAssertEqual(host.readyCount, 0)
    }

    @MainActor func testCloseOrderingAcceptsFinalPositionBeforeInvalidating() async throws {
        let state = ReaderSessionState(), host = Host()
        let lifecycle = ReaderSessionLifecycle(state: state, host: host)
        await lifecycle.open()
        let owner = try XCTUnwrap(state.requestID)
        let bookID = host.bookID
        var finalAccepted = false, closedWithoutOwner = false
        host.onEngineClose = { finalAccepted = state.accept(owner, bookID: bookID) {} }
        host.onClosed = { closedWithoutOwner = state.requestID == nil }
        host.events = []
        lifecycle.close()
        XCTAssertEqual(host.events, ["invalidate-position", "close-fonts", "close-navigation", "close-engine", "closed"])
        XCTAssertTrue(finalAccepted); XCTAssertTrue(closedWithoutOwner)
        XCTAssertFalse(state.accept(owner) {})
    }

    @MainActor func testBoundEntryRetainsHostUntilReleasedWithoutCreatingTaskWrapper() async {
        let state = ReaderSessionState()
        weak var retained: Host?
        var entry: (@MainActor () async -> Void)? = {
            let host = Host()
            retained = host
            return ReaderSessionLifecycle(state: state, host: host).open
        }()
        XCTAssertNotNil(retained)
        await entry?()
        XCTAssertEqual(retained?.readyCount, 1)
        entry = nil
        XCTAssertNil(retained)
    }

    @MainActor private final class Gate {
        private var continuation: CheckedContinuation<Void, Never>?
        private let onEntered: () -> Void
        private var released = false
        private(set) var entered = false
        init(_ onEntered: @escaping () -> Void) { self.onEntered = onEntered }
        func wait() async {
            if released { return }
            await withCheckedContinuation { continuation = $0; entered = true; onEntered() }
        }
        func release() { released = true; let pending = continuation; continuation = nil; pending?.resume() }
    }

    private struct Failure: LocalizedError {
        let phase: String
        var errorDescription: String? { phase }
    }

    @MainActor private final class Host: ReaderSessionLifecycleHost {
        let bookID = UUID(), book = 7
        var events = [String]()
        var engineAvailable = true, cancelFailure = false
        var failurePhase: String?, failure: String?, gatePhase: String?
        var gate: Gate?
        var readyCount = 0, engineCloses = 0
        var enginePosition: Int?
        var onEngineClose: (() -> Void)?, onClosed: (() -> Void)?

        func step(_ phase: String) async throws {
            events.append(phase)
            if phase == gatePhase, let held = gate { gate = nil; await held.wait() }
            try fail(phase)
        }
        func fail(_ phase: String) throws {
            if failurePhase == phase {
                if cancelFailure { throw CancellationError() }
                throw Failure(phase: phase)
            }
        }
        func appearance() async throws -> Int { try await step("appearance"); return 11 }
        func fonts() async throws -> Int { try await step("fonts"); return 12 }
        func interaction() async throws -> Int { try await step("interaction"); return 22 }
        func position(_ id: UUID) async throws -> Int? { XCTAssertEqual(id, bookID); try await step("position"); return 33 }
        func chapters(_ id: UUID) async throws -> [String] { XCTAssertEqual(id, bookID); try await step("chapters"); return ["chapter"] }
        func bookmarks(_ id: UUID) async throws -> [String] { XCTAssertEqual(id, bookID); try await step("bookmarks"); return ["bookmark"] }
        func open(_ book: Int, _ file: URL, _ position: Int?) async throws {
            XCTAssertEqual(book, 7); XCTAssertEqual(file.path, "/reader.epub")
            enginePosition = position; try await step("engine")
        }

        var readAppearance: @MainActor () async throws -> Int { appearance }
        var loadFonts: @MainActor () async throws -> Int { fonts }
        var readInteraction: @MainActor () async throws -> Int { interaction }
        var readPosition: (UUID) async throws -> Int? { position }
        var readChapters: (UUID) async throws -> [String] { chapters }
        var readBookmarks: (UUID) async throws -> [String] { bookmarks }
        var openEngine: (@MainActor (Int, URL, Int?) async throws -> Void)? { engineAvailable ? open : nil }
        var resolveFile: @MainActor () throws -> URL { { self.events.append("resolve-file"); try self.fail("resolve-file"); return URL(fileURLWithPath: "/reader.epub") } }
        var begin: @MainActor (UUID) -> Void { { _ in self.events.append("begin") } }
        var showStage: @MainActor (ReaderOpeningStage) -> Void { { self.events.append("stage.\($0)") } }
        var clearSaveFailure: @MainActor () -> Void { { self.events.append("clear-save") } }
        var commitFonts: @MainActor (Int, UUID) throws -> Void { { _, _ in self.events.append("commit-fonts") } }
        var reportFontFailure: @MainActor (String, UUID) throws -> Void { { message, _ in self.events.append("font-failure.\(message)") } }
        var applyAppearance: @MainActor (Int) throws -> Void { { value in try self.fail("apply-appearance"); self.events.append("apply-appearance.\(value)") } }
        var applyInteraction: @MainActor (Int) throws -> Void { { value in try self.fail("apply-interaction"); self.events.append("apply-interaction.\(value)") } }
        var publishChapters: @MainActor ([String]) -> Void { { _ in self.events.append("publish-chapters") } }
        var publishBookmarks: @MainActor ([String]) -> Void { { _ in self.events.append("publish-bookmarks") } }
        var publishReady: @MainActor (Int) -> Void { { value in self.readyCount += 1; self.events.append("ready.\(value)") } }
        var publishOpenFailure: @MainActor (String?) -> Void { { value in self.failure = value; self.events.append(value == nil ? "clear-open-failure" : "open-failure") } }
        var invalidatePositionCapture: @MainActor () -> Void { { self.events.append("invalidate-position") } }
        var closeFonts: @MainActor () -> Void { { self.events.append("close-fonts") } }
        var closeNavigation: @MainActor () -> Void { { self.events.append("close-navigation") } }
        var closeEngine: @MainActor () -> Void { { self.engineCloses += 1; self.events.append("close-engine"); self.onEngineClose?() } }
        var publishClosed: @MainActor () -> Void { { self.events.append("closed"); self.onClosed?() } }
    }
}
