// XianxiaReader extension of Readium 3.11 (BSD-3-Clause).
// Navigator integration follows Eugene Martinson's PR811; this bounded,
// fixed-viewport implementation replaces its whole-book placeholders.
import ReadiumShared
import UIKit

@MainActor protocol EPUBInfiniteScrollViewDelegate: AnyObject {
    func infiniteScrollView(_ view: EPUBInfiniteScrollView, spreadViewAtIndex index: Int) -> EPUBSpreadView?
    func infiniteScrollViewDidUpdateViews(_ view: EPUBInfiniteScrollView)
}

/// Sampling lifetime only. A resize preserves the cached anchor needed by measure().
private struct EPUBSamplingLayout {
    private var size = CGSize.zero
    private(set) var generation = UUID()

    mutating func update(_ size: CGSize) {
        guard self.size != size else { return }
        self.size = size
        generation = UUID()
    }

    func matches(_ generation: UUID, size: CGSize, currentSize: CGSize) -> Bool {
        self.generation == generation && size == currentSize
    }
}

#if DEBUG
private let epubViewportReadDiagnosticsEnabled = ["paired-safe", "paired-conflict"].contains(
    ProcessInfo.processInfo.environment["XIANXIA_VIEWPORT_FIXTURE"] ?? "")

@MainActor private final class EPUBInnerDiagnosticBuffer {
    var events: [EPUBViewportFixtureEvent] = []
    var dropped = 0
    var live = false

    /// False means this lifetime is already live; deliver through its captured sink.
    func store(_ event: EPUBViewportFixtureEvent) -> Bool {
        guard !live else { return false }
        if events.count == 255 { events.removeFirst(); dropped += 1 }
        events.append(event)
        return true
    }

    func take() -> (events: [EPUBViewportFixtureEvent], dropped: Int)? {
        guard !live else { return nil }
        live = true
        let batch = events; events.removeAll()
        return (batch, dropped)
    }
}

/// Instance-only test bridge. Values contain geometry/identities, never book text.
public struct EPUBViewportFixtureEvent: Sendable {
    @TaskLocal public static var source = "native"
    public let requestID: UUID
    public let kind: String
    public let values: [String: String]
    public init(requestID: UUID, kind: String, values: [String: String]) {
        self.requestID = requestID; self.kind = kind; self.values = values
    }
}

@MainActor public protocol EPUBViewportFixtureControl: AnyObject {
    func observe(_ event: EPUBViewportFixtureEvent)
    func pause(_ event: EPUBViewportFixtureEvent) async -> Bool
    func invalidate(_ reason: String)
}
#endif

@MainActor final class EPUBInfiniteScrollView: UIScrollView, UIScrollViewDelegate, Loggable {
    @MainActor private final class Slot {
        let view: EPUBSpreadView
        let wrapper = UIView()
        var height: CGFloat = 0
        var ready = false
        var positioning = false
        var failure: String?
        var anchorDocumentY: CGFloat?
        var anchorRevision: UInt64?
        var anchorViewportTop: CGFloat?
        var savedAnchor: Locator?
        var anchorDiagnostic = "not sampled"
        var loadTask: Task<Void, Never>?
        var timeoutTask: Task<Void, Never>?
        var timeoutLifecycle = "not timed out"
        init(_ view: EPUBSpreadView) {
            self.view = view
            wrapper.clipsToBounds = true
            wrapper.addSubview(view)
        }
    }
    weak var infiniteDelegate: EPUBInfiniteScrollViewDelegate?
    private(set) var chapterCount = 0
    private(set) var currentIndex = 0
    private var slots: [Int: Slot] = [:]
    private var epoch = UUID()
    private var layingOut = false
    private var navigation = false
    private var lastSize = CGSize.zero
    private var samplingLayout = EPUBSamplingLayout()
    private var viewportRevision: UInt64 = 0
    // Release has no installer or controller type, only unused nil opaque storage.
    private var viewportFixtureStorage: AnyObject?
    // Nil in Release; the installer and all mutations live in DEBUG code.
    private var fixtureReadRequests: [UUID: [String: String]]?
    // Nil opaque storage in Release; all access/installers are DEBUG-only.
    private var fixtureInnerDiagnosticStorage: AnyObject?
    // Debug evidence only: no extra await, scheduling or restoration decisions.
    private var reflowTrace: [String] = []
    private func recordReflow(_ message: @autoclosure () -> String) {
        guard epubLoadingDiagnosticsEnabled else { return }
        if reflowTrace.count == 64 { reflowTrace.removeFirst() }
        reflowTrace.append("\(ProcessInfo.processInfo.systemUptime) \(message())")
    }
    private var lastTrackedOffset: CGFloat = 0
    private var screenDragStart: CGFloat?
    private var screenTurnInFlight = false
    private var screenTurnCover: UIView?
    private var screenTurnCoverID: UUID?
    private var screenTurnCoverTask: Task<Void, Never>?
    var automaticScrolling = false
    var locationSamplingIdentity: String {
        automaticScrolling ? "\(epoch):\(currentIndex):\(lastSize)" : viewportIdentity
    }
    enum AutomaticStep { case moved, waiting, finished, interrupted, failed }
    func advanceAutomatically(by distance: CGFloat) -> AutomaticStep {
        guard window != nil, !screenPagingEnabled, !isDragging, !isDecelerating,
              !navigation, !screenTurnInFlight else { return .interrupted }
        guard distance.isFinite, distance > 0 else { return .waiting }
        guard isCurrentResourceReady, let last = readyIndices.last, let tail = slots[last] else {
            return slots[currentIndex]?.failure == nil ? .waiting : .failed
        }
        // Never scroll into loading placeholders or past the last ready resource.
        let limit = max(-contentInset.top, tail.wrapper.frame.maxY - viewportHeight - contentInset.top)
        if contentOffset.y >= limit - 0.01 {
            preload()
            if last + 1 == chapterCount { return .finished }
            return slots[last + 1]?.failure == nil ? .waiting : .failed
        }
        setContentOffset(CGPoint(x: 0, y: min(limit, contentOffset.y + distance)), animated: false)
        return .moved
    }
    var screenPagingEnabled = false {
        didSet {
            guard screenPagingEnabled != oldValue else { return }
            removeScreenTurnCover()
            screenDragStart = nil
            screenTurnInFlight = false
            setContentOffset(contentOffset, animated: false)
            decelerationRate = screenPagingEnabled ? .fast : .normal
            accessibilityValue = screenPagingEnabled ? "上下整屏" : "上下连续滚动"
        }
    }
    private let previousBoundary = UILabel()
    private let boundary = UIView()
    private let boundaryLabel = UILabel()
    private let retry = UIButton(type: .system)
    // At most 12 very short resources; typical long chapters use 3-5.
    static let maximumLoadedResourceCount = 12
    var loadedViews: [Int: EPUBSpreadView] { slots.mapValues { $0.view } }
    var currentView: EPUBSpreadView? { slots[currentIndex]?.view }
    var isCurrentResourceReady: Bool {
        guard let slot = slots[currentIndex] else { return false }
        return slot.ready && !slot.positioning && slot.failure == nil
    }
    var viewportIdentity: String { "\(epoch):\(currentIndex):\(viewportRevision)" }
    var diagnosticState: String {
        "index=\(currentIndex) revision=\(viewportRevision) top=\(viewportTop) navigation=\(navigation) screenCover=\(screenTurnCover != nil) "
            + slots.keys.sorted().map { index in
                guard let slot = slots[index] else { return "missing \(index)" }
                var state = "slot\(index){ready=\(slot.ready) positioning=\(slot.positioning) failure=\(slot.failure ?? "none") wrapper=\(slot.wrapper.frame) frame=\(slot.view.frame) savedTop=\(String(describing: slot.anchorViewportTop)) anchor=\(slot.anchorDiagnostic)}"
                if epubLoadingDiagnosticsEnabled {
                    state += " lifecycle={\(slot.view.loadingLifecycleDiagnostic)} beforeTimeoutClear={\(slot.timeoutLifecycle)}"
                }
                return state
            }.joined(separator: " ")
            + (epubLoadingDiagnosticsEnabled ? " reflowTrace={" + reflowTrace.joined(separator: "; ") + "}" : "")
    }
    private var viewportHeight: CGFloat { max(1, bounds.height - contentInset.top - contentInset.bottom) }
    private var samplingViewportSize: CGSize { CGSize(width: bounds.width, height: viewportHeight) }
    private var viewportTop: CGFloat { max(0, contentOffset.y + contentInset.top) }
    // Keep the last tenth of the viewport visible so a wrapped line is never
    // skipped at a screen boundary. This is not a new pagination/DOM engine.
    private var screenStep: CGFloat { max(1, viewportHeight * 0.9) }
    private var screenOffsetRange: ClosedRange<CGFloat> {
        -contentInset.top ... max(-contentInset.top, contentSize.height - bounds.height + contentInset.bottom)
    }

    func turnScreen(forward: Bool, animated: Bool) -> Bool {
        guard isCurrentResourceReady, !isDragging, !isDecelerating,
              !screenTurnInFlight, screenTurnCover == nil else { return false }
        let target = (contentOffset.y + (forward ? screenStep : -screenStep)).clamped(to: screenOffsetRange)
        guard abs(target - contentOffset.y) > 0.5 else { return false }
        screenTurnInFlight = animated && !UIAccessibility.isReduceMotionEnabled
        if !screenTurnInFlight { retainScreenTurnFrame() }
        setContentOffset(CGPoint(x: 0, y: target), animated: screenTurnInFlight)
        return true
    }
    private func retainScreenTurnFrame() {
        // Readium 3.11's PaginationView uses the same native snapshot technique
        // for WKWebView's nonanimated native-scroll flash (issue 737 / PR 763).
        // Retain one viewport only, outside the moving content; no bitmap cache
        // or per-frame work. Direct manipulation never enters this path.
        guard let parent = superview, window != nil,
              let cover = snapshotView(afterScreenUpdates: false) else {
            log(.warning, "Could not retain the reading frame for an instant screen turn; transition may flash")
            return
        }
        cover.frame = parent.convert(bounds, from: self)
        cover.isUserInteractionEnabled = false
        cover.accessibilityElementsHidden = true
        cover.accessibilityIdentifier = "readium.screen-turn-cover"
        parent.insertSubview(cover, aboveSubview: self)
        screenTurnCover = cover
        let request = UUID()
        screenTurnCoverID = request
        screenTurnCoverTask = Task { @MainActor [weak self] in
            do { try await Task.sleep(nanoseconds: 200_000_000) }
            catch is CancellationError { return }
            catch {
                guard let self, self.screenTurnCoverID == request else { return }
                self.log(.warning, "Screen turn frame retention failed: \(error)")
                self.removeScreenTurnCover()
                return
            }
            guard let self, self.screenTurnCoverID == request else { return }
            self.removeScreenTurnCover()
        }
    }
    private func removeScreenTurnCover() {
        screenTurnCoverID = nil
        screenTurnCoverTask?.cancel()
        screenTurnCoverTask = nil
        screenTurnCover?.removeFromSuperview()
        screenTurnCover = nil
    }
    private var readyIndices: [Int] {
        guard slots[currentIndex]?.ready == true else { return [] }
        var low = currentIndex, high = currentIndex
        while low > 0, slots[low - 1]?.ready == true { low -= 1 }
        while high + 1 < chapterCount, slots[high + 1]?.ready == true { high += 1 }
        return Array(low...high)
    }
    var visibleIndices: ClosedRange<Int> {
        let visible = readyIndices.filter {
            guard let frame = slots[$0]?.wrapper.frame else { return false }
            return frame.maxY > viewportTop && frame.minY < viewportTop + viewportHeight
        }
        return (visible.first ?? currentIndex)...(visible.last ?? currentIndex)
    }
    var progressionInCurrentChapter: Double { progression(in: currentIndex).lowerBound }
    func progression(in index: Int) -> ClosedRange<Double> {
        guard let slot = slots[index], slot.ready, slot.height > 0 else { return 0...0 }
        let start = min(max((viewportTop - slot.wrapper.frame.minY) / slot.height, 0), 1)
        let end = min(max((viewportTop + viewportHeight - slot.wrapper.frame.minY) / slot.height, start), 1)
        return Double(start)...Double(end)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        alwaysBounceVertical = true
        accessibilityIdentifier = "readium.continuous-scroll"
        accessibilityValue = "上下连续滚动"
        previousBoundary.text = "正在加载上一章…"
        previousBoundary.textAlignment = .center
        previousBoundary.font = .preferredFont(forTextStyle: .footnote)
        previousBoundary.isUserInteractionEnabled = true
        previousBoundary.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(retryPreviousBoundary)))
        addSubview(previousBoundary)
        boundaryLabel.textAlignment = .center
        boundaryLabel.numberOfLines = 2
        boundaryLabel.font = .preferredFont(forTextStyle: .footnote)
        retry.setTitle("重试加载", for: .normal)
        retry.accessibilityIdentifier = "readium.continuous-retry"
        retry.addTarget(self, action: #selector(retryBoundary), for: .touchUpInside)
        boundary.addSubview(boundaryLabel)
        boundary.addSubview(retry)
        addSubview(boundary)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("Use init(frame:)") }
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        contentInset = UIEdgeInsets(top: safeAreaInsets.top, left: 0, bottom: safeAreaInsets.bottom, right: 0)
        setNeedsLayout()
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil { clear() }
    }
    private func clear() {
        automaticScrolling = false
        removeScreenTurnCover()
        screenDragStart = nil
        screenTurnInFlight = false
        setContentOffset(contentOffset, animated: false)
        #if DEBUG
            for slot in slots.values { slot.view.configureInnerScrollDiagnostics(nil, reason: "viewport-clear") }
            fixtureDrainRetiringInnerDiagnostics(reason: "viewport-clear")
        #endif
        epoch = UUID()
        for index in Array(slots.keys) { evict(index) }
        #if DEBUG
            fixtureReadRequests = nil
            viewportFixtureControl?.invalidate("viewport-cleared")
            fixtureInnerDiagnosticStorage = nil
        #endif
    }
    func shutdown() {
        chapterCount = 0
        #if DEBUG
            fixtureRecordClearOrigin("shutdown")
        #endif
        clear()
        infiniteDelegate = nil
    }
    private func evict(_ index: Int) {
        guard let slot = slots.removeValue(forKey: index) else { return }
        #if DEBUG
            slot.view.configureInnerScrollDiagnostics(nil, reason: "slot-evicted")
        #endif
        slot.loadTask?.cancel()
        slot.timeoutTask?.cancel()
        slot.view.clear()
        slot.wrapper.removeFromSuperview()
        setNeedsLayout()
    }
    func reload(at index: Int, location: PageLocation, count: Int) {
        #if DEBUG
            fixtureRecordClearOrigin("reload")
        #endif
        clear()
        chapterCount = count
        guard count > 0 else { return }
        currentIndex = min(max(index, 0), count - 1)
        load(currentIndex, location: location)
    }
    func goToIndex(_ index: Int, location: PageLocation, options: NavigatorGoOptions) async -> Bool {
        guard 0..<chapterCount ~= index else { return false }
        removeScreenTurnCover()
        screenDragStart = nil
        screenTurnInFlight = false
        setContentOffset(contentOffset, animated: false)
        navigation = true
        defer { navigation = false }
        if slots[index]?.ready != true {
            clear()
            currentIndex = index
            load(index, location: .start)
        }
        let activeEpoch = epoch
        // Loading has a 20s watchdog that clears Readium's continuations.
        await slots[index]?.loadTask?.value
        guard epoch == activeEpoch, let slot = slots[index], slot.ready else { return false }
        currentIndex = index
        layoutSlots(preserveAnchor: false)
        slot.positioning = true
        defer { slot.positioning = false }
        slot.anchorRevision = nil
        slot.anchorViewportTop = nil
        await slot.view.go(to: location, animated: false)
        guard epoch == activeEpoch, slots[index] === slot else { return false }
        let local = await navigationOffset(in: slot, location: location)
        guard epoch == activeEpoch, slots[index] === slot else { return false }
        slot.positioning = false
        let y = slot.wrapper.frame.minY + local
        // A DOM go has already moved the inner document. Apply the outer
        // coordinate atomically, so no old animation can overwrite a reflow
        // correction. User drag/deceleration and one-screen turns are separate.
        setContentOffset(CGPoint(x: 0, y: y - contentInset.top), animated: false)
        preload()
        infiniteDelegate?.infiniteScrollViewDidUpdateViews(self)
        return true
    }
    private func load(_ index: Int, location: PageLocation = .start) {
        guard 0..<chapterCount ~= index, slots[index] == nil,
              slots.count < Self.maximumLoadedResourceCount,
              let view = infiniteDelegate?.infiniteScrollView(self, spreadViewAtIndex: index) else { return }
        let slot = Slot(view)
        slot.wrapper.accessibilityIdentifier = "readium.chapter.\(index)"
        slots[index] = slot
        #if DEBUG
            fixtureBindInnerDiagnostics(index, slot)
        #endif
        addSubview(slot.wrapper)
        view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: viewportHeight)
        view.webView.scrollView.isScrollEnabled = false
        view.webView.scrollView.contentInset = .zero
        let request = epoch
        view.registerJSMessage(named: "xianxiaBodyResized") { [weak self, weak slot] _ in
            guard let self, let slot, self.slots[index] === slot, slot.ready else { return }
            Task { @MainActor in await self.measure(index, slot: slot, request: request) }
        }
        slot.timeoutTask = Task { @MainActor [weak self, weak slot] in
            do { try await Task.sleep(nanoseconds: 20_000_000_000) }
            catch is CancellationError { return }
            catch { self?.boundaryLabel.text = error.localizedDescription; return }
            guard let self, let slot, self.epoch == request, self.slots[index] === slot, !slot.ready else { return }
            #if DEBUG
                self.fixtureRecordClearOrigin("timeout-fired", index: index, slot: slot)
            #endif
            if epubLoadingDiagnosticsEnabled { slot.timeoutLifecycle = slot.view.loadingLifecycleDiagnostic }
            slot.failure = "章节加载超时"
            slot.view.clear()
            self.layoutSlots(preserveAnchor: true)
        }
        slot.loadTask = Task { @MainActor [weak self, weak slot] in
            guard let self, let slot else { return }
            slot.positioning = true
            defer { slot.positioning = false }
            await slot.view.continuousInitializationReady()
            guard !Task.isCancelled, self.epoch == request, self.slots[index] === slot, slot.failure == nil else { return }
            await slot.view.go(to: location, animated: false)
            guard !Task.isCancelled, self.epoch == request, self.slots[index] === slot, slot.failure == nil else { return }
            await self.measure(index, slot: slot, request: request)
            guard self.epoch == request, self.slots[index] === slot, slot.ready else { return }
            slot.timeoutTask?.cancel()
            self.layoutSlots(preserveAnchor: true)
            if index == self.currentIndex, location != .start {
                let local = await self.navigationOffset(in: slot, location: location)
                guard self.epoch == request, self.slots[index] === slot else { return }
                let y = slot.wrapper.frame.minY + local
                slot.positioning = false
                self.contentOffset.y = y - self.contentInset.top
            }
            slot.positioning = false
            self.updateViewports(source: "load-ready")
            self.preload()
            self.infiniteDelegate?.infiniteScrollViewDidUpdateViews(self)
        }
        layoutSlots(preserveAnchor: true)
    }
    private func navigationOffset(in slot: Slot, location: PageLocation) async -> CGFloat {
        if location == .start { return 0 }
        if location == .end { return max(0, slot.height - 24 - viewportHeight) }
        if case let .locator(locator) = location, locator.locations.cssSelector != nil,
           locator.locations.otherLocations["xianxiaContinuousAnchorVersion"]?.double == 1 {
            do {
                let documentY = try await slot.view.continuousAnchorDocumentY(locator)
                if let y = documentY {
                    let offset = locator.locations.otherLocations["xianxiaViewportOffset"]?.double ?? 0
                    return max(0, y - CGFloat(offset))
                }
            } catch { boundaryLabel.text = "位置锚点恢复失败：\(error.localizedDescription)" }
        }
        // Keep Readium's text matching/fragment/progression behavior. Execute
        // the target and read its coordinate in ONE WebKit callback: between
        // two callbacks a late native viewport synchronization can otherwise
        // reset scrollY before the outer chapter window receives the target.
        let script: String
        if case let .locator(locator) = location {
            do {
                let json = try locator.jsonString()
                script = """
                ((locator) => {
                  let moved = true;
                  if (locator.text?.highlight != null) {
                    moved = readium.scrollToLocator(locator, false);
                  } else if (locator.locations?.fragments?.[0]) {
                    moved = readium.scrollToId(locator.locations.fragments[0], false);
                  } else {
                    readium.scrollToPosition(locator.locations?.progression ?? 0, 'ltr', false);
                  }
                  return moved ? window.scrollY : null;
                })(\(json))
                """
            } catch {
                boundaryLabel.text = "位置偏移编码失败：\(error.localizedDescription)"
                return slot.view.webView.scrollView.contentOffset.y
            }
        } else {
            script = "window.scrollY"
        }
        let result = await slot.view.evaluateScript(script)
        switch result {
        case let .success(value):
            if let y = value as? NSNumber, y.doubleValue.isFinite { return CGFloat(y.doubleValue) }
            boundaryLabel.text = "位置偏移无效"
        case let .failure(error):
            boundaryLabel.text = "位置偏移读取失败：\(error.localizedDescription)"
        }
        return slot.view.webView.scrollView.contentOffset.y
    }
    private func measure(_ index: Int, slot: Slot, request: UUID) async {
        #if DEBUG
            let fixture = viewportFixtureControl
            let fixtureID = fixture.map { _ in UUID() }
            var fixtureWorkCaptured = false
            if let id = fixtureID {
                fixture?.observe(.init(requestID: id, kind: "work-start", values: fixtureValues(index, slot)))
            }
            defer {
                if let id = fixtureID {
                    var values = fixtureValues(index, slot); values["captured"] = String(fixtureWorkCaptured)
                    fixture?.observe(.init(requestID: id, kind: "work-finished", values: values))
                }
            }
            if let fixture, let id = fixtureID {
                guard await fixture.pause(.init(requestID: id, kind: "measure-before-capture", values: fixtureValues(index, slot))),
                      !Task.isCancelled, epoch == request, slots[index] === slot else { return }
            }
            fixtureWorkCaptured = true
        #endif
        let anchorJSON: String
        let measuredRevision = viewportRevision
        let measuredAnchor = slot.savedAnchor
        let measuredLocalTop = viewportTop - slot.wrapper.frame.minY
        let measuredAnchorIsCurrent = savedAnchorMatchesViewport(slot, revision: measuredRevision)
        #if DEBUG
            let fixtureContext = fixture == nil ? [:] : fixtureValues(index, slot)
            var fixtureOutcome = "not-committed"
            if let id = fixtureID { fixture?.observe(.init(requestID: id, kind: "measure-start", values: fixtureContext)) }
            defer {
                if let id = fixtureID {
                    var values = fixtureValues(index, slot); values["outcome"] = fixtureOutcome
                    fixture?.observe(.init(requestID: id, kind: "measure-finished", values: values))
                }
            }
            let fixtureJS = fixture == nil ? "" : ",fixture:{width:innerWidth,height:innerHeight,scrollY}"
        #else
            let fixtureJS = ""
        #endif
        do {
            anchorJSON = try slot.savedAnchor?.jsonString() ?? "{}"
        } catch {
            slot.failure = error.localizedDescription
            layoutSlots(preserveAnchor: true)
            return
        }
        let script = """
        (() => {
          const body = document.body;
          if (!body) return null;
          if (!window.__xianxiaBodyObserver) {
            window.__xianxiaBodyObserver = new ResizeObserver(() => webkit.messageHandlers.xianxiaBodyResized.postMessage(1));
            window.__xianxiaBodyObserver.observe(body);
            for (const child of body.children) window.__xianxiaBodyObserver.observe(child);
          }
          const style = getComputedStyle(body);
          let bottom = Math.max(0, body.getBoundingClientRect().bottom + scrollY);
          for (const child of body.children) bottom = Math.max(bottom, child.getBoundingClientRect().bottom + scrollY);
          if (!body.children.length) {
            const range = document.createRange(); range.selectNodeContents(body);
            bottom = range.getBoundingClientRect().bottom + scrollY;
          }
          const anchor = (\(EPUBSpreadView.continuousAnchorRectFunction))(\(anchorJSON));
          return {height: Math.ceil(bottom + (parseFloat(style.marginBottom) || 0)),
                  anchorY: anchor ? anchor.top + scrollY : null\(fixtureJS)};
        })()
        """
        recordReflow("start index=\(index) revision=\(measuredRevision) local=\(measuredLocalTop) currentAnchor=\(measuredAnchorIsCurrent) anchor=\(anchorJSON)")
        let result = await slot.view.evaluateScript(script)
        #if DEBUG
            if let fixture, let id = fixtureID {
                var values = fixtureContext
                if case let .success(value) = result, let data = value as? [String: Any] {
                    for key in ["height", "anchorY"] {
                        if let number = data[key] as? NSNumber { values["result." + key] = number.stringValue }
                    }
                }
                if case let .success(value) = result, let data = value as? [String: Any],
                   let metadata = data["fixture"] as? [String: Any] {
                    for key in ["width", "height", "scrollY"] {
                        if let number = metadata[key] as? NSNumber { values["dom." + key] = number.stringValue }
                    }
                }
                guard await fixture.pause(.init(requestID: id, kind: "measure-before-commit", values: values)) else {
                    fixtureOutcome = "aborted"; return
                }
            }
        #endif
        guard epoch == request, slots[index] === slot else {
            recordReflow("discard index=\(index) revision=\(measuredRevision) staleEpochOrSlot")
            return
        }
        switch result {
        case let .success(value):
            guard let data = value as? [String: Any], let number = data["height"] as? NSNumber, number.doubleValue.isFinite else {
                slot.failure = "章节布局尺寸无效"; slot.ready = false
                slot.view.clear(); layoutSlots(preserveAnchor: true); return
            }
            let height = max(96, CGFloat(number.doubleValue) + 24)
            let changed = abs(slot.height - height) > 0.5
            let newAnchorY = (data["anchorY"] as? NSNumber).map { CGFloat($0.doubleValue) }
            let mayRestoreAnchor = index == currentIndex && !slot.positioning && measuredAnchor != nil && measuredAnchorIsCurrent
                && slot.savedAnchor == measuredAnchor && savedAnchorMatchesViewport(slot, revision: measuredRevision)
                && viewportRevision == measuredRevision
                && abs(viewportTop - slot.wrapper.frame.minY - measuredLocalTop) < 0.5
            #if DEBUG
                if let id = fixtureID {
                    var values = fixtureValues(index, slot)
                    values["ownerMatches"] = String(epoch == request && slots[index] === slot)
                    values["indexMatches"] = String(index == currentIndex)
                    values["anchorEqual"] = String(slot.savedAnchor == measuredAnchor)
                    values["anchorCurrentAtStart"] = String(measuredAnchorIsCurrent)
                    values["anchorCurrentNow"] = String(savedAnchorMatchesViewport(slot, revision: measuredRevision))
                    values["revisionMatches"] = String(viewportRevision == measuredRevision)
                    values["localMatches"] = String(abs(viewportTop - slot.wrapper.frame.minY - measuredLocalTop) < 0.5)
                    values["mayRestore"] = String(mayRestoreAnchor)
                    fixture?.observe(.init(requestID: id, kind: "measure-guard", values: values))
                    fixtureOutcome = "committed"
                }
            #endif
            let desiredLocal: CGFloat? = mayRestoreAnchor ? newAnchorY.map { y in
                y - CGFloat(measuredAnchor?.locations.otherLocations["xianxiaViewportOffset"]?.double ?? 0)
            } : nil
            recordReflow("complete index=\(index) revision=\(measuredRevision)->\(viewportRevision) current=\(index == currentIndex) positioning=\(slot.positioning) anchorCurrentAtStart=\(measuredAnchorIsCurrent) anchorEqual=\(slot.savedAnchor == measuredAnchor) anchorCurrentNow=\(savedAnchorMatchesViewport(slot, revision: measuredRevision)) local=\(measuredLocalTop)->\(viewportTop - slot.wrapper.frame.minY) anchorY=\(String(describing: newAnchorY)) desiredLocal=\(String(describing: desiredLocal)) mayRestore=\(mayRestoreAnchor) heightChanged=\(changed)")
            if let newAnchorY, mayRestoreAnchor { slot.anchorDocumentY = newAnchorY }
            slot.height = height
            slot.ready = true
            if changed {
                layoutSlots(preserveAnchor: true)
            }
            if let desiredLocal, let currentSlot = slots[currentIndex] {
                let desired = currentSlot.wrapper.frame.minY + desiredLocal - contentInset.top
                recordReflow("apply index=\(index) outer=\(contentOffset.y) desired=\(desired) wrapper=\(currentSlot.wrapper.frame.minY)")
                if abs(contentOffset.y - desired) > 0.5 {
                    screenTurnInFlight = false
                    contentOffset.y = desired
                }
            }
        case let .failure(error):
            slot.failure = "章节布局失败：\(error.localizedDescription)"
            slot.ready = false
            slot.view.clear()
            layoutSlots(preserveAnchor: true)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // Track every observed size transition, including reentrant layout and A→B→A.
        // This does not invalidate the scroll revision or M's saved anchor.
        samplingLayout.update(samplingViewportSize)
        guard !layingOut else { return }
        if lastSize != bounds.size {
            automaticScrolling = false
            removeScreenTurnCover()
            screenDragStart = nil
            if screenTurnInFlight {
                screenTurnInFlight = false
                setContentOffset(contentOffset, animated: false)
            }
            lastSize = bounds.size
            recordReflow("resize size=\(lastSize) revision=\(viewportRevision) outer=\(contentOffset.y) local=\(viewportTop - (slots[currentIndex]?.wrapper.frame.minY ?? 0))")
            for (index, slot) in slots {
                slot.view.frame.size = CGSize(width: bounds.width, height: viewportHeight)
                if slot.ready { Task { @MainActor in await self.measure(index, slot: slot, request: self.epoch) } }
            }
        }
        layoutSlots(preserveAnchor: true)
    }
    private func layoutSlots(preserveAnchor: Bool) {
        guard !layingOut else { return }
        layingOut = true
        defer { layingOut = false }
        let oldOrigin = slots[currentIndex]?.wrapper.frame.minY ?? 0
        let local = viewportTop - oldOrigin
        let indices = readyIndices
        var y: CGFloat = (indices.first ?? currentIndex) > 0 ? 64 : 0
        previousBoundary.isHidden = y == 0
        previousBoundary.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 64)
        previousBoundary.text = slots[(indices.first ?? currentIndex) - 1]?.failure ?? "正在加载上一章…"
        for index in slots.keys.sorted() {
            guard let slot = slots[index] else { continue }
            slot.wrapper.isHidden = slot.failure != nil
            guard indices.contains(index) else {
                // WKWebView needs a real, non-hidden viewport to run Readium's
                // load/requestAnimationFrame handshake. Unready neighbours
                // stay outside the finite content range, never as blank pages.
                let pendingY: CGFloat = index == currentIndex && indices.isEmpty ? 0 : contentSize.height + viewportHeight
                slot.wrapper.frame = CGRect(x: 0, y: pendingY, width: bounds.width, height: viewportHeight)
                continue
            }
            slot.wrapper.frame = CGRect(x: 0, y: y, width: bounds.width, height: slot.height)
            y += slot.height
        }
        let last = indices.last ?? currentIndex
        let hasNext = last + 1 < chapterCount
        boundary.isHidden = !hasNext && !indices.isEmpty
        boundary.frame = CGRect(x: 0, y: y, width: bounds.width, height: 64)
        boundaryLabel.frame = CGRect(x: 8, y: 0, width: max(0, bounds.width - 16), height: 30)
        retry.frame = CGRect(x: 0, y: 30, width: bounds.width, height: 30)
        let failure = slots[indices.isEmpty ? currentIndex : last + 1]?.failure
        boundaryLabel.text = failure ?? "正在加载下一章…"
        retry.isHidden = failure == nil
        if hasNext || indices.isEmpty { y += 64 }
        contentSize = CGSize(width: bounds.width, height: max(viewportHeight, y))
        if preserveAnchor, let origin = slots[currentIndex]?.wrapper.frame.minY, !indices.isEmpty {
            let desired = origin + local - contentInset.top
            if abs(contentOffset.y - desired) > 0.5 {
                // Earlier resources can finish loading during the same pan.
                // Move the gesture origin with that layout compensation.
                if let start = screenDragStart { screenDragStart = start + desired - contentOffset.y }
                screenTurnInFlight = false
                contentOffset.y = desired
                lastTrackedOffset = contentOffset.y
            }
        } else if indices.isEmpty {
            // The current DOM was released or failed. Keep its loading/retry
            // controls on screen instead of retaining a now-invalid offset.
            contentOffset.y = -contentInset.top
            lastTrackedOffset = contentOffset.y
        }
        updateViewports(source: "layout-slots")
        bringSubviewToFront(previousBoundary)
        bringSubviewToFront(boundary)
    }
    private func updateViewports(source: String) {
        for index in readyIndices {
            guard let slot = slots[index], !slot.positioning else { continue }
            let local = min(max(viewportTop - slot.wrapper.frame.minY, 0), max(slot.height - 24 - viewportHeight, 0))
            #if DEBUG
                let innerDiagnostic = slot.view.innerScrollDiagnostics
                let innerWriterID = innerDiagnostic?.beginWrite("viewport-" + source, target: local)
                defer { if let innerWriterID { innerDiagnostic?.endWrite(innerWriterID) } }
                let fixtureBefore: (uptime: Double, innerY: CGFloat, frameY: CGFloat)? = readDiagnosticsFixture == nil ? nil : (
                    ProcessInfo.processInfo.systemUptime, slot.view.webView.scrollView.contentOffset.y, slot.view.frame.minY)
                var fixtureWrote = false
            #endif
            slot.view.frame = CGRect(x: 0, y: local, width: bounds.width, height: viewportHeight)
            #if DEBUG
                innerDiagnostic?.record("viewport-frame-applied", id: innerWriterID)
                let fixtureBeforeAssignment = fixtureBefore.map { _ in slot.view.webView.scrollView.contentOffset.y }
            #endif
            if abs(slot.view.webView.scrollView.contentOffset.y - local) > 0.5 {
                #if DEBUG
                    fixtureWrote = true
                #endif
                slot.view.webView.scrollView.contentOffset.y = local
            }
            #if DEBUG
                if let before = fixtureBefore, let beforeAssignment = fixtureBeforeAssignment {
                    fixtureViewportWrite(index, slot, source: source, target: local, before: before,
                                         beforeAssignment: beforeAssignment, wrote: fixtureWrote)
                }
            #endif
        }
    }
    private func preload() {
        let visible = visibleIndices
        for index in Array(slots.keys) where index < visible.lowerBound - 3 || index > visible.upperBound + 3 { evict(index) }
        let indices = readyIndices
        guard !indices.isEmpty else { return }
        if let first = indices.first, first > max(0, visible.lowerBound - 3), slots[first - 1] == nil { load(first - 1) }
        if let last = indices.last, last + 1 < chapterCount, last + 1 <= visible.upperBound + 3, slots[last + 1] == nil,
           (slots[last]?.wrapper.frame.maxY ?? 0) - viewportTop < viewportHeight * 2.5 { load(last + 1) }
    }
    @objc private func retryPreviousBoundary() {
        let index = (readyIndices.first ?? currentIndex) - 1
        guard index >= 0 else { return }
        evict(index); load(index)
    }
    @objc private func retryBoundary() {
        let index = readyIndices.last.map { $0 + 1 } ?? currentIndex
        let location = slots[index]?.savedAnchor.map { PageLocation.locator($0) } ?? .start
        evict(index); load(index, location: location)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !layingOut else { return }
        if abs(contentOffset.y - lastTrackedOffset) > 0.5 {
            viewportRevision &+= 1
            lastTrackedOffset = contentOffset.y
        }
        updateViewports(source: "scroll-delegate")
        if !navigation, let focused = readyIndices.first(where: { (slots[$0]?.wrapper.frame.maxY ?? 0) > viewportTop }) {
            currentIndex = focused
        }
        preload()
        infiniteDelegate?.infiniteScrollViewDidUpdateViews(self)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeScreenTurnCover()
        screenTurnInFlight = false
        screenDragStart = screenPagingEnabled ? contentOffset.y : nil
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                  targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard screenPagingEnabled, let start = screenDragStart else { return }
        let distance = contentOffset.y - start
        let relative = distance / screenStep
        var screens: CGFloat = 0
        // Pick the adjacent stop from the RELEASE viewport. Reversing a
        // long drag must not jump several screens behind its original start.
        if velocity.y > 0.3 { screens = relative.rounded(.down) + 1 }
        else if velocity.y < -0.3 { screens = relative.rounded(.up) - 1 }
        else if abs(distance) > min(72, screenStep * 0.12) {
            screens = relative.rounded()
            if screens == 0 { screens = distance > 0 ? 1 : -1 }
        }
        targetContentOffset.pointee.y = (start + screens * screenStep).clamped(to: screenOffsetRange)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        screenDragStart = nil
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        screenTurnInFlight = false
    }
    private func savedAnchorMatchesViewport(_ slot: Slot, revision: UInt64) -> Bool {
        guard slot.anchorRevision == revision, let savedTop = slot.anchorViewportTop else { return false }
        // UIKit can lay out the content before delivering its scroll delegate
        // callback. The physical document slice is authoritative even when the
        // callback-based revision has not changed yet.
        return abs(viewportTop - slot.wrapper.frame.minY - savedTop) < 0.5
    }
    func firstVisibleElementLocator() async -> Locator? {
        #if DEBUG
            // These existing test-owned entries occur after armSample. Native
            // pre-arm sampling must not consume the buffered coverage receipts.
            if ["test-auxiliary", "original-capture"].contains(EPUBViewportFixtureEvent.source) {
                fixtureFlushInnerDiagnostics()
            }
        #endif
        #if DEBUG
            let fixture = viewportFixtureControl
            let fixtureID = fixture.map { _ in UUID() }
            let fixtureEntryEpoch = epoch
            let fixtureEntryIndex = currentIndex
            let fixtureEntrySlot = slots[currentIndex]
            var fixtureWorkCaptured = false
            if let id = fixtureID, let slot = fixtureEntrySlot {
                fixture?.observe(.init(requestID: id, kind: "work-start", values: fixtureValues(fixtureEntryIndex, slot)))
            }
            defer {
                if let id = fixtureID, let slot = fixtureEntrySlot {
                    var values = fixtureValues(fixtureEntryIndex, slot); values["captured"] = String(fixtureWorkCaptured)
                    fixture?.observe(.init(requestID: id, kind: "work-finished", values: values))
                }
            }
            if let fixture, let id = fixtureID, let slot = fixtureEntrySlot {
                guard await fixture.pause(.init(requestID: id, kind: "sample-before-capture", values: fixtureValues(fixtureEntryIndex, slot))),
                      !Task.isCancelled, epoch == fixtureEntryEpoch, currentIndex == fixtureEntryIndex,
                      slots[fixtureEntryIndex] === slot else { return nil }
            }
        #endif
        guard let slot = slots[currentIndex], slot.ready, !slot.positioning else { return nil }
        #if DEBUG
            fixtureWorkCaptured = true
        #endif
        let clipTop = max(0, viewportTop - slot.wrapper.frame.minY - slot.view.frame.minY)
        let clipBottom = min(viewportHeight, slot.height - slot.view.frame.minY)
        let request = epoch
        let index = currentIndex
        let revision = viewportRevision
        let layoutGeneration = samplingLayout.generation
        let layoutSize = samplingViewportSize
        let localTop = viewportTop - slot.wrapper.frame.minY
        let moving = automaticScrolling
        slot.anchorDiagnostic = "requested local=\(localTop) clip=\(clipTop)...\(clipBottom) revision=\(revision)"
        #if DEBUG
            var fixtureInputs = fixture == nil ? [:] : fixtureValues(index, slot)
            if fixture != nil {
                // Frozen inputs to this request, before the S suspension.
                fixtureInputs["clipTop"] = String(describing: clipTop)
                fixtureInputs["clipBottom"] = String(describing: clipBottom)
                fixtureInputs["viewMinYAtStart"] = String(describing: slot.view.frame.minY)
                fixtureInputs["wrapperMinYAtStart"] = String(describing: slot.wrapper.frame.minY)
                fixtureInputs["viewportTopAtStart"] = String(describing: viewportTop)
                fixtureInputs["layoutGeneration"] = layoutGeneration.uuidString
                fixtureInputs["layoutWidth"] = String(describing: layoutSize.width)
                fixtureInputs["layoutHeight"] = String(describing: layoutSize.height)
            }
            let fixtureContext = fixtureInputs
            if readDiagnosticsFixture != nil, let id = fixtureID {
                if fixtureReadRequests == nil { fixtureReadRequests = [:] }
                fixtureReadRequests?[id] = fixtureContext
            }
            defer { if let id = fixtureID { fixtureReadRequests?.removeValue(forKey: id) } }
            var fixtureOutcome = "rejected"
            var fixtureReason = "not-finished"
            if let id = fixtureID { fixture?.observe(.init(requestID: id, kind: "sample-start", values: fixtureContext)) }
            defer {
                if let id = fixtureID {
                    var values = fixtureValues(index, slot); values["outcome"] = fixtureOutcome
                    values["reason"] = fixtureReason
                    values["clipTop"] = fixtureContext["clipTop"]
                    values["clipBottom"] = fixtureContext["clipBottom"]
                    fixture?.observe(.init(requestID: id, kind: "sample-finished", values: values))
                }
            }
        #endif
        // Keep the old DOM anchor across reflow until measure() compensates;
        // a resize notification is not a user scroll.
        if !moving, savedAnchorMatchesViewport(slot, revision: revision), let anchor = slot.savedAnchor {
            slot.anchorDiagnostic = "cached local=\(localTop) revision=\(revision)"
            #if DEBUG
                fixtureOutcome = "cached"
                fixtureReason = "cached"
            #endif
            return anchor
        }
        #if DEBUG
            if let fixture, let id = fixtureID {
                guard await fixture.pause(.init(requestID: id, kind: "sample-before-read", values: fixtureContext)) else {
                    fixtureOutcome = "aborted"; fixtureReason = "barrier-aborted"; return nil
                }
            }
        #endif
        // Native UIScrollView can publish its new offset before WebKit has
        // committed the same document viewport. Collect all DOM values in
        // one callback and retry only this mismatch, for at most 3 samples.
        for attempt in 0..<3 {
            #if DEBUG
                if let id = fixtureID { fixtureReadRequests?[id]?["attempt"] = String(attempt) }
                let readObserver: ((String, [String: Double]) -> Void)? = readDiagnosticsFixture == nil ? nil : fixtureID.map { id in
                    { [weak self, weak slot] phase, numbers in
                        var fields = fixtureContext; fields["attempt"] = String(attempt)
                        fields["observerUptime"] = String(ProcessInfo.processInfo.systemUptime)
                        for (key, number) in numbers { fields["read." + key] = String(number) }
                        if let self, let slot {
                            for (key, value) in self.fixtureValues(index, slot) { fields["live." + key] = value }
                            fields["live.innerY"] = String(describing: slot.view.webView.scrollView.contentOffset.y)
                            fields["live.slotCurrent"] = String(self.slots[index] === slot)
                        }
                        fixture?.observe(.init(requestID: id, kind: "sample-read-" + phase, values: fields))
                    }
                }
                let metadata: (([String: Double]) -> Void)? = fixtureID.map { id in
                    { values in
                        var fields = fixtureContext; fields["attempt"] = String(attempt)
                        for (key, number) in values { fields["dom." + key] = String(number) }
                        fixture?.observe(.init(requestID: id, kind: "sample-dom", values: fields))
                    }
                }
                let snapshot = await slot.view.continuousVisibleAnchorSnapshot(visibleTop: clipTop, visibleBottom: clipBottom,
                                                                               fixtureMetadata: metadata, fixtureReadObserver: readObserver)
                readObserver?("snapshot-returned", ["uptime": ProcessInfo.processInfo.systemUptime])
                var fixtureDecision: [String: String] = [:]
                if fixtureID != nil {
                    fixtureDecision = fixtureContext
                    fixtureDecision["attempt"] = String(attempt)
                    fixtureDecision["observationPoint"] = "after-snapshot-await"
                    fixtureDecision["recordingPoint"] = "iteration-exit"
                    // Observed immediately after the same await; the original
                    // short-circuit guard below still decides, including cancellation.
                    fixtureDecision["notCancelled"] = String(!Task.isCancelled)
                    fixtureDecision["epochMatches"] = String(epoch == request)
                    fixtureDecision["indexMatches"] = String(currentIndex == index)
                    fixtureDecision["slotMatches"] = String(slots[index] === slot)
                    fixtureDecision["movingMatches"] = String(automaticScrolling == moving)
                    fixtureDecision["notPositioning"] = String(!slot.positioning)
                    fixtureDecision["revisionMatches"] = String(viewportRevision == revision)
                    fixtureDecision["localMatches"] = String(abs(viewportTop - slot.wrapper.frame.minY - localTop) < 0.5)
                    fixtureDecision["viewportMatches"] = String(moving || (viewportRevision == revision
                        && abs(viewportTop - slot.wrapper.frame.minY - localTop) < 0.5))
                    fixtureDecision["snapshotAvailable"] = String(snapshot != nil)
                    fixtureDecision["layoutMatches"] = String(samplingLayout.matches(layoutGeneration, size: layoutSize, currentSize: samplingViewportSize))
                    fixtureDecision["currentLayoutGeneration"] = samplingLayout.generation.uuidString
                    fixtureDecision["currentLayoutWidth"] = String(describing: bounds.width)
                    fixtureDecision["currentLayoutHeight"] = String(describing: viewportHeight)
                    fixtureDecision["currentRevision"] = String(viewportRevision)
                    fixtureDecision["currentLocalTop"] = String(describing: viewportTop - slot.wrapper.frame.minY)
                    fixtureDecision["currentViewMinY"] = String(describing: slot.view.frame.minY)
                    if let snapshot {
                        fixtureDecision["documentTop"] = String(describing: snapshot.documentTop)
                        fixtureDecision["documentY"] = String(describing: snapshot.documentY)
                        fixtureDecision["expectedDocumentTop"] = String(describing: max(0, localTop))
                        fixtureDecision["documentTopDelta"] = String(describing: snapshot.documentTop - max(0, localTop))
                        fixtureDecision["documentTopMatches"] = String(abs(snapshot.documentTop - max(0, localTop)) < 1)
                    }
                }
                defer {
                    if let id = fixtureID {
                        fixtureDecision["reason"] = fixtureReason
                        fixture?.observe(.init(requestID: id, kind: "sample-decision", values: fixtureDecision))
                    }
                }
            #else
                let snapshot = await slot.view.continuousVisibleAnchorSnapshot(visibleTop: clipTop, visibleBottom: clipBottom)
            #endif
            guard !Task.isCancelled, epoch == request, currentIndex == index, slots[index] === slot,
                  automaticScrolling == moving, !slot.positioning,
                  moving || (viewportRevision == revision && abs(viewportTop - slot.wrapper.frame.minY - localTop) < 0.5) else {
                #if DEBUG
                    fixtureReason = "context-invalid"
                #endif
                return nil
            }
            guard samplingLayout.matches(layoutGeneration, size: layoutSize, currentSize: samplingViewportSize) else {
                #if DEBUG
                    fixtureReason = "layout-invalidated"
                #endif
                return nil
            }
            guard let snapshot else {
                #if DEBUG
                    fixtureReason = "snapshot-unavailable"
                #endif
                return nil
            }
            // One bounded WebKit callback returns a complete DOM range and its
            // viewport offset. It remains a valid saved point while moving;
            // never cache it against a later physical viewport revision.
            if moving {
                #if DEBUG
                    fixtureReason = "moving-snapshot-returned"
                #endif
                return snapshot.locator
            }
            slot.anchorDiagnostic = "sample=\(attempt) documentY=\(snapshot.documentY) documentTop=\(snapshot.documentTop) local=\(localTop) revision=\(revision)"
            if abs(snapshot.documentTop - max(0, localTop)) >= 1 {
                #if DEBUG
                    fixtureReason = attempt < 2 ? "document-top-mismatch-retry" : "document-top-mismatch-exhausted"
                #endif
                if attempt < 2 {
                    do { try await Task.sleep(nanoseconds: 32_000_000) }
                    catch is CancellationError {
                        #if DEBUG
                            fixtureReason = "retry-sleep-cancelled"
                        #endif
                        return nil
                    }
                    catch {
                        #if DEBUG
                            fixtureReason = "retry-sleep-error"
                        #endif
                        boundaryLabel.text = error.localizedDescription; return nil
                    }
                }
                continue
            }
            slot.anchorRevision = revision
            slot.anchorViewportTop = localTop
            slot.savedAnchor = snapshot.locator
            #if DEBUG
                fixtureOutcome = "committed"
                fixtureReason = "committed"
            #endif
            slot.anchorDocumentY = snapshot.documentY
            slot.anchorDiagnostic += " accepted"
            return snapshot.locator
        }
        return nil
    }
}

#if DEBUG
extension EPUBInfiniteScrollView {
    private var fixtureInnerState: EPUBInnerDiagnosticBuffer {
        if let state = fixtureInnerDiagnosticStorage as? EPUBInnerDiagnosticBuffer { return state }
        let state = EPUBInnerDiagnosticBuffer(); fixtureInnerDiagnosticStorage = state
        return state
    }

    private var readDiagnosticsFixture: (any EPUBViewportFixtureControl)? {
        epubViewportReadDiagnosticsEnabled ? viewportFixtureControl : nil
    }

    private func fixtureBindInnerDiagnostics(_ index: Int, _ slot: Slot) {
        guard let fixture = readDiagnosticsFixture else { return }
        let bindingEpoch = epoch
        let identity = ["reader": String(describing: ObjectIdentifier(self)), "epoch": bindingEpoch.uuidString,
            "slot": String(describing: ObjectIdentifier(slot)), "index": String(index),
            "webView": String(describing: ObjectIdentifier(slot.view.webView)), "source": "bound-inner"]
        slot.view.configureInnerScrollDiagnostics({ [weak self, weak slot, weak fixture] id, kind, fields in
            guard let fixture else { return }
            let sameController: Bool
            if let control = self?.readDiagnosticsFixture { sameController = control === fixture }
            else { sameController = false }
            let current = sameController && self?.epoch == bindingEpoch && slot != nil && self?.slots[index] === slot
            let late = kind.hasPrefix("sample-read-inner-evaluation-late-")
            let terminal = kind == "sample-read-inner-coverage-end" || late
            guard current || terminal else { return }
            var values = identity.merging(fields) { _, new in new }
            values["ownerCurrent"] = String(current)
            let event = EPUBViewportFixtureEvent(requestID: id, kind: kind, values: values)
            if sameController, !late, let self {
                self.fixtureRecordInnerDiagnostic(event, fixture: fixture)
            } else {
                // Terminal receipts belong to the captured old controller,
                // never the controller/slot that replaced it.
                fixture.observe(event)
            }
        }, reason: "slot-bound")
    }

    private func fixtureRecordInnerDiagnostic(_ event: EPUBViewportFixtureEvent, fixture: any EPUBViewportFixtureControl) {
        let state = fixtureInnerState
        // Reserve one of the existing 256 journal entries for the delivery
        // receipt; losses before arming remain explicit, never a green result.
        if !state.store(event) { fixture.observe(event) }
    }

    private func fixtureFlushInnerDiagnostics() {
        guard let fixture = readDiagnosticsFixture else { return }
        fixtureDeliverInnerDiagnostics(fixtureInnerState, to: fixture, reason: "sampling")
    }

    private func fixtureDrainRetiringInnerDiagnostics(reason: String) {
        // Capture the old sink and existing state before epoch/storage/owner changes.
        // Never allocate a buffer or invent coverage to report an empty lifetime.
        guard let fixture = readDiagnosticsFixture,
              let state = fixtureInnerDiagnosticStorage as? EPUBInnerDiagnosticBuffer else { return }
        fixtureDeliverInnerDiagnostics(state, to: fixture, reason: reason)
    }

    private func fixtureDeliverInnerDiagnostics(_ state: EPUBInnerDiagnosticBuffer,
                                                to fixture: any EPUBViewportFixtureControl, reason: String) {
        guard let batch = state.take() else { return }
        fixture.observe(.init(requestID: UUID(), kind: "sample-read-inner-buffer-delivery", values: [
            "uptime": String(ProcessInfo.processInfo.systemUptime), "buffered": String(batch.events.count),
            "preArmDropped": String(batch.dropped), "incomplete": String(batch.dropped > 0),
            "reader": String(describing: ObjectIdentifier(self)), "epoch": epoch.uuidString,
            "deliverySource": EPUBViewportFixtureEvent.source, "deliveryReason": reason]))
        for event in batch.events { fixture.observe(event) }
    }

    private func fixtureRecordClearOrigin(_ origin: String, index: Int? = nil, slot: Slot? = nil) {
        guard let fixture = readDiagnosticsFixture,
              fixtureInnerDiagnosticStorage is EPUBInnerDiagnosticBuffer else { return }
        var fields = ["origin": origin, "reader": String(describing: ObjectIdentifier(self)),
            "epoch": epoch.uuidString, "uptime": String(ProcessInfo.processInfo.systemUptime),
            "taskRole": origin == "timeout-fired" ? "slot-timeout" : "clear-caller-current",
            "taskCancelled": String(Task.isCancelled)]
        if let index { fields["index"] = String(index) }
        if let slot {
            fields["slot"] = String(describing: ObjectIdentifier(slot))
            fields["webView"] = String(describing: ObjectIdentifier(slot.view.webView))
        }
        fixtureRecordInnerDiagnostic(.init(requestID: UUID(), kind: "sample-read-inner-clear-origin", values: fields),
                                     fixture: fixture)
    }

    private func fixtureViewportWrite(_ index: Int, _ slot: Slot, source: String, target: CGFloat,
                                      before: (uptime: Double, innerY: CGFloat, frameY: CGFloat),
                                      beforeAssignment: CGFloat, wrote: Bool) {
        guard let fixture = readDiagnosticsFixture else { return }
        var values = fixtureValues(index, slot)
        values["writerID"] = UUID().uuidString; values["writer.source"] = source
        values["writer.startUptime"] = String(before.uptime)
        values["writer.endUptime"] = String(ProcessInfo.processInfo.systemUptime)
        values["writer.targetY"] = String(describing: target)
        values["writer.innerBeforeFrame"] = String(describing: before.innerY)
        values["writer.frameBeforeY"] = String(describing: before.frameY)
        values["writer.frameAfterY"] = String(describing: slot.view.frame.minY)
        values["writer.innerBeforeAssignment"] = String(describing: beforeAssignment)
        values["writer.innerAfter"] = String(describing: slot.view.webView.scrollView.contentOffset.y)
        values["writer.assigned"] = String(wrote)
        let reads = (fixtureReadRequests ?? [:]).filter { $0.value["webView"] == values["webView"] }
        if reads.isEmpty {
            values["associatedRead"] = "false"
            fixture.observe(.init(requestID: UUID(), kind: "viewport-sync", values: values))
        } else {
            for (id, context) in reads.sorted(by: { $0.key.uuidString < $1.key.uuidString }) {
                var linked = values; linked["associatedRead"] = "true"
                linked["attempt"] = context["attempt"] ?? "before-loop"
                linked["readSource"] = context["source"]
                fixture.observe(.init(requestID: id, kind: "viewport-sync", values: linked))
            }
        }
    }

    var viewportFixtureControl: (any EPUBViewportFixtureControl)? {
        get { viewportFixtureStorage as? any EPUBViewportFixtureControl }
        set {
            if let current = viewportFixtureControl, let newValue, current === newValue { return }
            if viewportFixtureControl == nil, newValue == nil { return }
            for slot in slots.values { slot.view.configureInnerScrollDiagnostics(nil, reason: "fixture-replaced") }
            fixtureDrainRetiringInnerDiagnostics(reason: "fixture-replaced")
            fixtureInnerDiagnosticStorage = nil
            viewportFixtureStorage = newValue
            for (index, slot) in slots { fixtureBindInnerDiagnostics(index, slot) }
        }
    }

    private func fixtureAnchor(_ anchor: Locator?) -> String {
        guard let anchor else { return "nil" }
        do {
            let object = try JSONSerialization.jsonObject(with: Data(try anchor.jsonString().utf8))
            let bytes = try JSONSerialization.data(withJSONObject: object, options: .sortedKeys)
            // Diagnostic equality fingerprint only; text never leaves this function.
            var value: UInt64 = 14695981039346656037
            for byte in bytes { value = (value ^ UInt64(byte)) &* 1099511628211 }
            return String(value, radix: 16)
        } catch {
            // The controller treats this marker as a fixture failure, not a usable anchor.
            return "serialization-error"
        }
    }

    private func fixtureValues(_ index: Int, _ slot: Slot) -> [String: String] {
        ["reader": String(describing: ObjectIdentifier(self)), "epoch": epoch.uuidString,
         "slot": String(describing: ObjectIdentifier(slot)), "index": String(index),
         "webView": String(describing: ObjectIdentifier(slot.view.webView)),
         "revision": String(viewportRevision), "localTop": String(describing: viewportTop - slot.wrapper.frame.minY),
         "outerY": String(describing: contentOffset.y), "nativeWidth": String(describing: slot.view.bounds.width),
         "nativeHeight": String(describing: slot.view.bounds.height), "moving": String(automaticScrolling),
         "positioning": String(slot.positioning), "ready": String(slot.ready),
         "anchor": fixtureAnchor(slot.savedAnchor), "source": EPUBViewportFixtureEvent.source]
    }
}
#endif
