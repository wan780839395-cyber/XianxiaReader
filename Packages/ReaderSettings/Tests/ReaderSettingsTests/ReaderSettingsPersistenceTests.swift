import Foundation
import XCTest
import XianxiaCore
@testable import ReaderSettings

final class ReaderSettingsPersistenceTests: XCTestCase {
    @MainActor func testAppearanceWritesAcrossReadersStayOrderedAndObsoleteResultsAreNotPublished() async {
        let storage = ControlledReaderSettingsStorage()
        defer { storage.failPendingWrites() }
        let store = ReaderSettingsPersistence(storage: storage)
        let firstStarted = expectation(description: "old reader write started")
        storage.onAppearanceStarted = { firstStarted.fulfill() }
        var first = ReadingAppearance(); first.fontScale = 1.1
        store.saveAppearance(first, owner: UUID())
        await fulfillment(of: [firstStarted], timeout: 2)

        let newestOwner = UUID()
        var second = first; second.fontScale = 1.3
        var last = second; last.fontScale = 1.6
        store.saveAppearance(second, owner: newestOwner)
        store.saveAppearance(last, owner: newestOwner)
        XCTAssertEqual(storage.appearanceAttempts, [first])

        let secondStarted = expectation(description: "second write follows old write")
        storage.onAppearanceStarted = { secondStarted.fulfill() }
        storage.finishAppearance(error: ControlledReaderSettingsStorage.Failure.write)
        await fulfillment(of: [secondStarted], timeout: 2)
        XCTAssertNil(store.appearanceCompletion, "An obsolete failure must not become the newer reader's error")

        let lastStarted = expectation(description: "last edit follows second write")
        storage.onAppearanceStarted = { lastStarted.fulfill() }
        storage.finishAppearance()
        await fulfillment(of: [lastStarted], timeout: 2)
        XCTAssertNil(store.appearanceCompletion, "An old success must not publish while the latest edit is pending")
        storage.finishAppearance()
        await store.flush()
        XCTAssertEqual(storage.appearanceAttempts, [first, second, last])
        XCTAssertEqual(storage.storedAppearance, last)
        XCTAssertEqual(store.appearanceCompletion?.owner, newestOwner)
        XCTAssertNil(store.appearanceCompletion?.errorMessage)
    }

    @MainActor func testLatestAppearanceFailureIsVisibleUntilExplicitRetrySucceeds() async {
        let storage = ControlledReaderSettingsStorage()
        defer { storage.failPendingWrites() }
        let store = ReaderSettingsPersistence(storage: storage)
        let owner = UUID()
        var value = ReadingAppearance(); value.theme = .charcoal
        let started = expectation(description: "failed appearance write")
        storage.onAppearanceStarted = { started.fulfill() }
        store.saveAppearance(value, owner: owner)
        await fulfillment(of: [started], timeout: 2)
        storage.finishAppearance(error: ControlledReaderSettingsStorage.Failure.write)
        await store.flush()
        XCTAssertNotNil(store.appearanceCompletion?.errorMessage)
        XCTAssertEqual(storage.storedAppearance, ReadingAppearance())

        let retryStarted = expectation(description: "explicit retry")
        storage.onAppearanceStarted = { retryStarted.fulfill() }
        store.saveAppearance(value, owner: owner)
        await fulfillment(of: [retryStarted], timeout: 2)
        XCTAssertNotNil(store.appearanceCompletion?.errorMessage)
        storage.finishAppearance()
        await store.flush()
        XCTAssertEqual(storage.storedAppearance, value)
        XCTAssertNil(store.appearanceCompletion?.errorMessage)
    }

    @MainActor func testInteractionWritesKeepLatestValueAndFailureIndependentOfAppearance() async {
        let storage = ControlledReaderSettingsStorage()
        defer { storage.failPendingWrites() }
        let store = ReaderSettingsPersistence(storage: storage)
        let owner = UUID()
        var first = ReadingInteraction(); first.automaticScrollSpeed = 2
        var last = first; last.automaticScrollSpeed = 3
        let started = expectation(description: "interaction first write")
        storage.onInteractionStarted = { started.fulfill() }
        store.saveInteraction(first, owner: owner)
        await fulfillment(of: [started], timeout: 2)
        store.saveInteraction(last, owner: owner)
        let lastStarted = expectation(description: "interaction latest write")
        storage.onInteractionStarted = { lastStarted.fulfill() }
        storage.finishInteraction()
        await fulfillment(of: [lastStarted], timeout: 2)
        storage.finishInteraction(error: ControlledReaderSettingsStorage.Failure.write)
        await store.flush()
        XCTAssertEqual(storage.storedInteraction, first)
        XCTAssertNotNil(store.interactionCompletion?.errorMessage)
        XCTAssertNil(store.appearanceCompletion)

        let retryStarted = expectation(description: "interaction retry")
        storage.onInteractionStarted = { retryStarted.fulfill() }
        store.saveInteraction(last, owner: owner)
        await fulfillment(of: [retryStarted], timeout: 2)
        storage.finishInteraction()
        await store.flush()
        XCTAssertEqual(storage.interactionAttempts, [first, last, last])
        XCTAssertEqual(storage.storedInteraction, last)
        XCTAssertNil(store.interactionCompletion?.errorMessage)
    }

    @MainActor func testFlushIncludesAppearanceQueuedWhileWaitingForInteraction() async {
        let storage = ControlledReaderSettingsStorage()
        defer { storage.failPendingWrites() }
        let store = ReaderSettingsPersistence(storage: storage)
        let appearanceStarted = expectation(description: "appearance lane started")
        let interactionStarted = expectation(description: "interaction lane started independently")
        storage.onAppearanceStarted = { appearanceStarted.fulfill() }
        storage.onInteractionStarted = { interactionStarted.fulfill() }
        store.saveAppearance(ReadingAppearance(), owner: UUID())
        store.saveInteraction(ReadingInteraction(), owner: UUID())
        await fulfillment(of: [appearanceStarted, interactionStarted], timeout: 2)
        let flushStarted = expectation(description: "flush entered")
        var flushFinished = false
        let flushing = Task { flushStarted.fulfill(); await store.flush(); flushFinished = true }
        await fulfillment(of: [flushStarted], timeout: 2)
        storage.finishAppearance()

        let newerStarted = expectation(description: "new edit while other lane is blocked")
        storage.onAppearanceStarted = { newerStarted.fulfill() }
        var newest = ReadingAppearance(); newest.fontScale = 1.8
        store.saveAppearance(newest, owner: UUID())
        await fulfillment(of: [newerStarted], timeout: 2)
        storage.finishInteraction()
        await Task.yield()
        XCTAssertFalse(flushFinished)
        storage.finishAppearance()
        await flushing.value
        XCTAssertTrue(flushFinished)
        XCTAssertEqual(storage.storedAppearance, newest)
    }

    @MainActor func testNewReaderRestoreWaitsForPendingAppearanceWrite() async throws {
        let storage = ControlledReaderSettingsStorage()
        defer { storage.failPendingWrites() }
        let store = ReaderSettingsPersistence(storage: storage)
        let started = expectation(description: "closing reader still writing")
        storage.onAppearanceStarted = { started.fulfill() }
        var value = ReadingAppearance(); value.theme = .paper
        store.saveAppearance(value, owner: UUID())
        await fulfillment(of: [started], timeout: 2)
        let restoreStarted = expectation(description: "new reader requested persisted settings")
        let restoring = Task { restoreStarted.fulfill(); return try await store.readingAppearance() }
        await fulfillment(of: [restoreStarted], timeout: 2)
        XCTAssertEqual(storage.appearanceReadCount, 0)
        storage.finishAppearance()
        let restored = try await restoring.value
        XCTAssertEqual(restored, value)
        XCTAssertEqual(storage.appearanceReadCount, 1)
    }

    @MainActor func testStorageReadErrorPropagatesWithoutReplacingSettingsWithDefaults() async {
        let storage = ControlledReaderSettingsStorage()
        storage.readFailure = true
        let store = ReaderSettingsPersistence(storage: storage)
        do { _ = try await store.readingAppearance(); XCTFail("A damaged preferences file must remain an error") }
        catch { XCTAssertTrue(error is ControlledReaderSettingsStorage.Failure) }
        do { _ = try await store.readingInteraction(); XCTFail("A damaged interaction file must remain an error") }
        catch { XCTAssertTrue(error is ControlledReaderSettingsStorage.Failure) }
        XCTAssertTrue(storage.appearanceAttempts.isEmpty)
        XCTAssertTrue(storage.interactionAttempts.isEmpty)
    }

    @MainActor func testRealFileStoreKeepsExistingPreferencePathsAndValues() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root)
        defer { do { try FileManager.default.removeItem(at: root) } catch { XCTFail("Fixture cleanup failed: \(error)") } }
        let store = ReaderSettingsPersistence(storage: files)
        var appearance = ReadingAppearance(); appearance.fontScale = 1.5; appearance.theme = .charcoal
        var interaction = ReadingInteraction(); interaction.reduceMotion = true
        store.saveAppearance(appearance, owner: UUID())
        store.saveInteraction(interaction, owner: UUID())
        await store.flush()
        let savedAppearance = try await files.readingAppearance()
        let savedInteraction = try await files.readingInteraction()
        XCTAssertEqual(savedAppearance, appearance); XCTAssertEqual(savedInteraction, interaction)
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("Preferences/reading-v1.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("Preferences/interaction-v1.json").path))
    }
}

/// Explicit continuations make ordering tests independent of disk speed and sleeps.
@MainActor final class ControlledReaderSettingsStorage: ReaderSettingsStorage {
    enum Failure: LocalizedError {
        case write, read
        var errorDescription: String? { "controlled settings \(self) failure" }
    }
    var storedAppearance = ReadingAppearance()
    var storedInteraction = ReadingInteraction()
    var appearanceAttempts: [ReadingAppearance] = []
    var interactionAttempts: [ReadingInteraction] = []
    var appearanceReadCount = 0
    var readFailure = false
    var onAppearanceStarted: (() -> Void)?
    var onInteractionStarted: (() -> Void)?
    private var appearancePending: [CheckedContinuation<Void, Error>] = []
    private var interactionPending: [CheckedContinuation<Void, Error>] = []
    private var closing = false

    func readingAppearance() async throws -> ReadingAppearance {
        appearanceReadCount += 1
        if readFailure { throw Failure.read }
        return storedAppearance
    }
    func readingInteraction() async throws -> ReadingInteraction {
        if readFailure { throw Failure.read }
        return storedInteraction
    }
    func saveReadingAppearance(_ value: ReadingAppearance) async throws {
        if closing { throw Failure.write }
        appearanceAttempts.append(value)
        try await withCheckedThrowingContinuation { continuation in
            appearancePending.append(continuation); onAppearanceStarted?()
        }
        storedAppearance = value
    }
    func saveReadingInteraction(_ value: ReadingInteraction) async throws {
        if closing { throw Failure.write }
        interactionAttempts.append(value)
        try await withCheckedThrowingContinuation { continuation in
            interactionPending.append(continuation); onInteractionStarted?()
        }
        storedInteraction = value
    }
    func finishAppearance(error: Error? = nil) {
        guard !appearancePending.isEmpty else { XCTFail("No pending appearance write"); return }
        let continuation = appearancePending.removeFirst()
        if let error { continuation.resume(throwing: error) } else { continuation.resume() }
    }
    func finishInteraction(error: Error? = nil) {
        guard !interactionPending.isEmpty else { XCTFail("No pending interaction write"); return }
        let continuation = interactionPending.removeFirst()
        if let error { continuation.resume(throwing: error) } else { continuation.resume() }
    }
    func failPendingWrites() {
        closing = true
        let appearances = appearancePending; appearancePending = []
        let interactions = interactionPending; interactionPending = []
        appearances.forEach { $0.resume(throwing: Failure.write) }
        interactions.forEach { $0.resume(throwing: Failure.write) }
    }
}
