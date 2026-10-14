import Foundation
import XCTest
@testable import XianxiaCore

final class TXTReadingPlanCacheTests: XCTestCase {
    private func context(body:String="🙂修行e\u{301}",count:Int=20000) async throws -> (URL,URL,TXTPreparedIndex) {
        let root=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at:root,withIntermediateDirectories:true)
        addTeardownBlock { try FileManager.default.removeItem(at:root) }
        let source=root.appendingPathComponent("source.txt"), storage=root.appendingPathComponent("Storage")
        try Data(("第一卷 山门\n第一章 大章\n"+String(repeating:body,count:count)+"\n第二章 问道\n原书结束。").utf8).write(to:source)
        let index=try await TXTIndexCache(storageRoot:storage).prepare(source:source,bookID:UUID())
        return (root,storage,index)
    }
    private func metadata(_ index:TXTPreparedIndex,_ storage:URL) -> URL {
        storage.appendingPathComponent(index.normalizedRelativePath).deletingLastPathComponent().appendingPathComponent("reading-plan-v1.json")
    }
    private func edit(_ file:URL,_ change:(inout [String:Any]) throws -> Void) throws {
        var object=try XCTUnwrap(JSONSerialization.jsonObject(with:Data(contentsOf:file)) as? [String:Any])
        try change(&object); try JSONSerialization.data(withJSONObject:object).write(to:file)
    }
    func testFreshActorsReuseExactlyLegacyRangesWithBoundedBoundaryReads() async throws {
        let (_,storage,index)=try await context(), cache=try TXTReadingPlanCache(storageRoot:storage)
        let first=try await cache.prepare(index:index), second=try await TXTReadingPlanCache(storageRoot:storage).prepare(index:index)
        let file=storage.appendingPathComponent(index.normalizedRelativePath)
        let legacy=try await TXTReadingPlanner().build(index:index,file:file)
        XCTAssertFalse(first.reusedCache); XCTAssertTrue(second.reusedCache)
        XCTAssertEqual(second.plan.resources,legacy.resources); XCTAssertEqual(first.plan.resources,legacy.resources)
        XCTAssertGreaterThan(second.boundaryBytesRead,0)
        XCTAssertLessThanOrEqual(second.boundaryBytesRead,legacy.resources.count*2)
        let resource=try XCTUnwrap(legacy.resources.dropFirst().first)
        let anchor=TXTReadingAnchor(plan:legacy,resource:resource,paragraphStartByte:resource.startByte,characterUTF16Offset:0)
        XCTAssertTrue(anchor.isValid(plan:second.plan,resource:resource))
    }
    func testMissingMalformedAndVersionMetadataRebuildsWithoutChangingResources() async throws {
        let (_,storage,index)=try await context(), cache=try TXTReadingPlanCache(storageRoot:storage)
        let first=try await cache.prepare(index:index), file=metadata(index,storage)
        try FileManager.default.removeItem(at:file)
        let missing=try await cache.prepare(index:index); XCTAssertFalse(missing.reusedCache)
        try Data("broken".utf8).write(to:file)
        let corrupt=try await cache.prepare(index:index); XCTAssertFalse(corrupt.reusedCache)
        for key in ["schemaVersion","resourceVersion","resourceBytes","normalizerVersion","parserVersion"] {
            try edit(file) { $0[key]=999 }
            let rebuilt=try await cache.prepare(index:index)
            XCTAssertFalse(rebuilt.reusedCache); XCTAssertEqual(rebuilt.plan.resources,first.plan.resources)
        }
    }
    func testDigestIdentityAndChapterCoverageCorruptionNeverReuse() async throws {
        let (_,storage,index)=try await context(), cache=try TXTReadingPlanCache(storageRoot:storage)
        let first=try await cache.prepare(index:index), file=metadata(index,storage)
        for key in ["bookID","sourceSHA256","normalizedSHA256","codecIdentifier","chaptersSHA256","rangesSHA256"] {
            try edit(file) { $0[key]=key=="bookID" ? UUID().uuidString : "incorrect" }
            let rebuilt=try await cache.prepare(index:index)
            XCTAssertFalse(rebuilt.reusedCache); XCTAssertEqual(rebuilt.plan.resources,first.plan.resources)
        }
    }
    func testValidChecksumCannotApproveContinuationOrPrematureScalarCuts() async throws {
        for (body,delta) in [("🙂",Int64(1)),("a",Int64(-1))] {
            let (_,storage,index)=try await context(body:body,count:140000)
            let cache=try TXTReadingPlanCache(storageRoot:storage), first=try await cache.prepare(index:index), file=metadata(index,storage)
            try edit(file) { object in
                var ranges=try XCTUnwrap(object["ranges"] as? [[String:Any]])
                let end=try XCTUnwrap(ranges[0]["endByte"] as? NSNumber).int64Value+delta
                ranges[0]["endByte"]=end; ranges[1]["startByte"]=end
                var digest=TXTContentDigest()
                try digest.update(JSONSerialization.data(withJSONObject:ranges,options:.sortedKeys))
                object["ranges"]=ranges; object["rangesSHA256"]=digest.hexDigest()
            }
            let rebuilt=try await cache.prepare(index:index)
            XCTAssertFalse(rebuilt.reusedCache); XCTAssertEqual(rebuilt.plan.resources,first.plan.resources)
        }
    }
    func testNormalizedCorruptionRebuildsIndexAndPlanPreservingOriginal() async throws {
        let (root,storage,index)=try await context(), cache=try TXTReadingPlanCache(storageRoot:storage)
        let first=try await cache.prepare(index:index), original=root.appendingPathComponent("source.txt"), bytes=try Data(contentsOf:original)
        try Data("损坏cache".utf8).write(to:storage.appendingPathComponent(index.normalizedRelativePath))
        let refreshed=try await TXTIndexCache(storageRoot:storage).prepare(source:original,bookID:index.bookID)
        let rebuilt=try await cache.prepare(index:refreshed)
        XCTAssertFalse(refreshed.reusedCache); XCTAssertFalse(rebuilt.reusedCache)
        XCTAssertEqual(first.plan.resources,rebuilt.plan.resources); XCTAssertEqual(try Data(contentsOf:original),bytes)
    }
    func testDanglingManifestAndLinkedParentAreRejected() async throws {
        let (root,storage,index)=try await context(), cache=try TXTReadingPlanCache(storageRoot:storage)
        _=try await cache.prepare(index:index)
        let file=metadata(index,storage)
        try FileManager.default.removeItem(at:file)
        try FileManager.default.createSymbolicLink(at:file,withDestinationURL:root.appendingPathComponent("missing"))
        do { _=try await cache.prepare(index:index); XCTFail("Dangling metadata must reject") }
        catch { XCTAssertEqual(error as? StorageError,.unsafePath) }
        try FileManager.default.removeItem(at:file)
        let folder=file.deletingLastPathComponent(), escaped=root.appendingPathComponent("escaped-generation")
        try FileManager.default.moveItem(at:folder,to:escaped)
        try FileManager.default.createSymbolicLink(at:folder,withDestinationURL:escaped)
        do { _=try await cache.prepare(index:index); XCTFail("Linked generation must reject") }
        catch { XCTAssertEqual(error as? StorageError,.unsafePath) }
    }
    func testCancellationAndMetadataIOFailurePreservePublishedFiles() async throws {
        let (root,storage,index)=try await context(), cache=try TXTReadingPlanCache(storageRoot:storage)
        _=try await cache.prepare(index:index)
        let file=metadata(index,storage), before=try Data(contentsOf:file), raw=try Data(contentsOf:root.appendingPathComponent("source.txt"))
        let task=Task { withUnsafeCurrentTask { $0?.cancel() }; return try await cache.prepare(index:index) }
        do { _=try await task.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertEqual(try Data(contentsOf:file),before)
        try FileManager.default.removeItem(at:file)
        try FileManager.default.createDirectory(at:file,withIntermediateDirectories:false)
        do { _=try await cache.prepare(index:index); XCTFail("Directory cannot be a manifest") }
        catch { XCTAssertEqual(error as? TXTProcessingError,.invalidSource) }
        XCTAssertEqual(try Data(contentsOf:root.appendingPathComponent("source.txt")),raw)
    }
}
