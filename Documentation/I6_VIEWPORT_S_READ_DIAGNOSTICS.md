# I6 辅助 S 关联诊断本地实现（2026-10-23）

按[读取时序审阅](I6_VIEWPORT_S_READ_REVIEW.md)补齐被动观测。**实现与本地检查完成，尚未 Swift 编译或原生验证，也没有取得新的真实 S 读数。**本片不解释为1767根因已证或定位故障已修。

只改变三份 Swift 与必需 Vendor 摘要登记，共4项运行输入；原619项中的615项保持。未改 Adapter、CI、依赖、原测试选择、定位算法、生产 guard、原字可见断言、时间预算、固定三次采样或32ms原重采样间隔。没有新增 await 挂起点、Task、等待、重试、DOM查询或滚动赋值。

## 观测接线

| 文件 | 本片职责 |
| --- | --- |
| `Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBSpreadView.swift` | 给既有 evaluator/snapshot 增加默认nil观察闭包；只在 DEBUG 执行记录。实际 WK 提交、完成回调、同一次 JS 内布局读取前后状态 |
| `Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift` | 同 requestID/attempt 的活跃关联、snapshot返回、实时native状态；既有updateViewports三调用来源及frame/offset写入前后记录 |
| `Tests/iOS/ReaderRenderingTests.swift` | 配对模式独立256条诊断缓冲及附加payload；保留原128条控制事件与所有准入/屏障/判定/清理逻辑；新增同步journal机制检查，仅由配对机制入口调用 |
| `Vendor/ReadiumToolkit/UPSTREAM.json` | 仅更新两份Swift的实际LF源码摘要；版本、原始基线和语法限制登记不变 |

启用条件同时要求 DEBUG、进程已有 `XIANXIA_VIEWPORT_FIXTURE=paired-safe/paired-conflict` 和当前实例安装fixture。没有新增运行模式/环境输入。smoke与默认nil路径不创建关联表、不生成新观测事件，不执行新增JS读数。Release只保留nil关联字典槽与默认nil参数，记录器/关联操作均在DEBUG；没有新的调度层。

## 一次采样的关联字段

| 记录 | 精确位置与数据 |
| --- | --- |
| `sample-read-js-submit` | 既有`spreadLoaded()` await和清理/取消guard之后，在实际`webView.evaluateJavaScript`之前。记录Swift uptime、inner native offset、spread frame.minY、WebView宽高、attached/cleared |
| `sample-read-js-callback` | 原WK completion内部、原错误/成功continuation恢复之前。相同native字段，加evaluationSucceeded/resultObject；若weak self已失效，明确nativeAvailable=0，不伪造innerY |
| 原`sample-dom`附加字段 | 同一JS在任何find/caret/rect布局读取前捕获`scrollY/performance.now()`，返回对象增加readStartScrollY/readStartNow/readEndScrollY/readEndNow；不执行第二次JS或复制正文。无可用rect时原业务仍返回null，不为诊断改变返回形状 |
| `sample-read-snapshot-returned` | 原snapshot await返回后立即同步记录，位于原guard诊断及生产判定之前 |

所有新增读取事件沿用原requestID、attempt与冻结请求context，同时以`live.*`标记观测时的native字段、当前锚点指纹和slotCurrent。`read.*`为实际WK提交/回调处数据，`observerUptime`为上层接收观测的时刻，二者不混用。旧冻结`anchor`保留原含义，不作为实时缓存指纹。

Swift uptime只在Swift侧排序；JS的performance.now只在同一脚本内排序，不能直接跨时钟相减。提交回执不等于JS已经开始执行，完成一次2367也不等于之后视口持续同步。

## 既有同步写入的来源

`updateViewports(source:)`三调用点明确标记`load-ready`、`layout-slots`、`scroll-delegate`。计算local、设置spread frame、原offset差值>0.5判断和原赋值顺序保持。

每次`viewport-sync`包含writerID、开始/结束uptime、目标local、frame设置前innerY/frameY、frame设置后且原offset赋值前的innerY、最终innerY/frameY和原条件是否实际赋值。这样能区分frame设置引起的变化与显式contentOffset赋值；未赋值的同步调用也保留记录。

同一WebView正在捕获/持有/读取的请求按requestID关联；循环开始前标为before-loop，其后带实际attempt。一个写入可能关联多个请求，不把观察者当写入发起者。没有活跃采样时使用独立记录ID并标`associatedRead=false`，仍可按时间核对+600写入。关联在函数defer移除，clear时置nil；不参与任何guard或准入决策。

本片没有覆盖go/canonical JS/系统内部的全部滚动写入。找不到本同步点回执不能证明没有其他写入，也不能直接归咎WebKit。读取几何与同步记录本身可能影响时序，后续带诊断样本通过仍不等于旧因已修。

## 独立缓冲与清理

`sample-read-*`和`viewport-sync`先进入独立诊断分支并返回，绝不更新active/finished/dom/guards、entry队列或原sequence，不触发原event-overflow。只在配对且armed时保存，关闭后到达的回调可补记，但不会重新打开/提交或改变清理。

配对payload新增`readDiagnostics`、`readDiagnosticsTotal`、`readDiagnosticsDropped`。保留最近256条，满后丢最旧并累计计数；每条有独立diagnosticSequence及afterEventSequence。只要dropped>0，就不能用记录缺失证明没有更早写入。原smoke的payload与128条事件上限保持。现有原件、失败退出、安全失败停止和清理预算均保持。

新增同步Swift机制检查覆盖smoke忽略新事件、257条诊断不会占原事件/请求状态、旧条目丢弃可见，以及关闭后晚回调不污染清理。该段源码尚未原生编译/执行，不能与已执行的本地Python/Node检查混记。

## 本地验证与实际限制

| 检查 | 结果与边界 |
| --- | --- |
| 源码合同审计 | 原视口单例完整源码字节相同；原guard/循环/间隔与事件上限保持；smoke和Release实际提取JS字节相同；无新挂起点。对诊断默认参数、nil槽和来源标签归一后，Release控制流与原件一致，不宣称新二进制相同 |
| 仓库语法/静态 | 484 Swift语法通过，原54项Readium语法限制保留，新增0；七类静态通过。这不是Swift编译 |
| 4项既有Python工具 | smoke真实门槛/清理、单例路由、双臂真实退出及干扰拒绝定向检查全部通过；未跑工具整套 |
| 4组Node离线样本 | 执行实际提取JS及有界DOM stub：1767/2367稳定及布局中变化，原业务返回保持，无sampler写入；能记录2367→1767。不是WKWebView或真实故障复现 |
| 4项附加回执正反例 | 两模式均接受附加诊断字段；移除真实S终结后，即使诊断journal放入伪装的committed终结也仍拒绝。全部是合成输入，不冒充原生回执 |
| 编译/原生/full/Release/设备 | 本轮全部未执行，零CI。新Swift闭包/机制仍待原生编译和真实采样；旧安全65/冲突null、full191/192及I6/手机缺口保持，无新IPA |

首次本地语法检查在类内新增DEBUG声明处产生额外ERROR。已保留候选源码与诊断，改用项目既有文件级DEBUG extension模式后通过；未增加语法例外或修改基线。中间一次独立解析命令漏加载已有check-deps路径，保留工具错误；不是源码编译失败。私有快照对照使用before文件及独立索引，不将普通索引未跟踪Vendor显示的删除当成源码删除。

参考[固定Readium3.11 evaluator](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift)和[Apple WK脚本接口](https://developer.apple.com/documentation/webkit/wkwebview/evaluatejavascript(_:completionhandler:))，保持原加载等待、原WK调用及原continuation顺序，仅在相邻同步位置观察。没有引用其他版本补丁或更换API。

## 保存与下一边界

恢复目录`build/maintenance/I6-viewport-s-read-diagnostics-20261023/`保留before/四文件原件、首次语法候选/诊断、精确源码差异、source-audit、实际提取JS、所有检查的命令/原退出/完整输出、result及最终私有快照；[持久验证记录](ValidationLogs/project-isolation-i6-viewport-s-read-diagnostics.json)。1211项受保护原件、Build30与普通HEAD/index保持，不关机。

后续若获新授权，最小原生门槛仍是一次构建及原同例配对：安全全部合格才运行冲突，保留两臂真实退出；若S仍失败，先保留当前关联诊断查写入，不扩大整套或自动重派。本轮未派发，不授予新原生/发布验收。
