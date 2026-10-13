# 当前交接与恢复点

更新时间：2026-10-13（Asia/Shanghai）

## 当前阶段

Milestone 0：源码、工程定义、文档、CI 和测试已写入；Windows 静态验证与官方 Swift 6.1.2 Linux Core 编译/14 个 XCTest 已通过。基础 EPUB 流程是 M1 技术切片，尚未通过 macOS/iOS 构建验收。

## 环境实测

- 工作区：`D:\ai项目\XianxiaReader`，初始目录为空。
- Windows 11 家庭版 64 位，10.0.26200；PowerShell 7.6.5。
- Git 2.54.0、Python 3.11、Node 可用。
- Swift、Xcode、xcodebuild、XcodeGen、GitHub CLI 不可用。
- 本轮初始化本地 Git；尚未设置远端、提交或触发 GitHub Actions。
- 禁止以 localhost HTTP 服务作为主要预览方式。

## 恢复步骤

1. 阅读 AGENTS.md → PROJECT_STATUS.md → HANDOFF.md → ROADMAP.md。
2. 查看真实文件、Git 状态和检查日志，核实最后一步是否完成。
3. 先完成 M0 与 EPUB 构建验证，不大规模进入 TXT/完整书库/设置阶段。

## 首次恢复核实（历史断点，最新结果见下方）

- App / 两个 Packages / project.yml / GitHub workflow / Tests / Future 草案 / Documentation / scripts 均存在。
- 恢复时已有 JSON 报告停在 2026-10-13T08:41:48 UTC 的静态验证；随后重新检查，再新增复制边界/生命周期回归后变为 5 类检查、30 个 Swift 文件语法通过。
- Git 仍为 main、无提交、无 remote；现有新文件尚未 staged。未丢弃任何改动。
- 用户回复没有 GitHub 仓库；不猜测 remote，不等待或宣称 CI 已启动。
- 恢复检查未发现命令行匹配本工作区/本项目校验脚本的构建进程；无 Swift/xcodebuild 进程。其他 Node/Python 进程未修改。
- 上一段最终静态检查和构建工具测试已经完成；断在最终源码审查与交接状态同步前。
- Windows 无 Swift/Xcode。当前没有 build 目录或 `.xcresult`，不应等待不存在的 iOS 构建任务。

## 已落实

- Readium exact 3.11.0 的 loader/adapter 和独立 ReadingInterfaces。
- Foundation 领域模型、SQLite 版本化事务存储、相对路径管理、文件暂存/回滚/重启恢复。
- SwiftUI 基础书库、EPUB Document Picker 导入、基础 Reader/TOC/位置/书签。
- 原创 EPUB 2/3 样书，Core 与 iOS 测试源码；CI 与 IPA 打包工具。
- 本地结构、SQL、EPUB、30 个 Swift grammar 文件和 6 个 Python 工具测试通过；bash -n、PowerShell AST 与 Python compileall 通过。
- 真实 Linux Core 编译/14 个 XCTest 通过，受管理存储路径边界缺陷已修复。

## 恢复后修复

- 确认 Readium `Link(href:)` 接收 String，目录跳转使用持久化 href 原文。
- 明确 App MainActor 与已提交 Info.plist 引用，避免 XcodeGen 重写 plist。
- Reader 打开失败有独立错误视图与重试，不会关闭 alert 后无限显示“正在打开”。
- SQLite 初始化/迁移失败关闭 handle；较高 schema 在修改 journal_mode 前拒绝；增加原数据保留回归测试。
- 确认 XcodeGen 的 XcodeProj 9.14.0、Readium 使用的 SwiftSoup 2.13.5 manifest 要求 Swift 6.0，可被 Xcode 16.4 compiler 满足；传递版本仍待真实解析。

## 当前停靠点与下一步

### 当前工作：已获准升级 Docker，准备 GitHub

用户已明确允许升级 Docker，并要求继续、帮助 Git/GitHub。正在核对官方升级器、签名、现有容器及账户连接；GitHub 插件已找到但尚未连接，准备提供登录入口。当前 main 仍无提交/remote/作者配置，不能使用猜测身份提交。先完成可在本地审查的源文件/忽略规则检查；账户登录和 UAC 由用户本人完成，后续仓库创建/推送依据已确认账户和可见性，不覆盖现有仓库。

用户已选择私有仓库。Docker 4.95.0.242831 已由官方 updater 确认可用；缓存安装包数字签名 Valid / Docker Inc，SHA-256 与官方 checksums.txt 相同（73431db38491f770543880366228a23c993f84d1e8e045f56d83b8a98940cf76）。当前没有运行的用户容器，已有两个停止容器须保留。开始 `docker desktop update --quiet`，日志 `build/logs/docker-upgrade.log`；不能把启动升级等同完成。GitHub CLI 未安装；匿名 GitHub REST API rate limited，改用官方 release 下载入口准备便携 CLI。GitHub 插件已提供安装入口，连接未确认。

18:04 已确认 GitHub 连接：`wan780839395-cyber`（id 284319074）；已有其他仓库不修改。官方 GitHub CLI 2.102.0 便携版已下载到忽略的 `.cache/tools/`，SHA-256 与官方 checksums 相同；第一次读取 checksum 时 PowerShell 返回 byte[]，已正确按 UTF-8 解码验证，没有使用未校验的程序。Git 作者已仅在此仓库配置为已确认 login + ID-based noreply 邮箱。CLI OAuth 设备登录正在等待用户授权（一次性代码不写入文档）；connector 连接不能替代本机 CLI 登录。Docker updater 已拉取并进入安装，其日志显示请求 UAC，尚未完成。准备初始本地提交，登录后创建 `wan780839395-cyber/XianxiaReader` 私有仓库并推送，先检查重名，禁止覆盖其他仓库。

18:05 installer 实际返回“操作已被用户取消”（UAC），没有升级成功；安装子进程已退出，停止自己启动且卡在 Installing 的更新 CLI。日志保留为 `Documentation/ValidationLogs/docker-upgrade-cancelled.log`、`docker-upgrade-error.json`。已询问是否重试，等待用户，不绕过 UAC。原 Docker Engine 29.5.3 仍响应。初始 Git staging 发现源码末尾多余空行与默认 CRLF 规则，统一维护文本为 LF/一个末尾换行；原始 ValidationLogs/*.log 禁止 Git 换行转换并保留字节。纯格式变更后重跑 Core、更新 hash，再进行初始提交。暂未创建远端，CLI OAuth 尚未完成。

18:07 格式统一后 Core 再次完整编译/14 个 tests 成功（6.68 秒，exit 0）；报告和成功日志已更新为新源码，之前成功日志另存 `core-container-before-git-format.log`。仅停止自己的挂起 updater shell，不停止健康 backend。新增 `Documentation/GITHUB_SETUP.md` 记录双授权、本地作者与私有建仓流程；JSON 检查/清单工具固定写 LF，保证 Git checkout 后 hash 不受 Windows 换行转换影响。继续进行初始提交；CLI 授权和 UAC 重试选择仍待用户。

### 最新停靠点：Docker 已恢复，Core 已通过

2026-10-13 17:52（Asia/Shanghai）：第三次完整 Core 容器测试 exit 0，Swift 6.1.2 真正编译成功（6.78 秒），14 个 XCTest 全通过。源码与日志 hash、测试列表及范围见 `Documentation/CORE_VALIDATION_REPORT.json`。成功日志为 `Documentation/ValidationLogs/core-container-success.log`，两次失败日志保留，原件与现有代码均未丢弃。

最新改动：`BookFileStore` 对已存在的目录组件逐级拒绝符号链接/断链，避免末端缺失时遗漏父级越界；root 创建后再规范化。保留原越界测试并新增内部/断链与根别名回归。AGENTS/ARCHITECTURE 已登记该存储约束。

Docker backend/engine 已恢复，测试容器均已退出并由 `--rm` 清理；最终 `docker ps --all --filter label=project=XianxiaReader` 无条目。成功 engine 证据保存为 `Documentation/ValidationLogs/docker-engine-recovered.log`。文档已同步，最后 Windows 静态复查（5 类、30 个 Swift grammar 文件）、6 个 Python tests、Bash/PowerShell/Python 语法均通过。收尾刷新 `Documentation/FILE_INVENTORY.json`；若中断先核对该清单与日志，不再从 Docker 启动失败点重做。Docker Desktop 保持正常运行；没有进行中的项目测试/iOS/macOS 构建任务，也没有 GitHub 远端。

下一步仍为 M0 macOS gate：运行 `scripts/ci_ios.sh` 验证 Apple Core 分支、Readium/iOS 9 个 tests、设备 Release build 与 IPA。可使用有 Xcode 16.4 的 Mac，或未来建立用户自己的 GitHub 仓库后推送执行 CI。不能用本次 Linux 成功替代 iOS 验收，不大规模进入 M2。

### 本轮故障排查过程（历史记录）

#### 当前工作：Docker socket 根因与恢复

2026-10-13 17:40（Asia/Shanghai）已完成可回退修复：用原生 PowerShell 将仅含失效 socket 的两个运行目录改名保存，并重建空目录。备份为 `%LOCALAPPDATA%/Docker/run.xianxia-backup-20261013-174018` 和 `%LOCALAPPDATA%/docker-secrets-engine.xianxia-backup-20261013-174018`；计划和端点探测证据见 `Documentation/ValidationLogs/docker-runtime-quarantine.json`、`docker-socket-probe.json`。未删除数据或重置配置。`docker desktop start --detach` 返回成功，backend 当前存活；下一步核实 engine 是否可用，随后运行隔离的 Core 编译测试。启动请求成功不代表 engine 已就绪。

17:43 核实 engine 已响应（29.5.3 / Linux amd64），已启动 `pwsh -NoProfile -File scripts/test_core_container.ps1`。17:45 官方 Swift digest 镜像拉取完成，正在容器中安装 SQLite 开发依赖。完整当前输出为 `build/logs/core-container.log`；命令尚未返回测试结果，不要误标通过。详细环境故障与恢复见 `Documentation/DOCKER_RECOVERY.md`。

17:45 首次真实 Core 编译成功（Swift 6.1.2，8.31 秒），12 个 XCTest 中 `testSymlinkCannotEscapeStorage` 失败，命令 exit 1。Foundation 在 Linux 对包含符号链接且末端不存在的路径未解析父级链接；正在探测并修复真实路径边界。失败完整日志保留为 `Documentation/ValidationLogs/core-container-first-failure.log`。不能因末尾 Swift Testing 的“0 tests passed”误判 XCTest 成功，不移除失败用例。

17:48 已用同一 Swift 容器复现 Foundation 的区别（存在的目标解析成功、缺失目标原样返回）。修复 `BookFileStore`：先创建后 canonicalize root，逐级拒绝受管理路径内的符号链接，包括 dangling link；保留普通缺失目录路径。保留原越界测试并增加内部/断链与根目录别名回归，Core 共 14 tests。下一步重新完整编译/测试，结果尚待验证。

17:48 第二次编译成功，原越界及新增内部/断链测试通过；根目录别名测试的 URL 对象比较因目录末尾斜杠差异失败，实际文件系统路径相同。修正断言为比较 canonical filesystem path，仍保留根别名回归；第二次完整日志为 `Documentation/ValidationLogs/core-container-root-url-failure.log`。准备第三次完整测试。

用户明确要求“查找是什么原因 应该怎么做 继续”。正在只读核对 Docker run socket 的 reparse metadata/权限、backend 日志和 WSL。发现 `dockerInference`、`dockerEthernetVfkit`、`userAnalyticsOtlpHttp.sock` 均为 2026-10-06 遗留的 0 字节 ReparsePoint，Docker 当前已停止。先确认端点类型，再考虑保留备份的有限修复；不 factory reset、不删除镜像/容器/VHD、不启动网页预览。

用户要求继续。读取全部状态并核对真实工具：仍无 macOS/Xcode；本机有 Docker CLI 与 docker-desktop WSL，但 Docker engine 当前未运行。正在尝试利用隔离的官方 Swift Linux 容器进行 Core 真正编译/测试；这只能验证纯业务和 SQLite，不能替代 iOS build 或 iCloud 协调测试。现有源码全部保留，不大规模进入 M2。

Docker 启动尝试已结束：Desktop 初始化 Inference manager 时无法访问 `dockerInference` Unix socket，backend shutdown；无 Swift 容器/编译/测试执行。本轮启动的 Docker Desktop/backend/查询进程已结束；未修改 Docker 配置、清理其数据或使用 factory reset。registry manifest 查询确认官方 Swift 6.1.2 jammy 的 linux/amd64 digest，已用于 CI 和本地脚本。

本轮子步骤已完成：SourceFileCopying（Apple 仍使用 NSFileCoordinator，Linux 本地文件分支供 Core 测试）、Reader 关闭/打开竞态与旧回调过滤、1 个复制失败及 3 个生命周期回归。CI 新增 Swift 6.1.2 official Linux Core job，Windows 新增不启动 Desktop 的有超时 Core 脚本。该脚本已在 engine 不可用时实测以 exit 1 明确失败；未挂起、未执行 Swift tests。最终静态报告为 5 类检查/30 个 Swift 文件通过，6 个 Python 工具测试通过，Bash/PowerShell AST/Python 语法通过。

此前停靠点只完成静态验证，Core 12 个/iOS 9 个 Swift tests 尚未执行。该断点已继续推进：当前 Core 增至 14 个并在 Linux 通过，iOS 9 个仍待 macOS。当前最新日志/JSON 在 Documentation 下；`build/logs/docker-engine.*.log` 与 `core-container.log` 已被后续成功运行更新，历史环境失败保留在 `Documentation/ValidationLogs/core-environment.log`。

下一阶段仍是 M0 macOS build/test gate；当前没有 GitHub 仓库，不能触发远程构建。可在具备 Xcode 16.4 的 macOS 环境运行 `scripts/ci_ios.sh`；或以后建立用户自己的 GitHub 仓库并推送现有工程，执行 GitHub Actions。收到真实编译日志后先修复错误，不大规模进入 M2。

M0 放行后继续 M1 搜索、真实位置/链接/图片/CSS/交互与中文排版验收。当前 TXT/完整书库编辑/排版主题/音量键/性能测试均未实现，具体见功能矩阵。

## 验证边界

仅 Core 的 Linux 编译/14 个 XCTest 成功；Apple 文件协调、iOS App/Readium 编译、iOS 测试、模拟器阅读、普通设备/TrollStore 与 IPA 尚未验证。不得把静态检查、生成工程配置或 Core 成功说成整个 iOS 应用已构建。
