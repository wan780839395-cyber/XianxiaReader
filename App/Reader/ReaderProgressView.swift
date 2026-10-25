import ReaderPositions
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
    let positions = ReaderPositionState()
    var position: ReadingPosition? { positions.position }
    @Published private(set) var summary = ReaderProgressSummary(nil)

    init() {
        positions.onPositionChanged = { [weak self] position in
            guard let self else { return }
            let next = ReaderProgressSummary(position)
            if self.summary != next { self.summary = next }
        }
    }

    func update(_ position: ReadingPosition?) { positions.update(position) }
}

@MainActor struct ReaderProgressView: View {
    @ObservedObject var state: ReaderProgressState
    let palette: ReaderPalette
    var showBookProgress = true

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(state.summary.chapterTitle).font(.footnote).lineLimit(1)
                    .accessibilityIdentifier("reader.progress.title")
                Spacer(minLength: 0)
                if showBookProgress, let progress = state.summary.progression {
                    Text("\(Int(progress * 100))%")
                        .font(.caption.monospacedDigit()).foregroundStyle(palette.secondaryText)
                        .accessibilityIdentifier("reader.progress.percentage")
                }
            }
            if showBookProgress, let progress = state.summary.progression {
                ProgressView(value: progress).accessibilityLabel("全书阅读进度")
                    .accessibilityIdentifier("reader.progress.bar")
            }
        }
    }
}
