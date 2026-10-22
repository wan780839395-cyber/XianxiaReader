# 连续视口缩放：单例诊断（2026-10-22）

2026-10-22本片已保存：修正探针编译后，源b618ca86 / [CI39754777198](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39754777198)原单例1/1通过（20.730秒），前后证据齐。旧full失败未复现，根因未证，未改定位算法；用户决定本轮保存、下一轮只做撤去一个缩放前DOM观察await的对照。本轮结束，不追加CI。

旧最终full源77eebf40 / CI39735403242：191/192，唯一失败为 ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView 首次变宽后联合等待；详见[I6最终结果](I6_FINAL_ACCEPTANCE.md)。原件完整保留，根因尚未证明，Release未执行。

## 本片合同与范围

用户授权只查上述原方法。保留30秒/100ms、同一WebView/挂窗/alpha>0.99、DOM宽度误差<2、原字Range可见、最多12视图、先横后竖顺序。未修改弱准备条件scrollY>500或增加重试，避免预先把假设写成修复。

仅失败方法增加initialDOMY、初始/请求/实际outerY、完整保存Locator、缩放前原字bounding/client Range、每次原联合条件采样与身份/几何记录，前后均keepAlways附件。原生重排增加Debug下最多64条start/complete/apply/resize诊断，不新增await，不改变guard/提交顺序或位置算法；Release诊断关闭。原窗口恢复补入XCTest teardown，原defer保留。

新continuous-resize入口仅一个-only-testing，沿用原诊断构建/失败原件导出/真实退出码，不运行Core、独立模块、23项、UI、full或设备Release。此片不增加target或依赖，不修改App、Core、隔离模块、资源、工程版本或锁。Vendor仅上述文件与对应审阅摘要变化。

## 如何区分原因

1. 先核缩放前原字是否可见、实际DOM/outer是否完成请求的+600；原方法的>500仍按原合同执行。若原字基线本来不可见，不能把后续失败归咎缩放丢字。
2. 基线合格时比较每个原条件、原Range和WebView身份。结合measure的起始保存锚点、revision/local、恢复guard、算得anchorY/desiredLocal及实际应用偏移，区分布局未提交、恢复被过滤或位置算法错误。
3. 探针增加的观察await可改变时序；单次重放通过不证明根因修好。若有缺陷，再用原件确定最小修复及同例验证，不凭通过删除证据或扩大到整套。

## 适用参考及取舍

- [Apple layoutIfNeeded](https://developer.apple.com/documentation/uikit/uiview/layoutifneeded())是UIKit布局边界，不能当作异步WebKit锚点恢复完成；本轮不改变调用方式。
- [Readium3.11.0](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)在viewWillTransition/viewWillAppear通知viewSizeWillChange。本项目连续容器为本地扩展，不照搬分页重建或升级版本。
- [swift-snapshot-testing1.18.4](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.18.4/Sources/SnapshotTesting/Common/View.swift)明确窗口size/traits及dispose。借鉴生命周期清理，保留现有原生窗口缩放合同，不新增依赖。

## 验证状态

本地静态/Swift语法484无新增诊断，非编译；受影响位置门禁/CI失败路径/Readium来源20项中19通过、1 POSIX跳过。首次工具调用缺PYTHONPATH导致3个导入错误，原件保留；按scripts入口修正后通过，不是产品失败。这是首轮冻结前的检查状态；之后的实际编译与单例结果见下节。结果/原件写入build/maintenance/I6-viewport-20261022及对应CI目录，不将单例等同I6最终验收，无新IPA。

### 首轮实际编译结果

18e7bb94 / CI39752863708在原生编译失败，测试0次。新增探针用了当前Swift不可用的NSStringFromCGRect；已只改为String(describing:)，原件与第一轮机器记录保存在attempt-1。根因诊断尚未执行，不属于产品失败或修复。修正后的原单例结果见下节。

## 本次同例实测与原件

- 初始DOMY1767，初始outer1769；请求+600后的outer2369，捕获后的实际outer2369/DOMY2367，准备已到位。完整Locator原字499，缩放前Range top=-3.125、可见，宽402、高778。
- 首次变为874×402：27次原等待采样；初期原字仍可见但DOM宽仍402，宽度条件未满足，后续DOM宽874/高306，原字top=-3.125。WebView始终相同、挂窗、alpha1。原生measure记录保存char499、revision2、guard为true，desiredLocal2151并实际应用。该样本说明原生frame变化早于DOM视口提交，不能据此追认旧失败原因。
- 返回402×874：又2次采样后原499字top=23.875，仍可见；内部首可见字已经变为495，measure使用495并计算desiredLocal2340。原合同要求原字仍在可视范围，不是逐像素相等；这27px变化如实保留，未收紧或放宽原断言。两次原生窗口截图均有正文，不能替代手机流畅度或完整视觉验收。
- test/summary/export均0，App/测试实际模拟器编译通过；同例仅一次开始和一次通过，无额外原生case，零跳过。Xcode16.4/Swift6.1.2/Intel/macOS15.7.9/iPhone16 Pro；Linux109项工具通过。Core/独立模块/23项/UI/full/设备Release均未跑，无新IPA，最后交付仍Build30。
- 新探针留下1种Optional Any隐式转换warning（initialDOMY字典），本次总9处/7种warning，新增1种；0源码错误。保留已经测试的输入，不在收口后改代码或压制警告。其余warning为旧项，未混入Swift6迁移。

本片实际派发2轮：首次因探针编译错误耗654秒，测试0次；修正轮主步骤1282秒，其中首suite前1213.758秒、实际单例20.730秒、其余47.512秒含导出/上下文收束。两轮主步骤合计1936秒（32分16秒）；静态检查、排队、上传和本地下载另计。不将固定准备及我引入的编译错误计作阅读测试耗时。

成功原件：build/ci/39754777198，artifact12415489203 / 2179722字节 / SHA256 `1c15f4ed3e3fba8a62b089d2c3baaa5a329ecde0695dc7a71ccce86c209f18b9`。包含DiagnosticTests.xcresult、PositionBuild.xcresult、完整内部日志、summary、3份前后文字证据和2张原截图。首次编译错误原件build/ci/39752863708完整保留。两artifact均核GitHub digest/CRC/完整安全展开，确认后仅移除本轮重复ZIP。完整机器结果见[ValidationLogs/project-isolation-i6-viewport.json](ValidationLogs/project-isolation-i6-viewport.json)，两个源的冻结输入/派发、原始hash和决定保存在build/maintenance/I6-viewport-20261022。

## 下一轮唯一对照（已明确本轮不执行）

仅撤去test中的`await domProbe(originalFrame.width)`这一个缩放前观察挂起点，before证据字段标为未查询；保留其余观察（包括新增initialDOMY查询）、原完整Locator、各子条件、重排记录、原30秒/100ms与全部断言。可审阅patch已存build/maintenance/I6-viewport-20261022/next-control.patch，尚未应用。它不是恢复原方法全部挂起点，而是只区分这一个观察是否改变复现；不能承诺一次对照即根因闭环。预计另需20–30分钟冷准备，待下一轮用户恢复再做，不自动派发或重跑full。

旧full39735403242仍为191/192，不能把本片1/1加到旧结果称192/192或I6验收。正式设备Release、手机/TrollStore仍未验；旧失败缺前锚点和measure记录，现有证据不能宣布旧失败是环境、假失败或已修复。
