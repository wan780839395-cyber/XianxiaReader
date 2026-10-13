import Foundation
import ReadingInterfaces
import UIKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReaderLifecycleTests: XCTestCase {
    @MainActor private final class SuspendedEngine: ReaderEngine {
        let viewController = UIViewController()
        var currentPosition: ReadingPosition?
        var onPositionChanged: ((ReadingPosition) -> Void)?
        var onCenterTap: (() -> Void)?
        var onError: ((String) -> Void)?
        var closeCount = 0
        var onOpenStarted: (() -> Void)?
        private var pending: CheckedContinuation<Void, Error>?

        func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws {
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
        func go(to chapter: Chapter) async throws {}
        func go(to position: ReadingPosition) async throws { currentPosition = position }
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
}
