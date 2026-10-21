# 当前断点：分页字体回章头缺陷定向收口，下一切片R3（2026-10-21）

用户授权先确认分页问题，再做R3；首组暴露屏障越界后，用户明确只再补一组1+1。两组已自然结束，追加组39561815911成功；本轮不再派发第三组，不在收尾混入R3。保持电脑开机。

## 已确认的行为与来源

- 实际旧源4e6504624fac4d786247c8df07d42460cf1f67b9、实际修正af9b773c7fc04198432f4af238524af62cdf29a5为exact child；同一fixture/预算/原断言，且只差Readium JS+UPSTREAM。旧/新runtime分别字节同a812571/9bb6c86。workflow HEAD是旧源，不误当实际候选。
- 真原生单case各一次：旧1608→0、char1200不可见、原两行为断言失败，test65；新1608→1608、原字可见，test0、1/1、失败/跳过0。合格负对照true，原生已载入回调/帧源码均与对应Git源码匹配，两边536输入逐blob/SHA核验，源码编译错误0。
- 旧snap读取注入0并真实委托root scrollLeft写0；旧后续进度读取原生0/injected=false。新没有snap读取或任何root位置写入，唯一进度读取真实1608/injected=false。只把故障注入到目标writer，未改变其后续正常通知；真实宽变两边3216、连续一致仅在离线语义检查，不能冒充此run原生旋转覆盖。
- 生产修复仍只有固定Readium3.11 body ResizeObserver：初次/同宽正文尺寸通知不再重写位置，真实页宽变化继续原对齐；O更新、虚拟页、进度通知、canonical恢复保持。当前4个Vendor文件仍字节同9bb6c86，App/Core/字体模块/依赖/Locator/预算未改。此前同生产39528802200实际9/9、六分页字体目标字可见/保存delta0，单列历史正向证据，不冒充这轮重新执行字体链。

## 屏障问题与历史限制

首组39557140861旧1608→0，新虽无root写入却1608→804，均test65；新侧唯一注入0来自进度函数j，证明屏障污染第二所有者。追加组仅将该进度读委托原活getter，同生产守卫保住1608；原两断言不放宽。先前离线空j漏掉共享读取，是本次可避免的额外冷准备成本，教训已写入CHANGE_AND_DIAGNOSIS_WORKFLOW。新fixture从真实帧尾取进度函数名并核JSC栈，版本/帧尾或活getter变化直接失败；driver有进度被误注入时必须拒绝的反例。

旧39528802200没有回调/读写证据，旧源重放为何未复现的精确历史原因不能倒推。本轮已经形成合格负/正对照并排除所查writer，不能编造成“旧绿灯确实是捕错回调/环境原因”。旧关闭字体576行失败、此前连续resize81行失败仍独立记录发布影响；本片通过不抹去旧失败或证明所有位置时序问题都已消失。

## 验证、原件与成本

Windows456语法新增0/54既有Vendor限制，64工具59过5POSIX跳过/24.365秒；Bash/Node通过。最终Linux64/64（含driver6种情形）、Core137不同身份、TXT Release4通过，完整原件已核。语法不是编译；此run真实iOS模拟器编译和原行为单例另列。

最终基线步骤1879秒，首suite前1701.584秒，case14.425秒；暖候选步骤266秒、首suite前223.072秒、case11.353秒。此前失败组基线1517秒/case10.259秒，候选270秒/case6.913秒。首例前包含工具/依赖/模拟器/编译/启动，不能称纯编译或纯测试；完整步骤还含关闭/导出。原生选例不等于减少所有scheme编译成本，本轮没有混改缓存工程。

最终diagnostic93204220、baseline文字120130、Core116313字节，均GitHub digest/SHA/ZIP CRC核验；全原件在build/ci/39561815911，两边xcresult/完整日志/附件/实际输入保留。失败组144009926字节完整原件在39557140861；重复ZIP/分片已按精确回执清除，未做历史批量清理。最终权威：[成功分项](Documentation/ValidationLogs/paged-font-control-39561815911.json)、[失败组](Documentation/ValidationLogs/paged-font-control-39557140861.json)、[累计调查](Documentation/ValidationLogs/paged-font-investigation.json)。

完整188、设备Release、普通设备/TrollStore、手机/动效未验，无新IPA；最后交付仍Build30。此片只做故障注入及定位行为验收，没有新正文图目视验收。普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index SHA256 b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28与503保护输入保持；全部其他Rendering方法与正常字体双模式默认值保持。

本轮资料build/maintenance/PagedFontControl-20261021，最终保存信息见final-checkpoint.json/final-processes.json；普通HEAD/index不改，快照不等于该文档提交运行过完整发布。当前没有活动CI/observer/download；最终进程核对以回执为准。

## 下一独立切片

R3完整位置隔离仍未实施。13候选只在.cache/recovery/r3-candidate/tree，不能直接接线或写成已编译；先审阅最新真实文件与await/发布/同步提交顺序，明确位置状态、完整Locator持久化、取消/旧回调负责人和定向入口，再小步推进。当前已收口的分页writer回归必须保留，R3不改字体/设置/会话边界、依赖、位置格式或预算；完整188与Release设备门槛留I6。全项目隔离仍未完成，后续产品计划保留。

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
