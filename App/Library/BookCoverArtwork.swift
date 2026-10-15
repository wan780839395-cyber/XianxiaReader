import CoreGraphics
import SwiftUI

struct BookCoverArtwork: View {
    let title: String
    let image: CGImage?
    var compact = false
    var cropped = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.21, green: 0.31, blue: 0.29), Color(red: 0.12, green: 0.20, blue: 0.21)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            if let image {
                GeometryReader { geometry in
                    if cropped {
                        Image(decorative: image, scale: 1).resizable().scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        Image(decorative: image, scale: 1).resizable().scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "mountain.2").font(.title)
                    if !compact { Text(title).font(.system(.headline, design: .serif)).lineLimit(4) }
                }.foregroundStyle(Color(red: 0.91, green: 0.87, blue: 0.75)).padding(compact ? 8 : 16)
            }
        }.aspectRatio(2.0 / 3.0, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
