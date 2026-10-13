import Foundation
import ReadiumAdapter
import SwiftUI
import XianxiaCore

@MainActor final class LibraryViewModel: ObservableObject {
    @Published private(set) var books: [BookSummary] = []
    @Published private(set) var isImporting = false
    @Published private(set) var importingName = ""
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
        isImporting = true
        defer { isImporting = false; importingName = "" }
        var messages: [String] = []
        // Sequential imports bound memory and preserve the security-scoped URL for the full copy.
        for url in urls {
            if Task.isCancelled { break }
            importingName = url.lastPathComponent
            do {
                let outcome = try await importer.importBook(from: url)
                messages.append(contentsOf: outcome.warnings.map { "\(url.lastPathComponent)：\($0)" })
            } catch is CancellationError { break }
            catch { messages.append("\(url.lastPathComponent)：\(error.localizedDescription)") }
        }
        await refresh()
        if !messages.isEmpty { errorMessage = messages.joined(separator: "\n") }
    }
}
