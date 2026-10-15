import Foundation
import ReadiumAdapter
import SwiftUI
import XianxiaCore

enum LibrarySheet: String, Identifiable {
    case importFiles, txtEncoding, renameBook, trash, cover
    var id: String { rawValue }
}

@MainActor final class LibraryViewModel: ObservableObject {
    @Published private(set) var books: [BookSummary] = []
    @Published private(set) var removedBooks: [BookSummary] = []
    @Published var bookToRemove: Book?
    @Published private(set) var isManaging = false
    @Published private(set) var managementError: String?
    @Published private(set) var isImporting = false
    @Published private(set) var importingName = ""
    @Published private(set) var importStatus: String?
    @Published var errorMessage: String?
    @Published var txtEncoding: TXTEncoding = .automatic
    @Published var presentedSheet: LibrarySheet?
    @Published private(set) var retryTXTFiles: [URL] = []
    @Published var query = ""
    @Published var layout: LibraryLayout { didSet { defaults.set(layout.rawValue, forKey: "library.layout.v1") } }
    @Published var sortOrder: LibrarySortOrder { didSet { defaults.set(sortOrder.rawValue, forKey: "library.sort.v1") } }
    @Published private(set) var bookToRename: Book?
    @Published private(set) var isRenaming = false
    @Published private(set) var renameError: String?
    @Published private(set) var coverEditor: BookCoverEditorModel?
    var isEditingCover: Bool { coverEditor != nil }
    var visibleBooks: [BookSummary] { LibraryPresentation.books(books, query: query, order: sortOrder) }
    private let defaults: UserDefaults
    private var refreshRequestID: UUID?
    private var importTask: Task<Void,Never>?
    private var pickerCoordinator: EPUBDocumentPicker.Coordinator?
    private let services: AppServices
    private let importer: EPUBImportService

    init(services: AppServices, defaults: UserDefaults = .standard) {
        self.services = services
        self.defaults = defaults
        layout = defaults.string(forKey: "library.layout.v1").flatMap(LibraryLayout.init(rawValue:)) ?? .grid
        sortOrder = defaults.string(forKey: "library.sort.v1").flatMap(LibrarySortOrder.init(rawValue:)) ?? .recent
        importer = EPUBImportService(repository: services.repository, files: services.files,
                                     metadata: ReadiumPublicationLoader())
    }

    func refresh() async {
        let requestID = UUID(); refreshRequestID = requestID
        do {
            let result = try await services.repository.librarySnapshot()
            guard refreshRequestID == requestID else { return }
            books = result.books
            removedBooks = result.removedBooks
        } catch {
            guard refreshRequestID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }

    func beginCoverEditing(_ book: Book) {
        guard !isImporting, !isRenaming, !isManaging, !isEditingCover, presentedSheet == nil else { return }
        coverEditor = BookCoverEditorModel(book: book, services: services, library: self)
        presentedSheet = .cover
    }

    func dismissCoverEditor(editor: BookCoverEditorModel) {
        guard coverEditor === editor, !editor.isSaving else { return }
        finishCoverEditing(); presentedSheet = nil
    }

    func finishCoverEditing() {
        guard coverEditor?.isSaving != true else { return }
        coverEditor?.close(); coverEditor = nil
    }

    func reportCoverError(_ message: String) { errorMessage = message }

    func didSaveCover(_ book: Book, editor: BookCoverEditorModel) async {
        refreshRequestID = nil
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            let previous = books[index]
            books[index] = BookSummary(book: book, progression: previous.progression, lastReadAt: previous.lastReadAt)
        }
        importStatus = "封面已更新"
        await refresh()
    }

    func beginRename(_ book: Book) {
        guard !isImporting, !isRenaming, !isManaging, !isEditingCover, presentedSheet == nil else { return }
        bookToRename = book; renameError = nil; presentedSheet = .renameBook
    }

    func renameBook(_ id: UUID, title: String) async -> Bool {
        guard !isRenaming, !isImporting, !isManaging, !isEditingCover else { return false }
        isRenaming = true; renameError = nil
        defer { isRenaming = false }
        do {
            let updated = try await services.repository.renameBook(id, title: title)
            // A refresh started before this commit must not publish an old title.
            refreshRequestID = nil
            if let index = books.firstIndex(where: { $0.id == id }) {
                let previous = books[index]
                books[index] = BookSummary(book: updated, progression: previous.progression, lastReadAt: previous.lastReadAt)
            }
            await refresh()
            return true
        } catch {
            renameError = error.localizedDescription
            return false
        }
    }

    func requestRemoval(_ book: Book) {
        guard !isImporting, !isRenaming, !isManaging, !isEditingCover, presentedSheet == nil else { return }
        bookToRemove = book
    }

    func showTrash() {
        guard !isImporting, !isRenaming, !isManaging, !isEditingCover, presentedSheet == nil else { return }
        managementError = nil; presentedSheet = .trash
    }

    @discardableResult func moveToTrash(_ id: UUID) async -> Bool {
        await changeRemoval(id, restoring: false)
    }

    @discardableResult func restoreBook(_ id: UUID) async -> Bool {
        await changeRemoval(id, restoring: true)
    }

    private func changeRemoval(_ id: UUID, restoring: Bool) async -> Bool {
        guard !isManaging, !isImporting, !isRenaming, !isEditingCover else { return false }
        isManaging = true; managementError = nil; errorMessage = nil
        defer { isManaging = false }
        do {
            if restoring { try await services.repository.restoreBook(id) }
            else { try await services.repository.moveToTrash(id) }
            refreshRequestID = nil
            if restoring, let summary = removedBooks.first(where: { $0.id == id }) {
                removedBooks.removeAll { $0.id == id }; books.removeAll { $0.id == id }; books.append(summary)
            } else if !restoring, let summary = books.first(where: { $0.id == id }) {
                books.removeAll { $0.id == id }; removedBooks.removeAll { $0.id == id }; removedBooks.insert(summary, at: 0)
            }
            bookToRemove = nil
            importStatus = restoring ? "已恢复到书架，阅读位置和书签已保留" : "已移到回收站，可随时恢复"
            await refresh()
            return true
        } catch {
            managementError = error.localizedDescription
            errorMessage = error.localizedDescription
            return false
        }
    }

    func receivePickedDocuments(_ result: Result<[URL], Error>?) {
        // UIKit has already delivered the import-mode local copy. Start from
        // that event, as Readium's TestApp does, even if SwiftUI omits onDismiss.
        // Feedback stays in the shelf instead of racing another presentation.
        pickerCoordinator = nil
        presentedSheet = nil
        switch result {
        case .success(let urls): startImport(urls)
        case .failure(let error): errorMessage = error.localizedDescription
        case nil: break
        }
    }

    func retainPickerCoordinator(_ coordinator: EPUBDocumentPicker.Coordinator) {
        // UIDocumentPicker.delegate is weak. Its terminal callback can arrive
        // after SwiftUI dismantles the sheet, so the shelf owns the delegate
        // until completion. The completion captures this model weakly.
        pickerCoordinator?.invalidate()
        pickerCoordinator = coordinator
    }

    func startImport(_ urls: [URL]) {
        guard importTask == nil, !isImporting, !isRenaming, !isManaging, !isEditingCover else { return }
        importTask = Task { [weak self] in
            guard let self else { return }
            await self.importBooks(urls)
            self.importTask = nil
        }
    }
    func startSamplesImport() {
        guard importTask == nil, !isImporting, !isRenaming, !isManaging, !isEditingCover else { return }
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
        guard !isImporting, !isRenaming, !isManaging, !isEditingCover else { return }
        guard !urls.isEmpty else { errorMessage = ImportError.noFilesSelected.localizedDescription; return }
        errorMessage = nil
        importStatus = nil
        retryTXTFiles = []
        let encoding = txtEncoding
        isImporting = true
        defer { isImporting = false; importingName = "" }
        var messages: [String] = []
        var importedCount = 0
        var detectedLegacy: Set<String> = []
        // Sequential imports bound memory and preserve the security-scoped URL for the full copy.
        for url in urls {
            if Task.isCancelled { break }
            importingName = url.lastPathComponent
            do {
                let outcome = try await importer.importBook(from: url, txtEncoding: encoding)
                importedCount += 1
                if encoding == .automatic {
                    if outcome.detectedTXTEncoding == .gbk { detectedLegacy.insert("ANSI / GBK") }
                    if outcome.detectedTXTEncoding == .gb18030 { detectedLegacy.insert("GB18030") }
                }
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
        if !detectedLegacy.isEmpty { importStatus = (importStatus ?? "")+"（自动识别：\(detectedLegacy.sorted().joined(separator:"、"))）" }
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
