import Foundation

public struct TXTBookImportResult: Sendable {
    public let book: Book
    public let detectedEncoding: TXTEncoding
}

/// Coordinates a managed original, rebuildable index cache, then one Book+Chapter DB transaction.
public actor TXTBookImportService {
    private let files: BookFileStore
    private let repository: any BookRepository
    public init(files: BookFileStore, repository: any BookRepository) {
        self.files = files
        self.repository = repository
    }

    public func importBook(from source: URL, encoding: TXTEncoding = .automatic) async throws -> Book {
        try await importBookWithEncoding(from:source,encoding:encoding).book
    }
    public func importBookWithEncoding(from source: URL, encoding: TXTEncoding = .automatic) async throws -> TXTBookImportResult {
        let id = UUID()
        do {
            let staged = try await files.stageTXT(from: source, id: id)
            try Task.checkCancellation()
            let cache = try TXTIndexCache(storageRoot: files.root)
            let index = try await cache.prepare(source: staged.fileURL, bookID: id, encoding: encoding)
            try Task.checkCancellation()
            let paths = try await files.finalize(staged, coverData: nil)
            let book = Book(id: id, title: source.deletingPathExtension().lastPathComponent,
                            format: .txt, filePath: paths.filePath, txtEncoding: encoding)
            try Task.checkCancellation()
            try await repository.insert(book, chapters: index.chapters)
            // Cancellation after the DB transaction must never roll back a committed book.
            return TXTBookImportResult(book:book,detectedEncoding:index.encoding)
        } catch {
            let original = error
            do { try await files.discardImport(id: id) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }
}

extension TXTNormalizationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .encodingChoiceRequired: return "TXT 编码无法自动确定，请选择实际编码（ANSI / GBK、Big5、Windows-1252 或 UTF-16）后重试。"
        case .unsupportedBOM: return "暂不支持这个 TXT 的编码标记，请转换为 UTF-8 或 UTF-16 后导入。"
        case .conflictingBOM: return "所选编码与 TXT 编码标记不同，请改用自动识别或正确编码。"
        case .invalidEncoding(_, let offset): return "TXT 编码不正确或文件已损坏（字节 \(offset)），请核对编码后重试。"
        case .nonTextByte(let offset): return "文件含有非文本字节（\(offset)），请核对 TXT 编码。"
        case .codecUnavailable: return "系统无法转换这个 TXT 编码。"
        case .destinationExists: return "正文缓存目标已存在。"
        case .sourceChanged: return "书籍文件在处理期间改变，请重试。"
        case .cleanupFailed(let original, let cleanup): return "处理失败：\(original)。临时缓存清理失败：\(cleanup)。"
        }
    }
}
