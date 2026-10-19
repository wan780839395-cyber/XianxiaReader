import XCTest

final class ReaderAppearanceUITests: ReaderUITestCase {
    @MainActor func testNativeThemesTypographyAndPersistenceAfterRelaunch() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        app.launch(); defer { app.terminate() }
        func open() {
            let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
            XCTAssertTrue(book.waitForExistence(timeout: 20)); book.tap()
            XCTAssertTrue(app.buttons["reader.appearance.open"].waitForExistence(timeout: 20))
            let entry = app.buttons["reader.appearance.open"]
            XCTAssertTrue(NSPredicate(format: "enabled == true").evaluate(with: entry) || entry.waitForExistence(timeout: 10))
            // Opening completion can follow the menu's first accessibility frame.
            expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: entry)
            waitForExpectations(timeout: 20); entry.tap()
            XCTAssertTrue(app.buttons["reader.theme.warm"].waitForExistence(timeout: 10))
        }
        func snapshot(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
        }
        open(); snapshot("reader-settings-warm-build15")
        app.buttons["reader.theme.paper"].tap()
        app.buttons["reader.font-size.increase"].tap()
        app.buttons["reader.font-size.increase"].tap()
        XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "130%")
        snapshot("reader-settings-paper-build15")
        app.buttons["reader.theme.charcoal"].tap(); snapshot("reader-settings-charcoal-build15")
        app.buttons["reader.appearance.done"].tap()
        XCTAssertTrue(app.buttons["返回书库"].waitForExistence(timeout: 10))
        snapshot("reader-page-charcoal-build15")
        app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open()
        XCTAssertEqual(app.buttons["reader.theme.charcoal"].value as? String, "已选择")
        XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "130%")
        app.buttons["reader.theme.oled"].tap(); snapshot("reader-settings-oled-build15")
        app.buttons["reader.appearance.done"].tap()
        snapshot("reader-page-oled-build15")
    }
}
