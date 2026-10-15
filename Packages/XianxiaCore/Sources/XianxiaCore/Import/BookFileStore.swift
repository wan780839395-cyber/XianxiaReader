import Foundation

public enum StorageError: LocalizedError, Equatable {
    case unsafePath, unsupportedFormat, missingSource
    case cleanupFailed(original: String, cleanup: String)
    public var errorDescription: String? {
        switch self {
        case .unsafePath: return "书籍路径无效。"
        case .unsupportedFormat: return "请选择 EPUB 或 TXT 文件。"
        case .missingSource: return "选中的文件不存在或不是普通文件。"
        case .cleanupFailed(let original, let cleanup): return "导入失败：\(original)。临时文件清理失败：\(cleanup)。"
        }
    }
}

public struct StagedBook: Sendable {
    public let id: UUID
    public let fileURL: URL
    public let format: BookFormat
}

/// Blocking file work stays on this actor, never on the UI executor.
public actor BookFileStore {
    public nonisolated let root: URL
    private let manager = FileManager.default
    private let sourceCopier: any SourceFileCopying

    public init(root: URL, sourceCopier: any SourceFileCopying = PlatformSourceFileCopier()) throws {
        // Resolve the root only after it exists. Some Foundation implementations
        // leave symlinked parents unresolved when the final component is missing.
        let normalizedRoot = root.standardizedFileURL
        try FileManager.default.createDirectory(at: normalizedRoot, withIntermediateDirectories: true)
        self.root = normalizedRoot.resolvingSymlinksInPath()
        self.sourceCopier = sourceCopier
    }

    public nonisolated func resolve(_ relativePath: String) throws -> URL {
        guard !relativePath.isEmpty, !relativePath.hasPrefix("/"), !relativePath.contains("\\"),
              !relativePath.split(separator: "/").contains("..") else { throw StorageError.unsafePath }
        let target = root.appendingPathComponent(relativePath).standardizedFileURL
        guard target.path.hasPrefix(root.path + "/") else { throw StorageError.unsafePath }
        // Managed book storage never creates symlinks. Inspect each existing
        // component without following links, including dangling links, before
        // accepting a path whose leaf or intermediate directories do not exist.
        var prefix = root
        for component in relativePath.split(separator: "/") {
            prefix.appendPathComponent(String(component))
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: prefix.path)
                if attributes[.type] as? FileAttributeType == .typeSymbolicLink {
                    throw StorageError.unsafePath
                }
            } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
                break // No deeper component can exist until this directory is created.
            }
        }
        return target
    }

    public func stageEPUB(from source: URL, id: UUID = UUID()) throws -> StagedBook {
        try stage(from: source, id: id, format: .epub)
    }

    public func stageTXT(from source: URL, id: UUID = UUID()) throws -> StagedBook {
        try stage(from: source, id: id, format: .txt)
    }

    private func stage(from source: URL, id: UUID, format: BookFormat) throws -> StagedBook {
        try Task.checkCancellation()
        guard source.pathExtension.lowercased() == format.rawValue else { throw StorageError.unsupportedFormat }
        guard try source.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else { throw StorageError.missingSource }
        let directory = try resolve("Staging/\(id.uuidString)")
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        do {
            let target = try resolve("Staging/\(id.uuidString)/book.\(format.rawValue)")
            // No whole-file Data buffer; Apple builds coordinate File Provider materialization.
            try sourceCopier.copy(from: source, to: target)
            return StagedBook(id: id, fileURL: target, format: format)
        } catch {
            let original = error
            do { try manager.removeItem(at: directory) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }

    public func finalize(_ staged: StagedBook, coverData: Data?) throws -> (filePath: String, coverPath: String?) {
        let directory = try resolve("Staging/\(staged.id.uuidString)")
        var coverPath: String?
        if let coverData {
            try coverData.write(to: directory.appendingPathComponent("cover.jpg"), options: .atomic)
            coverPath = "Books/\(staged.id.uuidString)/cover.jpg"
        }
        let books = try resolve("Books")
        try manager.createDirectory(at: books, withIntermediateDirectories: true)
        try manager.moveItem(at: directory, to: books.appendingPathComponent(staged.id.uuidString))
        return ("Books/\(staged.id.uuidString)/book.\(staged.format.rawValue)", coverPath)
    }

    /// Used only to roll back an import whose database transaction never committed.
    public func discardImport(id: UUID) throws {
        for prefix in ["Staging", "Books", "Cache/TXT"] {
            let key = prefix == "Cache/TXT" ? id.uuidString.lowercased() : id.uuidString
            let path = try resolve("\(prefix)/\(key)")
            if manager.fileExists(atPath: path.path) { try manager.removeItem(at: path) }
        }
    }

    /// On restart, remove interrupted staging and finalized imports absent from the DB.
    /// knownBookIDs must include recoverably removed books, not just the visible shelf.
    public func recoverImports(knownBookIDs: Set<UUID>) throws {
        for prefix in ["Staging", "Books", "Cache/TXT"] {
            let directory = try resolve(prefix)
            guard manager.fileExists(atPath: directory.path) else { continue }
            for child in try manager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
                guard let id = UUID(uuidString: child.lastPathComponent) else { continue }
                if prefix == "Staging" || !knownBookIDs.contains(id) {
                    try manager.removeItem(at: resolve("\(prefix)/\(child.lastPathComponent)"))
                }
            }
        }
    }
}
