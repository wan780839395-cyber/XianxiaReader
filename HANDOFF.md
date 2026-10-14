# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

**TXT导入/Readium阅读/完整位置已接入Build5，完整自动CI通过；下一步设备TXT与数十MB冷导入/cache重开验收，完整M2尚未完成。** 不提前大规模进入M3/M4。

CI38559906005 / 已测运行源码37eb86a46dc9002af381a44204f9bc36d07e11a4 / codex/m2-txt-index / bootstrap=false，所有job success。Linux/macOS各68 Core（原60+新8），iOS46/46（原41+新5）、0 failed/skipped，test/附件/summary退出码0，设备Release CODE_SIGNING_ALLOWED=NO与Build5 IPA通过。完整full/run/Core/Apple日志、原始xcresult及ReaderSnapshots保存在build/ci/38559906005；455个运行文件Git blob SHA与当前源码一致，根/下载/workspace锁逐字节一致。源码Swift/C warning/error=0；AppIntents metadata及WebKit诊断另列并保留。Windows379 grammar新增0/pristine54限制保留、14 Python tooling通过，语法不是编译。五次真实失败分别记录，未跳过失败打包。

报告Documentation/M2_TXT_PRODUCT_VALIDATION_REPORT.json，成功证据ValidationLogs/m2-txt-product-build5-success.json，设计TXT_READING_DESIGN.md。真实iOS18.5模拟器验证了UTF8/带BOM UTF16LE/GB18030导入及重试、有界资源/转义、完整位置/错误字符与正文身份拒绝、长段滚动600点后非零charOffset与3px重开、搜索定位/会话取消。TXT连续快照已导出，自动几何/原生页面复查与实际设备分别记录；普通设备/TrollStore TXT仍未验收。

## 新包与旧包

- 新IPA：build/XianxiaReader-TXT-Build5.ipa，7699595 bytes，SHA256 e48e6ceb5151ca22d23a5cbb4491f71f0e90d0c87e8cef570ea2bb539ab6e621。
- 用户测试ZIP：build/XianxiaReader-TXT-Build5-TestKit.zip，7588693 bytes，SHA256 7d547c7582230e35860e0b591bb51adcf51f988a20470ff421d8805c6d1ac668；含IPA/三个原创UTF8、UTF16、GB18030 TXT样书/UTF8 TESTING.txt，CRC及内部IPA/包内fixture原始bytes一致，Build5/arm64/iPhoneOS/最低16.0/0755/系统SQLite/CoreFoundation/第三方声明核验通过。
- build/XianxiaReader.ipa仍是用户确认可用Build4，SHA256 7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1；Continuous-Build4-TestKit.zip SHA f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7。未覆盖。新包仅另存，TrollStore正常更新而不卸载/删库，实际安装由用户执行。

## 已实现的产品范围

1. TXTBookImportService actor：NSFileCoordinator原件副本、严格编码正规化/cache、文件提交、Book+Chapter事务；取消与错误只清理本次未提交UUID，数据库提交后不回滚已完成书籍。重启恢复同时处理Staging/Books/Cache/TXT，保留knownBookIDs。原件永久保留，cache可重建。
2. Book.txtEncoding可选字段向后兼容旧EPUB payload；SQL schema未改变/不删库。书库支持EPUB/TXT混合导入、明确编码选择、失败文件重试、取消与内置原创TXT样书；自动只信BOM/严格UTF8，GB18030明确选择。
3. TXTReadingPlanner为大章构建最多64KiB完整UTF8窗口元数据；Adapter公开Publication/Container/DataResource仅按需转一个窗口为XHTML、转义正文/脚本、段落有稳定byte ID；复用Readium3.11排版/CSS/有限连续窗口，不自建EPUB引擎/整本DOM/HTTP预览。
4. TXT独立readium.txt version1 envelope绑定原/normalized SHA、parser/normalizer/codec/资源版本、稳定章节ID、资源范围与段落byte/UTF16字符、完整原生Locator及视口偏移；不是仅百分比。打开/跳转先后台验证真实段落/代理对边界，错内容/越界/不兼容显式拒绝，SQLite仍过滤迟到异步保存。
5. ReadingInterfaces.currentChapters提供当前索引目录；卷跳到首叶子、书签/搜索/分页/连续复用现有控制层。TXT搜索保留issue876扩展、每批40/UI1000/上下文64与会话取消；await后检查request ID/Navigator身份、close拒绝旧回调。旧EPUB生命周期/迟到写入/竞态及41项回归保留。

Core仍Foundation/SQLite，无Readium/UIKit/SwiftUI；Readium API仅Adapter及集成测试。project.yml唯一工程源，新增文件按SwiftPM目录目标与XcodeGen App/Tests/Fixtures资源纳入。Readium版本/远程6 pins未改，resolve/test/build严格锁文件；本地EPUBSpreadView连续桥仅对显式TXT标记保留唯一转义字节ID，普通EPUB仍旧路径，UPSTREAM hash准确更新并经全套回归。

## 尚未验收及接续

1. 用户设备Build5：内置TXT与三编码导入/编码选择重试、目录卷章、连续/逆向/按屏、书签/搜索、关闭重开与模式/旋转、旧EPUB/旧书库；记录iPhone13/iOS16.6.1/TrollStore实际结果，普通签名设备单列。
2. 数十MB长篇冷导入/cache重开耗时、峰值内存及超长单行/数千章页面。cache复用仍流式计算原/normalized摘要，阅读范围构建也流式读正文，不宣称仅元数据秒开；旧cache generation尚无清理策略。巨大段落跨窗口的字形组合/段落节奏/资源边距待真实页面与M4/M5测量，不把字节无损覆盖当完整排版验收。
3. M2设备/长书门槛落实后再M3完整书库布局/列表/编辑/删除；字体/字号/行距/主题/亮度等按M4，性能M5。XBook/知识库仍仅草案，无提前抓取/账号/社交。

## 失败原件与历史

38552124765/c454a60：Core编译后1个新夹具失败，“尾声”合法标题被测试误当正文，68中67通过；iOS/Release未执行。更正普通叙述，保留标题规则和原断言。38552463402/97307de：各68 Core/应用编译通过，TXTReadingTests Locator.Text参数顺序错误导致test bundle未编译、summary0/result unknown、test65，Release无；按锁定public init(after:before:highlight:)修正。两次失败完整log/xcresult及ValidationLogs/m2-txt-product-fixture-heading-failure.json、m2-txt-product-test-api-order-failure.json保留，不写成工具错误或通过。

上轮编码/cacheCI38547339868/65c1b8d各60 Core/41 iOS/Release成功，Apple iconv四字节失败修复为公开SDK CoreFoundation；更早M2第一切片38538141364首轮EPUB冷打开超时/同源一次重试成功，根因仍未确认。原记录和历史HANDOFF_M2_PRODUCT_HISTORY_2026-10-14.md、HANDOFF_M2_CORE_HISTORY_2026-10-14.md、HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md保留；用户已确认Build4连续/重开正常，不以旧CI边界PNG不足否定实测。

38553767324/ed5ae3f：各68 Core/应用及test bundle编译通过，iOS45/46/0 skipped，只有TXT长段非零字符采样超时，Release未执行。参照既有EPUB长段回归，先完成明确段落跳转并确认DOM top，再合成600点滚动；仍要求char>100/3px，增加PNG/DOM/outer offset/位置诊断。之后当前完整CI通过；未改引擎或增大等待/降低断言，也不宣称旧超时已证实为产品bug或其根因完全确定。原文ValidationLogs/m2-txt-product-nonzero-anchor-timeout.json保留。

38555669042/5b8cc6a：各68 Core通过、iOS44/46，TXT非零char/正文快照通过，但重开invalidPosition；既有EPUB冷打开也超时。核实连续桥路径selector丢失TXT字节ID，anchor回退资源byte0却有正文char，严格恢复校验误落短标题。显式TXT文档使用唯一CSS.escape字节ID、本地扩展准确hash更新；新增实际段落byte断言，原char>100/3px/错误位置拒绝保持，完整本轮通过。失败原文ValidationLogs/m2-txt-product-byte-selector-failure.json保留，EPUB冷打开根因未宣称修复。

38558425326/1bb8f6c：各68 Core通过、iOS45/46，TXT修复后的非零char/重开3px/目录全部完成，但新增byte断言在轮询阶段提前对旧标题byte0执行而误报。将完全相同byte断言移到完成非零char采样后的实际saved值，额外assert该样本char>100；不改产品或降低门槛。原文ValidationLogs/m2-txt-product-polling-assertion-failure.json保留，原失败未覆盖成成功。

## 保留与恢复

本地main/HEAD6d761749911233122bcd031fcf718d22a19f9e77、原空index与所有原未提交改动保留。M2快照通过独立GIT_INDEX_FILE正常push，已测运行源码以37eb86a46dc9002af381a44204f9bc36d07e11a4/455个hash为准，之后仅文档快照不代表另一轮编译。旧370文件备份保留，当前维护文件inventory已更新。无自己启动的挂起进程或运行中的验证；Windows无Xcode，Docker此前管道缺失未启动/重置；公开标准macOS runner，没有账单修改/localhost服务。

下一轮先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核Git/文件/完整日志/运行任务，不假定最后步骤成功。长任务/可恢复子步骤/构建测试前写检查点；阶段同步状态/设计/报告/FILE_INVENTORY。build/.cache不随clone，GitHub artifacts14天，过期按锁重跑。自用/实际可用优先，卡点查官方及成熟方案，阅读交互参考微信读书，其余按原路线。
