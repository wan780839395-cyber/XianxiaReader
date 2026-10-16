import Foundation
import XCTest
@testable import XianxiaCore

final class ReadingInteractionTests: XCTestCase {
    func testBuild17InteractionJSONRetainsEverySettingWithoutScreenFlag() throws {
        let data = Data(#"{"version":1,"continuousScrolling":true,"reduceMotion":true,"autoHideMenu":false}"#.utf8)
        let restored = try JSONDecoder().decode(ReadingInteraction.self, from: data).validated()
        XCTAssertTrue(restored.continuousScrolling); XCTAssertTrue(restored.reduceMotion)
        XCTAssertFalse(restored.autoHideMenu); XCTAssertFalse(restored.verticalScreenPaging)
    }

    func testVerticalScreenModePersistsIndependentlyOfAppearance() async throws {
        let files = try store()
        var value = ReadingInteraction(); value.continuousScrolling = true; value.verticalScreenPaging = true
        try await files.saveReadingInteraction(value)
        let recreated = try BookFileStore(root: files.root)
        let restored = try await recreated.readingInteraction()
        XCTAssertEqual(restored, value)
        let appearance = try await recreated.readingAppearance()
        XCTAssertEqual(appearance, ReadingAppearance())
    }

    func testInvalidScreenPolicyAndMalformedNewFieldCannotBeSavedOrSilentlyDefaulted() async throws {
        let files = try store()
        try await files.saveReadingInteraction(ReadingInteraction())
        let url = try files.resolve("Preferences/interaction-v1.json"), original = try Data(contentsOf: url)
        var bad = ReadingInteraction(); bad.verticalScreenPaging = true
        do { try await files.saveReadingInteraction(bad); XCTFail("Screen policy requires continuous layout") }
        catch { XCTAssertEqual(try Data(contentsOf: url), original) }
        for field in ["\"yes\"", "null"] {
            let malformed = Data("{\"version\":1,\"continuousScrolling\":true,\"reduceMotion\":false,\"autoHideMenu\":true,\"verticalScreenPaging\":\(field)}".utf8)
            try malformed.write(to: url)
            do { _ = try await files.readingInteraction(); XCTFail("Wrong field type must be visible") }
            catch { XCTAssertEqual(try Data(contentsOf: url), malformed) }
        }
    }

    private func store() throws -> BookFileStore {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return files
    }

    func testDefaultsAndRecreationPreserveIndependentInteractionAndAppearance() async throws {
        let files = try store(), initial = try await files.readingInteraction()
        XCTAssertEqual(initial, ReadingInteraction())
        var appearance = ReadingAppearance(); appearance.theme = .paper
        try await files.saveReadingAppearance(appearance)
        var value = initial; value.continuousScrolling = true; value.reduceMotion = true; value.autoHideMenu = false
        try await files.saveReadingInteraction(value)
        let recreated = try BookFileStore(root: files.root)
        let restored = try await recreated.readingInteraction(), restoredAppearance = try await recreated.readingAppearance()
        XCTAssertEqual(restored, value); XCTAssertEqual(restoredAppearance, appearance)
    }

    func testCorruptFutureAndOversizedInteractionAreReportedWithoutReplacement() async throws {
        let files = try store()
        try await files.saveReadingInteraction(ReadingInteraction())
        let url = try files.resolve("Preferences/interaction-v1.json")
        let data = try Data(contentsOf: url)
        let future = try XCTUnwrap(String(data: data, encoding: .utf8)).replacingOccurrences(of: "\"version\":1", with: "\"version\":99")
        for bad in [Data("{broken".utf8), Data(future.utf8), Data(repeating: 32, count: 16_385)] {
            try bad.write(to: url)
            do { _ = try await files.readingInteraction(); XCTFail("Must surface bad preferences") }
            catch { XCTAssertEqual(try Data(contentsOf: url), bad) }
        }
    }

    func testInteractionWriteFailureCanBeRetriedWithoutDeletingAppearance() async throws {
        let files = try store()
        try await files.saveReadingAppearance(ReadingAppearance())
        let url = try files.resolve("Preferences/interaction-v1.json")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        do { try await files.saveReadingInteraction(ReadingInteraction()); XCTFail("Cannot overwrite directory") }
        catch { XCTAssertTrue(FileManager.default.fileExists(atPath: url.path)) }
        try FileManager.default.removeItem(at: url)
        try await files.saveReadingInteraction(ReadingInteraction())
        let appearance = try await files.readingAppearance()
        XCTAssertEqual(appearance, ReadingAppearance())
    }

    func testInteractionRejectsLinkedParentAndDanglingLeafForReadsAndWrites() async throws {
        let files = try store(), outside = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: outside) }
        let parent = files.root.appendingPathComponent("Preferences")
        let leaf = parent.appendingPathComponent("interaction-v1.json")
        try FileManager.default.createSymbolicLink(at: parent, withDestinationURL: outside)
        for dangling in [false, true] {
            if dangling {
                try FileManager.default.removeItem(at: parent)
                try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: false)
                try FileManager.default.createSymbolicLink(at: leaf, withDestinationURL: outside.appendingPathComponent("missing"))
            }
            do { _ = try await files.readingInteraction(); XCTFail("Read cannot follow link") }
            catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
            do { try await files.saveReadingInteraction(ReadingInteraction()); XCTFail("Write cannot follow link") }
            catch { XCTAssertEqual(error as? StorageError, .unsafePath) }
        }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: outside.path), [])
    }
}
