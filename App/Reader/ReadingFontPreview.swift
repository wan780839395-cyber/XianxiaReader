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
    @State private var image: CGImage?
    @State private var loadedRequest: ReadingFontPreviewRequest?
    @State private var failure: String?
    private var request: ReadingFontPreviewRequest {
        ReadingFontPreviewRequest(fileURL: resource?.fileURL, identity: resource?.asset.sha256 ?? systemFont.rawValue,
            // A reusable alpha mask: theme changes only tint the native image.
            systemFont: systemFont.rawValue, textRGB: 0, backgroundRGB: 0,
            pointSize: pointSize, compact: compact)
    }
    private var height: Double { compact ? 52 : max(72, pointSize * 4.5) }
    private struct LoadID: Equatable {
        let request: ReadingFontPreviewRequest
        let unavailable: Bool
    }
    var body: some View {
        Group {
            if unavailable {
                Text("字体文件暂不可用").font(.caption)
            } else if loadedRequest == request, let image {
                Image(decorative: image, scale: 3).resizable()
                    .renderingMode(.template).scaledToFit().accessibilityHidden(true)
                    .frame(maxWidth: CGFloat(image.width) / 3, maxHeight: CGFloat(image.height) / 3, alignment: .leading)
            } else if let failure {
                Text(failure).font(.caption)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .leading)
        .foregroundStyle(theme.foreground)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("字体字形样例")
        .accessibilityIdentifier("reader.font.preview." + (resource?.asset.id.uuidString ?? systemFont.rawValue))
        .accessibilityValue(unavailable ? "字体文件暂不可用" : (failure ?? (loadedRequest != request ? "正在准备" : "字形已就绪")))
        .task(id: LoadID(request: request, unavailable: unavailable)) {
            failure = nil
            guard !unavailable else { return }
            do {
                let result = try await ReadingFontPreviewRenderer.shared.image(request)
                try Task.checkCancellation()
                image = result; loadedRequest = request
            } catch {
                guard !Task.isCancelled else { return }
                failure = error.localizedDescription
            }
        }
    }
}
