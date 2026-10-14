import Foundation
@testable import ReadiumAdapter
import ReadiumShared
import SwiftUI
import UIKit
import WebKit
import XCTest
import XianxiaCore
@testable import XianxiaReader

final class TXTReadingTests: XCTestCase {
    private enum Failure: Error { case timedOut(String) }
    @MainActor private func context() throws -> (URL, AppServices) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let files = try BookFileStore(root: root.appendingPathComponent("Storage"))
        let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return (root,AppServices(repository: repository,files: files))
    }
    @MainActor private func imported(_ text: String) async throws -> (Book,URL,AppServices) {
        let (root,services) = try context(), source = root.appendingPathComponent("原创.txt")
        try Data(text.utf8).write(to: source)
        let book = try await TXTBookImportService(files: services.files,repository: services.repository).importBook(from: source)
        return (book,try services.files.resolve(book.filePath),services)
    }
    @MainActor private func prepared(_ text: String) async throws -> (Book,URL,AppServices,TXTPreparedPublication) {
        let (book,url,services) = try await imported(text)
        let publication = try await TXTReadiumPublicationLoader().open(book: book,fileURL: url,storageRoot: services.files.root)
        return (book,url,services,publication)
    }

    @MainActor func testActualTXTImportUTF8UTF16AndGB18030ChoiceRetryPreservesFiles() async throws {
        let (root,services) = try context(), model = LibraryViewModel(services: services)
        let text = "第一章 山门\r\n云海🙂\n第二章 问道\n原文保留"
        var utf16 = Data([0xFF,0xFE]); utf16.append(try XCTUnwrap(text.data(using: .utf16LittleEndian)))
        let gb: [UInt8] = [0xB5,0xDA,0xD2,0xBB,0xD5,0xC2,0x20,0xC9,0xBD,0xC3,0xC5,0x0D,0x0A,0xD4,0xC6,0xBA,0xA3,0x95,0x30,0x85,0x32,0x0A,0xB5,0xDA,0xB6,0xFE,0xD5,0xC2,0x20,0xCE,0xCA,0xB5,0xC0,0x0A,0xD4,0xAD,0xCE,0xC4,0xB1,0xA3,0xC1,0xF4]
        let vectors = [("utf8",Data(text.utf8)),("utf16",utf16),("gb",Data(gb))]
        var urls: [URL] = []
        for (name,bytes) in vectors { let url = root.appendingPathComponent(name+".txt"); try bytes.write(to: url); urls.append(url) }
        await model.importBooks(urls)
        XCTAssertEqual(model.books.count,2); XCTAssertEqual(model.retryTXTFiles,[urls[2]])
        XCTAssertTrue(model.errorMessage?.contains("编码") == true)
        model.txtEncoding = .gb18030
        await model.importBooks(model.retryTXTFiles)
        XCTAssertEqual(model.books.count,3); XCTAssertTrue(model.retryTXTFiles.isEmpty); XCTAssertNil(model.errorMessage)
        let cache = try TXTIndexCache(storageRoot: services.files.root)
        for summary in model.books {
            let book = summary.book
            let index = try await cache.prepare(source: services.files.resolve(book.filePath),bookID: book.id,encoding: book.txtEncoding ?? .automatic)
            XCTAssertTrue(index.reusedCache)
            let normalized = try await cache.normalizedURL(for: index)
            XCTAssertEqual(try String(contentsOf: normalized,encoding: .utf8),text)
            XCTAssertEqual(index.chapters.count,2)
        }
        for (i,vector) in vectors.enumerated() { XCTAssertEqual(try Data(contentsOf: urls[i]),vector.1) }
    }

    @MainActor func testTXTReadiumResourcesAreBoundedEscapedAndDoNotReadNextChapter() async throws {
        let text = "第一章 大章\n<script>window.txtInjected=true</script> & 原文🙂\n"+String(repeating:"修行🙂",count:25000)+"\n第二章 尾声\n未来章正文"
        let (_,_,_,prepared) = try await prepared(text)
        XCTAssertTrue(prepared.publication.conforms(to: .epub)); XCTAssertGreaterThan(prepared.plan.resources.count,3)
        let first = try XCTUnwrap(prepared.publication.get(prepared.publication.readingOrder[0]))
        let bytes = try await first.read().get(), html = try XCTUnwrap(String(data: bytes,encoding: .utf8))
        XCTAssertTrue(html.contains("&lt;script&gt;")); XCTAssertTrue(html.contains("&amp;"))
        XCTAssertFalse(html.contains("<script>")); XCTAssertFalse(html.contains("未来章正文"))
        for resource in prepared.plan.resources { XCTAssertLessThanOrEqual(resource.endByte-resource.startByte,Int64(TXTReadingPlan.resourceBytes)) }
        let tiny = try await self.prepared("甲").3
        let tinyResource = try XCTUnwrap(tiny.publication.get(tiny.publication.readingOrder[0]))
        let tinyBytes = try await tinyResource.read().get()
        XCTAssertTrue(try XCTUnwrap(String(data: tinyBytes,encoding: .utf8)).contains("甲"))
    }

    @MainActor func testTXTLocatorByteTextAndViewportRoundTripRejectsContentAndInvalidAnchors() async throws {
        let title = "第一章 锚点\n", text = title+"修行🙂再问道"
        let (book,url,services,prepared) = try await self.prepared(text)
        let resource = try XCTUnwrap(prepared.plan.resources.first)
        let href = try XCTUnwrap(AnyURL(string: resource.href))
        func locator(byte: Int64, character: Int) -> Locator {
            let point = DOMRange.Point(cssSelector: "#txt-b\(byte)",textNodeIndex: 0,charOffset: character)
            return Locator(href: href,mediaType: .xhtml,locations: .init(progression: 0.4,otherLocations: [
                "domRange":DOMRange(start: point).jsonValue,
                "xianxiaContinuousAnchor":.integer(1),"xianxiaContinuousViewportOffset":.integer(-17)]),
                text: .init(after: "再问道",before: "修行",highlight: "🙂"))
        }
        let original = locator(byte: Int64(title.utf8.count),character: 2)
        let position = try TXTPositionCodec.encode(original,bookID: book.id,plan: prepared.plan)
        XCTAssertEqual(position.engineID,"readium.txt")
        let restored = try await prepared.locator(position,bookID: book.id)
        XCTAssertEqual(restored,original)
        try await services.repository.save(position)
        let repositoryPosition = try await services.repository.position(for: book.id)
        XCTAssertEqual(repositoryPosition,position)
        for wrong in [locator(byte: 1,character: 0),locator(byte: Int64(title.utf8.count),character: 3)] {
            let invalid = try TXTPositionCodec.encode(wrong,bookID: book.id,plan: prepared.plan)
            do { _ = try await prepared.locator(invalid,bookID: book.id); XCTFail("Byte/UTF16 interior must fail") }
            catch { XCTAssertTrue(error is EPUBError) }
        }
        try Data((title+"正文改变了").utf8).write(to: url)
        let changed = try await TXTReadiumPublicationLoader().open(book: book,fileURL: url,storageRoot: services.files.root)
        XCTAssertThrowsError(try TXTPositionCodec.decode(position,bookID: book.id,plan: changed.plan))
    }

    @MainActor private func mount(_ engine: ReadiumReaderEngine) throws -> UIWindow {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: ReaderSurface(viewController: engine.viewController))
        window.makeKeyAndVisible(); window.layoutIfNeeded()
        addTeardownBlock { await MainActor.run { engine.close(); window.isHidden = true; previous?.makeKeyAndVisible() } }
        return window
    }
    @MainActor private func view(_ identifier: String, root: UIView) -> UIView? {
        if root.accessibilityIdentifier == identifier { return root }
        for child in root.subviews { if let found = view(identifier,root: child) { return found } }
        return nil
    }
    @MainActor private func webViews(_ root: UIView) -> [WKWebView] {
        (root as? WKWebView).map { [$0] } ?? root.subviews.flatMap { webViews($0) }
    }
    @MainActor private func wait(_ description: String, predicate: () async throws -> Bool) async throws {
        let deadline = Date().addingTimeInterval(20)
        while Date() < deadline {
            let ready = try await predicate()
            if ready { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        throw Failure.timedOut(description)
    }
    @MainActor func testRealTXTContinuousLongParagraphRestoresByteCharacterViewportAndTOC() async throws {
        let text = "第一章 长段\n"+String(repeating:"修行🙂再问道。",count:1000)+"\n第二章 尾声\n原创故事终点"
        let (book,url,services) = try await imported(text)
        let context = try await TXTReadiumPublicationLoader().open(book: book,fileURL: url,storageRoot: services.files.root)
        let engine = ReadiumReaderEngine(storageRoot: services.files.root); engine.setContinuousScrolling(true)
        let window = try mount(engine)
        try await engine.open(book: book,fileURL: url,position: nil)
        try await wait("TXT first real location") { engine.currentPosition != nil && engine.continuousLoadedResourceCount > 0 }
        let paragraphByte = "第一章 长段\n".utf8.count
        let selector = "document.getElementById('txt-b\(paragraphByte)')?.getBoundingClientRect().top ?? 10000"
        let scroll = try XCTUnwrap(view("readium.continuous-scroll",root: engine.viewController.view) as? UIScrollView)
        scroll.setContentOffset(CGPoint(x: 0,y: scroll.contentOffset.y+600),animated: false)
        try await wait("TXT nonzero character anchor") {
            guard let saved = engine.currentPosition else { return false }
            let (_,anchor,_) = try TXTPositionCodec.decode(saved,bookID: book.id,plan: context.plan)
            return anchor.characterUTF16Offset > 100
        }
        let saved = try XCTUnwrap(engine.currentPosition)
        let target = try XCTUnwrap(webViews(try XCTUnwrap(view("readium.chapter.0",root: engine.viewController.view))).first)
        let beforeValue = try await target.evaluateJavaScript(selector) as? Double
        let before = try XCTUnwrap(beforeValue); XCTAssertLessThan(before,-300)
        let image = try await target.takeSnapshot(configuration: nil)
        let attachment = XCTAttachment(image: image); attachment.name = "txt-continuous-long-paragraph"; attachment.lifetime = .keepAlways; add(attachment)
        engine.close()
        try await engine.open(book: book,fileURL: url,position: saved)
        try await wait("TXT restored viewport") {
            guard let wrapper = self.view("readium.chapter.0",root: engine.viewController.view),let reopened = self.webViews(wrapper).first else { return false }
            let y = try await reopened.evaluateJavaScript(selector) as? Double
            return abs((y ?? 10000)-before) < 3
        }
        let chapters = try XCTUnwrap(engine.currentChapters)
        try await engine.go(to: XCTUnwrap(chapters.last))
        try await wait("TXT second chapter") { engine.currentPosition?.chapterTitle == "第二章 尾声" }
        XCTAssertGreaterThan(window.bounds.height,0)
    }

    @MainActor func testRealTXTSearchPositionsJumpAndCloseCancelSession() async throws {
        let (book,url,services) = try await imported("第一章 云海\n原创修行起点\n第二章 问道\n唯一搜索落点🙂再问道")
        let engine = ReadiumReaderEngine(storageRoot: services.files.root); engine.setContinuousScrolling(true)
        _ = try mount(engine)
        try await engine.open(book: book,fileURL: url,position: nil)
        try await wait("TXT search ready") { engine.currentPosition != nil }
        let provider = try XCTUnwrap(engine.searchProvider), session = try await provider.search(query: "唯一搜索落点")
        let batch = try await session.next(); await session.cancel()
        let hit = try XCTUnwrap(batch?.first); XCTAssertEqual(hit.position.engineID,"readium.txt")
        try await engine.go(to: hit.position)
        try await wait("TXT search navigated") { engine.currentPosition?.chapterTitle == "第二章 问道" }
        engine.close(); XCTAssertNil(engine.currentPosition)
        do { _ = try await session.next(); XCTFail("Cancelled session must reject late reads") }
        catch { XCTAssertTrue(error is CancellationError) }
    }
}
