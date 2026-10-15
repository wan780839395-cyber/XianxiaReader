import Foundation

public enum BookEditingError: LocalizedError, Equatable, Sendable {
    case invalidTitle, bookNotFound
    public var errorDescription: String? {
        switch self {
        case .invalidTitle: return "书名须为 1–200 个字符，不能包含换行或控制字符。"
        case .bookNotFound: return "这本书已不在书库中，请刷新后重试。"
        }
    }
}

public enum BookTitle {
    public static func validated(_ input: String) throws -> String {
        let title = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, title.count <= 200,
              !title.unicodeScalars.contains(where: {
                  [.control, .lineSeparator, .paragraphSeparator].contains($0.properties.generalCategory)
              }) else {
            throw BookEditingError.invalidTitle
        }
        return title
    }
}
