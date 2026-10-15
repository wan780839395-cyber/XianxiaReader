import Foundation
import XianxiaCore

enum LibraryLayout: String, CaseIterable, Identifiable {
    case grid, list
    var id: String { rawValue }
    var title: String { self == .grid ? "网格" : "列表" }
    var symbol: String { self == .grid ? "square.grid.2x2" : "list.bullet" }
}

enum LibrarySortOrder: String, CaseIterable, Identifiable {
    case recent, imported, title
    var id: String { rawValue }
    var title: String {
        switch self { case .recent: return "最近阅读"; case .imported: return "最近导入"; case .title: return "书名" }
    }
}

enum LibraryPresentation {
    static func books(_ books: [BookSummary], query: String, order: LibrarySortOrder) -> [BookSummary] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]
        let locale = Locale(identifier: "zh_Hans_CN")
        return books.filter {
            query.isEmpty || $0.book.title.range(of: query, options: options, locale: locale) != nil
                || $0.book.author.range(of: query, options: options, locale: locale) != nil
        }.sorted { first, second in
            switch order {
            case .recent:
                let a = first.lastReadAt ?? first.book.importedAt, b = second.lastReadAt ?? second.book.importedAt
                if a != b { return a > b }
            case .imported:
                if first.book.importedAt != second.book.importedAt { return first.book.importedAt > second.book.importedAt }
            case .title:
                let comparison = first.book.title.compare(second.book.title, options: [.caseInsensitive, .numeric], locale: locale)
                if comparison != .orderedSame { return comparison == .orderedAscending }
            }
            return first.id.uuidString < second.id.uuidString
        }
    }
    static func progress(_ summary: BookSummary) -> Double? {
        summary.progression.flatMap { $0.isFinite ? min(max($0, 0), 1) : nil }
    }
    static func readingLabel(_ summary: BookSummary) -> String {
        if let progress = progress(summary) { return "已读 \(Int(progress * 100))%" }
        return summary.lastReadAt == nil ? "尚未阅读" : "已开始阅读"
    }
}
