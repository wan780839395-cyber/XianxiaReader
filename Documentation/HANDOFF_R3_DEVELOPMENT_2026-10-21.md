# R3a开发与首轮接线失败历史

以下为收口前交接/设计原文快照，最新状态见HANDOFF与project-isolation-r3a.json。

# 当前断点：R3a独立包修正已冻结，定向CI39573863939运行中（2026-10-21）

实际源755b428a60143d8f649372e6c545cc1e03f82ecb，codex/maintenance-position-state-r3a；修正回执build/maintenance/R3a-20261021/corrected-frozen.json。ReaderPositions独立包→原Core产品；位置/6测试/App/Vendor字节保持首源，Core manifest恢复原件。只跑同6+13；新独立6项步骤已过/103秒，原生build-for-testing已越过首轮缺CSQLite规划点并执行实际构建任务；尚未收齐13项原测试。之后boot及原test动作保留。首轮39569845077/原生test65、0项与完整证据保留；Windows459语法新增0/54既有、71工具65过6 POSIX跳过通过。普通HEAD/index保持，未改运行预算，无新IPA。

# 当前断点：R3a原生接线失败已留证，修正包边界（2026-10-21）

首源a9d4e84/CI39569845077：真实macOS独立6/6、Linux仓库/工具通过；原生test65、summary/export0，0项执行。完整59180字节artifact已核GitHub digest/SHA/ZIP CRC，原件build/ci/39569845077，独立xUnit与Core无外部依赖已重新核验。错误为XianxiaCore自动dynamic产品的BuildFile引用缺失PACKAGE-TARGET:CSQLite，发生在测试前构建规划；不归因定位行为或环境、不写成原生通过。

新假设/最小改动：同Core包新产品直接依赖Core target，与既有外部产品消费者触发Xcode动态产品规划冲突；这是结合错误与接线差异的推断，待新实际构建验证。改用现有ReaderSettings已验证布局：ReaderPositions为独立Foundation包，通过.product依赖原Core产品；业务代码/6测试/App调用不变，Core manifest恢复原件、SQLite SDK/链接/资源/锁不变。不强制改Core static/dynamic、不升级依赖。仍只验证同一6+13合同，不混入R3b/全188。

参考SwiftPM target/product官方规则、GRDB维护者在Swift Forums对相同dynamic+SQLite缺target错误的说明；说明不是本项目根因证明，最终需实际接线编译。独立包接线与先编译再boot的本片入口已修正，本地459语法新增0/既有54、71工具65过6 POSIX跳过（24.093秒）、Bash和静态边界通过。即将冻结独立包接线，仍仅6+13，不重跑全套。保留首轮失败原件及失败预算，不能覆盖成功。

# 当前断点：R3a已冻结，定向CI39569845077运行中（2026-10-21）

实际源a9d4e8424c01c6163af89d2f127f5a4caedffee7，codex/maintenance-position-state-r3a；只选position-isolation的6独立+13原生合同。1170原有输入中1157保持，35原测试输入保持，所有原await表达式/顺序及其他VM方法保持。仓库/工具Linux步骤已过；macOS独立6项合同步骤已通过（2分21秒，原件待最终下载复核），正在XcodeGen/原生工程冷准备，13项原用例尚未收齐。普通HEAD/index及既有WIP保持，无新IPA。恢复先核run、frozen.json、完整日志与实际文件。

# 当前断点：R3a 位置状态与保存请求隔离，开始实施（2026-10-21）

用户明确继续R3，保留现有功能和已修好的定位行为。本轮只做R3a：ReaderPositions Foundation-only真实target负责完整ReadingPosition、显式保存请求身份/失效、保存错误。App仍在原调用点执行捕获、原3秒/32ms预算、慢滚/设置flush及数据库await；不新增async封装。返回点/导航、捕获持久化编排与统一会话后续单列，不能称R3整体完成。

影响文件：新ReaderPositionState及6项独立合同；ReaderViewModel/ReaderProgressView同步接线；Core manifest/project.yml、架构登记及禁止UI/引擎依赖反例；快速入口/证据核验、影响映射、CI新增position-isolation选项。旧缓存整体覆盖会删除最新分页入口，禁止整包复制。原VM其他方法、现有iOS用例、Vendor四项定位修复、设置/字体模块、资源、锁与数据库实现保全。

定向门槛：Windows仓库/语法与工具；macOS独立6项真实SwiftPM合同（无App/Readium）；原iOS保存/进度/迟到结果8项生命周期+1项进度；真实EPUB/TXT完整锚点重开、同宽分页writer、双模式字体重开4项，共13项原生用例。冻结后仅派发这一组，不跑完整188/设备Release/导包。SwiftPM使用--parallel --xunit-output并核对精确测试身份与实际依赖。原断言/预算不变；失败保留原件并证明关联后再决定。

本轮保全快照：build/maintenance/R3a-20261021/before.json及HANDOFF-before.md；普通HEAD/index保持，旧CI已完成且无活动本地观察/下载任务。最后已验分页1+1的事实见下文；R3a源码/接线及快速入口已完成。Windows458语法新增0/既有Vendor限制54，71工具65通过/6 POSIX跳过（24.158秒），Bash语法通过；尚未Swift编译/原生验收。冻结前核对全部1170已有输入、原用例与VM await表达式/非本片方法，随后只派发position-isolation（6+13），不继承旧片验收。

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


---

# R3 阅读位置隔离

## 首轮接线失败与最小纠偏

CI39569845077/源a9d4e84已保留完整原件：macOS真实6/6、原生test65/0项执行；Xcode16.4生成的XianxiaCore dynamic产品规划引用缺失CSQLite target，尚未进入源码编译/测试。本轮新增Core包内产品直接依赖Core target是相关结构差异；结合错误推断为产品/内部target消费混合的规划问题，尚不能当作精确根因证明。

改为现有ReaderSettings的成熟本地模式：独立Packages/ReaderPositions，原状态源与6测试字节迁移不变，显式.product依赖原XianxiaCore；Core manifest恢复首轮之前的原件，不强制改变Core静态/动态类型，不改SQLite SDK链接/依赖锁。架构登记、project.yml、快速入口和精确依赖核验随之调整。新依赖树必须只有ReaderPositions→XianxiaCore，Core无外部依赖。完整Core仍137项，位置6项由ci_ios.sh独立执行并保留原件，iOS完整188不变。

仅本片position-isolation入口在模拟器boot前先对同一个选定destination执行标准build-for-testing，保留PositionBuild.xcresult与真实错误退出码；原xcodebuild test随后复用正常编译产物，原13项/断言/预算不变。提前发现接线故障，避免先支付模拟器迁移成本；不修改其他诊断或发布测试时序。此构建步骤不是测试通过，也不能替代原13项执行。

参考：[GRDB维护者对相同dynamic+SQLite缺target报错的说明](https://forums.swift.org/t/errors-on-build-after-add-package-grdb/76189)。其Xcode16.1案例涉及同时嵌入GRDB/GRDBDynamic，本项目16.4未声明这两个产品，只能借鉴检查产品消费路径，不能照抄为本项目已证原因。实际选择独立包来自本项目已验ReaderSettings布局和SwiftPM官方显式产品依赖规则；新原生构建仍须验证。

以下Core包内布局与143项描述为首轮设计历史，已由独立包/Core137+位置6取代。


## 2026-10-21 R3a 当前实施合同

本轮用户授权继续R3，先交付位置状态与显式保存请求隔离。源码初稿已接线，尚未Swift编译/原生验收。旧候选只复用经过当前差异审阅的10个文件；当前分页控制workflow、断言、故障注入和字体双模式默认值保留。

ReaderPositions是现有Core包内独立产品/target，只依赖XianxiaCore业务值与Foundation。它唯一保存不透明ReadingPosition、显式保存令牌/所属会话和保存错误；不解析Locator、不持有引擎/仓库/字体/界面、不自行创建异步任务。ReaderProgressState仅将同步位置通知转换为原去重摘要，完整位置不再由UI容器另存一份。错误继续在突变前通知ReaderViewModel；位置事件不触发整个ViewModel刷新。

saveNow中的每个await、guard、3秒截止/32ms既有间隔、固定布局分支、慢滚暂停/flush、设置flush和写库调用保持原调用点及顺序。新令牌判断等价于原会话ID+请求ID判断；旧defer只能结束自己的请求，关闭使令牌失效，保存失败保留完整位置，成功先发布完整位置再清除错误。close仍允许引擎发出最后位置回调后才使openRequestID失效。导航/返回点和会话生命周期不是本片迁移对象。

快速入口为`bash scripts/test_reader_positions.sh <新的输出目录>`，真实SwiftPM只执行6项状态合同，要求原始xUnit全部精确身份、无重复/失败/跳过、Core包无外部依赖；保留真实退出码。workflow新增`position-isolation`：仓库/工具检查后，同一macOS runner先6项独立合同，再原13项iOS用例（8保存/生命周期+1进度+4真实EPUB/TXT/字体/同宽writer）；不跑Core性能探针、完整188或设备导包。脚本会编译原scheme其他target，选例不能消除所有冷准备成本。

6项合同不接入iOS测试源，既有159集成+29UI数量保持188；完整发布流程照常测试Core包（原137+本片6=143），不以本定向结果代替I6。现有iOS用例主体、Vendor四项修复及资源/锁/数据库实现按输入哈希保全。运行证据及保护快照在build/maintenance/R3a-20261021，状态以HANDOFF最新记录为准。

取舍参考已复核[SwiftPM官方target/product与testTarget规则](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)和[isowords实际功能target依赖布局](https://github.com/pointfreeco/isowords/blob/main/Package.swift)。仅借用显式target依赖与独立测试的做法；保留本项目tools5.10、iOS16/macOS13、Xcode16.4，不迁移其TCA/iOS下限或远程依赖。纯同步提取避免重演R2新增挂起点的问题。

R3a完成后，捕获/写库编排、导航与返回点的责任迁移仍属于R3后续切片；状态模块落地不能写成R3整体或全项目隔离完成。

2026-10-20。当前为切片设计，尚未实现/编译/验收。用户最新选择本轮只查清定位、R3顺延；候选仅在.cache暂存，不接入构建根目录。不将R2的53/53复用为本片结果。

## 连续直接验证与分页未决（2026-10-21）

连续阅读偏移的直接行为已验证；整组仍失败5/6，不能发布。实际源`5340a5b48aecb554fabeb7f1ad6d5da3903eeee8` / [CI39456749155](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39456749155)，原生产控制`a84b6719d17f6a49c5e709ef9d56aa86faa72a8e`。同runner、同测试输入、534+534实际blob核对：旧源指定断言误差10.875点，修正后0.875点（原<3点断言保持）；连续六字体截图后保存字delta全0、字体ready与目标字可见。实际查看六张原生正文图，不代表动效或手机验收。

修正仅在`EPUBReflowableSpreadView.go(to:)`的无限连续canonical DOM分支同时消费完整字锚点与保存的viewport偏移；另同步UPSTREAM摘要。首个仅补native updateViewports的候选129e3506未修好，已撤回；不修改字体/App/Core/依赖/位置格式或预算。默认工作测试仍执行字体两模式；本次私有诊断源的字体链只选连续，不能声称其分页字体链通过。

5项通过：连续resize、EPUB完整锚点重复定位（含分页/连续）、连续六字体重开、分页长段完整字重开、TXT完整锚点返回。唯一失败为分页隐藏换字体用例397行：准备p25/char1016、x1608，结束h1/char0、x0。它与本改动的因果关系尚未证实，不能归咎环境；原CI保持失败/exit65（XCTest同一失败case两条issue），没有生成成功gate回执。用户已确认分页另查，故本轮保留该发布阻塞，不扩改、不重跑凑绿。

Windows456语法新增0/既有54、63工具59通过4POSIX跳过；Linux63工具、Core137、桌面TXT Release探针4通过；原生真实编译0源码错误。原生步骤28分44秒含准备/编译/测试/导出，实际case共189.091秒；首例在步骤开始1196.844秒后才进入，不能把总步骤算作测试或纯编译耗时。161356828字节diagnostic与116316字节Core完整artifact已SHA/CRC核验；原始日志、xcresult、manifest、正反例输入均在build/ci/39456749155，重复ZIP/分片按回执清除。

R3按用户决定顺延，13候选文件仍仅在.cache未接线，未编译或验收。完整187、设备Release、手机验收未执行，无新IPA，最后交付仍Build30。505保护输入、普通HEAD/index保持；没有运行中的本轮CI/observer/download。下一独立片先用已留原件比较分页两个字体请求的完整采样/重载Locator，必要时只跑同fixture最小对照，不盲重跑6/187。

## R3a：完整位置状态与保存请求身份

定位前置核查最新：39439273417给出有效几何，楷体与思源黑体在原断言后及原生截图后，保存字top=0.0625、expected=-9.9375、delta10，rect/rects完全相同。候选最小修正复用初始load已有updateViewports，在显式go设置外层offset后同样无条件同步一次，避免同坐标时没有外层回调导致内层DOM坐标残留。负对照冻结bc95fac只加强测试/诊断、生产不变：连续同一完整字/offset=-10的重复go，外层保持原坐标，显式不送scroll delegate回调，生命周期恢复该delegate。只有旧源在唯一指定断言失败，再运行一行修正和五个直接边界，才接受本片；暂无结果，不能预先宣称实际异步写入者或所有定位问题已修。R3候选仍未接线。

本小片计划把完整不透明ReadingPosition、显式保存请求身份、失败状态及同步结果接纳迁入真实ReaderPositions模块；App进度视图只观察显示摘要。通过原Core业务值复用版本化Locator，不解析/重写EPUB Locator或TXT锚点，不改变SQLite规则。

沿用现有XianxiaCore包，增加独立Foundation-only产品/target与直接测试target，避免引入新顶层包或Readium/UIKit依赖；XianxiaCore业务target不反向依赖ReaderPositions。project.yml实际链接产品，架构登记同步增加独立区域/节点及禁止UI/引擎导入的反例。与原ReaderSettings、Readium TestApp设置存储借鉴同一原则：状态/保存有效性拥有明确负责人，平台动作在调用方协调；不引入第三方框架。

App调用方保留原采样循环、3秒预算、32毫秒不可用间隔、暂停/flush先后、原数据库await、固定版式分支及错误文字。请求创建/核验/失效/结果应用为MainActor同步方法，避免职责提取新增async封装或改变原挂起点。close继续允许原引擎最终位置回调，保存请求先失效；打开/关闭生命周期仍属于后续R4。

直接合同覆盖完整字节/版本保留、同一会话新请求替代旧请求、旧defer不清空新请求、关闭/换会话失效、失败保旧及成功重试清错误。通过同步显式步骤模拟挂起前后状态，不加入依赖固定时间窗的竞态。

受影响生产文件限新模块、ReaderViewModel、ReaderProgressView、Core manifest/project.yml/架构登记；独立测试与边界工具反例另列。原设置、字体、导航/书签、引擎、Vendor、资源/锁及数据库实现保持。

最小验证：Windows仓库语法及工具；Linux/macOS真实模块测试；iOS原生命周期28、设置7、进度1及真实位置/字体的直接交界用例。仅在源码稳定后一次冻结派发，不逐编辑打包。完整187、严格设备Release、原生动效与手机验收仍属I6。

R3a只隔离状态和请求结果的接纳，完整采样/保存编排迁移仍属后续R3b。不能把R3a写成R3全部完成。

