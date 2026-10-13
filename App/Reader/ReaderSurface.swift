import SwiftUI
import UIKit

/// Keep the navigator's viewport independent of the menu's intrinsic size.
/// Readium handles safe area/content insets inside this full-size surface.
@MainActor struct ReaderSurface: View {
    let viewController: UIViewController

    var body: some View {
        GeometryReader { geometry in
            ReaderController(viewController: viewController)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
}

@MainActor private struct ReaderController: UIViewControllerRepresentable {
    let viewController: UIViewController
    func makeUIViewController(context: Context) -> UIViewController { viewController }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
