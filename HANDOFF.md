# 项目交接：维护与功能隔离优先，Build30 已交付

## 用户确认的当前优先级（2026-10-20）

I1已开始：用户再次授权继续，并要求发现偏移及时纠正、产品取舍不确定时及时提问。已核I0四项工具输入和529个保护输入均与回执相同，无已有测试/CI助手进程。当前切片限定为设置逻辑的独立快速入口与保守影响映射，不进入R2/R3/R4。

I1工作合同：把现有ReaderSettingsPersistence封装为只依赖XianxiaCore的新ReaderSettings本地包（iOS16/macOS13，Swift tools5.10），仅公开App所需的现有接口；AppServices/ViewModel与生命周期测试增加模块导入，设置算法、存储路径/格式及原7项测试函数保持。将原设置测试源放在包内，macOS SwiftPM与原iOS测试target使用同一份文件，保留151+29完整门槛；I0守卫仅对该精确测试源允许两个测试target编译，生产源码仍单一归属。新增快速脚本、严格7项xUnit结果验证、独立macOS workflow及只生成计划的反向依赖映射；快速路径不解析Readium、不启动模拟器。默认完整发布流程加上逻辑门槛，其余断言/预算/三锁不改。验证先Windows静态/工具，再一次冻结的macOS7项与原iOS设置/生命周期定向编译集成；最终发布验收留I6，本片不交付新IPA。

参考已核SwiftPM swift-6.1.2-RELEASE的SwiftTestCommand（--parallel与--xunit-output）及XcodeGen2.46.0源路径规范；不用动态manifest、重复生产实现、OpenCombine替身或新远程依赖。下一步保存I1源码/配置基线，再迁移并核原测试主体字节一致。

I1可恢复检查点：559输入基线与受改旧文件已存build/maintenance/I1-20261020/baseline.json、before.zip。设置类/测试已移入ReaderSettings包，App/iOS入口已接线；已核设置源码除必要public可见性外原文相同，7项测试与受控fixture除模块import外原文相同。架构守卫131源/14区域/15节点通过；22项架构工具与10项快速结果/影响映射工具通过，尚未编译Swift。CI入口已纠正为现有ios-build.yml的reader-logic / reader-logic-integration两个选择（新workflow的默认分支登记限制已核），完整路径不删减；当前正跑最终Windows检查，随后用一次冻结源派发7项macOS+原iOS设置/生命周期定向。详见FAST_VALIDATION.md，不把本地工具通过写成真实Swift通过。

派发前：Windows最终454语法新增0/54既有限制，61工具58通过/3既有POSIX本机跳过（19.708秒），Bash两个受改脚本语法通过；原设置7与生命周期28共35项仍在iOS target。准备从857c16b的交付文档基线，以替代index冻结到独立codex/maintenance-reader-settings分支，普通HEAD/index保持；本轮同时把已验证I0工具纳入快照。仅派发现有workflow的reader-logic-integration一次，成功也不表示完整180或设备Release。后续所有运行/原件以build/maintenance/I1-20261020/frozen.json及实际run为准。

用户已授权开始维护；偏离范围时及时纠正，涉及无法判断的产品取舍及时提问。后续产品计划保留，见[全项目隔离与维护计划](Documentation/PROJECT_ISOLATION_PLAN.md)。I0依赖守卫已落地且Windows验证完成，本轮未混入R2/R3/R4、UI变更或依赖升级。Build30 的验收只适用于下述已交付源。

最终I0：20项边界正反例通过；默认仓库7项静态检查与453 Swift语法新增0通过，54既有Vendor语法限制保持；完整Python工具49项46通过/3项既有POSIX本机跳过（12.343秒），真实exit0。源码扫描131文件/12区域/13target节点/3包，记录5个精确import例外。529个App/Packages/Vendor/Tests/锁/project保护输入及普通HEAD/index保持。最终输入、完整日志和逐文件归属在build/maintenance/I0-20261020/accepted-*，简明回执Documentation/ValidationLogs/project-isolation-i0.json；本片没有Swift编译、远程CI、原生/设备验收或项目新IPA。守卫不隔离同target内部类型访问；I1及R2/R3/R4/I5/I6未完成。

收尾负对照发现I0守卫可漏扫常规目录外的新target源码：真实临时仓库已登记target但漏登记功能负责人时，旧守卫未拒绝，单项工具回归真实失败（1.477秒）；这不是App行为失败。已改为同时扫描实际target源路径，保留去重/归属检查，原反例0.786秒通过。负/正原件为new-target-ownership-negative/positive-control.log。修正后完整49项/453语法重新通过，最终accepted输入保留check_repository原CRLF格式，其实际代码变化只有新增检查函数及列表接入。旧19/48与中间final20结果独立保留，不作为最终源码验收。

下一独立切片I1：先审阅现有逻辑测试对App宿主/Readium的依赖，定义最小快速入口与影响范围映射；保留现有完整发布门槛和三锁，不为纯设置测试引入Readium内部产品或文档插件。开始迁移前核对本片基线及明确新Swift target/公开接口的必要范围，再实施、定向与Apple编译验证；不要按下方历史“下一步”重做I0或派发旧CI。

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
