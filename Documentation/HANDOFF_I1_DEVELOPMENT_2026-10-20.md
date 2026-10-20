# I1实施过程历史（2026-10-20）

以下是派发及等待时的原交接，保留为过程证据；其中待验证/运行中/旧观察器状态均已由当前HANDOFF和最终I1回执更新，不触发重跑。

## 用户确认的当前优先级（2026-10-20）

I1已开始：用户再次授权继续，并要求发现偏移及时纠正、产品取舍不确定时及时提问。已核I0四项工具输入和529个保护输入均与回执相同，无已有测试/CI助手进程。当前切片限定为设置逻辑的独立快速入口与保守影响映射，不进入R2/R3/R4。

I1工作合同：把现有ReaderSettingsPersistence封装为只依赖XianxiaCore的新ReaderSettings本地包（iOS16/macOS13，Swift tools5.10），仅公开App所需的现有接口；AppServices/ViewModel与生命周期测试增加模块导入，设置算法、存储路径/格式及原7项测试函数保持。将原设置测试源放在包内，macOS SwiftPM与原iOS测试target使用同一份文件，保留151+29完整门槛；I0守卫仅对该精确测试源允许两个测试target编译，生产源码仍单一归属。新增快速脚本、严格7项xUnit结果验证、独立macOS workflow及只生成计划的反向依赖映射；快速路径不解析Readium、不启动模拟器。默认完整发布流程加上逻辑门槛，其余断言/预算/三锁不改。验证先Windows静态/工具，再一次冻结的macOS7项与原iOS设置/生命周期定向编译集成；最终发布验收留I6，本片不交付新IPA。

参考已核SwiftPM swift-6.1.2-RELEASE的SwiftTestCommand（--parallel与--xunit-output）及XcodeGen2.46.0源路径规范；不用动态manifest、重复生产实现、OpenCombine替身或新远程依赖。下一步保存I1源码/配置基线，再迁移并核原测试主体字节一致。

I1可恢复检查点：559输入基线与受改旧文件已存build/maintenance/I1-20261020/baseline.json、before.zip。设置类/测试已移入ReaderSettings包，App/iOS入口已接线；已核设置源码除必要public可见性外原文相同，7项测试与受控fixture除模块import外原文相同。架构守卫131源/14区域/15节点通过；22项架构工具与10项快速结果/影响映射工具通过，尚未编译Swift。CI入口已纠正为现有ios-build.yml的reader-logic / reader-logic-integration两个选择（新workflow的默认分支登记限制已核），完整路径不删减；当前正跑最终Windows检查，随后用一次冻结源派发7项macOS+原iOS设置/生命周期定向。详见FAST_VALIDATION.md，不把本地工具通过写成真实Swift通过。

派发前：Windows最终454语法新增0/54既有限制，61工具58通过/3既有POSIX本机跳过（19.708秒），Bash两个受改脚本语法通过；原设置7与生命周期28共35项仍在iOS target。准备从857c16b的交付文档基线，以替代index冻结到独立codex/maintenance-reader-settings分支，普通HEAD/index保持；本轮同时把已验证I0工具纳入快照。仅派发现有workflow的reader-logic-integration一次，成功也不表示完整180或设备Release。后续所有运行/原件以build/maintenance/I1-20261020/frozen.json及实际run为准。

已实际派发：[39398382008](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39398382008)，源1545a3cdafa248e563c01c408e04cd8cc3e71154 / codex/maintenance-reader-settings，reader-logic-integration；564个当前输入已核Git blob与本地摘要匹配，普通HEAD/index保持。本次只有这一轮运行，不移动冻结分支或生产/测试/工具输入；等待真实7项macOS和35项iOS结果。没有触发完整180、Release或IPA。中断后先读run.json并核实际job/日志/进程，再接收原件，不重派发。

17:15上海进度：repository-checks真实success，reader-logic的独立SwiftPM步骤09:08:45→09:10:40UTC成功（115秒含编译）；iOS settings集成步骤09:10:40UTC开始尚在运行。原XML/依赖树/日志待job完成后接收再正式核7项。观察器为python .cache/recovery/watch_autoscroll.py 39398382008，实际PID20280、exec26634；元数据/结束日志写build/ci/39398382008，I1本地证据另在build/maintenance/I1-20261020。恢复时核CommandLine与实际状态，不重复观察器或派发。

用户已授权开始维护；偏离范围时及时纠正，涉及无法判断的产品取舍及时提问。后续产品计划保留，见[全项目隔离与维护计划](Documentation/PROJECT_ISOLATION_PLAN.md)。I0依赖守卫已落地且Windows验证完成，本轮未混入R2/R3/R4、UI变更或依赖升级。Build30 的验收只适用于下述已交付源。

最终I0：20项边界正反例通过；默认仓库7项静态检查与453 Swift语法新增0通过，54既有Vendor语法限制保持；完整Python工具49项46通过/3项既有POSIX本机跳过（12.343秒），真实exit0。源码扫描131文件/12区域/13target节点/3包，记录5个精确import例外。529个App/Packages/Vendor/Tests/锁/project保护输入及普通HEAD/index保持。最终输入、完整日志和逐文件归属在build/maintenance/I0-20261020/accepted-*，简明回执Documentation/ValidationLogs/project-isolation-i0.json；本片没有Swift编译、远程CI、原生/设备验收或项目新IPA。守卫不隔离同target内部类型访问；I1及R2/R3/R4/I5/I6未完成。

收尾负对照发现I0守卫可漏扫常规目录外的新target源码：真实临时仓库已登记target但漏登记功能负责人时，旧守卫未拒绝，单项工具回归真实失败（1.477秒）；这不是App行为失败。已改为同时扫描实际target源路径，保留去重/归属检查，原反例0.786秒通过。负/正原件为new-target-ownership-negative/positive-control.log。修正后完整49项/453语法重新通过，最终accepted输入保留check_repository原CRLF格式，其实际代码变化只有新增检查函数及列表接入。旧19/48与中间final20结果独立保留，不作为最终源码验收。

下一独立切片I1：先审阅现有逻辑测试对App宿主/Readium的依赖，定义最小快速入口与影响范围映射；保留现有完整发布门槛和三锁，不为纯设置测试引入Readium内部产品或文档插件。开始迁移前核对本片基线及明确新Swift target/公开接口的必要范围，再实施、定向与Apple编译验证；不要按下方历史“下一步”重做I0或派发旧CI。

