import SwiftUI
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class DocumentImportTests: XCTestCase {
    @MainActor private final class Presentation: ObservableObject {
        @Published var visible = false
        var pickers: [UIDocumentPickerViewController] = []
    }

    @MainActor private struct PickerHarness: View {
        @ObservedObject var presentation: Presentation
        let model: LibraryViewModel

        var body: some View {
            Text("文件导入回归")
                .modifier(DocumentImportSheet(isPresented: $presentation.visible, model: model))
        }
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

    @MainActor private func mountPicker(model: LibraryViewModel) throws -> (UIWindow, Presentation) {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }
        let presentation = Presentation()
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: PickerHarness(presentation: presentation, model: model))
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        addTeardownBlock {
            await MainActor.run {
                // Retain the actual controllers through host teardown. The
                // remote document browser can still finish XPC layout messages
                // after a synthetic delegate callback dismisses its sheet.
                withExtendedLifetime(presentation.pickers) {
                    window.isHidden = true
                    window.rootViewController = nil
                    previous?.makeKey()
                }
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

    // Use the production SwiftUI sheet and real UIKit delegate, rather than
    // calling importBooks directly. No second presentation or shelf refresh
    // may be needed to transfer the very first selection to the import task.
    @MainActor private func verifyFirstSelection(format: BookFormat) async throws {
        let (root, services, model) = try context()
        let url: URL
        if format == .epub {
            url = try XCTUnwrap(Bundle.main.url(forResource: "chinese-epub3", withExtension: "epub", subdirectory: "Fixtures"))
        } else {
            url = root.appendingPathComponent("首次导入.txt")
            try Data("第一章 起点\n第一次选中的正文。\n第二章 继续\n下一章正文。".utf8).write(to: url)
        }
        let (window, presentation) = try mountPicker(model: model)
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
    }

    @MainActor func testFirstTXTSelectionThroughNativeSheetImportsWithoutRetry() async throws {
        try await verifyFirstSelection(format: .txt)
    }

    @MainActor func testFirstEPUBSelectionThroughNativeSheetImportsWithoutRetry() async throws {
        try await verifyFirstSelection(format: .epub)
    }

    @MainActor func testNativeSheetCancellationAndEmptySelectionCanRetryWithoutStaleFiles() async throws {
        let (_, _, model) = try context()
        let (window, presentation) = try mountPicker(model: model)
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
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
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
