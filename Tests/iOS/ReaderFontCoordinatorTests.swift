import Foundation
import ReaderFonts
import ReadingInterfaces
import XCTest
import XianxiaCore

/// Direct module contracts: no AppServices, file importer, engine or process-wide font registration.
@MainActor final class ReaderFontCoordinatorTests: XCTestCase {
    private let openingSession = UUID()
    private func prepareOpen(_ value: ReaderFontCoordinator, session: UUID? = nil) async throws {
        let owner = session ?? openingSession
        let loaded = try await value.loadResources()
        try value.commitOpening(loaded, session: owner)
    }
    private func asset(_ name: String) throws -> ReadingFontAsset {
        try ReadingFontAsset(id: UUID(), displayName: name, fileExtension: "ttf", sha256: String(repeating: "a", count: 64), bytes: 16)
    }
    private func coordinator(_ storage: FontCatalogFixture, bundled: [ReaderFontResource] = []) -> ReaderFontCoordinator {
        let value = ReaderFontCoordinator(storage: storage) { .init(fonts: [], resources: bundled, warning: nil) }
        value.beginSession(openingSession)
        addTeardownBlock { await storage.releaseAll() }
        return value
    }

    func testOpenLoadsBundledResourcesAndMissingImportFallsBackWithoutChangingPreference() async throws {
        let bundled = try asset("内置"), missing = try asset("丢失字体")
        let storage = FontCatalogFixture(); await storage.setFonts([missing]); await storage.setMissing(missing.id)
        let value = coordinator(storage, bundled: [.init(asset: bundled, fileURL: URL(fileURLWithPath: "/bundled.ttf"))])
        try await prepareOpen(value); value.markResourcesInstalled()
        XCTAssertEqual(value.importedFonts, [missing]); XCTAssertTrue(value.isAvailable(bundled.id))
        XCTAssertFalse(value.isAvailable(missing.id)); XCTAssertNotNil(value.message)
        var saved = ReadingAppearance(); saved.importedFontID = missing.id; saved.font = .serif
        let effective = value.effectiveAppearance(saved)
        XCTAssertNil(effective.importedFontID); XCTAssertEqual(effective.font, .original)
        XCTAssertEqual(saved.importedFontID, missing.id); XCTAssertEqual(saved.font, .serif)
        value.close()
    }

    func testBrowsingSkipsUnchangedFilesAndOnlyExplicitSelectionRequestsInstallation() async throws {
        let first = try asset("原字体"), added = try asset("外部字体")
        let storage = FontCatalogFixture(); await storage.setFonts([first])
        let value = coordinator(storage); try await prepareOpen(value); value.markResourcesInstalled()
        let initial = await storage.urlReads
        await value.refreshForBrowsing(); let unchanged = await storage.urlReads
        XCTAssertEqual(initial, unchanged)
        await storage.setFonts([first, added]); await value.refreshForBrowsing()
        XCTAssertEqual(value.importedFonts, [first, added]); XCTAssertNotNil(value.resourceForPreview(added.id))
        guard case .some(.install(let resource)) = value.importedSelection(added.id, appearance: .init(), isReady: true) else {
            return XCTFail("Browsing must expose the font without claiming the active navigator installed it")
        }
        XCTAssertEqual(resource.asset, added)
        value.markResourcesInstalled()
        guard case .some(.appearance(let selected)) = value.importedSelection(added.id, appearance: .init(), isReady: true) else {
            return XCTFail("Already installed fonts must use appearance application")
        }
        XCTAssertEqual(selected.importedFontID, added.id)
        let reset = value.builtInSelection(.serif, appearance: selected)
        XCTAssertNil(reset.importedFontID); XCTAssertEqual(reset.font, .serif)
        await value.refreshForBrowsing(force: true)
        let forced = await storage.urlReads; XCTAssertEqual(forced, initial + 4)
        value.close()
    }

    func testOlderBrowseCompletionAndCleanupCannotReplaceOrInvalidateNewerBrowse() async throws {
        let old = try asset("旧目录"), latest = try asset("新目录")
        let storage = FontCatalogFixture(), value = coordinator(storage)
        let firstStarted = expectation(description: "older list suspended")
        await storage.holdNextList { firstStarted.fulfill() }
        let first = Task { await value.refreshForBrowsing() }
        await fulfillment(of: [firstStarted], timeout: 10)
        await storage.setFonts([latest])
        let secondStarted = expectation(description: "new resource suspended")
        await storage.holdNextURL { secondStarted.fulfill() }
        let second = Task { await value.refreshForBrowsing() }
        await fulfillment(of: [secondStarted], timeout: 10)
        await storage.releaseList([old]); await first.value
        await storage.releaseURL(); await second.value
        XCTAssertEqual(value.importedFonts, [latest]); XCTAssertTrue(value.isAvailable(latest.id))
        XCTAssertFalse(value.isAvailable(old.id)); value.close()
    }

    func testImportInvalidatesPendingBrowseAndPublishesOnlyAfterExplicitCommit() async throws {
        let old = try asset("旧目录"), imported = try asset("导入结果")
        let storage = FontCatalogFixture(), value = coordinator(storage)
        let started = expectation(description: "browse suspended")
        await storage.holdNextList { started.fulfill() }
        let browse = Task { await value.refreshForBrowsing() }
        await fulfillment(of: [started], timeout: 10)
        let request = try XCTUnwrap(value.beginImport()); XCTAssertTrue(value.busy)
        await storage.setFonts([imported]); let loaded = try await value.loadResources()
        XCTAssertTrue(value.importedFonts.isEmpty, "Loading must not commit before the host rebuild succeeds")
        await value.refreshForBrowsing(); XCTAssertTrue(value.importedFonts.isEmpty)
        try value.commitImport(loaded, font: imported, request: request); value.finishImport(request)
        await storage.releaseList([old]); await browse.value
        XCTAssertEqual(value.importedFonts, [imported]); XCTAssertFalse(value.busy)
        guard case .some(.appearance(_)) = value.importedSelection(imported.id, appearance: .init(), isReady: true) else {
            return XCTFail("Successful import must remember which catalogue was installed")
        }
        value.close()
    }

    func testCloseReopenRejectsOldImportAndItsCleanupCannotClearNewBusyState() async throws {
        let storage = FontCatalogFixture(), value = coordinator(storage)
        let old = try XCTUnwrap(value.beginImport()); value.close(); value.beginSession(UUID())
        let current = try XCTUnwrap(value.beginImport())
        XCTAssertThrowsError(try value.checkCurrent(old)) { XCTAssertTrue($0 is CancellationError) }
        value.finishImport(old); XCTAssertTrue(value.busy); XCTAssertTrue(value.isCurrent(current))
        XCTAssertNil(value.beginImport(), "Only one import can own a catalogue at a time")
        value.finishImport(current); XCTAssertFalse(value.busy); value.close()
    }

    func testCloseReopenRejectsLateOpenCatalogueWithoutChangingNewSession() async throws {
        let old = try asset("旧会话"), latest = try asset("新会话")
        let storage = FontCatalogFixture(), value = coordinator(storage)
        let started = expectation(description: "old opening suspended")
        await storage.holdNextList { started.fulfill() }
        let opening = Task { try await prepareOpen(value) }
        await fulfillment(of: [started], timeout: 10)
        value.close(); let newSession = UUID(); value.beginSession(newSession)
        await storage.setFonts([latest]); try await prepareOpen(value, session: newSession)
        await storage.releaseList([old])
        do { try await opening.value; XCTFail("Late opening must be invalidated") }
        catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertEqual(value.importedFonts, [latest]); XCTAssertFalse(value.isAvailable(old.id)); value.close()
    }

    func testCancelledBrowseCannotPublishAndReadFailurePreservesLastCatalogue() async throws {
        let saved = try asset("现有字体"), added = try asset("取消结果")
        let storage = FontCatalogFixture(); await storage.setFonts([saved])
        let value = coordinator(storage); try await prepareOpen(value)
        let started = expectation(description: "cancelled refresh suspended")
        await storage.holdNextList { started.fulfill() }
        let refresh = Task { await value.refreshForBrowsing() }
        await fulfillment(of: [started], timeout: 10)
        refresh.cancel(); await storage.releaseList([added]); await refresh.value
        XCTAssertEqual(value.importedFonts, [saved]); XCTAssertFalse(value.isAvailable(added.id))
        await storage.failNextList(); await value.refreshForBrowsing(force: true)
        XCTAssertEqual(value.importedFonts, [saved]); XCTAssertTrue(value.isAvailable(saved.id)); XCTAssertNotNil(value.message)
        value.close()
    }
}

private actor FontCatalogFixture: ReaderFontCatalogStorage {
    private var fonts: [ReadingFontAsset] = []
    private var missing: UUID?
    private var listStarted: (@Sendable () -> Void)?
    private var urlStarted: (@Sendable () -> Void)?
    private var pendingList: CheckedContinuation<[ReadingFontAsset], Error>?
    private var pendingURL: CheckedContinuation<URL, Error>?
    private var pendingURLValue: URL?
    private var failList = false
    private(set) var urlReads = 0
    func setFonts(_ value: [ReadingFontAsset]) { fonts = value }
    func setMissing(_ id: UUID) { missing = id }
    func failNextList() { failList = true }
    func holdNextList(_ started: @escaping @Sendable () -> Void) { listStarted = started }
    func holdNextURL(_ started: @escaping @Sendable () -> Void) { urlStarted = started }
    func readingFonts() async throws -> [ReadingFontAsset] {
        if failList { failList = false; throw ReadingFontError.invalidFont }
        if let started = listStarted {
            listStarted = nil
            return try await withCheckedThrowingContinuation { pendingList = $0; started() }
        }
        return fonts
    }
    func readingFontURL(_ font: ReadingFontAsset) async throws -> URL {
        urlReads += 1
        if missing == font.id { throw ReadingFontError.missingFont }
        let url = URL(fileURLWithPath: "/fonts/\(font.id).ttf")
        if let started = urlStarted {
            urlStarted = nil; pendingURLValue = url
            return try await withCheckedThrowingContinuation { pendingURL = $0; started() }
        }
        return url
    }
    func releaseList(_ fonts: [ReadingFontAsset]) { let pending = pendingList; pendingList = nil; pending?.resume(returning: fonts) }
    func releaseURL() {
        let pending = pendingURL, url = pendingURLValue; pendingURL = nil; pendingURLValue = nil
        if let url { pending?.resume(returning: url) }
    }
    func releaseAll() {
        let list = pendingList, url = pendingURL; pendingList = nil; pendingURL = nil; pendingURLValue = nil
        list?.resume(throwing: CancellationError()); url?.resume(throwing: CancellationError())
    }
}
