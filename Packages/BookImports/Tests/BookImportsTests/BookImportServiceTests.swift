import BookImports
import Foundation
import SQLite3
import XCTest
import XianxiaCore

private enum ImportFixtureError: Error, LocalizedError, Equatable {
    case metadata, database
    var errorDescription: String? { self == .metadata ? "metadata denied" : "fixture SQL failed" }
}

private actor MetadataFixture: EPUBMetadataReading {
    typealias Operation = @Sendable (URL, UUID) async throws -> ImportedPublication
    private let operation: Operation
    private var ids: [UUID] = []
    init(_ operation: @escaping Operation) { self.operation = operation }
    func readMetadata(at url: URL, bookID: UUID) async throws -> ImportedPublication {
        ids.append(bookID)
        return try await operation(url, bookID)
    }
    func requests() -> [UUID] { ids }
}

final class BookImportServiceTests: XCTestCase {
    // Keep SQLite handles and their tiny roots together until worker exit, as in
    // the native import fixtures. No teardown removes files under a live actor.
    @MainActor private static var repositories: [SQLiteBookRepository] = []
    private struct Context: Sendable {
        let root: URL
        let repository: SQLiteBookRepository
        let files: BookFileStore
        func source(_ name: String = "original.EPUB", bytes: Data = Data("original publication bytes".utf8)) throws -> URL {
            let url = root.appendingPathComponent(name); try bytes.write(to: url); return url
        }
    }
    @MainActor private func context() throws -> Context {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("BookImportContracts-\(UUID().uuidString)")
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        Self.repositories.append(repository)
        return Context(root: root, repository: repository, files: files)
    }
    private func metadata() -> MetadataFixture {
        MetadataFixture { url, id in
            guard FileManager.default.fileExists(atPath: url.path) else { throw ImportFixtureError.metadata }
            return ImportedPublication(title: "", author: "作者", coverData: Data([1, 2, 3]),
                                       chapters: [Chapter(id: "one", bookID: id, ordinal: 0, title: "第一章", href: "one.xhtml")], warnings: ["fixture warning"])
        }
    }
    private func assertNoStaging(_ files: BookFileStore, file: StaticString = #filePath, line: UInt = #line) throws {
        let staging = try files.resolve("Staging")
        if FileManager.default.fileExists(atPath: staging.path) {
            XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: staging.path).isEmpty, file: file, line: line)
        }
    }
    private func executeSQL(_ sql: String, at url: URL) throws {
        var db: OpaquePointer?
        guard sqlite3_open(url.path, &db) == SQLITE_OK else { throw ImportFixtureError.database }
        defer { sqlite3_close(db) }
        guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else { throw ImportFixtureError.database }
    }

    @MainActor func testInvalidAndNonFileInputsNeverReachMetadataOrStorage() async throws {
        let c = try context(), reader = metadata()
        let service = EPUBImportService(repository: c.repository, files: c.files, metadata: reader)
        for source in [try c.source("bad.pdf"), try XCTUnwrap(URL(string: "https://example.com/book.epub"))] {
            do { _ = try await service.importBook(from: source); XCTFail("Must reject input") }
            catch { guard case ImportError.unsupportedFile = error else { throw error } }
        }
        let requests = await reader.requests(), books = try await c.repository.books()
        XCTAssertTrue(requests.isEmpty); XCTAssertTrue(books.isEmpty); try assertNoStaging(c.files)
    }

    @MainActor func testEPUBCommitKeepsOriginalFallbackCoverChaptersAndWarnings() async throws {
        let c = try context(), reader = metadata(), source = try c.source()
        let original = try Data(contentsOf: source)
        let service = EPUBImportService(repository: c.repository, files: c.files, metadata: reader)
        let result = try await service.importBook(from: source)
        XCTAssertEqual(result.book.title, "original"); XCTAssertEqual(result.book.author, "作者")
        XCTAssertEqual(result.warnings, ["fixture warning"]); XCTAssertNil(result.duplicate)
        XCTAssertEqual(try Data(contentsOf: c.files.resolve(result.book.filePath)), original)
        XCTAssertEqual(try Data(contentsOf: source), original)
        XCTAssertEqual(try Data(contentsOf: c.files.resolve(XCTUnwrap(result.book.coverPath))), Data([1, 2, 3]))
        let chapters = try await c.repository.chapters(for: result.book.id)
        XCTAssertEqual(chapters.first?.bookID, result.book.id); XCTAssertEqual(chapters.first?.href, "one.xhtml")
        try assertNoStaging(c.files)
    }

    @MainActor func testTXTUsesExistingNormalizerWithoutCallingEPUBMetadata() async throws {
        let c = try context(), reader = metadata(), source = try c.source("中文.txt", bytes: Data("第一章 山门\n正文🙂\n第二章 江湖\n灯火".utf8))
        let result = try await EPUBImportService(repository: c.repository, files: c.files, metadata: reader).importBook(from: source)
        let requests = await reader.requests(), chapters = try await c.repository.chapters(for: result.book.id)
        XCTAssertTrue(requests.isEmpty); XCTAssertEqual(result.book.format, .txt); XCTAssertEqual(result.detectedTXTEncoding, .utf8)
        XCTAssertEqual(chapters.count, 2); try assertNoStaging(c.files)
    }

    @MainActor func testPreflightDuplicatePreservesRemovedBookAndCompleteHistory() async throws {
        let c = try context(), reader = metadata(), source = try c.source()
        let service = EPUBImportService(repository: c.repository, files: c.files, metadata: reader)
        let original = try await service.importBook(from: source)
        let position = ReadingPosition(bookID: original.book.id, engineID: "fixture", locatorData: Data([4, 2, 7]), progression: 0.42)
        let bookmark = Bookmark(position: position, title: "中段")
        try await c.repository.save(position); try await c.repository.add(bookmark)
        _ = try await c.repository.renameBook(original.book.id, title: "自定义书名")
        try await c.repository.moveToTrash(original.book.id)
        let again = try await service.importBook(from: source)
        XCTAssertEqual(again.duplicate?.id, original.book.id); XCTAssertEqual(again.duplicate?.isRemoved, true)
        XCTAssertEqual(again.book.title, "自定义书名")
        let requests = await reader.requests(), saved = try await c.repository.position(for: original.book.id)
        let bookmarks = try await c.repository.bookmarks(for: original.book.id)
        XCTAssertEqual(requests.count, 1); XCTAssertEqual(saved, position); XCTAssertEqual(bookmarks, [bookmark])
        try assertNoStaging(c.files)
    }

    @MainActor func testMetadataFailureRollsBackStagedFilesAndPreservesSource() async throws {
        let c = try context(), source = try c.source()
        let reader = MetadataFixture { _, _ in throw ImportFixtureError.metadata }
        do { _ = try await EPUBImportService(repository: c.repository, files: c.files, metadata: reader).importBook(from: source); XCTFail("Must fail") }
        catch { guard case ImportFixtureError.metadata = error else { throw error } }
        let books = try await c.repository.books(); XCTAssertTrue(books.isEmpty)
        XCTAssertTrue(FileManager.default.fileExists(atPath: source.path)); try assertNoStaging(c.files)
    }

    @MainActor func testCancellationAfterMetadataCannotFinalizeOrCommit() async throws {
        let c = try context(), source = try c.source()
        let reader = MetadataFixture { _, _ in
            withUnsafeCurrentTask { $0?.cancel() }
            return ImportedPublication(title: "取消", author: "", coverData: nil, chapters: [])
        }
        let service = EPUBImportService(repository: c.repository, files: c.files, metadata: reader)
        let task = Task { try await service.importBook(from: source) }
        do { _ = try await task.value; XCTFail("Must cancel") }
        catch { XCTAssertTrue(error is CancellationError) }
        let books = try await c.repository.books(), ids = await reader.requests()
        XCTAssertEqual(ids.count, 1); XCTAssertTrue(books.isEmpty); try assertNoStaging(c.files)
        for id in ids { XCTAssertFalse(FileManager.default.fileExists(atPath: try c.files.resolve("Books/\(id.uuidString)").path)) }
    }

    @MainActor func testDatabaseFailureRollsBackFinalizedFilesAndKeepsExistingBook() async throws {
        let c = try context(), reader = metadata(), source = try c.source()
        let service = EPUBImportService(repository: c.repository, files: c.files, metadata: reader)
        let original = try await service.importBook(from: source)
        try executeSQL("CREATE TRIGGER deny_import BEFORE INSERT ON books BEGIN SELECT RAISE(ABORT,'import denied'); END;", at: c.root.appendingPathComponent("library.sqlite"))
        let other = try c.source("different.epub", bytes: Data("different bytes".utf8))
        do { _ = try await service.importBook(from: other); XCTFail("Must fail") }
        catch { XCTAssertTrue(error.localizedDescription.contains("import denied")) }
        let books = try await c.repository.books(), ids = await reader.requests()
        XCTAssertEqual(books.map(\.id), [original.book.id]); XCTAssertEqual(ids.count, 2)
        for id in ids where id != original.book.id { XCTAssertFalse(FileManager.default.fileExists(atPath: try c.files.resolve("Books/\(id.uuidString)").path)) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: try c.files.resolve(original.book.filePath).path))
        try assertNoStaging(c.files)
    }

    @MainActor func testCleanupFailureReportsOriginalErrorWithoutFollowingManagedSymlink() async throws {
        let c = try context(), source = try c.source(), external = c.root.appendingPathComponent("External")
        try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
        let marker = external.appendingPathComponent("keep"); try Data([8, 9]).write(to: marker)
        let reader = MetadataFixture { _, _ in
            try FileManager.default.createSymbolicLink(at: c.files.root.appendingPathComponent("Books"), withDestinationURL: external)
            throw ImportFixtureError.metadata
        }
        do { _ = try await EPUBImportService(repository: c.repository, files: c.files, metadata: reader).importBook(from: source); XCTFail("Must report cleanup failure") }
        catch {
            guard case ImportError.cleanupFailed(let original, let cleanup) = error else { throw error }
            XCTAssertEqual(original, "metadata denied"); XCTAssertEqual(cleanup, StorageError.unsafePath.localizedDescription)
        }
        XCTAssertEqual(try Data(contentsOf: marker), Data([8, 9])); try assertNoStaging(c.files)
        let books = try await c.repository.books(); XCTAssertTrue(books.isEmpty)
    }
}
