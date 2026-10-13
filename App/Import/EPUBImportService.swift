import Foundation
import ReadingInterfaces
import XianxiaCore

struct ImportOutcome {
    let book: Book
    let warnings: [String]
}

enum ImportError: LocalizedError {
    case noFilesSelected
    case unsupportedFile
    case missingSample
    case cleanupFailed(original: String, cleanup: String)
    var errorDescription: String? {
        switch self {
        case .noFilesSelected:
            return "文件选择器没有返回文件。请在“文件”中下载 EPUB，再从“我的 iPhone”重新导入。"
        case .unsupportedFile:
            return "请选择 .epub 文件。当前版本尚未支持 TXT 阅读。"
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

    init(repository: any BookRepository, files: BookFileStore, metadata: any EPUBMetadataReading) {
        self.repository = repository
        self.files = files
        self.metadata = metadata
    }

    func importBook(from source: URL) async throws -> ImportOutcome {
        guard source.isFileURL, source.pathExtension.lowercased() == "epub" else {
            throw ImportError.unsupportedFile
        }
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        let id = UUID()
        do {
            let staged = try await files.stageEPUB(from: source, id: id)
            let parsed = try await metadata.readMetadata(at: staged.fileURL, bookID: id)
            try Task.checkCancellation()
            let paths = try await files.finalize(staged, coverData: parsed.coverData)
            let fallback = source.deletingPathExtension().lastPathComponent
            let book = Book(id: id, title: parsed.title.isEmpty ? fallback : parsed.title, author: parsed.author,
                            format: .epub, filePath: paths.filePath, coverPath: paths.coverPath)
            try await repository.insert(book, chapters: parsed.chapters)
            return ImportOutcome(book: book, warnings: parsed.warnings)
        } catch {
            do { try await files.discardImport(id: id) }
            catch let cleanup {
                throw ImportError.cleanupFailed(original: error.localizedDescription, cleanup: cleanup.localizedDescription)
            }
            throw error
        }
    }
}
