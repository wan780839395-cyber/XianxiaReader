import Foundation

extension BookFileStore {
    public static let maximumCoverBytes: Int64 = 20 * 1_024 * 1_024

    public func stageCover(from source: URL, bookID: UUID) throws -> StagedCover {
        try Task.checkCancellation()
        guard source.isFileURL else { throw BookCoverError.invalidImage }
        try requireCoverFile(source)
        let cover = BookCoverOverride(), prefix = "StagingCovers/\(cover.assetID.uuidString)"
        let directory = try resolve(prefix)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        do {
            let target = try resolve(prefix + "/original")
            try sourceCopier.copy(from: source, to: target)
            try Task.checkCancellation()
            // Inspect the actual copied node, including providers that return a symlink or a growing file.
            try requireCoverFile(target)
            return StagedCover(bookID: bookID, cover: cover, originalURL: target)
        } catch {
            let original = error
            do { try manager.removeItem(at: directory) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }

    /// Receives a bounded JPEG from the platform image processor; Core does not decode images.
    public func finalizeCover(_ staged: StagedCover, thumbnailJPEG: Data) throws -> BookCoverOverride {
        try Task.checkCancellation()
        guard !thumbnailJPEG.isEmpty, thumbnailJPEG.count <= 2 * 1_024 * 1_024 else { throw BookCoverError.invalidThumbnail }
        let prefix = "StagingCovers/\(staged.cover.assetID.uuidString)"
        let original = try resolve(prefix + "/original")
        guard original == staged.originalURL else { throw StorageError.unsafePath }
        try requireCoverFile(original)
        let bookDirectory = try resolve("Books/\(staged.bookID.uuidString)")
        guard manager.fileExists(atPath: bookDirectory.path),
              try manager.attributesOfItem(atPath: bookDirectory.path)[.type] as? FileAttributeType == .typeDirectory else {
            throw BookCoverError.missingBookFiles
        }
        try thumbnailJPEG.write(to: resolve(prefix + "/thumbnail.jpg"), options: .atomic)
        let artwork = try resolve("Books/\(staged.bookID.uuidString)/Artwork")
        try manager.createDirectory(at: artwork, withIntermediateDirectories: true)
        let destination = try resolve(staged.cover.directory(bookID: staged.bookID))
        try manager.moveItem(at: resolve(prefix), to: destination)
        return staged.cover
    }

    /// Roll back ONLY this fresh, uncommitted asset. Never call for a committed cover.
    public func discardCover(_ staged: StagedCover) throws {
        for path in ["StagingCovers/\(staged.cover.assetID.uuidString)", staged.cover.directory(bookID: staged.bookID)] {
            let url = try resolve(path)
            if manager.fileExists(atPath: url.path) { try manager.removeItem(at: url) }
        }
    }

    /// A failed DB transaction restores its immutable asset to the draft for a real retry.
    public func rollbackCoverFinalization(_ staged: StagedCover) throws {
        let pending = try resolve("StagingCovers/\(staged.cover.assetID.uuidString)")
        let finalized = try resolve(staged.cover.directory(bookID: staged.bookID))
        if manager.fileExists(atPath: finalized.path) {
            try manager.createDirectory(at: resolve("StagingCovers"), withIntermediateDirectories: true)
            try manager.moveItem(at: finalized, to: pending)
        }
    }

    private func requireCoverFile(_ url: URL) throws {
        let attributes = try manager.attributesOfItem(atPath: url.path)
        guard attributes[.type] as? FileAttributeType == .typeRegular,
              let size = (attributes[.size] as? NSNumber)?.int64Value, size > 0 else { throw BookCoverError.invalidImage }
        guard size <= Self.maximumCoverBytes else { throw BookCoverError.imageTooLarge }
    }
}
