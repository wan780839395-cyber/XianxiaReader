# I6 最终验收：191/192，失败原件已保存

2026-10-22。用户授权的一次 `diagnostic_selection=full` 已执行完，未附加位置、字体或旋转原生预检，未重试工作流。冻结源 `77eebf40ff70318c7bced90b28269aa5198084f0`，GitHub [39735403242](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39735403242)，实际 `run_attempt=1`。本轮运行输入仅把工程构建号30升31，生产、原生测试、资源、锁、门禁与预算保持。完整门槛未通过，设备Release被阻止，未生成或交付Build31 IPA；最后交付仍Build30。

## 同源真实结果

| 边界 | 本轮结果 |
| --- | --- |
| 原生集成 | 163项全部执行：162通过、1失败 |
| 原生UI | 29/29通过 |
| 合计 | 192个唯一用例各开始/结束一次，191通过、1失败、0跳过；不是2个失败用例 |
| 六独立模块 | ReaderSettings7、ReaderPositions24、ReaderSessions15、LibraryShelf6、BookImports8、ReaderSearch8，合计68合同；原xUnit、依赖、环境、日志及回执重新核实 |
| Core | macOS、Linux各137个唯一parallel调度条目及真实成功边界；mac Core成功不能被包含它的ios job最终失败覆盖 |
| TXT Release探针 | macOS、Linux各4项，全部allChecksPassed |
| 工具 | 本轮Linux109/109；冻结前Windows边界/full门禁42/42、零跳过；484语法新增0、既有Vendor限制54，语法检查不是编译 |
| 编译 | 模拟器App及测试目标真实编译通过；0源码编译错误，8处既有warning诊断、6种消息，较上轮新增消息0；未混入warning清理或Swift6迁移 |
| 原始退出 | test=65、summary=0、attachment export=0、recording=0 |
| 设备Release / IPA / 手机 | Release未执行，无IPA；普通手机、TrollStore及真实流畅度未验收 |

Apple环境原件为Xcode16.4/16F6、Apple Swift6.1.2、Intel、macOS15.7.9；Linux为锁定digest的Swift6.1.2 jammy环境。根锁、下载锁、生成workspace锁字节一致。所有617运行输入与冻结源相符；普通HEAD/index及既有未提交工作保留。

初始化中关闭已在本次共享进程中通过：分页/连续均真实font ready、生产状态pending、屏障未释放时关闭，原delegate/移除断言成立。这一轮两个模式均保留最初FontFaceSet包装对象、走instance hook，不倒写为本轮也发生了旧GC现象。字体保位、返回点、重复定位、分页加载等原合同均在191通过项中；这些通过不能掩盖下述失败。

## 唯一失败及证据边界

`ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView`，38.021秒。首轮把挂窗视口从402×874调整为874×402后，在原81行30秒等待中失败；返回竖向的下一轮未执行。该等待同时检查同一WebView、挂窗、内容alpha、DOM宽度、原字符Range与视口相交。XCTest的断言和随后抛出的错误产生两条issue，但summary和唯一事件均只有1个失败case。

终态原件确认：窗口有效，正文one.xhtml，WebView874×306、内容alpha1、DOM complete、两个资源slot均ready，无章节加载失败或超时；外层offset2670/insetTop62，当前章节wrapper原点365，局部scrollY2367，revision2，当前上报完整锚点char777。失败例只产生两个文本附件，没有通过首轮等待后的截图。

这些数据不能确定联合断言具体哪一项为false：没有记录缩放前保存的原char/Range，也没有原WebView身份比较值、DOM innerWidth和measure开始/完成决策。不能仅凭当前char777宣布“原字丢失”，也不能因为正文ready或29UI通过就判定定位正确。

源码比较另确认：本测试方法与已交付Build30逐字相同，`ReadiumReaderEngine.swift`和`EPUBInfiniteScrollView.swift`也与该交付源相同。但其他Readium补丁、该测试文件其他内容及共享运行顺序有变化，不能据此证明旧问题、排除关联，或把责任归给隔离/环境。

本例请求+600后只等`scrollY>500`，不能证明这次位移已经到位。项目此前在另一个连续返回用例中实测initialY1767、requested2367、actual2367，并修正了该用例准备条件；参见[原证据](READER_POSITION_ISOLATION.md)。这解释了本例存在同类准备漏洞，尚不能认定它导致本次失败。生产异步重排未保住合格原锚点、联合条件中的身份/几何不成立，也都尚未排除。本轮不盲补算法、不放宽断言/预算。

## 下一项可区分原因的实验

仅原失败单例，先记录initial/requested/actualY、原完整Locator、缩放前原字符Range和当前WebView身份；每次变宽/还原分别记录原Range及每个布尔条件。必要时仅加有界measure诊断，记录锚点/revision、期望偏移及恢复guard选择，不改生产算法。保留原30秒、100ms、同WebView、原字可见、最多12视图与先横后竖顺序；不能增加重试或用延时让失败消失。新增观察await本身可能改变时序，一次重放通过不等于根因修复。

用户已明确选择“先保存完整断点，下一轮只查此例”。本轮到此收口，不追加探针、原生诊断或CI；下一轮仅查上述原单例，预计另需25–35分钟冷准备。单例之后仍须按实际生产/UI输入重新审阅发布门槛，不能承诺一个单例通过即可替代完整验收，更不能未经授权再跑full。

已核对的适用参考与取舍：

- [Apple layoutIfNeeded](https://developer.apple.com/documentation/uikit/uiview/layoutifneeded%28%29?language=objc)只描述UIKit视图子树布局；不能把它当成本项目异步WebKit锚点恢复完成的证明。
- [Readium3.11.0对应源码](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)通过生命周期/尺寸转换通知更新视图模型。本项目连续容器是本地扩展，不能照搬上游分页重建策略，也不升级版本。
- [swift-snapshot-testing1.18.4窗口fixture](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.18.4/Sources/SnapshotTesting/Common/View.swift)明确原生窗口尺寸/traits和恢复清理；用于审阅宿主准备，不把通用截图fixture当阅读锚点算法，不新增依赖。

## 实际耗时与原件

主步骤5947秒（99分7秒）：首原生suite前1653.361秒（27分33秒，含工具、六模块/Core、解析、启动和编译）；集成case846.937秒（14分7秒）；UI case3194.564秒（53分15秒）；其余252.138秒含suite间启动、结果收束、导出和附加诊断。没有设备Release成本，因为该阶段未执行。Linux并行任务、产物上传和本地下载另外记账，不把全部等待叫作纯编译或这个38秒单例。

完整诊断artifact12411464644，1196915933字节，SHA256 `edbe1c6972311ab31124e20a525a5c612e4805ef2c0d3870c8642353651ac8a8`；Core artifact12406981251，116294字节，SHA256 `c94ea0a806317f85b392d8f68e4e3b66c3e8d292e2b522c503c258a715df3376`。GitHub digest、CRC、安全完整展开均核验，只清除这些已确认展开产物的重复ZIP/分片，未清理其他历史诊断、源码、恢复点或交付包。

原件在`build/ci/39735403242`：完整workflow日志、API实际attempt、artifact manifest/回执、SimulatorTests.xcresult、内部完整build.log、summary、全部文本/像素/录屏及六模块/Core记录。GitHub workflow日志未出现最后的退出marker，artifact内部tee日志保留了marker和完整结束段；两者均保存，未按缺失尾部判断挂起或改写真实退出。成功交付所需的完整视觉核验及IPA检查没有宣称完成。

机器记录：[project-isolation-i6-final.json](ValidationLogs/project-isolation-i6-final.json)。输入/派发/失败切片/保护的Build30哈希/恢复点在`build/maintenance/I6-final-20261022`。仍保留AppServices宿主、App批次/呈现、同target UI访问和字体iOS依赖等明确边界债务；静态import守卫不等于全项目类型隔离。I6和发布门槛均未通过，不自动进入新功能。电脑保持开机。
