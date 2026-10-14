import Foundation

public enum TXTProcessingError: Error, Equatable, Sendable {
    case invalidConfiguration
    case invalidSource
    case emptyText
    case invalidUTF8(byteOffset: Int64)
    case byteOffsetOverflow
    case invalidChapterRange
    case sourceTruncated
    case windowTooSmall
    case operationAndCloseFailed(operation: String, close: String)
}

/// Strict Unicode scalar validation, including overlong encodings and surrogate exclusion.
/// Only a few bytes of state survive a chunk; no replacement characters are introduced.
struct TXTUTF8Validator {
    private var remaining = 0
    private var minimum: UInt8 = 0x80
    private var maximum: UInt8 = 0xBF
    private var sequenceStart: Int64 = 0
    var isAtScalarBoundary: Bool { remaining == 0 }

    mutating func accept(_ byte: UInt8, at offset: Int64) throws {
        if remaining > 0 {
            guard minimum...maximum ~= byte else { throw TXTProcessingError.invalidUTF8(byteOffset: offset) }
            remaining -= 1
            minimum = 0x80; maximum = 0xBF
            return
        }
        sequenceStart = offset
        switch byte {
        case 0x00...0x7F: return
        case 0xC2...0xDF: remaining = 1
        case 0xE0: remaining = 2; minimum = 0xA0
        case 0xE1...0xEC, 0xEE...0xEF: remaining = 2
        case 0xED: remaining = 2; maximum = 0x9F
        case 0xF0: remaining = 3; minimum = 0x90
        case 0xF1...0xF3: remaining = 3
        case 0xF4: remaining = 3; maximum = 0x8F
        default: throw TXTProcessingError.invalidUTF8(byteOffset: offset)
        }
    }
    func finish() throws {
        if remaining != 0 { throw TXTProcessingError.invalidUTF8(byteOffset: sequenceStart) }
    }
}

enum TXTFileAccess {
    /// ARC alone does not drain Foundation's autoreleased NSData/NSString in a long loop.
    /// Never span an await with a pool; keep only Swift decoder/index state across chunks.
    static func withTemporaryObjects<T>(_ operation: () throws -> T) rethrows -> T {
        #if canImport(ObjectiveC)
        return try autoreleasepool(invoking: operation)
        #else
        return try operation()
        #endif
    }

    static func consumeChunk(from handle: FileHandle, maximumBytes: Int,
                             operation: (Data) throws -> Void) throws -> Bool {
        try withTemporaryObjects {
            guard let data = try handle.read(upToCount: maximumBytes), !data.isEmpty else { return false }
            try Task.checkCancellation()
            try operation(data)
            return true
        }
    }

    /// Preserve a primary read/cancellation error even if closing the handle also fails.
    static func read<T>(url: URL, operation: (FileHandle) throws -> T) throws -> T {
        guard url.isFileURL,
              try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else {
            throw TXTProcessingError.invalidSource
        }
        let handle = try FileHandle(forReadingFrom: url)
        let result: T
        do { result = try operation(handle) }
        catch {
            let original = error
            do { try handle.close() }
            catch {
                throw TXTProcessingError.operationAndCloseFailed(operation: String(describing: original),
                                                                 close: String(describing: error))
            }
            throw original
        }
        try handle.close()
        return result
    }
}
