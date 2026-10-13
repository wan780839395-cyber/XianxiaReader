# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 当前断点

2026-10-14 01:00后续断点：CI38430692977 failure，31 tests中导航/菜单已通过，图像框830.3 > 正文812点使原上限断言失败；Release/IPA未执行。完整日志/xcresult已下载，旧Build2未覆盖。新增ReadiumViewportScript经公开setupUserScripts校准现有媒体保护到innerHeight95%，横排重排限定，固定/竖排不改；测试断言全部保留、增加尺寸附件。CI失败也导出附件再返回原test exit，任何test/export失败都不构建IPA。新记录ValidationLogs/m1-reader-media-failure.json。42 Swift grammar、9 Python/tooling及bash -n已通过，之后完整CI；后面的上一轮运行中描述为已结束的历史，收尾须替换。

已保留全部 M1 导入、阅读视口、目录/书签导航和测试改动。源码提交 `722127447057ef4555832d3950d98a2cb80114fd` 已推送 main。

[CI 38430692977](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38430692977)：仓库检查与 Linux Core 14 tests 通过；macOS runner 已分配，iOS job 正在执行完整流程。尚未获得最终测试/Release/IPA 结果。Windows 无遗留构建/测试进程，无未完成登录或 UAC。

本机最新成功产物仍是 **Build 2**，不能把它当成 Build 3。尚未覆盖 `build/XianxiaReader.ipa` 或测试 ZIP。

恢复后先用 `.cache/tools/github-cli.json` 中的 executable 查询上述 run；等 job 完成后下载完整 diagnostics/Core/IPA。网页可见日志尾部可能陈旧，不能据此取消构建。不要另起重复构建或重新登录。

## 用户反馈与实现范围

- 测试设备 iPhone13 / iOS16.6.1 / TrollStore；此前安装正常，iCloud 导入选择/打开阻塞。
- 导入修复后用户已确认 EPUB 可以导入，文件来源未细分；图片在阅读页面仅显示窄横条。
- 用户明确要求上下滑动无缝跨章，参考微信读书；不是增加下一章按钮。**真正纵向连续跨章尚未实现。** 独立 M1 引擎切片及有限资源窗口/定位要求见 `Documentation/CONTINUOUS_SCROLL_DESIGN.md`。
- Build 3：ReaderSurface 显式完整 viewport；Adapter 采用官方 frame/autoresizing 容器；目录/书签成功跳转收起菜单并过滤旧请求；恢复默认滚动时横向跨资源通路，界面明确“章内上下滚动”。不修改用户 EPUB/CSS、依赖版本或数据库。
- 原创 reader-layout.epub 有高纵横比封面上下标记和长短章；新增3实际窗口/DOM/快照测试、2导航生命周期回归。原26 iOS、Core及搜索80命中回归保留。
- 用户原书/CSS未取得，不认定唯一图像裁切原因；原创样书通过也不代表原书设备验收。

## 本轮失败与修正

1. CI38424689048 / 336b21a：App Debug编译完成，新增测试直接引用静态 ReadiumNavigator 的具体类型导致 test bundle metadata 链接失败。31 tests、Release/IPA未执行；改用公开 UIKit/WebKit 查看现有实例，未删除断言或重复链接 SDK。
2. CI38426725252 / 43d4b37：31 iOS执行，30通过/1等待one.xhtml超时；图片几何/菜单viewport通过。Release/IPA未执行。原探针仅检查纵向交集，横向移出屏幕的预加载页面可能被误认；DOM完成也不保证原生位置就绪。
3. 7221274：探针同时核对可视宽度/高度、DOM readiness及对应原生Locator；超时保留最后DOM/Locator。所有尺寸、图像、导航和生命周期断言不变。完整CI正在验证，具体失败原因不能仅凭推断标为已修复。

失败记录分别在 `Documentation/ValidationLogs/m1-reader-link-failure.json`、`m1-reader-navigation-failure.json`；原完整日志/生成工程/xcresult 在 `build/ci/38424689048/` 和 `build/ci/38426725252/`。过程检查点归档 `HANDOFF_M1_READER_HISTORY_2026-10-14.md`，历史“运行中”不覆盖本文件。

## 已通过的独立证据与旧包

- Windows 结构/SQL/三本EPUB/41 Swift grammar与6 Python tooling tests通过；grammar不是编译。
- 最新完整成功CI38411028842 / 0649833a2b48b5be3ea3ec24f8c62bd8d0dffef9：Linux/macOS各14 Core、26 iOS tests、Release和Build2 IPA；应用源码 compiler warnings=0，另有6 AppIntents metadata提示。
- Build2原件 `build/ci/38411028842/ipa/XianxiaReader.ipa`：7,386,778 bytes，SHA-256 `fb3bf3adb825e1d40e97c962188aac238a05012ba1e36e07367d5d3eab38b181`。旧测试ZIP也在此run目录备份。
- `M1_IMPORT_VALIDATION_REPORT.json` 的54来源hash属于Build2；`M1_SEARCH_VALIDATION_REPORT.json` 属于之前搜索、`IOS_VALIDATION_REPORT.json` 属于M0、`CORE_VALIDATION_REPORT.json`属于本机Linux、`VALIDATION_REPORT.json`仅静态。保留原报告，不混合覆盖。
- 更早CI38409222759由Agent误读网页旧片段而提前取消，实际26 iOS已通过、Release中断；原记录保留，不能写成源码失败或测试未执行。

## 本轮下一可恢复步骤

1. CI完成后下载实际日志、xcresult、ReaderSnapshots、IPA，确认31 tests与设备Release；失败则继续修具体问题，不降低断言。
2. 用 `.cache/diagnostics/inspect_ci_ipa.py` 核对 ZIP/Info/arm64/iOS/系统SQLite/权限；`.cache/diagnostics/record_reader_ci.py <runID> 31`核对来源hash/锁文件并生成独立阅读报告。查看分页/滚动的实际图像快照，再记录人工复查边界。
3. 核验后才替换最新IPA/完整日志，运行 `.cache/diagnostics/make_reader_testkit.py <runID>`生成Build3测试ZIP，原包留在原run目录。
4. 更新PROJECT_STATUS/README/ROADMAP/FEATURE_MATRIX/VALIDATION/DEVICE_ACCEPTANCE及文件hash快照；文档收尾提交用skip-ci，后续源码变更须完整CI。
5. 用户原书图片复测与真正纵向连续跨章仍属于M1。M1完整门槛未放行，不大规模进入M2/M4。

## 环境与恢复纪律

Windows11 / PowerShell7.6.5 / Git2.54 / Python3.11，本机无Xcode/Swift。CI macOS15 / Xcode16.4 / Swift6.1.2 / iOS18.5 simulator，设备最低iOS16。Docker Desktop4.95.0.242831 / engine29.8.2已恢复，不reset/prune用户工具。

私有仓库 https://github.com/wan780839395-cyber/XianxiaReader ，main跟踪origin/main，CLI已授权，不输出令牌/重新生成设备码。Readium exact3.11.0、11 pins来自真实CI；root锁文件复制到生成workspace并严格resolve/test/build。PR811只在忽略cache做apply --check（通过），未应用或执行，正式依赖未改。

先读PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE并核对实际Git/进程/完整日志；每个可恢复子步骤和长构建前更新本文件。project.yml是工程源；禁止localhost HTTP主要预览。自动/模拟器视觉/普通设备/TrollStore验收分别记录；TXT、完整书库、字体/主题/音量键、性能及XBook知识库仍按原路线。
