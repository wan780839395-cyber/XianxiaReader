# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## M4 第一片：开始检查点

用户“继续”授权进入 M4。已按 AGENTS 顺序恢复文档，核过 main HEAD 6d761749911233122bcd031fcf718d22a19f9e77、原 index 空、M2 tip 未动、M3 文档 tip 44af41f0b8e700db1c6815558cb95ce3b8ed08fc。706 维护文件、492 已编译运行/验证源 Git blob、23 新旧交付包、Build14 原始备份逐 hash/CRC 核过；只有文档晚于 Build14 编译。未发现自身遗留构建/监视/下载/视频任务。

开始前原始 706 文件及 inventory 共 707 项已独立备份到 .cache/recovery/20261015-build15/initial-worktree.zip，并检查 CRC；不改原 HEAD/index，保留全部未提交改动。前交接原件见 Documentation/HANDOFF_M4_SETTINGS_HISTORY_2026-10-15.md。

本轮限定五种阅读主题、内置字体选择与基础排版、全局偏好持久化和排版变化保持完整阅读位置。先核实锁定 Readium 3.11 Preferences/既有 DOM anchor API，再实现 ReadingInterfaces 能力和原生设置面板。字体文件导入、单书覆盖、四边独立间距、亮度、音量键及完整 M4 门槛后续推进。此刻源码尚未实现/编译，Build15 尚不存在；不得把计划写成验收。每可恢复步骤及构建/测试前继续更新此文。

## 已验证基线

Build14 b67a08bc7f6d0db0c97ec152a87e2128a3209c82 / CI38703788390：Linux/macOS 各110 Core、iOS84/84（79集成+5UI）、无签名设备 Release14、各四长 TXT Release探针。五种结果分开：Windows语法411/17 Python、Apple编译/模拟器通过；用户“没问题 正常”基本自用通过，其他设备/Provider/手机FPS矩阵未验。包与旧失败日志全部保留，不覆盖。详见 M3_DUPLICATES_VALIDATION_REPORT.json 及历史交接。M3 既定自用阶段收口，M4整体尚未完成。

M4源码子步骤已保存：Core版本化外观/受管理原子存储、可选ReadingInterfaces能力、Adapter Preferences映射/取消与DOM保护、原生设置面板、全局加载/串行保存与可见失败、DEBUG真实Reader UI样本；新增Core/iOS/UI回归。设计READING_APPEARANCE_DESIGN.md记录3.11官方资料和CJK缩进局部取舍。现在运行Windows语法与Python tooling，尚未编译，不宣称功能通过。

Windows检查完成：417 Swift语法文件，新增diagnostics0/上游pristine限制54；17 Python tooling通过，非Swift编译。准备通过新codex/m4-reading-appearance私有index候选推送/完整CI；原main/HEAD及index不动。预计115 Core各平台、89 iOS（83集成+6UI）；未完成测试前不打包。

第一候选14444c58ccba0ad683850625e54305111e2bd632已用私有index推送codex/m4-reading-appearance，CI38711095224已真实派发；498运行/验证源码blob hash及23旧包基线另记M4_APPEARANCE_VALIDATION_REPORT.json。CI尚在执行，未假定成功；源码失败保留原日志后最小修复，测试完成前不交付。

复核确定首候选动态CSS仅派发paginationView，而连续模式该对象nil；为避免无效长跑主动取消CI38711095224。取消前repository/Core job成功，iOS刚开始；这是Agent主动取消，不是源码编译/测试失败。已补连续current/loaded/resource脚本派发、当前资源优先/替换viewport终止，更新唯一既有Vendor修改VC的provenance hash，不改锁/原始基线；TXT回归同时断言实际字号至少增大40%。Windows417语法/17Python再过。现在保存第二候选并完整重跑。

第二候选587ff09b1e94c2aec6406847802060d01231dad0 / CI38711610037执行中，498源码hash/23旧包已登记。首轮已completed/cancelled并下载完整Core/Apple/full日志，实际Linux115Core+四探针通过，Apple停在XcodeGen依赖编译，未开始macOSCore/iOS/Release；取消证据m4-appearance-build15-agent-cancel.json，不写成产品失败。

等待第二候选CI期间的源码复核新增草稿：分页CSS变化会保留旧横向页offset，故新增仅排版变化时从fresh DOM Locator重载分页的参数/Adapter比较，纯颜色与模式原路径不变；新增分页长段落非零锚点可见与重开回归。完成/返回等待设置保存，失败留页提示。该草稿晚于正在跑的587ff09，不能用本轮CI替草稿背书，完整重跑后才可交付；预计115Core/90iOS（84集成+6UI）。尚未替换最终候选。

恢复检查点：已重新读文档/核对main HEAD、原空index、719实际维护文件/23旧包，保留快照.cache/recovery/20261015-build15/resumed-worktree.zip（CRC通过）。CI38711610037仍执行587ff09；后续分页reflow/保存失败留页/分页新增回归是晚于CI的草稿，待另次完整编译。旧watch_cover监视任务仅可读继续，未创建新重复CI。准备等待现有结果后读取完整日志/xcresult，再保存下一候选。

恢复后增补可恢复源码步骤：Adapter将分页reflow判断改为对比实际已提交appliedPreferences，防快速字号→主题/模式取消丢失必要重排；新分页测试连发字号+主题后仍要求同一非零文字锚点可见/重开。原CI尚未结束，此为待编译草稿。

恢复后准备第三源码快照（暂不派新CI，等38711610037完整结果）：已保留晚于旧候选的分页reflow/快速连发判断/设置写失败留页和新增真实分页非零锚点回归，TXT初始两字缩进computed比例也明确断言。Windows417/17Python已通过；下一候选预计115Core/90iOS。先用私有index存快照，原HEAD/index和23旧包不动，不将旧CI背书新源码。

CI38711610037已completed/failure，完整full/Core/Apple/xcresult/附件下载helper最终0。各115Core/四长书通过、Swift编译警告错误0；iOS87/89（2个失败case，3个断言/未预期失败），6UI与新EPUB五主题/位置通过。旧连续boundary首cover about:blank→watchdog/原30s超时，根因未确认；新TXT首窗口600点后非零UTF16等待超时，候选未附DOM诊断。严格test65、export/summary/recording0，未进Release，无IPA。证据second-candidate-failure.json。保持旧断言/超时不改；新增TXT使用既有已验证第二资源DOM跳转后滚动流程，同600点/>100UTF16/3px门槛，增加诊断；合并分页草稿再完整重跑。先前snapshot908da保存早期草稿，新候选需覆盖此TXT步骤。
