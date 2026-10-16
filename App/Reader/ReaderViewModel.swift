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

@MainActor final class ReaderViewModel: ObservableObject {
    @Published private(set) var isReady = false
    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var bookmarks: [Bookmark] = []
    @Published private(set) var position: ReadingPosition?
    @Published private(set) var openFailure: String?
    @Published var menuVisible = true
    @Published var scrolling = false
    @Published var errorMessage: String?
    @Published private(set) var appearance = ReadingAppearance()
    @Published private(set) var appearanceSaveFailure: String?
    @Published private(set) var interaction = ReadingInteraction()
    @Published private(set) var interactionSaveFailure: String?
    @Published private(set) var automaticScrollState = ReaderAutomaticScrollState.stopped
    @Published private(set) var automaticScrollPresented = false
    var settingsSaveFailure: String? { appearanceSaveFailure ?? interactionSaveFailure }
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
        do {
            let restoredAppearance = try await services.files.readingAppearance()
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            try engine.appearanceProvider?.setAppearance(restoredAppearance)
            appearance = restoredAppearance
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
        started = false
        openFailure = nil
        await open()
    }

    func close() {
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
        await engine?.automaticScrollProvider?.flushAutomaticScrollPosition()
        await appearanceSaveTask?.value
        await interactionSaveTask?.value
        if let position = engine?.currentPosition { await persist(position) }
    }

    func setAppearance(_ value: ReadingAppearance) {
        pauseAutomaticScroll()
        guard isReady, let provider = engine?.appearanceProvider else { return }
        do {
            try provider.setAppearance(value)
            appearance = value
        } catch { errorMessage = error.localizedDescription; return }
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
        pauseAutomaticScroll()
        guard isReady, let engine else { return }
        let requestID = openRequestID
        do {
            try await engine.go(to: chapter)
            guard openRequestID == requestID else { return }
            menuVisible = false
        } catch {
            guard openRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }

    func go(to bookmark: Bookmark) async {
        pauseAutomaticScroll()
        guard isReady, let engine else { return }
        let requestID = openRequestID
        do {
            try await engine.go(to: bookmark.position)
            guard openRequestID == requestID else { return }
            menuVisible = false
        } catch {
            guard openRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }

    func go(to result: ReaderSearchHit) async throws {
        pauseAutomaticScroll()
        guard isReady, let engine else { throw ReaderSearchError.unavailable }
        let requestID = openRequestID
        try await engine.go(to: result.position)
        guard openRequestID == requestID else { throw CancellationError() }
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
