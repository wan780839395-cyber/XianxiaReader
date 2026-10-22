# 连续视口：可控冲突配对方案审阅（2026-10-23）

2026-10-23 后续状态：[本地配对夹具](I6_VIEWPORT_PAIR_FIXTURE.md)已在约定5项运行输入内实现并完成本地静态/工具检查，未编译/原生运行，CI接线仍未实施。以下是获批方案的原始审阅结论，其“未实施”仅指审阅当时。

**方案审阅完成，未实施，零CI。** 617运行输入与保存源`f3cfd0b0`一致；已有隔离、定位修复、S诊断、算法、断言和预算保持。本轮只写设计及审计，不将方案写成已编译/复现。

用户已明确确认：**保留现有smoke原样，另设配对安全/冲突模式；生产guard、原字可见断言和预算不变，冲突臂7项guard作为诊断观测。** 这不是给现有smoke去掉断言，也不是把它只换一行当匹配对照。

## 1. 审阅结论与已有证据

| 已核事实 | 对下一步的约束 |
| --- | --- |
| CI39806769382 / 2a9fdfb5编译及smoke1/1通过；79事件，主M7项guard全true、五类残留空 | 只证明当前受控安全顺序，不能当新配对模式的安全臂 |
| 该样本S在22结束，24才开启捕获前准入，M在31准入 | 没有旧S跨尺寸读取；直接沿用该状态机无法制造H1 |
| resize后sample在41排队、48才捕获新上下文 | 这是另一个新请求，不能把它后来改锚点的事件当作旧S跨尺寸 |
| 原`advanceSafeResize`要求S先真实退出；M后7项全true，否则关闭reader | 既会阻止目标交错，也会在预期anchorEqual=false时提前结束，见不到原字条件 |
| 旧full39735403242只有联合等待失败，缺缩放前锚点/同次S/M链路 | 即使新配对支持H1，也不能追认旧full根因 |

H1仍是假设：旧尺寸上下文S在新DOM下真实读取，若原检查允许其提交B替换A，已捕获A的M可能因原`anchorEqual=false`放弃补偿，且其余正常工作结束后原字仍不可见。

当前源码支持检验这个假设，但尚未证明它发生：`layoutSubviews`改尺寸并排入measure，未在该处递增viewportRevision；sample原guard核epoch/index/revision/localTop等，另核真实documentTop与冻结localTop；measure恢复还依赖保存锚点相等。`EPUBNavigatorViewController`上层检查不能撤销下层已同步完成的缓存写入。所有这些原规则保留，不通过递增revision、清缓存、伪造Locator或改scrollY造样本。

## 2. 公共准备：先封住其他请求，只保留指定S/M两条操作

A仍来自原+600动作后的原capture，原字charOffset>100；S仍是原政策认领的首个合格缓存未命中请求，停在原sample-before-read，保留旧尺寸上下文F0。原capture可以通过另一真实旧尺寸采样建立A；其旧尺寸来源和SDK实际退出必须可追溯。辅助采样最多一次，不清缓存或循环补发。

两臂都在**原capture结束、旧S尚在读取前屏障**的同一阶段封闭其余入口。这比当前smoke的“先结束S再封入口”更早，因此需要新安全臂。此时只允许已登记S及其关联辅助外层任务在途，其他旧SDK工作必须实际结束；存在未归属旧工作即准备不成立，不能悄悄并入实验。

封入口后，同reader/epoch所有slot的measure和所有sample都在捕获前排队。仅指定S和选定主M可以按下表交错；不是全局取消串行准入，也不让任意第二条请求旁路。S虽在封入口前已捕获，仍计入活动工作到实际退出；主M沿另一条显式准入记录，不能共用一个entryRunning导致互等，或把S提前从active中移除来伪装空闲。

主M选目标slot第一条排队measure，**在捕获前选定，不在结果失败后换选**。两臂都在原横屏100ms/30秒谓词内用相同只读domProbe观察目标宽度F1，只取widthMatches作入场准备；随后该M才真实捕获A并执行原JS，停在原before-commit。其他工作继续排队。只读准备观察的政策相同、实际次数留证，不凭固定sleep/FIFO/Task优先级保证顺序。

## 3. 两臂唯一有意差异：S在哪个阶段放行

| 阶段 | paired-safe | paired-conflict |
| --- | --- | --- |
| 公共起点 | A有旧尺寸来源、S持有F0上下文、其他入口已封闭 | 相同 |
| S与resize顺序 | 放行S，在F0真实读取并实际退出；应仍保存A，再执行一次真实resize | S继续扣留，先执行同样resize |
| 主M准备 | F1宽度就绪，第一条目标M捕获A，取得原真实result后扣住 | 相同；S此时仍在旧上下文读取前屏障 |
| S收件 | 已完成，无第二次S/补发 | 只放行指定S，使用F0冻结参数在F1下执行原JS；保留原3次/32ms与所有拒绝分支，等实际终结 |
| M提交 | 放行指定M，记录原7项guard与实际退出；安全臂要求全true | 等S实际退出后放行M，原7项guard原样记录为观测，不因预期anchorEqual=false提前关闭reader |
| 后续工作 | S/M均实际退出后，其余工作按排队顺序逐条新捕获、真实退出 | 相同；不压制可能恢复原字的正常工作 |
| 业务判断 | 原DOM宽/原字Range可见联合条件、同WebView、挂窗、alpha、资源上限；再按原逻辑回竖屏 | 相同；若横屏原断言失败，保留原失败/退出，执行原清理，不以探针替代断言或强行继续竖屏 |

每臂保留自己的原100ms/30秒横屏时钟和原竖屏30秒；准备推进、放行、收件、排空与原DOM条件均包含其中，不在状态切换时重置时钟。原capture/cleanup各3秒及上限32 continuation/128事件不变。原读字脚本、JS结果、SDK同步应用顺序不动。

配对模式把“实验顺序/资格”与“原业务断言”分开记录。冲突臂B未改变或被原规则拒绝时，仍记录真实结果、正常放行M并排空，再运行原业务判断；不能为了制造冲突更换S/M或改值。若owner/物理位置已被外部事件污染、缺回执或取消，则按夹具失败终止。现有smoke的全true失败门槛和六组机制保持，不让冲突模式改写其通过含义。

## 4. 合格配对与最小补证

两臂须来自同一构建/锁文件/原创书籍/模拟器配置、同一初始阅读模式、相同F0/F1尺寸和+600政策；分别使用新reader/窗口/测试进程及独立xcresult。A的资源、selector/textNodeIndex/charOffset应一致，原ViewportOffset与物理localTop按既有0.5px界限核匹配。不同臂UUID/ObjectIdentifier必然分别归属本实例，不要求字符串相等。

S选择政策和一次辅助请求上限相同，实际caller/source均记录；若调用链来源不同或A/尺寸不匹配，不称严格匹配对照，不自动补跑找匹配样本。动态轮询次数可以不同，但不得一臂增加额外前置DOM等待或改变M选择政策。

M必须真实捕获A，读到F1 DOM和有限height/anchorY；否则即使7项guard全true，也不能证明原本存在可执行的锚点补偿。H1有效的冲突结果还要求：S实际committed B、B与A不同，且M生产判断中的owner、当前index、非positioning、原锚点存在、起始/当前viewport有效、revision/local匹配均保留，**仅anchorEqual及其推导mayRestore为false**。若revision/local等也变了，不能重复上轮混杂路径的归因。

现有证据尚缺以下精确字段，未来实施仅补DEBUG同次结果/原判读的标量，不新增JS/await或改业务计算：

- measure-before-commit旁路原同次result的height与anchorY（不能把fixture元数据width冒充anchorY）。
- measure-guard补当前index是否仍匹配；现有positioning、M起始非nil锚点、其余7项及revision/local字段继续使用。
- 配对身份、阶段、选定S/M ID、入口封闭/许可/域终结/work终结、原失败子条件及清理残留。指纹仅作诊断关联，原Swift Locator相等判断仍是实际guard依据。

每次S attempt继续保留clipTop/clipBottom/documentTop/expected及逐项reason。同次DOM宽度证明S实际在F1读取，冻结native尺寸证明其请求来自F0，不能用另一个请求/后一次DOM拼接。若真实geometry不满足原检查，记录拒绝，不把新尺寸写入旧上下文让它通过。

## 5. 结果判读：不能只看状态变化

| 实际证据 | 允许结论 |
| --- | --- |
| 安全臂准备/原断言/清理任一失败 | 配对无效，先留证，不执行下一冲突臂或改算法 |
| 冲突S在F1读取但被原检查拒绝，owner等前提有效 | 本样本未走到覆盖；只说明该真实分支拦下这次请求，不证明旧S或所有尺寸竞态已解决 |
| S提交B但B=A，或M仍全部合格，原字可见 | 本样本未形成目标冲突，不换请求凑负例 |
| B替换A，M仅因anchorEqual放弃补偿，但排空后原字仍可见 | 只证明状态交错，未复现阅读故障 |
| 上述合格交错后，原30秒内sameWebView/挂窗/alpha/F1宽/有效Range均正常，唯原字Range不相交；新安全臂通过 | 支持本次受控H1路径导致原字故障；仍不是旧full的历史根因证明 |
| 原字失败同时WebView更换/脱挂/DOM未就绪，或revision/local/owner改变 | 混杂或独立故障，不能归给锚点替换 |
| 顺序缺失、S/M没实际结束、越过入场、超限、清理残留、关闭后提交 | 夹具失败，即使原字曾可见也不验收 |

原失败发生在联合等待，必须查看各子条件；不能将“联合false”直接等同于原字丢失。失败后原JSON/日志/xcresult先保存，额外观察不得为成功提供新时间窗。旧full缺失的历史锚点不能用本轮数据回填。

## 6. 取消、后续实施范围与执行门槛

许可仍按(requestID, point)分开；指定S读取许可、主M入场/提交许可和其他队列不能相互消费。先失效/关闭reader，再abort全部waiter，最后恢复窗口；两条指定工作、已发run但未退出的工作及外层任务全部追踪到真实终结，原3秒teardown不变。配对模式的双工作在途取消/先放行/重复放行/晚回调须单独核，不能引用现有smoke六组通过来充当新Pair状态已验证。

下一实施片建议只接本地夹具与证据：ReaderRenderingTests（保留smoke分支）、InfiniteScrollView上述DEBUG标量、UPSTREAM该文件摘要、verify_reader_positions及对应工具正反例，最多5项运行输入；不改Adapter/SpreadView/JS、target/依赖或算法。若需要抽取共享代码，须逐一核await与同步应用边界，不为复用重排已验收smoke时序。本轮5项均未改。

当前CI入口硬编码smoke，现有校验器也要求其安全顺序，**不能直接拿现入口执行配对模式**。CI接线另片审阅必要驱动/路由与真实退出码：拟最多安全一次+冲突一次，优先复用同一构建产物并启动各自测试进程；复用能力尚未接线/编译，不能承诺已只需一次准备。安全臂不合格即收口，不自动补跑。

以后即使冲突原断言按假设失败，也必须保留真实test65及失败xcresult；实验分类“支持H1”不把它改成测试通过、成功IPA或发布验收。驱动须在保留每臂真实状态后报告实验结论，默认不吞失败；不得把预期故障隐藏在成功门槛中。实际原生次数、构建复用与退出规则须另获执行指令，本次不派发。

## 7. 参考、验证与恢复

已复核[Swift SE-0306 actor重入](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)：await两侧不能当作同一事务；使用显式阶段回执控制交错。[SE-0300](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0300-continuation.md)要求每continuation恰好恢复一次，resume不代表主体已执行完成；继续使用当前Swift6.1.2适用的CheckedContinuation/实际终结回执。

成熟fixture参考固定[Async Algorithms1.0.4 GatedSequence](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/GatedSequence.swift)的先许可后产值；其[Gate](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/Gate.swift)只有单pending且会替换旧者，不能照搬为本项目多waiter队列，不引入依赖或UnsafeContinuation。本项目旧`ci_position_offset_control.sh`可参考原件/输入/退出码分项留存，但它会切源码且有已识别预期失败处理，不是本次同构建、仅时序差异的可直接复用驱动。

本轮只做文档/源码审阅、617输入与原件摘要核对及仓库文档/工程/工作流/Vendor/架构静态检查；不重跑Swift语法、工具全组、编译或原生。最新实际结果仍为2a9fdfb5/CI39806769382 smoke1/1；旧full191/192、I6/Release/手机未验收、Build30保持。

恢复目录build/maintenance/I6-viewport-conflict-review-20261023：before、review-result、完整文档检查日志、final-checkpoint；权威[审计](ValidationLogs/project-isolation-i6-viewport-conflict-review.json)。普通HEAD/index、全部617运行输入、已有原件和Build30摘要保持。当前仅审阅完成，配对模式、补证标量及驱动均未实施，零CI，不关机。
