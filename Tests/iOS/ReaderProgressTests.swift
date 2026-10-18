import Combine
import Foundation
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReaderProgressTests: XCTestCase {
    @MainActor func testSummaryChangesDoNotDiscardOpaquePositionOrPublishEquivalentDisplay() {
        let state = ReaderProgressState()
        var changes = 0
        let subscription = state.objectWillChange.sink { changes += 1 }
        defer { subscription.cancel() }
        let bookID = UUID()
        let unknown = ReadingPosition(bookID: bookID, engineID: "test", locatorVersion: 6,
            locatorData: Data([1, 2, 3]), progression: .nan)
        state.update(unknown)
        XCTAssertEqual(state.position, unknown); XCTAssertEqual(changes, 0)
        XCTAssertEqual(state.summary.chapterTitle, "正文"); XCTAssertNil(state.summary.progression)
        let complete = ReadingPosition(bookID: bookID, engineID: "test", locatorVersion: 7,
            locatorData: Data([4, 5, 6]), chapterTitle: "当前章", progression: 1.5)
        state.update(complete)
        XCTAssertEqual(state.position, complete); XCTAssertEqual(state.summary.progression, 1)
        XCTAssertEqual(changes, 1)
        state.update(complete); XCTAssertEqual(changes, 1)
        state.update(nil)
        XCTAssertNil(state.position); XCTAssertEqual(state.summary.chapterTitle, "正文")
        XCTAssertNil(state.summary.progression); XCTAssertEqual(changes, 2)
    }
}
