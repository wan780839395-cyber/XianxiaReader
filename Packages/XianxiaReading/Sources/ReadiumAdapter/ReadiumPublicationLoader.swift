import Foundation
import ReadiumShared
import ReadiumStreamer
import ReadingInterfaces
import UIKit
import XianxiaCore

public enum EPUBError: LocalizedError {
    case invalidURL, unsupported, restricted, invalidPosition, navigationFailed
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "无法访问书籍文件。"
        case .unsupported: return "文件不是受支持的 EPUB，或正文阅读顺序为空。"
        case .restricted: return "此 EPUB 受 DRM 保护，当前版本无法解锁。"
        case .invalidPosition: return "保存的阅读位置版本不兼容或已损坏。"
        case .navigationFailed: return "无法跳转到这个阅读位置。"
        }
    }
}

/// Non-UI parsing executor. Each loader serializes its own Readium components.
public actor ReadiumPublicationLoader: EPUBMetadataReading {
    private let retriever: AssetRetriever
    private let opener: PublicationOpener

    public init() {
        let client = DefaultHTTPClient()
        let retriever = AssetRetriever(httpClient: client)
        self.retriever = retriever
        opener = PublicationOpener(parser: DefaultPublicationParser(
            httpClient: client, assetRetriever: retriever, pdfFactory: DefaultPDFDocumentFactory()
        ))
    }

    func open(at url: URL) async throws -> Publication {
        try Task.checkCancellation()
        guard let fileURL = FileURL(url: url) else { throw EPUBError.invalidURL }
        let asset = try await retriever.retrieve(url: fileURL).get()
        guard asset.format.conformsTo(.epub) else { throw EPUBError.unsupported }
        let publication = try await opener.open(asset: asset, allowUserInteraction: false).get()
        guard !publication.isRestricted else { throw EPUBError.restricted }
        guard publication.conforms(to: .epub), !publication.readingOrder.isEmpty else { throw EPUBError.unsupported }
        try Task.checkCancellation()
        return publication
    }

    public func readMetadata(at url: URL, bookID: UUID) async throws -> ImportedPublication {
        let publication = try await open(at: url)
        let links = try await publication.tableOfContents().get()
        var chapters: [Chapter] = []
        func append(_ links: [Link], depth: Int) {
            for link in links {
                let index = chapters.count
                chapters.append(Chapter(id: "\(bookID.uuidString):toc:\(index)", bookID: bookID,
                                        ordinal: index, title: link.title ?? "目录条目 \(index + 1)",
                                        depth: depth, href: link.href))
                append(link.children, depth: depth + 1)
            }
        }
        append(links.isEmpty ? publication.readingOrder : links, depth: 0)
        var warnings: [String] = []
        var coverData: Data?
        switch await publication.coverFitting(maxSize: CGSize(width: 600, height: 900)) {
        case .success(let image): coverData = image?.jpegData(compressionQuality: 0.85)
        case .failure(let error): warnings.append("封面读取失败：\(error.localizedDescription)")
        }
        let title = publication.metadata.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return ImportedPublication(title: title, author: publication.metadata.authors.map(\.name).joined(separator: "、"),
                                   coverData: coverData, chapters: chapters, warnings: warnings)
    }
}
