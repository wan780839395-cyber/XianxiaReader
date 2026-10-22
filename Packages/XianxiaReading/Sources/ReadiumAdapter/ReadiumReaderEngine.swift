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

@MainActor public final class ReadiumReaderEngine: NSObject, ReaderEngine, ReaderAppearanceProviding, ReaderFontProviding, ReaderInteractionProviding, ReaderAutomaticScrollProviding, EPUBNavigatorDelegate {
    private let host = UIViewController()
    private let loader = ReadiumPublicationLoader()
    private let txtLoader = TXTReadiumPublicationLoader()
    private let storageRoot: URL?
    private var txtReading: TXTPreparedPublication?
    private let additionalUserScripts: [WKUserScript]
    private var navigator: EPUBNavigatorViewController?
    // Opaque nil storage keeps test installation APIs entirely in the DEBUG extension.
    private var viewportFixtureStorage: AnyObject?
    private var readingFonts: [ReaderFontResource] = []
    public var fontProvider: (any ReaderFontProviding)? { self }

    public func setReadingFonts(_ fonts: [ReaderFontResource]) throws {
        // At most 12 imported faces plus the App's two bundled Chinese faces.
        guard navigator == nil, fonts.count <= 18, Set(fonts.map { $0.asset.id }).count == fonts.count else {
            throw ReaderPositionCaptureError.unavailable
        }
        for font in fonts {
            _ = try font.asset.validated()
            guard font.fileURL.isFileURL, FileURL(url: font.fileURL) != nil else { throw ReadingFontError.invalidFont }
        }
        readingFonts = fonts
    }

    private func fontDeclarations() throws -> [AnyHTMLFontFamilyDeclaration] {
        try readingFonts.map { resource in
            guard let file = FileURL(url: resource.fileURL) else { throw ReadingFontError.invalidFont }
            return CSSFontFamilyDeclaration(fontFamily: FontFamily(rawValue: resource.asset.cssFamily),
                fontFaces: [CSSFontFace(file: file, style: .normal, weight: .standard(.normal))])
                .eraseToAnyHTMLFontFamilyDeclaration()
        }
    }
    private var bookID: UUID?
    private var openRequestID: UUID?
    private var modeChangeRequestID: UUID?
    private var modeChangeTask: Task<Void, Never>?
    private var preferences = EPUBPreferences(scroll: false)
    private var appliedPreferences = EPUBPreferences(scroll: false)
    private var interaction = ReadingInteraction()
    private var pageTurnRequestID: UUID?
    public var automaticScrollProvider: (any ReaderAutomaticScrollProviding)? { self }
    public private(set) var automaticScrollState = ReaderAutomaticScrollState.stopped
    public var onAutomaticScrollStateChanged: ((ReaderAutomaticScrollState) -> Void)?
    private var automaticScrollLink: CADisplayLink?
    private var automaticScrollClock = AutomaticScrollClock()
    private var automaticScrollSpeed = 1.5
    private var automaticScrollLastSample: TimeInterval?
    private var automaticScrollSampleTask: Task<Void, Never>?
    private var automaticScrollSampleID: UUID?
    private(set) var automaticScrollSessionID: UUID?
    private var automaticScrollTouch: AutomaticScrollTouchObserver?
    private var automaticScrollPreviousIdleTimer: Bool?
    public var onReadingGesture: (() -> Void)?
    public var interactionProvider: (any ReaderInteractionProviding)? { self }
    var navigationOptions: NavigatorGoOptions {
        NavigatorGoOptions(animated: !interaction.reduceMotion && !UIAccessibility.isReduceMotionEnabled)
    }

    public func setInteraction(_ value: ReadingInteraction) throws {
        let updated = try value.validated()
        if updated.reduceMotion || updated.verticalScreenPaging != interaction.verticalScreenPaging { pauseAutomaticScroll() }
        interaction = updated
        navigator?.verticalScreenPagingEnabled = interaction.verticalScreenPaging
    }
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
    var continuousDiagnosticState: String {
        "preferences: " + preferenceRequestTrace.joined(separator: "; ") + " / "
            + (navigator?.continuousScrollDiagnosticState ?? "no navigator")
    }
    private var preferenceRequestTrace: [String] = []
    private func tracePreferenceRequest(_ value: String) {
        preferenceRequestTrace.append(value)
        if preferenceRequestTrace.count > 8 { preferenceRequestTrace.removeFirst() }
    }

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
            config: .init(preferences: preferences, disablePageTurnsWhileScrolling: true,
                          preloadPreviousPositionCount: 1, preloadNextPositionCount: 2,
                          fontFamilyDeclarations: try fontDeclarations()))
        supportsTextAppearance = publication.metadata.layout != .fixed
        supportsContinuousScrolling = publication.metadata.layout != .fixed
            && !navigator.settings.verticalText && navigator.settings.readingProgression == .ltr
        if preferences.infiniteScroll == true, !supportsContinuousScrolling {
            throw EPUBError.unsupported
        }
        self.bookID = book.id
        txtReading = txt
        self.navigator = navigator
        #if DEBUG
            navigator.viewportFixtureControl = viewportFixtureControl
        #endif
        navigator.verticalScreenPagingEnabled = interaction.verticalScreenPaging
        appliedPreferences = preferences
        searchProvider = publication.isSearchable ? ReadiumSearchProvider(publication: publication, bookID: book.id, txtPlan: txt?.plan) : nil
        currentPosition = position
        navigator.delegate = self
        // Readium dispatches only taps not consumed by links, selection, etc.
        // Avoid a SwiftUI gesture overlay that would block publication interactions.
        navigator.addObserver(.tap { [weak self, weak navigator] event in
            guard let self, let navigator, self.navigator === navigator, self.openRequestID != nil else { return false }
            let width = navigator.view.bounds.width
            guard width > 0 else { return false }
            if navigator.presentation.scroll && self.interaction.verticalScreenPaging {
                let height = navigator.view.bounds.height
                guard height > 0 else { return false }
                if event.location.y < height * 0.3 { await self.turnPage(forward: false) }
                else if event.location.y > height * 0.7 { await self.turnPage(forward: true) }
                else { self.onCenterTap?() }
            } else if event.location.x < width * 0.3 {
                if !navigator.presentation.scroll { await self.turnPage(forward: false) }
            } else if event.location.x > width * 0.7 {
                if !navigator.presentation.scroll { await self.turnPage(forward: true) }
            } else {
                self.onCenterTap?()
            }
            return true
        })
        navigator.addObserver(.drag(onStart: { [weak self, weak navigator] _ in
            guard let self, let navigator, self.navigator === navigator, self.openRequestID != nil,
                  !UIAccessibility.isVoiceOverRunning else { return false }
            self.onReadingGesture?()
            return false
        }))
        host.loadViewIfNeeded()
        host.addChild(navigator)
        // Seed a valid viewport before Readium starts its asynchronous layout.
        // Match the upstream SwiftUI container recipe instead of mounting a
        // zero-frame child and waiting for a later Auto Layout pass.
        navigator.view.frame = host.view.bounds
        navigator.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.addSubview(navigator.view)
        navigator.didMove(toParent: host)
        let touch = AutomaticScrollTouchObserver { [weak self, weak navigator] in
            guard let self, self.navigator === navigator, self.automaticScrollState.isActive else { return }
            self.pauseAutomaticScroll()
        }
        navigator.view.addGestureRecognizer(touch)
        automaticScrollTouch = touch
    }

    public func turnPage(forward: Bool) async {
        pauseAutomaticScroll()
        guard let navigator, pageTurnRequestID == nil, !Task.isCancelled else { return }
        let requestID = UUID()
        pageTurnRequestID = requestID
        defer { if pageTurnRequestID == requestID { pageTurnRequestID = nil } }
        if forward { await navigator.goForward(options: navigationOptions) }
        else { await navigator.goBackward(options: navigationOptions) }
    }

    public func go(to chapter: Chapter) async throws {
        pauseAutomaticScroll()
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
        guard await navigator.go(to: Link(href: href), options: navigationOptions) else { throw EPUBError.navigationFailed }
    }

    public func captureCurrentPosition() async throws -> ReadingPosition {
        try Task.checkCancellation()
        guard let navigator, let bookID, let requestID = openRequestID,
              modeChangeTask == nil else { throw ReaderPositionCaptureError.unavailable }
        pauseAutomaticScroll()
        await flushAutomaticScrollPosition()
        try Task.checkCancellation()
        guard openRequestID == requestID, self.navigator === navigator else { throw CancellationError() }
        guard modeChangeTask == nil else { throw ReaderPositionCaptureError.unavailable }
        let deadline = Date().addingTimeInterval(3)
        repeat {
            try Task.checkCancellation()
            guard openRequestID == requestID, self.navigator === navigator else { throw CancellationError() }
            guard modeChangeTask == nil else { throw ReaderPositionCaptureError.unavailable }
            let captured = await navigator.preserveCurrentDOMLocationForModeChange()
            try Task.checkCancellation()
            guard openRequestID == requestID, self.navigator === navigator else { throw CancellationError() }
            guard modeChangeTask == nil else { throw ReaderPositionCaptureError.unavailable }
            if captured, let locator = navigator.currentLocation {
                if let txtReading { return try TXTPositionCodec.encode(locator, bookID: bookID, plan: txtReading.plan) }
                return try ReadiumPositionCodec.encode(locator, bookID: bookID)
            }
            // A freshly mounted spread may still be restoring its initial full
            // locator behind the loading indicator. Wait for readable native
            // content instead of saving its transient chapter-head DOM.
            guard supportsTextAppearance, Date() < deadline else { break }
            try await Task.sleep(nanoseconds: 32_000_000)
        } while true
        throw ReaderPositionCaptureError.unavailable
    }

    public func go(to position: ReadingPosition) async throws {
        pauseAutomaticScroll()
        guard let bookID, let navigator else { throw EPUBError.navigationFailed }
        let requestID = openRequestID
        let locator: Locator
        if let txtReading { locator = try await txtReading.locator(position, bookID: bookID) }
        else { locator = try ReadiumPositionCodec.decode(position, bookID: bookID) }
        try Task.checkCancellation()
        guard openRequestID == requestID, self.navigator === navigator else { throw CancellationError() }
        guard await navigator.go(to: locator, options: navigationOptions) else { throw EPUBError.navigationFailed }
    }

    public func setScrolling(_ enabled: Bool) {
        stopAutomaticScroll()
        cancelModeChange()
        preferences.infiniteScroll = false
        preferences.scroll = enabled
        navigator?.submitPreferences(preferences)
        appliedPreferences = preferences
    }

    public func setContinuousScrolling(_ enabled: Bool) {
        stopAutomaticScroll()
        guard navigator == nil || !enabled || supportsContinuousScrolling else {
            onError?("这本书的固定布局、竖排或从右向左方向暂不支持连续滚动，请使用分页模式。")
            return
        }
        preferences.scroll = enabled
        preferences.infiniteScroll = enabled
        submitPreservingLocation()
    }

    public func setAppearance(_ appearance: ReadingAppearance) throws {
        pauseAutomaticScroll()
        preferences.apply(try appearance.validated())
        host.view.backgroundColor = UIColor(red: CGFloat((appearance.theme.backgroundRGB >> 16) & 255) / 255,
            green: CGFloat((appearance.theme.backgroundRGB >> 8) & 255) / 255,
            blue: CGFloat(appearance.theme.backgroundRGB & 255) / 255, alpha: 1)
        submitPreservingLocation()
    }

    private func submitPreservingLocation() {
        cancelModeChange()
        guard let navigator else { return }
        // Repeating applied preferences must not sample an opening DOM.
        // Cancel first so reverting a queued edit keeps the current settings.
        guard preferences != appliedPreferences else { return }
        let requestID = UUID()
        modeChangeRequestID = requestID
        let requestedPreferences = preferences
        modeChangeTask = Task { @MainActor [weak self, weak navigator] in
            guard let self, let navigator else { return }
            // A superseded task may not have started yet. Do not let it enter
            // WebKit's readiness/anchor work after a newer request replaces it.
            guard !Task.isCancelled, self.modeChangeRequestID == requestID, self.navigator === navigator else {
                self.tracePreferenceRequest("superseded before sample")
                return
            }
            self.tracePreferenceRequest("sample requested")
            defer {
                if self.modeChangeRequestID == requestID, self.navigator === navigator { self.modeChangeTask = nil }
            }
            let deadline = Date().addingTimeInterval(3)
            while true {
                let sampled = await navigator.preserveCurrentDOMLocationForModeChange()
                guard !Task.isCancelled, self.modeChangeRequestID == requestID, self.navigator === navigator else { return }
                if sampled { break }
                guard Date() < deadline else {
                    self.onError?("页面仍在排版，请稍后重新选择字体或排版设置。")
                    return
                }
                do { try await Task.sleep(nanoseconds: 32_000_000) }
                catch {
                    guard !Task.isCancelled, self.modeChangeRequestID == requestID, self.navigator === navigator else { return }
                    self.onError?("排版调整未完成：\(error.localizedDescription)")
                    return
                }
            }
            self.tracePreferenceRequest("sample returned")
            // Expose the fresh full anchor immediately. A close/save while the
            // reflow is settling must not use an older percentage-only callback.
            if let locator = navigator.currentLocation { self.capture(locator) }
            // Compare against the preferences actually submitted, not an edit
            // whose task a later theme/mode change may have just cancelled.
            let previous = self.appliedPreferences
            let reflows = previous.fontFamily != requestedPreferences.fontFamily || previous.fontSize != requestedPreferences.fontSize
                || previous.lineHeight != requestedPreferences.lineHeight || previous.paragraphSpacing != requestedPreferences.paragraphSpacing
                || previous.pageMargins != requestedPreferences.pageMargins || previous.paragraphIndent != requestedPreferences.paragraphIndent
                || previous.letterSpacing != requestedPreferences.letterSpacing || previous.fontWeight != requestedPreferences.fontWeight
                || previous.textAlign != requestedPreferences.textAlign || previous.publisherStyles != requestedPreferences.publisherStyles
            // A resource face can finish loading after the first DOM layout.
            // Use Readium's existing full-anchor invalidation for its typography;
            // system-font continuous edits keep the bounded live-CSS path.
            let resourceFont = self.readingFonts.contains {
                $0.asset.cssFamily == requestedPreferences.fontFamily?.rawValue
                    || $0.asset.cssFamily == previous.fontFamily?.rawValue
            }
            let rebuilds = reflows && (requestedPreferences.infiniteScroll != true || resourceFont)
            navigator.submitPreferences(requestedPreferences, reloadingPagination: rebuilds)
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
        stopAutomaticScroll()
        automaticScrollSampleID = nil
        automaticScrollSampleTask?.cancel()
        automaticScrollSampleTask = nil
        if let automaticScrollTouch { automaticScrollTouch.view?.removeGestureRecognizer(automaticScrollTouch) }
        automaticScrollTouch = nil
        // A suspended publication load must not mount a navigator after this reader closes.
        openRequestID = nil
        pageTurnRequestID = nil
        cancelModeChange()
        if let navigator {
            if let locator = navigator.currentLocation { capture(locator) }
            navigator.delegate = nil
            navigator.closeReadingSession()
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
        pauseAutomaticScroll()
        onError?(error.localizedDescription)
    }
    public func navigator(_ navigator: Navigator, didFailToLoadResourceAt href: RelativeURL, withError error: ReadError) {
        guard (navigator as AnyObject) === self.navigator else { return }
        pauseAutomaticScroll()
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

extension ReadiumReaderEngine {
    public func startAutomaticScroll(screensPerMinute: Double) throws {
        guard !interaction.reduceMotion, !UIAccessibility.isReduceMotionEnabled,
              !UIAccessibility.isVoiceOverRunning else { throw AutomaticScrollFailure.accessibility }
        guard screensPerMinute.isFinite, (0.5...6).contains(screensPerMinute),
              UIApplication.shared.applicationState == .active,
              let navigator, openRequestID != nil, supportsContinuousScrolling,
              preferences.infiniteScroll == true, !interaction.verticalScreenPaging,
              modeChangeTask == nil, navigator.automaticScrollViewportHeight != nil else {
            throw AutomaticScrollFailure.notReady
        }
        endAutomaticScrollClock()
        automaticScrollSampleID = nil
        automaticScrollSampleTask?.cancel(); automaticScrollSampleTask = nil
        automaticScrollSpeed = screensPerMinute
        let request = UUID()
        automaticScrollSessionID = request
        automaticScrollPreviousIdleTimer = UIApplication.shared.isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = true
        navigator.setAutomaticScrolling(true)
        let target = AutomaticScrollDisplayTarget(owner: self, request: request)
        let link = CADisplayLink(target: target, selector: #selector(AutomaticScrollDisplayTarget.tick(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        automaticScrollLink = link
        link.add(to: .main, forMode: .common)
        NotificationCenter.default.addObserver(self, selector: #selector(automaticScrollEnvironmentChanged),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(automaticScrollAccessibilityChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(automaticScrollAccessibilityChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
        setAutomaticScrollState(.running)
    }

    public func pauseAutomaticScroll() {
        guard automaticScrollState.isActive else { return }
        endAutomaticScrollClock()
        setAutomaticScrollState(.paused)
        requestAutomaticScrollPosition()
    }

    public func stopAutomaticScroll() {
        endAutomaticScrollClock()
        setAutomaticScrollState(.stopped)
    }

    public func flushAutomaticScrollPosition() async {
        guard automaticScrollState != .stopped else { return }
        pauseAutomaticScroll()
        requestAutomaticScrollPosition()
        await automaticScrollSampleTask?.value
    }

    private func setAutomaticScrollState(_ value: ReaderAutomaticScrollState) {
        guard automaticScrollState != value else { return }
        automaticScrollState = value
        onAutomaticScrollStateChanged?(value)
    }

    private func endAutomaticScrollClock() {
        automaticScrollSessionID = nil
        automaticScrollLink?.invalidate(); automaticScrollLink = nil
        if let automaticScrollPreviousIdleTimer { UIApplication.shared.isIdleTimerDisabled = automaticScrollPreviousIdleTimer }
        automaticScrollPreviousIdleTimer = nil
        automaticScrollClock.reset(); automaticScrollLastSample = nil
        if automaticScrollState.isActive { navigator?.setAutomaticScrolling(false) }
        for name in [UIApplication.willResignActiveNotification, UIAccessibility.reduceMotionStatusDidChangeNotification,
                     UIAccessibility.voiceOverStatusDidChangeNotification] {
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
    }

    @objc private func automaticScrollEnvironmentChanged() { pauseAutomaticScroll() }
    @objc private func automaticScrollAccessibilityChanged() {
        if UIAccessibility.isReduceMotionEnabled || UIAccessibility.isVoiceOverRunning { pauseAutomaticScroll() }
    }

    // Request identity also protects against an already queued display callback
    // after pause, close, speed change, a new book or a second explicit start.
    func advanceAutomaticScroll(at timestamp: TimeInterval, request: UUID) {
        guard automaticScrollSessionID == request, automaticScrollState.isActive,
              UIApplication.shared.applicationState == .active,
              let navigator, let height = navigator.automaticScrollViewportHeight else {
            if automaticScrollSessionID == request { pauseAutomaticScroll() }
            return
        }
        let distance = automaticScrollClock.distance(at: timestamp, viewportHeight: height, screensPerMinute: automaticScrollSpeed)
        guard distance > 0 else { return }
        switch navigator.advanceAutomaticScroll(by: distance) {
        case .moved:
            if automaticScrollState == .waiting {
                automaticScrollLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
                setAutomaticScrollState(.running)
            }
        case .waiting:
            automaticScrollLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: 10, preferred: 10)
            setAutomaticScrollState(.waiting)
        case .finished:
            endAutomaticScrollClock(); setAutomaticScrollState(.finished); requestAutomaticScrollPosition()
        case .interrupted: pauseAutomaticScroll()
        case .failed:
            pauseAutomaticScroll()
            onError?("自动慢滚已暂停，章节未能加载。请在正文边界重试加载后再继续。")
        }
        if automaticScrollState.isActive, automaticScrollSampleTask == nil,
           timestamp - (automaticScrollLastSample ?? -Double.greatestFiniteMagnitude) >= 1 {
            automaticScrollLastSample = timestamp
            requestAutomaticScrollPosition()
        }
    }

    private func requestAutomaticScrollPosition() {
        guard let navigator, let session = openRequestID else { return }
        automaticScrollSampleTask?.cancel()
        let request = UUID(); automaticScrollSampleID = request
        automaticScrollSampleTask = Task { @MainActor [weak self, weak navigator] in
            guard let self, let navigator, !Task.isCancelled, self.openRequestID == session,
                  self.navigator === navigator, self.automaticScrollSampleID == request else { return }
            await navigator.sampleAutomaticScrollLocation()
            guard !Task.isCancelled, self.openRequestID == session, self.navigator === navigator,
                  self.automaticScrollSampleID == request else { return }
            self.automaticScrollSampleTask = nil
        }
    }
}

#if DEBUG
extension ReadiumReaderEngine {
    typealias ViewportFixtureEvent = EPUBViewportFixtureEvent
    typealias ViewportFixtureControl = EPUBViewportFixtureControl
    var viewportFixtureControl: (any ViewportFixtureControl)? {
        get { viewportFixtureStorage as? any ViewportFixtureControl }
        set { viewportFixtureStorage = newValue; navigator?.viewportFixtureControl = newValue }
    }
    func requestViewportFixtureSample() async {
        await EPUBViewportFixtureEvent.$source.withValue("test-auxiliary") {
            _ = await navigator?.firstVisibleElementLocator()
        }
    }
}
#endif
