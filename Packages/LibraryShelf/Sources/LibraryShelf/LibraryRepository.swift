import Foundation
import XianxiaCore

/// Shelf metadata only. Import, search and reading-position writes have no port here.
public protocol LibraryRepository: Sendable {
    func librarySnapshot() async throws -> LibrarySnapshot
    func renameBook(_ id: UUID, title: String) async throws -> Book
    func moveToTrash(_ id: UUID) async throws
    func restoreBook(_ id: UUID) async throws
    func setCoverOverride(_ id: UUID, cover: BookCoverOverride?) async throws -> Book
}
