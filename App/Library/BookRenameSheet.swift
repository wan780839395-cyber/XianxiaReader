import SwiftUI
import XianxiaCore

@MainActor struct BookRenameSheet: View {
    let book: Book
    @ObservedObject var model: LibraryViewModel
    @State private var title: String

    init(book: Book, model: LibraryViewModel) {
        self.book = book; self.model = model
        _title = State(initialValue: book.title)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("书名") {
                    TextField("输入书名", text: $title).accessibilityIdentifier("library.rename.title")
                    Text("只修改书架显示的名称，阅读位置和书签会保留。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if let error = model.renameError {
                    Text(error).foregroundStyle(.red).accessibilityIdentifier("library.rename.error")
                }
            }
            .navigationTitle("修改书名").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { model.presentedSheet = nil }.disabled(model.isRenaming)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(model.isRenaming ? "保存中…" : "保存") {
                        Task {
                            if await model.renameBook(book.id, title: title) { model.presentedSheet = nil }
                        }
                    }.disabled(model.isRenaming).accessibilityIdentifier("library.rename.save")
                }
            }.interactiveDismissDisabled(model.isRenaming)
        }
    }
}
