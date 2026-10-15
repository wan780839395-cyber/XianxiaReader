import ReadiumAdapter
import SwiftUI
import XianxiaCore

@MainActor struct LibraryView: View {
    let services: AppServices
    @StateObject private var model: LibraryViewModel
    @State private var selectedBook: Book?
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || requestedReduceMotion }
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 190), spacing: 20, alignment: .topLeading)]

    init(services: AppServices, model: LibraryViewModel? = nil) {
        self.services = services
        _model = StateObject(wrappedValue: model ?? LibraryViewModel(services: services))
    }

    var body: some View {
        NavigationStack {
            shelfContent
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("藏书阁")
            .searchable(text: $model.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索书名或作者")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("显示方式", selection: $model.layout) {
                            ForEach(LibraryLayout.allCases) { layout in Label(layout.title, systemImage: layout.symbol).tag(layout) }
                        }
                        Picker("排序", selection: $model.sortOrder) {
                            ForEach(LibrarySortOrder.allCases) { order in Text(order.title).tag(order) }
                        }
                        Button { model.showTrash() } label: { Label("回收站（\(model.removedBooks.count)）", systemImage: "trash") }
                            .accessibilityIdentifier("library.open-trash")
                    } label: { Image(systemName: model.layout.symbol) }
                        .accessibilityLabel("书架显示与排序").accessibilityIdentifier("library.display")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("从文件导入 EPUB / TXT") { model.presentedSheet = .importFiles }
                        Button("导入内置样书") { model.startSamplesImport() }
                        Button("导入 TXT 样书") { model.startTXTSamplesImport() }
                        Button("TXT 编码") { model.presentedSheet = .txtEncoding }
                        Text("版本 \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "未知") (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "未知"))")
                    } label: { Image(systemName: "plus") }
                        .accessibilityLabel("导入书籍").disabled(model.isImporting || model.isManaging || model.isRenaming)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if model.isImporting {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("正在导入 \(model.importingName)").font(.footnote).lineLimit(1)
                        Button("取消") { model.cancelImport() }
                    }.padding().frame(maxWidth: .infinity).background(.regularMaterial)
                } else if let status = model.importStatus {
                    Text(status).font(.footnote).padding().frame(maxWidth: .infinity).background(.regularMaterial)
                }
                if let error = model.errorMessage, !model.isImporting {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.circle").foregroundStyle(.red)
                        ScrollView { Text(error).font(.footnote).frame(maxWidth: .infinity, alignment: .leading) }
                            .frame(maxHeight: 120)
                        Button("关闭") { model.errorMessage = nil }
                    }.padding().frame(maxWidth: .infinity).background(.regularMaterial)
                        .accessibilityIdentifier("library.import.error")
                }
                if !model.retryTXTFiles.isEmpty, !model.isImporting {
                    Button("选择 TXT 编码并重试") { model.presentedSheet = .txtEncoding }.padding(.bottom, 8)
                }
            }
            .modifier(DocumentImportSheet(model: model))
            .confirmationDialog("移出书架？", isPresented: Binding(get: { model.bookToRemove != nil }, set: { if !$0 { model.bookToRemove = nil } }),
                                titleVisibility: .visible, presenting: model.bookToRemove) { book in
                Button("移到回收站", role: .destructive) { Task { await model.moveToTrash(book.id) } }
                    .accessibilityIdentifier("library.confirm-remove")
                Button("取消", role: .cancel) { model.bookToRemove = nil }
            } message: { book in
                Text("“\(book.title)”将移到回收站，原书、阅读位置和书签会保留，可随时恢复。")
            }
            .fullScreenCover(item: $selectedBook, onDismiss: { Task { await model.refresh() } }) { book in
                ReaderView(book: book, services: services, factory: ReadiumEngineFactory(storageRoot: services.files.root))
            }
            .task { await model.refresh() }
        }
    }

    private var shelfContent: some View {
        Group {
            if model.books.isEmpty {
                ScrollView { emptyShelf }.transition(.opacity)
            } else if model.layout == .list, !model.visibleBooks.isEmpty {
                listShelf.transition(.opacity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        shelfHeader
                        if model.visibleBooks.isEmpty { noResults }
                        else {
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                                ForEach(model.visibleBooks) { summary in
                                    bookButton(summary, compact: false)
                                        .transition(reduceMotion ? .identity : .scale(scale: 0.94).combined(with: .opacity))
                                }
                            }.accessibilityIdentifier("library.grid")
                        }
                    }.padding(20)
                }.transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.88), value: model.visibleBooks.map(\.id))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: model.layout)
        .transaction { if reduceMotion { $0.animation = nil; $0.disablesAnimations = true } }
    }

    private var listShelf: some View {
        List {
            shelfHeader
                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 12, trailing: 20))
                .listRowSeparator(.hidden).listRowBackground(Color.clear)
            ForEach(model.visibleBooks) { summary in
                bookButton(summary, compact: true)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden).listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // Keep the row until confirmation AND the database commit.
                        // A short, muted action fits the shelf; full meaning stays in confirmation/accessibility.
                        Button { model.requestRemoval(summary.book) } label: { Label("移出", systemImage: "trash") }
                            .tint(Color(red: 0.31, green: 0.39, blue: 0.36))
                            .accessibilityLabel("移到回收站")
                            .disabled(model.isImporting || model.isRenaming || model.isManaging)
                            .accessibilityIdentifier("library.swipe-remove")
                    }
            }
        }.listStyle(.plain).scrollContentBackground(.hidden)
            .accessibilityIdentifier("library.list")
    }

    private var shelfHeader: some View {
        HStack {
            Text(model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                 ? "\(model.books.count) 本藏书" : "\(model.visibleBooks.count) 本匹配").font(.subheadline)
                .accessibilityIdentifier("library.count")
            Spacer()
            Text(model.sortOrder.title).font(.caption).foregroundStyle(.secondary)
        }
    }

    private var noResults: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass").font(.largeTitle).foregroundStyle(.secondary)
            Text("没有找到这本书").font(.headline)
            Text("试试其他书名或作者。").foregroundStyle(.secondary)
            Button("清除筛选") { model.query = "" }
        }.frame(maxWidth: .infinity).padding(.vertical, 60)
            .accessibilityIdentifier("library.no-results")
    }

    private var emptyShelf: some View {
        VStack(spacing: 18) {
            Image(systemName: "books.vertical").font(.system(size: 52)).foregroundStyle(.secondary)
            Text("把你的江湖，放进书架").font(.title2)
            Text("从“文件”导入 EPUB 或 TXT，在这里继续阅读。")
                .foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("导入书籍") { model.presentedSheet = .importFiles }.buttonStyle(.borderedProminent)
                .disabled(model.isImporting || model.isManaging || model.isRenaming)
            Button("导入内置样书") { model.startSamplesImport() }
                .disabled(model.isImporting || model.isManaging || model.isRenaming)
            Button("导入 TXT 样书") { model.startTXTSamplesImport() }.disabled(model.isImporting || model.isManaging || model.isRenaming)
            Button("打开回收站（\(model.removedBooks.count)）") { model.showTrash() }.accessibilityIdentifier("library.empty.open-trash")
            Text("支持 EPUB 与 TXT。\n若 iCloud 文件无法打开，请先下载到“我的 iPhone”再导入。")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.padding(.horizontal, 32).padding(.top, 100)
    }

    private func bookButton(_ summary: BookSummary, compact: Bool) -> some View {
        Button { selectedBook = summary.book } label: {
            Group {
                if compact {
                    HStack(spacing: 16) {
                        BookCoverView(book: summary.book, files: services.files, compact: true).frame(width: 56, height: 84)
                        details(summary)
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary).accessibilityHidden(true)
                    }.padding(14).background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        BookCoverView(book: summary.book, files: services.files)
                        details(summary)
                    }
                }
            }.contentShape(Rectangle())
        }.buttonStyle(.plain).disabled(model.isManaging).accessibilityIdentifier("library.book.\(summary.id.uuidString)")
            .accessibilityLabel("\(summary.book.title)，\(summary.book.author.isEmpty ? "作者未注明" : summary.book.author)，\(LibraryPresentation.readingLabel(summary))")
            .contextMenu {
                Button { model.beginRename(summary.book) } label: { Label("修改书名", systemImage: "pencil") }
                    .disabled(model.isImporting || model.isRenaming || model.isManaging)
                Button(role: .destructive) { model.requestRemoval(summary.book) } label: { Label("移出书架", systemImage: "trash") }
                    .disabled(model.isImporting || model.isRenaming || model.isManaging)
            }
    }

    private func details(_ summary: BookSummary) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(summary.book.title).font(.headline).lineLimit(2).foregroundStyle(.primary)
            Text(summary.book.author.isEmpty ? "作者未注明" : summary.book.author)
                .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            if let progress = LibraryPresentation.progress(summary) { ProgressView(value: progress).tint(.accentColor) }
            HStack(spacing: 8) {
                Text(LibraryPresentation.readingLabel(summary))
                Text(summary.book.format.rawValue.uppercased()).font(.caption2)
            }.font(.caption).foregroundStyle(.secondary)
            if let date = summary.lastReadAt { Text(date, style: .relative).font(.caption2).foregroundStyle(.secondary) }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
