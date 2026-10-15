import SwiftUI

@MainActor struct LibraryTrashSheet: View {
    @ObservedObject var model: LibraryViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("移出的书籍会保留在这里，不会自动清空。恢复后可继续原来的阅读位置和书签。")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text("原书文件仍保留，不会释放存储空间。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if let error = model.managementError {
                    Section { Text(error).foregroundStyle(.red).accessibilityIdentifier("library.trash.error") }
                }
                if model.removedBooks.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "trash").font(.largeTitle).foregroundStyle(.secondary)
                            Text("回收站是空的").font(.headline)
                            Text("从书架移出的书籍会出现在这里。")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity).padding(.vertical, 32)
                            .accessibilityIdentifier("library.trash.empty")
                    }
                } else {
                    Section("\(model.removedBooks.count) 本可恢复") {
                        ForEach(model.removedBooks) { summary in
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(summary.book.title).font(.headline)
                                    Text(summary.book.author.isEmpty ? "作者未注明" : summary.book.author)
                                        .font(.caption).foregroundStyle(.secondary)
                                    Text("\(LibraryPresentation.readingLabel(summary)) · \(summary.book.format.rawValue.uppercased())")
                                        .font(.caption).foregroundStyle(.secondary)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                Button("恢复") { Task { await model.restoreBook(summary.id) } }
                                    .buttonStyle(.bordered).disabled(model.isManaging)
                                    .accessibilityLabel("恢复\(summary.book.title)")
                                    .accessibilityIdentifier("library.restore.\(summary.id.uuidString)")
                            }.padding(.vertical, 6)
                        }
                    }
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: model.removedBooks.map(\.id))
            .transaction { if reduceMotion { $0.animation = nil; $0.disablesAnimations = true } }
            .navigationTitle("回收站").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { model.presentedSheet = nil }.disabled(model.isManaging).accessibilityIdentifier("library.trash.done")
                }
            }
            .overlay { if model.isManaging { ProgressView("正在保存…").padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12)) } }
            .interactiveDismissDisabled(model.isManaging)
        }
    }
}
