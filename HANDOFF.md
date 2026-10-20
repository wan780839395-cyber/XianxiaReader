# 当前工作：先核正文定位疑点，再推进R3第一片（2026-10-20）

用户授权先查清断言后连续模式锚点不匹配，确有问题则修复，再继续位置隔离。先复用39418977905与39411950208完整附件；尚未开始新CI。假设分支：真实布局后移/旧回调回跳，或测试期望锚点与实际重开后锚点不同。必须核清样本所属阶段和坐标，不能仅凭非零offset否认位置问题，也不能把后续false倒写成原断言失败。

本步先限于原测试与原件的只读分析；诊断必要时仅改ReaderRenderingTests的一组观测，不放宽原断言/3秒采样/20秒加载预算，不改Vendor/依赖/字体/界面。结论可恢复后另定义R3最小文件/行为合同，再提取位置捕获、保存、失败保旧、旧请求过滤；不同时提取会话或导航。实现、编译、定向、完整、原生及手机状态分别记录。保留R2所有完成改动和旧失败。

初步只读证据：39418977905小薇/连续的visible-before-save模型锚点p25/443，save-returned、closed、open-returned均p25/436、viewportOffset=-9.9375；后续PNG仍显示长段016处。说明不能将旧目标字false直接等同保存锚点丢失，但缺少Range几何，尚不能收口。W3C CSSOM View https://www.w3.org/TR/cssom-view/#extensions-to-the-range-interface 区分Range片段列表与合并边界框；本地固定Readium3.11的continuousAnchorRectFunction优先getClientRects()[0]，原测试用getBoundingClientRect，需实际测量，不能从规范推定本次原因。

最小实验position-observation：只执行原真实字体长链1例，保留原所有断言和预算；附加切换前/实际保存两锚点的rect/rects、scrollY和viewport offset，以及连续模式两呈现帧后的只读采样。生产App/Packages/Vendor/字体/工程/锁均保持7c33645，只增加该测试诊断与workflow/脚本选择。Windows语法已通过（456、新增0/既有54）；62工具仍在执行。普通HEAD/index及1157源文件SHA基线保留build/maintenance/R3-20261020/start.json，源快照r3-start-sources.zip。尚未派发新CI；下一步核工具结果、冻结4个文件、仅派发此1例。若不再出现false也不能追认旧观察根因已修。

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
