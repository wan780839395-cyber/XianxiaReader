import Foundation
import ReadiumAdapter
import SwiftUI
import XianxiaCore

@MainActor final class LibraryViewModel: ObservableObject {
    @Published private(set) var books: [BookSummary] = []
    @Published private(set) var isImporting = false
    @Published private(set) var importingName = ""
    @Published private(set) var importStatus: String?
    @Published var errorMessage: String?
    private let services: AppServices
    private let importer: EPUBImportService

    init(services: AppServices) {
        self.services = services
        importer = EPUBImportService(repository: services.repository, files: services.files,
                                     metadata: ReadiumPublicationLoader())
    }

    func refresh() async {
        do { books = try await services.repository.books() }
        catch { errorMessage = error.localizedDescription }
    }

    func importBooks(_ urls: [URL]) async {
        guard !isImporting else { return }
        guard !urls.isEmpty else { errorMessage = ImportError.noFilesSelected.localizedDescription; return }
        errorMessage = nil
        importStatus = nil
        isImporting = true
        defer { isImporting = false; importingName = "" }
        var messages: [String] = []
        var importedCount = 0
        // Sequential imports bound memory and preserve the security-scoped URL for the full copy.
        for url in urls {
            if Task.isCancelled { break }
            importingName = url.lastPathComponent
            do {
                let outcome = try await importer.importBook(from: url)
                importedCount += 1
                messages.append(contentsOf: outcome.warnings.map { "\(url.lastPathComponent)：\($0)" })
            } catch is CancellationError { break }
            catch { messages.append("\(url.lastPathComponent)：\(error.localizedDescription)") }
        }
        await refresh()
        if importedCount > 0 { importStatus = "已导入 \(importedCount) 本书" }
        if !messages.isEmpty { errorMessage = messages.joined(separator: "\n") }
    }

    func importSamples(bundle: Bundle = .main) async {
        let urls = ["chinese-epub2", "chinese-epub3"].compactMap {
            bundle.url(forResource: $0, withExtension: "epub", subdirectory: "Fixtures")
        }
        guard urls.count == 2 else { errorMessage = ImportError.missingSample.localizedDescription; return }
        await importBooks(urls)
    }
}
