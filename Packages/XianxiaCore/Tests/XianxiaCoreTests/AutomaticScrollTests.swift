import Foundation
import XCTest
@testable import XianxiaCore

final class AutomaticScrollTests: XCTestCase {
    func testElapsedTimeRetainsFractionalMotionAcross30_60_120Hz() {
        for rate in [30, 60, 120] {
            var clock = AutomaticScrollClock(), total = 0.0
            for frame in 0...rate * 10 {
                total += clock.distance(at: Double(frame) / Double(rate), viewportHeight: 720, screensPerMinute: 0.5)
            }
            XCTAssertEqual(total, 60, accuracy: 0.00001, "\(rate)Hz must cover the same distance, including subpoint steps")
        }
    }

    func testLongGapPauseResetAndReversedTimeNeverCatchUp() {
        var clock = AutomaticScrollClock()
        XCTAssertEqual(clock.distance(at: 1, viewportHeight: 600, screensPerMinute: 6), 0)
        XCTAssertEqual(clock.distance(at: 1.1, viewportHeight: 600, screensPerMinute: 6), 6, accuracy: 0.0001)
        XCTAssertEqual(clock.distance(at: 31, viewportHeight: 600, screensPerMinute: 6), 0)
        XCTAssertEqual(clock.distance(at: 31.1, viewportHeight: 600, screensPerMinute: 6), 6, accuracy: 0.0001)
        XCTAssertEqual(clock.distance(at: 20, viewportHeight: 600, screensPerMinute: 6), 0)
        clock.reset()
        XCTAssertEqual(clock.distance(at: 100, viewportHeight: 600, screensPerMinute: 6), 0)
    }

    func testInvalidClockInputCannotMoveAndSpeedUsesCurrentViewport() {
        var clock = AutomaticScrollClock()
        _ = clock.distance(at: 0, viewportHeight: 600, screensPerMinute: 1)
        XCTAssertEqual(clock.distance(at: 0.1, viewportHeight: 0, screensPerMinute: 1), 0)
        XCTAssertEqual(clock.distance(at: 0.2, viewportHeight: 600, screensPerMinute: .nan), 0)
        XCTAssertEqual(clock.distance(at: .infinity, viewportHeight: 600, screensPerMinute: 1), 0)
        XCTAssertEqual(clock.distance(at: 1, viewportHeight: 600, screensPerMinute: 1), 0)
        XCTAssertEqual(clock.distance(at: 1.1, viewportHeight: 1200, screensPerMinute: 3), 6, accuracy: 0.0001)
    }

    func testOldInteractionDefaultsSpeedAndStoresOnlyPreference() async throws {
        let data = Data(#"{"version":1,"continuousScrolling":true,"reduceMotion":false,"autoHideMenu":true}"#.utf8)
        var restored = try JSONDecoder().decode(ReadingInteraction.self, from: data).validated()
        XCTAssertEqual(restored.automaticScrollSpeed, 1.5)
        restored.automaticScrollSpeed = 3.5
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        try await files.saveReadingInteraction(restored)
        let recreated = try BookFileStore(root: root), value = try await recreated.readingInteraction()
        XCTAssertEqual(value.automaticScrollSpeed, 3.5)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as? [String: Any])
        XCTAssertNil(json["running"]); XCTAssertNil(json["automaticScrollState"])
    }

    func testMalformedOrOutOfRangeSpeedFailsWithoutReplacingPreferences() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        try await files.saveReadingInteraction(ReadingInteraction())
        let url = try files.resolve("Preferences/interaction-v1.json"), original = try Data(contentsOf: url)
        for speed in [Double.nan, .infinity, 0, 6.5] {
            var invalid = ReadingInteraction(); invalid.automaticScrollSpeed = speed
            do { try await files.saveReadingInteraction(invalid); XCTFail("Invalid speed must be visible") }
            catch { XCTAssertEqual(try Data(contentsOf: url), original) }
        }
        for field in ["null", "\"fast\"", "7"] {
            let bad = Data("{\"version\":1,\"continuousScrolling\":true,\"reduceMotion\":false,\"autoHideMenu\":true,\"automaticScrollSpeed\":\(field)}".utf8)
            try bad.write(to: url)
            do { _ = try await files.readingInteraction(); XCTFail("Do not silently default a malformed present field") }
            catch { XCTAssertEqual(try Data(contentsOf: url), bad) }
        }
    }
}
