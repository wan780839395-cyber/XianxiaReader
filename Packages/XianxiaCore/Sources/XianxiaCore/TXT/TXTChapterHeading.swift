import Foundation

public struct TXTChapterHeading: Equatable, Sendable {
    public enum Kind: String, Codable, Sendable { case chapter, volume, prologue }
    public let title: String
    public let kind: Kind
}

/// Conservative whole-line recognition; it never searches inside a body paragraph.
public struct TXTChapterHeadingRecognizer: Sendable {
    public static let parserVersion = 1
    public static let maximumTitleCharacters = 80
    private static let numbers = Set<Character>("0123456789０１２３４５６７８９零〇一二三四五六七八九十百千万亿两兩壹贰貳叁參肆伍陆陸柒捌玖拾佰仟萬億")
    private static let titleSeparators = Set<Character>(" ：:、.．-—（(")

    public init() {}

    public func recognize(_ rawLine: String) -> TXTChapterHeading? {
        let title = rawLine.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty, title.count <= Self.maximumTitleCharacters,
              !title.contains(where: { $0.isNewline || "。；;".contains($0) }) else { return nil }
        var remainder = title[...]
        if remainder.hasPrefix("正文") {
            remainder = remainder.dropFirst(2)
            trimLeadingSpace(&remainder)
        }
        if remainder.first == "第" {
            remainder = remainder.dropFirst()
            trimLeadingSpace(&remainder)
            guard consumeNumber(&remainder) else { return nil }
            trimLeadingSpace(&remainder)
            guard let unit = remainder.first else { return nil }
            remainder = remainder.dropFirst()
            if "章回节".contains(unit) { return TXTChapterHeading(title: title, kind: .chapter) }
            // Volume-like measure words can occur in prose. Require a separator or EOL.
            if "卷册部".contains(unit), separatedTitle(remainder) {
                return TXTChapterHeading(title: title, kind: .volume)
            }
            return nil
        }
        if remainder.first == "卷" {
            remainder = remainder.dropFirst()
            trimLeadingSpace(&remainder)
            if consumeNumber(&remainder), separatedTitle(remainder) {
                return TXTChapterHeading(title: title, kind: .volume)
            }
            return nil
        }
        if remainder.prefix(7).lowercased() == "chapter" {
            remainder = remainder.dropFirst(7)
            guard let first = remainder.first, first.isWhitespace || first == "." else { return nil }
            while let first = remainder.first, first.isWhitespace || first == "." { remainder = remainder.dropFirst() }
            let digits = remainder.prefix { "0123456789".contains($0) }
            guard !digits.isEmpty, digits.count <= 20 else { return nil }
            remainder = remainder.dropFirst(digits.count)
            if separatedTitle(remainder) { return TXTChapterHeading(title: title, kind: .chapter) }
            return nil
        }
        for name in ["序章", "楔子", "前言", "序言", "引子", "尾声", "终章", "后记", "番外"] {
            if remainder.hasPrefix(name), separatedTitle(remainder.dropFirst(name.count)) {
                return TXTChapterHeading(title: title, kind: .prologue)
            }
        }
        return nil
    }

    private func consumeNumber(_ remainder: inout Substring) -> Bool {
        let number = remainder.prefix { Self.numbers.contains($0) }
        guard !number.isEmpty, number.count <= 20 else { return false }
        remainder = remainder.dropFirst(number.count)
        return true
    }
    private func trimLeadingSpace(_ remainder: inout Substring) {
        while remainder.first?.isWhitespace == true { remainder = remainder.dropFirst() }
    }
    private func separatedTitle(_ remainder: Substring) -> Bool {
        guard let first = remainder.first else { return true }
        return first.isWhitespace || Self.titleSeparators.contains(first)
    }
}
