import XianxiaCore

/// Presets are actions over existing validated preferences, not a new persisted
/// mode. Opening the panel never overwrites an existing custom configuration.
enum ReadingLayoutPreset: String, CaseIterable, Identifiable {
    case comfortable, spacious, compact
    var id: Self { self }
    var title: String {
        switch self { case .comfortable: return "舒适"; case .spacious: return "宽松"; case .compact: return "紧凑" }
    }
    var detail: String {
        switch self { case .comfortable: return "日常阅读"; case .spacious: return "舒展留白"; case .compact: return "多看几行" }
    }
    func applying(to current: ReadingAppearance) -> ReadingAppearance {
        var value = current
        value.publisherStyles = false; value.firstLineIndent = true; value.indentSize = nil
        value.alignment = .natural; value.letterSpacing = nil; value.fontWeight = nil
        switch self {
        case .comfortable: value.lineHeight = 1.75; value.paragraphSpacing = 0.8; value.pageMargins = 1
        case .spacious: value.lineHeight = 1.95; value.paragraphSpacing = 1; value.pageMargins = 1.25
        case .compact: value.lineHeight = 1.5; value.paragraphSpacing = 0.4; value.pageMargins = 0.75
        }
        return value
    }
    func matches(_ value: ReadingAppearance) -> Bool {
        let preset = applying(to: value)
        return !value.publisherStyles && value.firstLineIndent && value.alignment == .natural
            && abs(value.lineHeight - preset.lineHeight) < 0.001
            && abs(value.paragraphSpacing - preset.paragraphSpacing) < 0.001
            && abs(value.pageMargins - preset.pageMargins) < 0.001
            && abs(value.characterSpacing) < 0.001 && abs(value.weightMultiplier - 1) < 0.001
            && abs(value.paragraphIndent - 2) < 0.001
    }
}
