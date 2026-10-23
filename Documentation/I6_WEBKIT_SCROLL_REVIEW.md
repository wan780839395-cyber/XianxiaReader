# I6 WebKit回写与先行native采样审阅（2026-10-23）

本片仅审阅39930462353原件、官方和固定版本源码，明确最小补证；没有实现夹具或修改619运行输入，没有CI、编译或新原生执行。保留隔离、定位修复、S诊断、smoke、返程窄屏、原字双向断言、原guard和全部预算。

## 本轮结论

首要候选是：先前导航产生的旧滚动目标在native已+600之后，经WebKit滚动树事务较晚应用。它能解释0→1767→2367→1767与回调时序，但还不是已证根因。不能把当时正在运行的native range-read、最近writer ID或WebKit入口直接当成发起者。

最值得补的缺口是**已有导航JS实际执行时请求了什么数值、何种behavior，以及它对应哪次提交**。只加更长等待、重复自然重放、再记录一个最近ID，都不能补齐这个缺口。

## 官方资料、版本与成熟实现

| 已核资料 | 可用于本案的事实与限制 |
| --- | --- |
| [Apple Safari18.5说明](https://developer.apple.com/documentation/safari-release-notes/safari-18_5-release-notes) | 18.5版本族为20621.2.5，可用于iOS18.5。原件模拟器为18.5/22F77；没有实际WebKit framework完整版本，不能仅据OS或macOS版本匹配精确源码。 |
| [Apple evaluateJavaScript合同](https://developer.apple.com/documentation/webkit/wkwebview/evaluatejavascript(_:completionhandler:)) | 回调代表JS求值完成，回调在主线程；这里不能将它扩张成所有滚动树提交已应用的屏障。下面的实际native读数也否定了这种假定。 |
| [WebKit发布tag](https://github.com/WebKit/WebKit/tree/WebKit-7621.2.5.11.1) | 官方tag对象解析为固定commit `e725732395be8ec3e8fd4d77704b807025ff62ff`，属621.2.5同代。用于路径审阅，不冒充22F77的精确二进制匹配。主分支已有四参数方法，不能套替本例三参数入口。 |
| [滚动树事务应用点](https://github.com/WebKit/WebKit/blob/e725732395be8ec3e8fd4d77704b807025ff62ff/Source/WebKit/UIProcess/RemoteLayerTree/RemoteLayerTreeDrawingAreaProxy.mm#L367) | 事务更新视图后处理requestedScroll，再调用页面requestScroll。说明这类应用可以与调用JS的时点分开；源码没有把请求与我们的evaluationID关联。 |
| [root请求暂存](https://github.com/WebKit/WebKit/blob/e725732395be8ec3e8fd4d77704b807025ff62ff/Source/WebKit/UIProcess/RemoteLayerTree/RemoteScrollingCoordinatorProxy.cpp#L95) | 提交scrolling state时收集root请求并取出；不是把最后一条应用writer直接当作来源。 |
| [PageClient转发](https://github.com/WebKit/WebKit/blob/e725732395be8ec3e8fd4d77704b807025ff62ff/Source/WebKit/UIProcess/ios/PageClientImplIOS.mm#L109)与[WK应用offset](https://github.com/WebKit/WebKit/blob/e725732395be8ec3e8fd4d77704b807025ff62ff/Source/WebKit/UIProcess/API/ios/WKWebViewIOS.mm#L1582) | 请求经三参数入口做坐标/缩放/inset转换和有效范围限制，最终设置native offset。可以解释已捕获栈；不能据栈推断原request参数、JS发起者或WebKit缺陷。 |
| [Readium3.11原导航](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift#L315)及[JS实现](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/Assets/Static/scripts/readium-reflowable.js) | 普通progression首尾可原生写offset，其余通过Readium JS导航。固定bundle的共同helper最终调用根元素scrollTo，参数来自上游计算。不能说成熟实现全面禁止native写入；本项目外层无限流/原字定位是本地扩展，不在3.11基线内，不能照搬普通scroll模式的验收结论。 |

引用的release源码、tag对象和SHA256保存在恢复目录references。曾按错误文件名取RemoteScrollingCoordinator时返回404，已保留记录并改查官方目录；最终用于判读的是成功取得的UIProcess RemoteLayerTree源码，不使用404或第三方搜索摘要作证。没有升级依赖或抄入平台私有API。

## 原件重新核出的时间线

| native systemUptime | 真实记录 |
| --- | --- |
| 1685.334739735→.346662479 | readium-id `85FE563F`实际提交/回调，inner仍0 |
| 1685.350054439→.368600061 | readium-locator `B182EA7E`实际提交/回调，inner仍0 |
| 1685.439862897→.482704597 | viewport-scroll-delegate明确写1767，inner从0到1767；不能把它倒称为78ms回退的writer |
| 1685.823874697→.825166393 | 同步原+600，inner1767→2367；layout-slots随后前后均2367 |
| 1685.873001697 | native样本`4485E689`的range-read `8AE2F005`实际提交，inner2367 |
| 1685.951182483 | 首次观测inner1767，原16帧栈止于WK滚动入口，currentWriterID=none；最近2367后78.181ms |
| 1686.850879142 | 上述native样本回调时inner已1767，但同次DOM结果documentTop仍2367；原外层localTop2367，原条件遂提交A |
| 控制seq14–18 | original-capture走cached，不是又发一次JS；不能把native与original-capture混为同一请求 |
| 控制seq21以后 | S实际三次读取1767，对期望2367差-600，九项上下文guard全真，最终被documentTop条件拒绝；没有主M/resize/返程 |

离线按原FNV64算法核对两个已知tagID脚本候选：`long-paragraph`且animated=false的候选与真实`fcbe0292d4725d85`匹配，true候选不匹配。这只是固定候选的非密码指纹核对；不能反推出未知locator JSON、目标数值或另一次导航的animated参数。它降低了“第一条tagID平滑动画未结束”这一具体猜测的优先级，不排除其他滚动请求。

## 候选排序

1. **旧导航目标/滚动树事务较晚应用**：有两次较早导航提交与回调、有先前位置1767、有发布源码应用链。缺实际JS target/behavior及平台事务身份，优先补这部分。
2. **布局、样式、焦点或其他未覆盖路径产生新的root请求**：range-read会查询DOM/几何，本身原脚本没有显式滚动赋值；不能以“只读”证明不会推动先前事务提交，也不能以时间靠近认定它主动请求1767。尚无发起证据，保留候选。
3. **已覆盖应用native再次明确写1767**：78ms内没有对应writer before/after；最近应用writer前后均2367，不支持将其认定为本次写入者。绑定前命令仍未完整覆盖，不能宣布全部应用路径已排除。
4. **仅尺寸裁剪/手势导致**：本次宽402、高778、contentHeight8334、zoom1、inset0，两值均在正常范围，且无拖动/减速/layer动画标记。该观测不支持简单裁剪解释，但不因此证明内部request参数或排除JS平滑滚动。

## 最小补证方案：建议3个运行输入

下一片建议只涉及：

1. `Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBSpreadView.swift`：既有DEBUG evaluator和内层诊断内的观察/解包、公开框架版本、上游栈来源标签。
2. `Vendor/ReadiumToolkit/UPSTREAM.json`：仅该源码摘要和说明。
3. `scripts/test_readium_provenance.py`：对应本地源码合同及JS语义正反例。

不改minified/release JS资产、Reflowable/FixedSpread override签名、Adapter、测试阶段或CI驱动。选择临时根元素自身方法观察，是为了直接看到成熟Readium helper最终交给浏览器的数值，而不是复制target公式猜目标；原型/window-wide拦截、私有API和新DOM滚动均不在方案内。

### 观察范围与转发合同

- 仅原配对诊断实例、原owner/epoch/WebView和严格识别的**现有Readium导航表达式**（id/locator/progression）；不能只凭contains标签包裹任意脚本。range-read、S、M、canonical及其他脚本不包裹，已知trace只有前两种writer。nil/Release必须传入原脚本原字节。
- 仍是原spreadLoaded await、原取消guard之后的一次WK求值；不加WK调用、Task、rAF、sleep、await、重试或新许可点。原callback发布与continuation恢复顺序保留。
- 在这次已知同步表达式运行期间，保存根元素自身scrollTo的原属性描述符，临时观察该**实例**的调用；原函数以原this和原arguments调用恰好一次。记录真实left/top/behavior、调用前后scrollTop/scrollY、同文档performance.now及同次evaluationID；不拷贝Locator/正文或整段脚本。仅识别本版本helper生成的普通数据参数，额外读数不能重复触发getter或强制转换；自定义accessor/未知重载记覆盖不完整并仍执行原调用。
- 原结果仍按原类型返回；原错误仍走原失败路径，不吞掉或改成成功。finally恢复原描述符；原本没有自有属性时删除本次自有属性，不能把继承方法永久盖住。已知helper是同步调用；未知/thenable表达式不扩展为等待。
- 回执随同一次WK结果到达，由已有回调解出诊断并还原原业务结果，加入既有256条独立journal，不占128条控制账本。每个实际调用须有before/after或throw分支；只保留有界记录，超量、无调用、无法恢复或无法解包均明确incomplete，不伪造命中。
- 如果根节点变换、方法不是可观察的原函数、自有属性不允许恢复，保持原表达式原执行并记覆盖不完整；不能为了诊断改写原页面行为。必须区分“原函数未调用/原业务返回false”和“观察失败”，不能假造请求target。

这是测试干预，会增加同步观察成本和JS栈层级；不能称零干预或承诺所有WK错误元数据逐字不变。这里的硬合同是原调用/参数/结果/失败语义及恢复，不是把新样本冒充完全未观察的自然运行。若本地做不到，就退回设计，不补等待来换绿。

### 框架身份、上游路径和清理

- 在既有coverage-start事件读取公开Bundle(for: WKWebView.self)的版本字段及既有OS信息；不存在则记unknown，不据版本族猜精确patch。
- 首个回退仍保留原16帧stack。利用同一次Thread.callStackSymbols观测，另外只给有界来源标签：是否见到滚动树事务提交、WebPageProxy/PageClient requestScroll；缺符号或被内联时unknown，不能仅由入口强填来源。只读符号，不调用或替换私有方法，不增加原stack条数/事件容量。
- JS本地finally负责同步属性恢复；没有持久全局hook或跨await的“当前来源”。Swift回调固定捕获旧evaluation/epoch，关闭/换slot后只进原有失效处理，不写新controller；文档/进程丢弃与晚到回执也必须明确覆盖边界，不增加关闭等待。
- 原128控制、256诊断、32 waiter、16栈帧、3次/32ms采样、100ms/30秒可见条件和3秒capture/cleanup保持。smoke和返程窄屏/原字双向断言继续原路径。

### 本地验证与结果判读

实施后先做本地检查，不先派CI：

- 原函数仅调用一次，this/同一options对象和参数列表、true/false/undefined结果、抛错失败语义保持；有/无自有属性、原描述符和嵌套调用均恢复；不可配置属性/根变换/超量给incomplete。
- nil/Release脚本字节不变；观察只覆盖允许的导航表达式，不能误包S/M或正文中恰好出现的函数名；原override/原await/取消/结果发布顺序保持。
- 包装回执不能替代真实SDK终结；错owner/epoch、重复/迟到、缺前后点、无法解包、restore失败不授予合格。预算与原控制、双向DOM正反例继续成立。JS运行时不可用就记录未执行，不以源码断言冒充语义测试。
- 只有上述透明性检查合格、方案仍在3输入内，才另等用户授权一轮原生同例。当前没有该授权，也不派CI。

| 将来取得的结果 | 可以怎样判断 |
| --- | --- |
| 某次已知导航真实target1767、非平滑，求值已回调后才出现事务回写栈 | 更支持旧请求较晚应用；仍无平台IPC ID，不能直接绑定某一事务或宣布旧full根因已证 |
| +600以后又有已覆盖导航真实请求1767 | 缩小到这次应用导航调用条件，保留原件再审阅；不现场改算法 |
| 所有已覆盖导航均无1767而回退仍出现 | 不能宣称WebKit缺陷；先看incomplete、绑定前和其他未覆盖路径，不扩大为全局hook |
| 包装未命中/恢复失败/预算溢出 | 夹具未合格，不评价业务结果，不豁免原guard |
| 新同例未回退 | 仅证明本轮回执/编译等实际达到项；不是根因修复，不自动自然重放 |

## 保存与验收边界

[持久审阅记录](ValidationLogs/project-isolation-i6-webkit-scroll-review.json)。恢复`build/maintenance/I6-webkit-scroll-review-20261023/`保留before、原件审阅、引用及哈希/tag对象、候选摘要核对、result/文档静态与最终快照。619运行输入、3699旧证据记录、Build30和普通HEAD/index保持，AGENTS已有文字变化不覆盖。

本片没有实现上述观察器或执行其正反例，仅做文档静态；没有Swift语法、编译、工具整套、原生/full/设备Release/IPA。真实结果仍39930462353编译0、安全/driver65、冲突null；返程未到达、I6/full191/192/Release/手机缺口保持，不关机。
