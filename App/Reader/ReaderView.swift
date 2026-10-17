import ReadingInterfaces
import SwiftUI
import UIKit
import XianxiaCore

@MainActor struct ReaderView: View {
    let book: Book
    @StateObject private var model: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    @State private var showContents = false
    @State private var showBookmarks = false
    @State private var showSearch = false
    @State private var showAppearance = false

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
            ReaderMenuView(book: book, model: model, returnToLibrary: {
                Task {
                    await model.saveNow()
                    if let failure = model.settingsSaveFailure { model.errorMessage = failure }
                    else { dismiss() }
                }
            }, showContents: { showContents = true }, showBookmarks: { showBookmarks = true },
               showSearch: { showSearch = true }, showAppearance: { showAppearance = true })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(model.appearance.theme.background)
        .tint(ReaderPalette(theme: model.appearance.theme).accent)
        .preferredColorScheme(model.appearance.theme.isDark ? .dark : .light)
        .sheet(isPresented: $showAppearance) { ReaderAppearanceView(model: model) }
        .sheet(isPresented: $showContents) {
            ReaderContentsView(chapters: model.chapters, bookTitle: book.title, theme: model.appearance.theme) { chapter in
                showContents = false
                Task { await model.go(to: chapter) }
            }
        }
        .sheet(isPresented: $showBookmarks) {
            ReaderBookmarksView(bookmarks: model.bookmarks, theme: model.appearance.theme,
                                onSelect: { bookmark in
                showBookmarks = false
                Task { await model.go(to: bookmark) }
            }, onDelete: { bookmark in Task { await model.removeBookmark(bookmark) } })
        }
        .sheet(isPresented: $showSearch) {
            if let provider = model.engine?.searchProvider {
                ReaderSearchView(provider: provider, theme: model.appearance.theme,
                                 reduceMotion: model.interaction.reduceMotion) { result in
                    try await model.go(to: result)
                    showSearch = false
                }
            }
        }
        .alert("阅读提示", isPresented: Binding(get: { model.errorMessage != nil },
                                              set: { if !$0 { model.errorMessage = nil } })) {
            Button("知道了") { model.errorMessage = nil }
        } message: { Text(model.errorMessage ?? "") }
        .task { model.setAdditionalReduceMotion(requestedReduceMotion); await model.open() }
        .onChange(of: requestedReduceMotion) { model.setAdditionalReduceMotion($0) }
        .onDisappear { model.close() }
        .onChange(of: scenePhase) { phase in
            if phase != .active { model.pauseAutomaticScroll(); Task { await model.saveNow() } }
        }
    }
}
