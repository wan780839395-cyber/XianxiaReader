import CSQLite
import Foundation
import XCTest
@testable import XianxiaCore

final class BookEditingTests: XCTestCase {
    private func root() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return root
    }

    func testRenameSurvivesReopenWithoutChangingFilesIdentityOrRelatedData() async throws {
        let root = try root(), url = root.appendingPathComponent("library.sqlite")
        let repository = try SQLiteBookRepository(url: url)
        let source = root.appendingPathComponent("original.txt"), raw = Data([0xD4,0xC6,0xBA,0xA3])
        try raw.write(to: source)
        let book = Book(title: "云海", author: "作者", format: .txt, filePath: "original.txt", coverPath: "cover.png",
                        importedAt: Date(timeIntervalSince1970: 100), txtEncoding: .gbk)
        let chapter = Chapter(id: "chapter:stable", bookID: book.id, ordinal: 0, title: "第一章", startByte: 0, endByte: 6)
        let position = ReadingPosition(bookID: book.id, engineID: "readium.txt", locatorData: Data("完整位置🙂".utf8), progression: 0.42,
                                       updatedAt: Date(timeIntervalSince1970: 400.5))
        let bookmark = Bookmark(position: position, title: "章中段")
        try await repository.insert(book, chapters: [chapter]); try await repository.save(position); try await repository.add(bookmark)
        let renamed = try await repository.renameBook(book.id, title: "  云海问道🙂  ")
        var expected = book; expected.title = "云海问道🙂"
        XCTAssertEqual(renamed, expected)
        let reopened = try SQLiteBookRepository(url: url), summaries = try await reopened.books()
        let saved = try await reopened.position(for: book.id), chapters = try await reopened.chapters(for: book.id), bookmarks = try await reopened.bookmarks(for: book.id)
        XCTAssertEqual(summaries.count, 1); XCTAssertEqual(summaries.first?.book, expected)
        XCTAssertEqual(saved, position); XCTAssertEqual(chapters, [chapter]); XCTAssertEqual(bookmarks, [bookmark])
        XCTAssertEqual(summaries.first?.lastReadAt, position.updatedAt); XCTAssertEqual(summaries.first?.progression, 0.42)
        XCTAssertEqual(try Data(contentsOf: source), raw)
        let control = try SQLiteConnection(url: url)
        XCTAssertEqual(try control.query("PRAGMA user_version;") { Int(sqlite3_column_int($0, 0)) }.first, 1)
    }

    func testInvalidTitlesRejectAndUnicodeOrQuotedTitlesRemainLiteral() async throws {
        let url = try root().appendingPathComponent("library.sqlite"), repository = try SQLiteBookRepository(url: url)
        let book = Book(title: "原书名", format: .epub, filePath: "original.epub")
        try await repository.insert(book, chapters: [])
        for title in ["", " \n\t ", String(repeating: "字", count: 201), "A\0B", "A\nB", "A\u{2028}B", "A\u{7F}B"] {
            do { _ = try await repository.renameBook(book.id, title: title); XCTFail("Invalid title must fail") }
            catch { XCTAssertEqual(error as? BookEditingError, .invalidTitle) }
            let books = try await repository.books(); XCTAssertEqual(books.first?.book, book)
        }
        let unicode = String(repeating: "👨‍👩‍👧‍👦", count: 200)
        XCTAssertEqual(try BookTitle.validated(unicode), unicode)
        let quoted = "云海'; DROP TABLE books; --"
        let updated = try await repository.renameBook(book.id, title: quoted), books = try await repository.books()
        XCTAssertEqual(updated.title, quoted); XCTAssertEqual(books.count, 1); XCTAssertEqual(books.first?.book.id, book.id)
    }

    func testMissingBookDoesNotCreateRecordAndCancelledRenameDoesNotWrite() async throws {
        let repository = try SQLiteBookRepository(url: root().appendingPathComponent("library.sqlite"))
        do { _ = try await repository.renameBook(UUID(), title: "新名"); XCTFail("Missing book must reject") }
        catch { XCTAssertEqual(error as? BookEditingError, .bookNotFound) }
        let book = Book(title: "原名", format: .epub, filePath: "original.epub")
        try await repository.insert(book, chapters: [])
        let task = Task { withUnsafeCurrentTask { $0?.cancel() }; return try await repository.renameBook(book.id, title: "不能提交") }
        do { _ = try await task.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        let books = try await repository.books(); XCTAssertEqual(books.map(\.book), [book])
    }

    func testRealSQLiteWriteFailureRollsBackAndRetryKeepsRepositoryUsable() async throws {
        let url = try root().appendingPathComponent("library.sqlite"), repository = try SQLiteBookRepository(url: url)
        let book = Book(title: "原名", format: .epub, filePath: "original.epub")
        try await repository.insert(book, chapters: [])
        let control = try SQLiteConnection(url: url)
        try control.execute("CREATE TRIGGER deny_rename BEFORE UPDATE ON books BEGIN SELECT RAISE(ABORT, 'rename denied'); END;")
        do { _ = try await repository.renameBook(book.id, title: "新名"); XCTFail("DB write failure must propagate") }
        catch { XCTAssertTrue((error as? DatabaseError)?.message.contains("rename denied") == true) }
        let unchanged = try await repository.books(); XCTAssertEqual(unchanged.map(\.book), [book])
        try control.execute("DROP TRIGGER deny_rename;")
        let retry = try await repository.renameBook(book.id, title: "成功重试")
        XCTAssertEqual(retry.title, "成功重试")
    }

    func testRenameReadsLatestPayloadAcrossConnectionsRatherThanStaleBook() async throws {
        let url = try root().appendingPathComponent("library.sqlite"), first = try SQLiteBookRepository(url: url), second = try SQLiteBookRepository(url: url)
        let old = Book(title: "旧名", author: "旧作者", format: .epub, filePath: "original.epub")
        try await first.insert(old, chapters: [])
        var latest = try await second.renameBook(old.id, title: "另一连接修改")
        latest.author = "最新作者"; latest.coverPath = "latest-cover.png"
        let control = try SQLiteConnection(url: url)
        try control.run("UPDATE books SET payload = ? WHERE id = ?;", [.blob(try JSONEncoder().encode(latest)), .text(old.id.uuidString)])
        let renamed = try await first.renameBook(old.id, title: "最终书名")
        latest.title = "最终书名"; XCTAssertEqual(renamed, latest)
        let stored = try await second.books(); XCTAssertEqual(stored.first?.book, latest)
    }
}
