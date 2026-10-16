// XianxiaReader extension of Readium 3.11 (BSD-3-Clause).
// Navigator integration follows Eugene Martinson's PR811; this bounded,
// fixed-viewport implementation replaces its whole-book placeholders.
import ReadiumShared
import UIKit

@MainActor protocol EPUBInfiniteScrollViewDelegate: AnyObject {
    func infiniteScrollView(_ view: EPUBInfiniteScrollView, spreadViewAtIndex index: Int) -> EPUBSpreadView?
    func infiniteScrollViewDidUpdateViews(_ view: EPUBInfiniteScrollView)
}

@MainActor final class EPUBInfiniteScrollView: UIScrollView, UIScrollViewDelegate {
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
    private var viewportRevision: UInt64 = 0
    private var lastTrackedOffset: CGFloat = 0
    private var screenDragStart: CGFloat?
    private var screenTurnInFlight = false
    var screenPagingEnabled = false {
        didSet {
            guard screenPagingEnabled != oldValue else { return }
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
        "index=\(currentIndex) revision=\(viewportRevision) top=\(viewportTop) navigation=\(navigation) "
            + slots.keys.sorted().map { index in
                guard let slot = slots[index] else { return "missing \(index)" }
                return "slot\(index){ready=\(slot.ready) positioning=\(slot.positioning) failure=\(slot.failure ?? "none") wrapper=\(slot.wrapper.frame) frame=\(slot.view.frame) savedTop=\(String(describing: slot.anchorViewportTop)) anchor=\(slot.anchorDiagnostic)}"
            }.joined(separator: " ")
    }
    private var viewportHeight: CGFloat { max(1, bounds.height - contentInset.top - contentInset.bottom) }
    private var viewportTop: CGFloat { max(0, contentOffset.y + contentInset.top) }
    // Keep the last tenth of the viewport visible so a wrapped line is never
    // skipped at a screen boundary. This is not a new pagination/DOM engine.
    private var screenStep: CGFloat { max(1, viewportHeight * 0.9) }
    private var screenOffsetRange: ClosedRange<CGFloat> {
        -contentInset.top ... max(-contentInset.top, contentSize.height - bounds.height + contentInset.bottom)
    }

    func turnScreen(forward: Bool, animated: Bool) -> Bool {
        guard isCurrentResourceReady, !isDragging, !isDecelerating, !screenTurnInFlight else { return false }
        let target = (contentOffset.y + (forward ? screenStep : -screenStep)).clamped(to: screenOffsetRange)
        guard abs(target - contentOffset.y) > 0.5 else { return false }
        screenTurnInFlight = animated && !UIAccessibility.isReduceMotionEnabled
        setContentOffset(CGPoint(x: 0, y: target), animated: screenTurnInFlight)
        return true
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
        screenDragStart = nil
        screenTurnInFlight = false
        setContentOffset(contentOffset, animated: false)
        epoch = UUID()
        for index in Array(slots.keys) { evict(index) }
    }
    func shutdown() {
        chapterCount = 0
        clear()
        infiniteDelegate = nil
    }
    private func evict(_ index: Int) {
        guard let slot = slots.removeValue(forKey: index) else { return }
        slot.loadTask?.cancel()
        slot.timeoutTask?.cancel()
        slot.view.clear()
        slot.wrapper.removeFromSuperview()
        setNeedsLayout()
    }
    func reload(at index: Int, location: PageLocation, count: Int) {
        clear()
        chapterCount = count
        guard count > 0 else { return }
        currentIndex = min(max(index, 0), count - 1)
        load(currentIndex, location: location)
    }
    func goToIndex(_ index: Int, location: PageLocation, options: NavigatorGoOptions) async -> Bool {
        guard 0..<chapterCount ~= index else { return false }
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
            self.updateViewports()
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
        let anchorJSON: String
        let measuredRevision = viewportRevision
        let measuredAnchor = slot.savedAnchor
        let measuredLocalTop = viewportTop - slot.wrapper.frame.minY
        let measuredAnchorIsCurrent = savedAnchorMatchesViewport(slot, revision: measuredRevision)
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
                  anchorY: anchor ? anchor.top + scrollY : null};
        })()
        """
        let result = await slot.view.evaluateScript(script)
        guard epoch == request, slots[index] === slot else { return }
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
            let desiredLocal: CGFloat? = mayRestoreAnchor ? newAnchorY.map { y in
                y - CGFloat(measuredAnchor?.locations.otherLocations["xianxiaViewportOffset"]?.double ?? 0)
            } : nil
            if let newAnchorY, mayRestoreAnchor { slot.anchorDocumentY = newAnchorY }
            slot.height = height
            slot.ready = true
            if changed {
                layoutSlots(preserveAnchor: true)
            }
            if let desiredLocal, let currentSlot = slots[currentIndex] {
                let desired = currentSlot.wrapper.frame.minY + desiredLocal - contentInset.top
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
        guard !layingOut else { return }
        if lastSize != bounds.size {
            screenDragStart = nil
            if screenTurnInFlight {
                screenTurnInFlight = false
                setContentOffset(contentOffset, animated: false)
            }
            lastSize = bounds.size
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
        updateViewports()
        bringSubviewToFront(previousBoundary)
        bringSubviewToFront(boundary)
    }
    private func updateViewports() {
        for index in readyIndices {
            guard let slot = slots[index], !slot.positioning else { continue }
            let local = min(max(viewportTop - slot.wrapper.frame.minY, 0), max(slot.height - 24 - viewportHeight, 0))
            slot.view.frame = CGRect(x: 0, y: local, width: bounds.width, height: viewportHeight)
            if abs(slot.view.webView.scrollView.contentOffset.y - local) > 0.5 {
                slot.view.webView.scrollView.contentOffset.y = local
            }
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
        updateViewports()
        if !navigation, let focused = readyIndices.first(where: { (slots[$0]?.wrapper.frame.maxY ?? 0) > viewportTop }) {
            currentIndex = focused
        }
        preload()
        infiniteDelegate?.infiniteScrollViewDidUpdateViews(self)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
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
        guard let slot = slots[currentIndex], slot.ready, !slot.positioning else { return nil }
        let clipTop = max(0, viewportTop - slot.wrapper.frame.minY - slot.view.frame.minY)
        let clipBottom = min(viewportHeight, slot.height - slot.view.frame.minY)
        let request = epoch
        let index = currentIndex
        let revision = viewportRevision
        let localTop = viewportTop - slot.wrapper.frame.minY
        slot.anchorDiagnostic = "requested local=\(localTop) clip=\(clipTop)...\(clipBottom) revision=\(revision)"
        // Keep the old DOM anchor across reflow until measure() compensates;
        // a resize notification is not a user scroll.
        if savedAnchorMatchesViewport(slot, revision: revision), let anchor = slot.savedAnchor {
            slot.anchorDiagnostic = "cached local=\(localTop) revision=\(revision)"
            return anchor
        }
        // Native UIScrollView can publish its new offset before WebKit has
        // committed the same document viewport. Collect all DOM values in
        // one callback and retry only this mismatch, for at most 3 samples.
        for attempt in 0..<3 {
            let snapshot = await slot.view.continuousVisibleAnchorSnapshot(visibleTop: clipTop, visibleBottom: clipBottom)
            guard !Task.isCancelled, epoch == request, currentIndex == index, slots[index] === slot,
                  viewportRevision == revision, !slot.positioning,
                  abs(viewportTop - slot.wrapper.frame.minY - localTop) < 0.5 else { return nil }
            guard let snapshot else { return nil }
            slot.anchorDiagnostic = "sample=\(attempt) documentY=\(snapshot.documentY) documentTop=\(snapshot.documentTop) local=\(localTop) revision=\(revision)"
            if abs(snapshot.documentTop - max(0, localTop)) >= 1 {
                if attempt < 2 {
                    do { try await Task.sleep(nanoseconds: 32_000_000) }
                    catch is CancellationError { return nil }
                    catch { boundaryLabel.text = error.localizedDescription; return nil }
                }
                continue
            }
            slot.anchorRevision = revision
            slot.anchorViewportTop = localTop
            slot.savedAnchor = snapshot.locator
            slot.anchorDocumentY = snapshot.documentY
            slot.anchorDiagnostic += " accepted"
            return snapshot.locator
        }
        return nil
    }
}
