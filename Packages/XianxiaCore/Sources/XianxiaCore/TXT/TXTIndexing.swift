import Foundation

/// Full normalization/import/cache facade, still to be integrated in M2.
/// TXTUTF8ChapterScanner is the independent streaming index component.
public protocol TXTIndexing: Sendable {
    func buildIndex(source: URL, normalizedUTF8: URL, bookID: UUID) async throws -> [Chapter]
}
