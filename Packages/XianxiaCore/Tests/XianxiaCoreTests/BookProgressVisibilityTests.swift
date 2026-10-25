import Foundation
import XCTest
@testable import XianxiaCore

final class BookProgressVisibilityTests: XCTestCase {
    func testLegacyDefaultsAndVisibilitySurviveFileStoreRecreation() async throws {
        let legacy = Data("{\"version\":1,\"continuousScrolling\":true,\"reduceMotion\":false,\"autoHideMenu\":true}".utf8)
        var settings = try JSONDecoder().decode(ReadingInteraction.self, from: legacy).validated()
        XCTAssertTrue(settings.showsBookProgress)
        XCTAssertTrue(settings.continuousScrolling)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let initial = try await files.readingInteraction()
        XCTAssertTrue(initial.showsBookProgress)
        settings.showsBookProgress = false
        try await files.saveReadingInteraction(settings)
        let recreated = try BookFileStore(root: root)
        let restored = try await recreated.readingInteraction()
        XCTAssertEqual(restored, settings)
        XCTAssertFalse(restored.showsBookProgress)
        settings.showsBookProgress = true
        try await recreated.saveReadingInteraction(settings)
        let visibleAgain = try await files.readingInteraction()
        XCTAssertTrue(visibleAgain.showsBookProgress)
    }

    func testMalformedPresentVisibilityRemainsAnErrorWithoutRewritingTheFile() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        try await files.saveReadingInteraction(ReadingInteraction())
        let url = try files.resolve("Preferences/interaction-v1.json")
        for field in ["null", "\"false\"", "0", "[]"] {
            let bad = Data("{\"version\":1,\"continuousScrolling\":false,\"reduceMotion\":false,\"autoHideMenu\":true,\"showsBookProgress\":\(field)}".utf8)
            try bad.write(to: url)
            do {
                _ = try await files.readingInteraction()
                XCTFail("A malformed present visibility preference must remain visible as an error")
            } catch {
                XCTAssertEqual(try Data(contentsOf: url), bad)
            }
        }
    }
}
