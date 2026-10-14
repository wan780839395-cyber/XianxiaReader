# 文件选择直接交接与完整书架回归

2026-10-14 用户在Build6测试包交付后报告：打开软件首次导入仍无反应/提示，第二次能够成功并出现错误。按交付上下文记录Build6设备首次验收失败，实际安装Build号/OS未由工具独立读取；自动49项通过不能覆盖这个反馈。Build6及历史原件保留，不改写其测试结论。

## 已核实的缺口

Build6把结果从页面State移到LibraryViewModel，但仍要等sheet.onDismiss消费才启动导入。旧3项原生测试挂载Text和单sheet；完整LibraryView实际还有编码sheet、reader cover、alert与首次refresh。没有证明首次系统Files关闭一定调用该消费方法，也没有在iOS16.6.1复现。因此本轮去掉这个必须依赖的事件，不再对排队状态反复补丁。

## 最小改动

- UIDocumentPicker delegate结果直接传给LibraryViewModel.receivePickedDocuments，关闭presentedSheet并立即启动原有Task或记录错误。没有pending队列/finishPicking/onDismiss启动导入。
- LibrarySheet作为唯一item sheet管理文件与原TXT编码页面，编码Form只提取到TXTEncodingSheet。保留reader cover/原设置值/编码重试路径。
- 成功/错误/取消仍由原后台导入流程生成；错误持续显示在书架底部，可关闭/重试，避免picker关闭时另一个alert争抢呈现。菜单显示包内实际版本/Build，便于确认是否更新到本轮。
- 按Readium3.11 TestApp同时支持数组和公共单URL delegate，统一一次终止过滤；取消/重复/迟到选择仍被拒绝。asCopy:true、data选择、security scope、NSFileCoordinator、文件/SQLite/Readium全部不改。

参考为锁定Readium3.11.0 / d82f44f4f05d87add9e22a8b75abbd61dce745dd的[LibraryViewController](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/TestApp/Sources/Library/LibraryViewController.swift)199-219行：选中文件delegate直接调用导入Task，同时实现两种回调。上轮只取其引用拥有者原则，本轮消除等待SwiftUI关闭的差异。Apple公开[UIDocumentPickerDelegate](https://developer.apple.com/documentation/uikit/uidocumentpickerdelegate)、[item sheet](https://developer.apple.com/documentation/swiftui/view/sheet(item:ondismiss:content:))及UIViewController transition合同支持本轮接口；不调用私有API，不换Readium版本。原始参考缓存已读，不直接照搬原位打开或窄类型过滤。

## 验证范围

原3项回归现在直接挂载完整生产LibraryView（包括真实NavigationStack、空/非空书架、编码sheet、cover、反馈与refresh），保留原件bytes/SQLite唯一书籍/成功提示/取消/空选择/迟到断言及15秒deadline。新增4项：完全没有sheet/onDismiss事件也能导入TXT/EPUB；首次无效文件在完整书架报告并可再次选择；已有书库首次导入与编码弹窗往返；单URL/重复数组/取消只消费一次。导出真实首次TXT成功/首次错误书架快照。

模拟器仍向实际delegate提供原创fixture URL，尚未自动点击系统Files选中云端文件，不能宣布已证明用户设备唯一根因。Windows381 grammar新增0/pristine54限制保留、14 tooling通过，非Swift编译。期望各68Core/iOS53/Build7设备Release，本轮尚未完成；确切源码/CI/完整结果另记M2_IMPORT_DELEGATE_VALIDATION_REPORT.json。M2设备/数十MB长书及M3/M4门槛不变。
