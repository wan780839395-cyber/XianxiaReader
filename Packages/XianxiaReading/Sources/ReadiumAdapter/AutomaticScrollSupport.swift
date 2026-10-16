import ReadingInterfaces
import UIKit

enum AutomaticScrollFailure: LocalizedError {
    case accessibility, notReady
    var errorDescription: String? {
        switch self {
        case .accessibility: return "自动慢滚在减少动态效果或旁白开启时停用。关闭对应设置后可手动开始。"
        case .notReady: return "自动慢滚需要已就绪的上下连续正文，请稍后重试。固定布局、竖排和从右向左的书籍暂不支持。"
        }
    }
}

@MainActor final class AutomaticScrollDisplayTarget: NSObject {
    private weak var owner: ReadiumReaderEngine?
    private let request: UUID
    init(owner: ReadiumReaderEngine, request: UUID) { self.owner = owner; self.request = request }
    @objc func tick(_ link: CADisplayLink) {
        guard let owner else { link.invalidate(); return }
        owner.advanceAutomaticScroll(at: link.targetTimestamp, request: request)
    }
}

/// Passive touch-down observation, including links/selection. It always fails
/// immediately and neither delays nor cancels the publication's own gestures.
@MainActor final class AutomaticScrollTouchObserver: UIGestureRecognizer {
    private let onTouch: () -> Void
    init(onTouch: @escaping () -> Void) {
        self.onTouch = onTouch
        super.init(target: nil, action: nil)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        onTouch()
        state = .failed
    }
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool { false }
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool { false }
}
