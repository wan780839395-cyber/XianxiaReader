# 连续视口缩放：单例诊断（2026-10-22）

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

本地静态/Swift语法484无新增诊断，非编译；受影响位置门禁/CI失败路径/Readium来源20项中19通过、1 POSIX跳过。首次工具调用缺PYTHONPATH导致3个导入错误，原件保留；按scripts入口修正后通过，不是产品失败。尚未获得本片Swift编译或单例结果。冻结前再次核范围，仅派发continuous-resize。结果/原件写入build/maintenance/I6-viewport-20261022及对应CI目录，不将单例等同I6最终验收，无新IPA。
