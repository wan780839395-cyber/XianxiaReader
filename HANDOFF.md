# 当前断点：本轮已收齐，按用户选择保存，停止补证（2026-10-21）

用户明确选择“本轮收完后先保存断点”。本轮已经自然结束、完整证据已收齐；不再派发补证、不继续修改fixture、不推进R3。电脑保持开机，不安排关机。下次仅在用户明确继续后恢复。

## 本次中断恢复核对

2026-10-21恢复时发现：CI及完整产物收集、分项验证和文档已完成；尚未落盘的是最终Git检查点与进程回执。本次仅补齐这两项，未改生产/fixture、未重新测试或派发CI。实时核对CI39528802200已success，最近20轮没有活动任务，本轮observer/download进程为0；503原保护输入与普通HEAD/index保持。保存正常双模式字体测试默认值，不把它冒充已执行的私有分页单模式9/9。具体检查点与收口凭据见下文final-checkpoint.json和final-processes.json。

## 事实与验收边界

- CI39528802200 success；workflow HEAD是基线a8125716758aef5802b6d53b3129acc53947c004，实际安装/编译候选9bb6c86ff0c500200d1413df0906a6cf9139bbb8，由patched-inputs.json证明。两边536实际输入逐blob/SHA核验；相同9case/顺序、原断言和预算不改。
- 基线8/9，exit65，唯一失败旧testClosingDuringDelayedFontReadyCannotNavigateOrNotifyNewReader原576行。候选9/9、exit0、失败/跳过0，两边源码编译错误0。不能把基线的关闭失败当分页负对照，也不从一次正例推出关闭时序旧问题已修。
- 新testSameWidthBodyResizeDoesNotOverwritePendingPagedWord两边before1608/after1608、word可见，旧代码也通过，sameWidthControlledFailure=false。原生可控负对照未命中，尚不合格；源码候选保留、分页问题不写成已彻底修好/完整收口。
- 候选六字体分页原链均真实loaded、无font/errorMessage、目标字可见、保存字delta0；采样在既有native截图之前，不是分页截图后断言。私有冻结该长链仅分页，工作默认仍双模式；其他真实捕获/关闭/TXT/连续控制按原9项执行。图片未逐张目视，不作完整原生视觉/动效/手机验收。
- 生产候选只改固定Readium3.11的readium-reflowable.js body ResizeObserver：记录前一个页宽O，只有e>0且e!==O才执行原分页对齐；初次/同宽正文尺寸通知不写位置。O更新、虚拟页和j()进度通知、连续R()及canonical恢复window.scrollTo保持。UPSTREAM新增精确JS override，pristine baseline摘要保留。无R3提取、App/Core/字体/依赖/Locator/预算变化。
- 离线真实回调+同一屏障的最小DOM stub旧0/新3618、真实宽变两边3216、连续一致，仅证明该算法边界，不替代原生负例。不能隐去原生屏障未命中的事实。

## 已完成检查、成本与保全

Windows456语法新增0/54既有Vendor限制、357 Vendor来源、Node运行/fixture语法和Bash通过；语法不是编译。Linux本run64 tooling前置、Core137不同身份与TXT Release探针4通过。新增1项回归后未来完整门槛159集成+29UI=188；本地最终校验器158→159及8个正反例通过0.237秒，该Python计数器更新未用于本次native源，不冒充本run已验该工具版本。

基线原生步骤2347秒，首例前1879.387秒含准备/编译/启动，case合计256.171秒；暖环境候选步骤428秒、首例前195.202秒、case203.380秒。不得把39分钟基线步骤写为测试或纯编译耗时。

完整diagnostic123747635字节、baseline文字194581字节、Core116279字节均GitHub digest/SHA/ZIP CRC核验；原件在build/ci/39528802200，含两边raw xcresult/完整日志/附件/实际输入。重复ZIP/分片按各download-receipt删除；当前开发证据保留，未做历史清理。原失败39523316446完整178163935字节也保留。

普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index SHA256 b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28保持；503保护输入与实际编译Vendor源码保持。完整188、设备Release/普通设备/TrollStore/手机验收未执行，无新IPA，最后交付仍Build30。R3的13候选仍仅.cache，未接线/编译。

权威回执：[本轮完整分项](Documentation/ValidationLogs/paged-font-resize-39528802200.json)、[累计调查](Documentation/ValidationLogs/paged-font-investigation.json)。冻结/离线/逐blob/计时/保全在build/maintenance/PagedFont-20261021/resize-guard-*。最新私有checkpoint及进程收口信息见同目录final-checkpoint.json/final-processes.json；普通HEAD/index不改。

## 用户继续后的下一项区分实验（本轮不执行）

先查为何新native屏障让旧源也保住1608：仅记录被捕获的实际Readium ResizeObserver/frame源码指纹、href、附窗/可见与初始化状态、注入scrollX getter命中次数、水平写入尝试及顺序。先证明故障注入确实进入目标writer；不加几何读取、固定等待或重试，不凭Node stub推断WebKit。屏障合格后只考虑旧/新单用例1+1，不重跑9/188。用户已明确本轮到此，不能把这段计划当作自动执行授权。

此前root setter4597b345实际6/8、分页仍被同RO写0，已精确撤回至d4cb607；失败原件与原因保留。其连续resize81行失败、本轮基线closing576行失败分别记录发布影响，未证明与本JS守卫相关，不扩修/归咎环境。旧逐轮交接在[分页调查历史](Documentation/HANDOFF_PAGED_FONT_INVESTIGATION_2026-10-21.md)，其中运行/关机说法为历史，以本节和真实证据为准。

## 上一片连续偏移（保留）

5340a5b/39456749155同runner旧源10.875点→修正0.875点，原<3点断言保持；连续六字体截图后delta0、字体ready、目标字可见。整组5/6，分页字体失败未消除发布阻塞。仅无限连续canonical DOM内消费完整字锚点和viewportOffset；native updateViewports失败候选已撤回、InfiniteScrollView原字节保持。详见ValidationLogs/continuous-offset-39456749155.json；不算R3或完整发布。

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
