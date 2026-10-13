import ReadingInterfaces
import SwiftUI
import UIKit
import XianxiaCore

@MainActor struct ReaderView: View {
    let book: Book
    @StateObject private var model: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var showContents = false
    @State private var showBookmarks = false
    @State private var showSearch = false

    init(book: Book, services: AppServices, factory: any ReaderEngineFactory) {
        self.book = book
        _model = StateObject(wrappedValue: ReaderViewModel(book: book, services: services, factory: factory))
    }

    var body: some View {
        ZStack {
            if let engine = model.engine {
                ReaderSurface(viewController: engine.viewController)
                    .accessibilityAction(named: "显示阅读菜单") { model.menuVisible = true }
            }
            if let failure = model.openFailure {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed").font(.largeTitle)
                    Text("书籍无法打开").font(.headline)
                    Text(failure).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("重试") { Task { await model.retryOpen() } }
                }.padding(32)
            } else if !model.isReady { ProgressView("正在打开书籍…") }
            if model.menuVisible || !model.isReady {
                VStack(spacing: 0) {
                    HStack {
                        Button { Task { await model.saveNow(); dismiss() } } label: {
                            Image(systemName: "chevron.down")
                        }.accessibilityLabel("返回书库")
                        Spacer()
                        Text(book.title).font(.headline).lineLimit(1)
                        Spacer()
                        Button { Task { await model.addBookmark() } } label: {
                            Image(systemName: "bookmark.badge.plus")
                        }.accessibilityLabel("添加书签").disabled(!model.isReady)
                    }.padding().background(.regularMaterial)
                    Spacer()
                    VStack(spacing: 12) {
                        HStack {
                            Text(model.position?.chapterTitle ?? "正文").lineLimit(1)
                            Spacer()
                            if let progress = model.position?.progression { Text("\(Int(progress * 100))%") }
                        }.font(.footnote).foregroundStyle(.secondary)
                        HStack {
                            Button("目录") { showContents = true }
                            Spacer()
                            Button(model.scrolling ? "上一节" : "上一页") { Task { await model.engine?.turnPage(forward: false) } }
                            Spacer()
                            Button(model.scrolling ? "下一节" : "下一页") { Task { await model.engine?.turnPage(forward: true) } }
                            Spacer()
                            Button("书签") { showBookmarks = true }
                        }
                        Toggle("章内上下滚动", isOn: Binding(get: { model.scrolling }, set: { model.setScrolling($0) }))
                            .font(.footnote)
                        if model.scrolling {
                            Text("章末可左右划动，或使用上一节 / 下一节接着阅读。")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Button { showSearch = true } label: { Label("书内搜索", systemImage: "magnifyingglass") }
                            .disabled(model.engine?.searchProvider == nil)
                    }.padding().background(.regularMaterial).disabled(!model.isReady)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showContents) {
            NavigationStack {
                List(model.chapters) { chapter in
                    Button {
                        showContents = false
                        Task { await model.go(to: chapter) }
                    } label: {
                        Text(chapter.title).padding(.leading, CGFloat(min(chapter.depth, 6)) * 12)
                    }
                }
                .navigationTitle("目录 · \(model.chapters.count) 条目")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { showContents = false } } }
            }
        }
        .sheet(isPresented: $showBookmarks) {
            NavigationStack {
                List {
                    if model.bookmarks.isEmpty { Text("尚未添加书签").foregroundStyle(.secondary) }
                    ForEach(model.bookmarks) { bookmark in
                        Button {
                            showBookmarks = false
                            Task { await model.go(to: bookmark) }
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bookmark.title)
                                Text(bookmark.createdAt, style: .date).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions {
                            Button("删除", role: .destructive) { Task { await model.removeBookmark(bookmark) } }
                        }
                    }
                }.navigationTitle("书签")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { showBookmarks = false } } }
            }
        }
        .sheet(isPresented: $showSearch) {
            if let provider = model.engine?.searchProvider {
                ReaderSearchView(provider: provider) { result in
                    try await model.go(to: result)
                    showSearch = false
                }
            }
        }
        .alert("阅读提示", isPresented: Binding(get: { model.errorMessage != nil },
                                              set: { if !$0 { model.errorMessage = nil } })) {
            Button("知道了") { model.errorMessage = nil }
        } message: { Text(model.errorMessage ?? "") }
        .task { await model.open() }
        .onDisappear { model.close() }
        .onChange(of: scenePhase) { phase in
            if phase != .active { Task { await model.saveNow() } }
        }
    }
}
