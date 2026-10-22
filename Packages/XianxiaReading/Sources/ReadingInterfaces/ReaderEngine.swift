import BookImports
import Foundation
import UIKit
import XianxiaCore

// Keep the existing API names; importing metadata belongs to BookImports.
public typealias ImportedPublication = BookImports.ImportedPublication
public typealias EPUBMetadataReading = BookImports.EPUBMetadataReading

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
    var fontProvider: (any ReaderFontProviding)? { get }
    var interactionProvider: (any ReaderInteractionProviding)? { get }
    var automaticScrollProvider: (any ReaderAutomaticScrollProviding)? { get }
    var supportsContinuousScrolling: Bool { get }
    func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws
    func turnPage(forward: Bool) async
    func go(to chapter: Chapter) async throws
    func go(to position: ReadingPosition) async throws
    /// Capture a fresh, complete text anchor before an explicit navigation.
    func captureCurrentPosition() async throws -> ReadingPosition
    func setScrolling(_ enabled: Bool)
    func setContinuousScrolling(_ enabled: Bool)
    func close()
}

public extension ReaderEngine {
    func captureCurrentPosition() async throws -> ReadingPosition {
        guard let currentPosition else { throw ReaderPositionCaptureError.unavailable }
        return currentPosition
    }
    var currentChapters: [Chapter]? { nil }
    var searchProvider: (any ReaderSearchProviding)? { nil }
    var appearanceProvider: (any ReaderAppearanceProviding)? { nil }
    var fontProvider: (any ReaderFontProviding)? { nil }
    var interactionProvider: (any ReaderInteractionProviding)? { nil }
    var automaticScrollProvider: (any ReaderAutomaticScrollProviding)? { nil }
    var supportsContinuousScrolling: Bool { false }
    func setContinuousScrolling(_ enabled: Bool) {
        if enabled { onError?("当前阅读引擎不支持连续滚动。") }
        else { setScrolling(false) }
    }
}

public enum ReaderPositionCaptureError: LocalizedError {
    case unavailable
    public var errorDescription: String? { "当前位置尚未稳定，请稍后再试。" }
}

public enum ReaderAutomaticScrollState: Equatable, Sendable {
    case stopped, running, waiting, paused, finished
    public var isActive: Bool { self == .running || self == .waiting }
}

@MainActor public protocol ReaderAutomaticScrollProviding: AnyObject {
    var automaticScrollState: ReaderAutomaticScrollState { get }
    var onAutomaticScrollStateChanged: ((ReaderAutomaticScrollState) -> Void)? { get set }
    /// Explicit start only; reading mode and accessibility policy remain authoritative.
    func startAutomaticScroll(screensPerMinute: Double) throws
    func pauseAutomaticScroll()
    func stopAutomaticScroll()
    /// Sample the final full locator after pausing, before persisting/dismissing.
    func flushAutomaticScrollPosition() async
}

@MainActor public protocol ReaderAppearanceProviding: AnyObject {
    /// False for fixed-layout publications. Initial preferences can be supplied before open.
    var supportsTextAppearance: Bool { get }
    func setAppearance(_ appearance: ReadingAppearance) throws
}

public struct ReaderFontResource: Equatable, Sendable {
    public let asset: ReadingFontAsset
    public let fileURL: URL
    public init(asset: ReadingFontAsset, fileURL: URL) { self.asset = asset; self.fileURL = fileURL }
}

@MainActor public protocol ReaderFontProviding: AnyObject {
    /// Supply an immutable catalogue before opening. Adding resources requires
    /// a controlled reopen at a freshly captured complete text anchor.
    func setReadingFonts(_ fonts: [ReaderFontResource]) throws
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
