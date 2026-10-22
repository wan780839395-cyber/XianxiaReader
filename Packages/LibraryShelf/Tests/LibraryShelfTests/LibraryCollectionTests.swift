import Foundation
import LibraryShelf
import XCTest
import XianxiaCore

final class LibraryCollectionTests: XCTestCase {
    private func summary(_ title: String = "旧书名") -> BookSummary {
        BookSummary(book: Book(title: title, format: .epub, filePath: "original.epub"),
                    progression: 0.42, lastReadAt: Date(timeIntervalSince1970: 42))
    }

    @MainActor func testLatestRefreshOwnsBothListsAndOldFailureIsRejected() async {
        let state = LibraryCollection(), book = summary(), removed = summary("回收站")
        let old = state.beginRefresh(), current = state.beginRefresh()
        XCTAssertFalse(state.acceptsRefresh(old)); XCTAssertTrue(state.acceptsRefresh(current))
        state.apply(LibrarySnapshot(books: [book], removedBooks: [removed]), requestID: current)
        state.apply(LibrarySnapshot(books: [], removedBooks: []), requestID: old)
        XCTAssertEqual(state.books, [book]); XCTAssertEqual(state.removedBooks, [removed])
    }

    @MainActor func testCommittedRenameAndCoverRetainReadingSummaryAndRejectOldSnapshot() async {
        let state = LibraryCollection(), original = summary()
        state.apply(LibrarySnapshot(books: [original], removedBooks: []), requestID: state.beginRefresh())
        let stale = state.beginRefresh()
        var renamed = original.book; renamed.title = "新书名"; renamed.coverPath = "cover.jpg"
        state.didCommitMetadata(renamed)
        state.apply(LibrarySnapshot(books: [original], removedBooks: []), requestID: stale)
        XCTAssertEqual(state.books.first?.book, renamed)
        XCTAssertEqual(state.books.first?.progression, original.progression)
        XCTAssertEqual(state.books.first?.lastReadAt, original.lastReadAt)
        XCTAssertTrue(state.removedBooks.isEmpty); XCTAssertFalse(state.acceptsRefresh(stale))
    }

    @MainActor func testTrashAndRestoreKeepSummaryOrderAndRejectPrecommitRefresh() async {
        let state = LibraryCollection(), first = summary(), second = summary("第二本"), removed = summary("原回收站")
        state.apply(LibrarySnapshot(books: [first, second], removedBooks: [removed]), requestID: state.beginRefresh())
        let oldTrash = state.beginRefresh(); state.didCommitRemoval(first.id, restoring: false)
        state.apply(LibrarySnapshot(books: [first, second], removedBooks: [removed]), requestID: oldTrash)
        XCTAssertEqual(state.books, [second]); XCTAssertEqual(state.removedBooks, [first, removed])
        let oldRestore = state.beginRefresh(); state.didCommitRemoval(first.id, restoring: true)
        state.apply(LibrarySnapshot(books: [second], removedBooks: [first, removed]), requestID: oldRestore)
        XCTAssertEqual(state.books, [second, first]); XCTAssertEqual(state.removedBooks, [removed])
    }

    @MainActor func testMissingCommitDoesNotInventBookAndStillInvalidatesRefresh() async {
        let state = LibraryCollection(), book = summary(), old = state.beginRefresh()
        state.didCommitMetadata(book.book); XCTAssertFalse(state.acceptsRefresh(old))
        let next = state.beginRefresh(); state.didCommitRemoval(book.id, restoring: true)
        XCTAssertFalse(state.acceptsRefresh(next)); XCTAssertTrue(state.books.isEmpty); XCTAssertTrue(state.removedBooks.isEmpty)
    }

    @MainActor func testChangeNotificationPrecedesEachListMutationSynchronously() async {
        let state = LibraryCollection(), book = summary()
        var observations: [[BookSummary]] = []
        state.willChange = { observations.append(state.books) }
        state.apply(LibrarySnapshot(books: [book], removedBooks: []), requestID: state.beginRefresh())
        XCTAssertEqual(observations, [[], [book]])
        state.willChange = nil
    }

    @MainActor func testFreshPostcommitSnapshotCanReconcileBothLists() async {
        let state = LibraryCollection(), book = summary()
        state.didCommitRemoval(book.id, restoring: false)
        let fresh = state.beginRefresh()
        state.apply(LibrarySnapshot(books: [], removedBooks: [book]), requestID: fresh)
        XCTAssertEqual(state.removedBooks, [book]); XCTAssertTrue(state.books.isEmpty)
    }
}
