import Foundation
import ReadiumShared
import XianxiaCore

enum TXTPositionCodec {
    static let engineID = "readium.txt"
    private struct Envelope: Codable {
        let anchor: TXTReadingAnchor
        let locator: Data
    }
    static func encode(_ locator: Locator, bookID: UUID, plan: TXTReadingPlan) throws -> ReadingPosition {
        guard plan.index.bookID == bookID, let resource = plan.resource(href: href(locator)) else { throw EPUBError.invalidPosition }
        let point = locator.locations.domRange?.jsonObject["start"]?.object
        let selector = point?["cssSelector"]?.string ?? locator.locations.cssSelector
        let offset = point?["charOffset"]?.integer ?? 0
        let paragraph = try paragraphByte(selector: selector) ?? resource.startByte
        let anchor = TXTReadingAnchor(plan: plan, resource: resource, paragraphStartByte: paragraph, characterUTF16Offset: offset)
        guard anchor.isValid(plan: plan, resource: resource) else { throw EPUBError.invalidPosition }
        var native = locator
        native.text.before = native.text.before.map { String($0.suffix(64)) }
        native.text.highlight = native.text.highlight.map { String($0.prefix(256)) }
        native.text.after = native.text.after.map { String($0.prefix(64)) }
        let envelope = Envelope(anchor: anchor, locator: try native.jsonData())
        let progress = Double(resource.startByte) + (locator.locations.progression ?? 0)*Double(resource.endByte-resource.startByte)
        return ReadingPosition(bookID: bookID, engineID: engineID, locatorData: try JSONEncoder().encode(envelope),
            chapterTitle: resource.chapter.title, progression: progress/Double(plan.index.normalizedBytes))
    }
    static func decode(_ position: ReadingPosition, bookID: UUID, plan: TXTReadingPlan) throws -> (Locator, TXTReadingAnchor, TXTReadingResource) {
        guard position.bookID == bookID, plan.index.bookID == bookID, position.engineID == engineID, position.locatorVersion == 1,
              position.locatorData.count <= 64*1024 else { throw EPUBError.invalidPosition }
        let envelope: Envelope
        do { envelope = try JSONDecoder().decode(Envelope.self, from: position.locatorData) }
        catch { throw EPUBError.invalidPosition }
        guard let locator = try Locator(json: JSONValue(jsonData: envelope.locator)),
              let resource = plan.resource(href: href(locator)), envelope.anchor.isValid(plan: plan, resource: resource) else {
            throw EPUBError.invalidPosition
        }
        let point = locator.locations.domRange?.jsonObject["start"]?.object
        let byte = try paragraphByte(selector: point?["cssSelector"]?.string ?? locator.locations.cssSelector) ?? resource.startByte
        guard byte == envelope.anchor.paragraphStartByte,
              (point?["charOffset"]?.integer ?? 0) == envelope.anchor.characterUTF16Offset else { throw EPUBError.invalidPosition }
        return (locator,envelope.anchor,resource)
    }
    private static func href(_ locator: Locator) -> String {
        let value = locator.href.removingQuery().removingFragment().string
        return value.hasPrefix("/") ? String(value.dropFirst()) : value
    }
    private static func paragraphByte(selector: String?) throws -> Int64? {
        guard let selector, let range = selector.range(of: "#txt-b", options: .backwards) else { return nil }
        let number = selector[range.upperBound...].prefix { $0.isASCII && $0.isNumber }
        guard let byte = Int64(number), byte >= 0 else { throw EPUBError.invalidPosition }
        return byte
    }
}
