import XCTest

final class ReadingExperienceUITests: ReaderUITestCase {
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
    @MainActor private func open(in app: XCUIApplication, observeFirstOpen: Bool = false) {
        // F5_WAIT_CONTROL_CONFIG_BEGIN
        let waitControl = ProcessInfo.processInfo.environment["XIANXIA_F5_WAIT_CONTROL"]
        if let waitControl {
            guard observeFirstOpen && ["predicate", "property"].contains(waitControl) else {
                XCTFail("Wait API control requires explicit first-open scope and a known arm"); return
            }
            print("F5_WAIT_CONTROL api=\(waitControl) scope=settings-enabled-only targetSaveExecuted=false")
        }
        // F5_WAIT_CONTROL_CONFIG_END
        let entry = book(in: app); XCTAssertTrue(entry.waitForExistence(timeout: 20)); XCTAssertTrue(entry.isHittable); entry.tap()
        let settings = app.buttons["reader.appearance.open"]
        XCTAssertTrue(settings.waitForExistence(timeout: 20))
        // F5_WAIT_CONTROL_GATE_BEGIN
        if waitControl == "property" {
            #if compiler(>=6.1)
            let readyResult = settings.wait(for: \.isEnabled, toEqual: true, timeout: 20)
            let progress = app.descendants(matching: .any).matching(identifier: "reader.open.status").firstMatch
            XCTAssertTrue(readyResult, progress.exists ? progress.label : "No opening status")
            #else
            XCTFail("Property wait control requires Xcode 16.3 or newer"); return
            #endif
        } else {
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: settings)
            let readyResult = XCTWaiter.wait(for: [ready], timeout: 20)
            let progress = app.descendants(matching: .any).matching(identifier: "reader.open.status").firstMatch
            XCTAssertEqual(readyResult, .completed, progress.exists ? progress.label : "No opening status")
        }
        if waitControl != nil { return } // Both control arms stop before body/save acceptance.
        // F5_WAIT_CONTROL_GATE_END
        let texts = app.webViews.staticTexts.matching(NSPredicate(format: "label CONTAINS '本样书用于' OR label CONTAINS '山门'"))
        if observeFirstOpen {
            let observation = F5FirstOpenObservation()
            let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
                let began = ProcessInfo.processInfo.systemUptime
                let ordinal = observation.begin()
                let elements = texts.allElementsBoundByIndex
                let queryReturned = ProcessInfo.processInfo.systemUptime
                var evaluated = 0
                var firstHittable: Int?
                let value = elements.contains { element in
                    let hit = element.isHittable
                    if hit { firstHittable = evaluated }
                    evaluated += 1
                    return hit
                }
                observation.finish(ordinal: ordinal, began: began, queryReturned: queryReturned,
                                   ended: ProcessInfo.processInfo.systemUptime, count: elements.count,
                                   evaluated: evaluated, firstHittable: firstHittable, value: value)
                return value
            }, object: nil)
            let waitBegan = ProcessInfo.processInfo.systemUptime
            let result = XCTWaiter.wait(for: [readable], timeout: 20)
            let waitReturned = ProcessInfo.processInfo.systemUptime
            if result == .timedOut {
                var payload = observation.freeze()
                let screenshotBegan = ProcessInfo.processInfo.systemUptime
                let screenshot = XCUIScreen.main.screenshot()
                let screenshotReturned = ProcessInfo.processInfo.systemUptime
                let image = XCTAttachment(screenshot: screenshot)
                image.name = "f5-first-open-after-timeout"; image.lifetime = .keepAlways; add(image)
                payload["schemaVersion"] = 1
                payload["scope"] = "first-open-only"
                payload["targetSaveExecuted"] = false
                payload["waitResult"] = "timedOut"
                payload["timeoutSeconds"] = 20
                payload["waitBeganUptime"] = waitBegan
                payload["nominalDeadlineUptime"] = waitBegan + 20
                payload["waitReturnedUptime"] = waitReturned
                payload["screenshotBeganUptime"] = screenshotBegan
                payload["screenshotReturnedUptime"] = screenshotReturned
                payload["sameFrameClaim"] = false
                payload["screenshotTiming"] = "API interval after wait return; actual pixel presentation time unavailable"
                do {
                    let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
                    let metadata = XCTAttachment(string: String(decoding: data, as: UTF8.self))
                    metadata.name = "f5-first-open-timeout-observation"; metadata.lifetime = .keepAlways; add(metadata)
                } catch {
                    let failure = XCTAttachment(string: "metadataEncodingFailed=true; original timedOut assertion retained")
                    failure.name = "f5-first-open-observation-error"; failure.lifetime = .keepAlways; add(failure)
                }
            }
            print("F5_FIRST_OPEN_RESULT raw=\(result.rawValue) targetSaveExecuted=false")
            XCTAssertEqual(result, .completed)
        } else {
        let readable = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in texts.allElementsBoundByIndex.contains { $0.isHittable } }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [readable], timeout: 20), .completed)
        }
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
        let app = start(fonts: true); defer { app.terminate() }
        let firstOpenOnly = ProcessInfo.processInfo.environment["XIANXIA_F5_FIRST_OPEN_ONLY"] == "1"
        if firstOpenOnly { print("F5_FIRST_OPEN_ONLY targetSaveExecuted=false") }
        open(in: app, observeFirstOpen: firstOpenOnly)
        if firstOpenOnly { return } // Diagnostic scope ends before settings/save; never full F5 acceptance.
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

// F5_FIRST_OPEN_OBSERVATION_HELPER_BEGIN
// Only primitive values from the original AX reads; one last sample, no body text/history.
private final class F5FirstOpenObservation {
    private let lock = NSLock()
    private var polls = 0
    private var inFlight = 0
    private var closed = false
    private var last: [String: Any] = [:]

    func begin() -> Int {
        lock.lock(); defer { lock.unlock() }
        polls += 1; inFlight += 1
        return polls
    }

    func finish(ordinal: Int, began: Double, queryReturned: Double, ended: Double,
                count: Int, evaluated: Int, firstHittable: Int?, value: Bool) {
        lock.lock(); defer { lock.unlock() }
        inFlight -= 1
        guard !closed else { return }
        last = ["ordinal": ordinal, "evaluationBeganUptime": began, "queryReturnedUptime": queryReturned,
                "evaluationEndedUptime": ended, "matchedCount": count, "evaluatedHittableCount": evaluated,
                "firstHittableIndex": firstHittable.map { $0 as Any } ?? NSNull(), "predicateResult": value]
    }

    func freeze() -> [String: Any] {
        lock.lock(); defer { lock.unlock() }
        closed = true
        return ["pollCount": polls, "evaluationsInFlightAtFreeze": inFlight, "lastCompletedEvaluation": last]
    }
}
// F5_FIRST_OPEN_OBSERVATION_HELPER_END
