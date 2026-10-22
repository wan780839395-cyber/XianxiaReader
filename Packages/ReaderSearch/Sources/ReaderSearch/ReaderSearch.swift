import Foundation
import XianxiaCore

public enum ReaderSearchLimits {
    public static let queryCharacters = 256
    public static let pageSize = 40
    public static let displayedResults = 1000
    public static let snippetCharacters = 64
}

public struct ReaderSearchHit: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let before: String
    public let highlight: String
    public let after: String
    public let position: ReadingPosition

    public init(id: UUID = UUID(), title: String, before: String, highlight: String,
                after: String, position: ReadingPosition) {
        self.id = id
        self.title = title
        self.before = before
        self.highlight = highlight
        self.after = after
        self.position = position
    }
}

/// Optional engine capability. The UI holds opaque positions, never Readium locators.
public protocol ReaderSearchProviding: Sendable {
    func search(query: String) async throws -> any ReaderSearchSession
}

/// Each session is independent; concurrent next() calls must be rejected or serialized.
public protocol ReaderSearchSession: Sendable {
    func next() async throws -> [ReaderSearchHit]?
    func cancel() async
}

public enum ReaderSearchError: LocalizedError {
    case invalidQuery, unavailable, busy
    public var errorDescription: String? {
        switch self {
        case .invalidQuery: return "请输入 1–256 个字符的关键词。"
        case .unavailable: return "当前书籍或阅读引擎暂不支持搜索。"
        case .busy: return "正在读取搜索结果，请稍后再试。"
        }
    }
}
