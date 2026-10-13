import Foundation
import ReadiumAdapter
import ReadingInterfaces
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class EPUBIntegrationTests: XCTestCase {
    private func fixture(_ name: String) throws -> URL {
        try XCTUnwrap(Bundle(for: Self.self).url(forResource: name, withExtension: "epub", subdirectory: "Fixtures"))
    }

    func testEPUB2AndEPUB3MetadataAndNavigationIndex() async throws {
        let loader = ReadiumPublicationLoader()
        for name in ["chinese-epub2", "chinese-epub3"] {
            let id = UUID()
            let metadata = try await loader.readMetadata(at: fixture(name), bookID: id)
            XCTAssertEqual(metadata.title, "云海问道·测试样书")
            XCTAssertEqual(metadata.author, "XianxiaReader 测试")
            XCTAssertEqual(metadata.chapters.count, 2)
            XCTAssertEqual(metadata.chapters.first?.title, "第一章 山门")
            XCTAssertTrue(metadata.chapters.allSatisfy { $0.bookID == id })
        }
    }

    @MainActor func testNavigatorCanBeCreatedWithoutAnHTTPServer() async throws {
        let engine = ReadiumReaderEngine()
        let url = try fixture("chinese-epub3")
        let book = Book(title: "测试", format: .epub, filePath: "test.epub")
        try await engine.open(book: book, fileURL: url, position: nil)
        XCTAssertEqual(engine.viewController.children.count, 1)
        engine.close()
        XCTAssertTrue(engine.viewController.children.isEmpty)
    }

    @MainActor func testRealImportPersistsBookAndCachedTOC() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let files = try BookFileStore(root: root)
        let importer = EPUBImportService(repository: repository, files: files, metadata: ReadiumPublicationLoader())
        let result = try await importer.importBook(from: fixture("chinese-epub3"))
        let books = try await repository.books()
        let chapters = try await repository.chapters(for: result.book.id)
        XCTAssertEqual(books.count, 1)
        XCTAssertEqual(chapters.count, 2)
        XCTAssertTrue(FileManager.default.fileExists(atPath: try files.resolve(result.book.filePath).path))
    }

    @MainActor func testCorruptEPUBImportRollsBackFilesAndDatabase() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let source = root.appendingPathComponent("corrupt.epub")
        try Data("invalid archive".utf8).write(to: source)
        let importer = EPUBImportService(repository: repository, files: files, metadata: ReadiumPublicationLoader())
        do { _ = try await importer.importBook(from: source); XCTFail("Corrupt EPUB must fail") }
        catch { /* Expected parser failure. Assert observable rollback below. */ }
        let books = try await repository.books()
        XCTAssertTrue(books.isEmpty)
        let staging = try files.resolve("Staging")
        if FileManager.default.fileExists(atPath: staging.path) {
            XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: staging.path).isEmpty)
        }
    }
}
