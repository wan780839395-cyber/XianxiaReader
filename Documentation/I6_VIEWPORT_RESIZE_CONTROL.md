# 连续视口缩放：单一观察挂起点对照（2026-10-22）

用户授权仅撤去`await domProbe(originalFrame.width)`，保留现有功能/隔离/定位修复、所有其他观察、原断言及30秒/100ms预算，只跑原continuous-resize单例。源码当前仅原方法一行变化，before DOM字段为null，不伪造缩放前DOM证据。初始scrollY查询及保存Locator、原字Range/宽度等联合条件的后续采样、Debug有界重排记录、窗口teardown、12视图及先横后竖顺序保持。

匹配基线b618ca86 / CI39754777198单例1/1（20.730秒），前后原字499可见；保存断点2dcd6909，617运行输入核验后除这一行均保持。基线与旧full191/192的差异、原件及参考取舍见[I6视口诊断](I6_VIEWPORT_RESIZE.md)。本片不改变App、Core、模块、Vendor、工程版本、依赖、CI入口或发布门禁，也不清理既有诊断warning，避免引入第二变量。

## 假设与判读

仅检验上轮缩放前这个额外观察挂起点是否影响复现。若失败，先查原联合条件中哪个为false，再结合原Locator与measure的anchor/revision/local/guard/应用记录；null不能当作缩放前原字已可见。若通过，只支持该样本在没有这一处等待时仍能保持原字，不能排除其他探针或共享测试顺序，不能证明旧full故障已修复。不得盲重放、放宽断言/预算或追加整套。

本地check_repository --swift-syntax：484文件、0新增诊断，Vendor原54语法限制保留；不是Swift编译。此前位置工具/CI失败路径/Readium来源20项（19通过、1 POSIX跳过）的工具输入与原日志仍在，本片无工具变化，不重复运行该组；CI必要仓库静态工具入口保留。尚未有本片原生结果。下一步冻结后仅continuous-resize1例，预计20–30分钟冷准备；证据写入build/maintenance/I6-viewport-control-20261022和实际CI目录。旧full及Release/手机未验收状态不变，无新IPA。
