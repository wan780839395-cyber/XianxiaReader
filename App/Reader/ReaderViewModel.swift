import Foundation
import ReadingInterfaces
import SwiftUI
import XianxiaCore

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
    let engine: (any ReaderEngine)?
    private let book: Book
    private let services: AppServices
    private var started = false
    private var openRequestID: UUID?
    private var appearanceSaveTask: Task<Void, Never>?

    init(book: Book, services: AppServices, factory: any ReaderEngineFactory) {
        self.book = book
        self.services = services
        do { engine = try factory.makeEngine(for: book.format) }
        catch { engine = nil; openFailure = error.localizedDescription }
        engine?.onCenterTap = { [weak self] in self?.menuVisible.toggle() }
        engine?.onError = { [weak self] message in self?.errorMessage = message }
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
            let restored = try await services.repository.position(for: book.id)
            chapters = try await services.repository.chapters(for: book.id)
            bookmarks = try await services.repository.bookmarks(for: book.id)
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            try await engine.open(book: book, fileURL: services.files.resolve(book.filePath), position: restored)
            try Task.checkCancellation()
            guard openRequestID == requestID else { throw CancellationError() }
            if let currentChapters = engine.currentChapters { chapters = currentChapters }
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
    }

    func saveNow() async {
        await appearanceSaveTask?.value
        if let position = engine?.currentPosition { await persist(position) }
    }

    func setAppearance(_ value: ReadingAppearance) {
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
        guard !value || engine?.supportsContinuousScrolling == true else {
            errorMessage = "这本书暂不支持上下连续滚动。"
            return
        }
        scrolling = value
        engine?.setContinuousScrolling(value)
    }

    func go(to chapter: Chapter) async {
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
        catch { errorMessage = "阅读进度未能写入：\(error.localizedDescription)" }
    }
}
