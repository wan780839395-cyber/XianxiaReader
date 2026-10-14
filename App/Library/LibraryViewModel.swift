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
    @Published var txtEncoding: TXTEncoding = .automatic
    @Published private(set) var retryTXTFiles: [URL] = []
    private var importTask: Task<Void,Never>?
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

    func startImport(_ urls: [URL]) {
        guard importTask == nil, !isImporting else { return }
        importTask = Task { [weak self] in
            guard let self else { return }
            await self.importBooks(urls)
            self.importTask = nil
        }
    }
    func startSamplesImport() {
        guard importTask == nil, !isImporting else { return }
        importTask = Task { [weak self] in
            guard let self else { return }
            await self.importSamples()
            self.importTask = nil
        }
    }
    func cancelImport() { importTask?.cancel() }
    func retryTXTImport() { startImport(retryTXTFiles) }
    func startTXTSamplesImport(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "云海问道-UTF8",withExtension: "txt",subdirectory: "Fixtures") else {
            errorMessage = ImportError.missingSample.localizedDescription; return
        }
        startImport([url])
    }

    func importBooks(_ urls: [URL]) async {
        guard !isImporting else { return }
        guard !urls.isEmpty else { errorMessage = ImportError.noFilesSelected.localizedDescription; return }
        errorMessage = nil
        importStatus = nil
        retryTXTFiles = []
        let encoding = txtEncoding
        isImporting = true
        defer { isImporting = false; importingName = "" }
        var messages: [String] = []
        var importedCount = 0
        // Sequential imports bound memory and preserve the security-scoped URL for the full copy.
        for url in urls {
            if Task.isCancelled { break }
            importingName = url.lastPathComponent
            do {
                let outcome = try await importer.importBook(from: url, txtEncoding: encoding)
                importedCount += 1
                messages.append(contentsOf: outcome.warnings.map { "\(url.lastPathComponent)：\($0)" })
            } catch is CancellationError { break }
            catch {
                if let failure = error as? TXTNormalizationError {
                    switch failure {
                    case .encodingChoiceRequired, .conflictingBOM, .invalidEncoding, .nonTextByte:
                        retryTXTFiles.append(url)
                    default: break
                    }
                }
                messages.append("\(url.lastPathComponent)：\(error.localizedDescription)")
            }
        }
        await refresh()
        if importedCount > 0 { importStatus = "已导入 \(importedCount) 本书" }
        if Task.isCancelled { importStatus = "导入已取消，已完成的 \(importedCount) 本书已保留" }
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
