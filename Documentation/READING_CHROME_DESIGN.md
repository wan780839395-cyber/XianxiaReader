# 阅读进度依赖与菜单边缘

Build28 已通过独立完整自动门槛和所列原生复核并交付，手机/M4整体仍待验收。

用户认可上一片并要求继续，延续M4流畅度与界面完善。本片只修改App展示依赖和菜单顶部装饰，保留原设置、正文渲染、引擎定位、每次完整Locator保存及迟到结果过滤。

## 进度依赖

实际Build27中ReaderViewModel.position是@Published，ReaderView的StateObject以及ReaderMenuView/ReaderAppearanceView的ObservedObject都会接到每个位置事件。菜单中只有章名、百分比与进度条需要读这个字段。按Apple公开的[Demystify SwiftUI performance，WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)所述缩小视图依赖：使用iOS16已有ObservableObject/Published，将进度变成稳定的独立对象；完整opaque位置每个事件照常更新并传入原数据库保存，只有显示摘要变化才发布给进度小视图。没有时间节流、丢弃最终位置、改百分比持久化或依赖更高系统的Observation，不使用_printChanges私有诊断调用。

新增真实ReaderViewModel/SQLite回归，连续65个位置事件检查root通知为0、相同章名/进度摘要合并、显示章变化仍发布、最后完整定位字节与版本落盘、关闭后迟到事件被拒绝。另核无位置/无有效进度、边界归一化及等价显示更新。它验证通知范围和保存正确性，不代表真机FPS或引擎DOM开销已量化。

同一次读源码与[固定Readium3.11 ControlFlow实现](https://raw.githubusercontent.com/readium/swift-toolkit/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Shared/Toolkit/ControlFlow.swift)核对：execute只合并等待idle期间请求，不序列化已经执行的async工作。这仍只是需trace确认的线索，本片不改Vendor/Readium/DOM调度/数据库写入频率，避免把未经测量的假设当手机卡顿根因。

## 菜单顶部

浮动卡片四周和状态栏下的正文曾与控件视觉交叠。给header背景加当前页面色的实色边缘和24pt向下渐隐，跟随原菜单过渡，不改变ReaderSurface全尺寸、Readium内部安全区或排版位置。装饰不接收触摸且对辅助功能隐藏，没有blur、整页截图或独立动画；系统/额外减少动效继续使用原identity过渡。

使用[SwiftUI background(alignment:content:)](https://developer.apple.com/documentation/swiftui/view/background(alignment:content:))及既有iOS16渐变/安全区API。需实际查看浅深色、菜单显隐、目录跨章与回看原生截图/录屏/原帧；不把遮罩等同于整本排版/标题留白或所有安全区问题修复。新真UI保留44pt、header位置稳定、跨章后进度更新、正文中点显隐、正常/减少动效与换色后可操作的检查。

## 门槛

Windows语法与17工具测试单列；独立完整Linux/macOS Core137、iOS161（135集成+26UI）及Release28/min16通过后才交付。原测试主体保留，不扩大原采样预算。无依赖/schema/缓存/资源窗口/锁文件变化。手机iPhone13/iOS16.6.1/TrollStore帧时间、内存/耗电，Build27标准字体入口实际样例已由用户确认成功，微信QQ/Alook逐来源格式与普通设备/辅助功能完整矩阵仍待真机；不归因60Hz，不提前M5。

## 实际结果

## Build28 阅读进度依赖与菜单顶部（2026-10-18）

实际源`8acc3f2f7980b3d291155936184f36ddc42d4c84` / `codex/m4-reader-chrome` / [完整CI 39113019568](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39113019568)。Linux/macOS Core各137，iOS161/161（135集成+26真UI）失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release28/min16。三锁六pins、546编译资源blob、六原字体/OFL与每平台4组长TXT Release探针已核。Windows448语法新增0/54既有Vendor限制、17工具通过，语法不是编译；受改测试文件38个原test主体不变，3新增，其他旧回归完整重跑。Core/Adapter/Vendor/CI/schema/依赖均保持Build27。

进度从ReaderViewModel广泛发布改为独立稳定对象，只有章名/进度条小视图观察摘要；相同显示摘要不发布，但每个完整Locator及原异步SQLite写入都保留。真实ViewModel/SQLite的65事件回归：root通知0、摘要通知2，最后完整字节/版本保存且关闭后迟到事件拒绝。该计数不是手机FPS、全部卡顿根因或数据库写入减少。顶部浮动菜单补页面色底与24pt渐隐，无blur、不接收触摸，不改引擎viewport、安全区/排版/位置；原44pt和系统/额外减少动效保持。

安装[XianxiaReader-ReadingChrome-Build28.ipa](build/XianxiaReader-ReadingChrome-Build28.ipa) SHA256 `700551af9cecd5b98fd22b7043eba690657392064dc5091de8f45c2925dd3958`；[原创样书/字体许可/原生Preview测试包](build/XianxiaReader-ReadingChrome-Build28-TestKit.zip) SHA256 `7a57affea60a83fb6c6519edecf7709ac07266c2f57da412441396dc4f36636d`。覆盖安装保留书库，+菜单确认0.0.1 (28)，49旧交付包和全部未提交工作/1047原路径/18恢复ZIP保留。

实际原生复核：本源22张选定PNG/4表已实际查看，另直接查看浅深色正常菜单两原图；4条完整原录屏一秒总览15表已查看；3个原始窗口120帧/12表已查看。浅深色正常/减少动效静态菜单、第二章67%进度、目录跳转及所列手势可接受。正常显隐窗口各有一次源PTS回退，减少动效窗口仅1帧，仅接受列明画面，不推断全时序/FPS。

用户对Build27总体认可并要求继续，不推定全部手机矩阵通过。iPhone13/iOS16.6.1/TrollStore的阅读/设置帧时间、内存/功耗仍待专项；Build27标准字体打开/导入已由用户确认成功（实际来源/样例），微信QQ/Alook与TTF/OTF逐项组合、普通签名/全部File Provider/VoiceOver/系统大字/旋转/减少动效完整矩阵仍单列待核。旧章首留白/分页快照不由此追认；慢滚隐藏菜单时状态栏透字仍可见，全页安全区未验收；无Share Extension、字体删除/无限字体、可变轴、单书覆盖或M5功能。先收本片菜单/跨章进度/设置手感反馈，再按PERFORMANCE_TEST_PLAN测正文DOM采样、主线程与渲染；本片不盲改定位管线。取舍及Apple官方来源READING_CHROME_DESIGN.md。M4整体未完，取消关机继续生效。
