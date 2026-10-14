# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

**Build7直接picker交接与delegate生命周期已通过完整自动CI，已交付新测试包；用户设备首次导入仍待确认，M2长书/设备未完成。** 用户在Build6交付后明确“打开软件第一次导入好像还是不会有反应和提示，第二次能成功导入和有错误提示”。已记录Build6设备首次验收失败，不用49项自动通过覆盖反馈。实际安装Build号/当前OS未从设备独立读取，沿用此前iPhone13/iOS16.6.1/TrollStore背景；新菜单可读取实际版本/Build。

最新CI38572197917 / 运行源码0afe45ef6764f3954b41c7f383fe98ff9f662181 / codex/import-delegate-lifetime / bootstrap=false，所有job success。Linux/macOS各68Core、iOS55/55、0 failed/skipped；相对Build6新增6项，9项交接/生命周期回归全部通过，其中6项挂载完整生产LibraryView。test/附件/summary退出码全0，设备Release CODE_SIGNING_ALLOWED=NO与Build7 IPA通过。完整run/full/Core/Apple日志、xcresult/ReaderSnapshots在build/ci/38572197917；457运行Git blob SHA与工作区一致，根/下载/workspace锁逐字节一致。源码Swift/C warning/error0；AppIntents、WebKit及tmp测试数据库清理的SQLite vnode unlink诊断原样保留，runtime diagnostics单列，不宣称所有运行诊断0。

Windows381 grammar新增0/pristine54限制保留，14 Python tooling通过，语法不是Swift编译。报告Documentation/M2_IMPORT_DELEGATE_VALIDATION_REPORT.json；成功证据ValidationLogs/m2-import-delegate-build7-success.json；设计IMPORT_DELEGATE_FIX.md。Readium3.11/Vendor/远程6 pins不变，project.yml唯一工程源，没有改生成xcodeproj。

## 实现与实际验证

1. LibraryViewModel.receivePickedDocuments从UIKit终止回调立即开始原导入Task或报告错误，不再等待sheet.onDismiss，也没有pendingImport/finishPicking队列。
2. UIDocumentPicker.delegate的公开声明为weak，LibraryViewModel持有Coordinator到终止回调；completion弱捕获model避免环，新picker替换时invalidate旧回调，消费后释放。Coordinator支持数组及公共单URL回调，共用一次终止/取消/迟到过滤。
3. DocumentImportSheet使用LibrarySheet唯一item sheet管理文件/编码；TXTEncodingSheet仅提取原Form。完整LibraryView错误显示持续底部提示，可关闭，不与picker关闭争抢alert。菜单显示实际Bundle版本/Build。asCopy/data/security-scope/NSFileCoordinator/文件/SQLite/编码/Readium/位置路径均保留。
4. 原3项测试从Text+单sheet改成完整LibraryView（navigation、空/非空书架、编码sheet、reader cover、反馈、refresh）。新增无任何dismiss事件仍导入TXT/EPUB、冷首次无效文件/错误/重试、已有书库+编码往返、单URL/重复数组/取消、context销毁后的delegate持有/替换/释放、完整LibraryView先关闭后弱delegate收到第一次选择仍导入。保留所有原件bytes/SQLite唯一书籍/反馈/迟到断言与15秒deadline。
5. 成功和错误的真实iOS18.5书架PNG已导出并查看：错误及关闭按钮、书籍与成功状态可见。成功PNG没有完整导航栏时序，不把它写成整页布局/M3验收。模拟器提供原创fixture URL给delegate，未自动点击实际Files/iCloud文件；不是用户设备唯一根因已复现或已确认解决。

依据锁定d82f44f Readium3.11 TestApp的直接delegate→Task、两种回调；Apple weak delegate/makeCoordinator/item sheet/transition公开合同已查，适用差异写在IMPORT_DELEGATE_FIX.md。旧方案仅搬迁结果所有者而仍依赖onDismiss，被设备反馈否定；本轮移除依赖并处理回调生命周期，不再盲补队列。无私有API/异常吞掉/测试删减。

## 新旧包

- Build7 IPA：build/XianxiaReader-Import-Build7.ipa，7703978 bytes，SHA256 e051bf073aec9ad4ae395a19620a32b7c885ec4e8362c6f2bacf3f1500c43716。
- Build7测试ZIP：build/XianxiaReader-Import-Build7-TestKit.zip，7594904 bytes，SHA256 5f280447e39b106cb096074a21d7d0a3954c8435a2131d4c038a8889309f4172。含1本原创EPUB/3编码TXT/UTF8说明；CRC/内部IPA/包内fixture一致；iPhoneOS/arm64/0755/最低16.0/SQLite/第三方声明核验通过。
- Build4/5/6六个旧IPA/测试ZIP均逐hash核验保留。build/XianxiaReader.ipa仍是Build4（SHA7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1），未覆盖；旧包明细在报告preservedPackages与历史交接。

TrollStore正常更新，保留书库，不卸载/删数据库。先从+菜单确认0.0.1 (7)，完全退出重开后首次选TXT，再重开首次选EPUB，并测取消/错误/已有书库；本地/已下载iCloud分别记录。普通签名设备仍独立待验收。

## 失败、诊断与保留

Build7初轮38570937418/5020bca：各68Core、iOS52/53、0 skipped，完整书架首次TXT/EPUB、错误/重试、已有书库/编码、无dismiss及单URL通过；取消/空选择/重试系统DocumentManager deallocated host proxy异常致进程退出，test65/附件0/summary0，Release/IPA未执行。完整原件/失败json保留，未取消或重试同源碰运气；最新0afe45e包含两个生命周期回归与真实所有者修复，全套通过，不宣称修复了Apple系统bug。

Build6用户反馈、上轮两个48/49系统异常及各历史M1/M2原件仍在ValidationLogs及HANDOFF_IMPORT_DELEGATE_HISTORY_2026-10-14.md、HANDOFF_IMPORT_HISTORY_2026-10-14.md与旧M1/M2历史。Windowsinventory曾errno22写入失败，重试已核验成功；辅助缓存helper重叠替换断言/快照文件名与PowerShell管道读取错误也已纠正，不写成Swift或产品失败。

SQLite诊断只展示tmp测试UUID数据库/WAL，context teardown在repository仍被测试闭包持有时删除tmp root。原文/hash与待修测试清理生命周期记录在m2-import-build7-runtime-diagnostics.json；没有新增生产库删除代码，也不隐瞒该运行诊断。后续维护测试清理；不以这一诊断断言用户书库损坏。

## 接续

先收集Build7首次导入设备结果；若仍无反应，记录菜单实际Build、本地/iCloud、选择器关闭前后状态，核实真实delegate是否送达，不再重复同一猜测。首次确认后按M2测TXT目录/搜索/书签/连续/关闭重开、数十MB冷导入/cache重开与巨段窗口/内存。cache/reading plan仍流式校验与读取，不承诺仅元数据秒开。M2落实后M3完整书库，M4字体/排版/主题，M5性能；XBook/知识库仍草案。

main/HEAD6d761749911233122bcd031fcf718d22a19f9e77、原空index与所有未提交改动保持。候选通过独立GIT_INDEX_FILE正常push，已测源码以0afe45ef6764f3954b41c7f383fe98ff9f662181/457 hashes为准，后续仅文档快照不是另一轮编译。旧370文件备份与六个旧包均保留，FILE_INVENTORY已刷新。无自己启动的挂起进程/运行CI，Windows无Xcode，未启动/重置Docker/localhost/账单。

恢复按AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核Git/文件/完整日志/任务；长任务/恢复点/构建测试前checkpoint。build/.cache不随clone，artifacts14天；过期按锁重跑。自用/实际可用优先，卡点查官方/成熟实现并记录版本与取舍。
