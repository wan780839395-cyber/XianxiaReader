# S rejected：被动诊断切片（2026-10-22）

2026-10-22 新S诊断仅一轮CI39793517830/2274ba25/attempt1：原生编译/链接、机制6项及Linux111工具通过；smoke 0/1（10.318秒），失败在M资格。本次S clipTop0/documentTop2367与期望一致，首采样committed，未出现第三次，旧S拒绝原因仍未证。未持有过渡measure和后续native采样改变版本/锚点，held M原恢复guard为false；失败后清理全空。617运行输入/算法/原断言预算保持，未重派，旧full191/192与Release/手机缺口、Build30保持。见[本轮结果](I6_VIEWPORT_S_NATIVE.md)。

以下保留当时范围，不能混同为本轮结果。

只补上轮smoke中已进入S的拒绝诊断；**零CI、未Swift编译、未原生运行，不能写S已经通过或旧故障已修复**。基线fe23d245，上一轮实测源65a82618 / CI39782692503保持原失败结论。定位算法、fixture/Adapter/测试、原断言与全部预算保持。

## 旧证据能进一步确定什么

原始事件仍在build/ci/39782692503和build/maintenance/I6-viewport-smoke-adapter-20261022，未覆盖。S请求68457F71-D05E-4F7B-A5C7-BAF6243184D4在放行后出现同一请求的attempt0、1、2，最后rejected。对照已测代码：for循环中唯一continue位于documentTop不匹配分支，前面所有上下文guard/snapshot为空/移动状态返回均直接结束函数。因此**attempt0和1已取得有效snapshot、通过上下文检查，documentTop不匹配，且原32ms等待正常返回**，才可能进入attempt2。这是旧日志结合控制流的推论，不是本轮新运行结果。

原记录只有scrollY1767/localTop2367，缺clipTop；documentTop=scrollY+clipTop，不能把两者差600直接当成documentTop差600。第三次可能是上下文失效、snapshot不可用，或第三次仍不匹配；现原件不能区分，也不能确定是谁改变DOM滚动值。没有真实resize/M发生，仍未证明旧full视口缩放失败的根因。

控制流判读参考[Swift官方guard/continue/defer说明](https://docs.swift.org/latest/documentation/the-swift-programming-language/controlflow/)及其[公开源码](https://github.com/swiftlang/swift-book/blob/main/TSPL.docc/LanguageGuide/ControlFlow.md)；现有Swift6.1.2语法已支持，无新API。实现复用锁定Readium3.11本地extension的同次evaluateScript结果和已有requestID/事件通道，不引入新SDK接口或依赖。Apple evaluateJavaScript网页本次只返回JS占位，Markdown读取失败，不把未取得的内容当作额外证据。

## 仅这两个采样点改变

`EPUBInfiniteScrollView.firstVisibleElementLocator`：

- 在S暂停前冻结clipTop/clipBottom、viewMinYAtStart、wrapperMinYAtStart、viewportTopAtStart，沿用已有请求身份/版本/原生尺寸。后续DOM记录携带这些请求原值，避免把恢复后的view.frame冒充请求开始时的frame。
- 同一次snapshot await返回后，记录notCancelled、epochMatches、indexMatches、slotMatches、movingMatches、notPositioning、revisionMatches、localMatches、viewportMatches及snapshotAvailable。附currentRevision/currentLocalTop/currentViewMinY，以及真实snapshot.documentTop/documentY、expectedDocumentTop、差值和documentTopMatches。
- **原短路guard继续独立作决定**，没有改成读取诊断字典。各标志是guard前的同步观察；取消可能从其他执行器在观察后到达，所以实际context-invalid分支优先，不能因观察值全true就宣称原guard通过。未增加await、Task或重新读取DOM。
- 每次实际尝试在原迭代退出时由同步defer发一条sample-decision（每请求最多3条）；字段observationPoint=after-snapshot-await、recordingPoint=iteration-exit明确记录点。重试退出记录发生在原32ms等待之后，不能将其序号当作guard评估的瞬时时刻。sample-finished另附最终reason及冻结clip，原outcome不变。

`EPUBSpreadView.continuousVisibleAnchorSnapshot`：继续原位置的metadata回调，从同一次JS已返回的顶层结果提取documentY/documentTop，附visibleTop/visibleBottom、evaluationSucceeded、resultObject、documentYFinite、documentTopFinite、locatorPresent。原JS字符串逐字保持，没有第二次evaluateJavaScript，也没有移动回调或重复Locator解码。

UPSTREAM.json只更新这两个localModifiedFiles摘要，其余来源/版本/哈希清单不变。新字段仅几何、布尔与固定原因，不新增正文或未来章节文本。现有Adapter桥按字典转发，不需要改Adapter、XCTest或控制器。初始slot不就绪guard发生在请求入场前，保持原样；本片针对上一轮已经held的S，不扩大到加载生命周期诊断。

## reason如何读

| reason | 说明 |
| --- | --- |
| cached | 原缓存路径返回，没有DOM尝试 |
| barrier-aborted | 原屏障放行结果为false，outcome保持aborted |
| context-invalid | 原await后上下文guard失败；结合逐项观察值核对，注意取消观察时差 |
| snapshot-unavailable | 原snapshot为空；DOM元数据可区分JS失败、非对象、非有限数值等；Locator JSON/解码仍归此分支，不重新解析来制造更细结论 |
| moving-snapshot-returned | 原moving路径直接返回；不更改它既有outcome标记，smoke S本来要求moving=false |
| document-top-mismatch-retry | 实际走入原不匹配分支且尚有原重试次数 |
| document-top-mismatch-exhausted | 第三次实际走入原不匹配分支，用尽原3次预算 |
| retry-sleep-cancelled / retry-sleep-error | 原32ms等待的实际catch分支；原错误显示与返回保留 |
| committed | 原状态写入路径完成；仍须核原sample-finished outcome |

新诊断不能让rejected转成功：原smoke校验器/committed要求、S/M资格、safe顺序、128事件/32waiter上限、3秒capture和cleanup、原100ms/30秒waitUntil及3次/32ms采样完全保留。可能的事件上限触发仍算失败，不扩大预算或静默丢弃记录。本轮不做几何写入/清缓存/改采样或移动屏障。

## 本轮验证与断点

Windows仓库7类静态及484 Swift语法通过（新增诊断0、保留Vendor54；**不是编译**）。受影响位置证据/来源工具15项：14通过、1 POSIX跳过；没有Swift测试、模拟器、设备Release或手机执行，没有新IPA。最后交付Build30，旧full仍191/192。旧CI Linux111/原生编译只属于旧源，不能算新增诊断已编译。

scope-audit核617运行输入只变两Swift和摘要，其余614保持；原两个文件所有多行JS和await行一致。DEBUG=false投影：Spread逐字一致；Infinite只有guard/catch排版换行，去空白文本一致。此为静态边界证据，不能证明运行时序无扰动。原失败日志、summary、附件摘要均重核一致。实现没有新增测试方法、自动CI或重试入口。

恢复目录build/maintenance/I6-viewport-s-diagnostics-20261022含before、scope-audit、repository-check、tooling-check、最终result/checkpoint；保存源以final-checkpoint为准。普通HEAD/index及Build30交付保持。下一片如获原生单例授权，只检查这些新字段能否区分S最终拒绝分支；若三次documentTop均不匹配，先查准备/滚动同步；若context-invalid查对应身份/取消；若snapshot-unavailable查同次JS/解析。仍不能仅凭一个分支推断DOM写入者。**本轮不派CI，后续执行需新授权。**
