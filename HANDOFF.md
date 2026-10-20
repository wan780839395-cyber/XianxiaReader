# 当前断点：连续偏移直接验证完成；分页另查，R3顺延（2026-10-21）

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
