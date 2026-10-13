import Foundation

/// Platform boundary for File Provider materialization versus ordinary local files.
public protocol SourceFileCopying: Sendable {
    func copy(from source: URL, to destination: URL) throws
}

public struct PlatformSourceFileCopier: SourceFileCopying {
    public init() {}

    public func copy(from source: URL, to destination: URL) throws {
        #if canImport(Darwin)
        // Apple platforms must coordinate iCloud/File Provider reads. Do not use the Linux
        // local-file path to bypass this behavior on iOS or macOS.
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var copyError: Error?
        coordinator.coordinate(readingItemAt: source, options: [], error: &coordinationError) { coordinated in
            do { try FileManager.default.copyItem(at: coordinated, to: destination) }
            catch { copyError = error }
        }
        if let coordinationError { throw coordinationError }
        if let copyError { throw copyError }
        #else
        // Non-Apple validation supports ordinary files only, not iCloud providers.
        try FileManager.default.copyItem(at: source, to: destination)
        #endif
    }
}
