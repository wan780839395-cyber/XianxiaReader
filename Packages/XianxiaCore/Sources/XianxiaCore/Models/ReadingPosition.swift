import Foundation

/// Engine-specific bytes are opaque to the library/database and versioned for future migrations.
public struct ReadingPosition: Codable, Equatable, Sendable {
    public let bookID: UUID
    public let engineID: String
    public let locatorVersion: Int
    public let locatorData: Data
    public let chapterTitle: String?
    public let progression: Double?
    public let updatedAt: Date

    public init(bookID: UUID, engineID: String, locatorVersion: Int = 1, locatorData: Data,
                chapterTitle: String? = nil, progression: Double? = nil, updatedAt: Date = Date()) {
        self.bookID = bookID
        self.engineID = engineID
        self.locatorVersion = locatorVersion
        self.locatorData = locatorData
        self.chapterTitle = chapterTitle
        self.progression = progression.flatMap { $0.isFinite ? min(max($0, 0), 1) : nil }
        self.updatedAt = updatedAt
    }
}
