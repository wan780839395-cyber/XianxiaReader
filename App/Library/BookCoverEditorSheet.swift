import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import XianxiaCore

@MainActor struct BookCoverEditorSheet: View {
    @ObservedObject var model: BookCoverEditorModel
    @State private var photo: PhotosPickerItem?
    private var previewBook: Book {
        var book = model.book
        if model.usesDefault { book.coverOverride = nil }
        return book
    }
    private var coverKind: String {
        if model.prepared != nil { return "待保存" }
        return model.usesDefault || model.book.coverOverride == nil ? "默认封面" : "自选封面"
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 14) {
                        Group {
                            if let prepared = model.prepared { BookCoverArtwork(title: model.book.title, image: prepared.preview, cropped: true) }
                            else { BookCoverView(book: previewBook, files: model.files) }
                        }.frame(width: 144, height: 216)
                            .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 6)
                            .accessibilityIdentifier("library.cover.preview")
                        Text(model.book.title).font(.headline).multilineTextAlignment(.center).lineLimit(2)
                        Text(coverKind).font(.caption).foregroundStyle(.secondary).accessibilityIdentifier("library.cover.kind")
                    }.padding(.top, 26)
                    VStack(spacing: 0) {
                        PhotosPicker(selection: $photo, matching: .images, preferredItemEncoding: .current) {
                            CoverSourceRow("从相册选择", symbol: "photo.on.rectangle")
                        }.accessibilityIdentifier("library.cover.photos")
                        Divider().padding(.leading, 48)
                        Button { model.choosingFile = true } label: { CoverSourceRow("从文件选择", symbol: "folder") }
                            .accessibilityIdentifier("library.cover.files")
                    }.buttonStyle(.plain).disabled(model.isLoading || model.isSaving)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    Button { model.restoreDefault() } label: { Label("恢复默认封面", systemImage: "arrow.counterclockwise") }
                        .disabled(model.isLoading || model.isSaving || (model.book.coverOverride == nil && model.prepared == nil))
                        .accessibilityIdentifier("library.cover.default")
                    if model.isLoading { ProgressView("正在准备封面…").font(.subheadline) }
                    if let error = model.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle").font(.footnote).foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading).accessibilityIdentifier("library.cover.error")
                    }
                    Text("只更换书架封面，原书、阅读位置和书签会保留。")
                        .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.padding(.horizontal, 24).padding(.bottom, 28)
            }.background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("更换封面").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { model.cancel() }.disabled(model.isSaving).accessibilityIdentifier("library.cover.cancel")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(model.isSaving ? "保存中…" : "保存") { Task { await model.save() } }
                            .disabled(model.isLoading || model.isSaving || !model.hasChanges).accessibilityIdentifier("library.cover.save")
                    }
                }.interactiveDismissDisabled(model.isSaving)
                .onChange(of: photo) { value in if let value { model.selectPhoto(value); photo = nil } }
                .sheet(isPresented: $model.choosingFile) {
                    EPUBDocumentPicker(onCompletion: { [weak model] result in model?.receiveFiles(result) },
                                       onCoordinatorCreated: { [weak model] coordinator in model?.retainCoordinator(coordinator) },
                                       contentTypes: [.image], allowsMultipleSelection: false)
                }
        }
    }
}

/// The picker can construct its label outside the UI executor. Store only values
/// there; SwiftUI renders this view's body (including Spacer) on the main actor.
@MainActor private struct CoverSourceRow: View {
    let title: String
    let symbol: String
    nonisolated init(_ title: String, symbol: String) { self.title = title; self.symbol = symbol }
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).foregroundStyle(.tint).frame(width: 22)
            Text(title).foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }.padding(16).contentShape(Rectangle())
    }
}
