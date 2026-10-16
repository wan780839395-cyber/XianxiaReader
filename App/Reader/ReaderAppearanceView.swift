import SwiftUI
import XianxiaCore

@MainActor struct ReaderAppearanceView: View {
    @ObservedObject var model: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    @State private var section = Section.appearance
    private enum Section: String, CaseIterable {
        case appearance = "外观", layout = "排版", interaction = "手感"
    }
    private var palette: ReaderPalette { ReaderPalette(theme: model.appearance.theme) }
    private var supportsText: Bool { model.engine?.appearanceProvider?.supportsTextAppearance == true }
    private var reduceMotion: Bool { systemReduceMotion || requestedReduceMotion || model.interaction.reduceMotion }

    private func binding<Value>(_ key: WritableKeyPath<ReadingAppearance, Value>) -> Binding<Value> {
        Binding(get: { model.appearance[keyPath: key] }, set: { value in
            var updated = model.appearance
            updated[keyPath: key] = value
            model.setAppearance(updated)
        })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("设置分组", selection: $section) {
                        ForEach(Section.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented).accessibilityIdentifier("reader.appearance.section")
                    preview
                    if section == .appearance { appearanceControls }
                    else if section == .layout { layoutControls }
                    else { interactionControls }
                    if !supportsText && section != .interaction {
                        Label("固定布局书籍保留原有页面，正文排版不可调整。", systemImage: "info.circle")
                            .font(.footnote).foregroundStyle(palette.secondaryText)
                    }
                    if let failure = model.appearanceSaveFailure {
                        ReaderSettingsCard(palette: palette) {
                            Label(failure, systemImage: "exclamationmark.circle")
                                .font(.footnote).foregroundStyle(.red)
                            Button("重试保存") { model.retryAppearanceSave() }.frame(minHeight: 44)
                        }.accessibilityIdentifier("reader.appearance.save-error")
                    }
                    if let failure = model.interactionSaveFailure {
                        ReaderSettingsCard(palette: palette) {
                            Label(failure, systemImage: "exclamationmark.circle").font(.footnote).foregroundStyle(.red)
                            Button("重试保存阅读手感") { model.retryInteractionSave() }.frame(minHeight: 44)
                        }.accessibilityIdentifier("reader.interaction.save-error")
                    }
                    VStack(spacing: 4) {
                        Text("设置自动保存，用于之后打开的书")
                            .font(.caption).foregroundStyle(palette.secondaryText)
                        Button(section == .interaction ? "恢复默认阅读手感" : "恢复默认外观和排版") {
                            if section == .interaction { model.setScrolling(false); model.setInteraction(ReadingInteraction()) }
                            else { model.setAppearance(ReadingAppearance()) }
                        }
                            .font(.footnote).frame(minHeight: 44)
                            .accessibilityIdentifier("reader.appearance.reset")
                    }.frame(maxWidth: .infinity)
                }.padding(20).disabled(model.fontBusy)
            }
            .accessibilityIdentifier("reader.appearance.scroll")
            .background(palette.background)
            .navigationTitle("阅读设置").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        Task {
                            await model.saveNow()
                            if model.settingsSaveFailure == nil { dismiss() }
                        }
                    }
                    .font(.subheadline.weight(.medium)).frame(minHeight: 44)
                    .disabled(model.fontBusy)
                    .accessibilityIdentifier("reader.appearance.done")
                }
            }
        }
        .tint(palette.accent).foregroundStyle(palette.text)
        .preferredColorScheme(model.appearance.theme.isDark ? .dark : .light)
        .presentationDetents([.large]).presentationDragIndicator(.visible)
        .interactiveDismissDisabled(model.fontBusy)
        .sheet(isPresented: $model.choosingFont) {
            EPUBDocumentPicker(onCompletion: { [weak model] result in model?.receiveFontFiles(result) },
                onCoordinatorCreated: { [weak model] value in model?.retainFontCoordinator(value) },
                contentTypes: [.data], allowsMultipleSelection: false)
        }
    }

    private func interactionBinding(_ key: WritableKeyPath<ReadingInteraction, Bool>) -> Binding<Bool> {
        Binding(get: { model.interaction[keyPath: key] }, set: { value in
            var updated = model.interaction; updated[keyPath: key] = value
            model.setInteraction(updated)
        })
    }

    private var interactionControls: some View {
        VStack(spacing: 20) {
            ReaderSettingsCard(palette: palette) {
                sectionTitle("阅读方式", symbol: "book")
                Picker("阅读方式", selection: Binding(get: { model.readingMode }, set: { model.setReadingMode($0) })) {
                    ForEach(ReaderMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode).disabled(mode != .horizontal && model.engine?.supportsContinuousScrolling != true)
                    }
                }.pickerStyle(.menu).accessibilityIdentifier("reader.interaction.mode")
                Text("记住你的选择，下次打开书籍时沿用。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
                if model.readingMode == .verticalScreen {
                    Text("上下轻划，松手停稳一屏。保留少量重叠，方便接着读；也可轻点页面上、下方翻屏。")
                        .font(.caption).foregroundStyle(palette.secondaryText)
                }
            }
            ReaderSettingsCard(palette: palette) {
                sectionTitle("沉浸阅读", symbol: "hand.draw")
                Toggle("滑动时收起菜单", isOn: interactionBinding(\.autoHideMenu))
                    .accessibilityIdentifier("reader.interaction.auto-hide")
                Text("轻点页面中央可以再次显示菜单。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
                Divider()
                Toggle("减少阅读动效", isOn: interactionBinding(\.reduceMotion))
                    .accessibilityIdentifier("reader.interaction.reduce-motion")
                Text("减少点按翻页和菜单过渡；手指滑动保持跟手。始终遵循系统的减少动态效果设置。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
            }
        }.disabled(model.engine?.interactionProvider == nil)
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("云海问道").font(.subheadline.weight(.medium))
                Spacer()
                Text(model.appearance.importedFontID == nil ? "阅读预览" : "配色预览").font(.caption2).opacity(0.6)
            }
            Text("山风穿过竹林，云影落在书页间。")
                .font(.system(size: 18 * model.appearance.fontScale,
                              design: model.appearance.font == .serif ? .serif : .default))
                .lineSpacing(5).fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(model.appearance.theme.foreground)
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .readerSurface(palette, fill: model.appearance.theme.background)
        .accessibilityIdentifier("reader.appearance.preview")
    }

    private var appearanceControls: some View {
        VStack(spacing: 20) {
            ReaderSettingsCard(palette: palette) {
                sectionTitle("阅读底色", symbol: "circle.lefthalf.filled")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50), spacing: 10)], spacing: 12) {
                    ForEach(ReadingTheme.allCases, id: \.self) { theme in themeButton(theme) }
                }
            }
            ReaderSettingsCard(palette: palette) {
                sectionTitle("字体与字号", symbol: "textformat")
                Picker("字体", selection: Binding<ReadingFont?>(get: { model.appearance.importedFontID == nil ? model.appearance.font : nil }, set: { if let font = $0 { model.selectBuiltInFont(font) } })) {
                    ForEach(ReadingFont.allCases, id: \.self) { Text($0.title).tag(Optional($0)) }
                }.pickerStyle(.segmented).accessibilityIdentifier("reader.font")
                HStack(spacing: 10) {
                    ForEach(BundledReadingFont.allCases) { font in
                        Button { model.selectImportedFont(font.id) } label: {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(font.title).font(.subheadline.weight(.medium))
                                    Text(font.subtitle).font(.caption2).foregroundStyle(palette.secondaryText)
                                }
                                Spacer(minLength: 0)
                                if model.appearance.importedFontID == font.id {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(palette.accent)
                                }
                            }.padding(10).frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                        }
                        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion, filled: true, radius: 13))
                        .disabled(!model.isFontAvailable(font.id))
                        .accessibilityIdentifier("reader.font.bundled.\(font.rawValue)")
                        .accessibilityValue(model.appearance.importedFontID == font.id ? "已选择" : "未选择")
                    }
                }
                Text("内置字体可离线使用，缺字由系统补全。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
                adjustment("字号", value: model.appearance.fontScale, range: 0.8...2, step: 0.1,
                           key: \.fontScale, id: "font-size", display: "\(Int((model.appearance.fontScale * 100).rounded()))%")
                if let selected = model.importedFonts.first(where: { $0.id == model.appearance.importedFontID }) {
                    Label(model.isFontAvailable(selected.id) ? "正文使用 \(selected.displayName)" : "暂用默认字体，原选择已保留", systemImage: model.isFontAvailable(selected.id) ? "checkmark.circle.fill" : "exclamationmark.circle")
                        .font(.caption).foregroundStyle(palette.accent)
                }
            }.disabled(!supportsText)
            ReaderSettingsCard(palette: palette) {
                sectionTitle("我的字体", symbol: "textformat.abc")
                ForEach(model.importedFonts) { font in
                    Button { model.selectImportedFont(font.id) } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(font.displayName).font(.subheadline).lineLimit(2)
                                Text(ByteCountFormatter.string(fromByteCount: font.bytes, countStyle: .file))
                                    .font(.caption).foregroundStyle(palette.secondaryText)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: model.appearance.importedFontID == font.id ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(palette.accent)
                        }.frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
                    .accessibilityIdentifier("reader.font.imported.\(font.id.uuidString)")
                    .accessibilityValue(model.appearance.importedFontID == font.id ? "已选择" : "未选择")
                }
                if model.fontBusy { ProgressView("正在导入字体并恢复阅读位置…").font(.footnote) }
                else {
                    Button { model.choosingFont = true } label: {
                        Label("导入字体", systemImage: "plus").font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
                    .accessibilityIdentifier("reader.font.import")
                }
                Text("支持 TTF、OTF 单字体，每个不超过 32 MB。缺少的字会使用系统字体补全。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
                if let message = model.fontMessage {
                    Text(message).font(.footnote).foregroundStyle(palette.secondaryText)
                        .accessibilityIdentifier("reader.font.message")
                }
            }.disabled(!supportsText || model.engine?.fontProvider == nil || model.fontBusy)
        }
    }

    private var layoutControls: some View {
        VStack(spacing: 20) {
            ReaderSettingsCard(palette: palette) {
                Toggle(isOn: binding(\.publisherStyles)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("沿用原书排版").font(.subheadline)
                        Text("保留原书的行距、段距与缩进")
                            .font(.caption).foregroundStyle(palette.secondaryText)
                    }
                }.accessibilityIdentifier("reader.publisher-styles")
            }
            ReaderSettingsCard(palette: palette) {
                sectionTitle("页面留白", symbol: "rectangle.inset.filled")
                adjustment("左右留白", value: model.appearance.pageMargins, range: 0.5...2, step: 0.25,
                           key: \.pageMargins, id: "margins", display: model.appearance.pageMargins.formatted(.number.precision(.fractionLength(2))))
            }
            ReaderSettingsCard(palette: palette) {
                sectionTitle("段落节奏", symbol: "text.alignleft")
                adjustment("行距", value: model.appearance.lineHeight, range: 1.2...2, step: 0.1,
                           key: \.lineHeight, id: "line-height", display: model.appearance.lineHeight.formatted(.number.precision(.fractionLength(2))))
                Divider().overlay(palette.border)
                adjustment("段间距", value: model.appearance.paragraphSpacing, range: 0...1.5, step: 0.1,
                           key: \.paragraphSpacing, id: "paragraph-spacing", display: model.appearance.paragraphSpacing.formatted(.number.precision(.fractionLength(1))))
                Divider().overlay(palette.border)
                Toggle("首行缩进两字", isOn: binding(\.firstLineIndent))
                    .font(.subheadline).frame(minHeight: 44).accessibilityIdentifier("reader.indent")
                Picker("对齐方式", selection: binding(\.alignment)) {
                    Text("自然对齐").tag(ReadingAlignment.natural)
                    Text("两端对齐").tag(ReadingAlignment.justified)
                }.pickerStyle(.segmented).accessibilityIdentifier("reader.alignment")
            }.disabled(model.appearance.publisherStyles)
            if model.appearance.publisherStyles {
                Text("关闭“沿用原书排版”后，可调整段落设置。")
                    .font(.footnote).foregroundStyle(palette.secondaryText)
            }
        }.disabled(!supportsText)
    }

    private func sectionTitle(_ title: String, symbol: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: symbol).font(.system(size: 13, weight: .medium))
                .foregroundStyle(palette.accent).frame(width: 27, height: 27)
                .background(palette.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)
            Text(title).font(.subheadline.weight(.medium)).foregroundStyle(palette.text)
        }.accessibilityElement(children: .combine).accessibilityAddTraits(.isHeader)
    }

    private func themeButton(_ theme: ReadingTheme) -> some View {
        let selected = model.appearance.theme == theme
        return Button {
            var updated = model.appearance; updated.theme = theme
            model.setAppearance(updated)
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 15, style: .continuous).fill(theme.background)
                    Text("文").font(.title3).foregroundStyle(theme.foreground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if selected {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(palette.accent).background(palette.card, in: Circle()).padding(4)
                    }
                }
                .frame(height: 52)
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(selected ? palette.accent : palette.border, lineWidth: selected ? 2 : 1))
                Text(theme.title).font(.caption).foregroundStyle(selected ? palette.accent : palette.secondaryText)
            }.frame(maxWidth: .infinity, minHeight: 78)
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
        .accessibilityLabel(theme.title)
        .accessibilityValue(selected ? "已选择" : "未选择")
        .accessibilityIdentifier("reader.theme.\(theme.rawValue)")
    }

    private func adjustment(_ title: String, value: Double, range: ClosedRange<Double>, step: Double,
                            key: WritableKeyPath<ReadingAppearance, Double>, id: String, display: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                Text(title).font(.subheadline).fixedSize()
                Spacer(minLength: 8)
                adjustmentControls(title, value: value, range: range, step: step, key: key, id: id, display: display)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(.subheadline)
                adjustmentControls(title, value: value, range: range, step: step, key: key, id: id, display: display)
            }
        }
    }

    private func adjustmentControls(_ title: String, value: Double, range: ClosedRange<Double>, step: Double,
                                    key: WritableKeyPath<ReadingAppearance, Double>, id: String, display: String) -> some View {
        HStack(spacing: 4) {
            adjustmentButton("minus", label: "减小\(title)", id: "reader.\(id).decrease",
                             disabled: value <= range.lowerBound + 0.001) {
                var updated = model.appearance; updated[keyPath: key] = max(range.lowerBound, value - step)
                model.setAppearance(updated)
            }
            Text(display).font(.subheadline.monospacedDigit()).frame(minWidth: 58, minHeight: 44)
                .accessibilityIdentifier("reader.\(id).value")
            adjustmentButton("plus", label: "增大\(title)", id: "reader.\(id).increase",
                             disabled: value >= range.upperBound - 0.001) {
                var updated = model.appearance; updated[keyPath: key] = min(range.upperBound, value + step)
                model.setAppearance(updated)
            }
        }.fixedSize(horizontal: true, vertical: false)
    }

    private func adjustmentButton(_ symbol: String, label: String, id: String, disabled: Bool,
                                  action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 15, weight: .medium))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion, filled: true, radius: 13))
        .disabled(disabled)
        .accessibilityLabel(label).accessibilityIdentifier(id)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: disabled)
    }
}
