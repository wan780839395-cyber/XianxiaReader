# 当前工作：R4b打开/重试/关闭编排隔离（2026-10-22，用户已授权）

仅推进现有ReaderSessions的编排切片。Foundation合同通过类型化方法引用接收原7个打开异步操作和原同步应用/清理；App保留SDK桥接。VM使用绑定方法值转交open/retryOpen，避免额外异步转发/Task；每次调用的编排上下文保留VM直到结束，VM不持有该上下文形成环。原阶段顺序、await后检查、字体失败降级、取消与普通失败区分、retry完整close后清错、close最终位置先接收再失效全部保留。R4a回调门/位置/字体事务和Core/Adapter/Vendor/锁不改。

源码及合同入口已写，尚未编译/验证：新增ReaderSessionLifecycle.swift、App/Reader/ReaderSessionHost.swift、8项ReaderSessionLifecycleTests；VM只替换原open/retry/close块为绑定入口与同步桥接工厂，其余方法不改。沿用既有包/target/架构区域，新增session-lifecycle choice只跑14独立+原13定向，不执行旧负对照；原生测试不修改、完整计数191不变。详细合同见Documentation/READER_SESSION_LIFECYCLE_ISOLATION.md。下一步先Windows语法/工具/静态顺序审阅，通过后冻结再派一次CI；语法不当编译。

Windows首检已通过：470 Swift语法新增0（54既有Vendor限制），Python83中76通过/7 POSIX跳过；工具新增核新choice不会执行旧负对照，独立14合同按各自类精确验收。此后仅修测试final-close observer的局部强引用为bookID值，避免fixture持有自身；不影响合同/入口，冻结前保留对其静态复核。当前无Swift编译/原生新结果，不记通过。

已冻结7ea52d41cbca4bdbe9271c3a984cb656a48872b8 / refs/heads/codex/isolate-reader-open-lifecycle，只派一次[CI39702147807](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39702147807)，selection=session-lifecycle。冻结收据build/maintenance/R4b-20261022/frozen.json：594运行输入逐blob核、9文件切片；原open完整流程经机械映射逐body比对一致，7await、检查/发布顺序保留，无异步转发/Task包装；其他VM方法及Tests/iOS/ReaderLifecycleTests.swift原件完全相同。普通HEAD/index保持。只读观察进程保存run/full日志/artifact元数据到build/ci/39702147807；若中断先查真实状态，不重派。当前编译/定向待结果。

首轮独立14合同步骤已成功，原生13正在同一CI准备。随后审阅仅修新测试失败清理：进入屏障超时先release/cancel/await旧Task，重开后先释放收完旧Task再断言newOwner非空；Gate可提前release。原2秒/所有行为断言保留，不是重试。此fixture源码变化须额外验证独立14，新增session_logic_only=true仅用于现有session-lifecycle时跳过原生步骤，默认false并有工具守卫；不再派第二个原生。最终必须分别记录首轮原生源与测试清理源，逐blob核实际App/库生产/iOS测试/工程/锁/版本一致，才能分项复用原13。正式结果未出，不能预报通过。

基线fd259b0f1a93df774c51fc74f1e521fc2254a06a；已核591运行输入与保存检查点一致、1203路径保护基线build/maintenance/R4b-20261022/before.json，普通HEAD/index不动，无旧运行观察进程。实现前已读4文档、实际源码、Git状态与原件；R4a真实6+13及旧1负保留。只跑新增包内编排合同与原13生命周期回归，不重跑旧负对照、Readium19、完整191或Release/IPA；先本地静态/工具，再冻结一次定向CI。原生准备成本与用例执行分记；发现其他边界失败先留证、不扩修。

以下为R4a已保存结果及历史，不覆盖本轮继续指令。

# 上一断点：R4a本片完成，下一片R4b（2026-10-22）

用户当前授权的会话归属与关闭失效切片已完成，实现/独立包编译/原生接线编译/定向验收通过；停在此边界，不自动混入打开/重试/关闭编排、I5或新增产品。电脑保持开机。下一片R4b保留原await/同步发布与现有定位；所有后续产品计划仍在ROADMAP/READING_FEATURE_IDEAS，未提前实现。

## 当前实际结果

- 运行源f516c28406a06884fa551d5ac25ef42028f59c3d / refs/heads/codex/isolate-reader-session-ownership，[CI39627814766](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39627814766) completed/success；仅一次派发、无原生重试。独立6/6；旧VM单例合格失败（5个STALE_SESSION_CALLBACK断言，test65）；候选13/13、test/summary/export均0；两轮build-for-testing成功、源码编译错误0。
- ReaderSessions Foundation-only产品拥有started/request/book与同步发布门；每次open绑定owner。旧tap/gesture/scroll/error/position及跨书位置拒绝，迟到写入错误不影响重开；close最后完整位置先接收再invalidate，已接收写入继续完成。字体失败允许重开但保留旧ID直到新begin的旧规则保留。原生产await行序列、28个旧测试正文完全一致，Core/Adapter/Vendor/字体/锁及R1/R2/R3定位源码不变。
- Windows最终467语法新增0（54既有Vendor限制，非编译），83工具中76过/7 POSIX跳过；远程冻结版本Linux82/82。冻结后5个工具/配置差异仅未来入口接线、规划正例与显式UTF-8读取，均本地复核；App/Packages/原生测试均与f516c28相同，不把这些工具改动冒充已在远程运行。静态142第一方Swift/19区域/20节点，5精确例外不增加。
- 当前仅R4a本片验收；R4b、R3整组、全项目隔离/完整162+29=191、设备Release/普通设备/TrollStore/手机均未验收，无新IPA，最后交付Build30。

## 成本、原件与恢复

包步骤83秒（Swift构建62.04秒），原生新旧对照步骤1719秒，首suite前1131.018秒；旧用例2.592秒、候选13项总0.890秒，实际执行合计3.482秒，其余是准备/编译/模拟器与宿主/结果采集。不能把1719秒称用例执行，也不能承诺共用缓存就没有候选启动成本。

权威Documentation/ValidationLogs/project-isolation-r4a.json；设计Documentation/READER_SESSION_ISOLATION.md；快速入口FAST_VALIDATION。完整artifact12359693099、56581158字节、SHA/digest4febf85f4266185ef620a40c478bfc0d5f309dee0368ff277fc65f3b84865f19，build/ci/39627814766/diagnostic完整保留，CRC/摘要/原始日志/四个xcresult/两阶段591输入逐blob已核。仅删除该已校验artifact的重复ZIP，不动历史、源码、包或恢复文件。

build/maintenance/R4a-20261021含1194路径保护before.json、frozen.json、result.json、最终工具日志及状态。普通HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，index SHA仍b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28；不得reset/clean旧WIP。收口检查点将保存到refs/heads/codex/reader-session-isolation-saved，实际SHA以同目录final-checkpoint.json和远程ref核对，不重派CI。观察/下载进程均已完成。

## 本片过程记录

以下是当时的中间状态与上片历史，均不覆盖上方最终结果；其中“待编译/运行中/下一片R4”的文字不可当作当前状态。

# 当前工作：R4a会话归属与关闭失效（2026-10-21，用户已授权）

R4a源码和最小验证入口已写，尚未编译/执行：新ReaderSessions Foundation-only产品、按次绑定owner的回调门、旧写入完成后的错误发布门，保留close最后位置先接收后失效。复核发现原字体失败只重置started不清ID，已用allowReopening原样保留，不能把两者合并。原28个测试正文保持，新增2个原生合同及6个包合同；新selection只跑旧1负对照+候选13生命周期例，共用runner/缓存，不跑全套。当前门槛因新增2例变为162+29=191，更新守卫不等于执行完整门槛。接下来先Windows静态/工具检查，再冻结只派一次此selection；详细合同见Documentation/READER_SESSION_ISOLATION.md。

Windows检查完成：467 Swift语法新增0（54既有Vendor parser限制），仓库/依赖边界通过；Python82项中75通过、7 POSIX跳过，日志build/maintenance/R4a-20261021/{repository,tooling}.log；3个受影响Bash分别bash-n通过。不是Swift编译。实时核CI39619940734已completed/success，无旧运行需要接续；本地无Swift命令。冻结前须逐旧方法/await行、全部1194旧路径hash核保护，再用私有索引提交；普通HEAD/index保留。

已冻结并仅派一次：f516c28406a06884fa551d5ac25ef42028f59c3d / refs/heads/codex/isolate-reader-session-ownership，[CI39627814766](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39627814766) session-isolation。冻结收据build/maintenance/R4a-20261021/frozen.json：591运行输入逐blob核对，1184旧路径hash未变；普通HEAD/index保持。VM所有旧方法除准入/失效/回调与2处字体started机械映射完全一致，原await行序列一致；原28个lifecycle测试正文全部一致。当前原生编译/定向待结果，禁止提前记通过。只读观察进程启动，输出run/full日志/元数据到build/ci/39627814766，若中断核实际job再决定，不重派。

冻结后仅补将来入口接线：plan_validation新增session-logic、full ci_ios执行同一6项独立入口并保留产物、1条工具正例；这4个工具/配置文件变化不参与本轮原生selection执行，须单独本地复核，最终检查点与f516c28分别记录。App/Packages/原生测试/锁不再改。远程仓库检查已通过；当前包编译尚待完成。不能把冻结后工具结果归入远程82项，也不能声称full脚本已执行。

后续入口本地复核完成：83项Python中76通过、7 POSIX跳过（tooling-final.log）；467语法/架构通过，142第一方Swift、19区域、20图节点、仍5精确例外；ci_ios bash-n通过。591冻结输入现仅上述4个工具/配置差异，全部App/Packages/原生测试hash一致。远程独立包步骤已完成（83秒），已进入对照原生环境/工程准备；完整6项/原生结果仍以最终下载receipt/日志/xcresult核验后记录。

2026-10-22 00点后恢复点：同一CI仍在运行。网页已显示旧单例2.592秒，先输出sameModelReopened/currentPositionStored，再仅出现scroll/gesture/tap/error/position五个STALE_SESSION_CALLBACK预定断言，1个case失败（不是5个case）。driver已进入候选重新resolve/增量编译，意味着旧门校验已放行；正式收口仍要下载并复核receipt、真正65和xcresult，不以网页尾部代替原件。候选13项尚待结果，不能重派CI；本地App/Packages/原生测试未再修改。

本轮范围：独立Foundation ReaderSessions负责人拥有started/请求ID/所属书及回调接收规则；VM保留原打开/重试/关闭编排、await和同步发布顺序，只按打开请求绑定引擎回调、关闭后失效。明确修正：旧闭包在同model重开后不接收；关闭后error/tap/gesture/slow-scroll回调不发布；进度已接收的每次写入继续执行，旧会话写入失败不污染新会话；engine.close最后位置回调仍先接收再失效。只选新独立会话合同及相关原打开/关闭/重试/迟到位置/导航/设置生命周期回归，不跑Readium19/全189/设备Release或截图重放。打开/重试编排、字体事务、保存/导航模块和Vendor/依赖锁不改；R4b后续。

已核584运行输入与9aac4d完全一致、普通HEAD/index保持，无旧观察/下载进程；1194保存路径保护基线见build/maintenance/R4a-20261021/before.json，上一交接原件同目录。预计影响新Packages/ReaderSessions、App/Reader/ReaderViewModel.swift、Tests/iOS/ReaderLifecycleTests.swift及最小XcodeGen/依赖登记/快速验证/CI接线与状态文档。新target必须实际编译接线；不只移动目录或给UUID包空壳。实现前先核实际fixture与既有模块模式，再冻结执行最小原生门槛，准备成本和测试分记。

以下是上一截图切片的已保存原始事实，不覆盖用户本轮R4a继续指令。

# 上一断点：重复定位截图边界本片通过，下一独立片R4（2026-10-21）

用户已授权先查清重复定位白图，再继续R4；本片已完成两轮同原单例的诊断/验证，停止追加截图CI。生产及分页加载/既有定位/R1/R2/R3隔离全部保留，无新IPA，电脑保持开机。普通HEAD/index及全部旧WIP不能reset/clean。下一片R4先明确会话请求归属、关闭失效与原await/同步发布顺序，随后拆打开/重试/关闭；不要为旧即时对照图再盲跑截图例，不把R4混入当前验收源。

## 实际修改与验收

诊断源841a2342c3851658dfaafab8f3b4e893916df305（codex/diagnose-repeated-seek-visibility），父上一文档检查点b2a199b；候选9aac4d10afbefd2144137d0ddc9af5dce7fca0d6（codex/fix-repeated-seek-snapshot）为精确子源，相对只有测试/HANDOFF两文件。584运行输入逐Git blob核，所有其他原方法保持；原false/true、+600准确准备、原30秒/100ms、返回3px、repeat外层0.5/原字3px和最初原截图都保留。新增3个私有helper及1个局部rect函数，只读native状态/截图/像素；没有新生产await或变更CI/Python工具。

白图出现在原go完成/DOM坐标已对，但像素更新尚未被截图纳入的时刻。当前挂窗WebView、alpha/presentation均1，原生frame正确；drawHierarchy Bool=true也能白。修正测试按生产contentInset扣62/34得778高真实viewport，维持0.9覆盖阈值；WK afterScreenUpdates=true纳入pending updates，随后验实际窗口非白、同一字/外层仍保持。首诊把874外层bounds当viewport分母，是本轮测试误测，已明确纠正，不能记成生产裁切问题。旧WK false策略来自成熟库通用快照，不适用刚go后的更新验收；Apple合同/取舍写入设计文档。

## 真实结果与证据边界

[诊断CI39615950830](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39615950830) completed/failure：0/1、28.808秒，build过、test65/summary0/export0。原位置断言过，新比例0.89016误测失败和WK false白图失败保留；之后同视图/同位置窗口图正常，不能把该后图倒写成最初图当时可见。

[候选CI39619940734](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39619940734) completed/success，实际head9aac4d，原一例1/1、43.231秒、无失败/跳过，build/test成功、源码编译错误0、test/summary/export均0。真实viewport覆盖1、同视图挂窗、alpha1；更新后WK图非白比例0.144965、实际窗口0.187717，两图实际查看可读；截图后原字top=-9.125、外层2376不变。原分页返回x1206→1206、连续longTop -599.125→-599.125、char499/offset-3.125一致。没有延长预算、固定sleep或测试重试。

原最初repeat图仍白且完整性Bool=true，作为不可靠即时取样的原始对照保留。本次原连续返回即时图也白，分页即时图可读；已实际查看五图，不称所有即时截图已验收。已修并验的是repeat的更新后原生渲染/位置合同，无新的引擎修复；精确GPU/物理屏幕时序和手机瞬态不在本片证明范围，旧连续失败缺before的历史根因也未追认。完整R3整组、Core137/iOS189、设备Release/普通设备/TrollStore/手机均未重跑，无新IPA，最后交付Build30。

## 成本、原件、恢复

两轮原生步骤1189/1064秒，首suite前1032.232/985.643秒为工具/依赖/编译/启动准备，实际case28.808/43.231秒，总实际测试72.039秒、准备2017.875秒；余量含导出/诊断。Windows464语法新增0/54既有Vendor限制通过（非编译），CI/Python源码未改不重复76本地工具；两轮Linux76/76。最终仓库结构检查在文档保存前执行，记录结果，不以检查代替原生。

权威Documentation/ValidationLogs/repeated-seek-snapshot-boundary.json；设计Documentation/READER_POSITION_ISOLATION.md。诊断完整artifact60316779字节、12354331379、SHA/digest4cc98ce99d66c1b92f611f28f68f9c02a53c5e095a401252ba2642f0a975127a，build/ci/39615950830保留。候选3797532字节、12355342399、SHA/digest99cf02d558826fd74f21cbc5aaf763ea56e44e6cb0c258c22418bd75a26852a1，build/ci/39619940734保留。均已CRC/完整展开、两个xcresult、summary和全部JSON/stdout一致核验；仅精确清重复ZIP，不动源码/包/旧原件。每轮一次只读API EOF均留原始stderr，未重派CI。

watcher及下载均已结束，临时浏览器页收尾关闭；恢复先查实际run/进程，不复用旧session/PID。保护1193旧路径、冻结及结果在build/maintenance/repeated-seek-visibility-20261021；最终文档检查点另记final-checkpoint.json，不是重新运行源。R4尚无生产改动，需作为下一独立切片建新保护基线，保留原close最后位置回调与open请求失效顺序，再按实际影响选择相应竞态回归；不无条件重跑Readium19/全189。

以下为上一片保存的历史原件与限制，当前以本页上文及专项结果为准。

# 上一断点：连续返回单例通过，测试准备漏洞修正，可见性另留疑点（2026-10-21）

用户最新授权：继续且只验证修正准备条件后的原单例。本片已收齐结果并保存，不追加CI，不进入R4；电脑保持开机。原HEAD/index与全部旧WIP必须保留，不reset/clean。

## 实际修改与结论

生产完全未改，分页native bootstrap及R1/R2/R3保持。诊断源d8d39d5d9301e93a9efe7790c57896c18869b9c6（codex/diagnose-continuous-return）增加原单例captured/restored/failed完整origin、原before/比较值和native几何证据，并加只选这一例的continuous-return入口；原false/true、3px/30秒/100ms及截图后的独立repeat保留。额外只读await可能扰动时序，诊断通过不能证明旧失败根因。

修正源e234b2bf6a583d0a1019bb142582c1bc97f34aab（codex/verify-continuous-return-preparation）是诊断源精确子提交，仅测试准备/HANDOFF两文件差异。旧scrollY>500在本次初始1767时已为真，现确认请求+600的目标2367实际到位后再capture，原返回断言不变。584运行输入与Git blob、所有其他测试方法/原返回后文、普通HEAD和index均核。验证确实等到本次动作完成，是本片已确认修正；旧失败缺before，精确原因仍未知，没有新生产修复可宣称。

## 实际验证与范围

诊断CI39600873539 completed/success，原单例1/1（46.146秒），生产未变。修正后[CI39607326744](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39607326744) completed/success，实际head e234b2b，原单例1/1（51.275秒）、失败/跳过0，build-for-testing及真实test成功，test/summary/export均0，源码编译错误0。Linux76/76；Windows464语法新增0/54既有限制（非编译）、76工具70过6 POSIX跳过24.772秒、Bash过，未为未变Python工具追加重跑。完整Core137/iOS189、设备Release、普通设备/TrollStore、手机未验，无新IPA，最后交付Build30。

准备附件initialY1767/requested2367/actual2367，legacyConditionAlreadyTrue=true。连续保存/返回longTop均-599.125、char499/savedOffset=-3.125、实际glyphTop=-3.125/clip0/scrollY2367；返回WebView重建但实际字相同。分页scrollX1206→1206。独立重复seek目标-10实际-9.125，误差0.875、外层2376不变，原坐标断言过。诊断版对应返回也完全相同，独立repeat误差0.125。这些只是各自样本，旧5/6与18/19不改写为全过。

## 必须保留的可见性疑点与下一片

实际查看本轮分页/连续返回原生截图均正文可读。但截图后的独立continuous-repeated-canonical-seek附件是白图，前一诊断版同名附件也白；其原流程先截图再读Range，仅坐标断言过不能代表可见像素验收。尚不能确定实际呈现与截图取样时刻的关系，也不能归咎环境或本次准备修正。原件与风险均保留，不隐藏或为此扩改/追加CI。本轮只验一例的授权已完成，下一片先单查这一可见性疑点，再推进R4；不从单次几何成功声称全部返回功能已修好。

## 原件、成本和恢复

权威Documentation/ValidationLogs/continuous-return-preparation.json，设计Documentation/READER_POSITION_ISOLATION.md。新原生步骤1385秒，其中首suite前1280.445秒为工具/依赖/编译/启动准备，单例51.275秒，余量含诊断导出；上一诊断步骤1666秒、首suite前1572.667秒，不把准备算纯测试。新完整artifact2662625字节，12350481069，SHA/digest 0e7be14f35285fea8e5ebb53763032f8239c325d5d6482991d4e110b70b18565；CRC/完整展开与两个xcresult/summary/全部附件JSON已核，原始日志在build/ci/39607326744。旧诊断原件在build/ci/39600873539，612791字节，digest dabbff242d3a715c6fa751e48f33e2e9b93ece66020573de21d20f870f5b1391。只精确清重复ZIP，不动源码/包/旧原件。

只读观察中有一次API EOF，原stderr已留，之后实际任务成功且完整日志收齐，没有重派CI。watcher和下载均结束；旧会话/PID不代表当前活跃状态，恢复查实际run/进程。冻结/保护/坐标汇总及两阶段回执在build/maintenance/continuous-return-20261021，最终文档检查点另记final-checkpoint.json，不是重新运行源。生成最终文档检查点前先执行仓库结构检查和保全核对；没有待执行原生任务。

以下保留上一轮加载缺口专项的历史原始结果，不能当当前运行状态。

# 当前断点：EPUB加载缺口对照有效，连续返回仍失败，已按用户选择保存（2026-10-21）

用户最新选择：先保存本片和失败证据，下一轮只查连续返回。停止追加CI/修正，不进R4；保持开机。普通HEAD/index和全部旧WIP保留，禁止reset/clean。

## 实际输入与结果

控制基线609cbd03463b64f312216a1c397616cd2be0659f（codex/epub-ready-control-baseline），候选0de44ba6d2d5875816f1a42a06d04f4313e21d9c（codex/fix-epub-native-readiness），远程refs已核；候选是精确子提交，仅Vendor SpreadView/UPSTREAM两文件差异。CI39594313793实际head为基线，脚本在合格旧负例后覆盖精确两文件候选，两相位584冻结输入均核Git blob，不能把基线head误当候选执行源。最终文档检查点另记于本地final-checkpoint.json，不是重跑源。

[CI39594313793](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39594313793) completed/failure。旧1项39.575秒合格复现指定断言失败，test65/tee0；候选6项为5过1失败，test65/tee0，无跳过/重试。两相位真实build-for-testing过，0源码编译错误。新分页加载屏障、原连续bootstrap、双模式关闭、隐藏字体、同宽writer过；原FreshReturnCapture用例首次跳正文及分页完整返回分支已过，连续返回981失败。因此只确认加载缺口修正有直接证据，整组/R3及全部定位未验收，R4未开始。

## 已改与实际断点

正文DOM complete不等于原生正文已经可读。旧页真实one.xhtml桥pending1时内层alpha0、currentPosition cover；候选用连续模式原有native didFinish+viewport/script探针启动同一完整初始化一次，字体/完整pending Locator完成后才alpha1/上报one/full DOM锚点，放行原桥后保持。仅扩大到重排分页；固定布局、连续语句/await次序、关闭取消、位置guard、Readium JS/R1/R2/R3/Core/依赖锁和原断言预算保持。精确3.11参考与取舍见READER_POSITION_ISOLATION及UPSTREAM。旧日志position先采样再await DOM，外层可见矩形没检查内层alpha；历史69秒延迟精确原因仍未证。

当前唯一失败为连续分支返回完整origin后的原3px断言，非初始封面问题。返回后DOM one、内层alpha1、初始化完成，scrollY2367、long top=-599.125，完整锚点char499/viewportOffset-3.125。原before值没有附件，不能确定delta或根因，不能归咎新代码或环境。分页原生截图与连续失败原件均保留；连续路径直接语句没变也不能排除前序分页状态影响。

## 下一轮唯一实验

只查原FreshReturnCapture单例的连续返回：先补模式/阶段、采样前后同一视图DOM、完整origin、跳出前before及返回后测量，保留false/true顺序、原3px/30秒及独立观察。先区分origin采样与恢复/测量时刻；需要远程才做同fixture旧/新一个单例对照，必须进入该返回阶段，不能把前置失败算返回负例或把单次重放成功写成已修。不要先改连续算法，不跑19/189或进入R4。若涉及更改预算/时序/范围，及时问用户。

## 验证、原件与成本

Windows464语法新增0/54既有限制（不是编译），76工具70过6 POSIX跳过（24.333秒），Bash通过；Linux76/76。原生driver1527秒，基线首suite前914.855秒含工具/依赖/编译/启动，旧case39.575秒；候选suite91.675秒（6项合计91.483），其余含增量准备和导出。不把冷准备当测试，不把5/6写成修复全过。未重跑独立24/Core137/完整189、设备Release/普通设备/TrollStore/手机，无新IPA，最后交付Build30。

权威Documentation/ValidationLogs/epub-native-readiness-control.json。完整原件119059067字节，artifact12344571830，SHA ae42d5dfee5f8e07cb4a509c07e9042cb29a300da7ba34a81a51ef0ef594f993，GitHub digest/CRC/完整展开均核；保留build/ci/39594313793/diagnostic中两相位xcresult、日志、summary、截图/附件、输入证明及baseline-verification。只清本轮重复ZIP，不动历史原件/包/源码。冻结、保全、工具结果、连续失败原件在build/maintenance/EPUB-first-jump-20261021，开发过程交接保存HANDOFF-development.md。watcher及下载均已结束、临时浏览器页已关闭；恢复查真实run/进程，旧exec/PID不当当前事实。

以下为上一片R3c当时的已保存断点，当前以本页上文和专项结果为准。

# 当前断点：R3c实现已保存，下一轮只查一个EPUB疑点（2026-10-21）

用户已选择先保存本片与断点，下一轮单查唯一失败；本轮不追加CI，不进入R4，保持开机。

实际运行源c180e1126cb1283f5599644a9232b8ee6ccf717e，codex/maintenance-navigation-return-r3c，[CI39585860717](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39585860717) completed/failure。最终文档检查点见build/maintenance/R3c-20261021/final-checkpoint.json，不能把文档提交写成新运行源。

导航/返回点已迁入现有ReaderPositions，完整原点、单次采样、原guard/go顺序、内部同步发布/菜单及只清自身锁保持。字体事务只换共享锁两行，close仅换同位置导航清空；R3a/b保存、其余33个VM方法、原16合同、原测试/fixture、Core/Vendor/字体/资源/manifest/锁保持。581冻结输入与Git树、普通HEAD/index及全部旧WIP已核；禁止reset/clean。

实际独立24/24（原16+8）、原生18/19无跳过，各一次；原6导航和保存/进度/双模式六字体/同宽writer/TXT均过，整组不能验收。真实编译0源码错误，Linux工具71/71；Windows464语法新增0/54既有限制、71工具65过6 POSIX跳过，Bash过。连续字体截图后六delta0，同宽root写入0、真实1608/injected=false。

唯一失败：ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes，初始分页跳正文时，DOM已为/OEBPS/one.xhtml且complete/long top0，engine.currentPosition仍OEBPS/cover.xhtml；jump helper1640原30秒条件未满足，尚未捕获/恢复原点，也没有首轮分页截图。此case直接构造原ReadiumReaderEngine，没有调用新VM/导航负责人；通用Continuous错误标签不能判为连续分支失败。引擎和fixture与上一片同字节，根因、环境归因及回归因果尚未证；不能称定位已完全修好或R3整组完成。

下一轮只查这一个跳正文/位置上报疑点：先比较currentPosition/currentLocation、go返回与初始化完成时序的原始证据，再定义可区分原因的单例对照；保留原断言/30秒预算，不无假设重跑19或188，不直接铺开Vendor修改。R4顺延，产品计划仍保留。

权威Documentation/ValidationLogs/project-isolation-r3c.json，设计/参考Documentation/READER_POSITION_ISOLATION.md，过程归档Documentation/HANDOFF_R3C_DEVELOPMENT_2026-10-21.md。完整92811656字节原件/两个xcresult/附件/日志在build/ci/39585860717，SHA/digest/CRC及完整展开已核，重复ZIP精确清除；保全/冻结/失败单例日志及工具首轮失败在build/maintenance/R3c-20261021。

仅一轮CI：独立142秒（Swift构建93.38秒），原生1633秒，首suite前1116.23秒准备，19项执行合计357.974秒；其余含导出诊断，不把准备算作纯编译/测试。完整Core137/iOS188、严格设备Release、普通设备/TrollStore、手机/动态验收未执行，无新IPA，最后交付Build30。恢复须核实际run/进程，旧exec/PID不能直接复用。
