import Foundation

private struct ReadingFontCatalog: Codable {
    let version: Int
    let fonts: [ReadingFontAsset]
}

extension BookFileStore {
    public static let maximumFontBytes: Int64 = 32 * 1_024 * 1_024

    public func readingFonts() throws -> [ReadingFontAsset] {
        let url = try resolve("Preferences/fonts-v1.json")
        let attributes: [FileAttributeKey: Any]
        do { attributes = try manager.attributesOfItem(atPath: url.path) }
        catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile { return [] }
        guard attributes[.type] as? FileAttributeType == .typeRegular,
              let size = (attributes[.size] as? NSNumber)?.int64Value, size <= 32_768 else { throw ReadingFontError.invalidCatalog }
        let catalog = try JSONDecoder().decode(ReadingFontCatalog.self, from: Data(contentsOf: url))
        guard catalog.version == 1, catalog.fonts.count <= 12,
              Set(catalog.fonts.map(\.id)).count == catalog.fonts.count,
              Set(catalog.fonts.map(\.sha256)).count == catalog.fonts.count else { throw ReadingFontError.invalidCatalog }
        return try catalog.fonts.map { try $0.validated() }
    }

    public func stageReadingFont(from source: URL) throws -> StagedReadingFont {
        try Task.checkCancellation()
        let ext = source.pathExtension.lowercased()
        guard source.isFileURL, ["ttf", "otf"].contains(ext) else { throw ReadingFontError.unsupportedFile }
        try requireReadingFontFile(source)
        let id = UUID(), prefix = "StagingFonts/\(id.uuidString.lowercased())"
        let directory = try resolve(prefix)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        do {
            let target = try resolve(prefix + "/font.\(ext)")
            try sourceCopier.copy(from: source, to: target)
            try Task.checkCancellation()
            try requireReadingFontFile(target)
            let digest = try TXTContentDigest.file(target)
            guard digest.bytes <= Self.maximumFontBytes else { throw ReadingFontError.fileTooLarge }
            return StagedReadingFont(id: id, fileURL: target, fileExtension: ext, sha256: digest.sha256, bytes: digest.bytes)
        } catch {
            let original = error
            do { try manager.removeItem(at: directory) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
    }

    public func commitReadingFont(_ staged: StagedReadingFont, displayName: String) throws -> ReadingFontAsset {
        try Task.checkCancellation()
        let pending = try resolve("StagingFonts/\(staged.id.uuidString.lowercased())")
        let source = try resolve("StagingFonts/\(staged.id.uuidString.lowercased())/font.\(staged.fileExtension)")
        guard source == staged.fileURL else { throw StorageError.unsafePath }
        try requireReadingFontFile(source)
        var fonts = try readingFonts()
        // Same bytes reimported retain the original identity, including a missing asset repair.
        let duplicate = fonts.first(where: { $0.sha256 == staged.sha256 })
        if duplicate == nil && fonts.count >= 12 { throw ReadingFontError.libraryFull }
        let asset = try duplicate ?? ReadingFontAsset(id: staged.id, displayName: displayName,
            fileExtension: staged.fileExtension, sha256: staged.sha256, bytes: staged.bytes)
        let destination = try resolve(asset.relativePath)
        if duplicate != nil && manager.fileExists(atPath: destination.path) {
            try requireReadingFontFile(destination)
            guard try TXTContentDigest.file(destination).sha256 == asset.sha256 else { throw ReadingFontError.invalidFont }
            try manager.removeItem(at: pending)
            return asset
        }
        let folder = destination.deletingLastPathComponent()
        try manager.createDirectory(at: folder, withIntermediateDirectories: true)
        try manager.moveItem(at: source, to: destination)
        do {
            if duplicate == nil { fonts.append(asset) }
            let directory = try resolve("Preferences")
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(ReadingFontCatalog(version: 1, fonts: fonts))
            try data.write(to: resolve("Preferences/fonts-v1.json"), options: .atomic)
        } catch {
            let original = error
            do { try manager.moveItem(at: destination, to: source) }
            catch { throw StorageError.cleanupFailed(original: original.localizedDescription, cleanup: error.localizedDescription) }
            throw original
        }
        // The committed font must remain even if removing its empty staging folder fails.
        do { try manager.removeItem(at: pending) }
        catch { throw StorageError.cleanupFailed(original: "字体已导入，请重新打开字体列表", cleanup: error.localizedDescription) }
        return asset
    }

    public func discardReadingFont(_ staged: StagedReadingFont) throws {
        let url = try resolve("StagingFonts/\(staged.id.uuidString.lowercased())")
        if manager.fileExists(atPath: url.path) { try manager.removeItem(at: url) }
    }

    public func readingFontURL(_ font: ReadingFontAsset) throws -> URL {
        _ = try font.validated()
        let url = try resolve(font.relativePath)
        try requireReadingFontFile(url)
        let digest = try TXTContentDigest.file(url)
        guard digest.sha256 == font.sha256, digest.bytes == font.bytes else { throw ReadingFontError.invalidFont }
        return url
    }

    private func requireReadingFontFile(_ url: URL) throws {
        let attributes = try manager.attributesOfItem(atPath: url.path)
        guard attributes[.type] as? FileAttributeType == .typeRegular,
              let size = (attributes[.size] as? NSNumber)?.int64Value, size > 0 else { throw ReadingFontError.invalidFont }
        guard size <= Self.maximumFontBytes else { throw ReadingFontError.fileTooLarge }
    }
}
