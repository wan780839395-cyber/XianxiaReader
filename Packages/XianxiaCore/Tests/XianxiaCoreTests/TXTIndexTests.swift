import Foundation
import XCTest
@testable import XianxiaCore

final class TXTIndexTests: XCTestCase {
    private func file(_ data: Data) throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("original.txt")
        try data.write(to: url)
        return url
    }
    private func scan(_ text: String, chunkBytes: Int = 7, bookID: UUID = UUID()) async throws -> TXTChapterScanResult {
        let url = try file(Data(text.utf8))
        return try await TXTUTF8ChapterScanner(chunkBytes: chunkBytes).scan(file: url, bookID: bookID)
    }
    private func assertError<T>(_ expected: TXTProcessingError, file: StaticString = #filePath, line: UInt = #line,
                                operation: () async throws -> T) async {
        do { _ = try await operation(); XCTFail("Expected \(expected)", file: file, line: line) }
        catch { XCTAssertEqual(error as? TXTProcessingError, expected, file: file, line: line) }
    }
    private func assertCoverage(_ result: TXTChapterScanResult, data: Data, file: StaticString = #filePath, line: UInt = #line) throws {
        let leaves = result.chapters.filter { $0.startByte != nil }
        var next = result.contentStartByte
        var reconstructed = Data()
        for chapter in leaves {
            let start = try XCTUnwrap(chapter.startByte, file: file, line: line)
            let end = try XCTUnwrap(chapter.endByte, file: file, line: line)
            XCTAssertEqual(start, next, file: file, line: line)
            XCTAssertGreaterThan(end, start, file: file, line: line)
            let bytes = data.subdata(in: Int(start)..<Int(end))
            XCTAssertNotNil(String(data: bytes, encoding: .utf8), file: file, line: line)
            reconstructed.append(bytes)
            next = end
        }
        XCTAssertEqual(next, Int64(data.count), file: file, line: line)
        XCTAssertEqual(reconstructed, data.dropFirst(Int(result.contentStartByte)), file: file, line: line)
        XCTAssertEqual(result.chapters.map(\.ordinal), Array(result.chapters.indices), file: file, line: line)
    }

    func testEightRequiredHeadingForms() {
        let recognizer = TXTChapterHeadingRecognizer()
        for line in ["第一章", "第一百二十三章", "第123章", "第 123 章", "正文 第一章", "Chapter 1"] {
            XCTAssertEqual(recognizer.recognize(line)?.kind, .chapter, line)
        }
        for line in ["第一卷", "卷一"] { XCTAssertEqual(recognizer.recognize(line)?.kind, .volume, line) }
        for line in ["第一章天地初开", "第两百一十八章 山门", "第壹佰贰拾叁章 云海", "Chapter.844 山门", "chapter 2: Cloud"] {
            XCTAssertEqual(recognizer.recognize(line)?.kind, .chapter, line)
        }
        XCTAssertEqual(recognizer.recognize(" 　序章：山门  ")?.title, "序章：山门")
        XCTAssertEqual(recognizer.recognize("第１卷 山门")?.kind, .volume)
    }
    func testBodyLinesAndMeasureWordsAreNotHeadings() {
        let recognizer = TXTChapterHeadingRecognizer()
        for line in ["", " ", "他想起第一章的故事", "第一章 修行的故事还没有结束。", "第一封信", "第四本书",
                     "第一卷的故事", "卷一的故事", "序章之后发生了什么", "chapter1 prose", "Chapter 1abc",
                     "第一章\n第二章", "第-1章 山门", "第章 山门", "第一章 " + String(repeating: "长", count: 100)] {
            XCTAssertNil(recognizer.recognize(line), line)
        }
    }
    func testBOMCRLFChineseEmojiAndHeadingsAcrossTinyChunks() async throws {
        let text = "\u{FEFF}这是前言\r\n\r\n第一卷 初入山门\r\n卷前的文字。\r\n第一章 山门\r\n正文🙂云海\r\n第二章 云海\n末行没有换行"
        let data = Data(text.utf8), url = try file(data), bookID = UUID()
        var baseline: [Chapter]?
        for size in [1, 2, 3, 5, 64] {
            let result = try await TXTUTF8ChapterScanner(chunkBytes: size).scan(file: url, bookID: bookID)
            XCTAssertEqual(result.chapters.map(\.title), ["序章", "第一卷 初入山门", "卷序", "第一章 山门", "第二章 云海"])
            XCTAssertEqual(result.chapters.map(\.depth), [0, 0, 1, 1, 1])
            XCTAssertEqual(result.contentStartByte, 3)
            XCTAssertEqual(result.byteCount, Int64(data.count))
            XCTAssertEqual(result.parserVersion, 1)
            XCTAssertEqual(result.leafChapterCount, 4)
            try assertCoverage(result, data: data)
            if let baseline { XCTAssertEqual(result.chapters, baseline) } else { baseline = result.chapters }
        }
        XCTAssertEqual(try Data(contentsOf: url), data, "Scanning must preserve the original bytes")
    }
    func testLoneCRAndFinalLineAreIndexed() async throws {
        let text = "第一章 山门\r甲\r第二章 云海\r乙"
        let result = try await scan(text, chunkBytes: 1)
        XCTAssertEqual(result.chapters.map(\.title), ["第一章 山门", "第二章 云海"])
        XCTAssertEqual(result.lineCount, 4)
        try assertCoverage(result, data: Data(text.utf8))
    }
    func testVolumeHeadingBelongsToFirstChildWithoutDuplicateText() async throws {
        let text = "\n第一卷 初入山门\n第一章 山门\n甲\n第二卷 云海\n第二章 云海\n乙\n"
        let result = try await scan(text)
        XCTAssertEqual(result.chapters.map(\.title), ["第一卷 初入山门", "第一章 山门", "第二卷 云海", "第二章 云海"])
        XCTAssertNil(result.chapters[0].startByte)
        XCTAssertNil(result.chapters[2].endByte)
        XCTAssertEqual(result.chapters[1].depth, 1)
        XCTAssertEqual(result.chapters[3].depth, 1)
        try assertCoverage(result, data: Data(text.utf8))
    }
    func testConsecutiveEmptyVolumesRetainTheirOwnHeadingBytes() async throws {
        let text = "第一卷 山门\n第二卷 云海\n第一章 正文\n甲"
        let result = try await scan(text)
        XCTAssertEqual(result.chapters.map(\.title), ["第一卷 山门", "卷序", "第二卷 云海", "第一章 正文"])
        try assertCoverage(result, data: Data(text.utf8))
    }
    func testExplicitPrologueAndRepeatedChapterNamesHaveStableIDs() async throws {
        let text = "序章 开端\n甲\n第一章 重名\n乙\n第一章 重名\n丙"
        let bookID = UUID()
        let first = try await scan(text, bookID: bookID)
        let second = try await scan(text, chunkBytes: 1, bookID: bookID)
        XCTAssertEqual(first.chapters, second.chapters)
        XCTAssertEqual(Set(first.chapters.map(\.id)).count, first.chapters.count)
        XCTAssertEqual(first.chapters.map(\.title), ["序章 开端", "第一章 重名", "第一章 重名"])
        try assertCoverage(first, data: Data(text.utf8))
    }
    func testLongBodyLineHasBoundedCandidateAndDoesNotHideNextHeading() async throws {
        let text = String(repeating: "云🙂", count: 150_000) + "\n第一章 山门\n甲"
        let result = try await scan(text, chunkBytes: 4096)
        XCTAssertEqual(result.chapters.map(\.title), ["序章", "第一章 山门"])
        XCTAssertLessThanOrEqual(result.maximumRetainedLineBytes, TXTUTF8ChapterScanner.maximumHeadingCandidateBytes)
        try assertCoverage(result, data: Data(text.utf8))
    }
    func testNoChapterFileIsOneBodyRange() async throws {
        let text = "云海\n少年踏入山门。\n"
        let result = try await scan(text)
        XCTAssertEqual(result.chapters.map(\.title), ["正文"])
        try assertCoverage(result, data: Data(text.utf8))
    }
    func testEmptyBOMOnlyAndWhitespaceFilesAreRejected() async throws {
        for text in ["", "\u{FEFF}", " \t\r\n　\n"] {
            let url = try file(Data(text.utf8))
            let scanner = try TXTUTF8ChapterScanner(chunkBytes: 1)
            await assertError(.emptyText) { try await scanner.scan(file: url, bookID: UUID()) }
        }
    }
    func testStrictUTF8RejectsOverlongSurrogateOutOfRangeAndTruncation() async throws {
        let cases: [([UInt8], Int64)] = [([0xC0, 0xAF], 0), ([0xE0, 0x80, 0x80], 1),
            ([0xED, 0xA0, 0x80], 1), ([0xF4, 0x90, 0x80, 0x80], 1), ([0xE4, 0xB8], 0), ([0xFF, 0xFE], 0)]
        for (bytes, offset) in cases {
            let url = try file(Data(bytes)), scanner = try TXTUTF8ChapterScanner(chunkBytes: 1)
            await assertError(.invalidUTF8(byteOffset: offset)) { try await scanner.scan(file: url, bookID: UUID()) }
        }
    }
    func testDiscardedLongLineIsStillEncodingValidated() async throws {
        var bytes = Data(repeating: 0x61, count: 2048)
        bytes.append(contentsOf: [0xE4, 0xFF])
        let url = try file(bytes), scanner = try TXTUTF8ChapterScanner(chunkBytes: 31)
        await assertError(.invalidUTF8(byteOffset: 2049)) { try await scanner.scan(file: url, bookID: UUID()) }
    }
    func testCancelledScanDoesNotReadOrMutateOriginal() async throws {
        let bytes = Data("第一章 山门\n原书保留".utf8), url = try file(bytes), scanner = try TXTUTF8ChapterScanner()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await scanner.scan(file: url, bookID: UUID())
        }
        do { _ = try await task.value; XCTFail("Cancellation must propagate") }
        catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertEqual(try Data(contentsOf: url), bytes)
    }
    func testInvalidConfigurationAndNonFileURLAreRejected() async throws {
        XCTAssertThrowsError(try TXTUTF8ChapterScanner(chunkBytes: 0))
        XCTAssertThrowsError(try TXTUTF8ChapterScanner(chunkBytes: TXTUTF8ChapterScanner.maximumChunkBytes + 1))
        let scanner = try TXTUTF8ChapterScanner(), url = try XCTUnwrap(URL(string: "https://example.invalid/book.txt"))
        await assertError(.invalidSource) { try await scanner.scan(file: url, bookID: UUID()) }
    }
    func testWindowReadsAcrossUTF8BoundariesWithoutNextChapterText() async throws {
        let text = "第一章 山门\n甲🙂乙云海\n第二章 云海\n未来章节内容"
        let bytes = Data(text.utf8), url = try file(bytes)
        let result = try await TXTUTF8ChapterScanner(chunkBytes: 2).scan(file: url, bookID: UUID())
        let chapter = try XCTUnwrap(result.chapters.first), reader = TXTChapterWindowReader()
        var local: Int64 = 0, reconstructed = ""
        while true {
            let window = try await reader.read(file: url, chapter: chapter, localByteOffset: local, maximumBytes: 7)
            XCTAssertLessThanOrEqual(window.text.utf8.count, 7)
            XCTAssertGreaterThan(window.nextLocalByteOffset, local)
            XCTAssertFalse(window.text.contains("未来"))
            reconstructed += window.text
            local = window.nextLocalByteOffset
            if window.isEndOfChapter { break }
        }
        let end = try XCTUnwrap(chapter.endByte)
        XCTAssertEqual(Data(reconstructed.utf8), bytes.prefix(Int(end)))
        let empty = try await reader.read(file: url, chapter: chapter, localByteOffset: local, maximumBytes: 7)
        XCTAssertEqual(empty.text, "")
        XCTAssertTrue(empty.isEndOfChapter)
    }
    func testWindowRejectsContinuationAnchorAndIncompleteChapterEnd() async throws {
        let url = try file(Data("中🙂文".utf8)), reader = TXTChapterWindowReader(), bookID = UUID()
        let chapter = Chapter(id: "c", bookID: bookID, ordinal: 0, title: "正文", startByte: 0, endByte: 10)
        await assertError(.invalidUTF8(byteOffset: 1)) { try await reader.read(file: url, chapter: chapter, localByteOffset: 1) }
        let badEnd = Chapter(id: "c", bookID: bookID, ordinal: 0, title: "正文", startByte: 0, endByte: 1)
        await assertError(.invalidUTF8(byteOffset: 0)) { try await reader.read(file: url, chapter: badEnd) }
    }
    func testWindowRejectsGroupRangeOverflowAndTruncatedSource() async throws {
        let url = try file(Data("中文".utf8)), reader = TXTChapterWindowReader(), bookID = UUID()
        let group = Chapter(id: "v", bookID: bookID, ordinal: 0, title: "第一卷")
        await assertError(.invalidChapterRange) { try await reader.read(file: url, chapter: group) }
        let tooLong = Chapter(id: "c", bookID: bookID, ordinal: 1, title: "正文", startByte: 0, endByte: 100)
        await assertError(.sourceTruncated) { try await reader.read(file: url, chapter: tooLong) }
        let chapter = Chapter(id: "c", bookID: bookID, ordinal: 1, title: "正文", startByte: 0, endByte: 6)
        await assertError(.invalidChapterRange) { try await reader.read(file: url, chapter: chapter, localByteOffset: Int64.max) }
        await assertError(.invalidConfiguration) { try await reader.read(file: url, chapter: chapter, maximumBytes: 3) }
        await assertError(.invalidConfiguration) { try await reader.read(file: url, chapter: chapter, maximumBytes: 262_145) }
    }
    func testWindowSupportsOffsetsAboveFourGiBWithoutReadingThePrefix() async throws {
        let url = try file(Data()), offset: Int64 = 4_294_967_296 + 17
        let handle = try FileHandle(forWritingTo: url)
        do {
            try handle.seek(toOffset: UInt64(offset))
            try handle.write(contentsOf: Data("云海".utf8))
        } catch {
            let original = error
            try handle.close()
            throw original
        }
        try handle.close()
        let chapter = Chapter(id: "sparse", bookID: UUID(), ordinal: 0, title: "正文", startByte: offset, endByte: offset + 6)
        let window = try await TXTChapterWindowReader().read(file: url, chapter: chapter, maximumBytes: 6)
        XCTAssertEqual(window.text, "云海")
        XCTAssertEqual(window.startByte, offset)
        XCTAssertEqual(window.endByte, offset + 6)
        XCTAssertTrue(window.isEndOfChapter)
    }
    func testCancelledWindowReadPropagatesCancellation() async throws {
        let url = try file(Data("中文".utf8))
        let chapter = Chapter(id: "c", bookID: UUID(), ordinal: 0, title: "正文", startByte: 0, endByte: 6)
        let reader = TXTChapterWindowReader()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await reader.read(file: url, chapter: chapter)
        }
        do { _ = try await task.value; XCTFail("Cancellation must propagate") }
        catch { XCTAssertTrue(error is CancellationError) }
    }
}
