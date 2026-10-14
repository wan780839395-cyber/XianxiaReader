import Foundation

public struct TXTChapterScanResult: Equatable, Sendable {
    public let chapters: [Chapter]
    public let contentStartByte: Int64
    public let byteCount: Int64
    public let lineCount: Int64
    public let maximumRetainedLineBytes: Int
    public let parserVersion: Int
    public var leafChapterCount: Int { chapters.filter { $0.startByte != nil }.count }
}

/// Scans an already-normalized UTF-8 file on an actor executor, independently of UI.
/// This is the indexing component, not the encoding/import/cache facade.
public actor TXTUTF8ChapterScanner {
    public static let maximumChunkBytes = 256 * 1024
    public static let maximumHeadingCandidateBytes = 512
    private let chunkBytes: Int
    public init(chunkBytes: Int = 64 * 1024) throws {
        guard 1...Self.maximumChunkBytes ~= chunkBytes else { throw TXTProcessingError.invalidConfiguration }
        self.chunkBytes = chunkBytes
    }

    public func scan(file: URL, bookID: UUID) throws -> TXTChapterScanResult {
        try Task.checkCancellation()
        return try TXTFileAccess.read(url: file) { handle in
            var state = TXTScanState(bookID: bookID)
            while let data = try handle.read(upToCount: chunkBytes), !data.isEmpty {
                try Task.checkCancellation()
                for byte in data { try state.accept(byte) }
            }
            try Task.checkCancellation()
            return try state.finish()
        }
    }
}

private struct TXTScanState {
    private var validator = TXTUTF8Validator()
    private let recognizer = TXTChapterHeadingRecognizer()
    private var builder: TXTChapterBuilder
    private var byteCount: Int64 = 0
    private var lineStart: Int64 = 0
    private var lineCount: Int64 = 0
    private var candidate: [UInt8] = []
    private var oversizedLine = false
    private var precedingCR = false
    private var firstBytes: [UInt8] = []
    private var maximumRetainedLineBytes = 0
    init(bookID: UUID) { builder = TXTChapterBuilder(bookID: bookID) }

    mutating func accept(_ byte: UInt8) throws {
        guard byteCount < Int64.max else { throw TXTProcessingError.byteOffsetOverflow }
        if byteCount % 4096 == 0 { try Task.checkCancellation() }
        try validator.accept(byte, at: byteCount)
        if firstBytes.count < 3 {
            firstBytes.append(byte)
            if firstBytes == [0xEF, 0xBB, 0xBF] { builder.contentStartByte = 3 }
        }
        if byte == 0x0A, precedingCR {
            lineStart = byteCount + 1
        } else if byte == 0x0A || byte == 0x0D {
            try finishLine()
            lineStart = byteCount + 1
        } else if !oversizedLine {
            if candidate.count < TXTUTF8ChapterScanner.maximumHeadingCandidateBytes {
                candidate.append(byte)
                maximumRetainedLineBytes = max(maximumRetainedLineBytes, candidate.count)
            } else {
                candidate.removeAll(keepingCapacity: true)
                oversizedLine = true
            }
        }
        precedingCR = byte == 0x0D
        byteCount += 1
    }
    private mutating func finishLine() throws {
        lineCount += 1
        if oversizedLine {
            builder.markBody()
        } else {
            // The streaming validator has already verified every byte, including discarded long lines.
            guard var text = String(bytes: candidate, encoding: .utf8) else {
                throw TXTProcessingError.invalidUTF8(byteOffset: lineStart)
            }
            if lineStart == 0, text.first == "\u{FEFF}" { text.removeFirst() }
            if let heading = recognizer.recognize(text) {
                builder.add(heading, at: max(lineStart, builder.contentStartByte))
            } else if !text.trimmingCharacters(in: .whitespaces).isEmpty { builder.markBody() }
        }
        candidate.removeAll(keepingCapacity: true)
        oversizedLine = false
    }
    mutating func finish() throws -> TXTChapterScanResult {
        try validator.finish()
        if lineStart < byteCount { try finishLine() }
        let chapters = try builder.finish(at: byteCount)
        return TXTChapterScanResult(chapters: chapters, contentStartByte: builder.contentStartByte,
                                    byteCount: byteCount, lineCount: lineCount,
                                    maximumRetainedLineBytes: maximumRetainedLineBytes,
                                    parserVersion: TXTChapterHeadingRecognizer.parserVersion)
    }
}

private struct TXTChapterBuilder {
    private enum PendingKind { case prelude, volumePrelude, explicit }
    let bookID: UUID
    var contentStartByte: Int64 = 0 {
        didSet { if entries.isEmpty { pendingStart = contentStartByte } }
    }
    private var entries: [Chapter] = []
    private var depth = 0
    private var pendingKind: PendingKind = .prelude
    private var pendingTitle = "序章"
    private var pendingStart: Int64 = 0
    private var hasBody = false
    init(bookID: UUID) { self.bookID = bookID }

    mutating func markBody() { hasBody = true }
    mutating func add(_ heading: TXTChapterHeading, at boundary: Int64) {
        let nextStart: Int64
        if pendingKind == .explicit || hasBody || (heading.kind == .volume && pendingKind == .volumePrelude) {
            appendLeaf(end: boundary)
            nextStart = boundary
        } else { nextStart = pendingStart } // Carry blank prefix or volume heading into the first child.
        if heading.kind == .volume {
            entries.append(Chapter(id: "txt-volume-v1:\(bookID.uuidString.lowercased()):\(boundary)",
                                   bookID: bookID, ordinal: entries.count, title: heading.title))
            depth = 1
            pendingKind = .volumePrelude
            pendingTitle = "卷序"
        } else {
            pendingKind = .explicit
            pendingTitle = heading.title
        }
        pendingStart = nextStart
        hasBody = false
    }
    private mutating func appendLeaf(end: Int64) {
        guard end > pendingStart else { return }
        entries.append(Chapter(id: "txt-v1:\(bookID.uuidString.lowercased()):\(pendingStart)", bookID: bookID,
                               ordinal: entries.count, title: pendingTitle, depth: depth,
                               startByte: pendingStart, endByte: end))
    }
    mutating func finish(at end: Int64) throws -> [Chapter] {
        guard end > contentStartByte, hasBody || pendingKind != .prelude else { throw TXTProcessingError.emptyText }
        if entries.isEmpty, pendingKind == .prelude { pendingTitle = "正文" }
        appendLeaf(end: end)
        return entries
    }
}
