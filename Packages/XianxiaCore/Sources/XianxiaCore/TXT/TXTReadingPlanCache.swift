import Foundation

public struct TXTPreparedReadingPlan: Sendable {
    public let plan: TXTReadingPlan
    public let reusedCache: Bool
    /// Actual one-byte reads used to verify cached scalar boundaries; excludes index digest reads.
    public let boundaryBytesRead: Int
}

private struct TXTReadingRange: Codable {
    let chapterID: String
    let startByte: Int64
    let endByte: Int64
}

private struct TXTReadingPlanManifest: Codable {
    let schemaVersion: Int
    let resourceVersion: Int
    let resourceBytes: Int
    let bookID: UUID
    let sourceSHA256: String
    let normalizedSHA256: String
    let normalizedBytes: Int64
    let parserVersion: Int
    let normalizerVersion: Int
    let codecIdentifier: String
    let chaptersSHA256: String
    let rangesSHA256: String
    let ranges: [TXTReadingRange]
}

/// Range metadata only. Caller must obtain a freshly verified index via TXTIndexCache.prepare.
/// Source/normalized full digests are still checked there; cache reuse never trusts mtime alone.
public actor TXTReadingPlanCache {
    public static let maximumManifestBytes = 8 * 1024 * 1024
    private let files: BookFileStore
    private var preparing: Set<UUID> = []
    public init(storageRoot: URL) throws { files = try BookFileStore(root: storageRoot) }

    public func prepare(index: TXTPreparedIndex) async throws -> TXTPreparedReadingPlan {
        guard preparing.insert(index.bookID).inserted else { throw TXTIndexCacheError.alreadyPreparingBook }
        defer { preparing.remove(index.bookID) }
        try Task.checkCancellation()
        let file = try files.resolve(index.normalizedRelativePath)
        let folder = index.normalizedRelativePath.split(separator: "/").dropLast().joined(separator: "/")
        let path = folder + "/reading-plan-v\(TXTReadingPlan.version).json"
        if let cached = try load(path: path, file: file, index: index) { return cached }
        let plan = try await TXTReadingPlanner().build(index: index, file: file)
        try Task.checkCancellation()
        let ranges = plan.resources.map { TXTReadingRange(chapterID: $0.chapter.id, startByte: $0.startByte, endByte: $0.endByte) }
        let manifest = TXTReadingPlanManifest(schemaVersion: 1, resourceVersion: TXTReadingPlan.version,
            resourceBytes: TXTReadingPlan.resourceBytes, bookID: index.bookID,
            sourceSHA256: index.sourceSHA256, normalizedSHA256: index.normalizedSHA256,
            normalizedBytes: index.normalizedBytes, parserVersion: TXTChapterHeadingRecognizer.parserVersion,
            normalizerVersion: TXTNormalizer.version, codecIdentifier: index.codecIdentifier,
            chaptersSHA256: try digest(index.chapters), rangesSHA256: try digest(ranges), ranges: ranges)
        let data = try JSONEncoder().encode(manifest)
        guard data.count <= Self.maximumManifestBytes else { throw TXTIndexCacheError.manifestTooLarge }
        try Task.checkCancellation()
        // Re-resolve after await, rejecting replaced parents and dangling target links.
        try data.write(to: files.resolve(path), options: .atomic)
        return TXTPreparedReadingPlan(plan: plan, reusedCache: false, boundaryBytesRead: 0)
    }

    private func load(path: String, file: URL, index: TXTPreparedIndex) throws -> TXTPreparedReadingPlan? {
        let url = try files.resolve(path)
        let data: Data
        do {
            data = try TXTFileAccess.read(url: url) { handle in
                guard try handle.seekToEnd() <= UInt64(Self.maximumManifestBytes) else { return Data() }
                try handle.seek(toOffset: 0)
                var result = Data()
                while try TXTFileAccess.consumeChunk(from: handle,
                    maximumBytes: min(64*1024, Self.maximumManifestBytes-result.count+1), operation: { result.append($0) }) {
                    if result.count > Self.maximumManifestBytes { return Data() }
                }
                return result
            }
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile { return nil }
        let manifest: TXTReadingPlanManifest
        do { manifest = try JSONDecoder().decode(TXTReadingPlanManifest.self, from: data) }
        catch is DecodingError { return nil } // Rebuildable range metadata; no original or database deletion.
        guard manifest.schemaVersion == 1, manifest.resourceVersion == TXTReadingPlan.version,
              manifest.resourceBytes == TXTReadingPlan.resourceBytes, manifest.bookID == index.bookID,
              manifest.sourceSHA256 == index.sourceSHA256, manifest.normalizedSHA256 == index.normalizedSHA256,
              manifest.normalizedBytes == index.normalizedBytes,
              manifest.parserVersion == TXTChapterHeadingRecognizer.parserVersion,
              manifest.normalizerVersion == TXTNormalizer.version, manifest.codecIdentifier == index.codecIdentifier,
              manifest.chaptersSHA256 == (try digest(index.chapters)),
              manifest.rangesSHA256 == (try digest(manifest.ranges)) else { return nil }
        return try validated(manifest.ranges, file: file, index: index)
    }

    private func validated(_ ranges: [TXTReadingRange], file: URL, index: TXTPreparedIndex) throws -> TXTPreparedReadingPlan? {
        let leaves = index.chapters.filter { $0.startByte != nil }
        guard !leaves.isEmpty, !ranges.isEmpty else { return nil }
        return try TXTFileAccess.withTemporaryObjects {
          try TXTFileAccess.read(url: file) { handle in
            guard try handle.seekToEnd() == UInt64(index.normalizedBytes) else { throw TXTProcessingError.sourceTruncated }
            var ordinal = 0, next = leaves[0].startByte, bytesRead = 0
            var resources: [TXTReadingResource] = []
            func scalarWidth(at offset: Int64) throws -> Int? {
                guard offset >= 0, offset < index.normalizedBytes else { return nil }
                return try TXTFileAccess.withTemporaryObjects {
                    try handle.seek(toOffset: UInt64(offset))
                    guard let data = try handle.read(upToCount: 1), let byte = data.first else { throw TXTProcessingError.sourceTruncated }
                    bytesRead += 1
                    switch byte {
                    case 0...0x7F: return 1
                    case 0xC2...0xDF: return 2
                    case 0xE0...0xEF: return 3
                    case 0xF0...0xF4: return 4
                    default: return nil // Never accept a cut inside a continuation byte.
                    }
                }
            }
            for range in ranges {
                try Task.checkCancellation()
                guard ordinal < leaves.count else { return nil }
                let chapter = leaves[ordinal]
                guard let start = chapter.startByte, let end = chapter.endByte,
                      range.chapterID == chapter.id, range.startByte == next,
                      range.startByte >= start, range.endByte > range.startByte,
                      range.endByte <= end else { return nil }
                let length = range.endByte-range.startByte
                guard length <= Int64(TXTReadingPlan.resourceBytes), try scalarWidth(at: range.startByte) != nil else { return nil }
                if range.endByte < end {
                    guard length >= Int64(TXTReadingPlan.resourceBytes-3),
                          let width = try scalarWidth(at: range.endByte),
                          width > TXTReadingPlan.resourceBytes-Int(length) else { return nil }
                    // Largest complete scalar window, exactly matching the original planner.
                } else if end < index.normalizedBytes {
                    guard try scalarWidth(at: end) != nil else { return nil }
                }
                resources.append(TXTReadingResource(href: "txt-v\(TXTReadingPlan.version)/\(index.normalizedSHA256)/b\(range.startByte).xhtml",
                    chapter: chapter, startByte: range.startByte, endByte: range.endByte))
                if range.endByte == end {
                    ordinal += 1
                    next = ordinal < leaves.count ? leaves[ordinal].startByte : nil
                } else { next = range.endByte }
            }
            guard ordinal == leaves.count else { return nil }
            try Task.checkCancellation()
            return TXTPreparedReadingPlan(plan: TXTReadingPlan(index: index, resources: resources), reusedCache: true, boundaryBytesRead: bytesRead)
          }
        }
    }

    private func digest<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
        var digest = TXTContentDigest(); try digest.update(encoder.encode(value))
        return digest.hexDigest()
    }
}
