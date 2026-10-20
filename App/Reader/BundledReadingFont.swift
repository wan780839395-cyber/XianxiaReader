import Foundation
import ReaderFonts
import ReadingInterfaces
import XianxiaCore

/// Immutable originals; stable identities survive catalog additions.
enum BundledReadingFont: String, CaseIterable, Identifiable {
    case sourceHanSerif, wenKai, sourceHanSans, zhuque, maShanZheng, xiaoWei

    private var index: UInt8 {
        switch self {
        case .sourceHanSerif: return 1
        case .wenKai: return 2
        case .sourceHanSans: return 3
        case .zhuque: return 4
        case .maShanZheng: return 5
        case .xiaoWei: return 6
        }
    }
    var id: UUID { UUID(uuid: (0x78, 0x72, 0x66, 0x6f, 0x6e, 0x74, 0x40, 0x00, 0x80, 0x00, 0, 0, 0, 0, 0, index)) }
    var title: String {
        switch self {
        case .sourceHanSerif: return "思源宋体"
        case .wenKai: return "霞鹜文楷"
        case .sourceHanSans: return "思源黑体"
        case .zhuque: return "朱雀仿宋"
        case .maShanZheng: return "马善政楷书"
        case .xiaoWei: return "站酷小薇"
        }
    }
    var subtitle: String {
        switch self {
        case .sourceHanSerif: return "端正 · 书卷"
        case .wenKai: return "舒展 · 柔和"
        case .sourceHanSans: return "清晰 · 简洁"
        case .zhuque: return "清雅 · 古意"
        case .maShanZheng: return "书写 · 笔意"
        case .xiaoWei: return "圆润 · 轻巧"
        }
    }
    var fileName: String {
        switch self {
        case .sourceHanSerif: return "SourceHanSerifSC-Regular"
        case .wenKai: return "LXGWWenKai-Regular"
        case .sourceHanSans: return "SourceHanSansSC-Regular"
        case .zhuque: return "ZhuqueFangsong-Regular"
        case .maShanZheng: return "MaShanZheng-Regular"
        case .xiaoWei: return "ZCOOLXiaoWei-Regular"
        }
    }
    var fileExtension: String {
        switch self {
        case .sourceHanSerif: return "otf"
        case .wenKai: return "ttf"
        case .sourceHanSans: return "otf"
        case .zhuque: return "ttf"
        case .maShanZheng: return "ttf"
        case .xiaoWei: return "ttf"
        }
    }
    private var metadata: (bytes: Int64, sha256: String) {
        switch self {
        case .sourceHanSerif: return (24543332, "78aa7a328fd974df2d688c8a9fd74a33d8334dfa84ab24d9d11efb2ffc464117")
        case .wenKai: return (25928940, "bf73f995c05f3f7baf7840b9d76d8d9678c8b150a020946a394ca63c67ed1350")
        case .sourceHanSans: return (16529832, "f1d8611151880c6c336aabeac4640ef434fa13cbfbf1ffe82d0a71b2a5637256")
        case .zhuque: return (8824084, "558c62730844fe54ba220146ed62f859d4e2880188d92d985f8921c6e3743bc4")
        case .maShanZheng: return (5857936, "6d2546bb189c732a8ca29af9e22457b152387d158aa459e4ac2ce1e51788b7fb")
        case .xiaoWei: return (6313808, "a42b620140f493db42f741351dfbf343c0936d58588ee8004b8b2a218d997ff1")
        }
    }
    func resource(bundle: Bundle = .main) throws -> ReaderFontResource {
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension, subdirectory: "Fonts") else {
            throw ReadingFontError.missingFont
        }
        let asset = try ReadingFontAsset(id: id, displayName: title, fileExtension: fileExtension,
            sha256: metadata.sha256, bytes: metadata.bytes)
        return ReaderFontResource(asset: asset, fileURL: url)
    }

    /// Resource ownership stays in the App bundle; the font module receives values only.
    @MainActor static func catalogueResources() -> ReaderFontCoordinator.Snapshot {
        var resources: [ReaderFontResource] = [], warning: String?
        for bundled in allCases {
            do { resources.append(try bundled.resource()) }
            catch { warning = "\(bundled.title)：\(error.localizedDescription)" }
        }
        return .init(fonts: [], resources: resources, warning: warning)
    }
}
