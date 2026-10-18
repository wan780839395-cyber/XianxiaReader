import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReadingExperienceTests: XCTestCase {
    @MainActor func testFullChineseFontValidationRecordsStreamingCostWithoutChangingIdentity() async throws {
        let services = try await services(), original = try BundledReadingFont.wenKai.resource()
        let begin = ProcessInfo.processInfo.systemUptime
        let font = try await ReadingFontImportService(files: services.files).importFont(from: original.fileURL)
        let importSeconds = ProcessInfo.processInfo.systemUptime - begin
        let validationStart = ProcessInfo.processInfo.systemUptime
        for _ in 0..<3 {
            let url = try await services.files.readingFontURL(font)
            XCTAssertEqual(url.lastPathComponent, "font.ttf")
        }
        let validationSeconds = ProcessInfo.processInfo.systemUptime - validationStart
        XCTAssertEqual(font.sha256, original.asset.sha256); XCTAssertEqual(font.bytes, original.asset.bytes)
        print("Chinese font streaming SHA: bytes=\(font.bytes) importSeconds=\(importSeconds) threeValidationsSeconds=\(validationSeconds)")
        let fonts = try await services.files.readingFonts(); XCTAssertEqual(fonts, [font])
    }

    private func services() async throws -> AppServices {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        return try await AppServices.create(storageRoot: root)
    }
    private func fixture() throws -> URL {
        try XCTUnwrap(Bundle.main.url(forResource: "iAWriterDuospace-Regular", withExtension: "ttf", subdirectory: "Fixtures/Fonts"))
    }

    @MainActor func testColdFontDocumentQueuesUntilServicesAndDeduplicatesWithoutSelecting() async throws {
        let services = try await services(), url = try fixture(), original = try Data(contentsOf: url)
        var appearance = ReadingAppearance(); appearance.theme = .charcoal; appearance.fontScale = 1.6
        try await services.files.saveReadingAppearance(appearance)
        let inbox = FontDocumentInbox()
        inbox.receive(url); inbox.receive(url)
        XCTAssertTrue(inbox.importing)
        let before = try await services.files.readingFonts(); XCTAssertTrue(before.isEmpty)
        inbox.attach(files: services.files); await inbox.waitUntilIdle()
        let fonts = try await services.files.readingFonts()
        XCTAssertEqual(fonts.count, 1); XCTAssertFalse(inbox.importing); XCTAssertNil(inbox.failure)
        XCTAssertTrue(try XCTUnwrap(inbox.message).contains(try XCTUnwrap(fonts.first).displayName))
        let unchanged = try await services.files.readingAppearance(); XCTAssertEqual(unchanged, appearance)
        XCTAssertEqual(try Data(contentsOf: url), original)
        let saved = try await services.files.readingFontURL(try XCTUnwrap(fonts.first))
        XCTAssertEqual(try Data(contentsOf: saved), original)
    }

    @MainActor func testWarmFontDocumentFailureIsVisibleAndNextImportRecovers() async throws {
        let services = try await services(), inbox = FontDocumentInbox()
        inbox.attach(files: services.files)
        let bad = services.files.root.appendingPathComponent("bad.ttf")
        try Data("not a font".utf8).write(to: bad)
        inbox.receive(bad); await inbox.waitUntilIdle()
        XCTAssertNotNil(inbox.failure); XCTAssertFalse(inbox.importing)
        let failed = try await services.files.readingFonts(); XCTAssertTrue(failed.isEmpty)
        inbox.receive(try fixture()); await inbox.waitUntilIdle()
        XCTAssertNil(inbox.failure); XCTAssertNotNil(inbox.message)
        let good = try await services.files.readingFonts(); XCTAssertEqual(good.count, 1)
        inbox.receive(try XCTUnwrap(URL(string: "https://example.invalid/font.ttf")))
        XCTAssertNotNil(inbox.failure)
        let after = try await services.files.readingFonts(); XCTAssertEqual(after, good)
        inbox.dismissFeedback(); XCTAssertNil(inbox.failure); XCTAssertNil(inbox.message)
    }

    func testDocumentDeclarationUsesSystemFontTypesAndAlternateViewerRole() throws {
        let types = try XCTUnwrap(Bundle.main.object(forInfoDictionaryKey: "CFBundleDocumentTypes") as? [[String: Any]])
        let declaration = try XCTUnwrap(types.first)
        XCTAssertEqual(declaration["CFBundleTypeRole"] as? String, "Viewer")
        XCTAssertEqual(declaration["LSHandlerRank"] as? String, "Alternate")
        let ids = try XCTUnwrap(declaration["LSItemContentTypes"] as? [String])
        for ext in ["ttf", "otf"] {
            let type = try XCTUnwrap(UTType(filenameExtension: ext))
            XCTAssertTrue(ids.contains(type.identifier)); XCTAssertTrue(type.conforms(to: .font))
        }
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "LSSupportsOpeningDocumentsInPlace") as? Bool, true)
    }

    func testPresetsPreserveFontSizeThemeAndValidateWithoutChangingCustomValuesOnInspection() throws {
        var custom = ReadingAppearance(); custom.fontScale = 1.6; custom.theme = .oled
        custom.importedFontID = UUID(); custom.font = .serif; custom.paragraphSpacing = 2.6
        custom.characterSpacing = 0.35; custom.weightMultiplier = 1.5; custom.paragraphIndent = 3.5
        let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
        let bytes = try encoder.encode(custom)
        XCTAssertFalse(ReadingLayoutPreset.allCases.contains { $0.matches(custom) })
        XCTAssertEqual(try encoder.encode(custom), bytes)
        for preset in ReadingLayoutPreset.allCases {
            let value = try preset.applying(to: custom).validated()
            XCTAssertEqual(value.fontScale, custom.fontScale); XCTAssertEqual(value.theme, custom.theme)
            XCTAssertEqual(value.importedFontID, custom.importedFontID); XCTAssertEqual(value.font, custom.font)
            XCTAssertTrue(preset.matches(value)); XCTAssertFalse(value.publisherStyles)
            XCTAssertEqual(value.paragraphIndent, 2)
            XCTAssertEqual(try JSONDecoder().decode(ReadingAppearance.self, from: JSONEncoder().encode(value)), value)
        }
    }

    @MainActor func testReaderPresentationThemeNeverChangesShelfOrWindowAndRestoresLocalOverride() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let oldKey = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene), shelf = UIViewController(), reader = UIViewController()
        shelf.overrideUserInterfaceStyle = .dark; window.rootViewController = shelf; window.makeKeyAndVisible()
        defer { window.isHidden = true; oldKey?.makeKey() }
        let shown = expectation(description: "real reader presentation")
        shelf.present(reader, animated: false) { shown.fulfill() }
        await fulfillment(of: [shown], timeout: 2)
        let controller = ReaderPresentationStyleController(style: .light)
        reader.addChild(controller); reader.view.addSubview(controller.view); controller.didMove(toParent: reader)
        XCTAssertEqual(reader.overrideUserInterfaceStyle, .light)
        XCTAssertEqual(shelf.overrideUserInterfaceStyle, .dark); XCTAssertEqual(window.overrideUserInterfaceStyle, .unspecified)
        controller.style = .dark; controller.apply(); XCTAssertEqual(reader.overrideUserInterfaceStyle, .dark)
        controller.style = .light; controller.apply(); controller.restore()
        XCTAssertEqual(reader.overrideUserInterfaceStyle, .unspecified)
        XCTAssertEqual(shelf.traitCollection.userInterfaceStyle, .dark)
        shelf.dismiss(animated: false)
    }
}
