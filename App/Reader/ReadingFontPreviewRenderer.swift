import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

struct ReadingFontPreviewRequest: Hashable, Sendable {
    let fileURL: URL?
    let identity: String
    let systemFont: String
    let textRGB: Int
    let backgroundRGB: Int
    let pointSize: Double
    let compact: Bool
}

enum ReadingFontPreviewError: LocalizedError {
    case unreadableFont, drawingFailed
    var errorDescription: String? {
        switch self {
        case .unreadableFont: return "字体样式暂时无法读取，请检查字体文件。"
        case .drawingFailed: return "字体样式暂时无法显示，请重新打开设置。"
        }
    }
}

/// Draw a bounded original sample with the actual file, without process-wide
/// registration or loading every CJK face on the main actor. One CGFont and at
/// most twelve already-drawn images / 8 MiB of pixels are retained. The UI never
/// encodes or decodes a PNG while scrolling; render() is the diagnostic exporter.
actor ReadingFontPreviewRenderer {
    static let shared = ReadingFontPreviewRenderer()
    private var lastURL: URL?
    private var lastFont: CGFont?
    private var images: [ReadingFontPreviewRequest: CGImage] = [:]
    private var order: [ReadingFontPreviewRequest] = []
    private var pixelBytes = 0
    private(set) var drawingCount = 0

    func image(_ request: ReadingFontPreviewRequest) throws -> CGImage {
        try Task.checkCancellation()
        guard request.pointSize.isFinite, (8...48).contains(request.pointSize) else {
            throw ReadingFontPreviewError.drawingFailed
        }
        if let image = images[request] { return image }
        let font: CTFont
        if let url = request.fileURL {
            if lastURL != url || lastFont == nil {
                guard let provider = CGDataProvider(url: url as CFURL), let loaded = CGFont(provider) else {
                    throw ReadingFontPreviewError.unreadableFont
                }
                lastURL = url; lastFont = loaded
            }
            guard let loaded = lastFont else { throw ReadingFontPreviewError.unreadableFont }
            font = CTFontCreateWithGraphicsFont(loaded, request.pointSize, nil, nil)
        } else if request.systemFont == "serif" {
            font = CTFontCreateWithName("TimesNewRomanPSMT" as CFString, request.pointSize, nil)
        } else {
            guard let system = CTFontCreateUIFontForLanguage(.system, request.pointSize, "zh-Hans" as CFString) else {
                throw ReadingFontPreviewError.drawingFailed
            }
            font = system
        }
        try Task.checkCancellation()
        let text = request.compact ? "山风拂过书页" : "山风穿过竹林，云海漫过书页。\n清茶半盏，闲书一卷。"
        func color(_ rgb: Int) -> CGColor {
            CGColor(red: CGFloat((rgb >> 16) & 255) / 255,
                    green: CGFloat((rgb >> 8) & 255) / 255,
                    blue: CGFloat(rgb & 255) / 255, alpha: 1)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): color(request.textRGB)
        ]
        let framesetter = CTFramesetterCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes) as CFAttributedString)
        let width: CGFloat = request.compact ? 156 : 300
        let inset: CGFloat = 2, scale: CGFloat = 3
        let measured = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: 0), nil,
            CGSize(width: width - inset * 2, height: 1000), nil)
        let height = min(240, max(26, ceil(measured.height) + 8))
        guard let context = CGContext(data: nil, width: Int(width * scale), height: Int(height * scale),
            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw ReadingFontPreviewError.drawingFailed }
        context.scaleBy(x: scale, y: scale)
        // All previews are transparent. Their native parent owns the surface;
        // an opaque PNG must never draw an inner rectangular page on the card.
        let path = CGPath(rect: CGRect(x: inset, y: 4, width: width - inset * 2, height: height - 8), transform: nil)
        CTFrameDraw(CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil), context)
        try Task.checkCancellation()
        guard let image = context.makeImage() else { throw ReadingFontPreviewError.drawingFailed }
        let cost = image.bytesPerRow * image.height
        while !order.isEmpty && (order.count >= 12 || pixelBytes + cost > 8 * 1_024 * 1_024) {
            if let old = images.removeValue(forKey: order.removeFirst()) {
                pixelBytes -= old.bytesPerRow * old.height
            }
        }
        images[request] = image; order.append(request); pixelBytes += cost
        drawingCount += 1
        return image
    }

    func cacheFootprint() -> (images: Int, bytes: Int) { (images.count, pixelBytes) }

    /// Kept for native validation attachments. The scrolling view uses image().
    func render(_ request: ReadingFontPreviewRequest) throws -> Data {
        let image = try image(request)
        try Task.checkCancellation()
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.png.identifier as CFString, 1, nil) else {
            throw ReadingFontPreviewError.drawingFailed
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw ReadingFontPreviewError.drawingFailed }
        return data as Data
    }
}
