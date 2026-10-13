# 架构与技术决策

## 依赖方向

```text
App (SwiftUI / 组装 / Library / Import / Reader)
 ├── XianxiaCore (Foundation 模型、SQLite、文件事务、TXT 索引接口)
 ├── ReadingInterfaces (UIKit 渲染边界、领域类型、EPUB 元数据接口)
 └── ReadiumAdapter → ReadingInterfaces + XianxiaCore + Readium
```

`XianxiaCore` 没有 SwiftUI、UIKit 或 Readium 依赖，可在 macOS 独立测试。额外的 Linux Core 测试使用普通本地文件复制分支，Apple 构建必须保留 `NSFileCoordinator`；两条路径分别验证，不等价。`ReadingInterfaces` 与 `ReadiumAdapter` 是同一 Swift Package 中不同 target：App 通过协议控制阅读，只在组装位置创建具体工厂。替换引擎时实现同样的协议并替换组装，不改变数据库和书库视图。

相比把所有目录平铺在根目录，使用 `App/` + 两个 `Packages/` 强制依赖边界，并允许 Windows 编辑、macOS Core 测试及 iOS 适配测试分别进行。Search/Themes/Settings 在对应 milestone 才新增实际模块，避免用空文件和假实现表示完成。

## 布局

```text
App/
  XianxiaReaderApp.swift / AppRootView.swift / AppServices.swift
  Library/             基础网格、缩略封面、状态
  Import/              security-scoped URL 生命周期、导入编排
  Reader/              引擎桥接、菜单、目录、书签与保存
  Resources/           Info.plist、颜色资源
Packages/
  XianxiaCore/
    Sources/CSQLite/    系统 SQLite3 modulemap
    Sources/XianxiaCore/
      Models/          Book、Chapter、ReadingPosition、Bookmark
      Database/        repository、连接、版本化 SQL migration
      Import/          文件暂存、提交、回滚、恢复
      TXT/             M2 索引协议；尚无解析器
    Tests/
  XianxiaReading/
    Sources/ReadingInterfaces/
    Sources/ReadiumAdapter/
Tests/iOS/             Readium、真实导入、Locator 测试
Tests/Fixtures/        原创 EPUB 2/3
Future/XBook/          容器协议草案
Future/Knowledge/      无剧透数据设计草案
Documentation/         功能矩阵、验证与性能计划
scripts/               结构验证、样书、CI 与 IPA 打包
.github/workflows/     macOS 构建及诊断输出
```

## 平台与语言

- iOS 16 起步，优先覆盖普通设备及部分 TrollStore 使用场景；不代表所有系统版本都有 TrollStore 安装能力。
- SwiftData 需要更高系统基线，因此 M0 使用系统 SQLite3。ORM 可以以后替换，`BookRepository` 屏蔽 UI 对具体存储的依赖。
- Swift tools 5.10、Swift 5 语言模式配合 Xcode 16.4。并发检查当前为 targeted；Readium Publication 在后台 loader actor 与主线程 Navigator 间传递，需在真正构建中检查警告和线程行为。不得用无依据的 `@unchecked Sendable` 或关掉错误来伪造验证通过。
- `project.yml` 为工程配置源。`.xcodeproj` 由锁定 XcodeGen 生成并在 CI 输出，不手写 PBX 文件，避免 Windows 维护重复配置。
- Readium 精确锁定 3.11.0，API 已对照同标签源码。传递依赖还需首次 macOS resolution；解析后锁文件随诊断上传。获得首次成功结果后审阅并把应用的 `Package.resolved` 纳入版本控制，再增加严格锁文件验证。当前不伪造一个未经解析的锁文件。

## 持久化与文件一致性

领域模型使用稳定 UUID；路径是应用存储根目录下的相对路径，避免 iOS 沙盒绝对路径随安装变化。正文存为文件，数据库仅存元数据、目录和 Locator，不把数百万字正文塞进数据库 JSON。

存储根目录先创建再解析系统父级链接（例如 Apple 的系统路径别名）；其内部由项目管理的路径不允许符号链接。解析相对路径时逐级检查已存在的节点，也拒绝 dangling link，不能只对完整路径调用 `resolvingSymlinksInPath`：Linux Foundation 在末端不存在时可能原样返回并遗漏父级链接。普通尚未创建的书籍目录仍可解析，其他文件错误正常传播。此校验适用于应用私有存储，不声称提供抵抗外部进程并发替换目录的操作系统级文件句柄隔离。

SQLite 由 `SQLiteBookRepository` actor 独占连接。启用外键、WAL、busy timeout、预编译绑定；迁移通过 `user_version` 管理。未知高版本数据库显式拒绝打开，不删除用户数据。Book 与其目录在同一事务插入；章节按 `(book_id, ordinal)` 索引，书签按书籍索引。

M0 为简单演进，将领域 record 编码为 JSON BLOB，并保留关系、排序和查询列。后续全文搜索使用单独 FTS/增量索引，不能扫描全部 BLOB；schema 变化需要 migration 和升级测试。未来关系库不在当前 schema 提前铺开。

导入顺序：

1. App 持有 Document Picker 的 security-scoped access，直到整个导入结束。
2. FileStore actor 通过 `SourceFileCopying` 复制到 `Staging/<id>/book.epub`，避免将全部文件读成内存 Data。默认 Apple copier 使用 `NSFileCoordinator`；Linux 验证使用普通 local copy，测试可注入写入部分文件后失败的 copier。
3. Loader actor 通过 Readium 识别实际格式、检查 DRM/reading order，读取元数据、TOC 和限定尺寸封面。
4. 移动到 `Books/<id>/`，再提交 Book + TOC 数据库事务。
5. 失败时移除该 UUID 暂存/成品。重启先查询数据库，再清理未提交的 UUID 文件夹；已知书籍不会被清理。清理仅在导入开始前运行。

文件移动与 SQLite 不是跨系统原子事务；上述提交顺序与重启恢复覆盖“文件已移动、DB 未提交”的中断窗口。若清理失败，向用户报告；不能吞掉错误声称导入成功。M3 删除采用单独可恢复事务方案，当前没有草率添加删除功能。

封面错误可以降级为标题封面，但必须保留导入警告。暂无内容 hash 去重；相同文件再次导入生成独立 UUID，不将其描述为去重完成。

## 阅读与位置

Readium 负责 EPUB 解析、EPUB Navigator、分页/滚动、CSS、图片、内部链接及后续搜索/Decoration/TTS/Preferences；本项目只构建控制层和产品 UI。M0 不覆盖全套 Readium 能力。

`ReaderEngine` 提供渲染控制器、分页、章节/位置跳转、滚动模式、事件回调；业务层只持有 `ReadingPosition`。持久化完整 Locator JSON，包括 href、fragment、资源/全书 progression 与文本上下文，并带 `engineID`/版本。不能用一个浮点百分比代替可靠位置恢复。

保存每次位置回调；SQLite UPSERT 按 `updated_at` 拒绝过期写入，处理异步任务顺序颠倒。关闭阅读与进入后台额外保存。损坏/不兼容 Locator 显式报错，不能静默归零。首次成功定位前“正在打开”不等于已读。

TOC 导入时持久化，打开目录只读取现有数组。EPUB TOC 可能含卷、分组、子节，界面使用“目录条目”，不能把数量伪装成精确小说章节总数。未来 XBook 知识范围需要独立 canonical chapter mapping。

输入通过 Readium observers 处理，不叠加透明 SwiftUI 点击层遮挡链接和选择。当前左右 30% 翻页、中间 40% 切换菜单；滚动模式保留正常滚动。菜单覆盖空间、字体变化与旋转定位需 M1/M4 真机验收。

引擎和 ViewModel 的每次打开请求具有独立 UUID。`close` 使悬挂的 publication load 失效；load 返回时先检查请求仍有效，再挂载控制器/发布 ready。旧请求不能关闭较新的 session，旧 Navigator 的 delegate 回调也不能更新当前书的阅读位置。关闭后的迟到 position 回调在 ViewModel 被拒绝；正常关闭时的最终位置回调仍保留。

## TXT 预定实现（M2）

仅定义 `TXTIndexing` 接口。实现必须独立于 UI，用后台流式转码/分块解析，处理跨块 UTF-8/UTF-16/GB18030 字符与跨块章节行。正文标准化为 UTF-8 旁路文件，章节记录 64 位字节区间，章节末尾为 exclusive end。阅读只加载当前及相邻章节窗口，不能将整本 String 发布到 UI。

索引 cache key 至少包含内容 SHA-256、编码/标准化版本、parser version；实现一次索引、重开复用。支持无章节、序章、卷与章层级、超长单行、误识别正文以及取消/磁盘不足恢复。具体阈值见性能测试计划。

## 后续扩展

Highlight / Note 和 Character / Realm / Faction / Item / Technique / Location / Relationship / StoryEvent 目前仅登记设计边界，不建空实体库。引擎 Decoration/Search/TTS 与产品服务分离；用户选择与已揭示知识由应用自己的服务维护。

无剧透原则是数据读取边界：查询接口必须接收已验证的章节范围，只返回此范围内的记录；不能先读未来内容再在 UI 隐藏。XBook 协议和知识草案位于 `Future/`，不进入应用 target。
