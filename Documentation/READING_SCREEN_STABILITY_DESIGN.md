# 整屏即时翻屏的画面保护

2026-10-16，Build20完整自动门槛及选定原生动作复核完成，手机矩阵仍单列。实际断点见HANDOFF.md。

Build19的完整自动门槛已过，但整屏UI原始MP4中42.073333秒有一张正文空白帧，42.228333秒恢复。此次直接解码原始VFR帧、保留PTS，没有fps重采样或插帧；因此旧20fps联系图的连续空帧包含重复保持，不能据其数量当手机帧率。它仍是实际记录中的空白，不能以采集原因直接豁免。

## 成熟方案与适用差异

[Readium issue737](https://github.com/readium/swift-toolkit/issues/737)讨论了原生无动画移动WKWebView或父UIScrollView时的闪白；同资源JS路径与跨资源原生路径的取舍不同。[PR763](https://github.com/readium/swift-toolkit/pull/763)采用临时原生snapshot保护跨资源过渡。项目锁定Readium3.11.0/revision d82f44f4的本地`Toolkit/PaginationView.swift`已经包含该方案，非动画分支保留100ms；不升级依赖、不复制新的外部代码。

[Apple公开snapshotView(afterScreenUpdates:)](https://developer.apple.com/documentation/uikit/uiview/snapshotview(afterscreenupdates:))的实际DocC JSON已核iOS7起可用，项目最低iOS16适用；回执m4-screen-build20-api-scope-review.json。

该issue最初报告Readium3.7/iOS26.3，本轮原始素材来自3.11本地连续扩展/iOS18.5模拟器，不能据类似症状宣布同一WebKit根因。当前连续容器会同时移动外层位置、固定视口和内层WebKit offset，直接把上游章内横向JS翻页换入不能覆盖这个合同。选择先做局部原生保护，并用完整新录屏比较。

## 本轮最小改动

只在上下整屏的显式无动画命令（用户/系统减少动效）前，使用公开UIView.snapshotView保留一个当前正文视口；作为同一父视图内的临时兄弟视图，避免跟随正文滚动。底层真实内容位置立即改变，200ms后静止切到新画面，无位移/缩放/淡入，增加有限的视觉等待，不把它称为零延迟。200ms为待原生素材核验的候选值，不是设备已优化结论。

保护视图不接收触摸、不进入可访问性树；同一时刻最多一张，不编码PNG、不保存图片、不缓存全书，也不在拖动帧循环中执行截图。保留期间拒绝新的显式整屏命令，不排队。新拖动立即取消保护，让直接操作接管；切模式、resize、显式跳转、重载、关闭也取消任务并移除视图。200ms任务在await后核请求ID，旧任务不能移除新保护。截图不可用时留warning并保持原导航，不能悄悄声称已保护。

普通有动画翻屏、直接手势/减速、连续模式、原DOM/Locator和章节窗口保持。单帧保护只为遮住原生过渡的未绘制间隙，不替代Readium排版或位置计算。性能成本及是否彻底消除空白须实物验证。

## 验证计划（开发时检查点，实际结果见文末）

新增真实容器回归：立即更新底层位置、最多一个保护/拒绝重入、触摸接管、模式/跳转/关闭清理、定时结束及迟到任务不复活。新增真正UI重复正反翻屏录屏，保留原普通/额外减少动效UI测试全部断言。预期各122Core/iOS108（95集成+13UI）/严格无签名Release20，不能在结果前填通过。

本轮新录屏必须直接核原始帧PTS与重复反向窗口；即使未发现空帧，也只对本轮覆盖动作成立，不能替代普通设备/TrollStore/手机FPS/真实系统Reduce Motion矩阵。若仍空白，保留失败并重新比较公开方案，不连续盲调200ms数字。

## 最终实际结果

Build20即时整屏翻屏画面保护通过[完整CI38850709820](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38850709820)，实际编译源`0b1fe87704713e668231ad36ab73ceb13bd3b077`。Linux/macOS各122Core、iOS108/108（95集成+13真正UI）、失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release20/min16，三份六pins锁、504源blob及每平台四长TXT Release探针已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不等于编译。

沿Readium3.11现有issue737/PR763方案，仅给上下整屏的显式无动画翻屏保留一个原生视口画面200ms；底层位置立即更新，无新增位移/淡入，视觉等待有限且需手机验证。新拖动立即接管，模式/resize/跳转/关闭清理，保留期间拒绝新显式命令且不排队；无每帧截图/PNG编码/新正文缓存，原直接手势、连续模式、DOM/完整Locator与依赖锁保持。新增真实容器清理/重入与真正UI重复反向录屏，26个受改文件内原测试主体保持。设计READING_SCREEN_STABILITY_DESIGN.md，候选特色READING_FEATURE_IDEAS.md。

安装`build/XianxiaReader-ScreenStability-Build20.ipa` / SHA256 `ae6897c0e2e0387b1550fce67570d9bcbd57a7eb09f5d1330007f8baa080cf27`；原创样书测试包`build/XianxiaReader-ScreenStability-Build20-TestKit.zip` / SHA256 `2e9381d77aca6c1762dab1f14d002bcae538333d84e02d04a37c692701120319`。正常覆盖更新保留书库，+菜单确认0.0.1 (20)；原33包与两新包/原创样书/Preview/ZIP内部IPA均核。原Build19问题证据不追认，详情M4_SCREEN_STABILITY_VALIDATION_REPORT.json与m4-screen-build20-native-review.json。

本轮44张原生PNG均已看，43张含非透明像素；整屏即时命令整窗、跨章整窗、普通/额外减少动效拖动后和重开均有正文。当前巨段TXT深色孤立图满屏文字；不追认旧留白成因或全部真机样书。分页孤立WKWebView PNG仍RGBA全0，另有完整EPUB整窗正文；旧Build15–19图片名来自本轮实际CI，不追认历史失败。

两段实际UI视频全时段1秒总览已看：新增即时正反39.76秒、原整屏双模式81.30秒。其余6阅读/5书库视频只保留，未宣称全13段逐段复核。新即时视频31.5–38.8秒保留的36原始VFR帧已看，可见3/4段与6/7段六次交替，最后回到原处，保护画面未一直盖住正文。旧整屏视频所选两个PTS区间另有99和15原帧，99中前52为可见位移正反翻屏、后47为设置弹层；15为另一组即时正反。共150原帧全部看，其中103为阅读翻屏正文，未见全空正文帧；无fps重采样/插帧。墨迹计数只定位人工检查，不单独当验收。

旧整屏视频的所选原始PTS在设置弹层前有回退，已在frames.json记录；不将PTS直接映射XCTest/真实墙钟，也不将这些原帧数量当手机FPS。200ms是源码保留上限意图，实际切换观感/响应需真机。本轮覆盖动作未复现Build19记录中的整段空白，属于上游原生保护思路下的局部改进，不声明WebKit根因修复、所有翻屏无空帧或完整设备通过。2次XCTest idle通知、系统RunningBoard/AppIntents诊断保留，画面保护warning为0，源编译warning/error另核0。

真实系统Reduce Motion、深色整屏过渡、VoiceOver/增强对比度/旋转、普通签名/TrollStore、手机等待感/触摸接管/FPS/耗电仍未验收。M4整体未完成。

普通签名/TrollStore、手机响应/FPS/耗电与真实系统Reduce Motion/可访问性/旋转继续单列。自动慢滚、回看返回、续读提示、字体导入等仍后续；人物/境界卡留M5查询层章节门槛。M4整体未完。
