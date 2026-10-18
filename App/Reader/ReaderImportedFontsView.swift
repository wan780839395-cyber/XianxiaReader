import SwiftUI
import XianxiaCore

@MainActor struct ReaderImportedFontsView: View {
    @ObservedObject var model: ReaderViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    @State private var query = ""
    @Environment(\.dismiss) private var dismiss
    private var palette: ReaderPalette { ReaderPalette(theme: model.appearance.theme) }
    private var fonts: [ReadingFontAsset] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return term.isEmpty ? model.importedFonts : model.importedFonts.filter { $0.displayName.localizedStandardContains(term) }
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("\(model.importedFonts.count) / 12 款").font(.subheadline)
                    Spacer()
                    Button { model.choosingFont = true } label: {
                        Label("导入字体", systemImage: "plus").font(.subheadline.weight(.medium)).frame(minHeight: 44)
                    }.accessibilityIdentifier("reader.font.import")
                }
                if model.importedFonts.isEmpty {
                    ReaderPanelEmptyState(symbol: "textformat.abc", title: "收藏喜欢的字形",
                        message: "导入 TTF / OTF，也可以在其他应用里选择用仙侠阅读打开。每款至多 32 MB。", palette: palette)
                } else if fonts.isEmpty {
                    Text("没有找到这个字体").font(.subheadline).foregroundStyle(palette.secondaryText).padding(.vertical, 20)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2), spacing: 10) {
                        ForEach(fonts) { font in
                            Button { model.selectImportedFont(font.id) } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top, spacing: 6) {
                                        Text(font.displayName).font(.subheadline.weight(.medium)).lineLimit(2)
                                            .frame(maxWidth: .infinity, minHeight: 40, alignment: .topLeading)
                                        Image(systemName: model.appearance.importedFontID == font.id ? "checkmark.circle.fill" : "circle")
                                            .font(.caption).foregroundStyle(palette.accent)
                                    }
                                    ReadingFontPreview(resource: model.fontResourceForPreview(font.id), theme: model.appearance.theme,
                                        pointSize: 19, compact: true, unavailable: !model.isFontAvailable(font.id))
                                }.padding(10).frame(maxWidth: .infinity, minHeight: 106).contentShape(Rectangle())
                            }
                            .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: systemReduceMotion || requestedReduceMotion || model.interaction.reduceMotion, filled: true, radius: 13))
                            .disabled(!model.isFontAvailable(font.id))
                            .accessibilityIdentifier("reader.font.imported.\(font.id.uuidString)")
                            .accessibilityValue(model.appearance.importedFontID == font.id ? "已选择" : "未选择")
                        }
                    }
                }
                if model.fontBusy { ProgressView("正在应用字体并恢复阅读位置…").font(.footnote) }
                if let message = model.fontMessage {
                    Text(message).font(.footnote).foregroundStyle(palette.secondaryText).accessibilityIdentifier("reader.font.message")
                }
                Text("字体仅用于本应用阅读，缺字由系统补全。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
            }.padding(16)
        }
        .accessibilityIdentifier("reader.fonts.scroll")
        .background(palette.background).foregroundStyle(palette.text).tint(palette.accent)
        .navigationTitle("我的字体").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(palette.background, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
        .searchable(text: $query, prompt: "查找字体名称")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: { Label("阅读设置", systemImage: "chevron.left").frame(minHeight: 44) }
                    .accessibilityIdentifier("reader.fonts.back").disabled(model.fontBusy)
            }
        }
        .disabled(model.fontBusy).navigationBarBackButtonHidden(true)
    }
}
