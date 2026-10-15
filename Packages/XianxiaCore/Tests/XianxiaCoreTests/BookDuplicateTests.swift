import CSQLite
import Foundation
import XCTest
@testable import XianxiaCore

final class BookDuplicateTests: XCTestCase {
    private func context() throws -> (URL, BookFileStore, SQLiteBookRepository) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return (root, files, repository)
    }
    private func source(_ root: URL, _ name: String = "云海", _ text: String = "第一章 山门\n正文🙂") throws -> URL {
        let url = root.appendingPathComponent(name + ".txt")
        try Data(text.utf8).write(to: url); return url
    }
    private func emptyStaging(_ files: BookFileStore) throws {
        let path = try files.resolve("Staging")
        if FileManager.default.fileExists(atPath: path.path) { XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: path.path).isEmpty) }
    }
    func testRenamedCopyPreservesUUIDCoverCompletePositionChaptersAndBookmarkAcrossReopen() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let importer = TXTBookImportService(files: files, repository: repository)
        let first = try await importer.importBook(from: url)
        _ = try await repository.renameBook(first.id, title: "我的云海")
        let cover = BookCoverOverride(assetID: UUID())
        let updated = try await repository.setCoverOverride(first.id, cover: cover)
        let position = ReadingPosition(bookID: first.id, engineID: "readium.txt", locatorData: Data("版本化完整锚点🙂".utf8), progression: 0.42)
        let bookmark = Bookmark(position: position, title: "中段")
        try await repository.save(position); try await repository.add(bookmark)
        let chapters = try await repository.chapters(for: first.id)
        let copy = root.appendingPathComponent("另一个名字.TXT"); try FileManager.default.copyItem(at: url, to: copy)
        let reopened = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let result = try await TXTBookImportService(files: files, repository: reopened).importBookWithEncoding(from: copy, encoding: .utf8)
        XCTAssertEqual(result.book, updated); XCTAssertEqual(result.duplicate?.book.id, first.id)
        XCTAssertEqual(result.duplicate?.isRemoved, false)
        let books = try await reopened.books(), saved = try await reopened.position(for: first.id)
        let marks = try await reopened.bookmarks(for: first.id), toc = try await reopened.chapters(for: first.id)
        XCTAssertEqual(books.count, 1); XCTAssertEqual(saved, position); XCTAssertEqual(marks, [bookmark]); XCTAssertEqual(toc, chapters)
        XCTAssertEqual(try Data(contentsOf: files.resolve(first.filePath)), Data(contentsOf: url))
        try emptyStaging(files)
    }
    func testTrashDuplicateRequiresExplicitRestoreAndRecoveryPreservesOriginal() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let importer = TXTBookImportService(files: files, repository: repository), first = try await importer.importBook(from: url)
        try await repository.moveToTrash(first.id)
        let duplicate = try await importer.importBookWithEncoding(from: url)
        XCTAssertEqual(duplicate.duplicate?.isRemoved, true); XCTAssertEqual(duplicate.book.id, first.id)
        let snapshot = try await repository.librarySnapshot(); XCTAssertTrue(snapshot.books.isEmpty); XCTAssertEqual(snapshot.removedBooks.count, 1)
        let knownIDs = try await repository.allBookIDs(); try await files.recoverImports(knownBookIDs: knownIDs)
        XCTAssertTrue(FileManager.default.fileExists(atPath: try files.resolve(first.filePath).path))
        try await repository.restoreBook(first.id)
        let restored = try await repository.books(); XCTAssertEqual(restored.map(\.id), [first.id]); try emptyStaging(files)
    }
    func testSameTitleDifferentBytesAndDifferentTXTInterpretationsRemainIndependent() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let importer = TXTBookImportService(files: files, repository: repository), first = try await importer.importBook(from: url)
        _ = try source(root, "云海", "第一章 山门\n不同的版本")
        let changed = try await importer.importBookWithEncoding(from: url)
        XCTAssertNil(changed.duplicate); XCTAssertNotEqual(first.id, changed.book.id)
        // UTF-8 and Windows-1252 both decode these original bytes strictly, but yield different text.
        let variant = try await importer.importBookWithEncoding(from: url, encoding: .windows1252)
        XCTAssertNil(variant.duplicate); XCTAssertNotEqual(variant.book.id, changed.book.id)
        let again = try await importer.importBookWithEncoding(from: url, encoding: .windows1252)
        XCTAssertEqual(again.book.id, variant.book.id); XCTAssertNotNil(again.duplicate)
        let books = try await repository.books(); XCTAssertEqual(books.count, 3)
    }
    func testConcurrentImportersAcrossRealConnectionsCommitOneBookAndCleanLoser() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let other = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let a = TXTBookImportService(files: files, repository: repository), b = TXTBookImportService(files: files, repository: other)
        async let left = a.importBookWithEncoding(from: url)
        async let right = b.importBookWithEncoding(from: url)
        let pair = try await [left, right]
        XCTAssertEqual(pair[0].book.id, pair[1].book.id); XCTAssertEqual(pair.filter { $0.duplicate == nil }.count, 1)
        let books = try await repository.books(); XCTAssertEqual(books.count, 1)
        let dirs = try FileManager.default.contentsOfDirectory(atPath: files.resolve("Books").path)
        XCTAssertEqual(dirs.count, 1); try emptyStaging(files)
    }
    func testLegacyDuplicatesAreIndexedWithoutMergingPreferActiveAndPreserveAllIDs() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        var legacy: [Book] = []
        for _ in 0..<2 {
            let staged = try await files.stageTXT(from: url), paths = try await files.finalize(staged, coverData: nil)
            let book = Book(id: staged.id, title: "旧云海", format: .txt, filePath: paths.filePath)
            try await repository.insert(book, chapters: []); legacy.append(book)
        }
        try await repository.moveToTrash(legacy[0].id)
        let result = try await TXTBookImportService(files: files, repository: repository).importBookWithEncoding(from: url)
        XCTAssertEqual(result.book.id, legacy[1].id); XCTAssertEqual(result.duplicate?.isRemoved, false)
        let records = try await repository.importRecords(), ids = try await repository.allBookIDs()
        XCTAssertEqual(ids, Set(legacy.map(\.id))); XCTAssertTrue(records.allSatisfy { $0.identity?.normalizedSHA256 != nil })
        try await files.recoverImports(knownBookIDs: ids)
        for book in legacy { XCTAssertTrue(FileManager.default.fileExists(atPath: try files.resolve(book.filePath).path)) }
    }
    func testMissingLegacyOriginalWarnsButDoesNotBlockUnrelatedImport() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let missing = Book(title: "原件缺失的旧书", format: .txt, filePath: "Books/missing/book.txt")
        try await repository.insert(missing, chapters: [])
        let result = try await TXTBookImportService(files: files, repository: repository).importBookWithEncoding(from: url)
        XCTAssertNil(result.duplicate); XCTAssertEqual(result.warnings.count, 1); XCTAssertTrue(result.warnings[0].contains(missing.title))
        let ids = try await repository.allBookIDs(); XCTAssertEqual(ids.count, 2)
    }
    func testCorruptOrMissingKnownOriginalRejectsWithoutFalseDuplicateSuccess() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let importer = TXTBookImportService(files: files, repository: repository), book = try await importer.importBook(from: url)
        let original = try files.resolve(book.filePath)
        try Data("损坏的内容".utf8).write(to: original)
        do { _ = try await importer.importBook(from: url); XCTFail("Must verify matching original") }
        catch { XCTAssertTrue(error is BookDuplicateError) }
        try FileManager.default.removeItem(at: original)
        do { _ = try await importer.importBook(from: url); XCTFail("Must reject missing known original") }
        catch { XCTAssertTrue(error is BookDuplicateError) }
        let ids = try await repository.allBookIDs(); XCTAssertEqual(ids, [book.id]); try emptyStaging(files)
    }
    func testIdentityWriteFailureRollsBackBookAndFinalizedFilesThenRetries() async throws {
        let (root, files, repository) = try context(), url = try source(root)
        let control = try SQLiteConnection(url: root.appendingPathComponent("library.sqlite"))
        try control.execute("CREATE TRIGGER deny_identity BEFORE INSERT ON book_import_identities BEGIN SELECT RAISE(ABORT, 'identity denied'); END;")
        let importer = TXTBookImportService(files: files, repository: repository)
        do { _ = try await importer.importBook(from: url); XCTFail("Write must fail") }
        catch { XCTAssertTrue(error.localizedDescription.contains("identity denied")) }
        let ids = try await repository.allBookIDs(); XCTAssertTrue(ids.isEmpty)
        for prefix in ["Books", "Cache/TXT"] {
            let path = try files.resolve(prefix)
            if FileManager.default.fileExists(atPath: path.path) { XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: path.path).isEmpty) }
        }
        try control.execute("DROP TRIGGER deny_identity;")
        _ = try await importer.importBook(from: url); let books = try await repository.books(); XCTAssertEqual(books.count, 1)
    }
    func testV2MigrationPreservesTrashPayloadAndPositionAndRetriesInterruptedDDL() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("library.sqlite")
        let book = Book(title: "升级保留", format: .txt, filePath: "Books/legacy/book.txt", coverOverride: BookCoverOverride(assetID: UUID()))
        let position = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([0,42,255]), progression: 0.42)
        func hex<T: Encodable>(_ v: T) throws -> String { try JSONEncoder().encode(v).map { String(format: "%02x", $0) }.joined() }
        do {
            var db: OpaquePointer?; XCTAssertEqual(sqlite3_open(url.path, &db), SQLITE_OK); defer { sqlite3_close(db) }
            let sql = try SQLiteConnection.migration("001_initial") + SQLiteConnection.migration("002_removed_books") +
                "INSERT INTO books VALUES ('\(book.id)', X'\(hex(book))', 100); INSERT INTO removed_books VALUES ('\(book.id)', 200);" +
                "INSERT INTO reading_positions VALUES ('\(book.id)', 0.42, 400, X'\(hex(position))');"
            XCTAssertEqual(sqlite3_exec(db, sql, nil, nil, nil), SQLITE_OK)
            let interrupted = try SQLiteConnection.migration("003_import_identities").replacingOccurrences(of: "COMMIT;", with: "")
            XCTAssertEqual(sqlite3_exec(db, interrupted, nil, nil, nil), SQLITE_OK)
        }
        for _ in 0..<2 {
            let repository = try SQLiteBookRepository(url: url), snapshot = try await repository.librarySnapshot(), saved = try await repository.position(for: book.id)
            XCTAssertEqual(snapshot.removedBooks.map(\.book), [book]); XCTAssertEqual(saved, position)
            let records = try await repository.importRecords(); XCTAssertEqual(records.count, 1); XCTAssertNil(records[0].identity)
        }
        let control = try SQLiteConnection(url: url)
        XCTAssertEqual(try control.query("PRAGMA user_version;") { sqlite3_column_int($0, 0) }, [3])
        XCTAssertEqual(try control.query("PRAGMA integrity_check;") { String(cString: sqlite3_column_text($0, 0)) }, ["ok"])
    }
    func testV3MigrationFailurePreservesV2AndRetriesAfterExplicitFixtureFaultRemoval() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("library.sqlite")
        var db: OpaquePointer?; XCTAssertEqual(sqlite3_open(url.path, &db), SQLITE_OK); defer { sqlite3_close(db) }
        let legacy = try SQLiteConnection.migration("001_initial") + SQLiteConnection.migration("002_removed_books")
        XCTAssertEqual(sqlite3_exec(db, legacy, nil, nil, nil), SQLITE_OK)
        XCTAssertEqual(sqlite3_exec(db, "CREATE TABLE book_import_identities(marker TEXT); INSERT INTO book_import_identities VALUES ('keep');", nil, nil, nil), SQLITE_OK)
        for _ in 0..<2 { XCTAssertThrowsError(try SQLiteBookRepository(url: url)) }
        var statement: OpaquePointer?
        XCTAssertEqual(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &statement, nil), SQLITE_OK)
        XCTAssertEqual(sqlite3_step(statement), SQLITE_ROW); XCTAssertEqual(sqlite3_column_int(statement, 0), 2); sqlite3_finalize(statement)
        // Only remove the deliberately injected test fault, never production data.
        XCTAssertEqual(sqlite3_exec(db, "DROP TABLE book_import_identities;", nil, nil, nil), SQLITE_OK)
        _ = try SQLiteBookRepository(url: url)
    }
}
