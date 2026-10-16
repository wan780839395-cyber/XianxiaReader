import Foundation

public enum ReadingTheme: String, Codable, CaseIterable, Sendable {
    case day, warm, paper, charcoal, oled

    public var title: String {
        switch self {
        case .day: return "日间"
        case .warm: return "暖白"
        case .paper: return "纸色"
        case .charcoal: return "深灰"
        case .oled: return "纯黑"
        }
    }
    public var backgroundRGB: Int {
        switch self {
        case .day: return 0xFFFFFF
        case .warm: return 0xF8F5ED
        case .paper: return 0xEDE0C4
        case .charcoal: return 0x242826
        case .oled: return 0x000000
        }
    }
    public var textRGB: Int { isDark ? 0xC6CCC5 : 0x303832 }
    public var isDark: Bool { self == .charcoal || self == .oled }
}

public enum ReadingFont: String, Codable, CaseIterable, Sendable {
    case original, serif, sansSerif
    public var title: String {
        switch self {
        case .original: return "默认"
        case .serif: return "衬线"
        case .sansSerif: return "无衬线"
        }
    }
}

public enum ReadingAlignment: String, Codable, CaseIterable, Sendable {
    case natural, justified
}

public enum ReadingAppearanceError: LocalizedError, Equatable {
    case invalidSettings, oversizedFile
    public var errorDescription: String? {
        switch self {
        case .invalidSettings: return "阅读设置版本或数值无效，原文件已保留。"
        case .oversizedFile: return "阅读设置文件过大，原文件已保留。"
        }
    }
}

/// App-owned, versioned global preferences. No engine-specific types or book contents.
public struct ReadingAppearance: Codable, Equatable, Sendable {
    public let version: Int
    public var theme: ReadingTheme = .warm
    public var font: ReadingFont = .original
    /// Optional field keeps existing reading-v1 files compatible.
    public var importedFontID: UUID?
    public var fontScale: Double = 1.1
    public var lineHeight: Double = 1.75
    public var paragraphSpacing: Double = 0.8
    public var pageMargins: Double = 1
    public var firstLineIndent = true
    public var alignment: ReadingAlignment = .natural
    public var publisherStyles = false

    public init() { version = 1 }

    public func validated() throws -> Self {
        guard version == 1, fontScale.isFinite, (0.8...2.0).contains(fontScale),
              lineHeight.isFinite, (1.2...2.0).contains(lineHeight),
              paragraphSpacing.isFinite, (0...1.5).contains(paragraphSpacing),
              pageMargins.isFinite, (0.5...2.0).contains(pageMargins) else {
            throw ReadingAppearanceError.invalidSettings
        }
        return self
    }
}
