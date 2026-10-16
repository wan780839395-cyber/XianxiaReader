import Foundation

/// Independent of typography and of a book's versioned reading locator.
public struct ReadingInteraction: Codable, Equatable, Sendable {
    public let version: Int
    public var continuousScrolling = false
    public var verticalScreenPaging = false
    public var reduceMotion = false
    public var autoHideMenu = true

    public init() { version = 1 }

    private enum CodingKeys: String, CodingKey {
        case version, continuousScrolling, verticalScreenPaging, reduceMotion, autoHideMenu
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decode(Int.self, forKey: .version)
        continuousScrolling = try values.decode(Bool.self, forKey: .continuousScrolling)
        verticalScreenPaging = try values.contains(.verticalScreenPaging)
            ? values.decode(Bool.self, forKey: .verticalScreenPaging) : false
        reduceMotion = try values.decode(Bool.self, forKey: .reduceMotion)
        autoHideMenu = try values.decode(Bool.self, forKey: .autoHideMenu)
    }

    public func validated() throws -> Self {
        guard version == 1, !verticalScreenPaging || continuousScrolling else { throw ReadingAppearanceError.invalidSettings }
        return self
    }
}
