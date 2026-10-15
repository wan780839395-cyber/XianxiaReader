import CSQLite
import Foundation
import XCTest
@testable import XianxiaCore

final class BookRemovalTests: XCTestCase {
    private func root() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return root
    }

    private func raw(_ url: URL, _ body: (OpaquePointer) throws -> Void) throws {
        var handle: OpaquePointer?
        guard sqlite3_open(url.path, &handle) == SQLITE_OK, let handle else { throw DatabaseError(message: "Fixture open failed") }
        defer { sqlite3_close(handle) }
        try body(handle)
    }

    private func execute(_ handle: OpaquePointer, _ sql: String) throws {
        guard sqlite3_exec(handle, sql, nil, nil, nil) == SQLITE_OK else { throw DatabaseError(message: String(cString: sqlite3_errmsg(handle))) }
    }

    private func makeLegacy(_ url: URL, book: Book, position: ReadingPosition, chapter: Chapter, bookmark: Bookmark) throws {
        func hex<T: Encodable>(_ value: T) throws -> String { try JSONEncoder().encode(value).map { String(format: "%02x", $0) }.joined() }
        try raw(url) { handle in
            try execute(handle, SQLiteConnection.migration("001_initial"))
            try execute(handle, "INSERT INTO books VALUES ('\(book.id.uuidString)', X'\(hex(book))', 100);")
            try execute(handle, "INSERT INTO chapters VALUES ('\(chapter.id)', '\(book.id.uuidString)', 0, X'\(hex(chapter))');")
            try execute(handle, "INSERT INTO reading_positions VALUES ('\(book.id.uuidString)', 0.42, 400, X'\(hex(position))');")
            try execute(handle, "INSERT INTO bookmarks VALUES ('\(bookmark.id.uuidString)', '\(book.id.uuidString)', 400, X'\(hex(bookmark))');")
        }
    }

    func testRealV1MigrationPreservesPayloadsAndRelatedRecordsOnRepeatedReopen() async throws {
        let url = try root().appendingPathComponent("library.sqlite")
        let book = Book(title: "升级前的云海", format: .txt, filePath: "Books/legacy/book.txt", txtEncoding: .gbk)
        let chapter = Chapter(id: "legacy-chapter", bookID: book.id, ordinal: 0, title: "第一章", startByte: 0, endByte: 600)
        let position = ReadingPosition(bookID: book.id, engineID: "readium.txt", locatorData: Data([0,1,2,255]), progression: 0.42)
        let bookmark = Bookmark(position: position, title: "章中段")
        try makeLegacy(url, book: book, position: position, chapter: chapter, bookmark: bookmark)
        for _ in 0..<3 {
            let repository = try SQLiteBookRepository(url: url)
            let snapshot = try await repository.librarySnapshot(), ids = try await repository.allBookIDs()
            let saved = try await repository.position(for: book.id), chapters = try await repository.chapters(for: book.id)
            let bookmarks = try await repository.bookmarks(for: book.id)
            XCTAssertEqual(snapshot.books.map(\.book), [book]); XCTAssertTrue(snapshot.removedBooks.isEmpty)
            XCTAssertEqual(ids, [book.id]); XCTAssertEqual(saved, position); XCTAssertEqual(chapters, [chapter]); XCTAssertEqual(bookmarks, [bookmark])
        }
        let control = try SQLiteConnection(url: url)
        XCTAssertEqual(try control.query("PRAGMA user_version;") { sqlite3_column_int($0, 0) }, [2])
        XCTAssertEqual(try control.query("PRAGMA integrity_check;") { String(cString: sqlite3_column_text($0, 0)) }, ["ok"])
    }

    func testUncommittedMigrationRollsBackOnConnectionCloseAndRetries() async throws {
        let url = try root().appendingPathComponent("library.sqlite")
        try raw(url) { handle in
            try execute(handle, SQLiteConnection.migration("001_initial"))
            // Simulate interruption after every migration statement except COMMIT.
            let pending = try SQLiteConnection.migration("002_removed_books").replacingOccurrences(of: "COMMIT;", with: "")
            try execute(handle, pending)
        }
        // Closing the actual SQLite connection rolls back uncommitted DDL/version.
        try raw(url) { handle in
            var statement: OpaquePointer?
            XCTAssertEqual(sqlite3_prepare_v2(handle, "PRAGMA user_version;", -1, &statement, nil), SQLITE_OK)
            defer { sqlite3_finalize(statement) }
            XCTAssertEqual(sqlite3_step(statement), SQLITE_ROW); XCTAssertEqual(sqlite3_column_int(statement, 0), 1)
        }
        let repository = try SQLiteBookRepository(url: url), book = Book(title: "恢复升级", format: .epub, filePath: "original.epub")
        try await repository.insert(book, chapters: []); try await repository.moveToTrash(book.id)
        let snapshot = try await repository.librarySnapshot(); XCTAssertEqual(snapshot.removedBooks.map(\.book), [book])
    }

    func testFailedMigrationLeavesV1DataAndAllowsExplicitRetryAfterFaultRemoved() async throws {
        let url = try root().appendingPathComponent("library.sqlite")
        let book = Book(title: "失败升级仍保留的书", format: .epub, filePath: "original.epub")
        let position = ReadingPosition(bookID: book.id, engineID: "readium", locatorData: Data([4,2]), progression: 0.42)
        let chapter = Chapter(id: "retained-chapter", bookID: book.id, ordinal: 0, title: "第一章")
        let bookmark = Bookmark(position: position, title: "保留")
        try makeLegacy(url, book: book, position: position, chapter: chapter, bookmark: bookmark)
        try raw(url) { handle in
            try execute(handle, "CREATE TABLE removed_books(fault TEXT); INSERT INTO removed_books VALUES ('preserved');")
        }
        for _ in 0..<2 { XCTAssertThrowsError(try SQLiteBookRepository(url: url)) }
        try raw(url) { handle in
            do {
                var statement: OpaquePointer?
                XCTAssertEqual(sqlite3_prepare_v2(handle, "PRAGMA user_version;", -1, &statement, nil), SQLITE_OK)
                defer { sqlite3_finalize(statement) }
                XCTAssertEqual(sqlite3_step(statement), SQLITE_ROW); XCTAssertEqual(sqlite3_column_int(statement, 0), 1)
            }
            do {
                var statement: OpaquePointer?
                XCTAssertEqual(sqlite3_prepare_v2(handle, "SELECT fault FROM removed_books;", -1, &statement, nil), SQLITE_OK)
                defer { sqlite3_finalize(statement) }
                XCTAssertEqual(sqlite3_step(statement), SQLITE_ROW)
                XCTAssertEqual(String(cString: try XCTUnwrap(sqlite3_column_text(statement, 0))), "preserved")
            }
            // Remove only this deliberately injected fixture fault, never a product recovery strategy.
            try execute(handle, "DROP TABLE removed_books;")
        }
        let repository = try SQLiteBookRepository(url: url), snapshot = try await repository.librarySnapshot()
        XCTAssertEqual(snapshot.books.map(\.book), [book]); XCTAssertTrue(snapshot.removedBooks.isEmpty)
        let saved = try await repository.position(for: book.id), chapters = try await repository.chapters(for: book.id), marks = try await repository.bookmarks(for: book.id)
        XCTAssertEqual(saved, position); XCTAssertEqual(chapters, [chapter]); XCTAssertEqual(marks, [bookmark])
    }

    func testRemovedOriginalCacheAndCompletePositionSurviveStartupRecoveryAndRestore() async throws {
        let root = try root(), files = try BookFileStore(root: root.appendingPathComponent("Storage")), url = root.appendingPathComponent("library.sqlite")
        let repository = try SQLiteBookRepository(url: url), source = root.appendingPathComponent("云海.txt")
        let bytes = Data("第一章 山门\n正文🙂\n第二章 江湖\n灯火仍在".utf8); try bytes.write(to: source)
        let importer = TXTBookImportService(files: files, repository: repository), book = try await importer.importBook(from: source)
        let chapters = try await repository.chapters(for: book.id)
        let position = ReadingPosition(bookID: book.id, engineID: "readium.txt", locatorData: Data("完整章中段锚点🙂".utf8), progression: 0.42)
        let bookmark = Bookmark(position: position, title: "中段")
        try await repository.save(position); try await repository.add(bookmark)
        try await repository.moveToTrash(book.id)
        let reopened = try SQLiteBookRepository(url: url), knownIDs = try await reopened.allBookIDs()
        try await files.recoverImports(knownBookIDs: knownIDs)
        let removed = try await reopened.librarySnapshot()
        XCTAssertTrue(removed.books.isEmpty); XCTAssertEqual(removed.removedBooks.map(\.book), [book])
        XCTAssertEqual(try Data(contentsOf: files.resolve(book.filePath)), bytes)
        let cache = try files.resolve("Cache/TXT/\(book.id.uuidString.lowercased())")
        XCTAssertTrue(FileManager.default.fileExists(atPath: cache.path))
        try await reopened.restoreBook(book.id)
        let final = try await reopened.librarySnapshot(), saved = try await reopened.position(for: book.id)
        let finalChapters = try await reopened.chapters(for: book.id), bookmarks = try await reopened.bookmarks(for: book.id)
        XCTAssertEqual(final.books.map(\.book), [book]); XCTAssertTrue(final.removedBooks.isEmpty)
        XCTAssertEqual(saved, position); XCTAssertEqual(finalChapters, chapters); XCTAssertEqual(bookmarks, [bookmark])
    }

    func testRemoveAndRestoreFailuresRollBackIdempotentlyWithoutAffectingOtherBooks() async throws {
        let url = try root().appendingPathComponent("library.sqlite"), repository = try SQLiteBookRepository(url: url), control = try SQLiteConnection(url: url)
        let a = Book(title: "同名", format: .epub, filePath: "a.epub"), b = Book(title: "同名", format: .txt, filePath: "b.txt")
        try await repository.insert(a, chapters: []); try await repository.insert(b, chapters: [])
        try control.execute("CREATE TRIGGER deny_remove BEFORE INSERT ON removed_books BEGIN SELECT RAISE(ABORT, 'remove denied'); END;")
        do { try await repository.moveToTrash(a.id); XCTFail("Write failure must propagate") }
        catch { XCTAssertTrue((error as? DatabaseError)?.message.contains("remove denied") == true) }
        let failed = try await repository.librarySnapshot(); XCTAssertEqual(failed.books.count, 2); XCTAssertTrue(failed.removedBooks.isEmpty)
        try control.execute("DROP TRIGGER deny_remove;")
        try await repository.moveToTrash(a.id); try await repository.moveToTrash(a.id)
        try control.execute("CREATE TRIGGER deny_restore BEFORE DELETE ON removed_books BEGIN SELECT RAISE(ABORT, 'restore denied'); END;")
        do { try await repository.restoreBook(a.id); XCTFail("Restore failure must propagate") }
        catch { XCTAssertTrue((error as? DatabaseError)?.message.contains("restore denied") == true) }
        let retained = try await repository.librarySnapshot(); XCTAssertEqual(retained.books.map(\.book), [b]); XCTAssertEqual(retained.removedBooks.map(\.book), [a])
        try control.execute("DROP TRIGGER deny_restore;")
        try await repository.restoreBook(a.id); try await repository.restoreBook(a.id)
        let final = try await repository.librarySnapshot(); XCTAssertEqual(Set(final.books.map(\.id)), [a.id,b.id]); XCTAssertTrue(final.removedBooks.isEmpty)
    }

    func testMissingAndCancelledMutationsRejectWithoutChangingStateAcrossConnections() async throws {
        let url = try root().appendingPathComponent("library.sqlite"), first = try SQLiteBookRepository(url: url), second = try SQLiteBookRepository(url: url)
        let book = Book(title: "保留", format: .epub, filePath: "original.epub")
        try await first.insert(book, chapters: [])
        do { try await first.moveToTrash(UUID()); XCTFail("Missing book must reject") } catch { XCTAssertEqual(error as? BookEditingError, .bookNotFound) }
        do { try await first.restoreBook(UUID()); XCTFail("Missing book must reject") } catch { XCTAssertEqual(error as? BookEditingError, .bookNotFound) }
        let cancelled = Task { withUnsafeCurrentTask { $0?.cancel() }; try await first.moveToTrash(book.id) }
        do { try await cancelled.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        let active = try await second.books(); XCTAssertEqual(active.map(\.book), [book])
        try await first.moveToTrash(book.id)
        let snapshot = try await second.librarySnapshot(); XCTAssertEqual(snapshot.removedBooks.map(\.book), [book]); XCTAssertTrue(snapshot.books.isEmpty)
        let cancelledRestore = Task { withUnsafeCurrentTask { $0?.cancel() }; try await second.restoreBook(book.id) }
        do { try await cancelledRestore.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        try await second.restoreBook(book.id)
        let restored = try await first.books(); XCTAssertEqual(restored.map(\.book), [book])
    }
}
