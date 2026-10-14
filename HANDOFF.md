# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 先核对这个实际断点

当前候选分支codex/m1-continuous-recovery，实际Git ref=2590801d2d60314728ab8f9062dc33b5e661a4c1。
正在验证的CI：38528382505，源码2590801d2d60314728ab8f9062dc33b5e661a4c1，resolve_local_readium=false，预期41项iOS；恢复先查该run，禁止重复启动/假定通过。

最新已经执行的CI为38526015806，源码93ef44fbd12ca85d03ad57acda5db955d6a35c93：Linux/macOS各14 Core，iOS 38/41通过、3 failed、0 skipped；设备Release/IPA未执行。失败详情：
- failed - Continuous reader did not reach expected state at jump(_:book:href:):237 (testContinuousFragmentAndDOMBookmarkRestore())
- failed - Continuous reader did not reach expected state at jump(_:book:href:):237 (testContinuousLayoutFailureShowsRetryAndRecoversTheAnchor())
- failed - Continuous reader did not reach expected state at jump(_:book:href:):237 (testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge())

本地仍为main/HEAD6d761749911233122bcd031fcf718d22a19f9e77，原index为空，原未提交改动全部保留；通过独立临时index创建候选快照，没有reset/stash/删库/改原书。原370文件备份.cache/recovery/20261014-092934已核验所有SHA/ZIP CRC；各次原始交接和检查点保存在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。旧candidate.json/documentation-snapshot.json不是最新Git状态。

## 当前源码与待验证内容

Atomic Readium target command plus scroll coordinate read in one JS callback。该候选通过Windows362文件grammar（pristine54限制/新增0）与14 tooling；当前新候选尚未Swift编译，最后已编译版本见上方真实CI。

原生bootstrap已能在抑制spreadLoaded rAF后取得首次位置，当前阻塞转移为章节已显示one.xhtml但位置仍cover.xhtml。新诊断仅记录当前index/revision/ready/positioning/wrapper/frame以及documentY-offset-localTop，不输出正文；需读取失败附件/完整日志确认何处拒绝，不把推测写成根因。

已加候选行为：完整初始化等待；原生didFinish直接WK探针启动同一CSS/初始定位/decoration管线（不再通过会等待spreadLoaded的包装器）；单次启动避免native/JS重复完成互相取消。clear取消bootstrap/load task、断开UI/WebKit delegate并释放两条加载等待链；清理后脚本拒绝执行、后到加载等待立即结束。positioning期间不捕获位置/做anchor补偿；cache使用实际localTop，DOM/UI origin不一致拒绝；mode/reload revision与view identity过滤迟到计算，nil不覆盖可靠位置。

41条回归保持（原31+连续8+旧termination1+rAF桥1），charOffset>100、重开3px、双章/逆向/高度/重试断言均未降低。长段最近几轮未到字符断言，不能宣称字符修复通过。

## 架构和范围

Vendor/ReadiumToolkit为官方3.11.0/d82f44f4f05d87add9e22a8b75abbd61dce745dd本地维护扩展，保留BSD许可/PR811参考/逐文件来源和hash；不是官方合并功能，不修改SourcePackages缓存。最多12资源，固定WK viewport、实际DOM章节高度、前后回收/加载边界/重试。保留标准href/CSS/text/progression并附加DOMRange字符/版本1视口偏移/64字符上下文；搜索保持原Readium文本定位。UI经ReadingInterfaces，Core仅Foundation/SQLite；fixed/RTL/竖排保留分页。

Package.resolved来自真实解析38496501326，6远程pins版本/revision未变；bootstrap=false，resolve/test/build严格锁定。

## 证据和旧产物

完整原始日志、summary、xcresult与附件在build/ci/各实际run/artifacts/XianxiaReader-build-diagnostics/build；最新38526015806日志已下载。Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json记录433候选Git blob SHA与最后真实测试；M1_CONTINUOUS_STATIC_REPORT.json仅静态，各失败原文见ValidationLogs。

build/XianxiaReader.ipa仍是Build3，7393693 bytes，SHA256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2；原件build/ci/38434939423/ipa，旧测试ZIP/Build2/3全部保留。没有新成功Build4包。普通设备签名、iPhone13/iOS16.6.1/TrollStore、原书图像/位置、原生手动拖动惯性、峰值内存及完整模拟器阅读均未验收；旧双章原创截图复查不能代替以上门槛。

## 下一步

CI38528382505/2590801已完成：40/41通过，0 skipped；章节fragment/重试/rAF桥/边界/模式均通过。只剩长段344：outer3119/local2367/DOMscrollY2367，实时caret499/506/513，但第一次候选仍是滚动前documentY1769.875、offset2.875、savedTop1767，一致性检查正确拒绝后没有再次采样。当前把Locator/documentY/documentTop放在同一JS快照，DOM尚未跟上原生视口时最多3次32ms重采样；epoch/revision/localTop/关闭取消仍核对，不无限轮询，不降低字符/3px断言。静态核验后完整41-test CI，补充尚未编译。

1. 先核对上方正在运行的CI实际状态/head/完整日志/xcresult，不重跑旧候选。读取数字诊断解决正确章节位置发布，再验证长段字符与完整41项；失败禁止Release/IPA。
2. 全套Core/iOS成功后设备Release CODE_SIGNING_ALLOWED=NO，下载核验CRC/arm64/系统SQLite/0755/最低iOS16/许可，保留旧Build3再提供Build4测试包。
3. 用户设备正常更新保留数据，不卸载/删库；原书、拖动惯性、普通设备/TrollStore分别验收。完整M1未放行，不进入M2/M4；TXT、完整书库、字体主题/音量键、百万字性能/XBook知识库均未实现。
4. 每个可恢复步骤和构建前更新本文件，阶段结束同步PROJECT_STATUS/设计/FILE_INVENTORY；不将未编译代码写成已通过。

## 环境与公开

用户已授权GitHub仓库公开，API PUBLIC；标准Ubuntu/macOS runner正常启动，旧38508277189账单拒绝是历史，没有修改付款/支出限额。公开审计原27 commits/718 blobs/64 logs及四本原创样书无待处理发现，模式扫描有范围限制；后续来源/日志也复核。Windows/PowerShell/Git/Python可用，无本机Xcode；未启动/重置Docker或localhost，其他项目进程保留。GitHub artifacts保留14天，build/.cache不随clone。
