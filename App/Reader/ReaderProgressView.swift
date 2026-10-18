import SwiftUI
import XianxiaCore

/// Only this small part of the chrome depends on the advancing book position.
/// Keep the full opaque locator even when its displayed summary is unchanged.
struct ReaderProgressSummary: Equatable {
    let chapterTitle: String
    let progression: Double?

    init(_ position: ReadingPosition?) {
        chapterTitle = position?.chapterTitle ?? "正文"
        progression = position?.progression.flatMap { $0.isFinite ? min(max($0, 0), 1) : nil }
    }
}

@MainActor final class ReaderProgressState: ObservableObject {
    private(set) var position: ReadingPosition?
    @Published private(set) var summary = ReaderProgressSummary(nil)

    func update(_ position: ReadingPosition?) {
        self.position = position
        let next = ReaderProgressSummary(position)
        if summary != next { summary = next }
    }
}

@MainActor struct ReaderProgressView: View {
    @ObservedObject var state: ReaderProgressState
    let palette: ReaderPalette

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(state.summary.chapterTitle).font(.footnote).lineLimit(1)
                    .accessibilityIdentifier("reader.progress.title")
                Spacer(minLength: 0)
                if let progress = state.summary.progression {
                    Text("\(Int(progress * 100))%")
                        .font(.caption.monospacedDigit()).foregroundStyle(palette.secondaryText)
                        .accessibilityIdentifier("reader.progress.percentage")
                }
            }
            if let progress = state.summary.progression {
                ProgressView(value: progress).accessibilityLabel("全书阅读进度")
            }
        }
    }
}
