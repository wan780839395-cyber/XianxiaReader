# 阅读进度依赖与菜单边缘

Build28 开发中，Build27 仍为最后已交付版本。当前源码尚未编译或设备验收。

用户认可上一片并要求继续，延续M4流畅度与界面完善。本片只修改App展示依赖和菜单顶部装饰，保留原设置、正文渲染、引擎定位、每次完整Locator保存及迟到结果过滤。

## 进度依赖

实际Build27中ReaderViewModel.position是@Published，ReaderView的StateObject以及ReaderMenuView/ReaderAppearanceView的ObservedObject都会接到每个位置事件。菜单中只有章名、百分比与进度条需要读这个字段。按Apple公开的[Demystify SwiftUI performance，WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)所述缩小视图依赖：使用iOS16已有ObservableObject/Published，将进度变成稳定的独立对象；完整opaque位置每个事件照常更新并传入原数据库保存，只有显示摘要变化才发布给进度小视图。没有时间节流、丢弃最终位置、改百分比持久化或依赖更高系统的Observation，不使用_printChanges私有诊断调用。

新增真实ReaderViewModel/SQLite回归，连续65个位置事件检查root通知为0、相同章名/进度摘要合并、显示章变化仍发布、最后完整定位字节与版本落盘、关闭后迟到事件被拒绝。另核无位置/无有效进度、边界归一化及等价显示更新。它验证通知范围和保存正确性，不代表真机FPS或引擎DOM开销已量化。

同一次读源码与[固定Readium3.11 ControlFlow实现](https://raw.githubusercontent.com/readium/swift-toolkit/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Shared/Toolkit/ControlFlow.swift)核对：execute只合并等待idle期间请求，不序列化已经执行的async工作。这仍只是需trace确认的线索，本片不改Vendor/Readium/DOM调度/数据库写入频率，避免把未经测量的假设当手机卡顿根因。

## 菜单顶部

浮动卡片四周和状态栏下的正文曾与控件视觉交叠。给header背景加当前页面色的实色边缘和24pt向下渐隐，跟随原菜单过渡，不改变ReaderSurface全尺寸、Readium内部安全区或排版位置。装饰不接收触摸且对辅助功能隐藏，没有blur、整页截图或独立动画；系统/额外减少动效继续使用原identity过渡。

使用[SwiftUI background(alignment:content:)](https://developer.apple.com/documentation/swiftui/view/background(alignment:content:))及既有iOS16渐变/安全区API。需实际查看浅深色、菜单显隐、目录跨章与回看原生截图/录屏/原帧；不把遮罩等同于整本排版/标题留白或所有安全区问题修复。新真UI保留44pt、header位置稳定、跨章后进度更新、正文中点显隐、正常/减少动效与换色后可操作的检查。

## 门槛

Windows语法与17工具测试单列；独立完整Linux/macOS Core137、iOS161（135集成+26UI）及Release28/min16通过后才交付。原测试主体保留，不扩大原采样预算。无依赖/schema/缓存/资源窗口/锁文件变化。手机iPhone13/iOS16.6.1/TrollStore帧时间、内存/耗电，微信QQ/Alook字体入口与普通设备/辅助功能完整矩阵仍待真机；不归因60Hz，不提前M5。
