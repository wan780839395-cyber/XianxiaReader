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
        fontSize = appearance.fontScale
        lineHeight = appearance.lineHeight
        paragraphSpacing = appearance.paragraphSpacing
        pageMargins = appearance.pageMargins
        paragraphIndent = appearance.firstLineIndent ? 2 : 0
        textAlign = appearance.alignment == .justified ? .justify : .start
        publisherStyles = appearance.publisherStyles
    }
}
