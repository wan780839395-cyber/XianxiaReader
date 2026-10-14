import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class DocumentImportTests: XCTestCase {
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
