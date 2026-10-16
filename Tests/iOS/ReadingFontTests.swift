import Foundation
import ReadingInterfaces
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReadingFontTests: XCTestCase {
    private func fixture() throws -> URL {
        try XCTUnwrap(Bundle(for: Self.self).url(forResource: "iAWriterDuospace-Regular", withExtension: "ttf", subdirectory: "Fixtures/Fonts"))
    }
    private func services() async throws -> AppServices {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let services = try await AppServices.create(storageRoot: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return services
    }

    func testRealCoreTextFileValidationDuplicateAndOriginalBytesPreserved() async throws {
        let services = try await self.services(), url = try fixture(), original = try Data(contentsOf: url)
        let service = ReadingFontImportService(files: services.files)
        let font = try await service.importFont(from: url)
        XCTAssertFalse(font.displayName.isEmpty); XCTAssertEqual(font.bytes, Int64(original.count))
        let duplicate = try await service.importFont(from: url); XCTAssertEqual(duplicate, font)
        let saved = try await services.files.readingFontURL(font)
        XCTAssertEqual(try Data(contentsOf: saved), original)
        XCTAssertEqual(try Data(contentsOf: url), original)
        let list = try await services.files.readingFonts(); XCTAssertEqual(list, [font])
        let broken = services.files.root.appendingPathComponent("fake.ttf")
        for bytes in [Data("not a font".utf8), Data([0, 1, 0, 0, 0, 0]), Data("ttcfbad-collection".utf8)] {
            try bytes.write(to: broken)
            do { _ = try await service.importFont(from: broken); XCTFail("Invalid font must fail") } catch { XCTAssertTrue(error is ReadingFontError) }
        }
        let after = try await services.files.readingFonts(); XCTAssertEqual(after, [font])
    }

    @MainActor func testFontImportRebuildFullAnchorSaveResetAndMissingAssetFallback() async throws {
        let services = try await self.services(), book = Book(title: "字体生命周期", format: .epub, filePath: "Books/test/book.epub")
        try await services.repository.insert(book, chapters: [])
        let engine = FontEngine(), model = ReaderViewModel(book: book, services: services, factory: FontFactory(engine: engine))
        await model.open()
        let origin = ReadingPosition(bookID: book.id, engineID: "test", locatorVersion: 7, locatorData: Data([1, 3, 5, 7]), progression: 0.43)
        engine.currentPosition = origin
        await model.importReadingFont(from: try fixture())
        XCTAssertEqual(engine.opens, 2); XCTAssertEqual(engine.currentPosition, origin)
        let font = try XCTUnwrap(model.importedFonts.first)
        XCTAssertEqual(model.appearance.importedFontID, font.id); XCTAssertFalse(model.fontBusy)
        await model.saveNow()
        let saved = try await services.files.readingAppearance(); XCTAssertEqual(saved.importedFontID, font.id)
        model.selectBuiltInFont(.serif); await model.saveNow()
        XCTAssertNil(model.appearance.importedFontID); XCTAssertEqual(engine.appearance?.font, .serif)
        model.selectImportedFont(font.id); await model.saveNow(); model.close()
        let fontURL = try await services.files.readingFontURL(font)
        try FileManager.default.removeItem(at: fontURL)
        await model.open()
        XCTAssertTrue(model.isReady); XCTAssertEqual(model.appearance.importedFontID, font.id)
        XCTAssertNil(engine.appearance?.importedFontID); XCTAssertNotNil(model.fontMessage)
        XCTAssertEqual(engine.currentPosition?.locatorData, origin.locatorData)
        model.close()
    }

    @MainActor func testFontCaptureFailureDoesNotCloseReaderAndReimportRetries() async throws {
        let services = try await self.services(), book = Book(title: "字体重试", format: .epub, filePath: "Books/test/book.epub")
        try await services.repository.insert(book, chapters: [])
        let engine = FontEngine(), model = ReaderViewModel(book: book, services: services, factory: FontFactory(engine: engine))
        await model.open(); engine.currentPosition = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([9]))
        engine.failCapture = true
        await model.importReadingFont(from: try fixture())
        XCTAssertEqual(engine.opens, 1); XCTAssertTrue(model.isReady); XCTAssertNil(model.appearance.importedFontID)
        XCTAssertEqual(model.importedFonts.count, 1); XCTAssertNotNil(model.fontMessage)
        engine.failCapture = false
        await model.importReadingFont(from: try fixture())
        XCTAssertEqual(engine.opens, 2); XCTAssertEqual(model.importedFonts.count, 1); XCTAssertNotNil(model.appearance.importedFontID)
        model.close()
    }

    @MainActor func testFontCaptureCloseReopenLateResultCannotRebuildNewReader() async throws {
        let services = try await self.services(), book = Book(title: "迟到字体", format: .epub, filePath: "Books/test/book.epub")
        try await services.repository.insert(book, chapters: [])
        let engine = FontEngine(), model = ReaderViewModel(book: book, services: services, factory: FontFactory(engine: engine))
        await model.open()
        let origin = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([5]))
        engine.currentPosition = origin; engine.suspendCapture = true
        let started = expectation(description: "font capture suspended")
        engine.onCapture = { started.fulfill() }
        let importTask = Task { await model.importReadingFont(from: try fixture()) }
        await fulfillment(of: [started], timeout: 10)
        model.close(); engine.suspendCapture = false; engine.onCapture = nil
        await model.open(); let newCloses = engine.closes
        engine.pendingCapture?.resume(returning: origin); engine.pendingCapture = nil
        await importTask.value
        XCTAssertEqual(engine.opens, 2); XCTAssertEqual(engine.closes, newCloses)
        XCTAssertTrue(model.isReady); XCTAssertFalse(model.fontBusy); XCTAssertFalse(model.navigationInProgress)
        XCTAssertNil(model.appearance.importedFontID); model.close()
    }

    @MainActor private struct FontFactory: ReaderEngineFactory {
        let engine: FontEngine
        func makeEngine(for format: BookFormat) throws -> any ReaderEngine { engine }
    }
    @MainActor private final class FontEngine: ReaderEngine, ReaderAppearanceProviding, ReaderFontProviding {
        var fontProvider: (any ReaderFontProviding)? { self }
        var appearanceProvider: (any ReaderAppearanceProviding)? { self }
        var supportsTextAppearance: Bool { true }
        var viewController = UIViewController()
        var currentPosition: ReadingPosition?
        var onPositionChanged: ((ReadingPosition) -> Void)?
        var onCenterTap: (() -> Void)?
        var onError: ((String) -> Void)?
        var appearance: ReadingAppearance?
        var fonts: [ReaderFontResource] = []
        var opens = 0, closes = 0
        var failCapture = false, suspendCapture = false
        var onCapture: (() -> Void)?
        var pendingCapture: CheckedContinuation<ReadingPosition, Error>?
        func setReadingFonts(_ fonts: [ReaderFontResource]) throws { self.fonts = fonts }
        func setAppearance(_ appearance: ReadingAppearance) throws { self.appearance = appearance }
        func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws { opens += 1; currentPosition = position }
        func close() { closes += 1; currentPosition = nil }
        func captureCurrentPosition() async throws -> ReadingPosition {
            if failCapture { throw ReaderPositionCaptureError.unavailable }
            if suspendCapture { return try await withCheckedThrowingContinuation { pendingCapture = $0; onCapture?() } }
            return try XCTUnwrap(currentPosition)
        }
        func turnPage(forward: Bool) async {}
        func go(to chapter: Chapter) async throws {}
        func go(to position: ReadingPosition) async throws { currentPosition = position }
        func setScrolling(_ enabled: Bool) {}
    }
}
