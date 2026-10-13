# 项目状态

更新时间：2026-10-13（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | **自动验收通过** | Linux/macOS Core、9 iOS tests、设备 Release 与真实 IPA 均成功 |
| M1 基础 EPUB | **搜索与导入修复自动验证通过**；完整阶段未验收 | 26 iOS tests、Build 2 Release/IPA；本机/iCloud 导入及真实阅读待验收 |
| M2 TXT | 未开始 | 后台流式分章、索引缓存与长文件测试 |
| M3 完整书库 | 未开始 | 完整编辑、封面修改与操作一致性 |
| M4 设置与主题 | 未开始 | 排版、字体、主题与交互验收 |
| M5 性能 | 未开始 | 超长书、内存、恢复与性能基线 |

## 当前实际实现

- SwiftUI 基础网格书库，封面/书名/作者/最近阅读/可用进度展示。
- EPUB Files 导入：UIKit 明确导入副本模式、宽类型选择/严格后缀与 Readium 实际格式校验、一次 delegate 回调/取消、sheet 关闭后交接；后台协调复制、Readium 3.11.0 元数据/限定尺寸封面/TOC。内置两本原创 EPUB 可通过相同流程导入，提供可见完成反馈。
- SQLite 存储 Book/Chapter/ReadingPosition/Bookmark；事务与 import recovery。
- Readium 隔离引擎、基础 Reader、目录/书签跳转、两侧点击与手势分页、中央菜单、分页/滚动、位置保存/恢复。
- Reader 请求失效和旧回调过滤；SourceFileCopying 隔离平台复制与失败注入。
- 引擎搜索协议、Readium SearchService 扩展、分批/取消/迟到回调过滤与结果跳转委托。每批 40、片段上下文各 64、界面最多 1000 条；不跨文本元素/资源匹配。
- 文件路径逐级检查，拒绝受管理存储内的符号链接/断链；先创建再规范化 root，兼容系统父级路径别名。
- 项目源 `project.yml`，两个 Swift Package，macOS GitHub Actions 与无签名 IPA 打包脚本。
- 四份指定根文档、恢复交接文档、XBook/无剧透草案、功能矩阵和性能计划。

## 验证与限制

- Windows 静态检查：结构/工程/CI/实际 SQL migration/EPUB 样书通过；39 个 Swift 文件 grammar 通过（不是编译）。
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
- 之前 CI 38402285563（b95aa4d）success：Linux/macOS 各 14 Core、20 iOS tests、Release 与 IPA 全通过，应用源码 compiler warnings=0，依赖 pins 不变。
- 上一搜索 IPA 原件 build/ci/38402285563/ipa/XianxiaReader.ipa：7,365,913 bytes，SHA-256 9673200a941600e2224870da6d006fa35679abc98a166887d5f4bb1151fd2365；原测试 ZIP 已另存此 run 目录。
- 用户确认 iPhone13 / iOS16.6.1 / TrollStore：旧包安装正常；EPUB 在 iCloud 选择后按“打开”无反应，导入验收失败，阅读无法继续。Build 2 修复已过 CI，真机待复测；TXT 尚未实现。
- 最新 CI 38411028842（0649833a2b48b5be3ea3ec24f8c62bd8d0dffef9）全部 success：Linux/macOS 各 14 Core、26 iOS tests、设备 Release 与 IPA。应用源码 compiler warnings=0；另有 6 条 AppIntents metadata 提取提示，已完整保留，非源码编译错误。11 个依赖 pins 不变。
- 最新 Build 2 IPA build/XianxiaReader.ipa：7,386,778 bytes，SHA-256 fb3bf3adb825e1d40e97c962188aac238a05012ba1e36e07367d5d3eab38b181；测试 ZIP 7,287,337 bytes。核验 ZIP/arm64/iOS/0755/最低 iOS16、Build 2、打包样书与源码一致、54 构建文件逐一匹配已测提交。
- 首轮导入 CI 38409222759 由 Agent 误读旧网页日志而提前取消；完整日志已证实各 14 Core 与 26 iOS tests 通过，设备 Release 中断，无 IPA。原日志/xcresult 与 ValidationLogs/m1-import-cancelled.json 保留；同代码完整重试成功。
- 最新证据 M1_IMPORT_VALIDATION_REPORT.json / IMPORT_FIX.md。M1_SEARCH_VALIDATION_REPORT.json 是之前搜索切片，IOS_VALIDATION_REPORT.json 是历史 M0，CORE_VALIDATION_REPORT.json 是本机 Linux，VALIDATION_REPORT.json 是静态检查；各 scope 独立。

## 下一步

用户确认 Build 2 后 EPUB 可以导入；截图显示阅读图片只剩窄横条，章节切换不方便。当前优先修复 M1 图片/渲染容器及章节导航，并加入真实页面回归；本地/iCloud 来源未细分，其他阅读项目尚待实测。M1 完整门槛未放行，不进入 M2。
