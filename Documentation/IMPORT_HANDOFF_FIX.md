# 首次文件导入交接

2026-10-14 用户报告 TXT 正常导入但首次选择不生效，EPUB 之前也发生过；随后明确“选择器关闭了，但书架没有新书，也没有提示”。此前 Build2 的导入修复覆盖类型/副本/协调复制/直接导入测试，没有运行真正的 SwiftUI 首次 sheet 关闭回归。Build5 的 TXT 后端测试也不能证明这个交接正常。

## 实现

两种格式共用 `DocumentImportSheet`，生产书架和原生回归使用同一组件。`LibraryViewModel` 保存 picker 结果，关闭后的 `finishPicking` 从同一个引用实例取出并立即清空，再启动导入或报告错误。取消留下空结果，重复关闭不会再次导入；原 Coordinator 的一次终止回调与取消后迟到文件过滤继续保留。没有改 File Provider 类型、asCopy、NSFileCoordinator、数据库提交顺序、编码/排版/位置，旧书库不迁移、不删除。

旧交接把待处理结果放在页面 `@State`，正文并不读取该值，`onDismiss` 再从捕获的页面快照取值。这存在首次交接读取旧值的疑点。现在结果由生命周期稳定的参考模型持有，不依赖页面刷新建立读取关系。Apple 的 [StateObject](https://developer.apple.com/documentation/swiftui/stateobject) 文档支持模型在视图生命周期内由 SwiftUI 管理，不能据此单独证明本次设备故障；本项目复现与修复结论以实际模拟器日志为准。

## 验证边界

新增 3 个 iOS 回归实际呈现 SwiftUI sheet / UIDocumentPicker 并调用真实 Coordinator delegate：冷首次 TXT、冷首次 EPUB，以及取消/空选择/再次选择/迟到文件。首次关闭后必须直接出现唯一书籍、成功提示和实际 SQLite 记录，原文件 bytes 必须一致；不手动刷新、不再次呈现、不直接调用 importBooks 来替代交接。

模拟器向 delegate 提供项目原创文件 URL，没有操作系统文件浏览器/实际 iCloud 下载的自动化，也没有代替用户 iPhone/TrollStore 实测。旧 EPUB 冷打开回归的历史超时是另一个未确认问题，不合并为首次文件导入故障。

旧交接候选80e503d / CI38563181206等待结果；工作区参考模型修复 Build6 尚未完整编译。Windows380语法新增0/pristine54限制保留、14 tooling通过，仅代表自动静态检查。完整 Core68/iOS49/设备Release结果与源码/锁/IPA核验另记 M2_IMPORT_HANDOFF_VALIDATION_REPORT.json。Build4/Build5 IPA与测试ZIP均保留，新的验证不能覆盖它们的历史证据。
