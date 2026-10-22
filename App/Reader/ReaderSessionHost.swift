import Foundation
import ReaderFonts
import ReaderSessions
import XianxiaCore

/// Typed App/SDK wiring only. Ordering, cancellation and ownership live in the
/// Foundation lifecycle; each bound operation retains its original receiver.
@MainActor struct ReaderSessionHost: ReaderSessionLifecycleHost {
    let bookID: UUID
    let book: Book
    let readAppearance: @MainActor () async throws -> ReadingAppearance
    let loadFonts: @MainActor () async throws -> ReaderFontCoordinator.Snapshot
    let readInteraction: @MainActor () async throws -> ReadingInteraction
    let readPosition: (UUID) async throws -> ReadingPosition?
    let readChapters: (UUID) async throws -> [Chapter]
    let readBookmarks: (UUID) async throws -> [Bookmark]
    let openEngine: (@MainActor (Book, URL, ReadingPosition?) async throws -> Void)?
    let resolveFile: @MainActor () throws -> URL
    let begin: @MainActor (UUID) -> Void
    let showStage: @MainActor (ReaderOpeningStage) -> Void
    let clearSaveFailure: @MainActor () -> Void
    let commitFonts: @MainActor (ReaderFontCoordinator.Snapshot, UUID) throws -> Void
    let reportFontFailure: @MainActor (String, UUID) throws -> Void
    let applyAppearance: @MainActor (ReadingAppearance) throws -> Void
    let applyInteraction: @MainActor (ReadingInteraction) throws -> Void
    let publishChapters: @MainActor ([Chapter]) -> Void
    let publishBookmarks: @MainActor ([Bookmark]) -> Void
    let publishReady: @MainActor (ReadingInteraction) -> Void
    let publishOpenFailure: @MainActor (String?) -> Void
    let invalidatePositionCapture: @MainActor () -> Void
    let closeFonts: @MainActor () -> Void
    let closeNavigation: @MainActor () -> Void
    let closeEngine: @MainActor () -> Void
    let publishClosed: @MainActor () -> Void
}
