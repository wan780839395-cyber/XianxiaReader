import SwiftUI

/// The shared File Provider presentation used by both EPUB and TXT imports.
@MainActor struct DocumentImportSheet: ViewModifier {
    @ObservedObject var model: LibraryViewModel

    func body(content: Content) -> some View {
        content.sheet(item: $model.presentedSheet) { sheet in
            switch sheet {
            case .importFiles:
                EPUBDocumentPicker(
                    onCompletion: { [weak model] result in model?.receivePickedDocuments(result) },
                    onCoordinatorCreated: { [weak model] coordinator in model?.retainPickerCoordinator(coordinator) }
                )
            case .txtEncoding:
                TXTEncodingSheet(model: model)
            case .renameBook:
                if let book = model.bookToRename { BookRenameSheet(book: book, model: model).id(book.id) }
            case .trash:
                LibraryTrashSheet(model: model)
            }
        }
    }
}
