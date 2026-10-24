import SwiftUI
import XianxiaCore

@MainActor struct ReaderAppearanceView: View {
    @ObservedObject var model: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var section = Section.appearance
    @State private var moreLayout = false
    @State private var savingSettings = false
    @State private var settingsCommitFailure: String?
    @EnvironmentObject private var fontInbox: FontDocumentInbox
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
            VStack(spacing: 0) {
                Picker("设置分组", selection: $section) {
                    ForEach(Section.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented).accessibilityIdentifier("reader.appearance.section")
                .padding(.horizontal, 16).padding(.vertical, 8)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if section == .appearance { preview; appearanceControls }
                        else if section == .layout { layoutControls }
                        else { interactionControls }
                        if !supportsText && section != .interaction {
                            Label("固定布局书籍保留原有页面，正文排版不可调整。", systemImage: "info.circle")
                                .font(.footnote).foregroundStyle(palette.secondaryText)
                        }
                        if let failure = model.appearanceSaveFailure {
                            settingsCard {
                                Label(failure, systemImage: "exclamationmark.circle")
                                    .font(.footnote).foregroundStyle(.red)
                                Button("重试保存") { model.retryAppearanceSave() }.frame(minHeight: 44)
                            }.accessibilityIdentifier("reader.appearance.save-error")
                        }
                        if let failure = model.interactionSaveFailure {
                            settingsCard {
                                Label(failure, systemImage: "exclamationmark.circle").font(.footnote).foregroundStyle(.red)
                                Button("重试保存阅读手感") { model.retryInteractionSave() }.frame(minHeight: 44)
                            }.accessibilityIdentifier("reader.interaction.save-error")
                        }
                        if let failure = model.positionSaveFailure {
                            settingsCard {
                                Label(failure, systemImage: "exclamationmark.circle").font(.footnote).foregroundStyle(.red)
                                Button("重试保存阅读位置") { Task { await model.saveNow(source: .positionRetry) } }.frame(minHeight: 44)
                            }.accessibilityIdentifier("reader.position.save-error")
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
                    }.padding(.horizontal, 16).padding(.vertical, 12).disabled(model.fontBusy || savingSettings)
                }
                .id(section)
                .accessibilityIdentifier("reader.appearance.scroll")
            }
            .background(palette.background)
            .overlay(alignment: .bottom) { FontInboxFeedback(inbox: fontInbox) }
            .navigationTitle("阅读设置").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard !savingSettings else { return }
                        savingSettings = true
                        Task {
                            let saved = await model.saveSettingsNow()
                            savingSettings = false
                            if saved { dismiss() }
                            else { settingsCommitFailure = model.appearanceSaveFailure ?? model.interactionSaveFailure }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if savingSettings { ProgressView().controlSize(.small) }
                            Text(savingSettings ? "保存中" : "完成")
                        }.frame(minWidth: 44, minHeight: 44)
                    }
                    .font(.subheadline.weight(.medium))
                    .disabled(model.fontBusy || savingSettings)
                    .accessibilityLabel("完成").accessibilityValue(savingSettings ? "正在保存设置" : "")
                    .accessibilityIdentifier("reader.appearance.done")
                }
            }
        }
        .tint(palette.accent).foregroundStyle(palette.text)
        .readerColorScheme(model.appearance.theme)
        .presentationDetents([.large]).presentationDragIndicator(.visible)
        .interactiveDismissDisabled(model.fontBusy || savingSettings)
        .alert("设置尚未保存", isPresented: Binding(get: { settingsCommitFailure != nil },
                                               set: { if !$0 { settingsCommitFailure = nil } })) {
            Button("知道了") { settingsCommitFailure = nil }
        } message: { Text(settingsCommitFailure ?? "") }
        .task { await model.refreshFontCatalogueForBrowsing() }
        .onReceive(NotificationCenter.default.publisher(for: .readingFontCatalogChanged)) { _ in
            Task { await model.refreshFontCatalogueForBrowsing(force: true) }
        }
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

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10, content: content)
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .readerSurface(palette, radius: 18)
    }

    private var interactionControls: some View {
        VStack(spacing: 14) {
            settingsCard {
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
            settingsCard {
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("云海问道").font(.subheadline.weight(.medium))
                Spacer()
                Text("字形样例").font(.caption2).opacity(0.6)
            }
            ReadingFontPreview(resource: model.fontResourceForPreview(model.appearance.importedFontID),
                systemFont: model.appearance.font, theme: model.appearance.theme,
                pointSize: 18 * model.appearance.fontScale,
                unavailable: model.appearance.importedFontID.map { !model.isFontAvailable($0) } ?? false)
            Text("字体样式预览 · 段落效果以正文为准")
                .font(.caption2).foregroundStyle(model.appearance.theme.foreground.opacity(0.65))
        }
        .foregroundStyle(model.appearance.theme.foreground)
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(model.appearance.theme.background, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("reader.appearance.preview")
    }

    private var appearanceControls: some View {
        VStack(spacing: 14) {
            settingsCard {
                sectionTitle("阅读底色", symbol: "circle.lefthalf.filled")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 8)], spacing: 8) {
                    ForEach(ReadingTheme.allCases, id: \.self) { theme in themeButton(theme) }
                }
            }
            settingsCard {
                sectionTitle("字体与字号", symbol: "textformat")
                Picker("字体", selection: Binding<ReadingFont?>(get: { model.appearance.importedFontID == nil ? model.appearance.font : nil }, set: { if let font = $0 { model.selectBuiltInFont(font) } })) {
                    ForEach(ReadingFont.allCases, id: \.self) { Text($0.title).tag(Optional($0)) }
                }.pickerStyle(.segmented).accessibilityIdentifier("reader.font")
                adjustment("字号", value: model.appearance.fontScale, range: 0.8...2, step: 0.1,
                           key: \.fontScale, id: "font-size", display: "\(Int((model.appearance.fontScale * 100).rounded()))%")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8),
                                         count: dynamicTypeSize.isAccessibilitySize ? 1 : 2), spacing: 8) {
                    ForEach(BundledReadingFont.allCases) { font in
                        Button { model.selectImportedFont(font.id) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Text(font.title).font(.subheadline.weight(.medium))
                                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                    Image(systemName: model.appearance.importedFontID == font.id ? "checkmark.circle.fill" : "circle")
                                        .font(.caption).foregroundStyle(palette.accent)
                                }
                                ReadingFontPreview(resource: model.fontResourceForPreview(font.id), theme: model.appearance.theme,
                                    pointSize: 19, compact: true, unavailable: !model.isFontAvailable(font.id))
                            }.padding(8).frame(maxWidth: .infinity, minHeight: 86, alignment: .leading).contentShape(Rectangle())
                        }
                        .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion, filled: true, radius: 13))
                        .disabled(!model.isFontAvailable(font.id))
                        .accessibilityLabel("\(font.title)，\(font.subtitle)")
                        .accessibilityIdentifier("reader.font.bundled.\(font.rawValue)")
                        .accessibilityValue(model.appearance.importedFontID == font.id ? "已选择" : "未选择")
                    }
                }
                Text("内置字体可离线使用，缺字由系统补全。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
                if let selected = model.importedFonts.first(where: { $0.id == model.appearance.importedFontID }) {
                    Label(model.isFontAvailable(selected.id) ? "正文使用 \(selected.displayName)" : "暂用默认字体，原选择已保留", systemImage: model.isFontAvailable(selected.id) ? "checkmark.circle.fill" : "exclamationmark.circle")
                        .font(.caption).foregroundStyle(palette.accent)
                }
            }.disabled(!supportsText)
            settingsCard {
                NavigationLink {
                    ReaderImportedFontsView(model: model)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "textformat.abc").foregroundStyle(palette.accent)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("我的字体").font(.subheadline.weight(.medium))
                            Text(model.importedFonts.isEmpty ? "导入并收藏喜欢的字形" : "已收藏 \(model.importedFonts.count) 款 · 浏览与选择")
                                .font(.caption).foregroundStyle(palette.secondaryText)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(palette.secondaryText)
                    }.frame(minHeight: 44).contentShape(Rectangle())
                }
                .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
                .accessibilityIdentifier("reader.fonts.open")
                if let message = model.fontMessage {
                    Text(message).font(.footnote).foregroundStyle(palette.secondaryText)
                        .accessibilityIdentifier("reader.font.message")
                }
            }.disabled(!supportsText || model.engine?.fontProvider == nil || model.fontBusy)
        }
    }

    private var layoutControls: some View {
        VStack(spacing: 14) {
            settingsCard {
                HStack {
                    sectionTitle("排版预设", symbol: "text.book.closed")
                    Spacer()
                    if !ReadingLayoutPreset.allCases.contains(where: { $0.matches(model.appearance) }) {
                        Text(model.appearance.publisherStyles ? "原书" : "自定义").font(.caption).foregroundStyle(palette.secondaryText)
                    }
                }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { presetButtons }
                    VStack(spacing: 8) { presetButtons }
                }
                Text("一键搭配排版，保留字体、字号和底色。")
                    .font(.caption).foregroundStyle(palette.secondaryText)
                Toggle("沿用原书排版", isOn: binding(\.publisherStyles))
                    .font(.subheadline).frame(minHeight: 44).accessibilityIdentifier("reader.publisher-styles")
            }
            settingsCard {
                sectionTitle("常用调整", symbol: "text.alignleft")
                VStack(spacing: 0) {
                    adjustment("字号", value: model.appearance.fontScale, range: 0.8...2, step: 0.1,
                               key: \.fontScale, id: "font-size", display: "\(Int((model.appearance.fontScale * 100).rounded()))%")
                    Divider().overlay(palette.border)
                    adjustment("行距", value: model.appearance.lineHeight, range: 1.2...2.8, step: 0.1,
                               key: \.lineHeight, id: "line-height", display: model.appearance.lineHeight.formatted(.number.precision(.fractionLength(2))))
                        .disabled(model.appearance.publisherStyles)
                    Divider().overlay(palette.border)
                    adjustment("左右留白", value: model.appearance.pageMargins, range: 0.25...2.5, step: 0.25,
                               key: \.pageMargins, id: "margins", display: model.appearance.pageMargins.formatted(.number.precision(.fractionLength(2))))
                }
            }
            settingsCard {
                Button { moreLayout.toggle() } label: {
                    HStack {
                        Text("更多调整").font(.subheadline.weight(.medium))
                        Spacer()
                        if !moreLayout { Text("段距 · 字距 · 缩进").font(.caption).foregroundStyle(palette.secondaryText) }
                        Image(systemName: moreLayout ? "chevron.up" : "chevron.down").font(.caption.weight(.semibold))
                    }.frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                }
                .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion))
                .accessibilityIdentifier("reader.layout.more")
                .accessibilityValue(moreLayout ? "已展开" : "已收起")
                if moreLayout {
                    VStack(spacing: 0) {
                        adjustment("段间距", value: model.appearance.paragraphSpacing, range: 0...3, step: 0.1,
                                   key: \.paragraphSpacing, id: "paragraph-spacing", display: model.appearance.paragraphSpacing.formatted(.number.precision(.fractionLength(1))))
                        Divider().overlay(palette.border)
                        adjustment("字距", value: model.appearance.characterSpacing, range: 0...0.5, step: 0.05,
                                   key: \.characterSpacing, id: "letter-spacing", display: model.appearance.characterSpacing.formatted(.number.precision(.fractionLength(2))))
                        Divider().overlay(palette.border)
                        adjustment("字重", value: model.appearance.weightMultiplier, range: 0.5...1.75, step: 0.25,
                                   key: \.weightMultiplier, id: "font-weight", display: model.appearance.fontWeight == nil ? "原字重" : "\(Int(model.appearance.weightMultiplier * 100))%")
                        Divider().overlay(palette.border)
                        adjustment("首行缩进", value: model.appearance.paragraphIndent, range: 0...4, step: 0.5,
                                   key: \.paragraphIndent, id: "indent-size", display: "\(model.appearance.paragraphIndent.formatted(.number.precision(.fractionLength(1)))) 字")
                    }.disabled(model.appearance.publisherStyles)
                    Toggle("启用首行缩进", isOn: binding(\.firstLineIndent))
                        .font(.subheadline).frame(minHeight: 44).accessibilityIdentifier("reader.indent")
                        .disabled(model.appearance.publisherStyles)
                    Picker("对齐方式", selection: binding(\.alignment)) {
                        Text("自然对齐").tag(ReadingAlignment.natural)
                        Text("两端对齐").tag(ReadingAlignment.justified)
                    }.pickerStyle(.segmented).accessibilityIdentifier("reader.alignment")
                        .disabled(model.appearance.publisherStyles)
                    Text("字重效果取决于字体本身。")
                        .font(.caption2).foregroundStyle(palette.secondaryText)
                }
            }
            if model.appearance.publisherStyles {
                Text("关闭“沿用原书排版”后，可调整段落设置。")
                    .font(.footnote).foregroundStyle(palette.secondaryText)
            }
        }.disabled(!supportsText)
    }

    private var presetButtons: some View {
        ForEach(ReadingLayoutPreset.allCases) { preset in
            Button { model.setAppearance(preset.applying(to: model.appearance)) } label: {
                VStack(spacing: 5) {
                    Text(preset.title).font(.subheadline.weight(.medium)).fixedSize()
                    Text(preset.detail).font(.caption2).foregroundStyle(palette.secondaryText).fixedSize()
                }.padding(.horizontal, 8).frame(maxWidth: .infinity, minHeight: 58)
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(preset.matches(model.appearance) ? palette.accent : .clear, lineWidth: 1.5))
            }
            .buttonStyle(ReaderPressStyle(palette: palette, reduceMotion: reduceMotion, filled: true, radius: 13))
            .accessibilityIdentifier("reader.layout.preset.\(preset.rawValue)")
            .accessibilityValue(preset.matches(model.appearance) ? "已选择" : "未选择")
        }
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
            }.frame(maxWidth: .infinity, minHeight: 60)
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
