import Combine
import Foundation
import ReaderSearch
import XCTest
import XianxiaCore

final class ReaderSearchViewModelTests: XCTestCase {
    private actor Session: ReaderSearchSession {
        var pages: [[ReaderSearchHit]]
        var cancelled = false
        var calls = 0
        let entered: XCTestExpectation?
        let onCancel: XCTestExpectation?
        private var continuation: CheckedContinuation<Void, Never>?
        init(pages: [[ReaderSearchHit]], entered: XCTestExpectation? = nil, onCancel: XCTestExpectation? = nil) {
            self.pages = pages; self.entered = entered; self.onCancel = onCancel
        }
        func next() async throws -> [ReaderSearchHit]? {
            calls += 1
            if let entered { await withCheckedContinuation { continuation = $0; entered.fulfill() } }
            if pages.isEmpty { return nil }
            return pages.removeFirst()
        }
        func finish() { continuation?.resume(); continuation = nil }
        func cancel() { cancelled = true; onCancel?.fulfill() }
        func snapshot() -> (Bool, Int) { (cancelled, calls) }
    }

    private actor Provider: ReaderSearchProviding {
        let sessions: [String: Session]
        let entered: XCTestExpectation?
        var calls = 0
        private var continuation: CheckedContinuation<Void, Never>?
        init(_ sessions: [String: Session], entered: XCTestExpectation? = nil) {
            self.sessions = sessions; self.entered = entered
        }
        func search(query: String) async throws -> any ReaderSearchSession {
            calls += 1
            if query == "old", let entered {
                await withCheckedContinuation { continuation = $0; entered.fulfill() }
            }
            guard let session = sessions[query] else { throw ReaderSearchError.unavailable }
            return session
        }
        func finish() { continuation?.resume(); continuation = nil }
        func callCount() -> Int { calls }
    }

    private func hit(_ text: String) -> ReaderSearchHit {
        ReaderSearchHit(title: "测试章", before: "之前", highlight: text, after: "之后",
                        position: ReadingPosition(bookID: UUID(), engineID: "test", locatorData: Data(text.utf8)))
    }

    @MainActor private func waitForIdle(_ model: ReaderSearchViewModel) async {
        guard model.isLoading else { return }
        let finished = expectation(description: "UI request finished")
        let observer = model.$isLoading.dropFirst().filter { !$0 }.prefix(1).sink { _ in finished.fulfill() }
        await fulfillment(of: [finished], timeout: 3)
        withExtendedLifetime(observer) {}
    }

    @MainActor func testLateStartedSessionIsCancelledAfterQueryChanges() async {
        let entered = expectation(description: "old provider suspended")
        let cancelled = expectation(description: "late session released")
        let old = Session(pages: [[hit("old")]], onCancel: cancelled)
        let newHit = hit("new")
        let provider = Provider(["old": old, "new": Session(pages: [[newHit]])], entered: entered)
        let model = ReaderSearchViewModel(provider: provider) { _ in }
        model.setQuery("old"); model.search()
        await fulfillment(of: [entered], timeout: 3)
        model.setQuery("new"); model.search()
        await waitForIdle(model)
        await provider.finish()
        await fulfillment(of: [cancelled], timeout: 3)
        XCTAssertEqual(model.results.map(\.id), [newHit.id])
        XCTAssertNil(model.errorMessage)
        model.cancel()
    }

    @MainActor func testLatePageCannotReplaceNewQueryResults() async {
        let entered = expectation(description: "old page suspended")
        let cancelled = expectation(description: "old page cancelled")
        // One invalidation and one late-response cleanup. Wait for the latter so
        // the assertion cannot pass merely because the old request has not resumed.
        cancelled.expectedFulfillmentCount = 2
        let old = Session(pages: [[hit("old")]], entered: entered, onCancel: cancelled)
        let newHit = hit("new")
        let model = ReaderSearchViewModel(provider: Provider(["old": old, "new": Session(pages: [[newHit]])])) { _ in }
        model.setQuery("old"); model.search()
        await fulfillment(of: [entered], timeout: 3)
        model.setQuery("new"); model.search()
        await waitForIdle(model)
        await old.finish()
        await fulfillment(of: [cancelled], timeout: 3)
        XCTAssertEqual(model.results.map(\.id), [newHit.id])
        XCTAssertFalse(model.isLoading)
        model.cancel()
    }

    @MainActor func testLoadMoreIsExplicitAndResultsStopAtVisibleLimit() async {
        let page = (0..<40).map { hit("修行\($0)") }
        let session = Session(pages: (0..<26).map { _ in page.map { hit($0.highlight) } })
        let model = ReaderSearchViewModel(provider: Provider(["修行": session])) { _ in }
        model.setQuery("修行"); model.search()
        await waitForIdle(model)
        XCTAssertEqual(model.results.count, 40)
        let firstSnapshot = await session.snapshot()
        XCTAssertEqual(firstSnapshot.1, 1)
        for _ in 1..<25 { model.loadMore(); await waitForIdle(model) }
        XCTAssertEqual(model.results.count, 1000)
        XCTAssertTrue(model.reachedLimit)
        XCTAssertFalse(model.canLoadMore)
        model.loadMore()
        let snapshot = await session.snapshot()
        XCTAssertTrue(snapshot.0)
        XCTAssertEqual(snapshot.1, 25)
        model.cancel()
    }

    @MainActor func testEmptyAndOversizedQueryNeverStartEngineSearch() async {
        let provider = Provider([:])
        let model = ReaderSearchViewModel(provider: provider) { _ in }
        for query in [" \n", String(repeating: "修", count: 257)] {
            model.setQuery(query); model.search()
            XCTAssertNotNil(model.errorMessage)
            XCTAssertFalse(model.isLoading)
        }
        let calls = await provider.callCount()
        XCTAssertEqual(calls, 0)
    }

    @MainActor func testSelectionDelegatesOpaquePositionAndReportsNavigationFailure() async {
        struct Failure: LocalizedError { var errorDescription: String? { "跳转测试错误" } }
        let result = hit("修行")
        var selected: ReadingPosition?
        let model = ReaderSearchViewModel(provider: Provider(["修行": Session(pages: [[result]])])) { hit in
            selected = hit.position
            throw Failure()
        }
        model.setQuery("修行"); model.search()
        await waitForIdle(model)
        await model.select(result)
        XCTAssertEqual(selected?.locatorData, result.position.locatorData)
        XCTAssertTrue(model.errorMessage?.contains("跳转测试错误") == true)
        model.cancel()
        selected = nil
        await model.select(result)
        XCTAssertNil(selected)
    }

    @MainActor func testCloseWhileProviderIsSuspendedRejectsAndCancelsLateSession() async {
        let entered = expectation(description: "provider suspended before close")
        let cancelled = expectation(description: "closed request releases late session")
        let session = Session(pages: [[hit("old")]], onCancel: cancelled)
        let provider = Provider(["old": session], entered: entered)
        let model = ReaderSearchViewModel(provider: provider) { _ in }
        model.setQuery("old"); model.search()
        await fulfillment(of: [entered], timeout: 3)
        model.cancel()
        await provider.finish()
        await fulfillment(of: [cancelled], timeout: 3)
        XCTAssertTrue(model.results.isEmpty)
        XCTAssertFalse(model.isLoading)
        XCTAssertFalse(model.canLoadMore)
        XCTAssertFalse(model.didSearch)
        XCTAssertNil(model.errorMessage)
    }

    private actor Gate {
        let entered: XCTestExpectation
        private var continuation: CheckedContinuation<Void, Never>?
        private var released = false
        init(_ entered: XCTestExpectation) { self.entered = entered }
        func wait() async {
            await withCheckedContinuation {
                if released { $0.resume() }
                else { continuation = $0 }
                entered.fulfill()
            }
        }
        func release() {
            released = true
            continuation?.resume(); continuation = nil
        }
    }

    private actor DelayedCancelSession: ReaderSearchSession {
        let result: ReaderSearchHit
        let gate: Gate
        let finished: XCTestExpectation
        init(result: ReaderSearchHit, gate: Gate, finished: XCTestExpectation) {
            self.result = result; self.gate = gate; self.finished = finished
        }
        func next() -> [ReaderSearchHit]? { [result] }
        func cancel() async { await gate.wait(); finished.fulfill() }
    }

    private struct FixedProvider: ReaderSearchProviding {
        let sessions: [String: any ReaderSearchSession]
        func search(query: String) async throws -> any ReaderSearchSession {
            guard let session = sessions[query] else { throw ReaderSearchError.unavailable }
            return session
        }
    }

    @MainActor func testDelayedOldCancellationCannotClearNewSessionOrItsNextPage() async {
        let entered = expectation(description: "old cleanup suspended")
        let finished = expectation(description: "old cleanup completed")
        let gate = Gate(entered)
        let old = DelayedCancelSession(result: hit("old"), gate: gate, finished: finished)
        let first = hit("new1"), second = hit("new2")
        let current = Session(pages: [[first], [second]])
        let model = ReaderSearchViewModel(provider: FixedProvider(sessions: ["old": old, "new": current])) { _ in }
        model.setQuery("old"); model.search()
        await waitForIdle(model)
        model.setQuery("new"); model.search()
        await fulfillment(of: [entered], timeout: 3)
        await waitForIdle(model)
        await gate.release()
        await fulfillment(of: [finished], timeout: 3)
        model.loadMore()
        await waitForIdle(model)
        let snapshot = await current.snapshot()
        let results = model.results.map(\.id)
        model.cancel()
        XCTAssertEqual(results, [first.id, second.id])
        XCTAssertEqual(snapshot.1, 2)
        XCTAssertFalse(snapshot.0)
    }

    @MainActor func testLateSelectionFailureCannotPublishIntoNewQuery() async {
        let entered = expectation(description: "navigation suspended")
        let gate = Gate(entered)
        let old = hit("old"), current = hit("new")
        let model = ReaderSearchViewModel(provider: Provider([
            "old": Session(pages: [[old]]), "new": Session(pages: [[current]])
        ])) { _ in
            await gate.wait()
            throw ReaderSearchError.unavailable
        }
        model.setQuery("old"); model.search()
        await waitForIdle(model)
        let selection = Task { await model.select(old) }
        await fulfillment(of: [entered], timeout: 3)
        model.setQuery("new"); model.search()
        await waitForIdle(model)
        await gate.release()
        await selection.value
        XCTAssertEqual(model.results.map(\.id), [current.id])
        XCTAssertNil(model.errorMessage)
        model.cancel()
    }
}
