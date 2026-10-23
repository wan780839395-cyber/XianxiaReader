//
//  Copyright 2026 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import ReadiumShared
@preconcurrency import WebKit

#if DEBUG
let epubLoadingDiagnosticsEnabled = true
#else
let epubLoadingDiagnosticsEnabled = false
#endif

protocol EPUBSpreadViewDelegate: AnyObject {
    /// Returns the content inset the spread view should use.
    func spreadViewContentInset(_ spreadView: EPUBSpreadView) -> UIEdgeInsets

    /// Called when the spread view finished loading.
    func spreadViewDidLoad(_ spreadView: EPUBSpreadView) async

    /// Called when the user tapped on an external link.
    func spreadView(_ spreadView: EPUBSpreadView, didTapOnExternalURL url: URL)

    /// Called when the user tapped on an internal link.
    func spreadView(_ spreadView: EPUBSpreadView, didTapOnInternalLink href: String, clickEvent: ClickEvent?)

    /// Called when the user tapped on a decoration.
    func spreadView(_ spreadView: EPUBSpreadView, didActivateDecoration id: Decoration.Id, inGroup group: DecorationGroup, frame: CGRect?, point: CGPoint?)

    /// Called when the text selection changes.
    func spreadView(_ spreadView: EPUBSpreadView, selectionDidChange text: Locator.Text?, frame: CGRect)

    /// Called when the pages visible in the spread changed.
    func spreadViewPagesDidChange(_ spreadView: EPUBSpreadView)

    /// Called when the spread view needs to present a view controller.
    func spreadView(_ spreadView: EPUBSpreadView, present viewController: UIViewController)

    /// Called when the user triggered an input pointer event.
    func spreadView(_ spreadView: EPUBSpreadView, didReceive event: PointerEvent)

    /// Called when the user triggered an input key event.
    func spreadView(_ spreadView: EPUBSpreadView, didReceive event: KeyEvent)

    /// Called when WKWebview terminates
    func spreadViewDidTerminate()
}

class EPUBSpreadView: UIView, Loggable, PageView {
    weak var delegate: EPUBSpreadViewDelegate?
    let viewModel: EPUBNavigatorViewModel
    let spread: EPUBSpread
    private(set) var focusedResource: ReadingOrder.Index?

    let webView: WebView

    private var lastClick: ClickEvent?

    /// If YES, the content will be faded in once loaded.
    let animatedLoad: Bool

    weak var activityIndicatorView: UIActivityIndicatorView?
    private var activityIndicatorStopWorkItem: DispatchWorkItem?

    private(set) var isSpreadLoaded = false
    private var spreadLoadTask: Task<Void, Never>?
    private var nativeBootstrapTask: Task<Void, Never>?
    private var navigationFinished = false
    private var initializationStarted = false
    private var initializationFinished = false
    private var wasCleared = false
    private let onContinuousInitializationReady = CompletionList()
    private var loadingStages: [String] = []
    private let loadingTraceID = epubLoadingDiagnosticsEnabled ? UUID().uuidString : ""
    // Nil opaque storage in Release; all access/installers are DEBUG-only.
    private var innerScrollDiagnosticStorage: AnyObject?

    /// Bounded metadata only: no book URL, locator, title or document text.
    private func recordLoadingStage(_ stage: String) {
        guard epubLoadingDiagnosticsEnabled, loadingStages.count < 24 else { return }
        loadingStages.append("\(Int(ProcessInfo.processInfo.systemUptime * 1000)):\(stage)")
        NSLog("XRReadingLifecycle %@", "\(loadingTraceID.prefix(8)):\(stage) continuous=\(viewModel.infiniteScroll) attached=\(window != nil) loading=\(webView.isLoading) hasURL=\(webView.url != nil) initialization=\(initializationStarted)/\(initializationFinished) cleared=\(wasCleared)")
    }

    var loadingLifecycleDiagnostic: String {
        guard epubLoadingDiagnosticsEnabled else { return "disabled" }
        return "trace=\(loadingTraceID.prefix(8)) navigationFinished=\(navigationFinished) initialization=\(initializationStarted)/\(initializationFinished) cleared=\(wasCleared) attached=\(window != nil) loading=\(webView.isLoading) hasURL=\(webView.url != nil) progress=\(webView.estimatedProgress) stages=\(loadingStages.joined(separator: ","))"
    }

    required init(
        viewModel: EPUBNavigatorViewModel,
        spread: EPUBSpread,
        scripts: [WKUserScript],
        animatedLoad: Bool
    ) {
        self.viewModel = viewModel
        self.spread = spread
        self.animatedLoad = animatedLoad

        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(viewModel.server, forURLScheme: viewModel.server.scheme)
        config.mediaTypesRequiringUserActionForPlayback = .all

        // Disable the Apple Intelligence Writing tools in the web views.
        // See https://github.com/readium/swift-toolkit/issues/509#issuecomment-2577780749
        if #available(iOS 18.0, *) {
            config.writingToolsBehavior = .none
        }

        webView = WebView(editingActions: viewModel.editingActions, configuration: config)

        super.init(frame: .zero)

        isOpaque = false
        backgroundColor = .clear

        webView.frame = bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(webView)
        setupWebView()

        for script in scripts {
            webView.configuration.userContentController.addUserScript(script)
        }
        registerJSMessages()

        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusDidChange), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)

        updateActivityIndicator()
        recordLoadingStage("request")
        loadSpread()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        clear()
    }

    /// Called when the spread view is removed from the view hierarchy, to
    /// clear pending operations and retain cycles.
    func clear() {
        #if DEBUG
            configureInnerScrollDiagnostics(nil, reason: "spread-clear")
        #endif
        recordLoadingStage("clear")
        wasCleared = true
        // A retired resource must not reload the current layout when WebKit
        // delivers a late process-termination or scroll callback.
        delegate = nil
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        scrollView.delegate = nil
        onContinuousInitializationReady.complete()
        onSpreadLoadedCallbacks.complete()
        webView.stopLoading()

        spreadLoadTask?.cancel()
        spreadLoadTask = nil
        nativeBootstrapTask?.cancel()
        nativeBootstrapTask = nil

        // Disable JS messages to break WKUserContentController reference.
        disableJSMessages()
    }

    func setupWebView() {
        scrollView.alpha = 0

        webView.backgroundColor = UIColor.clear
        scrollView.backgroundColor = UIColor.clear

        webView.allowsBackForwardNavigationGestures = false

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        // Prevents the pages from jumping down when the status bar is toggled
        scrollView.contentInsetAdjustmentBehavior = .never

        webView.navigationDelegate = self
        webView.uiDelegate = self
        scrollView.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var scrollView: UIScrollView {
        webView.scrollView
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            clear()
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil {
            enableJSMessages()
            scrollView.delegate = self
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bootstrapInitialization()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        recordLoadingStage(window == nil ? "window.detached" : "window.attached")
    }

    // Readium's window-load bridge posts spreadLoaded on requestAnimationFrame.
    // Offscreen preloads can have that callback suspended by WebKit. Native
    // navigation completion starts the SAME full initialization pipeline once
    // the Readium script and a real viewport are available; it does not mark
    // the spread ready merely because the DOM is complete. Reflowable paged
    // spreads also preload offscreen; fixed-layout initialization is unchanged.
    private func bootstrapInitialization() {
        guard (viewModel.infiniteScroll || self is EPUBReflowableSpreadView),
              navigationFinished, !wasCleared, !initializationStarted,
              nativeBootstrapTask == nil, bounds.width > 0, bounds.height > 0 else { return }
        nativeBootstrapTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.nativeBootstrapTask = nil }
            self.recordLoadingStage("bootstrap.start")
            self.webView.layoutIfNeeded()
            do {
                // The normal Readium evaluator waits for spreadLoaded. This
                // bootstrap probe must run directly, before that signal.
                let value = try await self.webView.evaluateJavaScript("document.readyState === 'complete' && typeof window.readium?.scrollToLocator === 'function' && innerWidth > 0 && innerHeight > 0")
                guard !Task.isCancelled, !self.wasCleared else { return }
                self.recordLoadingStage(value as? Bool == true ? "bootstrap.ready" : "bootstrap.not-ready")
                if value as? Bool == true { self.spreadDidLoad(NSNull()) }
            } catch {
                guard !Task.isCancelled, !self.wasCleared else { return }
                self.recordLoadingStage("bootstrap.error.\((error as NSError).code)")
                self.log(.error, error)
            }
        }
    }

    func loadSpread() {
        fatalError("loadSpread() must be implemented in subclasses")
    }

    /// Evaluates the given JavaScript into the resource's HTML page.
    @discardableResult
    func evaluateScript(_ script: String, inHREF href: AnyURL? = nil,
                        fixtureReadObserver: ((String, [String: Double]) -> Void)? = nil) async -> Result<Any, Error> {
        #if DEBUG
            let innerDiagnostic = innerScrollDiagnostics
            let evaluationID = innerDiagnostic?.enterEvaluation(script)
            var diagnosticSubmitted = false
            defer {
                if !diagnosticSubmitted, let evaluationID { innerDiagnostic?.cancelEvaluation(evaluationID) }
            }
        #endif
        await spreadLoaded()
        guard !wasCleared, !Task.isCancelled else { return .failure(CancellationError()) }

        log(.trace, "Evaluate script: \(script)")
        return await withCheckedContinuation { continuation in
            #if DEBUG
                // After the existing load await, at the actual WK submission.
                fixtureReadObserver?("js-submit", viewportReadNativeValues())
                if let evaluationID {
                    diagnosticSubmitted = true
                    innerDiagnostic?.submitEvaluation(evaluationID)
                }
                let writerObservation = evaluationID.flatMap { innerDiagnostic?.observeWriter(script, id: $0) }
                let submittedScript = writerObservation ?? script
            #else
                let submittedScript = script
            #endif
            webView.evaluateJavaScript(submittedScript) { [weak self] res, error in
                #if DEBUG
                    var businessResult = res
                    if writerObservation != nil, let evaluationID {
                        businessResult = innerDiagnostic?.writerResult(res, id: evaluationID, error: error)
                    }
                    if let fixtureReadObserver {
                        var values = self?.viewportReadNativeValues() ?? [
                            "uptime": ProcessInfo.processInfo.systemUptime, "nativeAvailable": 0]
                        values["evaluationSucceeded"] = error == nil ? 1 : 0
                        values["resultObject"] = businessResult is [String: Any] ? 1 : 0
                        fixtureReadObserver("js-callback", values)
                    }
                    if let evaluationID { innerDiagnostic?.finishEvaluation(evaluationID, error: error) }
                #else
                    let businessResult = res
                #endif
                if let error = error {
                    self?.log(.error, error)
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success(businessResult ?? ()))
                }
            }
        }
    }

    /// Called from the JS code when logging a message.
    private func didLog(_ body: Any) {
        guard let body = body as? String else {
            return
        }
        log(.debug, "JavaScript: \(body)")
    }

    /// Called from the JS code when logging an error.
    private func didLogError(_ body: Any) {
        guard let error = body as? [String: Any],
              var message = error["message"] as? String
        else {
            return
        }
        message = "JavaScript: \(message)"

        if let file = error["filename"] as? String, file != "/",
           let line = error["line"] as? Int, line != 0
        {
            log(.error, message, file: file, line: line)
        } else {
            log(.error, message)
        }
    }

    /// Called from the JS code when a tap is detected.
    /// If the JS indicates the tap is being handled within the webview, don't take action,
    /// just save the tap data for use by webView(_ webView:decidePolicyFor:decisionHandler:)
    private func didTap(_ data: Any) {
        guard let clickEvent = ClickEvent(json: data) else {
            return
        }
        lastClick = clickEvent
    }

    /// Called from the JS code when receiving a pointer event.
    private func didReceivePointerEvent(_ data: Any) {
        guard
            let json = data as? [String: Any],
            // FIXME: Really needed?
            let defaultPrevented = json["defaultPrevented"] as? Bool,
            !defaultPrevented,
            // Ignores events on interactive elements
            (json["interactiveElement"] as? String) == nil,
            var event = PointerEvent(json: json)
        else {
            return
        }

        event.location = convertPointToNavigatorSpace(event.location)

        if let targetElement = targetElement(from: json["targetElement"]) {
            event.targetElement = targetElement
        }

        delegate?.spreadView(self, didReceive: event)
    }

    /// Parses the target element JSON produced by `extractTargetElement()` in
    /// gestures.js and builds a `PointerEvent.TargetElement` with coordinates
    /// converted to the spread view's coordinate space.
    private func targetElement(from json: Any?) -> PointerEvent.TargetElement? {
        guard
            let dict = json as? [String: Any],
            let frameDict = dict["frame"] as? [String: Any],
            let x = frameDict["x"] as? Double,
            let y = frameDict["y"] as? Double,
            let width = frameDict["width"] as? Double,
            let height = frameDict["height"] as? Double
        else {
            return nil
        }

        let frame = convertRectToNavigatorSpace(
            CGRect(x: x, y: y, width: width, height: height)
        )

        // In a two-page FXL spread both resources are loaded in separate
        // iframes, so we use `resourceHref` to identify the correct reading
        // order resource.
        let link = (dict["resourceHref"] as? String)
            .flatMap { AnyURL(string: $0) }
            .flatMap { spread.linkWithHREF($0) }
        guard let link else { return nil }

        // Build a locator pointing to the element inside the resource that
        // contains it.
        var locator = Locator(
            href: link.url(),
            mediaType: link.mediaType ?? .xhtml
        )
        if let cssSelector = dict["cssSelector"] as? String {
            locator.locations.cssSelector = cssSelector
        }

        guard let content = contentElement(locator: locator, json: dict) else {
            return nil
        }
        return PointerEvent.TargetElement(frame: frame, content: content)
    }

    private func contentElement(
        locator: Locator,
        json: [String: Any]
    ) -> (any ContentElement)? {
        guard let tag = json["tag"] as? String else {
            return nil
        }

        // Relativize the src URL against the publication base URL so it
        // becomes a publication-relative href. External URLs (http://) or
        // already-relative URLs fall back to the raw value.
        let src: AnyURL? = (json["src"] as? String)
            .flatMap { AnyURL(string: $0) }
            .flatMap { viewModel.publicationBaseURL.relativize($0)?.anyURL ?? $0 }

        // Look up the Link in the publication manifest so the client gets full
        // metadata (media type, etc.). For resources not in the manifest (e.g.
        // external http:// images) we synthesise a plain Link.
        let embeddedLink: Link? = src.flatMap {
            viewModel.publication.linkWithHREF($0) ?? Link(href: $0.string)
        }

        var attributes: [ContentAttribute] = []
        if let label = json["accessibilityLabel"] as? String, !label.isEmpty {
            attributes.append(ContentAttribute(key: .accessibilityLabel, value: label))
        }
        let caption = json["caption"] as? String

        if let embeddedLink {
            switch tag {
            case "img", "svg":
                return ImageContentElement(
                    locator: locator,
                    embeddedLink: embeddedLink,
                    caption: caption,
                    attributes: attributes
                )
            default:
                break
            }
        }

        // Inline SVG fallback.
        if tag == "svg", let html = json["html"] as? String {
            return SVGContentElement(
                locator: locator,
                svg: html,
                caption: caption,
                attributes: attributes
            )
        }

        return nil
    }

    /// Converts the given JavaScript point into a point in the webview's coordinate space.
    func convertPointToNavigatorSpace(_ point: CGPoint) -> CGPoint {
        // To override in subclasses.
        point
    }

    /// Converts the given JavaScript rect into a rect in the webview's coordinate space.
    func convertRectToNavigatorSpace(_ rect: CGRect) -> CGRect {
        // To override in subclasses.
        rect
    }

    // We override the UIResponder touches callbacks to handle taps around the
    // web view.

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        on(.down, touches: touches, event: event)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        on(.move, touches: touches, event: event)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        on(.cancel, touches: touches, event: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        on(.up, touches: touches, event: event)
    }

    private func on(_ phase: PointerEvent.Phase, touches: Set<UITouch>, event: UIEvent?) {
        for touch in touches {
            delegate?.spreadView(self, didReceive: PointerEvent(
                pointer: Pointer(touch: touch, event: event),
                phase: phase,
                location: touch.location(in: self),
                modifiers: KeyModifiers(event: event)
            ))
        }
    }

    private func spreadLoadDidStart(_ body: Any) {}

    /// Called by the javascript code when the spread contents is fully loaded.
    /// The JS message `spreadLoaded` needs to be emitted by a subclass script, EPUBSpreadView's scripts don't.
    private func spreadDidLoad(_ body: Any) {
        guard !wasCleared, !initializationStarted else { return }
        initializationStarted = true
        recordLoadingStage("initialization.start")
        spreadLoadTask = Task { @MainActor in
            guard !Task.isCancelled, !wasCleared else { return }
            isSpreadLoaded = true
            applySettings()
            await spreadDidLoad()
            recordLoadingStage("initialization.content-returned")
            guard !Task.isCancelled, !wasCleared else { return }
            await delegate?.spreadViewDidLoad(self)
            recordLoadingStage("initialization.delegate-returned")
            guard !Task.isCancelled, !wasCleared else { return }
            initializationFinished = true
            recordLoadingStage("initialization.finished")
            onContinuousInitializationReady.complete()
            onSpreadLoadedCallbacks.complete()
            showSpread()
        }
    }

    /// To be overriden to customize the behavior after the spread is loaded.
    func spreadDidLoad() async {}

    private let onSpreadLoadedCallbacks = CompletionList()

    /// `isSpreadLoaded` is set before Readium's delayed initial location and
    /// decoration work finish. Continuous navigation must wait for all of it.
    func continuousInitializationReady() async {
        if initializationFinished || wasCleared { return }
        await withCheckedContinuation { continuation in
            onContinuousInitializationReady.add { continuation.resume() }
        }
    }

    /// Awaits for the spread to be fully loaded.
    func spreadLoaded() async {
        if isSpreadLoaded || wasCleared {
            return
        }

        await withCheckedContinuation { continuation in
            whenSpreadLoaded {
                continuation.resume()
            }
        }
    }

    /// Executes the given `callback` when the spread is fully loaded.
    func whenSpreadLoaded(_ callback: @escaping () -> Void) {
        let callback = onSpreadLoadedCallbacks.add(callback)
        if isSpreadLoaded || wasCleared {
            callback()
        }
    }

    func showSpread() {
        activityIndicatorView?.stopAnimating()
        activityIndicatorStopWorkItem?.cancel()
        UIView.animate(withDuration: animatedLoad ? 0.3 : 0, animations: {
            self.scrollView.alpha = 1
        })
    }

    /// Called by the JavaScript layer when the user selection changed.
    private func selectionDidChange(_ body: Any) {
        if body is NSNull {
            focusedResource = nil
            delegate?.spreadView(self, selectionDidChange: nil, frame: .zero)
            return
        }

        guard
            let selection = body as? [String: Any],
            let hrefString = selection["href"] as? String,
            let href = AnyURL(string: hrefString),
            let text = try? Locator.Text(json: JSONValue(selection["text"])),
            var frame = CGRect(json: selection["rect"])
        else {
            focusedResource = nil
            delegate?.spreadView(self, selectionDidChange: nil, frame: .zero)
            log(.warning, "Invalid body for selectionDidChange: \(body)")
            return
        }

        focusedResource = viewModel.readingOrder.firstIndexWithHREF(href)
        frame.origin = convertPointToNavigatorSpace(frame.origin)
        delegate?.spreadView(self, selectionDidChange: text, frame: frame)
    }

    /// Update webview style to userSettings.
    /// To override in subclasses.
    func applySettings() {
        assert(Thread.isMainThread, "User settings must be updated from the main thread")
    }

    // MARK: - Location and progression.

    /// Current progression in the resource with given href.
    func progression(in index: ReadingOrder.Index) -> ClosedRange<Double> {
        // To be overridden in subclasses if the resource supports a progression.
        0 ... 1
    }

    func go(to location: PageLocation, animated: Bool) async {
        fatalError("go(to:) must be implemented in subclasses")
    }

    enum Direction: CustomStringConvertible {
        case left
        case right

        var description: String {
            switch self {
            case .left: return "left"
            case .right: return "right"
            }
        }
    }

    func go(to direction: Direction, options: NavigatorGoOptions) async -> Bool {
        // The default implementation of a spread view considers that its content is entirely visible on screen.
        false
    }

    // Continuous mode clips a fixed-size WebView viewport inside its chapter
    // wrapper. Build a DOM anchor for the visible slice, not its hidden top.
    static let continuousAnchorRectFunction = """
    (locator) => {
      const locations = locator.locations || {}, point = locations.domRange?.start;
      const element = document.querySelector(point?.cssSelector || locations.cssSelector || 'body');
      if (!element) return null;
      if (point && Number.isInteger(point.charOffset)) {
        const node = element.childNodes[point.textNodeIndex];
        if (!node || node.nodeType !== Node.TEXT_NODE || point.charOffset > node.length) return null;
        const range = document.createRange();
        range.setStart(node, point.charOffset);
        range.setEnd(node, Math.min(node.length, point.charOffset + 1));
        return range.getClientRects()[0] || range.getBoundingClientRect();
      }
      return element.getBoundingClientRect();
    }
    """

    func continuousAnchorDocumentY(_ locator: Locator) async throws -> CGFloat? {
        let json = try locator.jsonString()
        let result = await evaluateScript("(() => { const rect = (\(Self.continuousAnchorRectFunction))(\(json)); return rect ? rect.top + scrollY : null; })()")
        return (try result.get() as? NSNumber).map { CGFloat($0.doubleValue) }
    }

    func continuousVisibleAnchorSnapshot(visibleTop: CGFloat, visibleBottom: CGFloat,
                                         fixtureMetadata: (([String: Double]) -> Void)? = nil,
                                         fixtureReadObserver: ((String, [String: Double]) -> Void)? = nil) async
        -> (locator: Locator, documentY: CGFloat, documentTop: CGFloat)?
    {
        #if DEBUG
            let fixtureReadStartJS = fixtureReadObserver == nil ? "" : "const fixtureReadStart = {scrollY, now:performance.now()};"
            let fixtureReadJS = fixtureReadObserver == nil ? "" : ",readStartScrollY:fixtureReadStart.scrollY,readStartNow:fixtureReadStart.now,readEndScrollY:scrollY,readEndNow:performance.now()"
            let fixtureJS = fixtureMetadata == nil ? "" : ",fixture:{width:innerWidth,height:innerHeight,scrollY\(fixtureReadJS)}"
        #else
            let fixtureReadStartJS = ""
            let fixtureJS = ""
        #endif
        let script = """
        (() => {
          const top = \(visibleTop), bottom = \(visibleBottom);\(fixtureReadStartJS)
          function find(root) {
            for (const child of root.children) {
              const style = getComputedStyle(child), rect = child.getBoundingClientRect();
              if (style.display !== 'none' && style.visibility !== 'hidden' && style.opacity !== '0'
                  && rect.bottom > top && rect.top < bottom && rect.right > 0 && rect.left < innerWidth) return find(child);
            }
            return root;
          }
          function selector(element) {
            // TXT windows assign unique byte IDs. Keep that source anchor in
            // the native Locator; ordinary EPUBs retain the existing path selectors.
            if (document.documentElement.getAttribute('data-xianxia-txt') === '1' && /^txt-b[0-9]+$/.test(element.id)) {
              const idSelector = '#' + CSS.escape(element.id);
              if (document.querySelectorAll(idSelector).length === 1) return idSelector;
            }
            const parts = [];
            for (let node = element; node && node.nodeType === 1; node = node.parentElement) {
              const tag = node.localName;
              const siblings = node.parentElement ? Array.from(node.parentElement.children).filter(x => x.localName === tag) : [];
              parts.unshift(tag + (siblings.length > 1 ? ':nth-of-type(' + (siblings.indexOf(node) + 1) + ')' : ''));
            }
            return parts.join(' > ');
          }
          let element = find(document.body), caret = null;
          // Public DOM caret API finds a character on the visible line even
          // inside a paragraph taller than the viewport. Only bounded context
          // is copied; a whole paragraph/resource is never returned to Swift.
          for (const y of [top + 2, top + 12, top + 24]) {
            if (y >= bottom) break;
            for (const x of [innerWidth * 0.2, innerWidth * 0.5, innerWidth * 0.8]) {
              const range = document.caretRangeFromPoint(x, y);
              if (range?.startContainer.nodeType !== Node.TEXT_NODE) continue;
              const node = range.startContainer, offset = range.startOffset;
              const test = document.createRange();
              test.setStart(node, offset); test.setEnd(node, Math.min(node.length, offset + 1));
              const rect = test.getClientRects()[0];
              if (rect && rect.bottom > top && rect.top < bottom && rect.right > 0 && rect.left < innerWidth && node.data.trim()) { caret = range; break; }
            }
            if (caret) break;
          }
          const locations = {cssSelector:selector(element), xianxiaContinuousAnchorVersion:1};
          let text = {};
          if (caret) {
            const node = caret.startContainer;
            // Context is bounded in UTF16, but no boundary may split an emoji's
            // surrogate pair: Foundation cannot serialize those invalid strings.
            const boundary = value => {
              if (value > 0 && value < node.length) {
                const before = node.data.charCodeAt(value - 1), after = node.data.charCodeAt(value);
                if (before >= 0xD800 && before <= 0xDBFF && after >= 0xDC00 && after <= 0xDFFF) return value - 1;
              }
              return value;
            };
            const offset = boundary(caret.startOffset);
            const contextStart = boundary(Math.max(0, offset - 64));
            const highlightEnd = boundary(Math.min(node.length, offset + 64));
            const contextEnd = boundary(Math.min(node.length, offset + 128));
            element = node.parentElement;
            locations.cssSelector = selector(element);
            locations.domRange = {start:{cssSelector:locations.cssSelector,
              textNodeIndex:Array.from(element.childNodes).indexOf(node), charOffset:offset}};
            text = {before:node.data.slice(contextStart, offset),
                    highlight:node.data.slice(offset, highlightEnd), after:node.data.slice(highlightEnd, contextEnd)};
          }
          const locator = {href:'#',type:'application/xhtml+xml',locations,text};
          const rect = (\(Self.continuousAnchorRectFunction))(locator);
          if (rect) locations.xianxiaViewportOffset = rect.top - top;
          return rect ? {locator, documentY:rect.top + scrollY, documentTop:scrollY + top\(fixtureJS)} : null;
        })()
        """
        #if DEBUG
            let result = await evaluateScript(script, fixtureReadObserver: fixtureReadObserver)
        #else
            let result = await evaluateScript(script)
        #endif
        #if DEBUG
            if let fixtureMetadata {
                var fields: [String: Double] = [:]
                if case let .success(value) = result, let data = value as? [String: Any],
                   let metadata = data["fixture"] as? [String: Any] {
                    for key in ["width", "height", "scrollY", "readStartScrollY", "readStartNow", "readEndScrollY", "readEndNow"] {
                        if let value = metadata[key] as? NSNumber { fields[key] = value.doubleValue }
                    }
                    // Already returned by this evaluation; no second DOM read.
                    for key in ["documentY", "documentTop"] {
                        if let value = data[key] as? NSNumber { fields[key] = value.doubleValue }
                    }
                }
                fields["visibleTop"] = Double(visibleTop)
                fields["visibleBottom"] = Double(visibleBottom)
                if case let .success(value) = result {
                    fields["evaluationSucceeded"] = 1
                    fields["resultObject"] = value is [String: Any] ? 1 : 0
                    if let data = value as? [String: Any] {
                        fields["documentYFinite"] = (data["documentY"] as? NSNumber)?.doubleValue.isFinite == true ? 1 : 0
                        fields["documentTopFinite"] = (data["documentTop"] as? NSNumber)?.doubleValue.isFinite == true ? 1 : 0
                        fields["locatorPresent"] = data["locator"] == nil ? 0 : 1
                    }
                } else { fields["evaluationSucceeded"] = 0 }
                fixtureMetadata(fields)
            }
        #endif
        do {
            guard let snapshot = try result.get() as? [String: Any],
                  let y = snapshot["documentY"] as? NSNumber, y.doubleValue.isFinite,
                  let top = snapshot["documentTop"] as? NSNumber, top.doubleValue.isFinite,
                  let json = JSONValue(snapshot["locator"]), let locator = try Locator(json: json) else { return nil }
            return (locator.copy(href: spread.first.link.url(), mediaType: spread.first.link.mediaType ?? .xhtml),
                    CGFloat(y.doubleValue), CGFloat(top.doubleValue))
        } catch { log(.error, error); return nil }
    }

    func findFirstVisibleElementLocator(visibleTop: CGFloat, visibleBottom: CGFloat) async -> Locator? {
        await continuousVisibleAnchorSnapshot(visibleTop: visibleTop, visibleBottom: visibleBottom)?.locator
    }

    func findFirstVisibleElementLocator() async -> Locator? {
        let result = await evaluateScript("readium.findFirstVisibleLocator()")
        do {
            let link = spread.first.link

            guard
                let json = try JSONValue(result.get()),
                let locator = try Locator(json: json)
            else {
                return nil
            }
            return locator.copy(href: link.url(), mediaType: link.mediaType ?? .xhtml)

        } catch {
            log(.error, error)
            return nil
        }
    }

    // MARK: - JS Messages

    private var JSMessages: [String: (Any) -> Void] = [:]
    private var JSMessagesEnabled = false

    /// Register a new JS message handler to be emitted from scripts.
    func registerJSMessage(named name: String, handler: @escaping (Any) -> Void) {
        guard JSMessages[name] == nil else {
            log(.error, "JS message already registered: \(name)")
            return
        }

        JSMessages[name] = handler
        if JSMessagesEnabled {
            webView.configuration.userContentController.add(self, name: name)
        }
    }

    /// To override in subclasses if needed.
    func registerJSMessages() {
        registerJSMessage(named: "log") { [weak self] in self?.didLog($0) }
        registerJSMessage(named: "logError") { [weak self] in self?.didLogError($0) }
        registerJSMessage(named: "tap") { [weak self] in self?.didTap($0) }
        registerJSMessage(named: "pointerEventReceived") { [weak self] in self?.didReceivePointerEvent($0) }
        registerJSMessage(named: "spreadLoadStarted") { [weak self] in self?.spreadLoadDidStart($0) }
        registerJSMessage(named: "spreadLoaded") { [weak self] in self?.spreadDidLoad($0) }
        registerJSMessage(named: "selectionChanged") { [weak self] in self?.selectionDidChange($0) }
        registerJSMessage(named: "decorationActivated") { [weak self] in self?.decorationDidActivate($0) }
        registerJSMessage(named: "keyEventReceived") { [weak self] in self?.didReceiveKeyEvent($0) }
    }

    /// Add the message handlers for incoming javascript events.
    private func enableJSMessages() {
        guard !JSMessagesEnabled else {
            return
        }
        JSMessagesEnabled = true
        for name in JSMessages.keys {
            webView.configuration.userContentController.add(self, name: name)
        }
    }

    /// Removes message handlers (preventing strong reference cycle).
    private func disableJSMessages() {
        guard JSMessagesEnabled else {
            return
        }
        JSMessagesEnabled = false
        for name in JSMessages.keys {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
    }

    private func didReceiveKeyEvent(_ event: Any) {
        guard
            let dict = event as? [String: Any],
            let keyEvent = KeyEvent(dict: dict)
        else {
            return
        }

        delegate?.spreadView(self, didReceive: keyEvent)
    }

    // MARK: - Decorator

    /// Called by the JavaScript layer when the user activates a decoration.
    private func decorationDidActivate(_ body: Any) {
        guard
            let decoration = body as? [String: Any],
            let decorationId = decoration["id"] as? Decoration.Id,
            let groupName = decoration["group"] as? String,
            var frame = CGRect(json: decoration["rect"])
        else {
            log(.warning, "Invalid body for decorationDidActivate: \(body)")
            return
        }

        frame = convertRectToNavigatorSpace(frame)
        let point = ClickEvent(json: decoration["click"])
            .map { convertPointToNavigatorSpace($0.point) }
        delegate?.spreadView(self, didActivateDecoration: decorationId, inGroup: groupName, frame: frame, point: point)
    }

    // MARK: - Accessibility

    private var isVoiceOverRunning = UIAccessibility.isVoiceOverRunning

    @objc private func voiceOverStatusDidChange() {
        // Avoids excessive settings refresh when the status didn't change.
        guard isVoiceOverRunning != UIAccessibility.isVoiceOverRunning else {
            return
        }
        isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        // Scroll mode will be activated if VoiceOver is on
        applySettings()
    }

    // MARK: - Scripts

    class func loadScript(named name: String) -> String {
        Bundle.module.url(forResource: "\(name)", withExtension: "js", subdirectory: "Assets/Static/scripts")
            .flatMap { try? String(contentsOf: $0) }!
    }
}

#if DEBUG
/// Instance-owned DEBUG metadata. Writer observation uses the existing WK call only.
@MainActor final class EPUBInnerScrollDiagnostics {
    typealias Sink = (UUID, String, [String: String]) -> Void
    private weak var view: EPUBSpreadView?
    private let sink: Sink
    private let coverageID = UUID()
    private var active = true
    private var previousY: Double?
    private var previousUptime: String?
    private var capturedRollback = false
    private var recordedLateCallback = false
    private var writerCapacityExceeded = false
    private var writers: [(id: UUID, source: String)] = []
    private var recentWriter: UUID?
    private var recentEvaluation: UUID?
    private var evaluations: [UUID: [String: String]] = [:]
    private var untrackedEvaluations = 0

    init(view: EPUBSpreadView, sink: @escaping Sink) { self.view = view; self.sink = sink }

    func start(navigationFinished: Bool, initializationStarted: Bool, initializationFinished: Bool) {
        let framework = Bundle(for: WKWebView.self)
        record("coverage-start", fields: ["navigationFinished": String(navigationFinished),
            "initializationStarted": String(initializationStarted), "initializationFinished": String(initializationFinished),
            "preBindingCommandsCovered": "false", "osVersion": ProcessInfo.processInfo.operatingSystemVersionString,
            "webKitBundleID": framework.bundleIdentifier ?? "unknown",
            "webKitVersion": framework.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown",
            "webKitBuild": framework.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown",
            "webKitVersionSource": "runtime-public-bundle", "exactSourceMatch": "unknown"])
    }

    func close(_ reason: String) {
        guard active else { return }
        active = false
        var fields = nativeValues()
        fields["reason"] = reason
        fields["pendingEvaluations"] = String(evaluations.count)
        fields["pendingEvaluationIDs"] = evaluations.keys.map(\.uuidString).sorted().prefix(16).joined(separator: ",")
        fields["pendingIDsTruncated"] = String(evaluations.count > 16)
        fields["untrackedEvaluations"] = String(untrackedEvaluations)
        fields["pendingWriters"] = String(writers.count)
        fields["writerCapacityExceeded"] = String(writerCapacityExceeded)
        emit("coverage-end", id: coverageID, fields: fields)
        evaluations.removeAll(); writers.removeAll(); previousY = nil; previousUptime = nil
        recentWriter = nil; recentEvaluation = nil; view = nil
    }

    func record(_ phase: String, id: UUID? = nil, fields: [String: String] = [:]) {
        guard active else { return }
        let native = nativeValues()
        if let y = Double(native["innerY"] ?? ""), y.isFinite {
            if let previousY, previousY - y > 0.5, !capturedRollback {
                capturedRollback = true
                var rollback = native
                rollback["previousY"] = String(previousY); rollback["observedAt"] = phase
                rollback["previousUptime"] = previousUptime ?? "unknown"
                let symbols = Array(Thread.callStackSymbols.prefix(16))
                let frames: [String] = symbols.map { frame in
                    let tokens = frame.split(separator: " ").filter { !$0.contains("/") && !$0.contains("\\") }
                    let normalized = tokens.joined(separator: " ").replacingOccurrences(of: #"0x[0-9a-fA-F]+"#,
                        with: "<address>", options: .regularExpression)
                    return String(normalized.prefix(160))
                }
                rollback["stack"] = frames.joined(separator: "\n")
                // Labels describe observed symbols, never an inferred IPC initiator.
                let origins = [("scrolling-tree-commit", "RemoteLayerTreeDrawingAreaProxy::commitLayerTree"),
                    ("scrolling-tree-commit", "RemoteLayerTreeDrawingAreaProxy::didCommitLayerTree"),
                    ("scrolling-tree-commit", "RemoteScrollingCoordinatorProxy::commitScrollingTreeState"),
                    ("web-page-proxy-request", "WebPageProxy::requestScroll"),
                    ("page-client-request", "PageClientImpl::requestScroll")]
                let labels = Set(origins.filter { entry in symbols.contains { $0.contains(entry.1) } }.map { $0.0 })
                rollback["originLabels"] = labels.isEmpty ? "unknown" : labels.sorted().joined(separator: ",")
                rollback["originLabelSource"] = "same-16-native-symbols"
                rollback["wkScrollEntryObserved"] = String(symbols.contains { $0.contains("_scrollToContentScrollPosition:") })
                emit("first-rollback", id: id ?? coverageID, fields: rollback)
            }
            previousY = y
            previousUptime = native["uptime"]
        }
        emit(phase, id: id ?? coverageID, fields: native.merging(fields) { _, new in new })
    }

    func beginWrite(_ source: String, target: CGFloat) -> UUID? {
        guard active else { return nil }
        guard writers.count < 16 else {
            if !writerCapacityExceeded { record("writer-capacity", fields: ["incomplete": "true"]) }
            writerCapacityExceeded = true; return nil
        }
        let id = UUID(); writers.append((id, source)); recentWriter = id
        record("writer-before", id: id, fields: ["writerSource": source, "targetY": String(describing: target)])
        return id
    }

    func endWrite(_ id: UUID) {
        defer { if writers.last?.id == id { writers.removeLast() } }
        record("writer-after", id: id, fields: ["writerScopeMatches": String(writers.last?.id == id)])
    }

    func enterEvaluation(_ script: String) -> UUID? {
        guard active else { return nil }
        guard evaluations.count < 256 else {
            untrackedEvaluations += 1
            if untrackedEvaluations == 1 { record("evaluation-capacity", fields: ["incomplete": "true"]) }
            return nil
        }
        let id = UUID()
        var digest: UInt64 = 14695981039346656037
        for byte in script.utf8 { digest = (digest ^ UInt64(byte)) &* 1099511628211 }
        // Shape labels and equality fingerprints only; never retain the script.
        let shapes: [(String, String)] = [("window.__xrCanonicalGoTarget", "canonical"),
                      ("readium.scrollToLocator(", "readium-locator"), ("readium.scrollToId(", "readium-id"),
                      ("readium.scrollToPosition(", "readium-progression"), ("window.scrollBy(", "window-by"),
                      ("window.scrollTo(", "window-to"), ("readium.setCSSProperties(", "css"),
                      ("document.createRange()", "range-read")]
        let category = shapes.first { script.contains($0.0) }?.1 ?? "other"
        evaluations[id] = ["category": category, "scriptDigest": String(digest, radix: 16), "phase": "entered"]
        record("evaluation-enter", id: id, fields: evaluations[id] ?? [:])
        return id
    }

    func submitEvaluation(_ id: UUID) {
        guard active else { return }
        recentEvaluation = id; evaluations[id]?["phase"] = "submitted"
        record("evaluation-submit", id: id, fields: evaluations[id] ?? [:])
    }

    // Strictly one synchronous Readium call. Text inside a Locator cannot select
    // a different script; unknown expressions keep their original bytes.
    private static let writerPattern = #"\Areadium\.(?:scrollToId\('(?:[^'\\\r\n]|\\[^\r\n])*', (?:true|false)\);|scrollToPosition\('(?:0|1|0\.[0-9]+|[0-9.]+[eE]-[0-9]+)', '(?:ltr|rtl|ttb|btt)', (?:true|false)\))\z"#

    private static func supportedWriter(_ script: String) -> Bool {
        if script.range(of: writerPattern, options: .regularExpression) != nil { return true }
        let prefix = "readium.scrollToLocator("
        guard script.hasPrefix(prefix),
              let suffix = [", true);", ", false);"].first(where: { script.hasSuffix($0) }),
              let data = String(script.dropFirst(prefix.count).dropLast(suffix.count)).data(using: .utf8)
        else { return false }
        do { return try JSONSerialization.jsonObject(with: data) is [String: Any] }
        catch { return false } // Unsupported diagnostic shape; original script still executes.
    }

    func observeWriter(_ script: String, id: UUID) -> String? {
        guard active, let view, view.innerScrollDiagnostics === self,
              evaluations[id]?["phase"] == "submitted", Self.supportedWriter(script)
        else { return nil }
        let expression = script.hasSuffix(";") ? String(script.dropLast()) : script
        // Insert the original expression last: text cannot replace template tokens.
        return Self.writerObservationBody + "(\"\(id.uuidString)\",\"\(coverageID.uuidString)\",function(){return " + expression + ";});"
    }

    func writerResult(_ result: Any?, id: UUID, error: Error?) -> Any? {
        // Decode for the original caller even after close. record() is active-only;
        // the existing finishEvaluation owns the one late terminal on the old sink.
        guard error == nil, let body = result as? [String: Any],
              body["schema"] as? String == "xr-scroll-observation-1",
              let kind = body["resultKind"] as? String,
              ["undefined", "null", "boolean", "number", "string"].contains(kind)
        else {
            record("writer-js-incomplete", id: id, fields: ["reason": error == nil ? "no-envelope" : "wk-error-no-envelope",
                "incomplete": "true"])
            return result
        }
        let identityMatches = body["evaluationID"] as? String == id.uuidString &&
            body["coverageID"] as? String == coverageID.uuidString
        if identityMatches, evaluations[id]?["phase"] == "submitted", let view, view.innerScrollDiagnostics === self,
           let calls = body["calls"] as? [[String: Any]], calls.count <= 16,
           let data = try? JSONSerialization.data(withJSONObject: calls, options: [.sortedKeys]),
           let callsJSON = String(data: data, encoding: .utf8) {
            record("writer-js-observation", id: id, fields: ["schema": "xr-scroll-observation-1",
                "incomplete": String(body["incomplete"] as? Bool ?? true),
                "reason": body["reason"] as? String ?? "unknown", "calls": callsJSON,
                "callCount": String(calls.count), "restored": String(body["restored"] as? Bool ?? false),
                "resultKind": kind, "observerIntervention": "temporary-root-own-method"])
        } else {
            record("writer-js-incomplete", id: id, fields: ["reason": "identity-or-envelope", "incomplete": "true"])
        }
        if kind == "undefined" { return nil }
        if kind == "null" { return NSNull() }
        return body["value"]
    }

    // Tested verbatim in Node. No global hooks or persistent state. Only known
    // synchronous helpers are eligible. Original exceptions escape unchanged;
    // WK errors cannot carry this success envelope and are explicitly incomplete.
    private static let writerObservationBody = #"""
    ((evaluationID, coverageID, invoke) => {
      const report = {schema: 'xr-scroll-observation-1', evaluationID, coverageID,
        calls: [], incomplete: false, reason: 'complete', restored: false};
      const incomplete = reason => { report.incomplete = true;
        if (report.reason === 'complete') report.reason = reason; };
      let root, own, original, installed = false;
      const snapshot = () => {
        try {
          const top = root.scrollTop, y = window.scrollY, time = performance.now();
          if (![top, y, time].every(v => typeof v === 'number' && Number.isFinite(v))) {
            incomplete('geometry-unavailable'); return null;
          }
          return {scrollTop: top, scrollY: y, time};
        } catch (_) { incomplete('geometry-error'); return null; }
      };
      const parameters = args => {
        if (args.length !== 1 || args[0] === null || typeof args[0] !== 'object') {
          incomplete('unsupported-overload'); return null;
        }
        const options = args[0], proto = Object.getPrototypeOf(options);
        if (proto !== Object.prototype && proto !== null) { incomplete('options-prototype'); return null; }
        const values = {};
        for (const key of ['left', 'top', 'behavior']) {
          const descriptor = Object.getOwnPropertyDescriptor(options, key);
          // Never evaluate option accessors or coerce values a second time.
          if (!descriptor || !('value' in descriptor)) { incomplete('options-accessor-or-missing'); return null; }
          const value = descriptor.value;
          if (key === 'behavior' ? !['auto', 'instant', 'smooth'].includes(value) :
              typeof value !== 'number' || !Number.isFinite(value)) {
            incomplete('options-value'); return null;
          }
          values[key] = value;
        }
        return values;
      };
      try {
        root = document.scrollingElement;
        if (!root) incomplete('no-root');
        else {
          own = Object.getOwnPropertyDescriptor(root, 'scrollTo');
          let cursor = root, descriptor;
          while (cursor && !descriptor) { descriptor = Object.getOwnPropertyDescriptor(cursor, 'scrollTo');
            cursor = Object.getPrototypeOf(cursor); }
          if (!descriptor || !('value' in descriptor) || typeof descriptor.value !== 'function' ||
              (own ? !own.configurable && !own.writable : !Object.isExtensible(root))) incomplete('method-unavailable');
          else {
            original = descriptor.value;
            const observed = function(...args) {
              let call;
              try {
                if (report.calls.length < 16) {
                  call = {index: report.calls.length, receiverMatches: this === root,
                    parameters: parameters(args), before: snapshot(), terminal: 'entered'};
                  report.calls.push(call);
                  if (this !== root) incomplete('receiver-changed');
                } else incomplete('call-capacity');
              } catch (_) { incomplete('observation-error'); }
              try {
                const value = Reflect.apply(original, this, args);
                if (call) call.terminal = 'returned';
                return value;
              } catch (error) {
                if (call) call.terminal = 'threw';
                throw error;
              } finally {
                if (call) call.after = snapshot();
              }
            };
            Object.defineProperty(root, 'scrollTo', own ? {...own, value: observed} :
              {value: observed, configurable: true, writable: true, enumerable: false});
            installed = true;
          }
        }
      } catch (_) { incomplete('installation-error'); }
      let value;
      try { value = invoke(); }
      finally {
        try {
          if (installed) {
            if (own) Object.defineProperty(root, 'scrollTo', own);
            else if (!delete root.scrollTo) throw new Error('restore');
            const current = Object.getOwnPropertyDescriptor(root, 'scrollTo');
            report.restored = own ? !!current && current.value === own.value &&
              current.writable === own.writable && current.enumerable === own.enumerable &&
              current.configurable === own.configurable : current === undefined;
            if (!report.restored) incomplete('restore-mismatch');
          } else incomplete('not-installed');
          if (document.scrollingElement !== root) incomplete('root-changed');
        } catch (_) { incomplete('restore-error'); }
      }
      if (report.calls.length === 0) incomplete('no-call');
      report.resultKind = value === undefined ? 'undefined' : value === null ? 'null' : typeof value;
      // Unknown objects/thenables retain WK's original handling. Do not inspect
      // .then or await them, and do not invent a serializable business value.
      if (!['undefined', 'null', 'boolean', 'number', 'string'].includes(report.resultKind) ||
          typeof value === 'number' && !Number.isFinite(value)) return value;
      if (value !== undefined) report.value = value;
      return report;
    })
    """#

    func cancelEvaluation(_ id: UUID) {
        guard active else {
            recordLateEvaluation(id, phase: "cancelled-before-submit", succeeded: false)
            return
        }
        var fields = evaluations[id] ?? [:]
        fields["taskCancelled"] = String(Task.isCancelled)
        record("evaluation-cancelled-before-submit", id: id, fields: fields)
        evaluations.removeValue(forKey: id)
    }

    func finishEvaluation(_ id: UUID, error: Error?) {
        guard active else {
            recordLateEvaluation(id, phase: "callback", succeeded: error == nil)
            return
        }
        var fields = evaluations[id] ?? [:]
        fields["succeeded"] = String(error == nil)
        if let error { fields["errorCode"] = String((error as NSError).code) }
        record("evaluation-callback", id: id, fields: fields)
        evaluations.removeValue(forKey: id)
    }

    private func recordLateEvaluation(_ id: UUID, phase: String, succeeded: Bool) {
        guard !recordedLateCallback else { return }
        recordedLateCallback = true
        emit("evaluation-late-" + phase, id: id, fields: ["uptime": String(ProcessInfo.processInfo.systemUptime),
            "nativeAvailable": "false", "closed": "true", "succeeded": String(succeeded)])
    }

    private func emit(_ phase: String, id: UUID, fields: [String: String]) {
        var values = fields
        values["coverageID"] = coverageID.uuidString; values["coverageActive"] = String(active)
        values["currentWriterID"] = writers.last?.id.uuidString ?? "none"
        values["currentWriterSource"] = writers.last?.source ?? "none"
        values["recentWriterID"] = recentWriter?.uuidString ?? "none"
        values["recentEvaluationID"] = recentEvaluation?.uuidString ?? "none"
        sink(id, "sample-read-inner-" + phase, values)
    }

    private func nativeValues() -> [String: String] {
        var values = ["uptime": String(ProcessInfo.processInfo.systemUptime), "nativeAvailable": "false"]
        guard let view else { return values }
        let scroll = view.webView.scrollView
        values["nativeAvailable"] = "true"
        let numbers: [String: CGFloat] = ["innerY": scroll.contentOffset.y, "innerX": scroll.contentOffset.x,
            "frameY": view.frame.minY, "webFrameY": view.webView.frame.minY, "boundsY": scroll.bounds.minY,
            "width": scroll.bounds.width, "height": scroll.bounds.height,
            "contentWidth": scroll.contentSize.width, "contentHeight": scroll.contentSize.height,
            "insetTop": scroll.contentInset.top, "insetBottom": scroll.contentInset.bottom,
            "adjustedInsetTop": scroll.adjustedContentInset.top, "adjustedInsetBottom": scroll.adjustedContentInset.bottom,
            "zoom": scroll.zoomScale]
        for (key, value) in numbers { values[key] = String(describing: value) }
        values["attached"] = String(view.window != nil); values["dragging"] = String(scroll.isDragging)
        values["decelerating"] = String(scroll.isDecelerating); values["tracking"] = String(scroll.isTracking)
        values["scrollEnabled"] = String(scroll.isScrollEnabled)
        values["layerHasAnimations"] = String(!(scroll.layer.animationKeys() ?? []).isEmpty)
        return values
    }
}

extension EPUBSpreadView {
    var innerScrollDiagnostics: EPUBInnerScrollDiagnostics? {
        get { innerScrollDiagnosticStorage as? EPUBInnerScrollDiagnostics }
        set { innerScrollDiagnosticStorage = newValue }
    }

    func configureInnerScrollDiagnostics(_ sink: EPUBInnerScrollDiagnostics.Sink?, reason: String) {
        let previous = innerScrollDiagnostics
        innerScrollDiagnostics = nil
        previous?.close(reason)
        guard !wasCleared, let sink else { return }
        let diagnostic = EPUBInnerScrollDiagnostics(view: self, sink: sink)
        innerScrollDiagnostics = diagnostic
        diagnostic.start(navigationFinished: navigationFinished, initializationStarted: initializationStarted,
                         initializationFinished: initializationFinished)
    }

    private func viewportReadNativeValues() -> [String: Double] {
        ["uptime": ProcessInfo.processInfo.systemUptime, "nativeAvailable": 1,
         "innerY": Double(webView.scrollView.contentOffset.y),
         "viewMinY": Double(frame.minY), "width": Double(webView.bounds.width),
         "height": Double(webView.bounds.height), "attached": window == nil ? 0 : 1,
         "cleared": wasCleared ? 1 : 0]
    }
}
#endif

// MARK: - WKScriptMessageHandler for handling incoming message from the javascript layer.

extension EPUBSpreadView: WKScriptMessageHandler {
    /// Handles incoming calls from JS.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let handler = JSMessages[message.name] else {
            return
        }
        handler(message.body)
    }
}

extension EPUBSpreadView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        recordLoadingStage("navigation.started")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        recordLoadingStage("navigation.committed")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        recordLoadingStage("navigation.provisional-error.\((error as NSError).code)")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        recordLoadingStage("navigation.error.\((error as NSError).code)")
        log(.error, error)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setNeedsStopActivityIndicator()
        navigationFinished = true
        recordLoadingStage("navigation.finished")
        bootstrapInitialization()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var policy: WKNavigationActionPolicy = .allow

        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                // Check if url is internal or external
                if let relativeURL = viewModel.publicationBaseURL.relativize(url) {
                    delegate?.spreadView(self, didTapOnInternalLink: relativeURL.string, clickEvent: lastClick)
                } else {
                    delegate?.spreadView(self, didTapOnExternalURL: url)
                }

                policy = .cancel
            }
        }

        decisionHandler(policy)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        recordLoadingStage("process.terminated")
        guard !wasCleared else { return }
        delegate?.spreadViewDidTerminate()
    }
}

extension EPUBSpreadView: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        webView.clearSelection()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        #if DEBUG
            if scrollView === webView.scrollView { innerScrollDiagnostics?.record("offset") }
        #endif
        // Do not remove, overridden in subclasses.
    }
}

extension EPUBSpreadView: WKUIDelegate {}

extension EPUBSpreadView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Prevents the tap event from being triggered by the fallback tap
        // gesture recognizer when it is also recognized by the web view.
        true
    }
}

private extension EPUBSpreadView {
    func updateActivityIndicator() {
        switch viewModel.theme {
        case .dark:
            createActivityIndicator(color: .white)
        default:
            createActivityIndicator(color: .systemGray)
        }
    }

    func createActivityIndicator(color: UIColor) {
        guard activityIndicatorView?.color != color else {
            return
        }

        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = addCenteredActivityIndicator(color: color)
    }

    private func setNeedsStopActivityIndicator() {
        guard activityIndicatorStopWorkItem == nil else {
            return
        }

        activityIndicatorStopWorkItem = DispatchWorkItem { [weak self] in
            defer {
                self?.activityIndicatorStopWorkItem = nil
            }

            guard
                let self = self,
                let workItem = activityIndicatorStopWorkItem,
                !workItem.isCancelled
            else {
                return
            }

            trace("stopping activity indicator because spread \(spread.first.link.href) did not load")
            activityIndicatorView?.stopAnimating()
        }

        // If the spread doesn't begin loading within 2 seconds it means that we
        // likely encountered an error. In that case the work item we
        // schedule below will stop the activity indicator.
        // If the spread begins to load it will send a `spreadLoadStart` JS
        // event which will cancel the work item being scheduled here.
        trace("scheduling activity indicator stop")
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2,
            execute: activityIndicatorStopWorkItem!
        )
    }
}

/// Produced by gestures.js
struct ClickEvent {
    let defaultPrevented: Bool
    let point: CGPoint
    let targetElement: String
    let interactiveElement: String?

    init(dict: [String: Any]) {
        defaultPrevented = dict["defaultPrevented"] as? Bool ?? false
        point = CGPoint(x: dict["x"] as? Double ?? 0, y: dict["y"] as? Double ?? 0)
        targetElement = dict["targetElement"] as? String ?? ""
        interactiveElement = dict["interactiveElement"] as? String
    }

    init?(json: Any?) {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        self.init(dict: dict)
    }
}

/// Produced by gestures.js
private extension PointerEvent {
    init?(json: [String: Any]) {
        guard
            let pointerId = json["pointerId"] as? Int,
            let pointerType = json["pointerType"] as? String,
            let phase = PointerEvent.Phase(json: json["phase"]),
            let x = json["x"] as? Double,
            let y = json["y"] as? Double
        else {
            return nil
        }

        let optionalPointer: Pointer? = switch pointerType {
        case "mouse":
            .mouse(MousePointer(id: pointerId, buttons: MouseButtons(json: json)))
        case "touch":
            .touch(TouchPointer(id: pointerId))
        default:
            nil
        }

        guard let pointer = optionalPointer else {
            return nil
        }

        self.init(
            pointer: pointer,
            phase: phase,
            location: CGPoint(x: x, y: y),
            modifiers: KeyModifiers(json: json)
        )
        // FIXME:
//        interactiveElement = dict["interactiveElement"] as? String
    }
}

private extension MouseButtons {
    init(json: [String: Any]) {
        self.init()

        guard let buttons = json["buttons"] as? Int else {
            return
        }

        self = MouseButtons(rawValue: buttons)
    }
}

private extension PointerEvent.Phase {
    init?(json: Any?) {
        guard let json = json as? String else {
            return nil
        }

        switch json {
        case "down": self = .down
        case "cancel": self = .cancel
        case "move": self = .move
        case "up": self = .up
        default: return nil
        }
    }
}

private extension KeyModifiers {
    init(json: [String: Any]) {
        self.init()

        if (json["control"] as? Bool) ?? false {
            insert(.control)
        }
        if (json["command"] as? Bool) ?? false {
            insert(.command)
        }
        if (json["shift"] as? Bool) ?? false {
            insert(.shift)
        }
        if (json["option"] as? Bool) ?? false {
            insert(.option)
        }
    }
}

private extension KeyEvent {
    /// Parses the dictionary created in keyboard.js
    init?(dict: [String: Any]) {
        guard
            let phase = Phase(json: dict["phase"]),
            let code = dict["code"] as? String
        else {
            return nil
        }

        let key: Key
        switch code {
        case "Enter":
            key = .enter
        case "Tab":
            key = .tab
        case "Space":
            key = .space
        case "ArrowDown":
            key = .arrowDown
        case "ArrowLeft":
            key = .arrowLeft
        case "ArrowRight":
            key = .arrowRight
        case "ArrowUp":
            key = .arrowUp
        case "End":
            key = .end
        case "Home":
            key = .home
        case "PageDown":
            key = .pageDown
        case "PageUp":
            key = .pageUp
        case "MetaLeft", "MetaRight":
            key = .command
        case "ControlLeft", "ControlRight":
            key = .control
        case "AltLeft", "AltRight":
            key = .option
        case "ShiftLeft", "ShiftRight":
            key = .shift
        case "Backspace":
            key = .backspace
        case "Escape":
            key = .escape
        default:
            guard let char = dict["key"] as? String else {
                return nil
            }
            key = .character(char.lowercased())
        }

        var modifiers = KeyModifiers(json: dict)
        if let modifier = KeyModifiers(key: key) {
            modifiers.remove(modifier)
        }

        self.init(phase: phase, key: key, modifiers: modifiers)
    }
}

private extension KeyEvent.Phase {
    init?(json: Any?) {
        guard let json = json as? String else {
            return nil
        }

        switch json {
        case "up": self = .up
        case "down": self = .down
        default: return nil
        }
    }
}
