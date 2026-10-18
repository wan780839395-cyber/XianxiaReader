import Foundation
import SwiftUI
import XianxiaCore

extension Notification.Name {
    static let readingFontCatalogChanged = Notification.Name("XianxiaReader.readingFontCatalogChanged")
}

/// Own the security scope immediately, including when a cold-start URL arrives
/// before AppServices is ready. Copy/validation remain in the existing actors.
@MainActor final class FontDocumentInbox: ObservableObject {
    @Published private(set) var importing = false
    @Published private(set) var message: String?
    @Published private(set) var failure: String?
    private struct Pending {
        let url: URL
        let scoped: Bool
    }
    private var pending: [Pending] = []
    private var files: BookFileStore?
    private var task: Task<Void, Never>?
    deinit { for item in pending where item.scoped { item.url.stopAccessingSecurityScopedResource() } }

    func receive(_ url: URL) {
        guard url.isFileURL, ["ttf", "otf"].contains(url.pathExtension.lowercased()) else {
            failure = "请选择 TTF 或 OTF 单字体文件。"; return
        }
        guard pending.count < 16 else { failure = "等待导入的字体较多，请稍后再试。"; return }
        if task == nil, pending.isEmpty { message = nil; failure = nil }
        pending.append(Pending(url: url, scoped: url.startAccessingSecurityScopedResource()))
        importing = true; startIfReady()
    }

    func attach(files: BookFileStore) { self.files = files; startIfReady() }
    func dismissFeedback() { message = nil; failure = nil }
    func waitUntilIdle() async { await task?.value }

    private func startIfReady() {
        guard task == nil, let files, !pending.isEmpty else { return }
        task = Task {
            let importer = ReadingFontImportService(files: files)
            while !pending.isEmpty {
                let item = pending.removeFirst()
                do {
                    let font = try await importer.importFont(from: item.url)
                    message = "已加入我的字体：\(font.displayName)"
                    NotificationCenter.default.post(name: .readingFontCatalogChanged, object: nil)
                } catch {
                    let problem = "字体未导入：\(item.url.lastPathComponent)：\(error.localizedDescription)"
                    failure = [failure, problem].compactMap { $0 }.joined(separator: "\n")
                }
                if item.scoped { item.url.stopAccessingSecurityScopedResource() }
            }
            importing = false; task = nil
        }
    }
}

struct FontInboxFeedback: View {
    @ObservedObject var inbox: FontDocumentInbox
    var body: some View {
        if inbox.importing || inbox.message != nil || inbox.failure != nil {
            HStack(spacing: 12) {
                if inbox.importing { ProgressView() }
                else { Image(systemName: inbox.failure == nil ? "checkmark.circle" : "exclamationmark.circle") }
                Text(inbox.importing ? "正在导入字体…" : (inbox.failure ?? inbox.message ?? ""))
                    .font(.footnote).frame(maxWidth: .infinity, alignment: .leading)
                if !inbox.importing { Button("关闭") { inbox.dismissFeedback() }.frame(minWidth: 44, minHeight: 44) }
            }.padding(.horizontal, 16).padding(.vertical, 8).background(.regularMaterial)
                .accessibilityIdentifier("font.inbox.feedback")
        }
    }
}
