import Foundation

/// Normalization+index contract implemented by StreamingTXTIndexer.
/// Managed version-cache and product import/reading are separate layers.
public protocol TXTIndexing: Sendable {
    func buildIndex(source: URL, normalizedUTF8: URL, bookID: UUID) async throws -> [Chapter]
}
