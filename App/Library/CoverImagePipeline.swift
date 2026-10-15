import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XianxiaCore

struct CoverImageResult: Sendable {
    let image: CGImage
    let warning: String?
}
private final class CoverImageCacheEntry {
    let result: CoverImageResult
    init(_ result: CoverImageResult) { self.result = result }
}
private enum CoverReadError: LocalizedError {
    case unavailable(thumbnail: String, original: String)
    var errorDescription: String? {
        switch self {
        case .unavailable(let thumbnail, let original): return "封面缩略图无法读取：\(thumbnail)；原图也无法读取：\(original)"
        }
    }
}

/// Serial background decoding keeps full-resolution photos off the UI executor.
actor CoverImagePipeline {
    static let shared = CoverImagePipeline()
    private let cache = NSCache<NSString, CoverImageCacheEntry>()
    init() { cache.totalCostLimit = 12 * 1_024 * 1_024; cache.countLimit = 64 }

    func image(files: BookFileStore, path: String, maximumPixelSize: Int, originalPath: String? = nil) throws -> CoverImageResult {
        try Task.checkCancellation()
        let url = try files.resolve(path)
        let key = "\(files.root.path)|\(path)|\(maximumPixelSize)" as NSString
        if let cached = cache.object(forKey: key) { return cached.result }
        let image: CGImage
        var warning: String?
        do { image = try downsample(url, maximumPixelSize: maximumPixelSize) }
        catch {
            // Custom thumbnails are rebuildable from the retained original. If both
            // reads fail, preserve both failures instead of hiding a broken cover.
            let thumbnailError = error
            guard let originalPath else { throw thumbnailError }
            do { image = try downsample(files.resolve(originalPath), maximumPixelSize: maximumPixelSize) }
            catch { throw CoverReadError.unavailable(thumbnail: thumbnailError.localizedDescription, original: error.localizedDescription) }
            warning = "已从原图恢复封面"
        }
        try Task.checkCancellation()
        let result = CoverImageResult(image: image, warning: warning)
        cache.setObject(CoverImageCacheEntry(result), forKey: key, cost: image.bytesPerRow * image.height)
        return result
    }

    func thumbnail(at url: URL) throws -> (jpeg: Data, preview: CGImage) {
        try Task.checkCancellation()
        let decoded = try downsample(url, maximumPixelSize: 1_080)
        guard let context = CGContext(data: nil, width: decoded.width, height: decoded.height, bitsPerComponent: 8,
                                      bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw BookCoverError.invalidThumbnail
        }
        let bounds = CGRect(x: 0, y: 0, width: CGFloat(decoded.width), height: CGFloat(decoded.height))
        context.setFillColor(CGColor(red: 0.12, green: 0.20, blue: 0.21, alpha: 1)); context.fill(bounds)
        context.draw(decoded, in: bounds)
        guard let image = context.makeImage() else { throw BookCoverError.invalidThumbnail }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw BookCoverError.invalidThumbnail
        }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw BookCoverError.invalidThumbnail }
        try Task.checkCancellation()
        return (data as Data, image)
    }

    private func downsample(_ url: URL, maximumPixelSize: Int) throws -> CGImage {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
              let height = properties[kCGImagePropertyPixelHeight] as? NSNumber,
              width.doubleValue > 0, height.doubleValue > 0,
              width.doubleValue * height.doubleValue <= 80_000_000 else { throw BookCoverError.invalidImage }
        let options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                      kCGImageSourceCreateThumbnailWithTransform: true,
                                      kCGImageSourceShouldCacheImmediately: true,
                                      kCGImageSourceThumbnailMaxPixelSize: min(maximumPixelSize, 1_080)]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { throw BookCoverError.invalidImage }
        return image
    }
}
