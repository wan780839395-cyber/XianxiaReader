# smoke安全顺序审阅与最小修正方案（2026-10-22）

2026-10-22 后续已按本页方案实现最小DEBUG准入/逐条排空候选，本地检查通过、零CI；未Swift编译/原生验收。见[实现与状态](I6_SMOKE_ADMISSION.md)，以下审阅/设计保持当时结论。

**审阅与方案完成，未实施，零CI。** 617运行输入与66d25ece保存源逐项保持；本片不改定位算法、fixture、S诊断、断言或预算。以下是准备实施的测试编排合同，不能写为已编译或已修好smoke。

## 1. 已证原因：屏障圈住的不是所有会改变M资格的操作

权威原件是CI39793517830/2274ba25的33项事件及[本轮报告](I6_VIEWPORT_S_NATIVE.md)。S首采样committed，旧S第三次rejected本次没有发生；本审阅只解释已观察到的M资格失败。

| 序号 | 真实操作 | 对M2的影响 |
| --- | --- | --- |
| 14 | S完成，锚点指纹A=6f417c8a0ff9e69e | 安全顺序此时成立 |
| 15、16 | M1/M2均捕获A、revision2、local2367 | 两个独立旧上下文已经形成 |
| 17–19 | M1同次DOM宽402，未匹配目标874的屏障；原恢复guard全true，完成时revision3/local2151 | M2捕获的版本和局部位置已过期 |
| 20、21 | M2返回DOM宽874，被扣住 | 扣住时只能保护它自己，不能撤销M1提交 |
| 22–28 | 后续native采样第一次documentTop2367不匹配local2151，第二次documentTop2151提交指纹B=ba9c2d8ae5057f9e | M2保存的A又被替换；这是指纹变化，不能仅凭指纹宣称读错字 |
| 29–31 | M2放行，owner仍匹配，anchorEqual/anchorCurrentNow/revisionMatches/localMatches/mayRestore均false | 夹具要求的恢复资格不成立，smoke失败 |
| 32、33 | close再abort，active/tasks/waiters全空 | 本样本没有清理残留 |

M1的measure-guard到measure-finished之间的实际提交段无await，事件18→19的版本/位置变化发生在此提交路径（包括同步UIKit回调）。现证据没有M1的原始height/anchorY明细，不能仅凭innerWidth402就认定某个几何数值计算错。M2的owner=true表明这不是旧reader/旧slot回调；原guard阻止了不合资格的锚点恢复。

`ViewportFixture.pause`的两个选择条件构成直接缺口：M只匹配同owner且DOM.width达到目标宽；S只在`sample == nil`时选择第一条。因此过渡M直接放行，后续新采样也直接放行。两者都能写`slot.savedAnchor`或改变当前viewport的恢复资格，原方案只保证“S先完成”，没有保证“M从捕获到提交期间这些状态不被其他操作改变”。

另有两个静态风险，**不是本轮已执行的根因**：

- `drainMeasures()`先设draining=true再resume全部M，后续M马上绕过屏障；resume也不保证SDK主体已完成。本例在调用drain前失败，不能说它造成了这次失败。
- 只把现有提交后屏障扩大到所有M，会积压已经读完旧DOM的结果。即使其mayRestore=false，measure仍会执行`slot.height = height`及可能的layoutSlots；不能将它们当作不会写入的无害旧请求，或直接丢弃来取得全绿。

## 2. 建议方案：只在受控区间、捕获状态前准入，主M后逐条排空

保留现有S首次读取屏障、M真实DOM结果后的提交屏障和所有原判断。新增一处**测试专用的入场控制**，同时覆盖`measure`与`firstVisibleElementLocator`的上下文捕获入口。同一reader/epoch的measure会通过layoutSlots影响当前viewport，不能只按目标slot过滤测量；采样也在该reader/epoch内统一管理。只在S和原capture已经完成、准备执行一次resize时启用，不影响原S过程。

此处有意增加DEBUG且显式安装夹具时的await，属于测试时序变化，不能称为纯职责提取或生产修复。未安装夹具与Release均无新增await/队列；正常引擎的定位、采样、缓存、Readium脚本和写入规则不动。

具体位置：

- measure入口，在读取measuredRevision/measuredAnchor/measuredLocalTop/measuredAnchorIsCurrent以及构造anchorJSON之前。禁止仅在evaluateScript之后排队，否则旧结果已经形成。
- sample入口，在冻结clip/frame/revision/local及缓存判断/DOM读取之前。现有详细sample-start、sample-before-read、sample-dom、sample-decision与sample-finished诊断在真正准入后仍按原逻辑产生；不能用排队时的预览值冒充准入后的S诊断。
- 请求ID、排队生命周期从入场前开始登记；SDK真实退出的defer提供终结回执，包含尚未捕获就取消的路径。resume后、捕获前复核原reader epoch、slot和取消状态；迟到请求不得冒充当前owner。

### 一个横屏等待时钟内的顺序

1. 验证原capture的A及S旧尺寸committed。原S第三次拒绝的诊断保留，不能为了到达M而放宽S要求。核准入前已有工作的真实终结；存在未受控的旧工作则判准备不成立，不把它悄悄并入新组。
2. 在同一个MainActor同步段内关闭入场，再执行原真实window.frame变宽。之后新来的测量/采样停在捕获前；不读取旧版本后再等待，也不创建新的SDK请求替代它。
3. 在原100ms/30秒横屏谓词中，复用已有只读domProbe脚本观察目标DOM宽度就绪。此时只取widthMatches作入场资格，**不能要求原字此时已经可见**，因为主M尚未补偿。DOM原联合可见断言仍在主M与排空完成后独立执行。此举增加了前置观察时序，必须记录，不保证无观察扰动；不增加独立等待、轮次或预算。
4. 准入目标slot的第一条排队M作为M0；其余同reader/epoch工作仍排队。该M现在才捕获A/版本/local并执行原真实JS。不是在多个失败结果中挑一个成功者；M0资格不成立就失败，不换下一个M重试。
5. 保留现有M0的真实before-commit屏障，核同次DOM宽、owner和捕获A，显式放行。必须取得原恢复guard全true及SDK实际finished，不能用release或measure-finished的committed单独代替锚点恢复资格。
6. M0实际完成后，排队工作按入场顺序**一次准入一条**，等其真实SDK终结后才准入下一条；它们此时才取得新上下文并作原判断。邻章M也要正常执行，不能丢掉、返回伪成功或把旧测量结果排到新结果后回放。只控制测试调用的时序，不改变每条真实操作的算法。
7. 原DOM联合条件为真后，再于同一MainActor返回点确认队列、运行中工作及waiter为空。若DOM await期间又有真实工作入场，继续在同一截止时间内排空并观察，不新建请求、不重置30秒。通过这个观察点后才回到正常准入；随后原竖屏分支不再注入。

UI布局、导航失效、加载watchdog等不是本片要改造的全局事件系统。它们若改变owner/资格，保留原guard并将该样本记为准备不成立；不靠禁止所有回调保证绿。尤其邻章loadTask可能等待measure，原20秒加载watchdog保持，排队不能绕过或延长它。方案只控制本次已证的measure/sample交错，不能承诺屏蔽一切UIKit事件。

### 许可、取消与证据

- 同一个请求可能先通过入场点，再停在原提交点。许可/continuation须区分`(requestID, point)`；不能让“已准入”的许可自动放过M提交屏障。入场记录使用queued/admitted/work-finished等独立事件语义，不能冒充原held/released/committed回执。
- 所有入场与提交continuation合计仍最多32，关键事件仍最多128；先释放也要记住正确点的许可，重复放行幂等。超过原上限直接失败并清理，不静默丢记录，不增加容量。
- 取消/关闭仍先标终态并关闭reader使epoch失效，再一次性abort入场和提交waiter；已发run但SDK未返回的工作继续计为运行中，须收到真实终结回执。不能把waiter移出字典就宣称队列已静止；teardown仍限原3秒，窗口恢复仍在失效/abort之后。
- 原S/M实测回执校验保持；新增入场顺序、同一时刻最多一条已准入工作、排空完成及晚提交的证据校验。已有六组机制检查保留，可扩强原多waiter/drain组内部断言，不能叠加新的超时段或把合成事件当真实SDK验收。

## 3. 为何这是本例所需的最小边界

| 更小改法 | 缺口 |
| --- | --- |
| 只禁止后续sample | M1已经单独让revision/local失效 |
| 只将旧宽M加入现有提交屏障 | 已捕获旧结果，排空后仍可能写旧height；不控制后续sample |
| 只控制目标slot的M | 邻章measure也能调用reader的layoutSlots影响viewport |
| 看见未持有M成功后改选它/重设A或revision | 改写实验起点，无法保留现有目标DOM及主M资格要求 |
| 接受主M的guard=false或忽略该断言 | 掩盖准备未成立；不满足用户保留原断言的要求 |

拟实施文件限制为5项：InfiniteScrollView的DEBUG入场接线、ReaderRenderingTests私有控制器/同例编排、UPSTREAM中该Swift摘要，以及既有位置证据校验器和对应工具正反例。Adapter自有DTO/协议与SpreadView/S诊断不需改变，不加target/依赖/新CI选择或新XCTest方法。未来实际差异超出此范围时先说明理由，不顺带改加载、定位或UI。

最低检查范围：保持原3次/32ms、capture/cleanup3秒、waitUntil100ms/30秒、两方向、原字charOffset>100、同WebView/挂窗/alpha、DOM宽/Range可见及≤12资源。先做入场/提交两点许可、并发排空和取消的离线结构/合同检查；Windows语法与受影响工具结果须注明非Swift执行。另获授权后才编译并跑同一smoke一次，失败留证，不自动重跑或扩整套。

这只修正**受控smoke的安全顺序**。串行准入改变自然交错，不能将它的通过当作自然并发正确、旧S第三次拒绝已解释、H1冲突复现成功或full192已通过。后续若设计冲突对照，须单独定义哪些请求允许跨尺寸捕获/提交，不能未经审阅复用此串行方案声称仍是原匹配对照。

## 4. 参考与本轮验证

复核固定版本[Async Algorithms1.0.4 Gate](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/Gate.swift)及[GatedSequence](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/GatedSequence.swift)：取显式许可及“先enter再产生值”的模式。Gate只有一个pending continuation，遇第二个enter会替换并resume旧者；不能照搬为本项目多waiter队列，也不复制UnsafeContinuation或引入该依赖。

[Swift SE-0300](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0300-continuation.md)明确resume只是安排恢复，须每路径恰好一次；采用项目现有Swift6.1.2可用的CheckedContinuation/MainActor方式，实际完成仍靠SDK终结回执，不借旧示例的取消写法。上述参考只支持门控方式，不能证明本reader方案已运行。

本轮只有文档/审计变化，617运行输入零漂移，原始日志与附件摘要重核一致。只执行仓库文档/项目/工作流/schema/fixture/Vendor/架构静态检查；不重复Swift语法、Python全组、编译或原生测试。上轮实测仍为编译通过、smoke0/1，旧full191/192、I6/Release/手机缺口和Build30保持。

恢复目录build/maintenance/I6-smoke-safe-order-review-20261022：before、review-result、完整文档检查日志及final-checkpoint；权威[审计](ValidationLogs/project-isolation-i6-smoke-safe-order-review.json)。下一片只在用户要求后实现上述最小夹具修正并做本地检查；本审阅不授权实施或派CI。普通HEAD/index、Build30 IPA/TestKit哈希保持，无新IPA，不关机。
