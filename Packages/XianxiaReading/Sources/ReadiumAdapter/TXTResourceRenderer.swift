import Foundation
import XianxiaCore

/// Presentation conversion stays outside Core and off MainActor. One input window <=64KiB.
actor TXTResourceRenderer {
    private let files: BookFileStore
    private let index: TXTPreparedIndex
    private let reader = TXTChapterWindowReader()
    init(files: BookFileStore, index: TXTPreparedIndex) { self.files = files; self.index = index }

    private func window(_ resource: TXTReadingResource) async throws -> TXTChapterWindow {
        guard let start = resource.chapter.startByte else { throw EPUBError.invalidPosition }
        let window = try await reader.read(file: files.resolve(index.normalizedRelativePath), chapter: resource.chapter,
            localByteOffset: resource.startByte-start, maximumBytes: max(4, Int(resource.endByte-resource.startByte)))
        guard window.startByte == resource.startByte, window.endByte == resource.endByte else { throw EPUBError.invalidPosition }
        return window
    }
    func render(_ resource: TXTReadingResource) async throws -> Data {
        let window = try await window(resource)
        let paragraphs = Self.paragraphs(window)
        let recognizer = TXTChapterHeadingRecognizer()
        var html = "<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"zh-Hans\"><head><meta charset=\"utf-8\"/><title>\(Self.escape(resource.chapter.title))</title><style>p{white-space:pre-wrap;text-indent:2em;margin:0 0 .8em;line-height:1.75}h2{white-space:pre-wrap;text-indent:0;margin:1.2em 0 .9em;font-size:1.3em;line-height:1.5}</style></head><body>"
        for (offset,text) in paragraphs {
            try Task.checkCancellation()
            let tag = recognizer.recognize(text) == nil ? "p" : "h2"
            html += "<\(tag) id=\"txt-b\(offset)\">\(text.isEmpty ? "<br/>" : Self.escape(text))</\(tag)>"
        }
        html += "</body></html>"
        try Task.checkCancellation()
        return Data(html.utf8)
    }
    func validate(_ anchor: TXTReadingAnchor, resource: TXTReadingResource) async throws {
        let window = try await window(resource)
        guard let paragraph = Self.paragraphs(window).first(where: { $0.0 == anchor.paragraphStartByte }) else {
            throw EPUBError.invalidPosition
        }
        let units = Array(paragraph.1.utf16)
        let offset = anchor.characterUTF16Offset
        guard offset >= 0, offset <= units.count else { throw EPUBError.invalidPosition }
        if offset < units.count, 0xDC00...0xDFFF ~= units[offset] { throw EPUBError.invalidPosition }
    }
    private static func paragraphs(_ window: TXTChapterWindow) -> [(Int64,String)] {
        let bytes = Array(window.text.utf8)
        var result: [(Int64,String)] = [], start=0, index=0
        while index < bytes.count {
            if bytes[index] == 10 || bytes[index] == 13 {
                result.append((window.startByte+Int64(start),String(decoding: bytes[start..<index],as: UTF8.self)))
                if bytes[index] == 13, index+1 < bytes.count, bytes[index+1] == 10 { index += 1 }
                index += 1; start = index
            } else { index += 1 }
        }
        if start < bytes.count { result.append((window.startByte+Int64(start),String(decoding: bytes[start...],as: UTF8.self))) }
        return result
    }
    private static func escape(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
    }
}
