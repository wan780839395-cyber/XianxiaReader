# R3 阅读位置隔离

## 连续返回原单例：准备条件通过，保留可见性疑点（2026-10-21）

诊断源d8d39d5 / CI39600873539仅原FreshReturnCapture单例1/1（46.146秒），没有生产修改。完整captured/restored附件与stdout一致：连续before/returned longTop=-599.125，char499、savedOffset与实际glyphTop均-3.125、nativeClip0、scrollY2367；返回重建WebView仍一致，独立重复seek目标-10实际-10.125、外层坐标不变。旧失败没有before，无法倒推其误差或根因；新增只读诊断await也可能扰动时序，不能称修复。

原测试准备在请求连续+600后只等待scrollY>500。章内long段落本身已有较大文档坐标，条件可能在移动前为真，不能证明本次动作完成。修正源e234b2bf6a583d0a1019bb142582c1bc97f34aab仅在原初始top探针同时读initialY，要求实际scrollY进入initialY+600的3px内再capture，附initial/requested/actual证据。实际移动、完整origin、false/true顺序、原返回3px/30秒/100ms及截图后独立观察保持；不是生产补丁，也不能当旧失败的合格根因对照。

用户授权的单轮CI39607326744 completed/success，修正源e234b2b，原单例1/1（51.275秒）、无失败/跳过，真实build/test及summary/export退出均0、源码编译错误0。准备附件实测initialY1767、requested2367、actual2367，旧>500在动作前确已为真；连续保存与返回longTop仍-599.125，同char499/offset-3.125/clip0。分页scrollX1206→1206。后续独立repeat实际-9.125对目标-10，误差0.875、外层2376不变，原几何合同过。

实际查看两张返回正文图均可读；第三张后续continuous-repeated-canonical-seek为白图，前一诊断版d8d39d5相同截图也白。该原观察先截图再读字符Range，未断言可见像素，因此几何通过不能等同可见性完成；原因尚未知，不归咎准备修正/环境，也不追认为已修。按本轮只验一例的授权保存，不追加CI、不进入R4；下一片只分辨实际可见性与截图取样时刻，再决定是否需要生产修正。

584输入逐blob匹配，父诊断源到修正源只有目标测试准备和HANDOFF两个文件；所有生产、分页加载、CI入口和其他方法保持。Windows464语法新增0/54限制（非编译）、76工具70过6 POSIX跳过，未为无变化的Python源码重跑；本轮Linux76/76。原生步骤1385秒，首suite前1280.445秒含工具/依赖/编译/启动，case51.275秒，余量含诊断导出；不能把总成本算纯测试。完整2662625字节artifact经digest/SHA/CRC核验，两个xcresult、完整日志、summary及全部附件保留build/ci/39607326744，只精确清重复ZIP。一次只读API EOF已留原始错误，没有重派任务。完整189/Core137/设备Release/手机未跑，无新IPA；分项权威见[本片结果](ValidationLogs/continuous-return-preparation.json)。

参考锁定[Readium3.11 VisualNavigator](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/VisualNavigator.swift)的采样接口与[CSSOM View Range几何](https://www.w3.org/TR/cssom-view/#dom-range-getclientrects)区分viewport和document坐标；本项目连续扩展不等同上游实现，也不把规范当实际WebKit时序证据。

## EPUB首次加载专项：对照有效，整组未过，已保存（2026-10-21）

用户选择本轮收口保存，下一轮只查连续返回，不追加CI或启动R4。实际控制基线609cbd03463b64f312216a1c397616cd2be0659f，候选0de44ba6d2d5875816f1a42a06d04f4313e21d9c为精确子提交；仅Vendor SpreadView和UPSTREAM差异，584输入各相位均核冻结Git blob。原R1/R2/R3、Readium JS、Core/锁及原测试行为/30秒/3px预算保持，普通HEAD/index及全部旧WIP保留。

锁定Readium3.11.0的spreadLoaded由requestAnimationFrame发送，分页缺少连续模式已有的原生完成bootstrap。本轮只控one.xhtml真实桥回调，证明DOM complete、窗口有效、pending1；旧码39.575秒在指定断言失败（内层alpha0、position cover、真实65）。候选桥仍held时完成完整初始化、alpha1/position one/full DOM锚点成立，放行原桥后保持。候选只扩大原有bootstrap到重排分页，保留字体/完整pendingLocator、once/close与位置guard，不把DOM完成直接当ready。固定布局不扩大；连续路径语句/await次序仅改标识，不能因此排除前序分页运行时影响。参考锁定[3.11.0原始SpreadView](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift)，复用已有连续桥屏障fixture，不升级依赖。

[CI39594313793](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39594313793)实际failure，候选5/6、真实65，无重试/跳过。受控分页、原连续bootstrap、两模式关闭、隐藏字体与同宽writer过。原FreshReturn用例首次跳转和整个分页分支已过（分页原生截图保留），但连续返回原点在981未满足原3px：返回后one.xhtml可见/完整初始化，scrollY2367、long top=-599.125、完整锚点char499/offset-3.125，已不是cover上报。原before值未记录，不能报告精确delta，也不能判断是新回归、原保存采样/返回误差或前序状态影响。旧R3c初始69秒延迟精确原因也未由这组对照证实。

下一轮只给原单例补模式/阶段、采样前后同一视图DOM、完整origin、跳出前before及返回后测量，保留false/true顺序和原3px/30秒。先区分错误origin与错误恢复/测量时刻；必要时才做同fixture旧/新单例对照，前置失败不能算返回负例，重放成功不能当根因修复。不先动连续算法、不重跑19/189。

两相位build-for-testing真实通过、0源码编译错误；Windows464语法新增0/54既有限制（非编译）、76工具70过6 POSIX跳过24.333秒，Linux76/76。原生driver1527秒：基线首suite前914.855秒准备，旧单例39.575秒；候选suite91.675秒（6项合计91.483秒），其他成本含增量准备及两次原件/附件导出。未跑独立24/Core137/完整189/设备Release/手机，无新IPA。完整119059067字节artifact经digest/SHA/CRC与展开核验，仅重复ZIP清除。详见[权威结果](ValidationLogs/epub-native-readiness-control.json)，原件build/ci/39594313793，冻结及失败单例在build/maintenance/EPUB-first-jump-20261021。下方R3c旧18/19仍按当时源保留，不改写成当前门槛。

## R3c实现与未通过的整组门槛（2026-10-21）

R3c保存断点（2026-10-21，用户已确认不追加运行）：导航/返回点负责人已在现有ReaderPositions实现并真实编译，源c180e1126cb1283f5599644a9232b8ee6ccf717e / [CI39585860717](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39585860717)结论failure。独立24/24、现有6项导航回归通过，原生整组18/19；唯一旧EPUB用例首次分页跳正文时DOM已到one.xhtml，但currentPosition仍报cover，尚未捕获/返回原点。该用例直接调用原引擎，未经过新导航负责人，原引擎/用例与上一片同字节；根因、环境归因及回归因果均未证，不能称整组或R3已验收。字体双模式六套、同宽分页writer、TXT及原保存回归通过。代码与旧WIP保留，下一轮只查此单例，R4顺延；未跑完整188/设备Release/手机，无新IPA。详见READER_POSITION_ISOLATION及ValidationLogs/project-isolation-r3c.json。

ReaderNavigationCoordinator在现有Foundation/Core包唯一持有完整返回点、导航令牌及busy状态，will-change通知接VM原objectWillChange。模块只接两个MainActor异步能力（采样、go）及同步会话/忙碌/暂停/成功通知，不持有引擎、仓库、字体或页面，不解析Locator。VM仍保留ready/engine检查与原目录/书签/搜索/返回入口及错误处理。新增入口核原会话，拒绝绑定重开后的新会话。

顺序为占锁→暂停→仅首次离开采样一次完整原点→原取消/会话/请求/所属书校验→go→原取消/身份校验→同步发布返回点/原隐藏菜单→defer只清自己的锁。发布全部在新增async入口内部完成，VM返回后不再提交。导航不复用保存的3秒/32ms重试；失败保留已有返回点、返回成功才清除，stay只在空闲时清除。原点只保存在会话内，不作为阅读进度写库；实际页面回调仍保存当前位置。旧采样不go，旧go不发布/隐藏新菜单，旧defer不清新锁；不能撤销已交给引擎的go。

字体原本共用导航锁，本片只把原锁赋值/defer换为beginExternal/endExternal；完整import/capture/save/reopen/commit与await原文保持。close仅在原三条清空的位置调用navigation.close，最后引擎回调及openRequestID失效顺序保持。原saveNow、R3a/b模块及桥接、其他33个VM方法、原16合同、全部原测试/fixture、Core/Vendor/字体/资源/manifest/锁不改。581输入SHA/实际运行Git树、普通HEAD/index与旧WIP核对。140 Swift源/17区域/18节点/5精确例外，未加target或白名单。

新增8项独立合同以continuation显式放行采样/go，覆盖完整原点/发布与通知顺序、失败/跨书原点/重试、字体共享锁/stay、迟到采样/go、取消及旧入口。原16合同原文保持。现24/24及原6导航回归通过；原生整组仍18/19，不能写19通过。Swift模块/App真实编译0源码错误；Linux工具71/71；Windows464语法新增0/54既有Vendor限制，71工具65过6 POSIX跳过（23.584秒），Bash通过。起草的unit-value语法表现与旧13项工具fixture计数在本地修正；首轮tooling失败原件保留，未改生产断言/预算。

唯一失败是ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes在最初分页迭代的jump helper1640超时：当前页报告cover.xhtml，实际可见DOM为one.xhtml/complete、long段落top=0。该用例直接构造ReadiumReaderEngine，没有调用VM或新导航模块；没有产生首个return-epub-paged截图，尚未执行原点捕获/返回断言。错误通用标签写Continuous，不代表已进入连续分支。源码路径与观察支持单列“跳正文后上报位置未更新”疑点；尚无匹配对照证明根因、环境归因或与本改动的因果。

其他18项通过，包括原6导航、保存/进度、双模式六字体、同宽分页writer及TXT。两模式字体/原字条件过，连续截图后六位置delta全0；同宽root写入0，真实进度1608/injected=false，owner/frame源码匹配冻结JS。以上仅对应样本，不可替代失败的EPUB完整返回点用例，也不能称整个位置行为稳定。

仅一轮CI。独立步骤142秒含Swift构建93.38秒；原生步骤1633秒，首suite前1116.23秒含工具/依赖/编译/启动，19项实际执行合计357.974秒，余量含诊断/导出。92811656字节原件经GitHub digest/SHA/ZIP CRC核验，完整日志、两个xcresult、manifest/附件在build/ci/39585860717；只精确清重复ZIP。失败单例原始日志在build/maintenance/R3c-20261021/failed-native-case.log，权威回执project-isolation-r3c.json保留failure/18+1及用户决定，不生成假成功回执。

参考[Swift SE-0306 actor重入](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)和当前锁定[Readium3.11 Navigator能力](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/Navigator.swift)，沿用引擎实际go、应用临时返回点的边界；MainActor不替代await后身份复核。复用项目已验同步提交/窄通知及受控fixture模式，不升级工具链或引入第三方框架。

用户已选择本轮保存、下一轮只查这一例，禁止追加CI或进入R4。下一实验先从原件比较adapter.currentPosition与navigator/currentLocation更新、初始化完成和go时序，区分正文已到但上报停封面与真正跳转未完成；需远程时只选原单例、保留同30秒断言，先明确对照条件，不无假设重放。完整188、设备Release、手机/动态验收未跑，无新IPA，最后交付Build30。

## R3b及更早历史证据（仅对应其当时源）


R3b捕获与持久化编排本片已实现、编译并通过定向验收。实际源`421a5786e2be65baf661bc889c166ac8f22aff41` / [CI39580846569](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39580846569)，独立16/16与原iOS13/13。分项回执[project-isolation-r3b.json](ValidationLogs/project-isolation-r3b.json)。导航/返回点下一片，R3整体及全项目隔离仍未完成。

## 责任及依赖

现有独立Packages/ReaderPositions保持Foundation→XianxiaCore、tools5.10、iOS16/macOS13。ReaderPositionState仍唯一持有完整不透明位置、保存令牌/所属会话及保存错误；ReaderProgressState仍只发布原去重进度摘要。新增ReaderPositionPersistence拥有显式捕获/等待/写库/错误/同步发布，也承接每个已接收进度事件的写库。没有新增包、target或远程依赖，原manifest、project.yml、依赖守卫及锁不改。

ReaderPositionSource只有固定布局能力、完整缓存位置和fresh捕获；nil只表示原引擎暂时不可采样。ReaderPositionStorage只有保存完整ReadingPosition。App的ReaderEnginePositionSource只把原unavailable错误转成nil，其他错误原样传播；ReaderPositionRepository只转发到原BookRepository actor，实际数据库I/O及旧时间戳拒绝仍由Core负责。模块不导入UI/Readium，不解析或重写Locator/TXT锚点。

## 保留的时序与行为

VM保留暂停慢滚→beginSave及defer→原慢滚flush→请求/取消检查→原设置flush→会话/ready/引擎检查这一整段。随后调用真正负责工作的captureAndSave；模块入口再核请求、非空会话及取消，采样、写库await后，在原guard内同步state.saved，完成后才返回VM。VM返回后只有原defer，不把状态提交移到新增await之后。此片新增异步职责入口，不能沿用R3a“所有await表达式原样”的说法。

固定布局继续使用完整缓存页，不采样；重排正文仍fresh捕获，原Date+3秒预算、32ms不可用等待及各挂起点后的身份检查保持。错误显示原中文消息、保留旧完整位置，重试成功才更新并清错。旧捕获不写库；已进入仓库的写入可能完成，Core按原时间戳处理，模块只阻止旧结果/错误覆盖新会话状态，不承诺撤销已提交写入。

引擎回调仍先同步接收完整位置，再每事件创建原来的一次Task；不合并或丢弃重复事件，不增加关闭后过滤，以保留close最后回调的写入。回调失败仍调用原暂停慢滚及可见错误处理。其潜在迟到错误属于后续会话切片，本片未宣称修复。open/close、导航/返回点、设置、慢滚及字体导入的capture→save→reopen特殊事务均未改，其他36个VM方法逐字保持。

## 定向合同与结果

- 原ReaderPositionStateTests六项完全保持；新增十项用受控continuation覆盖完整Locator及发布顺序、固定布局、不可用后重试、原3秒预算、采样/存储失败和重试清错、取消/过期入口、悬挂捕获、迟到存储结果，以及每事件完整写入与原错误。没有缩短生产预算或加入测试用生产开关。
- `bash scripts/test_reader_positions.sh <新的输出目录>`独立16/16，无App/Readium；拒绝已有目录，保留真实退出、完整日志、xUnit及真实依赖图。核验每项名字与所属类各一次，错误类/遗漏/多余/重复/失败/跳过均拒绝。
- 原8保存/生命周期+1进度+4 EPUB/TXT/双模式六字体/同宽writer，共13/13；原测试、fixture、断言和预算不动。真实模块及iOS App编译成功，无源码编译错误。Linux工具71/71；Windows462语法新增0/既有Vendor限制54，71工具65通过6 POSIX跳过；Bash通过。语法不是编译。
- 冻结579源码/测试/配置输入核对本地SHA与实际运行Git树；原状态/六合同、原35测试及全部Core/Vendor/字体/设置/资源/锁保持。138 Swift源、17区域、18图节点、5精确import例外，未扩白名单。普通HEAD/index及原有WIP保持。

原字/字体条件在两种模式六套字体通过；连续截图后的六个保存位置delta为[0, 0, 0, 0, 0, 0]。同宽分页回归原位置/原字断言通过，root写入0，真实进度值1608、injected=false，实际owner/frame源码匹配冻结JS。保留全部附件，包括多个挂载或空白WebView观察，不把它们直接当失败或静默删除。以上只支持对应样本，不能证明所有WebKit时序或手机体验。

## 成本与证据

只派发一次position-isolation，未跑完整188或设备Release。独立步骤101秒，Swift报告构建51.54秒；原生步骤1269秒，首suite前949.087秒包含工具/依赖/编译/启动，13项实际执行合计279.299秒，余量含导出及诊断。准备时间不是用例执行或纯编译时间。

完整artifact、两份xcresult、xUnit、依赖图、完整日志与附件在build/ci/39580846569，下载回执核对GitHub digest/SHA、字节数、ZIP CRC与安全展开；只清除该轮重复ZIP。冻结与最终文档检查点在build/maintenance/R3b-20261021。完整发布仍需同源门槛；本片无新IPA，最后交付Build30。

## 参考及实际取舍

参考[Swift SE-0306 actor规则](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)及[SE-0338非actor async执行规则](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0338-clarify-execution-non-actor-async.md)：actor方法在await处可重入，不能用MainActor替代身份复核。沿用当前工具链，不引入新并发模式。对照[Readium 3.11.0 navigator实际实现](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)与项目现有引擎合同：缓存currentPosition不替代正文fresh采样，App桥接不暴露Readium类型。复用本项目已验ReaderSettings/Core窄存储模式和现有ReaderPositions接线，不升级依赖或扩大改造。

## 历史及下一片

R3a源755b428a60143d8f649372e6c545cc1e03f82ecb / CI39573863939曾通过6+13，详见ValidationLogs/project-isolation-r3a.json及HANDOFF_R3_DEVELOPMENT_2026-10-21.md。首轮CI39569845077独立6过、iOS规划Core dynamic/CSQLite失败、0项执行，原件与失败回执仍保留；复用ReaderSettings包布局后接线可用，不宣称Xcode内部精确根因已证。旧[SwiftPM规则](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)、[isowords布局](https://github.com/pointfreeco/isowords/blob/main/Package.swift)及[GRDB不同消费图案例](https://forums.swift.org/t/errors-on-build-after-add-package-grdb/76189)只支持接线取舍，不移植其架构或根因。

下一独立片R3导航/返回点；字体导入特殊重开事务保留其原负责人，R4会话生命周期随后推进。完整Core137/iOS159+29=188、严格设备Release、普通设备/TrollStore、手机及动态体验均未在本片执行，不以16+13替代。原产品计划继续保留，维护期间不提前实现。
