# 当前交接与恢复点

更新时间：2026-10-13（Asia/Shanghai）

## 当前阶段

Milestone 0：源码、工程定义、文档、CI 和测试已写入；Windows/Linux Core 通过。首次 macOS CI 的 Apple Core 14 tests 已执行通过，iOS 模拟器在链接阶段失败，尚无 IPA。

## 最新恢复点（优先于下方历史记录）

第三次 CI 已启动：run `38390862584`，head `184aa09355ed0f44e9e27763c5d44fa0a8161434`，URL https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38390862584 。图标修复与本地静态/tooling 检查已提交并推送；main 跟踪 origin/main，没有 pending 登录/UAC/容器测试。当前只在等待远端 macOS CI；先检查此 run，不重启旧失败构建、不推送文档打断当前 job。仍未取得 iOS tests/Release/IPA 通过证据。

第二次 run 38389603242 已 failure。锁文件解析及 Linux/macOS Core 通过；新错误是 asset catalog 缺少 AppIcon，iOS tests 再次未运行。日志/xcresult 保存在 `build/ci/38389603242/ios/`。已经新增真实 1024 RGB PNG、appiconset、原创 SVG/生成脚本，并显式配置工程 AppIcon；图标已视觉检查。本地重新进行受影响的静态/tooling 检查后提交/推送第三次 CI，不重跑未变的 Core 源码。当前最新已推送提交仍为 7a2263b，图标修复待提交。

2026-10-13：GitHub CLI 已登录，私有仓库已创建并正常推送；Docker Desktop 4.95.0 / engine 29.8.2 已恢复，用户原容器保留。无需重新请求登录、UAC、建仓或推送许可。

首次 run 38385729586 已 failure，repository-checks 和 Linux Core 成功；macOS 完整日志下载至 `build/ci/38385729586/ios/build/logs/build.log`，诊断包含 `.xcresult` 和真实解析后的 lockfile。断点为 iOS 模拟器链接使用了宿主 Homebrew SQLite：`ld: building for 'iOS-simulator', but linking in dylib (...) built for 'macOS'`。不是 Readium API 编译错误，不能删除 SQLite 功能绕过。

修复：Core 的 CSQLite 去除 pkgConfig/Homebrew provider，由 Apple SDK 或 Linux 系统目录提供 SQLite。保留 modulemap 的 `link "sqlite3"` 和全部测试。将首次真实解析的 11 个依赖锁文件纳入根目录，生成工程后复制，CI 严格使用锁定版本。准备重跑本地 Core 与静态检查，更新源码 hash，再提交并推送第二次 macOS CI。失败日志保留，新的结果出来前不得标 iOS tests/build/IPA 成功。

再次恢复核实：自己的容器测试 session 91831 已 exit 0，修复后 Core 完整编译 6.70 秒、14 XCTest 通过；项目测试容器已自动退出，无运行中的 CI（只有首次失败 run）。下一步保留旧成功日志，绑定新 manifest/source hash，执行静态/tooling/shell 检查，再普通提交/推送触发第二次 CI。

修复已提交并正常推送：`7a2263b4ae75abf733d2edd188e4b298bf80369c`。第二次 run `38389603242` 实际 in_progress：[Actions](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38389603242)。本地 14 Core tests、30 Swift grammar、6 tooling tests、Bash/Python 语法通过，Core report 与 86 文件 hash 清单已更新。先等待此 run 结果，期间不推送纯文档触发 cancel-in-progress；失败时取日志继续修复，成功时下载 IPA/完整诊断并记录 Apple/iOS/Release 的独立证据。

## 环境实测

- 工作区：`D:\ai项目\XianxiaReader`，初始目录为空。
- Windows 11 家庭版 64 位，10.0.26200；PowerShell 7.6.5。
- Git 2.54.0、Python 3.11、Node 可用。
- 本机没有 Swift、Xcode、xcodebuild、XcodeGen；Swift 可在容器运行，GitHub CLI 2.102.0 便携路径记录于忽略的 `.cache/tools/github-cli.json`。
- 本地 Git main 初始提交已建立；远端/CI 的最新状态见下方当前工作。
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

最新工作（18:40）：用户明确要求再次发起 Docker UAC，并请求协助打开 GitHub 登录页；无需再次询问是否重试。现场确认 Git 工作区干净、CLI 仍未登录，session 3140 也已 expired_token / exit 1。准备使用已核验官方缓存 installer 重新发起 RunAs 升级，另生成新的 GitHub 设备代码并实际打开可见浏览器。旧代码均失效，不复用；账户登录/系统管理员挑战由用户本人完成，不将一次性代码写入仓库。

18:45 本机 CLI session 92908 已 Authentication complete / exit 0，账户 wan780839395-cyber；不再生成登录代码。GitHub 登录已完成，可以继续已获准的私有仓库创建/推送/CI。Docker 4.95.0 安装成功但 engine 未响应，Desktop CLI start 误报 already running，现场无 Desktop/backend 进程且 status 挂起；准备关闭自己的挂起 status 查询并直接启动新版 Desktop，保留旧容器/数据。

18:47 已创建并核实私有仓库 `https://github.com/wan780839395-cyber/XianxiaReader`，origin 指向该 HTTPS 地址；main 已正常推送（首次 head f9c3520），并跟踪 origin/main。Docker 直接启动新版 Desktop 后 engine 已响应，29.8.2 / Linux amd64；原 glm2api、zai2api 两个停止容器保留。安装/engine 证据与 verified JSON 已保存。首次 run list 暂为空，正在检查工作流登记/服务端状态；不把推送成功当 CI 成功。重试之前未运行的升级后 Core 容器测试，随后同步文档与 CI 证据。

18:50 首次 CI run `38385729586`（head f9c3520f361f6f4b73546c6c5af195071b32c727）实际运行，repository-checks 与 Linux core-tests 已 success，macOS ios job 正在 Build/test/package 步骤。URL：`https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38385729586`。本机升级后 Core 容器编译/14 个 tests 也已 success / exit 0（8.55 秒）。暂不推送纯文档收尾以免 cancel-in-progress 重启正在运行的构建；等结果后处理真实错误或归档日志/IPA/依赖锁。没有未完成登录/UAC，无需再问授权。

18:41 Docker installer RunAs 已成功（PID 14872 已退出；admin log 显示 Installation succeeded），程序版本核实为 4.95.0.242831；但后续 engine 查询失败，npipe/dockerDesktopLinuxEngine 不存在，不能标引擎已恢复或原容器已核对。Core 脚本也明确 exit 1 / 未运行 tests；正在核对新 backend 启动日志，历史 Core 成功证据保留。安装成功日志为 `docker-upgrade-success.log`。新 GitHub CLI 设备登录 session 92908 正在等待本人授权；通过 cua 已打开可见 IAB 登录页（tab 1），页面显示 Continue as wan780839395-cyber，已告知新代码并保留该 tab。user 未登录 CLI 前不创建/推送远端；如果用户授权完成，直接核对同一账户并继续私有建仓/CI。

最新断点（18:11）：本地初始提交 `a6466a6` 已完成（80 个文件），当时工作区干净；后续交接同步另行提交。GitHub connector 已连接并确认账户 `wan780839395-cyber`；GCM 无已存账户，本机便携 CLI 仍未登录。`gh auth login --web --git-protocol https --scopes workflow` 在等待本人设备授权；当前 exec session 80177 尚在，通常会到期退出，恢复时先核对 `gh auth status`，若已授权不要重复发起。一次性代码不持久化。

18:17 GitHub 安装完成回调后再次现场核对：connector 账户正常，本机 CLI 未登录；旧 session 80177 实际以 expired_token / exit 1 结束。重新发起设备登录，当前 exec session 3140 等待本人授权（新代码不入库）。本地已有 `a6466a6` 与交接提交 `b26dadf`，远端仍未创建；connector 对候选仓库的读取返回 404，最终建仓前还须使用授权后的 CLI 核实重名与权限。

Docker 升级失败在 UAC 取消，已关闭自己的 updater CLI/shell，旧 4.77 backend/29.5.3 engine 保持正常；不能标升级成功。已向用户询问是否重试，未收到回复前不重复弹管理员窗口。所有 Core/静态/工具测试均已完成，无进行中的项目测试或 iOS build。仓库 `wan780839395-cyber/XianxiaReader` 尚未创建/推送；用户已确认私有，CLI 成功后可核对重名并继续创建、正常推送及首轮 CI，无需再次询问仓库可见性或提交权限。

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
