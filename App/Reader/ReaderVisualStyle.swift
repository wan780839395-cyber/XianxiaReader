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
    var edgeLight: Color { Color.white.opacity(theme.isDark ? 0.09 : 0.95) }
    var shadow: Color { Color(readerRGB: 0x0D2117) }
}

/// An opaque, quiet surface above the page. Decoration never receives book input.
private struct ReaderPanelSurface: ViewModifier {
    let palette: ReaderPalette
    let cornerRadius: CGFloat
    let elevated: Bool
    let fill: Color?
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape.fill(fill ?? palette.card)
                    .overlay {
                        if fill == nil {
                            shape.fill(LinearGradient(
                                colors: [Color.white.opacity(palette.theme.isDark ? 0.025 : 0.5), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                    .allowsHitTesting(false)
            }
            .overlay {
                shape.strokeBorder(LinearGradient(
                    colors: [palette.edgeLight, contrast == .increased ? palette.text.opacity(0.35) : palette.border],
                    startPoint: .top, endPoint: .bottom), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: palette.shadow.opacity(elevated ? (palette.theme.isDark ? 0.28 : 0.12) : 0.04),
                    radius: elevated ? 18 : 8, x: 0, y: elevated ? 8 : 3)
            .shadow(color: palette.shadow.opacity(elevated ? 0.06 : 0.025), radius: 1, x: 0, y: 1)
    }
}

extension View {
    func readerSurface(_ palette: ReaderPalette, radius: CGFloat = 22,
                       elevated: Bool = false, fill: Color? = nil) -> some View {
        modifier(ReaderPanelSurface(palette: palette, cornerRadius: radius, elevated: elevated, fill: fill))
    }
}

/// Keep standard Button activation, cancellation and accessibility semantics.
/// The visual label settles on release; the outer hit region stays at least 44pt.
struct ReaderPressStyle: ButtonStyle {
    let palette: ReaderPalette
    var reduceMotion = false
    var filled = false
    var radius: CGFloat = 14
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let reduced = reduceMotion || systemReduceMotion || requestedReduceMotion
        let pressed = configuration.isPressed && isEnabled
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        configuration.label
            .background {
                shape.fill(filled ? palette.control : .clear)
                    .overlay(shape.fill(palette.accent.opacity(pressed ? 0.14 : 0)))
                    .overlay(shape.strokeBorder(
                        contrast == .increased ? palette.text.opacity(0.32) : (filled ? palette.border : .clear),
                        lineWidth: 1))
                    .allowsHitTesting(false)
            }
            .scaleEffect(pressed && !reduced ? 0.975 : 1)
            .offset(y: pressed && !reduced ? 0.5 : 0)
            .animation(reduced ? nil : (pressed ? .easeOut(duration: 0.08) : .spring(response: 0.28, dampingFraction: 0.82)),
                       value: pressed)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.35)
            .transaction { if reduced { $0.animation = nil; $0.disablesAnimations = true } }
    }
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
            .readerSurface(palette)
    }
}
