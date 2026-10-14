import Foundation
import ReadiumNavigator
import ReadiumShared
import ReadingInterfaces
import UIKit
import WebKit
import XianxiaCore

@MainActor public final class ReadiumEngineFactory: ReaderEngineFactory {
    public init() {}
    public func makeEngine(for format: BookFormat) throws -> any ReaderEngine {
        guard format == .epub else { throw EPUBError.unsupported }
        return ReadiumReaderEngine()
    }
}

@MainActor public final class ReadiumReaderEngine: NSObject, ReaderEngine, EPUBNavigatorDelegate {
    private let host = UIViewController()
    private let loader = ReadiumPublicationLoader()
    private var navigator: EPUBNavigatorViewController?
    private var bookID: UUID?
    private var openRequestID: UUID?
    private var modeChangeRequestID: UUID?
    private var modeChangeTask: Task<Void, Never>?
    private var preferences = EPUBPreferences(scroll: false)
    public var onPositionChanged: ((ReadingPosition) -> Void)?
    public var onCenterTap: (() -> Void)?
    public var onError: ((String) -> Void)?
    public var viewController: UIViewController { host }
    public private(set) var currentPosition: ReadingPosition?
    public private(set) var searchProvider: (any ReaderSearchProviding)?
    public private(set) var supportsContinuousScrolling = false
    public var continuousLoadedResourceCount: Int { navigator?.continuousScrollLoadedResourceCount ?? 0 }

    public override init() { super.init() }

    public func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws {
        close()
        let requestID = UUID()
        openRequestID = requestID
        let publication = try await loader.open(at: fileURL)
        try Task.checkCancellation()
        guard openRequestID == requestID else { throw CancellationError() }
        let locator = try position.map { try ReadiumPositionCodec.decode($0, bookID: book.id) }
        let navigator = try EPUBNavigatorViewController(publication: publication, initialLocation: locator,
            config: .init(preferences: preferences, disablePageTurnsWhileScrolling: false,
                          preloadPreviousPositionCount: 1, preloadNextPositionCount: 2))
        supportsContinuousScrolling = publication.metadata.layout != .fixed
            && !navigator.settings.verticalText && navigator.settings.readingProgression == .ltr
        if preferences.infiniteScroll == true, !supportsContinuousScrolling {
            throw EPUBError.unsupported
        }
        self.bookID = book.id
        self.navigator = navigator
        searchProvider = publication.isSearchable ? ReadiumSearchProvider(publication: publication, bookID: book.id) : nil
        currentPosition = position
        navigator.delegate = self
        // Readium dispatches only taps not consumed by links, selection, etc.
        // Avoid a SwiftUI gesture overlay that would block publication interactions.
        navigator.addObserver(.tap { [weak self, weak navigator] event in
            guard let self, let navigator else { return false }
            let width = navigator.view.bounds.width
            guard width > 0 else { return false }
            if event.location.x < width * 0.3 {
                if !navigator.presentation.scroll { await self.turnPage(forward: false) }
            } else if event.location.x > width * 0.7 {
                if !navigator.presentation.scroll { await self.turnPage(forward: true) }
            } else {
                self.onCenterTap?()
            }
            return true
        })
        host.loadViewIfNeeded()
        host.addChild(navigator)
        // Seed a valid viewport before Readium starts its asynchronous layout.
        // Match the upstream SwiftUI container recipe instead of mounting a
        // zero-frame child and waiting for a later Auto Layout pass.
        navigator.view.frame = host.view.bounds
        navigator.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.addSubview(navigator.view)
        navigator.didMove(toParent: host)
    }

    public func turnPage(forward: Bool) async {
        guard let navigator else { return }
        if forward { await navigator.goForward(options: .animated) }
        else { await navigator.goBackward(options: .animated) }
    }

    public func go(to chapter: Chapter) async throws {
        guard chapter.bookID == bookID, let href = chapter.href, AnyURL(string: href) != nil,
              let navigator else { throw EPUBError.navigationFailed }
        guard await navigator.go(to: Link(href: href), options: .animated) else { throw EPUBError.navigationFailed }
    }

    public func go(to position: ReadingPosition) async throws {
        guard let bookID, let navigator else { throw EPUBError.navigationFailed }
        let locator = try ReadiumPositionCodec.decode(position, bookID: bookID)
        guard await navigator.go(to: locator, options: .animated) else { throw EPUBError.navigationFailed }
    }

    public func setScrolling(_ enabled: Bool) {
        cancelModeChange()
        preferences.infiniteScroll = false
        preferences.scroll = enabled
        navigator?.submitPreferences(preferences)
    }

    public func setContinuousScrolling(_ enabled: Bool) {
        guard navigator == nil || !enabled || supportsContinuousScrolling else {
            onError?("这本书的固定布局、竖排或从右向左方向暂不支持连续滚动，请使用分页模式。")
            return
        }
        preferences.scroll = enabled
        preferences.infiniteScroll = enabled
        cancelModeChange()
        guard let navigator else { return }
        let requestID = UUID()
        modeChangeRequestID = requestID
        let requestedPreferences = preferences
        modeChangeTask = Task { @MainActor [weak self, weak navigator] in
            guard let self, let navigator else { return }
            await navigator.preserveCurrentDOMLocationForModeChange()
            guard !Task.isCancelled, self.modeChangeRequestID == requestID, self.navigator === navigator else { return }
            navigator.submitPreferences(requestedPreferences)
            self.modeChangeTask = nil
        }
    }

    private func cancelModeChange() {
        modeChangeRequestID = nil
        modeChangeTask?.cancel()
        modeChangeTask = nil
    }

    public func close() {
        // A suspended publication load must not mount a navigator after this reader closes.
        openRequestID = nil
        cancelModeChange()
        if let navigator {
            if let locator = navigator.currentLocation { capture(locator) }
            navigator.delegate = nil
            navigator.closeContinuousScrolling()
            navigator.willMove(toParent: nil)
            navigator.view.removeFromSuperview()
            navigator.removeFromParent()
        }
        navigator = nil
        bookID = nil
        currentPosition = nil
        searchProvider = nil
        supportsContinuousScrolling = false
    }

    public func navigator(_ navigator: Navigator, locationDidChange locator: Locator) {
        guard (navigator as AnyObject) === self.navigator else { return }
        capture(locator)
    }
    public func navigator(_ navigator: Navigator, presentError error: NavigatorError) {
        guard (navigator as AnyObject) === self.navigator else { return }
        onError?(error.localizedDescription)
    }
    public func navigator(_ navigator: Navigator, didFailToLoadResourceAt href: RelativeURL, withError error: ReadError) {
        guard (navigator as AnyObject) === self.navigator else { return }
        onError?("正文资源读取失败：\(error.localizedDescription)")
    }

    public func navigator(_ navigator: EPUBNavigatorViewController,
                          setupUserScripts userContentController: WKUserContentController) {
        guard navigator.publication.metadata.layout != .fixed else { return }
        userContentController.addUserScript(WKUserScript(source: ReadiumViewportScript.mediaBounds,
            injectionTime: .atDocumentEnd, forMainFrameOnly: true))
    }

    private func capture(_ locator: Locator) {
        guard let bookID else { return }
        do {
            let position = try ReadiumPositionCodec.encode(locator, bookID: bookID)
            currentPosition = position
            onPositionChanged?(position)
        } catch { onError?("阅读位置保存失败：\(error.localizedDescription)") }
    }
}
