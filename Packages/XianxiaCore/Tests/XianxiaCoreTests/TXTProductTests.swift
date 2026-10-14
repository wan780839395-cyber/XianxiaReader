import Foundation
import XCTest
@testable import XianxiaCore

final class TXTProductTests: XCTestCase {
    private struct FailedRepository: BookRepository {
        struct WriteFailure: Error {}
        let actual: SQLiteBookRepository
        func books() async throws -> [BookSummary] { try await actual.books() }
        func insert(_ book: Book, chapters: [Chapter]) async throws { throw WriteFailure() }
        func position(for id: UUID) async throws -> ReadingPosition? { try await actual.position(for: id) }
        func save(_ value: ReadingPosition) async throws { try await actual.save(value) }
        func chapters(for id: UUID) async throws -> [Chapter] { try await actual.chapters(for: id) }
        func bookmarks(for id: UUID) async throws -> [Bookmark] { try await actual.bookmarks(for: id) }
        func add(_ value: Bookmark) async throws { try await actual.add(value) }
        func removeBookmark(_ id: UUID) async throws { try await actual.removeBookmark(id) }
    }
    private func context() throws -> (URL, BookFileStore, SQLiteBookRepository) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return (root,files,repository)
    }
    func testTXTImportPersistsOriginalEncodingTOCAndCacheAcrossRestart() async throws {
        let (root,files,repository) = try context(), source = root.appendingPathComponent("江湖.TXT")
        let text = "第一卷 山门\r\n第一章 云海\r\n正文🙂\r\n第二章 问道\r\n山门的灯火仍在"
        let bytes = try XCTUnwrap(text.data(using: .utf16BigEndian)); try bytes.write(to: source)
        let book = try await TXTBookImportService(files: files, repository: repository).importBook(from: source, encoding: .utf16BigEndian)
        XCTAssertEqual(book.format,.txt); XCTAssertEqual(book.txtEncoding,.utf16BigEndian)
        XCTAssertEqual(book.title,"江湖"); XCTAssertTrue(book.filePath.hasSuffix("book.txt"))
        XCTAssertEqual(try Data(contentsOf: files.resolve(book.filePath)),bytes)
        let reopened = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let books = try await reopened.books(), chapters = try await reopened.chapters(for: book.id)
        XCTAssertEqual(books.map(\.book),[book]); XCTAssertEqual(chapters.map(\.title),["第一卷 山门","第一章 云海","第二章 问道"])
        try await files.recoverImports(knownBookIDs: [book.id])
        let cache = try TXTIndexCache(storageRoot: files.root)
        let index = try await cache.prepare(source: files.resolve(book.filePath),bookID: book.id,encoding: .utf16BigEndian)
        XCTAssertTrue(index.reusedCache); XCTAssertEqual(index.chapters,chapters)
        XCTAssertEqual(try Data(contentsOf: source),bytes)
    }
    func testFailedEncodingImportLeavesNoBookOrPublishedCacheAndAllowsRetry() async throws {
        let (root,files,repository) = try context(), source = root.appendingPathComponent("gb.txt")
        let bytes = Data([0x63,0x61,0x66,0xE9]); try bytes.write(to: source)
        let importer = TXTBookImportService(files: files,repository: repository)
        do { _ = try await importer.importBook(from: source); XCTFail("Encoding choice required") }
        catch { XCTAssertEqual(error as? TXTNormalizationError,.encodingChoiceRequired) }
        let books = try await repository.books(); XCTAssertTrue(books.isEmpty)
        for prefix in ["Staging","Books","Cache/TXT"] {
            let url = try files.resolve(prefix)
            if FileManager.default.fileExists(atPath: url.path) { XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: url.path).isEmpty) }
        }
        let book = try await importer.importBook(from: source,encoding: .windows1252)
        XCTAssertEqual(book.txtEncoding,.windows1252); XCTAssertEqual(try Data(contentsOf: source),bytes)
    }
    func testTXTInterruptedFinalizedOriginalAndCacheRecoveredCommittedBookPreserved() async throws {
        let (root,files,repository) = try context(), source = root.appendingPathComponent("test.txt")
        try Data("第一章 测试\n正文".utf8).write(to: source)
        let committed = try await TXTBookImportService(files: files,repository: repository).importBook(from: source)
        let orphan = try await files.stageTXT(from: source), cache = try TXTIndexCache(storageRoot: files.root)
        _ = try await cache.prepare(source: orphan.fileURL,bookID: orphan.id)
        _ = try await files.finalize(orphan,coverData: nil)
        try await files.recoverImports(knownBookIDs: [committed.id])
        XCTAssertTrue(FileManager.default.fileExists(atPath: try files.resolve(committed.filePath).path))
        for prefix in ["Books","Cache/TXT"] {
            let key = prefix == "Cache/TXT" ? orphan.id.uuidString.lowercased() : orphan.id.uuidString
            XCTAssertFalse(FileManager.default.fileExists(atPath: try files.resolve("\(prefix)/\(key)").path))
        }
        let retained = try await cache.prepare(source: files.resolve(committed.filePath),bookID: committed.id)
        XCTAssertTrue(retained.reusedCache)
    }
    func testTXTImportCancellationBeforeCopyDoesNotWriteBook() async throws {
        let (root,files,repository) = try context(), source = root.appendingPathComponent("cancel.txt")
        let bytes = Data("第一章 取消\n原书".utf8); try bytes.write(to: source)
        let importer = TXTBookImportService(files: files,repository: repository)
        let task = Task { withUnsafeCurrentTask { $0?.cancel() }; return try await importer.importBook(from: source) }
        do { _ = try await task.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        let books = try await repository.books(); XCTAssertTrue(books.isEmpty)
        XCTAssertEqual(try Data(contentsOf: source),bytes)
    }
    func testTXTDatabaseWriteFailureRollsBackFinalizedOriginalAndCachePreservesSource() async throws {
        let (root,files,repository) = try context(), source = root.appendingPathComponent("failure.txt")
        let bytes = Data("第一章 失败\n原文".utf8); try bytes.write(to: source)
        do { _ = try await TXTBookImportService(files: files,repository: FailedRepository(actual: repository)).importBook(from: source); XCTFail("Write must fail") }
        catch { XCTAssertTrue(error is FailedRepository.WriteFailure) }
        let books = try await repository.books(); XCTAssertTrue(books.isEmpty)
        for prefix in ["Staging","Books","Cache/TXT"] {
            let url = try files.resolve(prefix)
            if FileManager.default.fileExists(atPath: url.path) { XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: url.path).isEmpty) }
        }
        XCTAssertEqual(try Data(contentsOf: source),bytes)
    }
    func testLegacyEPUBPayloadWithoutEncodingStillDecodes() throws {
        let book = Book(title: "旧书", format: .epub, filePath: "Books/old/book.epub")
        let data = try JSONEncoder().encode(book)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String:Any])
        object.removeValue(forKey: "txtEncoding")
        let restored = try JSONDecoder().decode(Book.self,from: JSONSerialization.data(withJSONObject: object))
        XCTAssertEqual(restored,book); XCTAssertNil(restored.txtEncoding)
    }
    func testReadingPlanHugeChapterBoundedWindowsUTF8BytesCoverOriginalExactly() async throws {
        let (root,files,_) = try context(), source = root.appendingPathComponent("large.txt")
        let bytes = Data(("第一章 大章\n"+String(repeating:"修行🙂e\u{301}",count:25000)+"\n第二章 尾声\n尾声").utf8)
        try bytes.write(to: source)
        let cache = try TXTIndexCache(storageRoot: files.root), id = UUID()
        let index = try await cache.prepare(source: source,bookID: id), file = try await cache.normalizedURL(for: index)
        let plan = try await TXTReadingPlanner().build(index: index,file: file)
        XCTAssertGreaterThan(plan.resources.count,4)
        var next: Int64 = 0, recovered = Data(); let reader = TXTChapterWindowReader()
        for resource in plan.resources {
            XCTAssertEqual(resource.startByte,next); XCTAssertLessThanOrEqual(resource.endByte-resource.startByte,Int64(TXTReadingPlan.resourceBytes))
            let window = try await reader.read(file: file,chapter: resource.chapter,localByteOffset: resource.startByte - XCTUnwrap(resource.chapter.startByte),maximumBytes: max(4,Int(resource.endByte-resource.startByte)))
            recovered.append(contentsOf: window.text.utf8); next = resource.endByte
        }
        XCTAssertEqual(recovered,bytes); XCTAssertEqual(next,Int64(bytes.count))
    }
    func testReadingAnchorRejectsDifferentContentAndInvalidRanges() async throws {
        let (root,files,_) = try context(), source = root.appendingPathComponent("anchor.txt")
        try Data("第一章 锚点\n正文🙂".utf8).write(to: source)
        let cache = try TXTIndexCache(storageRoot: files.root), id = UUID()
        let index = try await cache.prepare(source: source,bookID: id), file = try await cache.normalizedURL(for: index)
        let plan = try await TXTReadingPlanner().build(index: index,file: file), resource = try XCTUnwrap(plan.resources.first)
        let good = TXTReadingAnchor(plan: plan,resource: resource,paragraphStartByte: resource.startByte,characterUTF16Offset: 0)
        XCTAssertTrue(good.isValid(plan: plan,resource: resource))
        let bad = TXTReadingAnchor(plan: plan,resource: resource,paragraphStartByte: resource.endByte,characterUTF16Offset: 0)
        XCTAssertFalse(bad.isValid(plan: plan,resource: resource))
        try Data("第一章 锚点\n新的正文".utf8).write(to: source)
        let newIndex = try await cache.prepare(source: source,bookID: id), newFile = try await cache.normalizedURL(for: newIndex)
        let newPlan = try await TXTReadingPlanner().build(index: newIndex,file: newFile)
        let newResource = try XCTUnwrap(newPlan.resources.first)
        XCTAssertFalse(good.isValid(plan: newPlan,resource: newResource))
    }
}
