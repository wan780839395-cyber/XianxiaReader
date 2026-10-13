import Foundation

public protocol BookRepository: Sendable {
    func books() async throws -> [BookSummary]
    func insert(_ book: Book, chapters: [Chapter]) async throws
    func position(for bookID: UUID) async throws -> ReadingPosition?
    func save(_ position: ReadingPosition) async throws
    func chapters(for bookID: UUID) async throws -> [Chapter]
    func bookmarks(for bookID: UUID) async throws -> [Bookmark]
    func add(_ bookmark: Bookmark) async throws
    func removeBookmark(_ id: UUID) async throws
}
