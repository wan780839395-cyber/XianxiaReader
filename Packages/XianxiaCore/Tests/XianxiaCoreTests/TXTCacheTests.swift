import Foundation
import XCTest
@testable import XianxiaCore

final class TXTCacheTests: XCTestCase {
    private func root() throws -> URL {
        let url=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url,withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: url) }
        return url
    }
    private func source(_ folder: URL) throws -> URL {
        let url=folder.appendingPathComponent("original.txt")
        try Data("第一卷 山门\n第一章 云海\n原始正文🙂\n第二章 问道\n正文".utf8).write(to: url)
        return url
    }
    private func manifest(_ index: TXTPreparedIndex, storage: URL) -> URL {
        storage.appendingPathComponent(index.normalizedRelativePath).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("index.json")
    }
    private func editManifest(_ index: TXTPreparedIndex, storage: URL, change: (inout [String:Any]) throws -> Void) throws {
        let url=manifest(index,storage: storage)
        var json=try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String:Any])
        try change(&json)
        try JSONSerialization.data(withJSONObject: json).write(to: url)
    }
    func testCacheReuseAcrossNewActorAndPreservesOriginal() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), bookID=UUID()
        let bytes=try Data(contentsOf: original)
        let first=try await TXTIndexCache(storageRoot: storage,chunkBytes: 1).prepare(source: original,bookID: bookID)
        let second=try await TXTIndexCache(storageRoot: storage,chunkBytes: 7).prepare(source: original,bookID: bookID)
        XCTAssertFalse(first.reusedCache); XCTAssertTrue(second.reusedCache)
        XCTAssertEqual(first.chapters,second.chapters); XCTAssertEqual(first.normalizedRelativePath,second.normalizedRelativePath)
        XCTAssertEqual(first.sourceSHA256,second.sourceSHA256)
        XCTAssertEqual(try Data(contentsOf: original),bytes)
        XCTAssertFalse(first.normalizedRelativePath.hasPrefix("/"))
    }
    func testSameSizeContentEditInvalidatesCacheAndLeavesOldGeneration() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), bookID=UUID()
        let cache=try TXTIndexCache(storageRoot: storage)
        let first=try await cache.prepare(source: original,bookID: bookID)
        let old=try await cache.normalizedURL(for: first)
        let originalBytes=try Data(contentsOf: original)
        var changed=originalBytes; changed[changed.count-1]=0x88 // Same length, different valid UTF-8 scalar.
        try changed.write(to: original)
        let second=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertFalse(second.reusedCache); XCTAssertNotEqual(first.sourceSHA256,second.sourceSHA256)
        XCTAssertNotEqual(first.normalizedRelativePath,second.normalizedRelativePath)
        XCTAssertEqual(try Data(contentsOf: old),originalBytes)
    }
    func testCorruptNormalizedTextRebuildsWithoutDeletingOriginal() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let first=try await cache.prepare(source: original,bookID: bookID), url=try await cache.normalizedURL(for: first)
        try Data("损坏cache".utf8).write(to: url)
        let second=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertFalse(second.reusedCache); XCTAssertNotEqual(first.normalizedRelativePath,second.normalizedRelativePath)
        let rebuilt=try await cache.normalizedURL(for: second)
        XCTAssertEqual(try Data(contentsOf: original),try Data(contentsOf: rebuilt))
    }
    func testMalformedManifestAndParserVersionRebuild() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let first=try await cache.prepare(source: original,bookID: bookID)
        try Data("broken json".utf8).write(to: manifest(first,storage: storage))
        let second=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertFalse(second.reusedCache)
        try editManifest(second,storage: storage) { $0["parserVersion"]=999 }
        let third=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertFalse(third.reusedCache); XCTAssertEqual(third.chapters,first.chapters)
    }
    func testCorruptTitleWithValidRangesInvalidatesIndexDigest() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let first=try await cache.prepare(source: original,bookID: bookID)
        try editManifest(first,storage: storage) { json in
            var chapters=try XCTUnwrap(json["chapters"] as? [[String:Any]])
            chapters[1]["title"]="被破坏的标题"
            json["chapters"]=chapters
        }
        let second=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertFalse(second.reusedCache); XCTAssertEqual(first.chapters,second.chapters)
    }
    func testMissingNormalizedCacheRebuilds() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let first=try await cache.prepare(source: original,bookID: bookID)
        try FileManager.default.removeItem(at: await cache.normalizedURL(for: first))
        let second=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertFalse(second.reusedCache); XCTAssertEqual(first.chapters,second.chapters)
    }
    func testManifestCannotRedirectToOtherBookOrParent() async throws {
        for redirect in ["../original.txt","Books/another/original.txt"] {
            let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
            let first=try await cache.prepare(source: original,bookID: bookID)
            try editManifest(first,storage: storage) { $0["normalizedRelativePath"]=redirect }
            do { _=try await cache.prepare(source: original,bookID: bookID); XCTFail("Unsafe metadata must be rejected") }
            catch { XCTAssertEqual(error as? StorageError,.unsafePath) }
            XCTAssertTrue(FileManager.default.fileExists(atPath: original.path))
        }
    }
    func testManagedCacheSymlinkAndDanglingManifestAreRejected() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let first=try await cache.prepare(source: original,bookID: bookID), normalized=try await cache.normalizedURL(for: first)
        try FileManager.default.removeItem(at: normalized)
        try FileManager.default.createSymbolicLink(at: normalized,withDestinationURL: original)
        do { _=try await cache.prepare(source: original,bookID: bookID); XCTFail("No managed symlinks") }
        catch { XCTAssertEqual(error as? StorageError,.unsafePath) }
        let metadata=manifest(first,storage: storage)
        try FileManager.default.removeItem(at: metadata)
        try FileManager.default.createSymbolicLink(at: metadata,withDestinationURL: folder.appendingPathComponent("missing"))
        do { _=try await cache.prepare(source: original,bookID: bookID); XCTFail("Dangling links must be rejected") }
        catch { XCTAssertEqual(error as? StorageError,.unsafePath) }
    }
    func testEncodingSelectionAndBookIDProduceSeparateCacheIdentity() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let auto=try await cache.prepare(source: original,bookID: bookID)
        let explicit=try await cache.prepare(source: original,bookID: bookID,encoding: .utf8)
        let another=try await cache.prepare(source: original,bookID: UUID())
        XCTAssertNotEqual(auto.normalizedRelativePath,explicit.normalizedRelativePath)
        XCTAssertNotEqual(auto.chapters.first?.id,another.chapters.first?.id)
        XCTAssertFalse(explicit.reusedCache); XCTAssertFalse(another.reusedCache)
    }
    func testFailedRebuildPreservesPreviouslyUsableCache() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let bytes=try Data(contentsOf: original), first=try await cache.prepare(source: original,bookID: bookID)
        let old=try await cache.normalizedURL(for: first)
        try Data([0xFF,0x81]).write(to: original)
        do { _=try await cache.prepare(source: original,bookID: bookID); XCTFail("Encoding choice required") }
        catch { XCTAssertEqual(error as? TXTNormalizationError,.encodingChoiceRequired) }
        XCTAssertEqual(try Data(contentsOf: old),bytes)
        try bytes.write(to: original)
        let restored=try await cache.prepare(source: original,bookID: bookID)
        XCTAssertTrue(restored.reusedCache)
    }
    func testCacheCancellationDoesNotTouchOriginalOrPublishedMetadata() async throws {
        let folder=try root(), original=try source(folder), storage=folder.appendingPathComponent("Storage"), cache=try TXTIndexCache(storageRoot: storage), bookID=UUID()
        let first=try await cache.prepare(source: original,bookID: bookID), bytes=try Data(contentsOf: manifest(first,storage: storage))
        let task=Task { withUnsafeCurrentTask { $0?.cancel() }; return try await cache.prepare(source: original,bookID: bookID) }
        do { _=try await task.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertEqual(try Data(contentsOf: manifest(first,storage: storage)),bytes)
    }
}
