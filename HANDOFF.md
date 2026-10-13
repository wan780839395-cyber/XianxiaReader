# 当前交接与恢复点

更新时间：2026-10-13（Asia/Shanghai）

## 当前断点

**M0 自动构建/测试/打包门槛已通过，下一阶段为 M1。** 尚未进行中文排版、真实点击/链接/滚动、iCloud 导入或真机/TrollStore 安装验收。当前没有运行中的项目测试或 CI，没有未完成登录/UAC。

已验证提交：`184aa09355ed0f44e9e27763c5d44fa0a8161434`。成功 run：[38390862584](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38390862584)。仓库检查、Linux Core、macOS/iOS job 均 success；14 Linux + 14 macOS Core XCTest、9 iOS XCTest 全通过，设备 Release 构建成功，CODE_SIGNING_ALLOWED=NO。

## 必须先核对的证据

- `Documentation/IOS_VALIDATION_REPORT.json`：真实 CI、环境、测试、45 个构建来源文件 hash、依赖锁、完整日志 hash 与 IPA 检查。
- `Documentation/CORE_VALIDATION_REPORT.json`：独立本机 Linux Core 编译/14 tests；字段不代表 iOS 检查。
- `Documentation/VALIDATION_REPORT.json`：Windows 静态检查，明确不执行 Swift 编译。
- `Documentation/FILE_INVENTORY.json`：维护文件恢复清单，不包含忽略的缓存/build。
- `Documentation/M0_ACCEPTANCE.md`：阶段门槛、产物与尚未验收内容。

最新 IPA：`build/XianxiaReader.ipa`，7,286,692 bytes，SHA-256 `847e61e3bb2de8227df59860fae86b561ebf4f839a3202fcd579098899e88d99`。ZIP 完整性、Payload、iPhoneOS、最低 iOS 16、arm64 Mach-O/iOS 平台和 executable 0755 均已检查；SQLite 实际链接 `/usr/lib/libsqlite3.dylib`。不是普通设备签名包，不代表已在 TrollStore 安装。

完整构建日志：`build/logs/ios-build.log`；下载原件及 SimulatorTests/DeviceBuild `.xcresult`、生成工程、实际 Package.resolved 在 `build/ci/38390862584/ios/`。GitHub IPA/诊断 artifact 保留 14 天，忽略目录不随 Git clone；换机器时先核对 artifacts 是否有效，必要时按已锁版本重新 workflow_dispatch。

## 环境与 Git

- 工作区 `D:\ai项目\XianxiaReader`；Windows 11、PowerShell 7.6.5、Git 2.54.0、Python 3.11；没有本机 Xcode/Swift。
- 本机 Docker Desktop 4.95.0.242831、engine 29.8.2 正常；用户原有 glm2api/zai2api 停止容器保留。不要重做 socket 修复或 reset。详情见 DOCKER_RECOVERY.md。
- 私有仓库 https://github.com/wan780839395-cyber/XianxiaReader ，origin/main 已建立并正常推送。CLI 已认证；无需再登录、询问可见性或推送许可。便携 gh 路径在忽略的 `.cache/tools/github-cli.json`，可用系统 gh 替代。
- Git 作者仅在此仓库使用已确认 login 与 ID-based noreply。不要输出令牌/设备码或提交个人小说。

## 本轮真实修复

1. 第一轮 CI 误用宿主 Homebrew SQLite：Core 去除 pkg-config/Homebrew provider，通过目标 SDK 头文件和库链接；数据库与全部测试保留。
2. 首次真实解析的 11 个依赖纳入根 Package.resolved。生成工程后复制到 workspace，resolve/test/build 全部严格锁定版本。
3. 第二轮缺少 AppIcon：新增原创 SVG、1024 RGB PNG、appiconset、工程设置与静态资源校验；第三轮完整 CI 已通过。

失败 run/log 位置与原始错误见 CI_FAILURES.md。早期 Docker、GitHub 授权和恢复过程完整归档于 `Documentation/HANDOFF_HISTORY_2026-10-13.md`；该文档是历史，不覆盖此处当前状态。

## 下一步：M1 基础 EPUB

1. 处理真实编译警告：ReaderView 的 Binding(set: model.setScrolling) 转换为 Sendable closure，先明确 MainActor 边界，不能禁用检查或使用无依据 unchecked Sendable。完整 CI 后记录结果。
2. 通过引擎协议增量接入 Readium search service，加入可取消搜索/结果跳转测试，不在 UI 读取全书。
3. 真实阅读验收 EPUB 2/3、图片/CSS/fragment 链接、目录、分页/滚动、中心菜单、书签及位置恢复；包含旋转/后台/重启。
4. 本机没有 iOS 设备控制能力；安装与页面体验由可用 Mac/用户真机测试，记录设备/iOS/构建 SHA，不能用 Navigator 构造测试代替。

M2 TXT、M3 完整书库、M4 字体/主题/排版/音量键、M5 长篇性能均尚未实现。XBook/知识库仅协议草案。严格按 ROADMAP 推进，禁止以 localhost HTTP server 为主要预览。

## 恢复纪律

先读 AGENTS → PROJECT_STATUS → HANDOFF → ROADMAP/ARCHITECTURE，核对 Git、实际进程和最近 CI。修改前、每个可恢复步骤后、长测试前更新此文档；保留原始书籍、失败日志和已提交功能。文档收尾提交只包含证据，不重新运行未变的应用源码构建；CI 对应上述已验证 SHA。
