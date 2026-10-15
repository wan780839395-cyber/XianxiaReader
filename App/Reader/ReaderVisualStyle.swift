import SwiftUI
import XianxiaCore

extension Color {
    init(readerRGB: Int) {
        self.init(red: Double((readerRGB >> 16) & 255) / 255,
                  green: Double((readerRGB >> 8) & 255) / 255,
                  blue: Double(readerRGB & 255) / 255)
    }
}

extension ReadingTheme {
    var background: Color { Color(readerRGB: backgroundRGB) }
    var foreground: Color { Color(readerRGB: textRGB) }
}

/// Native chrome has its own quiet surfaces; the book's five page colors stay unchanged.
struct ReaderPalette {
    let theme: ReadingTheme
    var background: Color { Color(readerRGB: theme.isDark ? 0x191E1B : 0xF2F4EF) }
    var card: Color { Color(readerRGB: theme.isDark ? 0x252C27 : 0xFFFFFF) }
    var control: Color { Color(readerRGB: theme.isDark ? 0x343E36 : 0xEDF1EB) }
    var accent: Color { Color(readerRGB: theme.isDark ? 0xABC8B4 : 0x3D6955) }
    var text: Color { theme.foreground }
    var secondaryText: Color { text.opacity(0.68) }
    var border: Color { text.opacity(0.08) }
}

struct ReaderSettingsCard<Content: View>: View {
    let palette: ReaderPalette
    let content: Content
    init(palette: ReaderPalette, @ViewBuilder content: () -> Content) {
        self.palette = palette
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(palette.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(palette.border))
    }
}
