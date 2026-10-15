import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Import a local copy instead of asking File Provider to open the original in place.
/// Providers sometimes label EPUBs as ZIP/data, so validate the extension and actual
/// publication after selection, rather than excluding them with a narrow UTI filter.
@MainActor struct EPUBDocumentPicker: UIViewControllerRepresentable {
    let onCompletion: (Result<[URL], Error>?) -> Void
    var onCoordinatorCreated: ((Coordinator) -> Void)? = nil
    var contentTypes: [UTType] = [.data]
    var allowsMultipleSelection = true

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(onCompletion: onCompletion)
        onCoordinatorCreated?(coordinator)
        return coordinator
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = Self.makePicker(contentTypes: contentTypes, allowsMultipleSelection: allowsMultipleSelection)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    static func makePicker(contentTypes: [UTType] = [.data], allowsMultipleSelection: Bool = true) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.shouldShowFileExtensions = true
        return picker
    }

    @MainActor final class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let onCompletion: (Result<[URL], Error>?) -> Void
        private var completed = false

        init(onCompletion: @escaping (Result<[URL], Error>?) -> Void) {
            self.onCompletion = onCompletion
        }

        func invalidate() { completed = true }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            deliver(urls)
        }

        // Readium 3.11's TestApp also implements the older single-URL delegate.
        // Both entry points share the same one-shot terminal state.
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            deliver([url])
        }

        private func deliver(_ urls: [URL]) {
            guard !completed else { return }
            completed = true
            if urls.isEmpty { onCompletion(.failure(ImportError.noFilesSelected)) }
            else { onCompletion(.success(urls)) }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            guard !completed else { return }
            completed = true
            onCompletion(nil)
        }
    }
}
