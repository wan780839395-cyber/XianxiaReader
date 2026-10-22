# 连续视口缩放：单一观察挂起点对照（2026-10-22）

2026-10-22已收口：源82b35f76 / [CI39759498210](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39759498210)，原单例1/1（11.293秒）；旧故障未复现，根因未证。用户决定保存本片，下一轮先做无CI复现设计。本轮结束，不追加实验。以下先列本片冻结合同，实际结果见后文。

用户授权仅撤去`await domProbe(originalFrame.width)`，保留现有功能/隔离/定位修复、所有其他观察、原断言及30秒/100ms预算，只跑原continuous-resize单例。源码当前仅原方法一行变化，before DOM字段为null，不伪造缩放前DOM证据。初始scrollY查询及保存Locator、原字Range/宽度等联合条件的后续采样、Debug有界重排记录、窗口teardown、12视图及先横后竖顺序保持。

匹配基线b618ca86 / CI39754777198单例1/1（20.730秒），前后原字499可见；保存断点2dcd6909，617运行输入核验后除这一行均保持。基线与旧full191/192的差异、原件及参考取舍见[I6视口诊断](I6_VIEWPORT_RESIZE.md)。本片不改变App、Core、模块、Vendor、工程版本、依赖、CI入口或发布门禁，也不清理既有诊断warning，避免引入第二变量。

## 假设与判读

仅检验上轮缩放前这个额外观察挂起点是否影响复现。若失败，先查原联合条件中哪个为false，再结合原Locator与measure的anchor/revision/local/guard/应用记录；null不能当作缩放前原字已可见。若通过，只支持该样本在没有这一处等待时仍能保持原字，不能排除其他探针或共享测试顺序，不能证明旧full故障已修复。不得盲重放、放宽断言/预算或追加整套。

本地check_repository --swift-syntax：484文件、0新增诊断，Vendor原54语法限制保留；不是Swift编译。此前位置工具/CI失败路径/Readium来源20项（19通过、1 POSIX跳过）的工具输入与原日志仍在，本片无工具变化，不重复运行该组；CI必要仓库静态工具入口保留。这属于派发前的检查记录；实际编译与同例结果见后文。证据写入build/maintenance/I6-viewport-control-20261022和实际CI目录。旧full及Release/手机未验收状态不变，无新IPA。

## 实际结果与判读边界

| 项目 | 同源结果 |
| --- | --- |
| 匹配基线 | b618ca86 / 39754777198，原单例1/1，20.730秒 |
| 本轮唯一运行输入差异 | before检查点中`await domProbe(originalFrame.width)`改`NSNull()`；617项中616不变 |
| 实际编译 | App/测试模拟器编译通过，0源码错误；9处/7种warning与基线相同，无新增类型，未压制或清理旧探针Optional Any warning |
| 实际测试 | 精确原方法开始/通过各1次，1通过、0失败、0跳过；test/summary/export均0 |
| 原生环境 | Xcode16.4/Swift6.1.2/Intel/macOS15.7.9/iPhone16 Pro，与匹配基线一致 |
| 工具 | CI Linux109项通过；本地484语法0新增诊断，非编译；无额外原生预检 |
| 其他门槛 | 未执行Core/模块/23项/UI/full/设备Release/手机，无新IPA，最后交付Build30 |

保存的原Locator指向char499。before仅记录native请求/实际outer2369，DOM字段明确为null；不能称本轮重新取得了缩放前DOM Range或DOM滚动完成证据。初始DOMY1767仍是原有的滚动前观察，保留该await不变。

横屏等待共2次采样：首个采样native WebView已874×306，但DOM仍报告402×778，原字top=-219.125且不可见；约0.130935秒后的采样DOM874×306、原字top=-3.125且可见，原联合条件通过。恢复竖屏再2次采样，原字top=23.875且可见。全程同WebView、挂窗、alpha1。原合同是原字最终可见，不是全帧无移动或像素严格相等，未把短过渡当作已排除的手机闪动问题。

重排记录显示两次mayRestoreAnchor=true，分别计算并应用desiredLocal2151、2340；返回竖屏时内部首字仍为495，原499字仍在可视范围。两轮外层offset因包装器/邻章布局时点而不同，不能只对比outerY判定正文丢位；局部DOMY及原字Range提供实际证据。本轮不存在原30秒缩放等待失败。

因此仅支持：**这个样本在撤去指定观察await后仍能通过，不能把上一轮通过归结为必需这个等待。** 它不能证明其他观察无影响、旧full假失败、共享顺序污染或旧故障已修复，更不能把两个不同时源的1/1加到旧full称192/192。

## 原件、耗时与本轮决定

仅派发1轮。原生主步骤1337秒（22分17秒）：首suite前1285.197秒（21分25秒），实际case11.293秒，其余40.510秒含导出/上下文收束；排队、上传、本地下载另计。没有额外编译失败或自动重试。

完整原件build/ci/39759498210：artifact12418352195，2239281字节，SHA256 `ee96d417242b2651ae571d865280593a53426666db536e82ebb7b6b80ce514b1`；GitHub digest/CRC/完整安全展开均核，保留完整日志、DiagnosticTests.xcresult、PositionBuild.xcresult、summary及全部附件，确认后仅清除重复ZIP。前一轮及旧full原件保持。机器记录见[ValidationLogs/project-isolation-i6-viewport-control.json](ValidationLogs/project-isolation-i6-viewport-control.json)。before/frozen/唯一dispatch/result/resize-evidence/scope-audit/user-decision在build/maintenance/I6-viewport-control-20261022。

用户已选择“保存本片，下一轮先做无CI复现设计”。当前所有自己的观察/下载任务已结束，本轮不追加CI或代码变更。下一轮只做设计和静态审阅：明确如何可控地令位置采样跨越尺寸变化，核对结果是否仍被接收并替换保存锚点；先定义屏障插点、显式放行/取消清理、原断言及新旧结果的判读。暂不实现屏障、不改定位算法、不派CI。

现有源码线索仅为假设：layoutSubviews尺寸变化处不改变viewportRevision；firstVisibleElementLocator在await后核epoch/index/slot/revision/localTop，没有独立尺寸身份。迟到采样能否据此替换原锚点、令measure的anchorEqual失败，尚无运行证据。原全组前序为模式切换用例，已注册close/window清理，亦未证明存在污染。只读线索分别保存在layout-sampling-hypothesis.json和order-context.json；不得把推测写成产品根因或直接补算法。

I6整体仍未验收，旧full39735403242仍191/192、设备Release未执行。未改任何生产算法、已有模块隔离、依赖、工程号或发布门禁。
