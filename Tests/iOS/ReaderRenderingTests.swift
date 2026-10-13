import ReadiumAdapter
import SwiftUI
import UIKit
import WebKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReaderRenderingTests: XCTestCase {
    @MainActor private final class OverlayState: ObservableObject {
        @Published var visible = true
    }

    @MainActor private struct Harness: View {
        let controller: UIViewController
        @ObservedObject var state: OverlayState
        var body: some View {
            ZStack {
                ReaderSurface(viewController: controller)
                if state.visible {
                    VStack {
                        Text("阅读菜单").padding().background(.regularMaterial)
                        Spacer()
                        Text("底部操作").padding().background(.regularMaterial)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private enum RenderFailure: Error { case timedOut(String, String), invalidProbe }

    @MainActor private func mount(_ engine: ReadiumReaderEngine) throws -> (UIWindow, OverlayState) {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }
        let state = OverlayState()
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: Harness(controller: engine.viewController, state: state))
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        addTeardownBlock {
            await MainActor.run {
                engine.close()
                window.isHidden = true
                window.rootViewController = nil
                previous?.makeKey()
            }
        }
        return (window, state)
    }

    @MainActor private func open(_ engine: ReadiumReaderEngine) async throws -> (Book, UIViewController) {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        let book = Book(title: "阅读页面测试", format: .epub, filePath: "reader-layout.epub")
        try await engine.open(book: book, fileURL: url, position: nil)
        return (book, try XCTUnwrap(engine.viewController.children.first))
    }

    @MainActor private func probe(_ navigator: UIViewController, engine: ReadiumReaderEngine,
                                 resource: String) async throws -> [String: Any] {
        let deadline = Date().addingTimeInterval(20)
        var lastProbe = "No visible web view"
        let script = """
        (() => {
          const image = document.querySelector('img');
          const rect = image?.getBoundingClientRect();
          return {href: location.pathname, height: innerHeight, width: innerWidth,
                  ready: document.readyState === 'complete' && (!image || image.complete),
                  imageHeight: rect?.height ?? 0, imageWidth: rect?.width ?? 0,
                  fit: image ? getComputedStyle(image).objectFit : '', title: document.title};
        })()
        """
        while Date() < deadline {
            if let webView = visibleWebView(in: navigator.view) {
                // Query the actual rendered WKWebView through its public API.
                // The host app owns Readium's static symbols; importing its
                // concrete Navigator metadata here would require duplicate linkage.
                let value = try await webView.evaluateJavaScript(script)
                guard let data = value as? [String: Any] else { throw RenderFailure.invalidProbe }
                var locatedHref: String?
                if let position = engine.currentPosition {
                    guard let locator = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any] else {
                        throw RenderFailure.invalidProbe
                    }
                    locatedHref = locator["href"] as? String
                }
                lastProbe = "DOM: \(data); reported location: \(locatedHref ?? "not emitted")"
                // document.readyState precedes Readium's spreadLoaded message
                // and native location update. Wait for both before sending the
                // next navigation command, just as a reader sees a ready page.
                if (data["href"] as? String)?.hasSuffix(resource) == true,
                   data["ready"] as? Bool == true, locatedHref?.hasSuffix(resource) == true { return data }
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        throw RenderFailure.timedOut(resource, lastProbe)
    }

    @MainActor func testViewportKeepsScreenHeightWhenMenuHidesAndReturns() async throws {
        let engine = ReadiumReaderEngine()
        let (window, state) = try mount(engine)
        let (_, navigator) = try await open(engine)
        let before = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        let initialHeight = try XCTUnwrap(before["height"] as? Double)
        XCTAssertGreaterThan(initialHeight, Double(window.bounds.height) * 0.7)
        XCTAssertGreaterThan(engine.viewController.view.bounds.height, window.bounds.height * 0.85)
        for visible in [false, true, false] {
            state.visible = visible
            window.setNeedsLayout()
            window.layoutIfNeeded()
            // Allow SwiftUI's observed-object transaction to reach UIKit.
            try await Task.sleep(nanoseconds: 200_000_000)
            let updated = try await probe(navigator, engine: engine, resource: "cover.xhtml")
            XCTAssertEqual(try XCTUnwrap(updated["height"] as? Double), initialHeight, accuracy: 2)
            XCTAssertEqual(navigator.view.bounds.height, engine.viewController.view.bounds.height, accuracy: 1)
        }
    }

    @MainActor func testTallCoverUsesWholeViewportInPaginatedAndScrollingModes() async throws {
        for scrolling in [false, true] {
            let engine = ReadiumReaderEngine()
            engine.setScrolling(scrolling)
            let (window, state) = try mount(engine)
            state.visible = false
            let (_, navigator) = try await open(engine)
            let data = try await probe(navigator, engine: engine, resource: "cover.xhtml")
            let height = try XCTUnwrap(data["height"] as? Double)
            let imageHeight = try XCTUnwrap(data["imageHeight"] as? Double)
            XCTAssertGreaterThan(height, Double(window.bounds.height) * 0.7)
            XCTAssertGreaterThan(imageHeight, height * 0.65)
            XCTAssertLessThanOrEqual(imageHeight, height + 2)
            XCTAssertEqual(data["fit"] as? String, "contain")
            let attachment = XCTAttachment(image: try await snapshotVisibleWebView(in: navigator.view))
            attachment.name = scrolling ? "tall-cover-scrolling" : "tall-cover-paginated"
            attachment.lifetime = .keepAlways
            add(attachment)
            engine.close()
            window.isHidden = true
        }
    }

    @MainActor func testScrollingCanMoveToNextResourceAndTOCFragment() async throws {
        let engine = ReadiumReaderEngine()
        engine.setScrolling(true)
        let (_, _) = try mount(engine)
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        await engine.turnPage(forward: true)
        let next = try await probe(navigator, engine: engine, resource: "one.xhtml")
        XCTAssertEqual(next["title"] as? String, "第一章 山门")
        try await engine.go(to: Chapter(id: "test:two", bookID: book.id, ordinal: 2,
                                       title: "第二章 云海", href: "OEBPS/two.xhtml#start"))
        let target = try await probe(navigator, engine: engine, resource: "two.xhtml")
        XCTAssertEqual(target["title"] as? String, "第二章 云海")
        XCTAssertGreaterThan(try XCTUnwrap(target["height"] as? Double), 300)
    }

    @MainActor private func snapshotVisibleWebView(in root: UIView) async throws -> UIImage {
        let webView = try XCTUnwrap(visibleWebView(in: root))
        return try await webView.takeSnapshot(configuration: nil)
    }

    @MainActor private func visibleWebView(in root: UIView) -> WKWebView? {
        webViews(in: root).first {
            let visible = root.bounds.intersection($0.convert($0.bounds, to: root))
            return $0.window != nil && visible.width > root.bounds.width * 0.5
                && visible.height > root.bounds.height * 0.5
        }
    }

    @MainActor private func webViews(in view: UIView) -> [WKWebView] {
        if let webView = view as? WKWebView { return [webView] }
        return view.subviews.flatMap { webViews(in: $0) }
    }
}
