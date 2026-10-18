import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class LibraryRemovalTests: XCTestCase {
    @MainActor private static let sessionRoot = FileManager.default.temporaryDirectory.appendingPathComponent("LibraryRemovalSession-\(UUID().uuidString)")
    // Keep small SQLite fixtures alive until worker exit; native dismissals can outlive a case.
    @MainActor private static var repositories: [SQLiteBookRepository] = []

    @MainActor private func context() async throws -> (URL, AppServices, UserDefaults) {
        let root = Self.sessionRoot.appendingPathComponent(UUID().uuidString)
        let services = try await AppServices.create(storageRoot: root)
        Self.repositories.append(services.repository)
        let suite = "LibraryRemoval-\(UUID().uuidString)", defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        addTeardownBlock { UserDefaults.standard.removePersistentDomain(forName: suite) }
        return (root, services, defaults)
    }

    @MainActor func testTXTAndEPUBRemovalSurvivesRealAppStartupRecoveryAndRestoresRelatedData() async throws {
        let (root, services, defaults) = try await context(), source = root.appendingPathComponent("云海.txt")
        let bytes = Data("第一章 山门\n正文🙂\n第二章 江湖\n灯火仍在".utf8); try bytes.write(to: source)
        let epub = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        let model = LibraryViewModel(services: services, defaults: defaults)
        await model.importBooks([source,epub]); XCTAssertEqual(model.books.count, 2); XCTAssertNil(model.errorMessage)
        var expected: [UUID: ReadingPosition] = [:]
        var bookmarks: [UUID: Bookmark] = [:]
        var chapters: [UUID: [Chapter]] = [:]
        for summary in model.books {
            let book = summary.book
            let position = ReadingPosition(bookID: book.id, engineID: book.format == .txt ? "readium.txt" : "readium.epub",
                                           locatorData: Data("完整章中段位置🙂\(book.id)".utf8), progression: 0.42)
            let bookmark = Bookmark(position: position, title: "中段")
            try await services.repository.save(position); try await services.repository.add(bookmark)
            expected[book.id] = position; bookmarks[book.id] = bookmark; chapters[book.id] = try await services.repository.chapters(for: book.id)
        }
        let originals = model.books.map(\.book)
        var fileBytes: [UUID: Data] = [:]
        for book in originals {
            fileBytes[book.id] = try Data(contentsOf: services.files.resolve(book.filePath))
            let moved = await model.moveToTrash(book.id); XCTAssertTrue(moved)
        }
        XCTAssertTrue(model.books.isEmpty); XCTAssertEqual(model.removedBooks.count, 2)
        // This is the production startup entry, not a hand-picked knownIDs approximation.
        let reopened = try await AppServices.create(storageRoot: root)
        Self.repositories.append(reopened.repository)
        let fresh = LibraryViewModel(services: reopened, defaults: defaults); await fresh.refresh()
        XCTAssertTrue(fresh.books.isEmpty); XCTAssertEqual(fresh.removedBooks.count, 2)
        for book in originals {
            XCTAssertEqual(try Data(contentsOf: reopened.files.resolve(book.filePath)), fileBytes[book.id])
            if let path = book.coverPath { XCTAssertTrue(FileManager.default.fileExists(atPath: try reopened.files.resolve(path).path)) }
            let restored = await fresh.restoreBook(book.id); XCTAssertTrue(restored)
            let position = try await reopened.repository.position(for: book.id), savedMarks = try await reopened.repository.bookmarks(for: book.id)
            let savedChapters = try await reopened.repository.chapters(for: book.id)
            XCTAssertEqual(position, expected[book.id]); XCTAssertEqual(savedMarks, [try XCTUnwrap(bookmarks[book.id])]); XCTAssertEqual(savedChapters, chapters[book.id])
        }
        XCTAssertEqual(Set(fresh.books.map(\.id)), Set(originals.map(\.id))); XCTAssertTrue(fresh.removedBooks.isEmpty)
        XCTAssertEqual(try Data(contentsOf: source), bytes)
    }

    @MainActor func testConfirmationCancelMissingBookErrorAndRecoveryRetryKeepShelfTruthful() async throws {
        let (_, services, defaults) = try await context(), book = Book(title: "云海问道", format: .txt, filePath: "fixture.txt")
        try await services.repository.insert(book, chapters: [])
        let model = LibraryViewModel(services: services, defaults: defaults); await model.refresh()
        model.requestRemoval(book); XCTAssertEqual(model.bookToRemove, book)
        model.bookToRemove = nil
        let unchanged = try await services.repository.books(); XCTAssertEqual(unchanged.map(\.book), [book])
        let rejected = await model.moveToTrash(UUID())
        XCTAssertFalse(rejected); XCTAssertNotNil(model.managementError); XCTAssertNotNil(model.errorMessage)
        XCTAssertEqual(model.books.map(\.book), [book]); XCTAssertTrue(model.removedBooks.isEmpty)
        let moved = await model.moveToTrash(book.id); XCTAssertTrue(moved); XCTAssertNil(model.managementError)
        let invalidRestore = await model.restoreBook(UUID()); XCTAssertFalse(invalidRestore); XCTAssertEqual(model.removedBooks.map(\.book), [book])
        let restored = await model.restoreBook(book.id); XCTAssertTrue(restored); XCTAssertNil(model.managementError)
        XCTAssertEqual(model.books.map(\.book), [book]); XCTAssertTrue(model.removedBooks.isEmpty)
    }

    @MainActor func testOverlappingRefreshDoesNotBringBackRemovedBookOrHideRestoredBook() async throws {
        let (_, services, defaults) = try await context(), book = Book(title: "云海", format: .epub, filePath: "fixture.epub")
        try await services.repository.insert(book, chapters: [])
        let model = LibraryViewModel(services: services, defaults: defaults); await model.refresh()
        let first = Task { await model.refresh() }
        let moved = await model.moveToTrash(book.id); await first.value
        XCTAssertTrue(moved); XCTAssertTrue(model.books.isEmpty); XCTAssertEqual(model.removedBooks.map(\.id), [book.id])
        let second = Task { await model.refresh() }
        let restored = await model.restoreBook(book.id); await second.value
        XCTAssertTrue(restored); XCTAssertEqual(model.books.map(\.id), [book.id]); XCTAssertTrue(model.removedBooks.isEmpty)
    }

    @MainActor func testNativeRemovalConfirmationTrashAndEmptySnapshots() async throws {
        let (_, services, defaults) = try await context(), book = Book(title: "云海问道", author: "原创样书", format: .txt, filePath: "fixture.txt")
        try await services.repository.insert(book, chapters: [])
        try await services.repository.save(ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([1,2]), progression: 0.42))
        let model = LibraryViewModel(services: services, defaults: defaults); await model.refresh()
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }, window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: LibraryView(services: services, model: model).environmentObject(FontDocumentInbox()))
        window.makeKeyAndVisible(); window.layoutIfNeeded()
        defer { window.isHidden = true; window.rootViewController = nil; previous?.makeKey() }
        try await Task.sleep(nanoseconds: 300_000_000)
        model.requestRemoval(book); try await waitForPresentation(window, presented: true)
        try await Task.sleep(nanoseconds: 300_000_000); attach(window, name: "library-removal-confirmation-build11")
        model.bookToRemove = nil; try await waitForPresentation(window, presented: false)
        let moved = await model.moveToTrash(book.id); XCTAssertTrue(moved)
        model.showTrash(); try await waitForPresentation(window, presented: true)
        try await Task.sleep(nanoseconds: 300_000_000); attach(window, name: "library-trash-populated-build11")
        let restored = await model.restoreBook(book.id); XCTAssertTrue(restored)
        try await Task.sleep(nanoseconds: 300_000_000); attach(window, name: "library-trash-empty-build11")
        model.presentedSheet = nil; try await waitForPresentation(window, presented: false)
    }

    @MainActor private func waitForPresentation(_ window: UIWindow, presented: Bool) async throws {
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            let visible = window.rootViewController?.presentedViewController != nil
            if visible == presented, window.rootViewController?.transitionCoordinator == nil { return }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTFail("Native presentation did not settle"); throw NSError(domain: "LibraryRemovalTests", code: 1)
    }

    @MainActor private func attach(_ window: UIWindow, name: String) {
        window.layoutIfNeeded()
        var rendered = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in rendered = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) }
        XCTAssertTrue(rendered); XCTAssertGreaterThan(image.size.height, 500)
        let attachment = XCTAttachment(image: image); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
