import Foundation
import XCTest
@testable import XianxiaCore

final class TXTContentDigestTests: XCTestCase {
    private func folder() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: url) }
        return url
    }

    func testFileDigestMatchesKnownSHA256AndPortableIncrementalAcrossChunkBoundaries() throws {
        let url = try folder().appendingPathComponent("digest.bin")
        let vectors: [(Data, String)] = [
            (Data(), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"),
            (Data("abc".utf8), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"),
            (Data("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".utf8), "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"),
            (Data((0..<131_089).map { UInt8(truncatingIfNeeded: $0 * 17 + 29) }), "52806523f6e7e98db5a400a870a703c4bd5347f44df89c6bc491e2739e70dc5d")
        ]
        for (data, expected) in vectors {
            try data.write(to: url)
            var portable = TXTContentDigest(); try portable.update(data)
            XCTAssertEqual(portable.hexDigest(), expected)
            for chunk in data.count > 1000 ? [63, 65, 65_536] : [1, 7, 63, 64, 65, 65_536] {
                let value = try TXTContentDigest.file(url, chunkBytes: chunk)
                XCTAssertEqual(value.sha256, expected); XCTAssertEqual(value.bytes, Int64(data.count))
            }
            XCTAssertEqual(try Data(contentsOf: url), data)
        }
    }

    func testCancelledFileDigestThrowsAndLeavesSourceReadable() async throws {
        let url = try folder().appendingPathComponent("digest.bin"), data = Data(repeating: 0x5a, count: 131_089)
        try data.write(to: url)
        let operation = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try TXTContentDigest.file(url)
        }
        do { _ = try await operation.value; XCTFail("Cancelled verification must not return a partial digest") }
        catch is CancellationError { XCTAssertTrue(operation.isCancelled) }
        catch { XCTFail("Unexpected verification error: \(error)") }
        XCTAssertEqual(try Data(contentsOf: url), data)
        let verified = try TXTContentDigest.file(url)
        var portable = TXTContentDigest(); try portable.update(data)
        XCTAssertEqual(verified.sha256, portable.hexDigest()); XCTAssertEqual(verified.bytes, Int64(data.count))
    }
}
