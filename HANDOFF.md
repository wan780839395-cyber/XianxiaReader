# 当前工作：先核正文定位疑点，再推进R3第一片（2026-10-20）

## 当前断点：连续偏移第二候选，分页另查（2026-10-21）

用户确认本轮只收口连续偏移，分页字体章头问题独立排查，R3顺延。39447634363/129e3506已完成失败：旧runtime负对照在指定断言失败10.875点；补updateViewports候选同样失败，不能验收，已只撤回其InfiniteScrollView和UPSTREAM两文件。完整156223138字节原件已核SHA/CRC并提取，原始退出65与两个失败保留；修正组3/5，另一项为分页字体重开章头，未走连续修改路径。

下一实验只改ReflowableSpreadView已有canonical DOM定位：无限连续模式在WebKit内部消费同一个字锚点与xianxiaViewportOffset；分页原分支保持。相同测试输入先运行原生产1例指定负对照，再运行6个直接用例（明确加入原分页完整字锚点回归；本次私有诊断字体链仅连续，默认仓库仍两模式）。原3点断言/预算、完整Locator/依赖/字体/App/Core保持，不增加等待重试，不导出IPA。新假设是内层默认文本定位忽略保存的viewport偏移；此前一行同步失败只排除该候选，不能冒称已捕获迟到写入者。

生成/检查/冻结前更新本断点；第二候选已实施，当前未编译/验收，先执行Windows检查后冻结同输入A/B。完整187、设备Release、手机验收未执行，R3候选仍只在.cache不接线。旧分页字体问题继续作为发布阻塞项。


当前唯一远程运行：修正源129e350605d9c81169827ee013237bae10120fb5 / codex/fix-continuous-position-offset / CI39447634363；负对照runtime bc95fac052937f4a0c15c3794d733ede4d25aefa。2026-10-20 15:56UTC独立REST核run仍in_progress，repository-checks与Core已success，原生控制步骤运行中。原push成功但后续git ls-remote因schannel握手失败，已用REST ref核同一SHA且确认没有既有run后仅派发一次；offset-fix-frozen.json含恢复核对。原observer三次网络读取失败退出，不是CI失败；查实际任务后已恢复只读观察。默认原生步骤不分内部阶段，未见原件前不能猜基线/正例是否执行或通过。

即将派发有确定性控制的修正验证：负对照runtime bc95fac052937f4a0c15c3794d733ede4d25aefa，沿用原生产文件；正例候选仅在EPUBInfiniteScrollView.go的外层setContentOffset后补已有updateViewports，并同步UPSTREAM该文件摘要/理由。内层DOM已移动但外层坐标不变时，主动同步不能依赖外层delegate回调。App/Core/字体/锁/工程均保持；507保护输入只有这2个Vendor文件例外，其余505不变。截图后位置检查已由观察升级为真实断言，原断言与预算保留。

Windows本候选456语法新增0/既有Vendor54、63工具59通过4明确POSIX本机跳过（35.888秒）、两Bash语法通过；已静态核XCTest autoclosure无await，尚未Swift编译。本次新增POSIX控制驱动fixture先在Linux前置执行，覆盖浅clone、预定红转绿、基线意外绿、错误失败、修正失败；它先通过才开始原生编译。原生同一runner先执行旧源1例，必须原exit65且唯一失败标记LATE_CANONICAL_VIEWPORT_OFFSET；再以相同测试输入/DerivedData执行修正版5例，不增加重试、放宽预算或生成IPA。R3按用户选择顺延，.cache暂存13文件不接线。

最新结论：第三轮1d8c696/39439273417连续单例1/1通过，但新增只读几何在楷体、思源黑体均复现保存同字的top从预期-9.9375变为0.0625、delta10，截图前后持续；两个Range方法一致且只含一个片段。证据snapshot-geometries.json及完整8345530字节原件已SHA/CRC核验，不能把1/1写成定位已修。旧三组baseline/R2完整Locator内容逐字段相同，已排除保存内容差异。

候选原因收窄到EPUBInfiniteScrollView.go：内层DOM先执行go，外层若坐标没变，依赖scrollViewDidScroll的updateViewports可能不再执行；初始load路径已有主动updateViewports。先构造确定性负对照：原FreshReturn测试在连续模式重复定位同一canonical字/offset=-10，保持外层坐标不变并显式屏蔽该次外层scroll回调；完整生命周期清理恢复delegate。旧源码必须在指定LATE_CANONICAL_VIEWPORT_OFFSET断言失败，才在同一runner/DerivedData验证仅补updateViewports的一行修正与5直接回归（EPUB重复返回、真实字体两模式、隐藏重排、连续resize、TXT完整锚点返回）。不新增target/修改依赖/位置格式/预算。负对照不成立或失败位置不同则终止后半实验，不盲跑修正。

本片R3继续顺延。新增截图后保存字delta<3及原目标字仍在位的断言，补上原测试只检查一次ready而遗漏后续偏移的覆盖。scripts/ci_position_offset_control.sh明确保存旧exit65及真实失败原件，要求指定负对照后修正5/5；不导出IPA。首次Windows语法已过，尚未冻结负对照或修改Vendor；工具中新增POSIX驱动fixture在Windows明确未执行，Linux前置将先验证四种成功/错误结果及浅clone，再允许原生job。

正在执行第三个有条件变化的单例：1d8c696409f2e677df5da0290386bcdf479c3419 / codex/diagnose-position-native-snapshot / CI39439273417，selection仍position-observation、私有测试仅连续模式。仅删除已证实不支持的Promise，改在原有UIGraphics原生截图之后复用同一String JSON观测函数；没有新的异步JS API/等待。默认工作文件仍保留两模式。source/frozen/dispatch为snapshot前缀；observer.cache/recovery/observe_position_snapshot.py保存snapshot-run/jobs/artifacts，恢复须先核实际run和进程，不能重复派发。当前未有第三轮行为结果；R3继续未接线、生产507保护输入及普通index保持。前两轮分别在封面准备、Agent诊断桥接中断，不能将三轮混成通过。

最新断点：第二轮97cd5ce/39434816178已完成失败。有效前景/连续封面已过（activeHref=cover.xhtml、legacy同一view、alpha1、hostAppeared=true），首个思源宋体原定位断言通过，两个点实际top/expectedTop均-9.9375、delta0；随后Agent新增evaluateJavaScript返回Promise导致WKErrorDomain5，整例0/1、31.242秒，后续五字体未执行。属于诊断错误，不能归为正文失败或初始化根因已修。83626657字节原件已SHA/CRC核验完整提取build/ci/39434816178/diagnostic，完整日志continuous-completed-job.log。用户已被明确告知这项错误及R3继续顺延。

已删除该Promise和额外两帧等待，改在既有原生截图之后第二次读取String JSON（after-native-snapshot），原断言/预算保持；这不是“两帧稳定”证明。下一轮沿同一连续单例、原生产源、原字体序列，不重复分页链，不新增生产代码。派发前核Swift语法与冻结差异，若再次在准备/诊断阻塞则依据新原件改变实验，不能盲跑。

最新用户决定：本轮只查清定位，R3顺延；禁止接线暂存R3候选。CI39428259337/5e2209c原生编译通过，但整例0/1：分页六内置字体走完，进入连续模式初始cover.xhtml时20秒超时，DOM为blank且未发位置，未到连续疑点；不是新增几何观测抛错。原生步骤32分16秒、整例136.633秒，不能把步骤耗时当测试耗时。完整113201043字节diagnostic已SHA/CRC核验并提取build/ci/39428259337/diagnostic，下载重复分片/ZIP按回执清除；完整job日志native-completed-job.log与run/artifacts保留在build/maintenance/R3-20261020。

第二次最小实验已派发97cd5ce671696b0d67084f92f3ab103d4305412c / codex/diagnose-continuous-position / CI39434816178；Linux前置通过、原生步骤运行中，尚无行为结果。私有commit只选择原test连续分支，工作目录默认test仍有两模式。observer为.cache/recovery/observe_continuous_position.py，continuous-run/jobs/artifacts/frozen均独立命名；首轮旧证明不覆盖。新观察会同时核切换前/实际保存两点、片段/合并矩形与后续帧。旧false与true的同字体inner offset差约10点，xianxiaViewportOffset约-9.9375，新增假设为迟到DOM定位忽略偏移；只作线索，尚不改Vendor。

外部复核：Apple公开viewDidAppear文档（https://developer.apple.com/documentation/uikit/uiviewcontroller/viewdidappear(_:)）说明出现生命周期；固定Readium3.11 SwiftUI指南（https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/docs/Guides/Navigator/SwiftUI.md）用真实父控制器与有效view.bounds挂载；WebKit iOS测试窗口（https://github.com/WebKit/WebKit/blob/main/Tools/WebKitTestRunner/ios/PlatformWebViewIOS.mm）显式makeKeyAndVisible及析构隐藏。后者为查阅时main快照，并非iOS18.5锁定版本，只参考窗口fixture管理，不移植其私有API；生产不变，当前候选按本项目既有公开UIKit fixture约束输入。

静态发现封面probe的visibleWebView只检查几何，忽略隐藏/scroll alpha；本项目连续模式存在同层blank WebView（R2附件alpha0）与活动资源WebView。尚未证明此轮封面超时唯一原因。下一最小实验：同一原test仅执行连续模式（私有诊断commit的模式选择，默认完整test继续两模式）；原所有断言、字体序列和20秒资源预算保持。开始前采用现成open(engine) fixture相同的前景/hasAppeared条件；封面probe显式选择readium.chapter.0，成功后记录旧候选href/alpha与真正候选对照；超时保留host与所有native WebView状态。仍保留两锚点几何与后续帧观察。此处是诊断输入有效性修正，不宣称生产初始化或正文根因已修。

用户授权先查清断言后连续模式锚点不匹配，确有问题则修复，再继续位置隔离。先复用39418977905与39411950208完整附件；尚未开始新CI。假设分支：真实布局后移/旧回调回跳，或测试期望锚点与实际重开后锚点不同。必须核清样本所属阶段和坐标，不能仅凭非零offset否认位置问题，也不能把后续false倒写成原断言失败。

本步先限于原测试与原件的只读分析；诊断必要时仅改ReaderRenderingTests的一组观测，不放宽原断言/3秒采样/20秒加载预算，不改Vendor/依赖/字体/界面。结论可恢复后另定义R3最小文件/行为合同，再提取位置捕获、保存、失败保旧、旧请求过滤；不同时提取会话或导航。实现、编译、定向、完整、原生及手机状态分别记录。保留R2所有完成改动和旧失败。

初步只读证据：39418977905小薇/连续的visible-before-save模型锚点p25/443，save-returned、closed、open-returned均p25/436、viewportOffset=-9.9375；后续PNG仍显示长段016处。说明不能将旧目标字false直接等同保存锚点丢失，但缺少Range几何，尚不能收口。W3C CSSOM View https://www.w3.org/TR/cssom-view/#extensions-to-the-range-interface 区分Range片段列表与合并边界框；本地固定Readium3.11的continuousAnchorRectFunction优先getClientRects()[0]，原测试用getBoundingClientRect，需实际测量，不能从规范推定本次原因。

恢复点：最小实验已冻结5e2209c6182896a937e987b205e10abc0c87286a / codex/diagnose-position-observation / CI39428259337；仓库与Linux Core阶段通过，原生步骤运行中，尚无最终回执。只读observer脚本.cache/recovery/observe_position_observation.py保存observation-run/jobs/artifacts到build/maintenance/R3-20261020；恢复先核实际进程/远程run，禁止重复dispatch。实时job日志API不可用，原错在native-live-log-unavailable.txt，不据此判断挂起。

R3a候选只存在.cache/recovery/r3-candidate/tree（11文件），未接入App/Packages实际构建根目录。方案见Documentation/READER_POSITION_ISOLATION.md；候选5 Swift语法通过、135源/18节点静态接线通过、6种禁用import逐一拒绝，VM40处await表达式及顺序保持。候选检查曾发现依赖登记顺序不匹配，已在暂存区纠正，未派发失败原生试验。尚无Swift编译或R3运行验收；必须先依据定位附件作结论，再决定应用候选。普通HEAD/index和所有既有工作仍保持。

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
