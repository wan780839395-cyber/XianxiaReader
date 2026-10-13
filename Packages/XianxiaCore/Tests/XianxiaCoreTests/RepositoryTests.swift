import CSQLite
import Foundation
import XCTest
@testable import XianxiaCore

final class RepositoryTests: XCTestCase {
    private func temporaryRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return root
    }

    func testLibraryPositionAndBookmarksSurviveReopening() async throws {
        let url = try temporaryRoot().appendingPathComponent("library.sqlite")
        let repository = try SQLiteBookRepository(url: url)
        let book = Book(title: "云海问道", author: "测试作者", format: .epub, filePath: "Books/test/book.epub")
        let chapter = Chapter(id: "chapter-1", bookID: book.id, ordinal: 0, title: "第一章", href: "one.xhtml")
        try await repository.insert(book, chapters: [chapter])
        let position = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data("位置".utf8), progression: 0.42)
        let bookmark = Bookmark(position: position, title: "第一章")
        try await repository.save(position)
        try await repository.add(bookmark)

        let reopened = try SQLiteBookRepository(url: url)
        let books = try await reopened.books()
        let restored = try await reopened.position(for: book.id)
        let chapters = try await reopened.chapters(for: book.id)
        let bookmarks = try await reopened.bookmarks(for: book.id)
        XCTAssertEqual(books.first?.book, book)
        XCTAssertEqual(books.first?.progression, 0.42)
        XCTAssertEqual(try XCTUnwrap(books.first?.lastReadAt).timeIntervalSince1970,
                       position.updatedAt.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(restored, position)
        XCTAssertEqual(chapters, [chapter])
        XCTAssertEqual(bookmarks, [bookmark])
        try await reopened.removeBookmark(bookmark.id)
        let remaining = try await reopened.bookmarks(for: book.id)
        XCTAssertTrue(remaining.isEmpty)
    }

    func testStalePositionCannotOverwriteNewerPosition() async throws {
        let repository = try SQLiteBookRepository(url: temporaryRoot().appendingPathComponent("library.sqlite"))
        let book = Book(title: "测试", format: .epub, filePath: "book.epub")
        try await repository.insert(book, chapters: [])
        let newer = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([2]), progression: 0.8,
                                    updatedAt: Date(timeIntervalSince1970: 200))
        let older = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([1]), progression: 0.2,
                                    updatedAt: Date(timeIntervalSince1970: 100))
        try await repository.save(newer)
        try await repository.save(older)
        let restored = try await repository.position(for: book.id)
        XCTAssertEqual(restored, newer)
    }

    func testInvalidChapterRollsBackWholeImport() async throws {
        let repository = try SQLiteBookRepository(url: temporaryRoot().appendingPathComponent("library.sqlite"))
        let book = Book(title: "回滚测试", format: .epub, filePath: "book.epub")
        let chapter = Chapter(id: "invalid", bookID: book.id, ordinal: -1, title: "无效")
        do {
            try await repository.insert(book, chapters: [chapter])
            XCTFail("Invalid ordinal must fail")
        } catch { XCTAssertTrue(error is DatabaseError) }
        let books = try await repository.books()
        let chapters = try await repository.chapters(for: book.id)
        XCTAssertTrue(books.isEmpty)
        XCTAssertTrue(chapters.isEmpty)
    }

    func testPositionForMissingBookFailsForeignKeyConstraint() async throws {
        let repository = try SQLiteBookRepository(url: temporaryRoot().appendingPathComponent("library.sqlite"))
        let position = ReadingPosition(bookID: UUID(), engineID: "test", locatorData: Data([1]))
        do { try await repository.save(position); XCTFail("Orphan position must fail") }
        catch { XCTAssertTrue(error is DatabaseError) }
    }

    func testChapterOrderAndBookIsolation() async throws {
        let repository = try SQLiteBookRepository(url: temporaryRoot().appendingPathComponent("library.sqlite"))
        let first = Book(title: "甲", format: .epub, filePath: "first.epub")
        let second = Book(title: "乙", format: .epub, filePath: "second.epub")
        let a = Chapter(id: "a", bookID: first.id, ordinal: 0, title: "第一章")
        let b = Chapter(id: "b", bookID: first.id, ordinal: 1, title: "第二章")
        try await repository.insert(first, chapters: [b, a])
        try await repository.insert(second, chapters: [])
        let ordered = try await repository.chapters(for: first.id)
        let other = try await repository.chapters(for: second.id)
        XCTAssertEqual(ordered, [a, b])
        XCTAssertTrue(other.isEmpty)
    }

    func testProgressionSanitizesOutOfRangeAndNonFiniteValues() {
        func position(_ value: Double) -> ReadingPosition {
            ReadingPosition(bookID: UUID(), engineID: "test", locatorData: Data(), progression: value)
        }
        XCTAssertEqual(position(-0.1).progression, 0)
        XCTAssertEqual(position(1.1).progression, 1)
        XCTAssertNil(position(.nan).progression)
        XCTAssertNil(position(.infinity).progression)
    }

    func testNewerSchemaIsRejectedWithoutChangingOrDeletingDatabase() throws {
        let url = try temporaryRoot().appendingPathComponent("future.sqlite")
        var connection: OpaquePointer?
        XCTAssertEqual(sqlite3_open(url.path, &connection), SQLITE_OK)
        let sql = "CREATE TABLE future_marker(value TEXT); INSERT INTO future_marker VALUES ('keep'); PRAGMA user_version = 99;"
        XCTAssertEqual(sqlite3_exec(connection, sql, nil, nil, nil), SQLITE_OK)
        sqlite3_close(connection)
        connection = nil
        for _ in 0..<3 { XCTAssertThrowsError(try SQLiteBookRepository(url: url)) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(sqlite3_open(url.path, &connection), SQLITE_OK)
        defer { sqlite3_close(connection) }
        var statement: OpaquePointer?
        XCTAssertEqual(sqlite3_prepare_v2(connection, "SELECT value FROM future_marker;", -1, &statement, nil), SQLITE_OK)
        defer { sqlite3_finalize(statement) }
        XCTAssertEqual(sqlite3_step(statement), SQLITE_ROW)
        let bytes = try XCTUnwrap(sqlite3_column_text(statement, 0))
        XCTAssertEqual(String(cString: bytes), "keep")
    }
}
