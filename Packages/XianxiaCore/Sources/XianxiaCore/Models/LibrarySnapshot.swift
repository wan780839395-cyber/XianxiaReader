import Foundation

/// One database read keeps the shelf and recoverable removal list consistent.
/// Removed books retain their original Book, files, chapters, position and bookmarks.
public struct LibrarySnapshot: Sendable {
    public let books: [BookSummary]
    public let removedBooks: [BookSummary]

    public init(books: [BookSummary], removedBooks: [BookSummary]) {
        self.books = books
        self.removedBooks = removedBooks
    }
}
