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
                    Text("ANSI / GBK（中文 Windows）").tag(TXTEncoding.gbk)
                    Text("GB18030（含扩展汉字）").tag(TXTEncoding.gb18030)
                    Text("Big5 / ANSI（繁体 Windows）").tag(TXTEncoding.big5)
                    Text("Windows-1252（西文 ANSI）").tag(TXTEncoding.windows1252)
                }.pickerStyle(.inline)
                Text("自动优先识别编码标记和 UTF-8，其他按中文 Windows 的 GBK / GB18030 尝试。ANSI 随系统语言不同；繁体或西文文件请选对应编码。原文件始终保留。")
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
