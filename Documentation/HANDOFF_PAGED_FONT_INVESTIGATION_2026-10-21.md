# 当前唯一实验：分页root setter对照（2026-10-21早晨）

基线d4cb607与候选4597b3455c8dc7f4ebfd88f4005e446c2f10431a精确parent/child，候选仅ReflowableSpreadView分页canonical滚动primitive及UPSTREAM；Tests/CI完全同blob，504保护输入及普通HEAD/index保持。已先推候选再派发一次paged-font-control，基线branch codex/diagnose-paged-font-light-observation（与上一run同SHA，必须按新run ID辨认），不会空等候选。2个旧原case保留负对照，安装已审阅候选后8个原直接回归；本次原函数名BothModes的长字体私有链仍只分页，工作默认两模式。语法456新增0/54既有限制，未原生编译。无完整187/Release/IPA/R3；用户已取消关机，保持开机。

# 分页候选准备（2026-10-21早晨，保持开机）

已取39478971105 baseline文字SHA/CRC，真实1/2、exit65。one.xhtml初始输入char1049、target3618正确，window-scrollTo1535ms后ResizeObserver/rAF在1545ms用scrollLeft写0，首次publish h1/0。完整原件待收。当前最小候选仅ReflowableSpreadView分页canonical分支改root scrollLeft=target，与上游resize writer同一primitive；连续/预算/await/字锚点不改。WebKit源码显示root setter与Window.scrollTo有不同position路径，但main仅机制参考、不冒充iOS18.5源码。尚未原生编译验收，不称已修。下一冻结d4cb607精确child候选后，同源2基线+8正例原case同runner验证，不再等临时决策/夜间询问，不展开R3。

# 当前恢复（2026-10-21早晨）

用户最新要求取消关机，保持开机；没有安排/执行过关机。实际CI39478971105已于19:31UTC结束，基线原生已执行，等待候选步骤失败；未推送任何修复候选，须先收取139590字节baseline文字确认原测试结果，不能把候选等待超时当源码失败。无本轮observer/download运行，普通HEAD/index保持，R3暂不展开。

# 当前断点：连续偏移直接验证完成；分页另查，R3顺延（2026-10-21）

当前唯一运行：轻量观察d4cb60717246eb18533e1166e92e3ddf31c969fc / codex/diagnose-paged-font-light-observation / CI39478971105，selection=paged-font-control。observer .cache/recovery/observe_paged_font_light.py / session91297，前缀light；Linux新driver fixture先过再开始native。当前无修复候选；baseline文字上传后同runner最多15分钟等待refs/heads/codex/fix-paged-font-restore-stage2，候选必须d4cb607精确child，仅白名单Vendor，Tests/CI输入相同；基线0/65均原样保留，baselineWasNegative=false时不能声称取得负对照或修好。正例使用paged-font-acceptance的8原case，新增的两个是字体初始化关闭/迟到回调；原断言及预算保持。Windows456语法新增0/54、64工具59过5POSIX跳过（21.814s）、Bash语法过。恢复先核实际run/mTime和进程，不重复派发；若observer连续HTTP失败，先用GODEBUG=http2client=0的gh api读取，不归咎CI。R3不做、未安排关机；用户不接夜间问题，分页验证修好并保存才关。

最新：608a98f/39472174050原生2/2通过，原test exit0，driver因要求负对照必须失败而exit1，后半未执行、无候选；不能写成源码失败或问题已修。189523字节中间文字与7977082字节完整原件均SHA/CRC已核。原JS观察读取矩形/样式、包ResizeObserver/rAF，加上canonical返回调试JSON后的scrollX/documentWidth读取，可能改变布局/时序（尚非已证根因）。已改成不读矩形/样式/不包Resize/rAF的有界写入/scroll事件记录，canonical仅在滚动前保存已计算target/width并返回原Bool，补原生requested/initial/script-returned尺寸。新driver允许基线exit0/65且真实保留baselineWasNegative，0不能当修复或负对照，不再因此关闭warm环境。正例8个原case：原6直接位置/TXT/连续检查加两字体初始化关闭/迟到回调，生产预算/原断言未改。新source尚未编译/冻结/派发，R3未做，无修复候选与关机计划。

当前唯一运行：staged源608a98f81cac8210a283fabd228086267218ce05 / codex/diagnose-paged-font-restore-stage2 / CI39472174050。已派发一次，Windows456语法新增0/既有54、64工具59过5POSIX跳过（21.937s）、Bash语法过；新driver fixture在Linux前置先验5种结果，未过不会开始native。observer .cache/recovery/observe_paged_font_staged.py / session45449，前缀staged，run进入“Validate reviewed paged font candidate...”时会保存staged-interim-artifacts并输出BASELINE TEXT READY，随后最多15分钟等待候选。候选必须608a98f精确child并仅改白名单Vendor，固定ref refs/heads/codex/fix-paged-font-restore-stage2；尚未存在/推送候选，不能把诊断当修复。取baseline文字优先（小artifact），判明go输入/初始pending/真实尺寸/JS target-before-after后再修；不盲猜源码。若baseline准备无效或全绿将止于原件，不称根因已修。最终完整产物会保留baseline原xcresult及正例6项；workflow head是baseline，若安装候选须以patched-inputs.json证明实际编译candidate SHA，不能混称run head。用户不接夜间问题、无需手机通知；分页未验证修好前不关机，R3顺延到下轮。

分页首轮诊断f620349/CI39465081517已失败1/2，103779244字节artifact已SHA/CRC核验。原生账证明：保存/重开返回/重建输入均p25/1049（progression0.37037），新view第一次publish已是h1/0、x0；hidden fixture本次通过。排除本样本采样/数据库丢完整锚点，尚不能区分初始go未生效、尺寸未定或后续重置。已新增requested/initial/canonical-script有界metadata，复用JS writer探针并使用既有storageRoot测试init，不增加await/预算。下一轮staged控制先保留失败baseline文字，最多15分钟等待本Agent审阅后的exact-child候选，只允许Nav/Reflowable/Pagination/UPSTREAM差异，然后同runner/DerivedData跑原6直接case；无候选则明确失败/保留原件，不自动补丁、不导出IPA。此等待是CI调试输入门槛，不改变生产3/20秒预算。R3今晚不做，分页修复验证完成再关机。

旧JS写入观察39348950147已是2/2且没有候选reset writer，不能当旧回跳已修。本轮新增区分条件为native锚点阶段账（sample/submit/reload/publish），JS探针只复用既有fixture；若只得到重放成功，不据此修复/关闭问题。

当前唯一运行：诊断源f620349bea43ed6c628490f95009e49f66a00313 / codex/diagnose-paged-font-anchor / CI39465081517。selection=paged-font，仅两个原测试，长字体链私有仅分页；工作默认仍双模式。observer .cache/recovery/observe_paged_font.py / exec session63297，侧档build/maintenance/PagedFont-20261021/diagnostic-run/jobs/artifacts，恢复须核mtime和远程run，禁止重复派发。尚无新native结果，尚未修复分页、未接线R3，也未安排关机；用户不接夜间问题，需决策写交接，问题解决/验证/保存后再关机。

派发前：Windows456语法新增0/既有54，63工具59通过4POSIX跳过，22.800秒。诊断仅两个原分页字体case；私有长链只选false，原断言/预算保持。普通HEAD/index、其余505输入及上一轮连续修正保持。最新用户不需要夜间问题/手机通知，必要问题写交接留待早晨；分页问题解决并保存结果后关机，R3下一轮。不安排定时关机、不在失败未决时先关。

分页诊断切片：仅DEBUG最多64条采样/提交/重建/发布的字偏移、类别、revision、native几何与view身份；不记录正文/完整selector/href，不增await或改行为预算。原隐藏字体fixture复用现有pagedRestoreProbe记录脚本写入；新paged-font选择仅两个原分页字体case（长链私有冻结仅分页，默认仍双模式）。本轮不实施R3，先Windows检查，尚未编译/派发/取得新结果。参考固定Readium3.11 spreadDidLoad/spreadLoaded与native load状态差异；官方源https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift。

最新用户授权（2026-10-21）：先单独查清并修好分页换字体回章头，再继续R3；控制改动/验证范围。当前只读核查原件，尚无生产改动/新CI；分页深字p25/1016→h1原因未定。开始基线build/maintenance/PagedFont-20261021/start.json，保留原HEAD/index及已有改动。新增用户指示：本次工作完成并保存交接后关机，覆盖之前保持开机；尚未安排关机。需要用户决定则保留现场不先关机。手机Codex/Remote入口已询问，主动推送未验证，不能承诺送达。

连续阅读偏移的直接行为已验证；整组仍失败5/6，不能发布。实际源`5340a5b48aecb554fabeb7f1ad6d5da3903eeee8` / [CI39456749155](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39456749155)，原生产控制`a84b6719d17f6a49c5e709ef9d56aa86faa72a8e`。同runner、同测试输入、534+534实际blob核对：旧源指定断言误差10.875点，修正后0.875点（原<3点断言保持）；连续六字体截图后保存字delta全0、字体ready与目标字可见。实际查看六张原生正文图，不代表动效或手机验收。

修正仅在`EPUBReflowableSpreadView.go(to:)`的无限连续canonical DOM分支同时消费完整字锚点与保存的viewport偏移；另同步UPSTREAM摘要。首个仅补native updateViewports的候选129e3506未修好，已撤回；不修改字体/App/Core/依赖/位置格式或预算。默认工作测试仍执行字体两模式；本次私有诊断源的字体链只选连续，不能声称其分页字体链通过。

5项通过：连续resize、EPUB完整锚点重复定位（含分页/连续）、连续六字体重开、分页长段完整字重开、TXT完整锚点返回。唯一失败为分页隐藏换字体用例397行：准备p25/char1016、x1608，结束h1/char0、x0。它与本改动的因果关系尚未证实，不能归咎环境；原CI保持失败/exit65（XCTest同一失败case两条issue），没有生成成功gate回执。用户已确认分页另查，故本轮保留该发布阻塞，不扩改、不重跑凑绿。

Windows456语法新增0/既有54、63工具59通过4POSIX跳过；Linux63工具、Core137、桌面TXT Release探针4通过；原生真实编译0源码错误。原生步骤28分44秒含准备/编译/测试/导出，实际case共189.091秒；首例在步骤开始1196.844秒后才进入，不能把总步骤算作测试或纯编译耗时。161356828字节diagnostic与116316字节Core完整artifact已SHA/CRC核验；原始日志、xcresult、manifest、正反例输入均在build/ci/39456749155，重复ZIP/分片按回执清除。

R3按用户决定顺延，13候选文件仍仅在.cache未接线，未编译或验收。完整187、设备Release、手机验收未执行，无新IPA，最后交付仍Build30。505保护输入、普通HEAD/index保持；没有运行中的本轮CI/observer/download。下一独立片先用已留原件比较分页两个字体请求的完整采样/重载Locator，必要时只跑同fixture最小对照，不盲重跑6/187。

精确回执：Documentation/ValidationLogs/continuous-offset-39456749155.json。历史调查交接可从a84b6719/5340a5b提交及reader-position-investigation回执恢复；不把旧pending段落当当前事实。

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


---

# 2026-10-21后续调查原文（历史，非当前状态）

# 用户最新要求：本轮收完后保存断点，停止补证（2026-10-21早晨）

用户选择“本轮收完后先保存断点”。只收CI39528802200实际结果、完整原件、source与本地验证后结束；不再派发原生补证、不修改新fixture、不推进R3，电脑保持开机。基线文字已核8/9、exit65，唯一失败为旧closing delayed-font-ready576行；新增same-width case旧源before1608/after1608、仍可见，故原生负对照不合格（不能用离线旧0新3618替代该事实）。候选正例仍运行中；即使9/9绿，也不得宣称根因已完整验收/该native屏障能击中旧故障。用户已知补证额外约30分钟冷准备并决定本轮后先停。以下运行资料保留，最终以最新回执为准。

# 当前唯一运行：同宽body resize写入隔离9+9对照（2026-10-21早晨，保持开机）

- CI39528802200，branch codex/diagnose-paged-font-resize-writer，selection=paged-font-control；基线a8125716758aef5802b6d53b3129acc53947c004，精确child候选9bb6c86ff0c500200d1413df0906a6cf9139bbb8，候选ref refs/heads/codex/fix-paged-font-resize-writer。已先原子推两份输入，再派发一次；禁止重复派发。
- 两边完全相同9case和顺序（原8直接位置/字体/TXT/关闭+新testSameWidthBodyResizeDoesNotOverwritePendingPagedWord），长字体私有仅分页、工作默认双模式。原8全文保持。baseline记录原0/65与sameWidthControlledFailure；绿重放/未取得合格控制不等于修复。正例仍要求真实9/9无失败跳过，不放宽断言/预算。
- runtime仅原Readium3.11 readium-reflowable.js体ResizeObserver记前一个O，仅e>0且e!==O时写分页scrollLeft；初次/同宽body尺寸变化不写位置。原O更新、虚拟页、j()进度、连续R()行为与恢复window.scrollTo保持。UPSTREAM新增精确JS override摘要、原baselineFiles摘要保留。Node语法/357 Vendor/456 Swift语法新增0既有54、Bash通过；Windows64工具59过5POSIX跳过（最终driver变化仍须Linux fixture前置）。此源Linux64 tooling前置及Core job已过，原生运行中，无候选结果。离线真实新旧回调+同fixture屏障验证旧0/新3618、真实宽变两边3216、连续一致；该最小DOM stub不代替WebKit/原生验收，回执resize-guard-offline-control.json。
- 新fixture捕获真实body ResizeObserver产生的帧，已验证深字可见后显式queue/release；只在放行回调执行中注入已抓到的旧scrollX0，真实viewport未变；等下一帧后直接断言位置和原字。无短时间窗碰运气；defer close与既有XCTest teardown清理。新增1case后未来完整门槛为188（原187+1），本轮未跑。当前本地verify_ui_baseline.py严格计数已从158提高159，正反例同步；这是未用于本轮native的Python最终门槛校验器变化，未改变本轮冻结的JS/App/UI/9case输入，需单独记录本地工具验证，不冒充本run已跑新validator。
- 503保护输入、普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28保持；R3仍只.cache13文件，未接线/编译，无新IPA/Release/手机验收。用户取消关机，保持开机。
- 冻结/可读JS差异/dispatch证据build/maintenance/PagedFont-20261021/resize-guard-*.json。当前observer .cache/recovery/observe_paged_font_resize_guard.ps1 / session42739（实际PID恢复时核对），记在同目录resize-guard-run/jobs/artifacts.json，恢复先核实际PID/run/source，不沿用旧session。

## 已拒绝候选与成本

39523316446基线1/2（楷体重开target3618后RO写0），4597b345候选实际编译后6/8、exit65，font change原731行仍root setter3618→同RO写0；证明更换primitive不足，已精确撤回Reflowable/UPSTREAM至d4cb607。另continuous resize81行失败，是否测试顺序/旧行为未定，故新对照两边同9case/顺序保留该控制，不扩改连续。完整178163935字节artifact已SHA/CRC核，原件build/ci/39523316446/diagnostic；Core137/TXT4独立通过、116279字节核验。旧观察器已停止，旧run已自然结束。以下旧断点均为历史，以本节和真实输入/日志为准。

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

