import XCTest

final class ReadingFontUITests: XCTestCase {
    @MainActor func testSixNativeFontSamplesAndCustomTypographyPersist() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        app.launch(); defer { app.terminate() }
        func reveal(_ element: XCUIElement, up: Bool = true) {
            for _ in 0..<7 {
                if element.isHittable { break }
                if up { app.scrollViews["reader.appearance.scroll"].swipeUp() }
                else { app.scrollViews["reader.appearance.scroll"].swipeDown() }
            }
            XCTAssertTrue(element.isHittable)
        }
        func open() {
            let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
            XCTAssertTrue(book.waitForExistence(timeout: 30)); book.tap()
            let settings = app.buttons["reader.appearance.open"]
            XCTAssertTrue(settings.waitForExistence(timeout: 20))
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
            XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 20), .completed); settings.tap()
        }
        func snapshot(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name
            attachment.lifetime = .keepAlways; add(attachment)
        }
        open()
        for name in ["sourceHanSerif", "wenKai", "sourceHanSans", "zhuque", "maShanZheng", "xiaoWei"] {
            let row = app.buttons["reader.font.bundled.\(name)"]; reveal(row); row.tap()
            XCTAssertEqual(row.value as? String, "已选择")
            snapshot("reader-font-sample-row-\(name)-build24")
        }
        let section = app.segmentedControls["reader.appearance.section"]
        reveal(section, up: false); section.buttons["排版"].tap()
        for key in ["letter-spacing", "font-weight", "indent-size"] {
            let button = app.buttons["reader.\(key).increase"]; reveal(button); button.tap()
        }
        XCTAssertEqual(app.staticTexts["reader.indent-size.value"].label, "2.5 字")
        snapshot("reader-font-extended-layout-build24")
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open()
        reveal(section, up: false); section.buttons["排版"].tap()
        reveal(app.staticTexts["reader.letter-spacing.value"])
        XCTAssertEqual(app.staticTexts["reader.letter-spacing.value"].label, "0.05")
        reveal(app.staticTexts["reader.font-weight.value"])
        XCTAssertEqual(app.staticTexts["reader.font-weight.value"].label, "125%")
        reveal(app.staticTexts["reader.indent-size.value"])
        XCTAssertEqual(app.staticTexts["reader.indent-size.value"].label, "2.5 字")
        snapshot("reader-font-extended-layout-reopened-build24")
    }

    @MainActor func testBundledChineseFontCardsSelectPersistAndSwitchInDarkMode() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        app.launch(); defer { app.terminate() }
        func open() {
            let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
            XCTAssertTrue(book.waitForExistence(timeout: 30)); book.tap()
            let settings = app.buttons["reader.appearance.open"]
            XCTAssertTrue(settings.waitForExistence(timeout: 20))
            let enabled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
            XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 20), .completed); settings.tap()
        }
        func reveal(_ entry: XCUIElement) {
            for _ in 0..<5 { if entry.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeUp() }
            XCTAssertTrue(entry.isHittable)
        }
        func snapshot(_ name: String) {
            let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
        }
        open()
        let song = app.buttons["reader.font.bundled.sourceHanSerif"], kai = app.buttons["reader.font.bundled.wenKai"]
        reveal(song); song.tap(); XCTAssertEqual(song.value as? String, "已选择")
        snapshot("reader-font-bundled-song-build23")
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open(); reveal(song)
        XCTAssertEqual(song.value as? String, "已选择")
        let dark = app.buttons["reader.theme.charcoal"]
        for _ in 0..<5 { if dark.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeDown() }
        XCTAssertTrue(dark.isHittable); dark.tap()
        reveal(kai); kai.tap(); XCTAssertEqual(kai.value as? String, "已选择")
        XCTAssertEqual(song.value as? String, "未选择"); snapshot("reader-font-bundled-kai-dark-build23")
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open(); reveal(kai)
        XCTAssertEqual(kai.value as? String, "已选择")
    }
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
        let cancel = app.buttons.matching(NSPredicate(format: "label == '取消' OR label == 'Cancel'")).firstMatch
        XCTAssertTrue(cancel.waitForExistence(timeout: 30))
        let pickerReady = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true AND enabled == true"), object: cancel)
        XCTAssertEqual(XCTWaiter.wait(for: [pickerReady], timeout: 20), .completed)
        let frame = cancel.frame, appFrame = app.frame
        XCTAssertTrue(appFrame.contains(frame)); XCTAssertGreaterThan(frame.width, 0)
        cancel.tap()
        let dismissed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: cancel)
        XCTAssertEqual(XCTWaiter.wait(for: [dismissed], timeout: 20), .completed)
        XCTAssertTrue(app.buttons["reader.font.import"].waitForExistence(timeout: 10))
        XCTAssertEqual(font.value as? String, "已选择"); snapshot("reader-font-picker-cancel-build23")
        let done = app.buttons["reader.appearance.done"]
        let restored = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true AND enabled == true"), object: done)
        XCTAssertEqual(XCTWaiter.wait(for: [restored], timeout: 20), .completed)
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open(); revealFonts()
        XCTAssertEqual(font.value as? String, "已选择"); snapshot("reader-font-reopened-build23")
        let dark = app.buttons["reader.theme.charcoal"]
        for _ in 0..<5 { if dark.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeDown() }
        XCTAssertTrue(dark.isHittable); dark.tap(); revealFonts(); snapshot("reader-font-selected-dark-build23")
        let builtIn = app.segmentedControls["reader.font"].buttons["衬线"]
        for _ in 0..<5 { if builtIn.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeDown() }
        XCTAssertTrue(builtIn.isHittable)
        builtIn.tap(); revealFonts(); XCTAssertEqual(font.value as? String, "未选择")
        snapshot("reader-font-default-restored-build23")
    }
}
