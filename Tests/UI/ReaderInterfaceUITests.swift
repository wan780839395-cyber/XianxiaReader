import XCTest

final class ReaderInterfaceUITests: XCTestCase {
    @MainActor func testReturnPointContentsBookmarkAndCurrentPositionRelaunch() {
        let app = start(); defer { app.terminate() }
        app.buttons["reader.mode"].tap(); app.buttons["上下连续滚动"].tap()
        XCTAssertTrue(app.scrollViews["readium.continuous-scroll"].waitForExistence(timeout: 20)); waitForReadableText(in: app)
        app.buttons["reader.bookmark.add"].tap()
        snapshot("reader-return-origin-light-build22", in: app)
        app.buttons["reader.contents.open"].tap()
        let chapter = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'reader.contents.' AND label CONTAINS '第二章'")).firstMatch
        XCTAssertTrue(chapter.waitForExistence(timeout: 10)); chapter.tap()
        waitForReturnText("灯下第1段", in: app)
        let back = app.buttons["reader.return.go"]
        XCTAssertTrue(back.waitForExistence(timeout: 10)); XCTAssertTrue(back.isHittable)
        XCTAssertGreaterThanOrEqual(back.frame.height, 44)
        snapshot("reader-return-target-light-build22", in: app)
        back.tap(); waitForReturnText("本样书用于", in: app)
        XCTAssertFalse(back.exists); snapshot("reader-return-restored-light-build22", in: app)
        centerTap(in: app); app.buttons["reader.contents.open"].tap()
        XCTAssertTrue(chapter.waitForExistence(timeout: 10)); chapter.tap(); waitForReturnText("灯下第1段", in: app)
        app.buttons["reader.return.stay"].tap(); XCTAssertFalse(back.exists)
        centerTap(in: app); app.buttons["reader.bookmarks.open"].tap()
        let bookmark = app.buttons.matching(identifier: "reader.bookmark.entry").firstMatch
        XCTAssertTrue(bookmark.waitForExistence(timeout: 10)); bookmark.tap()
        waitForReturnText("本样书用于", in: app); XCTAssertTrue(back.waitForExistence(timeout: 10))
        back.tap(); waitForReturnText("灯下第1段", in: app)
        centerTap(in: app); app.buttons["返回书库"].tap(); app.terminate(); app.launch(); openBookAtReturnTarget(in: app)
        XCTAssertFalse(back.exists); waitForReturnText("灯下第1段", in: app)
        snapshot("reader-return-current-reopened-build22", in: app)
    }

    @MainActor func testReturnPointSearchDarkReducedMotionAndStay() {
        let app = start(reduceMotion: true); defer { app.terminate() }
        app.buttons["reader.appearance.open"].tap(); app.buttons["reader.theme.charcoal"].tap(); app.buttons["reader.appearance.done"].tap()
        app.buttons["reader.search.open"].tap()
        let query = app.textFields["reader.search.query"]
        XCTAssertTrue(query.waitForExistence(timeout: 10)); query.tap(); query.typeText("原创样书的终点")
        app.buttons["reader.search.submit"].tap()
        let result = app.buttons.matching(identifier: "reader.search.result").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 20)); result.tap()
        waitForReturnText("原创样书的终点", in: app)
        let back = app.buttons["reader.return.go"]
        XCTAssertTrue(back.waitForExistence(timeout: 10)); snapshot("reader-return-search-dark-reduced-build22", in: app)
        back.tap(); waitForReturnText("本样书用于", in: app)
        XCTAssertFalse(back.exists); snapshot("reader-return-restored-dark-reduced-build22", in: app)
        centerTap(in: app); app.buttons["reader.contents.open"].tap()
        let chapter = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'reader.contents.' AND label CONTAINS '第三章'")).firstMatch
        XCTAssertTrue(chapter.waitForExistence(timeout: 10)); chapter.tap()
        waitForReturnText("原创样书的终点", in: app)
        app.buttons["reader.return.stay"].tap(); XCTAssertFalse(back.exists)
        snapshot("reader-return-stay-dark-reduced-build22", in: app)
    }

    @MainActor private func waitForReturnText(_ value: String, in app: XCUIApplication) {
        let elements = app.webViews.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", value))
        let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            elements.allElementsBoundByIndex.contains { $0.isHittable }
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [readable], timeout: 20), .completed)
    }

    @MainActor private func openBookAtReturnTarget(in app: XCUIApplication) {
        let book = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS '云海问道'")).firstMatch
        XCTAssertTrue(book.waitForExistence(timeout: 20)); book.tap()
        let settings = app.buttons["reader.appearance.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 20))
        let enabled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
        XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 20), .completed)
    }
    @MainActor func testAutomaticSlowScrollTouchBackgroundDarkControlsSpeedAndStaticRelaunch() {
        let app = start(); defer { app.terminate() }
        app.buttons["reader.autoscroll.open"].tap()
        let toggle = app.buttons["reader.autoscroll.toggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 10))
        XCTAssertTrue(app.scrollViews["readium.continuous-scroll"].waitForExistence(timeout: 20))
        waitForReadableText(in: app)
        XCTAssertEqual(toggle.value as? String, "准备慢滚")
        for _ in 0..<3 { app.buttons["reader.autoscroll.faster"].tap() }
        XCTAssertEqual(app.staticTexts["reader.autoscroll.speed"].value as? String, "每分钟 3.0 屏")
        snapshot("reader-autoscroll-light-ready-build21", in: app)
        toggle.tap()
        let running = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "正在慢滚"), object: toggle)
        XCTAssertEqual(XCTWaiter.wait(for: [running], timeout: 10), .completed)
        // Keep a real original screen recording of sustained movement, not a
        // synthetic frame animation. The app remains free to update its display.
        let elapsed = XCTNSPredicateExpectation(predicate: NSPredicate(value: false), object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [elapsed], timeout: 3), .timedOut)
        centerTap(in: app)
        let paused = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "已暂停"), object: toggle)
        XCTAssertEqual(XCTWaiter.wait(for: [paused], timeout: 10), .completed)
        snapshot("reader-autoscroll-touch-paused-build21", in: app)
        toggle.tap(); XCUIDevice.shared.press(.home); app.activate()
        XCTAssertEqual(toggle.value as? String, "已暂停")
        snapshot("reader-autoscroll-background-paused-build21", in: app)
        app.buttons["reader.autoscroll.close"].tap()
        app.buttons["reader.appearance.open"].tap(); app.buttons["reader.theme.charcoal"].tap()
        app.buttons["reader.appearance.done"].tap()
        app.buttons["reader.autoscroll.open"].tap()
        XCTAssertEqual(app.staticTexts["reader.autoscroll.speed"].value as? String, "每分钟 3.0 屏")
        toggle.tap()
        let darkElapsed = XCTNSPredicateExpectation(predicate: NSPredicate(value: false), object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [darkElapsed], timeout: 3), .timedOut)
        toggle.tap()
        snapshot("reader-autoscroll-dark-paused-build21", in: app)
        app.buttons["reader.autoscroll.close"].tap(); app.buttons["返回书库"].tap()
        app.terminate(); app.launch(); openBook(in: app)
        XCTAssertFalse(toggle.exists)
        app.buttons["reader.autoscroll.open"].tap()
        XCTAssertEqual(toggle.value as? String, "准备慢滚")
        XCTAssertEqual(app.staticTexts["reader.autoscroll.speed"].value as? String, "每分钟 3.0 屏")
        snapshot("reader-autoscroll-reopened-static-build21", in: app)
    }

    @MainActor func testAutomaticSlowScrollRespectsAdditionalReduceMotion() {
        let app = start(reduceMotion: true); defer { app.terminate() }
        app.buttons["reader.autoscroll.open"].tap()
        let toggle = app.buttons["reader.autoscroll.toggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 10)); XCTAssertFalse(toggle.isEnabled)
        XCTAssertTrue(app.staticTexts["减少动态效果已开启，慢滚停用"].exists)
        snapshot("reader-autoscroll-reduced-disabled-build21", in: app)
        app.buttons["reader.autoscroll.close"].tap()
        XCTAssertTrue(app.buttons["reader.mode"].isHittable)
    }
    @MainActor func testInstantVerticalScreenRepeatedReverseKeepsControlsAndReadableText() {
        let app = start(reduceMotion: true); defer { app.terminate() }
        app.buttons["reader.mode"].tap()
        XCTAssertTrue(app.buttons["上下整屏"].waitForExistence(timeout: 10)); app.buttons["上下整屏"].tap()
        let scroll = app.scrollViews["readium.continuous-scroll"]
        XCTAssertTrue(scroll.waitForExistence(timeout: 20))
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "上下整屏"), object: scroll)
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 20), .completed)
        waitForReadableText(in: app)
        readingDrag(in: app, vertical: true)
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["reader.mode"])
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 10), .completed)
        centerTap(in: app)
        XCTAssertTrue(app.buttons["reader.page.next"].waitForExistence(timeout: 10))
        snapshot("reader-screen-instant-before-build20", in: app)
        for _ in 0..<3 {
            app.buttons["reader.page.next"].tap()
            app.buttons["reader.page.previous"].tap()
        }
        XCTAssertTrue(app.buttons["reader.page.previous"].isHittable)
        XCTAssertTrue(app.buttons["reader.page.next"].isHittable)
        XCTAssertEqual(app.buttons["reader.mode"].value as? String, "上下整屏")
        waitForReadableText(in: app)
        snapshot("reader-screen-instant-after-build20", in: app)
    }

    @MainActor func testVerticalScreenNativeDragControlsModeRestoreAndReturnToContinuous() {
        for reduced in [false, true] {
            let app = start(reduceMotion: reduced); defer { app.terminate() }
            let variant = reduced ? "reduced" : "normal"
            app.buttons["reader.mode"].tap()
            XCTAssertTrue(app.buttons["上下整屏"].waitForExistence(timeout: 10)); app.buttons["上下整屏"].tap()
            let scroll = app.scrollViews["readium.continuous-scroll"]
            XCTAssertTrue(scroll.waitForExistence(timeout: 20))
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "上下整屏"), object: scroll)
            XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 20), .completed)
            waitForReadableText(in: app)
            snapshot("reader-screen-before-\(variant)-build19", in: app)
            readingDrag(in: app, vertical: true)
            let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["reader.mode"])
            XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 10), .completed)
            snapshot("reader-screen-after-drag-\(variant)-build19", in: app)
            centerTap(in: app); XCTAssertTrue(app.buttons["reader.page.next"].waitForExistence(timeout: 10))
            XCTAssertEqual(app.buttons["reader.page.next"].label, "下一屏")
            app.buttons["reader.page.next"].tap(); app.buttons["reader.page.previous"].tap()
            app.buttons["reader.appearance.open"].tap(); app.buttons["手感"].tap()
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '保留少量重叠'")).firstMatch.waitForExistence(timeout: 10))
            snapshot("reader-screen-settings-\(variant)-build19", in: app)
            app.buttons["reader.appearance.done"].tap(); app.buttons["返回书库"].tap()
            app.terminate(); app.launch(); openBook(in: app)
            XCTAssertEqual(app.buttons["reader.mode"].value as? String, "上下整屏")
            snapshot("reader-screen-restored-\(variant)-build19", in: app)
            app.buttons["reader.mode"].tap(); app.buttons["上下连续滚动"].tap()
            XCTAssertEqual(app.buttons["reader.mode"].value as? String, "上下连续滚动")
        }
    }

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
        waitForReadableText(in: app)
    }

    @MainActor private func waitForReadableText(in app: XCUIApplication) {
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
            app.scrollViews["reader.appearance.scroll"].swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor private func revealAtTop(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<4 {
            if element.isHittable { return }
            app.scrollViews["reader.appearance.scroll"].swipeDown()
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
        let original = app.switches["reader.publisher-styles"]
        revealAtTop(original, in: app)
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
        revealAtTop(app.buttons["外观"], in: app); app.buttons["外观"].tap()
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
        // The menu selection precedes the asynchronous navigator rebuild.
        // Wait for the actual continuous container and readable text, not just
        // the new menu label, before exercising the original vertical gesture.
        XCTAssertTrue(app.scrollViews["readium.continuous-scroll"].waitForExistence(timeout: 20))
        waitForReadableText(in: app)
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

    @MainActor func testSurfaceControlsKeepSingleActivationAndHitRegionsAfterHeldPress() {
        for reduced in [false, true] {
            let app = start(reduceMotion: reduced)
            defer { app.terminate() }
            let variant = reduced ? "reduced" : "normal"
            let settings = app.buttons["reader.appearance.open"]
            XCTAssertGreaterThanOrEqual(settings.frame.width, 44)
            XCTAssertGreaterThanOrEqual(settings.frame.height, 44)
            snapshot("reader-depth-menu-light-\(variant)-build18", in: app)
            // A held native Button must still activate once on release. Its
            // press response is retained in the actual XCTest video.
            settings.press(forDuration: 0.35)
            let increase = app.buttons["reader.font-size.increase"]
            XCTAssertTrue(increase.waitForExistence(timeout: 10)); reveal(increase, in: app)
            XCTAssertGreaterThanOrEqual(increase.frame.width, 44)
            XCTAssertGreaterThanOrEqual(increase.frame.height, 44)
            XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "110%")
            increase.press(forDuration: 0.35)
            XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "120%")
            increase.press(forDuration: 0.35)
            XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "130%")
            app.buttons["reader.font-size.decrease"].press(forDuration: 0.35)
            XCTAssertEqual(app.staticTexts["reader.font-size.value"].label, "120%")
            snapshot("reader-depth-settings-light-\(variant)-build18", in: app)
            revealAtTop(app.buttons["reader.theme.charcoal"], in: app)
            app.buttons["reader.theme.charcoal"].press(forDuration: 0.35)
            XCTAssertEqual(app.buttons["reader.theme.charcoal"].value as? String, "已选择")
            snapshot("reader-depth-settings-dark-\(variant)-build18", in: app)
            app.buttons["reader.appearance.done"].tap()
            XCTAssertTrue(app.buttons["reader.contents.open"].waitForExistence(timeout: 10))
            for id in ["reader.contents.open", "reader.bookmarks.open", "reader.search.open", "reader.appearance.open"] {
                XCTAssertGreaterThanOrEqual(app.buttons[id].frame.width, 44)
                XCTAssertGreaterThanOrEqual(app.buttons[id].frame.height, 44)
            }
            snapshot("reader-depth-menu-dark-\(variant)-build18", in: app)
        }
    }
}
