import Foundation
import ReadingInterfaces
import XianxiaCore

/// Stable, read-only App resources. No copy into the user's imported-font catalog.
enum BundledReadingFont: String, CaseIterable, Identifiable {
    case sourceHanSerif, wenKai

    var id: UUID {
        UUID(uuid: (0x78, 0x72, 0x66, 0x6f, 0x6e, 0x74, 0x40, 0x00, 0x80, 0x00, 0, 0, 0, 0, 0,
                    self == .sourceHanSerif ? 1 : 2))
    }
    var title: String { self == .sourceHanSerif ? "思源宋体" : "霞鹜文楷" }
    var subtitle: String { self == .sourceHanSerif ? "端正 · 书卷" : "舒展 · 柔和" }
    var fileName: String { self == .sourceHanSerif ? "SourceHanSerifSC-Regular" : "LXGWWenKai-Regular" }
    var fileExtension: String { self == .sourceHanSerif ? "otf" : "ttf" }

    func resource(bundle: Bundle = .main) throws -> ReaderFontResource {
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension, subdirectory: "Fonts") else {
            throw ReadingFontError.missingFont
        }
        // These immutable originals are hashed at build/package verification. Opening
        // a book only resolves the bundle URL; WebKit loads the selected face lazily.
        let asset = try ReadingFontAsset(id: id, displayName: title, fileExtension: fileExtension,
            sha256: self == .sourceHanSerif
                ? "78aa7a328fd974df2d688c8a9fd74a33d8334dfa84ab24d9d11efb2ffc464117"
                : "bf73f995c05f3f7baf7840b9d76d8d9678c8b150a020946a394ca63c67ed1350",
            bytes: self == .sourceHanSerif ? 24_543_332 : 25_928_940)
        return ReaderFontResource(asset: asset, fileURL: url)
    }
}
