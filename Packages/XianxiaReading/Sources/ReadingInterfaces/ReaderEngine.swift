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
    var currentChapters: [Chapter]? { get }
    var onPositionChanged: ((ReadingPosition) -> Void)? { get set }
    var onCenterTap: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var searchProvider: (any ReaderSearchProviding)? { get }
    var appearanceProvider: (any ReaderAppearanceProviding)? { get }
    var interactionProvider: (any ReaderInteractionProviding)? { get }
    var supportsContinuousScrolling: Bool { get }
    func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws
    func turnPage(forward: Bool) async
    func go(to chapter: Chapter) async throws
    func go(to position: ReadingPosition) async throws
    func setScrolling(_ enabled: Bool)
    func setContinuousScrolling(_ enabled: Bool)
    func close()
}

public extension ReaderEngine {
    var currentChapters: [Chapter]? { nil }
    var searchProvider: (any ReaderSearchProviding)? { nil }
    var appearanceProvider: (any ReaderAppearanceProviding)? { nil }
    var interactionProvider: (any ReaderInteractionProviding)? { nil }
    var supportsContinuousScrolling: Bool { false }
    func setContinuousScrolling(_ enabled: Bool) {
        if enabled { onError?("当前阅读引擎不支持连续滚动。") }
        else { setScrolling(false) }
    }
}

@MainActor public protocol ReaderAppearanceProviding: AnyObject {
    /// False for fixed-layout publications. Initial preferences can be supplied before open.
    var supportsTextAppearance: Bool { get }
    func setAppearance(_ appearance: ReadingAppearance) throws
}

@MainActor public protocol ReaderEngineFactory {
    func makeEngine(for format: BookFormat) throws -> any ReaderEngine
}

@MainActor public protocol ReaderInteractionProviding: AnyObject {
    /// A passive observation of reading gestures; it never consumes publication input.
    var onReadingGesture: (() -> Void)? { get set }
    /// Applies motion and continuous screen input policy. Layout mode changes
    /// still use ReaderEngine's capability check and location protection.
    func setInteraction(_ value: ReadingInteraction) throws
}
