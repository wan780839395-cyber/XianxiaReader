import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class LibraryTests: XCTestCase {
    @MainActor private static let sessionRoot = FileManager.default.temporaryDirectory.appendingPathComponent("LibraryFixtureSession-\(UUID().uuidString)")
    // SwiftUI/SQLite cleanup can outlive a case. Keep the small fixture repositories
    // AND their directories until worker exit, as the native import suite does.
    @MainActor private static var repositories: [SQLiteBookRepository] = []
    @MainActor private func context() throws -> (URL, AppServices, UserDefaults) {
        let root = Self.sessionRoot.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let suite = "LibraryTests-\(UUID().uuidString)", defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        Self.repositories.append(repository)
        addTeardownBlock { UserDefaults.standard.removePersistentDomain(forName: suite) }
        return (root, AppServices(repository: repository, files: files), defaults)
    }

    @MainActor func testLayoutSortPreferencesPersistAndInvalidValuesFallBack() throws {
        let (_, services, defaults) = try context()
        let first = LibraryViewModel(services: services, defaults: defaults)
        XCTAssertEqual(first.layout, .grid); XCTAssertEqual(first.sortOrder, .recent)
        first.layout = .list; first.sortOrder = .title; first.query = "临时筛选"
        let reopened = LibraryViewModel(services: services, defaults: defaults)
        XCTAssertEqual(reopened.layout, .list); XCTAssertEqual(reopened.sortOrder, .title); XCTAssertEqual(reopened.query, "")
        defaults.set("future-layout", forKey: "library.layout.v1"); defaults.set("future-sort", forKey: "library.sort.v1")
        let fallback = LibraryViewModel(services: services, defaults: defaults)
        XCTAssertEqual(fallback.layout, .grid); XCTAssertEqual(fallback.sortOrder, .recent)
    }

    @MainActor func testMetadataOnlyFilteringNumericSortAndReadingProgress() throws {
        let a = Book(id: try XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000001")), title: "Book 2", author: "Café", format: .epub,
                     filePath: "original.epub", importedAt: Date(timeIntervalSince1970: 100))
        let b = Book(id: try XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000002")), title: "Book 10", author: "山门", format: .txt,
                     filePath: "original.txt", importedAt: Date(timeIntervalSince1970: 400))
        let summaries = [BookSummary(book: b, progression: nil, lastReadAt: nil), BookSummary(book: a, progression: 0.42, lastReadAt: Date(timeIntervalSince1970: 300))]
        XCTAssertEqual(LibraryPresentation.books(summaries, query: "", order: .recent).map(\.id), [a.id,b.id])
        XCTAssertEqual(LibraryPresentation.books(summaries, query: "", order: .imported).map(\.id), [b.id,a.id])
        XCTAssertEqual(LibraryPresentation.books(summaries, query: "", order: .title).map(\.id), [a.id,b.id])
        for query in ["cafe", "ＣＡＦＥ", " book 2 "] { XCTAssertEqual(LibraryPresentation.books(summaries, query: query, order: .recent).map(\.id), [a.id]) }
        XCTAssertEqual(LibraryPresentation.books(summaries, query: "山门", order: .title).map(\.id), [b.id])
        XCTAssertTrue(LibraryPresentation.books(summaries, query: "正文里才有的词", order: .recent).isEmpty)
        XCTAssertEqual(LibraryPresentation.readingLabel(summaries[1]), "已读 42%")
        XCTAssertEqual(LibraryPresentation.readingLabel(summaries[0]), "尚未阅读")
        XCTAssertNil(LibraryPresentation.progress(BookSummary(book: a, progression: .nan, lastReadAt: nil)))
        XCTAssertEqual(LibraryPresentation.progress(BookSummary(book: a, progression: 2, lastReadAt: nil)), 1)
        let tied = summaries.map { BookSummary(book: $0.book, progression: nil, lastReadAt: Date(timeIntervalSince1970: 300)) }
        XCTAssertEqual(LibraryPresentation.books(tied, query: "", order: .recent).map(\.id), [a.id,b.id])
    }

    @MainActor func testRenameThroughShelfPersistsOriginalAndCompleteReadingPosition() async throws {
        let (root, services, defaults) = try context(), source = root.appendingPathComponent("云海.txt")
        let raw = Data("第一章 山门\n云海问道，原件保留。".utf8); try raw.write(to: source)
        let book = try await TXTBookImportService(files: services.files, repository: services.repository).importBook(from: source)
        let position = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data("complete locator".utf8), progression: 0.42)
        try await services.repository.save(position)
        let model = LibraryViewModel(services: services, defaults: defaults); await model.refresh()
        model.beginRename(book); XCTAssertEqual(model.presentedSheet, .renameBook)
        let invalid = await model.renameBook(book.id, title: " ")
        XCTAssertFalse(invalid); XCTAssertNotNil(model.renameError); XCTAssertEqual(model.books.first?.book.title, book.title)
        let missing = await model.renameBook(UUID(), title: "无法保存")
        XCTAssertFalse(missing); XCTAssertNotNil(model.renameError); XCTAssertEqual(model.books.count, 1)
        model.query = book.title
        let renamed = await model.renameBook(book.id, title: "  山门新书名🙂  ")
        XCTAssertTrue(renamed); XCTAssertNil(model.renameError); XCTAssertFalse(model.isRenaming)
        XCTAssertEqual(model.books.first?.book.title, "山门新书名🙂"); XCTAssertTrue(model.visibleBooks.isEmpty)
        XCTAssertEqual(model.books.first?.id, book.id); XCTAssertEqual(model.books.first?.progression, 0.42)
        XCTAssertEqual(try Data(contentsOf: services.files.resolve(book.filePath)), raw)
        XCTAssertEqual(try Data(contentsOf: source), raw)
        let reopened = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite")), stored = try await reopened.books()
        let saved = try await reopened.position(for: book.id)
        XCTAssertEqual(stored.first?.book.title, "山门新书名🙂"); XCTAssertEqual(saved, position)
    }

    @MainActor func testRefreshOverlappingCommittedRenameKeepsLatestTitle() async throws {
        let (_, services, defaults) = try context(), book = Book(title: "旧书名", format: .epub, filePath: "original.epub")
        try await services.repository.insert(book, chapters: [])
        let model = LibraryViewModel(services: services, defaults: defaults); await model.refresh()
        let refreshing = Task { await model.refresh() }
        let saved = await model.renameBook(book.id, title: "已提交的新名")
        await refreshing.value
        XCTAssertTrue(saved); XCTAssertEqual(model.books.first?.book.title, "已提交的新名")
        let stored = try await services.repository.books(); XCTAssertEqual(stored.first?.book, model.books.first?.book)
    }

    @MainActor func testNativeShelfGridListFilterAndRenameErrorSnapshots() async throws {
        let (_, services, defaults) = try context(), model = LibraryViewModel(services: services, defaults: defaults)
        let titles = ["云海问道", "山门旧事", "剑过青山", "长夜听雨", "千章行路", "一盏灯照见江湖"]
        for (index, title) in titles.enumerated() {
            let book = Book(title: title, author: index == 0 ? "原创样书" : "", format: index % 2 == 0 ? .txt : .epub, filePath: "fixture-\(index)")
            try await services.repository.insert(book, chapters: [])
            if index == 0 { try await services.repository.save(ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data(), progression: 0.42)) }
        }
        await model.refresh()
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }, window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: LibraryView(services: services, model: model))
        window.makeKeyAndVisible(); window.layoutIfNeeded()
        defer { window.isHidden = true; window.rootViewController = nil; previous?.makeKey() }
        for layout in LibraryLayout.allCases {
            model.layout = layout
            try await Task.sleep(nanoseconds: 300_000_000); window.layoutIfNeeded()
            attach(window, name: "library-\(layout.rawValue)-build10")
        }
        model.query = "找不到的书名"
        try await Task.sleep(nanoseconds: 300_000_000); window.layoutIfNeeded()
        XCTAssertTrue(model.visibleBooks.isEmpty); attach(window, name: "library-filter-empty-build10")
        model.query = ""; model.beginRename(try XCTUnwrap(model.books.first?.book))
        let deadline = Date().addingTimeInterval(10)
        while window.rootViewController?.presentedViewController == nil, Date() < deadline { try await Task.sleep(nanoseconds: 50_000_000) }
        XCTAssertNotNil(window.rootViewController?.presentedViewController)
        let rejected = await model.renameBook(try XCTUnwrap(model.books.first?.id), title: " ")
        XCTAssertFalse(rejected); XCTAssertNotNil(model.renameError)
        try await Task.sleep(nanoseconds: 300_000_000); window.layoutIfNeeded()
        attach(window, name: "library-rename-error-build10")
        model.presentedSheet = nil
        let dismissalDeadline = Date().addingTimeInterval(10)
        while (window.rootViewController?.presentedViewController != nil || window.rootViewController?.transitionCoordinator != nil), Date() < dismissalDeadline {
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTAssertNil(window.rootViewController?.presentedViewController)
    }

    @MainActor private func attach(_ window: UIWindow, name: String) {
        var rendered = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in rendered = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) }
        XCTAssertTrue(rendered); XCTAssertGreaterThan(image.size.width, 300); XCTAssertGreaterThan(image.size.height, 500)
        let attachment = XCTAttachment(image: image); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
