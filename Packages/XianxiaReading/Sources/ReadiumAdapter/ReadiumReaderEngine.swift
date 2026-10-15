import Foundation
import ReadiumNavigator
import ReadiumShared
import ReadingInterfaces
import UIKit
import WebKit
import XianxiaCore

@MainActor public final class ReadiumEngineFactory: ReaderEngineFactory {
    private let storageRoot: URL?
    public init(storageRoot: URL? = nil) { self.storageRoot = storageRoot }
    public func makeEngine(for format: BookFormat) throws -> any ReaderEngine {
        guard format == .epub || format == .txt else { throw EPUBError.unsupported }
        if format == .txt, storageRoot == nil { throw EPUBError.invalidURL }
        return ReadiumReaderEngine(storageRoot: storageRoot)
    }
}

@MainActor public final class ReadiumReaderEngine: NSObject, ReaderEngine, ReaderAppearanceProviding, EPUBNavigatorDelegate {
    private let host = UIViewController()
    private let loader = ReadiumPublicationLoader()
    private let txtLoader = TXTReadiumPublicationLoader()
    private let storageRoot: URL?
    private var txtReading: TXTPreparedPublication?
    private let additionalUserScripts: [WKUserScript]
    private var navigator: EPUBNavigatorViewController?
    private var bookID: UUID?
    private var openRequestID: UUID?
    private var modeChangeRequestID: UUID?
    private var modeChangeTask: Task<Void, Never>?
    private var preferences = EPUBPreferences(scroll: false)
    private var appliedPreferences = EPUBPreferences(scroll: false)
    public var onPositionChanged: ((ReadingPosition) -> Void)?
    public var onCenterTap: (() -> Void)?
    public var onError: ((String) -> Void)?
    public var viewController: UIViewController { host }
    public private(set) var currentPosition: ReadingPosition?
    public private(set) var searchProvider: (any ReaderSearchProviding)?
    public private(set) var supportsContinuousScrolling = false
    public var appearanceProvider: (any ReaderAppearanceProviding)? { self }
    public private(set) var supportsTextAppearance = false
    public var continuousLoadedResourceCount: Int { navigator?.continuousScrollLoadedResourceCount ?? 0 }
    public var currentChapters: [Chapter]? { txtReading?.plan.index.chapters }
    var continuousDiagnosticState: String { navigator?.continuousScrollDiagnosticState ?? "no navigator" }

    public override init() {
        storageRoot = nil
        additionalUserScripts = []
        super.init()
    }

    // Integration tests can delay a WebKit bridge without altering production
    // resource files or disabling the reader's real initialization work.
    public init(storageRoot: URL?) {
        self.storageRoot = storageRoot
        additionalUserScripts = []
        super.init()
    }

    init(additionalUserScripts: [WKUserScript], storageRoot: URL? = nil) {
        self.storageRoot = storageRoot
        self.additionalUserScripts = additionalUserScripts
        super.init()
    }

    public func open(book: Book, fileURL: URL, position: ReadingPosition?) async throws {
        close()
        let requestID = UUID()
        openRequestID = requestID
        let publication: Publication
        let txt: TXTPreparedPublication?
        if book.format == .txt {
            guard let storageRoot else { throw EPUBError.invalidURL }
            let prepared = try await txtLoader.open(book: book, fileURL: fileURL, storageRoot: storageRoot)
            txt = prepared; publication = prepared.publication
        } else {
            guard book.format == .epub else { throw EPUBError.unsupported }
            txt = nil; publication = try await loader.open(at: fileURL)
        }
        try Task.checkCancellation()
        guard openRequestID == requestID else { throw CancellationError() }
        let locator: Locator?
        if let position {
            if let txt { locator = try await txt.locator(position, bookID: book.id) }
            else { locator = try ReadiumPositionCodec.decode(position, bookID: book.id) }
        } else { locator = nil }
        try Task.checkCancellation()
        guard openRequestID == requestID else { throw CancellationError() }
        let navigator = try EPUBNavigatorViewController(publication: publication, initialLocation: locator,
            config: .init(preferences: preferences, disablePageTurnsWhileScrolling: false,
                          preloadPreviousPositionCount: 1, preloadNextPositionCount: 2))
        supportsTextAppearance = publication.metadata.layout != .fixed
        supportsContinuousScrolling = publication.metadata.layout != .fixed
            && !navigator.settings.verticalText && navigator.settings.readingProgression == .ltr
        if preferences.infiniteScroll == true, !supportsContinuousScrolling {
            throw EPUBError.unsupported
        }
        self.bookID = book.id
        txtReading = txt
        self.navigator = navigator
        appliedPreferences = preferences
        searchProvider = publication.isSearchable ? ReadiumSearchProvider(publication: publication, bookID: book.id, txtPlan: txt?.plan) : nil
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
        guard chapter.bookID == bookID, let navigator else { throw EPUBError.navigationFailed }
        let href: String
        if let txtReading {
            guard let actual = txtReading.plan.index.chapters.first(where: { $0.id == chapter.id }) else { throw EPUBError.navigationFailed }
            let leaf = actual.startByte != nil ? actual : txtReading.plan.index.chapters.first { $0.ordinal > actual.ordinal && $0.startByte != nil }
            guard let leaf, let resource = txtReading.plan.firstResource(chapterID: leaf.id) else { throw EPUBError.navigationFailed }
            href = resource.href
        } else {
            guard let value = chapter.href, AnyURL(string: value) != nil else { throw EPUBError.navigationFailed }
            href = value
        }
        guard await navigator.go(to: Link(href: href), options: .animated) else { throw EPUBError.navigationFailed }
    }

    public func go(to position: ReadingPosition) async throws {
        guard let bookID, let navigator else { throw EPUBError.navigationFailed }
        let requestID = openRequestID
        let locator: Locator
        if let txtReading { locator = try await txtReading.locator(position, bookID: bookID) }
        else { locator = try ReadiumPositionCodec.decode(position, bookID: bookID) }
        try Task.checkCancellation()
        guard openRequestID == requestID, self.navigator === navigator else { throw CancellationError() }
        guard await navigator.go(to: locator, options: .animated) else { throw EPUBError.navigationFailed }
    }

    public func setScrolling(_ enabled: Bool) {
        cancelModeChange()
        preferences.infiniteScroll = false
        preferences.scroll = enabled
        navigator?.submitPreferences(preferences)
        appliedPreferences = preferences
    }

    public func setContinuousScrolling(_ enabled: Bool) {
        guard navigator == nil || !enabled || supportsContinuousScrolling else {
            onError?("这本书的固定布局、竖排或从右向左方向暂不支持连续滚动，请使用分页模式。")
            return
        }
        preferences.scroll = enabled
        preferences.infiniteScroll = enabled
        submitPreservingLocation()
    }

    public func setAppearance(_ appearance: ReadingAppearance) throws {
        preferences.apply(try appearance.validated())
        host.view.backgroundColor = UIColor(red: CGFloat((appearance.theme.backgroundRGB >> 16) & 255) / 255,
            green: CGFloat((appearance.theme.backgroundRGB >> 8) & 255) / 255,
            blue: CGFloat(appearance.theme.backgroundRGB & 255) / 255, alpha: 1)
        submitPreservingLocation()
    }

    private func submitPreservingLocation() {
        cancelModeChange()
        guard let navigator else { return }
        let requestID = UUID()
        modeChangeRequestID = requestID
        let requestedPreferences = preferences
        modeChangeTask = Task { @MainActor [weak self, weak navigator] in
            guard let self, let navigator else { return }
            await navigator.preserveCurrentDOMLocationForModeChange()
            guard !Task.isCancelled, self.modeChangeRequestID == requestID, self.navigator === navigator else { return }
            // Expose the fresh full anchor immediately. A close/save while the
            // reflow is settling must not use an older percentage-only callback.
            if let locator = navigator.currentLocation { self.capture(locator) }
            // Compare against the preferences actually submitted, not an edit
            // whose task a later theme/mode change may have just cancelled.
            let previous = self.appliedPreferences
            let reflows = previous.fontFamily != requestedPreferences.fontFamily || previous.fontSize != requestedPreferences.fontSize
                || previous.lineHeight != requestedPreferences.lineHeight || previous.paragraphSpacing != requestedPreferences.paragraphSpacing
                || previous.pageMargins != requestedPreferences.pageMargins || previous.paragraphIndent != requestedPreferences.paragraphIndent
                || previous.textAlign != requestedPreferences.textAlign || previous.publisherStyles != requestedPreferences.publisherStyles
            navigator.submitPreferences(requestedPreferences, reloadingPagination: reflows)
            self.appliedPreferences = requestedPreferences
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
        txtReading = nil
        supportsContinuousScrolling = false
        supportsTextAppearance = false
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
        for script in additionalUserScripts { userContentController.addUserScript(script) }
        guard navigator.publication.metadata.layout != .fixed else { return }
        userContentController.addUserScript(WKUserScript(source: ReadiumViewportScript.mediaBounds,
            injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        // Upstream CJK styles omit the paragraph-indent preference. Keep the
        // horizontal Chinese override local and opt out with publisher styles.
        userContentController.addUserScript(WKUserScript(source: """
            (() => {
              if (getComputedStyle(document.documentElement).writingMode !== 'horizontal-tb') return;
              const style = document.createElement('style');
              style.textContent = ':root:lang(zh)[style*="readium-advanced-on"][style*="--USER__paraIndent"] p { text-indent: var(--USER__paraIndent) !important; }';
              document.head.appendChild(style);
            })();
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
    }

    private func capture(_ locator: Locator) {
        guard let bookID else { return }
        do {
            let position: ReadingPosition
            if let txtReading { position = try TXTPositionCodec.encode(locator, bookID: bookID, plan: txtReading.plan) }
            else { position = try ReadiumPositionCodec.encode(locator, bookID: bookID) }
            currentPosition = position
            onPositionChanged?(position)
        } catch { onError?("阅读位置保存失败：\(error.localizedDescription)") }
    }
}
