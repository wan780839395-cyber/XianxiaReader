import XCTest

final class ReadingFontUITests: XCTestCase {
    @MainActor func testNativeFontSelectionPickerCancelDarkResetAndRelaunch() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        app.launchEnvironment["XR_READER_UI_FONTS"] = "1"
        app.launch(); defer { app.terminate() }
        func open() {
            let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
            XCTAssertTrue(book.waitForExistence(timeout: 30)); book.tap()
            let settings = app.buttons["reader.appearance.open"]
            XCTAssertTrue(settings.waitForExistence(timeout: 20))
            let enabled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
            XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 20), .completed); settings.tap()
        }
        func revealFonts() {
            let entry = app.buttons["reader.font.import"]
            for _ in 0..<4 { if entry.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeUp() }
            XCTAssertTrue(entry.isHittable)
        }
        func snapshot(_ name: String) {
            let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
        }
        open(); revealFonts()
        let font = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'reader.font.imported.'")).firstMatch
        XCTAssertTrue(font.waitForExistence(timeout: 10)); font.tap()
        XCTAssertEqual(font.value as? String, "已选择"); snapshot("reader-font-selected-light-build23")
        app.buttons["reader.font.import"].tap()
        let cancel = app.descendants(matching: .any).matching(NSPredicate(format: "label == '取消' OR label == 'Cancel'")).firstMatch
        XCTAssertTrue(cancel.waitForExistence(timeout: 10))
        let frame = cancel.frame, appFrame = app.frame
        XCTAssertTrue(appFrame.contains(frame)); XCTAssertGreaterThan(frame.width, 0)
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: frame.midX - appFrame.minX, dy: frame.midY - appFrame.minY)).tap()
        XCTAssertTrue(app.buttons["reader.font.import"].waitForExistence(timeout: 10))
        XCTAssertEqual(font.value as? String, "已选择"); snapshot("reader-font-picker-cancel-build23")
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open(); revealFonts()
        XCTAssertEqual(font.value as? String, "已选择"); snapshot("reader-font-reopened-build23")
        app.scrollViews["reader.appearance.scroll"].swipeDown()
        app.buttons["reader.theme.charcoal"].tap(); revealFonts(); snapshot("reader-font-selected-dark-build23")
        app.scrollViews["reader.appearance.scroll"].swipeDown()
        let builtIn = app.segmentedControls["reader.font"].buttons["衬线"]
        if !builtIn.isHittable { app.scrollViews["reader.appearance.scroll"].swipeUp() }
        builtIn.tap(); revealFonts(); XCTAssertEqual(font.value as? String, "未选择")
        snapshot("reader-font-default-restored-build23")
    }
}
