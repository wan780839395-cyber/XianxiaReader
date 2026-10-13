import Foundation
import UIKit
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

/// UIKit appears only at the rendering boundary; domain/storage contain no Readium types.
@MainActor public protocol ReaderEngine: AnyObject {
    var viewController: UIViewController { get }
    var currentPosition: ReadingPosition? { get }
    var onPositionChanged: ((ReadingPosition) -> Void)? { get set }
    var onCenterTap: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws
    func turnPage(forward: Bool) async
    func go(to chapter: Chapter) async throws
    func go(to position: ReadingPosition) async throws
    func setScrolling(_ enabled: Bool)
    func close()
}

@MainActor public protocol ReaderEngineFactory {
    func makeEngine(for format: BookFormat) throws -> any ReaderEngine
}
