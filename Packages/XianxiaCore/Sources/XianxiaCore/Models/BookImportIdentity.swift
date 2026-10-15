import Foundation

/// Original bytes identify a file; normalized TXT bytes identify its interpretation.
/// A nil TXT normalized digest is an incomplete, lazily indexed legacy record.
public struct BookImportIdentity: Codable, Equatable, Sendable {
    public let format: BookFormat
    public let sha256: String
    public let byteCount: Int64
    public let normalizedSHA256: String?

    public init(format: BookFormat, sha256: String, byteCount: Int64, normalizedSHA256: String? = nil) {
        self.format = format; self.sha256 = sha256; self.byteCount = byteCount
        self.normalizedSHA256 = normalizedSHA256
    }
    var complete: Bool { format == .epub || (format == .txt && normalizedSHA256 != nil) }
    func validate() throws {
        func digest(_ value: String) -> Bool { value.utf8.count == 64 && value.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) } }
        guard [.epub, .txt].contains(format), byteCount >= 0, digest(sha256),
              normalizedSHA256.map(digest) ?? true, format != .epub || normalizedSHA256 == nil else {
            throw DatabaseError(message: "导入指纹无效。")
        }
    }
}

public struct BookImportRecord: Sendable {
    public let book: Book
    public let identity: BookImportIdentity?
}

public struct DuplicateBook: Equatable, Sendable, Identifiable {
    public let book: Book
    public let isRemoved: Bool
    public var id: UUID { book.id }
}

public enum BookImportCommit: Sendable {
    case inserted
    case duplicate(DuplicateBook)
}

public enum BookDuplicateError: LocalizedError {
    case originalUnavailable(String)
    public var errorDescription: String? {
        switch self {
        case .originalUnavailable(let reason):
            return "已有书籍的原件无法核实，已停止此次导入，避免误判重复：\(reason)"
        }
    }
}
