# I6最终门槛失败已留证：不重跑full

2026-10-22 I6最终full已完成一次，源77eebf40/CI39735403242/Build31：192全部执行，191通过、1失败、0跳过（集成162/163、UI29/29）。六模块68、两平台Core各137/TXT Release各4、Linux109工具通过；模拟器编译通过。唯一失败为连续视口变宽后的原字/WebView联合等待，缺缩放前原锚点及子条件诊断，未证明根因或修复。test65、summary/export/recording0；Release被阻止、未执行，无新IPA，最后交付仍Build30。无额外原生预检/重跑，完整原件已核；用户已决定本轮保存完整断点，下一轮只查此单例；本轮不追加诊断或CI。I6未通过，不进入新功能。 见[原件与断点](I6_FINAL_ACCEPTANCE.md)。

---

# I6d 最终范围已核（2026-10-22，尚未派发）

下一轮推荐冻结最终输入后仅选择workflow `diagnostic_selection=full` 一次，原生163+29=192及同源严格设备Release/包；保留现有组件/Core/TXT快检。不要前置position-acceptance/fonts-full/rotation-full，不走不合格的unit-release旧UI复用。本轮仅审计，未启动。可复用原件、剩余门槛及成本见[I6d最终范围](I6_FINAL_ACCEPTANCE_SCOPE.md)。

---

# I6c 初始化关闭单例入口（2026-10-22，1/1）

workflow `diagnostic_selection=initialization-close` 只执行原初始化关闭单例（分页/连续两个分支），不跑Core/独立包/23项/全套或打包。598aedd / CI39729365995编译、原单例及两模式pending门/断开清理回执通过；原实例hook丢失机制与测试准备修正见[I6c结果](I6_INITIALIZATION_CLOSE.md)。verify_reader_positions.py close严格核事件/summary/两模式证据，保持真实退出码。

---

# I6b 位置/加载定向入口（2026-10-22，已执行22/23）

workflow `diagnostic_selection=position-acceptance` 只运行审计确定的23项原生用例，不执行独立包、Core、全套或设备打包。结果以verify_reader_positions.py acceptance核对精确事件、summary及真实退出码；原生产/测试正文与预算保持。源075c2cc / CI39721680702真实编译通过，23项实际22通过/1失败/0跳过，test=65、summary/export=0；初始化中关闭用例在准备探针处超时，未执行关闭断言。原件已保留，不能重跑整组凑绿；下一步仅单查这一例，见[I6b结果与断点](I6_POSITION_ACCEPTANCE.md)。

---

# I6a 当前验收入口（2026-10-22）

完整发布的ci_ios.sh在原真实退出检查后、设备Release前新增`verify_ui_baseline.py --full-summary build/test-results-summary.json`，要求192/192且零失败/跳过；本轮只做本地105工具检查，未运行完整或设备门槛。完整artifact收齐六个独立合同目录。下一片23项原生范围见[I6a审计](I6_ACCEPTANCE_AUDIT.md)，尚无新selector/派发。历史UI复用配置28项/ARM与当前29项/Intel不匹配，不能作为捷径。

---

# I5c 搜索快速入口（2026-10-22，本片已验证）

- `bash scripts/test_reader_search.sh <fresh-output-folder>`：macOS独立ReaderSearch8合同，Core/Combine，无App/Readium。
- workflow `diagnostic_selection=search-isolation`：仅上项及13原生搜索/输入/返回点；先build-for-testing，再启动模拟器。精确case/依赖/退出码验证见`verify_reader_search.py`，门槛不能替代完整192或设备Release。
- 边界与原顺序见`SEARCH_ISOLATION.md`。最终53f7e1f2/CI39715718761为独立8/8、原生13/13及编译通过；不代表完整/设备验收。

---

2026-10-22 I5b已验：`bash scripts/test_book_imports.sh <fresh-output-folder>`仅BookImports8项；`import-isolation`仅包8+原生14，先接线编译再模拟器，不跑完整192或IPA。最终c8b53e38/CI39712813755为8+14及编译通过，仅本片门槛，详见IMPORT_ISOLATION。

2026-10-22 I5a已验入口：`bash scripts/test_library_shelf.sh <fresh-output-folder>`仅LibraryShelf六合同；`library-isolation`仅该包+原书库/回收站/封面17+新增延迟初始化1=18项，不跑完整192/IPA。最终1532b863/CI39707770264独立6+原生18及编译通过，仅本片门槛，详见LIBRARY_ISOLATION。

# 隔离模块快速验证

R4b当前入口（2026-10-22）：`bash scripts/test_reader_sessions.sh <新目录>`直接编译真实Foundation-only包，当前15合同（原会话6+编排/桥接9）；`session-lifecycle`默认先15再原13生命周期，仅本片。若只改此包/夹具，可显式`session_logic_only=true`，该模式已在CI39702833284验证当时14项通过且原生步骤skipped；最终15在CI39703522408完整包步骤重新编译/执行。不能把只跑逻辑模式称原生/设备验收。旧session-isolation的新旧回调对照仍保留，不为纯提取反复重跑旧负例。

本片首CI39702147807包14过、App3处具体actor方法值编译失败，未执行原生；修正只经已有异步协议取值，最终c0008349 / CI39703522408为15+13通过。Windows470语法无新增、83工具76过/7 POSIX跳过；最终Linux83/83。最终包步骤92.0秒（Swift构建68.55秒）、原生步骤1054.0秒，首suite前992.658秒，13项实际0.652秒；首失败及独立夹具成本另见原始回执，3派发/2原生构建尝试/1次原生用例执行，不隐去失败成本。完整门槛仍191未跑，独立15另计。下方R4a与其他日期均为历史数量。


当前事实以此段为准：f516c284 / CI39627814766独立6/6、旧1项合格失败、候选13/13，真实编译通过。Windows最终83项中76通过/7 POSIX跳过；远程冻结源Linux82/82，新增规划正例及显式UTF-8工具修正另经本地检查，未归入远程82项。模块步骤83秒（Swift构建62.04秒）；原生对照步骤1719秒，首suite前1131.018秒，旧用例2.592秒/候选13项合计0.890秒；其余为准备、构建、启动与结果采集。只派一次、无原生重试。完整191/Release未跑，下方其他日期数量为历史记录。

R4a当前入口（2026-10-22，本片定向通过）：`bash scripts/test_reader_sessions.sh <新的输出目录>`直接编译真实Foundation-only包并精确执行6个会话合同，无Core/Readium/App宿主。`session-isolation` workflow只跑此入口、旧VM的1项合格回调负对照和候选13项生命周期回归，保留原exit/summary/xcresult，不导出IPA。详细合同与原await/关闭顺序见READER_SESSION_ISOLATION.md。

冻结原生输入f516c28后补充的自动计划/完整门槛接线单独验证：plan_validation对ReaderSessions源码先列session-logic，再列既有原生门槛；ci_ios在原有包检查后执行同一会话入口，完整产物保留ReaderSessions目录。不会因独立合同通过自动复用UI或签发Release；本轮完整脚本未执行。新增2项iOS回归后未来完整计数162+29=191，独立6项另计。

R3c当前入口（2026-10-21）：test_reader_positions.sh独立24项（状态6+保存10+导航8）通过；position-isolation保持原13项并补原6导航，当前19项实际18过1失败，严格native verifier拒绝成功回执。未改原测试/断言/预算。源码c180e112/CI39585860717，用户决定本轮保存，下一轮仅查FreshReturnCapture首次EPUB跳正文/位置上报一例，不重跑19/188碰运气。完整Core仍137、iOS159+29=188；无IPA。

历史R3b入口（2026-10-21）：`bash scripts/test_reader_positions.sh <新的输出目录>`真实独立16/16，原状态6项及捕获/持久化10项，精确核验名字和所属测试类，各执行一次、无失败/跳过，真实依赖仅ReaderPositions→Core。本轮步骤101秒，Swift报告构建51.54秒；workflow position-isolation先这16项，再原13项iOS合同，源421a578/CI39580846569均通过。原生步骤1269秒含准备/编译/启动/测试/导出，首suite前949.087秒，13项执行时间之和279.299秒。不跑完整188/设备Release/IPA；未来完整发布通过同一脚本另执行16项，不把它们塞入iOS计数。Core仍137、iOS仍159+29=188，当前未执行完整门槛。原13测试与预算保持。

以下按所标日期保留历史入口和成本，当前数量以本段为准。



2026-10-21最新：分页writer定向补证39561815911完成，同一单用例旧负例1/1、新正例1/1，原字与无位置写入均核；生产9bb6c86保持，下一切片R3未实施。完整188、设备Release/手机仍待独立门槛，不能把本1+1或历史9/9称全量通过。首组屏障越界失败保留；最新事实见HANDOFF与ValidationLogs/paged-font-control-39561815911.json。

当前分页快速入口：macOS单正例用`bash scripts/ci_reader_diagnostic.sh paged-resize-control`，只选已有same-width用例；对照用`paged-font-control` workflow输入，在已经冻结的旧源branch派发，预先提供exact-child候选，driver只跑旧/新各1case并严格核目标frame、snap注入、真实进度旁路、原位置/原字断言与输入。默认候选ref为`codex/fix-paged-font-owner-control`，重用时必须先更新成与新baseline精确配对的源，不能把历史ref直接套在任意当前HEAD上。已有`paged-font-acceptance`9case内部入口保留，但本片未重跑9/188；此对照不打包设备IPA。

2026-10-21分页维护补充：新增1条可控body resize原生回归，未来完整门槛为159集成+29UI=188，Release严格unit计数同步提高159；完整188尚未执行。当前9+9已结束，候选9/9但原生负对照未命中，用户保存断点，不代表修复/发布门槛，最新见HANDOFF与paged-font-investigation回执。下方R2的187仅其当时源的历史数量。

2026-10-20。本片已实现并通过真实定向编译/执行，唯一CI39398382008/源1545a3cdafa248e563c01c408e04cd8cc3e71154；原件及分项回执见ValidationLogs/project-isolation-i1.json与build/ci/39398382008。本维护源未执行完整180/原生动态/设备Release或手机验收，未生成新IPA。

## R2新增入口与当前门槛

ReaderFonts已在XianxiaReading内独立编译，当前font-isolation诊断选择覆盖53项（7模块、8原字体、7设置、28生命周期、2真实字体、1原生picker），修正源410343b/39418977905通过；不生成IPA。字体仍依赖iOS的ReadingInterfaces，未建macOS无App字体入口；不要把下方I1的115秒当R2编译耗时。

原测试保留，增加7字体合同后完整门槛158集成+29UI=187，unit-release的严格计数同步提高158，保护输入/环境要求不变。本维护源完整187未跑；任何生产/UI输入变化仍需新验证，不能借本入口复用旧UI。I1设置包/脚本/原7合同未改，下面计时仅保留其历史实测。

## 最小模块与保留合同

ReaderSettings本地Swift包仅依赖XianxiaCore，最低iOS16/macOS13、Swift tools5.10；原ReaderSettingsPersistence从App移动到该包，仅公开现有调用需要的类型/成员，排队、错误、owner/request过滤、flush和文件路径不变。Combine来自Apple SDK，不引入OpenCombine、Readium或新远程依赖。Linux Core包保持原有依赖与测试入口。

原7项ReaderSettingsPersistenceTests与ControlledReaderSettingsStorage使用同一份包内测试源，函数主体与原文件一致；macOS SwiftPM无App宿主执行，原iOS XianxiaReaderTests也明确编译该文件，ReaderLifecycleTests继续使用原受控fixture。原151集成+29UI发布门槛不删减。

I0的生产源码单一编译归属继续保持。只对这一份精确测试文件登记sharedTestSources、两个unit-test target及理由；守卫拒绝把该许可用于App/其他生产target。共享测试不意味着运行实体重复或用复制测试掩盖错误。

## 执行入口

- macOS：`bash scripts/test_reader_logic.sh <新的输出目录>`。不传目录时使用build/ReaderLogic；已有目录会失败保留，选择新目录再执行，脚本不删除原证据。
- 现有iOS Build and Test workflow的`reader-logic`选择：仓库静态/工具检查后，仅执行macOS逻辑job；不启动Linux性能探针、模拟器、Readium解析或设备打包。
- `reader-logic-integration`选择：先执行完全相同的7项快速逻辑，再执行原settings诊断（设置/生命周期），验证App导入、公开接口、iOS链接及原行为。不执行完整UI或设备Release，也不生成IPA。
- 原默认完整发布路径保持，ci_ios.sh在Core/iOS原门槛之前增加同一逻辑脚本。快速结果不替代完整发布验收，开发迭代无需反复导出IPA。

脚本保留真实SwiftPM退出码、完整日志和xUnit；verify_reader_logic.py要求原7个名字各执行一次，无失败/跳过/重复/遗漏，同时读取真实show-dependencies JSON，依赖树必须只有ReaderSettings与XianxiaCore。零测试、错误类别或额外依赖不能写成功回执。receipt只承认macOS逻辑，不承认iOS集成、原生体验或发布。

## 本轮实测与已有分层入口

| 层级 | 入口/本轮结果 | 证据范围 |
| --- | --- | --- |
| 仓库/工具 | check_repository与Python unittest；Linux61/61、Windows58通过3既有POSIX跳过 | 静态/工具，不代替Swift编译 |
| 独立设置逻辑 | test_reader_logic.sh；macOS7/7，步骤115秒，编译92.18秒，case耗时之和1.521秒 | 真实依赖仅ReaderSettings/Core，未启动App/Readium |
| App设置合同 | ci_reader_diagnostic.sh settings；原iOS35/35 | App/测试接线与设置/生命周期合同；case合计1.963秒、suite墙钟2.454秒，步骤1763秒含准备/编译/启动/导出 |
| 真实引擎合同 | 复用ci_reader_diagnostic.sh fonts / preferences-idempotency / reader-session等既有选择，按当片合同选最小范围 | I1未执行，不复用Build30冒充当前源通过 |
| 原生UI | 复用ci_reader_diagnostic.sh settings-ui / background-ui等既有选择 | I1未执行；XCTest与截图不代替手机动态体验 |
| 最终发布 | ci_ios.sh / workflow full，冻结输入执行原151集成+29UI及严格设备Release | I1未执行，留I6；定向逻辑成功不授权跳过 |

上述计时来自完整原始日志与job步骤，不把case耗时之和、冷编译、App启动或整个CI墙钟混成一个数字。SwiftPM还会输出一次Swift Testing“0 tests”信息；本项目7项是XCTest，必须以同轮tests.xml的精确身份核验，不能据那一行判定零执行或拿它当七项通过。

## 影响范围映射

`python scripts/plan_validation.py --changed <仓库相对路径...> --report <输出JSON>`。

工具读取I0的真实声明图与逐文件编译归属，计算反向影响；同一测试源的两个target都纳入。文档/工具改动与生产依赖分别规划，设置逻辑优先运行快速入口；App/引擎受影响时仍列出iOS/原生检查。未知/删除文件、锁、工程、资源及共享配置保守转为完整范围。未登记依赖或源码先由架构守卫失败；工具只给计划，不执行命令、跳过门槛、复用UI结果或签发验收。

当前App仍共用target，影响范围会偏保守；R2/R3/R4/I5拆分后再逐步细化。不能凭文件名推断字体、位置和生命周期已经互不影响。

## 已核原始资料

- [SwiftPM swift-6.1.2-RELEASE SwiftTestCommand](https://github.com/swiftlang/swift-package-manager/blob/swift-6.1.2-RELEASE/Sources/Commands/SwiftTestCommand.swift)：核对parallel、xunit-output及XUnitGenerator的真实字段。该版本非parallel路径不生成所需并行xUnit，故入口明确使用parallel；不更换测试框架或放宽原断言。
- [XcodeGen2.46.0 ProjectSpec](https://github.com/yonaskolb/XcodeGen/blob/2.46.0/Docs/ProjectSpec.md#sources)：多个明确源路径与包产品依赖；project.yml仍为唯一工程源，不编辑生成xcodeproj。
- [GitHub workflow_dispatch](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_dispatch)：手动触发的workflow文件须在默认分支登记。因此复用已有ios-build.yml的明确选择，不为分支试验新增重复workflow或改main。

本片只封装已实现的R1并补快速测试，不提取R2字体/R3位置/R4会话，不更改主题、设置完成时机、定位预算、Vendor和原真实锁。
