# 当前任务：查清分页负对照未命中，再确认字体回章头修复（2026-10-21）

用户最新明确继续，授权先查原生负对照未命中原因，确认分页换字体问题修复后才继续R3；控制代码/验证范围，不跑整套。旧“保存后停止”指令已被本次继续覆盖。保持开机。

当前事实：ecde4d4是本地保存检查点；实际旧/新原生源a812571/9bb6c86，CI39528802200已结束，候选9/9但新同宽屏障旧源也通过，sameWidthControlledFailure=false。编译/536+536输入与完整原件此前已核；不能把旧关闭失败算分页负对照。503保护输入、普通HEAD/index保持，无活动observer/download；R3未接线。

本轮切片：只查/加强Tests/iOS/ReaderRenderingTests.swift中已有同宽ResizeObserver屏障，必要时为单用例对照调整scripts/ci_reader_diagnostic.sh、scripts/ci_paged_font_control.sh及其直接工具回归；生产JS候选与UPSTREAM先冻结9bb6c86，不动App/Core/字体模块/依赖/Locator/预算。旧字体/截图用例和默认双模式保留。

区分假设：屏障可能捕获非目标callback/frame、stale scrollX getter未被实际writer读取，或写入后另一路恢复；尚未证实。新增有界无几何诊断只记录observer/frame源码、href/初始化标志、getter命中、root scrollLeft写入与顺序，并断言确实进入目标路径；不靠短sleep或重试。先核官方WKContentWorld与WebKit/Readium原实现及成熟fixture，再决定最小修改。

验证顺序：先Windows/JS语法和实际回调语义控制；冻结同一fixture，至多旧/新单用例各一次、共用runner与DerivedData，不跑9/188或设备Release/IPA。原生若仍未形成负对照，保留原件并改根据诊断归因，不重复碰绿；范围或产品取舍不清再问用户。单用例对照通过仍不等于完整188、手机或R3验收。之后是否需要补一个原字体链，以取得原生证据后的受影响边界决定并明确记录，不自动扩成整套。

已实现待验证：已有native单用例现在只捕获包含真实root scrollLeft写入的Readium回调/帧，记录源码、href/inline模式、实际stale getter读取与原生root setter尝试并原样委托；原位置/可见断言与预算保持。控制driver仅此1case×旧/新，候选限JS+UPSTREAM，提前提供exact-child，删除空等900秒；基线还须实证目标帧、stale读取、写0及原断言失败，候选须无位置写入，未形成负对照则保留回执但门槛失败。原9case入口保留但本轮不用。

参考已核：Readium固定d82f44f的utils.js中body RO每次调用onViewportWidthChanged→snapCurrentPosition，不区分页宽/正文变化；WPT resize-observer/resources/resizeTestHelper.js用下一RAF显式推进/完成并断开observer；WKUserScript与evaluateJavaScript默认page world一致。未升级依赖。参考原文与摘要在本轮build目录和Documentation/ValidationLogs/paged-font-control-20261021.json。

本地真实回调+新fixture的最小DOM控制已通过：旧同宽实际委托写0，新不写且保3618；真实宽变两边3216、连续一致。只作为低成本语义检查，不作WebKit验收。下一步Windows仓库/Swift语法、定向工具/Bash与Node检查，之后冻结并派发一次同runner1+1；生产文件仍与9bb6c86字节一致。

本轮资料：build/maintenance/PagedFontControl-20261021。旧证据：Documentation/ValidationLogs/paged-font-resize-39528802200.json、build/ci/39528802200与build/maintenance/PagedFont-20261021/final-checkpoint.json。历史交接见Documentation/HANDOFF_PAGED_FONT_INVESTIGATION_2026-10-21.md。

# 上一片：R2字体编排本片完成

2026-10-20。用户优先维护全项目、隔离功能，再新增产品功能；发现偏移及时纠正，不能判断的产品取舍及时问。I0/I1/I2本片门槛完成，整个项目隔离尚未完成。下一轮先定义I3/R3完整位置的文件/合同/直接回归，不在R2收尾提前实施；后续产品清单保留在PROJECT_ISOLATION_PLAN、ROADMAP、READING_FEATURE_IDEAS。

## 当前实现与验收

真实源410343b7bbdb7b0f667d277c910f7f349a4d4ae7 / codex/maintenance-reader-fonts；CI[39418977905](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39418977905) success。ReaderFonts是XianxiaReading内真实product/target，只依赖ReadingInterfaces/Core，拥有目录、资源/已安装ID、选中判断、busy/message及异步请求身份；App读取单一状态并转发通知，保留原导入/预览/Bundle/picker、完整锚点与引擎重开。打开恢复原await加载→核会话→同步commitOpening→安装/应用，不再额外包装async prepare。未改存储格式、字体文件、依赖/锁、位置算法或Readium/Vendor。

最终同源53/53、失败/跳过/重复0：新字体合同7、原字体8、设置7、生命周期28、原真实字体2、原生picker1。原失败长链139.733秒、隐藏重排11.918秒通过；真实编译0源码诊断，原断言/预算无改动。Windows456语法新增0/54既有Vendor限制，62工具59通过3既有POSIX本机跳过（21.857秒）、Bash语法通过；Linux62/62、Core137个独立身份及TXT Release4/4均已核原件。Xcode16.4/Swift6.1.2/macOS15.7.9、iPhone16Pro iOS18.5模拟器。原生步骤1893秒含准备/编译/启动/测试/导出，case耗时之和313.263秒不等于独占墙钟。R2不具备macOS无App字体快速入口，原因见设计；I1设置快速包未改。

已实际查看当前run七张原图：选择/取消/重开/深色/重置五张设置图，分页/连续初次导入字体两张正文图；可读，无所选图加载/错误覆盖。未查看全部字体帧/录像，不能当手机流畅度验收。本维护源未跑完整158集成+29UI=187、完整原生动效、严格设备Release或普通设备/TrollStore验收，未生成新IPA；最终发布留I6。

## 失败历史与独立位置观察

首轮f29c4ba/39406897687真实52/53，分页首次内置字体选择719行失败。最小同runner对照293251e/39411950208只跑同一原test各一次：pre-R2 222f10e为1/1，R2 f29为0/1，后者在756行思源黑体分页重开后失败。原件证明保存/打开返回时完整p25/char1049正确，后续字体ready但退至h1；与首轮不同失败位置不能直接当一个根因。修正本片引入的额外async封装后，本源重新执行53/53，不重试同源碰绿、不降低断言；通过不等于WebKit时序机制已完全查明。

收尾另核断言通过后的连续诊断：改前基线12组中有2组anchorCondition=false（思源黑体/朱雀，native offset4822/4824），本源有1组（小薇，offset4808），均字体loaded且无错误；这些单次样本不证明频率改善或章头回跳。记录在post-assert-observation-comparison及最终回执，作为R3/I6单独复核项：同一canonical anchor、viewport offset与settled布局的后续帧，不改原预算，不混进本片修复。

## 原件、保全与恢复

当前权威：Documentation/ValidationLogs/project-isolation-r2.json；build/maintenance/R2-20261020/accepted.json、open-boundary-frozen.json、preservation-open-boundary.json、expected-cases.json。566个输入的Git blob/本地SHA保持；26个非字体VM方法与原52测试/fixture输入原文保持，460个Core/Adapter/Vendor/资源/样书/锁输入保持（XianxiaReading manifest新增target为本片必要改动，单列）。当前133 Swift源/15区域/16节点/5精确import例外，23项边界正反例随62工具验证。普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index127条保持，所有既有未提交工作保留，禁止reset/clean。

build/ci/39418977905包含最终完整日志、diagnostic/Core两个artifact和SHA/CRC下载回执；首轮39406897687及对照39411950208的完整原件仍作为当前R2诊断证据保留，旧失败不能倒写成功。各次完整提取核验后，仅其重复分片/ZIP按精确回执清除。已交付Build30完整诊断39373881574和安装包、原字体/书籍、恢复ZIP均保留；本轮资料待I6稳定化后按CI保留规则收敛。

三个CI均已自然结束，所有本轮观察/接收进程已退出；旧exec/PID不可复用，恢复先核实际CIM/run。早期CLI TLS/EOF与一次工具连接刷新只影响本地观察，独立REST恢复；不能把远程字体断言失败归因本地网络。临时r2-font-comparison managed worktree已归档可恢复，诊断源293251e仍在codex/diagnose-r2-fonts，回执control-worktree-archived.json；主目录源码不受影响。最终仅同步文档提交，必须证明566运行输入不变，不再派发CI。

最后交付仍Build30：Release源aa0a119a71b10f1f345bc6f4cd54f6c8b4e2871a / CI39373881574；IPA build/XianxiaReader-SettingsIsolation-Build30.ipa，SHA256 35752183296684a573bf866c84ad34f555adc5d16aadcab7148763c1f839a638。手机验收待反馈，Build29“已暂停”仅旧路径。当前R2没有新安装包，不能复用Build30完整180/Release冒充本维护源验收。

完整本轮/旧交接已归档到Documentation/HANDOFF_R2_DEVELOPMENT_2026-10-20.md，旧I1过程另在HANDOFF_I1_DEVELOPMENT_2026-10-20.md。保持电脑开机，不安排关机。
