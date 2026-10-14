import SwiftUI

/// The shared File Provider presentation used by both EPUB and TXT imports.
@MainActor struct DocumentImportSheet: ViewModifier {
    @Binding var isPresented: Bool
    @ObservedObject var model: LibraryViewModel
    @State private var pendingImport: Result<[URL], Error>?

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: finishPicking) {
            EPUBDocumentPicker { result in
                pendingImport = result
                isPresented = false
            }
        }
    }

    private func finishPicking() {
        let result = pendingImport
        pendingImport = nil
        switch result {
        case .success(let urls): model.startImport(urls)
        case .failure(let error): model.errorMessage = error.localizedDescription
        case nil: break
        }
    }
}
