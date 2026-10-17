import ReadingInterfaces
import SwiftUI
import XianxiaCore

@MainActor struct ReaderSearchView: View {
    @StateObject private var model: ReaderSearchViewModel
    let theme: ReadingTheme
    @Environment(\.dismiss) private var dismiss
    @FocusState private var queryFocused: Bool
    private var palette: ReaderPalette { ReaderPalette(theme: theme) }

    init(provider: any ReaderSearchProviding, theme: ReadingTheme,
         onSelect: @escaping (ReaderSearchHit) async throws -> Void) {
        self.theme = theme
        _model = StateObject(wrappedValue: ReaderSearchViewModel(provider: provider, onSelect: onSelect))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                List {
                    Section {
                        if let error = model.errorMessage {
                            Label(error, systemImage: "exclamationmark.circle")
                                .font(.subheadline).foregroundStyle(.red)
                                .accessibilityIdentifier("reader.search.error")
                        }
                        if model.results.isEmpty && !model.isLoading && model.errorMessage == nil {
                            ReaderPanelEmptyState(symbol: model.didSearch ? "text.magnifyingglass" : "magnifyingglass",
                                                  title: model.didSearch ? "没有找到匹配正文" : "查找书中内容",
                                                  message: model.didSearch ? "换个关键词，再试一次。" : "输入关键词，查找当前书籍中的正文。",
                                                  palette: palette)
                                .accessibilityIdentifier(model.didSearch ? "reader.search.empty" : "reader.search.intro")
                        }
                    }
                    .listRowBackground(palette.card).listRowSeparatorTint(palette.border)
                    if !model.results.isEmpty {
                        Section {
                            ForEach(model.results) { result in
                                Button { Task { await model.select(result) } } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(result.title).font(.caption).foregroundStyle(palette.secondaryText)
                                        (Text(result.before).foregroundColor(palette.text)
                                         + Text(result.highlight).foregroundColor(palette.accent).bold()
                                         + Text(result.after).foregroundColor(palette.text))
                                            .font(.body).lineLimit(4)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                    .padding(.vertical, 6).contentShape(Rectangle())
                                }
                                .buttonStyle(.plain).disabled(model.isLoading)
                                .accessibilityIdentifier("reader.search.result")
                            }
                        } header: {
                            Text("已找到 \(model.results.count) 条").textCase(nil).foregroundStyle(palette.secondaryText)
                        }
                        .listRowBackground(palette.card).listRowSeparatorTint(palette.border)
                    }
                    Section {
                        if model.isLoading {
                            HStack(spacing: 10) {
                                ProgressView().tint(palette.accent)
                                Text("正在搜索…").foregroundStyle(palette.secondaryText)
                                Spacer(minLength: 0)
                                Button("停止") { model.cancel() }.frame(minHeight: 44)
                                    .accessibilityIdentifier("reader.search.stop")
                            }
                        } else if model.reachedLimit {
                            Text("已显示前 1000 条结果，请使用更具体的关键词。")
                                .font(.footnote).foregroundStyle(palette.secondaryText)
                        } else if model.canLoadMore {
                            Button("加载更多结果") { model.loadMore() }.frame(minHeight: 44)
                                .accessibilityIdentifier("reader.search.more")
                        }
                    }.listRowBackground(palette.card)
                }
                .accessibilityIdentifier("reader.search.results")
                .scrollDismissesKeyboard(.interactively)
                .readerPanelList(palette)
            }
            .background(palette.background)
            .toolbarBackground(palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("书内搜索")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }.frame(minHeight: 44)
                        .accessibilityIdentifier("reader.search.done")
                }
            }
        }
        .readerPanelPresentation(palette)
        .onDisappear { model.cancel() }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(palette.secondaryText).accessibilityHidden(true)
                TextField("搜索书中关键词", text: Binding(get: { model.query }, set: { model.setQuery($0) }))
                    .foregroundStyle(palette.text).tint(palette.accent)
                    .frame(minHeight: 44)
                    .submitLabel(.search).onSubmit { submitSearch() }.focused($queryFocused)
                    .autocorrectionDisabled().textInputAutocapitalization(.never)
                    .accessibilityIdentifier("reader.search.query")
                if !model.query.isEmpty {
                    Button { model.setQuery(""); queryFocused = true } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(palette.secondaryText)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain).accessibilityLabel("清空搜索词")
                    .accessibilityIdentifier("reader.search.clear")
                }
            }
            .frame(minHeight: 48).padding(.leading, 12).padding(.trailing, model.query.isEmpty ? 12 : 0)
            .background(palette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            Button("搜索") { submitSearch() }.font(.subheadline.weight(.medium))
                .padding(.horizontal, 12).frame(minHeight: 48)
                .buttonStyle(ReaderPressStyle(palette: palette, filled: true))
                .disabled(model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("reader.search.submit")
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 4)
    }

    private func submitSearch() {
        queryFocused = false
        model.search()
    }
}
