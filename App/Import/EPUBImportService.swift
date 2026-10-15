import Foundation
import ReadingInterfaces
import XianxiaCore

struct ImportOutcome {
    let book: Book
    let warnings: [String]
    let detectedTXTEncoding: TXTEncoding?
    let duplicate: DuplicateBook?
    init(book:Book,warnings:[String],detectedTXTEncoding:TXTEncoding?=nil,duplicate:DuplicateBook?=nil) {
        self.book=book; self.warnings=warnings; self.detectedTXTEncoding=detectedTXTEncoding
        self.duplicate=duplicate
    }
}

enum ImportError: LocalizedError {
    case noFilesSelected
    case unsupportedFile
    case missingSample
    case cleanupFailed(original: String, cleanup: String)
    var errorDescription: String? {
        switch self {
        case .noFilesSelected:
            return "文件选择器没有返回文件。请在“文件”中下载书籍，再从“我的 iPhone”重新导入。"
        case .unsupportedFile:
            return "请选择 .epub 或 .txt 文件。"
        case .missingSample:
            return "安装包中的测试样书缺失，请更新应用后重试。"
        case .cleanupFailed(let original, let cleanup):
            return "导入失败：\(original)。临时文件清理也失败：\(cleanup)，下次启动将重试恢复。"
        }
    }
}

@MainActor final class EPUBImportService {
    private let repository: any BookRepository
    private let files: BookFileStore
    private let metadata: any EPUBMetadataReading
    private let txtImporter: TXTBookImportService

    init(repository: any BookRepository, files: BookFileStore, metadata: any EPUBMetadataReading) {
        self.repository = repository
        self.files = files
        self.metadata = metadata
        txtImporter = TXTBookImportService(files: files, repository: repository)
    }

    func importBook(from source: URL, txtEncoding: TXTEncoding = .automatic) async throws -> ImportOutcome {
        guard source.isFileURL, ["epub","txt"].contains(source.pathExtension.lowercased()) else {
            throw ImportError.unsupportedFile
        }
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        if source.pathExtension.lowercased() == "txt" {
            let result=try await txtImporter.importBookWithEncoding(from:source,encoding:txtEncoding)
            return ImportOutcome(book:result.book,warnings:result.warnings,detectedTXTEncoding:result.detectedEncoding,duplicate:result.duplicate)
        }
        let id = UUID()
        do {
            let staged = try await files.stageEPUB(from: source, id: id)
            let identity = try await files.importIdentity(staged: staged)
            let deduplicator = BookImportDeduplicator(files: files, repository: repository)
            let check = try await deduplicator.check(identity)
            if let duplicate = check.duplicate {
                try await files.discardImport(id: id)
                return ImportOutcome(book: duplicate.book, warnings: check.warnings, duplicate: duplicate)
            }
            let parsed = try await metadata.readMetadata(at: staged.fileURL, bookID: id)
            try Task.checkCancellation()
            let paths = try await files.finalize(staged, coverData: parsed.coverData)
            let fallback = source.deletingPathExtension().lastPathComponent
            let book = Book(id: id, title: parsed.title.isEmpty ? fallback : parsed.title, author: parsed.author,
                            format: .epub, filePath: paths.filePath, coverPath: paths.coverPath)
            let commit = try await repository.commitImport(book, chapters: parsed.chapters, identity: identity)
            if case .duplicate(let duplicate) = commit {
                try await deduplicator.verify(duplicate, identity: identity)
                try await files.discardImport(id: id)
                return ImportOutcome(book: duplicate.book, warnings: check.warnings, duplicate: duplicate)
            }
            return ImportOutcome(book: book, warnings: check.warnings + parsed.warnings)
        } catch {
            do { try await files.discardImport(id: id) }
            catch let cleanup {
                throw ImportError.cleanupFailed(original: error.localizedDescription, cleanup: cleanup.localizedDescription)
            }
            throw error
        }
    }
}
