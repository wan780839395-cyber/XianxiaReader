# XianxiaReader · 仙侠阅读

面向中文玄幻、修仙、仙侠、武侠和超长网文的本地 iOS 阅读器。用户从自己的文件导入书籍；项目不提供小说下载站或在线书城。

**M0通过，M1连续跨章候选完整自动CI通过；完整M1仍待实际阅读/设备验收。** [CI 38530334549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38530334549)（已测源码d62af3b7576a11a1b7318e029355ef1847710113）：Linux/macOS各14 Core、41/41 iOS tests、无签名设备Release与Build4 IPA成功。测试包已核验，旧Build3原件保留；见[项目状态](PROJECT_STATUS.md)。

Build4连续证据：长段字符/重开、目录/搜索/书签、模式往返、窗口回收、迟到回调及加载桥回归通过；用户随后确认连续功能与重开位置正常。旧CI边界PNG缺第二章的截图限制仍保留，不否定用户实测；未单独报告的原书图片、普通设备、旋转及性能继续记录。原 `build/XianxiaReader-Continuous-Build4-TestKit.zip` 保留。自用优先、卡点参考成熟方案、微信读书交互与现有路线原则见[参考记录](Documentation/MATURE_READER_REFERENCES.md)；恢复见[当前交接](HANDOFF.md)和[连续验证报告](Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json)。

最新用户实测：连续阅读功能与重开位置已确认正常，现按计划进入M2 TXT。[分章第一切片](Documentation/TXT_INDEX_DESIGN.md)新增独立Core标题识别、UTF-8流式索引及有界章节窗口，[完整CI38538141364](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38538141364)的同源码attempt2为Linux/macOS各33 Core、41/41 iOS与设备Release成功；初轮EPUB冷启动超时原文保留，原因未确认；随后编码/版本cache第二Core切片通过[CI38547339868](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38547339868)：Linux/macOS各60 Core、41 iOS及设备Release；支持严格UTF8/UTF16/GB18030旁路转换与内容/目录摘要cache，首轮Apple iconv失败及修复证据保留。TXT产品随后接入Build5并通过[CI38559906005](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38559906005)：各68 Core、46 iOS及设备Release。提供编码选择/重试/取消、有界Readium阅读、目录/书签/搜索与完整byte/text位置；设备/长书仍待验收。UI完整书库布局在M3，字体/行距/主题在M4。未逐项报告的原书图片、普通设备/旋转/性能仍单独记录。

## 当前已写入

- SwiftUI 应用入口、基础网格书库、封面/书名/作者/阅读进度/最近阅读时间。
- Files Document Picker 多选 EPUB，明确导入副本模式、后台协调复制、Readium 元数据读取、缩略封面与目录缓存；新增原创内置样书入口。导入修复已过CI，用户确认EPUB可以导入、来源未细分，详见 [导入修复](Documentation/IMPORT_FIX.md)。
- 基于 Readium 的 Reader：目录跳转、手势分页、左右区域点击分页、中央点击菜单、分页/滚动切换、位置保存/恢复、书签添加/跳转/删除。
- SQLite actor、事务迁移、隔离的业务模型和阅读引擎接口、失败导入回滚与重启恢复。
- Reader 关闭时使尚未完成的打开请求失效，过滤旧 Navigator 回调；文件复制支持失败注入，Apple 分支保留 File Provider 协调。
- 原创中文 EPUB 2/3 样书、Core 单元测试、iOS 集成测试、Windows 可运行的结构/语法检查。
- GitHub Actions：macOS 构建、模拟器测试、无签名设备应用、`Payload/` 打包与完整日志 artifact。

M1 搜索切片已过 CI：Readium SearchService 扩展、分批结果、取消/迟到回调过滤和跳转委托；真实命中定位仍待页面验收，详见 [搜索设计](Documentation/SEARCH_DESIGN.md)。TXT 导入/有界Readium阅读/完整位置已接入并过Build5自动CI；完整书库编辑、自定义字体、五种主题、全部排版设置、音量键翻页和长篇性能验收尚未实现，详见 [功能矩阵](Documentation/FEATURE_MATRIX.md)。XBook 与知识库仅有协议草案。

## 技术基线

| 项目 | 选择 |
| --- | --- |
| 最低系统 | iOS / iPadOS 16.0 |
| UI / 并发 | SwiftUI、UIKit Navigator 桥接、Swift Concurrency |
| 数据 | 系统 SQLite3，经 actor 串行访问；不依赖 iOS 17 的 SwiftData |
| EPUB | Readium **3.11.0 本地维护扩展候选**，基线/许可/差异hash见Vendor/ReadiumToolkit；不自行实现排版引擎 |
| 工程 | `project.yml` 是唯一工程定义，XcodeGen **2.46.0** 生成 `.xcodeproj` |
| CI | `macos-15`、Xcode **16.4**、Swift 5 语言模式；Core 使用 tools 5.10 |

Readium 3.11.0 的 Navigator 使用自定义 URL scheme 提供资源，无需 localhost HTTP server。依赖的 `DefaultHTTPClient` 是客户端，不是监听服务。[官方发布说明](https://github.com/readium/swift-toolkit/releases/tag/3.11.0)

## Windows 开发

可以编辑和维护全部源码、文档、Swift Package manifest、工程及 CI 配置。无需启动本地网页服务。当前工作区没有 Swift/Xcode；Windows 检查不等于 iOS 构建。

```powershell
python -m venv .venv
.venv\Scripts\python -m pip install -r scripts/requirements-checks.txt
.venv\Scripts\python scripts/check_repository.py --swift-syntax
.venv\Scripts\python -m unittest discover -s scripts -p "test_*.py" -v
git status --short
```

Swift 语法检查使用 tree-sitter，只发现语法和结构错误，不能检查 SDK、类型、链接、Swift 隔离规则或运行行为。Python SQLite 检查实际迁移文件，但不能替代 Swift repository 测试。

## macOS / Xcode 构建

安装 Xcode 16.4 并完成首次启动，安装 XcodeGen 2.46.0。若使用其他版本，先修改基线并执行完整 CI，不允许凭空宣称兼容。

```bash
export DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer
xcodegen generate --spec project.yml
mkdir -p XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
cp Package.resolved XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader -onlyUsePackageVersionsFromResolvedFile
swift test --package-path Packages/XianxiaCore
open XianxiaReader.xcodeproj
```

在 Xcode 中选择 `XianxiaReader` scheme 与模拟器。普通 iOS 设备需要设置个人 Team / 唯一 Bundle Identifier 并正常签名。不要将本地签名证书提交到仓库。`XianxiaReading` 使用 UIKit，不能用 macOS 的 `swift test` 验证；它的测试由 iOS test target 执行。

可运行 CI 同款完整流程（要求可用 iOS 18.5 iPhone 模拟器）：

```bash
mkdir -p build/logs
set -o pipefail
bash scripts/ci_ios.sh 2>&1 | tee build/logs/build.log
```

## GitHub Actions / IPA

项目公开仓库为 [wan780839395-cyber/XianxiaReader](https://github.com/wan780839395-cyber/XianxiaReader)，origin/main 已建立并推送。用户已明确同意公开源码；使用公开仓库标准GitHub-hosted runner的免费构建，不启用大型runner或付费超额，说明见[GitHub接续](Documentation/GITHUB_SETUP.md)。`main` push、PR 和手动 `workflow_dispatch` 执行 [.github/workflows/ios-build.yml](.github/workflows/ios-build.yml)。构建结论以 PROJECT_STATUS 和 GitHub Actions 的具体run为准；阅读/设备验收与自动构建结果分开记录。

最新成功产物已下载至 `build/XianxiaReader.ipa`，完整日志 `build/logs/ios-build.log`。来源提交、SHA-256 与独立验证范围见 [M1_READER_VALIDATION_REPORT.json](Documentation/M1_READER_VALIDATION_REPORT.json)；M1_SEARCH_VALIDATION_REPORT.json 和 IOS_VALIDATION_REPORT.json 保留之前的搜索/M0 范围。GitHub artifacts 保留 14 天，忽略的本机构建目录不会随 clone；过期后重新运行锁定版本的 workflow。

用户测试设备为iPhone13/iOS16.6.1/TrollStore，先前安装/EPUB导入用户报告正常；Build4原书图片、连续双章/逆向、惯性与重开位置待实测。当前 `build/XianxiaReader-Continuous-Build4-TestKit.zip` 包含Build4 IPA、四本原创EPUB和UTF-8说明；保留数据正常更新，菜单启用“上下连续滚动”。候选自动CI通过，当前边界PNG未完整显示第二章，完整阅读仍待验收；见[真机验收](Documentation/DEVICE_ACCEPTANCE.md)。旧Build3包及测试ZIP原件保留。

CI 先检查仓库、运行 Core 测试与 iOS 集成测试，然后使用 `CODE_SIGNING_ALLOWED=NO` 构建设备 Release `.app`。测试或编译失败会使 job 失败，不会跳过错误输出成功 IPA。

- `XianxiaReader-unsigned-ipa`：包含 **XianxiaReader.ipa**，内部为 `Payload/XianxiaReader.app/`。
- `XianxiaReader-build-diagnostics`：完整 `build/logs/build.log`、环境记录、`.xcresult`、生成的 `.xcodeproj` 及解析后的 `Package.resolved`；失败时也上传已有诊断。
- `XianxiaReader-core-diagnostics`：独立 Linux Core 编译/测试日志，使用 Swift 6.1.2 jammy 的已验证 linux/amd64 image digest；iOS job 等待此项通过。macOS job 仍再次运行 Core 测试以覆盖 Apple 文件协调分支。

无签名 IPA 用于后续 TrollStore 测试，不是普通 iOS 安装签名包；设备是否适合 TrollStore 与实际安装/运行必须另行验证。本项目不会申请平台级权限或植入私有 entitlement 来实现阅读功能。

## 可选 Windows Core 编译测试

本机若已有正常运行的 Docker Desktop，可以执行：

```powershell
pwsh -File scripts/test_core_container.ps1
```

脚本先检查引擎，20 秒无响应则明确失败；不会替你启动或重置 Docker。容器只读挂载项目，不映射端口，编译缓存位于容器临时目录，日志写入 `build/logs/`。Linux 分支仅验证普通本地文件复制、SQLite 和业务模型，不能代替 macOS/iOS 的 `NSFileCoordinator`、Readium 或 UI 测试。

本轮已恢复 Docker 的失效旧 socket 故障，并实际编译 Core、运行全部 14 个 XCTest，退出码为 0；首次失败暴露的路径边界缺陷已修复。成功日志和源码 hash 见 [Core 验证报告](Documentation/CORE_VALIDATION_REPORT.json)，环境修复见 [Docker 恢复记录](Documentation/DOCKER_RECOVERY.md)，完整边界见 [验证记录](Documentation/VALIDATION.md)。官方镜像来源见 [Swift Docker 安装文档](https://www.swift.org/install/linux/docker/)。

## 样书与维护

AppIcon 为原创书页/山峰/月亮图案；Xcode 直接使用提交的 PNG。维护图标时可安装 `scripts/requirements-assets.txt` 并运行 `python scripts/generate_app_icon.py`，同时生成 SVG 源稿和 PNG；这不是构建依赖。

`Tests/Fixtures/chinese-epub2.epub`、`chinese-epub3.epub`的正文与封面均为项目原创测试内容；`reader-layout.epub`为独立高封面/长短章样书。分别运行generate_fixtures.py和generate_reader_fixture.py，不覆盖原搜索回归。

```powershell
python scripts/generate_fixtures.py
```

源码结构和取舍见 [ARCHITECTURE.md](ARCHITECTURE.md)；阶段门槛见 [ROADMAP.md](ROADMAP.md)。后续 Agent 必须先读 [AGENTS.md](AGENTS.md)，按交接文件恢复工作，并明确区分“已写入”“编译通过”“设备验收”。

使用 Git 保存项目阶段；当前远端/提交状态以 `git status`、`git log` 和 PROJECT_STATUS 为准。`Documentation/FILE_INVENTORY.json` 提供维护文件 SHA-256 恢复快照（不包含自身与忽略缓存）。阶段完成后运行 `python scripts/write_inventory.py` 刷新；不要把 hash 快照当成编译验收。维护文本使用 LF，原始验证日志保持字节，不纳入源码格式检查。

2026-10-14首次文件交接增量：Build6 / [CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849)各68 Core、49 iOS及设备Release通过，EPUB/TXT共用引用模型结果交接；新增原生sheet首次/取消/空选择/重试回归。旧交接未在iOS18.5复现用户iOS16.6.1现象，设备首次导入仍待实测，M2长书/设备未完成。新包build/XianxiaReader-Import-Build6-TestKit.zip；旧Build4/5不变。详见Documentation/IMPORT_HANDOFF_FIX.md与HANDOFF。
