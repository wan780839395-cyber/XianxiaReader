import Foundation

/// Independent of typography and of a book's versioned reading locator.
public struct ReadingInteraction: Codable, Equatable, Sendable {
    public let version: Int
    public var continuousScrolling = false
    public var reduceMotion = false
    public var autoHideMenu = true

    public init() { version = 1 }

    public func validated() throws -> Self {
        guard version == 1 else { throw ReadingAppearanceError.invalidSettings }
        return self
    }
}
