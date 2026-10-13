import Combine
import Foundation
import ReadingInterfaces
import XCTest
import XianxiaCore
@testable import XianxiaReader

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
}
