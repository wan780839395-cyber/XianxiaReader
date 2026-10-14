import SwiftUI
import XianxiaCore

@MainActor struct TXTEncodingSheet: View {
    @ObservedObject var model: LibraryViewModel

    var body: some View {
        NavigationStack {
            Form {
                Picker("TXT 编码", selection: $model.txtEncoding) {
                    Text("自动识别").tag(TXTEncoding.automatic)
                    Text("UTF-8").tag(TXTEncoding.utf8)
                    Text("UTF-16 小端").tag(TXTEncoding.utf16LittleEndian)
                    Text("UTF-16 大端").tag(TXTEncoding.utf16BigEndian)
                    Text("GB18030 / GBK").tag(TXTEncoding.gb18030)
                }.pickerStyle(.inline)
                Text("有编码标记的 TXT 可自动识别。不确定时请按文件实际编码选择；原文件会保留。")
                    .font(.footnote).foregroundStyle(.secondary)
                if !model.retryTXTFiles.isEmpty {
                    Button("按所选编码重试") {
                        model.presentedSheet = nil
                        model.retryTXTImport()
                    }
                }
            }.navigationTitle("TXT 编码")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { model.presentedSheet = nil }
                    }
                }
        }
    }
}
