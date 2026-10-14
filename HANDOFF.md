# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

### TXT产品接入开始（覆盖下方上一切片的完成点）

38553767324/ed5ae3f真实failure：各68 Core/应用+test bundle编译通过，iOS45/46/0 skipped。新三编码导入/有界资源/位置拒绝/搜索通过，只有TXT长段“滚动600点后非零char anchor”采样超时；Release/IPA未执行，根因此刻未确认。完整summary/xcresult/full/log保留build/ci/38553767324与ValidationLogs/m2-txt-product-nonzero-anchor-timeout.json。依据既有EPUB长段测试先完成明确段落Locator跳转并确认DOM top，再合成600点滚动，仍要求char>100/重开3px，增加原生PNG/DOM/outer offset/完整位置诊断；不改引擎或增大等待、降低断言。此改动待完整CI，不把它写成已修复产品问题。

**最新真实验证：CI38553767324 / ed5ae3f8c8088751a4b7e8cf645e006539767fcd / codex/m2-txt-index，bootstrap=false，预期各68 Core/46 iOS/Build5设备Release。** 测试接口顺序修正已正常push并dispatch，main/原index保持原样。恢复先查此run/head/完整artifact，不重复dispatch或从旧60/41推断TXT通过；455候选来源hash与待验收门槛在M2_TXT_PRODUCT_VALIDATION_REPORT.json。前两轮真实失败原件保留。

已核实新Linux Core success及完整artifact build/ci/38552463402/core/core-tests.log：真实Swift/C编译、68项（原60+新8）全部通过，无源码warning/error匹配；Apple/iOS真实页面/Release尚未完成。新样书由项目原创文本生成UTF8/带BOM UTF16LE/GB18030三个小文件，纳入资源与候选hash；没有用户小说。

38552463402真实结果已结束failure：Linux/macOS各68 Core通过，应用源码编译通过；iOS测试TXTReadingTests.swift:83的Locator.Text参数顺序错误（after须在before前）导致test bundle编译失败。summary total0/result unknown，不是46项通过；test exit65，Release/IPA未执行。完整full/run/日志/xcresult已下载。按锁定3.11的public init(after:before:highlight:)调整测试调用顺序，不改断言或产品源码；此修复待新完整CI。不要同源重试编译错误或把测试0条当成功。

真实首轮已结束failure：Linux新Core成功编译，68项中testTXTImportPersistsOriginalEncodingTOCAndCacheAcrossRestart的标题数组失败。夹具正文独立行“尾声”正属于已有标题识别器的合法章节标题，实际4条与测试错误预期3条不符；iOS未开始、没有IPA。完整Core/full/run已下载build/ci/38552124765。修正夹具为普通叙述“山门的灯火仍在”，同时将真实页面测试“第二章原创终点”（也符合允许无空格的章标题）改为“原创故事终点”；保留识别规则和原3条/章标题/窗口恢复断言，不降低测试。此修复待新完整CI。

2026-10-14用户再次要求继续。已按顺序核对文档、main6d76174/原空index、M2分支2eaa974、CI38547339868/65c1b8d真实success及本机无挂起任务。下一切片接入受管理TXT导入、明确编码选择、Readium公开Publication/Container有界资源及完整TXT位置；原书/现有书库/Build4保留。先阅读锁定3.11本地公开API，再写最小实现与真实导入/窗口/位置/生命周期回归；此刻尚未写入新源码，不把上轮Core60/旧iOS41当产品TXT验收。

构建前检查点：已写入TXTBookImportService（原件/索引cache/Book+TOC事务与失败恢复），可选Book.txtEncoding向后兼容旧EPUB JSON；BookFileStore保留NSFileCoordinator并支持TXT。TXTReadingPlanner将大章拆为最多64KiB轻量范围，Adapter公开Publication/Container/DataResource按窗口转XHTML、转义正文、字节段落ID，复用Readium排版与安全搜索。TXT独立完整位置envelope绑定原/normalized摘要、parser/normalizer/codec与稳定章ID、段落byte/UTF16字符和完整原生Locator，恢复在后台验证段落边界/代理对，不只百分比。UI支持TXT编码选择/失败重试/取消及原创TXT样书；Build号5，原Build4包不覆盖。新增8 Core/5 iOS回归，预期各68 Core/46 iOS；旧生命周期/迟到保存回归均保留，原TXT拒绝混合导入测试改为TXT+EPUB成功并保留不支持文件失败断言。Windows379 grammar新增0/14 tooling通过（不是编译）；此刻所有新源码待真实完整CI，Readium/vendor/远程锁未修改。

**M2 Core编码正规化/内容版本cache第二切片完整自动CI通过；下一步TXT导入与阅读接入。** 当前安装包仍只有EPUB入口，不能把Core完成写成TXT产品已可用或完整M2验收。

CI38547339868 / 运行源码65c1b8d6dbebf311c1e6b4b9534cda59373940b6 / codex/m2-txt-index / bootstrap=false，repository-checks、Linux Core、macOS/iOS/Release job全部success。Linux/macOS各60 Core（33原+27新增：16正规化/11cache）、原41/41 iOS，0 failed/skipped，test/附件/summary退出码0；设备Release CODE_SIGNING_ALLOWED=NO成功。完整日志、原始xcresult、锁、IPA归档在build/ci/38547339868，445个运行文件Git blob SHA与当前源码一致，根/下载/workspace锁逐字节一致。源码Swift/C warning/error=0；AppIntents/WebKit诊断原样保留，不算设备验收。

Windows372 grammar新增诊断0（Readium pristine54限制原样保留）及14项Python tooling通过；语法检查不是编译。报告Documentation/M2_TXT_NORMALIZATION_VALIDATION_REPORT.json，成功证据ValidationLogs/m2-txt-normalization-cache-success.json。macOS执行了编码向量；iOS41项仍是既有EPUB集成回归，TXT在iOS的真实导入/codec运行/页面/设备还须后续验证。

首轮CI38545821529/973bae6真实failure：Linux60成功，macOS Core已编译但Apple系统iconv两项四字节向量（emoji byte17/补充汉字byte0）失败，iOS/Release未执行，没有IPA。完整失败日志/hash与ValidationLogs/m2-txt-normalization-apple-iconv-failure.json保留。修复使用公开SDK CoreFoundation，Linux保留glibc iconv，原断言未降低，并补充补充范围两端、非法第三/四字节/单字节和非零错误偏移。该修复后的新源码通过完整CI；不把首轮失败改写成未执行或工具失败。

此前M2第一切片CI38538141364/0643093：各33 Core通过，attempt1旧EPUB首次打开位置超时40/41，Release未执行；仅同源重试失败job一次，attempt2全套成功41/41及Release。超时原因未确认，原记录与两轮artifact保留；没有降低测试或修改用户已确认可用的阅读源码。历史完整检查点见HANDOFF_M2_CORE_HISTORY_2026-10-14.md及HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。

## 已实现与限制

- Core独立八类标题识别、流式UTF8分章/卷组目录、Int64/end-exclusive范围、最多256KiB章节窗口；19项第一切片回归持续通过。
- TXTNormalizer actor：UTF8/UTF16 LE/BE/GB18030，默认64KiB/上限256KiB读取；严格跨块/代理对/四字节，BOM冲突/损坏/截断/NUL明确失败，不替换正文。原书不改，UTF8 sidecar成功后才发布，失败/取消清理本次临时文件并保留原始失败。
- Apple内部CTextCodec仅用公开CoreFoundation GB_18030_2000/lossByte=0与SDK框架；Linux用glibc iconv禁用IGNORE/TRANSLIT。字节边界扫描不自建字符表。平台codec ID使旧Apple cache失效，无远程依赖或Homebrew路径。
- TXTContentDigest：增量SHA256、独立空串/abc/跨块/百万a/中文emoji向量通过，用于内容cache身份。
- TXTIndexCache：绑定bookID/原SHA/normalizedSHA/目录SHA/编码/normalizer/parser/codec版本，相对路径逐节点验证，manifest上限8MiB；新generation完整后原子发布。损坏/缺失/版本失配可重建，链接/越界拒绝；失败不删除旧cache/原书/数据库。复用避免转码/分章，但目前仍流式核验全文摘要，不能承诺仅元数据快开；旧generation清理/长篇性能待后续。
- StreamingTXTIndexer实现完整正规化+分章facade。Core保持Foundation/SQLite业务边界，无Readium/UIKit/SwiftUI。数据库schema未改变。

## 尚未实现与接续

1. 受管理TXT导入：复用Apple NSFileCoordinator副本、暂存/文件提交/DB事务/中断恢复；明确编码选择与可见取消/失败。已有EPUB流程与书库保留，不能通过删库修复。
2. ReadiumAdapter按已索引字节范围提供有界TXT资源，经ReadingInterfaces操作，核对本地锁定Readium3.11公开Publication/Container/Resource API。大章也需窗口切分，不能DataResource缓存整本或全章巨量String；仍复用Readium排版。
3. TXT完整版本化位置：内容身份/稳定叶子ID/局部字节与文本锚点/视口偏移，拒绝错正文/无效范围与迟到异步保存；目录/重开/模式切换及竞态集成回归。
4. iOS实际UTF8/UTF16/GB18030导入、数十MB冷导入/cache重开与设备中文页面；自动检查/编译/模拟器/普通设备/TrollStore分别记录。M3完整书库布局/编辑、M4字号/字体/行距/主题、M5性能顺序不变。

每个可恢复步骤/构建测试前更新本文件；阶段结束同步状态/设计/报告/FILE_INVENTORY。继续先读AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核实际Git/日志/进程，不依赖聊天压缩是否成功。

## 用户反馈与保留

用户确认连续阅读与重开位置正常，按Build4上下文记录核心功能可用；已知背景iPhone13/iOS16.6.1/TrollStore，未独立读取Build号。未单独报告的原书图像/旋转/其他设备/性能仍待确认，不以历史CI PNG缺第二章否定用户实测。卡点先查官方/成熟方案，可参考微信读书交互，其余按原路线；资料见TXT_INDEX_DESIGN和MATURE_READER_REFERENCES。

本地main/HEAD6d761749911233122bcd031fcf718d22a19f9e77及原空index不动，所有原未提交改动保留；候选通过GIT_INDEX_FILE独立快照正常push，不reset/stash/checkout/删库。M2已测运行源码为上述65c1b8d6dbebf311c1e6b4b9534cda59373940b6，之后仅文档快照不代表另一轮源码编译。旧370文件备份.cache/recovery/20261014-092934核验记录与历史各run原件保留。

build/XianxiaReader.ipa仍为用户已确认可用Build4，7502213 bytes/SHA256 7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1；Continuous-Build4-TestKit.zip SHA f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7。新同Build号CI IPA只归档各run目录，没有覆盖用户包；TXT UI未接入，不提供相同界面新测试包。新IPA hash/平台/SDK系统库/0755/CRC见成功报告。

当前CI已结束，无自己启动的挂起工具。Windows无Xcode；Docker此前只读查询失败missing dockerDesktopLinuxEngine pipe，未启动/重置Docker。Apple验证用公开仓库标准macOS runner，无账单/付款修改，无localhost服务。根Package.resolved仍6个真实pins，resolve/test/build严格锁定；原始source与资源不升级。GitHub artifacts14天，build/.cache不随clone，过期按锁重跑。
