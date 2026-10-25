import Foundation

/// Independent of typography and of a book's versioned reading locator.
public struct ReadingInteraction: Codable, Equatable, Sendable {
    public let version: Int
    public var continuousScrolling = false
    public var verticalScreenPaging = false
    public var reduceMotion = false
    public var autoHideMenu = true
    public var showsBookProgress = true
    public var automaticScrollSpeed = 1.5

    public init() { version = 1 }

    private enum CodingKeys: String, CodingKey {
        case version, continuousScrolling, verticalScreenPaging, reduceMotion, autoHideMenu, showsBookProgress, automaticScrollSpeed
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decode(Int.self, forKey: .version)
        continuousScrolling = try values.decode(Bool.self, forKey: .continuousScrolling)
        verticalScreenPaging = try values.contains(.verticalScreenPaging)
            ? values.decode(Bool.self, forKey: .verticalScreenPaging) : false
        reduceMotion = try values.decode(Bool.self, forKey: .reduceMotion)
        autoHideMenu = try values.decode(Bool.self, forKey: .autoHideMenu)
        showsBookProgress = try values.contains(.showsBookProgress)
            ? values.decode(Bool.self, forKey: .showsBookProgress) : true
        automaticScrollSpeed = try values.contains(.automaticScrollSpeed)
            ? values.decode(Double.self, forKey: .automaticScrollSpeed) : 1.5
    }

    public func validated() throws -> Self {
        guard version == 1, !verticalScreenPaging || continuousScrolling,
              automaticScrollSpeed.isFinite, (0.5...6).contains(automaticScrollSpeed) else { throw ReadingAppearanceError.invalidSettings }
        return self
    }
}
