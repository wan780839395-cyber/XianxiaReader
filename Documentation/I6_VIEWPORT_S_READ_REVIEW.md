# I6 辅助 S 读取时序本地审阅（2026-10-23）

后续已按本方案完成[S关联诊断的本地实现与检查](I6_VIEWPORT_S_READ_DIAGNOSTICS.md)，零CI；真实WK/编译仍未验证，具体写入者尚未证。以下保留审阅时结论。

本片只审阅 [39895434704](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39895434704) 的安全臂及其冻结源码 `eb7b46628905797e15b1bc3115c77de7dd20e1ac`。**已查清 S 为什么不会自动复用后来提交的 2367 锚点；尚未查清新执行的 JS 为什么又连续报告 1767。**不将这个证据缺口写成定位算法根因已证。

零 CI、零运行输入改动；不增加探针、等待、重试，不调整算法、生产 guard、原字可见断言或预算。原 smoke、配对模式、隔离、定位修复与 S 诊断保留。原生 0/1、安全原退出 65、冲突 null 的旧结果保持，未获得新的原生通过证据。

## 同一请求中，哪些值先捕获，哪些值后读取

| 阶段 | 源码与实际行为 |
| --- | --- |
| 捕获入口 | `EPUBInfiniteScrollView.swift:717` 先经过捕获前统一准入，再取得 slot；没有提前读取 DOM 快照 |
| 请求输入 | 742–776 捕获 clipTop、clipBottom、epoch/index/revision、localTop、moving；诊断 context 同时冻结，其中 anchor 字段也是当时的指纹 |
| 缓存检查 | 778–785 只检查一次 `savedAnchorMatchesViewport`；命中就返回，不会到读取屏障。本次 S 已越过此检查 |
| 读取屏障 | 788–792 的 `sample-before-read` 先挂起；此时尚未构造/提交本次 DOM 读取 |
| 每次采样 | 796–805 的固定三次循环，每次重新调用 `continuousVisibleAnchorSnapshot`；冻结的是请求输入，不是 JS 返回值 |
| 实际 JS 提交 | `EPUBSpreadView.swift:629–747` 每次构造脚本；254–270 的 evaluator 先 await `spreadLoaded()`，核对清理/取消，再直接调用该 WebView 的 `evaluateJavaScript`，无返回值缓存 |
| 完成与判定 | 同一 JS 对象包含 documentTop、documentY 与诊断 scrollY；返回后先诊断，再由原 guard 判定，失败时只执行原有有界重采样 |

`spreadLoaded()` 的已加载分支直接返回，未加载分支才等待 continuation；不能把这个加载屏障当作 DOM 视口同步保证。`WebView` 子类没有覆盖 JS evaluator，`test-auxiliary` 的 TaskLocal 只进入诊断 source 字段，不切换另一套读数算法。

## 33 条原始事件与源码可以共同证明什么

| 顺序 | 观测及其含义 |
| --- | --- |
| 1–5 | 辅助 S 的 native localTop=2367、clipTop=0、revision=2，缓存指纹还是 `87718199b4c850a3`；在读取前持有 |
| 6–15 | 另一个 native 请求独立执行：首次 DOM=1767，第二次 DOM=2367，提交锚点 A，指纹变为 `6f417c8a0ff9e69e` |
| 16–21 | original-capture 命中 A 的缓存并完成，随后统一准入开启；这一 capture 没有再读 DOM，也不能用它证明此时 DOM 仍是 2367 |
| 22–23 | pair-sealed 后放行 S，未执行 resize。S 从缓存检查之后继续，不重新检查后来更新的 A |
| 24–29 | S 的三次新执行均返回 scrollY/documentTop=1767；clipTop=0，期望2367，差值-600。三次快照可用，九项上下文条件全 true，documentTopMatches=false |
| 30–33 | S 以 `document-top-mismatch-exhausted` rejected；终结事件的实时锚点仍是 A，并未被旧读数覆盖。安全资格失败后关闭，取消清理集合全空 |

这里有两个独立事实：缓存 A 已成功保存；后续 S 的新 DOM 读数没有达到原资格。**“native 采样曾读到 2367”不能替代 S 自身的成功终结，也不能证明之后页面一直停在 2367。**旧 `sample-dom`/`sample-decision` 中 anchor 字段来自冻结 context，不能把旧指纹误读成实际缓存被写回。

S 的首次 JS 提交在放行之后；native 的 2367 完成回执在放行之前。因而不能仅用“屏障前已读旧值、之后才返回”或“这两次回调乱序”解释这组事件。已记录的是同一 WebView 先后返回了不同视口值，不是屏障重放旧 JS 结果。

## 候选写入与排除边界

| 路径 | 静态审阅结果 | 原件的证明边界 |
| --- | --- | --- |
| `updateViewports()`，InfiniteScrollView:640–649 | 按 outer/wrapper 算 local，设置 spread frame；inner native offset 与 local 差 >0.5 才赋值 | 这是主要同步写入点；原诊断未记录其每次写入前后值，也未记录 JS 提交瞬间 inner native offset，不能指定某次写回1767 |
| 布局/测量/外层滚动 | `layoutSlots`、`measure` 与 scroll delegate 可以改变外层布局/offset，继而调用上述同步点 | S 的 revision/local/slot guard 均成立，不等于内层 offset 或 WebKit 进程视口没有变化。没有 pair-resize/主 M 不能外推为整个系统没有布局回调 |
| go/初始化、fragment/progression、canonical `window.scrollTo` | 这些路径有显式定位写入；本例目标资源初始化早已完成，持有至拒绝事件未见导航/重新加载/更换 slot | 不能凭无导航事件证明所有已经提交的 WebKit 滚动影响都已落定；现有日志没有关联最后一次执行写入者 |
| fixture seal/release/original capture | seal/release 只管理准入与 continuation；capture 保存 Locator，不显式修改页面 offset；自动滚动已停止，对应 pause/flush 在这里不执行滚动 | 已排除这几处代码直接写1767；不据此排除唤醒后布局或进程提交的间接影响 |
| DOM sampler | caret/range/rect 与 scrollY 读取，无显式 scrollTo/contentOffset 写入；S 数值来自同一返回对象 | 布局读取可能触发布局，不能仅凭“无显式赋值”断言它绝无 WebKit 视口副作用；当前证据也不能认定它就是原因 |

因此已排除：S 屏障前 DOM 快照重放、三次循环复用单个 JS 返回值、TaskLocal 注入不同读数、clipTop 造成的600差值、跨 slot/epoch/revision 的明显过期接收、诊断混用第二次 DOM 查询，以及 S 旧结果覆盖 A。

尚不能区分：inner native offset 曾变化；已提交的滚动/布局在 WebKit 内部稍后生效；DOM 读取触发布局后产生变化；其他未带写入回执的路径。不能把任一候选升级为已证根因，也不能将本次 S 资格失败追认为历史 full 连续缩放故障的根因。

## 对照适用版本的资料

- [Readium Swift Toolkit 3.11.0 EPUBSpreadView](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift)：固定版本使用加载等待、WK 执行与 continuation 返回的包装，没有返回值缓存。本项目 UPSTREAM.json 锁定3.11.0/revision `d82f44f4f05d87add9e22a8b75abbd61dce745dd`；本地另有关闭/取消 guard，连续采样与屏障属于本项目补丁，上游不能直接证明其正确性。
- [Apple evaluateJavaScript API](https://developer.apple.com/documentation/webkit/wkwebview/evaluatejavascript(_:completionhandler:))：只用于核对脚本执行/结果回调接口，不将一次完成回调解释为后续 native/DOM 视口持续同步的保证，也未据此认定某个 iOS WebKit 缺陷。

没有升级依赖、照搬其他版本 workaround 或修改定位算法。

## 下一项能区分原因的最小证据（仅建议，未实施）

若后续继续，先做受配对诊断开关限定的被动观测，预计最多三份运行输入：`EPUBInfiniteScrollView.swift`、`EPUBSpreadView.swift`、`ReaderRenderingTests.swift`。不改 Adapter/CI，不加新屏障或等待，不为让安全臂通过重查缓存、改采样条件或注入滚动。

1. 用原 requestID/attempt 串联实际 `evaluateJavaScript` 提交、完成回调、snapshot await 返回；Swift 使用同一单调时钟，并记录同一 WebView 的 inner native offset、local/revision 与当前锚点指纹。提交记录必须在现有 `spreadLoaded` 之后、实际 WK 调用之前，不能只在外层调用之前记一次。
2. 在原有同一次 JS 中记录布局/caret 读取前后的 scrollY 与 JS 自身单调时间；不添加第二次 DOM 调用，不复制正文。JS 时间只用于本次脚本内部排序，不直接与 Swift uptime 相减。新增读取也可能有观察影响，结果只支持带诊断的样本。
3. 给既有 `updateViewports` 同步点记录目标 local、赋值前/后 inner offset、调用来源及当前 request 关联；只观察，不新增/强制一次赋值。未覆盖的 go/JS 写入仍明确标为证据缺口，不能凭“没有这条回执”断言没有任何写入。

判读保持分层：若 native offset 及明确写入回执回到1767，追该写入来源；若 native 始终2367而同一 JS 起止不同，优先查读取/布局之间的变化；若 JS 起止都1767且 native2367，只能确认跨层不一致，再查未完成的滚动/提交，不能直接选一种修复。若本次恢复正常，仅为带新观测的样本通过，不宣称旧因已修。不自动派 CI或自然重放。

## 本片验证与恢复

恢复目录 `build/maintenance/I6-viewport-s-read-review-20261023/` 保存 before、33事件审阅与源码顺序核验、result、文档检查和最终本地私有快照。619项运行输入、1201项受保护原件、Build30及普通HEAD/index逐项复核；只修改项目文档。

本地原件中另有不透明 xcresult Data blob。限定检查只保存格式/大小头信息；一次256MiB内存上限解码被拒绝，随后只流式读首4096字节确认非普通tar，不扩展为私有格式解码工程，也不把未解码内容写成“没有日志”。未展开或写入大副本，原件保持。

本地33事件/源码顺序核验通过，`python scripts/check_repository.py` 七类静态检查通过。它们不等于 Swift 编译或新原生验证；本片未运行工具整套、Swift语法、原生单例、full、Release或手机验收。旧 full 191/192、I6/Release/手机缺口与最后交付Build30不变，不关机。S读数回退的写入者仍待证。
