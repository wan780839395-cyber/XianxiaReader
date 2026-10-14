# M2 TXT产品接入

状态：2026-10-14源码已写入，CI38552463402/97307de验证中。Linux68 Core已通过；macOS/iOS46与Build5设备Release尚未取得最终结果。原Build4用户包/小说/数据库保留；不能把源码或上轮60Core/旧41iOS写成TXT设备已验收。

## 导入与缓存

TXTBookImportService在Core actor协调原件暂存、副本编码正规化与索引cache、文件提交及Book+Chapter数据库事务；Apple仍使用NSFileCoordinator，不读取整本Data到主线程。源URL由App导入服务持有security scope直到处理完成。原件保存Books/UUID/book.txt，编码选择保存为Book可选字段txtEncoding；旧EPUB JSON缺字段仍可解码，SQL schema未改，已有书库不删。

自动识别仅BOM/严格UTF8。失败显示编码选择/重试入口，明确选择UTF8/UTF16 LE/BE/GB18030，保留原文；GBK常用双字节子集走同一GB18030系统转换器。批次顺序处理，部分失败保留成功书籍，可取消；DB提交后不因取消回滚已提交书籍。只有本次未提交UUID的Staging/Books/Cache/TXT在失败时移除；重启恢复以数据库knownBookIDs保护已提交记录与缓存。清理失败保留原始失败并向用户显示。

cache仍绑定原/normalized/目录摘要与parser/normalizer/codec版本，损坏可重建，原件不改。重开虽避免转码/分章，当前仍流式摘要校验及构建轻量阅读范围，不宣称仅元数据快开；数十MB冷导入与重开时间/峰值内存仍待测量。

## 成熟接口与有界阅读

直接查阅本地锁定Readium3.11公开源码，而非套用旧Fetcher版本API：

- [Publication与Container](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Shared/Publication/Publication.swift)：Publication(manifest:container:servicesBuilder:)与资源访问。
- [Container](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Shared/Toolkit/Data/Container/Container.swift)、[DataResource](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Shared/Toolkit/Data/Resource/DataResource.swift)：惰性资源提供与请求范围。DataResource会缓存数据，因此每次仅创建一个有界窗口资源，不让container持有全书资源正文。
- PositionsService/PerResourcePositionsService、DefaultContentService/HTMLResourceContentIterator.Factory、既有SafeTextSearchService工厂分别提供位置列表/正文/安全搜索；不升级远程pins或Vendor。

TXTReadingPlanner仅保留轻量范围，把每个叶子章节拆为最多64KiB、完整UTF8标量的窗口，范围精确覆盖原规范正文、不跨下一章。同内容版本/同byte start的资源href稳定，含完整normalized摘要与renderer版本；章节仍使用Core稳定ID，卷分组没有重复正文。

Adapter的TXTResourceRenderer actor按窗口转换XHTML，CR/LF段落有绝对字节ID；文本中的HTML/脚本字符转义，样书标题与段落提供基础节奏。没有串起全书DOM、自建EPUB排版或localhost预览；虚拟Publication使用公开EPUB阅读profile复用Readium Navigator/CSS/连续窗口。大章也分窗口，超长单行在窗口边界的段落节奏/字形组合与资源间边距仍需真实长书页面及M4/M5验证，不把自动字节无损覆盖测试当完整中文排版验收。

阅读层通过ReadingInterfaces.currentChapters返回实际cache索引，避免UI沿用旧parser目录；目录分组跳到对应首个叶子。基础书库布局/全面字体/主题仍按M3/M4。

## 完整位置与生命周期

TXT与EPUB分别使用readium.txt/readium.epub命名空间；TXT version1 envelope包括原/normalized SHA、parser/normalizer/codec/资源版本、稳定叶子ID、resource start/end、段落byte start、段内UTF16字符偏移，以及完整原生Locator（href/CSS/DOMRange/文本上下文/连续视口偏移等）。摘要/范围/章ID/版本不符拒绝恢复，绝不静默归零。不是只存百分比；progress仅用于书架显示。

恢复/书签/搜索定位先在后台有界读取校验真实段落起始与UTF16代理对边界，再交Readium原生定位。Native Locator与独立anchor必须一致；context最多64字符、highlight256；内容变化不复用旧位置。正常原件不会改写，cache损坏重建同内容可重开。位置保存仍通过原SQLite时间戳拒绝迟到写入。

TXT打开与定位的await之后核对open request ID和Navigator identity；close使未完成请求失效、拒绝旧回调，清理search provider/context。搜索仍通过ReadingInterfaces可选capability，保留issue876修复、每批40/UI1000/上下文64与取消会话，结果使用TXT完整位置；不会先汇总全书结果。

## 验证范围

新8 Core：编码/原件/目录与cache重开、识别不确定重试、原件+cache中断恢复、取消、DB写失败回滚、旧EPUB payload解码、大章64KiB窗口UTF8字节全覆盖、错正文/越界anchor拒绝。

新5 iOS：真实UTF8/UTF16/GB18030导入与编码重试、窗口/脚本转义/不读下一章/极短正文、完整byte/text/viewport位置与错误UTF16/正文身份拒绝、真实连续长段600点滚动后非零字符与3px重开、真实搜索TXT位置跳转/取消；现有EPUB生命周期/迟到写入/竞态/目录/搜索/连续41项保留。原混合导入测试更新为TXT+EPUB成功，新增不支持PDF失败断言，未删除失败路径。

首轮CI38552124765/c454a60在Linux68项的一个新夹具断言失败：正文“尾声”符合合法标题，实际目录4条与错误预期3条不符；Core已编译，iOS/Release未执行。修正夹具普通叙述，原规则和断言不变，完整原文/hash保留ValidationLogs/m2-txt-product-fixture-heading-failure.json。不把工具错误、取消或测试未执行写成成功。

最终自动检查/Swift编译/原生WK页面快照与断言/普通设备/TrollStore五种结果单独记录；本设计此刻待完整CI，真实数十MB导入/cache重开、设备中文页面与巨章边界仍待验收。
