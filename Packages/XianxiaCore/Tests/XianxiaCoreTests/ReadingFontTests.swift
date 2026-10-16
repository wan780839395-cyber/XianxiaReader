import Foundation
import XCTest
@testable import XianxiaCore

final class ReadingFontTests: XCTestCase {
    private func store() throws -> BookFileStore {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let store = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return store
    }
    private func source(_ files: BookFileStore, text: String = "portable storage fixture") throws -> URL {
        let url = files.root.appendingPathComponent(UUID().uuidString + ".ttf")
        try Data(text.utf8).write(to: url); return url
    }

    func testLegacyAppearanceWithoutFontIDAndStrictInvalidField() throws {
        let original = try JSONEncoder().encode(ReadingAppearance())
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: original) as? [String: Any])
        json.removeValue(forKey: "importedFontID")
        let legacy = try JSONDecoder().decode(ReadingAppearance.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertNil(legacy.importedFontID)
        var custom = legacy; custom.importedFontID = UUID()
        XCTAssertEqual(try JSONDecoder().decode(ReadingAppearance.self, from: JSONEncoder().encode(custom)), custom)
        for bad in [42 as Any, ["bad"] as Any, "not-a-uuid" as Any] {
            json["importedFontID"] = bad
            XCTAssertThrowsError(try JSONDecoder().decode(ReadingAppearance.self, from: JSONSerialization.data(withJSONObject: json)))
        }
    }

    func testFontStageCommitDuplicateRestartAndMissingAssetRepair() async throws {
        let files = try store(), url = try source(files), bytes = try Data(contentsOf: url)
        let pending = try await files.stageReadingFont(from: url)
        let font = try await files.commitReadingFont(pending, displayName: "本地字体 \"示例\"")
        XCTAssertFalse(font.cssFamily.contains("示例")); XCTAssertFalse(font.relativePath.contains("示例"))
        let recreated = try BookFileStore(root: files.root)
        let list = try await recreated.readingFonts(); XCTAssertEqual(list, [font])
        let target = try await recreated.readingFontURL(font); XCTAssertEqual(try Data(contentsOf: target), bytes)
        let second = try await recreated.stageReadingFont(from: url)
        let duplicate = try await recreated.commitReadingFont(second, displayName: "重名")
        XCTAssertEqual(duplicate, font)
        try FileManager.default.removeItem(at: target)
        let third = try await recreated.stageReadingFont(from: url)
        let repaired = try await recreated.commitReadingFont(third, displayName: "重新导入")
        XCTAssertEqual(repaired, font)
        let repairedURL = try await recreated.readingFontURL(font)
        XCTAssertEqual(try Data(contentsOf: repairedURL), bytes)
    }

    func testFontMetadataFailureRollsBackAndRetryPreservesSource() async throws {
        let files = try store(), url = try source(files), bytes = try Data(contentsOf: url)
        let staged = try await files.stageReadingFont(from: url)
        let broken = try files.resolve("Preferences/fonts-v1.json")
        try FileManager.default.createDirectory(at: broken, withIntermediateDirectories: true)
        do { _ = try await files.commitReadingFont(staged, displayName: "失败"); XCTFail("Metadata failures must be visible") }
        catch { XCTAssertTrue(FileManager.default.fileExists(atPath: staged.fileURL.path)) }
        try FileManager.default.removeItem(at: broken)
        let font = try await files.commitReadingFont(staged, displayName: "重试")
        let savedURL = try await files.readingFontURL(font)
        XCTAssertEqual(try Data(contentsOf: savedURL), bytes)
        XCTAssertEqual(try Data(contentsOf: url), bytes)
    }

    func testFontManagedPathsRejectParentAndDanglingLinksAndTamperedBytes() async throws {
        let files = try store(), url = try source(files), staged = try await files.stageReadingFont(from: url)
        let font = try await files.commitReadingFont(staged, displayName: "路径验证")
        let target = try await files.readingFontURL(font), outside = files.root.appendingPathComponent("outside")
        try FileManager.default.removeItem(at: target)
        try FileManager.default.createSymbolicLink(at: target, withDestinationURL: outside)
        do { _ = try await files.readingFontURL(font); XCTFail("Dangling font link rejected") }
        catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        try FileManager.default.removeItem(at: target)
        try Data("changed".utf8).write(to: target)
        do { _ = try await files.readingFontURL(font); XCTFail("Changed asset rejected") }
        catch { XCTAssertEqual(error as? ReadingFontError, .invalidFont) }
        try FileManager.default.removeItem(at: target.deletingLastPathComponent())
        try FileManager.default.createSymbolicLink(at: target.deletingLastPathComponent(), withDestinationURL: files.root)
        do { _ = try await files.readingFontURL(font); XCTFail("Parent link rejected") }
        catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
    }

    func testFontBoundsCorruptCatalogAndStagingRecoveryNeverDeleteCommittedAsset() async throws {
        let files = try store(), url = try source(files)
        let staged = try await files.stageReadingFont(from: url)
        let font = try await files.commitReadingFont(staged, displayName: "保留")
        let leftover = try await files.stageReadingFont(from: url)
        try await files.recoverImports(knownBookIDs: [])
        XCTAssertFalse(FileManager.default.fileExists(atPath: leftover.fileURL.path))
        let saved = try await files.readingFontURL(font); XCTAssertTrue(FileManager.default.fileExists(atPath: saved.path))
        let catalog = try files.resolve("Preferences/fonts-v1.json"), broken = Data("{broken".utf8)
        try broken.write(to: catalog)
        do { _ = try await files.readingFonts(); XCTFail("Corrupt catalog visible") } catch { XCTAssertEqual(try Data(contentsOf: catalog), broken) }
        let wrong = url.deletingPathExtension().appendingPathExtension("ttc")
        try FileManager.default.copyItem(at: url, to: wrong)
        do { _ = try await files.stageReadingFont(from: wrong); XCTFail("Collections unsupported") }
        catch { XCTAssertEqual(error as? ReadingFontError, .unsupportedFile) }
        let large = files.root.appendingPathComponent("large.ttf")
        XCTAssertTrue(FileManager.default.createFile(atPath: large.path, contents: nil))
        let handle = try FileHandle(forWritingTo: large); try handle.truncate(atOffset: UInt64(BookFileStore.maximumFontBytes + 1)); try handle.close()
        do { _ = try await files.stageReadingFont(from: large); XCTFail("Oversize rejected before parsing") }
        catch { XCTAssertEqual(error as? ReadingFontError, .fileTooLarge) }
    }

    func testFontCatalogLimitAllowsDuplicateWithoutReplacingExistingFonts() async throws {
        let files = try store()
        var first: ReadingFontAsset?
        for number in 0..<12 {
            let url = try source(files, text: "font storage fixture \(number)")
            let staged = try await files.stageReadingFont(from: url)
            let font = try await files.commitReadingFont(staged, displayName: "字体\(number)")
            if first == nil { first = font }
        }
        let url = try source(files, text: "thirteenth"), staged = try await files.stageReadingFont(from: url)
        do { _ = try await files.commitReadingFont(staged, displayName: "超限"); XCTFail("Bound catalogue") }
        catch { XCTAssertEqual(error as? ReadingFontError, .libraryFull) }
        try await files.discardReadingFont(staged)
        let duplicateSource = try source(files, text: "font storage fixture 0")
        let duplicateStage = try await files.stageReadingFont(from: duplicateSource)
        let duplicate = try await files.commitReadingFont(duplicateStage, displayName: "重复")
        XCTAssertEqual(duplicate, first)
        let fonts = try await files.readingFonts(); XCTAssertEqual(fonts.count, 12)
    }
}
