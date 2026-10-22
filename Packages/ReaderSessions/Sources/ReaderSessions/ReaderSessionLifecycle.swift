import Foundation

public enum ReaderOpeningStage { case settings, fonts, position, layout }

/// SDK values remain opaque. Async requirements are method values, so adapters
/// can hand over the existing operations without an extra async forwarding call.
@MainActor public protocol ReaderSessionLifecycleHost {
    associatedtype Appearance
    associatedtype Fonts
    associatedtype Interaction
    associatedtype Position: Sendable
    associatedtype Chapters: Sendable
    associatedtype Bookmarks: Sendable
    associatedtype Publication
    var bookID: UUID { get }
    var book: Publication { get }
    var readAppearance: @MainActor () async throws -> Appearance { get }
    var loadFonts: @MainActor () async throws -> Fonts { get }
    var readInteraction: @MainActor () async throws -> Interaction { get }
    var readPosition: (UUID) async throws -> Position { get }
    var readChapters: (UUID) async throws -> Chapters { get }
    var readBookmarks: (UUID) async throws -> Bookmarks { get }
    var openEngine: (@MainActor (Publication, URL, Position) async throws -> Void)? { get }
    var resolveFile: @MainActor () throws -> URL { get }
    var begin: @MainActor (UUID) -> Void { get }
    var showStage: @MainActor (ReaderOpeningStage) -> Void { get }
    var clearSaveFailure: @MainActor () -> Void { get }
    var commitFonts: @MainActor (Fonts, UUID) throws -> Void { get }
    var reportFontFailure: @MainActor (String, UUID) throws -> Void { get }
    var applyAppearance: @MainActor (Appearance) throws -> Void { get }
    var applyInteraction: @MainActor (Interaction) throws -> Void { get }
    var publishChapters: @MainActor (Chapters) -> Void { get }
    var publishBookmarks: @MainActor (Bookmarks) -> Void { get }
    var publishReady: @MainActor (Interaction) -> Void { get }
    var publishOpenFailure: @MainActor (String?) -> Void { get }
    var invalidatePositionCapture: @MainActor () -> Void { get }
    var closeFonts: @MainActor () -> Void { get }
    var closeNavigation: @MainActor () -> Void { get }
    var closeEngine: @MainActor () -> Void { get }
    var publishClosed: @MainActor () -> Void { get }
}

/// One invocation context, sharing the reader's R4a ownership state. The App
/// exposes these bound entry methods directly and does not retain this context.
@MainActor public final class ReaderSessionLifecycle<Host: ReaderSessionLifecycleHost> {
    private let state: ReaderSessionState
    private let host: Host

    public init(state: ReaderSessionState, host: Host) { self.state = state; self.host = host }

    public func open() async {
        guard let openEngine = host.openEngine, let requestID = state.begin(bookID: host.bookID) else { return }
        host.begin(requestID)
        host.showStage(.settings)
        host.clearSaveFailure()
        do {
            let appearance = try await host.readAppearance()
            try Task.checkCancellation()
            guard state.requestID == requestID else { throw CancellationError() }
            host.showStage(.fonts)
            do {
                let loaded = try await host.loadFonts()
                try Task.checkCancellation()
                guard state.requestID == requestID else { throw CancellationError() }
                try host.commitFonts(loaded, requestID)
            } catch is CancellationError { throw CancellationError() }
            catch {
                guard state.requestID == requestID else { throw CancellationError() }
                try host.reportFontFailure(error.localizedDescription, requestID)
            }
            try host.applyAppearance(appearance)
            host.showStage(.position)
            let interaction = try await host.readInteraction()
            try Task.checkCancellation()
            guard state.requestID == requestID else { throw CancellationError() }
            try host.applyInteraction(interaction)
            let position = try await host.readPosition(host.bookID)
            let chapters = try await host.readChapters(host.bookID)
            host.publishChapters(chapters)
            let bookmarks = try await host.readBookmarks(host.bookID)
            host.publishBookmarks(bookmarks)
            try Task.checkCancellation()
            guard state.requestID == requestID else { throw CancellationError() }
            host.showStage(.layout)
            try await openEngine(host.book, host.resolveFile(), position)
            try Task.checkCancellation()
            guard state.requestID == requestID else { throw CancellationError() }
            host.publishReady(interaction)
        } catch is CancellationError {
            guard state.requestID == requestID else { return }
            host.closeEngine()
            state.invalidate()
        } catch {
            guard state.requestID == requestID else { return }
            host.publishOpenFailure(error.localizedDescription)
        }
    }

    public func retryOpen() async {
        guard host.openEngine != nil else { return }
        close()
        host.publishOpenFailure(nil)
        await open()
    }

    public func close() {
        host.invalidatePositionCapture()
        host.closeFonts()
        host.closeNavigation()
        // The current owner must still accept the engine's final full position.
        host.closeEngine()
        state.invalidate()
        host.publishClosed()
    }
}
