import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Import a local copy instead of asking File Provider to open the original in place.
/// Providers sometimes label EPUBs as ZIP/data, so validate the extension and actual
/// publication after selection, rather than excluding them with a narrow UTI filter.
@MainActor struct EPUBDocumentPicker: UIViewControllerRepresentable {
    let onCompletion: (Result<[URL], Error>?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCompletion: onCompletion) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = Self.makePicker()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    static func makePicker() -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        picker.allowsMultipleSelection = true
        picker.shouldShowFileExtensions = true
        return picker
    }

    @MainActor final class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let onCompletion: (Result<[URL], Error>?) -> Void
        private var completed = false

        init(onCompletion: @escaping (Result<[URL], Error>?) -> Void) {
            self.onCompletion = onCompletion
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
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
