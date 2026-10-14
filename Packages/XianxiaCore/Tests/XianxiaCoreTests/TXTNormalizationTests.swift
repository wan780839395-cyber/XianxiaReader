import Foundation
import XCTest
@testable import XianxiaCore

final class TXTNormalizationTests: XCTestCase {
    private let sample="第一章 山门\r\n云海🙂\n第二章 问道\n原文保留"
    private func root() throws -> URL {
        let url=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: url) }
        return url
    }
    private func hex(_ text: String) -> Data {
        let chars=Array(text)
        return Data(stride(from: 0,to: chars.count,by: 2).map { UInt8(String(chars[$0...$0+1]),radix: 16)! })
    }
    private func digest(_ data: Data) throws -> String {
        var value=TXTContentDigest(); try value.update(data); return value.hexDigest()
    }
    private func normalizationError(_ bytes: Data, encoding: TXTEncoding,
                                    expected: TXTNormalizationError) async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("text.txt")
        try bytes.write(to: source)
        do { _=try await TXTNormalizer(chunkBytes: 1).normalize(source: source,destination: output,encoding: encoding); XCTFail("Expected \(expected)") }
        catch { XCTAssertEqual(error as? TXTNormalizationError,expected) }
        XCTAssertEqual(try Data(contentsOf: source),bytes)
        XCTAssertFalse(FileManager.default.fileExists(atPath: output.path))
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path),["source.txt"])
    }

    func testSHA256KnownVectorsAndIncrementalBoundaries() throws {
        let vectors=[("","e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"),
                     ("abc","ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"),
                     ("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq","248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")]
        for (text,expected) in vectors {
            XCTAssertEqual(try digest(Data(text.utf8)),expected)
            var incremental=TXTContentDigest()
            for byte in text.utf8 { try incremental.update(Data([byte])) }
            XCTAssertEqual(incremental.hexDigest(),expected)
            XCTAssertEqual(incremental.hexDigest(),expected,"Finalization must not mutate state")
        }
    }
    func testSHA256MillionBytesAndChineseMatchesIndependentVector() throws {
        var value=TXTContentDigest()
        for _ in 0..<1000 { try value.update(Data(repeating: 0x61,count: 1000)) }
        XCTAssertEqual(value.hexDigest(),"cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0")
        XCTAssertEqual(try digest(Data(sample.utf8)),"912ee09dbbac4c3bd4eb741b2daa51e4fe05a7ad9d29062f902adfb8befca6fe")
    }
    func testUTF8BOMRemovalAndSourceDigestPreserveOriginal() async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt")
        var original=Data([0xEF,0xBB,0xBF]); original.append(contentsOf: sample.utf8); try original.write(to: source)
        for chunk in [1,2,3,64] {
            let output=folder.appendingPathComponent("normalized-\(chunk).txt")
            let result=try await TXTNormalizer(chunkBytes: chunk).normalize(source: source,destination: output)
            XCTAssertEqual(result.encoding,.utf8)
            XCTAssertEqual(try Data(contentsOf: output),Data(sample.utf8))
            XCTAssertEqual(result.sourceSHA256,try digest(original))
            XCTAssertEqual(result.normalizedSHA256,try digest(Data(sample.utf8)))
            XCTAssertEqual(result.sourceBytes,Int64(original.count))
            XCTAssertEqual(result.normalizedBytes,Int64(sample.utf8.count))
        }
        XCTAssertEqual(try Data(contentsOf: source),original)
    }
    func testUTF16LEBEBOMSurrogatesAcrossOneByteChunks() async throws {
        let folder=try root()
        for (encoding,stringEncoding,bom) in [(TXTEncoding.utf16LittleEndian,String.Encoding.utf16LittleEndian,[UInt8(0xFF),0xFE]),
                                                (.utf16BigEndian,.utf16BigEndian,[0xFE,0xFF])] {
            let payload=try XCTUnwrap(sample.data(using: stringEncoding))
            var bytes=Data(bom); bytes.append(payload)
            let source=folder.appendingPathComponent(encoding.rawValue+".txt"), output=folder.appendingPathComponent(encoding.rawValue+"-utf8.txt")
            try bytes.write(to: source)
            let result=try await TXTNormalizer(chunkBytes: 1).normalize(source: source,destination: output)
            XCTAssertEqual(result.encoding,encoding)
            XCTAssertEqual(try String(contentsOf: output,encoding: .utf8),sample)
            XCTAssertEqual(result.normalizedSHA256,"912ee09dbbac4c3bd4eb741b2daa51e4fe05a7ad9d29062f902adfb8befca6fe")
        }
    }
    func testExplicitBOMLessUTF16UsesChosenEncoding() async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("text.txt")
        try XCTUnwrap(sample.data(using: .utf16BigEndian)).write(to: source)
        let result=try await TXTNormalizer(chunkBytes: 3).normalize(source: source,destination: output,encoding: .utf16BigEndian)
        XCTAssertEqual(result.encoding,.utf16BigEndian)
        XCTAssertEqual(try String(contentsOf: output,encoding: .utf8),sample)
    }
    func testGB18030ChineseTwoAndFourByteCharactersAcrossChunks() async throws {
        let bytes=hex("b5dad2bbd5c220c9bdc3c50d0ad4c6baa3953085320ab5dab6fed5c220cecab5c00ad4adcec4b1a3c1f4")
        let folder=try root(), source=folder.appendingPathComponent("source.txt"); try bytes.write(to: source)
        for chunk in [1,2,3,7,64] {
            let output=folder.appendingPathComponent("utf8-\(chunk).txt")
            let result=try await TXTNormalizer(chunkBytes: chunk).normalize(source: source,destination: output,encoding: .gb18030)
            XCTAssertEqual(try String(contentsOf: output,encoding: .utf8),sample)
            XCTAssertEqual(result.sourceSHA256,try digest(bytes))
            XCTAssertEqual(result.normalizedSHA256,"912ee09dbbac4c3bd4eb741b2daa51e4fe05a7ad9d29062f902adfb8befca6fe")
        }
    }
    func testGB18030SupplementaryCJKScalar() async throws {
        let folder=try root()
        // Independent GB18030 vectors include both ends of the supplementary range.
        for (encoded,utf8) in [("90308130","f0908080"),("95328236","f0a08080"),("e3329a35","f48fbfbf")] {
            let source=folder.appendingPathComponent(encoded+".txt"), output=folder.appendingPathComponent(encoded+"-utf8.txt")
            try hex(encoded).write(to: source)
            _=try await TXTNormalizer(chunkBytes: 1).normalize(source: source,destination: output,encoding: .gb18030)
            XCTAssertEqual(try Data(contentsOf: output),hex(utf8))
        }
    }
    func testAutomaticChineseANSIAndUnknownEncodingStillRequiresChoice() async throws {
        let folder=try root(), source=folder.appendingPathComponent("ansi.txt"), output=folder.appendingPathComponent("utf8.txt")
        let bytes=hex("d4c6baa3"); try bytes.write(to:source)
        let result=try await TXTNormalizer(chunkBytes:1).normalize(source:source,destination:output)
        XCTAssertEqual(result.encoding,.gbk)
        XCTAssertEqual(try String(contentsOf:output,encoding:.utf8),"云海")
        XCTAssertEqual(try Data(contentsOf:source),bytes)
        try await normalizationError(Data([0x81]),encoding:.automatic,expected:.encodingChoiceRequired)
        // An authoritative UTF-8 BOM must never fall back to legacy encodings.
        try await normalizationError(Data([0xEF,0xBB,0xBF,0xE4,0xB8]),encoding:.automatic,
            expected:.invalidEncoding(encoding:.utf8,byteOffset:3))
    }
    func testBOMConflictsAndUTF32AreRejected() async throws {
        try await normalizationError(Data([0xFF,0xFE,0x61,0]),encoding: .utf8,expected: .conflictingBOM)
        try await normalizationError(Data([0xEF,0xBB,0xBF,0x61]),encoding: .gb18030,expected: .conflictingBOM)
        try await normalizationError(Data([0xFF,0xFE,0,0]),encoding: .automatic,expected: .unsupportedBOM)
        try await normalizationError(Data([0,0,0xFE,0xFF]),encoding: .automatic,expected: .unsupportedBOM)
    }
    func testUTF16BrokenSurrogateAndOddByteFailWithoutSidecar() async throws {
        try await normalizationError(Data([0xFF,0xFE,0,0xD8]),encoding: .automatic,
                                     expected: .invalidEncoding(encoding: .utf16LittleEndian,byteOffset: 2))
        try await normalizationError(Data([0xFF,0xFE,0,0xDC]),encoding: .automatic,
                                     expected: .invalidEncoding(encoding: .utf16LittleEndian,byteOffset: 2))
        try await normalizationError(Data([0xFF,0xFE,0x61]),encoding: .automatic,
                                     expected: .invalidEncoding(encoding: .utf16LittleEndian,byteOffset: 2))
    }
    func testGB18030InvalidAndTruncatedInputRejectsRatherThanReplacement() async throws {
        try await normalizationError(Data([0x81,0x20]),encoding: .gb18030,
                                     expected: .invalidEncoding(encoding: .gb18030,byteOffset: 0))
        try await normalizationError(Data([0x95,0x30,0x85]),encoding: .gb18030,
                                     expected: .invalidEncoding(encoding: .gb18030,byteOffset: 0))
        for malformed in [[UInt8(0x95),0x30,0x20,0x32],[0x95,0x30,0x85,0x40],[0x80],[0xFF]] {
            try await normalizationError(Data(malformed),encoding: .gb18030,
                                         expected: .invalidEncoding(encoding: .gb18030,byteOffset: 0))
        }
        try await normalizationError(Data([0x61,0x95,0x30,0x85,0x40]),encoding: .gb18030,
                                     expected: .invalidEncoding(encoding: .gb18030,byteOffset: 1))
    }
    func testNULRejectedAndExistingDestinationPreserved() async throws {
        try await normalizationError(Data([0x61,0,0x62]),encoding: .utf8,expected: .nonTextByte(byteOffset: 1))
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("output.txt")
        try Data(sample.utf8).write(to: source); let old=Data("existing".utf8); try old.write(to: output)
        do { _=try await TXTNormalizer().normalize(source: source,destination: output); XCTFail("Must preserve destination") }
        catch { XCTAssertEqual(error as? TXTNormalizationError,.destinationExists) }
        XCTAssertEqual(try Data(contentsOf: output),old)
    }
    func testCancelledNormalizationPreservesOriginalAndNoOutput() async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("output.txt")
        let bytes=Data(sample.utf8); try bytes.write(to: source); let normalizer=try TXTNormalizer()
        let task=Task { withUnsafeCurrentTask { $0?.cancel() }; return try await normalizer.normalize(source: source,destination: output) }
        do { _=try await task.value; XCTFail("Must cancel") } catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertEqual(try Data(contentsOf: source),bytes)
        XCTAssertFalse(FileManager.default.fileExists(atPath: output.path))
    }
    func testNormalizerEmptyInputHasNoOutputOrTemporaryFiles() async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("output.txt")
        try Data([0xEF,0xBB,0xBF]).write(to: source)
        do { _=try await TXTNormalizer().normalize(source: source,destination: output); XCTFail("Empty text must fail") }
        catch { XCTAssertEqual(error as? TXTProcessingError,.emptyText) }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path),["source.txt"])
    }
    func testStreamingFacadeActuallyNormalizesAndIndexes() async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("output.txt")
        try XCTUnwrap(sample.data(using: .utf16LittleEndian)).write(to: source)
        let chapters=try await StreamingTXTIndexer(encoding: .utf16LittleEndian,chunkBytes: 1).buildIndex(source: source,normalizedUTF8: output,bookID: UUID())
        XCTAssertEqual(chapters.map(\.title),["第一章 山门","第二章 问道"])
        XCTAssertEqual(chapters.last?.endByte,Int64(sample.utf8.count))
    }
    func testFacadeFailedEmptyIndexRemovesOnlyNewSidecar() async throws {
        let folder=try root(), source=folder.appendingPathComponent("source.txt"), output=folder.appendingPathComponent("output.txt")
        let bytes=Data("　 \n".utf8); try bytes.write(to: source)
        do { _=try await StreamingTXTIndexer().buildIndex(source: source,normalizedUTF8: output,bookID: UUID()); XCTFail("No body") }
        catch { XCTAssertEqual(error as? TXTProcessingError,.emptyText) }
        XCTAssertEqual(try Data(contentsOf: source),bytes)
        XCTAssertFalse(FileManager.default.fileExists(atPath: output.path))
    }
}
