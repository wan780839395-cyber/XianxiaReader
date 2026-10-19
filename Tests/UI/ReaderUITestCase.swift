import XCTest
import UIKit

/// Device orientation survives app termination. XCTest teardown still runs when
/// an assertion stops a test before its Swift defer can restore the device.
class ReaderUITestCase: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        await Self.resetDevice()
    }

    override func tearDown() async throws {
        await Self.resetDevice()
        try await super.tearDown()
    }

    @MainActor private static func resetDevice() {
        let app = XCUIApplication()
        if app.state != .notRunning { app.terminate() }
        XCUIDevice.shared.orientation = .portrait
    }
}
