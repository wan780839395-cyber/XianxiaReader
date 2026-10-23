# I6 准备期取消与诊断交付：本地审阅及最小补证（2026-10-23）

本片只审阅39946614486原件、当前冻结源码及官方/固定版本实现。619运行输入不变，没有实施探针、修改算法或派CI。上轮编译0、安全test/driver65、冲突null与未完成的原生观察验收保持。

## 结论与边界

**已确认诊断丢失的路径；尚未确认CancellationError的首个抛出await或发起取消者。** 最小补证应同时解决“首错记录晚于清理”和“预arm缓冲未交付”，不能只给最终错误换一句文案或重复自然重放。

原件只有mechanics通过、RENDER_HOST_READY、一个连续spread的request/attached/clear/detached，以及38.343秒处的裸CancellationError。pair仍seal/stage0，sampleID/measureID为空，控制只有closing/abort-issued，readDiagnostics/total/dropped均0。不能把这些0解释为没有writer执行、属性已恢复、没有缓冲丢弃或所有取消路径通过。

### 取消传播审阅

| 路径 | 当前源码合同及本轮能否定位 |
| --- | --- |
| host准备 | RENDER_HOST_READY证实原host等待已通过。它不证明publication-open、封面probe、jump或正文准备均完成 |
| engine.open | 原loader await、Task.checkCancellation、openRequestID失效分支可以产生/传播取消。缺返回/首错标记，不能认定具体是哪条；已有spread生命周期也不能替代每个await回执 |
| 封面/正文WK probe | 测试直接调用公开WKWebView async API，未经过本次Spread writer包裹。现有日志未记录其回调错误类型/domain/code或当前测试Task标志，不能据裸错误判定任务取消或WK失败 |
| 原100ms轮询sleep | Swift6.1.2中此API会在当前任务取消时抛CancellationError；需要知道首错阶段与当时的Task.isCancelled。没有阶段记录，不能用38秒反推是哪一段预算 |
| Spread.evaluateScript guard | 等原spreadLoaded后，wasCleared或Task.isCancelled产生Result.failure(CancellationError)。此guard早于新writer观察，且在旧fe67f563源码中已存在；不是新观察器新增取消点 |
| tagID/Locator导航 | 上述Result失败在Reflowable中转false，Adapter的章节go再报navigationFailed，沿这些分支不会直接原样抛成当前裸CancellationError。此排除仅限已核分支，不代表排除所有SDK间接影响 |
| S/M、位置捕获、resize/返程 | 本轮未到armSample，更未到原capture、S、M和resize；不应先改这些算法解释准备期错误 |
| slot 20秒加载保护 | 自己的sleep取消被本Task捕获并return，不直接向XCTest抛错；真正超时后的clear可能间接影响正在等待的操作。缺入口标记，不能确认该分支本轮执行 |
| 合成mechanics取消 | 使用独立、无engine/window的控制器及Task<Void,Never>；取消这些句柄不等于直接关闭真实engine或向本测试抛错。不能把通过的合成取消当真实SDK取消覆盖 |

已有clear日志可能来自错误后的原defer/teardown。它先于XCTest打印，不足以证明它先于错误发生。当前Task标志即便将来读到true，也只能表明采样时的取消状态，不能凭它认定是谁发起取消。

### 已确认的交付缺口

1. `EPUBInfiniteScrollView.fixtureRecordInnerDiagnostic`在state.live前缓存最多255条，等test-auxiliary/original-capture采样才flush；正常native早采样不会触发交付。这是有意的原控制边界。
2. `ViewportFixture.observe`对sample-read/viewport-sync另要求pair!=nil且armed。即使SDK提前送来元数据，原接收端仍会丢掉。
3. container.clear先关闭各spread诊断，随后换epoch/evict，最后把fixtureInnerDiagnosticStorage置nil；setter也先关闭旧诊断再丢缓冲换控制器。两处都没有在旧缓冲作废前排空。
4. 原test defer会先cleanUp：abort→关闭真实reader→恢复frame→移除fixture；XCTest最后才打印未捕获异常。若只在tearDown补错误文本，已经无法区分原错误与清理后果。
5. Adapter bridge的observe是同步、原requestID/kind/values透传，没有新的过滤或await。此次方案无需改Adapter或新建跨模块API。

## 官方及成熟实现核对

- [Swift6.1.2取消实现](https://github.com/swiftlang/swift/blob/swift-6.1.2-RELEASE/stdlib/public/Concurrency/TaskCancellation.swift)：checkCancellation检查标志后抛错；CancellationError也可直接构造。错误类型本身不等同于当前任务已被取消。
- [Swift6.1.2 sleep](https://github.com/swiftlang/swift/blob/swift-6.1.2-RELEASE/stdlib/public/Concurrency/TaskSleep.swift)：取消时恢复原sleep continuation并抛错。只观察现有sleep边界，不加取消handler/Task或重新等待。
- [Apple公开WK回调合同](https://developer.apple.com/documentation/webkit/wkwebview/evaluatejavascript(_:completionhandler:))：原结果/错误由原求值回调返回，回调在主线程；这不是所有加载/滚动事务已完成的屏障，也未保证当前错误一定表示Swift测试任务取消。
- [Readium3.11固定Spread](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBSpreadView.swift)、[固定Reflowable](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift)：保留spreadLoaded→一次原WK调用→原回调，导航布尔失败合同作为参考。当地连续滚动/关闭扩展不能冒充上游原实现，也不为本片退回上游clear而撤销已修复生命周期。
- [Apple Async Algorithms1.0.4 Gate](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/Gate.swift)：参考显式状态交换、一次排空和恢复点顺序。该Gate自身不是完整取消方案，本片不引入其unsafe continuation或新依赖。

实际工具链为Swift6.1.2/Xcode16.4，模拟器iOS18.5/22F77。方案只用已有Task.isCancelled、NSError元数据、ProcessInfo uptime与现有continuation；不采用最新Swift6.5的cancellationReason等API，不将编译器源码tag当精确设备runtime二进制。精确WebKit版本仍须从原coverage-start读数交付，不能按OS或参考WebKit tag填值。官方页面动态抓取/路径404失败与最终成功固定源分别保留记录；不用失败页面支持结论。

## 建议下一片：仅5个运行输入

| 文件 | 最小职责 |
| --- | --- |
| Tests/iOS/ReaderRenderingTests.swift | paired-only准备阶段/首错快照；现有await前的同步标记；允许未arm的paired元数据进入原诊断journal；相应同步mechanics反例 |
| Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift | 已知clear入口原位置的被动来源标记；旧owner/epoch缓冲作废前一次排空 |
| Vendor/ReadiumToolkit/UPSTREAM.json | 仅该Vendor源码摘要及诊断说明，保留baseline/锁文件/版本 |
| scripts/test_readium_provenance.py | DEBUG/Release、原await/调用/清理顺序、旧owner排空和容量的源码正反例 |
| scripts/test_reader_positions_tools.py | 首错/提前诊断不能替代SDK、原safe失败仍拒绝、原smoke与返程双向断言仍有效的反例 |

不改Spread/Reflowable/FixedSpread签名、Adapter、生产位置/导航/加载算法、JS资产、工程/target、CI驱动或验收器。目录和模块归属保持，不先扩散到所有打开/关闭场景。

### A. 首错必须先于原defer清理保存

- 只为paired-safe/conflict创建fixture-owned、MainActor同步的准备记录；smoke/默认nil保持原路径，无全局/跨用例状态。
- 对open/封面probe/jump/正文准备的**原有**await前记录固定阶段。对原probe JS、原轮询sleep等需要区分的内部点，给现有helper传可选同步观察器，默认nil；签名只用常驻的Foundation原始类型，DEBUG-only fixture类型不漏入Release helper签名。不新增async wrapper、await、Task或取消handler，不改原WK API重载、脚本或提交次数。
- 记录最后进入阶段、进入时uptime/当前测试Task取消标志；首错记录阶段、捕获时uptime/取消标志、动态错误类型、NSError domain/code，另带已有fixture nonce/mode及已持有的原生owner身份。不能复制localizedDescription/userInfo、路径、Locator/正文或新查询页面。
- 首错为一个有界、只写一次的payload字段，阶段为一个有界最新快照；反复cleanup和journal溢出不覆盖首错。记录函数必须同步且不抛错，不在原catch中做可能抛错的序列化或Task.checkCancellation。不假造Task ID，明确标注taskRole=test-current；slot timeout Task的标志不能混称测试Task标志。
- 外层do/catch仅在准备未完成时保存首错并原样throw error。**现有最早fixture cleanUp defer必须留在此do/catch之外、注册顺序不变**，使catch先存首错；不能为记录而提前abort/close，不能把CancellationError改成timeout、Failure.invalid或成功。准备已完成后的S/M/返回错误不能冒充准备首错。
- 原fixture.failure可以继续none；新增firstError不授予业务资格，也不单独制造第二个fixture失败来替代原XCTest错误。

### B. 只为将要作废的旧缓冲增加交付出口

- container.clear：保持原物理动作和调用顺序；在原configureInnerScrollDiagnostics(nil)循环已产生coverage-end之后、原epoch更换/evict/缓冲置nil之前，同步交付旧缓冲。正常活跃期的采样flush时点保持。
- fixture setter：在关闭旧spread诊断后、原缓冲丢弃和viewportFixtureStorage换新之前，交付给捕获的**旧fixture**。不能借新owner/nonce盖住旧事件。
- 优先复用原有一次排空规则：旧state置live/取出并removeAll/一个交付receipt/逐条交付；即将退休的状态随后仍按原代码清理。读取已有storage，不为了记“空”创建新buffer；nil/从未建立的状态保持未观测，不能假造coverage。
- paired接收端只调整sample-read/viewport-sync这条**诊断分支**的未arm接收；pair仍必需，closed后的旧终结仍只到旧fixture。原控制observe/pause、armed、admission、guard和所有真实SDK终结规则不变。
- 原独立256诊断journal、255条预arm缓冲+1交付receipt及丢弃计数保持；溢出仍显式incomplete。原128控制账本不增加事件；不靠删除早期记录、清零丢弃或忽略未登记SDK请求换绿。
- 已知clear来源在原调用点记录固定标签：shutdown、reload，以及slot timeout真正通过原guard后、原view.clear前的timeout-fired；不改变clear/override签名，不搬动slot移除/epoch更新/stopLoading/continuation完成/Task.cancel。来源事件只属于诊断，不生成SDK work/sample/measure终结。
- 对原slot-evicted/spread-clear/fixture-replaced仍保留原coverage-end原因。未覆盖的直接clear或进程消失继续unknown；不能因新增几个标签声称所有清理发起者已覆盖。
- 不查询新的DOM或WK JS；不加stack扫描、全局hook、取消屏障、额外等待或恢复重试。同步观察也有成本，不能称零干预。

## 先做的本地定向检查与结果判读

实施后的本地检查只覆盖受影响边界：provenance及原smoke2/配对7工具检查；新同步fixture机制先静态审阅，不能将Windows语法/源码检查写成Swift行为已执行。按项目要求做一次仓库语法/静态，原生编译与同例执行另待授权，本片不执行这些实施验收。

必须包含：

- 首错恰好一次、原错误对象/语义继续传播；后续defer/teardown不覆盖；prepare complete后的异常不误分类。静态检查do/catch与原defer先后，原await列表/WK调用及默认nil/Release合同不变。
- 未arm的paired元数据可接收但控制状态不推进；smoke不启用新行为。首错/版本/恢复标签不补全S/M真实回执，准备期失败仍被原验收器拒绝，退出65/null保持。
- clear和换fixture两条退休路径的coverage-end→旧buffer交付→epoch/storage失效顺序；一次排空、空/nil、重复清理、255/256边界/丢弃、旧owner/迟到与新fixture隔离。缺失/错身份/重复或溢出不能授予合格。
- 保留原guard、3次/32ms、封面probe20秒、100ms/30秒、3秒capture/cleanup、原20秒slot保护，以及返程窄屏、原字双向断言和每请求真实终结。不开新CI接线，不放宽驱动门槛。

| 后续证据 | 最多能怎样判断 |
| --- | --- |
| 首错是probe/poll-sleep，进入或捕获时测试Task已取消 | 定位到取消被观察的await区间；发起取消者仍须另证，不能归咎某个child |
| 首错是公开WK JS，测试Task标志false | 原WK/资源/显式错误路径优先；结合NSError与同owner清理记录审阅，不能仅据类型认定WebKit缺陷 |
| 同WebView的timeout-fired先于首错 | 支持原加载保护间接终止等待的候选；不等于证明其全部因果，不增原20秒预算 |
| 首错先于cleanup/shutdown标签 | 后续clear可以是清理后果；不把它当首次取消者 |
| 只定位到publication-open | 仍缺loader/旧请求失效分支证据；下一片再定边界，不预先改Adapter |
| 收到旧coverage-start/end和排空receipt | 可恢复已有真实版本/提交元数据；不代表原字/S/M或恢复属性已通过 |
| 缺首错、缺排空、错owner、overflow或进程退出 | 本轮观察不完整，保存失败；不能当“未执行/已恢复”，不继续无诊断重放 |

## 保存与当前验收状态

[持久审阅记录](ValidationLogs/project-isolation-i6-preparation-cancellation-review.json)。恢复`build/maintenance/I6-preparation-cancellation-review-20261023/`保存before、固定参考原件/哈希、source-review-audit、result及最终checkpoint。

本片不实施上述5输入方案，只改项目文档；619运行输入、4835旧证据记录、Build30和普通HEAD/index保持，AGENTS已有改动不覆盖。只做文档静态与源码审阅断言，没有新Swift语法/编译/工具套件/原生/full/Release/IPA或CI派发。旧回跳根因、原生观察与I6发布缺口继续保留。
