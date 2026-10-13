# M1 真机导入问题与修复

2026-10-13，用户 iPhone13 / iOS16.6.1 / TrollStore 安装正常。先反馈 EPUB 灰色不可选，随后截图显示原创 chinese-epub3.epub 已在 iCloud 云盘选中，但按“打开”没有反应。未取得系统 File Provider 日志，因此不能确定是系统权限、下载还是 SwiftUI 交接失败；不能把解析单测通过当成导入流程正常。

## 本次修改

- 使用公开 UIDocumentPickerViewController 的 `forOpeningContentTypes:asCopy:`，明确 `asCopy: true`，得到导入副本，再复用原来的后台文件协调复制、Readium 校验及 SQLite 事务。没有删除 NSFileCoordinator 或加入私有权限。
- 选择器允许 `.data`，避免 File Provider 的 ZIP/动态 UTI 标注让 EPUB 灰色。业务入口检查本地 `.epub` 后缀，Readium 检查真实 EPUB 内容；TXT、其他格式和伪装 EPUB 仍拒绝且报错。
- delegate 只接收一次终止回调；取消后的迟到文件不触发导入。sheet 关闭后才处理导入/提示，避免错误提示被文件选择器盖住。批次部分失败保留成功书籍，并显示成功数量和错误。
- 两本原创样书作为应用资源，提供“导入内置样书”。它们经过同一个真实导入流程，允许在 File Provider 仍异常时继续验收阅读；不能据此宣布 iCloud 问题已解决。
- Build 2，版本仍 0.0.1，便于区分本次修复包。

Apple 说明导入会提供沙盒内的临时副本，而原位打开依赖外部 security-scoped URL：[Document Picker Programming Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/DocumentPickerProgrammingGuide/AccessingDocuments/AccessingDocuments.html)。现代 API：[init(forOpeningContentTypes:asCopy:)](https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller/init(foropeningcontenttypes:ascopy:))。这支持本次实现选择，并不证明本机故障的唯一原因。

## 验证边界

新增 6 个 iOS 回归：选中/重复回调、取消/迟到、空回调、TXT 与大写 EPUB 混合批次、主应用包中的样书真实导入、空批次重试。原来的 EPUB/生命周期/位置/搜索回归全部保留。Windows 39 grammar 与 6 Python tooling tests 已通过。[完整 CI 38411028842](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38411028842) 的 Linux/macOS 各 14 Core、26 iOS tests、设备 Release/Build 2 IPA 全通过；54 构建来源 hash 匹配提交 0649833，样书/版本/IPA 完整性已核验，详见 M1_IMPORT_VALIDATION_REPORT.json。应用源码 compiler warnings=0，AppIntents metadata 的 6 条提示另行保留。

首轮 CI 38409222759 因 Agent 误读网页旧片段，过早取消了正在进行的设备 Release；完整日志证实当时测试已通过。取消记录见 ValidationLogs/m1-import-cancelled.json，同提交重试已成功。不能把那次取消写成代码失败，也不能把本次 CI 通过写成真实 iCloud 导入已通过。

真机依次验证：

1. 用 TrollStore 更新应用，保留数据；点击“导入内置样书”，应出现两本两章书并可阅读。
2. 将测试包的 Samples 放入“我的 iPhone”，从应用导入，确认选择器关闭、出现导入状态、书架新增书籍。
3. 再从 iCloud 导入同一本，检查已下载和仅云端文件。若仍无反应，记录是否选择器停留、是否下载完成；先使用本地副本继续阅读验收。
4. 取消、选择 TXT/损坏 EPUB、混合批次均需有正确反馈，不丢已导入书籍。

本机与 iCloud 两条路径分开记录，TXT 仍属于尚未开始的 M2。
