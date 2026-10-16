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
/// registration or loading every CJK face on the main actor. Only one CGFont and
/// twelve small PNG results are retained; no book text enters this cache.
actor ReadingFontPreviewRenderer {
    static let shared = ReadingFontPreviewRenderer()
    private var lastURL: URL?
    private var lastFont: CGFont?
    private var images: [ReadingFontPreviewRequest: Data] = [:]
    private var order: [ReadingFontPreviewRequest] = []

    func render(_ request: ReadingFontPreviewRequest) throws -> Data {
        try Task.checkCancellation()
        guard request.pointSize.isFinite, (8...48).contains(request.pointSize) else {
            throw ReadingFontPreviewError.drawingFailed
        }
        if let data = images[request] { return data }
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
        let text = request.compact ? "山风拂卷，云海问道" : "山风穿过竹林，云影落在书页间。\n少年循着石阶，缓缓走入云海。"
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
        let width: CGFloat = 300, inset: CGFloat = 2, scale: CGFloat = 2
        let measured = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: 0), nil,
            CGSize(width: width - inset * 2, height: 1000), nil)
        let height = min(240, max(26, ceil(measured.height) + 8))
        guard let context = CGContext(data: nil, width: Int(width * scale), height: Int(height * scale),
            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw ReadingFontPreviewError.drawingFailed }
        context.scaleBy(x: scale, y: scale)
        context.setFillColor(color(request.backgroundRGB)); context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let path = CGPath(rect: CGRect(x: inset, y: 4, width: width - inset * 2, height: height - 8), transform: nil)
        CTFrameDraw(CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil), context)
        try Task.checkCancellation()
        let data = NSMutableData()
        guard let image = context.makeImage(), let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.png.identifier as CFString, 1, nil) else {
            throw ReadingFontPreviewError.drawingFailed
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw ReadingFontPreviewError.drawingFailed }
        let result = data as Data
        while order.count >= 12 { images.removeValue(forKey: order.removeFirst()) }
        images[request] = result; order.append(request)
        return result
    }
}
