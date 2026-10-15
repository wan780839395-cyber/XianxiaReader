import ImageIO
import SQLite3
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class BookCoverTests: XCTestCase {
    @MainActor private static var repositories: [SQLiteBookRepository] = []
    @MainActor private static let session = FileManager.default.temporaryDirectory.appendingPathComponent("CoverTests-\(UUID().uuidString)")

    @MainActor private func context() async throws -> (URL, AppServices, LibraryViewModel) {
        let root = Self.session.appendingPathComponent(UUID().uuidString)
        let services = try await AppServices.create(storageRoot: root)
        Self.repositories.append(services.repository)
        let suite = "CoverTests.\(UUID().uuidString)", defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        addTeardownBlock { UserDefaults.standard.removePersistentDomain(forName: suite) }
        return (root, services, LibraryViewModel(services: services, defaults: defaults))
    }
    @MainActor private func importedBook(_ root: URL, _ services: AppServices) async throws -> Book {
        let url = root.appendingPathComponent("云海问道.txt")
        try Data("第一章 山门\n原书🙂\n第二章 江湖\n位置和书签仍在".utf8).write(to: url)
        return try await TXTBookImportService(files: services.files, repository: services.repository).importBook(from: url)
    }
    // A generated two-colour bitmap is a decoder test input, never production artwork.
    @MainActor private func image(_ root: URL, orientation: Int = 1) throws -> URL {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
        let bitmap = UIGraphicsImageRenderer(size: CGSize(width: 1_200, height: 600), format: format).image { context in
            UIColor.red.setFill(); context.fill(CGRect(x: 0, y: 0, width: 600, height: 600))
            UIColor.blue.setFill(); context.fill(CGRect(x: 600, y: 0, width: 600, height: 600))
        }
        let url = root.appendingPathComponent("cover-\(UUID().uuidString).jpg")
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try XCTUnwrap(bitmap.cgImage), [kCGImagePropertyOrientation: orientation] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return url
    }
    @MainActor private func sql(_ text: String, root: URL) throws {
        var connection: OpaquePointer?
        XCTAssertEqual(sqlite3_open(root.appendingPathComponent("library.sqlite").path, &connection), SQLITE_OK)
        let database = try XCTUnwrap(connection); defer { sqlite3_close(database) }
        XCTAssertEqual(sqlite3_exec(database, text, nil, nil, nil), SQLITE_OK, String(cString: sqlite3_errmsg(database)))
    }

    @MainActor func testBackgroundDownsamplingAppliesEXIFOnceAndRetainsOriginalBytes() async throws {
        let (root, services, _) = try await context(), url = try image(root, orientation: 6)
        let bytes = try Data(contentsOf: url), service = CoverImportService(files: services.files, repository: services.repository)
        let draft = try await service.prepare(from: url, bookID: UUID())
        XCTAssertEqual(draft.preview.width, 540); XCTAssertEqual(draft.preview.height, 1_080)
        XCTAssertLessThan(draft.thumbnailJPEG.count, 2 * 1_024 * 1_024)
        XCTAssertEqual(try Data(contentsOf: draft.staged.originalURL), bytes)
        let source = try XCTUnwrap(CGImageSourceCreateWithData(draft.thumbnailJPEG as CFData, nil))
        let decoded = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        XCTAssertEqual(decoded.width, 540); XCTAssertEqual(decoded.height, 1_080)
        let properties = try XCTUnwrap(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
        XCTAssertEqual((properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1, 1)
        let small = try await CoverImagePipeline().image(files: services.files,
            path: "StagingCovers/\(draft.staged.cover.assetID.uuidString)/original", maximumPixelSize: 252)
        XCTAssertEqual(max(small.image.width, small.image.height), 252); XCTAssertNil(small.warning)
        try await service.discard(draft)
    }

    @MainActor func testMissingThumbnailUsesOriginalWithWarningAndBothFailuresRemainVisible() async throws {
        let (root, services, _) = try await context(), book = try await importedBook(root, services)
        let service = CoverImportService(files: services.files, repository: services.repository)
        let draft = try await service.prepare(from: image(root), bookID: book.id), saved = try await service.save(draft)
        let cover = try XCTUnwrap(saved.coverOverride), thumbnail = try services.files.resolve(cover.thumbnailPath(bookID: book.id))
        do { _ = try await service.save(draft); XCTFail("An already committed draft cannot be saved twice") }
        catch {
            let stored = try await services.repository.books(); XCTAssertEqual(stored.first?.book.coverOverride, cover)
            XCTAssertTrue(FileManager.default.fileExists(atPath: thumbnail.path))
            XCTAssertTrue(FileManager.default.fileExists(atPath: try services.files.resolve(cover.originalPath(bookID: book.id)).path))
        }
        try FileManager.default.removeItem(at: thumbnail)
        let pipeline = CoverImagePipeline()
        for _ in 0..<2 {
            let recovered = try await pipeline.image(files: services.files, path: cover.thumbnailPath(bookID: book.id), maximumPixelSize: 600,
                                                     originalPath: cover.originalPath(bookID: book.id))
            XCTAssertEqual(recovered.warning, "已从原图恢复封面"); XCTAssertEqual(recovered.image.width, 600)
        }
        try FileManager.default.removeItem(at: services.files.resolve(cover.originalPath(bookID: book.id)))
        do {
            _ = try await CoverImagePipeline().image(files: services.files, path: cover.thumbnailPath(bookID: book.id), maximumPixelSize: 600,
                                                     originalPath: cover.originalPath(bookID: book.id)); XCTFail("Both failures")
        } catch { XCTAssertTrue(error.localizedDescription.contains("原图也无法读取")); XCTAssertTrue(error.localizedDescription.contains("缩略图")) }
    }

    @MainActor func testRealTXTAndEPUBCoverSaveStartupTrashRestoreAndDefaultPreserveRelatedData() async throws {
        let (root, services, model) = try await context(), txt = try await importedBook(root, services)
        let epubURL = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        await model.importBooks([epubURL]); XCTAssertNil(model.errorMessage)
        let epub = try XCTUnwrap(model.books.first(where: { $0.book.format == .epub })?.book)
        let service = CoverImportService(files: services.files, repository: services.repository), source = try image(root)
        var originals: [UUID: Data] = [:], defaultImages: [UUID: Data] = [:], positions: [UUID: ReadingPosition] = [:]
        var chapters: [UUID: [Chapter]] = [:], marks: [UUID: Bookmark] = [:], overrides: [UUID: BookCoverOverride] = [:]
        for book in [txt, epub] {
            originals[book.id] = try Data(contentsOf: services.files.resolve(book.filePath))
            if let path = book.coverPath { defaultImages[book.id] = try Data(contentsOf: services.files.resolve(path)) }
            let position = ReadingPosition(bookID: book.id, engineID: "readium.\(book.format.rawValue)", locatorData: Data("完整位置🙂".utf8), progression: 0.42)
            let mark = Bookmark(position: position, title: "原书签")
            try await services.repository.save(position); try await services.repository.add(mark)
            positions[book.id] = position; marks[book.id] = mark; chapters[book.id] = try await services.repository.chapters(for: book.id)
            let draft = try await service.prepare(from: source, bookID: book.id), saved = try await service.save(draft)
            overrides[book.id] = try XCTUnwrap(saved.coverOverride)
            try await services.repository.moveToTrash(book.id)
        }
        let reopened = try await AppServices.create(storageRoot: root); Self.repositories.append(reopened.repository)
        let snapshot = try await reopened.repository.librarySnapshot()
        XCTAssertTrue(snapshot.books.isEmpty); XCTAssertEqual(snapshot.removedBooks.count, 2)
        let resetter = CoverImportService(files: reopened.files, repository: reopened.repository)
        for original in [txt, epub] {
            let saved = try XCTUnwrap(snapshot.removedBooks.first(where: { $0.id == original.id })?.book)
            XCTAssertEqual(saved.coverOverride, overrides[original.id]); XCTAssertEqual(saved.coverPath, original.coverPath)
            let cover = try XCTUnwrap(saved.coverOverride)
            XCTAssertEqual(try Data(contentsOf: reopened.files.resolve(cover.originalPath(bookID: saved.id))), try Data(contentsOf: source))
            XCTAssertTrue(FileManager.default.fileExists(atPath: try reopened.files.resolve(cover.thumbnailPath(bookID: saved.id)).path))
            try await reopened.repository.restoreBook(saved.id)
            let reset = try await resetter.useDefault(bookID: saved.id); XCTAssertEqual(reset, original)
            let position = try await reopened.repository.position(for: saved.id), savedChapters = try await reopened.repository.chapters(for: saved.id)
            let bookmarks = try await reopened.repository.bookmarks(for: saved.id)
            XCTAssertEqual(position, positions[saved.id]); XCTAssertEqual(savedChapters, chapters[saved.id]); XCTAssertEqual(bookmarks, [try XCTUnwrap(marks[saved.id])])
            XCTAssertEqual(try Data(contentsOf: reopened.files.resolve(saved.filePath)), originals[saved.id])
            if let path = saved.coverPath { XCTAssertEqual(try Data(contentsOf: reopened.files.resolve(path)), defaultImages[saved.id]) }
            XCTAssertTrue(FileManager.default.fileExists(atPath: try reopened.files.resolve(cover.originalPath(bookID: saved.id)).path))
        }
        let final = try await AppServices.create(storageRoot: root); Self.repositories.append(final.repository)
        let books = try await final.repository.books()
        XCTAssertEqual(books.map(\.book).sorted { $0.id.uuidString < $1.id.uuidString }, [txt, epub].sorted { $0.id.uuidString < $1.id.uuidString })
    }

    @MainActor func testRealDatabaseFailureKeepsDraftForRetryAndRefreshKeepsLatestMetadata() async throws {
        let (root, services, library) = try await context(), book = try await importedBook(root, services)
        try await services.repository.save(ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([1,2,3]), progression: 0.42))
        await library.refresh(); library.beginCoverEditing(book)
        let editor = try XCTUnwrap(library.coverEditor); editor.selectFile(try image(root)); await editor.waitForLoad()
        let draft = try XCTUnwrap(editor.prepared)
        try sql("CREATE TRIGGER deny_cover BEFORE UPDATE ON books BEGIN SELECT RAISE(ABORT,'cover denied'); END;", root: root)
        let rejected = await editor.save(); XCTAssertFalse(rejected); XCTAssertTrue(editor.errorMessage?.contains("cover denied") == true)
        XCTAssertTrue(editor.prepared?.staged.cover == draft.staged.cover); XCTAssertTrue(library.coverEditor === editor)
        XCTAssertTrue(FileManager.default.fileExists(atPath: draft.staged.originalURL.path))
        let unchanged = try await services.repository.books(); XCTAssertNil(unchanged.first?.book.coverOverride)
        try sql("DROP TRIGGER deny_cover;", root: root)
        _ = try await services.repository.renameBook(book.id, title: "最新书名")
        let overlapping = Task { await library.refresh() }
        let saved = await editor.save(); await overlapping.value
        XCTAssertTrue(saved); XCTAssertNil(library.coverEditor); XCTAssertNil(library.presentedSheet)
        XCTAssertEqual(library.books.first?.book.title, "最新书名"); XCTAssertEqual(library.books.first?.progression, 0.42)
        XCTAssertEqual(library.books.first?.book.coverOverride, draft.staged.cover)
        XCTAssertTrue(FileManager.default.fileExists(atPath: try services.files.resolve(draft.staged.cover.originalPath(bookID: book.id)).path))
    }

    @MainActor func testLateCancelledLoadAndClosedEditorCannotReplaceNewDraftOrSession() async throws {
        let (root, services, library) = try await context(), book = try await importedBook(root, services)
        await library.refresh(); library.beginCoverEditing(book); let editor = try XCTUnwrap(library.coverEditor)
        let service = CoverImportService(files: services.files, repository: services.repository), source = try image(root)
        let old = try await service.prepare(from: source, bookID: book.id), newest = try await service.prepare(from: source, bookID: book.id)
        let gate = CoverGate(), oldTask = try XCTUnwrap(editor.startLoad { await gate.value() })
        await gate.waitForRequest()
        let nextTask = try XCTUnwrap(editor.startLoad { newest }); await nextTask.value
        gate.release(old); await oldTask.value
        XCTAssertEqual(editor.prepared?.staged.cover, newest.staged.cover)
        XCTAssertFalse(FileManager.default.fileExists(atPath: old.staged.originalURL.path)); XCTAssertFalse(editor.isLoading)
        let late = try await service.prepare(from: source, bookID: book.id), secondGate = CoverGate()
        let lateTask = try XCTUnwrap(editor.startLoad { await secondGate.value() }); await secondGate.waitForRequest()
        editor.cancel(); library.beginCoverEditing(book); let newEditor = try XCTUnwrap(library.coverEditor)
        XCTAssertFalse(newEditor === editor)
        secondGate.release(late); await lateTask.value
        editor.receiveFiles(.failure(BookCoverError.invalidImage)); editor.cancel()
        XCTAssertTrue(library.coverEditor === newEditor); XCTAssertNil(newEditor.prepared); XCTAssertNil(newEditor.errorMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: late.staged.originalURL.path))
        newEditor.cancel()
    }

    @MainActor func testFirstFileDelegateCallbackSurvivesWrapperAndInvalidSelectionCanRetry() async throws {
        let (root, services, library) = try await context(), book = try await importedBook(root, services)
        await library.refresh(); library.beginCoverEditing(book); let editor = try XCTUnwrap(library.coverEditor)
        let bad = root.appendingPathComponent("bad.jpg"); try Data("不是图片".utf8).write(to: bad)
        let picker = EPUBDocumentPicker.makePicker(contentTypes: [.image], allowsMultipleSelection: false)
        XCTAssertFalse(picker.allowsMultipleSelection)
        weak var retained: EPUBDocumentPicker.Coordinator?
        autoreleasepool {
            let wrapper = EPUBDocumentPicker(onCompletion: { [weak editor] in editor?.receiveFiles($0) },
                onCoordinatorCreated: { [weak editor] in editor?.retainCoordinator($0) }, contentTypes: [.image], allowsMultipleSelection: false)
            let coordinator = wrapper.makeCoordinator(); picker.delegate = coordinator; retained = coordinator
        }
        XCTAssertNotNil(retained)
        let delegate = try XCTUnwrap(retained)
        delegate.documentPicker(picker, didPickDocumentAt: bad); delegate.documentPicker(picker, didPickDocumentsAt: [try image(root)])
        await editor.waitForLoad(); XCTAssertNotNil(editor.errorMessage); XCTAssertNil(editor.prepared)
        let staging = try services.files.resolve("StagingCovers")
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: staging.path).isEmpty)
        let retry = EPUBDocumentPicker.Coordinator { [weak editor] in editor?.receiveFiles($0) }; editor.retainCoordinator(retry)
        retry.documentPicker(picker, didPickDocumentsAt: [try image(root)]); await editor.waitForLoad()
        XCTAssertNotNil(editor.prepared); XCTAssertNil(editor.errorMessage)
        let empty = EPUBDocumentPicker.Coordinator { [weak editor] in editor?.receiveFiles($0) }; editor.retainCoordinator(empty)
        empty.documentPickerWasCancelled(picker); XCTAssertNotNil(editor.prepared)
        let result = await editor.save(); XCTAssertTrue(result)
    }

    @MainActor func testPhotoFileTransferCopiesBeforeProviderDisappearsAndCancellationPreservesBook() async throws {
        let (root, services, library) = try await context(), book = try await importedBook(root, services), source = try image(root)
        let bytes = try Data(contentsOf: source), transfer = try await CoverPhotoTransferStore.shared.copy(source)
        try FileManager.default.removeItem(at: source)
        XCTAssertEqual(try Data(contentsOf: transfer.staged.originalURL), bytes)
        let service = CoverImportService(files: services.files, repository: services.repository)
        let draft = try await service.prepare(from: transfer.staged.originalURL, bookID: book.id)
        try await CoverPhotoTransferStore.shared.discard(transfer)
        XCTAssertEqual(try Data(contentsOf: draft.staged.originalURL), bytes)
        try await service.discard(draft)
        await library.refresh(); library.beginCoverEditing(book); let editor = try XCTUnwrap(library.coverEditor)
        editor.selectFile(try image(root)); await editor.waitForLoad(); editor.cancel()
        let stored = try await services.repository.books(); XCTAssertEqual(stored.first?.book, book); XCTAssertNil(library.coverEditor)
        XCTAssertTrue(FileManager.default.fileExists(atPath: try services.files.resolve(book.filePath).path))
    }

    @MainActor func testNativeCoverPreviewErrorSavedShelfAndRestoreDefaultSnapshots() async throws {
        let (root, services, model) = try await context(), book = try await importedBook(root, services)
        await model.refresh()
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }, window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: LibraryView(services: services, model: model)); window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil; previous?.makeKey() }
        model.beginCoverEditing(book); try await presentation(window, visible: true)
        let editor = try XCTUnwrap(model.coverEditor)
        editor.selectFile(root.appendingPathComponent("missing.jpg")); await editor.waitForLoad(); XCTAssertNotNil(editor.errorMessage)
        try await snapshot(window, "library-cover-error-build13")
        editor.selectFile(try image(root)); await editor.waitForLoad(); XCTAssertNotNil(editor.prepared)
        try await snapshot(window, "library-cover-preview-build13")
        let saved = await editor.save(); XCTAssertTrue(saved); try await presentation(window, visible: false)
        try await snapshot(window, "library-cover-saved-build13")
        model.beginCoverEditing(try XCTUnwrap(model.books.first?.book)); try await presentation(window, visible: true)
        let reset = try XCTUnwrap(model.coverEditor); reset.restoreDefault(); XCTAssertTrue(reset.hasChanges)
        try await snapshot(window, "library-cover-default-preview-build13")
        let resetSaved = await reset.save(); XCTAssertTrue(resetSaved); try await presentation(window, visible: false)
        XCTAssertNil(model.books.first?.book.coverOverride)
    }

    @MainActor private func presentation(_ window: UIWindow, visible: Bool) async throws {
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            if (window.rootViewController?.presentedViewController != nil) == visible,
               window.rootViewController?.transitionCoordinator == nil { return }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTFail("Native sheet did not reach requested state")
    }
    @MainActor private func snapshot(_ window: UIWindow, _ name: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000); window.layoutIfNeeded()
        var rendered = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in rendered = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) }
        XCTAssertTrue(rendered)
        let attachment = XCTAttachment(image: image); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}

@MainActor private final class CoverGate {
    private var continuation: CheckedContinuation<PreparedCover, Never>?
    private var requested: CheckedContinuation<Void, Never>?
    func value() async -> PreparedCover {
        await withCheckedContinuation { continuation = $0; requested?.resume(); requested = nil }
    }
    func waitForRequest() async {
        if continuation != nil { return }
        await withCheckedContinuation { requested = $0 }
    }
    func release(_ value: PreparedCover) { continuation?.resume(returning: value); continuation = nil }
}
