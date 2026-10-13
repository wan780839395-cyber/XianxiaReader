import Foundation
import ReadiumShared
import ReadingInterfaces

/// Readium 3.11 search extension avoiding sliding-window grapheme offsets (#876).
/// Readium remains responsible for EPUB parsing, DOM selectors and content iteration.
final class SafeTextSearchService: SearchService {
    let options = SearchOptions(caseSensitive: false, diacriticSensitive: true, exact: true,
                                regularExpression: false)
    private let publication: Weak<Publication>

    init(publication: Weak<Publication>) { self.publication = publication }

    static func makeFactory() -> SearchServiceFactory {
        { SafeTextSearchService(publication: $0.publication) }
    }

    func search(query: String, options: SearchOptions?) async -> SearchResult<any SearchIterator> {
        guard !query.isEmpty, query.count <= ReaderSearchLimits.queryCharacters,
              options?.regularExpression != true, options?.wholeWord != true else {
            return .failure(.badQuery(ReaderSearchError.invalidQuery))
        }
        guard let publication = publication(), let content = publication.content() else {
            return .failure(.publicationNotSearchable)
        }
        do {
            let links = try await publication.tableOfContents().get()
            var titles: [String: String] = [:]
            func collect(_ links: [Link]) {
                for link in links {
                    if let title = link.title {
                        let href = String(link.href.prefix(while: { $0 != "#" }))
                        if !href.isEmpty, titles[href] == nil { titles[href] = title }
                    }
                    collect(link.children)
                }
            }
            collect(links)
            return .success(SafeTextSearchIterator(content: content.iterator(), query: query,
                caseSensitive: options?.caseSensitive ?? false, titles: titles))
        } catch {
            return .failure(.reading(error))
        }
    }
}

/// Single-consumer cursor; ReadiumSearchSession enforces this across actor awaits.
final class SafeTextSearchIterator: SearchIterator {
    private let content: any ContentIterator
    private let query: String
    private let compareOptions: String.CompareOptions
    private let titles: [String: String]
    private var element: TextContentElement?
    private var text = ""
    private var offset: String.Index?
    private var finished = false
    private(set) var resultCount: Int? = 0

    init(content: any ContentIterator, query: String, caseSensitive: Bool = false,
         titles: [String: String] = [:]) {
        self.content = content
        self.query = query
        compareOptions = caseSensitive ? [.literal] : [.literal, .caseInsensitive]
        self.titles = titles
    }

    func next() async -> SearchResult<LocatorCollection?> {
        guard !finished else { return .success(nil) }
        var matches: [Locator] = []
        do {
            while matches.count < ReaderSearchLimits.pageSize {
                try Task.checkCancellation()
                if let element, let offset, offset < text.endIndex,
                   let range = text.range(of: query, options: compareOptions, range: offset..<text.endIndex),
                   !range.isEmpty {
                    // All indices refer to this one immutable joined String. Inline graphemes
                    // can merge without corrupting an integer offset into a trimmed window.
                    self.offset = text.index(after: range.lowerBound)
                    let before = String(text[..<range.lowerBound].suffix(ReaderSearchLimits.snippetCharacters))
                    let after = String(text[range.upperBound...].prefix(ReaderSearchLimits.snippetCharacters))
                    let href = element.locator.href.string
                    let locator = element.locator.copy(title: Optional(titles[href] ?? element.locator.title), text: {
                        $0 = Locator.Text(after: after.isEmpty ? nil : after,
                                          before: before.isEmpty ? nil : before,
                                          highlight: String(self.text[range]))
                    })
                    matches.append(locator)
                    continue
                }
                guard let next = try await content.next() else { finished = true; break }
                try Task.checkCancellation()
                guard let next = next as? TextContentElement, !next.segments.isEmpty else { continue }
                element = next
                text = next.segments.map(\.text).joined()
                offset = text.startIndex
                // A miss must not retain the previous element's text/cursor.
            }
            resultCount = (resultCount ?? 0) + matches.count
            if finished { element = nil; text = ""; offset = nil }
            return .success(matches.isEmpty ? nil : LocatorCollection(locators: matches))
        } catch {
            finished = true
            element = nil; text = ""; offset = nil
            return .failure(.reading(error as? ReadError ?? ReadError.wrap(error) ?? .decoding(error)))
        }
    }
}
