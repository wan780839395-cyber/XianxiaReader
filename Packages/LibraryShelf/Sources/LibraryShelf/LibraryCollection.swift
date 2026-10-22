import Foundation
import XianxiaCore

/// Synchronous shelf state. Callers retain their existing awaits and error presentation.
@MainActor public final class LibraryCollection {
    public var willChange: (() -> Void)?
    public private(set) var books: [BookSummary] = [] { willSet { willChange?() } }
    public private(set) var removedBooks: [BookSummary] = [] { willSet { willChange?() } }
    private var refreshRequestID: UUID?

    public init() {}

    public func beginRefresh() -> UUID {
        let id = UUID(); refreshRequestID = id
        return id
    }

    public func acceptsRefresh(_ id: UUID) -> Bool { refreshRequestID == id }

    public func apply(_ result: LibrarySnapshot, requestID: UUID) {
        guard acceptsRefresh(requestID) else { return }
        books = result.books
        removedBooks = result.removedBooks
    }

    public func didCommitMetadata(_ book: Book) {
        // Invalidate pre-commit snapshots even when the book is currently filtered out.
        refreshRequestID = nil
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            let previous = books[index]
            books[index] = BookSummary(book: book, progression: previous.progression, lastReadAt: previous.lastReadAt)
        }
    }

    public func didCommitRemoval(_ id: UUID, restoring: Bool) {
        refreshRequestID = nil
        if restoring, let summary = removedBooks.first(where: { $0.id == id }) {
            removedBooks.removeAll { $0.id == id }; books.removeAll { $0.id == id }; books.append(summary)
        } else if !restoring, let summary = books.first(where: { $0.id == id }) {
            books.removeAll { $0.id == id }; removedBooks.removeAll { $0.id == id }; removedBooks.insert(summary, at: 0)
        }
    }
}
