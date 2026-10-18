import SwiftUI
import UIKit
import XianxiaCore

extension View {
    /// Scope the reader's theme to its presented controller. A reading preference
    /// must never become a window preference inherited by the shelf/search UI.
    func readerColorScheme(_ theme: ReadingTheme) -> some View {
        environment(\.colorScheme, theme.isDark ? .dark : .light)
            .background(ReaderPresentationStyle(style: theme.isDark ? .dark : .light).frame(width: 0, height: 0))
    }
}

private struct ReaderPresentationStyle: UIViewControllerRepresentable {
    let style: UIUserInterfaceStyle
    func makeUIViewController(context: Context) -> ReaderPresentationStyleController {
        ReaderPresentationStyleController(style: style)
    }
    func updateUIViewController(_ controller: ReaderPresentationStyleController, context: Context) {
        controller.style = style; controller.apply()
    }
    static func dismantleUIViewController(_ controller: ReaderPresentationStyleController, coordinator: ()) {
        controller.restore()
    }
}

@MainActor final class ReaderPresentationStyleController: UIViewController {
    var style: UIUserInterfaceStyle
    private weak var target: UIViewController?
    private var previous = UIUserInterfaceStyle.unspecified
    private var applied = UIUserInterfaceStyle.unspecified
    init(style: UIUserInterfaceStyle) { self.style = style; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
    override func loadView() { view = UIView(); view.isUserInteractionEnabled = false }
    override func didMove(toParent parent: UIViewController?) { super.didMove(toParent: parent); apply() }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); apply() }
    func apply() {
        var node = parent
        while let controller = node {
            if controller.presentingViewController != nil {
                if target !== controller { restore(); target = controller; previous = controller.overrideUserInterfaceStyle }
                applied = style
                if controller.overrideUserInterfaceStyle != style { controller.overrideUserInterfaceStyle = style }
                return
            }
            node = controller.parent
        }
        // During construction there may be no presentation yet. Do not climb
        // into or modify the window/root controller to compensate for that.
        if overrideUserInterfaceStyle != style { overrideUserInterfaceStyle = style }
    }
    func restore() {
        if let target, target.overrideUserInterfaceStyle == applied { target.overrideUserInterfaceStyle = previous }
        target = nil
    }
}
