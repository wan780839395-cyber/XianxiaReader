# M2 TXT产品接入

## Build9 当前实现

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。


以下为历史阶段记录，当前范围以上述Build9与设备反馈为准。

状态：2026-10-14已过完整CI38559906005/37eb86a：Linux/macOS各68 Core、46 iOS、Build5设备Release，455来源hash和三份锁一致。五次真实失败的原文保留；原Build4/书库/数据库不覆盖。新三编码TXT原生集成/搜索/长段重开自动通过，实际设备/数十MB/巨大单行边界尚未验收，完整M2未完成。

## 导入与缓存

TXTBookImportService在Core actor协调原件暂存、副本编码正规化与索引cache、文件提交及Book+Chapter数据库事务；Apple仍使用NSFileCoordinator，不读取整本Data到主线程。源URL由App导入服务持有security scope直到处理完成。原件保存Books/UUID/book.txt，编码选择保存为Book可选字段txtEncoding；旧EPUB JSON缺字段仍可解码，SQL schema未改，已有书库不删。

自动识别仅BOM/严格UTF8。失败显示编码选择/重试入口，明确选择UTF8/UTF16 LE/BE/GB18030，保留原文；GBK常用双字节子集走同一GB18030系统转换器。批次顺序处理，部分失败保留成功书籍，可取消；DB提交后不因取消回滚已提交书籍。只有本次未提交UUID的Staging/Books/Cache/TXT在失败时移除；重启恢复以数据库knownBookIDs保护已提交记录与缓存。清理失败保留原始失败并向用户显示。

cache仍绑定原/normalized/目录摘要与parser/normalizer/codec版本，损坏可重建，原件不改。重开虽避免转码/分章，当前仍流式摘要校验及构建轻量阅读范围，不宣称仅元数据快开；数十MB冷导入与重开时间/峰值内存仍待测量。

## 成熟接口与有界阅读

直接查阅本地锁定Readium3.11公开源码，而非套用旧Fetcher版本API：

- [Publication与Container](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Shared/Publication/Publication.swift)：Publication(manifest:container:servicesBuilder:)与资源访问。
- [Container](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Shared/Toolkit/Data/Container/Container.swift)、[DataResource](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Shared/Toolkit/Data/Resource/DataResource.swift)：惰性资源提供与请求范围。DataResource会缓存数据，因此每次仅创建一个有界窗口资源，不让container持有全书资源正文。
- PositionsService/PerResourcePositionsService、DefaultContentService/HTMLResourceContentIterator.Factory、既有SafeTextSearchService工厂分别提供位置列表/正文/安全搜索；不升级远程pins或Readium版本。

TXTReadingPlanner仅保留轻量范围，把每个叶子章节拆为最多64KiB、完整UTF8标量的窗口，范围精确覆盖原规范正文、不跨下一章。同内容版本/同byte start的资源href稳定，含完整normalized摘要与renderer版本；章节仍使用Core稳定ID，卷分组没有重复正文。

Adapter的TXTResourceRenderer actor按窗口转换XHTML，CR/LF段落有绝对字节ID；文本中的HTML/脚本字符转义，样书标题与段落提供基础节奏。没有串起全书DOM、自建EPUB排版或localhost预览；虚拟Publication使用公开EPUB阅读profile复用Readium Navigator/CSS/连续窗口。大章也分窗口，超长单行在窗口边界的段落节奏/字形组合与资源间边距仍需真实长书页面及M4/M5验证，不把自动字节无损覆盖测试当完整中文排版验收。

阅读层通过ReadingInterfaces.currentChapters返回实际cache索引，避免UI沿用旧parser目录；目录分组跳到对应首个叶子。基础书库布局/全面字体/主题仍按M3/M4。

## 完整位置与生命周期

TXT与EPUB分别使用readium.txt/readium.epub命名空间；TXT version1 envelope包括原/normalized SHA、parser/normalizer/codec/资源版本、稳定叶子ID、resource start/end、段落byte start、段内UTF16字符偏移，以及完整原生Locator（href/CSS/DOMRange/文本上下文/连续视口偏移等）。摘要/范围/章ID/版本不符拒绝恢复，绝不静默归零。不是只存百分比；progress仅用于书架显示。

实际断点38555669042证明：完成段落导航后的char>100与原生截图通过，但重开invalidPosition。源码核实连续扩展原selector只生成html/body/p路径，丢失txt-b字节ID；codec回退资源byte0而仍有长段char，真实恢复校验误落短标题。最小修复为renderer显式data-xianxia-txt=1标记；本地EPUBSpreadView的连续selector只对该标记的唯一txt-b ID使用公开[CSS.escape](https://drafts.csswg.org/cssom/#the-css.escape()-method)，保留真实byte+character，普通EPUB仍原路径。更新UPSTREAM声明准确hash，不升级3.11/远程pins、不放宽校验，不建立额外全书段落表。新回归同时要求采样paragraph byte等于实际正文段落；此修复及严格byte/char/3px检查已由CI38559906005/37eb86a完整验证。旧EPUB首开超时同轮重现，单列，不宣称此修复解决了它。

恢复/书签/搜索定位先在后台有界读取校验真实段落起始与UTF16代理对边界，再交Readium原生定位。Native Locator与独立anchor必须一致；context最多64字符、highlight256；内容变化不复用旧位置。正常原件不会改写，cache损坏重建同内容可重开。位置保存仍通过原SQLite时间戳拒绝迟到写入。

TXT打开与定位的await之后核对open request ID和Navigator identity；close使未完成请求失效、拒绝旧回调，清理search provider/context。搜索仍通过ReadingInterfaces可选capability，保留issue876修复、每批40/UI1000/上下文64与取消会话，结果使用TXT完整位置；不会先汇总全书结果。

## 验证范围

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](PERFORMANCE_TEST_PLAN.md)。

新8 Core：编码/原件/目录与cache重开、识别不确定重试、原件+cache中断恢复、取消、DB写失败回滚、旧EPUB payload解码、大章64KiB窗口UTF8字节全覆盖、错正文/越界anchor拒绝。

新5 iOS：真实UTF8/UTF16/GB18030导入与编码重试、窗口/脚本转义/不读下一章/极短正文、完整byte/text/viewport位置与错误UTF16/正文身份拒绝、真实连续长段600点滚动后非零字符与3px重开、真实搜索TXT位置跳转/取消；现有EPUB生命周期/迟到写入/竞态/目录/搜索/连续41项保留。原混合导入测试更新为TXT+EPUB成功，新增不支持PDF失败断言，未删除失败路径。

首轮CI38552124765/c454a60在Linux68项的一个新夹具断言失败：正文“尾声”符合合法标题，实际目录4条与错误预期3条不符；Core已编译，iOS/Release未执行。修正夹具普通叙述，原规则和断言不变，完整原文/hash保留ValidationLogs/m2-txt-product-fixture-heading-failure.json。不把工具错误、取消或测试未执行写成成功。

最终自动检查/Swift编译/原生WK页面快照与断言/普通设备/TrollStore五种结果单独记录；本切片已通过完整CI，真实数十MB导入/cache重开、设备中文页面与巨章边界仍待验收。

第二轮38552463402各68 Core/应用编译通过，测试Locator.Text参数顺序错误使test bundle未编译、summary0/result unknown、Release未执行；更正public init(after:before:highlight:)后进入实际测试。第三轮38553767324为45/46，TXT非零字符采样超时；参照既有EPUB测试完成明确段落/DOM就绪后再滚动，原char>100/3px断言保持，本轮完整通过。未改引擎/增大等待/删除断言；超时根因未完全确认。三次失败及原始日志/summary分别保留ValidationLogs，不能将旧失败覆盖成成功。
