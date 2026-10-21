@testable import ReadiumAdapter
import ReadingInterfaces
import SwiftUI
import UIKit
import WebKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class ReaderRenderingTests: XCTestCase {
    @MainActor func testRepeatedAppliedPreferencesKeepFreshCaptureAvailableAndCancelQueuedChange() async throws {
        let engine = ReadiumReaderEngine()
        let appearance = ReadingAppearance()
        try engine.setAppearance(appearance); engine.setContinuousScrolling(true)
        var errors: [String] = []; engine.onError = { errors.append($0) }
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let scroll = try continuousScroll(engine)
        try await waitUntil {
            let web = try self.resourceWebView(engine, index: 1)
            return abs((try await web.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double) ?? 10000) < 5
        }
        scroll.contentOffset.y += 600
        try await waitUntil { ((try await self.resourceWebView(engine, index: 1).evaluateJavaScript("scrollY") as? Double) ?? 0) > 500 }
        func point(_ position: ReadingPosition) throws -> NSDictionary {
            let data = try XCTUnwrap(JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any])
            let locations = try XCTUnwrap(data["locations"] as? [String: Any])
            let range = try XCTUnwrap(locations["domRange"] as? [String: Any])
            let start = try XCTUnwrap(range["start"] as? [String: Any])
            XCTAssertGreaterThan(try XCTUnwrap(start["charOffset"] as? Int), 100)
            return NSDictionary(dictionary: start)
        }
        let original = try point(try await engine.captureCurrentPosition())
        let originalWeb = try resourceWebView(engine, index: 1)
        for revertingQueuedEdit in [false, true] {
            if revertingQueuedEdit { engine.setContinuousScrolling(false) }
            engine.setContinuousScrolling(true)
            try engine.setAppearance(appearance)
            // A redundant request must never make a fresh capture unavailable.
            let captured = try await engine.captureCurrentPosition()
            XCTAssertEqual(try point(captured), original)
            XCTAssertTrue(try resourceWebView(engine, index: 1) === originalWeb)
            XCTAssertNotNil(view(identifier: "readium.continuous-scroll", in: engine.viewController.view))
            XCTAssertTrue(errors.isEmpty, "Repeating applied preferences must not raise a layout error: \(errors)")
        }
        engine.close()
    }

    @MainActor func testContinuousViewportResizeKeepsOriginalWordAndLiveWebView() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (window, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let scroll = try continuousScroll(engine)
        try await waitUntil {
            let web = try self.resourceWebView(engine, index: 1)
            guard web.window != nil, web.scrollView.alpha > 0.99 else { return false }
            return abs((try await web.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double) ?? 10000) < 5
        }
        scroll.contentOffset.y += 600
        try await waitUntil { ((try await self.resourceWebView(engine, index: 1).evaluateJavaScript("scrollY") as? Double) ?? 0) > 500 }
        let saved = try await engine.captureCurrentPosition()
        let data = try XCTUnwrap(JSONSerialization.jsonObject(with: saved.locatorData) as? [String: Any])
        let locations = try XCTUnwrap(data["locations"] as? [String: Any])
        let range = try XCTUnwrap(locations["domRange"] as? [String: Any])
        let point = try XCTUnwrap(range["start"] as? [String: Any])
        let selector = try XCTUnwrap(point["cssSelector"] as? String)
        let offset = try XCTUnwrap(point["charOffset"] as? Int); XCTAssertGreaterThan(offset, 100)
        let quoted = String(decoding: try JSONEncoder().encode(selector), as: UTF8.self)
        let originalWeb = try resourceWebView(engine, index: 1)
        let originalFrame = window.frame
        // A real mounted viewport resize checks the live continuous path.
        // The existing UI scenario separately rotates the physical simulator.
        defer { window.frame = originalFrame; window.layoutIfNeeded() }
        for size in [CGSize(width: originalFrame.height, height: originalFrame.width), originalFrame.size] {
            window.frame = CGRect(origin: originalFrame.origin, size: size)
            window.layoutIfNeeded()
            try await waitUntil {
                let web = try self.resourceWebView(engine, index: 1)
                guard web === originalWeb, web.window != nil, web.scrollView.alpha > 0.99 else { return false }
                return try await web.evaluateJavaScript("""
                    (()=>{const n=document.querySelector(\(quoted))?.firstChild;
                    if(!n||n.nodeType!==3||n.length<=\(offset))return false;
                    const r=document.createRange();r.setStart(n,\(offset));r.setEnd(n,\(offset+1));const b=r.getBoundingClientRect();
                    return Math.abs(innerWidth-\(size.width))<2 && b.bottom>0 && b.top<innerHeight && b.right>0 && b.left<innerWidth;})()
                    """) as? Bool == true
            }
            XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
            let image = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }); image.name = "continuous-resize-same-word-\(Int(size.width))"; image.lifetime = .keepAlways; add(image)
        }
        engine.close()
    }

    @MainActor func testSameWidthBodyResizeDoesNotOverwritePendingPagedWord() async throws {
        let barrier = WKUserScript(source: """
            (()=>{
              const Original=window.ResizeObserver;
              window.ResizeObserver=class extends Original {
                constructor(callback){super((entries,observer)=>{
                  if(entries.some(entry=>entry.target===document.body)){
                    window.__xrQueueBodyResize=()=>{
                      const original=window.requestAnimationFrame;
                      window.requestAnimationFrame=frame=>{
                        window.__xrHeldBodyFrame=frame;
                        return original.call(window,()=>{});
                      };
                      try{callback(entries,observer);}finally{window.requestAnimationFrame=original;}
                      return typeof window.__xrHeldBodyFrame==='function';
                    };
                  }
                  callback(entries,observer);
                });}
              };
              window.__xrReleaseBodyResize=()=>{
                const frame=window.__xrHeldBodyFrame;if(typeof frame!=='function')return false;
                delete window.__xrHeldBodyFrame;
                const descriptor=Object.getOwnPropertyDescriptor(window,'scrollX');
                // Reproduce the stale coordinate captured in the real failure.
                // The actual viewport and pending word remain unchanged.
                Object.defineProperty(window,'scrollX',{configurable:true,get:()=>0});
                try{frame(performance.now());}finally{
                  if(descriptor)Object.defineProperty(window,'scrollX',descriptor);else delete window.scrollX;
                }
                requestAnimationFrame(()=>{window.__xrBodyResizeCompleted=true;});
                return true;
              };
            })()
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let engine = ReadiumReaderEngine(additionalUserScripts: [barrier])
        defer { engine.close() }
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let locator: [String: Any] = ["href": "OEBPS/one.xhtml", "type": "application/xhtml+xml",
            "locations": ["xianxiaContinuousAnchorVersion": 1,
                "domRange": ["start": ["cssSelector": "#long-paragraph", "textNodeIndex": 0, "charOffset": 1200]]]]
        try await engine.go(to: ReadingPosition(bookID: book.id, engineID: ReadiumPositionCodec.engineID,
                                               locatorData: JSONSerialization.data(withJSONObject: locator)))
        let web = try XCTUnwrap(visibleWebView(in: engine.viewController.view))
        let word = """
            (()=>{const n=document.getElementById('long-paragraph')?.firstChild;
            if(!n||n.length<=1200)return false;
            const r=document.createRange();r.setStart(n,1200);r.setEnd(n,1201);const b=r.getBoundingClientRect();
            return b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight;})()
            """
        try await waitUntil {
            try await web.evaluateJavaScript("scrollX>100 && typeof window.__xrQueueBodyResize==='function' && (\(word))") as? Bool == true
        }
        let beforeValue = try await web.evaluateJavaScript("scrollX") as? Double
        let before = try XCTUnwrap(beforeValue)
        let queued = try await web.evaluateJavaScript("window.__xrQueueBodyResize()") as? Bool
        XCTAssertEqual(queued, true)
        let released = try await web.evaluateJavaScript("window.__xrReleaseBodyResize()") as? Bool
        XCTAssertEqual(released, true)
        try await waitUntil { try await web.evaluateJavaScript("window.__xrBodyResizeCompleted===true") as? Bool == true }
        let afterValue = try await web.evaluateJavaScript("scrollX") as? Double
        let after = try XCTUnwrap(afterValue)
        let visible = try await web.evaluateJavaScript(word) as? Bool
        print("SAME_WIDTH_RESIZE_CONTROL before=\(before) after=\(after) wordVisible=\(String(describing: visible))")
        XCTAssertEqual(after, before, accuracy: 1, "SAME_WIDTH_RESIZE_MUST_NOT_WRITE_POSITION")
        XCTAssertEqual(visible, true, "The original word must survive the released same-width body callback")
    }

    @MainActor func testPagedReopenRestoresFirstCharacterOfLongParagraph() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let services = try await AppServices.create(storageRoot: root)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        let staged = try await services.files.stageEPUB(from: url)
        let paths = try await services.files.finalize(staged, coverData: nil)
        let book = Book(id: staged.id, title: "段首恢复回归", format: .epub, filePath: paths.filePath)
        let engine = ReadiumReaderEngine(storageRoot: root)
        try engine.setReadingFonts(try BundledReadingFont.allCases.map { try $0.resource() })
        var appearance = ReadingAppearance(); appearance.fontScale = 1.5; appearance.theme = .charcoal
        appearance.importedFontID = BundledReadingFont.sourceHanSerif.id
        try engine.setAppearance(appearance)
        let (_, state) = try mount(engine); state.visible = false
        try await waitUntil { self.diagnosticHost?.hasAppeared == true && engine.viewController.view.window?.isKeyWindow == true }
        let fileURL = try services.files.resolve(paths.filePath)
        try await engine.open(book: book, fileURL: fileURL, position: nil)
        _ = try await self.probe(try XCTUnwrap(engine.viewController.children.first), engine: engine, resource: "cover.xhtml")
        engine.close()
        let locator: [String: Any] = [
            "href": "OEBPS/one.xhtml", "type": "application/xhtml+xml",
            "locations": ["position": 3, "progression": 0.18518518518518517,
                          "totalProgression": 0.34259259259259256,
                          "xianxiaContinuousAnchorVersion": 1, "xianxiaViewportOffset": 3,
                          "domRange": ["start": ["cssSelector": "html > body > p:nth-of-type(25)",
                                                 "textNodeIndex": 0, "charOffset": 0]]],
        ]
        let position = ReadingPosition(bookID: book.id, engineID: ReadiumPositionCodec.engineID,
                                       locatorData: try JSONSerialization.data(withJSONObject: locator))
        try await engine.open(book: book, fileURL: fileURL, position: position)
        let visible = """
            (()=>{const n=document.getElementById('long-paragraph')?.firstChild;if(!n)return false;
            const r=document.createRange();r.setStart(n,0);r.setEnd(n,1);const b=r.getBoundingClientRect();
            return location.pathname.endsWith('/one.xhtml')&&b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight;})()
            """
        let chinese = ReadingFontTests.chineseFontScript(try BundledReadingFont.sourceHanSerif.resource().asset.cssFamily,
                                                        paragraph: "#long-paragraph")
        do {
            try await waitUntil {
                guard let web = self.visibleWebView(in: engine.viewController.view), web.scrollView.alpha > 0.99 else { return false }
                return try await web.evaluateJavaScript("(\(visible)) && (\(chinese))") as? Bool == true
            }
        } catch {
            // Capture native scroll targets only after the original assertion failed.
            for web in webViews(in: engine.viewController.view) {
                do {
                    let result = try await web.evaluateJavaScript("JSON.stringify(window.__xrPagedRestoreTrace)")
                    let evidence = XCTAttachment(string: String(describing: result))
                    evidence.name = "paged-first-character-restore-trace"; evidence.lifetime = .keepAlways; add(evidence)
                    print("PAGED_FIRST_CHARACTER_RESTORE \(String(describing: result))")
                } catch { print("PAGED_RESTORE_DIAGNOSTIC_READ_FAILED \(error)") }
            }
            throw error
        }
        engine.close()
    }

    @MainActor func testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews() async throws {
        let delay = WKUserScript(source: """
            Object.defineProperty(document.fonts,'ready',{get(){
              window.__xrCloseProbeStarted=true;
              return new Promise(resolve=>setTimeout(()=>resolve(document.fonts),2000));
            }});
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        for continuous in [false, true] {
            let engine = ReadiumReaderEngine(additionalUserScripts: [delay])
            engine.setContinuousScrolling(continuous)
            let font = try BundledReadingFont.wenKai.resource()
            try engine.setReadingFonts([font])
            var appearance = ReadingAppearance(); appearance.importedFontID = font.asset.id
            try engine.setAppearance(appearance)
            let (_, state) = try mount(engine); state.visible = false
            let (_, navigator) = try await open(engine)
            try await waitUntil {
                guard let web = self.webViews(in: navigator.view).first else { return false }
                return try await web.evaluateJavaScript("window.__xrCloseProbeStarted === true") as? Bool == true
            }
            let retired = webViews(in: navigator.view)
            XCTAssertFalse(retired.isEmpty)
            engine.close()
            // Keep the old navigator/views alive deliberately: close must revoke
            // their work now, independently of when Swift/WebKit deallocates them.
            for web in retired {
                XCTAssertNil(web.navigationDelegate, "Closing mode=\(continuous) must disconnect navigation callbacks")
                XCTAssertNil(web.uiDelegate, "Closing mode=\(continuous) must disconnect UI callbacks")
                XCTAssertNil(web.scrollView.delegate, "Closing mode=\(continuous) must disconnect scroll callbacks")
            }
            XCTAssertTrue(webViews(in: navigator.view).isEmpty, "Closed mode=\(continuous) must remove preloaded web views")
            XCTAssertTrue(engine.viewController.children.isEmpty)
        }
    }

    @MainActor func testImmediateCloseCannotMountLatePaginationOrWebViews() async throws {
        for continuous in [false, true] {
            let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(continuous)
            let (_, state) = try mount(engine); state.visible = false
            let (_, navigator) = try await open(engine)
            engine.close()
            // Let the navigator's already-scheduled initialization return after close.
            try await Task.sleep(nanoseconds: 200_000_000)
            XCTAssertTrue(engine.viewController.children.isEmpty)
            XCTAssertTrue(webViews(in: navigator.view).isEmpty, "Closed mode=\(continuous) must reject late initialization")
        }
    }

    @MainActor func testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord() async throws {
        let initial = try BundledReadingFont.wenKai.resource(), intermediate = try BundledReadingFont.sourceHanSerif.resource()
        let final = try BundledReadingFont.sourceHanSans.resource()
        let delay = WKUserScript(source: """
            const fonts=document.fonts;
            const nativeReady=Object.getOwnPropertyDescriptor(Object.getPrototypeOf(fonts),'ready').get;
            Object.defineProperty(fonts,'ready',{get(){
              const request=(window.__xrPreviewReadyRequest||0)+1;
              window.__xrPreviewReadyRequest=request;
              window.__xrPreviewReadyStarted=true;
              window.__xrPreviewReadySettled=false;
              const one=location.pathname.endsWith('/one.xhtml')&&document.body;
              const family=one?getComputedStyle(document.body).fontFamily:'';
              const middle=one&&family.includes('\(intermediate.asset.cssFamily)');
              const initial=one&&family.includes('\(initial.asset.cssFamily)')&&window.__xrInitialFontReleased!==true;
              const ready=nativeReady.call(fonts);
              if(initial)ready.then(()=>{window.__xrInitialFontFaceReady=true;});
              const gate=initial?new Promise(resolve=>{
                window.__xrInitialFontReadyHeld=true;
                (window.__xrInitialFontGates??=[]).push(resolve);
                window.__xrReleaseInitialFont=()=>{
                  window.__xrInitialFontReleased=true;
                  window.__xrInitialFontGates.splice(0).forEach(release=>release());
                };
              }):middle?new Promise(resolve=>{
                (window.__xrPreviewReadyGates??=[]).push(resolve);
                window.__xrReleasePreviewReady=()=>window.__xrPreviewReadyGates.splice(0).forEach(release=>release());
              }):Promise.resolve();
              return Promise.all([ready,gate]).then(()=>{
                if(window.__xrPreviewReadyRequest===request)window.__xrPreviewReadySettled=true;
                return fonts;
              });
            }});
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let engine = ReadiumReaderEngine(additionalUserScripts: [delay, Self.pagedNavigationWriterProbe()])
        var interaction = ReadingInteraction(); interaction.reduceMotion = true
        try engine.setInteraction(interaction)
        try engine.setReadingFonts([initial, intermediate, final])
        var appearance = ReadingAppearance(); appearance.fontScale = 1; appearance.importedFontID = initial.asset.id
        try engine.setAppearance(appearance)
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        // Bring the resource into the viewport before waiting for its
        // requestAnimationFrame-driven spreadLoaded/font initialization.
        try await engine.go(to: Chapter(id: "fixture:initialization-one", bookID: book.id, ordinal: 1,
                                       title: "初始化目标", href: "OEBPS/one.xhtml"))
        print("INITIALIZATION_PENDING_CONTROL stage=target-resource-in-viewport")
        // Hold the initial pending-location restore after the real font has
        // loaded. A seek issued now must remain the latest location when the
        // initializer resumes; this ordering does not depend on a short sleep.
        var initialDocument: WKWebView?
        try await waitUntil {
            guard let web = self.visibleWebView(in: engine.viewController.view),
                  web.url?.lastPathComponent == "one.xhtml" else { return false }
            if try await web.evaluateJavaScript("window.__xrInitialFontReadyHeld===true && window.__xrInitialFontFaceReady===true") as? Bool == true {
                initialDocument = web; return true
            }
            return false
        }
        print("INITIALIZATION_PENDING_CONTROL stage=real-font-ready-initial-restore-held")
        // This regression owns font replacement, not a sequence of page turns.
        // Use the same versioned full locator as a real bookmark to prepare a
        // known deep word; the navigation/overlapping-turn regressions stay separate.
        let preparedLocator: [String: Any] = [
            "href": "OEBPS/one.xhtml", "type": "application/xhtml+xml",
            "locations": [
                "xianxiaContinuousAnchorVersion": 1, "xianxiaViewportOffset": 4,
                "domRange": ["start": ["cssSelector": "#long-paragraph", "textNodeIndex": 0, "charOffset": 1200]],
            ],
        ]
        try await engine.go(to: ReadingPosition(bookID: book.id, engineID: ReadiumPositionCodec.engineID,
                                               locatorData: JSONSerialization.data(withJSONObject: preparedLocator)))
        let heldDocument = try XCTUnwrap(initialDocument)
        try await waitUntil {
            return try await heldDocument.evaluateJavaScript("""
                (()=>{if(window.__xrInitialFontReadyHeld!==true||window.__xrInitialFontReleased===true)return false;
                const n=document.getElementById('long-paragraph')?.firstChild;if(!n||n.length<=1200)return false;
                const r=document.createRange();r.setStart(n,1200);r.setEnd(n,1201);const b=r.getBoundingClientRect();
                return scrollX>100&&b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight;})()
                """) as? Bool == true
        }
        print("INITIALIZATION_PENDING_CONTROL stage=original-word-visible-while-held")
        let released = try await heldDocument.evaluateJavaScript("""
            (()=>{if(typeof window.__xrReleaseInitialFont!=='function')return false;
              window.__xrReleaseInitialFont();return true;})()
            """) as? Bool
        XCTAssertEqual(released, true)
        print("INITIALIZATION_PENDING_CONTROL stage=initial-restore-released")
        do {
            try await waitUntil {
                guard let web = self.visibleWebView(in: engine.viewController.view), web.scrollView.window != nil,
                      web.scrollView.alpha > 0.99 else { return false }
                return try await web.evaluateJavaScript("""
                    (()=>{if(!location.pathname.endsWith('/one.xhtml')||window.__xrPreviewReadySettled!==true)return false;
                    window.__xrInitialRestoreReadyObserved=true;
                    const n=document.getElementById('long-paragraph')?.firstChild;if(!n||n.length<=1200)return false;
                    const r=document.createRange();r.setStart(n,1200);r.setEnd(n,1201);const b=r.getBoundingClientRect();
                    return scrollX>100&&b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight;})()
                    """) as? Bool == true
            }
        } catch {
            let diagnosticRect = clippedVisibleRect(heldDocument, root: engine.viewController.view)
            if heldDocument.window != nil, diagnosticRect.width > 0, diagnosticRect.height > 0 {
                do {
                    let value = try await heldDocument.evaluateJavaScript("""
                        (()=>{const n=document.getElementById('long-paragraph')?.firstChild;let wordVisible=false;
                        if(n&&n.length>1200){const r=document.createRange();r.setStart(n,1200);r.setEnd(n,1201);
                          const b=r.getBoundingClientRect();wordVisible=b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight;}
                        return JSON.stringify({released:window.__xrInitialFontReleased===true,
                          faceReady:window.__xrInitialFontFaceReady===true,
                          readyObserved:window.__xrInitialRestoreReadyObserved===true,
                          settled:window.__xrPreviewReadySettled===true,x:scrollX,wordVisible,href:location.pathname});})()
                        """)
                    let details = "attached=\(heldDocument.window != nil) alpha=\(heldDocument.scrollView.alpha) result=\(String(describing: value))"
                    let attachment = XCTAttachment(string: details)
                    attachment.name = "initial-pending-location-failure"; attachment.lifetime = .keepAlways; add(attachment)
                    print("INITIALIZATION_PENDING_FAILURE \(details)")
                } catch { print("INITIALIZATION_PENDING_DIAGNOSTIC_READ_FAILED \(error)") }
            } else {
                print("INITIALIZATION_PENDING_DIAGNOSTIC_SKIPPED hidden or detached viewport")
            }
            throw error
        }
        print("INITIALIZATION_PENDING_CONTROL stage=original-word-survived-initial-restore")
        // No additional await before the original capture: retain only native
        // geometry from the view that just satisfied the original deep-word check.
        let preparedViewID = visibleWebView(in: engine.viewController.view).map { String(describing: ObjectIdentifier($0)) } ?? "nil"
        let preparedGeometry = visibleWebView(in: engine.viewController.view).map {
            "frame=\($0.frame) offset=\($0.scrollView.contentOffset) clipped=\(clippedVisibleRect($0, root: engine.viewController.view))"
        } ?? "nil"
        var saved: ReadingPosition?
        try await waitUntil {
            do { saved = try await engine.captureCurrentPosition(); return true }
            catch ReaderPositionCaptureError.unavailable { return false }
        }
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(saved).locatorData) as? [String: Any])
        let locations = try XCTUnwrap(payload["locations"] as? [String: Any]), range = try XCTUnwrap(locations["domRange"] as? [String: Any])
        let point = try XCTUnwrap(range["start"] as? [String: Any])
        let selector = try XCTUnwrap(point["cssSelector"] as? String), offset = try XCTUnwrap(point["charOffset"] as? Int)
        print("PREPARED_CAPTURE_SAMPLE preparedView=\(preparedViewID) prepared=\(preparedGeometry) selector=\(selector) offset=\(offset)")
        XCTAssertGreaterThan(offset, 100, "Prepare a deep original word before font changes: \(selector), char=\(offset)")
        if offset <= 100 {
            // The original precondition already failed. Observe the page before
            // any font mutation, and do not continue with an invalid deep anchor.
            let captured = String(decoding: try XCTUnwrap(saved).locatorData, as: UTF8.self)
            print("PREPARED_CAPTURE_FAILED preparedView=\(preparedViewID) prepared=\(preparedGeometry) captured=\(captured)")
            for web in webViews(in: engine.viewController.view) {
                let native = "view=\(ObjectIdentifier(web)) prepared=\(String(describing: ObjectIdentifier(web)) == preparedViewID) "
                    + "alpha=\(web.scrollView.alpha) frame=\(web.frame) offset=\(web.scrollView.contentOffset) "
                    + "clipped=\(clippedVisibleRect(web, root: engine.viewController.view)) url=\(web.url?.path ?? "nil")"
                var dom = "not sampled: native page unavailable"
                if web.window != nil, web.scrollView.alpha > 0.99, let url = web.url, url.scheme != "about" {
                    do {
                        dom = String(describing: try await web.evaluateJavaScript("""
                            (()=>{const point=r=>r?{left:r.left,right:r.right,top:r.top,bottom:r.bottom}:null;
                              const n=document.getElementById('long-paragraph')?.firstChild;
                              let deep=null;if(n&&n.length>1200){const r=document.createRange();r.setStart(n,1200);r.setEnd(n,1201);deep=point(r.getBoundingClientRect());}
                              const carets=[];for(const y of [2,12,24])for(const x of [innerWidth*.2,innerWidth*.5,innerWidth*.8]){
                                const c=document.caretRangeFromPoint(x,y);if(c?.startContainer.nodeType!==Node.TEXT_NODE)continue;
                                const r=document.createRange(),n=c.startContainer,o=c.startOffset;r.setStart(n,o);r.setEnd(n,Math.min(n.length,o+1));
                                carets.push({x,y,tag:n.parentElement?.tagName,id:n.parentElement?.id,offset:o,rect:point(r.getClientRects()[0])});}
                              return JSON.stringify({href:location.pathname,x:scrollX,y:scrollY,width:innerWidth,height:innerHeight,
                                ready:document.readyState,fontReady:window.__xrPreviewReadySettled,deep,carets,canonicalTarget:window.__xrCanonicalGoTarget,trace:window.__xrPagedRestoreTrace,writers:window.__xrPagedRestoreWriters});})()
                            """))
                    } catch { dom = "read failed: \(error)" }
                }
                let detail = "\(native) DOM=\(dom)"
                let attachment = XCTAttachment(string: detail)
                attachment.name = "prepared-capture-before-font-mutation"
                attachment.lifetime = .keepAlways; add(attachment)
                print("PREPARED_CAPTURE_FAILED \(detail)")
            }
            return
        }
        let quoted = String(decoding: try JSONEncoder().encode(selector), as: UTF8.self)
        appearance.importedFontID = intermediate.asset.id; try engine.setAppearance(appearance)
        var pendingFontWebView: WKWebView?
        try await waitUntil {
            for web in self.webViews(in: navigator.view) {
                if try await web.evaluateJavaScript("location.pathname.endsWith('/one.xhtml') && getComputedStyle(document.body).fontFamily.includes('\(intermediate.asset.cssFamily)') && window.__xrPreviewReadyStarted===true && window.__xrPreviewReadySettled!==true") as? Bool == true {
                    pendingFontWebView = web
                    return true
                }
            }
            return false
        }
        let pendingFont = try XCTUnwrap(pendingFontWebView)
        addTeardownBlock { try await Self.releaseFontGate(pendingFont) }
        appearance.importedFontID = final.asset.id; try engine.setAppearance(appearance)
        // The second request is issued while the intermediate font is still held.
        // Explicitly release the fault injection, rather than racing an 800ms timer.
        try await Self.releaseFontGate(pendingFont)
        try await waitUntil {
            guard let web = self.visibleWebView(in: engine.viewController.view), web.scrollView.window != nil,
                  web.scrollView.alpha > 0.99 else { return false }
            return try await web.evaluateJavaScript("""
                (()=>{if(!getComputedStyle(document.body).fontFamily.includes('\(final.asset.cssFamily)'))return false;
                const n=document.querySelector(\(quoted))?.firstChild;if(!n||n.length<=\(offset))return false;
                const r=document.createRange();r.setStart(n,\(offset));r.setEnd(n,\(offset+1));const b=r.getBoundingClientRect();
                return b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight;})()
                """) as? Bool == true
        }
        engine.close()
    }

    @MainActor private static func releaseFontGate(_ web: WKWebView) async throws {
        _ = try await web.evaluateJavaScript("window.__xrReleasePreviewReady?.(); null")
    }

    @MainActor func testSixFontsAndExtendedTypographyKeepFreshNonzeroContinuousAnchor() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let resources = try BundledReadingFont.allCases.map { try $0.resource() }
        try engine.setReadingFonts(resources)
        var appearance = ReadingAppearance(); appearance.fontScale = 1
        appearance.importedFontID = resources[0].asset.id; try engine.setAppearance(appearance)
        let (window, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let web = self.webViews(in: wrapper).first, web.scrollView.window != nil,
                  web.scrollView.alpha > 0.99 else { return false }
            return abs((try await web.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double) ?? 10000) < 5
        }
        let scroll = try continuousScroll(engine)
        scroll.setContentOffset(CGPoint(x: 0, y: scroll.contentOffset.y + 600), animated: false)
        try await waitUntil { ((try await self.resourceWebView(engine, index: 1).evaluateJavaScript("scrollY") as? Double) ?? 0) > 500 }
        for (index, resource) in resources.enumerated() {
            let origin = try await engine.captureCurrentPosition()
            let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: origin.locatorData) as? [String: Any])
            let locations = try XCTUnwrap(payload["locations"] as? [String: Any])
            let range = try XCTUnwrap(locations["domRange"] as? [String: Any])
            let point = try XCTUnwrap(range["start"] as? [String: Any])
            let selector = try XCTUnwrap(point["cssSelector"] as? String), offset = try XCTUnwrap(point["charOffset"] as? Int)
            XCTAssertGreaterThan(offset, 100)
            let y = try XCTUnwrap(locations["xianxiaViewportOffset"] as? Double)
            let quoted = String(decoding: try JSONEncoder().encode(selector), as: UTF8.self)
            appearance.importedFontID = resource.asset.id
            appearance.characterSpacing = 0.25; appearance.weightMultiplier = 1.5
            appearance.paragraphIndent = 3.5; appearance.lineHeight = 2.4; appearance.paragraphSpacing = 2
            try engine.setAppearance(appearance)
            var lastProbe = ""
            try await waitUntil {
                guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                      let web = self.webViews(in: wrapper).first, web.scrollView.window != nil,
                      web.scrollView.alpha > 0.99 else { return false }
                let result = try await web.evaluateJavaScript("""
                    (()=>{const p=document.querySelector(\(quoted)),n=p?.firstChild;
                    if(!n||n.nodeType!==3||n.length<=\(offset))return false;
                    const r=document.createRange();r.setStart(n,\(offset));r.setEnd(n,\(offset+1));const b=r.getBoundingClientRect();
                    const s=getComputedStyle(p),root=parseFloat(getComputedStyle(document.documentElement).fontSize);
                    const ready=b.bottom>0&&b.top<innerHeight&&Math.abs(b.top-(\(y)))<3
                      &&s.fontFamily.includes('\(resource.asset.cssFamily)')&&s.fontWeight==='600'
                      &&Math.abs(parseFloat(s.letterSpacing)/root-0.125)<0.01
                      &&Math.abs(parseFloat(s.textIndent)/root-3.5)<0.01;
                    return {ready,family:s.fontFamily,weight:s.fontWeight,spacingRem:parseFloat(s.letterSpacing)/root,
                      indentRem:parseFloat(s.textIndent)/root,expectedY:\(y),actualY:b.top,char:\(offset)};})()
                    """) as? [String: Any]
                let probe = String(describing: result)
                if probe != lastProbe { print("Build24 font[\(index)] typography: \(probe)"); lastProbe = probe }
                return result?["ready"] as? Bool == true
            }
            let web = try resourceWebView(engine, index: 1)
            let glyphs = try await web.evaluateJavaScript(ReadingFontTests.chineseFontScript(resource.asset.cssFamily, paragraph: "#long-paragraph")) as? Bool
            XCTAssertEqual(glyphs, true)
            let image = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }); image.name = "font-six-body-\(index)-build24"; image.lifetime = .keepAlways; add(image)
            XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
        }
        let saved = try await engine.captureCurrentPosition()
        let file = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        engine.close(); try await engine.open(book: book, fileURL: file, position: saved)
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let web = self.webViews(in: wrapper).first, web.scrollView.window != nil,
                  web.scrollView.alpha > 0.99 else { return false }
            return try await web.evaluateJavaScript("document.getElementById('long-paragraph')!=null && getComputedStyle(document.getElementById('long-paragraph')).fontWeight==='600'") as? Bool == true
        }
        let reopened = try await engine.captureCurrentPosition()
        let data = try XCTUnwrap(JSONSerialization.jsonObject(with: reopened.locatorData) as? [String: Any])
        XCTAssertNotNil((data["locations"] as? [String: Any])?["domRange"])
        engine.close()
    }

    @MainActor func testClosingDuringDelayedFontReadyCannotNavigateOrNotifyNewReader() async throws {
        let delay = WKUserScript(source: """
            Object.defineProperty(document.fonts,'ready',{get(){
              window.__xrFontReadyStarted=true;
              return new Promise(resolve=>setTimeout(()=>{window.__xrFontReadySettled=true;resolve(document.fonts);},2000));
            }});
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let engine = ReadiumReaderEngine(additionalUserScripts: [delay])
        let resource = try BundledReadingFont.wenKai.resource()
        try engine.setReadingFonts([resource])
        var appearance = ReadingAppearance(); appearance.importedFontID = resource.asset.id
        try engine.setAppearance(appearance)
        let (window, state) = try mount(engine); state.visible = false
        let (oldBook, oldNavigator) = try await open(engine)
        try await waitUntil {
            guard let web = self.webViews(in: oldNavigator.view).first else { return false }
            return try await web.evaluateJavaScript("window.__xrFontReadyStarted === true && window.__xrFontReadySettled !== true") as? Bool == true
        }
        let captureStarted = expectation(description: "Capture while initial font page is hidden")
        let oldCapture = Task { @MainActor in
            captureStarted.fulfill()
            return try await engine.captureCurrentPosition()
        }
        await fulfillment(of: [captureStarted], timeout: 1)
        engine.close()
        var delivered: [UUID] = []
        engine.onPositionChanged = { delivered.append($0.bookID) }
        let (newBook, newNavigator) = try await open(engine)
        do { _ = try await oldCapture.value; XCTFail("Hidden-page capture must not return a transient or new-reader locator") }
        catch is CancellationError { XCTAssertNil(oldNavigator.parent) }
        catch { XCTFail("Closed capture should be cancelled: \(error)") }
        XCTAssertNotEqual(oldBook.id, newBook.id); XCTAssertFalse(oldNavigator === newNavigator)
        try await waitUntil {
            guard let web = self.webViews(in: newNavigator.view).first else { return false }
            let settled = try await web.evaluateJavaScript("window.__xrFontReadySettled === true") as? Bool == true
            return settled && engine.currentPosition?.bookID == newBook.id
        }
        XCTAssertTrue(delivered.allSatisfy { $0 == newBook.id })
        XCTAssertNil(oldNavigator.parent); XCTAssertNil(oldNavigator.view.superview)
        XCTAssertEqual(engine.viewController.children.count, 1); XCTAssertGreaterThan(window.bounds.width, 0)
        engine.close()
    }
    @MainActor func testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes() async throws {
        struct Factory: ReadingInterfaces.ReaderEngineFactory {
            let engine: ReadiumReaderEngine
            func makeEngine(for format: BookFormat) throws -> any ReadingInterfaces.ReaderEngine { engine }
        }
        for continuous in [false, true] {
            let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            let services = try await AppServices.create(storageRoot: root)
            addTeardownBlock { try FileManager.default.removeItem(at: root) }
            let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
            let staged = try await services.files.stageEPUB(from: url)
            let paths = try await services.files.finalize(staged, coverData: nil)
            let book = Book(id: staged.id, title: "字体阅读", format: .epub, filePath: paths.filePath)
            try await services.repository.insert(book, chapters: [])
            var interaction = ReadingInteraction(); interaction.continuousScrolling = continuous; interaction.reduceMotion = true
            try await services.files.saveReadingInteraction(interaction)
            var initialAppearance = ReadingAppearance(); initialAppearance.fontScale = 1
            try await services.files.saveReadingAppearance(initialAppearance)
            let engine = ReadiumReaderEngine(additionalUserScripts: [Self.pagedNavigationWriterProbe()], storageRoot: root)
            let (window, state) = try mount(engine); state.visible = false
            let model = ReaderViewModel(book: book, services: services, factory: Factory(engine: engine))
            // Match the existing open(engine) fixture's foreground precondition
            // before starting the real ViewModel path. Resource budget stays 20s.
            try await waitUntil {
                guard let host = self.diagnosticHost, host.hasAppeared,
                      let window = engine.viewController.view.window,
                      window.isKeyWindow, !window.isHidden,
                      window.windowScene?.activationState == .foregroundActive else { return false }
                let frame = engine.viewController.view.convert(engine.viewController.view.bounds, to: window)
                return frame.width > 0 && frame.height > 0 && frame.intersects(window.bounds)
            }
            await model.open(); XCTAssertTrue(model.isReady)
            let navigator = try XCTUnwrap(engine.viewController.children.first)
            _ = try await probe(navigator, engine: engine, resource: "cover.xhtml", continuousResourceIndex: continuous ? 0 : nil)
            // App open can request a restored reading mode asynchronously.
            // Finish that initial transition before issuing test navigation.
            try await waitUntil {
                do { _ = try await engine.captureCurrentPosition(); return true }
                catch ReaderPositionCaptureError.unavailable { return false }
            }
            try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
            _ = try await probe(try XCTUnwrap(engine.viewController.children.first), engine: engine, resource: "one.xhtml")
            if continuous {
                let scroll = try continuousScroll(engine)
                let web = try resourceWebView(engine, index: 1)
                try await waitUntil { abs((try await web.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double) ?? 10000) < 5 }
                scroll.contentOffset.y += 600
                try await waitUntil { ((try await web.evaluateJavaScript("scrollY") as? Double) ?? 0) > 500 }
            } else { for _ in 0..<3 { await engine.turnPage(forward: true) } }
            let original = continuous ? try resourceWebView(engine, index: 1) : try XCTUnwrap(visibleWebView(in: engine.viewController.view))
            let caretScript = "(() => { const r=document.caretRangeFromPoint(innerWidth*.2,2); return r?.startContainer.parentElement?.closest('#long-paragraph') ? r.startOffset : null; })()"
            var stableCharacter: Int?, previousCharacter: Int?
            try await waitUntil {
                let value = try await original.evaluateJavaScript(caretScript) as? Int
                defer { previousCharacter = value }
                guard let value, value > 100, value == previousCharacter else { return false }
                stableCharacter = value; return true
            }
            let character = try XCTUnwrap(stableCharacter); XCTAssertGreaterThan(character, 100)
            let initialTopScript = """
                (()=>{const n=document.getElementById('long-paragraph').firstChild;
                const r=document.createRange();r.setStart(n,\(character));r.setEnd(n,\(character+1));return r.getBoundingClientRect().top;})()
                """
            let initialTopValue = try await original.evaluateJavaScript(initialTopScript) as? Double
            let initialTop = try XCTUnwrap(initialTopValue)
            let initialVerticalCheck = continuous ? "Math.abs(b.top - \(initialTop)) < 3" : "true"
            let fontURL = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "iAWriterDuospace-Regular", withExtension: "ttf", subdirectory: "Fixtures/Fonts"))
            await model.importReadingFont(from: fontURL)
            let font = try XCTUnwrap(model.importedFonts.first)
            XCTAssertEqual(model.appearance.importedFontID, font.id); XCTAssertFalse(model.fontBusy)
            let anchorScript = """
                (() => {const n=document.getElementById('long-paragraph')?.firstChild;if(!n)return false;
                const r=document.createRange();r.setStart(n,\(character));r.setEnd(n,\(character+1));const b=r.getBoundingClientRect();
                return b.right>0 && b.left<innerWidth && b.bottom>0 && b.top<innerHeight && (\(initialVerticalCheck));})()
                """
            let fontScript = """
                (() => {const family='\(font.cssFamily)'; const p=document.getElementById('long-paragraph');
                if(!p || !getComputedStyle(p).fontFamily.includes(family))return false;
                if(!Array.from(document.fonts).some(f=>f.family.includes(family)&&f.status==='loaded'))return false;
                const c=document.createElement('canvas').getContext('2d');c.font='30px '+family;const actual=c.measureText('iiiiWWWW').width;
                c.font='30px serif';return Math.abs(actual-c.measureText('iiiiWWWW').width)>1;})()
                """
            func active() -> WKWebView? {
                let candidate: WKWebView?
                if continuous {
                    guard let wrapper = view(identifier: "readium.chapter.1", in: engine.viewController.view) else { return nil }
                    candidate = webViews(in: wrapper).first
                } else { candidate = visibleWebView(in: engine.viewController.view) }
                // Readium sets isSpreadLoaded before finishing pending-location
                // navigation and showing scrollView. A ready DOM alone can still
                // be behind its loading indicator in a native screenshot.
                guard let candidate, candidate.window != nil, candidate.scrollView.alpha > 0.99 else { return nil }
                return candidate
            }
            func recordReopenCheckpoint(_ phase: String, font: String, stored: ReadingPosition? = nil) {
                func describe(_ position: ReadingPosition?) -> String {
                    guard let position else { return "nil" }
                    return "updatedAt=\(position.updatedAt.timeIntervalSince1970) "
                        + String(decoding: position.locatorData, as: UTF8.self)
                }
                let details = "phase=\(phase) font=\(font) continuous=\(continuous) ready=\(model.isReady)\n"
                    + "saveFailure=\(model.positionSaveFailure ?? "nil")\n"
                    + "model=\(describe(model.position))\nengine=\(describe(engine.currentPosition))\n"
                    + "stored=\(describe(stored))"
                let attachment = XCTAttachment(string: details)
                attachment.name = "font-reopen-\(font)-\(continuous)-\(phase)"
                attachment.lifetime = .keepAlways; add(attachment)
                print("FONT_REOPEN_CHECKPOINT \(details)")
            }
            try await waitUntil { guard let web = active() else { return false }; return try await web.evaluateJavaScript(fontScript) as? Bool == true }
            try await waitUntil { guard let web = active() else { return false }; return try await web.evaluateJavaScript(anchorScript) as? Bool == true }
            let sizeValue = try await XCTUnwrap(active()).evaluateJavaScript("parseFloat(getComputedStyle(document.getElementById('long-paragraph')).fontSize)") as? Double
            let originalSize = try XCTUnwrap(sizeValue)
            var updated = model.appearance; updated.fontScale = 1.5; updated.theme = .charcoal
            model.setAppearance(updated)
            let reflowScript = "(\(anchorScript)) && parseFloat(getComputedStyle(document.getElementById('long-paragraph')).fontSize) > \(originalSize * 1.3)"
            try await waitUntil { guard let web = active() else { return false }; return try await web.evaluateJavaScript(reflowScript) as? Bool == true }
            await model.saveNow(); model.close(); await model.open()
            XCTAssertEqual(model.appearance.importedFontID, font.id)
            try await waitUntil { guard let web = active() else { return false }; return try await web.evaluateJavaScript(fontScript) as? Bool == true }
            try await waitUntil { guard let web = active() else { return false }; return try await web.evaluateJavaScript(reflowScript) as? Bool == true }
            XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
            let evidence = XCTAttachment(string: "Actual served custom family=\(font.cssFamily); loaded FontFace and Latin canvas metric differs from serif; original long paragraph UTF16=\(character) remains visible after imported-font rebuild, 150% reflow and static reopen; continuous=\(continuous)")
            evidence.name = "font-real-load-anchor-\(continuous)"; evidence.lifetime = .keepAlways; add(evidence)
            let image = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) })
            image.name = "font-epub-\(continuous ? "continuous" : "paged")-build23"; image.lifetime = .keepAlways; add(image)
            let metricScript = "(()=>{const c=document.createElement('canvas').getContext('2d');c.font='30px \(font.cssFamily)';return c.measureText('iiiiWWWW').width;})()"
            let metricValue = try await XCTUnwrap(active()).evaluateJavaScript(metricScript) as? Double
            let firstMetric = try XCTUnwrap(metricValue)
            var nextAnchorScript = anchorScript
            var nextAnchorLocations = "null"
            func sampleNextAnchor() async throws {
                var captured: ReadingPosition?
                try await waitUntil {
                    do { captured = try await engine.captureCurrentPosition(); return true }
                    catch ReaderPositionCaptureError.unavailable { return false }
                }
                let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(captured).locatorData) as? [String: Any])
                let locations = try XCTUnwrap(payload["locations"] as? [String: Any])
                nextAnchorLocations = String(decoding: try JSONSerialization.data(withJSONObject: locations), as: UTF8.self)
                let range = try XCTUnwrap(locations["domRange"] as? [String: Any])
                let point = try XCTUnwrap(range["start"] as? [String: Any])
                let selector = try XCTUnwrap(point["cssSelector"] as? String)
                let offset = try XCTUnwrap(point["charOffset"] as? Int)
                XCTAssertEqual(point["textNodeIndex"] as? Int, 0, "Fixture paragraphs contain a single text node")
                let viewportOffset: Double
                if continuous { viewportOffset = try XCTUnwrap(locations["xianxiaViewportOffset"] as? Double) }
                else { viewportOffset = 0 }
                let verticalCheck = continuous ? "Math.abs(b.top - \(viewportOffset)) < 3" : "true"
                let json = String(decoding: try JSONEncoder().encode(selector), as: UTF8.self)
                nextAnchorScript = """
                    (()=>{const n=document.querySelector(\(json))?.firstChild;if(!n||n.nodeType!==3)return false;
                    const r=document.createRange();r.setStart(n,\(offset));r.setEnd(n,\(offset+1));const b=r.getBoundingClientRect();
                    return b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight&&(\(verticalCheck));})()
                    """
            }
            // A page boundary may expose an earlier word after each reflow.
            // Preserve the full point visible immediately before each separate
            // action, rather than demanding the first action's bottom word stay
            // on screen through an arbitrary chain of different page layouts.
            try await sampleNextAnchor()
            await model.importReadingFont(from: try BundledReadingFont.wenKai.resource().fileURL)
            let second = try XCTUnwrap(model.importedFonts.first(where: { $0.id != font.id }))
            XCTAssertEqual(second.fileExtension, font.fileExtension)
            let firstURL = try await services.files.readingFontURL(font)
            let secondURL = try await services.files.readingFontURL(second)
            XCTAssertEqual(firstURL.lastPathComponent, secondURL.lastPathComponent)
            XCTAssertNotEqual(firstURL, secondURL)
            let secondScript = ReadingFontTests.chineseFontScript(second.cssFamily, paragraph: "#long-paragraph")
            try await waitUntil {
                guard let web = active() else { return false }
                return try await web.evaluateJavaScript("(\(secondScript)) && (\(nextAnchorScript))") as? Bool == true
            }
            let routesScript = """
                (()=>{const result={};for(const style of document.querySelectorAll('style')){
                  for(const r of Array.from(style.sheet?.cssRules||[])){
                    if(r.type!==CSSRule.FONT_FACE_RULE)continue;
                    for(const f of ['\(font.cssFamily)','\(second.cssFamily)']){
                      if(r.style.getPropertyValue('font-family').includes(f))result[f]=r.style.getPropertyValue('src');
                    }
                  }
                }return result;})()
                """
            let routeValue = try await XCTUnwrap(active()).evaluateJavaScript(routesScript) as? [String: String]
            let routes = try XCTUnwrap(routeValue)
            XCTAssertEqual(routes.count, 2); XCTAssertEqual(Set(routes.values).count, 2, "Same-basename fonts require independent served URLs")
            try await sampleNextAnchor(); model.selectImportedFont(font.id)
            try await waitUntil {
                guard let web = active() else { return false }
                return try await web.evaluateJavaScript("(\(fontScript)) && (\(nextAnchorScript))") as? Bool == true
            }
            let reselectedMetric = try await XCTUnwrap(active()).evaluateJavaScript(metricScript) as? Double
            XCTAssertEqual(try XCTUnwrap(reselectedMetric), firstMetric, accuracy: 0.01)
            for bundled in BundledReadingFont.allCases {
                let asset = try bundled.resource().asset
                try await sampleNextAnchor()
                model.selectImportedFont(asset.id)
                let chinese = ReadingFontTests.chineseFontScript(asset.cssFamily, paragraph: "#long-paragraph")
                try await waitUntil {
                    guard let web = active() else { return false }
                    return try await web.evaluateJavaScript("(\(chinese)) && (\(nextAnchorScript))") as? Bool == true
                }
                recordReopenCheckpoint("visible-before-save", font: bundled.rawValue)
                await model.saveNow()
                recordReopenCheckpoint("save-returned", font: bundled.rawValue)
                let savedPayload = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(model.position).locatorData) as? [String: Any])
                let savedLocations = try XCTUnwrap(savedPayload["locations"] as? [String: Any])
                let savedLocationsJSON = String(decoding: try JSONSerialization.data(withJSONObject: savedLocations), as: UTF8.self)
                model.close()
                recordReopenCheckpoint("closed", font: bundled.rawValue)
                await model.open()
                recordReopenCheckpoint("open-returned", font: bundled.rawValue)
                XCTAssertEqual(model.appearance.importedFontID, asset.id)
                @discardableResult @MainActor func recordRenderedReopen(_ phase: String) async -> [String: Any]? {
                    var activeSnapshot: [String: Any]?
                    // Observe after the original assertion, so the probe does not
                    // change the save/close/open sequence or its readiness budget.
                    for web in webViews(in: engine.viewController.view) {
                        do {
                            let result = try await web.evaluateJavaScript("""
                                JSON.stringify({href:location.pathname,x:scrollX,width:innerWidth,
                                  fontCondition:(\(chinese)),anchorCondition:(\(nextAnchorScript)),
                                  family:document.body?getComputedStyle(document.body).fontFamily:null,
                                  fontReady:window.__xianxiaReadingFontReady,fontStatus:document.fonts.status,
                                  faces:Array.from(document.fonts).map(f=>({family:f.family,status:f.status})),
                                  geometry:(()=>{
                                    function point(locations){
                                      const p=locations?.domRange?.start, n=p&&document.querySelector(p.cssSelector)?.childNodes[p.textNodeIndex];
                                      if(!n||n.nodeType!==3||p.charOffset>=n.length)return null;
                                      const r=document.createRange();r.setStart(n,p.charOffset);r.setEnd(n,p.charOffset+1);
                                      const b=r.getBoundingClientRect();
                                      return {point:p,expectedTop:locations.xianxiaViewportOffset,
                                        rect:b.toJSON(),rects:Array.from(r.getClientRects(),x=>x.toJSON()),
                                        visible:b.right>0&&b.left<innerWidth&&b.bottom>0&&b.top<innerHeight,
                                        delta:b.top-(locations.xianxiaViewportOffset??0)};
                                    }
                                    return {time:performance.now(),y:scrollY,height:innerHeight,documentHeight:document.documentElement.scrollHeight,
                                      beforeSelection:point(\(nextAnchorLocations)),saved:point(\(savedLocationsJSON))};
                                  })(),
                                  canonicalTarget:window.__xrCanonicalGoTarget,trace:window.__xrPagedRestoreTrace,writers:window.__xrPagedRestoreWriters})
                                """)
                            let details = "phase=\(phase) font=\(bundled.rawValue) continuous=\(continuous) "
                                + "alpha=\(web.scrollView.alpha) nativeOffset=\(web.scrollView.contentOffset) "
                                + "nativeSize=\(web.scrollView.contentSize) fontMessage=\(model.fontMessage ?? "nil") "
                                + "errorMessage=\(model.errorMessage ?? "nil") result=\(String(describing: result))"
                            let attachment = XCTAttachment(string: details)
                            attachment.name = "font-rendered-reopen-\(bundled.rawValue)-\(continuous)-\(phase)"
                            attachment.lifetime = .keepAlways; add(attachment)
                            print("FONT_RENDERED_REOPEN \(details)")
                            if web === active(), let serialized = result as? String,
                               let data = serialized.data(using: .utf8) {
                                activeSnapshot = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                            }
                        } catch { print("FONT_RENDERED_DIAGNOSTIC_READ_FAILED \(error)") }
                    }
                    return activeSnapshot
                }
                do {
                    try await waitUntil {
                        guard let web = active() else { return false }
                        return try await web.evaluateJavaScript("(\(chinese)) && (\(nextAnchorScript))") as? Bool == true
                    }
                    await recordRenderedReopen("passed")
                    XCTAssertNil(model.errorMessage, "A rendered font must not leave a reading alert; font=\(bundled.rawValue) continuous=\(continuous)")
                } catch {
                    await recordRenderedReopen("failed")
                    // Read only after the original failure, preserving its timing
                    // and error even when collecting the database evidence fails.
                    do {
                        let stored = try await services.repository.position(for: book.id)
                        recordReopenCheckpoint("failed-restoration", font: bundled.rawValue, stored: stored)
                    } catch { print("FONT_REOPEN_DIAGNOSTIC_READ_FAILED \(error)") }
                    throw error
                }
                let chineseImage = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) })
                chineseImage.name = "font-epub-\(bundled.rawValue)-\(continuous ? "continuous" : "paged")-build23"
                chineseImage.lifetime = .keepAlways; add(chineseImage)
                // Use the existing synchronous native snapshot as the second
                // observation boundary. evaluateJavaScript cannot return a Promise.
                if continuous {
                    let observed = await recordRenderedReopen("after-native-snapshot")
                    let snapshot = try XCTUnwrap(observed)
                    let geometry = try XCTUnwrap(snapshot["geometry"] as? [String: Any])
                    let saved = try XCTUnwrap(geometry["saved"] as? [String: Any])
                    let delta = try XCTUnwrap(saved["delta"] as? Double)
                    XCTAssertEqual(saved["visible"] as? Bool, true)
                    XCTAssertLessThan(abs(delta), 3, "CONTINUOUS_SAVED_VIEWPORT_OFFSET font=\(bundled.rawValue)")
                    XCTAssertEqual(snapshot["anchorCondition"] as? Bool, true, "The original pre-font word must remain in place after the native snapshot")
                }
            }
            model.close()
        }
    }
    @MainActor func testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes() async throws {
        for continuous in [false, true] {
            let engine = ReadiumReaderEngine()
            var interaction = ReadingInteraction(); interaction.reduceMotion = true
            try engine.setInteraction(interaction)
            if continuous { engine.setContinuousScrolling(true) }
            let (window, state) = try mount(engine); state.visible = false
            let (book, navigator) = try await open(engine)
            _ = try await probe(navigator, engine: engine, resource: "cover.xhtml", continuousResourceIndex: continuous ? 0 : nil)
            try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
            let web = continuous ? try resourceWebView(engine, index: 1) : try XCTUnwrap(visibleWebView(in: engine.viewController.view))
            if continuous {
                let scroll = try continuousScroll(engine)
                try await waitUntil { abs((try await web.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double) ?? 10000) < 5 }
                scroll.setContentOffset(CGPoint(x: 0, y: scroll.contentOffset.y + 600), animated: false)
                try await waitUntil { ((try await web.evaluateJavaScript("scrollY") as? Double) ?? 0) > 500 }
            } else {
                await engine.turnPage(forward: true)
                try await waitUntil { ((try await web.evaluateJavaScript("scrollX") as? Double) ?? 0) > 100 }
            }
            let script = continuous ? "document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000" : "scrollX"
            let origin = try await engine.captureCurrentPosition()
            let json = try XCTUnwrap(JSONSerialization.jsonObject(with: origin.locatorData) as? [String: Any])
            let locations = try XCTUnwrap(json["locations"] as? [String: Any])
            XCTAssertNotNil(locations["domRange"], "Return points must retain a full text anchor")
            let beforeValue = try await web.evaluateJavaScript(script) as? Double
            let before = try XCTUnwrap(beforeValue)
            try await jump(engine, book: book, href: "OEBPS/two.xhtml")
            try await engine.go(to: origin)
            try await waitUntil {
                let restored = continuous ? try self.resourceWebView(engine, index: 1) : try XCTUnwrap(self.visibleWebView(in: engine.viewController.view))
                return abs(((try await restored.evaluateJavaScript(script) as? Double) ?? 10000) - before) < 3
            }
            XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
            let image = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }); image.name = "return-epub-\(continuous ? "continuous" : "paged")-build22"; image.lifetime = .keepAlways; add(image)
            if continuous {
                // A clipped first line is a valid canonical position. Repeat the
                // identical seek with no outer scroll callback, as happens when
                // setContentOffset does not change the outer coordinate.
                var targetJSON = json, targetLocations = locations
                targetLocations["xianxiaViewportOffset"] = -10.0
                targetJSON["locations"] = targetLocations
                let target = ReadingPosition(bookID: origin.bookID, engineID: origin.engineID,
                    locatorVersion: origin.locatorVersion,
                    locatorData: try JSONSerialization.data(withJSONObject: targetJSON, options: .sortedKeys),
                    chapterTitle: origin.chapterTitle, progression: origin.progression, updatedAt: origin.updatedAt)
                let range = try XCTUnwrap(targetLocations["domRange"] as? [String: Any])
                let start = try XCTUnwrap(range["start"] as? [String: Any])
                let startJSON = String(decoding: try JSONSerialization.data(withJSONObject: start), as: UTF8.self)
                let topScript = """
                    (()=>{const p=\(startJSON),n=document.querySelector(p.cssSelector)?.childNodes[p.textNodeIndex];
                    if(!n)return null;const r=document.createRange();r.setStart(n,p.charOffset);r.setEnd(n,p.charOffset+1);
                    return r.getBoundingClientRect().top;})()
                    """
                try await jump(engine, book: book, href: "OEBPS/two.xhtml")
                try await engine.go(to: target)
                let restored = try resourceWebView(engine, index: 1)
                try await waitUntil { abs(((try await restored.evaluateJavaScript(topScript) as? Double) ?? 10000) + 10) < 3 }
                let scroll = try continuousScroll(engine), beforeOuter = scroll.contentOffset.y
                let previousDelegate = scroll.delegate
                addTeardownBlock { await MainActor.run { scroll.delegate = previousDelegate } }
                defer { scroll.delegate = previousDelegate }
                scroll.delegate = nil
                try await engine.go(to: target)
                let repeatedImage = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                    window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                }); repeatedImage.name = "continuous-repeated-canonical-seek"; repeatedImage.lifetime = .keepAlways; add(repeatedImage)
                let afterValue = try await restored.evaluateJavaScript(topScript) as? Double
                let after = try XCTUnwrap(afterValue)
                let details = "expectedTop=-10 actualTop=\(after) outerBefore=\(beforeOuter) outerAfter=\(scroll.contentOffset.y) inner=\(restored.scrollView.contentOffset.y)"
                print("CONTINUOUS_REPEAT_ANCHOR \(details)")
                let evidence = XCTAttachment(string: details); evidence.name = "continuous-repeated-anchor"; evidence.lifetime = .keepAlways; add(evidence)
                XCTAssertLessThan(abs(scroll.contentOffset.y - beforeOuter), 0.5, "Control must keep the same outer coordinate")
                XCTAssertLessThan(abs(after + 10), 3, "LATE_CANONICAL_VIEWPORT_OFFSET: repeated seek must preserve the saved word offset without a scroll callback")
            }
            engine.close()
        }
    }
    @MainActor func testAutomaticScrollRealDisplayLinkPauseLateFrameFullLocatorAndReopen() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (window, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let scroll = try continuousScroll(engine), before = scroll.contentOffset.y
        var locations = 0
        engine.onPositionChanged = { _ in locations += 1 }
        let previousIdleTimer = UIApplication.shared.isIdleTimerDisabled
        try engine.startAutomaticScroll(screensPerMinute: 6)
        XCTAssertTrue(UIApplication.shared.isIdleTimerDisabled)
        let oldRequest = try XCTUnwrap(engine.automaticScrollSessionID)
        try await waitUntil { scroll.contentOffset.y > before + 200 }
        XCTAssertEqual(engine.automaticScrollState, .running)
        XCTAssertLessThan(locations, 12, "Position sampling must not follow display frequency")
        let touch = try XCTUnwrap(navigator.view.gestureRecognizers?.compactMap { $0 as? AutomaticScrollTouchObserver }.first)
        XCTAssertFalse(touch.cancelsTouchesInView); XCTAssertFalse(touch.delaysTouchesBegan)
        touch.touchesBegan([], with: UIEvent())
        XCTAssertEqual(engine.automaticScrollState, .paused)
        XCTAssertEqual(UIApplication.shared.isIdleTimerDisabled, previousIdleTimer)
        await engine.flushAutomaticScrollPosition()
        let paused = scroll.contentOffset.y
        engine.advanceAutomaticScroll(at: 1234, request: oldRequest)
        try await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(scroll.contentOffset.y, paused, accuracy: 0.5)
        let saved = try XCTUnwrap(engine.currentPosition)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: saved.locatorData) as? [String: Any])
        let locator = try XCTUnwrap(json["locations"] as? [String: Any])
        XCTAssertNotNil(locator["domRange"]); XCTAssertNotNil(locator["xianxiaViewportOffset"])
        let web = try resourceWebView(engine, index: 1)
        let script = "document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000"
        let yValue = try await web.evaluateJavaScript(script) as? Double
        let y = try XCTUnwrap(yValue)
        let image = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }); image.name = "autoscroll-epub-paused-build21"; image.lifetime = .keepAlways; add(image)
        engine.close()
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        try await engine.open(book: book, fileURL: url, position: saved)
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let reopened = self.webViews(in: wrapper).first else { return false }
            return abs(((try await reopened.evaluateJavaScript(script) as? Double) ?? 10000) - y) < 3
        }
        XCTAssertEqual(engine.automaticScrollState, .stopped)
    }

    @MainActor func testAutomaticScrollCrossesChapterStopsAtBookEndAndBackgroundDoesNotResume() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let scroll = try continuousScroll(engine)
        let first = try XCTUnwrap(view(identifier: "readium.chapter.1", in: scroll))
        let height = scroll.bounds.height - scroll.contentInset.top - scroll.contentInset.bottom
        scroll.contentOffset.y = first.frame.maxY - height * 1.75 - scroll.contentInset.top
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.2", in: engine.viewController.view) else { return false }
            return abs(wrapper.frame.minY - first.frame.maxY) < 2 && wrapper.frame.height > 100
        }
        let second = try XCTUnwrap(view(identifier: "readium.chapter.2", in: engine.viewController.view))
        scroll.contentOffset.y = second.frame.minY - scroll.bounds.height - scroll.contentInset.top - 80
        let before = scroll.contentOffset.y
        try engine.startAutomaticScroll(screensPerMinute: 6)
        try await waitUntil {
            let titles = try await self.visibleTitles(engine)
            return scroll.contentOffset.y > before + 100 && titles.contains("第二章 云海")
        }
        XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
        XCTAssertEqual(engine.automaticScrollState, .paused)
        let y = scroll.contentOffset.y
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(scroll.contentOffset.y, y, accuracy: 0.5)
        scroll.contentOffset.y = max(-scroll.contentInset.top, scroll.contentSize.height - scroll.bounds.height + scroll.contentInset.bottom)
        try engine.startAutomaticScroll(screensPerMinute: 6)
        try await waitUntil { engine.automaticScrollState == .finished }
        XCTAssertNil(engine.automaticScrollSessionID)
        var reduced = ReadingInteraction(); reduced.continuousScrolling = true; reduced.reduceMotion = true
        try engine.setInteraction(reduced)
        XCTAssertThrowsError(try engine.startAutomaticScroll(screensPerMinute: 1.5))
    }
    @MainActor func testInstantScreenFrameProtectionRejectsOverlapAndClearsOnDragModeJumpAndClose() async throws {
        let engine = try screenEngine(reduced: true)
        let (window, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        try await Task.sleep(nanoseconds: 150_000_000)
        let scroll = try continuousScroll(engine)
        let parent = try XCTUnwrap(scroll.superview)
        let before = scroll.contentOffset.y
        await engine.turnPage(forward: true)
        let cover = try XCTUnwrap(view(identifier: "readium.screen-turn-cover", in: parent))
        XCTAssertTrue(cover.superview === parent)
        XCTAssertFalse(cover.isUserInteractionEnabled)
        XCTAssertTrue(cover.accessibilityElementsHidden)
        XCTAssertEqual(cover.frame.width, scroll.bounds.width, accuracy: 1)
        XCTAssertEqual(cover.frame.height, scroll.bounds.height, accuracy: 1)
        XCTAssertGreaterThan(scroll.contentOffset.y, before + 100, "Underlying location still applies immediately")
        let after = scroll.contentOffset.y
        await engine.turnPage(forward: false)
        XCTAssertEqual(scroll.contentOffset.y, after, accuracy: 1, "A rapid second command must not queue behind the retained frame")
        scroll.delegate?.scrollViewWillBeginDragging?(scroll)
        XCTAssertNil(cover.superview, "Direct manipulation removes the retained frame immediately")
        scroll.delegate?.scrollViewDidEndDragging?(scroll, willDecelerate: false)
        await engine.turnPage(forward: false)
        let nextCover = try XCTUnwrap(view(identifier: "readium.screen-turn-cover", in: parent))
        var interaction = ReadingInteraction(); interaction.continuousScrolling = true; interaction.reduceMotion = true
        try engine.setInteraction(interaction)
        XCTAssertNil(nextCover.superview)
        interaction.verticalScreenPaging = true; try engine.setInteraction(interaction)
        await engine.turnPage(forward: true)
        XCTAssertNotNil(view(identifier: "readium.screen-turn-cover", in: parent))
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        XCTAssertNil(view(identifier: "readium.screen-turn-cover", in: parent))
        await engine.turnPage(forward: true)
        try await waitUntil { self.view(identifier: "readium.screen-turn-cover", in: parent) == nil }
        let attachment = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }); attachment.name = "screen-instant-whole-window-build20"; attachment.lifetime = .keepAlways; add(attachment)
        await engine.turnPage(forward: false)
        let finalCover = try XCTUnwrap(view(identifier: "readium.screen-turn-cover", in: parent))
        engine.close()
        XCTAssertNil(finalCover.superview)
        try await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertNil(view(identifier: "readium.screen-turn-cover", in: parent), "A late task must not restore a closed session's frame")
    }

    @MainActor private func screenEngine(reduced: Bool) throws -> ReadiumReaderEngine {
        let engine = ReadiumReaderEngine()
        var interaction = ReadingInteraction()
        interaction.continuousScrolling = true; interaction.verticalScreenPaging = true; interaction.reduceMotion = reduced
        try engine.setInteraction(interaction); engine.setContinuousScrolling(true)
        return engine
    }

    @MainActor private func proposedScreenTarget(_ scroll: UIScrollView, start: CGFloat,
                                               distance: CGFloat, velocity: CGFloat) -> CGFloat {
        scroll.setContentOffset(CGPoint(x: 0, y: start), animated: false)
        scroll.delegate?.scrollViewWillBeginDragging?(scroll)
        scroll.setContentOffset(CGPoint(x: 0, y: scroll.contentOffset.y + distance), animated: false)
        var target = CGPoint(x: 0, y: 9_999_999)
        withUnsafeMutablePointer(to: &target) { pointer in
            scroll.delegate?.scrollViewWillEndDragging?(scroll, withVelocity: CGPoint(x: 0, y: velocity), targetContentOffset: pointer)
        }
        scroll.delegate?.scrollViewDidEndDragging?(scroll, willDecelerate: false)
        return target.y
    }

    @MainActor func testVerticalScreenNativeTargetsOverlapReverseCancelClampAndLeaveContinuousUnchanged() async throws {
        let engine = try screenEngine(reduced: true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let scroll = try continuousScroll(engine)
        try await waitUntil { scroll.contentSize.height > scroll.bounds.height * 5 }
        XCTAssertEqual(scroll.accessibilityValue, "上下整屏"); XCTAssertEqual(scroll.decelerationRate, .fast)
        let step = (scroll.bounds.height - scroll.contentInset.top - scroll.contentInset.bottom) * 0.9
        let origin = scroll.contentOffset.y + step * 2
        XCTAssertEqual(proposedScreenTarget(scroll, start: origin, distance: 140, velocity: 5), origin + step, accuracy: 2)
        XCTAssertEqual(proposedScreenTarget(scroll, start: origin, distance: -140, velocity: -5), origin - step, accuracy: 2)
        XCTAssertEqual(proposedScreenTarget(scroll, start: origin, distance: step * 1.8, velocity: -5), origin + step, accuracy: 2)
        XCTAssertEqual(proposedScreenTarget(scroll, start: origin, distance: -step * 1.8, velocity: 5), origin - step, accuracy: 2)
        XCTAssertEqual(proposedScreenTarget(scroll, start: origin, distance: 8, velocity: 0), origin, accuracy: 2)
        let lower = -scroll.contentInset.top
        XCTAssertEqual(proposedScreenTarget(scroll, start: lower, distance: -20, velocity: -2), lower, accuracy: 2)
        var interaction = ReadingInteraction(); interaction.continuousScrolling = true
        try engine.setInteraction(interaction)
        XCTAssertEqual(scroll.accessibilityValue, "上下连续滚动"); XCTAssertEqual(scroll.decelerationRate, .normal)
        XCTAssertEqual(proposedScreenTarget(scroll, start: origin, distance: 140, velocity: 5), 9_999_999)
    }

    @MainActor func testVerticalScreenCommandsCrossPhysicalChapterBoundaryAndRejectOverlappingAnimation() async throws {
        let engine = try screenEngine(reduced: false)
        let (window, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#start")
        let scroll = try continuousScroll(engine)
        let first = try XCTUnwrap(view(identifier: "readium.chapter.1", in: scroll))
        let step = (scroll.bounds.height - scroll.contentInset.top - scroll.contentInset.bottom) * 0.9
        scroll.setContentOffset(CGPoint(x: 0, y: first.frame.maxY - step * 1.75 - scroll.contentInset.top), animated: false)
        try await waitUntil {
            guard let second = self.view(identifier: "readium.chapter.2", in: scroll) else { return false }
            return abs(second.frame.minY - first.frame.maxY) < 2 && second.frame.height >= 96
        }
        let before = scroll.contentOffset.y
        async let a: Void = engine.turnPage(forward: true)
        async let b: Void = engine.turnPage(forward: true)
        _ = await (a, b)
        try await waitUntil { scroll.contentOffset.y > before + 100 }
        try await Task.sleep(nanoseconds: 600_000_000)
        if !UIAccessibility.isReduceMotionEnabled {
            XCTAssertEqual(scroll.contentOffset.y, before + step, accuracy: 3, "Native animation must not queue a second screen")
        }
        try await waitUntil { (try await self.visibleTitles(engine)).contains("第二章 云海") }
        let attachment = XCTAttachment(image: UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }); attachment.name = "screen-cross-chapter-whole-window-build19"; attachment.lifetime = .keepAlways; add(attachment)
        var interaction = ReadingInteraction(); interaction.continuousScrolling = true
        interaction.verticalScreenPaging = true; interaction.reduceMotion = true; try engine.setInteraction(interaction)
        let reverseFrom = scroll.contentOffset.y
        await engine.turnPage(forward: false)
        XCTAssertEqual(scroll.contentOffset.y, reverseFrom - step, accuracy: 3, "Reduced command must apply immediately")
        XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
    }

    @MainActor func testVerticalScreenKeepsNonzeroDOMAnchorAcrossPolicyToggleAndReopen() async throws {
        let engine = try screenEngine(reduced: true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let web = try resourceWebView(engine, index: 1)
        try await waitUntil { abs((try await web.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double) ?? 10000) < 5 }
        await engine.turnPage(forward: true)
        try await waitUntil {
            guard let position = engine.currentPosition,
                  let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any],
                  let locations = json["locations"] as? [String: Any], let range = locations["domRange"] as? [String: Any],
                  let start = range["start"] as? [String: Any] else { return false }
            return (start["charOffset"] as? Int ?? 0) > 100
        }
        let script = "document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000"
        let beforeValue = try await web.evaluateJavaScript(script) as? Double
        let before = try XCTUnwrap(beforeValue)
        XCTAssertLessThan(before, -400)
        var interaction = ReadingInteraction(); interaction.continuousScrolling = true; interaction.reduceMotion = true
        try engine.setInteraction(interaction)
        let afterToggle = try await web.evaluateJavaScript(script) as? Double
        XCTAssertEqual(try XCTUnwrap(afterToggle), before, accuracy: 3)
        interaction.verticalScreenPaging = true; try engine.setInteraction(interaction)
        let saved = try XCTUnwrap(engine.currentPosition)
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        engine.close(); try await engine.open(book: book, fileURL: url, position: saved)
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view), let reopened = self.webViews(in: wrapper).first else { return false }
            return abs(((try await reopened.evaluateJavaScript(script) as? Double) ?? 10000) - before) < 3
        }
        XCTAssertEqual(try continuousScroll(engine).accessibilityValue, "上下整屏")
    }

    // Do not read rectangles/styles or wrap ResizeObserver/rAF: those reads can
    // force layout and change the initial-restore race being observed.
    @MainActor private static func pagedNavigationWriterProbe() -> WKUserScript {
        WKUserScript(source: """
            (()=>{
              const trace=window.__xrPagedRestoreTrace=[], writers=window.__xrPagedRestoreWriters=[];
              const record=(phase,args)=>{
                const value=args[0], requested=typeof value==='object'?value?.left:value;
                writers.push({phase,requested,at:performance.now(),stack:String(new Error().stack||'')});
                if(writers.length>24)writers.shift();
              };
              const windowScroll=window.scrollTo;
              window.scrollTo=function(...args){record('window-scrollTo',args);return windowScroll.apply(this,args);};
              const elementScroll=Element.prototype.scrollTo;
              Element.prototype.scrollTo=function(...args){record('element-scrollTo',args);return elementScroll.apply(this,args);};
              const descriptor=Object.getOwnPropertyDescriptor(Element.prototype,'scrollLeft');
              if(descriptor?.set)Object.defineProperty(Element.prototype,'scrollLeft',{
                ...descriptor,set(value){record('scrollLeft',[value]);return descriptor.set.call(this,value);}
              });
              addEventListener('scroll',()=>{
                trace.push({at:performance.now(),x:scrollX,y:scrollY});if(trace.length>24)trace.shift();
              },{passive:true});
            })()
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }

    @MainActor private static func pagedRestoreProbe() -> WKUserScript {
        WKUserScript(source: """
            (()=>{
              const trace=window.__xrPagedRestoreTrace=[], writers=window.__xrPagedRestoreWriters=[];
              const writerStack=()=>String(new Error().stack||'').split('\\n').slice(0,5).join('|');
              function record(phase,args,stack){
                const node=document.getElementById('long-paragraph')?.firstChild;
                let rect=null;
                if(node?.length){const r=document.createRange();r.setStart(node,0);r.setEnd(node,1);rect=r.getClientRects()[0];}
                trace.push({phase,at:performance.now(),href:location.pathname,width:innerWidth,height:innerHeight,x:scrollX,
                  requested:typeof args?.[0]==='object'?args[0].left:args?.[0],
                  firstX:rect?.left,firstY:rect?.top,ready:document.readyState,
                  fontReady:window.__xianxiaReadingFontReady,fontStatus:document.fonts.status,
                  family:document.body?getComputedStyle(document.body).fontFamily:null,
                  paragraphFamily:document.getElementById('long-paragraph')?getComputedStyle(document.getElementById('long-paragraph')).fontFamily:null,
                  documentWidth:document.documentElement.scrollWidth,
                  faces:Array.from(document.fonts).map(f=>({family:f.family,status:f.status}))});
                if(trace.length>16)trace.shift();
                if(stack){writers.push({phase,at:performance.now(),x:scrollX,
                  requested:typeof args?.[0]==='object'?args[0].left:args?.[0],stack});
                  if(writers.length>16)writers.shift();}
              }
              // Observe only frames scheduled inside a ResizeObserver callback.
              // Preserve original scheduling, callback arguments and return values.
              let inResize=false;
              const frame=window.requestAnimationFrame;
              window.requestAnimationFrame=function(callback){
                if(!inResize)return frame.call(this,callback);
                return frame.call(this,function(...args){
                  record('resize-frame-before',[]);
                  try{return callback.apply(this,args);}finally{record('resize-frame-after',[]);}
                });
              };
              const Observer=window.ResizeObserver;
              window.ResizeObserver=class extends Observer {
                constructor(callback){super((entries,observer)=>{
                  const previous=inResize;inResize=true;
                  try{callback.call(observer,entries,observer);}finally{inResize=previous;}
                });}
              };
              // Readium's own scrollToPosition uses Element.scrollTo, while
              // snapCurrentPosition writes scrollLeft. Observe both public paths
              // without replacing their values, scheduling or return behavior.
              const elementScroll=Element.prototype.scrollTo;
              Element.prototype.scrollTo=function(...args){
                if(this!==document.scrollingElement)return elementScroll.apply(this,args);
                record('element-before',args,writerStack());
                try{return elementScroll.apply(this,args);}finally{record('element-after',args);}
              };
              const left=Object.getOwnPropertyDescriptor(Element.prototype,'scrollLeft');
              if(left?.set&&left.configurable){Object.defineProperty(Element.prototype,'scrollLeft',{
                ...left,set(value){
                  const root=this===document.scrollingElement;
                  if(root)record('left-before',[value],writerStack());
                  try{return left.set.call(this,value);}finally{if(root)record('left-after',[value]);}
                }});}
              const scroll=window.scrollTo;
              window.scrollTo=function(...args){record('before',args);const result=scroll.apply(window,args);record('after',args);return result;};
              window.addEventListener('scroll',()=>record('scroll',[]),{passive:true});
            })()
            """, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }

    @MainActor private weak var diagnosticEngine: ReadiumReaderEngine?
    @MainActor private weak var diagnosticHost: HarnessHostController?
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

    @MainActor private final class HarnessHostController: UIHostingController<Harness> {
        private(set) var hasAppeared = false
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            hasAppeared = true
        }
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            hasAppeared = false
        }
    }

    private enum RenderFailure: Error { case timedOut(String, String), invalidProbe }

    @MainActor private func mount(_ engine: ReadiumReaderEngine) throws -> (UIWindow, OverlayState) {
        diagnosticEngine = engine
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive })
        let previous = scene.windows.first { $0.isKeyWindow }
        let state = OverlayState()
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        let host = HarnessHostController(rootView: Harness(controller: engine.viewController, state: state))
        diagnosticHost = host
        window.rootViewController = host
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
        // Opening a publication is a separate step from attaching a SwiftUI
        // host. Match the real foreground presentation before starting WebKit.
        try await waitUntil {
            guard let host = self.diagnosticHost, host.hasAppeared,
                  let window = engine.viewController.view.window,
                  window.isKeyWindow, !window.isHidden,
                  window.windowScene?.activationState == .foregroundActive else { return false }
            let frame = engine.viewController.view.convert(engine.viewController.view.bounds, to: window)
            return frame.width > 0 && frame.height > 0 && frame.intersects(window.bounds)
        }
        print("RENDER_HOST_READY uptimeMs=\(Int(ProcessInfo.processInfo.systemUptime * 1000)) appeared=\(diagnosticHost?.hasAppeared == true) key=\(engine.viewController.view.window?.isKeyWindow == true) bounds=\(engine.viewController.view.bounds)")
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        let book = Book(title: "阅读页面测试", format: .epub, filePath: "reader-layout.epub")
        try await engine.open(book: book, fileURL: url, position: nil)
        return (book, try XCTUnwrap(engine.viewController.children.first))
    }

    @MainActor private func probe(_ navigator: UIViewController, engine: ReadiumReaderEngine,
                                 resource: String, continuousResourceIndex: Int? = nil) async throws -> [String: Any] {
        let deadline = Date().addingTimeInterval(20)
        var lastProbe = "No visible web view"
        let script = """
        (() => {
          const image = document.querySelector('img');
          const rect = image?.getBoundingClientRect();
          return {href: location.pathname, height: innerHeight, width: innerWidth,
                  ready: document.readyState === 'complete' && (!image || image.complete),
                  imageHeight: rect?.height ?? 0, imageWidth: rect?.width ?? 0,
                  fit: image ? getComputedStyle(image).objectFit : '', title: document.title,
                  mediaLimit: getComputedStyle(document.documentElement).getPropertyValue('--RS__maxMediaHeight')};
        })()
        """
        while Date() < deadline {
            let candidate: WKWebView?
            if let index = continuousResourceIndex {
                candidate = view(identifier: "readium.chapter.\(index)", in: navigator.view).flatMap { webViews(in: $0).first }
            } else { candidate = visibleWebView(in: navigator.view) }
            if let webView = candidate, continuousResourceIndex == nil || webView.scrollView.alpha > 0.99 {
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
                   data["ready"] as? Bool == true, locatedHref?.hasSuffix(resource) == true {
                    if continuousResourceIndex != nil {
                        let legacy = visibleWebView(in: navigator.view)
                        let legacyHref = try await legacy?.evaluateJavaScript("location.pathname")
                        print("CONTINUOUS_PROBE_SELECTED activeHref=\(data["href"] ?? "nil") legacyHref=\(String(describing: legacyHref)) same=\(legacy === webView) legacyAlpha=\(String(describing: legacy?.scrollView.alpha)) hostAppeared=\(diagnosticHost?.hasAppeared == true)")
                    }
                    return data
                }
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        let native = webViews(in: navigator.view).map { "alpha=\($0.scrollView.alpha) hidden=\($0.isHidden) window=\($0.window != nil) offset=\($0.scrollView.contentOffset) size=\($0.scrollView.contentSize)" }.joined(separator: "; ")
        throw RenderFailure.timedOut(resource, lastProbe + "; hostAppeared=\(diagnosticHost?.hasAppeared == true) key=\(engine.viewController.view.window?.isKeyWindow == true) continuousResource=\(String(describing: continuousResourceIndex)); \(native)")
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
            let metrics = XCTAttachment(string: "scrolling=\(scrolling); DOM=\(data); native viewport=\(navigator.view.bounds)")
            metrics.name = scrolling ? "cover-metrics-scrolling" : "cover-metrics-paginated"
            metrics.lifetime = .keepAlways
            add(metrics)
            let height = try XCTUnwrap(data["height"] as? Double)
            let imageHeight = try XCTUnwrap(data["imageHeight"] as? Double)
            XCTAssertGreaterThan(height, Double(window.bounds.height) * 0.7)
            XCTAssertGreaterThan(imageHeight, height * 0.65)
            XCTAssertLessThanOrEqual(imageHeight, height + 2, "scrolling=\(scrolling); \(data)")
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

    @MainActor private func waitUntil(caller: String = #function, line: Int = #line,
                                     _ condition: @MainActor () async throws -> Bool) async throws {
        let deadline = Date().addingTimeInterval(30)
        while Date() < deadline {
            let ready = try await condition()
            if ready { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        var diagnostic = "\(caller):\(line)"
        if let engine = diagnosticEngine {
            let root = engine.viewController.view!
            diagnostic += "\nhostAppeared=\(diagnosticHost?.hasAppeared == true) windowKey=\(root.window?.isKeyWindow == true) windowHidden=\(String(describing: root.window?.isHidden)) scene=\(String(describing: root.window?.windowScene?.activationState)) rootFrame=\(root.frame)"
            diagnostic += "\nposition=\(engine.currentPosition.map { String(decoding: $0.locatorData, as: UTF8.self) } ?? "nil")"
            diagnostic += "\ncontinuous state=\(engine.continuousDiagnosticState)"
            if let scroll = view(identifier: "readium.continuous-scroll", in: root) as? UIScrollView {
                diagnostic += "\nouter offset=\(scroll.contentOffset) inset=\(scroll.contentInset) content=\(scroll.contentSize) bounds=\(scroll.bounds)"
            }
            for webView in webViews(in: root) {
                let visibleRect = clippedVisibleRect(webView, root: root)
                diagnostic += "\nweb frame=\(webView.frame) visible=\(visibleRect) offset=\(webView.scrollView.contentOffset)"
                guard webView.window != nil, visibleRect.width > 0, visibleRect.height > 0 else {
                    diagnostic += " DOM not queried: hidden or detached native viewport"
                    continue
                }
                do {
                    let value = try await webView.evaluateJavaScript("({href:location.pathname,ready:document.readyState,y:scrollY,height:innerHeight,line12:document.getElementById('line-12')?.getBoundingClientRect().top,line18:document.getElementById('line-18')?.getBoundingClientRect().top,long:document.getElementById('long-paragraph')?.getBoundingClientRect().top,canonicalTarget:JSON.stringify(window.__xrCanonicalGoTarget),trace:JSON.stringify(window.__xrPagedRestoreTrace),writers:JSON.stringify(window.__xrPagedRestoreWriters),caretOffsets:[0.2,0.5,0.8].map(x=>document.caretRangeFromPoint(innerWidth*x,2)?.startOffset)})")
                    diagnostic += " DOM=\(String(describing: value))"
                } catch { diagnostic += " DOM error=\(error.localizedDescription)" }
            }
        }
        let attachment = XCTAttachment(string: diagnostic)
        attachment.name = "continuous-failure-\(caller)-\(line)"; attachment.lifetime = .keepAlways; add(attachment)
        print("CONTINUOUS_DIAGNOSTIC \(diagnostic)")
        XCTFail("Continuous reader did not reach expected state at \(caller):\(line)")
        throw RenderFailure.timedOut("continuous", diagnostic)
    }

    @MainActor private func view(identifier: String, in root: UIView) -> UIView? {
        if root.accessibilityIdentifier == identifier { return root }
        for child in root.subviews {
            if let found = view(identifier: identifier, in: child) { return found }
        }
        return nil
    }

    @MainActor private func continuousScroll(_ engine: ReadiumReaderEngine) throws -> UIScrollView {
        try XCTUnwrap(view(identifier: "readium.continuous-scroll", in: engine.viewController.view) as? UIScrollView)
    }

    @MainActor private func clippedVisibleRect(_ webView: WKWebView, root: UIView) -> CGRect {
        var visible = webView.convert(webView.bounds, to: root).intersection(root.bounds)
        var ancestor: UIView? = webView
        while let current = ancestor, current !== root {
            if current.isHidden || current.alpha < 0.1 { return .null }
            if current.clipsToBounds { visible = visible.intersection(current.convert(current.bounds, to: root)) }
            ancestor = current.superview
        }
        return visible
    }

    @MainActor private func visibleTitles(_ engine: ReadiumReaderEngine) async throws -> [String] {
        let root = engine.viewController.view!
        var titles: [String] = []
        for webView in webViews(in: root) where clippedVisibleRect(webView, root: root).height > 30 {
            let value = try await webView.evaluateJavaScript("document.title")
            if let title = value as? String { titles.append(title) }
        }
        return titles
    }

    @MainActor private func resourceWebView(_ engine: ReadiumReaderEngine, index: Int) throws -> WKWebView {
        let wrapper = try XCTUnwrap(view(identifier: "readium.chapter.\(index)", in: engine.viewController.view))
        return try XCTUnwrap(webViews(in: wrapper).first)
    }

    @MainActor private func jump(_ engine: ReadiumReaderEngine, book: Book, href: String) async throws {
        try await engine.go(to: Chapter(id: "fixture:\(href)", bookID: book.id, ordinal: 1, title: "测试目标", href: href))
        try await waitUntil {
            guard let position = engine.currentPosition,
                  let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any] else { return false }
            return (json["href"] as? String)?.hasSuffix(String(href.split(separator: "#")[0])) == true
        }
    }

    @MainActor func testContinuousBoundaryShowsTwoResourcesAndScrollsBack() async throws {
        let engine = ReadiumReaderEngine()
        engine.setContinuousScrolling(true)
        let (window, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.continuousLoadedResourceCount >= 1 && engine.currentPosition != nil }
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#start")
        let scroll = try continuousScroll(engine)
        let first = try XCTUnwrap(view(identifier: "readium.chapter.1", in: scroll))
        scroll.setContentOffset(CGPoint(x: 0, y: first.frame.maxY - 180 - scroll.contentInset.top), animated: false)
        try await waitUntil {
            let titles = try await self.visibleTitles(engine)
            return titles.contains("第一章 山门") && titles.contains("第二章 云海")
        }
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            _ = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = "continuous-two-chapter-boundary"; attachment.lifetime = .keepAlways; add(attachment)
        // A reverse drag crosses the SAME physical boundary without chapter go().
        scroll.setContentOffset(CGPoint(x: 0, y: first.frame.minY - 150 - scroll.contentInset.top), animated: false)
        try await waitUntil {
            let titles = try await self.visibleTitles(engine)
            return titles.contains("封面完整性") && titles.contains("第一章 山门")
        }
        XCTAssertLessThanOrEqual(engine.continuousLoadedResourceCount, 12)
    }

    @MainActor func testContinuousFragmentAndDOMBookmarkRestore() async throws {
        // Stage-only fixture diagnostics: retain the original navigation/geometry
        // conditions and timeouts if a future run fails with navigationFailed.
        var stage = "initial-open"
        defer { print("[fragment-bookmark-test] last stage: \(stage)") }
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        stage = "fragment-jump"
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#line-12")
        let webView = try resourceWebView(engine, index: 1)
        try await waitUntil {
            let y = try await webView.evaluateJavaScript("document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 5
        }
        try await waitUntil {
            guard let position = engine.currentPosition,
                  let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any],
                  let locations = json["locations"] as? [String: Any],
                  let text = json["text"] as? [String: Any] else { return false }
            return (json["href"] as? String)?.hasSuffix("one.xhtml") == true && locations["cssSelector"] != nil
                && ((text["before"] as? String ?? "") + (text["highlight"] as? String ?? "")).contains("第12段")
        }
        let saved = try XCTUnwrap(engine.currentPosition)
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        engine.close()
        stage = "bookmark-reopen"
        try await engine.open(book: book, fileURL: url, position: saved)
        try await waitUntil {
            self.view(identifier: "readium.chapter.1", in: engine.viewController.view) != nil
        }
        let reopened = try resourceWebView(engine, index: 1)
        stage = "reopened-geometry"
        try await waitUntil {
            let y = try await reopened.evaluateJavaScript("document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 5
        }
        stage = "complete"
    }

    @MainActor func testContinuousHeightChangeKeepsVisibleDOMAnchor() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#line-12")
        let webView = try resourceWebView(engine, index: 1)
        try await waitUntil {
            let y = try await webView.evaluateJavaScript("document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000") as? Double
            guard let position = engine.currentPosition,
                  let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any],
                  let text = json["text"] as? [String: Any] else { return false }
            return abs(y ?? 10000) < 5 && ((text["before"] as? String ?? "") + (text["highlight"] as? String ?? "")).contains("第12段")
        }
        let script = "document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000"
        let beforeValue = try await webView.evaluateJavaScript(script) as? Double
        let before = try XCTUnwrap(beforeValue)
        // Models an image above the current paragraph acquiring its final height.
        _ = try await webView.evaluateJavaScript("document.getElementById('line-2').style.minHeight='500px'")
        try await Task.sleep(nanoseconds: 500_000_000)
        try await waitUntil {
            let y = try await webView.evaluateJavaScript(script) as? Double
            return abs((y ?? 10000) - before) < 3
        }
    }

    @MainActor func testContinuousLongParagraphRestoresCharacterAndViewportOffset() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        let target = try resourceWebView(engine, index: 1)
        try await waitUntil {
            let y = try await target.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 5
        }
        let scroll = try continuousScroll(engine)
        scroll.setContentOffset(CGPoint(x: 0, y: scroll.contentOffset.y + 600), animated: false)
        try await waitUntil {
            guard let position = engine.currentPosition,
                  let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any],
                  let locations = json["locations"] as? [String: Any],
                  let range = locations["domRange"] as? [String: Any],
                  let start = range["start"] as? [String: Any] else { return false }
            return (start["charOffset"] as? Int ?? 0) > 100
        }
        let saved = try XCTUnwrap(engine.currentPosition)
        let webView = try resourceWebView(engine, index: 1)
        let y = try await webView.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double
        let before = try XCTUnwrap(y)
        XCTAssertLessThan(before, -400)
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        engine.close()
        try await engine.open(book: book, fileURL: url, position: saved)
        try await waitUntil { engine.continuousLoadedResourceCount > 0 }
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let reopened = self.webViews(in: wrapper).first else { return false }
            let value = try await reopened.evaluateJavaScript("document.getElementById('long-paragraph')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs((value ?? 10000) - before) < 3
        }
    }

    @MainActor func testContinuousLayoutFailureShowsRetryAndRecoversTheAnchor() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#line-12")
        let webView = try resourceWebView(engine, index: 1)
        try await waitUntil {
            let y = try await webView.evaluateJavaScript("document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 5
        }
        try await waitUntil {
            guard let position = engine.currentPosition,
                  let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any],
                  let text = json["text"] as? [String: Any] else { return false }
            return ((text["before"] as? String ?? "") + (text["highlight"] as? String ?? "")).contains("第12段")
        }
        // Trigger an invalid late measurement. The reader must expose a
        // retry, release the failed DOM, and reload from the original EPUB.
        _ = try await webView.evaluateJavaScript("document.body.remove()")
        try await waitUntil {
            guard let retry = self.view(identifier: "readium.continuous-retry", in: engine.viewController.view) as? UIButton else { return false }
            let root = engine.viewController.view!
            return !retry.isHidden && retry.superview?.isHidden == false
                && retry.convert(retry.bounds, to: root).intersection(root.bounds).height > 20
        }
        let retry = try XCTUnwrap(view(identifier: "readium.continuous-retry", in: engine.viewController.view) as? UIButton)
        retry.sendActions(for: .touchUpInside)
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let restored = self.webViews(in: wrapper).first else { return false }
            let y = try await restored.evaluateJavaScript("document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 5
        }
    }

    @MainActor func testContinuousSearchJumpAndModeRoundTripKeepTheParagraph() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        _ = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        let provider = try XCTUnwrap(engine.searchProvider)
        let session = try await provider.search(query: "第18段原创")
        let batch = try await session.next()
        await session.cancel()
        let hit = try XCTUnwrap(batch?.first)
        try await engine.go(to: hit.position)
        try await waitUntil {
            let webView = try self.resourceWebView(engine, index: 1)
            let y = try await webView.evaluateJavaScript("document.getElementById('line-18')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 50
        }
        engine.setContinuousScrolling(false)
        try await waitUntil { self.view(identifier: "readium.continuous-scroll", in: engine.viewController.view) == nil }
        try await waitUntil {
            guard let webView = self.visibleWebView(in: engine.viewController.view) else { return false }
            let ready = try await webView.evaluateJavaScript("document.title === '第一章 山门' && document.readyState === 'complete'") as? Bool
            return ready == true
        }
        // DOM readiness precedes Readium's asynchronous spread positioning.
        // Observe the actual restored paragraph before issuing a second mode change.
        try await waitUntil {
            guard let webView = self.visibleWebView(in: engine.viewController.view) else { return false }
            let visible = try await webView.evaluateJavaScript("(() => { const r = document.getElementById('line-18')?.getBoundingClientRect(); return !!r && r.bottom > 0 && r.top < innerHeight && r.right > 0 && r.left < innerWidth; })()") as? Bool
            return visible == true
        }
        engine.setContinuousScrolling(true)
        try await waitUntil { engine.continuousLoadedResourceCount > 0 }
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let webView = self.webViews(in: wrapper).first else { return false }
            let visible = try await webView.evaluateJavaScript("(() => { const r = document.getElementById('line-18')?.getBoundingClientRect(); return !!r && r.bottom > 0 && r.top < innerHeight; })()") as? Bool
            return visible == true
        }
    }

    @MainActor func testThousandResourcesUseBoundedWindowAndCloseClearsViews() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "window-long", withExtension: "epub", subdirectory: "Fixtures"))
        let book = Book(title: "千章窗口测试", format: .epub, filePath: "window-long.epub")
        try await engine.open(book: book, fileURL: url, position: nil)
        try await waitUntil { engine.currentPosition != nil }
        for index in [500, 999, 100, 0] {
            try await jump(engine, book: book, href: "OEBPS/chapter-\(index).xhtml#line-2")
            try await waitUntil {
                guard let position = engine.currentPosition,
                      let json = try JSONSerialization.jsonObject(with: position.locatorData) as? [String: Any] else { return false }
                return (json["href"] as? String)?.hasSuffix("chapter-\(index).xhtml") == true
            }
            XCTAssertLessThanOrEqual(webViews(in: engine.viewController.view).count, 12)
        }
        weak var releasedWebView: WKWebView? = try resourceWebView(engine, index: 0)
        engine.close()
        XCTAssertTrue(engine.viewController.children.isEmpty)
        XCTAssertTrue(webViews(in: engine.viewController.view).isEmpty)
        try await waitUntil { releasedWebView == nil }
    }

    @MainActor func testLateModeChangeCannotRebuildReopenedContinuousReader() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        engine.setContinuousScrolling(false)
        await Task.yield()
        engine.close()
        engine.setContinuousScrolling(true)
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        try await engine.open(book: book, fileURL: url, position: nil)
        try await waitUntil { engine.continuousLoadedResourceCount >= 2 && engine.currentPosition != nil }
        XCTAssertNotNil(view(identifier: "readium.continuous-scroll", in: engine.viewController.view))
    }

    @MainActor func testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge() async throws {
        let script = WKUserScript(source: """
        const nativeFrame = window.requestAnimationFrame.bind(window);
        window.requestAnimationFrame = callback => {
          if (String(callback).includes('spreadLoaded')) {
            window.__xianxiaBlockedSpreadLoaded = true;
            return 0;
          }
          return nativeFrame(callback);
        };
        """, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let engine = ReadiumReaderEngine(additionalUserScripts: [script]); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        let cover = try resourceWebView(engine, index: 0)
        let blocked = try await cover.evaluateJavaScript("window.__xianxiaBlockedSpreadLoaded === true") as? Bool
        XCTAssertEqual(blocked, true, "Regression must suppress the actual spreadLoaded animation-frame callback")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#line-12")
        let text = try resourceWebView(engine, index: 1)
        try await waitUntil {
            let y = try await text.evaluateJavaScript("document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000") as? Double
            return abs(y ?? 10000) < 5
        }
        let textBlocked = try await text.evaluateJavaScript("window.__xianxiaBlockedSpreadLoaded === true") as? Bool
        XCTAssertEqual(textBlocked, true)
    }

    @MainActor func testRetiredContinuousProcessCannotReloadPagedReader() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        let (_, state) = try mount(engine); state.visible = false
        _ = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        let retiredWebView = try resourceWebView(engine, index: 0)
        let retiredDelegate = try XCTUnwrap(retiredWebView.navigationDelegate)
        let retiredSpread = try XCTUnwrap(retiredWebView.superview)
        defer { withExtendedLifetime(retiredSpread) {} }

        engine.setContinuousScrolling(false)
        try await waitUntil {
            guard self.view(identifier: "readium.continuous-scroll", in: engine.viewController.view) == nil,
                  let webView = self.visibleWebView(in: engine.viewController.view) else { return false }
            return try await webView.evaluateJavaScript("document.readyState === 'complete' && document.title.length > 0") as? Bool == true
        }
        let activeWebView = try XCTUnwrap(visibleWebView(in: engine.viewController.view))
        // Deliver the public WKNavigationDelegate callback after the old
        // chapter has been removed. It must not reload the new paged layout.
        retiredDelegate.webViewWebContentProcessDidTerminate?(retiredWebView)
        try await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertTrue(visibleWebView(in: engine.viewController.view) === activeWebView)
        XCTAssertNil(view(identifier: "readium.continuous-scroll", in: engine.viewController.view))
    }

    @MainActor func testEPUBAppearanceUsesRealCSSAndPreservesAnchorAcrossReflowAndReopen() async throws {
        let engine = ReadiumReaderEngine(); engine.setContinuousScrolling(true)
        var appearance = ReadingAppearance(); appearance.fontScale = 1
        try engine.setAppearance(appearance)
        let (_, state) = try mount(engine); state.visible = false
        let (book, _) = try await open(engine)
        try await waitUntil { engine.currentPosition != nil }
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#line-12")
        let positionScript = "document.getElementById('line-12')?.getBoundingClientRect().top ?? 10000"
        try await waitUntil {
            let web = try self.resourceWebView(engine, index: 1)
            return abs(try await web.evaluateJavaScript(positionScript) as? Double ?? 10000) < 5
        }
        for theme in ReadingTheme.allCases {
            appearance.theme = theme; appearance.fontScale = 1.4; appearance.lineHeight = 1.9
            try engine.setAppearance(appearance)
            let rgb = theme.backgroundRGB
            let expected = "rgb(\((rgb >> 16) & 255), \((rgb >> 8) & 255), \(rgb & 255))"
            try await waitUntil {
                let web = try self.resourceWebView(engine, index: 1)
                let color = try await web.evaluateJavaScript("getComputedStyle(document.documentElement).backgroundColor") as? String
                let y = try await web.evaluateJavaScript(positionScript) as? Double ?? 10000
                return color == expected && abs(y) < 3
            }
        }
        let image = try await resourceWebView(engine, index: 1).takeSnapshot(configuration: nil)
        let attachment = XCTAttachment(image: image); attachment.name = "epub-oled-reflow-build15"
        attachment.lifetime = .keepAlways; add(attachment)
        let saved = try XCTUnwrap(engine.currentPosition)
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        engine.close()
        try await engine.open(book: book, fileURL: url, position: saved)
        try await waitUntil {
            guard let wrapper = self.view(identifier: "readium.chapter.1", in: engine.viewController.view),
                  let web = self.webViews(in: wrapper).first else { return false }
            return abs(try await web.evaluateJavaScript(positionScript) as? Double ?? 10000) < 3
        }
    }

    @MainActor func testPagedTypographyKeepsNonzeroTextAnchorInsteadOfOldPageOffset() async throws {
        let engine = ReadiumReaderEngine()
        var appearance = ReadingAppearance(); appearance.fontScale = 1
        try engine.setAppearance(appearance)
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        _ = try await probe(navigator, engine: engine, resource: "one.xhtml")
        for _ in 0..<3 { await engine.turnPage(forward: true) }
        let web = try XCTUnwrap(visibleWebView(in: engine.viewController.view))
        let pointValue = try await web.evaluateJavaScript("""
            (() => {const r=document.caretRangeFromPoint(innerWidth*.2,2);
            return r?.startContainer.parentElement?.closest('#long-paragraph') ? r.startOffset : null;})()
            """) as? Int
        let character = try XCTUnwrap(pointValue); XCTAssertGreaterThan(character, 100)
        let originalFont = try await web.evaluateJavaScript("parseFloat(getComputedStyle(document.getElementById('long-paragraph')).fontSize)") as? Double
        let fontBefore = try XCTUnwrap(originalFont)
        let initial = XCTAttachment(string: "Expected long-paragraph UTF16 offset \(character) to stay in viewport after 180 percent reflow and reopen.")
        initial.name = "paged-appearance-original-character"; initial.lifetime = .keepAlways; add(initial)
        let script = """
            (() => {const n=document.getElementById('long-paragraph')?.firstChild;if(!n)return false;const r=document.createRange();
            r.setStart(n,\(character));r.setEnd(n,\(character+1));const b=r.getBoundingClientRect();
            return b.left >= -1 && b.left < innerWidth && b.top >= -1 && b.bottom <= innerHeight+1
              && parseFloat(getComputedStyle(n.parentElement).fontSize) > \(fontBefore * 1.7);})()
            """
        appearance.fontScale = 1.8; appearance.lineHeight = 1.9; appearance.theme = .paper
        try engine.setAppearance(appearance)
        appearance.theme = .charcoal
        try engine.setAppearance(appearance) // Cancels the pending font edit; its reflow must still happen.
        try await waitUntil {
            guard let active = self.visibleWebView(in: engine.viewController.view) else { return false }
            return try await active.evaluateJavaScript(script) as? Bool == true
        }
        let saved = try XCTUnwrap(engine.currentPosition)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: saved.locatorData) as? [String: Any])
        let savedLocations = try XCTUnwrap(payload["locations"] as? [String: Any])
        XCTAssertNotNil(savedLocations["domRange"], "Ordinary paged location callbacks must retain a full text anchor after reflow")
        let savedEvidence = XCTAttachment(data: saved.locatorData, uniformTypeIdentifier: "public.json")
        savedEvidence.name = "paged-appearance-full-anchor-before-reopen"; savedEvidence.lifetime = .keepAlways; add(savedEvidence)
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "reader-layout", withExtension: "epub", subdirectory: "Fixtures"))
        engine.close(); try await engine.open(book: book, fileURL: url, position: saved)
        try await waitUntil {
            guard let active = self.visibleWebView(in: engine.viewController.view) else { return false }
            return try await active.evaluateJavaScript(script) as? Bool == true
        }
        let rendered = try await snapshotVisibleWebView(in: engine.viewController.view)
        let attachment = XCTAttachment(image: rendered); attachment.name = "epub-paged-reflow-build15"
        attachment.lifetime = .keepAlways; add(attachment)
    }

    @MainActor func testPagedTypographyRebuildDoesNotQueueDynamicCSSIntoNewPage() async throws {
        let script = WKUserScript(source: """
            window.__xianxiaDynamicPreferenceCalls = 0;
            const originalSetCSSProperties = readium.setCSSProperties;
            readium.setCSSProperties = function(properties) {
              window.__xianxiaDynamicPreferenceCalls++;
              return originalSetCSSProperties.call(this, properties);
            };
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let engine = ReadiumReaderEngine(additionalUserScripts: [script])
        var appearance = ReadingAppearance(); appearance.fontScale = 1
        try engine.setAppearance(appearance)
        let (_, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        _ = try await probe(navigator, engine: engine, resource: "one.xhtml")
        for _ in 0..<3 { await engine.turnPage(forward: true) }
        let before = try XCTUnwrap(visibleWebView(in: engine.viewController.view))
        let size = try await before.evaluateJavaScript("parseFloat(getComputedStyle(document.getElementById('long-paragraph')).fontSize)") as? Double
        let originalFont = try XCTUnwrap(size)
        appearance.fontScale = 1.5; appearance.theme = .charcoal
        try engine.setAppearance(appearance)
        try await waitUntil {
            guard let page = self.visibleWebView(in: engine.viewController.view), page !== before else { return false }
            let value = try await page.evaluateJavaScript("(() => { const p = document.getElementById('long-paragraph'); return p ? parseFloat(getComputedStyle(p).fontSize) : 0; })()") as? Double
            return (value ?? 0) > originalFont * 1.4
        }
        let page = try XCTUnwrap(visibleWebView(in: engine.viewController.view))
        let calls = try await page.evaluateJavaScript("window.__xianxiaDynamicPreferenceCalls") as? Int
        XCTAssertEqual(calls, 0, "A rebuilt page must get final injected CSS, without a late dynamic typography write")
        // A color-only edit still updates the same live page instead of rebuilding it.
        appearance.theme = .oled; try engine.setAppearance(appearance)
        try await waitUntil {
            guard self.visibleWebView(in: engine.viewController.view) === page else { return false }
            return try await page.evaluateJavaScript("getComputedStyle(document.documentElement).backgroundColor === 'rgb(0, 0, 0)' && window.__xianxiaDynamicPreferenceCalls > 0") as? Bool == true
        }
    }

    @MainActor func testMotionPolicyReachesRealWebNavigationAndOverlappingTurnsDoNotQueue() async throws {
        let engine = ReadiumReaderEngine()
        var interaction = ReadingInteraction(); interaction.reduceMotion = true
        try engine.setInteraction(interaction)
        XCTAssertFalse(engine.navigationOptions.animated)
        let (window, state) = try mount(engine); state.visible = false
        let (book, navigator) = try await open(engine)
        _ = try await probe(navigator, engine: engine, resource: "cover.xhtml")
        try await jump(engine, book: book, href: "OEBPS/one.xhtml#long-paragraph")
        _ = try await probe(navigator, engine: engine, resource: "one.xhtml")
        let web = try XCTUnwrap(visibleWebView(in: engine.viewController.view))
        _ = try await web.evaluateJavaScript("""
            window.__xianxiaMotionCalls = [];
            const originalScrollBy = window.scrollBy;
            window.scrollBy = function(options) {
              window.__xianxiaMotionCalls.push(options.behavior);
              return originalScrollBy.call(this, options);
            };
            null;
            """)
        await engine.turnPage(forward: true)
        try await waitUntil { try await web.evaluateJavaScript("scrollX > 0") as? Bool == true }
        let first = try await web.evaluateJavaScript("window.__xianxiaMotionCalls") as? [String]
        XCTAssertEqual(first, ["instant"])
        interaction.reduceMotion = false; try engine.setInteraction(interaction)
        let expected = UIAccessibility.isReduceMotionEnabled ? "instant" : "smooth"
        async let a: Void = engine.turnPage(forward: true)
        async let b: Void = engine.turnPage(forward: true)
        _ = await (a, b)
        let calls = try await web.evaluateJavaScript("window.__xianxiaMotionCalls") as? [String]
        XCTAssertEqual(calls, ["instant", expected], "Overlapping requests must not accumulate extra page turns")
        let saved = try XCTUnwrap(engine.currentPosition)
        XCTAssertFalse(saved.locatorData.isEmpty)
        window.layoutIfNeeded()
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: image); attachment.name = "epub-motion-whole-window-build17"
        attachment.lifetime = .keepAlways; add(attachment)
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
