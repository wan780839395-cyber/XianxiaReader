import CoreTransferable
import Foundation
import UniformTypeIdentifiers
import XianxiaCore

/// FileRepresentation avoids loading an unbounded photo into a main-actor Data buffer.
struct CoverPhotoFile: Transferable, Sendable {
    let staged: StagedCover
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            try await CoverPhotoTransferStore.shared.copy(received.file)
        }
    }
}

actor CoverPhotoTransferStore {
    static let shared = CoverPhotoTransferStore()
    private var files: BookFileStore?
    private func store() throws -> BookFileStore {
        if let files { return files }
        let created = try BookFileStore(root: FileManager.default.temporaryDirectory.appendingPathComponent("XianxiaPhotoCoverTransfers"))
        files = created; return created
    }
    func copy(_ url: URL) async throws -> CoverPhotoFile {
        let files = try store()
        let staged = try await files.stageCover(from: url, bookID: UUID())
        return CoverPhotoFile(staged: staged)
    }
    func discard(_ value: CoverPhotoFile) async throws { try await store().discardCover(value.staged) }
}
