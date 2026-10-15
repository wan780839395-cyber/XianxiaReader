import Foundation
import ReadiumAdapter
import XianxiaCore

struct AppServices: Sendable {
    let repository: SQLiteBookRepository
    let files: BookFileStore

    static func create(storageRoot: URL? = nil) async throws -> AppServices {
        try await Task.detached(priority: .userInitiated) {
            let support = try FileManager.default.url(for: .applicationSupportDirectory,
                                                     in: .userDomainMask, appropriateFor: nil, create: true)
            let root = storageRoot ?? support.appendingPathComponent("XianxiaReader", isDirectory: true)
            let repository = try SQLiteBookRepository(url: root.appendingPathComponent("library.sqlite"))
            let files = try BookFileStore(root: root)
            let knownIDs = try await repository.allBookIDs()
            // Runs once before the UI can start another import. Never clean while an import is active.
            try await files.recoverImports(knownBookIDs: knownIDs)
            return AppServices(repository: repository, files: files)
        }.value
    }
}
