import Foundation
@testable import ReadiumAdapter
import ReadiumShared
import ReadingInterfaces
import XCTest
import XianxiaCore

final class ReadiumSearchTests: XCTestCase {
    private final class Elements: ContentIterator {
        var items: [TextContentElement]
        var index = 0
        var failure: Error?
        init(_ items: [TextContentElement] = [], failure: Error? = nil) { self.items = items; self.failure = failure }
        func next() async throws -> (any ContentElement)? {
            if let failure { throw failure }
            guard index < items.count else { return nil }
            defer { index += 1 }
            return items[index]
        }
        func previous() async throws -> (any ContentElement)? { nil }
    }

    private func element(segments: [String]) throws -> TextContentElement {
        let href = try XCTUnwrap(AnyURL(string: "chapter.xhtml"))
        let locator = Locator(href: href, mediaType: .xhtml,
            locations: .init(otherLocations: ["cssSelector": .string("html > body > p:nth-child(1)")]))
        return TextContentElement(locator: locator, role: .body,
                                  segments: segments.map { .init(locator: locator, text: $0) })
    }

    func testBatchSizeSnippetBoundsAndEndPreserveCSSLocator() async throws {
        let item = try element(segments: [String(repeating: "修行", count: 95)])
        let iterator = SafeTextSearchIterator(content: Elements([item]), query: "修行")
        var counts: [Int] = []
        while let page = try await iterator.next().get() {
            counts.append(page.locators.count)
            for locator in page.locators {
                XCTAssertEqual(locator.text.highlight, "修行")
                XCTAssertLessThanOrEqual(locator.text.before?.count ?? 0, 64)
                XCTAssertLessThanOrEqual(locator.text.after?.count ?? 0, 64)
                XCTAssertEqual(locator.locations.cssSelector, "html > body > p:nth-child(1)")
            }
        }
        XCTAssertEqual(counts, [40, 40, 15])
        XCTAssertEqual(iterator.resultCount, 95)
        let end = try await iterator.next().get()
        XCTAssertNil(end)
    }

    func testCombiningCharactersEmojiAndInlineSegmentBoundaries() async throws {
        let item = try element(segments: ["序 e", "\u{0301}，仙剑", "\u{FE0F}与👩", "\u{200D}🚀，修", "行终章"])
        for query in ["e\u{0301}", "剑\u{FE0F}", "👩\u{200D}🚀", "修行"] {
            let iterator = SafeTextSearchIterator(content: Elements([item]), query: query)
            let page = try await iterator.next().get()
            XCTAssertEqual(page?.locators.count, 1)
            XCTAssertEqual(page?.locators.first?.text.highlight, query)
        }
    }

    func testLiteralQueryCaseInsensitiveAndNoCrossParagraphMatch() async throws {
        let items = try [element(segments: ["Chapter A .* 修"]), element(segments: ["行"])]
        for (query, count) in [("chapter a", 1), (".*", 1), ("修行", 0)] {
            let iterator = SafeTextSearchIterator(content: Elements(items), query: query)
            let page = try await iterator.next().get()
            XCTAssertEqual(page?.locators.count ?? 0, count)
        }
    }

    func testContentReadFailureIsNotReportedAsNoMatches() async {
        struct Failure: Error {}
        let iterator = SafeTextSearchIterator(content: Elements(failure: Failure()), query: "修行")
        switch await iterator.next() {
        case .failure(.reading): break
        default: XCTFail("Resource failure must be surfaced")
        }
    }

    @MainActor func testRealEPUB2AndEPUB3ChineseSearchPositions() async throws {
        for name in ["chinese-epub2", "chinese-epub3"] {
            let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: name, withExtension: "epub", subdirectory: "Fixtures"))
            let engine = ReadiumReaderEngine()
            defer { engine.close() }
            let book = Book(title: "搜索测试", format: .epub, filePath: "book.epub")
            try await engine.open(book: book, fileURL: url, position: nil)
            let provider = try XCTUnwrap(engine.searchProvider)
            let session = try await provider.search(query: " 修行 ")
            let first = try await session.next()
            let second = try await session.next()
            let end = try await session.next()
            XCTAssertEqual(first?.count, 40)
            XCTAssertEqual(second?.count, 40)
            XCTAssertNil(end)
            XCTAssertEqual(first?.first?.title, "第一章 山门")
            XCTAssertEqual(second?.first?.title, "第二章 云海")
            let hit = try XCTUnwrap(second?.first)
            let locator = try ReadiumPositionCodec.decode(hit.position, bookID: book.id)
            XCTAssertEqual(locator.text.highlight, "修行")
            XCTAssertNotNil(locator.locations.cssSelector)
            XCTAssertTrue(locator.href.string.hasSuffix("two.xhtml"))
            await session.cancel()
        }
    }

    private actor SuspendedIterator: SearchIterator {
        let entered: XCTestExpectation
        nonisolated let resultCount: Int? = nil
        private var continuation: CheckedContinuation<LocatorCollection?, Never>?
        init(entered: XCTestExpectation) { self.entered = entered }
        func next() async -> SearchResult<LocatorCollection?> {
            .success(await withCheckedContinuation { continuation in
                self.continuation = continuation
                entered.fulfill()
            })
        }
        func finish() { continuation?.resume(returning: nil); continuation = nil }
    }

    func testConcurrentNextRejectedAndCancelledSessionRejectsLatePage() async throws {
        let entered = expectation(description: "cursor suspended")
        let iterator = SuspendedIterator(entered: entered)
        let session = ReadiumSearchSession(publication: nil, iterator: iterator, bookID: UUID())
        let first = Task { try await session.next() }
        await fulfillment(of: [entered], timeout: 3)
        do { _ = try await session.next(); XCTFail("Concurrent cursor advance must fail") }
        catch ReaderSearchError.busy { }
        await session.cancel()
        await iterator.finish()
        do { _ = try await first.value; XCTFail("Cancelled cursor must reject late completion") }
        catch is CancellationError { }
        do { _ = try await session.next(); XCTFail("Cancelled cursor cannot restart") }
        catch is CancellationError { }
    }
}
