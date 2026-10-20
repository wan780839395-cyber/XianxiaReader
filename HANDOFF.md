# 项目交接：维护与功能隔离优先，Build30 已交付

R2派发前最终：Windows456语法新增0/54既有限制，62工具59通过/3既有POSIX跳过（21.156秒），Bash语法通过；133 Swift源/15区域/16节点/5例外。460个Core/Adapter/Vendor/资源/样书/锁保护输入不变（仅XianxiaReading manifest为本片新增target必要改动），原所有测试保持，普通HEAD/index保持。准备从222f10e冻结到codex/maintenance-reader-fonts，唯一选择font-isolation53项；不做完整187/设备Release/IPA。

## 当前断点：R2字体编排开始（2026-10-20）

R2授权已核；564个I1输入全部匹配，普通HEAD/index和既有工作保持，未见项目观察/接收残留。R2限定为新增XianxiaReading内ReaderFonts独立target（依赖Core/ReadingInterfaces，不依赖ReadiumAdapter/App），迁移字体目录/资源/选中判断、刷新及导入令牌失效；App保留CoreText导入、预览/Bundle资源、picker和完整锚点/引擎重开协调。保留浏览不重开、显式选中才安装、缺字降级但不改保存偏好、失败保旧/可重试、关闭重开迟到结果不能污染新会话。生产不复制字体服务，不动存储/schema/锁/Vendor或布局预算。

R2基线564输入/旧文件恢复ZIP在build/maintenance/R2-20261020。影响文件拟为ReaderViewModel、BundledReadingFont、新ReaderFonts源码/直接逻辑测试、Reading Package.swift、project.yml、边界登记与单一font-isolation诊断选择；原ReadingFontTests/生命周期/真实引擎/UI用例不删改。先Windows静态/工具及保全，再一次冻结源的最小font-isolation真实编译/集成/两项真实字体与一项原生选择；完整发布/设备Release留I6，不生成IPA。参考已取Readium固定3.11基线字体指南、Readest2d37bbf字体store/service和Apple actor重入说明，取舍将写R2设计；没有产品行为变更需决定，发现偏移则先收缩。

R2可恢复检查点：ReaderFonts源码、App桥接/状态转发、Package/project/边界登记已接线；7项直接模块竞态合同及font-isolation53项选择已写。原字体/生命周期测试逐字节保持；最初456语法新增0/54既有限制、61工具58通过3POSIX跳过。新增字体依赖越界负例后将跑最终Windows检查（预期62项），尚无Swift编译。R2设计/成熟实现取舍见Documentation/READER_FONT_ISOLATION.md；源码改动未进入R3/R4，尚未派发CI。

R2范围自查：原unit-release工具硬编码151项，新增7直接合同后只把精确门槛提高到158并同步原工具正反例，不降低断言、不复用旧UI。Windows第一轮62项59通过/3既有POSIX跳过、456语法新增0；最后计数工具变更后重跑工具最终日志，Swift源不变。

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
