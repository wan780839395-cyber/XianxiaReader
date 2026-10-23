# I6 跨布局旧采样最小修正（2026-10-23，本地验证）

本片只修复39962812139受控配对暴露的缺口：S在402宽捕获输入、874宽读取后仍提交，覆盖M需要的旧锚点；M据正确的anchorEqual保护跳过恢复，原字top=-219.125。该证据不证明旧full、2367→1767或准备期CancellationError的自然根因。本轮不推送、不派CI。

## 最小行为变化

`EPUBInfiniteScrollView.swift`增加独立的EPUBSamplingLayout（记录有效阅读视口尺寸及UUID代次）。layoutSubviews仍先super，随后在原重入guard前观察有效尺寸变化；同尺寸不换代，A→B→A换两代。尺寸采用bounds.width与扣除contentInset后的viewportHeight，避免外层高度和原native窗口不一致。

S在原挂起点前捕获布局代次与尺寸；原WK回调后先执行全部原身份/滚动/位置guard，再核布局。代次不同或实际有效尺寸不同即返回nil，不写anchorRevision/anchorViewportTop/savedAnchor/documentY，也不增加WK调用、await、Task、等待或重试。直接尺寸比较覆盖布局pass尚未执行的情况，代次覆盖尺寸已变回原值的情况。

滚动revision不因布局而递增，M测量/补偿整段源码未修改，仍保留真正新锚点、导航、滚动与物理局部位置的保护。缓存锚点的早返回合同保持，M继续使用原锚点完成排版补偿。只有本地原样方法/恢复表达式支持该变化，UIKit/WebKit结果仍未执行。

## 影响文件与验收合同

只改6运行输入：Vendor InfiniteScroll、UPSTREAM摘要/说明、ReaderRenderingTests、verify_reader_positions.py及两个既有工具测试test_reader_positions_tools.py/test_readium_provenance.py。无新target/接口/Adapter/JS资产/依赖或CI接线。

配对夹具/验收器新增明确layout-invalidated终结：仍要求原SDK请求与9项原采样上下文、实际DOM/快照、新代次、保留A及M全部原guard。原字双向断言和返程窄屏不变，原失败65继续保留。返程请求也逐个核真实read/decision/terminal与新旧代次，支持尺寸变回原值的正确作废，不忽略请求。历史anchor-replaced等分支仍可判读。smoke的安全顺序和M guard合同保持。

## 本地检查

首轮33项中32通过、1项Swift行为因镜像名称无法解析而skip；没有将skip计为通过。引擎正常，缓存实际ID与上一轮完全一致（sha256:1122c18e938491180820e9b4902c489dadd5a89f7e6bd99ff9b64e7f1b18f41f），其现有RepoDigest为swift@sha256，同一摘要的canonical引用可用；只确认引用路径差异，不推断Docker内部原因。未拉取/安装/重置/改安全网络或清理镜像容器。只补跑缺失1项，Swift6.1.2/x86_64-unknown-linux-gnu编译执行退出0；原32项不重复执行。

该行为夹具从实际Release源码抽取完整S方法、缓存判断与M恢复表达式，UIKit/WK明确替换为Foundation几何与显式continuation。负对照机械撤掉新捕获与guard后，其S方法SHA256严格等于冻结050c2b2原码（25a2496ca7fdb22fb6e50cff1dddba503439ca26e78d5ef9c54981a5f654d85e），不是另写算法。旧/新各9个有控制的场景：

| 场景 | 旧S实际结果 | 新S实际结果 |
| --- | --- | --- |
| 同尺寸/同尺寸layout pass/新布局后发起 | 正常提交新锚点，旧M不覆盖新锚点 | 相同 |
| 跨尺寸/变回原尺寸/尺寸变了尚未layout pass | 提交并覆盖A，M抑制恢复 | 旧S作废、A保留、M允许恢复 |
| 新滚动/物理位置先变化但未发delegate/导航epoch变化 | 旧S作废，M不恢复旧位置 | 相同 |

宽屏模型中实际M表达式2147.875-(-3.125)=2151，保持原字身份499；这是替身几何/缓存验证，不是原生DOM可见性验收。M整段源码SHA256仍ca3050402bf2b21effbd565bde72f94c8d65cc59fc73beeac1b0bd3274bee798；原await/JS/3次与32ms/业务断言及清理预算源码合同通过。上一轮准备Trace/Buffer的原样helper哈希fc58e570...保持，复用已经实际执行的Swift6.1.2结果，不重复编译无关helper。

验收器正反例覆盖：新代次缺失/相同/伪造、错误尺寸/快照/上下文、A被改写、M原guard失败、原字不可见均拒绝；原65保留，返程请求不能省略。对39962812139原件只复读新Python验收器，仍得到安全unchanged/0、冲突candidate-controlled-word-failure/65；这不是原生重跑。

仓库7项静态、484文件Swift grammar通过（54上游登记限制/新增0），不是Swift iOS编译。另已核既有Navigator：无anchor返回(nil,nil)，不会在此拒绝后直接降级成百分比定位；这些调用方源码未改。没有Swift iOS target编译、UIKit/WK单例、full、Release或设备验收；旧full191/192、准备期取消和JS参数options-value缺口保持，最后交付仍Build30。

## 官方及成熟实现依据与取舍

- [Swift官方并发章节原文](https://raw.githubusercontent.com/swiftlang/swift-book/main/TSPL.docc/LanguageGuide/Concurrency.md)说明异步工作会挂起并允许UI继续更新。MainActor串行不替代挂起前后输入资格；本片在原await后重验，未加新异步层。章节为当前文档，实际采用的UUID/CGSize及并发语法由已有Swift6.1.2执行核验，无新版本API。
- [Readium3.11固定版本Navigator](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)在viewWillAppear/viewWillTransition/didBecomeActive独立通知viewSizeWillChange；参考尺寸与阅读位置职责分开，不照搬上游分页reflow。本地连续容器/cache是扩展，不能声称上游已有本修正。
- Apple layoutSubviews页面抓取仅得到JS占位，Markdown入口失败，未据此假定UIKit或WebKit的同步屏障。真实布局/回调时序仍需原生验证。

## 保存与剩余门槛

恢复build/maintenance/I6-layout-sample-invalidation-20261023/保留before、6原件、首轮skip、镜像引用错误、原样旧/新harness、真实命令/退出/stdout及局部工具/后续语法记录；旧原件和Build30保持。最终恢复ref/revision见final-checkpoint.json，普通HEAD/index不变。[持久验证记录](ValidationLogs/project-isolation-i6-layout-sample-invalidation.json)。

下一门槛是另行授权的同例原生验证：新S明确layout-invalidated且A不变、M原guard/恢复、宽屏和返程原字、真实SDK终结与取消清理。此次无CI额度，不推送；不能把本地替身对照当原生修好或旧自然故障已修。
