import SwiftUI
import ReadingInterfaces
import XianxiaCore

struct ReadingFontPreview: View {
    let resource: ReaderFontResource?
    var systemFont: ReadingFont = .original
    let theme: ReadingTheme
    var pointSize: Double = 20
    var compact = false
    var unavailable = false
    @State private var png: Data?
    @State private var failure: String?
    private var request: ReadingFontPreviewRequest {
        ReadingFontPreviewRequest(fileURL: resource?.fileURL, identity: resource?.asset.sha256 ?? systemFont.rawValue,
            systemFont: systemFont.rawValue, textRGB: theme.textRGB, backgroundRGB: theme.backgroundRGB,
            pointSize: pointSize, compact: compact)
    }
    var body: some View {
        Group {
            if unavailable {
                Text("字体文件暂不可用").font(.caption)
            } else if let png, let image = UIImage(data: png) {
                Image(uiImage: image).resizable().scaledToFit().accessibilityHidden(true)
            } else if let failure {
                Text(failure).font(.caption)
            } else {
                ProgressView().frame(maxWidth: .infinity, minHeight: compact ? 30 : 76)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("字体字形样例")
        .accessibilityIdentifier("reader.font.preview." + (resource?.asset.id.uuidString ?? systemFont.rawValue))
        .accessibilityValue(unavailable ? "字体文件暂不可用" : (failure ?? (png == nil ? "正在准备" : "字形已就绪")))
        .task(id: request) {
            png = nil; failure = nil
            guard !unavailable else { return }
            do {
                let result = try await ReadingFontPreviewRenderer.shared.render(request)
                try Task.checkCancellation(); png = result
            } catch {
                guard !Task.isCancelled else { return }
                failure = error.localizedDescription
            }
        }
    }
}
