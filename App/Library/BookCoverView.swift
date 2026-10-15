import SwiftUI
import UIKit
import XianxiaCore

private enum BookCoverLoad: Sendable { case data(Data), failure(String) }

@MainActor struct BookCoverView: View {
    let book: Book
    let files: BookFileStore
    var compact = false
    @State private var image: UIImage?
    @State private var warning: String?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                LinearGradient(colors: [Color(red: 0.21, green: 0.31, blue: 0.29),
                                        Color(red: 0.12, green: 0.20, blue: 0.21)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack(spacing: 12) {
                    Image(systemName: "mountain.2").font(.title)
                    if !compact { Text(book.title).font(.system(.headline, design: .serif)).lineLimit(4) }
                }.foregroundStyle(Color(red: 0.91, green: 0.87, blue: 0.75)).padding(compact ? 8 : 16)
            }
            if warning != nil {
                VStack { Spacer(); Label("封面不可用", systemImage: "exclamationmark.triangle").font(.caption2)
                    .padding(4).background(.regularMaterial).foregroundStyle(.primary) }
            }
        }
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(warning.map { "封面不可用：\($0)" } ?? "")
        .accessibilityHidden(warning == nil)
        .task(id: book.coverPath) {
            image = nil; warning = nil
            guard let path = book.coverPath else { return }
            let loaded = await Task.detached(priority: .utility) { () -> BookCoverLoad in
                do { return .data(try Data(contentsOf: files.resolve(path))) }
                catch { return .failure(error.localizedDescription) }
            }.value
            guard !Task.isCancelled else { return }
            switch loaded {
            case .data(let data):
                if let decoded = UIImage(data: data) { image = decoded }
                else { warning = "图片格式无法识别，已使用文字封面。" }
            case .failure(let message): warning = message
            }
        }
    }
}
