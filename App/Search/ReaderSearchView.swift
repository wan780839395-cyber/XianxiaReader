import ReadingInterfaces
import SwiftUI

@MainActor struct ReaderSearchView: View {
    @StateObject private var model: ReaderSearchViewModel
    @Environment(\.dismiss) private var dismiss

    init(provider: any ReaderSearchProviding, onSelect: @escaping (ReaderSearchHit) async throws -> Void) {
        _model = StateObject(wrappedValue: ReaderSearchViewModel(provider: provider, onSelect: onSelect))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("搜索书中关键词", text: Binding(get: { model.query }, set: { model.setQuery($0) }))
                            .submitLabel(.search).onSubmit { model.search() }
                            .autocorrectionDisabled().textInputAutocapitalization(.never)
                            .accessibilityIdentifier("reader.search.query")
                        Button("搜索") { model.search() }.disabled(model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .accessibilityIdentifier("reader.search.submit")
                    }
                }
                if let error = model.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }
                if !model.results.isEmpty {
                    Section("已找到 \(model.results.count) 条") {
                        ForEach(model.results) { result in
                            Button { Task { await model.select(result) } } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(result.title).font(.caption).foregroundStyle(.secondary)
                                    (Text(result.before) + Text(result.highlight).bold() + Text(result.after))
                                        .font(.body).foregroundStyle(.primary).lineLimit(4)
                                }.padding(.vertical, 4)
                            }.disabled(model.isLoading).accessibilityIdentifier("reader.search.result")
                        }
                    }
                } else if model.didSearch && !model.isLoading && model.errorMessage == nil {
                    Text("没有找到匹配的正文。可以换个关键词再试。").foregroundStyle(.secondary)
                } else if !model.didSearch && model.errorMessage == nil {
                    Text("输入关键词，查找当前书籍中的正文。").foregroundStyle(.secondary)
                }
                if model.isLoading {
                    HStack { ProgressView(); Text("正在搜索…"); Spacer(); Button("停止") { model.cancel() } }
                } else if model.reachedLimit {
                    Text("已显示前 1000 条结果，请使用更具体的关键词。").font(.footnote).foregroundStyle(.secondary)
                } else if model.canLoadMore {
                    Button("加载更多结果") { model.loadMore() }
                }
            }
            .navigationTitle("书内搜索")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
        }
        .onDisappear { model.cancel() }
    }
}
