# 当前交接与恢复点

## R1设置隔离与分项验证（2026-10-19）

最新实际证据：39209145399/cb14211为3/4，微型scheme连续8次加载/释放全过（首次3.20秒，其余0.40～0.61秒），六字体第6次重建WebContent启动62.15秒而失败。39209591549/99acd92为0/2，两项新关闭回归确实在旧生产上失败：分页回调未断开/预加载未移除，立即关闭后两模式均迟到创建WebView。现只修Adapter的close调用和Vendor navigator的终止合同，拒绝初始化跨await迟到；沿用未修改的Readium PaginationView移除/clear机制。等待66项reader-session定向（30 renderer +28 lifecycle+7 settings+1末尾WK control），不先打包/跑UI；原20秒/3秒/字体15秒预算保持。微型probe改排最后，避免预热真实reader回归；移除仅100ms观测且不能证明旧对象泄漏的临时teardown采样，改用明确关闭合同断言。补有界只读资源采样以便区分后续进程启动/内存条件，不记录命令参数或小说。当前修正尚未Apple编译。

第二个互不依赖的关闭合同诊断：[39209591549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39209591549)，99acd92/codex/webkit-close-diagnostic，生产仍未改。此run预期验证两项新关闭合同是否在旧实现上失败，不能据其结果打包；四项加载对照39209145399仍在原分支运行，没有被取消。两run分别完整保留真实结论。

当前唯一诊断：[39209145399](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39209145399)，源cb1421185a56b51b083ba619b8265770264b3dd6，webkit-loading共4项。453 Swift语法新增0/25工具/bash通过（不是编译）；28原renderer主体逐字不变、生产/UI/样书/锁不变已核。私有快照和准确备份见.cache/recovery/20261019-webkit-loading；正常HEAD/index保持。等待真实原生结果，不更新此构建ref，不重复dispatch。

用户最新要求：把耗时教训写入整个项目并继续解决阻塞。已更新根AGENTS.md并新增Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md，后续会话按最小假设实验执行。当前准备webkit-loading定向：一个不导入Readium的微型自定义scheme页面连续8次创建/加载/释放，对照原三个失败用例；原28个renderer函数主体和生产20秒/3秒预算保持，测试helper记录关闭100ms后弱引用是否仍存活。新增1个control及2个关闭合同测试，因此后续候选总单元/集成应为148（旧145全部保留）；先运行4项原生诊断，不打IPA，不盲跑全套。App/Packages/Vendor/UI/project/锁不改。当前新增源码尚未Apple编译，以后续实际run为准。两个关闭回归先在未修生产的源上运行webkit-close诊断：验证分页关闭时仍保留回调，以及已排队初始化能否在close后创建WebView；故意持有旧navigator，证明是否依赖deinit清理。此诊断与四项最小加载互不依赖，使用独立CI分支避免取消旧run。

实际断点：[unit-release 39203522040](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39203522040) / 冻结源`cb0b1e296985a3ba7d1fe4c64339d65dea4d5e2f`已于05:38:56 UTC结束，结论failure。xcresult为145总、142通过、3失败、0跳过；settings 7项和lifecycle 28项全部通过。Linux/macOS Core各137、各4项Release TXT探针通过；旧28项UI基线真实日志及同输入保护校验通过。test=65，export/summary/recording=0，Release未执行，没有Build30 IPA。完整Apple/Core原件已下载并核GitHub digest/CRC，监看和下载任务已结束；禁止把监看器exit0写成CI成功。

上一轮完整验证：39196134450/source8f已失败并收齐digest/CRC原件。28 UI target全部通过，145单元/集成仅旧ContinuousLayoutFailureShowsRetryAndRecoversTheAnchor在初始cover失败，尚未注入故障。raw173唯一case/172过/1失败，xcresult summary172总/171过/1失败，两种原值都保留。20秒预算内WebKit在19.198秒才开始导航；慢启动独因仍未证明已修。

三项失败是ReaderRenderingTests的AutomaticScrollRealDisplayLinkPauseLateFrameFullLocatorAndReopen、SixFontsAndExtendedTypographyKeepFreshNonzeroContinuousAnchor、TallCoverUsesWholeViewportInPaginatedAndScrollingModes。日志明确出现WebContent进程启动24.550291秒与30.992426/31.131335秒；前一项宿主已appeared、key、foreground、非隐藏。原20秒预算内未完成导航，不是已证明的设置失败，也不能据此认定全部是环境问题。上一轮失败的ContinuousLayoutFailureShowsRetryAndRecoversTheAnchor这次通过；宿主检查没有解决慢启动问题，保留为诊断，不能标成根因修复。详见`Documentation/ValidationLogs/m4-settings-isolation-r1-unit-release-failure.json`。

当前候选只改测试宿主与CI：明确前台scene、真实viewDidAppear/key-window/非零几何后才open；全部28个renderer测试函数主体不变。unit-release重新读取真实8f/39196134450元数据和完整UI日志，核28项各通过一次、无失败/跳过及App/Packages/Vendor/Tests/UI/Fixtures/project/锁等受保护输入相同，并核Xcode16.4/16F6、host arm64、iPhone16Pro/iOS18.5；本轮该保护已实际通过。当前145必须全部通过才继续原严格Release30。默认full保留，不能把分项证据写成一次173/173。Windows452语法新增0（54旧Vendor限制）/25工具/bash已通过；语法不是编译。

R1生产代码仍只有AppServices/ReaderViewModel/ReaderSettingsPersistence三个文件，App与Packages/Vendor/UI/project/真实锁同8f（也是b111生产输入）。已过settings35/35；UI公共fixture修正的39194509105/8f为6/6，Swift编译诊断0，原件及portrait深灰/文楷原图已核；其后28 UI全套通过。此前完整170/172、169/173及本轮失败均独立保留；目录首次点按失败和WebKit慢启动独因仍未定。R2字体/R3位置/R4会话服务未实现，M4/手机验收未完成。

正常HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，暂存区空，大量既有未提交源码保留。实际编译源为cb0b1e2，UI完整验证源为8f5b427；私有分支codex/refactor-reader-settings。恢复材料见`.cache/recovery/20261019-settings-isolation/render-harness-before/`、`render-boundary-proof.json`和`source-proof-unit-release.json`。正常index看不到的私有快照文件不能直接拿git diff base对工作树判断删除；用alternate-index tree/commit对commit核验。此前本地一次直接比工作树的guard失败已按此修正，真实保护输入仍相同；没有改正常index。最新`build/ci/39203522040/recovery-checkpoint.json`已重核552源码/资源输入、53旧交付包SHA、空index和正常HEAD；旧恢复ZIP未触及，不关机。

实现、成熟项目/官方依据、失败详情与当前验证入口：[READER_ISOLATION_PLAN.md](Documentation/READER_ISOLATION_PLAN.md)、[R1验证记录](Documentation/ValidationLogs/m4-settings-isolation-r1.json)。设置职责提取已编译并通过定向回归，但R1整体验收仍未完成；Build29仍最后交付，没有本片IPA。下一断点是最小WebKit加载/子进程启动对照，先证实原因或隔离条件，再改动与重测；不继续无假设地重跑整套，不扩大到R2/R3/R4，不放宽20秒/3秒预算。

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
