import Foundation

public enum ReadingFontError: LocalizedError, Equatable {
    case unsupportedFile, invalidFont, fileTooLarge, libraryFull, invalidCatalog, missingFont
    public var errorDescription: String? {
        switch self {
        case .unsupportedFile: return "请选择单字体 TTF 或 OTF 文件，暂不支持字体集合。"
        case .invalidFont: return "无法读取这个字体，请选择有效的单字体文件。"
        case .fileTooLarge: return "字体文件须在 32 MB 以内。"
        case .libraryFull: return "已导入 12 款字体，暂不能继续添加。"
        case .invalidCatalog: return "字体记录无法读取，原文件已保留。"
        case .missingFont: return "字体文件缺失或不可用，已暂用默认字体；原选择保留，可重新导入。"
        }
    }
}

/// Immutable local asset. Display names never enter CSS or file paths.
public struct ReadingFontAsset: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let displayName: String
    public let fileExtension: String
    public let sha256: String
    public let bytes: Int64
    public var relativePath: String { "Fonts/\(id.uuidString.lowercased())/font.\(fileExtension)" }
    public var cssFamily: String { "xrfont" + id.uuidString.lowercased().replacingOccurrences(of: "-", with: "") }

    public init(id: UUID, displayName: String, fileExtension: String, sha256: String, bytes: Int64) throws {
        self.id = id; self.displayName = displayName; self.fileExtension = fileExtension
        self.sha256 = sha256; self.bytes = bytes
        _ = try validated()
    }
    public func validated() throws -> Self {
        guard ["ttf", "otf"].contains(fileExtension), (1...32 * 1_024 * 1_024).contains(bytes),
              !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, displayName.count <= 80,
              !displayName.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }),
              sha256.utf8.count == 64, sha256.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else {
            throw ReadingFontError.invalidCatalog
        }
        return self
    }
}

public struct StagedReadingFont: Sendable {
    public let id: UUID
    public let fileURL: URL
    public let fileExtension: String
    public let sha256: String
    public let bytes: Int64
}
