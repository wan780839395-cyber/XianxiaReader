import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class DocumentImportTests: XCTestCase {
    // Native document services can send XPC layout messages after UIKit's public
    // dismissal completion. Retain the COMPLETE hidden host tree for this test
    // worker, not only the picker controllers; never access private proxy APIs.
    // Only six fixed full-Library fixtures are mounted in this suite.
    @MainActor private static var nativeHosts: [(UIWindow, Presentation)] = []
    @MainActor private static let sessionRoot = FileManager.default.temporaryDirectory
        .appendingPathComponent("DocumentImportFixtureSession-\(UUID().uuidString)")
    @MainActor private final class Presentation {
        let model: LibraryViewModel
        var pickers: [UIDocumentPickerViewController] = []
        var visible: Bool {
            get { model.presentedSheet == .importFiles }
            set { model.presentedSheet = newValue ? .importFiles : nil }
        }
        init(model: LibraryViewModel) { self.model = model }
    }

    private enum PresentationFailure: Error { case timedOut(String) }

    @MainActor private func waitFor(_ description: String, until ready: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(15)
        while Date() < deadline {
            if ready() { return }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        throw PresentationFailure.timedOut(description)
    }

    @MainActor private func mountPicker(services: AppServices, model: LibraryViewModel) throws -> (UIWindow, Presentation) {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }
        let presentation = Presentation(model: model)
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: LibraryView(services: services, model: model).environmentObject(FontDocumentInbox()))
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        Self.nativeHosts.append((window,presentation))
        addTeardownBlock {
            await MainActor.run {
                window.isHidden = true
                previous?.makeKey()
            }
        }
        return (window, presentation)
    }

    @MainActor private func findPicker(in controller: UIViewController?) -> UIDocumentPickerViewController? {
        guard let controller else { return nil }
        if let picker = controller as? UIDocumentPickerViewController { return picker }
        if let picker = findPicker(in: controller.presentedViewController) { return picker }
        for child in controller.children {
            if let picker = findPicker(in: child) { return picker }
        }
        return nil
    }

    @MainActor private func presentPicker(window: UIWindow, presentation: Presentation) async throws -> UIDocumentPickerViewController {
        presentation.visible = true
        try await waitFor("document picker presentation") {
            guard let picker = self.findPicker(in: window.rootViewController),
                  let presented = window.rootViewController?.presentedViewController else { return false }
            return picker.view.window != nil && !picker.isBeingPresented && !presented.isBeingPresented
                && picker.transitionCoordinator == nil && presented.transitionCoordinator == nil
        }
        let picker = try XCTUnwrap(findPicker(in: window.rootViewController))
        presentation.pickers.append(picker)
        return picker
    }

    @MainActor private func waitForDismissal(window: UIWindow, picker: UIDocumentPickerViewController) async throws {
        // presentedViewController can be cleared before its disappearing view
        // and transition have finished. Do not tear down or re-present yet.
        try await waitFor("document picker fully dismissed") {
            window.rootViewController?.presentedViewController == nil
                && window.rootViewController?.transitionCoordinator == nil
                && picker.transitionCoordinator == nil && picker.viewIfLoaded?.window == nil
        }
    }

    @MainActor private func attachShelf(_ window: UIWindow, name: String) {
        window.layoutIfNeeded()
        var rendered = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            rendered = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        XCTAssertTrue(rendered)
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // Mount the entire production LibraryView, including its navigation,
    // encoding sheet, reader cover and feedback, not a single-sheet Text view.
    @MainActor private func verifyFirstSelection(format: BookFormat) async throws {
        let (root, services, model) = try context()
        let url: URL
        if format == .epub {
            url = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        } else {
            url = root.appendingPathComponent("首次导入.txt")
            try Data("第一章 起点\n第一次选中的正文。\n第二章 继续\n下一章正文。".utf8).write(to: url)
        }
        let (window, presentation) = try mountPicker(services: services, model: model)
        let picker = try await presentPicker(window: window, presentation: presentation)
        let delegate = try XCTUnwrap(picker.delegate)
        delegate.documentPicker?(picker, didPickDocumentsAt: [url])
        try await waitForDismissal(window: window, picker: picker)
        try await waitFor("first selection committed and displayed") { model.books.count == 1 && !model.isImporting }
        XCTAssertFalse(presentation.visible)
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.importStatus, "已导入 1 本书")
        let book = try XCTUnwrap(model.books.first?.book)
        XCTAssertEqual(book.format, format)
        let stored = try await services.repository.books()
        XCTAssertEqual(stored.map(\.book.id), [book.id])
        let original = try Data(contentsOf: url)
        XCTAssertEqual(try Data(contentsOf: services.files.resolve(book.filePath)), original)
        if format == .txt { attachShelf(window, name: "library-first-txt-success") }
    }

    @MainActor func testFirstTXTSelectionThroughNativeSheetImportsWithoutRetry() async throws {
        try await verifyFirstSelection(format: .txt)
    }

    @MainActor func testFirstEPUBSelectionThroughNativeSheetImportsWithoutRetry() async throws {
        try await verifyFirstSelection(format: .epub)
    }

    @MainActor func testNativeSheetCancellationAndEmptySelectionCanRetryWithoutStaleFiles() async throws {
        let (_, services, model) = try context()
        let (window, presentation) = try mountPicker(services: services, model: model)
        let cancelled = try await presentPicker(window: window, presentation: presentation)
        let cancelledDelegate = try XCTUnwrap(cancelled.delegate)
        cancelledDelegate.documentPickerWasCancelled?(cancelled)
        try await waitForDismissal(window: window, picker: cancelled)
        XCTAssertTrue(model.books.isEmpty)
        XCTAssertNil(model.importStatus)
        let empty = try await presentPicker(window: window, presentation: presentation)
        let emptyDelegate = try XCTUnwrap(empty.delegate)
        emptyDelegate.documentPicker?(empty, didPickDocumentsAt: [])
        try await waitForDismissal(window: window, picker: empty)
        try await waitFor("empty picker error after dismissal") {
            window.rootViewController?.presentedViewController == nil && model.errorMessage != nil
        }
        XCTAssertEqual(model.errorMessage, ImportError.noFilesSelected.localizedDescription)
        let sample = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        let retry = try await presentPicker(window: window, presentation: presentation)
        let retryDelegate = try XCTUnwrap(retry.delegate)
        cancelledDelegate.documentPicker?(cancelled, didPickDocumentsAt: [sample])
        XCTAssertTrue(model.books.isEmpty)
        retryDelegate.documentPicker?(retry, didPickDocumentsAt: [sample])
        try await waitForDismissal(window: window, picker: retry)
        try await waitFor("retry imports exactly once") { model.books.count == 1 && !model.isImporting }
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.importStatus, "已导入 1 本书")
    }

    @MainActor func testPickerDeliversSelectedFilesOnceAndIgnoresLateCancellation() throws {
        let urls = [URL(fileURLWithPath: "/tmp/first.epub"), URL(fileURLWithPath: "/tmp/second.epub")]
        var received: [[URL]] = []
        let coordinator = EPUBDocumentPicker.Coordinator { result in
            switch result {
            case .success(let selected): received.append(selected)
            default: XCTFail("Expected picked URLs")
            }
        }
        let picker = EPUBDocumentPicker.makePicker()
        XCTAssertTrue(picker.allowsMultipleSelection)
        coordinator.documentPicker(picker, didPickDocumentsAt: urls)
        coordinator.documentPicker(picker, didPickDocumentsAt: urls)
        coordinator.documentPickerWasCancelled(picker)
        XCTAssertEqual(received, [urls])
    }

    @MainActor func testSingleURLDelegateDeliversOnceAndIgnoresDuplicateArrayAndCancel() {
        let url = URL(fileURLWithPath: "/tmp/legacy.epub")
        var received: [[URL]] = []
        let coordinator = EPUBDocumentPicker.Coordinator { result in
            if case .success(let urls) = result { received.append(urls) }
            else { XCTFail("Expected the selected URL") }
        }
        let picker = EPUBDocumentPicker.makePicker()
        coordinator.documentPicker(picker, didPickDocumentAt: url)
        coordinator.documentPicker(picker, didPickDocumentsAt: [url])
        coordinator.documentPickerWasCancelled(picker)
        XCTAssertEqual(received, [[url]])
    }

    @MainActor func testSelectionStartsImportWithoutAnySheetDismissalCallback() async throws {
        for format in [BookFormat.txt, .epub] {
            let (root, services, model) = try context()
            let url: URL
            if format == .txt {
                url = root.appendingPathComponent("直接交接.txt")
                try Data("第一章 起点\n首次回调直接交给导入任务。".utf8).write(to: url)
            } else {
                url = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
            }
            model.presentedSheet = .importFiles
            let coordinator = EPUBDocumentPicker.Coordinator(onCompletion: model.receivePickedDocuments)
            let picker = EPUBDocumentPicker.makePicker()
            coordinator.documentPicker(picker, didPickDocumentsAt: [url])
            // Intentionally no sheet, onDismiss, refresh, or second selection.
            // Build6 queued this result indefinitely without finishPicking.
            try await waitFor("selected file imports independently of dismissal") { model.books.count == 1 && !model.isImporting }
            XCTAssertNil(model.presentedSheet)
            XCTAssertNil(model.errorMessage)
            XCTAssertEqual(model.importStatus, "已导入 1 本书")
            coordinator.documentPicker(picker, didPickDocumentAt: url)
            coordinator.documentPickerWasCancelled(picker)
            let stored = try await services.repository.books()
            XCTAssertEqual(stored.count, 1)
        }
    }

    @MainActor func testShelfOwnsPickerDelegateUntilTerminalEventWithoutRetainCycle() async throws {
        let (root, _, model) = try context()
        let url = root.appendingPathComponent("延迟回调.txt")
        try Data("第一章 起点\n选择器销毁后的交接。".utf8).write(to: url)
        let picker = EPUBDocumentPicker.makePicker()
        weak var weakDelegate: EPUBDocumentPicker.Coordinator?
        do {
            let wrapper = EPUBDocumentPicker(
                onCompletion: { [weak model] result in model?.receivePickedDocuments(result) },
                onCoordinatorCreated: { [weak model] coordinator in model?.retainPickerCoordinator(coordinator) }
            )
            let coordinator = wrapper.makeCoordinator()
            weakDelegate = coordinator
            picker.delegate = coordinator
        }
        // The wrapper/context owner is now gone; UIKit itself keeps only a
        // weak delegate. The shelf must keep the first callback deliverable.
        XCTAssertNotNil(weakDelegate)
        XCTAssertNotNil(picker.delegate)
        let stale = try XCTUnwrap(weakDelegate)
        do {
            let replacement = EPUBDocumentPicker(
                onCompletion: { [weak model] result in model?.receivePickedDocuments(result) },
                onCoordinatorCreated: { [weak model] coordinator in model?.retainPickerCoordinator(coordinator) }
            ).makeCoordinator()
            weakDelegate = replacement
            picker.delegate = replacement
        }
        stale.documentPicker(picker, didPickDocumentsAt: [url])
        XCTAssertTrue(model.books.isEmpty)
        XCTAssertFalse(model.isImporting, "A replaced coordinator must not start a late import")
        weakDelegate?.documentPicker(picker, didPickDocumentsAt: [url])
        XCTAssertNil(weakDelegate, "Terminal delivery must release the shelf's delegate owner")
        try await waitFor("delegate survives context teardown") { model.books.count == 1 && !model.isImporting }
        XCTAssertNil(model.errorMessage)
    }

    @MainActor func testFirstPickerCallbackAfterFullLibraryDismissalStillImports() async throws {
        let (root, services, model) = try context()
        let url = root.appendingPathComponent("关闭后回调.txt")
        try Data("第一章 起点\n系统先关闭选择器也不能丢选中的书。".utf8).write(to: url)
        let (window, presentation) = try mountPicker(services: services, model: model)
        let picker = try await presentPicker(window: window, presentation: presentation)
        weak var callback = picker.delegate as? EPUBDocumentPicker.Coordinator
        model.presentedSheet = nil
        try await waitForDismissal(window: window, picker: picker)
        XCTAssertNotNil(callback, "The real coordinator must outlive the dismissed representable")
        // No strong local delegate and no onDismiss import path.
        callback?.documentPicker(picker, didPickDocumentsAt: [url])
        try await waitFor("first selection delivered after dismissal") { model.books.count == 1 && !model.isImporting }
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.importStatus, "已导入 1 本书")
        let stored = try await services.repository.books()
        XCTAssertEqual(stored.count, 1)
    }

    @MainActor func testFirstInvalidSelectionInFullLibraryShowsFeedbackAndCanRetry() async throws {
        let (root, services, model) = try context()
        let bad = root.appendingPathComponent("unsupported.pdf")
        try Data("not a supported book".utf8).write(to: bad)
        let (window, presentation) = try mountPicker(services: services, model: model)
        let picker = try await presentPicker(window: window, presentation: presentation)
        let delegate = try XCTUnwrap(picker.delegate)
        delegate.documentPicker?(picker, didPickDocumentsAt: [bad])
        try await waitForDismissal(window: window, picker: picker)
        try await waitFor("first invalid selection reports error") { model.errorMessage != nil && !model.isImporting }
        XCTAssertTrue(model.errorMessage?.contains("unsupported.pdf") == true)
        XCTAssertTrue(model.books.isEmpty)
        XCTAssertNil(model.importStatus)
        XCTAssertNil(window.rootViewController?.presentedViewController, "Feedback must not need a second modal")
        attachShelf(window, name: "library-first-import-error")
        let good = root.appendingPathComponent("再次选择.txt")
        try Data("第一章 起点\n失败后的首次有效选择。".utf8).write(to: good)
        let retry = try await presentPicker(window: window, presentation: presentation)
        let retryDelegate = try XCTUnwrap(retry.delegate)
        retryDelegate.documentPicker?(retry, didPickDocumentsAt: [good])
        try await waitForDismissal(window: window, picker: retry)
        try await waitFor("retry after visible error") { model.books.count == 1 && !model.isImporting }
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.importStatus, "已导入 1 本书")
    }

    @MainActor func testFirstFileSelectionWithExistingShelfAndEncodingSheetRoundTrip() async throws {
        let (root, services, model) = try context()
        let original = root.appendingPathComponent("已有书籍.txt")
        try Data("第一章 旧书\n既有书库必须保留。".utf8).write(to: original)
        await model.importBooks([original])
        let originalID = try XCTUnwrap(model.books.first?.id)
        let (window, presentation) = try mountPicker(services: services, model: model)
        let added = root.appendingPathComponent("首次选择.txt")
        try Data("第一章 新书\n有书库时的第一次文件导入。".utf8).write(to: added)
        let picker = try await presentPicker(window: window, presentation: presentation)
        let delegate = try XCTUnwrap(picker.delegate)
        delegate.documentPicker?(picker, didPickDocumentsAt: [added])
        try await waitForDismissal(window: window, picker: picker)
        try await waitFor("first import on populated shelf") { model.books.count == 2 && !model.isImporting }
        XCTAssertTrue(model.books.contains { $0.id == originalID })
        model.presentedSheet = .txtEncoding
        try await waitFor("encoding sheet presentation") {
            window.rootViewController?.presentedViewController?.view.window != nil
                && window.rootViewController?.presentedViewController?.transitionCoordinator == nil
        }
        XCTAssertNil(findPicker(in: window.rootViewController))
        model.txtEncoding = .gb18030
        model.presentedSheet = nil
        try await waitFor("encoding sheet dismissal") {
            window.rootViewController?.presentedViewController == nil
                && window.rootViewController?.transitionCoordinator == nil
        }
        XCTAssertEqual(model.txtEncoding, .gb18030)
        model.txtEncoding = .automatic
        let afterEncoding = try await presentPicker(window: window, presentation: presentation)
        let afterDelegate = try XCTUnwrap(afterEncoding.delegate)
        afterDelegate.documentPickerWasCancelled?(afterEncoding)
        try await waitForDismissal(window: window, picker: afterEncoding)
        XCTAssertEqual(model.books.count, 2)
    }

    @MainActor func testCancelledPickerCannotStartImportWithLateFiles() {
        var callbacks = 0
        let coordinator = EPUBDocumentPicker.Coordinator { result in
            callbacks += 1
            XCTAssertNil(result)
        }
        let picker = EPUBDocumentPicker.makePicker()
        coordinator.documentPickerWasCancelled(picker)
        coordinator.documentPicker(picker, didPickDocumentsAt: [URL(fileURLWithPath: "/tmp/late.epub")])
        XCTAssertEqual(callbacks, 1)
    }

    @MainActor func testEmptyPickerCallbackExplainsMissingFile() {
        var message: String?
        let coordinator = EPUBDocumentPicker.Coordinator { result in
            if case .failure(let error) = result { message = error.localizedDescription }
            else { XCTFail("Empty selection must produce a visible error") }
        }
        coordinator.documentPicker(EPUBDocumentPicker.makePicker(), didPickDocumentsAt: [])
        XCTAssertEqual(message, ImportError.noFilesSelected.localizedDescription)
    }

    @MainActor private func context() throws -> (URL, AppServices, LibraryViewModel) {
        let root = Self.sessionRoot.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at:root,withIntermediateDirectories:true)
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        // Mounted hosts intentionally keep repositories alive until the worker
        // exits. Its temporary sandbox is reclaimed with that test process;
        // unlinking library.sqlite here would violate SQLite's open-file lifetime.
        let services = AppServices(repository: repository, files: files)
        return (root, services, LibraryViewModel(services: services))
    }

    @MainActor func testBroadPickerImportsTXTAndUppercaseEPUBRejectsUnsupportedFileInSameBatch() async throws {
        let (root, services, model) = try context()
        let valid = root.appendingPathComponent("local-copy.EPUB")
        let sample = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        try FileManager.default.copyItem(at: sample, to: valid)
        let txt = root.appendingPathComponent("novel.txt")
        try Data("第一章 测试".utf8).write(to: txt)
        let unsupported = root.appendingPathComponent("unsupported.pdf")
        try Data("not a supported book".utf8).write(to: unsupported)
        await model.importBooks([txt, unsupported, valid])
        XCTAssertEqual(model.books.count, 2)
        let epub = try XCTUnwrap(model.books.first { $0.book.format == .epub })
        XCTAssertEqual(epub.book.title, "云海问道·测试样书")
        XCTAssertEqual(model.importStatus, "已导入 2 本书")
        XCTAssertTrue(model.errorMessage?.contains("unsupported.pdf") == true)
        XCTAssertFalse(model.isImporting)
        let chapters = try await services.repository.chapters(for: epub.book.id)
        XCTAssertEqual(chapters.count, 2)
        XCTAssertEqual(try String(contentsOf: txt, encoding: .utf8), "第一章 测试")
        XCTAssertTrue(FileManager.default.fileExists(atPath: valid.path))
    }

    @MainActor func testBundledSamplesImportWithoutFileProvider() async throws {
        let (_, services, model) = try context()
        await model.importSamples()
        XCTAssertEqual(model.books.count, 2)
        XCTAssertEqual(model.importStatus, "已导入 2 本书")
        XCTAssertFalse(model.isImporting)
        for summary in model.books {
            let chapters = try await services.repository.chapters(for: summary.book.id)
            XCTAssertEqual(chapters.count, 2)
            XCTAssertTrue(FileManager.default.fileExists(atPath: try services.files.resolve(summary.book.filePath).path))
        }
    }

    @MainActor func testEmptyBatchReportsErrorAndCanRetryWithSamples() async throws {
        let (_, _, model) = try context()
        await model.importBooks([])
        XCTAssertEqual(model.errorMessage, ImportError.noFilesSelected.localizedDescription)
        XCTAssertFalse(model.isImporting)
        await model.importSamples()
        XCTAssertEqual(model.books.count, 2)
        XCTAssertEqual(model.importStatus, "已导入 2 本书")
        XCTAssertNotEqual(model.errorMessage, ImportError.noFilesSelected.localizedDescription)
    }
}
