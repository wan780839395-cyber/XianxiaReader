import Foundation
import XCTest
@testable import XianxiaCore

final class TXTLegacyEncodingTests: XCTestCase {
    private func root() throws -> URL {
        let root=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at:root,withIntermediateDirectories:true)
        addTeardownBlock { try FileManager.default.removeItem(at:root) }
        return root
    }
    private func bytes(_ hex:String) -> Data {
        let characters=Array(hex)
        return Data(stride(from:0,to:characters.count,by:2).map { UInt8(String(characters[$0...$0+1]),radix:16)! })
    }
    func testGBKBig5Windows1252IndependentVectorsAcrossEverySmallChunk() async throws {
        let root=try root()
        let vectors:[(TXTEncoding,String,String)] = [
            (.gbk,"b5dad2bbd5c220c9bdc3c50d0ad4c6baa3cec ab5c0a1a3".replacingOccurrences(of:" ",with:""),"第一章 山门\r\n云海问道。"),
            (.big5,"b2c4a440b3b920a473aaf90d0ab6b3aefc b0dd b944 a143".replacingOccurrences(of:" ",with:""),"第一章 山門\r\n雲海問道。"),
            (.windows1252,"4368617074657220310d0a436166e920972080","Chapter 1\r\nCafé — €")]
        for (encoding,hex,text) in vectors {
            let raw=bytes(hex), source=root.appendingPathComponent(encoding.rawValue+".txt")
            try raw.write(to:source)
            for chunk in [1,2,3,7,64] {
                let output=root.appendingPathComponent("\(encoding.rawValue)-\(chunk).txt")
                let result=try await TXTNormalizer(chunkBytes:chunk).normalize(source:source,destination:output,encoding:encoding)
                XCTAssertEqual(result.encoding,encoding)
                XCTAssertEqual(try String(contentsOf:output,encoding:.utf8),text)
                XCTAssertEqual(result.codecIdentifier,TXTNormalizer.codecIdentifier(for:encoding))
            }
            XCTAssertEqual(try Data(contentsOf:source),raw)
        }
    }
    func testWindows936EuroAndGB18030FourBytesStayDifferent() async throws {
        let root=try root(), source=root.appendingPathComponent("euro.txt"), output=root.appendingPathComponent("out.txt")
        try Data([0x80]).write(to:source)
        let result=try await TXTNormalizer(chunkBytes:1).normalize(source:source,destination:output)
        XCTAssertEqual(result.encoding,.gbk); XCTAssertEqual(try String(contentsOf:output,encoding:.utf8),"€")
        let supplementary=root.appendingPathComponent("supplementary.txt"), normalized=root.appendingPathComponent("supplementary-utf8.txt")
        try bytes("95328236").write(to:supplementary)
        let automatic=try await TXTNormalizer(chunkBytes:1).normalize(source:supplementary,destination:normalized)
        XCTAssertEqual(automatic.encoding,.gb18030)
        XCTAssertEqual(try Data(contentsOf:normalized),bytes("f0a08080"))
    }
    func testUndefinedTruncatedLegacyAndNULNeverReplaceOrPublish() async throws {
        let root=try root()
        for (ordinal,encoding,raw) in [(0,TXTEncoding.gbk,Data([0x81])),(1,.big5,Data([0xA4])),
                                       (2,.big5,Data([0xA4,0x80])),(3,.windows1252,Data([0x81])),
                                       (4,.gbk,Data([0x61,0,0x62]))] {
            let source=root.appendingPathComponent("\(ordinal).txt"), output=root.appendingPathComponent("\(ordinal)-out.txt")
            try raw.write(to:source)
            do { _=try await TXTNormalizer(chunkBytes:1).normalize(source:source,destination:output,encoding:encoding); XCTFail("Invalid encoding must reject") }
            catch let failure as TXTNormalizationError {
                if ordinal==4 { XCTAssertEqual(failure,.nonTextByte(byteOffset:1)) }
                else { XCTAssertEqual(failure,.invalidEncoding(encoding:encoding,byteOffset:0)) }
            }
            XCTAssertFalse(FileManager.default.fileExists(atPath:output.path))
            XCTAssertEqual(try Data(contentsOf:source),raw)
        }
    }
    func testNewEncodingsImportPersistAndReopenWithCorrectCodecIdentity() async throws {
        let root=try root(), files=try BookFileStore(root:root.appendingPathComponent("Storage"))
        let repository=try SQLiteBookRepository(url:root.appendingPathComponent("library.sqlite"))
        for (encoding,raw,text) in [(TXTEncoding.gbk,Data([0xD4,0xC6,0xBA,0xA3]),"云海"),
                                   (.big5,Data([0xB6,0xB3,0xAE,0xFC]),"雲海"),
                                   (.windows1252,Data([0x63,0x61,0x66,0xE9]),"café")] {
            let source=root.appendingPathComponent(encoding.rawValue+".txt"); try raw.write(to:source)
            let book=try await TXTBookImportService(files:files,repository:repository).importBook(from:source,encoding:encoding)
            XCTAssertEqual(book.txtEncoding,encoding)
            let cache=try TXTIndexCache(storageRoot:files.root)
            let index=try await cache.prepare(source:files.resolve(book.filePath),bookID:book.id,encoding:encoding)
            XCTAssertTrue(index.reusedCache); XCTAssertEqual(index.encoding,encoding)
            XCTAssertEqual(index.codecIdentifier,TXTNormalizer.codecIdentifier(for:encoding))
            let normalized=try await cache.normalizedURL(for:index)
            XCTAssertEqual(try String(contentsOf:normalized,encoding:.utf8),text)
            XCTAssertEqual(try Data(contentsOf:files.resolve(book.filePath)),raw)
        }
        let stored=try await repository.books(); XCTAssertEqual(stored.count,3)
    }
    func testAutomaticStrategyUpgradeKeepsOldUTF8AnchorsAndOriginal() async throws {
        let root=try root(), storage=root.appendingPathComponent("Storage"), source=root.appendingPathComponent("old.txt"), id=UUID()
        let raw=Data("第一章 起点\n旧位置应继续恢复。".utf8); try raw.write(to:source)
        let cache=try TXTIndexCache(storageRoot:storage), first=try await cache.prepare(source:source,bookID:id)
        let normalized=try await cache.normalizedURL(for:first), plan=try await TXTReadingPlanner().build(index:first,file:normalized)
        let resource=try XCTUnwrap(plan.resources.first)
        let anchor=TXTReadingAnchor(plan:plan,resource:resource,paragraphStartByte:resource.startByte,characterUTF16Offset:0)
        let currentFolder=normalized.deletingLastPathComponent().deletingLastPathComponent()
        let legacyFolder=currentFolder.deletingLastPathComponent().appendingPathComponent(currentFolder.lastPathComponent.replacingOccurrences(of:"-auto2",with:""))
        try FileManager.default.moveItem(at:currentFolder,to:legacyFolder)
        let manifest=legacyFolder.appendingPathComponent("index.json")
        var object=try XCTUnwrap(JSONSerialization.jsonObject(with:Data(contentsOf:manifest)) as? [String:Any])
        object["normalizedRelativePath"]=first.normalizedRelativePath.replacingOccurrences(of:"-auto2",with:"")
        try JSONSerialization.data(withJSONObject:object).write(to:manifest)
        let next=try await cache.prepare(source:source,bookID:id)
        XCTAssertFalse(next.reusedCache); XCTAssertEqual(next.normalizedSHA256,first.normalizedSHA256)
        let nextFile=try await cache.normalizedURL(for:next), nextPlan=try await TXTReadingPlanner().build(index:next,file:nextFile)
        XCTAssertTrue(anchor.isValid(plan:nextPlan,resource:try XCTUnwrap(nextPlan.resources.first)))
        XCTAssertEqual(plan.resources,nextPlan.resources); XCTAssertEqual(try Data(contentsOf:source),raw)
    }
}
