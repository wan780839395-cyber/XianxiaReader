import ReadiumAdapter
import SwiftUI
import XianxiaCore

@MainActor struct LibraryView: View {
    let services: AppServices
    @StateObject private var model: LibraryViewModel
    @State private var showImporter = false
    @State private var pendingImport: Result<[URL], Error>?
    @State private var selectedBook: Book?
    @State private var showTXTEncoding = false
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
                        Text("从“文件”导入 EPUB 或 TXT，在这里继续阅读。")
                            .foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Button("导入书籍") { showImporter = true }.buttonStyle(.borderedProminent)
                            .disabled(model.isImporting)
                        Button("导入内置样书") { model.startSamplesImport() }
                            .disabled(model.isImporting)
                        Button("导入 TXT 样书") { model.startTXTSamplesImport() }.disabled(model.isImporting)
                        Text("支持 EPUB 与 TXT。\n若 iCloud 文件无法打开，请先下载到“我的 iPhone”再导入。")
                            .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
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
                    Menu {
                        Button("从文件导入 EPUB / TXT") { showImporter = true }
                        Button("导入内置样书") { model.startSamplesImport() }
                        Button("导入 TXT 样书") { model.startTXTSamplesImport() }
                        Button("TXT 编码") { showTXTEncoding = true }
                    } label: { Image(systemName: "plus") }
                        .accessibilityLabel("导入书籍").disabled(model.isImporting)
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
                if !model.retryTXTFiles.isEmpty, !model.isImporting {
                    Button("选择 TXT 编码并重试") { showTXTEncoding = true }.padding(.bottom, 8)
                }
            }
            .sheet(isPresented: $showImporter, onDismiss: finishPicking) {
                EPUBDocumentPicker { result in
                    pendingImport = result
                    showImporter = false
                }
            }
            .fullScreenCover(item: $selectedBook, onDismiss: { Task { await model.refresh() } }) { book in
                ReaderView(book: book, services: services, factory: ReadiumEngineFactory(storageRoot: services.files.root))
            }
            .sheet(isPresented: $showTXTEncoding) {
                NavigationStack {
                    Form {
                        Picker("TXT 编码", selection: $model.txtEncoding) {
                            Text("自动识别").tag(TXTEncoding.automatic)
                            Text("UTF-8").tag(TXTEncoding.utf8)
                            Text("UTF-16 小端").tag(TXTEncoding.utf16LittleEndian)
                            Text("UTF-16 大端").tag(TXTEncoding.utf16BigEndian)
                            Text("GB18030 / GBK").tag(TXTEncoding.gb18030)
                        }.pickerStyle(.inline)
                        Text("有编码标记的 TXT 可自动识别。不确定时请按文件实际编码选择；原文件会保留。")
                            .font(.footnote).foregroundStyle(.secondary)
                        if !model.retryTXTFiles.isEmpty {
                            Button("按所选编码重试") { showTXTEncoding = false; model.retryTXTImport() }
                        }
                    }.navigationTitle("TXT 编码")
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { showTXTEncoding = false } } }
                }
            }
            .alert("书库提示", isPresented: Binding(get: { model.errorMessage != nil },
                                                  set: { if !$0 { model.errorMessage = nil } })) {
                Button("知道了") { model.errorMessage = nil }
            } message: { Text(model.errorMessage ?? "") }
            .task { await model.refresh() }
        }
    }

    private func finishPicking() {
        // Wait for the picker sheet to dismiss before showing an error or starting
        // the app's import. A local import-mode copy remains valid after dismissal.
        let result = pendingImport
        pendingImport = nil
        switch result {
        case .success(let urls): model.startImport(urls)
        case .failure(let error): model.errorMessage = error.localizedDescription
        case nil: break
        }
    }
}
