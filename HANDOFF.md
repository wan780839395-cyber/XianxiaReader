# 当前交接与恢复点

2026-10-16，Build21自动慢滚开工，尚未实现/编译。

用户“没问题 继续吧”记录为Build20基本自用反馈，不扩大设备/FPS验收。已按AGENTS顺序读文档，核实际HEAD6d761749/空index/私有tip02ecc460、837清单hash、35包、十份备份；838原路径ZIP备份/原hash见m4-autoscroll-build21-start.json，Build20交接归档HANDOFF_M4_BUILD20_DELIVERY_2026-10-16.md。最新完整CI38850709820成功，无遗留开发任务/活动CI。保留所有未提交改动，仅私有index快照。

下一片：自动慢滚，阅读菜单主动进入，仅连续模式；可调速、触摸立即暂停、后台/关闭/跳转/布局变化停止，重开静止。减少动态效果或VoiceOver启用时禁用并解释；不自动绕过用户系统偏好。先核设计与有界窗口，按真实时间/小数移动，不后台追赶，不逐帧DOM/写库；旧Readium execute实际不节流，需明确低频位置采样与暂停后最终完整Locator。完整Core/iOS/Release21及真实UI视频/原始帧门槛在前，不能用Windows语法替代编译。

## 源码子步骤/测试前检查点

Build21基础源码与5 Core/7 iOS回归已接入；设计READING_AUTOSCROLL_DESIGN.md。Core纯时钟、速度偏好旧兼容；可选capability→Adapter短时CADisplayLink→Vendor有界step；约每秒完整位置/暂停flush，触摸/后台/模式/排版/resize/错误停，重开静止。尚未执行Windows检查或Apple编译，不宣称通过。接下来Windows语法/17工具及私有index旧测试主体/差异审阅，再冻结源码送完整CI。

## Build21 Windows通过/Apple构建前

426 Swift语法新增诊断0（54上游语法限制原留）、17 Python tooling tests通过；不是Swift编译。私有review-index相对02ecc460核无删除，49个受改文件内原测试主体逐AST保持，新增12测试（5Core+5集成+2真正UI），507源blob冻结；证据m4-autoscroll-build21-windows.json。当前普通HEAD/index未变，原838路径/35包备份保留。现在创建私有源码候选并显式dispatch完整CI；预期Core127每平台、iOS115（100集成+15UI），实际结果仍待读取日志，不预写通过。暂未交付Build21，Build20仍可安装基线。

首候选源5abe86c3e5a7bf2e4220a62b70e008018295993d，实际dispatch CI38857983539，尚在运行；不可把本地语法通过写成Apple编译成功。下一步核实时job和完整日志/xcresult，成功后审原生视频，失败保留日志再修。

构建早期审阅补全慢滚保持亮屏/恢复原idleTimer状态的生命周期与断言。首CI38857983539当时仅Linux安装依赖/未进入Apple，将主动取消并保留取消阶段，不归为源码失败。重跑Windows检查/源码冻结后用新候选完整CI。

第二候选fc68f13e3bcb68c72d7b35ca492511874c182a2d / CI38858126400已实际dispatch。首轮取消状态另存m4-autoscroll-build21-first-agent-cancel.json。Windows重跑通过，仍49原测试主体保持/12新增/507冻结源。Apple结果仍待完整日志，当前尚无Build21安装包。

Linux完整原日志/性能artifact已实际下载CRC核验：127/127 Core、四Release长TXT探针均通过，日志无源编译warning/error。Apple仍排队/未验证；回执m4-autoscroll-build21-linux.json。运行中的本轮API watcher进程为watch_autoscroll.py，负责记录真实状态/完整日志，非永久自动化。

首轮取消最终实际阶段已核：Core编译/测试通过，取消打断Linux Release TXT性能步骤，Apple未执行（不是源码失败）。gh查看全日志因未启动iOS的log not found失败，已用REST下载真实完整log ZIP/CRC，回执保留错误和成功原件。早先“安装依赖”为当时观察，最终阶段以此为准。第二轮Linux127/四Release探针通过，Apple正在实际构建测试aggregate步骤，不能用网页尾部推断内部阶段。

只读复查发现：新增EPUB/TXT慢滚跨窗口测试在触发2.5屏预取前等待下一资源，可能因测试准备次序超时。现有整屏跨章测试先移动到当前wrapper尾部1.75屏内，再等真实相邻frame。当前507源码仍冻结为fc68f13，未修改/取消本轮，先收完整实际结果再修准备步骤；原所有断言保留，pending-readiness-review.json仅审查发现不当实际失败结果。

进入第二轮后续源码修正子步骤：当前CI38858126400仍编译fc68f13旧候选，尚未取完整结果；允许工作文件继续修正，不能再声称它们与该轮507编译blob一致。先修已代码核实的两条测试预取准备，补前台状态guard及读取/进度/设置写入错误时暂停、条内错误重试；新增真实临时存储失败/重试模型回归。旧候选完整源由Git保留，结果待核，不会据当前文件伪造旧轮测试通过。修正后重新Windows/冻结/完整CI才交付。

修正子步骤已完成，测试前检查点：EPUB/TXT先移动到当前ready尾部1.75屏触发预取，再核真实相邻frame；前台active双guard；读取/进度错误先暂停，速度写入失败条内可见/重试不自动恢复。新增临时存储真实失败/恢复原文件/重试回归，当前共13新增（5Core+6集成+2UI），预期116iOS=101集成+15UI。旧fc68候选完整freeze另存second-candidate-freeze.json，尚未用新结果覆盖；现在Windows检查，待当前CI真实结论后创建修正候选重新全跑。
修正后Windows426语法新增0/17工具通过（corrected-windows.log/corrected-tooling.log）。当前未Apple编译的修正先做私有WIP快照用于中断恢复，不触发/不取消正在运行的fc68旧源CI；其真实结果仍要完整读取。后续须再冻结最终源、显式dispatch完整CI，不能交付该WIP。
