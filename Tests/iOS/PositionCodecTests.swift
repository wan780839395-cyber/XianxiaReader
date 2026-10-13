import Foundation
import ReadiumAdapter
import XCTest
import XianxiaCore

final class PositionCodecTests: XCTestCase {
    func testLocatorRoundTripPreservesFragmentsAndTextContext() throws {
        let id = UUID()
        let json = Data("""
        {"href":"chapter.xhtml#section-2","type":"application/xhtml+xml","title":"第二章",\
        "locations":{"progression":0.25,"totalProgression":0.4,"position":12,"fragments":["section-2"]},\
        "text":{"before":"此前","highlight":"修行","after":"此后"}}
        """.utf8)
        let position = ReadingPosition(bookID: id, engineID: ReadiumPositionCodec.engineID, locatorData: json)
        let locator = try ReadiumPositionCodec.decode(position, bookID: id)
        let encoded = try ReadiumPositionCodec.encode(locator, bookID: id)
        let restored = try ReadiumPositionCodec.decode(encoded, bookID: id)
        XCTAssertEqual(restored, locator)
        XCTAssertEqual(encoded.progression, 0.4)
        XCTAssertEqual(encoded.chapterTitle, "第二章")
    }

    func testWrongBookEngineVersionAndCorruptDataAreRejected() {
        let id = UUID()
        let positions = [
            ReadingPosition(bookID: UUID(), engineID: ReadiumPositionCodec.engineID, locatorData: Data()),
            ReadingPosition(bookID: id, engineID: "unknown", locatorData: Data()),
            ReadingPosition(bookID: id, engineID: ReadiumPositionCodec.engineID, locatorVersion: 2, locatorData: Data()),
            ReadingPosition(bookID: id, engineID: ReadiumPositionCodec.engineID, locatorData: Data("bad json".utf8))
        ]
        for position in positions { XCTAssertThrowsError(try ReadiumPositionCodec.decode(position, bookID: id)) }
    }
}
