# S拒绝诊断已保存：零CI，未编译，下一步需新执行授权（2026-10-22）

2026-10-22 S rejected被动诊断切片完成，零CI：旧同请求attempt0/1/2可证明前两次有效snapshot后documentTop不匹配，第三次终止原因仍缺。只补两Swift DEBUG诊断（冻结clip/frame、同次documentTop、逐项guard观察/实际reason）及两项Vendor摘要，原JS/await/算法/测试/断言预算保持；其余614运行输入不变。484语法/静态及14工具通过/1 POSIX跳过，未编译/原生运行。不能称S已通过或旧full根因已证，旧191/192及Release/手机缺口、Build30保持。见[诊断与判读](Documentation/I6_VIEWPORT_S_DIAGNOSTICS.md)。

基线fe23d245，最新源见build/maintenance/I6-viewport-s-diagnostics-20261022/final-checkpoint.json；before/scope-audit/result及本地完整日志同目录。旧CI39782692503/65a82618仍smoke 0/1，旧原件已核未动；没有运行helper或新CI。已用旧控制流证明前两次重试来源，第三次及DOM回到1767的写入者仍未知，不能把scrollY直接当documentTop。

新增sample-decision在迭代退出defer同步发出，guard布尔值为await后观察、reason为实际分支；取消可在观察之后到达。clip/frame是请求开始冻结值，documentTop来自原同次JS返回；无额外JS/采样/await/Task。原guard/catch只加DEBUG原因，Release归一文本一致，原断言、fixture、S/M资格、事件上限和预算不改。snapshot-unavailable内部的Locator解码仍属组合分支，没有为细分而重复解码。

下一片只有用户新授权才可原生编译/跑原smoke单例，先核新增clip/documentTop/逐项reason与最后拒绝分支，不派整套、不改算法；本片未验证新增字段实际运行或M。普通HEAD/index及Build30保持，无新IPA，不关机。

---

# S诊断已接线，验证前：零CI、未编译（2026-10-22）

只改两处DEBUG采样诊断及Vendor两项摘要：冻结clip/frame、同次返回documentTop/JSON状态、每次await后的逐项上下文观察及实际终止分支。原guard/await/状态写入和JS脚本保留；sample-decision在原迭代退出时defer同步记录，无新增await/Task/采样。即将核Release投影、范围、语法及受影响工具；这些不等于编译或S复现。基线/证据build/maintenance/I6-viewport-s-diagnostics-20261022，禁止派CI。

---

# S rejected诊断切片进行中：零CI、只补证据（2026-10-22）

用户授权查清S rejected并补clipTop/documentTop及逐项拒绝原因，不派CI、不改定位算法。已核上一轮39782692503真实结束、无运行helper，当前617输入与fe23d245保存候选一致。新基线build/maintenance/I6-viewport-s-diagnostics-20261022/before.json。

范围仅InfiniteScroll采样诊断、Spread同次JS结果诊断和Vendor摘要；不改Adapter、XCTest、控制器、屏障资格、断言、30秒/3秒、3次/32ms、原JS脚本或生产guard/写入。全部新增内容限DEBUG；验证用去DEBUG后完整源码对照及受影响Python/仓库语法检查，不派CI。原失败附件/完整日志保持。

旧事件同一S有attempt0/1/2，按实际代码唯一continue路径可证明前两次通过上下文与有效snapshot后发生documentTop不匹配；最后一次原因、clipTop与移回1767写入者仍未知，不能追认旧full根因。下一步加被动诊断，原生编译/运行未执行，完成后同步报告及保存断点。普通HEAD/index及Build30保持，不关机。

---

# Adapter桥单轮原生验证已保存：编译通过，S前置失败，禁止自动重派（2026-10-22）

2026-10-22 Adapter桥修正版仅一轮CI39782692503/65a82618/attempt1：原生编译/链接通过，Linux111及控制器机制6项通过；原视口smoke 0/1（12.506秒），停在缩放前S资格。S实际命中/放行但终结rejected，M未执行；失败后active/tasks/waiters均空。1767/2367现场不足证明具体拒绝分支，clip/documentTop/guard诊断仍缺；旧full根因未证。本轮617运行输入零漂移、未改算法/原断言预算、未重派。原件与断点已保存，旧full191/192、Release/手机缺口和Build30保持。见[本片结果](Documentation/I6_VIEWPORT_ADAPTER_SMOKE.md)。

恢复先核build/maintenance/I6-viewport-smoke-adapter-20261022/final-checkpoint.json及唯一dispatch-attempt/frozen/result；CI已completed failure，不得因中断重新派发。上轮链接问题已获本轮真实编译通过依据；本轮用例失败不能写成全绿。failure-analysis含16项序列、真实S released/run后rejected、另一native committed/原capture cached、三次DOM scrollY1767/localTop2367；原JS documentTop还含未记clipTop，所以具体拒绝分支/回跳写入者不确定，不能归咎算法或环境。

下一片先只做缺失S资格证据的无CI审阅/方案（clipTop/clipBottom/view.frame、同次documentTop、逐项guard原因），不自动实施或重跑。定位算法、原断言/30秒/3秒及原3次/32ms保持，M和真实SDK持有中取消仍未验收。完整日志/两xcresult/summary/附件及SHA/CRC收件在build/ci/39782692503；原件不得覆盖。普通HEAD/index及Build30两交付哈希保持，无新IPA，不关机。

---

# smoke原生单例运行中：只派一次，禁止重派（2026-10-22）

冻结源65a82618fb1174c84be6c10729de92e828b79e25，CI39782692503，selection=continuous-resize-smoke，只跑原视口方法1例及其机制6项。定位源码、原断言/预算保持；不跑Core/组件/23项/UI/full/设备Release。当前尚无原生结果，恢复先核build/maintenance/I6-viewport-smoke-adapter-20261022的attempt/dispatch/frozen与真实job，禁止因中断再派。完整编译/测试原件须收齐再判，失败不自动重跑。旧full191/192与Build30保持，不关机。

---

# Adapter桥接修正版：新授权仅一轮smoke，冻结前（2026-10-22）

用户已明确授权再派一轮CI，覆盖上轮“需新授权”限制；不是重派旧run。只验证f675c39b候选的原生编译及原视口smoke单例：机制6项、真实S/M命中/放行回执及取消/关闭清理。617运行输入与候选零漂移；复用其已核本地静态结果，不叠加本地预检，不改定位算法、原断言/预算，不跑整套或设备Release。

本轮唯一尝试锁及冻结目录build/maintenance/I6-viewport-smoke-adapter-20261022；冻结后写dispatch-attempt再POST一次，恢复先核真实run，失败留原件、禁止自动再派。上轮39777683114链接失败原件完整保留；本轮尚未派发、原生结果未知。普通HEAD/index及Build30交付保持，不关机。

---

# smoke单轮失败已保存，Debug桥候选修正未原生验证（2026-10-22）

唯一CI39777683114 / 9f1c503a6be4bbc15ad333613adad73a38352380 / run_attempt1已结束；禁止重派。Linux111通过，原生步骤819秒，Swift对象编译已发生，但XianxiaReaderTests链接失败exit65，测试和机制执行0。五组缺符号都是SDK Event/Control（含TaskLocal/元数据），Tests.o通过Adapter typealias直接引用SDK类型；Tests工程只链接Adapter。不是定位断言失败，不能宣称编译或smoke验收通过。

原件已核：artifact12426406178，250175字节，SHA256 6e6fa624c7a61f77c40455e37839d85566aadbf09bb0149c1f986d3b01de5d7b，CRC通过，9文件/1776693字节位于build/ci/39777683114/diagnostic；日志/PositionBuild.xcresult存在，测试xcresult/summary不存在（未执行）。只移除校验后的重复ZIP。frozen/唯一dispatch-attempt/run-api/原始measured-result-before-correction及undefined-symbols保留，不能用修后候选冒充已测源。

已局部修正2文件Debug桥候选：Adapter自己拥有事件DTO/控制协议，私有bridge转换SDK事件；TaskLocal与fixture capture包装留在Adapter，Tests不再引用SDK事件/协议/TaskLocal。SDK/Vendor/工程/依赖不变，原算法/断言/预算保持；两文件Release完整投影逐字一致，默认nil无新增await，34个其他测试体/waitUntil保持。候选484语法/静态通过（新增0/原Vendor54），15定向工具中14通过/1 POSIX跳过；没有编译/机制/原生结果，不可写已修复链接或已命中。

当前源应以最终saved checkpoint为准；父为本轮已测9f1c503a，普通HEAD/index保持。证据及恢复build/maintenance/I6-viewport-smoke-20261022/final-checkpoint.json，权威报告Documentation/I6_VIEWPORT_SMOKE.md和ValidationLogs/project-isolation-i6-viewport-smoke.json。当前唯一CI预算已耗尽；下一步只在新授权后，对当前Adapter自有类型候选再做同一smoke原生验证，不改算法/不启动冲突复现/不扩大整组。旧full191/192、I6/Release/手机未验收、最后交付Build30保持，无新IPA、不关机。

---

# smoke原生单例运行中：只派一次，禁止重派（2026-10-22）

冻结源9f1c503a6be4bbc15ad333613adad73a38352380，CI39777683114，selection=continuous-resize-smoke，只跑原视口方法1例及其机制6项。定位源码、原断言/预算保持；不跑Core/组件/23项/UI/full/设备Release。当前尚无原生结果，恢复先核build/maintenance/I6-viewport-smoke-20261022的attempt/dispatch/frozen与真实job，禁止因中断再派。完整编译/测试原件须收齐再判，失败不自动重跑。旧full191/192与Build30保持，不关机。

---

# smoke单轮原生验证准备：最多一次CI，不自动重跑（2026-10-22）

用户授权仅一轮CI，编译并验证原视口单例的smoke夹具，确认机制6项、真实S/M命中/放行回执和取消/关闭清理。定位算法、原断言/预算不改，不跑Core/组件/23项/UI/full/设备Release。当前还未派发；基线2d490b6a及617运行输入零漂移，before与尝试锁目录build/maintenance/I6-viewport-smoke-20261022。

现有continuous-resize只跑普通单例，必须补专用continuous-resize-smoke选择、TEST_RUNNER_XIANXIA_VIEWPORT_FIXTURE=smoke环境传递、成功后的收件校验，避免普通单例冒充fixture通过。仅改workflow/诊断入口/既有位置证据校验器及相应Python工具测试；五个Swift夹具/算法源和Vendor摘要保持。Apple官方环境变量文档与WWDC22-110361核对TEST_RUNNER_剥前缀规则。本地15工具项14通过/1 POSIX跳过，484语法/静态通过；Swift/Vendor等613输入保持。下一步冻结输入/私有分支并写dispatch-attempt后只派一次；任何失败先保留完整原件再查，不重派。

恢复先核frozen/dispatch-attempt/dispatch与真实run；不可用旧“未派发”字样替代GitHub状态。旧full191/192及Release/手机缺口保持，无新IPA，最后交付Build30，不关机。

---

# 连续视口最小Debug夹具：源码接线完成，未原生验证、零CI（2026-10-22）

用户仅授权最小fixture及命中/放行/取消清理检查，不派CI、不改定位算法。已在设计规定6个源/摘要文件实现，默认关闭；原单例测试进程显式XIANXIA_VIEWPORT_FIXTURE=smoke才安装实例控制器，未知模式失败。现有App/Core/ReadingInterfaces/隔离模块/资源/依赖/项目/CI均未动，原断言/预算保留。实现与未来执行资格详见[设计第9节](Documentation/I6_VIEWPORT_REPRODUCTION_DESIGN.md)。

S在缓存未命中、首次DOM读取前；M组在真实结果之后/原guard之前。身份/TaskLocal来源/同次JS几何/实际finished均有记录，安全顺序先放S、再resize放M；未实现冲突顺序。六项控制器自检已编写，但未运行。复合清理在open前注册，替代本方法两个裸frame清理：先关闭失效，abort全部waiter后恢复frame，异步teardown以3秒检查残留及晚提交，不能仅依赖defer。

Windows实际检查：仓库7类静态及484文件语法通过，新增诊断0/保留Vendor54；相关Python13项中12通过/1 POSIX跳过。第一次因本地解析器不支持类内#if成员而失败，日志保留；改为文件级Debug扩展，无白名单/检查/架构例外变更。Release无安装入口，三个私有nil opaque槽/内部默认nil元数据参数不参与业务；5Swift的Release归一化文本对照保持，不能代替编译。源码风险仍为Swift6.1.2桥接/continuation/XCTest接线未编译，实际缓存/尺寸资格尚无运行原件。

本机无Swift编译器；docker info exit1，Linux引擎管道不存在，未启容器/重置工具。零CI、零Swift执行，原生屏障命中、放行和取消清理均未验收，旧根因未证。源基线f167a752；617输入中仅预定6项改变，其他611保持；普通HEAD/index保持。证据与恢复build/maintenance/I6-viewport-fixture-20261022，项目审计Documentation/ValidationLogs/project-isolation-i6-viewport-fixture.json。保存后下一步应先明确仅此smoke的原生验证范围，未有新授权不得派CI/冲突复现/改算法。旧full39735403242仍191/192，I6/Release/手机未验收，无新IPA，最后交付Build30，不关机。

---

# 连续视口可控复现设计：设计完成，未实施、零CI（2026-10-22）

用户本轮只授权设计与静态审阅；保留原断言/预算、现有隔离及定位修复，不实施屏障、不改定位算法、不派CI。已完成[可控复现设计](Documentation/I6_VIEWPORT_REPRODUCTION_DESIGN.md)：H1为“旧请求上下文跨尺寸后读新DOM，B覆盖A，measure因anchorEqual=false不恢复A”；它仍是假设，不能追认为旧full根因。

实际源码审阅纠正了三点：S须在缓存未命中且首次真实DOM读取前扣住，扣旧结果不足以检验H1；M须扣住目标新布局的并发测量组，避免其他测量先补偿；受控方法的裸frame teardown和defer须同时换成幂等复合清理，先关闭失效/abort再恢复窗口。逐请求身份、同一次JS元数据、显式release/finished回执、安全/冲突顺序、原30秒/3秒预算、原有3次DOM采样/32ms间隔及结果分类已写清。参考Swift官方、Apple XCTest及固定版本Async Algorithms Gate，仅取适用模式，不加依赖。

当前仅文档变更，尚无fixture、无Swift编译、无新增测试/CI执行；617运行输入对已测82b35f76/CI39759498210零漂移，普通HEAD/index保持。基线与审计目录build/maintenance/I6-viewport-repro-design-20261022，源快照父7048594fcf0bafa22c683d9265e3db1d654b2687。仓库文档/工程/工作流/schema/fixture/Vendor/架构7类静态检查全部通过（python scripts/check_repository.py，exit0）；这不是Swift语法、编译或测试。实际差异限9个文档/审计文件，617输入逐项SHA256零漂移。

本片边界到设计保存为止。下一片若用户授权，先实现本同例最小Debug fixture并核命中/取消/默认关闭路径，再另行确定原生匹配对照范围；不可凭本设计直接派CI或改算法。旧full39735403242仍191/192，旧根因未证；I6/Release/手机未验收，无新IPA，最后交付Build30，电脑保持运行。

---

# 连续视口同例对照：本片保存，下一轮只做无CI设计（2026-10-22）

用户最新决定“保存本片，下一轮先做无CI复现设计”。本轮结束，不追加CI、不实施屏障/定位修复、不改已测代码，不跑整套/设备Release。自己的观察/下载已完成，电脑保持开机。

冻结82b35f768442c6127baa9a540b28fae0f0edbc82 / CI39759498210 completed success。相对b618ca86/39754777198，唯一运行输入变化是before检查点的`await domProbe(originalFrame.width)`改NSNull；其余616输入及所有探针/原断言/30秒100ms/12视图/横竖顺序保持。原App/测试模拟器真实编译通过；原单例精确1/1（11.293秒），test/summary/export均0，9处/7种旧warning保持、无新增。CI Linux109通过，本地语法484无新增（非编译）。仅派1次，无额外预检/重跑。

原Locator char499，before native请求/实际outer2369；DOM明确null，不能宣称本轮查过缩放前Range或DOM滚动完成。横屏2次采样：首native874×306/DOM402×778、原字top=-219.125不可见；0.130935秒后DOM874×306、top=-3.125可见。恢复竖屏又2次采样top23.875可见。始终同WebView/挂窗/alpha1。measure两次guard=true、desiredLocal2151/2340，均实际应用。原合同只要求原字最终可见，本片不声称无瞬态跳动或逐像素相等。

结论仅为：该样本不依赖那个额外等待也通过。旧full39735403242失败未复现、根因未证，不称已修复或假失败；不能合并时源称192/192。没有产品算法/模块/依赖/配置改动，设备Release/手机仍未验，无新IPA，最后交付Build30。

权威Documentation/I6_VIEWPORT_RESIZE_CONTROL.md及ValidationLogs/project-isolation-i6-viewport-control.json；build/maintenance/I6-viewport-control-20261022含before保护1249旧路径、frozen/唯一dispatch、scope-audit/result/resize-evidence、用户决定及后续final-checkpoint。主步骤1337秒：首suite前1285.197秒，case11.293秒，其余40.510秒；上传/下载另计。build/ci/39759498210完整artifact12418352195/2239281B/SHAee96d417242b2651ae571d865280593a53426666db536e82ebb7b6b80ce514b1已digest/CRC/安全展开核验，保留完整日志、两xcresult、summary及全部附件；只清除已验证重复ZIP。旧原件及Build30交付不动。

下一轮先只做无CI设计和静态审阅，不能直接实现或派发：核对“位置采样跨越尺寸变化后是否被接收并替换保存锚点”的可控复现，明确屏障插点、显式放行/取消清理、原断言与结果判读。源码仅见尺寸变化不改变viewportRevision、采样await后无独立尺寸身份；尚未观察到它实际导致故障，不得直接当根因修算法。order-context记录旧前序模式切换但清理已注册，未证明共享污染。先读layout-sampling-hypothesis/order-context、完整本片证据及实际文件/Git，不重派已完成run。普通HEAD/index及617已测输入保持。

---

# 连续视口缩放单例运行中：禁止重复派发（2026-10-22）

冻结源82b35f768442c6127baa9a540b28fae0f0edbc82，CI39759498210，selection=continuous-resize，仅原失败方法1例。原断言及30秒/100ms预算不变；不跑Core/模块/23项/UI/full/设备Release，无新IPA。此刻仍在准备/编译，尚无本片结果。恢复先核build/maintenance/I6-viewport-control-20261022的frozen/dispatch与真实run，禁止重复派发。旧full191/192与全部原件仍保留，普通HEAD/index未改。

---

# 连续视口同例对照：本地检查通过，准备冻结（2026-10-22）

仅保存patch指定的一行变化：before DOM查询await改NSNull。已逐字审阅其余测试代码与b618ca86匹配，484语法0新增（非编译），生产/Vendor/原断言/预算/其余观察保持。现在冻结并只派发continuous-resize原方法1例；不跑23项/full/Core/独立模块/UI/设备Release。结果未形成，旧故障根因仍待证。

本片目录build/maintenance/I6-viewport-control-20261022含before、检查，随后写入frozen/唯一dispatch；中断先核实际run，禁止重复派发。设计与因果边界见Documentation/I6_VIEWPORT_RESIZE_CONTROL.md。

---

# 连续视口缩放同例对照开始（2026-10-22）

用户已恢复并明确授权：只撤去指定`await domProbe(originalFrame.width)`，不改其余探针/原断言/30秒100ms/12视图/横竖顺序，仅原continuous-resize单例，不跑整套。下一步核准保存patch后应用，完成本地语法/范围审阅再冻结派发一次。

已核上轮保存2dcd6909及实测b618ca86/CI39754777198完成success；617输入零漂移，普通HEAD/index不变，无遗留实验进程（查询自身gh已结束）。本轮before保护1249路径，build/maintenance/I6-viewport-control-20261022保存本片全部证据。旧full191/192、根因未证/Release未执行保持，不把对照准备称已验收。

唯一假设：上轮缩放前新增DOM观察挂起点可能改变复现。对照before DOM明确标null，保留初始scrollY查询及原Locator、之后联合条件/重排记录；若仍通过，只能说明本样本不依赖此等待，不能据此排除其他观察、共享顺序或旧故障。若失败先保存原件，按具体条件和measure决策判断，不盲改算法或重跑整套。

---

# 连续视口缩放：证据保存，本轮结束（2026-10-22）

用户最新决定“先保存本轮证据，下一轮做该对照”。不追加CI、不应用对照patch，不跑23项/full/设备Release，不进入新功能。原生轮次均完成，自己的观察/下载任务已结束，电脑保持开机。

本片先18e7bb94/CI39752863708探针编译失败（NSStringFromCGRect不可用），测试0次、654秒，原件留存；只修为String(describing:)后，b618ca861046499316bfb3ded1fdcd8826a4c66e / CI39754777198 success。实际原单例1/1、20.730秒；test/summary/export均0，原App/测试模拟器编译通过。修正轮主步骤1282秒，其中首suite前1213.758秒。总共2轮CI、实际原方法仅1次；没有盲重试或整套重跑。

原字499：缩放前outer请求/实际2369、DOM2367、Range top=-3.125；横屏874宽原字top=-3.125，返回402宽top=23.875，均可见、同一WebView/挂窗/alpha1。横屏27次采样中见原生frame已变、DOM仍402的过渡，后续宽度874并通过；measure保存499、guard=true、desiredLocal2151并应用。回竖屏内部首字为495、desiredLocal2340，原499字仍可见。原合同是可见性，不是像素相等。旧full缺缩放前原字和measure决策，此次通过不能证明旧失败已修复；观察await影响未排除。定位算法/原断言/30秒100ms/12视图/横竖顺序及既有隔离保留。

权威Documentation/I6_VIEWPORT_RESIZE.md及ValidationLogs/project-isolation-i6-viewport.json。build/maintenance/I6-viewport-20261022：before保护1247旧路径；attempt-1存首次冻结/派发/结果；compiled-probe存修正冻结/派发/结果及resize-evidence；user-decision.json确认本轮收口；后续final-checkpoint为最终快照。build/ci/39752863708和39754777198完整日志/xcresult/summary/附件及digest/CRC回执均保留；成功artifact12415489203/SHA1c15f4ed3e3fba8a62b089d2c3baaa5a329ecde0695dc7a71ccce86c209f18b9，2张截图有正文，非手机验收。新探针另有Optional Any转换warning，保留已测源码（9处/7种、新增1种），未静默清理/压制。

下一轮只应用已保存未执行的next-control.patch：撤去`await domProbe(originalFrame.width)`这一个缩放前DOM观察挂起点，before字段标未查询；initialDOMY查询等其他探针保持。它只区分这一处观察的时序影响，并非恢复原方法全部await。保留原Locator、联合条件/重排记录及预算，预计20–30分钟冷准备，仅同例；先核现场/源码哈希和已完成run，禁止重派本轮。旧full39735403242仍191/192，Release/手机未执行，无新IPA，最后交付Build30。

---

# 连续视口缩放单例运行中：禁止重复派发（2026-10-22）

冻结源b618ca861046499316bfb3ded1fdcd8826a4c66e，CI39754777198，selection=continuous-resize，仅原失败方法1例。原断言及30秒/100ms预算不变；不跑Core/模块/23项/UI/full/设备Release，无新IPA。此刻仍在准备/编译，尚无本片结果。恢复先核build/maintenance/I6-viewport-20261022/compiled-probe的frozen/dispatch与真实run，禁止重复派发。旧full191/192与全部原件仍保留，普通HEAD/index未改。

---

# 连续视口缩放：首轮编译错误已留证，仅修探针一行（2026-10-22）

CI39752863708 / 18e7bb94在测试编译阶段失败，原生用例0次；新增诊断NSStringFromCGRect在当前Swift不可用，非阅读功能失败。完整workflow日志、PositionBuild.xcresult、原编译诊断artifact12415715147已digest/CRC核对保存；初轮冻结/派发/结果保存在build/maintenance/I6-viewport-20261022/attempt-1。实际原生主步骤耗时见其result，不冒称是测试执行。

仅改该诊断的frame格式化为String(describing:)，不碰断言/预算/产品算法。下一步本地检查后冻结新源，再仅派发同一continuous-resize单例；不重跑full/23项/组件/Core/Release。用户已授权此例诊断和必要修复，原交接“只一次full”保持；第二轮只因具体编译修正，不是盲重放。若中断先核attempt-1与后续compiled-probe的frozen/dispatch，不能重复派发。

---

# 连续视口缩放单例运行中：禁止重复派发（2026-10-22）

冻结源18e7bb94d5e07c38d4c4569a0c29eef0547c338a，CI39752863708，selection=continuous-resize，仅原失败方法1例。原断言及30秒/100ms预算不变；不跑Core/模块/23项/UI/full/设备Release，无新IPA。此刻仍在准备/编译，尚无本片结果。恢复先核build/maintenance/I6-viewport-20261022的frozen/dispatch与真实run，禁止重复派发。旧full191/192与全部原件仍保留，普通HEAD/index未改。

---

# 连续视口缩放：探针完成，准备冻结单例（2026-10-22）

本地语法484无新增诊断（非编译）；受影响工具20项19通过/1 POSIX跳过，首次缺PYTHONPATH导入错误及更正原件均保存。已审阅Debug有界重排记录不增加await、不改恢复guard/应用顺序；只修改失败方法的观察，原30秒/100ms/联合条件/12视图/横竖顺序不变。

准备冻结并仅派发continuous-resize：原方法1例，不跑Core/组件/23项/UI/full/Release。此刻尚无编译或单例结果，未宣布根因/修复。实际范围与假设见Documentation/I6_VIEWPORT_RESIZE.md，基线及日志见build/maintenance/I6-viewport-20261022。若中断须先核frozen/dispatch及真实run，禁止重复派发。

---

# 连续视口缩放单例诊断开始（2026-10-22）

用户已恢复并授权：先补缩放前后锚点和重排证据，仅运行 ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView；保留原断言、30秒/100ms预算及全部既有隔离定位修复，不跑23项/整套/Release。

现场基线：上一轮完整断点3ca60eff，617冻结输入零漂移，普通HEAD/index匹配，未见遗留诊断进程。build/maintenance/I6-viewport-20261022/before.json保护全部1247路径原始哈希。旧full191/192及Release未执行仍为历史事实，不提前写为通过。

本片先仅补失败方法中的准备坐标、完整Locator、原字Range、WebView身份及每个缩放谓词；必要时添加受诊断开关约束的有界measure记录。不改变滚动/恢复算法、原await顺序与断言，不修未证实假设。新增精确单例入口需静态检查、冻结后仅派发一次诊断；如发现实际缺陷，再据原件选择最小修复与必要同例验证。下一步：审阅现有诊断接口与适用参考，完成探针后更新此处再构建。

---

# I6最终断点：一次full191/192，原件收齐，禁止重派（2026-10-22）

2026-10-22 I6最终full已完成一次，源77eebf40/CI39735403242/Build31：192全部执行，191通过、1失败、0跳过（集成162/163、UI29/29）。六模块68、两平台Core各137/TXT Release各4、Linux109工具通过；模拟器编译通过。唯一失败为连续视口变宽后的原字/WebView联合等待，缺缩放前原锚点及子条件诊断，未证明根因或修复。test65、summary/export/recording0；Release被阻止、未执行，无新IPA，最后交付仍Build30。无额外原生预检/重跑，完整原件已核；用户已决定本轮保存完整断点，下一轮只查此单例；本轮不追加诊断或CI。I6未通过，不进入新功能。

冻结源77eebf40ff70318c7bced90b28269aa5198084f0，GitHub实际run_attempt=1。只升工程构建号30→31；617输入现场匹配。生产/原生测试/资源/锁/预算与全部既有隔离定位修复保留。主步骤5947秒：首suite前1653.361秒含工具/组件/Core/解析/编译/启动，集成case846.937秒、UI3194.564秒，其余252.138秒含导出收束，无Release成本。

唯一失败ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView在首次402×874→874×402、原81行30秒等待失败；原方法与交付Build30逐字同，直接Engine/InfiniteScroll源码也相同，但其他Readium/测试文件及顺序有变化。终态one.xhtml可读alpha1/ready、当前char777/localY2367；原char/Range、身份比较与measure决策没有记录，不能宣布原字丢失、测试假失败或归咎环境。+600后>500的准备条件存在漏洞，只是待区分假设，非已证根因。原2条issue仅1失败case；全部192各执行一次。

完整artifact12411464644/1196915933B/SHA edbe1c6972311ab31124e20a525a5c612e4805ef2c0d3870c8642353651ac8a8，Core12406981251/116294B/SHA c94ea0a806317f85b392d8f68e4e3b66c3e8d292e2b522c503c258a715df3376，digest/CRC/完整展开均核，重复ZIP/分片按精确回执清除。build/ci/39735403242保留全部xcresult、内部完整tee日志、summary、文本/像素/录屏和六包/Core回执。workflow日志末缺退出marker，内部build.log实际test65/summary0/export0/recording0，不以外部缺尾倒写失败点。模拟器源码编译0错误，8处warning/6种消息与39729365995同，新增消息0。

收口权威Documentation/I6_FINAL_ACCEPTANCE.md与ValidationLogs/project-isolation-i6-final.json；build/maintenance/I6-final-20261022含before/frozen/唯一dispatch/result/原失败切片、保护Build30哈希及后续final-checkpoint。只读watcher/下载已结束，无运行中的CI。用户已明确选择“先保存完整断点，下一轮只查此例”。本轮到此收口，不追加探针、原生诊断、CI或Release。下一轮恢复时仅查原连续视口缩放单例：先补有界准备/原字/各子条件和measure探针，再冻结新输入，保留原预算与断言；不自动重跑192，不能承诺单例即发布验收。

当前仅完成取证/文档，未改生产或失败测试，未宣布根因修复、完整视觉/手机验收。普通HEAD/index及旧WIP保留，电脑保持开机。恢复先核final-checkpoint/实际文件/Git/进程与run；切勿重复派已完成CI。

---

# I6失败取证中：主步骤failure，正在上传诊断，禁止重跑（2026-10-22）
+
+唯一CI39735403242，full/77eebf40ff70318c7bced90b28269aa5198084f0/Build31。主步骤06:42:58→08:22:05 UTC，5947秒后failure；workflow尚在上传诊断。当前不知具体测试/导出/构建失败点，不能写192通过或归咎源码/环境。下一步只收该轮完整原件、真实退出与摘要后查清，不自动整套重试，不改断言/预算/生产。
+
+build/maintenance/I6-final-20261022/main-step-failure.json已保留真实step元数据；只读watch_i6_final.py仍在跟踪，结束会收full.log/artifacts.json，之后用download_i6_final.py与collect_i6_final.py收口。无新IPA交付，最后仍Build30，617输入冻结、普通HEAD/index保持，电脑保持开机。
+
+---
+
+# I6只读观察断点：主任务仍在运行，不追旧实时片段（2026-10-22）
+
+同一CI39735403242/full/77eebf40/Build31，派发仍1次。已取到完成job的真实API原日志：109工具通过、Linux137唯一调度+真实成功退出；Core artifact12406981251完整下载/CRC/摘要已核，Release TXT4通过。本轮这些是新执行结果。
+
+实时浏览器曾见初始化关闭单例双模式通过；后因日志页崩溃，临时tab6关闭也被崩溃data URL策略阻挡，未更改权限，不再操作该页。API可读运行中日志但连续返回07:12旧片段/86项通过，已停止重复追读；不可把局部/旧尾部当最终计数或卡住证据。独立只读watch_i6_final.py仍每45秒取真实状态，结束后收完整full.log/manifest。
+
+最终192/Apple设备Release/IPA仍未验收；frozen/dispatch/native-started/observation-checkpoint在build/maintenance/I6-final-20261022。现成collect_i6_final.py/download_i6_final.py/verify_i6_final_ipa.py/review_i6_final_images.py仅在.cache/recovery，未纳入构建输入。仅允许收结果，不重新派发；失败先保存原件查清。普通HEAD/index和617输入保持，电脑保持开机。
+
+---
+
+# I6运行断点：原生用例已开始，结果仍待收齐（2026-10-22）
+
+CI39735403242仅派1次full，源77eebf40ff70318c7bced90b28269aa5198084f0，Build31。真实浏览器已见XCTest DocumentImportTests原生导入用例通过；不据局部实时日志宣布192通过。仓库/Core job元数据success；CLI在workflow结束前暂不提供完整job日志，读日志的exit1原件已留，不是测试失败。原生/full/设备Release最终结果均待完整日志、xcresult和产物。617运行输入及普通HEAD/index现场再核不变。
+
+只读观察器.cache/recovery/watch_i6_final.py 39735403242仍在运行，结束后保存build/ci/39735403242/run.json、full.log、artifacts.json。冻结/唯一派发回执在build/maintenance/I6-final-20261022。恢复核实际进程和CI，不重派/不加预检；失败先留证，不自动整套重试。电脑保持开机。
+
+---
+
+# I6最终验收运行中：一次full已派发，禁止重复（2026-10-22）

冻结源77eebf40ff70318c7bced90b28269aa5198084f0，ref refs/heads/codex/i6-final-acceptance，CI39735403242，selection=full，Build31。仅派发1次，192=163集成+29UI及同源设备Release；不叠加原生预检。运行结果尚未形成，不代表通过。617冻结输入、1245旧路径、普通HEAD/index及既有改动保持；运行源只工程构建号变化，生产/测试/依赖/预算不变。恢复读取build/maintenance/I6-final-20261022/frozen.json、dispatch.json与真实CI，不自动整套重试。失败保存完整原件后查清；电脑保持开机。

---

# I6最终验收冻结前：仅版本号变化，准备派发一次full（2026-10-22）

1245旧路径保留，运行输入只project.yml构建号30→31；生产/原生测试/资源/锁/CI门禁/预算保持。Windows仓库/484语法新增0、既有Vendor54（非编译），仅42项边界与full门禁工具检查通过，无额外原生预检。现在冻结617运行输入，仅派发一次full覆盖163+29=192与同源设备Release。用户明确不自动整套重试；恢复先核本地frozen/dispatch和实际CI，不重复派发。build/maintenance/I6-final-20261022保存全部原始输入及回执。当前尚无新编译/原生/Release/IPA结果。普通HEAD/index保持，电脑保持开机。

---

# I6最终验收开始：用户已授权一次full，冻结Build31（2026-10-22）

本轮授权一次diagnostic_selection=full：原生163集成+29UI=192，全部零失败/跳过后，同源严格CODE_SIGNING_ALLOWED=NO设备Release及IPA核验。不前置23项、字体或旋转预检；既有六模块/Core/TXT门禁保留，不另起组件CI。失败先保存原件，不自动整套重试，拿不准时询问。

基线4ab15d7e保存点，617运行输入现场匹配；普通HEAD/index及全部既有WIP保留。生产、测试、门禁、预算、依赖锁及资源不改，只在冻结前将project.yml构建号30升31，MARKETING_VERSION仍0.0.1。开始快照和后续冻结/派发/原件在build/maintenance/I6-final-20261022。当前尚未派发、未编译/测试/导出，无新IPA。恢复先核frozen/dispatch/实际CI，禁止重复派发。电脑保持开机。

---

# I6d断点：最终验收范围审计完成，未派CI（2026-10-22）

用户要求先核缺口/复用/必要范围，本轮只审计和写项目记录，生产/测试/CI/门禁/版本均不改，无新编译或Swift测试、无新IPA。基线b4e2edc保存点，当前617运行输入与598aedd真实编译/单例源完全一致；最新CI39729365995已远端重新核实completed/success，无本轮后台任务。普通HEAD/index保持。

六独立模块原件及传递输入重核：Settings7、Positions24、Sessions15、Shelf6、Imports8、Search8可分项引用。位置69项只有校验器文件变化，logic imports/常量/函数AST保持，旧xUnit用当前验证器重核；不要写成69文件全同或新执行68项。各包Apple Swift6.1.2/Xcode16F6/Intel/macOS15.7.9对应最新环境。Core Linux/mac各137和TXT Release各4保留历史输入/原件；Core parallel137按job筛选调度项+原真实成功退出核对，尾部Swift Testing0不是这组测试。SQLite环境本轮未重新执行核定，最终Core门禁不绕过。

当前静态库存163集成+29UI=192、156第一方Swift/25区域/26图节点/2精确例外。旧23项22/23与新关闭1/1分项引用，不能相加成同源23/23；生产/工程/资源不变且只有关闭一个方法变化，其余191方法/助手保持，后续full会覆盖23，不再另起23预检。最新109工具与编译属598源原CI，本轮未重跑这些工具或Apple构建。

UI实际配置仍39196134450/8f5b427的28项ARM，当前29项Intel且54受保护输入变化；最后交付Build30的29项也有51项变化，不可复用，不走unit-release。当前工程仍Build30；若交付新包须先定构建号再冻结，不能验证后改工程沿用旧结果。

下一轮推荐现有diagnostic_selection=full一次：原生163+29全部且零失败/跳过，完整日志/xcresult/真实退出/像素录屏核验，同源严格CODE_SIGNING_ALLOWED=NO设备Release和包核验；不前置position-acceptance/fonts-full/rotation-full，不失败后自动整套重试。现有full附带六模块/mac Core/TXT4、并行Linux Core/TXT4快检保留，不单开组件CI；本轮不造新复用/跳过框架。当前只确定范围，未派下一轮。

最近交付源旧180完整主步骤6647秒：实际集成804.415、UI3899.124，其余1943.461含准备/编译/启动/导出/设备Release/打包；额外旋转预检另1477秒。六模块各轮冷构建历史合计415.36秒，仅为量级，不能相加预测当前缓存。当前192非旧180，final是两小时级任务；150分钟是workflow上限、非ETA，不能用单例17秒估计。真正避免的是重复原生预检/多次冷准备。

仍缺当前同源192、设备Release/包、普通/TrollStore手机与流畅度反馈。Reader宿主AppServices、App批次/呈现、同target UI类型访问及字体iOS依赖保留为明确边界债务，不宣称全项目彻底类型隔离；不混入重构或Swift6 warning修复。I6整体未验收。

权威Documentation/I6_FINAL_ACCEPTANCE_SCOPE.md与ValidationLogs/project-isolation-i6-final-scope.json；原件hash/源比较/范围在build/maintenance/I6-final-audit-20261022。边界/UI复用工具正反例42/42通过、零失败跳过，未重跑109全组；最终静态守卫及484语法新增0/既有54通过（非编译）。仅保存私有恢复点，具体revision见本地final-checkpoint.json，恢复先查final-checkpoint.json/实际文件/Git/进程，不派CI。电脑保持开机。

---

# I6c断点：初始化关闭单例已收口，生产不改（2026-10-22）

用户授权仅查这一例。冻结运行源598aedd02ab6f6d95876ccac5f17658b8cc11905，codex/initialization-close-probe；CI39729365995已completed/success。只派一次initialization-close，原单例1/1，分页/连续均在真实字体已ready、生产字体状态pending、屏障未释放时关闭；原三个delegate/移除断言全部通过。test/summary/export=0，原生编译通过，未跑23项/完整192/Core/独立包/Release/手机，无新IPA，最后交付仍Build30。

根因机制已有直接原生记录：分页installed=true且封面路径正确，WeakRef初始包装对象已不可取（alive=false/same=false），原实例hook0次、当前own ready=false，prototype后备hook1次。原测试只绑临时FontFaceSet JS包装对象，包装对象回收后实例覆盖失效，无法置started标记。连续本次保留原包装对象、实例hook1次；不能称两模式本次都回收，也不能追认前轮精确GC事件或底层原生对象销毁。前轮39721680702原22/23失败/test65保持历史，不相加成同源23/23。

修正只限原ReaderRenderingTests一个方法：实例/WeakRef诊断、prototype后备、真实native ready与显式Promise屏障，替换2秒自动释放；原30秒/生产15秒预算不变。仅查询挂窗当前视口封面，准备要求installed/start/nativeReady、pending且未释放/未完成。原关闭断言逐字保持；旧视图有记录清理和原teardown保持。生产/App/Packages/Vendor/工程/资源/锁、其他原生方法与原有隔离/定位修复不改；617运行输入仅5处差异。旧logic/native/acceptance函数AST和原shell主体命令保持。

本地9工具8通过/1POSIX跳过，真实JS3夹具通过；Linux109工具通过。Swift语法484新增0/既有54（非编译）；真实Apple编译0源码错误，8条唯一源码warning与前轮逐条同消息，仅后方行号变。6原生附件/日志/summary/回执已核。原生步骤901秒，首Selected suite前817.675秒含准备/编译/启动，实际单例17.101秒。

artifact12405307611/427326B，SHA363949aa0042eb3c224a68ab118dcf0bdf043e42de9524842df9abb72d89a233与GitHub digest一致、CRC通过；完整原件在build/ci/39729365995，重复ZIP校验后清除，原39721680702仍用于对照而保留。当前watcher/下载均已完成；本地build/maintenance/I6-close-20261022保存before/frozen/dispatch/result/范围与原件hash。权威Documentation/I6_INITIALIZATION_CLOSE.md及ValidationLogs/project-isolation-i6-close.json。

本片不再加跑；下一片回到I6最终验收范围核对，完整192/Release/手机仍未验收，不自动开展新功能。接下来只做文档/最终静态核对与私有恢复点保存，普通HEAD/index不得改。若恢复先查实际文件/Git/CI/进程和final-checkpoint.json，不重复派发。电脑保持开机。

---

# I6b断点：23项已跑完22通过/1失败，原件收齐（2026-10-22）

冻结运行源075c2ccfbc597eba2afa57c6622f44ecba1cf6ce，私有分支codex/position-loading-acceptance，CI39721680702已completed/failure。只派1轮，精确23项全部执行、22通过/1失败/0跳过，原生编译通过；test=65，summary/export=0。Core/独立包/全套192/设备Release/手机未执行，无新IPA，最后交付仍Build30。

唯一失败ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews在原298行等待__xrCloseProbeStarted，发生于第一轮continuous=false分页；两个spread已初始化完成但探针未见。case本体engine.close与断开/移除断言均未运行、连续分支未进；随后teardown清理。共用错误中的Continuous不是模式证据，2条issue只有1个失败case。不能称关闭缺陷已复现或归咎环境/新隔离。仅下一单例可加安装/错误/getter次数/每个WebView身份诊断，保持生产与原预算；用户已选择“先保存本轮证据，下一轮单查这一例”。本轮到此收口，不加探针、不再派发；下一轮仅诊断此case，保持原生产、断言和预算，不重跑23项或整套。

正文返回、六字体双模式/隐藏重排、分页同宽resize、原生加载和TXT定位均通过。已核12字体图联系表、分页返回和连续重复seek更新后窗口/WK原图；六个连续字体截图后saved.visible=true/delta0/anchorCondition=true。原即时UIKit空白原件仍留，不能称手机瞬态已验收；不因该观察扩生产修复。Windows107工具100通过7POSIX跳过/Linux107通过；语法484新增0/既有Vendor54，语法不等于编译。

成本：原生步骤1821秒，首Selected suite前1335.783秒含准备/编译/启动，case合计314.763秒；不能把30分钟都算测试或纯编译。artifact12401799234/102227599B，GitHub digest与SHA 9a56a41979b0ee22fb7ef702ec990069288aabe6eba3ea0e102bb97ba6f84626一致、CRC通过；完整展开/日志/xcresult/summary/manifest在build/ci/39721680702，重复ZIP校验后已删。

本轮运行输入仅workflow、ci_reader_diagnostic.sh、verify_reader_positions.py及对应tooling测试4处变化；原生产/App/Packages/Vendor/原生测试/资源/工程/锁原样。独立位置verify_logic AST保持且旧24 xUnit用当前验证器核过，未重新执行Swift包；旧CI39585860717仍失败18/19。本地before/frozen/scope-audit/result/失败切片在build/maintenance/I6-position-20261022；权威记录Documentation/I6_POSITION_ACCEPTANCE.md及ValidationLogs/project-isolation-i6-position.json。只读watcher与下载进程均已完成。恢复核对最新答复、Git/输入、进程及已有原件，不重复派发。普通HEAD/index保持，电脑保持开机。

---

# 当前断点：I6a审计与门禁修补完成，23项原生尚未派发（2026-10-22）

2026-10-22 I6a边界/证据审计及两处发布门禁修补完成：原始合同与传递输入核实后，6个独立模块只可分项引用，不能相加成同源验收。补齐完整artifact的设置/导入/搜索证据目录，并在Release前增加full192全部通过、零失败/跳过摘要门禁。105项本地工具98通过/7 POSIX跳过，语法484无新增诊断（非编译）；首旧夹具失败及修正保留。仅5个CI/tooling输入变化，其余612及全部生产Swift/原生测试/工程/资源/锁保持。Reader宿主AppServices、UI/批次桥接和字体iOS依赖仍是边界限制；下一片只做原19位置+4加载=23项，不复用旧28项UI配置。当前零CI派发、未跑原生/完整192/Release/手机、无新App IPA，I6整体未验收。详见[审计与精确门槛](Documentation/I6_ACCEPTANCE_AUDIT.md)及ValidationLogs/project-isolation-i6-audit.json。

本轮门禁在Windows以真实Bash/Python和受控外部工具夹具验证，不能说已跑Xcode或新CI。精确23项清单、本轮105日志、旧夹具失败/修正及基线见build/maintenance/I6-audit-20261022。恢复先核该目录final-checkpoint.json、617运行输入、普通HEAD/index及实际进程。后续只补23项入口并冻结输入，失败先留证；不自动扩大到全套、Release、AppServices重构、警告清理或新功能。电脑保持开机。

以下为本片过程和历史，顶部事实优先。

# I6a范围修正：补两处已证的验收门禁缺口（2026-10-22）

审计发现完整ios artifact未收ReaderLogic/BookImports/ReaderSearch，且ci_ios.sh仅unit-release校验163、full没有明确192且零跳过的summary门禁。现将本片从纯审计收窄为“审计+这两处验收入口修补”：只改完整CI产物清单、full summary检查与正反例，不改生产/原生测试/断言/预算，不派发任何CI。原before快照仍有效；最终报告必须修正“617全部输入不变”的临时表述，分别报告Swift输入保留与CI/tooling改动。本轮新工具检查需要重新执行，不能复用旧102当本轮结果。

---

# 当前断点：I6a审计完成，下一片仅23项位置/加载门槛（2026-10-22）

2026-10-22 I6a审计完成，尚未执行I6原生/完整验收：617运行输入与I5c被测源一致，6个独立模块的原始合同、传递输入和日志可分项复核，不能相加成同源全绿。Reader宿主AppServices、批次/UI编排、同target类型隔离及字体iOS依赖保留明确边界债务。下一片限定原位置19+加载回归4=23项，先收口R3；旧Build30受保护输入51处不同，不能复用旧UI29。完整163+29=192、设备Release及手机仍待后续，本轮零CI派发、生产/测试/工程/资源/锁不改、无新IPA。见[审计与精确门槛](Documentation/I6_ACCEPTANCE_AUDIT.md)及ValidationLogs/project-isolation-i6-audit.json。

本轮只做审计和文档，未修改生产/测试/工作流。恢复先核build/maintenance/I6-audit-20261022/final-checkpoint.json、617输入、普通HEAD/index和实际进程；不要重跑已核组件或把旧18/19、5/6改写为已过。下一片原断言/预算不变，不自动扩大到AppServices重构、警告修复、全套、Release或新产品。电脑保持开机。

以下为历史过程，顶部事实优先。

# 当前断点：I6a 剩余边界与验收范围审计开始（2026-10-22）

用户本轮要求先核对剩余边界和必要验收范围，不直接运行全套。以I5c保存点`88e3d87089677fc97a79816fef755360234b289d`为基线，617运行输入现场一致，普通HEAD/index不变，无遗留测试进程。快照见`build/maintenance/I6-audit-20261022/before.json`。

本片只审计实际源码依赖/保留桥接、已有真实日志及输入匹配、未收口的定位合同和后续最小用例清单；不提取更多生产模块，不改测试/断言/预算，不派发CI、全套、Release或IPA。结论须区分可分项复用、仅历史参考、当前仍缺证，不能把多轮结果相加成同源通过。

---

# 当前断点：I5c搜索本片完成，I6尚未启动（2026-10-22）

完整原生日志有10次/8条唯一源码警告，与I5b CI39712813755逐条完全相同（新增/消失均0）：LibraryAssembly外部符合、BookDuplicateTests的ImportOutcome Sendable、ReaderRenderingTests的UIKit delegate Sendable/preconcurrency；独立搜索包及本片搜索源码警告0。保留真实日志，不静音或扩入本片；现Swift5目标可编译，未来Swift6迁移须另审阅。

2026-10-22 I5c搜索本片完成：ReaderSearch真实独立包拥有原搜索DTO/可选协议与请求/分页/取消/选择编排，只依赖Core及Foundation/Combine。App与ReadingInterfaces保留typealias兼容，无新异步层，原12await、函数正文、发布与清理顺序不变。最终53f7e1f2 / CI39715718761独立macOS8/8、原生13/13，包及App/测试接线真实编译通过。搜索界面/输入、Readium3.11安全搜索服务/限制、ReaderPositions及书库/导入/字体/会话/Core/Adapter/Vendor/资源/锁不改；原生测试正文不改。完整163+29=192、Core137全组、Release/设备/手机未跑，无新IPA，最后交付Build30。详见Documentation/SEARCH_ISOLATION.md与ValidationLogs/project-isolation-i5-search.json。

Windows484语法新增0（54既有Vendor限制，非编译）、102工具95通过7 POSIX跳过；最终Linux102/102。首静态projectPackages漏登已被拦截并修正，原repository.log保留，修正后repository-corrected.log通过；未改生产行为来绕过门禁。静态156第一方源/25区/26节点/2精确例外。独立包依赖Combine，仅macOS合同，不声称Linux包通过。新搜索源码编译警告0，实际test/summary/export均0；既有LibraryAssembly外部符合警告按原记录保留。

本轮仅1次派发/1次原生执行：独立包步骤68.0秒（Swift构建51.05秒）；原生步骤965.0秒，其中首原生suite前928.468秒，13用例实际合计4.402秒。独立合同与冷工具/依赖/工程生成/原生编译/模拟器准备成本分开，不以全套重跑补绿。

原件build/ci/39715718761/diagnostic，artifact12399144481/446473字节/SHA8f8530ac60963fa0b4b8f8cc329be301e41256f275d568d0510feadf844c9efa，GitHub digest/CRC/安全完整解压已核，仅清除精确重复ZIP。build/maintenance/I5-search-20261022含before/frozen/scope-audit/result/final-checkpoint，617运行输入与被测源一致；普通HEAD/index及旧WIP保留。恢复先核现场/ref/实际进程，勿重派已完成CI。电脑保持开机。

下一片应先按总方案核对剩余边界与I6所需门槛，不能把本片13例当完整验收；原产品计划保留ROADMAP/READING_FEATURE_IDEAS。以下是历史过程，顶部最终事实优先。

# 运行中：I5c 独立搜索8/8已过，原生13例待完成（2026-10-22）

- 冻结源码`53f7e1f268d58f37219dcbbba1d47204c57db124`，ref `codex/isolate-reader-search`；CI39715718761仅派发一次，当前reader-positions原生定向步骤运行中。独立ReaderSearch包真实Swift6.1.2编译与8合同已通过（浏览器实时日志，最终以完整下载日志/xUnit/receipt复核）。App/测试编译和13原生仍未验收；不把本条当最终成功。
- `build/maintenance/I5-search-20261022`保存before/frozen/scope-audit/dispatch。617冻结运行输入；保留1228旧路径基线（13个明确改动、1215原样）。原VM12await/正文、搜索声明及全部原iOS测试已精确核对；普通HEAD/index保持。
- 自己启动的只读观察器`.cache/recovery/watch_i5_search.py 39715718761`在运行（会在结束后取完整日志/manifest，不重派CI）。恢复先核实际状态/进程/完整日志，禁止从网页旧尾部推断挂起。完整192/Core137/Release/设备未跑，无新IPA，不关机。

---

# 当前断点：I5c 搜索边界隔离开始（2026-10-22）

- 用户授权只做搜索边界；保留 I5a/b、R1–R4 和修好的阅读定位，不运行完整192、Release或IPA。
- 已核实上一片保存点 `32de76158ad18f0ccd0968bd97d0a35317a375b1`，610个运行输入一致；普通HEAD/index不变，无遗留Python/Swift/gh测试进程。开始快照：`build/maintenance/I5-search-20261022/before.json`（原交接另存同目录）。
- 本片拟将搜索DTO/协议与原ReaderSearchViewModel原样迁至独立ReaderSearch SwiftPM模块，仅依赖Core及Foundation/Combine。App和ReadingInterfaces保留typealias兼容入口；不新增异步封装，不改搜索字段、界面、Readium服务/限制或阅读导航。
- Windows语法已通过484文件（非编译）；初次漏登projectPackages被静态门禁拦截，已补精确登记并保留原始失败日志。原VM逐字符机械对照确认12个await和所有函数正文不变，搜索声明原样，所有Tests/iOS正文不变。Python102项检查通过（95通过/7 POSIX跳过）；shell三脚本语法通过。即将冻结并仅派发8+13定向验证，未运行编译/原生；原生失败先留证不扩片。
- 实现已落盘，尚未编译：ReaderSearch真实target及Core依赖、App/ReadingInterfaces兼容别名、依赖登记与正反例、8独立合同和13原生选择入口已接线。即将运行Windows语法/工具检查，冻结前逐一核对原VM正文和全部原生测试。
- 定向门槛：独立搜索合同、原搜索VM/Readium/原生输入及搜索返回点合同；Windows静态/工具检查后冻结输入，一次定向原生执行。实现、编译、验证均尚未完成。
- 若出现其他边界失败，先留证并核实归属，不为全绿扩大范围。电脑保持开机。

---

# 当前断点：I5b导入事务本片完成，搜索留后续（2026-10-22）

2026-10-22 I5b导入事务本片完成：BookImports为真实Foundation/Core独立包，拥有原EPUB/TXT导入服务与元数据合同；App/ReadingInterfaces以typealias保留旧调用名称/协议身份，无async包装、原11await与服务body保持。最终c8b53e38 / CI39712813755独立macOS8/8、原生14/14，包及App/测试接线编译通过。App批次UI/Task/picker/FontInbox、书库、搜索及阅读/字体/定位/会话/Core/Adapter/Vendor/资源/锁保持；批次呈现仍在App，不能称全部导入编排或全项目已隔离。完整163+29=192/Core137全组/Release/设备/手机未跑，无新IPA，最后交付Build30。搜索后续。详见Documentation/IMPORT_ISOLATION.md及ValidationLogs/project-isolation-i5-import.json。

Windows480语法新增0（54既有Vendor限制，非编译）、96工具89通过7 POSIX跳过；首工具用例名生成错误原日志保留，修正后全96复核。最终Linux96/96；包合同仅macOS，不声称Linux包可编译。静态153第一方源/23区/24节点/2精确例外。原所有iOS测试正文与预算不变；原生只选DocumentImport7、BookDuplicate4、真实EPUB metadata/import/rollback3。真实test/summary/export=0，早期build-for-testing在模拟器启动前通过。新导入源码编译警告数量0；上片LibraryAssembly外部符合警告仍按原记录保留，不静音。

本轮仅1次派发、1次原生执行：独立包步骤65.0秒（Swift构建48.08秒），原生步骤775.0秒，其中首原生suite前713.681秒；14个用例实际合计18.4秒。准备/工程生成/依赖解析/编译/模拟器成本与用例执行分开；不补旧负对照或全套凑绿。

原件build/ci/39712813755/diagnostic，artifact12397619362/1673922字节/SHAb5bb4ab86d11dc20f8e2a03577d57e4b2c5ef460db51f0e96be3e7efa5ff5d32，digest/CRC/完整解压已核，仅精确清除重复ZIP。权威Documentation/ValidationLogs/project-isolation-i5-import.json；build/maintenance/I5-import-20261022含before/frozen/scope-audit/result与final-checkpoint，610运行输入冻结。普通HEAD/index与1219原路径基线保留，实际例外以检查点精确清单为准；不reset/clean旧WIP，恢复先核现场/ref/进程，不重派本片CI。电脑保持开机。

本片停止在导入事务，不自动进入批次重构、搜索或新产品。原产品计划保留ROADMAP/READING_FEATURE_IDEAS；后续按一片一门槛推进。

以下为本片过程与上片历史，不覆盖顶部最终事实。

CI39712813755：独立BookImports8项通过；原生已越过早期build-for-testing进入模拟器首次数据迁移，14项尚未开始。当前仅确认包与接线编译，不称原生验收；完整日志/xcresult结束后核。生产610输入保持，不重派。

已冻结c8b53e38f9148f0a1968567191e1bca8471558b6 / refs/heads/codex/isolate-book-import-transactions，仅派CI39712813755（import-isolation）。frozen.json核610运行输入、20路径，scope-audit核service只改public/去掉ReadingInterfaces import，11await原文、元数据声明和ReaderEngine剩余协议正文保持；所有旧Tests/iOS/其他App/LibraryShelf/Core/Adapter/Vendor/锁/资源不改。Windows480语法新增0/54既有、96工具89通过7 POSIX跳过；首96工具名称错误原日志保留，修正复核全通过。watch_i5_import.py只读收本run，勿重派；独立8/原生14与真实编译待结果。完整192/Release/手机/IPA未执行，电脑保持开机。

Windows480语法新增0/54既有、静态153源/23区/24节点/2例外通过。96工具首检发现生成验证器时把用例名中的Shelf误替成Import，已只修回精确原用例名；失败原日志保留，不涉及生产或原测试。复核工具后再冻结，原生/Swift仍待验。

源码和8+14定向入口已接线，准备Windows静态/语法/工具检查；MetadataReading合同迁入BookImports，ReadingInterfaces/App保持typealias身份，原11await和service body须冻结时逐段核。App批次/picker/FontInbox/搜索/阅读/定位/LibraryShelf/所有原生旧测试保持；原生新增target先build-for-testing再boot。尚无新Swift编译/验收。

# 当前工作：I5b导入事务边界隔离（2026-10-22，用户已授权）

仅导入事务：新BookImports Foundation/Core包拥有EPUBImportService、ImportOutcome/ImportError、ImportedPublication/EPUBMetadataReading；ReadingInterfaces保留旧名称typealias兼容，阅读引擎协议正文不改。App保留同名alias、原picker/批次UI状态与原await；Readium loader在原Adapter实现，原服务暂存/身份/去重/解析/取消/最终化/提交/回滚顺序及security scope不变。FontInbox、搜索、reader/定位/字体/会话及LibraryShelf均保护；不推进新的批次编排提取，不跑完整192/Release/手机/IPA。

已核上片603运行输入与e3ff6c73保存点一致、1219路径基线build/maintenance/I5-import-20261022/before.json，普通HEAD/index保持，无旧Python观察任务。下一步独立包合同与原DocumentImport/去重/EPUB导入最小选择，先本地静态/工具，再冻结一组原生编译；门槛及实际成本分记。尚无新Swift编译/验收。

以下为上片保存结果与历史，不覆盖本轮工作。

# 当前断点：I5a书库本片完成，导入/搜索留后续（2026-10-22）

原生有1项新编译警告（同处发出2次）：LibraryAssembly:7对本仓库Core类型/LibraryShelf协议做外部符合，未来重复声明可能冲突；本片保留单一App组装声明，不静音、不为此改Core协议归属扩片。它不是编译错误或功能失败，完整原警告保留。已查看本次书架网格、非空回收站、保存封面三张原生图，均有预期内容；不代表手机或动效验收。

2026-10-22 I5a书库本片完成：LibraryShelf真实Foundation/Core包拥有同步列表、刷新身份及提交合并，窄仓库不暴露导入/搜索/位置写入。App组装原引擎/导入器，书库不再持有AppServices/创建Readium；原await、导入/搜索流程、Reader/R1/R2/R3/R4及定位/字体保持。最终1532b863 / CI39707770264独立6/6、原17+新增延迟初始化1=18/18，包和App/测试真实编译通过。书库UI仍同App target，特定类型静态检查不等于完整类型隔离。完整163+29=192/Release/设备/手机未跑，无新IPA，最后交付Build30；导入/搜索留后续。见Documentation/LIBRARY_ISOLATION.md和ValidationLogs/project-isolation-i5-library.json。

最终源1532b86300247bb8c6697323bfd6230d88a39bbb / refs/heads/codex/preserve-library-model-initialization / CI39707770264 completed/success。独立6和原17+新增StateObject挂载1原生18全部通过，无失败/跳过，test/summary/export=0。Windows476语法新增0/54既有，90工具83过7 POSIX跳过，修正影响4+8另验；最终Linux90/90。静态150第一方Swift/21区域/22图节点/2精确测试例外。

成本：两派发、首候选由Agent主动停止在包编译、无包测试完成或原生执行；修正源一次实际原生执行。包Swift构建62.12秒，包+原生步骤1519.0秒，包合同完成至首原生suite1373.218秒，18项实际合计18.019秒；准备/编译成本不称用例执行。

权威Documentation/ValidationLogs/project-isolation-i5-library.json；原件build/ci/39707770264/diagnostic，artifact12396681750/9630545字节/SHAde1ce10e2392a7b45c8d7ca63f77bee2023c6155cc182255da8fe97826427ca3，digest/CRC/完整解压已核；取消轮39707366902/full.log与artifact12395048460同样保留。只精确删重复ZIP，无历史/源码清理。

build/maintenance/I5-library-20261022含before/frozen/corrected-frozen/scope-audit/result/final-checkpoint。603运行输入冻结，1208原路径按精确范围保护；fixture移至App原件字节不变，所有旧原生测试/导入方法/搜索/阅读生产保持。普通HEAD仍6d761749911233122bcd031fcf718d22a19f9e77、index SHAb0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28；恢复核实际ref和进程，不重派本片CI，不reset/clean旧WIP。电脑保持开机。

用户本片已完成，不自动进入导入/搜索或新增产品。原特性计划保留在ROADMAP/READING_FEATURE_IDEAS。Library UI仍在App target，状态独立编译；全项目隔离/完整192/Release/手机仍待后续。

以下为过程与历史，不覆盖顶部最终事实。

观察修正：GitHub实时日志按分页延迟加载，聚焦步骤后单次Ctrl+End仍可能停旧页；已连续读状态/到末尾，直至可见最大行号不再增长，确认当前原生SwiftCompile（DifferenceKit），不是从旧尾部推断卡住。完整日志最终仍以下载原件为准。

CI39707770264独立6项实际通过（日志Verified library logic:6）；原生已完成XcodeGen和锁定依赖解析，当前模拟器首次数据迁移，18原生尚未开始，不称原生/编译验收。日志搜索框焦点会使Ctrl+End停留旧片段，已改从步骤标题聚焦至真实尾部；只读观察、不重派。生产603输入保持。

修正输入1532b86300247bb8c6697323bfd6230d88a39bbb / refs/heads/codex/preserve-library-model-initialization已冻结（603运行输入），仅派CI39707770264，6+18待结果。Windows476语法新增0/54既有，受改工具4+8通过；其余90工具既有通过，最终Linux90须重新核。首CI39707366902 cancelled：包编译尚未完成、无测试完成/无原生build/test执行，不称6或17通过；主动停止不是源码失败。full.log/metadata/artifact12395048460/1423字节/SHAf2ae4a9a2baf11dfdfc82a7f1e338b8a8bce12a5a11a2a3002411fa6bb06fe25已CRC/digest保存，重复ZIP精确清除。watch_i5_library_corrected.py只读观察新run，不重派。全192/Release/手机未执行，所有原生旧测试与阅读定位保护。

审阅发现并纠正默认model提前创建：按Apple StateObject thunk合同改LibraryView model参数为escaping autoclosure，保持原延迟初始化。CI39707366902已主动cancel（不是源码失败），待收实际步骤/完整原件。新增LibraryBoundaryTests1原生合同，原17正文保持，修正源仅跑6+18；完整计数163+29=192但本片不跑。下一步本地定向检查后冻结修正输入，仅补一次真实编译与18原生。前轮cc5929不能作为修正App输入的原生证据。

已冻结cc592909d4f4c827de84262d525d1ee1adedb6e2 / refs/heads/codex/isolate-library-shelf，仅派发CI39707366902（library-isolation）。frozen.json保护602运行输入、26路径（含原fixture无改动移动），原所有Tests/iOS/导入/搜索/reader/Core/Adapter/Vendor/资源/锁保持。scope-audit核原导入等未改方法正文与所有await表达式相同。Windows475语法新增0/54既有、90工具83过7跳过、静态149源/21区/22节点/2精确测试例外通过。观察脚本watch_i5_library.py只读收原件，不重派；Swift编译与6+17真实结果待收，完整191/Release/手机未跑。

源码/定向入口已接线，准备Windows检查：新增LibraryShelf6合同、library-isolation一次包+原17，原生测试正文全部保护；只新增三个静态书库依赖正反例与四个证据/路由工具合同。原await未移动，LibraryPresentation/导入方法/搜索与reader完全保持。待冻结前检查/真实Swift编译，未验收。

# 当前工作：I5a书库边界隔离（2026-10-22，用户已授权）

仅书库：新Foundation/Core LibraryShelf拥有列表/刷新身份/已提交元数据和回收站状态，窄LibraryRepository不含导入、搜索和位置写入。App保留原await/错误/互斥编排；引擎、导入器在App组装，书库只接依赖。封面流程只改依赖类型，不改事务；LibraryInteractionFixture移到App组装区域，原生测试通过兼容组装入口保持原文。导入/搜索/阅读源码与所有原定位/会话行为保护，不运行全191/Release/手机、不产IPA。

已核R4b最终594运行输入逐hash一致、1208保存路径基线build/maintenance/I5-library-20261022/before.json，普通HEAD/index保持，无旧观察/下载进程。下一步完成同步状态合同、静态依赖正反例和Windows检查，冻结后仅一次独立包+书库/回收站/封面原生定向编译验证。尚未编译/验收。遇到其他边界失败先留证，不扩修。

以下为上片已保存结果，不覆盖本轮工作。

# 当前断点：R4b本片完成，下一阶段I5（2026-10-22）

本轮用户授权的打开/重试/关闭编排切片已完成，实现/编译/定向验收通过；收口在本片，不自动进入I5或新增功能。电脑保持开机。下一阶段按PROJECT_ISOLATION_PLAN一片一门槛整理书库/导入/搜索与组装；后续产品计划保留在ROADMAP/READING_FEATURE_IDEAS。

## 当前实际结果

- 最终运行源c00083492fcfccd56fae978178f72e56a5542e35 / refs/heads/codex/fix-reader-lifecycle-repository-binding，[CI39703522408](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39703522408) completed/success：真实Foundation包15/15、原13项生命周期13/13，App/测试build-for-testing成功，源码编译错误0，test/summary/export均0。
- ReaderSessionLifecycle实际拥有原7个打开await与同步应用、retry完整close/清错、close最终位置后失效；App仅类型化SDK方法值/同步桥接。VM直接转交绑定入口，无async转发/额外Task；每次上下文保留接收者至结束，不由VM长期持有。R4a状态/回调、所有其他VM方法及原30项生命周期测试正文、R1/R2/R3定位/字体、Core/Adapter/Vendor/资源/锁不改。
- 首轮7ea52d / CI39702147807：14独立通过，App3处具体actor同步方法值编译失败，原生未执行；保留真实65与失败原件。改用已有any BookRepository async要求取值，不改DB，实现对应桥接合同使最终15；原计划复用首轮原生结果未成立，最终13是修正源重新执行。中间3fa329 / CI39702833284仅夹具清理14/14与session_logic_only=true快入口验收，原生skipped；不称最终15或原生验收。
- 本地470语法新增0（54既有Vendor限制，非编译）、83工具76过/7 POSIX跳过；最终CI Linux83/83。静态145第一方Swift/19区/20图节点、5精确例外不增加。最终生产/原生输入冻结后未再改；全部594输入逐blob保护，普通HEAD/index保留。
- 当前仅R4b本片及已有R4a各自门槛通过。全项目隔离/I5、R3整组、完整162+29=191、设备Release/普通设备/TrollStore/手机均未验收，无新IPA，最后交付Build30。

## 成本、原件与恢复

最终包步骤92.0秒（Swift构建68.55秒），原生步骤1054.0秒；首suite前992.658秒，13项实际0.652秒，其余为准备/编译/模拟器与宿主/结果采集。总体3派发、2原生构建尝试、原生用例真正执行1次；首编译失败与纯夹具轮成本分别保留，不隐藏也不统称测试执行。

权威Documentation/ValidationLogs/project-isolation-r4b.json；设计READER_SESSION_LIFECYCLE_ISOLATION及FAST_VALIDATION。三个run完整原件在build/ci/{39702147807,39702833284,39703522408}/diagnostic，下载均CRC/digest验证后只精确删重复ZIP，原件/日志/xcresult保留。最终artifact12395005666/422570字节/SHAf0a471e244d22b4c1fcd7f3a4a8154aec88f051cf4940d69187273fe1ee3e754。首失败与清理artifact详情见权威回执，不继续声称首轮有原生结果。

build/maintenance/R4b-20261022含1203路径before、frozen/fixture-frozen/corrected-frozen、机械映射审阅、attempts/result及最终检查点。普通HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，index SHA仍b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28；不得reset/clean旧WIP。收口ref为refs/heads/codex/reader-lifecycle-isolation-saved，实际SHA以final-checkpoint.json/远程ref核对；不要重派本片CI。收口已核无本人启动的观察/下载进程。

## 本片过程与历史

以下保留当时中间状态与失败/旧断点，不覆盖上方最终事实；“待编译/运行中/14项/复用原生”的文字不是最终门槛。

# 当前工作：R4b打开/重试/关闭编排隔离（2026-10-22，用户已授权）

仅推进现有ReaderSessions的编排切片。Foundation合同通过类型化方法引用接收原7个打开异步操作和原同步应用/清理；App保留SDK桥接。VM使用绑定方法值转交open/retryOpen，避免额外异步转发/Task；每次调用的编排上下文保留VM直到结束，VM不持有该上下文形成环。原阶段顺序、await后检查、字体失败降级、取消与普通失败区分、retry完整close后清错、close最终位置先接收再失效全部保留。R4a回调门/位置/字体事务和Core/Adapter/Vendor/锁不改。

源码及合同入口已写，尚未编译/验证：新增ReaderSessionLifecycle.swift、App/Reader/ReaderSessionHost.swift、8项ReaderSessionLifecycleTests；VM只替换原open/retry/close块为绑定入口与同步桥接工厂，其余方法不改。沿用既有包/target/架构区域，新增session-lifecycle choice只跑14独立+原13定向，不执行旧负对照；原生测试不修改、完整计数191不变。详细合同见Documentation/READER_SESSION_LIFECYCLE_ISOLATION.md。下一步先Windows语法/工具/静态顺序审阅，通过后冻结再派一次CI；语法不当编译。

Windows首检已通过：470 Swift语法新增0（54既有Vendor限制），Python83中76通过/7 POSIX跳过；工具新增核新choice不会执行旧负对照，独立14合同按各自类精确验收。此后仅修测试final-close observer的局部强引用为bookID值，避免fixture持有自身；不影响合同/入口，冻结前保留对其静态复核。当前无Swift编译/原生新结果，不记通过。

已冻结7ea52d41cbca4bdbe9271c3a984cb656a48872b8 / refs/heads/codex/isolate-reader-open-lifecycle，只派一次[CI39702147807](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39702147807)，selection=session-lifecycle。冻结收据build/maintenance/R4b-20261022/frozen.json：594运行输入逐blob核、9文件切片；原open完整流程经机械映射逐body比对一致，7await、检查/发布顺序保留，无异步转发/Task包装；其他VM方法及Tests/iOS/ReaderLifecycleTests.swift原件完全相同。普通HEAD/index保持。只读观察进程保存run/full日志/artifact元数据到build/ci/39702147807；若中断先查真实状态，不重派。当前编译/定向待结果。

首轮独立14合同步骤已成功，原生13正在同一CI准备。随后审阅仅修新测试失败清理：进入屏障超时先release/cancel/await旧Task，重开后先释放收完旧Task再断言newOwner非空；Gate可提前release。原2秒/所有行为断言保留，不是重试。此fixture源码变化须额外验证独立14，新增session_logic_only=true仅用于现有session-lifecycle时跳过原生步骤，默认false并有工具守卫；不再派第二个原生。最终必须分别记录首轮原生源与测试清理源，逐blob核实际App/库生产/iOS测试/工程/锁/版本一致，才能分项复用原13。正式结果未出，不能预报通过。

清理源已冻3fa3293277779ce990bbc182f001ddfa67462343 / refs/heads/codex/verify-reader-lifecycle-fixture，[CI39702833284](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39702833284)，session-lifecycle+session_logic_only=true；仅包合同，原生步骤必须skipped。fixture-frozen.json已核594输入仅测试fixture/工作流/工具scope测试3项runtime差异，全部App/库生产/原iOS测试/工程/锁/构建脚本与7ea52d相同；5文件子变更含文档/HANDOFF。Windows复核470语法及83工具76过7跳过。两进程只读观察各run，不重复派发；最终分别核日志/summary/xcresult与版本环境，不能把逻辑run当第二次原生。

实际首轮失败已确认：CI39702147807 completed/failure，独立14/14过，App build-for-testing在VM155-157三处报actor-isolated sync method不能partial apply，未启动原生用例/模拟器测试。不是环境或旧定位问题，也不能复用为原生13通过。失败完整日志/metadata已保存，artifact12394101464保留下载核验；不重写失败历史。已仅将三个仓库引用经现有any BookRepository异步协议暴露，并补1个同型actor同步实现/异步协议方法值合同（独立将为15项），无新增await/Task、无DB实现改动。对这一明确修正才补一次15+原13；并行的14逻辑清理run继续收原始结果，不能当最终15或原生验收。下一步本地复核后冻结修正源。

修正源已冻c00083492fcfccd56fae978178f72e56a5542e35 / refs/heads/codex/fix-reader-lifecycle-repository-binding，只派[CI39703522408](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39703522408)，session-lifecycle（默认session_logic_only=false），先15包合同、后原13。corrected-frozen.json核定相对3fa仅VM协议引用、测试/验证器及文档5文件变化；编排实现、所有其他VM方法、原生测试/工程/锁保持。原件：首失败artifact12394101464/194991字节/SHA5f9a3b2e2baf202a0997464c986554da69d0733f0db47810f4395d2c2f39b03d已CRC/digest完整保留；清理逻辑run39702833284 completed/success、14/14，原生步骤skipped，artifact12393403553/3452字节/SHA590e45f72e3e4eee9d47234bc0ce1648ec46c3c54b6d2472604ca3f9907c6270已核完整。均只精确删重复ZIP。Windows修正后470语法及83工具76过7跳过。新观察进程只读收39703522408，不要重派；当前Swift/原生最终结果待收。

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
