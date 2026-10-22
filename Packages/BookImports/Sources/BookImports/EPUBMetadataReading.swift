import Foundation
import XianxiaCore

public struct ImportedPublication: Sendable {
    public let title: String
    public let author: String
    public let coverData: Data?
    public let chapters: [Chapter]
    public let warnings: [String]

    public init(title: String, author: String, coverData: Data?, chapters: [Chapter], warnings: [String] = []) {
        self.title = title
        self.author = author
        self.coverData = coverData
        self.chapters = chapters
        self.warnings = warnings
    }
}

public protocol EPUBMetadataReading: Sendable {
    func readMetadata(at url: URL, bookID: UUID) async throws -> ImportedPublication
}

