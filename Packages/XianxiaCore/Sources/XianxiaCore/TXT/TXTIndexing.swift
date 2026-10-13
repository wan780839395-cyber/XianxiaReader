import Foundation

/// M2 contract only: no dummy parser and no claim of TXT support in M0.
public protocol TXTIndexing: Sendable {
    func buildIndex(source: URL, normalizedUTF8: URL, bookID: UUID) async throws -> [Chapter]
}
