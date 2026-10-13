# 项目状态

更新时间：2026-10-13（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | Windows 检查与 Linux Core 编译/14 tests 通过；macOS gate 待验证 | 工程定义、文档、CI、隔离接口、基础测试已写入 |
| M1 基础 EPUB | 基础导入/阅读验证切片已写入，未验收 | 先取得 M0 build/test 结果，再完成搜索与阅读体验验收 |
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
- **iOS 9 个 Swift 测试、Apple 文件协调、Xcode build、模拟器阅读、真机与 TrollStore 尚未验证；没有真实 `XianxiaReader.ipa`。**
- 用户已选择私有 GitHub 仓库；connector 与本机 CLI 均已确认 `wan780839395-cyber`（id 284319074），本地作者仅在此仓库配置为该 login 与 noreply 邮箱。初始提交 `a6466a6` 已保存 80 个项目文件；已核对目标仓库返回 404，正在创建私有远端并准备首次推送。当前提交/工作区以 `git log/status` 为准。
- Docker 重试 UAC 后已升级至 4.95.0.242831（安装日志/文件版本确认），正在核实新版 engine；此时不把安装完成标为引擎验证通过。首次 UAC 取消日志保留。
- 最新证据见 Documentation/VALIDATION.md、CORE_VALIDATION_REPORT.json（真实 Core 编译/测试）与 VALIDATION_REPORT.json（静态检查）。两份 JSON 的验证范围不同。

## 下一步

在 macOS 执行构建，或获得 GitHub 仓库后执行现成 CI；修复实际日志中的编译问题并固定解析后的依赖。M0 通过后推进 M1 搜索与设备阅读验收，再进入 TXT。
