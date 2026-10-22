import CoreGraphics
import Foundation
import LibraryShelf
import XianxiaCore

struct PreparedCover: Sendable {
    let staged: StagedCover
    let thumbnailJPEG: Data
    let preview: CGImage
}

actor CoverImportService {
    private let files: BookFileStore
    private let repository: any LibraryRepository
    init(files: BookFileStore, repository: any LibraryRepository) { self.files = files; self.repository = repository }

    func prepare(from source: URL, bookID: UUID) async throws -> PreparedCover {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        let staged = try await files.stageCover(from: source, bookID: bookID)
        do {
            let rendered = try await CoverImagePipeline.shared.thumbnail(at: staged.originalURL)
            try Task.checkCancellation()
            return PreparedCover(staged: staged, thumbnailJPEG: rendered.jpeg, preview: rendered.preview)
        } catch {
            let original = error
            do { try await files.discardCover(staged) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }

    func save(_ prepared: PreparedCover) async throws -> Book {
        // Only a successful fresh finalization belongs to this transaction.
        // Repeating a committed save must never move that asset back to staging.
        let cover = try await files.finalizeCover(prepared.staged, thumbnailJPEG: prepared.thumbnailJPEG)
        do {
            return try await repository.setCoverOverride(prepared.staged.bookID, cover: cover)
        } catch {
            let original = error
            do { try await files.rollbackCoverFinalization(prepared.staged) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }

    func useDefault(bookID: UUID) async throws -> Book { try await repository.setCoverOverride(bookID, cover: nil) }
    func discard(_ prepared: PreparedCover) async throws { try await files.discardCover(prepared.staged) }
}
