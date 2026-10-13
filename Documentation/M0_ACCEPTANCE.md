# M0 自动验收记录

2026-10-13：**M0 构建、测试与打包通过，允许开始 M1。** 这不是完整 MVP 或设备阅读体验验收。

私有仓库：[XianxiaReader](https://github.com/wan780839395-cyber/XianxiaReader)。成功 CI：[38390862584](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38390862584)，实际提交 `184aa09355ed0f44e9e27763c5d44fa0a8161434`。

| 门槛 | 结果 |
| --- | --- |
| 工程生成 | XcodeGen 2.46.0 成功生成实际 Xcode 工程 |
| 编译环境 | Xcode 16.4 / Apple Swift 6.1.2，macOS 15.7.9；iOS 18.5 模拟器 |
| 仓库与构建工具 | 30 Swift grammar 文件、结构/SQL/EPUB、6 Python 工具测试通过 |
| Linux Core | Swift 6.1.2，14 XCTest 全通过 |
| Apple Core | macOS 真正编译，14 XCTest 全通过；本地文件的 NSFileCoordinator 分支 |
| iOS 集成 | 9 XCTest、0 failures；真实 EPUB 2/3 解析、导入/回滚、Navigator 构造、Locator 和 Reader 生命周期 |
| 设备应用 | generic iOS Release 构建成功，CODE_SIGNING_ALLOWED=NO |
| IPA | 已生成、下载并验证 ZIP/Payload/arm64 Mach-O/iOS platform/0755 executable |
| 可复现依赖 | 11 个真实解析 pins，所有 xcodebuild 严格使用 Package.resolved；CI 生成 pins 与提交一致 |

产物 `build/XianxiaReader.ipa`（7,286,692 bytes），SHA-256：

```text
847e61e3bb2de8227df59860fae86b561ebf4f839a3202fcd579098899e88d99
```

完整日志 `build/logs/ios-build.log`；原件、`.xcresult`、生成工程与环境在 `build/ci/38390862584/ios/`。GitHub artifact 为 XianxiaReader-build-diagnostics / XianxiaReader-core-diagnostics / XianxiaReader-unsigned-ipa，保留 14 天。本机文件不随 clone，报告保存日志和源文件 hash；若 artifact 到期，重新运行已锁版本的 CI。

机器可读证据见 IOS_VALIDATION_REPORT.json。CORE_VALIDATION_REPORT.json 和 VALIDATION_REPORT.json 分别是本机 Linux 与静态检查范围，不能混用布尔字段。此前两次失败及修复见 CI_FAILURES.md，未删除数据库、图标设置或失败测试。

验收收尾提交仅更新文档/证据，45 个构建来源文件已逐一核对与成功 SHA 一致，使用 GitHub 支持的 [文档提交跳过 CI 标记](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs)。应用、测试、工程和 CI 脚本没有变更，成功验证仍对应上述 SHA；后续代码变更必须完整 CI。

## 剩余边界

- M0 当时的 Swift 5 targeted 模式有一处 ReaderView Binding 到 Sendable closure 的编译警告；不是零警告构建。M1 先修复明确隔离，再单独规划 Swift 6 严格模式。
- CI 还有 Actions Node 20 弃用与 ubuntu-latest 镜像迁移提示，应独立升级/固定并验证；这些不是本次构建失败原因。
- Navigator 构造与 API 测试没有验收正文实际渲染、中文标点/标题节奏、页面点击和图片/内部链接。iOS 16 设备兼容性、iCloud/File Provider、普通签名/TrollStore 安装仍未验证。
- TXT、完整书库编辑、搜索、字体/主题/排版设置、音量键与长篇性能测试待对应阶段；XBook/世界观知识库只有草案。

下一步 M1：先处理隔离警告，再增量搜索与结果跳转，完成真实 EPUB 阅读/恢复/交互验收。M1 通过前不大规模进入 M2。
