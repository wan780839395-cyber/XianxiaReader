import Foundation

/// A cached navigation entry. EPUB TOC entries are not necessarily one-to-one with novel chapters.
public struct Chapter: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let bookID: UUID
    public let ordinal: Int
    public let title: String
    public let depth: Int
    public let href: String?
    /// Reserved for the M2 normalized UTF-8 file index. End is exclusive.
    public let startByte: Int64?
    public let endByte: Int64?

    public init(id: String, bookID: UUID, ordinal: Int, title: String, depth: Int = 0,
                href: String? = nil, startByte: Int64? = nil, endByte: Int64? = nil) {
        self.id = id
        self.bookID = bookID
        self.ordinal = ordinal
        self.title = title
        self.depth = depth
        self.href = href
        self.startByte = startByte
        self.endByte = endByte
    }
}
