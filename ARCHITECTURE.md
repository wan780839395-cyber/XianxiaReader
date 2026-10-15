# 架构与技术决策

## Build17 阅读手感第一片（验证中）

Foundation领域ReadingInteraction与独立BookFileStore actor JSON保存交互偏好，不改变appearance-v1/schema3/Locator。ReadingInterfaces可选ReaderInteractionProviding隔离动效与被动手势，Adapter统一导航options/关闭身份与分页防重入，UI只持领域值。首候选97/99，正常拖动未收菜单仍诊断，源码不等价验收；当前精确边界与后续修正见READING_MOTION_DESIGN.md及HANDOFF.md。

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
      TXT/             M2标题识别/有界窗口/严格正规化/摘要cache/产品导入与读取范围
    Tests/
    Benchmarks/TXTPerformanceProbe/  独立桌面Release测量工具，iOS App不链接
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

M2长篇验证使用Core package内独立`TXTPerformanceProbe` executable，依赖公开Core API，不把Darwin/Glibc测量调用放入Core业务target。`scripts/run_txt_performance.py`流式生成原创临时样本并逐样本分进程运行，实际Apple/Linux复制、缓存和数据库路径分别测量；进程退出后再清理临时数据库。iOS App仅依赖library product，测试工具不进安装包。完整测量JSON/log作为CI诊断上传，小摘要进入交接；契约见PERFORMANCE_TEST_PLAN.md。

## 平台与语言

- iOS 16 起步，优先覆盖普通设备及部分 TrollStore 使用场景；不代表所有系统版本都有 TrollStore 安装能力。
- SwiftData 需要更高系统基线，因此 M0 使用系统 SQLite3。Apple 构建通过 modulemap 使用目标 SDK 的头文件和库；不能使用宿主 Homebrew 的 pkg-config，否则 iOS 会误链接 macOS dylib。Linux 安装 libsqlite3-dev，使用标准系统搜索路径。ORM 可以以后替换，`BookRepository` 屏蔽 UI 对具体存储的依赖。
- Swift tools 5.10、Swift 5 语言模式配合 Xcode 16.4。M1 搜索 CI 38402285563 已通过，targeted 模式的 Binding 警告已修复，应用源码编译零警告。Readium Publication 在后台 actor 与 MainActor 间的交接以及 Swift 6 严格模式迁移仍须独立审查，不用无依据的 `@unchecked Sendable` 或关闭检查伪造通过。
- `project.yml` 为工程配置源。`.xcodeproj` 由锁定 XcodeGen 生成并在 CI 输出，不手写 PBX 文件，避免 Windows 维护重复配置。
- Build3使用官方Readium3.11.0/11 pins。连续模式候选切换为 `Vendor/ReadiumToolkit` 本地维护扩展，基线revision仍为 `d82f44f4f05d87add9e22a8b75abbd61dce745dd`；来源/精确文件hash/许可/本地修改在UPSTREAM.json，不是官方合并功能。根 `Package.resolved` 原样来自macOS真实解析run38496501326，实际6 pins与旧锁版本/revision/location相同；未使用的server/SQLite/LCP依赖被SwiftPM裁剪，细项保留在来源记录。首轮解析不代表编译验收。生成工程后复制锁到workspace，resolve/test/build严格使用 `-onlyUsePackageVersionsFromResolvedFile`；bootstrap仅用于明确首次解析，采用真实artifact后必须关闭并完整重跑。

## 持久化与文件一致性

领域模型使用稳定 UUID；路径是应用存储根目录下的相对路径，避免 iOS 沙盒绝对路径随安装变化。正文存为文件，数据库仅存元数据、目录和 Locator，不把数百万字正文塞进数据库 JSON。

存储根目录先创建再解析系统父级链接（例如 Apple 的系统路径别名）；其内部由项目管理的路径不允许符号链接。解析相对路径时逐级检查已存在的节点，也拒绝 dangling link，不能只对完整路径调用 `resolvingSymlinksInPath`：Linux Foundation 在末端不存在时可能原样返回并遗漏父级链接。普通尚未创建的书籍目录仍可解析，其他文件错误正常传播。此校验适用于应用私有存储，不声称提供抵抗外部进程并发替换目录的操作系统级文件句柄隔离。

SQLite 由 `SQLiteBookRepository` actor 独占连接。启用外键、WAL、busy timeout、预编译绑定；迁移通过 `user_version` 管理。未知高版本数据库显式拒绝打开，不删除用户数据。Book 与其目录在同一事务插入；章节按 `(book_id, ordinal)` 索引，书签按书籍索引。

M0 为简单演进，将领域 record 编码为 JSON BLOB，并保留关系、排序和查询列。后续全文搜索使用单独 FTS/增量索引，不能扫描全部 BLOB；schema 变化需要 migration 和升级测试。未来关系库不在当前 schema 提前铺开。

导入顺序：

1. App 使用 UIKit Document Picker 的 `asCopy: true` 请求本地导入副本，允许 data 类型选择，再验证 `.epub` / `.txt` 后缀与实际内容。一次 delegate 完成后，LibraryViewModel 立即开始导入或报告错误，不等待 onDismiss；Coordinator 由书架持有到终止回调，completion 弱捕获 model，新presentation失效旧Coordinator，结果消费后释放。文件/编码共用单个 LibrarySheet item sheet，错误持久显示在书架，避免另一个alert争抢呈现。若 URL 提供 security-scoped access，持有到导入完成。首次关闭无书籍/无提示的新反馈及原生回归见 IMPORT_DELEGATE_FIX.md（Build6设备首次失败，旧交接文档仅保留历史）；此前类型/副本修复 CI38411028842 / 26 tests 是历史证据，不能证明首次 sheet 或真实 File Provider 通过。
2. FileStore actor 通过 `SourceFileCopying` 复制到 `Staging/<id>/book.epub`，避免将全部文件读成内存 Data。默认 Apple copier 使用 `NSFileCoordinator`；Linux 验证使用普通 local copy，测试可注入写入部分文件后失败的 copier。
3. Loader actor 通过 Readium 识别实际格式、检查 DRM/reading order，读取元数据、TOC 和限定尺寸封面。
4. 移动到 `Books/<id>/`，再提交 Book + TOC 数据库事务。
5. 失败时移除该 UUID 暂存/成品。重启先查询数据库，再清理未提交的 UUID 文件夹；已知书籍不会被清理。清理仅在导入开始前运行。

文件移动与 SQLite 不是跨系统原子事务；上述提交顺序与重启恢复覆盖“文件已移动、DB 未提交”的中断窗口。若清理失败，向用户报告；不能吞掉错误声称导入成功。M3 删除采用单独可恢复事务方案，当前没有草率添加删除功能。

封面错误可以降级为标题封面，但必须保留导入警告。暂无内容 hash 去重；相同文件再次导入生成独立 UUID，不将其描述为去重完成。

## 阅读与位置

Readium 负责 EPUB 解析、EPUB Navigator、分页/滚动、CSS、图片、内部链接及后续搜索/Decoration/TTS/Preferences；本项目只构建控制层和产品 UI。M0 不覆盖全套 Readium 能力。

SwiftUI 的 `ReaderSurface` 使用显式 viewport 尺寸，菜单只叠加在阅读区域之上，不参与正文尺寸计算。Adapter 在挂载 Navigator 时设置有效 frame 和 autoresizing，与上游 SwiftUI 容器合同一致。图像/CSS 仍由 Readium 解析、排版，不修改用户 EPUB 或全局强制覆盖作者图像样式。

横排重排媒体仅校准 ReadiumCSS 已有的 `--RS__maxMediaHeight` 保护：公开 setupUserScripts 钩子按真实 `innerHeight` 的95%设定像素上限，resize同步；避免WebKit的device-height/vh与实际正文视口不一致。不改作者width/aspect/object-fit，固定布局和竖排不接入此修正。原图/CSS仍保留，实际图像尺寸与原书体验分别验收。

Build3的官方Readium3.11 `scroll` 仅章内滚动。Build4连续候选通过 `ReadingInterfaces` 可选能力接入本地Navigator扩展，外部UIScrollView只分配有界已加载资源，每章WKWebView保持视口尺寸；显示加载边界，最多12个资源并按可见距离回收。仍复用Readium资源服务/CSS/正文DOM，不拼接全书或分配数千章空白。横排LTR重排支持范围显式检查；固定布局/RTL/竖排保留原路径。CI38530334549/d62af3b完整自动回归、设备Release/IPA通过，用户已确认连续功能和重开位置可用。旧边界PNG证据限制保留，未逐项确认的设备/内存/旋转等继续记录，详见 `Documentation/CONTINUOUS_SCROLL_DESIGN.md`。

连续候选位置保持标准Locator href/CSS/text/progression，并附加DOMRange字符位置及版本化局部视口偏移；只取64字符上下文。超长单段不退回段首。原搜索Locator继续走Readium文本定位；仅标记过的连续保存锚点使用精确字符恢复。异步位置/测量结果核对资源epoch和视口revision，未加载资源不发出假位置。close显式取消窗口任务、恢复待定位continuation并移除JS handlers。上述自动回归及600点滑动后字符/重开3px门槛在CI38530334549通过，不能代替实际设备体验。

模式转换先异步取得实际DOM锚点，request ID/Task取消与Navigator identity防止迟到切换作用于新session。Readium的isSpreadLoaded早于延迟初始定位/decoration完成，因此增加显式完整初始化等待，clear也恢复等待者；原生go期间暂缓容器覆盖inner offset。go后读取DOM scrollY作为实际坐标，显式目录/搜索/书签定位原子提交外层offset，普通拖动/惯性与按屏滚动保留原路径。所有修复以完整CI为准，不能仅凭可见DOM就把位置恢复写成验收通过。

显式跳转通过同一次JS执行原Readium定位并读取scrollY；位置保存则原子读取Locator/documentY/documentTop，发生DOM与原生视口不一致时最多采样3次，每次都核对epoch/revision/当前slot，不无限等待。原生didFinish公开WK探针启动同一完整初始化管线，避免后台rAF加载桥暂停；回收取消任务并解除等待链。已通过41项iOS自动验证，用户确认连续功能/重开位置正常；未单独报告的其他页面/设备项目仍待验收。用户要求卡点参考成熟实现，已审阅epub.js/Foliate/Readium连续方案；具体适用范围与保持原架构的取舍见 `Documentation/MATURE_READER_REFERENCES.md`。

回收章节的clear还必须断开spread、WKNavigationDelegate/WKUIDelegate和内层scroll delegate；已clear的WebKit进程终止以及取消加载完成回调不能要求当前Navigator重载。公开后首次CI38511938460为37/39，历史失败已保留；迟到termination真实窗口回归及全部41项在38530334549通过，不能据此把每一处旧失败都归为同一原因。

实际窗口测试通过公开 UIKit/WebKit API 检查 DOM、完整原生 Locator 和可视区域。DOM `readyState` 与 Readium 原生位置就绪分别等待；预加载 WebView 必须在两个轴上与 viewport 重叠才算当前页。快照保存在 xcresult，几何断言与视觉复查分别记录；原创样书通过不代表用户书籍完成设备验收。

`ReaderEngine` 提供渲染控制器、分页、章节/位置跳转、滚动模式、事件回调；业务层只持有 `ReadingPosition`。持久化完整 Locator JSON，包括 href、fragment、资源/全书 progression 与文本上下文，并带 `engineID`/版本。不能用一个浮点百分比代替可靠位置恢复。

保存每次位置回调；SQLite UPSERT 按 `updated_at` 拒绝过期写入，处理异步任务顺序颠倒。关闭阅读与进入后台额外保存。损坏/不兼容 Locator 显式报错，不能静默归零。首次成功定位前“正在打开”不等于已读。

TOC 导入时持久化，打开目录只读取现有数组。EPUB TOC 可能含卷、分组、子节，界面使用“目录条目”，不能把数量伪装成精确小说章节总数。未来 XBook 知识范围需要独立 canonical chapter mapping。

输入通过 Readium observers 处理，不叠加透明 SwiftUI 点击层遮挡链接和选择。当前左右 30% 翻页、中间 40% 切换菜单；滚动模式保留正常滚动。菜单覆盖空间、字体变化与旋转定位需 M1/M4 真机验收。

引擎和 ViewModel 的每次打开请求具有独立 UUID。`close` 使悬挂的 publication load 失效；load 返回时先检查请求仍有效，再挂载控制器/发布 ready。旧请求不能关闭较新的 session，旧 Navigator 的 delegate 回调也不能更新当前书的阅读位置。关闭后的迟到 position 回调在 ViewModel 被拒绝；正常关闭时的最终位置回调仍保留。

## M1 搜索切片

引擎提供可选 ReaderSearchProviding / ReaderSearchSession，actor 隔离读取游标。UI 仅持有 Sendable 命中 DTO 与完整 ReadingPosition；位置跳转复用 ReaderEngine.go。关闭/改词取消 task 和 session，通过 request ID 拒绝迟到数据；清理前先解除当前 session 引用，避免 await 返回后覆盖较新查询。

锁定的 Readium3.11 默认 ContentSearchService 存在组合字形拼接偏移缺陷，因此使用官方 SearchService factory 扩展；Readium 仍负责正文解析/DOM locator。服务按 TextContentElement 的 joined String 原生索引匹配，每批40、上下文各64；界面最多1000条、手动加载更多，不报告未计算的全书总数。跨 inline segment 可匹配，跨元素/资源不可；不开放 regex。实现与上游依据见 Documentation/SEARCH_DESIGN.md。

原9+新增11 iOS tests 已过真实 CI，尚未验收页面命中定位。Readium 内部按整个 XHTML 解析，超大单资源内存/取消延迟留 M5 实测；正文全文搜索与未来知识库的章节范围查询分别管理。

## TXT 实现边界（M2）

产品接入已过CI38559906005/37eb86a各68 Core/46 iOS/Build5 Release。Core TXTBookImportService复用原件协调复制/cache/文件提交/数据库事务与UUID恢复，Book可选txtEncoding兼容旧payload；Adapter通过公开Publication/Container/惰性DataResource仅按64KiB窗口转XHTML。TXT独立readium.txt完整位置envelope绑定内容/版本、稳定章ID、byte/UTF16与原生Locator，后台边界验证及await后request/Navigator检查。UI经ReadingInterfaces.currentChapters与可选search操作，Readium不进入Core，SQL schema/远程锁/Readium版本未改；本地连续selector仅对显式TXT标记保留唯一字节ID，准确更新UPSTREAM hash，普通EPUB仍原路径。设计TXT_READING_DESIGN.md；设备/长书/排版边界仍待验收。

第二切片已过完整CI38547339868/65c1b8d：各60 Core、41 iOS与设备Release。业务仍为Foundation/SQLite，与Readium/UI隔离。GB18030内部CTextCodec：Apple使用公开SDK CoreFoundation（GB_18030_2000/lossByte=0），Linux用glibc iconv，无新远程依赖/Homebrew路径。Apple系统iconv首轮实际四字节回归失败原件保留，更换接口后原断言及扩展向量全部通过。UTF8/UTF16严格增量校验/解码，SHA256绑定原/normalized/目录身份；cache generation原子manifest只存校验过的相对路径。平台codec ID用于缓存失效，复用仍流式核验摘要；当时产品TXT导入/阅读尚未接入；最新接入以上方Build5为准。细节见TXT_INDEX_DESIGN.md。

第一切片新增 `TXTChapterHeadingRecognizer`、`TXTUTF8ChapterScanner`与`TXTChapterWindowReader`；在Core actor扫描已规范化UTF-8正文，严格跨块校验、CRLF/BOM/长行处理，返回卷分组与叶子Int64/end-exclusive范围，按不越章的有界窗口读取。已过CI38538141364/0643093（attempt2各33 Core、41 iOS、设备Release）；`StreamingTXTIndexer`已实现正规化+索引facade，`TXTIndexCache`已实现cache；该历史节点产品导入/阅读未接入；目前已由上方Build5独立集成验证。

实现独立于UI，后续后台流式转码必须处理UTF-16/GB18030边界，将正文标准化为UTF-8旁路文件并保留原件；阅读只加载当前/相邻窗口，不能将整本String发布到UI。卷不重复正文范围；卷标题与卷序文字保留在叶子范围，不丢失未识别前言。标题ID以同bookID/字节位置稳定生成，内容改变须cache失效，不能跨不同正文复用位置。

索引 cache key 至少包含内容 SHA-256、编码/标准化版本、parser version；实现一次索引、重开复用。支持无章节、序章、卷与章层级、超长单行、误识别正文以及取消/磁盘不足恢复。具体阈值见性能测试计划。

## 后续扩展

Highlight / Note 和 Character / Realm / Faction / Item / Technique / Location / Relationship / StoryEvent 目前仅登记设计边界，不建空实体库。引擎 Decoration/Search/TTS 与产品服务分离；用户选择与已揭示知识由应用自己的服务维护。

无剧透原则是数据读取边界：查询接口必须接收已验证的章节范围，只返回此范围内的记录；不能先读未来内容再在 UI 隐藏。XBook 协议和知识草案位于 `Future/`，不进入应用 target。

## 2026-10-15 TXT ANSI 与范围缓存

Build9新增GBK/CP936、Big5/CP950、Windows-1252严格流式转换；App枚举选择、实际检测结果仍通过Core/导入协议，不持有Readium Locator。自动BOM/严格UTF8后按中文GBK/GB18030，其他手选；Apple SDK与Linux系统iconv独立向量验证。Apple CP936单独euro官方映射小桥接仅在完整字符边界，不改GB18030。Normalizer/parser/Locator v1、旧codec身份保持，自动策略独立v2 cache key；新codec由index携带以验证anchor，旧自动UTF8cache重建后旧完整位置回归通过。

TXTReadingPlanCache只持久resource范围与内容/章节/codec/版本身份，8MiB元数据限额、原子写入、重新路径检查；新Loader先获取TXTIndexCache完整摘要已验证index，后读范围cache。仍全量digest，复用边界最多每resource两次单字节读取，与旧planner最大scalar窗口一致；损坏重建、取消/IO/路径错误可见。Core仍无UIKit/SwiftUI/Readium，ReadiumAdapter公开Publication服务/有界正文与Locator边界不变。完整设计与官方/成熟参考见Documentation/TXT_ANSI_COMPATIBILITY.md，真实各80Core/58iOS及Release9证据见最新报告；设备结果独立。

## M3 书库浏览与改名

LibraryPresentation仅处理书名/作者元数据筛选、稳定排序和已保存进度；LibraryViewModel注入UserDefaults持久化布局/排序，用refresh请求ID拒绝较旧结果；LibraryView基于原生LazyVGrid/LazyVStack和共享LibrarySheet，长按进入BookRenameSheet。File Provider原delegate生命周期不变；新sheet以book.id区分状态，保存中不能互动关闭，错误留在表单。

Core新增BookTitle验证与BookRepository.renameBook，SQLite事务helper返回泛型提交值，BEGIN IMMEDIATE后读最新payload只改title。无schema变更、不用UI旧Book覆盖author/cover、不变原件路径/目录/位置/书签，真实写失败/回滚/重试与多连接最新元数据有回归。封面读取仍后台执行，取消后拒绝旧结果，失败有可见/无障碍降级警告。Build10各85Core/63iOS/设备Release已通过，但仅M3第一切片；封面替换、可恢复删除、重复导入策略继续单独设计和验证。详见Documentation/LIBRARY_BROWSING_DESIGN.md及最新报告。

## M3 可恢复移出书架（Build11）

数据库通过新增002迁移升级到v2；removed_books仅记录移出时间，Book/原件/cache/章节/位置/书签保持。librarySnapshot一次读取书架/回收站；books只返回书架。AppServices启动恢复必须用allBookIDs包含回收站，不能根据可见书架清理已提交文件。移出/恢复仅在SQLite事务内变更标记，重复操作幂等，失效UUID/取消/写入失败正常抛错；没有新增文件搬移或跨存储提交窗口。001旧迁移原字节保留，新版库由旧App拒绝打开。

LibraryView共享sheet加入回收站，长按移出有原生确认，空书架也能恢复；管理操作串行且提交后才发布。回收站不自动清空、不回收磁盘空间；没有永久删除。Build11的91Core/67iOS/Release及真实启动清理/原生三图通过，用户已确认该切片可用；Build12新增手势/流畅度设备反馈另记。Readium/Vendor/codec/Locator/真实六pins锁和Apple文件协调复制均不升级。封面替换与重复导入策略仍下一M3切片，详见LIBRARY_REMOVAL_DESIGN.md。

## M3 原生左滑与动效（Build12）

LibraryView按布局选择原生List或ScrollView/LazyVGrid；List行接尾侧swipeActions，禁全滑直接执行，灰绿色普通按钮进入既有确认，数据提交后才移出。固定UUID身份驱动短spring补位/scale+opacity过渡，布局切换短淡入淡出；LibraryTrashSheet恢复行有短过渡，系统Reduce Motion关闭自定义移动/缩放和继承动画。未新增Core/DB/schema/Reader依赖变化。

新增独立bundle.ui-testing target与三个XCUITest，旧67iOS不跳过。AppRoot通过可选LibraryInteractionFixture接入隔离小样；只有DEBUG分支读启动配置/建立fixture，Release prepare恒nil且Mach-O无XR_LIBRARY_UI_*旗标。CI显式保留每项XCTest的成功录屏，基座simctl录屏只用于诊断并收集真实退出；录屏或原test/导出/summary失败都不能生成IPA；完整视频/六图用于独立视觉核验，不当手机帧率或完整主题验收。详见LIBRARY_INTERACTION_DESIGN.md与最新报告。

## M3 封面替换（Build13）

Core Book可选coverOverride与UUID派生Artwork路径，最新payload事务只改此字段，schema2/迁移不变。BookFileStore独立StagingCovers与不可变Artwork，Apple协调复制；文件先finalize再DB，DB失败回移草稿，只有本次finalize成功才回滚。启动清临时stage，回收站UUID也保留；已提交/旧自选原图不GC。原书/默认EPUB封面/正文缓存和完整位置/书签分离。

App新增CoverImagePipeline/CoverImportService actor与BookCoverEditorModel/Sheet，公开PhotosPicker FileRepresentation/共享UIDocumentPicker，20MiB/8000万像素限制，后台1080px JPEG和600/252px显示缩略缓存，CGImage方向只转换一次。requestID/closed/Task/Coordinator防旧结果覆盖，提交后仅当前editor可关闭；缩略图坏时有界原图恢复有警告。Release不带DEBUG种书入口。完整门槛和具体风险见LIBRARY_COVER_DESIGN.md/M3_COVER_VALIDATION_REPORT.json。

## M3 精确重复导入（Build14）

003迁移到schema3新增book_import_identities，不改Book JSON/Locator；非唯一索引保留旧重复书。BookImportDeduplicator在Core actor流式补齐旧原件摘要，匹配TXT时才按其编码恢复正规化身份；BookFileStore继续执行根目录/逐级symlink合同。BookRepository新增指纹记录/查询和事务内复查提交，SQLite BEGIN IMMEDIATE串行化多连接竞争，Book/Chapter/指纹一起提交。已有匹配原件必须再次核实；取消/失败只清理未提交的新UUID。UI结果区分新增与重复、回收站恢复仍显式调用既有repository动作。详细限制和验证见LIBRARY_DUPLICATE_DESIGN.md/M3_DUPLICATES_VALIDATION_REPORT.json。

## M4 外观偏好第一片（验证中）

ReadingAppearance属于Core Foundation领域模型，持久化由现有BookFileStore actor负责Preferences/reading-v1.json，最大16KiB、逐级路径检查与原子写。ReadingInterfaces以ReaderAppearanceProviding可选能力隔离具体Preferences，UI只持领域值。ReaderViewModel在打开前加载，并按输入序列保存；Adapter映射3.11偏好，复用DOM anchor与取消/身份保护。已维护Vendor的Navigator派发增加连续视图分支，仍只作用于有界loaded/current/resource；锁/原始基线不变，UPSTREAM记录hash与取舍。具体范围、原书排版优先级及未做项见READING_APPEARANCE_DESIGN.md。源码不等价编译或手机验收。

## M4 Build16 原生界面

ReaderMenuView承载阅读菜单，ReaderVisualStyle管理App层灰绿浅深色语义表面，ReaderAppearanceView以外观/排版分组调用既有ReaderViewModel。UI不持有Readium类型，版本化偏好模型/Locator/schema/原件和缓存合同保持。必要分页修复在Adapter采样前取消检查与维护Vendor的分页就绪/CSS失效路径中，未升级引擎/锁或修改JS bundle；原非零文字/180%重开回归和新增真实WebKit互斥回归通过。参考及实际原生验证见READING_UI_DESIGN.md。
