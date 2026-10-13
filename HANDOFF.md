# 当前交接与恢复点

更新时间：2026-10-13（Asia/Shanghai）

## 当前断点

2026-10-13 真机反馈：iPhone13 / iOS16.6.1 / TrollStore 安装正常；EPUB 在 iCloud 文件选择器中可选，点击“打开”无反应（用户截图），此前也反馈文件呈灰色。已写入明确 UIKit 导入副本模式、宽文件过滤/严格格式校验、一次 delegate 回调、导入完成反馈和原创内置样书；Build 2，新增 6 iOS 回归。Windows 结构/39 Swift grammar 与 6 Python tooling tests 已通过（首次误用不存在的 tooling 目录，已按实际 scripts 目录重跑成功），下一步提交并运行完整 CI。详见 IMPORT_FIX.md。真实 iCloud 修复仍需用户复测；TXT 尚未实现，不提前进入 M2。

**M0 已通过；M1 搜索切片已通过真实 CI，完整 M1 仍待页面/设备验收。** 当前没有运行中的项目构建/测试，没有未完成登录/UAC。不要大规模进入 M2。

最新已验证代码：`b95aa4d117984ddb85e81b1901b82e42d453758b`；成功 [CI 38402285563](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38402285563)。仓库检查、Linux/macOS Core 各 14 tests、20 iOS tests、设备 Release 与 IPA 全通过；应用源码编译 warning 为 0。原 Binding Sendable 警告及新增冗余类型转换警告均已清理，没有关闭检查、删除测试或改变依赖版本。

## 用户设备与下一步

用户确认：**iPhone 13 / iOS 16.6.1 / 已安装 TrollStore（巨魔）**。这不代表应用安装或阅读已通过。无需再询问型号/安装方式。

1. 用户安装最新已验证 IPA，按 `Documentation/DEVICE_ACCEPTANCE.md` 测试。已提供含 IPA、两本原创 EPUB、TESTING.txt 的真机测试 ZIP。
2. 收到安装/阅读反馈后按具体问题修复。优先核对搜索命中定位、目录/内部链接/图片、菜单/分页/滚动/旋转、书签与后台/重启位置恢复；不能用 Navigator 构造或模拟器 XCTest 代替页面验收。
3. iCloud/File Provider 导入、异常/DRM 反馈与真实长篇阅读还待 M1 验收。M2 TXT、M3 完整书库、M4 排版主题字体/音量键、M5 性能均未进入。

## 当前产物与验证

- 最新 IPA：`build/XianxiaReader.ipa`，7,365,913 bytes；SHA-256 `9673200a941600e2224870da6d006fa35679abc98a166887d5f4bb1151fd2365`。核验 iPhoneOS/最低 iOS16/arm64 Mach-O/iOS platform、ZIP/Payload/0755；CODE_SIGNING_ALLOWED=NO，仍需实际 TrollStore 安装。
- 真机测试 ZIP：`build/XianxiaReader-iPhone13-TestKit.zip`，7,266,207 bytes，包含已核验 IPA、Samples/chinese-epub2.epub、chinese-epub3.epub 与操作说明。ZIP CRC 与内部 IPA hash 已核对。
- 完整日志：`build/logs/ios-build.log`；原件、SimulatorTests/DeviceBuild `.xcresult`、生成工程和环境在 `build/ci/38402285563/ios/`。
- `Documentation/M1_SEARCH_VALIDATION_REPORT.json`：最新 CI、20 测试名字、52 构建来源文件 hash、IPA/日志 hash、compiler warnings 与验收范围。
- `Documentation/IOS_VALIDATION_REPORT.json`：历史 M0 提交 184aa09 / run38390862584；不是当前 M1 来源。M0 包原件 `build/ci/38390862584/ipa/XianxiaReader.ipa` 与日志保留。
- 首轮已通过的 M1 搜索包在 `build/ci/38399996364/ipa/`，报告另存 `Documentation/ValidationLogs/m1-search-first-pass.json`，当时有冗余 cast 警告。
- `CORE_VALIDATION_REPORT.json` 为本机 Linux Core，`VALIDATION_REPORT.json` 为静态检查；不能混用 scope 的布尔字段。`FILE_INVENTORY.json` 记录维护文件 hash。

GitHub artifacts 保留 14 天，忽略的 build/.cache 不随 clone。新机器先核对 artifact 是否有效，必要时使用已锁依赖重新 workflow_dispatch；不要把旧 IPA hash 赋给新包。

## 本轮源码与限制

ReadingInterfaces 的可选 ReaderSearchProviding/ReaderSearchSession 与 Sendable DTO 隔离 Readium。ReadiumAdapter 注册 SearchService factory，按 TextContentElement 使用同一 String 的原生索引匹配，避开锁定 3.11 默认服务的组合字形窗口缺陷（上游 issue876）。正文解析/DOM/reading order 由 Readium 提供。

每批 40、上下文各最多 64 字符；UI 最多 1000 条并提示更具体关键词，显式加载更多。改词/停止/关闭取消任务/session，request ID 拒绝迟到数据；并发 next 被拒绝。搜索位置经原有 ReaderEngine.go 委托。11 新搜索回归 + 原 9 iOS 回归全部保留并通过。

搜索不跨文本元素/资源，不支持 regex/模糊匹配；Readium 内部仍一次解析整个 XHTML，大单章内存/取消延迟尚未测量。详见 SEARCH_DESIGN.md 和 M1_SEARCH_ACCEPTANCE.md。未来知识库搜索必须另行受 canonical chapter 范围限制，不能直接复用全文正文搜索来读取未来增强事实。

## 环境与 Git

- 工作区 `D:\ai项目\XianxiaReader`，Windows 11 / PowerShell7.6.5 / Git2.54 / Python3.11，无本机 Xcode/Swift。CI Xcode16.4 / Swift6.1.2 / iOS18.5 simulator，Swift5 targeted 模式；通过不代表 Swift6 strict 已验收。
- Docker Desktop4.95.0.242831 / engine29.8.2 已恢复；保留用户原有容器和 socket 备份，不 reset/prune。Core 容器脚本只验证 Linux 分支。
- 私有仓库 https://github.com/wan780839395-cyber/XianxiaReader ，main 跟踪 origin/main，CLI 已授权。路径 `.cache/tools/github-cli.json`；不输出令牌，不重复生成设备码。
- Readium exact3.11.0 和 11 个实际解析 pins 不变，根 Package.resolved 复制到生成 workspace，resolve/test/build 严格使用锁文件。
- 文档收尾提交仅包含文档/证据，代码来源逐文件匹配上述成功 SHA；用 skip-ci 避免重建未变代码，后续代码修改必须完整 CI。

## 恢复纪律

先 AGENTS → PROJECT_STATUS → HANDOFF → ROADMAP/ARCHITECTURE，核对 Git、进程、CI 和日志 hash。保留原始书籍、失败证据与已完成功能；每个可恢复步骤及长测试前更新本文件。禁止以 localhost HTTP server 为主要预览。

M0 早期过程归档 `HANDOFF_HISTORY_2026-10-13.md`；本轮 M1 恢复/CI 过程归档 `HANDOFF_M1_SEARCH_HISTORY_2026-10-13.md`。历史里的“准备/运行中”不覆盖当前结论。
