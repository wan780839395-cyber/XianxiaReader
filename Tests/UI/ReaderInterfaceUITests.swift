import XCTest

final class ReaderInterfaceUITests: XCTestCase {
    @MainActor private func start(reduceMotion: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        if reduceMotion { app.launchEnvironment["XR_LIBRARY_UI_REDUCE_MOTION"] = "1" }
        app.launch()
        openBook(in: app)
        return app
    }

    @MainActor private func openBook(in app: XCUIApplication) {
        let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
        XCTAssertTrue(book.waitForExistence(timeout: 20)); book.tap()
        let settings = app.buttons["reader.appearance.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 20))
        let enabled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
        XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 20), .completed)
    }

    @MainActor private func snapshot(_ name: String, in app: XCUIApplication) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name; image.lifetime = .keepAlways; add(image)
    }

    @MainActor private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<4 {
            if element.isHittable { return }
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor func testNativeMenuLayoutGroupsPublisherRulesAndRelaunch() {
        let app = start(); defer { app.terminate() }
        for id in ["reader.contents.open", "reader.bookmarks.open", "reader.search.open", "reader.appearance.open", "reader.page.previous", "reader.page.next"] {
            let button = app.buttons[id]
            XCTAssertTrue(button.isHittable, id)
            XCTAssertGreaterThanOrEqual(button.frame.width, 44, id)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44, id)
        }
        snapshot("reader-menu-light-build16", in: app)
        app.buttons["reader.mode"].tap()
        XCTAssertTrue(app.buttons["上下连续滚动"].waitForExistence(timeout: 10))
        snapshot("reader-mode-menu-build16", in: app)
        app.buttons["上下连续滚动"].tap()
        XCTAssertEqual(app.buttons["reader.mode"].value as? String, "上下连续滚动")
        app.buttons["reader.contents.open"].tap()
        XCTAssertTrue(app.navigationBars.matching(NSPredicate(format: "identifier BEGINSWITH '目录'")).firstMatch.waitForExistence(timeout: 10))
        app.buttons["完成"].tap()
        app.buttons["reader.appearance.open"].tap()
        XCTAssertTrue(app.buttons["reader.theme.warm"].waitForExistence(timeout: 10))
        snapshot("reader-appearance-light-build16", in: app)
        app.buttons["排版"].tap()
        let margins = app.buttons["reader.margins.increase"]
        XCTAssertTrue(margins.waitForExistence(timeout: 10)); reveal(margins, in: app)
        margins.tap()
        XCTAssertEqual(app.staticTexts["reader.margins.value"].label, "1.25")
        snapshot("reader-layout-light-build16", in: app)
        let line = app.buttons["reader.line-height.increase"]
        reveal(line, in: app); line.tap()
        XCTAssertEqual(app.staticTexts["reader.line-height.value"].label, "1.85")
        // Turning original styles on must disable the same real typography controls.
        app.scrollViews.firstMatch.swipeDown()
        let original = app.switches["reader.publisher-styles"]
        XCTAssertTrue(original.isHittable); original.tap()
        XCTAssertFalse(line.isEnabled)
        original.tap(); XCTAssertTrue(line.isEnabled)
        app.buttons["reader.appearance.done"].tap()
        app.buttons["返回书库"].tap(); app.terminate(); app.launch(); openBook(in: app)
        app.buttons["reader.appearance.open"].tap()
        XCTAssertTrue(app.buttons["排版"].waitForExistence(timeout: 10)); app.buttons["排版"].tap()
        XCTAssertEqual(app.staticTexts["reader.margins.value"].label, "1.25")
        reveal(app.buttons["reader.line-height.increase"], in: app)
        XCTAssertEqual(app.staticTexts["reader.line-height.value"].label, "1.85")
        app.scrollViews.firstMatch.swipeDown(); app.buttons["外观"].tap()
        app.buttons["reader.theme.charcoal"].tap()
        snapshot("reader-appearance-dark-build16", in: app)
        app.buttons["排版"].tap(); snapshot("reader-layout-dark-build16", in: app)
        app.buttons["reader.appearance.done"].tap()
        snapshot("reader-menu-dark-build16", in: app)
    }

    @MainActor func testReducedMotionNativeGroupedSettingsRemainUsable() {
        let app = start(reduceMotion: true); defer { app.terminate() }
        app.buttons["reader.appearance.open"].tap()
        XCTAssertTrue(app.buttons["reader.theme.paper"].waitForExistence(timeout: 10))
        app.buttons["reader.theme.paper"].tap(); app.buttons["排版"].tap()
        let margins = app.buttons["reader.margins.increase"]
        reveal(margins, in: app); margins.tap()
        XCTAssertEqual(app.staticTexts["reader.margins.value"].label, "1.25")
        snapshot("reader-reduced-motion-layout-build16", in: app)
        app.buttons["reader.appearance.done"].tap()
        XCTAssertTrue(app.buttons["reader.appearance.open"].waitForExistence(timeout: 10))
        snapshot("reader-reduced-motion-menu-build16", in: app)
    }
}
