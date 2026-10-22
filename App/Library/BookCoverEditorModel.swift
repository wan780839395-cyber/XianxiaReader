import CoreGraphics
import Foundation
import LibraryShelf
import PhotosUI
import SwiftUI
import XianxiaCore

@MainActor final class BookCoverEditorModel: ObservableObject {
    let book: Book
    let files: BookFileStore
    @Published private(set) var prepared: PreparedCover?
    @Published private(set) var usesDefault = false
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?
    @Published var choosingFile = false
    var hasChanges: Bool { prepared != nil || (usesDefault && book.coverOverride != nil) }
    private let service: CoverImportService
    private weak var library: LibraryViewModel?
    private var requestID: UUID?
    private var loadTask: Task<Void, Never>?
    private var coordinator: EPUBDocumentPicker.Coordinator?
    private var closed = false

    init(book: Book, files: BookFileStore, repository: any LibraryRepository, library: LibraryViewModel) {
        self.book = book; self.files = files; self.library = library
        service = CoverImportService(files: files, repository: repository)
    }
    func retainCoordinator(_ value: EPUBDocumentPicker.Coordinator) { coordinator?.invalidate(); coordinator = value }
    func receiveFiles(_ result: Result<[URL], Error>?) {
        guard !closed else { return }
        coordinator = nil; choosingFile = false
        switch result {
        case .success(let urls):
            guard let url = urls.first else { errorMessage = BookCoverError.invalidImage.localizedDescription; return }
            selectFile(url)
        case .failure(let error): errorMessage = error.localizedDescription
        case nil: break
        }
    }
    func selectFile(_ url: URL) {
        startLoad { [service, book] in try await service.prepare(from: url, bookID: book.id) }
    }
    func selectPhoto(_ item: PhotosPickerItem) {
        startLoad { [service, book] in
            guard let photo = try await item.loadTransferable(type: CoverPhotoFile.self) else { throw BookCoverError.invalidImage }
            do {
                let prepared = try await service.prepare(from: photo.staged.originalURL, bookID: book.id)
                do { try await CoverPhotoTransferStore.shared.discard(photo) }
                catch {
                    let original = error
                    do { try await service.discard(prepared) }
                    catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
                    throw original
                }
                return prepared
            } catch {
                let original = error
                do { try await CoverPhotoTransferStore.shared.discard(photo) }
                catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
                throw original
            }
        }
    }
    @discardableResult func startLoad(_ operation: @escaping @MainActor () async throws -> PreparedCover) -> Task<Void, Never>? {
        guard !isSaving, !closed else { return nil }
        loadTask?.cancel()
        let id = UUID(); requestID = id; isLoading = true; errorMessage = nil
        let task = Task { [weak self] in
            guard let self else { return }
            defer { if self.requestID == id { self.isLoading = false; self.loadTask = nil } }
            do {
                let next = try await operation()
                guard self.requestID == id, !self.closed, !Task.isCancelled else {
                    do { try await self.service.discard(next) }
                    catch { self.library?.reportCoverError("旧封面草稿清理失败：\(error.localizedDescription)") }
                    return
                }
                let previous = self.prepared
                self.prepared = next; self.usesDefault = false
                if let previous { try await self.service.discard(previous) }
            } catch is CancellationError { return }
            catch {
                if self.requestID == id, !self.closed, !Task.isCancelled { self.errorMessage = error.localizedDescription }
                else if case StorageError.cleanupFailed = error { self.library?.reportCoverError(error.localizedDescription) }
            }
        }
        loadTask = task
        return task
    }
    func waitForLoad() async { await loadTask?.value }
    func cancel() { if !isSaving { library?.dismissCoverEditor(editor: self) } }
    func restoreDefault() {
        guard !isSaving, !isLoading, !closed else { return }
        let previous = prepared; prepared = nil; usesDefault = true; errorMessage = nil
        if let previous { discardLater(previous) }
    }
    func save() async -> Bool {
        guard !isLoading, !isSaving, !closed, hasChanges else { return false }
        isSaving = true; errorMessage = nil
        defer { isSaving = false }
        do {
            let updated: Book
            if usesDefault { updated = try await service.useDefault(bookID: book.id) }
            else if let prepared { updated = try await service.save(prepared) }
            else { return false }
            prepared = nil
            await library?.didSaveCover(updated, editor: self)
            isSaving = false
            library?.dismissCoverEditor(editor: self)
            return true
        } catch { errorMessage = error.localizedDescription; return false }
    }
    func close() {
        guard !closed, !isSaving else { return }
        closed = true; requestID = nil; loadTask?.cancel(); coordinator?.invalidate(); coordinator = nil
        if let prepared { self.prepared = nil; discardLater(prepared) }
    }
    private func discardLater(_ prepared: PreparedCover) {
        let service = service, library = library
        Task {
            do { try await service.discard(prepared) }
            catch { library?.reportCoverError("封面临时文件清理失败：\(error.localizedDescription)") }
        }
    }
}
