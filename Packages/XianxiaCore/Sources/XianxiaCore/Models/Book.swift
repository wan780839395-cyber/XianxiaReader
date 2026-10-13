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
    public let importedAt: Date

    public init(id: UUID = UUID(), title: String, author: String = "", format: BookFormat,
                filePath: String, coverPath: String? = nil, importedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.format = format
        self.filePath = filePath
        self.coverPath = coverPath
        self.importedAt = importedAt
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
