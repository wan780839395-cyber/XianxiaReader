import Combine
import Foundation
import ReadingInterfaces
import XianxiaCore

public protocol ReaderFontCatalogStorage: Sendable {
    func readingFonts() async throws -> [ReadingFontAsset]
    func readingFontURL(_ font: ReadingFontAsset) async throws -> URL
}

extension BookFileStore: ReaderFontCatalogStorage {}

/// Owns font catalogue state, not the reader, locator, file importer or preview renderer.
@MainActor public final class ReaderFontCoordinator: ObservableObject {
    public struct Snapshot {
        public let fonts: [ReadingFontAsset]
        public let resources: [ReaderFontResource]
        public let warning: String?
        public init(fonts: [ReadingFontAsset], resources: [ReaderFontResource], warning: String?) {
            self.fonts = fonts; self.resources = resources; self.warning = warning
        }
    }
    public struct ImportRequest {
        public let id: UUID
        fileprivate let session: UUID
    }
    public enum Selection {
        case appearance(ReadingAppearance)
        case install(ReaderFontResource)
    }

    @Published public private(set) var importedFonts: [ReadingFontAsset] = []
    @Published public private(set) var busy = false
    @Published public var message: String?
    public private(set) var resources: [ReaderFontResource] = []
    private var installedIDs: Set<UUID> = []
    private var session: UUID?
    private var catalogRequestID: UUID?
    private var importRequestID: UUID?
    private let storage: any ReaderFontCatalogStorage
    private let bundledResources: @MainActor () -> Snapshot

    public init(storage: any ReaderFontCatalogStorage, bundledResources: @escaping @MainActor () -> Snapshot) {
        self.storage = storage; self.bundledResources = bundledResources
    }

    public func beginSession(_ id: UUID) { session = id }

    public func close() {
        session = nil; catalogRequestID = nil; importRequestID = nil
        installedIDs = []; busy = false
    }

    public func resourceForPreview(_ id: UUID?) -> ReaderFontResource? {
        guard let id else { return nil }
        return resources.first { $0.asset.id == id }
    }

    public func isAvailable(_ id: UUID) -> Bool { resourceForPreview(id) != nil }

    public func markResourcesInstalled() { installedIDs = Set(resources.map { $0.asset.id }) }

    public func prepareForOpen() async throws {
        guard let owner = session else { throw CancellationError() }
        do {
            let loaded = try await loadResources()
            try Task.checkCancellation()
            guard session == owner else { throw CancellationError() }
            importedFonts = loaded.fonts; resources = loaded.resources; message = loaded.warning
        } catch is CancellationError { throw CancellationError() }
        catch {
            guard session == owner else { throw CancellationError() }
            resources = []; message = error.localizedDescription
        }
    }

    /// Loading is separate from publication: an import commits only after the reader rebuild succeeds.
    public func loadResources() async throws -> Snapshot {
        let bundled = bundledResources()
        var resources = bundled.resources, warning = bundled.warning
        let fonts: [ReadingFontAsset]
        do { fonts = try await storage.readingFonts() }
        catch is CancellationError { throw CancellationError() }
        catch { return Snapshot(fonts: [], resources: resources, warning: error.localizedDescription) }
        for font in fonts {
            try Task.checkCancellation()
            do { resources.append(ReaderFontResource(asset: font, fileURL: try await storage.readingFontURL(font))) }
            catch { warning = "\(font.displayName)：\(error.localizedDescription)" }
        }
        return Snapshot(fonts: fonts, resources: resources, warning: warning)
    }

    public func refreshForBrowsing(force: Bool = false) async {
        guard let owner = session, !busy else { return }
        let request = UUID(); catalogRequestID = request
        defer { if catalogRequestID == request { catalogRequestID = nil } }
        func current() -> Bool {
            session == owner && catalogRequestID == request && !busy && !Task.isCancelled
        }
        do {
            // Preserve the bounded catalogue fast path; do not rehash unchanged font files.
            let catalogue = try await storage.readingFonts()
            guard current(), force || catalogue != importedFonts else { return }
            let loaded = try await loadResources()
            guard current() else { return }
            importedFonts = loaded.fonts; resources = loaded.resources
            if let warning = loaded.warning { message = warning }
        } catch is CancellationError { return }
        catch {
            guard session == owner, catalogRequestID == request else { return }
            message = "字体列表暂时无法更新：\(error.localizedDescription)"
        }
    }

    public func builtInSelection(_ font: ReadingFont, appearance: ReadingAppearance) -> ReadingAppearance {
        message = nil
        var updated = appearance; updated.font = font; updated.importedFontID = nil
        return updated
    }

    public func importedSelection(_ id: UUID, appearance: ReadingAppearance, isReady: Bool) -> Selection? {
        guard let resource = resourceForPreview(id) else {
            message = ReadingFontError.missingFont.localizedDescription; return nil
        }
        guard isReady, !busy else { return nil }
        if !installedIDs.contains(id) { return .install(resource) }
        message = nil
        var updated = appearance; updated.importedFontID = id
        return .appearance(updated)
    }

    public func effectiveAppearance(_ value: ReadingAppearance) -> ReadingAppearance {
        var effective = value
        if let id = value.importedFontID, !isAvailable(id) {
            effective.importedFontID = nil; effective.font = .original
            message = ReadingFontError.missingFont.localizedDescription
        }
        return effective
    }

    public func beginImport() -> ImportRequest? {
        guard let session, !busy else { return nil }
        catalogRequestID = nil
        let request = ImportRequest(id: UUID(), session: session)
        importRequestID = request.id; busy = true; message = nil
        return request
    }

    public func isCurrent(_ request: ImportRequest) -> Bool {
        session == request.session && importRequestID == request.id
    }

    public func checkCurrent(_ request: ImportRequest) throws {
        try Task.checkCancellation()
        guard isCurrent(request) else { throw CancellationError() }
    }

    public func finishImport(_ request: ImportRequest) {
        if isCurrent(request) { importRequestID = nil; busy = false }
    }

    public func commitImport(_ loaded: Snapshot, font: ReadingFontAsset, request: ImportRequest) throws {
        try checkCurrent(request)
        resources = loaded.resources; importedFonts = loaded.fonts
        markResourcesInstalled()
        message = "已导入并启用 \(font.displayName)"
    }

    public func reloadImportedFonts(for request: ImportRequest) async throws {
        let fonts = try await storage.readingFonts()
        try checkCurrent(request); importedFonts = fonts
    }
}
