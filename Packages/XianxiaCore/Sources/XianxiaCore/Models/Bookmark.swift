import Foundation

public struct Bookmark: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let bookID: UUID
    public let title: String
    public let position: ReadingPosition
    public let createdAt: Date

    public init(id: UUID = UUID(), position: ReadingPosition, title: String, createdAt: Date = Date()) {
        self.id = id
        self.bookID = position.bookID
        self.title = title
        self.position = position
        self.createdAt = createdAt
    }
}
