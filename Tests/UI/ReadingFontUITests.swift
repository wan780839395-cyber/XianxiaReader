import XCTest

final class ReadingFontUITests: XCTestCase {
    @MainActor func testCompactSettingsKeepFontRowsStableAndLayoutWithinOneScreen() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_READER_UI_SETTINGS"] = "1"
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = "list"
        app.launch(); defer { app.terminate() }
        let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
        XCTAssertTrue(book.waitForExistence(timeout: 30)); book.tap()
        let settings = app.buttons["reader.appearance.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 20))
        let enabled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
        XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 20), .completed); settings.tap()
        func reveal(_ element: XCUIElement, up: Bool) {
            for _ in 0..<5 {
                if element.isHittable { break }
                if up { app.scrollViews["reader.appearance.scroll"].swipeUp() }
                else { app.scrollViews["reader.appearance.scroll"].swipeDown() }
            }
            XCTAssertTrue(element.isHittable)
        }
        func snapshot(_ name: String) {
            let image = XCTAttachment(screenshot: app.screenshot())
            image.name = name; image.lifetime = .keepAlways; add(image)
        }
        let song = app.buttons["reader.font.bundled.sourceHanSerif"]
        let kai = app.buttons["reader.font.bundled.wenKai"]
        reveal(song, up: true); reveal(kai, up: true)
        XCTAssertLessThan(abs(song.frame.minY - kai.frame.minY), 2)
        XCTAssertGreaterThan(kai.frame.minX, song.frame.minX)
        let rowHeight = song.frame.height
        XCTAssertGreaterThanOrEqual(rowHeight, 86)
        for _ in 0..<3 {
            app.scrollViews["reader.appearance.scroll"].swipeUp()
            app.scrollViews["reader.appearance.scroll"].swipeDown()
            reveal(song, up: false)
            XCTAssertEqual(song.frame.height, rowHeight, accuracy: 1)
        }
        snapshot("reader-settings-font-grid-build25")
        let dark = app.buttons["reader.theme.charcoal"]; reveal(dark, up: false); dark.tap()
        reveal(song, up: true)
        XCTAssertEqual(song.frame.height, rowHeight, accuracy: 1)
        snapshot("reader-settings-font-grid-dark-build25")
        let section = app.segmentedControls["reader.appearance.section"]
        XCTAssertTrue(section.isHittable, "Groups stay available while browsing fonts")
        section.buttons["排版"].tap()
        XCTAssertTrue(app.buttons["reader.margins.increase"].isHittable)
        XCTAssertTrue(app.buttons["reader.line-height.increase"].isHittable)
        XCTAssertLessThan(app.buttons["reader.margins.increase"].frame.maxY, app.frame.maxY - 20)
        XCTAssertFalse(app.buttons["reader.indent-size.increase"].exists, "Rare controls start collapsed")
        snapshot("reader-settings-compact-layout-build27")
        let more = app.buttons["reader.layout.more"]; reveal(more, up: true); more.tap()
        let alignment = app.segmentedControls["reader.alignment"]
        reveal(app.buttons["reader.indent-size.increase"], up: true)
        XCTAssertTrue(app.buttons["reader.indent-size.increase"].isHittable)
        reveal(alignment, up: true); XCTAssertTrue(alignment.isHittable)
        let original = app.switches["reader.publisher-styles"]; reveal(original, up: false)
        original.tap()
        XCTAssertTrue(app.buttons["reader.margins.increase"].isEnabled, "Original styles must still allow page margins")
        XCTAssertFalse(app.buttons["reader.line-height.increase"].isEnabled)
        XCTAssertFalse(app.buttons["reader.indent-size.increase"].isEnabled)
        original.tap()
        XCTAssertTrue(app.buttons["reader.line-height.increase"].isEnabled)
    }

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
        let more = app.buttons["reader.layout.more"]; reveal(more); more.tap()
        for key in ["letter-spacing", "font-weight", "indent-size"] {
            let button = app.buttons["reader.\(key).increase"]; reveal(button); button.tap()
        }
        XCTAssertEqual(app.staticTexts["reader.indent-size.value"].label, "2.5 字")
        snapshot("reader-font-extended-layout-build24")
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open()
        reveal(section, up: false); section.buttons["排版"].tap()
        reveal(more); more.tap()
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
            let entry = app.buttons["reader.fonts.open"]
            for _ in 0..<4 { if entry.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeUp() }
            XCTAssertTrue(entry.isHittable); entry.tap()
            XCTAssertTrue(app.buttons["reader.font.import"].waitForExistence(timeout: 10))
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
        app.buttons["reader.fonts.back"].tap()
        let done = app.buttons["reader.appearance.done"]
        let restored = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true AND enabled == true"), object: done)
        XCTAssertEqual(XCTWaiter.wait(for: [restored], timeout: 20), .completed)
        app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); open(); revealFonts()
        XCTAssertEqual(font.value as? String, "已选择"); snapshot("reader-font-reopened-build23")
        app.buttons["reader.fonts.back"].tap()
        let dark = app.buttons["reader.theme.charcoal"]
        for _ in 0..<5 { if dark.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeDown() }
        XCTAssertTrue(dark.isHittable); dark.tap(); revealFonts(); snapshot("reader-font-selected-dark-build23")
        app.buttons["reader.fonts.back"].tap()
        let builtIn = app.segmentedControls["reader.font"].buttons["衬线"]
        for _ in 0..<5 { if builtIn.isHittable { break }; app.scrollViews["reader.appearance.scroll"].swipeDown() }
        XCTAssertTrue(builtIn.isHittable)
        builtIn.tap(); revealFonts(); XCTAssertEqual(font.value as? String, "未选择")
        snapshot("reader-font-default-restored-build23")
    }
}
