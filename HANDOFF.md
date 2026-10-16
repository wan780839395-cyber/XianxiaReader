# 当前交接与恢复点

2026-10-16（Asia/Shanghai）

## 当前实际结果

Build20即时整屏翻屏画面保护通过[完整CI38850709820](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38850709820)，实际编译源`0b1fe87704713e668231ad36ab73ceb13bd3b077`。Linux/macOS各122Core、iOS108/108（95集成+13真正UI）、失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release20/min16，三份六pins锁、504源blob及每平台四长TXT Release探针已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不等于编译。

沿Readium3.11现有issue737/PR763方案，仅给上下整屏的显式无动画翻屏保留一个原生视口画面200ms；底层位置立即更新，无新增位移/淡入，视觉等待有限且需手机验证。新拖动立即接管，模式/resize/跳转/关闭清理，保留期间拒绝新显式命令且不排队；无每帧截图/PNG编码/新正文缓存，原直接手势、连续模式、DOM/完整Locator与依赖锁保持。新增真实容器清理/重入与真正UI重复反向录屏，26个受改文件内原测试主体保持。设计READING_SCREEN_STABILITY_DESIGN.md，候选特色READING_FEATURE_IDEAS.md。

安装`build/XianxiaReader-ScreenStability-Build20.ipa` / SHA256 `ae6897c0e2e0387b1550fce67570d9bcbd57a7eb09f5d1330007f8baa080cf27`；原创样书测试包`build/XianxiaReader-ScreenStability-Build20-TestKit.zip` / SHA256 `2e9381d77aca6c1762dab1f14d002bcae538333d84e02d04a37c692701120319`。正常覆盖更新保留书库，+菜单确认0.0.1 (20)；原33包与两新包/原创样书/Preview/ZIP内部IPA均核。原Build19问题证据不追认，详情M4_SCREEN_STABILITY_VALIDATION_REPORT.json与m4-screen-build20-native-review.json。

本轮44张原生PNG均已看，43张含非透明像素；整屏即时命令整窗、跨章整窗、普通/额外减少动效拖动后和重开均有正文。当前巨段TXT深色孤立图满屏文字；不追认旧留白成因或全部真机样书。分页孤立WKWebView PNG仍RGBA全0，另有完整EPUB整窗正文；旧Build15–19图片名来自本轮实际CI，不追认历史失败。

两段实际UI视频全时段1秒总览已看：新增即时正反39.76秒、原整屏双模式81.30秒。其余6阅读/5书库视频只保留，未宣称全13段逐段复核。新即时视频31.5–38.8秒保留的36原始VFR帧已看，可见3/4段与6/7段六次交替，最后回到原处，保护画面未一直盖住正文。旧整屏视频所选两个PTS区间另有99和15原帧，99中前52为可见位移正反翻屏、后47为设置弹层；15为另一组即时正反。共150原帧全部看，其中103为阅读翻屏正文，未见全空正文帧；无fps重采样/插帧。墨迹计数只定位人工检查，不单独当验收。

旧整屏视频的所选原始PTS在设置弹层前有回退，已在frames.json记录；不将PTS直接映射XCTest/真实墙钟，也不将这些原帧数量当手机FPS。200ms是源码保留上限意图，实际切换观感/响应需真机。本轮覆盖动作未复现Build19记录中的整段空白，属于上游原生保护思路下的局部改进，不声明WebKit根因修复、所有翻屏无空帧或完整设备通过。2次XCTest idle通知、系统RunningBoard/AppIntents诊断保留，画面保护warning为0，源编译warning/error另核0。

真实系统Reduce Motion、深色整屏过渡、VoiceOver/增强对比度/旋转、普通签名/TrollStore、手机等待感/触摸接管/FPS/耗电仍未验收。M4整体未完成。

普通签名/TrollStore、手机响应/FPS/耗电与真实系统Reduce Motion/可访问性/旋转继续单列。自动慢滚、回看返回、续读提示、字体导入等仍后续；人物/境界卡留M5查询层章节门槛。M4整体未完。

## 保存与后续

原HEAD6d761749/空index/M2 e6f31d85/M3 44af41f0保持，私有index维护codex/m4-reading-appearance；编译源与后续纯文档tip分列。原824开始路径仍在，504编译源blob、837维护文件清单、33旧包和两新包、十份备份均已逐hash/CRC核过；最终纯文档tip/远端/树一致性核验见build/ci/38850709820/final-preservation-check.json。Build19交付与本轮发展交接分别归档HANDOFF_M4_BUILD19_DELIVERY_2026-10-16.md、HANDOFF_M4_SCREEN_STABILITY_DEVELOPMENT_2026-10-16.md。

恢复先AGENTS→状态→交接→路线→架构，再核实际Git/文件/hash/完整日志/运行任务，保留未提交改动。手机优先核减少动效下快速正反按钮/正文点按、手指接管、关闭/重开和跨章；200ms视觉等待是否舒适未验收。核实反馈后按独立M4切片推进自动慢滚，先读READING_AUTOSCROLL_DRAFT.md；特色取舍READING_FEATURE_IDEAS.md。M4整体未完，不提前进入M5、不沿用旧关机请求。CI/下载/检查均已结束，无本轮遗留后台任务。
