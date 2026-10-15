import XCTest

final class LibraryInteractionUITests: XCTestCase {
    @MainActor private func start(layout: String, reduceMotion: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launchEnvironment["XR_LIBRARY_UI_TEST_ID"] = UUID().uuidString
        app.launchEnvironment["XR_LIBRARY_UI_LAYOUT"] = layout
        if reduceMotion { app.launchEnvironment["XR_LIBRARY_UI_REDUCE_MOTION"] = "1" }
        app.launch()
        XCTAssertTrue(book("云海问道", in: app).waitForExistence(timeout: 20))
        return app
    }

    @MainActor private func book(_ title: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.book.' AND label CONTAINS %@", title)).firstMatch
    }

    @MainActor private func action(_ id: String, label: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier == %@ OR label == %@", id, label)).firstMatch
    }

    @MainActor private func count(_ expected: Int, in app: XCUIApplication) {
        let label = app.staticTexts["library.count"]
        XCTAssertTrue(label.waitForExistence(timeout: 10)); XCTAssertEqual(label.label, "\(expected) 本藏书")
    }

    @MainActor private func waitGone(_ element: XCUIElement) {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [gone], timeout: 10), .completed)
    }

    @MainActor private func restoreCloud(in app: XCUIApplication) {
        app.buttons["library.display"].tap()
        let open = app.buttons.matching(NSPredicate(format: "identifier == 'library.open-trash' OR label BEGINSWITH '回收站（'")).firstMatch
        XCTAssertTrue(open.waitForExistence(timeout: 5)); open.tap()
        let restore = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'library.restore.' AND label CONTAINS '云海问道'")).firstMatch
        XCTAssertTrue(restore.waitForExistence(timeout: 5)); restore.tap()
        XCTAssertTrue(app.otherElements["library.trash.empty"].waitForExistence(timeout: 5) || app.staticTexts["回收站是空的"].exists)
        action("library.trash.done", label: "完成", in: app).tap()
        XCTAssertTrue(book("云海问道", in: app).waitForExistence(timeout: 5)); count(3, in: app)
    }

    @MainActor private func removeCloudFromGrid(in app: XCUIApplication) {
        book("云海问道", in: app).press(forDuration: 1)
        let remove = app.buttons["移出书架"]
        XCTAssertTrue(remove.waitForExistence(timeout: 5)); remove.tap()
        let confirm = action("library.confirm-remove", label: "移到回收站", in: app)
        XCTAssertTrue(confirm.waitForExistence(timeout: 5)); confirm.tap()
        waitGone(book("云海问道", in: app)); count(2, in: app)
    }

    @MainActor private func snapshot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }

    @MainActor func testNativeListSwipeCancelCommitReopenAndRestore() {
        let app = start(layout: "list"); defer { app.terminate() }
        count(3, in: app)
        book("云海问道", in: app).swipeLeft()
        let swipe = action("library.swipe-remove", label: "移到回收站", in: app)
        XCTAssertTrue(swipe.waitForExistence(timeout: 5)); snapshot(app, "library-list-swipe-build12")
        swipe.tap()
        XCTAssertTrue(app.buttons["取消"].waitForExistence(timeout: 5)); app.buttons["取消"].tap()
        XCTAssertTrue(book("云海问道", in: app).exists); count(3, in: app)
        book("云海问道", in: app).swipeLeft()
        XCTAssertTrue(swipe.waitForExistence(timeout: 5)); swipe.tap()
        let confirm = action("library.confirm-remove", label: "移到回收站", in: app)
        XCTAssertTrue(confirm.waitForExistence(timeout: 5)); confirm.tap()
        waitGone(book("云海问道", in: app)); count(2, in: app)
        XCTAssertTrue(book("剑过青山", in: app).exists); XCTAssertTrue(book("山门旧事", in: app).exists)
        app.terminate(); app.launch()
        XCTAssertTrue(book("剑过青山", in: app).waitForExistence(timeout: 20))
        XCTAssertFalse(book("云海问道", in: app).exists); count(2, in: app)
        restoreCloud(in: app)
        XCTAssertTrue(book("云海问道", in: app).label.contains("42%"))
        snapshot(app, "library-list-restored-build12")
    }

    @MainActor func testGridRemovalReflowsAndRestoreReturnsOriginalOrder() {
        let app = start(layout: "grid"); defer { app.terminate() }
        let before = book("剑过青山", in: app).frame
        snapshot(app, "library-grid-before-build12")
        removeCloudFromGrid(in: app)
        let after = book("剑过青山", in: app).frame
        XCTAssertLessThan(after.minX, before.minX - 30)
        XCTAssertTrue(book("山门旧事", in: app).exists)
        snapshot(app, "library-grid-after-build12")
        restoreCloud(in: app)
        XCTAssertEqual(book("剑过青山", in: app).frame.minX, before.minX, accuracy: 3)
        snapshot(app, "library-grid-restored-build12")
    }

    @MainActor func testReducedMotionRemovalAndRestoreKeepUsableGrid() {
        let app = start(layout: "grid", reduceMotion: true); defer { app.terminate() }
        let before = book("剑过青山", in: app).frame
        removeCloudFromGrid(in: app)
        XCTAssertLessThan(book("剑过青山", in: app).frame.minX, before.minX - 30)
        snapshot(app, "library-reduced-motion-build12")
        restoreCloud(in: app)
        XCTAssertEqual(book("剑过青山", in: app).frame.minX, before.minX, accuracy: 3)
    }
}
