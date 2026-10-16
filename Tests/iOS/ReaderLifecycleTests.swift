import Foundation
import ReadingInterfaces
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReaderLifecycleTests: XCTestCase {
    @MainActor func testReturnPointRetainsFirstFullAnchorAcrossContentsBookmarkSearchAndStay() async throws {
        let (book, services, engine, model) = try await context()
        let opened = expectation(description: "return reader open")
        engine.onOpenStarted = { opened.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [opened], timeout: 2); engine.finishOpen(); await opening.value
        let origin = ReadingPosition(bookID: book.id, engineID: "test", locatorVersion: 7,
            locatorData: Data([1, 3, 5, 7]), chapterTitle: "原处", progression: 0.42)
        engine.currentPosition = origin
        model.showAutomaticScroll(); model.startAutomaticScroll()
        await model.go(to: Chapter(id: "second", bookID: book.id, ordinal: 1, title: "查看处"))
        XCTAssertEqual(model.automaticScrollState, .paused)
        XCTAssertEqual(model.returnPosition, origin); XCTAssertFalse(model.menuVisible)
        let target = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([8]), progression: 0.8)
        await model.go(to: Bookmark(position: target, title: "远处"))
        try await model.go(to: ReaderSearchHit(title: "命中", before: "", highlight: "云海", after: "", position: target))
        XCTAssertEqual(model.returnPosition, origin); XCTAssertEqual(engine.captureCalls, 1)
        await model.saveNow()
        let savedTarget = try await services.repository.position(for: book.id)
        XCTAssertEqual(savedTarget?.locatorData, target.locatorData, "Progress follows the current page, not the return point")
        await model.returnToReading()
        XCTAssertEqual(engine.currentPosition?.locatorData, origin.locatorData)
        XCTAssertEqual(engine.currentPosition?.locatorVersion, 7)
        XCTAssertNil(model.returnPosition); XCTAssertFalse(model.navigationInProgress)
        engine.currentPosition = target
        await model.go(to: Bookmark(position: origin, title: "再次查看"))
        XCTAssertEqual(model.returnPosition, target)
        model.stayAtCurrentPosition(); XCTAssertNil(model.returnPosition)
        model.close()
    }

    @MainActor func testReturnPointFailureRetryAndClosePreserveCurrentProgressWithoutPersistingOrigin() async throws {
        struct Failure: LocalizedError { var errorDescription: String? { "原创跳转失败" } }
        let (book, services, engine, model) = try await context()
        let opened = expectation(description: "open return retry")
        engine.onOpenStarted = { opened.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [opened], timeout: 2); engine.finishOpen(); await opening.value
        let origin = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([1]), progression: 0.2)
        let target = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([9]), progression: 0.9)
        engine.currentPosition = origin; engine.navigationFailure = Failure()
        await model.go(to: Bookmark(position: target, title: "失败"))
        XCTAssertNil(model.returnPosition); XCTAssertNotNil(model.errorMessage)
        engine.navigationFailure = nil; model.errorMessage = nil
        await model.go(to: Bookmark(position: target, title: "成功"))
        engine.navigationFailure = Failure(); await model.returnToReading()
        XCTAssertEqual(model.returnPosition, origin); XCTAssertEqual(engine.currentPosition, target)
        XCTAssertNotNil(model.errorMessage); XCTAssertFalse(model.navigationInProgress)
        engine.navigationFailure = nil; model.errorMessage = nil
        await model.saveNow(); model.close()
        XCTAssertNil(model.returnPosition)
        let stored = try await services.repository.position(for: book.id)
        XCTAssertEqual(stored?.locatorData, target.locatorData)
        let reopened = expectation(description: "reopen at actual current target")
        engine.onOpenStarted = { reopened.fulfill() }
        let reopening = Task { await model.open() }
        await fulfillment(of: [reopened], timeout: 2); engine.finishOpen(); await reopening.value
        XCTAssertNil(model.returnPosition); XCTAssertEqual(engine.currentPosition?.locatorData, target.locatorData)
        model.close()
    }

    @MainActor func testReturnCaptureCloseReopenLateResultCannotNavigateOrClearNewRequest() async throws {
        let (book, _, engine, model) = try await context()
        let opened = expectation(description: "open before capture")
        engine.onOpenStarted = { opened.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [opened], timeout: 2); engine.finishOpen(); await opening.value
        let origin = ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([3]))
        let chapter = Chapter(id: "late", bookID: book.id, ordinal: 1, title: "目标")
        let capturing = expectation(description: "capture suspended")
        engine.onCaptureStarted = { capturing.fulfill() }
        let jumping = Task { await model.go(to: chapter) }
        await fulfillment(of: [capturing], timeout: 2)
        XCTAssertTrue(model.navigationInProgress)
        await model.go(to: chapter)
        XCTAssertEqual(engine.captureCalls, 1); XCTAssertEqual(engine.navigationCalls, 0)
        model.errorMessage = nil; model.close()
        let reopened = expectation(description: "new session")
        engine.onOpenStarted = { reopened.fulfill() }
        let reopening = Task { await model.open() }
        await fulfillment(of: [reopened], timeout: 2); engine.finishOpen(); await reopening.value
        let navigating = expectation(description: "new navigation suspended")
        engine.onCaptureStarted = nil; engine.currentPosition = origin
        engine.onGoStarted = { navigating.fulfill() }
        let next = Task { await model.go(to: chapter) }
        await fulfillment(of: [navigating], timeout: 2)
        engine.finishCapture(position: origin); await jumping.value
        XCTAssertEqual(engine.navigationCalls, 1); XCTAssertTrue(model.navigationInProgress)
        XCTAssertNil(model.returnPosition); XCTAssertNil(model.errorMessage)
        engine.finishNavigation(); await next.value
        XCTAssertEqual(model.returnPosition, origin); XCTAssertFalse(model.navigationInProgress)
        model.close()
    }

    @MainActor func testReturnCaptureFailureAndCancellationNeverPublishOrNavigate() async throws {
        let (book, _, engine, model) = try await context()
        let opened = expectation(description: "capture rejection")
        engine.onOpenStarted = { opened.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [opened], timeout: 2); engine.finishOpen(); await opening.value
        engine.captureFailure = ReaderPositionCaptureError.unavailable
        let chapter = Chapter(id: "fail", bookID: book.id, ordinal: 1, title: "目标")
        await model.go(to: chapter)
        XCTAssertEqual(engine.navigationCalls, 0); XCTAssertNil(model.returnPosition)
        XCTAssertNotNil(model.errorMessage); XCTAssertFalse(model.navigationInProgress)
        model.errorMessage = nil; engine.captureFailure = nil
        let capturing = expectation(description: "cancelled capture")
        engine.onCaptureStarted = { capturing.fulfill() }
        let jumping = Task { await model.go(to: chapter) }
        await fulfillment(of: [capturing], timeout: 2); jumping.cancel()
        engine.finishCapture(position: ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([1])))
        await jumping.value
        XCTAssertEqual(engine.navigationCalls, 0); XCTAssertNil(model.returnPosition)
        XCTAssertNil(model.errorMessage); XCTAssertFalse(model.navigationInProgress)
        model.close()
    }
    @MainActor func testAutomaticScrollPreferenceWriteFailurePausesAndRetryKeepsOriginalSettings() async throws {
        let (_, services, engine, model) = try await context()
        let started = expectation(description: "ready to test speed write failure")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        model.showAutomaticScroll(); await model.saveNow()
        let url = try services.files.resolve("Preferences/interaction-v1.json")
        let original = try Data(contentsOf: url)
        try FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        model.startAutomaticScroll(); model.adjustAutomaticScrollSpeed(by: 0.5)
        let failureDeadline = Date().addingTimeInterval(2)
        while model.interactionSaveFailure == nil && Date() < failureDeadline { try await Task.sleep(nanoseconds: 10_000_000) }
        XCTAssertNotNil(model.interactionSaveFailure); XCTAssertEqual(model.automaticScrollState, .paused)
        XCTAssertTrue(model.automaticScrollPresented)
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)); XCTAssertTrue(isDirectory.boolValue)
        try FileManager.default.removeItem(at: url); try original.write(to: url)
        model.retryInteractionSave()
        let retryDeadline = Date().addingTimeInterval(2)
        while model.interactionSaveFailure != nil && Date() < retryDeadline { try await Task.sleep(nanoseconds: 10_000_000) }
        XCTAssertNil(model.interactionSaveFailure)
        let restored = try await services.files.readingInteraction(); XCTAssertEqual(restored.automaticScrollSpeed, 2)
        XCTAssertEqual(model.automaticScrollState, .paused, "A successful retry must not resume movement")
        model.startAutomaticScroll(); engine.onError?("原创测试读取失败")
        XCTAssertEqual(model.automaticScrollState, .paused); XCTAssertEqual(model.errorMessage, "原创测试读取失败")
        model.close()
    }
    @MainActor func testAutomaticScrollExplicitStartSpeedPersistenceBackgroundPauseAndStaticReopen() async throws {
        let (_, services, engine, model) = try await context()
        let started = expectation(description: "ready for slow scroll")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        XCTAssertEqual(model.automaticScrollState, .stopped)
        model.showAutomaticScroll()
        XCTAssertTrue(model.automaticScrollPresented); XCTAssertEqual(model.readingMode, .continuous)
        XCTAssertEqual(engine.automaticStarts, 0, "Entering controls must not move text")
        model.startAutomaticScroll(); XCTAssertEqual(model.automaticScrollState, .running)
        model.adjustAutomaticScrollSpeed(by: 0.5)
        XCTAssertEqual(engine.automaticSpeed, 2)
        model.pauseAutomaticScroll(); XCTAssertEqual(model.automaticScrollState, .paused)
        await model.saveNow(); XCTAssertGreaterThan(engine.automaticFlushes, 0)
        let saved = try await services.files.readingInteraction(); XCTAssertEqual(saved.automaticScrollSpeed, 2)
        model.close(); engine.onAutomaticScrollStateChanged?(.running)
        XCTAssertEqual(model.automaticScrollState, .stopped, "Late callbacks after close cannot restart controls")
        let reopenedStarted = expectation(description: "reopen static")
        engine.onOpenStarted = { reopenedStarted.fulfill() }
        let reopened = Task { await model.open() }
        await fulfillment(of: [reopenedStarted], timeout: 2); engine.finishOpen(); await reopened.value
        XCTAssertEqual(model.interaction.automaticScrollSpeed, 2)
        XCTAssertFalse(model.automaticScrollPresented); XCTAssertEqual(model.automaticScrollState, .stopped)
        model.close()
    }

    @MainActor func testAutomaticScrollAdditionalReduceMotionAndModeExitCannotStartMotion() async throws {
        let (_, _, engine, model) = try await context()
        let started = expectation(description: "motion policy ready")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        model.showAutomaticScroll(); model.setAdditionalReduceMotion(true); model.startAutomaticScroll()
        XCTAssertEqual(engine.automaticStarts, 0); XCTAssertNotNil(model.errorMessage)
        model.setAdditionalReduceMotion(false); model.startAutomaticScroll()
        XCTAssertEqual(model.automaticScrollState, .running)
        model.setReadingMode(.horizontal)
        XCTAssertEqual(model.automaticScrollState, .stopped); XCTAssertFalse(model.automaticScrollPresented)
        model.close()
    }
    @MainActor func testVerticalScreenRestoreAndContinuousSwitchRetainSameSession() async throws {
        let (_, services, engine, model) = try await context()
        var saved = ReadingInteraction(); saved.continuousScrolling = true; saved.verticalScreenPaging = true
        try await services.files.saveReadingInteraction(saved)
        let started = expectation(description: "vertical mode ready before mount")
        engine.onOpenStarted = { XCTAssertEqual(engine.interaction, saved); started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        XCTAssertEqual(model.readingMode, .verticalScreen); XCTAssertEqual(engine.continuousChanges, 1)
        model.setReadingMode(.continuous)
        XCTAssertEqual(engine.continuousChanges, 1, "Input policy must not rebuild the continuous publication")
        XCTAssertEqual(model.readingMode, .continuous); XCTAssertFalse(try XCTUnwrap(engine.interaction).verticalScreenPaging)
        model.setReadingMode(.horizontal); XCTAssertEqual(engine.continuousChanges, 2)
        model.setReadingMode(.verticalScreen); XCTAssertEqual(engine.continuousChanges, 3)
        await model.saveNow()
        let restored = try await services.files.readingInteraction(); XCTAssertEqual(restored, saved)
        model.close()
    }

    @MainActor func testUnsupportedLayoutRetainsPreferredVerticalScreenForOtherBooks() async throws {
        let (_, services, engine, model) = try await context()
        var saved = ReadingInteraction(); saved.continuousScrolling = true; saved.verticalScreenPaging = true
        try await services.files.saveReadingInteraction(saved); engine.supportsContinuousScrolling = false
        let started = expectation(description: "unsupported vertical layout")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        XCTAssertEqual(model.readingMode, .horizontal); XCTAssertFalse(engine.continuous)
        let restored = try await services.files.readingInteraction(); XCTAssertEqual(restored, saved)
        model.close()
    }

    @MainActor private final class SuspendedEngine: ReaderEngine, ReaderAppearanceProviding, ReaderInteractionProviding, ReaderAutomaticScrollProviding {
        var automaticScrollProvider: (any ReaderAutomaticScrollProviding)? { self }
        var automaticScrollState = ReaderAutomaticScrollState.stopped
        var onAutomaticScrollStateChanged: ((ReaderAutomaticScrollState) -> Void)?
        var automaticStarts = 0
        var automaticFlushes = 0
        var automaticSpeed = 0.0
        func startAutomaticScroll(screensPerMinute: Double) throws {
            automaticStarts += 1; automaticSpeed = screensPerMinute
            automaticScrollState = .running; onAutomaticScrollStateChanged?(.running)
        }
        func pauseAutomaticScroll() {
            guard automaticScrollState.isActive else { return }
            automaticScrollState = .paused; onAutomaticScrollStateChanged?(.paused)
        }
        func stopAutomaticScroll() { automaticScrollState = .stopped; onAutomaticScrollStateChanged?(.stopped) }
        func flushAutomaticScrollPosition() async { automaticFlushes += 1 }
        let viewController = UIViewController()
        var currentPosition: ReadingPosition?
        var onPositionChanged: ((ReadingPosition) -> Void)?
        var onCenterTap: (() -> Void)?
        var onError: ((String) -> Void)?
        var interactionProvider: (any ReaderInteractionProviding)? { self }
        var onReadingGesture: (() -> Void)?
        var interaction: ReadingInteraction?
        var supportsContinuousScrolling = true
        var continuous = false
        var continuousChanges = 0
        func setInteraction(_ value: ReadingInteraction) throws { interaction = try value.validated() }
        func setContinuousScrolling(_ enabled: Bool) { continuous = enabled; continuousChanges += 1 }
        var closeCount = 0
        var appearanceProvider: (any ReaderAppearanceProviding)? { self }
        var supportsTextAppearance: Bool { true }
        var appearance: ReadingAppearance?
        func setAppearance(_ appearance: ReadingAppearance) throws { self.appearance = try appearance.validated() }
        var onOpenStarted: (() -> Void)?
        var onGoStarted: (() -> Void)?
        var onCaptureStarted: (() -> Void)?
        var captureCalls = 0
        var navigationCalls = 0
        var captureFailure: Error?
        var navigationFailure: Error?
        private var openedBookID: UUID?
        private var pendingCapture: CheckedContinuation<ReadingPosition, Error>?
        private var pending: CheckedContinuation<Void, Error>?
        private var pendingGo: CheckedContinuation<Void, Error>?

        func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws {
            openedBookID = book.id
            try await withCheckedThrowingContinuation { continuation in
                pending = continuation
                onOpenStarted?()
            }
            currentPosition = position
        }
        func finishOpen(error: Error? = nil) {
            let continuation = pending
            pending = nil
            if let error { continuation?.resume(throwing: error) }
            else { continuation?.resume() }
        }
        func close() { closeCount += 1; currentPosition = nil }
        func turnPage(forward: Bool) async {}
        func go(to chapter: Chapter) async throws { try await navigation() }
        func go(to position: ReadingPosition) async throws {
            try await navigation()
            currentPosition = position
        }
        func captureCurrentPosition() async throws -> ReadingPosition {
            captureCalls += 1
            if let captureFailure { throw captureFailure }
            if onCaptureStarted != nil {
                return try await withCheckedThrowingContinuation { continuation in
                    pendingCapture = continuation; onCaptureStarted?()
                }
            }
            if let currentPosition { return currentPosition }
            return ReadingPosition(bookID: try XCTUnwrap(openedBookID), engineID: "test", locatorData: Data([0]))
        }
        func finishCapture(position: ReadingPosition) {
            let pending = pendingCapture; pendingCapture = nil; pending?.resume(returning: position)
        }
        private func navigation() async throws {
            navigationCalls += 1
            if let navigationFailure { throw navigationFailure }
            if onGoStarted != nil {
                try await withCheckedThrowingContinuation { continuation in
                    pendingGo = continuation
                    onGoStarted?()
                }
            }
        }
        func finishNavigation(error: Error? = nil) {
            let continuation = pendingGo
            pendingGo = nil
            if let error { continuation?.resume(throwing: error) }
            else { continuation?.resume() }
        }
        func setScrolling(_ enabled: Bool) {}
    }

    @MainActor private struct Factory: ReaderEngineFactory {
        let engine: SuspendedEngine
        func makeEngine(for format: BookFormat) throws -> any ReaderEngine { engine }
    }

    @MainActor private func context() async throws -> (Book, AppServices, SuspendedEngine, ReaderViewModel) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        let files = try BookFileStore(root: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let book = Book(title: "生命周期测试", format: .epub, filePath: "Books/test/book.epub")
        try await repository.insert(book, chapters: [])
        let services = AppServices(repository: repository, files: files)
        let engine = SuspendedEngine()
        return (book, services, engine, ReaderViewModel(book: book, services: services, factory: Factory(engine: engine)))
    }

    @MainActor func testCloseDuringOpenCannotReturnReaderToReadyState() async throws {
        let (_, _, engine, model) = try await context()
        let started = expectation(description: "engine open suspended")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2)
        model.close()
        engine.finishOpen()
        await opening.value
        XCTAssertFalse(model.isReady)
        XCTAssertNil(model.openFailure)
        XCTAssertEqual(engine.closeCount, 1)
    }

    @MainActor func testAppearanceRestoresBeforeOpenAndRapidEditsPersistInOrder() async throws {
        let (_, services, engine, model) = try await context()
        var saved = ReadingAppearance(); saved.theme = .paper; saved.fontScale = 1.4
        try await services.files.saveReadingAppearance(saved)
        let started = expectation(description: "open with saved appearance")
        engine.onOpenStarted = { XCTAssertEqual(engine.appearance, saved); started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2)
        engine.finishOpen(); await opening.value
        for theme in ReadingTheme.allCases {
            var value = model.appearance; value.theme = theme; model.setAppearance(value)
        }
        await model.saveNow()
        let restored = try await services.files.readingAppearance()
        XCTAssertEqual(restored.theme, .oled); XCTAssertEqual(restored.fontScale, 1.4)
        XCTAssertNil(model.appearanceSaveFailure)
        model.close()
    }

    @MainActor func testInteractionRestoresSerialEditsAndLateGesturesCannotHideMenuAfterClose() async throws {
        let (_, services, engine, model) = try await context()
        var saved = ReadingInteraction(); saved.continuousScrolling = true; saved.reduceMotion = true
        try await services.files.saveReadingInteraction(saved)
        let started = expectation(description: "open with interaction")
        engine.onOpenStarted = { XCTAssertEqual(engine.interaction, saved); started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        XCTAssertTrue(model.scrolling); XCTAssertTrue(engine.continuous)
        engine.onReadingGesture?(); XCTAssertFalse(model.menuVisible)
        model.menuVisible = true
        for autoHide in [false, true, false] {
            var value = model.interaction; value.autoHideMenu = autoHide; model.setInteraction(value)
        }
        engine.onReadingGesture?(); XCTAssertTrue(model.menuVisible)
        model.setScrolling(false); await model.saveNow()
        let restored = try await services.files.readingInteraction()
        XCTAssertFalse(restored.autoHideMenu); XCTAssertFalse(restored.continuousScrolling); XCTAssertTrue(restored.reduceMotion)
        model.close(); engine.onReadingGesture?(); XCTAssertTrue(model.menuVisible)
    }

    @MainActor func testInteractionWriteFailureRetryAndAdditionalReductionDoesNotPersist() async throws {
        let (_, services, engine, model) = try await context()
        let started = expectation(description: "open")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        model.setAdditionalReduceMotion(true)
        XCTAssertEqual(engine.interaction?.reduceMotion, true)
        let directory = try services.files.resolve("Preferences")
        try Data([1]).write(to: directory)
        model.setScrolling(true); await model.saveNow()
        XCTAssertNotNil(model.interactionSaveFailure); XCTAssertTrue(model.isReady)
        try FileManager.default.removeItem(at: directory)
        model.retryInteractionSave(); await model.saveNow()
        XCTAssertNil(model.settingsSaveFailure)
        let restored = try await services.files.readingInteraction()
        XCTAssertTrue(restored.continuousScrolling); XCTAssertFalse(restored.reduceMotion)
        model.setAdditionalReduceMotion(false); XCTAssertEqual(engine.interaction?.reduceMotion, false)
        model.close()
    }

    @MainActor func testUnsupportedBookKeepsPreferredContinuousModeForOtherBooks() async throws {
        let (_, services, engine, model) = try await context()
        var saved = ReadingInteraction(); saved.continuousScrolling = true
        try await services.files.saveReadingInteraction(saved)
        engine.supportsContinuousScrolling = false
        let started = expectation(description: "open unsupported layout")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2); engine.finishOpen(); await opening.value
        XCTAssertFalse(model.scrolling); XCTAssertTrue(model.interaction.continuousScrolling)
        let restored = try await services.files.readingInteraction(); XCTAssertEqual(restored, saved)
        model.close()
    }

    @MainActor func testAppearanceWriteFailureShowsRetryAndKeepsCurrentReadingSession() async throws {
        let (_, services, engine, model) = try await context()
        let started = expectation(description: "open")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2)
        engine.finishOpen(); await opening.value
        let path = try services.files.resolve("Preferences")
        try Data([1]).write(to: path)
        var value = model.appearance; value.theme = .charcoal
        model.setAppearance(value); await model.saveNow()
        XCTAssertNotNil(model.appearanceSaveFailure); XCTAssertTrue(model.isReady)
        try FileManager.default.removeItem(at: path)
        model.retryAppearanceSave(); await model.saveNow()
        XCTAssertNil(model.appearanceSaveFailure)
        let restored = try await services.files.readingAppearance()
        XCTAssertEqual(restored, value); model.close()
    }

    @MainActor func testFailedOpenCanRetryAndBecomeReady() async throws {
        struct Failure: LocalizedError {
            var errorDescription: String? { "test open failure" }
        }
        let (_, _, engine, model) = try await context()
        let first = expectation(description: "first attempt")
        engine.onOpenStarted = { first.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [first], timeout: 2)
        engine.finishOpen(error: Failure())
        await opening.value
        XCTAssertEqual(model.openFailure, "test open failure")
        XCTAssertFalse(model.isReady)

        let second = expectation(description: "retry attempt")
        engine.onOpenStarted = { second.fulfill() }
        let retrying = Task { await model.retryOpen() }
        await fulfillment(of: [second], timeout: 2)
        engine.finishOpen()
        await retrying.value
        XCTAssertNil(model.openFailure)
        XCTAssertTrue(model.isReady)
        model.close()
    }

    @MainActor func testLatePositionAfterCloseIsNotPersisted() async throws {
        let (book, services, engine, model) = try await context()
        let started = expectation(description: "open")
        engine.onOpenStarted = { started.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [started], timeout: 2)
        engine.finishOpen()
        await opening.value
        model.close()
        engine.onPositionChanged?(ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([1])))
        XCTAssertNil(model.position)
        let restored = try await services.repository.position(for: book.id)
        XCTAssertNil(restored)
    }

    @MainActor func testLateChapterNavigationCannotHideReopenedReadersMenu() async throws {
        let (book, _, engine, model) = try await context()
        let opened = expectation(description: "open")
        engine.onOpenStarted = { opened.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [opened], timeout: 2)
        engine.finishOpen()
        await opening.value
        let started = expectation(description: "navigation suspended")
        engine.onGoStarted = { started.fulfill() }
        let jumping = Task { await model.go(to: Chapter(id: "test", bookID: book.id, ordinal: 0, title: "第一章")) }
        await fulfillment(of: [started], timeout: 2)
        model.close()
        let reopened = expectation(description: "reopen")
        engine.onOpenStarted = { reopened.fulfill() }
        let reopening = Task { await model.open() }
        await fulfillment(of: [reopened], timeout: 2)
        engine.finishOpen()
        await reopening.value
        model.menuVisible = true
        engine.finishNavigation()
        await jumping.value
        XCTAssertTrue(model.isReady)
        XCTAssertTrue(model.menuVisible)
        model.close()
    }

    @MainActor func testLateBookmarkFailureAfterCloseCannotShowError() async throws {
        struct Failure: LocalizedError { var errorDescription: String? { "late bookmark failure" } }
        let (book, _, engine, model) = try await context()
        let opened = expectation(description: "open")
        engine.onOpenStarted = { opened.fulfill() }
        let opening = Task { await model.open() }
        await fulfillment(of: [opened], timeout: 2)
        engine.finishOpen()
        await opening.value
        let started = expectation(description: "bookmark navigation suspended")
        engine.onGoStarted = { started.fulfill() }
        let bookmark = Bookmark(position: ReadingPosition(bookID: book.id, engineID: "test", locatorData: Data([0])), title: "测试")
        let jumping = Task { await model.go(to: bookmark) }
        await fulfillment(of: [started], timeout: 2)
        model.close()
        engine.finishNavigation(error: Failure())
        await jumping.value
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isReady)
    }
}
