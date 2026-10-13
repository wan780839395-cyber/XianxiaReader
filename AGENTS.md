# XianxiaReader Agent 规范

## 开始与恢复

1. 先读 `PROJECT_STATUS.md` → `HANDOFF.md` → `ROADMAP.md` → `ARCHITECTURE.md`；用户新指令优先。
2. 检查工作目录、Git 状态、工具、已有日志和实际文件；不要用聊天记忆替代事实。
3. 长任务开始、每个可恢复子步骤后、生成/构建/测试前更新 `HANDOFF.md`；中断后核实最后步骤是否完成。
4. 阶段结束同步 `PROJECT_STATUS.md`、HANDOFF 和必要设计文档。文档不能把待编译源码写成已验收功能。

## 产品边界

- 中文玄幻/仙侠/武侠长篇本地阅读体验优先；用户导入 EPUB/TXT。不是在线书城复制品。
- 严格按 M0→M1→M2→M3→M4→M5 门槛推进。未通过前阶段构建与测试，不大规模进入下一阶段。
- 当前 XBook 与知识库只有协议草案。不得提前铺开世界观 CRUD、抓取小说、云账号或社交系统。
- 禁止将 localhost HTTP server 作为主要预览方式；使用原生 iOS 构建/模拟器/真机。

## 架构与代码

- `XianxiaCore` 保持 Foundation/SQLite 业务边界，不导入 Readium/UIKit/SwiftUI。
- Apple SQLite 必须通过 SDK 的头文件和库链接；禁止让宿主 Homebrew 的 pkg-config 路径进入 iOS 交叉构建。Linux 使用系统 SQLite 开发包。
- UI 通过 `ReadingInterfaces` 操作引擎；Readium API 只存在 `ReadiumAdapter` 与它的集成测试中。
- EPUB 使用 Readium，不自建排版引擎。精确版本升级须查官方对应版本 API 并运行完整验证。
- `project.yml` 是工程唯一源，不手工修改生成的 `.xcodeproj`。新增文件需确保 XcodeGen 与 SwiftPM target/resource 正确。
- Swift Concurrency 隔离文件复制、索引和数据库；不在主线程读取/转码/解析整个 TXT；不让整本正文进入 ObservableObject。
- 原始书籍永久保留，缓存可重建；正文、缩略图、目录、搜索分别管理。路径持久化为相对路径，解析必须验证不越出存储根目录。
- 受管理存储内部禁止符号链接；校验不存在的目标也须检查父级节点及 dangling link。保留越界、正常缺失目录和根目录系统别名回归，不能只依赖完整路径的 `resolvingSymlinksInPath`。
- 数据 schema 升级使用新迁移和恢复测试；不可删除数据库来“修复”升级。写入错误须可见。
- 位置保存完整版本化 Locator，不能只存百分比；TXT 使用稳定章节与局部字节/文本锚点。忽略旧异步写入需有测试。
- 不通过 `try?`、空 `catch`、私有 API、`@unchecked Sendable`、删除测试或禁用错误来假装通过。允许的 best-effort 清理必须注明并保留原始失败；缺封面可降级但须有警告。

## 中文 TXT / 排版

- 分章识别器与 UI 分离；流式处理编码和跨块行；按章节窗口加载；缓存须绑定内容与 parser 版本。
- 八类章节标题与反例必须有回归。卷/章层级、序章与正文边界明确，64 位 byte offset/end-exclusive。
- 两字缩进、标点换行、标题和段落节奏需真实页面验收；不要把网页模板当排版完成。
- 深色正文避免纯白高亮；字体、布局变更不应破坏用户阅读位置。

## 无剧透硬边界

- 所有未来知识（人物/别名/境界/势力/物品/功法/地点/关系/事件/地图/摘要）必须具有章节揭示范围。
- 查询层收到当前已验证的 canonical chapter 后，最多返回已揭示记录；禁止先读取未来内容再由 UI 遮挡。
- 缺少/无效章节范围采用拒绝显示，不默认全书可见。EPUB TOC ordinal 不能未经映射直接作为小说章序。
- 构建日志、搜索建议、缓存和诊断不得泄漏未来章节内容。

## 验证与汇报

- Windows 上运行 `scripts/check_repository.py --swift-syntax` 和 Python tooling tests；语法检查不是编译。
- macOS 上跑 Core Swift tests；iOS target 跑 Readium/真实导入/位置集成测试；最终设备 Release build 使用 `CODE_SIGNING_ALLOWED=NO`。
- Linux Core 测试可使用锁定 digest 的官方 Swift 容器；Apple 文件协调分支仍须 macOS 验证。`SourceFileCopying` 不得在 iOS 上静默改用普通 copy。
- 关闭 reader 要使尚未完成的打开请求失效，并过滤旧回调；修改 async 生命周期时运行相应竞态/重试/迟到位置回归。
- Docker 等工具不可用时保留实际错误并终止自己启动的挂起任务，不重置用户工具或把测试“未执行”改写为“通过”。
- CI 必须保留 `set -euo pipefail`、真实 test/build 退出码、完整日志及失败诊断 artifact；不得跳过失败生成成功 IPA。
- 不伪造 `Package.resolved`。第一次真实解析后审阅并纳入锁文件，固定传递依赖。
- 根 `Package.resolved` 来自真实 CI；生成工程后复制到 workspace 的 swiftpm 目录，resolve/test/build 均严格使用锁文件。依赖升级需要重新真实解析和完整 CI。
- 自动检查、Swift 编译、模拟器阅读、普通设备、TrollStore 设备五种结果分开记录。没有测试环境仍继续可在 Windows 完成的工作，并明确剩余风险。
- 只提交源码、配置、文档和原创小样书，不提交个人小说、证书、令牌、大生成缓存或构建包。
- 完成报告包含文件、实现范围、尚未实现、验证结果、编译/设备风险及合理下一阶段；不得承诺在无新请求/自动化时自行永久运行。
