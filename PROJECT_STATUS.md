# 项目状态

更新时间：2026-10-13（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | **自动验收通过** | Linux/macOS Core、9 iOS tests、设备 Release 与真实 IPA 均成功 |
| M1 基础 EPUB | 首轮搜索切片自动验证通过；清理警告后重跑；完整阶段未验收 | 20 iOS tests、设备 Release/IPA 通过；真实阅读仍待设备验收 |
| M2 TXT | 未开始 | 后台流式分章、索引缓存与长文件测试 |
| M3 完整书库 | 未开始 | 完整编辑、封面修改与操作一致性 |
| M4 设置与主题 | 未开始 | 排版、字体、主题与交互验收 |
| M5 性能 | 未开始 | 超长书、内存、恢复与性能基线 |

## 当前实际实现

- SwiftUI 基础网格书库，封面/书名/作者/最近阅读/可用进度展示。
- EPUB Files 导入，后台协调复制、Readium 3.11.0 元数据/限定尺寸封面/TOC。
- SQLite 存储 Book/Chapter/ReadingPosition/Bookmark；事务与 import recovery。
- Readium 隔离引擎、基础 Reader、目录/书签跳转、两侧点击与手势分页、中央菜单、分页/滚动、位置保存/恢复。
- Reader 请求失效和旧回调过滤；SourceFileCopying 隔离平台复制与失败注入。
- 文件路径逐级检查，拒绝受管理存储内的符号链接/断链；先创建再规范化 root，兼容系统父级路径别名。
- 项目源 `project.yml`，两个 Swift Package，macOS GitHub Actions 与无签名 IPA 打包脚本。
- 四份指定根文档、恢复交接文档、XBook/无剧透草案、功能矩阵和性能计划。

## 验证与限制

- Windows 静态检查：结构/工程/CI/实际 SQL migration/EPUB 样书通过；30 个 Swift 文件 grammar 通过。
- Python 构建工具：6 tests 通过；Git Bash `bash -n` 与 Python compileall 通过。
- **Core 在官方 Swift 6.1.2 Linux 容器中编译成功，14 个 XCTest 全通过，命令 exit 0。** 原路径越界失败已修复，失败/成功日志均保留。
- CI 增加 Linux Core job 并锁定 image digest；Windows 容器脚本已实测成功及 engine 不可用失败分支，超时分支尚未实测。
- Docker 旧 AF_UNIX 端点阻塞启动的问题已有限修复，原运行目录保留备份，engine 已恢复；详见 Documentation/DOCKER_RECOVERY.md。
- **真实 CI run 38390862584 全部 success：Linux/macOS 各 14 Core tests、9 iOS tests、设备 Release 构建与 IPA 通过。** Apple 文件协调覆盖本地测试文件，未验收 iCloud/File Provider；模拟器实际页面体验、真机与 TrollStore 尚未验证。
- 已创建私有仓库 https://github.com/wan780839395-cyber/XianxiaReader，origin 已配置，main 已推送；connector 与本机 CLI 均已确认同一账户。本地作者仅在此仓库配置为 login 与 noreply 邮箱。
- 历史首次 run 38385729586：误链接宿主 SQLite，iOS tests 取消；已改为目标 SDK。真实解析的 11 个依赖纳入根 Package.resolved。
- 历史第二次 run 38389603242：缺 AppIcon，iOS tests 取消；已补齐真实图标。两项修复均已通过第三次 CI。
- 第三次 CI run 38390862584（head 184aa09355ed0f44e9e27763c5d44fa0a8161434）已通过前述所有门槛；前两条是保留的失败历史。产物为 build/XianxiaReader.ipa，SHA-256 847e61e3bb2de8227df59860fae86b561ebf4f839a3202fcd579098899e88d99，已核对 arm64/iOS 平台、系统 SQLite、ZIP 与 executable 权限。
- Docker 已升级至 4.95.0.242831，engine 29.8.2 正常响应，原有两个停止容器保留；升级后 Core 编译/14 个 tests 再次通过。首次 UAC 取消日志保留。
- 最新证据见 Documentation/M0_ACCEPTANCE.md、IOS_VALIDATION_REPORT.json（真实 CI）、CORE_VALIDATION_REPORT.json（本机 Linux Core）与 VALIDATION_REPORT.json（静态检查），三个范围分别记录。

## 下一步

正在 M1：首轮搜索 CI 38399996364 已全通过，20 iOS tests、设备 Release 和真实 IPA；Binding 警告已消除。已清理多余 ReadError cast，准备再次完整 CI；详细证据 M1_SEARCH_VALIDATION_REPORT.json 和设计 SEARCH_DESIGN.md。用户设备为 iPhone13/iOS16.6.1/已装 TrollStore，安装/页面体验尚待实测，不大规模进入 M2。
