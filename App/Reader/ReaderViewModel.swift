import Foundation
import ReadingInterfaces
import SwiftUI
import XianxiaCore

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

private enum ReaderJumpError: LocalizedError {
    case busy
    var errorDescription: String? { "正在跳转，请稍候。" }
}

@MainActor final class ReaderViewModel: ObservableObject {
    @Published private(set) var isReady = false
    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var bookmarks: [Bookmark] = []
    @Published private(set) var position: ReadingPosition?
    @Published private(set) var openFailure: String?
    @Published private(set) var openStatus = "正在打开书籍…"
    @Published var menuVisible = true
    @Published var scrolling = false
    @Published var errorMessage: String?
    @Published private(set) var appearance = ReadingAppearance()
    @Published private(set) var appearanceSaveFailure: String?
    @Published private(set) var interaction = ReadingInteraction()
    @Published private(set) var interactionSaveFailure: String?
    @Published private(set) var positionSaveFailure: String?
    @Published private(set) var automaticScrollState = ReaderAutomaticScrollState.stopped
    @Published private(set) var automaticScrollPresented = false
    @Published private(set) var returnPosition: ReadingPosition?
    @Published private(set) var navigationInProgress = false
    @Published private(set) var importedFonts: [ReadingFontAsset] = []
    @Published private(set) var fontBusy = false
    @Published private(set) var fontMessage: String?
    @Published var choosingFont = false
    private var fontResources: [ReaderFontResource] = []
    private var installedFontIDs: Set<UUID> = []
    private var fontCatalogRequestID: UUID?
    func fontResourceForPreview(_ id: UUID?) -> ReaderFontResource? {
        guard let id else { return nil }
        return fontResources.first { $0.asset.id == id }
    }
    private var fontRequestID: UUID?
    private var fontImportTask: Task<Void, Never>?
    private var fontPickerCoordinator: EPUBDocumentPicker.Coordinator?
    var settingsSaveFailure: String? { appearanceSaveFailure ?? interactionSaveFailure ?? positionSaveFailure }
    var readingMode: ReaderMode {
        scrolling ? (interaction.verticalScreenPaging ? .verticalScreen : .continuous) : .horizontal
    }
    let engine: (any ReaderEngine)?
    private let book: Book
    private let services: AppServices
    private var started = false
    private var openRequestID: UUID?
    private var appearanceSaveTask: Task<Void, Never>?
    private var interactionSaveTask: Task<Void, Never>?
    private var additionalReduceMotionRequested = false
    private var navigationRequestID: UUID?
    private var positionSaveRequestID: UUID?

    init(book: Book, services: AppServices, factory: any ReaderEngineFactory) {
        self.book = book
        self.services = services
        do { engine = try factory.makeEngine(for: book.format) }
        catch { engine = nil; openFailure = error.localizedDescription }
        engine?.onCenterTap = { [weak self] in
            guard let self else { return }
            if self.automaticScrollPresented { self.pauseAutomaticScroll(); self.menuVisible = false }
            else { self.menuVisible.toggle() }
        }
        engine?.automaticScrollProvider?.onAutomaticScrollStateChanged = { [weak self] value in
            guard let self, self.openRequestID != nil else { return }
            self.automaticScrollState = value
        }
        engine?.interactionProvider?.onReadingGesture = { [weak self] in
            guard let self, self.openRequestID != nil, self.isReady, self.interaction.autoHideMenu else { return }
            self.menuVisible = false
        }
        engine?.onError = { [weak self] message in
            self?.pauseAutomaticScroll()
            self?.errorMessage = message
        }
        engine?.onPositionChanged = { [weak self] position in
            guard let self, self.openRequestID != nil else { return }
            self.position = position
            // Save each emitted position immediately; SQLite rejects stale out-of-order writes.
            Task { await self.persist(position) }
        }
    }

    func open() async {
        guard !started, let engine else { return }
        started = true
        let requestID = UUID()
        openRequestID = requestID
        openStatus = "正在读取阅读设置…"
        positionSaveFailure = nil
        do {
            let restoredAppearance = try await services.files.readingAppearance()
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            openStatus = "正在准备字体…"
            do {
                let loaded = try await loadFontResources()
                try Task.checkCancellation()
                guard openRequestID == requestID else { throw CancellationError() }
                importedFonts = loaded.fonts; fontResources = loaded.resources; fontMessage = loaded.warning
            } catch is CancellationError { throw CancellationError() }
            catch {
                guard openRequestID == requestID else { throw CancellationError() }
                fontResources = []; fontMessage = error.localizedDescription
            }
            try engine.fontProvider?.setReadingFonts(fontResources)
            installedFontIDs = Set(fontResources.map { $0.asset.id })
            try engine.appearanceProvider?.setAppearance(effectiveAppearance(restoredAppearance))
            appearance = restoredAppearance
            openStatus = "正在恢复阅读位置…"
            let restoredInteraction = try await services.files.readingInteraction()
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            try applyInteraction(restoredInteraction)
            interaction = restoredInteraction
            let restored = try await services.repository.position(for: book.id)
            chapters = try await services.repository.chapters(for: book.id)
            bookmarks = try await services.repository.bookmarks(for: book.id)
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            openStatus = "正在排版书籍…"
            try await engine.open(book: book, fileURL: services.files.resolve(book.filePath), position: restored)
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            if let currentChapters = engine.currentChapters { chapters = currentChapters }
            scrolling = restoredInteraction.continuousScrolling && engine.supportsContinuousScrolling
            if scrolling { engine.setContinuousScrolling(true) }
            position = engine.currentPosition
            isReady = true
        } catch is CancellationError {
            guard openRequestID == requestID else { return }
            engine.close()
            openRequestID = nil
            started = false
        } catch {
            guard openRequestID == requestID else { return }
            openFailure = error.localizedDescription
        }
    }

    func retryOpen() async {
        guard engine != nil else { return }
        close()
        openFailure = nil
        await open()
    }

    func close() {
        positionSaveRequestID = nil
        fontCatalogRequestID = nil; installedFontIDs = []
        fontRequestID = nil; fontImportTask?.cancel(); fontImportTask = nil
        fontPickerCoordinator?.invalidate(); fontPickerCoordinator = nil
        choosingFont = false; fontBusy = false
        navigationRequestID = nil
        navigationInProgress = false
        returnPosition = nil
        // Allow the engine's final position callback before invalidating this session.
        engine?.close()
        openRequestID = nil
        started = false
        isReady = false
        automaticScrollState = .stopped
        automaticScrollPresented = false
    }

    func saveNow() async {
        pauseAutomaticScroll()
        let sessionID = openRequestID
        let requestID = UUID()
        positionSaveRequestID = requestID
        defer {
            if positionSaveRequestID == requestID { positionSaveRequestID = nil }
        }
        await engine?.automaticScrollProvider?.flushAutomaticScrollPosition()
        guard openRequestID == sessionID, positionSaveRequestID == requestID, !Task.isCancelled else { return }
        await appearanceSaveTask?.value
        guard openRequestID == sessionID, positionSaveRequestID == requestID, !Task.isCancelled else { return }
        await interactionSaveTask?.value
        guard openRequestID == sessionID, positionSaveRequestID == requestID,
              !Task.isCancelled, sessionID != nil, isReady, let engine else { return }
        do {
            var sampled: ReadingPosition?
            if engine.appearanceProvider?.supportsTextAppearance == false {
                // Fixed-layout pages keep their full page locator; they have no
                // reflowable DOM anchor to sample.
                guard let page = engine.currentPosition else { throw ReaderPositionCaptureError.unavailable }
                sampled = page
            } else {
                let deadline = Date().addingTimeInterval(3)
                while sampled == nil {
                    do { sampled = try await engine.captureCurrentPosition() }
                    catch ReaderPositionCaptureError.unavailable {
                        guard openRequestID == sessionID, positionSaveRequestID == requestID, !Task.isCancelled else { return }
                        guard Date() < deadline else { throw ReaderPositionCaptureError.unavailable }
                        try await Task.sleep(nanoseconds: 32_000_000)
                        guard openRequestID == sessionID, positionSaveRequestID == requestID, !Task.isCancelled else { return }
                    }
                }
            }
            try Task.checkCancellation()
            guard openRequestID == sessionID, positionSaveRequestID == requestID else { return }
            guard let fresh = sampled else { throw ReaderPositionCaptureError.unavailable }
            try await services.repository.save(fresh)
            guard openRequestID == sessionID, positionSaveRequestID == requestID, !Task.isCancelled else { return }
            position = fresh
            positionSaveFailure = nil
        } catch is CancellationError {
            return
        } catch {
            guard openRequestID == sessionID, positionSaveRequestID == requestID else { return }
            positionSaveFailure = "阅读进度尚未保存：\(error.localizedDescription)"
        }
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
        // Preserve input order even if several edits arrive while disk work is suspended.
        let previous = appearanceSaveTask
        let files = services.files
        appearanceSaveTask = Task { [weak self] in
            await previous?.value
            do {
                try await files.saveReadingAppearance(value)
                self?.appearanceSaveFailure = nil
            } catch {
                self?.appearanceSaveFailure = "设置尚未保存：\(error.localizedDescription)"
            }
        }
    }

    func retryAppearanceSave() { setAppearance(appearance) }

    func selectBuiltInFont(_ font: ReadingFont) {
        fontMessage = nil
        var updated = appearance; updated.font = font; updated.importedFontID = nil
        setAppearance(updated)
    }

    func selectImportedFont(_ id: UUID) {
        guard fontResources.contains(where: { $0.asset.id == id }) else {
            fontMessage = ReadingFontError.missingFont.localizedDescription; return
        }
        guard isReady, !fontBusy else { return }
        if !installedFontIDs.contains(id), let resource = fontResourceForPreview(id) {
            // An Open In import is added to the catalogue without touching the
            // active book. Only explicit selection installs it at a saved anchor.
            fontImportTask = Task { await importReadingFont(from: resource.fileURL) }
            return
        }
        fontMessage = nil
        var updated = appearance; updated.importedFontID = id
        setAppearance(updated)
    }

    func isFontAvailable(_ id: UUID) -> Bool { fontResources.contains(where: { $0.asset.id == id }) }

    func refreshFontCatalogueForBrowsing(force: Bool = false) async {
        guard let session = openRequestID, isReady, !fontBusy else { return }
        let request = UUID(); fontCatalogRequestID = request
        defer { if fontCatalogRequestID == request { fontCatalogRequestID = nil } }
        do {
            // A catalogue is at most 32 KiB. Ordinary settings presentation does
            // not need to rehash every unchanged multi-megabyte font resource.
            let catalogue = try await services.files.readingFonts()
            guard openRequestID == session, fontCatalogRequestID == request, !fontBusy, !Task.isCancelled else { return }
            guard force || catalogue != importedFonts else { return }
            let loaded = try await loadFontResources()
            guard openRequestID == session, fontCatalogRequestID == request, !fontBusy, !Task.isCancelled else { return }
            importedFonts = loaded.fonts; fontResources = loaded.resources
            if let warning = loaded.warning { fontMessage = warning }
        } catch is CancellationError { return }
        catch {
            guard openRequestID == session, fontCatalogRequestID == request else { return }
            fontMessage = "字体列表暂时无法更新：\(error.localizedDescription)"
        }
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
        var effective = value
        if let id = value.importedFontID, !fontResources.contains(where: { $0.asset.id == id }) {
            effective.importedFontID = nil; effective.font = .original
            fontMessage = ReadingFontError.missingFont.localizedDescription
        }
        return effective
    }

    private func loadFontResources() async throws -> (fonts: [ReadingFontAsset], resources: [ReaderFontResource], warning: String?) {
        var resources: [ReaderFontResource] = [], warning: String?
        for bundled in BundledReadingFont.allCases {
            do { resources.append(try bundled.resource()) }
            catch { warning = "\(bundled.title)：\(error.localizedDescription)" }
        }
        let fonts: [ReadingFontAsset]
        do { fonts = try await services.files.readingFonts() }
        catch is CancellationError { throw CancellationError() }
        catch { return ([], resources, error.localizedDescription) }
        for font in fonts {
            try Task.checkCancellation()
            do { resources.append(ReaderFontResource(asset: font, fileURL: try await services.files.readingFontURL(font))) }
            catch { warning = "\(font.displayName)：\(error.localizedDescription)" }
        }
        return (fonts, resources, warning)
    }

    /// A new catalogue is installed once at navigator construction. Ordinary
    /// selection among already loaded fonts still uses bounded native reflow.
    func importReadingFont(from source: URL) async {
        guard isReady, !fontBusy, !navigationInProgress, let engine, let provider = engine.fontProvider,
              let session = openRequestID else { return }
        let request = UUID(); fontRequestID = request; fontBusy = true; fontMessage = nil
        defer { if fontRequestID == request { fontRequestID = nil; fontBusy = false } }
        func current() throws {
            try Task.checkCancellation()
            guard openRequestID == session, fontRequestID == request else { throw CancellationError() }
        }
        var anchor: ReadingPosition?
        var rebuilding = false
        let oldResources = fontResources, oldAppearance = appearance
        do {
            pauseAutomaticScroll()
            let font = try await ReadingFontImportService(files: services.files).importFont(from: source)
            try current()
            let loaded = try await loadFontResources()
            try current()
            guard loaded.resources.contains(where: { $0.asset.id == font.id }) else { throw ReadingFontError.missingFont }
            let position = try await engine.captureCurrentPosition()
            try current()
            try await services.repository.save(position)
            try current()
            anchor = position
            navigationRequestID = request; navigationInProgress = true
            defer { if navigationRequestID == request { navigationRequestID = nil; navigationInProgress = false } }
            var updated = appearance; updated.importedFontID = font.id
            engine.close(); rebuilding = true
            try provider.setReadingFonts(loaded.resources)
            try engine.appearanceProvider?.setAppearance(updated)
            try await engine.open(book: book, fileURL: services.files.resolve(book.filePath), position: position)
            try current()
            fontResources = loaded.resources; importedFonts = loaded.fonts; appearance = updated
            installedFontIDs = Set(loaded.resources.map { $0.asset.id })
            self.position = engine.currentPosition
            fontMessage = "已导入并启用 \(font.displayName)"; saveAppearanceValue(updated)
        } catch is CancellationError {
            // Closing invalidates this request. Never close or mutate a reopened reader.
            if openRequestID == session, fontRequestID == request, rebuilding {
                engine.close(); isReady = false; started = false
                openFailure = "字体应用已取消，请重试打开。"
            }
        } catch {
            guard openRequestID == session, fontRequestID == request else { return }
            let original = error.localizedDescription
            if rebuilding, let anchor {
                do {
                    engine.close(); try provider.setReadingFonts(oldResources)
                    try engine.appearanceProvider?.setAppearance(effectiveAppearance(oldAppearance))
                    try await engine.open(book: book, fileURL: services.files.resolve(book.filePath), position: anchor)
                    try current()
                } catch {
                    guard openRequestID == session, fontRequestID == request else { return }
                    isReady = false; started = false
                    openFailure = "字体应用失败：\(original)。恢复阅读失败：\(error.localizedDescription)"
                }
            }
            fontMessage = "字体操作未完成：\(original)。可重新导入；已经导入的文件会保留。"
            // Reload the list even when capture was not stable; importing and
            // changing the current reading layout have separate commit points.
            do {
                let fonts = try await services.files.readingFonts()
                try current(); importedFonts = fonts
            } catch {
                guard openRequestID == session, fontRequestID == request else { return }
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
        let previous = interactionSaveTask
        let files = services.files
        interactionSaveTask = Task { [weak self] in
            await previous?.value
            do {
                try await files.saveReadingInteraction(value)
                self?.interactionSaveFailure = nil
            } catch {
                self?.pauseAutomaticScroll()
                self?.interactionSaveFailure = "阅读手感尚未保存：\(error.localizedDescription)"
            }
        }
    }

    func retryInteractionSave() { setInteraction(interaction) }

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
        guard !navigationInProgress else { return }
        returnPosition = nil
    }

    private func navigate(returning: Bool = false,
                          operation: @MainActor (any ReaderEngine) async throws -> Void) async throws {
        guard isReady, let engine, let session = openRequestID else { throw ReaderPositionCaptureError.unavailable }
        guard navigationRequestID == nil, !fontBusy else { throw ReaderJumpError.busy }
        let request = UUID()
        navigationRequestID = request
        navigationInProgress = true
        defer {
            if navigationRequestID == request {
                navigationRequestID = nil
                navigationInProgress = false
            }
        }
        pauseAutomaticScroll()
        // One origin per excursion. Ordinary callbacks keep saving the actual
        // current reading position; closing never silently returns to origin.
        var origin = returnPosition
        if origin == nil && !returning { origin = try await engine.captureCurrentPosition() }
        try Task.checkCancellation()
        guard openRequestID == session, navigationRequestID == request else { throw CancellationError() }
        guard returning || origin?.bookID == book.id else { throw ReaderPositionCaptureError.unavailable }
        try await operation(engine)
        try Task.checkCancellation()
        guard openRequestID == session, navigationRequestID == request else { throw CancellationError() }
        returnPosition = returning ? nil : origin
        menuVisible = false
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

    private func persist(_ position: ReadingPosition) async {
        do { try await services.repository.save(position) }
        catch { pauseAutomaticScroll(); errorMessage = "阅读进度未能写入：\(error.localizedDescription)" }
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
