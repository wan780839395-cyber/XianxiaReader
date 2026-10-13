import ReadiumAdapter
import SwiftUI
import UniformTypeIdentifiers
import XianxiaCore

@MainActor struct LibraryView: View {
    let services: AppServices
    @StateObject private var model: LibraryViewModel
    @State private var showImporter = false
    @State private var selectedBook: Book?
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 190), spacing: 20)]

    init(services: AppServices) {
        self.services = services
        _model = StateObject(wrappedValue: LibraryViewModel(services: services))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if model.books.isEmpty {
                    VStack(spacing: 18) {
                        Image(systemName: "books.vertical").font(.system(size: 52)).foregroundStyle(.secondary)
                        Text("把你的江湖，放进书架").font(.title2)
                        Text("从“文件”导入 EPUB，在这里继续阅读。")
                            .foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Button("导入 EPUB") { showImporter = true }.buttonStyle(.borderedProminent)
                            .disabled(model.isImporting)
                    }.padding(.horizontal, 32).padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 28) {
                        ForEach(model.books) { summary in
                            Button { selectedBook = summary.book } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    BookCoverView(book: summary.book, files: services.files)
                                    Text(summary.book.title).font(.headline).lineLimit(2).foregroundStyle(.primary)
                                    Text(summary.book.author.isEmpty ? "作者未注明" : summary.book.author)
                                        .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                    if let progress = summary.progression {
                                        ProgressView(value: progress)
                                        Text("已读 \(Int(progress * 100))%").font(.caption).foregroundStyle(.secondary)
                                    } else {
                                        Text(summary.lastReadAt == nil ? "尚未阅读" : "已开始阅读")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    if let date = summary.lastReadAt {
                                        Text(date, style: .relative).font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                            }.buttonStyle(.plain)
                        }
                    }.padding(20)
                }
            }
            .navigationTitle("藏书阁")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showImporter = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("导入 EPUB").disabled(model.isImporting)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if model.isImporting {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("正在导入 \(model.importingName)").font(.footnote).lineLimit(1)
                    }.padding().frame(maxWidth: .infinity).background(.regularMaterial)
                }
            }
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [UTType(filenameExtension: "epub") ?? .data],
                          allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls): Task { await model.importBooks(urls) }
                case .failure(let error): model.errorMessage = error.localizedDescription
                }
            }
            .fullScreenCover(item: $selectedBook, onDismiss: { Task { await model.refresh() } }) { book in
                ReaderView(book: book, services: services, factory: ReadiumEngineFactory())
            }
            .alert("书库提示", isPresented: Binding(get: { model.errorMessage != nil },
                                                  set: { if !$0 { model.errorMessage = nil } })) {
                Button("知道了") { model.errorMessage = nil }
            } message: { Text(model.errorMessage ?? "") }
            .task { await model.refresh() }
        }
    }
}
