import Foundation
import CoreText
import CryptoKit
import ReadingInterfaces
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReadingFontTests: XCTestCase {
    func testTransparentDecodedPreviewCacheReusesSixFacesAndBoundsPixelMemory() async throws {
        let renderer = ReadingFontPreviewRenderer()
        var requests: [ReadingFontPreviewRequest] = []
        var originals: [CGImage] = []
        for item in BundledReadingFont.allCases {
            let resource = try item.resource()
            let request = ReadingFontPreviewRequest(fileURL: resource.fileURL, identity: resource.asset.sha256,
                systemFont: "original", textRGB: 0, backgroundRGB: 0, pointSize: 19, compact: true)
            let image = try await renderer.image(request)
            let pixels = try XCTUnwrap(image.dataProvider?.data) as Data
            XCTAssertEqual(image.bitsPerPixel, 32)
            let alpha = stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
            XCTAssertEqual(alpha.min(), 0); XCTAssertEqual(alpha.max(), 255)
            XCTAssertEqual(pixels[3], 0, "The corner must blend into its native parent")
            requests.append(request); originals.append(image)
        }
        for _ in 0..<4 {
            for (request, original) in zip(requests, originals) {
                let revisited = try await renderer.image(request)
                XCTAssertTrue(revisited === original, "Returning to a font row must reuse drawn pixels")
            }
        }
        let drawings = await renderer.drawingCount
        XCTAssertEqual(drawings, 6, "Repeated list browsing must not reparse/redraw the six faces")
        let resource = try BundledReadingFont.wenKai.resource()
        for index in 0..<20 {
            let request = ReadingFontPreviewRequest(fileURL: resource.fileURL, identity: resource.asset.sha256,
                systemFont: "original", textRGB: index, backgroundRGB: 0, pointSize: 48, compact: false)
            let image = try await renderer.image(request)
            let pixels = try XCTUnwrap(image.dataProvider?.data) as Data
            XCTAssertEqual(pixels[3], 0, "The large sample must also have no rectangular background")
            let footprint = await renderer.cacheFootprint()
            XCTAssertLessThanOrEqual(footprint.images, 12)
            XCTAssertLessThanOrEqual(footprint.bytes, 8 * 1_024 * 1_024)
        }
    }

    func testActualNativePreviewImagesDifferAcrossSixFontsAndInvalidInputIsVisible() async throws {
        let renderer = ReadingFontPreviewRenderer()
        var digests = Set<String>()
        XCTAssertEqual(BundledReadingFont.allCases.count, 6)
        for item in BundledReadingFont.allCases {
            let resource = try item.resource()
            let request = ReadingFontPreviewRequest(fileURL: resource.fileURL, identity: resource.asset.sha256,
                systemFont: "original", textRGB: 0x303832, backgroundRGB: 0xF8F5ED, pointSize: 22, compact: false)
            let png = try await renderer.render(request), cached = try await renderer.render(request)
            XCTAssertEqual(png, cached)
            let image = try XCTUnwrap(UIImage(data: png)), cg = try XCTUnwrap(image.cgImage)
            XCTAssertEqual(cg.width, 900); XCTAssertGreaterThan(cg.height, 50)
            let pixels = try XCTUnwrap(cg.dataProvider?.data) as Data
            XCTAssertGreaterThan(Set(pixels).count, 20, "Real glyph ink must be present")
            XCTAssertTrue(digests.insert(SHA256.hash(data: png).map { String(format: "%02x", $0) }.joined()).inserted)
            let attachment = XCTAttachment(image: image); attachment.name = "font-settings-sample-\(item.rawValue)-build24"
            attachment.lifetime = .keepAlways; add(attachment)
        }
        let compactResource = try BundledReadingFont.wenKai.resource()
        let compactRequest = ReadingFontPreviewRequest(fileURL: compactResource.fileURL, identity: compactResource.asset.sha256,
            systemFont: "original", textRGB: 0x303832, backgroundRGB: 0xF8F5ED, pointSize: 19, compact: true)
        let compactPNG = try await renderer.render(compactRequest)
        let compactCG = try XCTUnwrap(UIImage(data: compactPNG)?.cgImage)
        let compactPixels = try XCTUnwrap(compactCG.dataProvider?.data) as Data
        XCTAssertEqual(compactCG.bitsPerPixel, 32)
        let alphas = stride(from: 3, to: compactPixels.count, by: 4).map { compactPixels[$0] }
        XCTAssertEqual(alphas.min(), 0, "Font rows blend into their native card instead of an opaque rectangle")
        XCTAssertEqual(alphas.max(), 255, "Transparent samples must retain visible glyph ink")
        let bad = ReadingFontPreviewRequest(fileURL: URL(fileURLWithPath: "/missing/font.ttf"), identity: "missing",
            systemFont: "original", textRGB: 0, backgroundRGB: 0xFFFFFF, pointSize: 20, compact: false)
        do { _ = try await renderer.render(bad); XCTFail("No system-font masquerade for a missing file") }
        catch { XCTAssertTrue(error is ReadingFontPreviewError) }
    }
    static func chineseFontScript(_ family: String, paragraph: String) -> String {
        """
        (()=>{const f='\(family)',p=document.querySelector('\(paragraph)');
        if(!p||!getComputedStyle(p).fontFamily.includes(f)||!Array.from(document.fonts).some(x=>x.family.includes(f)&&x.status==='loaded'))return false;
        function signature(font){const c=document.createElement('canvas');c.width=450;c.height=80;
          const g=c.getContext('2d');g.font='30px '+font;g.fillText('山风云海问道修仙',4,45);
          const d=g.getImageData(0,0,c.width,c.height).data;let n=0;for(let i=3;i<d.length;i+=4)n=(n+d[i]*(i%251+1))>>>0;return n;}
        const actual=signature(f);return actual>0&&actual!==signature('serif');})()
        """
    }
    func testBundledChineseOriginalFontsHaveGlyphsLicensesAndDoNotUseImportSlots() async throws {
        let services = try await self.services()
        for item in BundledReadingFont.allCases {
            let resource = try item.resource(), asset = resource.asset
            let data = try Data(contentsOf: resource.fileURL)
            XCTAssertEqual(Int64(data.count), asset.bytes)
            XCTAssertEqual(SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(), asset.sha256)
            let license = try XCTUnwrap(Bundle.main.url(forResource: item.fileName + "-OFL", withExtension: "txt", subdirectory: "Fonts"))
            XCTAssertTrue(try String(contentsOf: license, encoding: .utf8).contains("SIL OPEN FONT LICENSE"))
            let descriptors = try XCTUnwrap(CTFontManagerCreateFontDescriptorsFromURL(resource.fileURL as CFURL) as? [CTFontDescriptor])
            XCTAssertEqual(descriptors.count, 1)
            let font = CTFontCreateWithFontDescriptor(try XCTUnwrap(descriptors.first), 30, nil)
            let text = Array("山风云海问道修仙，。".utf16)
            var glyphs = [CGGlyph](repeating: 0, count: text.count)
            XCTAssertTrue(CTFontGetGlyphsForCharacters(font, text, &glyphs, text.count))
            XCTAssertTrue(glyphs.allSatisfy { $0 != 0 })
            XCTAssertNotNil(CTFontCreatePathForGlyph(font, glyphs[0], nil))
        }
        let imported = try await services.files.readingFonts()
        XCTAssertTrue(imported.isEmpty)
    }
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
        await model.saveNow(); model.close()
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
        let source = try fixture()
        let importTask = Task { await model.importReadingFont(from: source) }
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
