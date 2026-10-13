# 当前验证与已知风险

本轮开发于 2026-10-13（Asia/Shanghai）。Windows 11，PowerShell 7.6.5，Git 2.54.0.windows.1，Python 3.11；无 Swift/Xcode/xcodebuild/XcodeGen 可执行文件。官方依赖源码仅保存在忽略的 `.cache/` 用于 API 审查，不作为产品源码提交。

**最新结论：M0 自动验收通过。** [CI 38390862584](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38390862584) 的 14 Linux + 14 macOS Core tests、9 iOS tests、设备 Release 与 IPA 全成功。实际提交 184aa09355ed0f44e9e27763c5d44fa0a8161434；机器可读证据 IOS_VALIDATION_REPORT.json，门槛/产物 M0_ACCEPTANCE.md。模拟器阅读体验、真机与 TrollStore 安装仍未验收。

## 本地完成的验证

- 项目文档、Swift Package 路径、target 来源、资源 JSON/plist 与 YAML 结构。
- 实际 `001_initial.sql` 迁移在 Python SQLite 中执行；版本、完整性、外键、章节唯一序号/非负约束、进度范围及级联规则通过。
- 两个原创 EPUB 的 mimetype 首位/不压缩、XML、manifest/spine 引用与中文元数据通过。
- 30 个 Swift 文件 tree-sitter 语法检查通过。此检查不验证 Swift 类型、SDK、链接和并发隔离。
- 6 个 Python 构建工具测试通过（可用模拟器选择、缺失 runtime 拒绝、IPA 结构、模拟器包拒绝、缺 executable 拒绝、越出 bundle 的 executable 拒绝）；Windows 未执行 Unix 可执行权限/符号链接断言，这些断言由 Linux/macOS 测试执行。
- `scripts/ci_ios.sh` 使用 Git Bash `bash -n` 检查通过；这不是 macOS CI 执行。
- `scripts/test_core_container.ps1` 通过 PowerShell AST 语法检查；这不代表容器命令实际成功执行。
- 本地 Core 脚本已在 engine 不可用的真实条件下验证 exit 1，明确表示未执行 Swift tests；随后修复 Docker 并实际执行成功。成功运行分支已实测，20 秒超时分支尚未实测。历史环境失败见 `ValidationLogs/core-environment.log`。
- **Core 在 digest 锁定的官方 Swift 6.1.2 Linux 容器中编译成功，14 个 XCTest 全部通过，命令 exit 0。** Git 维护文本统一 LF/末尾换行后重新完整编译（6.68 秒）并通过全部测试，报告已绑定新源码 hash。验证 Foundation/SQLite、普通文件复制、导入恢复和路径边界；未覆盖 Apple 文件协调分支。
- 对照 Readium 3.11.0（commit `d82f44f4f05d87add9e22a8b75abbd61dce745dd`）检查打开、Navigator、preferences、TOC、cover、Locator JSON 与 input observers 签名。
- 对照 XcodeGen 2.46.0（commit `8445e778451c7e44237b90281bde622d764b0084`）检查工程定义。App 明确使用已有 `INFOPLIST_FILE`，避免 generator 重写应用 plist。

JSON 结果分为三个范围：`VALIDATION_REPORT.json` 只记录静态检查，Swift 编译字段 false 表示该命令不执行编译；`CORE_VALIDATION_REPORT.json` 记录本机 Linux Core 编译/测试，包含源码和日志 hash；`IOS_VALIDATION_REPORT.json` 记录真实 macOS/iOS CI、设备 Release 与 IPA，附已构建源码 hash 和产物检查。三者均不表示真机阅读或 TrollStore 验收。

最终本地日志已保存：`ValidationLogs/windows-static.log`、`python-tooling.log`、`script-syntax.log`。Python packaging 测试仅打包临时合成 bundle，日志中的 `test.ipa` 不是产品 `XianxiaReader.ipa`。

## Swift 测试执行状态

- Core 14 个：**Linux 全通过**。数据库重开/阅读位置/书签、旧位置拒绝、事务回滚、孤立位置外键、目录排序/隔离、进度范围、文件暂存/恢复、路径与 symlink 越界、内部/断链拒绝、系统父级链接下新 root 的规范化、未支持格式拒绝、较高数据库 schema 拒绝且保留原数据、部分复制失败清理且保留原件。
- macOS Core 14 个：首次 CI 中全部执行通过（Apple 文件协调分支）。
- iOS 9 个：**第三次 CI 全通过、0 failures**。EPUB 2/3 元数据/目录、无 HTTP server Navigator 构造、真实导入、损坏 EPUB 回滚、Locator 完整往返、错误 book/engine/version/JSON 拒绝，以及阅读中途关闭/失败重试/关闭后迟到位置三个生命周期回归。前两次构建错误和被取消测试保留在 CI_FAILURES.md。

首次真实 Core 编译成功，但原 symlink 越界测试失败：Linux Foundation 对末端不存在的路径没有解析父级链接。修复为逐级拒绝受管理存储的链接并保留正常缺失目录；不删除测试或绕过错误。第二次仅根别名测试因目录 URL 尾斜杠不同而失败，断言修正为文件系统路径比较。三次完整日志分别保留为 `ValidationLogs/core-container-first-failure.log`、`core-container-root-url-failure.log`、`core-container-success.log`。最终 14 个 XCTest 与 exit 0 共同证明通过；日志末尾 Swift Testing 的“0 tests passed”属于未使用的另一测试框架，不能据此忽略 XCTest 失败。

“构造 Navigator”验证 API 生命周期，未验证渲染完成、页数、中文排版或实际点击行为。不得把这项测试通过称为阅读体验验收。

## 编译与设备风险

1. 首次误链接 Homebrew SQLite 已修复并通过第三次完整 CI；IPA 实际链接系统 `/usr/lib/libsqlite3.dylib`。失败与修复见 CI_FAILURES.md。
2. Swift 5 targeted 的实际构建存在 ReaderView.swift:62 的 Binding setter 到 Sendable closure 转换警告，M1 优先明确 MainActor 隔离。Readium Publication 非 Sendable，后续 Swift 6 严格模式迁移仍需独立审查，不能用当前通过代表全量并发安全。
3. 首次 macOS 真实解析的 11 个依赖已审阅并纳入根 `Package.resolved`；CI resolve/test/build 严格锁定版本。其来源为 run 38385729586 的诊断 artifact，Readium revision 与精确基线一致。
4. Runner 的 Xcode 16.4/iOS 18.5 当前官方清单可用，未来镜像可能移除；脚本会显式失败，不能静默换 compiler 或跳过 simulator test。
5. 第二次缺 AppIcon 已修复；第三次 CI 的模拟器和设备 asset compiler 均成功。原创 SVG、1024 RGB PNG、appiconset 已提交；图标生成依赖仅用于维护，构建不需 Pillow。
6. 未签名 IPA 已生成并核验 arm64/iOS device、最低 iOS 16、ZIP/Payload/0755 与 hash；普通设备签名/TrollStore 安装和 iOS 16 真机运行尚未验证。
7. Reader 菜单遮挡/安全区、旋转、滚动转换、链接选择、iCloud materialization、巨大 EPUB 的 position 计算仍需实际阅读验收与性能测量。

## 下一验证顺序

M0 gates 已通过，下一步处理隔离警告、接入 M1 搜索，完成位置/交互/排版的实际阅读验收；通过后才大规模进入 M2。

恢复时无 GitHub 连接/remote；用户随后选择私有并完成授权，已建立私有仓库、核实本项目 noreply 作者并推送 main。前两次真实失败已修复，第三次 CI 全部成功；当前没有运行中的项目构建，也无需再次登录/UAC。历史过程见 HANDOFF_HISTORY_2026-10-13.md。

## 本轮 Core 编译环境恢复

本机有 Docker CLI 和 `docker-desktop` WSL。第一次启动 Desktop 时，日志在 2026-10-13 16:59（Asia/Shanghai）记录 backend 因 Inference manager 的 `dockerInference` Unix socket 访问失败而 shutdown。该次故障发生在编译之前，属于 Docker 工具环境。

后续核实四个遗留端点为不可访问的 AF_UNIX reparse point（Win32 error 1920）。17:40 保留备份两个只含 socket 的运行目录并重建后，engine 恢复响应。随后镜像拉取、Core 编译与最终 14 个测试成功完成。未 factory reset、修改配置或删除用户镜像/容器/VHDX。用户之后授权升级，18:41 Docker Desktop 4.95.0 安装成功，18:47 engine 29.8.2 响应，升级后与 SQLite 修复后 Core 均再次通过全部 14 tests。修复细节、备份路径和官方依据见 [DOCKER_RECOVERY.md](DOCKER_RECOVERY.md)，不推断未证实的磁盘/驱动根因。

只读 registry manifest 查询与真实拉取均确认 `swift:6.1.2-jammy` 的 linux/amd64 manifest digest 为 `sha256:1122c18e938491180820e9b4902c489dadd5a89f7e6bd99ff9b64e7f1b18f41f`。CI 与本地 Core 脚本锁定该镜像；容器实际安装 SQLite development headers 并执行 `swift test`。第三次 CI 的 macOS job 也独立执行 Apple 分支测试，不能用 Linux 分支替代。

官方依据：[Readium 3.11.0](https://github.com/readium/swift-toolkit/releases/tag/3.11.0)、[XcodeGen 2.46.0](https://github.com/yonaskolb/XcodeGen/releases/tag/2.46.0)、[macOS 15 runner 清单](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)。
