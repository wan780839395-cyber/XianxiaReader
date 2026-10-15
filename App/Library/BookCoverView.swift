import CoreGraphics
import SwiftUI
import XianxiaCore

@MainActor struct BookCoverView: View {
    let book: Book
    let files: BookFileStore
    var compact = false
    @State private var image: CGImage?
    @State private var warning: String?
    @State private var displayedPath: String?
    @State private var displayedCropped = false
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.libraryReduceMotionRequested) private var requestedReduceMotion

    var body: some View {
        ZStack {
            BookCoverArtwork(title: book.title, image: image, compact: compact, cropped: displayedCropped)
                .id(displayedPath).transition(.opacity)
        }
            .overlay(alignment: .bottom) {
                if let warning {
                    Label(warning == "已从原图恢复封面" ? warning : "封面不可用", systemImage: "exclamationmark.triangle").font(.caption2).lineLimit(1)
                        .padding(4).background(.regularMaterial).foregroundStyle(.primary)
                }
            }
            .animation(systemReduceMotion || requestedReduceMotion ? nil : .easeInOut(duration: 0.18), value: displayedPath)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(warning ?? "")
            .accessibilityHidden(warning == nil)
            .task(id: "\(book.displayCoverPath ?? "default")|\(compact)") {
                warning = nil
                guard let path = book.displayCoverPath else { image = nil; displayedPath = nil; return }
                do {
                    let decoded = try await CoverImagePipeline.shared.image(files: files, path: path, maximumPixelSize: compact ? 252 : 600,
                                                                          originalPath: book.coverOverride?.originalPath(bookID: book.id))
                    guard !Task.isCancelled else { return }
                    image = decoded.image; displayedPath = path; displayedCropped = book.coverOverride != nil; warning = decoded.warning
                } catch is CancellationError { return }
                catch {
                    guard !Task.isCancelled else { return }
                    image = nil; displayedPath = nil; warning = "封面不可用：\(error.localizedDescription)"
                }
            }
    }
}
