# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

2026-10-14 Build6设备反馈更新：用户报告“打开软件第一次导入好像还是不会有反应和提示，第二次能成功导入和有错误提示”。Build6首次设备验收失败，不能继续把参考模型交接视为设备修复成功。已核实main/原空index与所有旧改动/包保留、无运行CI或本地任务。当前重新检查完整LibraryView（两种sheet/fullScreenCover/alert）与UIKit delegate自动关闭时序；上轮Text+单sheet harness未覆盖完整书架/真实File Provider，iOS18.5自动结果仍保留但不足以证明此设备问题解决。即将补完整书架冷首次回归，并改为直接从delegate触发导入，去掉onDismiss必须先发生的依赖；先查官方/锁定Readium成熟实现，尚未写入或编译新修复。

新源码已写入但待编译：LibraryViewModel.receivePickedDocuments直接触发导入/错误，不再排队等onDismiss；LibrarySheet统一文件/编码为单个item sheet，完整LibraryView错误改为持续书架提示（可关闭），避免picker关闭时再争抢alert。TXTEncodingSheet仅提取原编码页面；保留asCopy/NSFileCoordinator/DB/原件/Readium原路径。Coordinator按官方Readium3.11样例补单URL公共delegate，和数组/取消共用终止过滤。Build7。原3个sheet回归现在全部挂载完整生产LibraryView（空/非空书架、reader cover、编码、反馈），新增4项：无任何dismiss事件也要导入、冷首次无效文件与提示/重试、已有书库+编码弹窗往返、单URL/重复数组/取消。保留原断言/15秒deadline/关闭transition；首次成功/错误导出真实书架截图。即将Windows381 grammar/14 tooling及完整CI，各68Core/iOS53/Build7Release均待执行；不是已修复设备根因。

候选5020bca0406fa9823db6e270563f283df74739c9 / CI38570937418 / codex/import-first-selection / bootstrap=false已真实启动。Windows381语法新增0/pristine54、14 tooling通过；非Swift编译。M2_IMPORT_DELEGATE_VALIDATION_REPORT.json记录457运行hash/旧Build4、5、6六个包hash，尚无通过门槛。维护inventory初次写入遇到OSError errno22，原tool输出保留，随后同一脚本重试成功569条；候选中inventory为前一快照，后续文档快照纳入新清单，不假定初次写入成功。忽略缓存验证helper生成也曾字符串替换断言失败（尚未写出/执行），已修正重叠替换并py_compile后成功记录；不是Swift/CI/产品失败。源码/原index/main均保留。

随后核实Apple当前公开声明UIDocumentPicker.delegate为weak；原测试的let delegate强引用会掩盖representable关闭后delegate丢失。工作区进一步将Coordinator由LibraryViewModel强持有至终止回调（completion弱捕获model无环），新presentation替换时invalidate旧Coordinator，结果消费后释放。新增2项：wrapper/context离开作用域后仅shelf持有delegate，替换后的迟到事件被拒绝且终止后释放；完整LibraryView先关闭picker、仅弱delegate后到仍首次导入。新总计各68Core/iOS55/Build7，381语法通过但尚未编译。运行中的38570937418仍是不可变5020bca/53项前一候选，不能当最新工作区结果。新CI将使用独立ref避免取消旧验证；checkpoint后开始。

最新已真实启动0afe45ef6764f3954b41c7f383fe98ff9f662181 / CI38572197917 / codex/import-delegate-lifetime / bootstrap=false，期望各68Core/iOS55/Build7Release。新报告457运行hash/六个旧包保留，前一53项report归档到.cache/recovery/build7-first-candidate-report.json，两个CI不互相取消。仅Windows语法/14tooling已通过，编译/模拟器/原生书架快照/Release/IPA仍待完整结果。当前不再改这版运行源码，阶段结束同步实际证据。

前一38570937418/5020bca已结束：各68Core，iOS52/53、0 skipped；完整LibraryView首次TXT/EPUB、已有书库/编码切换、首次无效文件/反馈/重试以及无dismiss回归和单URL回归均通过。取消/空选择/重试再次系统DocumentManager deallocated host proxy崩溃，test65/附件0/summary0，Release/IPA未执行。完整run/full/Core/Apple日志/xcresult及书架快照下载到build/ci/38570937418，ValidationLogs/m2-import-build7-first-candidate-failure.json保留。不是用户首次失败唯一根因；最新0afe45e/55项仍待完成。

最新38572197917/0afe45e完整success原件已下载核验：各68Core，iOS55/55/0 failed/skipped；9项交接/生命周期回归全部通过，含无dismiss、完整书架关闭后弱delegate回调、context销毁/替换旧回调/终止释放；test/附件/summary全0，设备Release CODE_SIGNING_ALLOWED=NO和Build7 IPA通过，457运行hash/三份锁一致，源码compiler warnings/errors0。IPA7703978 bytes SHAe051bf073aec9ad4ae395a19620a32b7c885ec4e8362c6f2bacf3f1500c43716，iPhoneOS/arm64/0755/最低16.0/SQLite/声明/CRC通过。真实首次错误/成功书架PNG已查看：错误与关闭按钮、书籍/成功状态可见；成功PNG未覆盖完整导航栏时序，不写成整页布局验收。原始日志还保留tmp测试root清理时的SQLite vnode unlink诊断（context teardown删除tmp数据库时对象仍活），另记runtime diagnostics，不宣称运行诊断0或生产数据库被删。当前即将另存新IPA/原创样书ZIP及同步文档；设备首次问题仍待用户Build7实测。

**首次文件导入交接已改为参考模型保存并通过Build6完整自动CI；用户iOS16.6.1首次选择仍待实测确认。完整M2设备/长书未完成，不提前进入M3/M4。** 用户反馈为“选择器关闭了，但书架没有新书，也没有提示”，TXT正常可导入但首次不生效，EPUB此前同样发生。不是把后端直接导入通过当成整个File Provider流程已验收。

最新CI38566503849 / 已测运行源码5522489906224a089c91e92180bdcebbe9be2095 / codex/import-first-selection / bootstrap=false，所有job success。Linux/macOS各68 Core、iOS49/49、0 failed/skipped，新增3个真实SwiftUI/UIDocumentPicker交接回归全部通过；test/附件/summary退出码0，设备Release CODE_SIGNING_ALLOWED=NO和Build6 IPA通过。完整run/full/Core/Apple日志、原始xcresult及ReaderSnapshots位于build/ci/38566503849，456个运行Git blob SHA与工作区源码一致，根/下载/workspace锁文件逐字节一致。源码Swift/C warning/error=0，AppIntents/WebKit诊断仍原样保留。Windows380 grammar新增0/pristine54限制保留、14 Python tooling通过，语法不是编译。

报告Documentation/M2_IMPORT_HANDOFF_VALIDATION_REPORT.json；成功证据ValidationLogs/m2-import-handoff-build6-success.json；设计与参考IMPORT_HANDOFF_FIX.md。Readium3.11.0/远程6 pins/Vendor本地扩展与Build5相同，没有升级依赖或改生成xcodeproj。

## 本轮实现与边界

1. App/Import/DocumentImportSheet.swift是书架与原生回归共用的sheet交接；LibraryView不再用未在正文读取的pendingImport @State。
2. LibraryViewModel持有pick结果，onDismiss读取并立即清空，再开始Task或展示错误；取消/重复关闭不启动旧导入。原Coordinator的一次终止/迟到文件过滤保留。EPUB与TXT走同一修复，文件副本/后台协调复制/数据库/编码/排版/完整位置未改变；project.yml Build6。
3. Tests/iOS/DocumentImportTests.swift新回归：首次TXT、首次EPUB、取消/空选择/再次选择/迟到文件。真实sheet和UIKit delegate → 原导入服务/SQLite/书架更新，不手动刷新或再呈现来促使首次导入；验证书籍唯一、成功提示和原文件bytes。呈现/关闭须完成真实transition和view脱离window，实际picker保留到host teardown，15秒deadline与全部断言保留。
4. 模拟器提供原创fixture URL给delegate，没有操作实际Files目录/云端下载；iOS18.5提取的旧交接首次TXT/EPUB也通过，因此用户iOS16.6.1现象的唯一根因仍未证实。参考模型交接消除页面快照存储依赖，自动通过不写成用户设备故障已确定解决。

官方/成熟参考：锁定d82f44f Readium3.11 TestApp由持久UIKit controller把delegate URL交给library Task；本项目取其引用拥有者原则，保留SwiftUI、宽data/asCopy:true、本地协调copy和关闭后提示。Apple StateObject/transitionCoordinator/dismiss completion及相同异常论坛报告已读，差异/证据限制写在IMPORT_HANDOFF_FIX.md；不调用私有selector或吞系统异常。

## 新包与旧包

- 新IPA：build/XianxiaReader-Import-Build6.ipa，7700896 bytes，SHA256 05196a90edca2269c4e9ec3e755808a168d50a4aab50666bef82933b07491e0c。
- 用户测试ZIP：build/XianxiaReader-Import-Build6-TestKit.zip，7590645 bytes，SHA256 112113c0e939c5d8aabdc5ad2280c8faf77f3f1d9288145e902d8ec3cc4a815c；含Build6 IPA、1本原创EPUB/3种编码TXT/UTF8 TESTING.txt，CRC/内部IPA/包内fixture bytes一致，Build6/arm64/iPhoneOS/最低16.0/0755/系统SQLite/第三方声明核验通过。
- Build5 TXT IPA SHA e48e6ceb5151ca22d23a5cbb4491f71f0e90d0c87e8cef570ea2bb539ab6e621、ZIP SHA 7d547c7582230e35860e0b591bb51adcf51f988a20470ff421d8805c6d1ac668仍保留。
- build/XianxiaReader.ipa仍是用户确认可用Build4，SHA 7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1；Continuous-Build4-TestKit.zip SHA f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7。旧包均未覆盖。

TrollStore正常更新应用，保留书库，不卸载/删数据库；实际安装由用户执行。普通签名设备单列待验收。

## 失败原件

38563181206 / 80e503d（提取旧交接）与38564595658 / e858ee6（参考模型修复初轮）均各68Core/iOS48/49、0 skipped，首次TXT/EPUB通过；新增取消/空选择/重试测试系统DocumentManager向deallocated host proxy发消息，NSInternalInconsistencyException致进程退出。test65/附件0/summary0，Release/IPA未执行。完整日志/原始xcresult及m2-import-native-sheet-baseline-failure.json、m2-import-build6-native-sheet-lifetime-failure.json保留，不写成编译失败、用户首次导入根因或通过。

最新5522489仅改测试过渡/生命周期等待，导入产品修复不变，未增加timeout或降低断言；随后本轮全部通过。不宣称已修复Apple系统异常。历史M1/M2失败、Build5成功37eb86a/38559906005的68Core/46iOS/Release与产品实现范围保留在HANDOFF_IMPORT_HISTORY_2026-10-14.md及既有M1/M2历史文件，不把它们当当前运行源码。

## 接续与保留

1. 用户设备完全退出重开后首次选择本地TXT，确认选择器关闭后直接导入/出现书；再重开首次选择EPUB。分别测“我的iPhone”与已下载iCloud文件、取消后再导入。保留既有书库、连续跨章/位置/目录/搜索/书签回归结果；普通签名设备/TrollStore分别记录。只有当前用户部分导入与Build4连续/重开确认，TXT完整设备矩阵未通过。
2. 接着按M2测数十MB长篇冷导入/cache重开、峰值内存/巨段窗口接缝/数千章。cache/阅读范围构建仍流式校验与读取，不能承诺仅元数据秒开；旧cache generation清理、巨段字体组合/资源边距/旋转待设备验收。M2落实后M3完整书库，M4字体/排版/主题，M5性能。XBook/知识库仍草案。
3. 本地main/HEAD6d761749911233122bcd031fcf718d22a19f9e77与原空index、所有原未提交文件保留。候选通过独立GIT_INDEX_FILE正常push；当前已测源码以5522489906224a089c91e92180bdcebbe9be2095/456 hashes为准，之后只文档快照不等于另一轮编译。旧370文件ZIP备份与四个旧包hash均核验保留，FILE_INVENTORY已更新。无自己启动的挂起进程/CI；Windows无Xcode，未启动/重置Docker/localhost/账单。

下一轮先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核Git/实际文件/完整日志/运行任务；长任务/可恢复步骤/构建测试前写checkpoint。build/.cache不随clone，GitHub artifacts14天，过期按锁重跑。新用户指令优先，自用/实际可用优先；卡点按锁定版本查官方与成熟实现，记录取舍，不盲补。
