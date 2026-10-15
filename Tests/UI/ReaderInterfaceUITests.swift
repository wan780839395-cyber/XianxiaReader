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
        // Engine open mounts a navigator before WebKit finishes its initial page.
        // Exercise reading gestures only once this original fixture is readable.
        let text = app.webViews.staticTexts.matching(NSPredicate(format: "label CONTAINS '本样书用于' OR label CONTAINS '山门'"))
        let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            text.allElementsBoundByIndex.contains { $0.isHittable }
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [readable], timeout: 20), .completed)
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
        for id in ["reader.contents.open", "reader.bookmarks.open", "reader.search.open", "reader.appearance.open", "reader.page.previous", "reader.page.next", "reader.bookmark.add"] {
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

    @MainActor private func centerTap(in app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42)).tap()
    }

    @MainActor private func readingDrag(in app: XCUIApplication, vertical: Bool) {
        let from = app.coordinate(withNormalizedOffset: CGVector(dx: vertical ? 0.5 : 0.78, dy: 0.46))
        let to = app.coordinate(withNormalizedOffset: CGVector(dx: vertical ? 0.5 : 0.22, dy: vertical ? 0.28 : 0.46))
        from.press(forDuration: 0.05, thenDragTo: to)
    }

    @MainActor func testReadingDragHidesMenuModePersistsAndOptOutKeepsMenu() {
        let app = start(); defer { app.terminate() }
        readingDrag(in: app, vertical: false)
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["reader.appearance.open"])
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 10), .completed)
        snapshot("reader-horizontal-immersive-build17", in: app)
        centerTap(in: app)
        XCTAssertTrue(app.buttons["reader.mode"].waitForExistence(timeout: 10))
        app.buttons["reader.mode"].tap(); app.buttons["上下连续滚动"].tap()
        // Exercise a vertical gesture, then check saved mode and controls after relaunch.
        readingDrag(in: app, vertical: true)
        let continuousHidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["reader.appearance.open"])
        XCTAssertEqual(XCTWaiter.wait(for: [continuousHidden], timeout: 10), .completed)
        snapshot("reader-continuous-immersive-build17", in: app)
        centerTap(in: app)
        XCTAssertTrue(app.buttons["reader.appearance.open"].waitForExistence(timeout: 10))
        app.buttons["reader.appearance.open"].tap(); app.buttons["手感"].tap()
        let autoHide = app.switches["reader.interaction.auto-hide"]
        XCTAssertTrue(autoHide.waitForExistence(timeout: 10)); autoHide.tap()
        app.switches["reader.interaction.reduce-motion"].tap()
        snapshot("reader-interaction-settings-build17", in: app)
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); openBook(in: app)
        XCTAssertEqual(app.buttons["reader.mode"].value as? String, "上下连续滚动")
        readingDrag(in: app, vertical: true)
        XCTAssertTrue(app.buttons["reader.appearance.open"].isHittable)
        app.buttons["reader.appearance.open"].tap(); app.buttons["手感"].tap()
        XCTAssertEqual(app.switches["reader.interaction.auto-hide"].value as? String, "0")
        XCTAssertEqual(app.switches["reader.interaction.reduce-motion"].value as? String, "1")
        snapshot("reader-interaction-restored-build17", in: app)
    }

    @MainActor func testAdditionalReducedMotionMenuCanHideAndReturnWithNativeDrag() {
        let app = start(reduceMotion: true); defer { app.terminate() }
        readingDrag(in: app, vertical: false)
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["reader.appearance.open"])
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 10), .completed)
        centerTap(in: app)
        XCTAssertTrue(app.buttons["reader.appearance.open"].waitForExistence(timeout: 10))
        snapshot("reader-motion-reduced-menu-build17", in: app)
    }
}
