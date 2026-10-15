import Foundation

/// A custom cover is independent of the publication's original cover.
/// Paths are derived from UUIDs, never supplied by the image picker or persisted as absolute URLs.
public struct BookCoverOverride: Codable, Equatable, Sendable {
    public let assetID: UUID
    public init(assetID: UUID = UUID()) { self.assetID = assetID }
    public func directory(bookID: UUID) -> String { "Books/\(bookID.uuidString)/Artwork/\(assetID.uuidString)" }
    public func originalPath(bookID: UUID) -> String { directory(bookID: bookID) + "/original" }
    public func thumbnailPath(bookID: UUID) -> String { directory(bookID: bookID) + "/thumbnail.jpg" }
}

public enum BookCoverError: LocalizedError, Equatable {
    case invalidImage, imageTooLarge, missingBookFiles, invalidThumbnail
    public var errorDescription: String? {
        switch self {
        case .invalidImage: return "无法读取这张图片，请选择有效的照片或图片文件。"
        case .imageTooLarge: return "图片超过 20 MB，请选择较小的图片。"
        case .missingBookFiles: return "原书目录不存在，封面未更改。"
        case .invalidThumbnail: return "封面缩略图无效，原封面已保留。"
        }
    }
}

public struct StagedCover: Sendable {
    public let bookID: UUID
    public let cover: BookCoverOverride
    public let originalURL: URL
}
