# 当前交接与恢复点

当前断点（2026-10-20 10:10上海）：39357294714 / 832fbaa正在验证测试target链接修正后的原6项；556输入冻结，已有工作保留。上轮39354867480是链接失败/用例0执行，后台暂停单项39352276145已1/1通过。最终179项、设备Release与Build30 IPA仍未通过。

## R1设置隔离：字体诊断2/2，完整发布仍未通过

完整39243868846/024fc87仍为171/177失败，Release未执行，无Build30 IPA；Build29是最后交付。当前预期150集成+29UI=179，尚未执行完整179门槛。

最新滚动写入者诊断[39348950147](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39348950147)/96e913a已完成2/2，0失败/跳过，test/summary/export均0，Swift编译诊断0；556冻结输入匹配，artifact12233013451完整SHA/CRC已核。六字体分页和连续模式原断言、隐藏重排原断言通过；此轮只增强测试探针，没有生产修复，未复现旧回跳，不能宣称根因已修。连续字体诊断仍出现既有排版错误消息，不等于无错误用户流程。原件和边界见Documentation/ValidationLogs/scroll-writer-probe-39348950147.json。

前轮39279664338/f32实际0/2，原失败和2010→0轨迹保持：已记录RO帧晚于回跳，未找出唯一写入者。最新插桩通过不能倒写旧结果。当前无39348950147的watcher/接收/下载进程残留。

最近4UI39272564753/e85仍2/4：纸色正反例和菜单重开通过；Home/activate后运行但缺少真实后台前置条件；深灰横屏持续“正在准备”，原可读/无加载守卫拒绝。后者仍阻塞发布，不归咎于纸色或无证据归咎环境。

用户已确认Build29手机慢滚→桌面→再打开为“已暂停”，仅此交付版本路径反馈。后台UI前置条件[39352276145](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39352276145)/ff196499已完成1/1，0失败/跳过，test/summary/export0，Swift编译诊断0，556输入及artifact12234387680完整SHA/CRC已核。原立即暂停断言保持，日志实际53.23秒Home→56.76秒桌面图标→59.18秒activate→62.56秒暂停截图；已查看该原图，真实正文与已暂停可见。生产暂停逻辑不改，证明本测试切片通过，不抹去旧失败或代替完整/设备验收。watcher21713/receiver75655均退出0，无本轮残留进程；记录Documentation/ValidationLogs/background-precondition-39352276145.json。

最新39354867480/abbcf18已结束，仓库/Core通过，iOS源码无编译诊断但XianxiaReaderTests链接失败，原生用例执行0项；不是6项行为失败或通过。完整artifact12235502581 SHA/CRC已核，原件build/ci/39354867480。新增测试直接使用ReadiumNavigator/Shared，测试target缺少显式产品链接；按XcodeGen2.46官方声明，只在project.yml给测试target增加已有本地包两产品，不更改Readium/远程pins/生产源码。下一步Windows预检/实际Git来源清单后同6项验证。当前无旧watcher/receiver残留。记录Documentation/ValidationLogs/continuous-rotation-39354867480-link-failure.json。

连续模式仅在EPUBSettings解析infiniteScroll时固定spread=never，避免自动双页旋转的多余销毁重开；保留分页偏好。源码已应用，原6项行为仍待验证；150集成+29UI=179完整门槛与Release/设备未通过。

正常HEAD6d761749、普通index及既有交付包保持；不做R2/R3/R4/M5，不关机。长期规则在AGENTS.md和Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md。

## Build29 阅读安全区边缘（2026-10-19）

本切片已交付。实际Release源`a65086c1151831b54d90ed083fa36fc27848b5cb` / `codex/m4-reading-edges` / [完整CI39147081645](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39147081645)：Linux/macOS Core各137，iOS163/163（136集成+27真UI）、失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release29/min16。547编译资源blob、三锁六pins、六完整原字体/OFL、每平台4长TXT Release探针已核。Windows449语法新增0/54既有Vendor限制、17工具测试通过；语法不算编译。

补充源`f32002880ebe7702321cce90f1d030823c047c53`仅加强本轮新增旋转测试及recovery名单：App/Core/Adapter/Vendor/原Fixtures/锁/project/默认完整CI与上述Release全同字节，547记录中545相同、2测试/诊断路径不同。C[39155583794](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39155583794)实际10/11，新旋转81.659秒通过，唯一旧字体case在初次cover位置未发出时20秒probe失败，尚未执行换字体；完全同源原两个字体case单独复核[39179687615](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39179687615)实际2/2。保留原失败及根因未定风险，不称C11全过、f320完整163/设备Release或旧时序根因已修。299其他原test主体不改；预算/断言保持。精确来源见m4-edges-build29-production-provenance.json。

ReaderSurface保留原完整viewport/控制器，以UIKit真实safeAreaInsets和CAShapeLayer evenOdd绘制页面色不安全四边，中心透明，触摸/辅助功能穿透；明确zPosition高于迟到navigator。仅布局、安全区或颜色变化重绘，无逐滚动回调/blur，禁隐式动画。正文排版/contentInset/offset/完整Locator、数据库/依赖、加载20秒及保存3秒保持。App/Vendor有界Debug安全阶段元数据已登记，Release开关false不记录日志或AX。

安装[XianxiaReader-ReadingEdges-Build29.ipa](build/XianxiaReader-ReadingEdges-Build29.ipa)，SHA256 `2c8ef157dbe26d921c08d3a5ffa10a3ef6ee4d481c7b831ff3eb1191ae42901c`；[原创样书/字体许可/原生Preview测试包](build/XianxiaReader-ReadingEdges-Build29-TestKit.zip)，SHA256 `adfab4519e80cca8357e5b243be21bfeba5d9fcd0843be8e2067986c5b9a9cb9`。覆盖安装保留书库，不卸载或删库；+菜单确认0.0.1 (29)。51旧包、未提交工作、1062原路径及19恢复ZIP保持。

实际原生复核：A37原图/6完整录屏31总览/3窗口134帧已核，A旧旋转的排版alert与颜色错配历史继续拒绝；同生产的C10原图/81秒录屏6总览/3窗口114原始帧（11表）已核，浅深暂停、横屏和恢复竖屏正文与所列安全边缘可接受。App横屏裁图带黑区，公开XCUIScreen整屏图正确，双图/几何probe证明观测差异；Preview只收C的6张正确阅读整屏图。旋转仍显示加载并短暂章头再恢复锚点，不作为无缝动效或手机FPS验收。

旧四轮完整失败、a650早期定向10/10、第五完整自动通过但原生拒绝、B旋转10/11、C10/11和同源字体2/2全部独立留证，不追认旧失败。已核当前无生产变动，采用真实完整Release加同生产补充验证，未跳过失败CI生成IPA。原件本地范围服从最新CI保留回执，文字日志/summary/metadata与项目验证记录保留。

M4整体未完，普通设备/TrollStore、大字/VoiceOver/完整旋转及减少动效矩阵、手机Release帧时间/内存/功耗未验收。Build28“目前感觉流畅”仅实际手机主观反馈；Build27外部字体导入仅用户实际样例。未含字体删除/无限字体/可变轴/单书覆盖、Share Extension或M5。下一步收本片手机状态栏/手势条/旋转与慢滚触摸反馈，按性能计划推进，不盲改定位管线。

最新用户“改完别关机了”：保持开机，本轮不发出关机命令或安排关机。

## 保全与恢复

正常HEAD6d761749/空index、M2 e6f31d85/M3 44af41f0保持。edges源a650为完整Release，screen源f320为补充旋转/字体复核，appearance为最终文档私有快照；正常工作树未提交改动全部保持。最终实际审计见build/ci/39147081645/final-preservation-check.json和final-delivery-receipt.json；它们未生成前不要假定最后收尾成功。547当前源对f320验证，545与Release同字节，不能将对a650的两测试差异说成“只改文档”。

本轮验收依赖A完整、C整屏和同源字体D三组诊断，均属本版本使用中证据；历史轮只保留完整文字日志/summary/metadata，精确清单与证据边界见m4-edges-build29-ci-retention.json。根53交付包、源/原创素材/19恢复ZIP不在历史CI清理范围。旧原件路径是否仍在本地以回执为准。

恢复先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核实际Git/文件/完整日志/任务。完整开发过程归档HANDOFF_BUILD29_DEVELOPMENT_2026-10-19.md。本片完成后的下一项是手机反馈/性能专项，M4未完不进入M5；保持开机。

## 本地历史诊断收尾已完成

旧7轮20566项、9954.8MiB已按审定绝对路径/链接/摘要清理，独立核对删除项均不存在；482项完整文字日志/summary/metadata保留，53根交付包摘要保持。A39147081645/C39155583794/D39179687615是本版验收依赖，三组完整诊断仍保留至下一交付；源/原创素材/19恢复ZIP未纳入删除。实际精确回执Documentation/ValidationLogs/m4-edges-build29-ci-retention.json。旧大原件路径为历史引用，不表示仍在本地。下一步最终源/包/备份/私有树/远端与任务核对，未见final-delivery-receipt.json前不假定其完成；保持开机。

当前fonts2诊断已派发：https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39279664338 / f32cc9333418a2ca30e97e2e47676f5f07bad175。Windows453语法新增0/54Vendor限制已通过（非编译），556输入冻结；仅ReaderRenderingTests测试诊断变化，无生产变更，原断言与预算保留。不移动冻结输入，不追加full。首次dispatch HTTP500后两次只读确认无新run，才重发一次成功。

2026-10-20恢复后，滚动写入者fonts2诊断已派发：https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39348950147 / 96e913a0782370272705ca8d8e3ac62577c5e878。556冻结输入，只改一个测试文件，Windows/JS/本地转发检查已过（非原生）。旧39279664338是0/2完成，旧watcher/下载均无残留；当前watcher见build/ci/39348950147-watch.log。完成前不移动或改变冻结源码。

本轮接收流程：watcher exec47555持续核39348950147；接收器exec34194（.cache/recovery/await_scroll_writer_diagnostic.py）只等待本轮完成元数据及artifact，随后完整下载校验并运行analyze_scroll_writer_probe.py。接收器70分钟截止；不触发新CI。只有看到diagnostic-download-receipt.json与scroll-writer-probe-check.json才算完成取证。中断后先核实际进程/文件，勿重复启动两个接收器。

2026-10-20 08:54上海实际进程：watcher PID2180/exec47555，receiver PID9404/exec34194；恢复时CIM同时查watch_autoscroll.py、await_scroll_writer_diagnostic.py和download_experience27_diagnostic.py，先验CommandLine再决定是否复用，避免漏查receiver或因PID复用停错进程。当前无下载进程，39348950147仍in_progress。

2026-10-20用户手机反馈：当前交付Build29开始慢滚→回桌面→再打开后“已暂停”。只记录此手机路径，不等于R1当前源设备/完整矩阵验收。原生后台失败先核测试真实进入后台的前置条件，不据此补生产暂停逻辑。记录Documentation/ValidationLogs/build29-background-phone-20261020.json。

后台UI候选仅缓存：ReaderInterfaceUITests-background-precondition-candidate.swift / background-precondition-plan.json，Swift tree grammar无错误（不是原生编译）。依据固定Mozilla c603c9c BaseTestCase.swift的Home→后台→Springboard→activate流程；候选要求启动前正在慢滚、后台/挂起状态且Home有可点击图标、activate后原暂停断言保持，不重按Home、不改生产预算/暂停逻辑。用户Build29手机已暂停反馈独立留证。尚未应用，不混入当前39348950147的冻结输入。

2026-10-20 09:14上海：后台UI单项已派发 https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39352276145 / ff196499c340760471afbed318d9ac99debaa432，selection=background-ui，预期原1项。556构建输入已冻结，只有原UI方法/诊断脚本/workflow变化；生产不变、其他UI方法主体相同，Windows453语法新增0/54既有限制、工具26通过3本地POSIX跳过、Bash语法通过。watcher exec21713与receive_background_precondition.py只收本轮真实结果/原件；完成前不移动分支或改冻结输入。不重复apply/freeze、不同步追加full。接收完成需见diagnostic-download-receipt.json和background-precondition-check.json，后者未出现不算完成。


后续连续旋转候选只保存在.cache：continuous-spread-plan.json / continuous-spread-candidate.diff，尚未应用或原生编译。原xcresult已补出4份UI日志；D3E58E25在深灰横屏替换正文后24.566秒没有navigation/initialization事件。源码发现infiniteScroll文档宣称禁用spread、controller已固定单页，但EPUBSettings仍auto，横竖切换触发全量invalidate/reload；候选仅continuous解析spread=never，保留分页偏好。固定Readium3.11/PR811 head5e22已核，PR仍未合并，不能冒充上游现成修复。新回归将验证auto/always/never和defaults/显式切回，默认门槛需150集成+29UI=179，不能继续用149单元基线。当前后台run39352276145/ff19649仍冻结，不应用后续候选。

ACTUAL39354554615/d1ad446 repository check_vendor failed: Windows CRLF digest vs Git LF. Native job skipped, zero selected cases executed, no diagnosticartifact. Watcher/receiver exited, no source compile result. Corrected source EOL to LF and inventory SHA371fbdbad00f9029f6b869fc4c28c31077492ede1454438f62129dcdc1716bab; production semantics unchanged. Before next push verify actual Git Vendor blobs then select same6, no full.

2026-10-20 09:42上海：已按实际Git blob核完整354项Vendor摘要及556构建输入，生产blob与d1ad446完全相同，仅修LF来源登记。当前39354867480/abbcf18c992ad9c8369be0c745e881de08939677，selection=continuous-rotation，原生预期6。旧39354554615在repo前置失败、原生未执行，日志/证据保持。watch_autoscroll.py与receive_continuous_rotation.py 39354867480正在接收本轮；完成需见diagnostic-download-receipt.json及continuous-rotation-check.json，不重复派发/应用/冻结，不改当前556输入。普通HEAD/index不动。

当前39354867480/abbcf18仍在原生流程，watcher exec36463/PID25212，receiver exec49002/PID42224（receive_continuous_rotation.py 39354867480）。原39354554615只在repo摘要阶段失败，无原生artifact。下一候选仅缓存rotation-release-candidate/：把新纯策略case扩为同字非零锚点在真实挂窗宽/窄两种viewport中仍可见并保持同WebView，再在同job6项预检通过后full179/设备Release；尚未应用，原完整/设备门槛仍未通过。候选Swiftgrammar无错误（非编译），字体/旋转两种preflight成功/失败/导出退出传播fixture已本地验证，完整29工具待实际应用后再跑。是否采用须先看当前6项和原生图，不能越过当前冻结输入。

2026-10-20 10:10上海恢复：39354867480/abbcf18实际testtarget链接失败，6项执行0（不是测试通过），原artifact完整核。project.yml测试target显式链接本地ReadiumNavigator/Shared，生产与原6测试不变；Windows453语法0新/54限制、工具26pass3skip，实际Git354项Vendor来源和556输入通过。私有源832fbaa45db4224007748141fd579d349772833d，当前派发39357294714/continuous-rotation原6项，watch_autoscroll.py和receive_continuous_rotation.py带source-proof-test-readium-link.json。原任务已退出，无残留；当前源码冻结，不动分支或追加full。只有diagnostic-download-receipt.json及continuous-rotation-check.json齐才算收完。缓存rotation-release-candidate尚未应用。


## 2026-10-20 12:52 上海：PROJECT_STATUS.md旧首页R1段落归档

## R1设置隔离：字体诊断2/2，完整发布仍未通过

完整39243868846/024fc87仍为171/177失败，Release未执行，无Build30 IPA；Build29是最后交付。当前预期150集成+29UI=179，尚未执行完整179门槛。

最新滚动写入者诊断[39348950147](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39348950147)/96e913a已完成2/2，0失败/跳过，test/summary/export均0，Swift编译诊断0；556冻结输入匹配，artifact12233013451完整SHA/CRC已核。六字体分页和连续模式原断言、隐藏重排原断言通过；此轮只增强测试探针，没有生产修复，未复现旧回跳，不能宣称根因已修。连续字体诊断仍出现既有排版错误消息，不等于无错误用户流程。原件和边界见Documentation/ValidationLogs/scroll-writer-probe-39348950147.json。

前轮39279664338/f32实际0/2，原失败和2010→0轨迹保持：已记录RO帧晚于回跳，未找出唯一写入者。最新插桩通过不能倒写旧结果。当前无39348950147的watcher/接收/下载进程残留。

最近4UI39272564753/e85仍2/4：纸色正反例和菜单重开通过；Home/activate后运行但缺少真实后台前置条件；深灰横屏持续“正在准备”，原可读/无加载守卫拒绝。后者仍阻塞发布，不归咎于纸色或无证据归咎环境。

用户已确认Build29手机慢滚→桌面→再打开为“已暂停”，仅此交付版本路径反馈。后台UI前置条件[39352276145](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39352276145)/ff196499已完成1/1，0失败/跳过，test/summary/export0，Swift编译诊断0，556输入及artifact12234387680完整SHA/CRC已核。原立即暂停断言保持，日志实际53.23秒Home→56.76秒桌面图标→59.18秒activate→62.56秒暂停截图；已查看该原图，真实正文与已暂停可见。生产暂停逻辑不改，证明本测试切片通过，不抹去旧失败或代替完整/设备验收。watcher21713/receiver75655均退出0，无本轮残留进程；记录Documentation/ValidationLogs/background-precondition-39352276145.json。

最新39354867480/abbcf18已结束，仓库/Core通过，iOS源码无编译诊断但XianxiaReaderTests链接失败，原生用例执行0项；不是6项行为失败或通过。完整artifact12235502581 SHA/CRC已核，原件build/ci/39354867480。新增测试直接使用ReadiumNavigator/Shared，测试target缺少显式产品链接；按XcodeGen2.46官方声明，只在project.yml给测试target增加已有本地包两产品，不更改Readium/远程pins/生产源码。下一步Windows预检/实际Git来源清单后同6项验证。当前无旧watcher/receiver残留。记录Documentation/ValidationLogs/continuous-rotation-39354867480-link-failure.json。

连续模式仅在EPUBSettings解析infiniteScroll时固定spread=never，避免自动双页旋转的多余销毁重开；保留分页偏好。源码已应用，原6项行为仍待验证；150集成+29UI=179完整门槛与Release/设备未通过。

正常HEAD6d761749、普通index及既有交付包保持；不做R2/R3/R4/M5，不关机。长期规则在AGENTS.md和Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md。



## 2026-10-20 12:52 上海：ROADMAP.md旧首页R1段落归档

## R1设置隔离：字体诊断2/2，完整发布仍未通过

完整39243868846/024fc87仍为171/177失败，Release未执行，无Build30 IPA；Build29是最后交付。当前预期150集成+29UI=179，尚未执行完整179门槛。

最新滚动写入者诊断[39348950147](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39348950147)/96e913a已完成2/2，0失败/跳过，test/summary/export均0，Swift编译诊断0；556冻结输入匹配，artifact12233013451完整SHA/CRC已核。六字体分页和连续模式原断言、隐藏重排原断言通过；此轮只增强测试探针，没有生产修复，未复现旧回跳，不能宣称根因已修。连续字体诊断仍出现既有排版错误消息，不等于无错误用户流程。原件和边界见Documentation/ValidationLogs/scroll-writer-probe-39348950147.json。

前轮39279664338/f32实际0/2，原失败和2010→0轨迹保持：已记录RO帧晚于回跳，未找出唯一写入者。最新插桩通过不能倒写旧结果。当前无39348950147的watcher/接收/下载进程残留。

最近4UI39272564753/e85仍2/4：纸色正反例和菜单重开通过；Home/activate后运行但缺少真实后台前置条件；深灰横屏持续“正在准备”，原可读/无加载守卫拒绝。后者仍阻塞发布，不归咎于纸色或无证据归咎环境。

用户已确认Build29手机慢滚→桌面→再打开为“已暂停”，仅此交付版本路径反馈。后台UI前置条件[39352276145](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39352276145)/ff196499已完成1/1，0失败/跳过，test/summary/export0，Swift编译诊断0，556输入及artifact12234387680完整SHA/CRC已核。原立即暂停断言保持，日志实际53.23秒Home→56.76秒桌面图标→59.18秒activate→62.56秒暂停截图；已查看该原图，真实正文与已暂停可见。生产暂停逻辑不改，证明本测试切片通过，不抹去旧失败或代替完整/设备验收。watcher21713/receiver75655均退出0，无本轮残留进程；记录Documentation/ValidationLogs/background-precondition-39352276145.json。

最新39354867480/abbcf18已结束，仓库/Core通过，iOS源码无编译诊断但XianxiaReaderTests链接失败，原生用例执行0项；不是6项行为失败或通过。完整artifact12235502581 SHA/CRC已核，原件build/ci/39354867480。新增测试直接使用ReadiumNavigator/Shared，测试target缺少显式产品链接；按XcodeGen2.46官方声明，只在project.yml给测试target增加已有本地包两产品，不更改Readium/远程pins/生产源码。下一步Windows预检/实际Git来源清单后同6项验证。当前无旧watcher/receiver残留。记录Documentation/ValidationLogs/continuous-rotation-39354867480-link-failure.json。

连续模式仅在EPUBSettings解析infiniteScroll时固定spread=never，避免自动双页旋转的多余销毁重开；保留分页偏好。源码已应用，原6项行为仍待验证；150集成+29UI=179完整门槛与Release/设备未通过。

正常HEAD6d761749、普通index及既有交付包保持；不做R2/R3/R4/M5，不关机。长期规则在AGENTS.md和Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md。



## 初始化对照收件后归档 2026-10-20T05:13:45.111692+00:00

# 项目交接（2026-10-20 12:33上海，初始化对照恢复）

## 当前断点（2026-10-20 12:35上海）

13:01上海复核：556输入未变、普通index空；watcher24684/receiver20636的实际CommandLine均对应本轮。仓库/Core成功，原生job仍in_progress；job日志API尚404，不能据此判挂起或推断用例阶段。PROJECT_STATUS/ROADMAP的过期R1“下一步”已完整归档到恢复历史，首页改为当前180与分项验收边界。既有幂等2/2的两张原生字体图已实际查看，静态范围及原图SHA写入preferences-idempotency-39362754281.json；不扩展为手机/动画验收。

已冻结并派发39370263590/d28feaa120c6ddb7b26dce0450cf561cc3e7ffc7，selection=initialization-pending1。先公开导航目标章节进viewport，只查询当前WK；隐藏DOM诊断跳过，启用现有30分钟有界宿主资源监测。生产/Vendor/锁与176303d相同，556输入/354实际Vendor来源核实。源码/分支冻结，不重复apply/freeze或派发。

watcher exec93265 / receiver exec45461（receive_visible_initialization.py + source-proof-initialization-visible-control.json）；恢复核CIM实际CommandLine。收件需initialization-pending-check.json、原始完整artifact SHA/CRC；新qualifier要求target-resource-in-viewport与原3阶段、可见ready/settled且x0/word消失。未合格不应用缓存Vendor候选、不运行full180。

## 上轮取消的真实边界

39365686520/c9dcba9由Agent取消（非源码失败），完整artifact12240662458/87685字节SHA74e133954dc71cd597b14db46a4f11225ad3d2d508cb818941740a0bcb1f5ba9/CRC与556来源核。原生测试0执行，无summary/测试退出码，xcresult仅Staging未完成。Session日志04:12:47.590发出宿主App launch请求（wait_for_debugger=1）后未记录bundle连接或case开始，标准输出0字节，Agent04:21取消；源码已构建/安装至宿主启动阶段。不能说这37.6分钟由测试fixture、定位或环境独有原因造成。fixture本体没有运行，也未证明pendingLocation假设。

watcher38944/PID26412与receiver40407/PID20560均退出0，恢复核CIM实际CommandLine。普通HEAD/index、旧包/已完成生产改动保持。该轮已结束；新任务见本页当前断点。

## 下一项（同一生产源，只修fixture与观测）

initialization-visible-control已应用（before-initialization-visible-control备份）：先用公开导航把one.xhtml移进viewport，再仅检查几何当前的WKWebView等待原生font-ready屏障；失败时隐藏/未准备窗口只记native几何，不再等待其DOM。原30秒字可见断言、原字体替换/锚点合同保持。仅修测试前置顺序，不能当成前轮未进入测试的原因。

同时把现有30分钟有界capture_native_resources监测用于initialization-pending，并保留testmanagerd/debugserver/xctest进程名（不含参数/书文），下次若宿主仍起不来能分清App进程存在与否及内存状态；不改真实功能预算/不重试用例。预计3源文件（测试/诊断选择monitor/监测器），生产仍为176303d。已备份并应用，Windows453语法0新增/54限制、工具26pass3本地POSIX跳过、Bash通过；已冻结/派发当前单项，原生结果待收。

只有首个target-resource-in-viewport、原3阶段完整，失败后attached/alpha可见、released/faceReady/readyObserved/settled均true、x0且wordVisible=false才支持初始化覆盖。若更早失败/原字保留就不应用缓存Vendor候选；候选仅将pendingLocation更新移至isSpreadLoaded判断前。

## 已验证和发布边界

39362754281/176303d幂等片2/2，真实编译0诊断、test/summary/export0，完整artifact12238663866 SHA/CRC与556核；30字体观测errorMessage全nil。首开真实模式变化与后续重复偏好有别，不声称guard唯一解释所有历史初始化故障。

39358438791/e2c7990原6项5/6：same-word viewport、真实字体重开、跨章、六字体连续、浅深旋转通过；hidden最初深字失败（未换字体），另有12条连续字体错误，后来幂等2项清零。本轮full/Release自动跳过，无Agent取消。已看深灰横/恢复竖和宽viewport3原图；未整段录屏/手机FPS。

最终151集成+29UI=180从未完整通过，设备Release未执行，无Build30；Build29最后交付。后台UI39352276145已1/1，用户Build29手机已暂停。39354867480链接0执行、39357294714docc锁解析0执行都独立保留，原project图已恢复。

普通HEAD6d761749911233122bcd031fcf718d22a19f9e77、普通index空，历史未提交/未跟踪源码、Vendor、53旧包/恢复ZIP保持；不重跑旧apply/freeze、不做R2/R3/R4/M5、无关清理或关机。历史Documentation/HANDOFF_R1_RECOVERY_HISTORY_2026-10-20.md。

## 工具

cua本地浏览器仍报Work设置禁用，未改权限。job REST日志用gh api --allow-escape-sequences原样捕获；404可能未flush，尾部也可能缓冲7分钟，不能据尾部推断挂起。以上宿主断点来自收齐的原始Session与空stdout，不是网页尾部猜测。


## Build30最终收件前交接归档 2026-10-20T07:51:04.738226+00:00

# 项目交接（2026-10-20，初始化位置覆盖最小修复）

## 当前断点

15:32:47上海：39373881574的完整测试/设备Release/打包脚本success（05:42:00→07:32:47UTC），正在上传完整诊断及IPA。六项先行阶段success保留；结构化180与原件/IPA SHA/CRC/556/53旧包最终核验、当前原生图像/录屏核验仍待收。不要重跑CI或改冻结输入。metadata回执full-step-receipt.json。

13:42上海元数据：当前39373881574的Targeted continuous rotation preflight阶段success（05:17:23→05:42:00UTC），完整Build/test/package阶段已开始。逐case完整日志/summary仍待收齐，不能把API旧尾部当挂起；当前live日志仅刷新至05:36字体case。普通源/分支继续冻结，最终180/Release未验收。metadata回执build/ci/39373881574/preflight-step-receipt.json。

39373881574 / aa0a119a71b10f1f345bc6f4cd54f6c8b4e2871a 已派发rotation-full，source-proof-latest-initial-location.json全556冻结/实际354Vendor核，Windows通过。普通HEAD/index保持。watcher exec34146/PID20472、receiver exec97148/PID37996（旧46581/34898会话失效后已核实恢复）；接收器receive_rotation_full.py expectedFull180，最终核验verify_rotation_full_delivery.py。先6项→完整180→设备Release，150分钟job上限；禁止重跑旧35分钟收件取消脚本。当前源/分支冻结，不重复派发。

39370263590/d28feaa自然结束failure，未发出Agent取消。原生1执行0/1、46.530秒、测试65/summary0/export0、Swift编译诊断0；完整artifact12241737946/98953768字节SHA1ba77a568362b9cb6e20f75e14b0c4445d6d6cf73f417a5d492eba720f8fb2db及CRC、556输入全核。watcher93265/PID24684和receiver45461/PID20636已退出0，恢复先核实际CommandLine。

对照合格：目标章节已进viewport、真实原字体ready、屏障保持时char1200可见；显式放行后当前WK attached/alpha1、released/faceReady/readyObserved/settled均true，x0且原字不可见。失败在原30秒联合断言，尚未替换字体，不是宿主未启动。原始build/ci/39370263590，记录Documentation/ValidationLogs/initialization-pending-39370263590.json。

已备份before-latest-initial-location后，仅修改Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift：把既有pendingLocation赋值移到isSpreadLoaded判断前，初始化等字体结束时读取最新定位。同步UPSTREAM真实LF摘要19ab7308346ba538b431e8493d25c1bc7bb3104fc86b89828ea1ceb21f0276f4及固定版本理由。另554构建输入不变，d28修正后的fixture原样保留；没有套用缓存旧测试。

本步源码已应用，Windows语法/工具/Bash已通过，556实际Git输入/354 Vendor清单已冻结aa0a119并派发当前39373881574，仓库/Linux Core已通过；原生先行阶段脚本已success，逐case原件待收；当前正在完整180及后续Release阶段，完整/设备Release尚未验收。当前rotation-full同job顺序6项→151集成+29UI→严格无签名设备Release30。各阶段失败阻止后续，不复用旧UI，不重复派发。冻结后直到结果/原件收齐不改构建输入。

## 已验证与发布边界

39362754281/176303d幂等2/2，30字体观测errorMessage全nil，完整artifact SHA/CRC与556核；两张真实字体原图已看，限engine harness静态正文。真实偏好变化仍完整fresh采样/原3秒预算，首次模式恢复与重复提交有区别。

39358438791/e2c7990原6项5/6：viewport同字/同WK、真实字体重开、跨章、六字体连续、浅深实际旋转通过，hidden初始深字失败、full/Release自动跳过。连续模式spread=never修复保留；原生3图已看，整段录屏/手机FPS未验收。

39352276145后台UI1/1，用户Build29手机“已暂停”，限该路径；生产暂停逻辑不改。完整旧39243868846仍171/177，当前完整180从未通过、设备Release未执行，无Build30；Build29最后交付。

39365686520前轮Agent取消/0用例，原始Session停宿主launch请求，不能归因fixture或环境独有原因；不能与本轮真实断言失败混写。旧链接/锁解析0执行独立保留，project图已恢复，不重加Readium根产品或修改锁。

## 成本与保留

本轮原生job1972秒，首case05:03:25UTC、job04:36:17，case46.530秒；结束case后仍有结果整理/诊断/上传。资源原件187样本，04:47:35至05:06:37UTC、跨度1142.622秒，未采满30分钟；不能把32.9分钟全记成用例或App启动。35分钟成本取消脚本先复查发现任务已完成，未发出取消API；不得运行该旧脚本处理下一轮。

PROJECT_STATUS/ROADMAP旧R1首页已完整归档恢复历史，当前首页不再带已失效“下一步”。普通HEAD6d761749911233122bcd031fcf718d22a19f9e77、普通index空、53旧包/恢复ZIP/未提交源码保持；不用整树reset/checkout。不做R2/R3/R4/M5、无关清理或关机。

## 工具

gh .cache/tools/gh_2.102.0/bin/gh.exe；cua本地浏览器仍报Work禁用，未改权限，CLI正常。job日志API404不等于挂起，必须收原件后报告实际阶段。使用独立索引创建私有候选，不移动普通HEAD/index。运行任务/验证接收均在派发后补写本页。


13:18上海：Windows453语法0新增/54既有限制，工具26pass/3Windows跳过，Bash通过；实际Git556与354Vendor核，私有候选aa0a119a71b10f1f345bc6f4cd54f6c8b4e2871a已push。普通HEAD/index不动。准备唯一一次rotation-full派发，冻结输入，后续收件前不改源码/分支。

本轮实际进程清单（恢复核CommandLine防PID复用）：[{"ProcessId": 29932, "CommandLine": "\"C:\\Users\\78083\\AppData\\Local\\Programs\\Python\\Python311\\python.exe\" .cache/recovery/receive_rotation_full.py 39373881574 .cache/recovery/20261019-webkit-loading/source-proof-latest-initial-location.json"}, {"ProcessId": 4040, "CommandLine": "\"C:\\Users\\78083\\AppData\\Local\\Programs\\Python\\Python311\\python.exe\" .cache/recovery/watch_autoscroll.py 39373881574"}]


13:37上海会话恢复：工具会话刷新后旧exec46581/34898已Unknown process、CIM无旧Python；远程39373881574仍运行，未取消或重派。556输入全核未变，仅恢复本地watcher exec34146、receiver exec97148，实际CIM=[{"ProcessId": 20472, "CommandLine": "\"C:\\Users\\78083\\AppData\\Local\\Programs\\Python\\Python311\\python.exe\" .cache/recovery/watch_autoscroll.py 39373881574"}, {"ProcessId": 37996, "CommandLine": "\"C:\\Users\\78083\\AppData\\Local\\Programs\\Python\\Python311\\python.exe\" .cache/recovery/receive_rotation_full.py 39373881574 .cache/recovery/20261019-webkit-loading/source-proof-latest-initial-location.json"}]。后续使用新会话；原35分钟取消脚本不适用于此150分钟分阶段任务。

最终自动门槛已核：39373881574定向6/6、完整151+29=180/180、Core各137、TXT各4、严格设备Release30、556输入/三锁六pins/53旧包、三个artifact完整SHA/CRC均通过。当前8张原生图已实际查看，开始四次旋转原始PTS连续帧与IPA内容核验；两接收/监测进程均退出0，尚未复制交付包。冻结输入不变。
