# I6 配对控制与验收区间审阅（2026-10-23）

## 后续最小实现与本地检查（2026-10-23）

已按下文方案实施，仅两个工具文件有运行输入变化；原审阅记录从下一节起保留其当时状态。

- `verify_viewport_pair_arm`区分真实准入结束点和关闭观察终点。前者继续原S/M guard、FIFO与真实排空；之后按唯一work-start归属核每个SDK请求，禁止跨界重命名、复用身份、孤立/重复事件、缺终结、假captured及关闭后提交。原128事件/32 waiter/3采样上限不变。
- 返程measure保留实际布尔guard与mayRestore=false，真实committed不等于已执行位置补偿；不对返程强制FIFO。sample区分实际缓存、读取和原有三次内分支，核冻结clipTop/局部位置、同次DOM/decision与真实terminal，不伪造JS或忽略失败。
- 原完整Locator与WebView贯穿宽窄两个原记录；成功须各自最后实际DOM poll的有限坐标、宽度、挂窗/alpha/可见/accepted和原时间顺序。返程仅有passed标签、宽屏poll冒充窄屏、换origin、字不可见都拒绝。真实65和安全失败停止保持。
- 原件副本旧validator仍报`Unregistered SDK work crossed the paired interval`；新验收保留全部85事件并明确返回97616F62(62–68/7条)、B21FDA31(69–75/7条)、C1E3C098(76–83/8条)，未按请求ID豁免。此离线结果位于`build/maintenance/I6-pair-interval-fix-20261023/original-safe-offline-review.json`，没有覆写旧CI或授权启动冲突臂。
- 本地定向7配对（含逐条删除/重复/串身份/跨界/未退出、缓存和真实三采样/超限、双向DOM及65反例）+2既有smoke+28驱动消费者检查通过，共37项唯一工具检查。首轮6/2/28及最终7/28真实命令/日志均保留，日志中CLI64是本地真实子进程失败样本，不是原生执行。smoke实现及两项测试AST无变化，复用本轮实际2/2；484 Swift语法通过，54既有上游限制/新增0，不是Swift编译。

619输入仅两工具变化，其余617逐哈希保持；验收器只有上述一个顶层函数AST变化，smoke/CI/Swift/SDK/Adapter不变。2567旧证据、原Build30与普通HEAD/index保持，AGENTS既有文字变化原样保留，未归入本片。恢复`build/maintenance/I6-pair-interval-fix-20261023/`有before、各次检查原日志/退出、原件副本、源边界/原件核验、result与最终私有快照；[持久结果](ValidationLogs/project-isolation-i6-pair-interval-fix.json)。

本片未派CI、未编译/执行新原生配对、未跑full/设备Release或产出IPA。旧CI仍safe0/driver2/conflict null；没有冲突臂、同构建双臂通过或旧1767根因的新结论。I6/full191/192/Release/手机和新取消分支未命中缺口保持，不自动运行下一CI。

---


本轮仅本地审阅与最小修正设计，基线`1b6bcda0`。**零运行源码改动、零CI，没有实现新的验收器，也没有重新判定旧CI通过。**保留返程窄屏、原字双向断言、实际SDK回执、smoke、隔离/定位修复及S诊断；生产guard、原S/M资格和等待/事件预算保持。

## 已查清的不一致

39920796794编译通过、安全原单例1/1，但driver2、冲突null。原85条控制事件如下：

| 点位 | 源码与真实回执 | 应承担的合同 |
| --- | --- | --- |
| admission-armed21 / pair-sealed22 | armMeasures开启准入，仅保留指定S，选第一条目标M | 控制首轮宽屏S/M交错及后续FIFO排空 |
| pair-drained60 | 受控S/M与已排队工作都已真实退出 | 此刻排空，不证明以后不会再产生SDK工作 |
| 宽屏DOM通过 / admission-complete61 | acceptVisibleResize核stage4、isQuiescent，然后admissionActive=false | 结束捕获前准入；原字宽屏条件已满足 |
| 返程窄屏62–83 | 原测试将window恢复原size，不再调用宽屏配对advanceResize；pause遇admissionActive=false直接返回true | 按原逻辑运行的新SDK工作，仍须观察其真实生命周期和原字可见结果 |
| closing84 / abort-issued85 | 两方向原断言之后关闭reader，五类集合最终为空 | 关闭失效、continuation与迟到提交检查 |
| 原pair验收器481–486 | 要求seal到closing内所有SDK工作都在首轮queued登记集合或指定S中 | 把已结束准入后的自然工作也要求queued，遂拒绝三请求 |

Swift夹具的控制终点是61；Python验收器的准入要求延续到84，两者不一致。原方案明确“首轮排空和业务判断后按原逻辑回竖屏”，现有smoke验收也使用admission-complete作准入区间终点；这提供了既有合同依据。**不是新诊断事件占用了SDK登记，也不能据此断言3个请求是多余工作。**

## 这3个请求具有什么证据

| 请求（短ID） | 原序号 | 实际链 | 本例结果 |
| --- | --- | --- | --- |
| 97616F62 | 62–68 | work-start→measure-before-capture→measure-start→before-commit→guard→measure-finished→work-finished | committed/captured=true；revision3→4、local2151→2340 |
| B21FDA31 | 69–75 | 同上 | committed/captured=true；mayRestore=false，仍有真实终结 |
| C1E3C098 | 76–83 | work-start→sample-before-capture→sample-start→before-read→sample-dom→decision→sample-finished→work-finished | documentTopMatches=true、committed/captured=true |

三请求均在61之后开始、84之前结束；reader/epoch/slot/WebView/index在各自生命周期内一致，开始时nativeWidth402，没有queued/admitted。原件有完整捕获、领域终结和外层work终结。第一个measure的revision/local变化和第二个mayRestore=false说明：**不能要求返程所有动态位置字段恒定或所有measure都执行补偿。**保留实际生产guard决定，生命周期核验不应重写它。

返程证据也已存在，无需追加Swift探针：`CONTINUOUS_RESIZE_EVIDENCE`依次为before-resize、passed-874、passed-402；两份通过记录都含原origin、originalWeb及polls。各自最后一个原DOM poll保留sameWebView/attached=true、alpha1、valid/visible/widthMatches/accepted=true，实际宽度分别874、402，原字坐标和Range有效性齐全；窄屏poll uptime1539.430663001。原用例两次都保留资源上限12和原截图。

## 最小方案：只修改两个工具文件

下一实施片建议仅：

1. `scripts/verify_reader_positions.py`中的`verify_viewport_pair_arm`及必要私有辅助核验。
2. `scripts/test_reader_positions_tools.py`中的配对证据样本和正反例。

不改ReaderRenderingTests、SDK、Adapter、诊断、CI接线或smoke校验。不新增事件、Task、JS、continuation、等待、重试或实验阶段；保留Swift现有宽屏控制与自然返程时序。把准入延长到返程并强制FIFO会改变原实验，不是本片选择。

这不是简单将`< closing`替换成`< admission-complete`。应将每个SDK requestID完整归入下述两种核验，seal→closing内仍不允许存在未核验请求或孤立SDK事件。

### A. 原受控区间

- 唯一、真实、顺序正确的admission-complete作为成功臂的准入终点；必须位于最后pair-drained之后、closing之前，原宽屏DOM谓词已合格，边界计数均0。
- 独立核对该点前指定S、主M和所有受控请求都实际结束，不仅信任“零残留”字符串。请求在终点前开始就属于受控区间，不能把终结拖到终点后再改名为返程请求。
- S/M选择与安全/冲突顺序、旧DOM的A来源、原guard、主M选定、逐条新捕获、FIFO、真实domain/work终结等原条件保持。
- 首轮内任何无queued/admitted的SDK工作仍拒绝；终点之后再出现准入许可也拒绝。所有continuation预算、恰好一次放行和关闭后禁止commit仍覆盖全记录。

### B. 准入结束后到关闭的原生观察区间

- 通过**唯一work-start所在区间**决定归属，而不是用完成时间、requestID白名单或“正好这3个”来分配。两个集合不相交；缺start、多start、ID复用、跨界未完成或混入别的reader/epoch均拒绝。
- 每个measure核对唯一work-start、before-capture、domain-start、实际before-commit/guard/terminal及work-finished的顺序和同一归属；本例两条已具备全部证据。
- 每个sample按**实际分支**核对：读取分支的before-read、同次DOM/decision、原terminal及work-finished；缓存分支须有实际cached terminal/reason而非伪造JS。不能要求每个合法sample都有JS，也不能靠补一条通用finished来假装捕获成功。未知/不完整或无法解释的取消/未捕获退出仍拒绝，留证后另查。
- captured=true与真实领域终结必须对应；reader/epoch持续属于本臂，slot/WebView/index按本请求保持；邻章可使用自己的合法身份，不能冒充主章。动态revision/local/anchor按原件保留，不硬套主M的全true条件，不将committed解释为一定做了位置补偿。
- 保留自然并发，不为这些请求伪造queued/admitted、强制FIFO或改变生产执行顺序。即使原字可见，缺terminal、串身份、未结束、遗留gate或关闭后提交仍失败。
- 全部SDK生命周期事件均须落入受控集合、指定S或这些已完整核验的观察集合；领域事件/终结也不能成为孤儿。给返回proof增加观察请求数量/身份和区间说明；`serialDrainVerified`只表示原受控区间，不冒充返程也串行。

成功臂必须同时具备A、B和双向原业务证据。这会替换验收器错误的单一区间假设，并加强对返程完整性的核对；不删除生产guard或放过未登记请求。

## 返程窄屏与失败分支

- 原`pairPredicate`继续代表首轮宽屏、原S/M效果与排空后的联合条件，不覆盖成窄屏结果。
- 成功臂除已有三段phase及原origin一致外，进一步核对passed-wide/passed-narrow**各自原记录**中的最后一个DOM poll：真实预期宽度、有限实际宽度/高度/Range坐标、sameWebView/挂窗/alpha及原valid/visible/widthMatches/accepted。不能只凭名为passed-402的标记或截图授予窄屏通过。
- 无实际窄屏DOM数据、origin被换、错误宽度、原字不可见、缺返程或用宽屏poll冒充窄屏均拒绝；不能为补数据额外读DOM、延后原断言或新开时间窗。
- 真实status65且宽屏原断言失败时，本来可能没有admission-complete及返程：控制持续到closing，沿用原完整准入检查和冲突失败分类，不伪造成功边界/返程，不改变真实65。status0缺admission-complete则不合格。
- 已有结束标记而返程原断言失败时仍保留真实65及失败原件，不能变成安全臂合格或受控H1成功；安全失败仍停止冲突。未解释的所有权/清理失败也不豁免。

关闭始终是整次观察/清理终点。请求缺取消或终结凭据不能因最终集合为空而通过；新诊断取消/迟到分支未命中的缺口不由本工具方案自动消除。

## 下一实施片的本地验证范围

先在不可变原件的副本上验证新验收器：39920796794应明确核出受控集合以及**这3个**完整观察请求，不过滤任何原SDK事件；保留原test0、driver2及旧CI失败事实。输出新增离线审阅结果，不能覆写原result/xcresult、matchedBuildVerified或历史状态。

对应工具正反例至少包括：

- 完整3请求、无后续SDK请求、合法缓存sample、合法并发观察请求；新旧origin与宽窄DOM均绑定。
- 每个请求逐类删除/重复start、capture、guard、terminal、work-finished，captured=false、混入旧epoch/换slot或WebView、孤立领域事件、ID复用、跨终点生命周期：全部拒绝。原件正例必须返回这3个ID，防止实现简单过滤它们。
- 删除/重复/移动admission-complete，提前结束准入、S/M未终结却声明排空、首轮旁路准入、结束后仍有queued/admitted/held、错误或重复放行：拒绝。
- 返程只有phase字符串、删实际poll、替换origin、用宽屏poll冒充窄屏、DOM字不见/宽度不符/未挂窗：拒绝；原S/M混杂及smoke原正反例继续成立。
- 真实宽屏失败65无返程、返程失败65、SDK未退出或关闭后commit、预算超限：失败分类与真实退出保持，安全不合格不能进入冲突。

只运行位置证据工具和同构建配对驱动的现有定向工具组，检查消费者兼容；不跑工具整套、Swift编译或CI。本轮尚未编写/执行这些新正反例。128控制事件、256诊断、32 waiter、原100ms/30秒双向谓词、3秒capture/cleanup及生产3次/32ms采样策略均不变。

## 参考与取舍

[Swift SE-0300](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0300-continuation.md)说明resume只是令任务可再次调度，不能当作主体完成；继续保留每请求真正work-finished和恰好一次放行，不以admitted/released替代终结。该机制Swift5.5已实现，适用于本项目6.1.2。

固定[Swift Async Algorithms1.0.4 GatedSequence](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/GatedSequence.swift)把advance/open与next内等待后产值分开；参考其许可与实际产出分层，保留本项目多请求/多gate及取消规则，不引依赖或照搬其单步模型。现有smoke只提供明确准入区间的项目内先例，本方案另加返程生命周期核验，不把smoke的覆盖范围扩大。

## 本轮保存状态

恢复`build/maintenance/I6-pair-interval-review-20261023/`保存before、只读review-audit、result、文档静态检查和最终私有快照；[持久审阅记录](ValidationLogs/project-isolation-i6-pair-interval-review.json)。619运行输入、2556受保护证据记录、Build30及普通HEAD/index保持，无运行助手遗留。

本轮仅原件/源码审阅和文档静态，不跑Swift语法、工具整套或原生。最新真实结果仍为39920796794：编译0、安全test0/driver2、冲突null；旧1767回退未复现、I6/full191/192/Release/手机缺口保持。方案未实施、未改变任何历史CI结论，不关机。
