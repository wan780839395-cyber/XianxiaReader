import Foundation

public struct TXTPreparedIndex: Equatable, Sendable {
    public let bookID: UUID
    public let sourceSHA256: String
    public let normalizedSHA256: String
    public let encoding: TXTEncoding
    public let normalizedRelativePath: String
    public let normalizedBytes: Int64
    public let chapters: [Chapter]
    public let reusedCache: Bool
}

public enum TXTIndexCacheError: Error, Equatable, Sendable {
    case alreadyPreparingBook
    case manifestTooLarge
}

private struct TXTCacheManifest: Codable {
    let schemaVersion: Int
    let bookID: UUID
    let requestedEncoding: TXTEncoding
    let actualEncoding: TXTEncoding
    let sourceSHA256: String
    let sourceBytes: Int64
    let normalizedSHA256: String
    let normalizedBytes: Int64
    let normalizedRelativePath: String
    let normalizerVersion: Int
    let parserVersion: Int
    let codecIdentifier: String
    let chaptersSHA256: String
    let chapters: [Chapter]
}

/// A cache generation is committed by one atomic manifest write after normalization/indexing.
/// Raw and normalized digests are streamed on lookup; fast metadata-only reopen is a later layer.
public actor TXTIndexCache {
    public static let maximumManifestBytes = 8 * 1024 * 1024
    private let store: BookFileStore
    private let normalizer: TXTNormalizer
    private let scanner: TXTUTF8ChapterScanner
    private var preparing: Set<UUID> = []

    public init(storageRoot: URL, chunkBytes: Int = 64 * 1024) throws {
        store = try BookFileStore(root: storageRoot)
        normalizer = try TXTNormalizer(chunkBytes: chunkBytes)
        scanner = try TXTUTF8ChapterScanner(chunkBytes: chunkBytes)
    }

    public func prepare(source: URL, bookID: UUID, encoding: TXTEncoding = .automatic) async throws -> TXTPreparedIndex {
        guard preparing.insert(bookID).inserted else { throw TXTIndexCacheError.alreadyPreparingBook }
        defer { preparing.remove(bookID) }
        try Task.checkCancellation()
        // This actor owns cache I/O. It never scans the source on MainActor.
        let original = try TXTContentDigest.file(source)
        let key = original.sha256 + "-" + encoding.rawValue + "-n\(TXTNormalizer.version)-p\(TXTChapterHeadingRecognizer.parserVersion)-" + TXTNormalizer.codecIdentifier
        let folder = "Cache/TXT/\(bookID.uuidString.lowercased())/\(key)"
        let manifestPath = folder + "/index.json"
        if let cached = try loadManifest(path: manifestPath, folder: folder, sourceDigest: original,
                                         bookID: bookID, encoding: encoding) { return cached }
        let generation = folder + "/" + UUID().uuidString.lowercased()
        let directory = try store.resolve(generation)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let normalizedPath = generation + "/normalized.txt"
        do {
            let normalized = try store.resolve(normalizedPath)
            let result = try await normalizer.normalize(source: source, destination: normalized, encoding: encoding)
            guard result.sourceSHA256 == original.sha256, result.sourceBytes == original.bytes else {
                throw TXTNormalizationError.sourceChanged
            }
            let scan = try await scanner.scan(file: normalized, bookID: bookID)
            let verifiedNormalized = try TXTContentDigest.file(normalized)
            guard scan.byteCount == result.normalizedBytes, verifiedNormalized.bytes == result.normalizedBytes,
                  verifiedNormalized.sha256 == result.normalizedSHA256 else { throw TXTNormalizationError.sourceChanged }
            try Task.checkCancellation()
            let manifest = TXTCacheManifest(schemaVersion: 1, bookID: bookID, requestedEncoding: encoding,
                actualEncoding: result.encoding, sourceSHA256: result.sourceSHA256, sourceBytes: result.sourceBytes,
                normalizedSHA256: result.normalizedSHA256, normalizedBytes: result.normalizedBytes,
                normalizedRelativePath: normalizedPath, normalizerVersion: TXTNormalizer.version,
                parserVersion: scan.parserVersion, codecIdentifier: result.codecIdentifier,
                chaptersSHA256: try chapterDigest(scan.chapters), chapters: scan.chapters)
            let bytes = try JSONEncoder().encode(manifest)
            guard bytes.count <= Self.maximumManifestBytes else { throw TXTIndexCacheError.manifestTooLarge }
            // Recheck the original after await to reject changes during normalization/indexing.
            let current = try TXTContentDigest.file(source)
            guard current.sha256 == original.sha256, current.bytes == original.bytes else { throw TXTNormalizationError.sourceChanged }
            try Task.checkCancellation()
            // Resolving again rejects a replaced link, including dangling links at the manifest.
            try bytes.write(to: store.resolve(manifestPath), options: .atomic)
            return prepared(manifest, reused: false)
        } catch {
            let originalError = error
            do { try FileManager.default.removeItem(at: store.resolve(generation)) }
            catch { throw TXTNormalizationError.cleanupFailed(original: String(describing: originalError), cleanup: String(describing: error)) }
            throw originalError
        }
    }

    public func normalizedURL(for index: TXTPreparedIndex) throws -> URL { try store.resolve(index.normalizedRelativePath) }

    private func loadManifest(path: String, folder: String, sourceDigest: (sha256: String, bytes: Int64),
                              bookID: UUID, encoding: TXTEncoding) throws -> TXTPreparedIndex? {
        let url = try store.resolve(path)
        let bytes: Data
        do {
            bytes = try TXTFileAccess.read(url: url) { handle in
                guard try handle.seekToEnd() <= UInt64(Self.maximumManifestBytes) else { return Data() }
                try handle.seek(toOffset: 0)
                var result = Data()
                while let part = try handle.read(upToCount: min(64*1024, Self.maximumManifestBytes-result.count+1)), !part.isEmpty {
                    try Task.checkCancellation()
                    result.append(part)
                    if result.count > Self.maximumManifestBytes { return Data() }
                }
                return result
            }
        } catch let failure as CocoaError where failure.code == .fileReadNoSuchFile || failure.code == .fileNoSuchFile { return nil }
        let manifest: TXTCacheManifest
        do { manifest = try JSONDecoder().decode(TXTCacheManifest.self, from: bytes) }
        catch is DecodingError { return nil } // Rebuildable metadata corruption; no source/DB deletion.
        guard manifest.schemaVersion == 1, manifest.bookID == bookID, manifest.requestedEncoding == encoding,
              manifest.actualEncoding != .automatic, manifest.sourceSHA256 == sourceDigest.sha256,
              manifest.sourceBytes == sourceDigest.bytes, manifest.normalizerVersion == TXTNormalizer.version,
              manifest.parserVersion == TXTChapterHeadingRecognizer.parserVersion,
              manifest.codecIdentifier == TXTNormalizer.codecIdentifier, manifest.normalizedBytes > 0,
              manifest.normalizedSHA256.count == 64 else { return nil }
        // Metadata may never redirect to another book, raw file or outside the generation.
        guard manifest.normalizedRelativePath.hasPrefix(folder + "/") else { throw StorageError.unsafePath }
        let suffix = manifest.normalizedRelativePath.dropFirst(folder.count+1).split(separator: "/", omittingEmptySubsequences: false)
        guard suffix.count == 2, UUID(uuidString: String(suffix[0])) != nil, suffix[1] == "normalized.txt" else { throw StorageError.unsafePath }
        let normalized = try store.resolve(manifest.normalizedRelativePath)
        let normalizedDigest: (sha256: String, bytes: Int64)
        do { normalizedDigest = try TXTContentDigest.file(normalized) }
        catch let failure as CocoaError where failure.code == .fileReadNoSuchFile || failure.code == .fileNoSuchFile { return nil }
        guard normalizedDigest.sha256 == manifest.normalizedSHA256, normalizedDigest.bytes == manifest.normalizedBytes,
              validRanges(manifest), try chapterDigest(manifest.chapters) == manifest.chaptersSHA256 else { return nil }
        try Task.checkCancellation()
        return prepared(manifest, reused: true)
    }
    private func validRanges(_ manifest: TXTCacheManifest) -> Bool {
        guard !manifest.chapters.isEmpty else { return false }
        var next: Int64 = 0, ids: Set<String> = []
        for (ordinal,chapter) in manifest.chapters.enumerated() {
            guard chapter.bookID == manifest.bookID, chapter.ordinal == ordinal, ids.insert(chapter.id).inserted,
                  !chapter.title.isEmpty, chapter.title.count <= TXTChapterHeadingRecognizer.maximumTitleCharacters,
                  chapter.depth == 0 || chapter.depth == 1, chapter.href == nil else { return false }
            if let start=chapter.startByte, let end=chapter.endByte {
                guard start == next, end > start, end <= manifest.normalizedBytes,
                      chapter.id == "txt-v1:\(manifest.bookID.uuidString.lowercased()):\(start)" else { return false }
                next=end
            } else {
                guard chapter.startByte == nil, chapter.endByte == nil, chapter.depth == 0,
                      chapter.id.hasPrefix("txt-volume-v1:\(manifest.bookID.uuidString.lowercased()):") else { return false }
            }
        }
        return next == manifest.normalizedBytes
    }
    private func prepared(_ manifest: TXTCacheManifest, reused: Bool) -> TXTPreparedIndex {
        TXTPreparedIndex(bookID: manifest.bookID, sourceSHA256: manifest.sourceSHA256,
            normalizedSHA256: manifest.normalizedSHA256, encoding: manifest.actualEncoding,
            normalizedRelativePath: manifest.normalizedRelativePath, normalizedBytes: manifest.normalizedBytes,
            chapters: manifest.chapters, reusedCache: reused)
    }
    private func chapterDigest(_ chapters: [Chapter]) throws -> String {
        let encoder=JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        var digest=TXTContentDigest()
        try digest.update(encoder.encode(chapters))
        return digest.hexDigest()
    }
}

/// Full normalization+index contract; caller owns managed paths and chooses the encoding.
public actor StreamingTXTIndexer: TXTIndexing {
    private let normalizer: TXTNormalizer
    private let scanner: TXTUTF8ChapterScanner
    private let encoding: TXTEncoding
    public init(encoding: TXTEncoding = .automatic, chunkBytes: Int = 64 * 1024) throws {
        self.encoding=encoding
        normalizer=try TXTNormalizer(chunkBytes: chunkBytes)
        scanner=try TXTUTF8ChapterScanner(chunkBytes: chunkBytes)
    }
    public func buildIndex(source: URL, normalizedUTF8: URL, bookID: UUID) async throws -> [Chapter] {
        _ = try await normalizer.normalize(source: source, destination: normalizedUTF8, encoding: encoding)
        do { return try await scanner.scan(file: normalizedUTF8, bookID: bookID).chapters }
        catch {
            let original=error
            do { try FileManager.default.removeItem(at: normalizedUTF8) }
            catch { throw TXTNormalizationError.cleanupFailed(original: String(describing: original), cleanup: String(describing: error)) }
            throw original
        }
    }
}
