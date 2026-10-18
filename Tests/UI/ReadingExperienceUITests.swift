import XCTest

final class ReadingExperienceUITests: XCTestCase {
    @MainActor private func start(fonts: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        if fonts { app.launchEnvironment["XR_READER_UI_FONTS"] = "1"; app.launchEnvironment["XR_READER_UI_MANY_FONTS"] = "1" }
        app.launch()
        XCTAssertTrue(book(in: app).waitForExistence(timeout: 30))
        return app
    }
    @MainActor private func book(in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
    }
    @MainActor private func open(in app: XCUIApplication) {
        let entry = book(in: app); XCTAssertTrue(entry.waitForExistence(timeout: 20)); XCTAssertTrue(entry.isHittable); entry.tap()
        let settings = app.buttons["reader.appearance.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 20))
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
        let readyResult = XCTWaiter.wait(for: [ready], timeout: 20)
        let progress = app.descendants(matching: .any).matching(identifier: "reader.open.status").firstMatch
        XCTAssertEqual(readyResult, .completed, progress.exists ? progress.label : "No opening status")
        let texts = app.webViews.staticTexts.matching(NSPredicate(format: "label CONTAINS '本样书用于' OR label CONTAINS '山门'"))
        let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in texts.allElementsBoundByIndex.contains { $0.isHittable } }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [readable], timeout: 20), .completed)
    }
    @MainActor private func snapshot(_ name: String, in app: XCUIApplication) {
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = name + "-build27"
        image.lifetime = .keepAlways; add(image)
    }
    @MainActor private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 { if element.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeUp() }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor func testSystemDarkShelfSearchStaysDarkAcrossRepeatedReaderSessions() {
        let app = start(); defer { app.terminate() }
        let count = app.staticTexts["library.count"]
        XCTAssertEqual(count.value as? String, "深色", "CI boots the real simulator in system dark mode")
        snapshot("experience-shelf-system-dark", in: app)
        for theme in ["warm", "charcoal", "warm"] {
            let query = app.searchFields.firstMatch
            XCTAssertTrue(query.waitForExistence(timeout: 10)); query.tap(); query.typeText("云海")
            XCTAssertEqual(count.value as? String, "深色")
            snapshot("experience-shelf-search-\(theme)", in: app)
            let cancel = app.buttons.matching(NSPredicate(format: "label == '取消' OR label == 'Cancel'")).firstMatch
            XCTAssertTrue(cancel.waitForExistence(timeout: 10)); cancel.tap()
            open(in: app)
            app.buttons["reader.appearance.open"].tap(); app.buttons["reader.theme.\(theme)"].tap()
            app.buttons["reader.appearance.done"].tap()
            app.buttons["返回书库"].tap()
            XCTAssertTrue(book(in: app).waitForExistence(timeout: 20)); XCTAssertTrue(book(in: app).isHittable)
            XCTAssertEqual(count.value as? String, "深色")
            snapshot("experience-shelf-return-\(theme)", in: app)
        }
        open(in: app); snapshot("experience-fourth-reopen-readable", in: app)
    }

    @MainActor func testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection() {
        let app = start(fonts: true); defer { app.terminate() }; open(in: app)
        app.buttons["reader.appearance.open"].tap()
        let collection = app.buttons["reader.fonts.open"]
        reveal(collection, in: app)
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'reader.font.imported.'")).firstMatch.exists)
        snapshot("experience-font-collection-entry", in: app); collection.tap()
        let fonts = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'reader.font.imported.'"))
        XCTAssertEqual(fonts.count, 3)
        let first = fonts.element(boundBy: 0), second = fonts.element(boundBy: 1)
        XCTAssertLessThan(abs(first.frame.minY - second.frame.minY), 2)
        XCTAssertGreaterThan(second.frame.minX, first.frame.minX)
        XCTAssertGreaterThanOrEqual(first.frame.height, 44)
        let latin = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'reader.font.imported.' AND label CONTAINS[c] 'iA' ")).firstMatch
        XCTAssertTrue(latin.exists); latin.tap(); XCTAssertEqual(latin.value as? String, "已选择")
        snapshot("experience-imported-font-grid", in: app)
        let query = app.textFields["reader.fonts.query"]
        XCTAssertTrue(query.exists); XCTAssertTrue(query.isHittable); XCTAssertGreaterThanOrEqual(query.frame.height, 44)
        query.tap(); query.typeText("iA")
        XCTAssertEqual(fonts.count, 1); XCTAssertEqual(latin.value as? String, "已选择")
        snapshot("experience-imported-font-search", in: app)
        let clear = app.buttons["reader.fonts.clear"]
        XCTAssertTrue(clear.isHittable); XCTAssertGreaterThanOrEqual(clear.frame.height, 44); clear.tap()
        XCTAssertEqual(fonts.count, 3)
        query.typeText("iA\n")
        XCTAssertEqual(fonts.count, 1); XCTAssertFalse(app.keyboards.firstMatch.exists)
        clear.tap(); XCTAssertEqual(fonts.count, 3)
        app.buttons["reader.fonts.back"].tap()
        app.buttons["排版"].tap()
        XCTAssertFalse(app.buttons["reader.letter-spacing.increase"].exists)
        for preset in ["spacious", "compact", "comfortable"] {
            let button = app.buttons["reader.layout.preset.\(preset)"]
            XCTAssertTrue(button.isHittable); button.tap(); XCTAssertEqual(button.value as? String, "已选择")
            XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "110%")
            snapshot("experience-layout-\(preset)", in: app)
        }
        let control = app.buttons["reader.layout.more"]
        reveal(control, in: app); control.tap()
        let spacing = app.buttons["reader.letter-spacing.increase"]; reveal(spacing, in: app); spacing.tap()
        XCTAssertEqual(app.staticTexts["reader.letter-spacing.value"].label, "0.05")
        snapshot("experience-layout-advanced", in: app)
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        open(in: app); app.buttons["reader.appearance.open"].tap(); app.buttons["排版"].tap()
        XCTAssertEqual(app.buttons["reader.layout.preset.comfortable"].value as? String, "未选择")
        let reopened = app.buttons["reader.layout.more"]
        reveal(reopened, in: app); reopened.tap(); reveal(app.staticTexts["reader.letter-spacing.value"], in: app)
        XCTAssertEqual(app.staticTexts["reader.letter-spacing.value"].label, "0.05")
        snapshot("experience-layout-custom-reopened", in: app)
    }
}
