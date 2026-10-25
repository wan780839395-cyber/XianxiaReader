import Combine
import Foundation
import ReaderSettings
import ReaderFonts
import ReaderPositions
import ReaderSessions
import ReadingInterfaces
import SwiftUI
import XianxiaCore

#if DEBUG
private let readerSaveDiagnosticsAvailable = true
#else
private let readerSaveDiagnosticsAvailable = false
#endif

enum ReaderMode: CaseIterable, Hashable {
    case horizontal, continuous, verticalScreen
    var title: String {
        switch self {
        case .horizontal: return "左右翻页"
        case .continuous: return "上下连续滚动"
        case .verticalScreen: return "上下整屏"
        }
    }
    var symbol: String {
        switch self {
        case .horizontal: return "book"
        case .continuous: return "scroll"
        case .verticalScreen: return "arrow.up.arrow.down.square"
        }
    }
}

enum ReaderSaveSource: String {
    case unspecified, settingsDismissed, returnToLibrary, sceneInactive, positionRetry
}

@MainActor final class ReaderViewModel: ObservableObject {
    @Published private(set) var isReady = false
    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var bookmarks: [Bookmark] = []
    let progress = ReaderProgressState()
    private(set) var position: ReadingPosition? {
        get { progress.position }
        set { progress.update(newValue) }
    }
    @Published private(set) var openFailure: String?
    @Published private(set) var openStatus = "正在打开书籍…"
    @Published var menuVisible = true
    @Published var scrolling = false
    @Published var errorMessage: String?
    @Published private(set) var appearance = ReadingAppearance()
    @Published private(set) var appearanceSaveFailure: String?
    @Published private(set) var interaction = ReadingInteraction()
    @Published private(set) var interactionSaveFailure: String?
    var positionSaveFailure: String? { positions.saveFailure }
    @Published private(set) var automaticScrollState = ReaderAutomaticScrollState.stopped
    @Published private(set) var automaticScrollPresented = false
    var returnPosition: ReadingPosition? { navigation.returnPosition }
    var navigationInProgress: Bool { navigation.inProgress }
    private let fonts: ReaderFontCoordinator
    var importedFonts: [ReadingFontAsset] { fonts.importedFonts }
    var fontBusy: Bool { fonts.busy }
    var fontMessage: String? {
        get { fonts.message }
        set { fonts.message = newValue }
    }
    @Published var choosingFont = false
    func fontResourceForPreview(_ id: UUID?) -> ReaderFontResource? { fonts.resourceForPreview(id) }
    private var fontImportTask: Task<Void, Never>?
    private var fontPickerCoordinator: EPUBDocumentPicker.Coordinator?
    var settingsSaveFailure: String? { appearanceSaveFailure ?? interactionSaveFailure ?? positionSaveFailure }
    var readingMode: ReaderMode {
        scrolling ? (interaction.verticalScreenPaging ? .verticalScreen : .continuous) : .horizontal
    }
    let engine: (any ReaderEngine)?
    private let book: Book
    private let services: AppServices
    private let sessions = ReaderSessionState()
    private var openRequestID: UUID? { sessions.requestID }
    private var settingsSubscriptions: Set<AnyCancellable> = []
    private var interactionHasPendingEngineEdits = false
    private var additionalReduceMotionRequested = false
    private let navigation = ReaderNavigationCoordinator()
    private var positions: ReaderPositionState { progress.positions }
    private lazy var positionPersistence = ReaderPositionPersistence(
        state: positions, storage: ReaderPositionRepository(services.repository))

    // F5 save observation: no publishing, tasks, engine reads or unbounded output.
    private let saveDiagnosticsEnabled = readerSaveDiagnosticsAvailable && ProcessInfo.processInfo.environment["XR_READER_UI_SETTINGS"] == "1"
    private lazy var saveDiagnosticOwner = UUID().uuidString
    private var saveDiagnosticRequests = 0
    private var saveDiagnosticRows: [String] = []
    var saveDiagnosticSummary: String {
        return saveDiagnosticRows.isEmpty ? "" : " | saveCoverage=first-32-requests,last-8-rows | " + saveDiagnosticRows.joined(separator: " | ")
    }

    private func beginSaveDiagnostic(source: ReaderSaveSource, sessionID: UUID?) -> String? {
        guard saveDiagnosticsEnabled, saveDiagnosticRequests < 32 else { return nil }
        saveDiagnosticRequests += 1
        let identity = "owner=\(saveDiagnosticOwner) session=\(sessionID?.uuidString ?? "nil") request=\(saveDiagnosticRequests) source=\(source.rawValue)"
        recordSaveDiagnostic("\(identity) phase=begin")
        return identity
    }

    private func recordSaveDiagnostic(_ value: String) {
        guard saveDiagnosticsEnabled else { return }
        let row = "t=\(Int(ProcessInfo.processInfo.systemUptime * 1000)) \(value)"
        saveDiagnosticRows.append(row)
        if saveDiagnosticRows.count > 8 { saveDiagnosticRows.removeFirst(saveDiagnosticRows.count - 8) }
        NSLog("XRSave %@", row)
    }

    init(book: Book, services: AppServices, factory: any ReaderEngineFactory) {
        self.book = book
        self.services = services
        fonts = ReaderFontCoordinator(storage: services.files, bundledResources: BundledReadingFont.catalogueResources)
        do { engine = try factory.makeEngine(for: book.format) }
        catch { engine = nil; openFailure = error.localizedDescription }
        positions.onSaveFailureWillChange = { [weak self] in self?.objectWillChange.send() }
        navigation.onStateWillChange = { [weak self] in self?.objectWillChange.send() }
        fonts.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &settingsSubscriptions)
        services.readerSettings.$appearanceCompletion.sink { [weak self] completion in
            guard let self, self.openRequestID != nil, completion?.owner == self.openRequestID else { return }
            self.appearanceSaveFailure = completion?.errorMessage.map { "设置尚未保存：\($0)" }
        }.store(in: &settingsSubscriptions)
        services.readerSettings.$interactionCompletion.sink { [weak self] completion in
            guard let self, self.openRequestID != nil, completion?.owner == self.openRequestID else { return }
            self.interactionSaveFailure = completion?.errorMessage.map { "阅读手感尚未保存：\($0)" }
            if completion?.errorMessage == nil { self.interactionHasPendingEngineEdits = false }
            else if self.interactionHasPendingEngineEdits { self.pauseAutomaticScroll() }
        }.store(in: &settingsSubscriptions)
    }

    private func bindEngineCallbacks(_ engine: any ReaderEngine, owner: UUID) {
        engine.onCenterTap = { [weak self] in
            guard let self else { return }
            self.sessions.accept(owner) {
                if self.automaticScrollPresented { self.pauseAutomaticScroll(); self.menuVisible = false }
                else { self.menuVisible.toggle() }
            }
        }
        engine.automaticScrollProvider?.onAutomaticScrollStateChanged = { [weak self] value in
            guard let self else { return }
            self.sessions.accept(owner) { self.automaticScrollState = value }
        }
        engine.interactionProvider?.onReadingGesture = { [weak self] in
            guard let self else { return }
            self.sessions.accept(owner) {
                guard self.isReady, self.interaction.autoHideMenu else { return }
                if self.menuVisible { self.menuVisible = false }
            }
        }
        engine.onError = { [weak self] message in
            guard let self else { return }
            self.sessions.accept(owner) {
                self.pauseAutomaticScroll()
                self.errorMessage = message
            }
        }
        engine.onPositionChanged = { [weak self] position in
            guard let self else { return }
            self.sessions.accept(owner, bookID: position.bookID) {
                self.position = position
                // Keep every accepted write, including close's final position.
                Task {
                    await self.positionPersistence.persistEmitted(position) { message in
                        self.sessions.accept(owner) {
                            self.pauseAutomaticScroll()
                            self.errorMessage = message
                        }
                    }
                }
            }
        }
    }

    // Bound methods preserve the caller's task and avoid an async forwarding
    // wrapper. The transient lifecycle retains this model for that invocation.
    var open: @MainActor () async -> Void { makeSessionLifecycle().open }
    var retryOpen: @MainActor () async -> Void { makeSessionLifecycle().retryOpen }
    func close() { makeSessionLifecycle().close() }

    private func makeSessionLifecycle() -> ReaderSessionLifecycle<ReaderSessionHost> {
        let engine = engine
        let repository: any BookRepository = services.repository
        return ReaderSessionLifecycle(state: sessions, host: ReaderSessionHost(
            bookID: book.id, book: book,
            readAppearance: services.readerSettings.readingAppearance,
            loadFonts: fonts.loadResources,
            readInteraction: services.readerSettings.readingInteraction,
            readPosition: repository.position(for:),
            readChapters: repository.chapters(for:),
            readBookmarks: repository.bookmarks(for:),
            openEngine: engine?.open(book:fileURL:position:),
            resolveFile: { try self.services.files.resolve(self.book.filePath) },
            begin: { owner in
                if let engine { self.bindEngineCallbacks(engine, owner: owner) }
                self.fonts.beginSession(owner)
            },
            showStage: { stage in
                switch stage {
                case .settings: self.openStatus = "正在读取阅读设置…"
                case .fonts: self.openStatus = "正在准备字体…"
                case .position: self.openStatus = "正在恢复阅读位置…"
                case .layout: self.openStatus = "正在排版书籍…"
                }
            },
            clearSaveFailure: positions.clearSaveFailure,
            commitFonts: fonts.commitOpening(_:session:),
            reportFontFailure: fonts.reportOpeningFailure(_:session:),
            applyAppearance: { restored in
                try engine?.fontProvider?.setReadingFonts(self.fonts.resources)
                self.fonts.markResourcesInstalled()
                try engine?.appearanceProvider?.setAppearance(self.effectiveAppearance(restored))
                self.appearance = restored
            },
            applyInteraction: { restored in
                try self.applyInteraction(restored)
                self.interaction = restored
                self.interactionHasPendingEngineEdits = false
            },
            publishChapters: { self.chapters = $0 },
            publishBookmarks: { self.bookmarks = $0 },
            publishReady: { restored in
                if let currentChapters = engine?.currentChapters { self.chapters = currentChapters }
                self.scrolling = restored.continuousScrolling && engine?.supportsContinuousScrolling == true
                if self.scrolling { engine?.setContinuousScrolling(true) }
                self.position = engine?.currentPosition
                self.isReady = true
            },
            publishOpenFailure: { self.openFailure = $0 },
            invalidatePositionCapture: positions.invalidateSave,
            closeFonts: {
                self.fonts.close()
                self.fontImportTask?.cancel(); self.fontImportTask = nil
                self.fontPickerCoordinator?.invalidate(); self.fontPickerCoordinator = nil
                self.choosingFont = false
            },
            closeNavigation: navigation.close,
            closeEngine: { engine?.close() },
            publishClosed: {
                self.isReady = false
                self.automaticScrollState = .stopped
                self.automaticScrollPresented = false
            }))
    }

    /// A covered navigator may still be rebuilding its DOM. Commit the settings
    /// here; the presenting reader requests a fresh full position on dismissal.
    func saveSettingsNow() async -> Bool {
        pauseAutomaticScroll()
        guard let sessionID = openRequestID, !Task.isCancelled else { return false }
        await services.readerSettings.flush()
        guard openRequestID == sessionID, !Task.isCancelled else { return false }
        return appearanceSaveFailure == nil && interactionSaveFailure == nil
    }

    func saveNow(source: ReaderSaveSource = .unspecified) async {
        pauseAutomaticScroll()
        let sessionID = openRequestID
        let requestID = positions.beginSave(sessionID: sessionID)
        defer { positions.endSave(requestID) }
        let diagnosticID = beginSaveDiagnostic(source: source, sessionID: sessionID)
        var phase = "motion-flush", capture = "not-entered"
        var returnedNil = 0, engineUnavailable = 0
        defer {
            if let diagnosticID {
                recordSaveDiagnostic("\(diagnosticID) phase=end boundary=\(phase) capture=\(capture) returnedNil=\(returnedNil) engineUnavailable=\(engineUnavailable) ready=\(isReady) positionFailure=\(positionSaveFailure != nil) settingsFailure=\(settingsSaveFailure != nil)")
            }
        }
        await engine?.automaticScrollProvider?.flushAutomaticScrollPosition()
        guard positions.isCurrent(requestID, sessionID: openRequestID), !Task.isCancelled else { return }
        phase = "settings-flush"
        await services.readerSettings.flush()
        guard positions.isCurrent(requestID, sessionID: openRequestID),
              !Task.isCancelled, sessionID != nil, isReady, let engine else { return }
        phase = "position"
        let unavailableObserver: ((ReaderEnginePositionSource.UnavailableReason) -> Void)? = diagnosticID == nil ? nil : { reason in
            switch reason {
            case .returnedNil: returnedNil += 1
            case .engineUnavailable: engineUnavailable += 1
            }
        }
        let captureObserver: ((ReaderPositionPersistence.CaptureDiagnostic) -> Void)? = diagnosticID == nil ? nil : { value in
            capture = "\(value.reason.rawValue),attempts:\(value.attempts),unavailable:\(value.unavailableCaptures),failurePublished:\(value.failurePublished)"
        }
        await positionPersistence.captureAndSave(from: ReaderEnginePositionSource(engine, observeUnavailable: unavailableObserver), request: requestID,
                                                 diagnostic: captureObserver) { self.openRequestID }
        phase = "returned"
    }

    func setAppearance(_ value: ReadingAppearance) {
        pauseAutomaticScroll()
        guard isReady, !fontBusy, let provider = engine?.appearanceProvider else { return }
        do {
            try provider.setAppearance(effectiveAppearance(value))
            appearance = value
        } catch { errorMessage = error.localizedDescription; return }
        saveAppearanceValue(value)
    }

    private func saveAppearanceValue(_ value: ReadingAppearance) {
        guard let owner = openRequestID else { return }
        services.readerSettings.saveAppearance(value, owner: owner)
    }

    func retryAppearanceSave() { setAppearance(appearance) }

    func selectBuiltInFont(_ font: ReadingFont) {
        setAppearance(fonts.builtInSelection(font, appearance: appearance))
    }

    func selectImportedFont(_ id: UUID) {
        guard let selection = fonts.importedSelection(id, appearance: appearance, isReady: isReady) else { return }
        switch selection {
        case .install(let resource):
            // Browsing never installs a new catalogue; explicit selection owns the rebuild.
            fontImportTask = Task { await importReadingFont(from: resource.fileURL) }
        case .appearance(let updated): setAppearance(updated)
        }
    }

    func isFontAvailable(_ id: UUID) -> Bool { fonts.isAvailable(id) }

    func refreshFontCatalogueForBrowsing(force: Bool = false) async {
        guard isReady else { return }
        await fonts.refreshForBrowsing(force: force)
    }

    func retainFontCoordinator(_ coordinator: EPUBDocumentPicker.Coordinator) {
        fontPickerCoordinator?.invalidate(); fontPickerCoordinator = coordinator
    }

    func receiveFontFiles(_ result: Result<[URL], Error>?) {
        fontPickerCoordinator = nil; choosingFont = false
        switch result {
        case .success(let urls):
            guard let url = urls.first else { fontMessage = ReadingFontError.unsupportedFile.localizedDescription; return }
            fontImportTask = Task { await importReadingFont(from: url) }
        case .failure(let error): fontMessage = error.localizedDescription
        case nil: break
        }
    }

    private func effectiveAppearance(_ value: ReadingAppearance) -> ReadingAppearance {
        fonts.effectiveAppearance(value)
    }

    /// A new catalogue is installed once at navigator construction. Ordinary
    /// selection among already loaded fonts still uses bounded native reflow.
    func importReadingFont(from source: URL) async {
        guard isReady, !fontBusy, !navigationInProgress, let engine, let provider = engine.fontProvider,
              let session = openRequestID else { return }
        guard let fontRequest = fonts.beginImport() else { return }
        let request = fontRequest.id
        defer { fonts.finishImport(fontRequest) }
        func current() throws {
            try fonts.checkCurrent(fontRequest)
            guard openRequestID == session else { throw CancellationError() }
        }
        var anchor: ReadingPosition?
        var rebuilding = false
        let oldResources = fonts.resources, oldAppearance = appearance
        do {
            pauseAutomaticScroll()
            let font = try await ReadingFontImportService(files: services.files).importFont(from: source)
            try current()
            let loaded = try await fonts.loadResources()
            try current()
            guard loaded.resources.contains(where: { $0.asset.id == font.id }) else { throw ReadingFontError.missingFont }
            let position = try await engine.captureCurrentPosition()
            try current()
            try await services.repository.save(position)
            try current()
            anchor = position
            navigation.beginExternal(request)
            defer { navigation.endExternal(request) }
            var updated = appearance; updated.importedFontID = font.id
            engine.close(); rebuilding = true
            try provider.setReadingFonts(loaded.resources)
            try engine.appearanceProvider?.setAppearance(updated)
            try await engine.open(book: book, fileURL: services.files.resolve(book.filePath), position: position)
            try current()
            try fonts.commitImport(loaded, font: font, request: fontRequest)
            appearance = updated
            self.position = engine.currentPosition
            saveAppearanceValue(updated)
        } catch is CancellationError {
            // Closing invalidates this request. Never close or mutate a reopened reader.
            if openRequestID == session, fonts.isCurrent(fontRequest), rebuilding {
                engine.close(); isReady = false; sessions.allowReopening()
                openFailure = "字体应用已取消，请重试打开。"
            }
        } catch {
            guard openRequestID == session, fonts.isCurrent(fontRequest) else { return }
            let original = error.localizedDescription
            if rebuilding, let anchor {
                do {
                    engine.close(); try provider.setReadingFonts(oldResources)
                    try engine.appearanceProvider?.setAppearance(effectiveAppearance(oldAppearance))
                    try await engine.open(book: book, fileURL: services.files.resolve(book.filePath), position: anchor)
                    try current()
                } catch {
                    guard openRequestID == session, fonts.isCurrent(fontRequest) else { return }
                    isReady = false; sessions.allowReopening()
                    openFailure = "字体应用失败：\(original)。恢复阅读失败：\(error.localizedDescription)"
                }
            }
            fontMessage = "字体操作未完成：\(original)。可重新导入；已经导入的文件会保留。"
            // Reload the list even when capture was not stable; importing and
            // changing the current reading layout have separate commit points.
            do {
                try await fonts.reloadImportedFonts(for: fontRequest)
                try current()
            } catch {
                guard openRequestID == session, fonts.isCurrent(fontRequest) else { return }
                fontMessage = "\(original)。字体列表：\(error.localizedDescription)"
            }
        }
    }

    func setScrolling(_ value: Bool) {
        setReadingMode(value ? .continuous : .horizontal)
    }

    func setReadingMode(_ mode: ReaderMode) {
        if automaticScrollPresented && mode != .continuous { endAutomaticScroll() }
        guard isReady, engine?.interactionProvider != nil else { return }
        let continuous = mode != .horizontal
        guard !continuous || engine?.supportsContinuousScrolling == true else {
            errorMessage = "这本书暂不支持上下连续滚动。"
            return
        }
        var updated = interaction
        updated.continuousScrolling = continuous
        updated.verticalScreenPaging = mode == .verticalScreen
        setInteraction(updated)
        guard interaction == updated else { return }
        // Snapping is an input policy on the same continuous DOM. Do not
        // rebuild or resample the publication when only that policy changes.
        if scrolling != continuous { engine?.setContinuousScrolling(continuous) }
        scrolling = continuous
    }

    func setInteraction(_ value: ReadingInteraction) {
        guard isReady, engine?.interactionProvider != nil else { return }
        do { try applyInteraction(value); interaction = value }
        catch { errorMessage = error.localizedDescription; return }
        guard let owner = openRequestID else { return }
        interactionHasPendingEngineEdits = true
        services.readerSettings.saveInteraction(value, owner: owner)
    }

    func setBookProgressVisible(_ visible: Bool) {
        guard isReady, let owner = openRequestID else { return }
        var updated = interaction
        updated.showsBookProgress = visible
        interaction = updated
        services.readerSettings.saveInteraction(updated, owner: owner)
    }

    func retryInteractionSave() {
        if interactionHasPendingEngineEdits { setInteraction(interaction) }
        else { setBookProgressVisible(interaction.showsBookProgress) }
    }

    func setAdditionalReduceMotion(_ requested: Bool) {
        if requested { pauseAutomaticScroll() }
        additionalReduceMotionRequested = requested
        do { try applyInteraction(interaction) }
        catch { errorMessage = error.localizedDescription }
    }

    private func applyInteraction(_ value: ReadingInteraction) throws {
        var effective = value
        effective.reduceMotion = effective.reduceMotion || additionalReduceMotionRequested
        try engine?.interactionProvider?.setInteraction(effective)
    }

    func go(to chapter: Chapter) async {
        let requestID = openRequestID
        do {
            try await navigate { try await $0.go(to: chapter) }
        } catch is CancellationError {
            return
        } catch {
            guard openRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }

    func go(to bookmark: Bookmark) async {
        let requestID = openRequestID
        do {
            try await navigate { try await $0.go(to: bookmark.position) }
        } catch is CancellationError {
            return
        } catch {
            guard openRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }

    func go(to result: ReaderSearchHit) async throws {
        try await navigate { try await $0.go(to: result.position) }
    }

    func returnToReading() async {
        guard let origin = returnPosition else { return }
        let requestID = openRequestID
        do {
            try await navigate(returning: true) { try await $0.go(to: origin) }
        } catch is CancellationError {
            return
        } catch {
            guard openRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }

    func stayAtCurrentPosition() {
        navigation.stay()
    }

    private func navigate(returning: Bool = false,
                          operation: @MainActor (any ReaderEngine) async throws -> Void) async throws {
        guard isReady, let engine, let session = openRequestID else { throw ReaderPositionCaptureError.unavailable }
        do {
            try await navigation.navigate(bookID: book.id, session: session, sessionID: { self.openRequestID },
                isBlocked: { self.fontBusy }, pause: { self.pauseAutomaticScroll() },
                capture: { try await engine.captureCurrentPosition() }, onSuccess: { self.menuVisible = false },
                operation: { try await operation(engine) }, returning: returning)
        } catch ReaderNavigationError.unavailable {
            throw ReaderPositionCaptureError.unavailable
        }
    }

    func addBookmark() async {
        guard let position = engine?.currentPosition else {
            errorMessage = "阅读页面尚未准备好，请稍后添加书签。"
            return
        }
        do {
            try await services.repository.add(Bookmark(position: position, title: position.chapterTitle ?? book.title))
            bookmarks = try await services.repository.bookmarks(for: book.id)
        } catch { errorMessage = error.localizedDescription }
    }

    func removeBookmark(_ bookmark: Bookmark) async {
        do {
            try await services.repository.removeBookmark(bookmark.id)
            bookmarks = try await services.repository.bookmarks(for: book.id)
        } catch { errorMessage = error.localizedDescription }
    }

    func showAutomaticScroll() {
        guard isReady, engine?.supportsContinuousScrolling == true, engine?.automaticScrollProvider != nil else { return }
        setReadingMode(.continuous)
        automaticScrollPresented = true
        menuVisible = false
    }

    func startAutomaticScroll() {
        guard !navigationInProgress else { return }
        guard isReady, automaticScrollPresented, !additionalReduceMotionRequested, !interaction.reduceMotion else {
            errorMessage = "开启减少动态效果时自动慢滚停用。可在阅读设置中调整。"
            return
        }
        do { try engine?.automaticScrollProvider?.startAutomaticScroll(screensPerMinute: interaction.automaticScrollSpeed) }
        catch { errorMessage = error.localizedDescription }
    }

    func pauseAutomaticScroll() { engine?.automaticScrollProvider?.pauseAutomaticScroll() }

    func endAutomaticScroll() {
        pauseAutomaticScroll()
        engine?.automaticScrollProvider?.stopAutomaticScroll()
        automaticScrollState = .stopped
        automaticScrollPresented = false
        menuVisible = true
    }

    func adjustAutomaticScrollSpeed(by amount: Double) {
        var updated = interaction
        updated.automaticScrollSpeed = min(6, max(0.5, updated.automaticScrollSpeed + amount))
        setInteraction(updated)
        if automaticScrollState.isActive { startAutomaticScroll() }
    }
}
