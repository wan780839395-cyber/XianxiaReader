import SwiftUI
import XianxiaCore

extension ReadingTheme {
    var background: Color { Color(rgb: backgroundRGB) }
    var foreground: Color { Color(rgb: textRGB) }
}

private extension Color {
    init(rgb: Int) {
        self.init(red: Double((rgb >> 16) & 255) / 255,
                  green: Double((rgb >> 8) & 255) / 255, blue: Double(rgb & 255) / 255)
    }
}

@MainActor struct ReaderAppearanceView: View {
    @ObservedObject var model: ReaderViewModel
    @Environment(\.dismiss) private var dismiss

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
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("阅读底色").font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                        HStack(spacing: 10) {
                            ForEach(ReadingTheme.allCases, id: \.self) { theme in
                                Button {
                                    var updated = model.appearance; updated.theme = theme
                                    model.setAppearance(updated)
                                } label: {
                                    VStack(spacing: 7) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 14).fill(theme.background)
                                            Text("文").font(.title3).foregroundStyle(theme.foreground)
                                        }
                                        .frame(height: 48)
                                        .overlay(RoundedRectangle(cornerRadius: 14)
                                            .stroke(model.appearance.theme == theme ? Color.accentColor : Color.secondary.opacity(0.22),
                                                    lineWidth: model.appearance.theme == theme ? 2.5 : 1))
                                        Text(theme.title).font(.caption).foregroundStyle(.primary)
                                    }.frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(theme.title)
                                .accessibilityValue(model.appearance.theme == theme ? "已选择" : "未选择")
                                .accessibilityIdentifier("reader.theme.\(theme.rawValue)")
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 9) {
                        Text("云海问道").font(.headline)
                        Text("山风穿过竹林，云影落在书页间。\n慢慢读，让故事继续。")
                            .font(.system(size: 18 * model.appearance.fontScale,
                                          design: model.appearance.font == .serif ? .serif : .default))
                            .lineSpacing(5)
                    }
                    .foregroundStyle(model.appearance.theme.foreground)
                    .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(model.appearance.theme.background, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.secondary.opacity(0.15)))
                    .accessibilityIdentifier("reader.appearance.preview")

                    VStack(spacing: 18) {
                        Toggle("沿用原书排版", isOn: binding(\.publisherStyles))
                            .accessibilityIdentifier("reader.publisher-styles")
                        Text("关闭后可自定义行距、段距与首行缩进；设置会用于之后打开的书。")
                            .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                        Picker("字体", selection: binding(\.font)) {
                            ForEach(ReadingFont.allCases, id: \.self) { Text($0.title).tag($0) }
                        }.pickerStyle(.segmented).accessibilityIdentifier("reader.font")
                        adjustment("字号", value: model.appearance.fontScale, range: 0.8...2, step: 0.1,
                                   key: \.fontScale, id: "font-size", display: "\(Int((model.appearance.fontScale * 100).rounded()))%")
                        adjustment("左右留白", value: model.appearance.pageMargins, range: 0.5...2, step: 0.25,
                                   key: \.pageMargins, id: "margins", display: model.appearance.pageMargins.formatted(.number.precision(.fractionLength(2))))
                        Group {
                            adjustment("行距", value: model.appearance.lineHeight, range: 1.2...2, step: 0.1,
                                       key: \.lineHeight, id: "line-height", display: model.appearance.lineHeight.formatted(.number.precision(.fractionLength(2))))
                            adjustment("段间距", value: model.appearance.paragraphSpacing, range: 0...1.5, step: 0.1,
                                       key: \.paragraphSpacing, id: "paragraph-spacing", display: model.appearance.paragraphSpacing.formatted(.number.precision(.fractionLength(1))))
                            Toggle("首行缩进两字", isOn: binding(\.firstLineIndent))
                                .accessibilityIdentifier("reader.indent")
                            Picker("对齐方式", selection: binding(\.alignment)) {
                                Text("自然对齐").tag(ReadingAlignment.natural)
                                Text("两端对齐").tag(ReadingAlignment.justified)
                            }.pickerStyle(.segmented)
                        }.disabled(model.appearance.publisherStyles)
                    }
                    .padding(18).background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                    .disabled(model.engine?.appearanceProvider?.supportsTextAppearance != true)
                    if model.engine?.appearanceProvider?.supportsTextAppearance != true {
                        Text("固定布局书籍保留原有页面，正文排版不可调整。")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    if let failure = model.appearanceSaveFailure {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(failure).font(.footnote).foregroundStyle(.red)
                            Button("重试保存") { model.retryAppearanceSave() }
                        }.accessibilityIdentifier("reader.appearance.save-error")
                    }
                    Button("恢复默认阅读设置") { model.setAppearance(ReadingAppearance()) }
                        .frame(maxWidth: .infinity).padding(.bottom, 12)
                }.padding(20)
            }
            .navigationTitle("阅读设置").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { Task { await model.saveNow(); dismiss() } }
                        .accessibilityIdentifier("reader.appearance.done")
                }
            }
        }
        .preferredColorScheme(model.appearance.theme.isDark ? .dark : .light)
        .presentationDetents([.large]).presentationDragIndicator(.visible)
    }

    private func adjustment(_ title: String, value: Double, range: ClosedRange<Double>, step: Double,
                            key: WritableKeyPath<ReadingAppearance, Double>, id: String, display: String) -> some View {
        HStack(spacing: 14) {
            Text(title).font(.subheadline)
            Spacer()
            Button {
                var updated = model.appearance
                updated[keyPath: key] = max(range.lowerBound, value - step)
                model.setAppearance(updated)
            } label: { Image(systemName: "minus").frame(width: 30, height: 32) }
                .disabled(value <= range.lowerBound + 0.001)
                .accessibilityLabel("减小\(title)").accessibilityIdentifier("reader.\(id).decrease")
            Text(display).font(.subheadline.monospacedDigit()).frame(minWidth: 48)
                .accessibilityIdentifier("reader.\(id).value")
            Button {
                var updated = model.appearance
                updated[keyPath: key] = min(range.upperBound, value + step)
                model.setAppearance(updated)
            } label: { Image(systemName: "plus").frame(width: 30, height: 32) }
                .disabled(value >= range.upperBound - 0.001)
                .accessibilityLabel("增大\(title)").accessibilityIdentifier("reader.\(id).increase")
        }.buttonStyle(.bordered)
    }
}
