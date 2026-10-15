import Foundation

public enum BookFormat: String, Codable, Sendable {
    case epub, txt, xbook
}

public struct Book: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var author: String
    public let format: BookFormat
    /// Paths relative to the application's storage root; never persist sandbox absolute paths.
    public let filePath: String
    public var coverPath: String?
    /// Optional JSON field keeps old records and the imported publication cover intact.
    public var coverOverride: BookCoverOverride?
    public var displayCoverPath: String? { coverOverride?.thumbnailPath(bookID: id) ?? coverPath }
    public let importedAt: Date
    /// Optional for backward-compatible decoding of existing EPUB records.
    public let txtEncoding: TXTEncoding?

    public init(id: UUID = UUID(), title: String, author: String = "", format: BookFormat,
                filePath: String, coverPath: String? = nil, importedAt: Date = Date(), txtEncoding: TXTEncoding? = nil,
                coverOverride: BookCoverOverride? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.format = format
        self.filePath = filePath
        self.coverPath = coverPath
        self.coverOverride = coverOverride
        self.importedAt = importedAt
        self.txtEncoding = txtEncoding
    }
}

public struct BookSummary: Identifiable, Equatable, Sendable {
    public let book: Book
    public let progression: Double?
    public let lastReadAt: Date?
    public var id: UUID { book.id }

    public init(book: Book, progression: Double?, lastReadAt: Date?) {
        self.book = book
        self.progression = progression
        self.lastReadAt = lastReadAt
    }
}
