import ReadiumNavigator
import XianxiaCore

extension EPUBPreferences {
    mutating func apply(_ appearance: ReadingAppearance) {
        backgroundColor = Color(rawValue: appearance.theme.backgroundRGB)
        textColor = Color(rawValue: appearance.theme.textRGB)
        theme = appearance.theme.isDark ? .dark : .light
        switch appearance.font {
        case .original: fontFamily = nil
        case .serif: fontFamily = .serif
        case .sansSerif: fontFamily = .sansSerif
        }
        if let id = appearance.importedFontID {
            fontFamily = FontFamily(rawValue: "xrfont" + id.uuidString.lowercased().replacingOccurrences(of: "-", with: ""))
        }
        fontSize = appearance.fontScale
        lineHeight = appearance.lineHeight
        paragraphSpacing = appearance.paragraphSpacing
        pageMargins = appearance.pageMargins
        paragraphIndent = appearance.paragraphIndent
        letterSpacing = appearance.letterSpacing
        fontWeight = appearance.fontWeight
        textAlign = appearance.alignment == .justified ? .justify : .start
        publisherStyles = appearance.publisherStyles
    }
}
