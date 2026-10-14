import Foundation

public struct TXTChapterWindow: Equatable, Sendable {
    public let chapterID: String
    public let text: String
    public let startByte: Int64
    public let endByte: Int64
    public let nextLocalByteOffset: Int64
    public let isEndOfChapter: Bool
}

/// Reads only a window within a validated leaf chapter. URLs must be resolved by BookFileStore.
public actor TXTChapterWindowReader {
    public static let maximumWindowBytes = 256 * 1024
    public init() {}

    public func read(file: URL, chapter: Chapter, localByteOffset: Int64 = 0,
                     maximumBytes: Int = 64 * 1024) throws -> TXTChapterWindow {
        guard 4...Self.maximumWindowBytes ~= maximumBytes else { throw TXTProcessingError.invalidConfiguration }
        guard let start = chapter.startByte, let end = chapter.endByte, start >= 0, end > start,
              localByteOffset >= 0, localByteOffset <= end - start else { throw TXTProcessingError.invalidChapterRange }
        try Task.checkCancellation()
        return try TXTFileAccess.read(url: file) { handle in
            let size = try handle.seekToEnd()
            guard UInt64(end) <= size else { throw TXTProcessingError.sourceTruncated }
            let windowStart = start + localByteOffset // Safe because the offset is bounded by end - start.
            let count = Int(min(Int64(maximumBytes), end - windowStart))
            try handle.seek(toOffset: UInt64(windowStart))
            var bytes = Data()
            while bytes.count < count {
                try Task.checkCancellation()
                guard let part = try handle.read(upToCount: count - bytes.count), !part.isEmpty else {
                    throw TXTProcessingError.sourceTruncated
                }
                bytes.append(part)
            }
            var validator = TXTUTF8Validator()
            var completeBytes = 0
            for (index, byte) in bytes.enumerated() {
                try validator.accept(byte, at: windowStart + Int64(index))
                if validator.isAtScalarBoundary { completeBytes = index + 1 }
            }
            // At an actual chapter end, partial UTF-8 is corruption, not a chunk boundary.
            if windowStart + Int64(count) == end { try validator.finish() }
            guard count == 0 || completeBytes > 0 else { throw TXTProcessingError.windowTooSmall }
            let complete = bytes.prefix(completeBytes)
            guard let text = String(data: complete, encoding: .utf8) else {
                throw TXTProcessingError.invalidUTF8(byteOffset: windowStart)
            }
            let windowEnd = windowStart + Int64(completeBytes)
            try Task.checkCancellation()
            return TXTChapterWindow(chapterID: chapter.id, text: text, startByte: windowStart, endByte: windowEnd,
                                    nextLocalByteOffset: windowEnd - start, isEndOfChapter: windowEnd == end)
        }
    }
}
