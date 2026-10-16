import Foundation
import XCTest
@testable import XianxiaCore

final class ReadingAppearanceTests: XCTestCase {
    func testLegacyJSONAndExtendedTypographyRoundTripWithoutMigration() async throws {
        let legacy = Data("{\"version\":1,\"theme\":\"warm\",\"font\":\"original\",\"fontScale\":1.1,\"lineHeight\":1.75,\"paragraphSpacing\":0.8,\"pageMargins\":1,\"firstLineIndent\":true,\"alignment\":\"natural\",\"publisherStyles\":false}".utf8)
        let value = try JSONDecoder().decode(ReadingAppearance.self, from: legacy).validated()
        XCTAssertNil(value.fontWeight); XCTAssertNil(value.letterSpacing); XCTAssertNil(value.indentSize)
        XCTAssertEqual(value.paragraphIndent, 2)
        var edited = value
        edited.characterSpacing = 0.25; edited.weightMultiplier = 1.5; edited.paragraphIndent = 3.5
        edited.lineHeight = 2.7; edited.paragraphSpacing = 2.8; edited.pageMargins = 0.25
        let files = try store(); try await files.saveReadingAppearance(edited)
        let recreated = try BookFileStore(root: files.root)
        let restored = try await recreated.readingAppearance(); XCTAssertEqual(restored, edited)
        edited.firstLineIndent = false; XCTAssertEqual(edited.paragraphIndent, 0)
        edited.firstLineIndent = true; XCTAssertEqual(edited.paragraphIndent, 3.5)
    }

    func testExtendedTypographyRejectsNonfiniteAndOutOfRangeWithoutOverwriting() async throws {
        let files = try store(); try await files.saveReadingAppearance(ReadingAppearance())
        let url = try files.resolve("Preferences/reading-v1.json"), original = try Data(contentsOf: url)
        for key in [\ReadingAppearance.letterSpacing, \.fontWeight, \.indentSize] {
            for invalid in [Double.nan, Double.infinity, -1, 99] {
                var value = ReadingAppearance(); value[keyPath: key] = invalid
                do { try await files.saveReadingAppearance(value); XCTFail("Invalid new value must be visible") }
                catch { XCTAssertEqual(try Data(contentsOf: url), original) }
            }
        }
    }

    private func store() throws -> BookFileStore {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return files
    }

    func testMissingPreferencesUseDefaultsAndPersistAcrossStoreRecreation() async throws {
        let files = try store(), initial = try await files.readingAppearance()
        XCTAssertEqual(initial, ReadingAppearance())
        var value = initial
        value.theme = .charcoal; value.font = .serif; value.fontScale = 1.6
        value.lineHeight = 1.9; value.paragraphSpacing = 1.2; value.pageMargins = 1.5
        value.firstLineIndent = false; value.alignment = .justified
        try await files.saveReadingAppearance(value)
        let recreated = try BookFileStore(root: files.root), restored = try await recreated.readingAppearance()
        XCTAssertEqual(restored, value)
        XCTAssertFalse(ReadingTheme.charcoal.textRGB == 0xFFFFFF)
        XCTAssertFalse(ReadingTheme.oled.textRGB == 0xFFFFFF)
    }

    func testCorruptAndFutureSettingsAreVisibleAndPreserved() async throws {
        let files = try store(), directory = try files.resolve("Preferences")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = try files.resolve("Preferences/reading-v1.json")
        let valid = try JSONEncoder().encode(ReadingAppearance())
        let future = try XCTUnwrap(String(data: valid, encoding: .utf8)).replacingOccurrences(of: "\"version\":1", with: "\"version\":99")
        for data in [Data("{broken".utf8), Data(future.utf8)] {
            try data.write(to: url)
            do { _ = try await files.readingAppearance(); XCTFail("Must report unreadable settings") }
            catch { XCTAssertEqual(try Data(contentsOf: url), data) }
        }
    }

    func testInvalidEditsCannotOverwriteLastSavedSettings() async throws {
        let files = try store()
        try await files.saveReadingAppearance(ReadingAppearance())
        let url = try files.resolve("Preferences/reading-v1.json"), before = try Data(contentsOf: url)
        for bad in [Double.nan, Double.infinity, 0, 2.1] {
            var value = ReadingAppearance(); value.fontScale = bad
            do { try await files.saveReadingAppearance(value); XCTFail("Invalid scale must fail") }
            catch { XCTAssertEqual(try Data(contentsOf: url), before) }
        }
    }

    func testOversizedSettingsAndWriteFailureAreNotSilentlyIgnored() async throws {
        let files = try store(), directory = try files.resolve("Preferences")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = try files.resolve("Preferences/reading-v1.json")
        let data = Data(repeating: 32, count: 16_385); try data.write(to: url)
        do { _ = try await files.readingAppearance(); XCTFail("Bound reads") }
        catch { XCTAssertEqual(error as? ReadingAppearanceError, .oversizedFile) }
        XCTAssertEqual(try Data(contentsOf: url), data)
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        do { try await files.saveReadingAppearance(ReadingAppearance()); XCTFail("Directory must not be overwritten") }
        catch { XCTAssertTrue(FileManager.default.fileExists(atPath: url.path)) }
    }

    func testPreferencesRejectParentAndDanglingLeafSymlinks() async throws {
        let files = try store(), outside = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: outside) }
        let parent = files.root.appendingPathComponent("Preferences")
        try FileManager.default.createSymbolicLink(at: parent, withDestinationURL: outside)
        do { try await files.saveReadingAppearance(ReadingAppearance()); XCTFail("No linked parent") }
        catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        try FileManager.default.removeItem(at: parent)
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        let leaf = parent.appendingPathComponent("reading-v1.json")
        try FileManager.default.createSymbolicLink(at: leaf, withDestinationURL: outside.appendingPathComponent("missing.json"))
        do { _ = try await files.readingAppearance(); XCTFail("No dangling leaf") }
        catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        do { try await files.saveReadingAppearance(ReadingAppearance()); XCTFail("No dangling write") }
        catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        XCTAssertFalse(FileManager.default.fileExists(atPath: outside.appendingPathComponent("missing.json").path))
    }
}
