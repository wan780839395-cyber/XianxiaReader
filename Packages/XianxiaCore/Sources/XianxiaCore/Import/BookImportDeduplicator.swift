import Foundation

extension BookFileStore {
    public func importIdentity(relativePath: String, format: BookFormat, normalizedSHA256: String? = nil) throws -> BookImportIdentity {
        let url = try resolve(relativePath)
        guard try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else { throw StorageError.missingSource }
        let digest = try TXTContentDigest.file(url)
        return BookImportIdentity(format: format, sha256: digest.sha256, byteCount: digest.bytes, normalizedSHA256: normalizedSHA256)
    }

    public func importIdentity(staged: StagedBook, normalizedSHA256: String? = nil) throws -> BookImportIdentity {
        try importIdentity(relativePath: "Staging/\(staged.id.uuidString)/book.\(staged.format.rawValue)",
                           format: staged.format, normalizedSHA256: normalizedSHA256)
    }
}

public struct BookDuplicateCheck: Sendable {
    public let duplicate: DuplicateBook?
    public let warnings: [String]
}

/// Legacy originals are streamed once, on demand, off the main executor.
/// Their TXT cache is consulted only when the incoming original actually matches.
public actor BookImportDeduplicator {
    private let files: BookFileStore
    private let repository: any BookRepository
    public init(files: BookFileStore, repository: any BookRepository) { self.files = files; self.repository = repository }

    public func check(_ incoming: BookImportIdentity) async throws -> BookDuplicateCheck {
        var warnings: [String] = []
        for record in try await repository.importRecords() where record.book.format == incoming.format {
            try Task.checkCancellation()
            var value: BookImportIdentity
            if let known = record.identity { value = known }
            else {
                do { value = try await files.importIdentity(relativePath: record.book.filePath, format: record.book.format) }
                catch is CancellationError { throw CancellationError() }
                catch { warnings.append("“\(record.book.title)”的旧原件无法核对，未参与去重：\(error.localizedDescription)"); continue }
                try await repository.recordImportIdentity(value, for: record.book.id)
            }
            if value.format == .txt, value.normalizedSHA256 == nil,
               value.sha256 == incoming.sha256, value.byteCount == incoming.byteCount {
                do {
                    let cache = try TXTIndexCache(storageRoot: files.root)
                    let index = try await cache.prepare(source: files.resolve(record.book.filePath), bookID: record.book.id,
                                                        encoding: record.book.txtEncoding ?? .automatic)
                    guard index.sourceSHA256 == value.sha256 else { throw TXTNormalizationError.sourceChanged }
                    value = BookImportIdentity(format: .txt, sha256: value.sha256, byteCount: value.byteCount, normalizedSHA256: index.normalizedSHA256)
                } catch is CancellationError { throw CancellationError() }
                catch { warnings.append("“\(record.book.title)”的旧 TXT 编码无法核对，未参与去重：\(error.localizedDescription)"); continue }
                try await repository.recordImportIdentity(value, for: record.book.id)
            }
        }
        let duplicate = try await repository.duplicate(for: incoming)
        if let duplicate { try await verify(duplicate, identity: incoming) }
        return BookDuplicateCheck(duplicate: duplicate, warnings: warnings)
    }

    public func verify(_ duplicate: DuplicateBook, identity: BookImportIdentity) async throws {
        do {
            let actual = try await files.importIdentity(relativePath: duplicate.book.filePath, format: duplicate.book.format)
            guard actual.sha256 == identity.sha256, actual.byteCount == identity.byteCount else { throw TXTNormalizationError.sourceChanged }
        } catch is CancellationError { throw CancellationError() }
        catch { throw BookDuplicateError.originalUnavailable(error.localizedDescription) }
    }
}
