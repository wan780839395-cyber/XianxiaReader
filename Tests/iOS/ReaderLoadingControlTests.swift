import UIKit
import WebKit
import XCTest

/// A local, tiny custom-scheme page separates WebKit startup from EPUB/Readium work.
final class ReaderLoadingControlTests: XCTestCase {
    @MainActor func testMinimalCustomSchemeLoadsAndReleasesAcrossRepeatedWindows() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive })
        let previous = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        addTeardownBlock {
            await MainActor.run {
                window.isHidden = true
                window.rootViewController = nil
                previous?.makeKey()
            }
        }
        let handler = LocalPageHandler()
        for cycle in 0..<8 {
            let retired = try await loadPage(cycle: cycle, host: host, handler: handler)
            let deadline = Date().addingTimeInterval(2)
            while retired.value != nil && Date() < deadline {
                try await Task.sleep(nanoseconds: 20_000_000)
            }
            print("WEBKIT_CONTROL released cycle=\(cycle) alive=\(retired.value != nil)")
            XCTAssertNil(retired.value, "A completed local web view must not accumulate across opens")
        }
        XCTAssertEqual(handler.requests, 8)
    }

    @MainActor private func loadPage(cycle: Int, host: UIViewController,
                                     handler: LocalPageHandler) async throws -> WeakWebView {
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(handler, forURLScheme: "xr-loading-control")
        let started = ProcessInfo.processInfo.systemUptime
        let web = WKWebView(frame: host.view.bounds, configuration: configuration)
        let observer = NavigationObserver(started: started, cycle: cycle)
        web.navigationDelegate = observer
        host.view.addSubview(web)
        let retired = WeakWebView(web)
        defer { web.stopLoading(); web.navigationDelegate = nil; web.removeFromSuperview() }
        print("WEBKIT_CONTROL request cycle=\(cycle)")
        let url = try XCTUnwrap(URL(string: "xr-loading-control://page/\(cycle)"))
        web.load(URLRequest(url: url))
        let deadline = Date().addingTimeInterval(20)
        while !observer.finished && observer.failure == nil && Date() < deadline {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        if let failure = observer.failure { throw failure }
        XCTAssertTrue(observer.finished, "Minimal custom-scheme page exceeded the existing 20-second loading budget")
        guard observer.finished else { throw LoadingFailure.timedOut }
        let text = try await web.evaluateJavaScript("document.getElementById('probe').textContent")
        XCTAssertEqual(text as? String, "local loading control")
        print("WEBKIT_CONTROL finished cycle=\(cycle) elapsed=\(ProcessInfo.processInfo.systemUptime - started)")
        return retired
    }

    private enum LoadingFailure: Error { case timedOut }

    @MainActor private final class WeakWebView {
        weak var value: WKWebView?
        init(_ value: WKWebView) { self.value = value }
    }

    @MainActor private final class LocalPageHandler: NSObject, WKURLSchemeHandler {
        private(set) var requests = 0
        func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
            requests += 1
            let data = Data("<html><head><meta name='viewport' content='width=device-width'></head><body><p id='probe'>local loading control</p></body></html>".utf8)
            guard let url = urlSchemeTask.request.url else {
                urlSchemeTask.didFailWithError(URLError(.badURL)); return
            }
            print("WEBKIT_CONTROL scheme-start request=\(requests)")
            urlSchemeTask.didReceive(URLResponse(url: url, mimeType: "text/html", expectedContentLength: data.count,
                                                textEncodingName: "utf-8"))
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
        func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
    }

    @MainActor private final class NavigationObserver: NSObject, WKNavigationDelegate {
        let started: TimeInterval
        let cycle: Int
        var finished = false
        var failure: Error?
        init(started: TimeInterval, cycle: Int) { self.started = started; self.cycle = cycle }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("WEBKIT_CONTROL navigation-start cycle=\(cycle) elapsed=\(ProcessInfo.processInfo.systemUptime - started)")
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { finished = true }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { failure = error }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { failure = error }
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { failure = URLError(.cannotLoadFromNetwork) }
    }
}
