# R2实施与诊断历史（2026-10-20）

以下完整保留本轮结束前的交接。旧运行中/失败待对照/源码版本/观察器只作历史；当前断点以主HANDOFF和最终R2回执为准，不触发旧CI或apply脚本。

# 项目交接：维护与功能隔离优先，Build30 已交付

R2当前唯一活跃验证：[39418977905](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39418977905)，修正源410343b7bbdb7b0f667d277c910f7f349a4d4ae7 / codex/maintenance-reader-fonts / font-isolation53项。基于新假设删除额外async prepare包装，恢复调用方原同步提交边界；只有VM.open/模块入口/新7测试调用桥接三Swift文件改变。Windows456语法新增0、62工具59通过3既有POSIX跳过（21.857秒）；566输入冻结，26个非字体方法、原52测试/fixture、460保护输入及普通HEAD/index保持。新源码尚未Apple验证，旧52/53不冒充本源结果。

实际本地观察exec1653/.cache/recovery/observe_reader_fonts_r2_open_boundary.py，用独立urllib每60秒读同一run，连续3错误停；原件写build/ci/39418977905。第一轮53与最小A/B均已自然结束/接收完整原件，旧观察/接收不再活跃。原source frozen.json及failed/control回执保留，当前权威open-boundary-frozen.json/preservation-open-boundary.json/dispatch.json。若本修正仍失败，停止此假设并在扩到位置/Readium前询问用户，不再盲补或重跑53；未进入R3，未做187/Release/IPA。

R2打开边界修正已实现：删除模块prepareForOpen异步包装，VM恢复原await加载→核会话→同步commitOpening→安装/应用；模块同步提交仍拒绝旧会话/取消，新增7项测试保留原断言仅更新调用桥接。只改3个Swift文件，原52测试/fixture与Core/Vendor/锁/字体不变。修正Windows456语法新增0/54既有限制、62工具59通过3既有POSIX跳过（21.857秒），新源码尚未Swift编译；准备唯一同源53定向，之前52/53和A过B失败各自保留，不冒充修正后验收。

R2最小A/B39411950208已自然结束failure：同runner/共同脚本/同一原test各一次，pre-R2 222f10e真实1/1（139.189秒），R2 f29c4ba真实0/1（87.752秒），失败改到756行sourceHanSans分页重开；不能归因本地网络，也不能把首轮719与这次756直接视为同根因。完整83141238字节artifact已SHA/CRC核/提取，A/B原源树/日志/summary/xcresult俱在；比较回执minimal-comparison-result.json。

实际诊断：保存/closed/open-returned完整p25/char1049正确，随后字体ready/loaded但anchor false、x0/h1，晚位置回调也覆盖存储。原因未定。下一唯一源码修正假设：R2新增prepareForOpen异步封装引入了额外提交边界，恢复原ViewModel的await加载→核会话→同步提交→安装/应用顺序；只改VM.open、新模块入口、新7项测试调用桥接，不动位置算法/Vendor/原测试/预算。修前3文件ZIP已存before-open-boundary-correction.zip，f29及首两轮失败全部保留。修正后先Windows定向/静态，再冻结跑53原受影响范围（生产打开流程改变须重新验证UI，不复用首轮结果），未进入R3。

R2恢复11:22UTC：工具连接刷新后旧exec65104不可用，CIM证实旧control观察器已不在；原run.json最后11:14UTC为旧快照，已重新只读查询核仍in_progress。新观察exec53955/.cache/recovery/observe_reader_fonts_r2_control.py，未重派CI。主目录生产566输入仍冻结；PROJECT_STATUS/ROADMAP/ARCHITECTURE/总方案已如实同步52/53与A/B待，不提前记R2验收。

R2最小A/B已实际派发：[39411950208](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39411950208)，诊断源293251e8cf74cabcbdd3cfb946ed7203a1e0cccc / codex/diagnose-r2-fonts。独立managed worktree C:/Users/78083/.codex/worktrees/r2-font-comparison/XianxiaReader，只改workflow/harness/HANDOFF三处；App/Packages/Vendor/Tests/project/锁均与f29相同，主工作目录566输入保持冻结。harness在远程临时checkout依次测试pre-R2 222f10e与R2 f29c4ba，同runner/共同原诊断脚本，只选原失败test各一次，不改函数/断言/预算，不重试；分别保留实际源树、summary、xcresult、原退出码和上下文。任一失败整体仍非0，结果不能冒充原53通过。只读观察exec65104/.cache/recovery/observe_reader_fonts_r2_control.py，原件到build/ci/39411950208；原53观察/接收均已退出。

首轮53的五张原生设置截图已实际查看：浅色选择/取消/重开均保选中，深色可读，重置后未选中；回执build/maintenance/R2-20261020/native-review.json。不称完整UI/动效/手机验收。生产不再追加修改，先等A/B原始结果区分原因。

R2实际断点：唯一53项CI39406897687/f29c4ba已自然结束failure，源码真实编译0诊断，52通过/1失败/0跳过。新模块7、原字体8、设置7、生命周期28、隐藏重排1及原生picker1通过；失败原real-font用例719行在分页第一次内置字体切换后未保住正文。诊断名Continuous不等于连续模式；附件font-real-load-anchor-false/font-epub-paged证明该阶段，根因及与R2关系未定。129975990字节完整artifact已GitHubSHA/CRC核验、完整保留并按回执清重复ZIP/分片；首轮失败回执build/maintenance/R2-20261020/first-targeted-failure.json。原所有566输入继续冻结，未修改测试断言/重试/预算。

下一项已明确假设：单轮同runner最小A/B，原失败test不改，分别pre-R2 222f10e与R2 f29c4ba；共同诊断脚本只选择这一项，复用已编译依赖，分别留原退出码/xcresult/日志。A也失败才有改前证据；A过B失败支持关联；两者通过只说明单项没复现，不能倒写首轮53全绿或根因已修。只改诊断harness独立分支，生产源不变，完整187/Release/设备仍留I6。

R2唯一CI已实际派发：[39406897687](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39406897687)，源f29c4babbc0e92d83b286703540e1334ff771532 / codex/maintenance-reader-fonts / font-isolation。566输入已核冻结，原52个测试/fixture输入及26个非字体ReaderViewModel方法原文保持。实际仓库/Core job成功，reading-diagnostic运行中；未取得新Swift/53项原件。只读有界观察器PID20856 / exec1169，命令.cache/recovery/watch_reader_fonts_r2.py 39406897687，结果写build/ci/39406897687；一次API观察失败原stderr已留存，未重派测试。恢复先核实际run/进程，不使用旧I1观察器。预期53精确身份在build/maintenance/R2-20261020/expected-cases.json，当前回执project-isolation-r2.json为pending。

R2派发前最终：Windows456语法新增0/54既有限制，62工具59通过/3既有POSIX跳过（21.156秒），Bash语法通过；133 Swift源/15区域/16节点/5例外。460个Core/Adapter/Vendor/资源/样书/锁保护输入不变（仅XianxiaReading manifest为本片新增target必要改动），原所有测试保持，普通HEAD/index保持。准备从222f10e冻结到codex/maintenance-reader-fonts，唯一选择font-isolation53项；不做完整187/设备Release/IPA。

## 当前断点：R2字体编排开始（2026-10-20）

R2授权已核；564个I1输入全部匹配，普通HEAD/index和既有工作保持，未见项目观察/接收残留。R2限定为新增XianxiaReading内ReaderFonts独立target（依赖Core/ReadingInterfaces，不依赖ReadiumAdapter/App），迁移字体目录/资源/选中判断、刷新及导入令牌失效；App保留CoreText导入、预览/Bundle资源、picker和完整锚点/引擎重开协调。保留浏览不重开、显式选中才安装、缺字降级但不改保存偏好、失败保旧/可重试、关闭重开迟到结果不能污染新会话。生产不复制字体服务，不动存储/schema/锁/Vendor或布局预算。

R2基线564输入/旧文件恢复ZIP在build/maintenance/R2-20261020。影响文件拟为ReaderViewModel、BundledReadingFont、新ReaderFonts源码/直接逻辑测试、Reading Package.swift、project.yml、边界登记与单一font-isolation诊断选择；原ReadingFontTests/生命周期/真实引擎/UI用例不删改。先Windows静态/工具及保全，再一次冻结源的最小font-isolation真实编译/集成/两项真实字体与一项原生选择；完整发布/设备Release留I6，不生成IPA。参考已取Readium固定3.11基线字体指南、Readest2d37bbf字体store/service和Apple actor重入说明，取舍将写R2设计；没有产品行为变更需决定，发现偏移则先收缩。

R2可恢复检查点：ReaderFonts源码、App桥接/状态转发、Package/project/边界登记已接线；7项直接模块竞态合同及font-isolation53项选择已写。原字体/生命周期测试逐字节保持；最初456语法新增0/54既有限制、61工具58通过3POSIX跳过。新增字体依赖越界负例后将跑最终Windows检查（预期62项），尚无Swift编译。R2设计/成熟实现取舍见Documentation/READER_FONT_ISOLATION.md；源码改动未进入R3/R4，尚未派发CI。

R2范围自查：原unit-release工具硬编码151项，新增7直接合同后只把精确门槛提高到158并同步原工具正反例，不降低断言、不复用旧UI。Windows第一轮62项59通过/3既有POSIX跳过、456语法新增0；最后计数工具变更后重跑工具最终日志，Swift源不变。

R2观察恢复10:29UTC：原watcher exec1169已因累计3次API TLS/EOF错误退出1，不再活跃；原3份stderr完整保留。仅对本地观察进程设置GODEBUG=http2client=0，单次元数据查询2.05秒成功，仍reading-diagnostic in_progress；这不证明HTTP2是根因，也没有修改CI或重跑测试。新只读观察器exec47809，命令.cache/recovery/watch_reader_fonts_r2_http1.py 39406897687，错误写独立watch-http1-error-*不覆盖旧证据。恢复时核实际CIM及run.json，所有566输入继续冻结。

R2观察恢复10:40UTC：HTTP/1观察器exec47809也累计3次API错误后退出1，证明前述客户端开关未解决连接问题；原错误各自保留。按GitHub官方GET workflow run/list jobs文档，独立Python urllib只读观察成功，当前exec27936/.cache/recovery/observe_reader_fonts_r2_rest.py，每60秒读取同一个run（连续3次错误即停），原始run-rest/jobs-rest及兼容run.json保留metadataSource。真实job仍运行，未重派/取消CI，未改566输入。用户说明可能本地网络问题，作为线索而非已证实根因。恢复先核本段进程，不再复用旧CLI观察器。

## I1已完成基线（历史，以下结果保留）

用户确认先维护整个项目、做好功能隔离，再继续新功能；发现偏移及时纠正，不能判断的产品取舍及时提问。I0依赖守卫与I1快速入口已落地，整个项目隔离仍未完成。下一轮先定义I2/R2字体编排的文件/合同/定向门槛，不在I1收尾混入字体、位置或会话提取。后续产品计划保留在PROJECT_ISOLATION_PLAN、ROADMAP与READING_FEATURE_IDEAS。

I1实际源1545a3cdafa248e563c01c408e04cd8cc3e71154 / codex/maintenance-reader-settings；唯一CI[39398382008](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39398382008)真实success。设置持久化移入只依赖Core的ReaderSettings本地包，原算法/存储格式保持；App和原iOS测试实际接线编译。原7项设置测试与fixture保持原文，仅模块import变化，同时用于macOS包测试和原iOS门槛，生命周期28项只增加import。生产源码不重复归属；精确共享测试许可拒绝生产target。快速脚本、严格7项结果/依赖验证与保守反向影响映射见FAST_VALIDATION.md；默认完整门槛仍为原151集成+29UI并增加同一逻辑检查。

验收：Windows454 Swift语法新增0/54既有Vendor限制、Python61项58通过/3既有POSIX本机跳过、Bash语法通过；Linux真实61/61、无跳过。Xcode16.4/Swift6.1.2/macOS15.7.9独立逻辑7/7，真实依赖仅ReaderSettings/XianxiaCore，无App宿主或Readium，步骤115秒含92.18秒编译；原iOS18.5模拟器设置/生命周期35/35、无失败/跳过/重复，源码诊断0。iOS步骤1763秒含准备/编译/启动/导出，35用例耗时之和1.963秒、所选suite墙钟2.454秒；不要把两者混称测试执行耗时。未跑本维护源完整180、真UI/原生动效、设备Release/普通设备/TrollStore；未生成新IPA，最后交付仍Build30。最终发布与设备门槛留I6。

原件已收齐：build/ci/39398382008/full.log、reader-logic完整artifact、logic-download-receipt.json，GitHub SHA256/ZIP CRC与run/source核对通过；仅该artifact重复分片/ZIP已在完整提取后按精确回执删除。405068字节artifact保留为当前开发证据，Build30完整诊断/交付包与恢复ZIP保持。简明最终回执Documentation/ValidationLogs/project-isolation-i1.json；冻结564输入和accepted/preservation-final证据在build/maintenance/I1-20261020。564输入Git blob/本地SHA均保持；461个Vendor/Core/Adapter/资源/样书/锁输入保持，普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index保持，既有未提交工作保留。

观察器旧exec26634/PID20280在工具环境刷新后已不存在；旧会话不可用。曾一次gh API EOF已保留watch-error.log，后续直接查询成功，不是源码失败；未重派CI或盲重试测试。本run已完成，接收/audit任务同步退出0，无本轮观察/接收残留任务。源码冻结后只同步文档回执，最终文档提交不得改变上述564输入。保持电脑开机。

本轮实施/等待原交接已归档到Documentation/HANDOFF_I1_DEVELOPMENT_2026-10-20.md；其中旧运行中、待Apple、下一片I1及PID只作历史。下方I0/Build30历史不替代本维护源的分项验收。

## I0过程记录（历史，最终状态以上节为准）

I0工作合同：新增显式依赖/区域登记与静态检查器、工具正反例及check_repository接入；输入是当前Swift源、两个Package.swift与project.yml。现有App/Reader等仍在同一target，这一片只能限制imports/声明依赖、登记旧例外，不能声称已隔离同target内部的类型访问。先保存源码/配置哈希与普通HEAD/index，修改后核对App/Packages/Vendor/Tests/锁/project字节保持。保留Core无UI/Readium、接口不依赖适配器、仅明确组装/旧集成允许具体依赖的合同；新功能目录/target未登记、禁用依赖、循环及未解析语法必须失败。验证先用可控临时仓库反例，再跑当前仓库静态/语法与Python tooling；本片不改生产输入，不派发两小时原生CI、不生成IPA。

可恢复检查点：build/maintenance/I0-20261020/baseline.json已保存556个现有输入哈希及普通HEAD/index，edited-inputs-before.zip保留受改旧文件。新增architecture-boundaries.json和check_architecture.py、接入check_repository；实际源扫描131个Swift文件/12区域/13图节点，18项真实临时仓库正反例已通过（8.366秒）。包含循环、不同import形式、新功能/target、动态manifest、过期例外、源码排除/重复编译归属及解析失败的拒绝。登记的5个精确import例外包括3个App具体适配依赖和2个真实Readium集成fixture，不能扩为目录通配许可。当前冻结工具输入，下一步运行完整Windows静态/Swift语法与Python tooling，再核生产输入哈希；尚未把定向通过写成全套通过。

随后自查补齐包级循环（不只target循环），19项定向8.353秒通过。第一次Windows完整检查453语法新增0、54既有Vendor限制保持；第一次工具47项44通过/3项既有POSIX本机跳过（11.248秒）。工具源码增加包级循环后必须重新验证，最终日志另存*-final，不覆盖上述原结果。已核529个App/Packages/Vendor/Tests/锁/project保护输入、普通HEAD/index均保持，556基线中只有本片check_repository.py接入口改变。下一步为最终本地门槛与文档同步，无原生CI。

以下I0工作合同与检查点为本片执行记录；当前结果及下一步以上述最终I0/I1段落为准。后续按 R2→R3→R4 及书库/导入/搜索边界逐项迁移，每项分别记录实现、Windows静态、Apple编译、定向、完整和设备状态。

## Build30交付基线（以下保留其历史验收）

R1本片实现、真实编译、定向、完整与严格设备Release已完成；不再派发CI或运行旧apply/freeze/取消脚本。Release源aa0a119a71b10f1f345bc6f4cd54f6c8b4e2871a / codex/refactor-reader-settings，CI39373881574 success。定向6/6，151集成+29真UI=180/180，失败/跳过0；Linux/macOS Core各137、TXT Release各4。源编译0诊断，test/export/summary/recording均0，未复用旧UI，严格无签名iPhoneOS arm64 Release30/min16。

最终自动核验build/ci/39373881574/final-gates.json passed；全556输入、354实际Git Vendor清单、三锁六pins、六原字体摘要、普通HEAD/index和53旧包均核。apple/core/ipa三个artifact完整GitHub SHA/CRC校验/提取后已按精确回执清重复分片/ZIP。原始日志、xcresult、项目、录屏、图、三个收件回执均在本run目录；保留为当前已交付版本完整诊断。

交付IPA：build/XianxiaReader-SettingsIsolation-Build30.ipa，68890724字节，SHA35752183296684a573bf866c84ad34f555adc5d16aadcab7148763c1f839a638。TestKit：build/XianxiaReader-SettingsIsolation-Build30-TestKit.zip，64238089字节，SHAc61538db0ea6f209c1aadcbbbf9f6fc067d82f8af1cd0ddaa597b76e31be7128；24源文件逐字节/CRC核，含原创EPUB/TXT、六套原字体及许可、本轮8原图Preview。实际IPA内容另核版本0.0.1(30)、bundleIDcom.xianxiareader.app、min16、Mach-O arm64/platform iOS、可执行权限、无嵌入签名材料和六字体摘要。覆盖安装，不卸载或删库。

## 实现与因果证据

App ReaderSettingsPersistence隔离外观/手感有序存储；saveSettingsNow不从被覆盖reader采位置，dismiss后fresh保存。ReadiumAdapter取消替代请求后对相同已应用偏好幂等；真实变化仍fresh完整位置/3秒采样预算和可见错误。连续模式spread=never避免无关双页旋转重建；ReflowableSpreadView仅提前既有pendingLocation赋值，使字体初始化结束读取最新完整定位。

合格负对照39370263590/d28feaa不改生产：真实字体ready、深字1200可见时显式屏障放行，随后当前WK attached/alpha1且ready/settled、x0/原字消失，真实0/1；该轮自然结束无Agent取消。只移动既有赋值并登记UPSTREAM真实LF摘要19ab7308346ba538b431e8493d25c1bc7bb3104fc86b89828ea1ceb21f0276f4；同fixture本轮先行7.407秒通过，完整再次通过，原预算/断言保持。此前幂等2/2与后台1/1各自原件保留，未把其余旧启动/加载问题统一归因。

## 原生与设备验收

已查看当前run8张真实原图（浅/深暂停、横屏、恢复竖屏各3；真实字体分页/连续各1）以及四次旋转窗口全部38个原始PTS帧。正文/暂停状态可读，无所选窗口加载或错误提示，系统旋转变换角区可见，恢复竖屏与暂停内容一致。录屏218.07秒、平均4.40fps为稀疏VFR观测；只验所选20秒窗口，不称看过整段或手机FPS。普通设备/TrollStore/手机性能仍待用户实际反馈，Build29“已暂停”不冒充Build30反馈。

下一项仅手机核对：换字体/字号/主题→关面板→回书库重开的位置/错误；连续暂停后浅深旋转；慢滚回桌面再打开已暂停。本轮R2/R3/R4/M5未做，M4整体未验收。CI可观测性拆分作为后续独立切片记录，未混入生产修复。

## 证据与保留

Documentation/ValidationLogs/m4-settings-isolation-r1-success.json、m4-settings-isolation-r1-native-review.json、m4-settings-isolation-build30-delivery.json为当前权威回执；m4-settings-isolation-r1.json顶部最终状态已同步，历史失败字段保留。PROJECT_STATUS/ROADMAP/ARCHITECTURE/方案与DEVICE_ACCEPTANCE已同步。历史交接见Documentation/HANDOFF_R1_RECOVERY_HISTORY_2026-10-20.md。

本轮watcher exec34146/PID20472、receiver exec97148/PID37996均已退出0，CIM核无本轮Python残留；旧会话46581/34898在工具刷新后失效并已恢复过，不再使用。无活跃CI/接收或实现任务。普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index保持，历史未提交/未跟踪工作、恢复ZIP和53旧交付包保留，新增本轮两交付包。最终仅提交文档回执到私有分支，不把生成包/缓存提交。

保持电脑开机；不安排关机。cua曾报Work设置禁用，未改权限；gh CLI正常。job日志曾落后85分钟，不能用旧尾部判断挂起。完整脚本110分47秒：集成case合计804.415秒、UI3899.124秒，原生case合计不等于独占墙钟；测试/导出退出07:09:05UTC，Release构建成功07:32:30UTC，单设备Release约23分26秒，另有准备/上传。真实成本审计仅覆盖本地completed metadata，不等于账号计费或纯编码时间。
