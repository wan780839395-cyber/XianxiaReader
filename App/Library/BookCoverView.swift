import SwiftUI
import UIKit
import XianxiaCore

@MainActor struct BookCoverView: View {
    let book: Book
    let files: BookFileStore
    @State private var image: UIImage?

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
                    Text(book.title).font(.system(.headline, design: .serif)).lineLimit(4)
                }.foregroundStyle(Color(red: 0.91, green: 0.87, blue: 0.75)).padding()
            }
        }
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityHidden(true)
        .task(id: book.coverPath) {
            image = nil
            guard let path = book.coverPath else { return }
            let data = await Task.detached(priority: .utility) {
                guard let url = try? files.resolve(path) else { return Data?.none }
                return try? Data(contentsOf: url)
            }.value
            if !Task.isCancelled, let data { image = UIImage(data: data) }
        }
    }
}
