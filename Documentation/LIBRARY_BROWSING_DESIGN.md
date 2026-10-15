# M3 书库浏览与改名（Build10完整自动门槛通过）

日期：2026-10-15。用户在Build9交付后回复“ok没问题 可以继续了”，按既定M3继续。第一切片包含网格/列表、最近阅读/导入/书名排序、书名/作者筛选、进度与改名；封面替换、可恢复删除、重复导入策略在下一M3切片。M3尚未全部完成，M4字体/排版/主题未提前展开。

## 展示与偏好

保留当前青绿文字封面，以原生SwiftUI NavigationStack、LazyVGrid/LazyVStack、菜单Picker与searchable建立书库。默认网格；最近阅读优先已读书的实际阅读时间，未读书按导入时间放后，最近导入有独立选项。书名用中文locale与数字顺序、UUID稳定tie break，筛选仅书名和作者元数据，不搜正文或知识库。无匹配状态区别于空书库，支持清除筛选。布局/排序存到UserDefaults的library.layout.v1、library.sort.v1，未知值回落默认，搜索词不持久化。进度只显示已保存值，非有限值拒绝显示，越界值夹至0–1。

[Apple AppStorage文档](https://developer.apple.com/documentation/swiftui/appstorage)和[searchable API](https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:)-18a8f)用于公开API核对。网站Markdown端点本次工具返回Unsupported content-type，保留这一限制；实际用现有iOS16/Xcode16.4编译/原生截图来核实，不根据网页不可读假定新API已编译。实现选择注入UserDefaults的MainActor model，而非在每个View重复AppStorage，方便重开与隔离偏好验证，不引入新依赖。

已有BookCoverView静默try?读取改为明确结果：后台读取封面并拒绝越界路径，缺失/坏图片降级文字封面且有可见/无障碍警告；取消后不发布旧任务结果。列表小封面不重复挤入整段书名，沿用有界导入缩略图，不加载书籍正文。

## 改名与一致性

共用单LibrarySheet增加renameBook，保持既有File Provider/delegate引用交接。长按书籍选择“修改书名”，单行输入、取消和保存，写入过程中禁用关闭；失败留在表单内显示错误。仅修改书架名称，不重写EPUB/TXT原件、改路径或重置书库。

Core验证trim后1–200个Character，拒绝Unicode控制/换行/段落分隔符，允许组合字符与ZWJ emoji。SQL通过UUID/bound参数定位记录，不插入用户标题到SQL文本。按[SQLite事务官方说明](https://www.sqlite.org/lang_transaction.html)，现有BEGIN IMMEDIATE事务先取得写事务、读取最新book payload再更新title；其他元数据不从UI旧快照覆盖，既有事务helper泛型化返回提交值。SQLite schema仍v1，不需要新迁移，无原件/cover/章节/Locator/书签/importedAt变更。原rollback注释中的best-effort与原始错误保持。

Model等待真实提交成功后更新书库并刷新；refresh request ID拒绝较早读取覆盖新标题，不先显示成功。新model从SQLite和偏好恢复。取消发生在事务开始前不会写；开始后的单一同步短事务完整提交或回滚，不在事务内await。

## 验证与剩余范围

新增5 Core：改名重开和关联/原件不变、标题非法/Unicode/SQL字面量、缺失/取消、真实SQLite trigger拒写与重试、第二连接最新payload保留。新增5 iOS：偏好恢复/未知值、元数据筛选/数字排序/进度、App真实TXT改名/完整位置保留、refresh重叠提交、原生网格/列表/无匹配/改名错误四张截图。实际各85 Core、63 iOS全部通过，所有既有导入、ANSI、搜索、位置、生命周期和四长书Release探针完整运行。

Windows390 Swift语法新增诊断0（pristine54限制保留）、16tooling通过，不等于Swift编译。Linux/macOS/iOS/设备Release与手机体验分别记录。CI38666201246/4ba69e58cdaa325cfd08e31ba5c3db42b1595b82已完成编译/测试/Release及Build10 IPA/测试包；设备结果独立待验收。原main/index和所有未提交工作、Build4–9旧包及上轮成功/失败原件保留。上轮一次性关机已收到命令exit0，此次没有新的关机请求，不重新调度。

## 首轮实际验证与最小修正

cd76b4d / CI38662816246各85Core/4Release探针及全部5新Library回归通过，旧TXT首次实页定位20秒超时导致iOS62/63、test65/export0/summary0，Release未执行，完整原件保留。Reader/Vendor/codec与Build9相同，单次首定位失败原因未证实，不把重跑当SDK修复。新增Library fixture曾在SwiftUI/SQLite结束前删临时root，有3条vnode unlink日志；沿用已验证DocumentImportFixtureSession的成熟夹具做法，保留4个小repository和目录直到worker退出，只清理隔离UserDefaults，原生sheet等待真实dismiss。TXT失败仅加同步原生诊断，不放宽20秒/600点/字符或3px断言，不通过可能挂起的JS读取诊断或未来正文；不声称两处现象已证实同因。

已看首轮网格/列表图，布局可读；“最近阅读”之前把更新导入的未读书混在已读前，使已读进度不易看到。实际取舍改为已读按阅读时间优先、未读按导入放后，仍可独立选择最近导入。回归增加未读导入400比已读300更新仍应放后。新源码需完整CI及最终四图核验，不能将失败候选写成可交付包。


## 最新证据

2026-10-15 M3书库浏览/改名切片Build10已通过完整自动门槛：[CI38666201246](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38666201246) / 4ba69e58cdaa325cfd08e31ba5c3db42b1595b82。Linux/macOS各85Core、iOS63/63、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA。Windows390 Swift语法新增0（pristine54限制保留）/16tooling，语法不是编译；468源码Git blob hash、根/download/workspace六pins锁与13旧包一致。保护Readium/Vendor/codec/Locator/schema/文件协调不变，原main/HEAD6d76174和空index、所有未提交工作保留。

书架支持网格/列表、最近阅读/导入/书名排序并保存偏好、书名/作者筛选、无匹配状态、已保存进度。长按修改书名，最新DB payload在BEGIN IMMEDIATE事务内只改title，保留UUID/原件路径/cover/目录/完整位置/书签/importedAt；失败显示且不假装保存。刷新请求ID防旧读取覆盖提交新名。缺失/坏封面后台读取降级且有可见/无障碍警告。原生网格/列表/筛选无结果/改名错误四图已查看，观察与测试、设备门槛分开记录。 网格封面统一顶部对齐，筛选后的数量标作本匹配。中间候选d7cbc1d/CI38664441495完整自动门槛已通过，原图发现这两处UI问题后才做最小视觉修正并再次完整验证；中间成功原件/四图观察/运行诊断保留m3-library-pre-alignment-*，不把中间包当最终源码。

新测试包`build/XianxiaReader-Library-Build10-TestKit.zip`，SHA256 `3111d7fdfab3fb91f61f659001cbe6e26ba9173a5d27bd7ca7537aff0fe1215e`，含Build10 IPA和沿用的11原创样本/证据；正常更新保留书库，+菜单确认0.0.1 (10)。用户在Build9上下文回复“ok没问题 可以继续了”，记录基本自用接受，不扩写逐个编码/手机性能或普通设备矩阵。Build10手机布局/改名体验待测；M3尚有封面替换、可恢复删除、重复导入策略，M4字体/排版/主题随后。真实桌面4样本仍核全文digest/范围复用/锚点，不当手机性能。实现与来源见LIBRARY_BROWSING_DESIGN.md、M3_LIBRARY_VALIDATION_REPORT.json。

首轮cd76b4d/38662816246各85Core/四探针及5新Library回归通过，旧TXT首定位20秒超时使iOS62/63、test65/export0/summary0，Release未执行，完整原件保留。Library夹具清理3条SQLite unlink诊断通过保留小repository/目录至worker退出处理；原生sheet等待真实关闭，TXT仅加同步原生诊断，20秒/600点/字符/3px门槛保持。首定位唯一根因未证实，不宣称修复全部WebKit时序问题。最近阅读按实际已读优先、未读导入时间置后，有对应回归。
