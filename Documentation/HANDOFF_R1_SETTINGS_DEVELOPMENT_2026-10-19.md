# R1 设置隔离开发历史

以下是恢复整理前的原始检查点，运行状态只代表当时；当前状态以根 HANDOFF 为准。

# 当前交接与恢复点

## 用户同意优先隔离阅读职责（2026-10-19）

恢复先看：当前唯一运行是最终完整39189899149/source9b47026，watch_autoscroll.py同run，日志在build/ci/39189899149/watch.log；Windows451/17已过。定向39188609488已3/3且原件收齐，原完整39184148461仍按170/172失败保留，无Release/IPA。当前App/Packages/Vendor/project/锁与已通过35项定向的b111源完全相同。预期本完整137各/173=145集成+28UI target（含1纯测量/27真UI）/Release30，尚未新完整门槛或交付；勿重复派发或把诊断通过写成TOC点按根因已修。

用户明确要求实施并参考成熟项目。R1 已审阅同基线 Readium 3.11 UserPreferencesStore、固定 revision Readest 设置/书籍存储及 Apple actors 并发合同，具体链接与取舍在方案。源码已接入共享设置队列、窄存储接口和按会话过滤的完成订阅；新增7项独立存储边界+2项生命周期回归，原test主体待冻结对照。新增 settings 定向入口只跑存储与生命周期，不生成 IPA。恢复基线在 `.cache/recovery/20261019-settings-isolation/start.json`/`before/`。Windows451语法新增0/54既有Vendor限制、17工具、bash -n通过；版本30待Apple定向，随后同源完整门槛，尚未编译/交付。旧完整位置采样与3秒/20秒预算不改。

冻结源 `b1119d0b79601d0537c7208533d2b079e5706e7e` / `codex/refactor-reader-settings` 的 settings 定向 [39182894124](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39182894124)真实35/35、失败/跳过0（26原生命周期主体逐字保持+2新生命周期+7存储），实际测试0.85秒，Swift编译诊断0；Linux137通过。完整日志、xcresult summary及两artifact的GitHub digest/CRC已核，原生大材料仅约0.4MB，不生成IPA。8运行/测试/配置路径白名单和正常HEAD/index保持；同恢复目录 `candidate.json`/`candidate.diff`/`diagnostic-result.json` 可恢复。接下来唯一同源完整137各平台/172iOS（145集成+27UI）/Release30，完整门槛仍未通过，不拿定向代替交付。

同源完整已唯一派发 [39184148461](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39184148461)，运行代码不再变化，预计137各/172iOS/Release30。正式范围与定向结果在 `Documentation/ValidationLogs/m4-settings-isolation-r1.json`。本地核Linux时首次误用macOS的Executed汇总格式断言失败，已按实际并行日志核137个唯一XCTest索引；原件与CI未变，不重跑。恢复先核本run实际状态和日志，不另派完整。

本完整run的Linux原件已GitHub digest/CRC核收，137唯一XCTest及4组长TXT Release探针的allChecksPassed均正确；只置Linux门槛。Apple仍运行，gh watch为exec80920，完整日志/summary/Release30尚待，不修改冻结源码。

完整39184148461已真实失败：145集成全过，27UI中25过/2失败，预期170/172待xcresult原件核实；无Release/IPA。旧progress/header用例在第一次目录跳第二章后等待“灯下第1段”20秒失败（尚未改设置或执行回看），旧安全区用例完成浅深旋转后返回按钮AX高度43.999999999999986低于原44断言。所有9新增用例、旧字体/设置UI均过。当前下载同run完整1922089479字节artifact12158577919（exec5356）看原图/录屏/AX，旧预算和生产源码暂不改。先查官方浮点精度合同并定位真实页态，之后只定向这两项；不盲重派完整。

原件已GitHub digest/CRC全收，xcresult确为170/172；下载5356/监看58689都已结束。已实看2张完整录屏1fps总览、点按原帧、深色恢复竖屏与设置重开原PNG，解码点按事件为portrait402x874下x201/y424.333。记录中第二章点击后目录仍停留，没有设置编辑/回看操作，独因未定，不改引擎。依据Apple FloatingPoint.ulp，只将安全区用例的高度测量限定为4ULP近整数归一化，保留原44阈值；新增纯测量反例43/43.5/43.999999仍不合格。旧progress函数逐字不改；其他原test只有此1处测量适配。App/Packages/Vendor相对b111保持。Windows451新增0/17工具/bash -n通过，下一唯一settings-ui3诊断（两失败原case+1纯测量），不拿它当完整门槛。详情first-full-failure.json。

三项定向已唯一派发 [39188609488](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39188609488)，源`9b47026ace3d9fc92d1df943b112fb19a96d5ffd`/同构建ref，生产App/Packages/Vendor/project/锁与b111完全相同，仅UI测量与定向配置变化。预期3（2真UI+1纯测量），不是完整/Release门槛。实际范围ui-candidate.json/diff；之后若需完整应为173=145集成+28UI target（27真UI+1纯测量），不能把原27真UI写成28真UI。

39188609488/9b已真实3/3、失败跳过0，原progress93.689秒、原safe-edge80.023秒、新纯测量0.154秒；原prod输入与进度函数未改。本次通过不证明旧目录点按根因已修。完整原件GitHub digest/CRC已核，保留首轮170失败及原图/录屏。即将冻结同9b唯一full173/137各/Release30，不继承诊断为交付门槛。

状态监看gh watch80920因GitHub API EOF退出1，独立API已核run39184148461仍in_progress。一次提前请求完整日志明确返回“仍在运行、结束后可用”，不算源码/测试失败。改复用已有watch_autoscroll.py同run，仅接续查询和最终取日志，不dispatch；旧watch错误在full-watch.log，恢复须查真实run，不凭本地监看退出码判CI失败。

实施顺序和第一片边界见 [READER_ISOLATION_PLAN.md](Documentation/READER_ISOLATION_PLAN.md)。恢复时先核实际工作树、同源run与任务，再按单片范围推进；Build29 交付和既有未定根因继续按下文记录。定向watch已结束；完整当前复用watch_autoscroll.py39184148461，日志在build/ci/39184148461/watch.log，不另起重复监看/dispatch。源码冻结，运行时不要更新构建ref或把未完成结果写成通过。



## 2026-10-19 关闭合同复现与定向候选历史（以根交接最新状态为准）

# 当前交接与恢复点

## R1设置隔离与分项验证（2026-10-19）

当前唯一运行：[reader-session 39211610770](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39211610770)，383b11a69f71094e229facaa7e4129e128e8956b/codex/refactor-reader-settings，预期66项，不构建设备包。前两项诊断均已结束并核原件：加载对照3/4，关闭合同0/2，均未取消。当前源码554输入已对快照核验，453 Swift语法新增0/25工具通过；正常HEAD/index保持。snapshot/source-proof与精确差异见.cache/recovery/20261019-webkit-loading/close-fix-candidate.json与source-proof-close-fix.json。等本run实际结果再决定下一步，不重复dispatch、不更新构建ref。

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

