# 当前准备：同宽ResizeObserver写入隔离的9+9对照

单一行为切片：viewport宽度未变的body尺寸通知不再写分页位置；初次O=0不对齐，真实宽变保留原对齐，虚拟页及进度通知仍执行。新显式frame barrier回归已加入、原测试全文保持；原字可见前置和after-frame原位置断言。两边相同9case/顺序，包含已失败连续case和之前的两个关闭case，以区分测试顺序/旧连续问题；不靠扩大成完整188。Windows456语法新增0/54、64工具59过5POSIX跳过、Node测试脚本及Bash语法过。尚未编译/派发此源。保持开机，R3不做。

# 当前：root setter候选已拒绝并撤回（2026-10-21早晨，保持开机）

39523316446实际基线1/2、候选6/8、test exit65，候选4597b345真实编译0源码错误。完整178163935字节artifact SHA/CRC核验，原件build/ci/39523316446/diagnostic。分页change731行仍target3618后ResizeObserver scrollLeft0；另continuous resize81行失败，因果未定单列。ReflowableSpreadView/UPSTREAM已精确恢复d4cb607，失败候选没有保留为生产修复；R3不做、保持开机。下一最小切片仅上游body ResizeObserver：仅viewport宽度真正变化时才重对齐页，初次/同宽正文尺寸变化不写位置；先补显式barrier、陈旧scrollX故障注入确定性回归，再冻结同runner9基线+9正例，完全相同case及执行顺序（包括关闭→连续原控制），原预算/断言不改。尚未应用新JS修正或派发。以下为本run历史准备记录。

# 当前断点：分页换字体回章头的最小候选验证中（2026-10-21早晨）

用户最新指令：取消关机，保持开机；没有安排或执行过关机。只收口分页问题，R3仍未接线；原13候选仅在.cache。没有新增产品功能、IPA、完整187或设备Release/手机验收。

## 当前唯一任务

- CI39523316446，基线d4cb60717246eb18533e1166e92e3ddf31c969fc，branch codex/diagnose-paged-font-light-observation，selection=paged-font-control。同branch/同baseline SHA存在旧run，必须使用此ID；恢复先核实际run/jobs、进程和文件，不重复派发。
- 已审阅候选4597b3455c8dc7f4ebfd88f4005e446c2f10431a，为d4cb607精确child，已先推refs/heads/codex/fix-paged-font-restore-stage2再派发本run。runtime仅ReflowableSpreadView分页canonical DOM分支将window.scrollTo改为root scrollLeft=target，以及UPSTREAM摘要/说明。此为行为修正，不是R3提取；连续分支、完整Locator、字体等待/原await、3/20秒预算、原断言保持。
- 先执行2个原分页字体用例并保留真实基线0/65，再安装候选、核全部运行blob，同runner/DerivedData执行8个原直接位置/字体/关闭/TXT回归。候选已存在，无需人工临时提交；没有自动补丁或重试。工作默认长字体测试仍双模式，私有冻结该长链仅分页，不能冒充其连续字体链复测。
- Windows456语法新增0/54既有Vendor限制、verify_vendor357通过；语法不是编译。64工具fixture已随当前远程repository-checks通过，Core/native状态读取实际jobs；本run基线已核真实1/2、exit65，楷体wenKai重开回章头，147222字节文字SHA/CRC核验。正例8项运行中，尚无候选结果。
- 只读observer .cache/recovery/observe_paged_font_setter.py，当前session28886（仅为保留读取错误stderr而重启本地观察器，远程run未重启；恢复须核实际PID，旧session不能当进程仍活）；输出build/maintenance/PagedFont-20261021/setter-run/jobs/artifacts.json。gh api需时可用GODEBUG=http2client=0；读网失败不代表CI失败。

## 已确认失败与待证明机制

- 首诊f620349/39465081517真实1/2，保存、打开返回、重建输入完整p25/char1049正确，新页面第一次publish h1/0。文件存在、字体ready、完整字锚点有效；不是本样本保存/数据库丢失。
- 第二诊608a98f/39472174050实际2/2；driver错误要求负对照必须失败，未进入候选阶段，不是源码失败/已修。重型观测可能改变布局/时序，根因未由此证明。
- 轻量d4cb607/39478971105真实1/2、test exit65、0源码编译错误。决定性失败链：初始location char1049、canonicalTarget3618/width402；window-scrollTo请求3618 at1535ms；Readium3.11 ResizeObserver/rAF在1545ms写scrollLeft0，首次publish h1/0。该样本的后续覆盖写入已抓到；不把hidden用例偶发失败自动认成同根因。
- 轻量run最终失败在900秒等候候选（无人提交），不是新增源码失败。139590字节文字与79176639字节完整artifact已SHA/CRC核验，build/ci/39478971105；raw xcresult/完整日志保留。完整原件首次collect正确，zip/分片按回执清除。ledger=build/maintenance/PagedFont-20261021/light-ledger.log。
- 当前候选假设：使用与resize snap相同的root scrollLeft直接属性路径，避免Window.scrollTo待生效时被旧scrollX覆盖。WebKit Element/LocalDOMWindow main源码显示不同position调用路径；只作机制参考，不冒充iOS18.5对应源码或已证修复。原生对照后才接受/拒绝。

## 保全与下一步

普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index SHA256 b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28保持；504保护输入和既有WIP/上一片连续修正保持。候选freeze/diff/dispatch在build/maintenance/PagedFont-20261021/setter-*.json与.diff；使用alternate index，无reset/clean/普通提交。

先取本run实际原测试+候选8结果与patched-inputs候选SHA，再收完整artifact、native后续writer/锚点和所需原图。若失败，保留原件并用新差异缩小原因，不重跑全CI碰绿；若通过，写清负对照是否真失败、修正实际范围和未执行的完整/Release/设备门槛。用户明确保持开机。此前逐轮交接原文已保存在[分页调查历史](Documentation/HANDOFF_PAGED_FONT_INVESTIGATION_2026-10-21.md)，其中关机/运行状态为历史，以本节和实际证据为准。

## 前片连续偏移结果（保留）

5340a5b/39456749155同runner旧源10.875点→修正0.875点，原<3点断言保持；连续六字体截图后保存字delta0、字体ready、目标字可见。整组5/6，分页hidden字体失败仍为发布阻塞，不能发布/生成IPA。唯一生产修正为无限连续canonical DOM分支内部消费完整字锚点与viewportOffset；native updateViewports失败候选已撤回，InfiniteScrollView保持原字节。六张原图已看，非动效或手机验收。精确回执Documentation/ValidationLogs/continuous-offset-39456749155.json；原控制a84b6719/5340输入及505保护证据保留。

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
