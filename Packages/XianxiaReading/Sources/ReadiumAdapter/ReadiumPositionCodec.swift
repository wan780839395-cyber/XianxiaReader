import Foundation
import ReadiumShared
import XianxiaCore

public enum ReadiumPositionCodec {
    public static let engineID = "readium.epub"

    public static func encode(_ locator: Locator, bookID: UUID) throws -> ReadingPosition {
        ReadingPosition(bookID: bookID, engineID: engineID, locatorData: try locator.jsonData(),
                        chapterTitle: locator.title, progression: locator.locations.totalProgression)
    }

    public static func decode(_ position: ReadingPosition, bookID: UUID) throws -> Locator {
        guard position.bookID == bookID, position.engineID == engineID, position.locatorVersion == 1,
              let locator = try Locator(json: JSONValue(jsonData: position.locatorData)) else {
            throw EPUBError.invalidPosition
        }
        return locator
    }
}
