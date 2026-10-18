import SwiftUI
import UIKit

/// Keep the navigator's viewport independent of the menu's intrinsic size.
/// Readium handles safe area/content insets inside this full-size surface.
@MainActor struct ReaderSurface: View {
    let viewController: UIViewController
    let pageColor: Color

    init(viewController: UIViewController, pageColor: Color = .clear) {
        self.viewController = viewController
        self.pageColor = pageColor
    }

    var body: some View {
        GeometryReader { geometry in
            ReaderController(viewController: viewController, pageColor: pageColor)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
}

@MainActor private struct ReaderController: UIViewControllerRepresentable {
    let viewController: UIViewController
    let pageColor: Color

    @MainActor final class Coordinator {
        let cover = ReaderSafeAreaCover()
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        let cover = context.coordinator.cover
        cover.pageColor = UIColor(pageColor)
        cover.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(cover)
        NSLayoutConstraint.activate([
            cover.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            cover.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            cover.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.cover.pageColor = UIColor(pageColor)
    }

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.cover.removeFromSuperview()
    }
}

/// Scroll insets reserve room at the beginning/end, but do not clip text while
/// scrolling. Paint only the unsafe edges; leave navigator geometry and input alone.
@MainActor final class ReaderSafeAreaCover: UIView {
    override class var layerClass: AnyClass { CAShapeLayer.self }
    var pageColor = UIColor.clear {
        didSet { if !pageColor.isEqual(oldValue) { setNeedsLayout() } }
    }

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        accessibilityElementsHidden = true
        isOpaque = false
        backgroundColor = .clear
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("Use init()") }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let shape = layer as! CAShapeLayer
        let path = UIBezierPath(rect: bounds)
        let readable = bounds.inset(by: safeAreaInsets)
        if readable.width > 0, readable.height > 0 { path.append(UIBezierPath(rect: readable)) }
        // No implicit layer animation on rotation, theme changes or menu updates.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shape.fillRule = .evenOdd
        shape.fillColor = pageColor.resolvedColor(with: traitCollection).cgColor
        shape.path = path.cgPath
        CATransaction.commit()
    }
}
