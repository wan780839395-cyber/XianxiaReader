import SwiftUI

/// The shared File Provider presentation used by both EPUB and TXT imports.
@MainActor struct DocumentImportSheet: ViewModifier {
    @ObservedObject var model: LibraryViewModel

    func body(content: Content) -> some View {
        content.sheet(item: $model.presentedSheet) { sheet in
            switch sheet {
            case .importFiles:
                EPUBDocumentPicker(onCompletion: model.receivePickedDocuments)
            case .txtEncoding:
                TXTEncodingSheet(model: model)
            }
        }
    }
}
