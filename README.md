# XianxiaReader · 仙侠阅读

面向中文玄幻、修仙、仙侠、武侠和超长网文的本地 iOS 阅读器。用户从自己的文件导入书籍；项目不提供小说下载站或在线书城。

**M0 自动构建/测试/打包已通过，下一阶段为 M1；不是完整 MVP。** [CI 38390862584](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38390862584) 完成 Linux/macOS 各 14 Core tests、9 iOS tests 与设备 Release，真实 IPA 已生成。模拟器实际阅读、真机与 TrollStore 尚未验收，详见 [M0 验收](Documentation/M0_ACCEPTANCE.md) 和 [项目状态](PROJECT_STATUS.md)。

## 当前已写入

- SwiftUI 应用入口、基础网格书库、封面/书名/作者/阅读进度/最近阅读时间。
- Files Document Picker 多选 EPUB，后台协调复制、Readium 元数据读取、缩略封面与目录缓存。
- 基于 Readium 的 Reader：目录跳转、手势分页、左右区域点击分页、中央点击菜单、分页/滚动切换、位置保存/恢复、书签添加/跳转/删除。
- SQLite actor、事务迁移、隔离的业务模型和阅读引擎接口、失败导入回滚与重启恢复。
- Reader 关闭时使尚未完成的打开请求失效，过滤旧 Navigator 回调；文件复制支持失败注入，Apple 分支保留 File Provider 协调。
- 原创中文 EPUB 2/3 样书、Core 单元测试、iOS 集成测试、Windows 可运行的结构/语法检查。
- GitHub Actions：macOS 构建、模拟器测试、无签名设备应用、`Payload/` 打包与完整日志 artifact。

M1 搜索切片已写入：Readium SearchService 扩展、分批结果、取消/迟到回调过滤和跳转委托，待新一轮 CI/真实页面验收；细节见 [搜索设计](Documentation/SEARCH_DESIGN.md)。TXT 正文阅读/自动分章、完整书库编辑、自定义字体、五种主题、全部排版设置、音量键翻页和长篇性能验收尚未实现，详见 [功能矩阵](Documentation/FEATURE_MATRIX.md)。XBook 与知识库仅有协议草案。

## 技术基线

| 项目 | 选择 |
| --- | --- |
| 最低系统 | iOS / iPadOS 16.0 |
| UI / 并发 | SwiftUI、UIKit Navigator 桥接、Swift Concurrency |
| 数据 | 系统 SQLite3，经 actor 串行访问；不依赖 iOS 17 的 SwiftData |
| EPUB | Readium Swift Toolkit **exact 3.11.0**，不自行实现排版引擎 |
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

项目私有仓库为 [wan780839395-cyber/XianxiaReader](https://github.com/wan780839395-cyber/XianxiaReader)，origin/main 已建立并推送。`main` push、PR 和手动 `workflow_dispatch` 执行 [.github/workflows/ios-build.yml](.github/workflows/ios-build.yml)。第三次 CI 已全通过，完整结论见 PROJECT_STATUS 和 GitHub Actions；阅读/设备验收与自动构建结果分开记录。

最新成功产物已下载至 `build/XianxiaReader.ipa`，完整日志 `build/logs/ios-build.log`。来源提交、SHA-256 与独立验证范围见 [IOS_VALIDATION_REPORT.json](Documentation/IOS_VALIDATION_REPORT.json)。GitHub artifacts 保留 14 天，忽略的本机构建目录不会随 clone；过期后重新运行锁定版本的 workflow。

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

`Tests/Fixtures/chinese-epub2.epub`、`chinese-epub3.epub` 的正文与封面均为项目原创测试内容，含中文标点、CSS、图像和内部链接。

```powershell
python scripts/generate_fixtures.py
```

源码结构和取舍见 [ARCHITECTURE.md](ARCHITECTURE.md)；阶段门槛见 [ROADMAP.md](ROADMAP.md)。后续 Agent 必须先读 [AGENTS.md](AGENTS.md)，按交接文件恢复工作，并明确区分“已写入”“编译通过”“设备验收”。

使用 Git 保存项目阶段；当前远端/提交状态以 `git status`、`git log` 和 PROJECT_STATUS 为准。`Documentation/FILE_INVENTORY.json` 提供维护文件 SHA-256 恢复快照（不包含自身与忽略缓存）。阶段完成后运行 `python scripts/write_inventory.py` 刷新；不要把 hash 快照当成编译验收。维护文本使用 LF，原始验证日志保持字节，不纳入源码格式检查。
