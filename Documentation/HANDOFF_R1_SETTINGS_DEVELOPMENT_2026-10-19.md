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

