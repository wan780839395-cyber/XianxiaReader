import SwiftUI

/// The shared File Provider presentation used by both EPUB and TXT imports.
@MainActor struct DocumentImportSheet: ViewModifier {
    @Binding var isPresented: Bool
    @ObservedObject var model: LibraryViewModel

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: model.finishPicking) {
            EPUBDocumentPicker { result in
                model.receivePickedDocuments(result)
                isPresented = false
            }
        }
    }
}
