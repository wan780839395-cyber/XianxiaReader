import ReadiumAdapter
import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class BookDuplicateTests: XCTestCase {
    @MainActor private static var repositories: [SQLiteBookRepository] = []
    @MainActor private func context() async throws -> (URL, AppServices, LibraryViewModel) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("DuplicateSession-\(UUID().uuidString)")
        let services = try await AppServices.create(storageRoot: root); Self.repositories.append(services.repository)
        let suite = "Duplicate-\(UUID().uuidString)", defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        addTeardownBlock { UserDefaults.standard.removePersistentDomain(forName: suite) }
        return (root, services, LibraryViewModel(services: services, defaults: defaults))
    }
    @MainActor func testRealEPUBAndTXTRenamedCopiesKeepUUIDCoverAndFullReadingHistory() async throws {
        let (root, services, model) = try await context()
        let epub = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        let txt = root.appendingPathComponent("云海.txt"); try Data("第一章 山门\n正文🙂".utf8).write(to: txt)
        await model.importBooks([epub, txt]); XCTAssertEqual(model.books.count, 2); XCTAssertNil(model.errorMessage)
        let originals = model.books.map(\.book)
        var positions: [UUID: ReadingPosition] = [:], marks: [UUID: Bookmark] = [:], chapters: [UUID: [Chapter]] = [:]
        for book in originals {
            _ = try await services.repository.renameBook(book.id, title: "自定义\(book.format.rawValue)")
            let position = ReadingPosition(bookID: book.id, engineID: "readium.\(book.format.rawValue)", locatorData: Data([0,42,255]), progression: 0.42)
            let mark = Bookmark(position: position, title: "保留")
            try await services.repository.save(position); try await services.repository.add(mark)
            positions[book.id] = position; marks[book.id] = mark; chapters[book.id] = try await services.repository.chapters(for: book.id)
            let copy = root.appendingPathComponent("改名副本.\(book.format.rawValue)")
            try FileManager.default.copyItem(at: services.files.resolve(book.filePath), to: copy)
            await model.importBooks([copy]); XCTAssertNil(model.errorMessage); XCTAssertEqual(model.duplicateBooks.first?.id, book.id)
            XCTAssertEqual(model.importStatus, "1 个重复文件，已保留原书")
            XCTAssertEqual(model.books.count, 2)
        }
        let reopened = try await AppServices.create(storageRoot: root); Self.repositories.append(reopened.repository)
        for book in originals {
            let position = try await reopened.repository.position(for: book.id), bookmarks = try await reopened.repository.bookmarks(for: book.id)
            let toc = try await reopened.repository.chapters(for: book.id)
            XCTAssertEqual(position, positions[book.id]); XCTAssertEqual(bookmarks, [try XCTUnwrap(marks[book.id])]); XCTAssertEqual(toc, chapters[book.id])
            let current = try XCTUnwrap(model.books.first(where: { $0.id == book.id })?.book)
            XCTAssertEqual(current.coverPath, book.coverPath); XCTAssertEqual(current.filePath, book.filePath); XCTAssertEqual(current.importedAt, book.importedAt)
            XCTAssertEqual(current.title, "自定义\(book.format.rawValue)")
        }
    }
    @MainActor func testMixedBatchCountsDuplicatesNewBooksAndBadFilesTruthfully() async throws {
        let (root, _, model) = try await context(), first = root.appendingPathComponent("云海.txt"), other = root.appendingPathComponent("另一版.txt"), bad = root.appendingPathComponent("坏书.epub")
        try Data("第一章 起点\n正文".utf8).write(to: first); try Data("第一章 起点\n内容不同".utf8).write(to: other); try Data([0,1,2]).write(to: bad)
        await model.importBooks([first]); await model.importBooks([first, first, other, bad])
        XCTAssertEqual(model.books.count, 2); XCTAssertEqual(model.duplicateBooks.count, 1)
        XCTAssertEqual(model.importStatus, "已导入 1 本书 · 2 个重复文件，已保留原书")
        XCTAssertTrue(try XCTUnwrap(model.errorMessage).contains("坏书.epub")); XCTAssertTrue(model.retryTXTFiles.isEmpty)
        model.dismissDuplicates(); XCTAssertTrue(model.duplicateBooks.isEmpty)
    }
    @MainActor func testDuplicateTrashFeedbackRestoresExplicitlyAndKeepsSavedProgressAfterRestart() async throws {
        let (root, services, model) = try await context(), source = root.appendingPathComponent("云海.txt")
        try Data("第一章 书页\n正文".utf8).write(to: source); await model.importBooks([source])
        let book = try XCTUnwrap(model.books.first?.book), position = ReadingPosition(bookID: book.id, engineID: "readium.txt", locatorData: Data([4,2]), progression: 0.42)
        try await services.repository.save(position); let moved = await model.moveToTrash(book.id); XCTAssertTrue(moved)
        await model.importBooks([source]); XCTAssertTrue(model.books.isEmpty); XCTAssertEqual(model.removedBooks.count, 1)
        XCTAssertEqual(model.duplicateBooks.first?.isRemoved, true)
        let restored = await model.restoreBook(book.id); XCTAssertTrue(restored)
        XCTAssertEqual(model.books.first?.id, book.id); XCTAssertEqual(model.books.first?.progression, 0.42)
        XCTAssertTrue(model.removedBooks.isEmpty)
        let reopened = try await AppServices.create(storageRoot: root); Self.repositories.append(reopened.repository)
        let saved = try await reopened.repository.position(for: book.id); XCTAssertEqual(saved, position)
    }
    @MainActor func testCancelledDuplicateImportDoesNotRemoveAlreadyCommittedBook() async throws {
        let (root, services, model) = try await context(), source = root.appendingPathComponent("云海.txt")
        try Data("第一章 书页\n正文".utf8).write(to: source); await model.importBooks([source]); let before = model.books
        let importer = EPUBImportService(repository: services.repository, files: services.files, metadata: ReadiumPublicationLoader())
        let task = Task { withUnsafeCurrentTask { $0?.cancel() }; return try await importer.importBook(from: source) }
        do { _ = try await task.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        await model.refresh(); XCTAssertEqual(model.books, before)
        XCTAssertTrue(FileManager.default.fileExists(atPath: try services.files.resolve(XCTUnwrap(before.first?.book.filePath)).path))
    }
}
