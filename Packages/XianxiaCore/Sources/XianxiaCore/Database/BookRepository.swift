import Foundation

public protocol BookRepository: Sendable {
    func books() async throws -> [BookSummary]
    func librarySnapshot() async throws -> LibrarySnapshot
    /// Includes removed books: import recovery must never discard their originals.
    func allBookIDs() async throws -> Set<UUID>
    func moveToTrash(_ id: UUID) async throws
    func restoreBook(_ id: UUID) async throws
    func insert(_ book: Book, chapters: [Chapter]) async throws
    func renameBook(_ id: UUID, title: String) async throws -> Book
    func setCoverOverride(_ id: UUID, cover: BookCoverOverride?) async throws -> Book
    func position(for bookID: UUID) async throws -> ReadingPosition?
    func save(_ position: ReadingPosition) async throws
    func chapters(for bookID: UUID) async throws -> [Chapter]
    func bookmarks(for bookID: UUID) async throws -> [Bookmark]
    func add(_ bookmark: Bookmark) async throws
    func removeBookmark(_ id: UUID) async throws
}
