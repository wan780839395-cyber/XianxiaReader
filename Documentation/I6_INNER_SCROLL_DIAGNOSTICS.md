# I6 内层回退被动诊断实现（2026-10-23）

2026-10-23后续唯一原生CI已完成：新增诊断编译/运行通过；安全原单例1/1，但夹具控制区间与验收区间不一致，driver2、冲突null，配对未验收。旧1767未复现，新增取消/迟到分支未命中。见[原生结果](I6_INNER_SCROLL_NATIVE.md)。以下为本地实现当时状态。

按[本地审阅方案](I6_INNER_SCROLL_WRITER_REVIEW.md)实现，基线`3bb3ef43`。本片只做本地检查，零CI，不改定位算法、生产guard、原字断言/预算，不增加等待、重试、屏障或JS执行。**已实现诊断，尚未原生编译/运行；1767写入者、旧full根因和定位修复验收仍未证。**

## 五项运行输入

| 文件 | 本片改动 |
| --- | --- |
| Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBSpreadView.swift | 实例诊断状态、覆盖起止、首次观测回退、inner delegate、通用evaluator提交/回调、关闭/取消记录 |
| Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift | 原首尾progression setter周围5行DEBUG包装，target计算和原赋值保持 |
| Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift | 绑定/身份/早期暂存/清理，原viewport frame/offset写入周围同步记录 |
| Vendor/ReadiumToolkit/UPSTREAM.json | 只更新上述三Swift的localModified摘要，上游baseline/版本/依赖保持 |
| scripts/test_readium_provenance.py | 三项定向来源/时序/生命周期合同检查及负例，保留原五项 |

其余614/619运行输入保持，包括Adapter、FixedSpread签名/透传、原视口用例、fixture协议、CI、smoke与S诊断、JS bundle和既有隔离/定位修复。源代码新增约305行Swift，全部诊断接线和类型在DEBUG中；Release只多两个默认nil的AnyObject存储槽，无诊断访问器/安装器。采用项目已有opaque存储模式，没有为新源码扩大语法基线。

## 记录与身份

同实例coverageID、writerID、evaluationID均为独立UUID；记录reader/epoch/slot/index/WebView固定身份和Swift systemUptime。异步回调不借用TaskLocal猜调用来源，后续槽和邻章不能替代原身份。recentWriter/recentEvaluation只是最近记录的候选，**不是写入因果证明**。

- `sample-read-inner-coverage-start/end`：绑定时当前native几何、导航/初始化状态，preBindingCommandsCovered=false；结束时reason、pending evaluation数量/至多16个ID、截断标记、writer数量和容量缺口。构造器已调用loadSpread，绑定前命令仍不在完整覆盖承诺中。
- `offset`和其他既有同步观察点：inner X/Y、spread/web frameY、scroll bounds、contentSize、contentInset/adjustedInset、zoom、attached/dragging/decelerating/tracking/scrollEnabled和layerHasAnimations。layer动画标记不能冒充UIScrollView滚动状态。
- `first-rollback`：同coverage第一次相邻观测Y下降超过0.5，保存前值/前次时间、本次值/时间、触发观察点和一次至多16帧、每帧160字符的栈；去除地址和路径。后续变化仍有普通数值记录。它可能发生在初始化期间，不保证恰好是旧0.383秒窗口的回退，也不是每次setter审计。
- `writer-before/after`及`viewport-frame-applied`：原native首尾setter和viewport同步范围，记录target和实际前后几何。同步writer上下文用defer退栈，不跨await；frame之后、原offset判断之前单独记录，保留原差值条件和原setter。
- `evaluation-enter/submit/callback`：既有evaluator加载await前进入、原guard后实际WK提交、原完成回调。保存形状分类及脚本等值摘要，不保存script/正文/locator/selector。分类为canonical、Readium locator/id/progression、window by/to、CSS、range-read或other，不解释JS计算target。既有S的requestID/attempt和原回调诊断原样保留，原JS及唯一continuation成功/失败恢复不变。
- `evaluation-cancelled-before-submit`：只在原加载await/guard未走到提交时由defer记录，并附当前task取消标记；提交后的回调保持真实error/success，不能把回调所在任务状态当原请求取消状态。

所有新增事件均使用原`sample-read-`路由，进入原独立256条journal，不占128条控制事件。未添加Task、DOM查询、layoutIfNeeded、额外JS、私有API、滚动修正或重新采样。

## 覆盖开始、早期记录与预算

接线核实发现原fixture在armed前忽略诊断。若直接发送coverage-start及初始JS回执会丢失。因此在Infinite实例里暂存最多255条元数据，额外保留1条交付状态位置；不修改fixture协议/armed条件/预算。既有test-auxiliary/original-capture入口发生在原armSample之后，首次进入时同步交付状态及暂存事件，再切为实时投递。普通native预布防采样不触发排出。

交付状态含buffered、preArmDropped、incomplete和deliverySource。暂存溢出显式累计丢弃，不能解读为完整观测；交付仍经过原journal的256上限及既有丢弃计数。journal序号/afterEventSequence是**交付时**顺序，暂存记录的实际顺序以各自Swift uptime和固定身份判断，不能据交付序号推断原先控制事件发生顺序。

该排出触发依赖本例现有入口/布防顺序，不承诺任意外部controller都会先arm。没有发生该入口的未布防结束不构成完整覆盖。coverage-start太晚、任一丢弃/容量缺口、pending或身份不符都必须留作观测缺口，不能调大预算来换“完整”。

## 取消、替换与关闭

- slot构造返回后、原go/后续await之前同步绑定；后装fixture也绑定已有slots，同一fixture重复设置不重建覆盖。
- clear先解除诊断状态并失效coverage，再沿原路径改变epoch/取消/释放；evict在原task cancel前结束该slot诊断。替换fixture先结束旧覆盖并清空旧暂存，再绑定新controller。没有改变原取消/放行/排空实现。
- sink弱持有owner、slot及原controller；诊断状态弱持有spread。结束时清空evaluation、writer、前值和弱view。旧WK completion只捕获原诊断状态，不延长WebView生命。
- 关闭后只允许至多一条合并的late callback/late-before-submit回执，携带旧coverage/请求和closed标记；仅投递给捕获的旧controller，不能进入新controller/slot或新暂存队列。coverage-end已列出当时pending项，不能把一条late回执当作全部pending逐条终结。
- repeated clear/evict/fixture移除保持幂等；诊断容量上限（writer嵌套16、在途evaluation256）只影响记录，显式标记缺口，不截断业务执行。原active/tasks/waiters/queued/running五类清理验收仍须原生用例确认，本轮未执行。

## 本地检查与限制

最终provenance **8/8**，包括原FixedSpread签名合同；Swift语法**484份通过，保留54项上游限制，新增0**；七类仓库静态通过。没有重跑Python整套、原生单例、配对、full、Release或设备，没有新IPA。

精确源码对照：除两个未使用的nil存储声明外，三Swift的DEBUG=false源码与基线一致；全部嵌入多行JS、await调用序列一致。定向合同另核实际提交在原加载await/guard之后、原S observer顺序保持、成功/失败仅原两处分支恢复continuation，以及弱身份/关闭先失效/有界暂存等。**这些是来源和语法检查，不是Swift类型编译或真实取消/首次回退验收。**

首轮原件保留：语法工具不支持新增class成员内#if DEBUG写法，改用既有opaque模式消除错误而未新增豁免；负例原先选return true，未必存在于Release分支，两次检查暴露后改为实际存在的guard变异，未降低正例合同。检查包装器首次输出遇Windows编码错误，子进程真实失败码和原始日志已保存，修正的只是忽略目录内输出编码。最终仅补受影响检查，Swift通过后Python负例改动没有触及Swift，复用该次语法结果。

恢复`build/maintenance/I6-inner-scroll-diagnostics-20261023/`保存before、baseline源码、首轮/修正版检查原件、source-contract-audit、frozen/result和最终私有快照；[持久记录](ValidationLogs/project-isolation-i6-inner-scroll-diagnostics.json)。保护旧2404条证据记录、Build30与普通HEAD/index，不清理旧原件，不关机。

本片完成本地诊断实现与检查。下一步若获单例原生授权，先核coverage-start/交付/零丢弃及实际首次回退/原生writer/evaluator链，再依[判读表](I6_INNER_SCROLL_WRITER_REVIEW.md)区分原因；保持原安全失败即停止、冲突未启动/null、真实退出码，不自动重派。最新真实原生结果仍是39912011242：编译0、安全65/冲突null；旧full191/192、I6/Release/手机缺口保持。
