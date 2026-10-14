import CTextCodec
import Foundation

public enum TXTEncoding: String, Codable, Sendable {
    case automatic, utf8, utf16LittleEndian, utf16BigEndian, gb18030
}

public struct TXTNormalizationResult: Equatable, Sendable {
    public let encoding: TXTEncoding
    public let sourceSHA256: String
    public let normalizedSHA256: String
    public let sourceBytes: Int64
    public let normalizedBytes: Int64
    public let normalizerVersion: Int
    public let codecIdentifier: String
}

public enum TXTNormalizationError: Error, Equatable, Sendable {
    case encodingChoiceRequired
    case unsupportedBOM
    case conflictingBOM
    case invalidEncoding(encoding: TXTEncoding, byteOffset: Int64)
    case nonTextByte(byteOffset: Int64)
    case codecUnavailable
    case destinationExists
    case sourceChanged
    case cleanupFailed(original: String, cleanup: String)
}

/// Writes a new UTF-8 sidecar, never the original. Automatic mode trusts BOM or strict UTF-8 only.
public actor TXTNormalizer {
    public static let version = 1
    public static var codecIdentifier: String {
        #if canImport(Darwin)
        return "apple-sdk-corefoundation-gb18030-2000-v1"
        #else
        return "glibc-iconv-gb18030-v1"
        #endif
    }
    private let chunkBytes: Int
    public init(chunkBytes: Int = 64 * 1024) throws {
        guard 1...TXTUTF8ChapterScanner.maximumChunkBytes ~= chunkBytes else { throw TXTProcessingError.invalidConfiguration }
        self.chunkBytes = chunkBytes
    }

    public func normalize(source: URL, destination: URL, encoding requested: TXTEncoding = .automatic) throws -> TXTNormalizationResult {
        try Task.checkCancellation()
        guard destination.isFileURL, source.standardizedFileURL != destination.standardizedFileURL else {
            throw TXTProcessingError.invalidConfiguration
        }
        let manager = FileManager.default
        guard !manager.fileExists(atPath: destination.path) else { throw TXTNormalizationError.destinationExists }
        let temporary = destination.deletingLastPathComponent().appendingPathComponent(".normalize-\(UUID().uuidString)")
        try Data().write(to: temporary, options: .withoutOverwriting)
        do {
            let result = try TXTFileAccess.read(url: source) { input in
                try Self.write(to: temporary) { output in
                    var header = Data()
                    while header.count < 4, let bytes = try input.read(upToCount: 4-header.count), !bytes.isEmpty { header.append(bytes) }
                    let choice = try Self.chooseEncoding(header: header, requested: requested)
                    var decoder = TXTStreamDecoder(encoding: choice.encoding, startOffset: Int64(choice.bomBytes))
                    var sourceDigest = TXTContentDigest(), normalizedDigest = TXTContentDigest()
                    var sourceBytes: Int64 = 0, normalizedBytes: Int64 = 0
                    func process(_ bytes: Data, skip: Int = 0) throws {
                        try Task.checkCancellation()
                        try sourceDigest.update(bytes)
                        guard Int64(bytes.count) <= Int64.max-sourceBytes else { throw TXTProcessingError.byteOffsetOverflow }
                        sourceBytes += Int64(bytes.count)
                        let converted: Data
                        do { converted = try decoder.decode(Data(bytes.dropFirst(skip))) }
                        catch let failure as TXTNormalizationError where requested == .automatic && choice.bomBytes == 0 {
                            if case .invalidEncoding = failure { throw TXTNormalizationError.encodingChoiceRequired }
                            throw failure
                        }
                        try output.write(contentsOf: converted)
                        try normalizedDigest.update(converted)
                        guard Int64(converted.count) <= Int64.max-normalizedBytes else { throw TXTProcessingError.byteOffsetOverflow }
                        normalizedBytes += Int64(converted.count)
                    }
                    try process(header, skip: choice.bomBytes)
                    while try TXTFileAccess.consumeChunk(from: input, maximumBytes: chunkBytes, operation: { try process($0) }) {}
                    do { try decoder.finish() }
                    catch let failure as TXTNormalizationError where requested == .automatic && choice.bomBytes == 0 {
                        if case .invalidEncoding = failure { throw TXTNormalizationError.encodingChoiceRequired }
                        throw failure
                    }
                    try Task.checkCancellation()
                    guard normalizedBytes > 0 else { throw TXTProcessingError.emptyText }
                    try output.synchronize()
                    return TXTNormalizationResult(encoding: choice.encoding, sourceSHA256: sourceDigest.hexDigest(),
                        normalizedSHA256: normalizedDigest.hexDigest(), sourceBytes: sourceBytes,
                        normalizedBytes: normalizedBytes, normalizerVersion: Self.version, codecIdentifier: Self.codecIdentifier)
                }
            }
            try Task.checkCancellation()
            try manager.moveItem(at: temporary, to: destination)
            return result
        } catch {
            let original = error
            do { try manager.removeItem(at: temporary) }
            catch { throw TXTNormalizationError.cleanupFailed(original: String(describing: original), cleanup: String(describing: error)) }
            throw original
        }
    }

    static func chooseEncoding(header: Data, requested: TXTEncoding) throws -> (encoding: TXTEncoding, bomBytes: Int) {
        let bytes = Array(header)
        if bytes.starts(with: [0xFF,0xFE,0,0]) || bytes.starts(with: [0,0,0xFE,0xFF]) { throw TXTNormalizationError.unsupportedBOM }
        let bom: (TXTEncoding, Int)?
        if bytes.starts(with: [0xEF,0xBB,0xBF]) { bom = (.utf8,3) }
        else if bytes.starts(with: [0xFF,0xFE]) { bom = (.utf16LittleEndian,2) }
        else if bytes.starts(with: [0xFE,0xFF]) { bom = (.utf16BigEndian,2) }
        else { bom = nil }
        if let (encoding,count) = bom {
            guard requested == .automatic || requested == encoding else { throw TXTNormalizationError.conflictingBOM }
            return (encoding,count)
        }
        return (requested == .automatic ? .utf8 : requested,0)
    }

    private static func write<T>(to url: URL, operation: (FileHandle) throws -> T) throws -> T {
        let handle = try FileHandle(forWritingTo: url)
        let result: T
        do { result = try operation(handle) }
        catch {
            let original = error
            do { try handle.close() }
            catch { throw TXTProcessingError.operationAndCloseFailed(operation: String(describing: original), close: String(describing: error)) }
            throw original
        }
        try handle.close()
        return result
    }
}

private struct TXTStreamDecoder {
    let encoding: TXTEncoding
    private var offset: Int64
    private var validator = TXTUTF8Validator()
    private var pending: [UInt8] = []
    private var highSurrogate: UInt16?
    private var highOffset: Int64 = 0
    init(encoding: TXTEncoding, startOffset: Int64) { self.encoding=encoding; offset=startOffset }

    mutating func decode(_ data: Data) throws -> Data {
        switch encoding {
        case .utf8:
            for byte in data {
                if byte == 0 { throw TXTNormalizationError.nonTextByte(byteOffset: offset) }
                do { try validator.accept(byte, at: offset) }
                catch { throw TXTNormalizationError.invalidEncoding(encoding: encoding, byteOffset: offset) }
                offset += 1
            }
            return data
        case .utf16LittleEndian, .utf16BigEndian:
            let bytes = pending + Array(data)
            pending.removeAll(keepingCapacity: true)
            var output = Data(), index = 0
            while index+1 < bytes.count {
                if index % 4096 == 0 { try Task.checkCancellation() }
                let unit = encoding == .utf16LittleEndian
                    ? UInt16(bytes[index]) | (UInt16(bytes[index+1]) << 8)
                    : (UInt16(bytes[index]) << 8) | UInt16(bytes[index+1])
                let scalar: UInt32?
                if let high = highSurrogate {
                    guard 0xDC00...0xDFFF ~= unit else { throw invalid(highOffset) }
                    scalar = 0x10000 + (UInt32(high)-0xD800)*0x400 + UInt32(unit)-0xDC00
                    highSurrogate = nil
                } else if 0xD800...0xDBFF ~= unit {
                    highSurrogate=unit; highOffset=offset; scalar=nil
                } else if 0xDC00...0xDFFF ~= unit { throw invalid(offset) }
                else { scalar=UInt32(unit) }
                if let value=scalar {
                    guard value != 0 else { throw TXTNormalizationError.nonTextByte(byteOffset: offset) }
                    guard let unicode=Unicode.Scalar(value) else { throw invalid(offset) }
                    output.append(contentsOf: String(unicode).utf8)
                }
                offset += 2; index += 2
            }
            if index < bytes.count { pending.append(bytes[index]) }
            return output
        case .gb18030:
            let bytes = pending + Array(data)
            pending.removeAll(keepingCapacity: true)
            guard !bytes.isEmpty else { return Data() }
            var output = [UInt8](repeating: 0, count: bytes.count*4+4)
            var consumed=0, produced=0
            let status = bytes.withUnsafeBufferPointer { input in
                output.withUnsafeMutableBufferPointer { target in
                    xr_gb18030_to_utf8(input.baseAddress, input.count, target.baseAddress, target.count, &consumed, &produced)
                }
            }
            guard status == 0 || status == 1 else {
                if status == 3 || status == 5 { throw invalid(offset+Int64(consumed)) }
                throw TXTNormalizationError.codecUnavailable
            }
            pending = Array(bytes.dropFirst(consumed))
            guard pending.count <= 3 else { throw invalid(offset+Int64(consumed)) }
            // Validate the system output and reject NUL; never accept a replacement conversion.
            var checked = TXTUTF8Validator()
            for (index,byte) in output.prefix(produced).enumerated() {
                if byte == 0 { throw TXTNormalizationError.nonTextByte(byteOffset: offset) }
                try checked.accept(byte, at: Int64(index))
            }
            try checked.finish()
            offset += Int64(consumed)
            return Data(output.prefix(produced))
        case .automatic: throw TXTProcessingError.invalidConfiguration
        }
    }
    func finish() throws {
        if encoding == .utf8 {
            do { try validator.finish() }
            catch let failure as TXTProcessingError {
                if case .invalidUTF8(let at)=failure { throw invalid(at) }
                throw failure
            }
        }
        if let _ = highSurrogate { throw invalid(highOffset) }
        if !pending.isEmpty { throw invalid(offset) }
    }
    private func invalid(_ at: Int64) -> TXTNormalizationError { .invalidEncoding(encoding: encoding, byteOffset: at) }
}
