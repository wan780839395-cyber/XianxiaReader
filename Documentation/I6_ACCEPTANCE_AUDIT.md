# I6a 剩余边界、验收范围与发布门禁修补

后续更新（2026-10-22）：下文是I6a时点审计。I6b已新增并执行精确23项入口，真实编译通过、22/23，初始化关闭用例的准备探针失败，原件保留；I6整体仍未验收。最新结果和唯一下一步见[I6b位置/加载定向结果](I6_POSITION_ACCEPTANCE.md)。

2026-10-22。本片完成源码/证据审计和两处必要发布门禁修补，不是I6最终验收。基线保存点`88e3d87089677fc97a79816fef755360234b289d`，被测运行源`53f7e1f268d58f37219dcbbba1d47204c57db124`；开始时617运行输入与保存点一致；本片只改5个CI/tooling输入，其余612原样。所有生产Swift、原生测试、工程、依赖/锁/资源均未改；没有派发CI、原生、全套或Release，未生成新App IPA。

## 当前结论

核心编排已形成真实模块并接线编译；整个App的类型隔离及同源完整验收尚未完成。当前静态登记为156第一方Swift源、25区域、26图节点、2精确测试例外；新功能仍须先明确所属模块、状态/持久化负责人、允许依赖、取消/迟到结果、独立合同和跨模块门槛，沿用PROJECT_ISOLATION_PLAN，原产品计划不变。

## 剩余边界及处置

| 边界 | 现场事实 | 本片处置 |
| --- | --- | --- |
| Reader宿主 | ReaderViewModel:69仍持有AppServices；位置/字体/会话编排已分出，但宿主仍能取得广泛Core能力 | 明确保留债务；以后按具体变更收窄端口，不在审计中重写Reader或宣称全项目彻底隔离 |
| 书库界面 | LibraryViewModel仍拥有批次导入Task、picker、反馈及操作互斥；BookImports拥有实际导入事务 | 现有界面编排保留；新导入业务进入所属模块，批次重构另片 |
| UI/平台桥接 | 三个界面仍在App target；ReadingInterfaces含UIKit；ReaderFonts仍依赖该iOS合同 | 静态守卫与真实模块编译分开报告；没有无App macOS字体门槛，不为形式增加UI targets |
| Readium例外 | ReadiumSearchTests.swift、TXTReadingTests.swift精确导入ReadiumShared | 均为真实集成fixture，理由/移除阶段齐全，保留；生产Readium SDK仅在Adapter，App组装只引入ReadiumAdapter |
| 既有源码警告 | 10次/8条唯一警告，与I5b逐条一致；搜索新增0 | LibraryAssembly符合、ImportOutcome及UIKit delegate Sendable，当前Swift5编译通过；另片处理，不静音、不混入Swift6迁移 |

## 已有证据可以怎样用

逐个读取原始xUnit、完整组件测试日志、真实依赖图、环境及完整workflow日志，并比较模块/测试/传递Core/执行脚本/验证器/.gitattributes的Git输入集合。以下仅可分项复用，绝不能相加成当前源的68项执行或同源原生/完整验收。

| 独立合同 | 原run | 原结果 | 当前输入差异 |
| --- | --- | --- | --- |
| ReaderSettings | 39398382008 | 7/7 | 65个输入，差异0 |
| ReaderPositions | 39585860717 | 24/24 | 69个输入，差异0 |
| ReaderSessions | 39703522408 | 15/15 | 8个输入，差异0 |
| LibraryShelf | 39707770264 | 6/6 | 66个输入，差异0 |
| BookImports | 39712813755 | 8/8 | 66个输入，差异0 |
| ReaderSearch | 39715718761 | 8/8 | 66个输入，差异0 |

R3c整轮CI39585860717仍为失败18/19；复用的是其单独已通过的ReaderPositions24合同，不复用失败原生门槛。其完整workflow日志实际文件名为complete-run.log，已核实存在，不因没有full.log误判丢证。所有组件均记录Apple Swift6.1.2环境与日志SHA；后续环境变化必须重新审阅。

Core在Linux CI39418977905、macOS CI39373881574各有137个唯一真实测试事件，Core/.gitattributes输入与当前无差异；只作为对应历史组件证据，最终仍核工具链/SDK/SQLite，Linux不能替代Apple文件协调或设备验收。ReaderFonts的iOS接口依赖已变化，旧53项只作历史；不复用为当前已过。

最新CI39715718761已真实编译包、App和测试targets，但仅执行搜索13项及独立8项。当前仅复核其原始结果，不重跑。Python工具102项是该轮Linux结果，本轮不虚写成新执行；本片因CI/tooling门禁有修改，已重新运行全部105工具检查（Windows98通过/7 POSIX跳过），不是复用旧102；Linux本轮未跑。仓库/语法守卫484文件无新增诊断、保留54个Vendor限制（非编译）。

## 下一片最小门槛：23项，尚未执行

目的仅为在当前整合输入下收口R3位置保真，再决定是否进入最终整合。取现有position-isolation19项与epub-ready-patched6项的去重并集23项：15项轻量状态/持久化/导航合同，8项真实EPUB/TXT、字体/加载/关闭合同。一次冷准备，不能拆成多轮单例再凑通过。完整精确清单见ValidationLogs/project-isolation-i6-audit.json与本地build/maintenance/I6-audit-20261022/next-native-cases.txt。

在原19项之外只加：

- `ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews`
- `ReaderRenderingTests/testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge`
- `ReaderRenderingTests/testPagedNativeLoadDoesNotWaitForAnimationFrameBridge`
- `ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord`

保留原断言、超时预算、受控屏障和失败清理。当前六字体真实用例已在原生截图后断言saved.visible、abs(delta)<3及anchorCondition=true，不能把先前等待的一次成功代替这一独立观察；原连续返回同时保留3px坐标、当前+600准备条件与更新后原生/WK截图检查。必须读完整23项事件、summary和真实退出码；原始文本/像素证据另核，不把坐标等同于手机流畅度。

如果出现失败：先保存完整日志/xcresult与原断言，然后证明属于该边界；不增加重试、不放宽预算、不自动拉入无关修复或完整CI。若是相同假设无新证据，不重复跑。最近原生冷准备约15–16分钟；23项中的双模式六字体测试另有执行成本，不能承诺4.4秒或把13个搜索用例的耗时用于估计这一组。

本轮只审计这组范围，没有新增23项selector或派发这一组；workflow只补产物保留路径。下一片需要接一个精确23项入口并冻结输入，不能直接调用会重复选择/只执行其中一半的旧入口。

## 两处实际门禁缺口及本片修补

1. 完整ios artifact原来未收ReaderLogic、BookImports、ReaderSearch的xUnit/依赖/receipt等目录；现补齐六个独立模块目录，always上传及原日志/xcresult/录屏保留规则不变。
2. ci_ios.sh原来只在unit-release检查163摘要；full未明确检查192全部通过且零跳过。现复用verify_ui_baseline.py新增--full-summary，要求result=Passed、total=passed=192、failed=skipped=0且无testFailures；放在原test/summary/export/video真实退出检查之后、设备Release/IPA之前。没有修改Xcode命令、选择范围、原退出码或断言。

本地正反例包括零/缺/多/失败/跳过/矛盾摘要，以及实际ci_ios.sh测试到Release代码片段。旧成功夹具只输出占位SUMMARY且没有新Python入口，首轮105中1项失败已保留tooling.log；修正为真实JSON和真实验证器后，全105为98通过/7 POSIX跳过。测试证明跳过1项会阻止Release检查点，原测试/导出/摘要/录屏失败仍保留退出码。临时test.ipa是原打包工具的小夹具，已随临时目录清理，不是本项目的新App包。

真实完整192及这份修改后的workflow尚未在macOS执行；上述只能证明本地门禁逻辑，不能写成完整/设备已验收。历史28项UI复用配置保留原事实，当前仍拒绝复用，后续只能从真实新结果建立基线。

## 最终门槛及不能复用的范围

最后交付Build30完整源的受保护生产/包/工程输入有51路径变化。实际UI复用配置仍是CI39196134450/8f5b427的历史28项、ARM环境，与当前有54处受保护变化且当前为29项/Intel环境；不得把旧记录改称29项或当前通过。即使Tests/UI不变，也不满足verify_ui_baseline.py的复用条件，不能走旧29项UI复用的unit-release捷径。当前静态用例库存为163集成+29原生UI=192；23项定向不能代替它。

23项收口后，再冻结最终源、核对必要组件环境，并单独执行同源完整192和严格CODE_SIGNING_ALLOWED=NO设备Release；发布前核真实日志/summary/附件/录屏/包内容，不能失败后直接发IPA。普通设备、TrollStore、真实位置/字体/后台/旋转和流畅度反馈单列；本片未进行上述验收，也未生成新IPA，最后交付仍Build30。

本片除这两处验收门禁外，不做AppServices/全UI提取、批次重构、警告消除、CI缓存工程或任何新产品功能。I6a完成，I6整体仍未验收。

权威机器记录：Documentation/ValidationLogs/project-isolation-i6-audit.json；本地before/audit/精确用例清单/检查与最终保存点见build/maintenance/I6-audit-20261022。
