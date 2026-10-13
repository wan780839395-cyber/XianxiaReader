# 当前交接与恢复点

更新时间：2026-10-13（Asia/Shanghai）

## 当前断点

2026-10-13 新真机反馈：用户确认 EPUB 可以导入；图像只显示窄横条，并明确想要上下滚动时无缝跨章（不是下一章按钮）。已写入 ReaderSurface 明确完整 viewport、Readium 官方 frame/autoresizing 容器、目录/书签菜单与迟到导航过滤；恢复章内滚动的默认横向跨资源手势并明确界面标签。Build 3，新增原创图像/长短章样书、3真实页面/2导航竞态回归，待静态检查及完整CI，旧包未覆盖。真连续滚动尚未实现：3.11仅章内滚动，issue684/PR811未合并；独立 M1 引擎切片见 CONTINUOUS_SCROLL_DESIGN.md，不能将本次横向跨节写成无缝纵向。图像原因仅据源码布局合同推断，用户书CSS未提供。导入来源未细分，其他设备体验未验收；字体/主题等M4后续，不跳入M2。

构建检查点：Windows 结构/样书/41 Swift grammar 与6 tooling tests通过。首轮源码336b21a / CI38424689048：仓库/Linux/macOS Core通过，App Debug编译完成；新增测试直接引用静态ReadiumNavigator具体类型导致test bundle链接metadata失败，31 iOS tests未执行，Release/IPA未执行。原失败日志/xcresult保留在build/ci/38424689048。已改测试通过UIKit容器的公开子视图访问实际WKWebView并保留同一DOM/快照/导航检查，避免重复SDK链接；待重跑检查和完整CI。不是删除测试/关闭错误。旧Build2包未覆盖。

**M0 自动门槛通过；M1 搜索与 EPUB 导入修复已通过完整 CI，Build 2 已下载核验。完整 M1 待用户真机反馈，不进入 M2。** 当前没有运行中的项目构建/测试、未完成登录或 UAC。

用户设备 iPhone13 / iOS16.6.1 / TrollStore。用户报告旧包安装正常，但 iCloud 中选中 chinese-epub3.epub 后按“打开”无反应，阅读无法测试；此前也报告文件呈灰色。截图只证明交接阻塞，没有系统 File Provider 日志，不认定唯一根因。新包的安装/导入/阅读尚未获得用户确认。

## 已完成修复

- EPUBDocumentPicker 使用公开 UIKit `asCopy: true` 请求导入副本，`.data` 选择覆盖提供者错误/动态类型标注；后缀和实际 EPUB 内容仍由 service/Readium 校验。多选保留，TXT/其他文件明确拒绝。
- Coordinator 只接受一次终止回调，取消后的迟到文件不触发导入；sheet 关闭后交接。导入成功数量和失败信息可见，保留批次中的成功书籍。
- 两本原创 EPUB 2/3 样书打进应用，可点击“导入内置样书”走相同后台复制/Readium/数据库流程，绕过 File Provider 继续阅读验收；不据此宣布 iCloud 已修复。
- Build 2 / version0.0.1；新增 6 iOS 回归，原 20 回归与 Core 测试保留。没有更改 Readium/依赖版本、数据库 schema 或原始书籍。

文件与依据见 Documentation/IMPORT_FIX.md。TXT 只有索引协议，正文阅读/分章尚未实现；M3 完整书库、M4 字体/主题/排版/音量键、M5 长篇性能与 XBook/知识库仍按原路线执行。

## 最新验证与产物

- 源码提交 `0649833a2b48b5be3ea3ec24f8c62bd8d0dffef9`；[CI 38411028842](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38411028842) 三个 jobs 全部 success，Linux/macOS 各 14 Core、26 iOS tests、设备 Release 与 IPA 全通过。
- Windows 结构/SQL/样书/39 Swift grammar 与 6 Python tooling tests 通过；grammar 不是编译。首次误用不存在的 tooling 目录已按 scripts 目录重跑。
- `Documentation/M1_IMPORT_VALIDATION_REPORT.json`：54 构建来源文件逐一匹配已测 SHA、11 pins 不变、IPA/日志 hash、测试名字、样书打包核对。应用源码 compiler warnings=0；6 条 AppIntents metadata 提取提示单列保留，GitHub actions 的运行时弃用/runner 通知不等于源码警告。
- 最新 `build/XianxiaReader.ipa`：7,386,778 bytes，SHA-256 `fb3bf3adb825e1d40e97c962188aac238a05012ba1e36e07367d5d3eab38b181`。核验 Build 2、最低 iOS16/iPhoneOS/arm64 Mach-O/iOS platform、系统 SQLite、ZIP/Payload/0755、样书与源码一致；CODE_SIGNING_ALLOWED=NO。
- `build/XianxiaReader-iPhone13-TestKit.zip`：7,287,337 bytes，包含上述 IPA、两本 Samples 和 TESTING.txt，ZIP CRC/内部 IPA hash 已检查。
- 完整日志 `build/logs/ios-build.log`；原件、SimulatorTests/DeviceBuild xcresult、生成工程、环境/锁文件在 `build/ci/38411028842/ios/`；IPA/Core 原件在同 run 的 ipa/core 目录。

首轮导入 CI 38409222759 被 Agent 过早取消：误读网页旧片段为工程工具停滞；完整日志证实当时各 14 Core 与 26 iOS tests 已通过，实际在设备 Release 的 ReadiumShared 编译期间中断，无完整 IPA。记录 `Documentation/ValidationLogs/m1-import-cancelled.json` 与 `build/ci/38409222759/` 原日志/xcresult 保留。同提交完整重试成功，不能继续使用“应用测试未执行”的旧判断。

之前搜索包原件和测试 ZIP 在 `build/ci/38402285563/`，报告 M1_SEARCH_VALIDATION_REPORT.json；历史 M0 原件 run38390862584、报告 IOS_VALIDATION_REPORT.json。本机 Linux CORE_VALIDATION_REPORT.json 与静态 VALIDATION_REPORT.json 的 scope 独立。GitHub artifact 保留14天，build/.cache 不随 clone；过期后按锁定依赖重新 CI。

## 下一步与设备边界

1. 提供最新测试 ZIP，使用 TrollStore 正常更新，保留应用/书籍数据。
2. 先“导入内置样书”，打开阅读；再从“我的 iPhone”导入外部 EPUB；最后复测 iCloud 已下载/仅云端文件的“打开”。分别记录结果；iCloud 仍异常时可先下载到本地继续测试。
3. 按 DEVICE_ACCEPTANCE.md 核对中文页面、目录/内部链接/图片、分页/滚动/中央菜单/旋转、搜索命中定位、书签及后台/重启位置恢复。
4. 本地/iCloud/页面验收通过后才推进 M2；自动测试不能替代真机 File Provider、普通设备签名或 TrollStore 阅读验收。

## 环境与恢复纪律

Windows11 / PowerShell7.6.5 / Git2.54 / Python3.11，无本机 Xcode/Swift；CI Xcode16.4 / Swift6.1.2 / iOS18.5 simulator，Swift5 targeted 模式。Docker Desktop4.95.0.242831 / engine29.8.2 已恢复，保留用户原容器/socket备份，不 reset/prune。

私有仓库 https://github.com/wan780839395-cyber/XianxiaReader ，main 跟踪 origin/main，CLI 已授权，路径 `.cache/tools/github-cli.json`；不输出令牌/重新生成设备码。根 Package.resolved 来自真实 CI，Readium exact3.11.0，共11 pins，复制到生成 workspace 且严格 resolve/test/build。

先读 AGENTS → PROJECT_STATUS → HANDOFF → ROADMAP/ARCHITECTURE；核对实际 Git、进程、完整日志与 hash，更新每个可恢复点。project.yml 是工程源；禁止 localhost HTTP 主要预览。网页局部日志不能证明编译停滞。文档收尾提交仅更新证据，用 skip-ci；后续代码变更必须完整 CI。

历史过程见 HANDOFF_HISTORY_2026-10-13.md、HANDOFF_M1_SEARCH_HISTORY_2026-10-13.md、HANDOFF_M1_IMPORT_HISTORY_2026-10-13.md；历史“运行中”不覆盖本文件。
