# 首次文件导入交接

2026-10-14 用户报告 TXT 正常导入但首次选择不生效，EPUB 之前也发生过；随后明确“选择器关闭了，但书架没有新书，也没有提示”。此前 Build2 的导入修复覆盖类型/副本/协调复制/直接导入测试，没有运行真正的 SwiftUI 首次 sheet 关闭回归。Build5 的 TXT 后端测试也不能证明这个交接正常。

## 实现

两种格式共用 `DocumentImportSheet`，生产书架和原生回归使用同一组件。`LibraryViewModel` 保存 picker 结果，关闭后的 `finishPicking` 从同一个引用实例取出并立即清空，再启动导入或报告错误。取消留下空结果，重复关闭不会再次导入；原 Coordinator 的一次终止回调与取消后迟到文件过滤继续保留。没有改 File Provider 类型、asCopy、NSFileCoordinator、数据库提交顺序、编码/排版/位置，旧书库不迁移、不删除。

旧交接把待处理结果放在页面 `@State`，正文并不读取该值，`onDismiss` 再从捕获的页面快照取值。这存在首次交接读取旧值的疑点。现在结果由生命周期稳定的参考模型持有，不依赖页面刷新建立读取关系。Apple 的 [StateObject](https://developer.apple.com/documentation/swiftui/stateobject) 文档支持模型在视图生命周期内由 SwiftUI 管理，不能据此单独证明本次设备故障；本项目复现与修复结论以实际模拟器日志为准。

## 参考与取舍

核实锁定Readium3.11.0 / d82f44f4f05d87add9e22a8b75abbd61dce745dd的官方[TestApp LibraryViewController](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/TestApp/Sources/Library/LibraryViewController.swift)：它让持久的UIKit controller接收picker delegate并把URL交给library Task，不把待导入结果放进SwiftUI页面值中。本项目采用相同的引用拥有者交接原则，但保留SwiftUI书架、asCopy:true宽类型选择、后台协调复制，并在sheet关闭后展示提示；没有照搬它的原位打开/窄类型策略或替换引擎。源文件已读并保存在忽略缓存.cache/recovery/readium-3.11-LibraryViewController.swift，未纳入Vendor/改锁。

测试时序依据Apple公开[transitionCoordinator](https://developer.apple.com/documentation/uikit/uiviewcontroller/transitioncoordinator)与[dismiss completion](https://developer.apple.com/documentation/uikit/uiviewcontroller/dismiss(animated:completion:))，等待真实过渡结束再移除host/重新呈现。Apple论坛[773879](https://developer.apple.com/forums/thread/773879)有相同DocumentManager异常和提前关闭父controller的用户复现报告；DTS当时未复现，该帖子不构成本项目设备根因或已修复系统bug的证据。不调用栈中的私有selector，也不隐藏异常。

## 验证边界

新增 3 个 iOS 回归实际呈现 SwiftUI sheet / UIDocumentPicker 并调用真实 Coordinator delegate：冷首次 TXT、冷首次 EPUB，以及取消/空选择/再次选择/迟到文件。首次关闭后必须直接出现唯一书籍、成功提示和实际 SQLite 记录，原文件 bytes 必须一致；不手动刷新、不再次呈现、不直接调用 importBooks 来替代交接。

模拟器向 delegate 提供项目原创文件 URL，没有操作系统文件浏览器/实际 iCloud 下载的自动化，也没有代替用户 iPhone/TrollStore 实测。旧 EPUB 冷打开回归的历史超时是另一个未确认问题，不合并为首次文件导入故障。

旧交接候选80e503d / CI38563181206已结束：各68 Core、iOS48/49。首次TXT/EPUB成功，提取后的旧交接在iOS18.5未复现用户设备现象；新增取消/空选择/重试测试启动时，系统DocumentManager向deallocated host proxy发消息，NSInternalInconsistencyException致进程退出。test65/附件0/summary0，Release/IPA未执行。完整日志/xcresult和ValidationLogs/m2-import-native-sheet-baseline-failure.json保留，不把系统崩溃或首次成功写成已确定设备根因。

参考模型修复 e858ee6 / Build6 / CI38564595658同样各68Core/iOS48/49，首次TXT/EPUB通过，取消/重试再次发生上述系统异常；未执行Release/IPA，完整失败原件保留。生产修复没有改动，后续仅修测试的呈现/关闭时序：真实picker和父controller的transition结束、关闭后view脱离window，picker保留到host teardown，而非仅等待presentedViewController为nil。全部行为/数据库/原件断言与15秒deadline保留；未吞异常或增加timeout。

最新5522489 / codex/import-first-selection / CI38566503849已全部成功：各68Core/iOS49/49/Build6设备Release，0 failed/skipped，test/附件/summary退出码0；456运行Git blob SHA及根/下载/workspace锁匹配。Windows380语法新增0/pristine54限制保留、14 tooling通过，语法不是编译。新IPA/测试ZIP已核验，报告M2_IMPORT_HANDOFF_VALIDATION_REPORT.json / ValidationLogs/m2-import-handoff-build6-success.json / m2-import-build6-test-kit.json。用户iOS16.6.1首次导入仍待实测，旧交接未在iOS18.5复现，不能把本轮自动通过写成设备根因已证实。Build4/Build5 IPA与ZIP均保留。
