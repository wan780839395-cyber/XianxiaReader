# I6 准备期首错与旧缓冲保全：本地实现，行为未验（2026-10-23）

按追加的收敛授权实施[既定方案](I6_PREPARATION_CANCELLATION_REVIEW.md)，只改约定5个运行输入。原生首个抛错await、取消发起者与旧2367→1767回退来源仍未确定。本轮零CI、零推送，不把源码检查写成取消行为通过。

## 实现边界

- `Tests/iOS/ReaderRenderingTests.swift`：paired-only准备记录保存最新阶段、进入/捕获时uptime及当前Task取消标志、动态错误类型和NSError domain/code；首错只写一次，不记录正文/userInfo。原最早cleanUp defer仍在外层do/catch之外，先记录再原样throw error；准备完成后的失败不归入准备首错。沿原open/probe/jump/waitUntil挂起点增加同步、默认nil观察参数，未新增async wrapper/await。nonce/mode仍由原fixture payload关联，原生reader/epoch/slot/WebView沿旧诊断事件交付，不制造Task ID。
- 同一测试文件仅放开paired诊断分支的预arm接收。独立256诊断journal不授予S/M或控制资格；smoke与原armed、pause/admission/guard保持。增加同步mechanics反例，但本机未执行这些Swift机制检查。
- `EPUBInfiniteScrollView.swift`：保持原coverage-end关闭动作，在epoch/storage/owner作废前向捕获的旧fixture同步排空一次；clear和fixture setter两出口均覆盖。正常采样flush时点保持。复用原255缓冲+1receipt规则，溢出仍带dropped/incomplete；无storage不懒创建空生命周期。已知shutdown/reload/真正timeout-fired原位置增加被动诊断标签，未覆盖入口仍unknown。
- `UPSTREAM.json`仅更新该Vendor文件摘要和本片说明；两个既有Python测试文件增加源码边界与验收反例。Adapter、Spread/FixedSpread、JS资产、工程、CI驱动和验收器均未修改。

## 已执行与未执行

| 检查 | 结果与边界 |
| --- | --- |
| provenance18 + 原smoke2/配对7 + 新增验收反例2 | 共29项：28通过，真实Swift helper行为1项skip；不是29/29行为通过 |
| 原样Swift helper夹具 | 已生成`.cache/preparation-diagnostics/harness.swift`及`behavior.json`。直接抽取实际Trace/Buffer/Event/交付方法，仅用mock替换UIKit owner和sink。计划核首错/原NSError重抛、真实Task取消、完成后忽略、255边界/旧sink/一次排空；本机没有swiftc，未编译执行，UIKit接线也未验 |
| 仓库静态/语法 | 7静态检查、484 Swift grammar通过；54条上游已登记语法限制、0新增；不是Swift类型检查或编译 |
| 原行为源码合同 | 原await序列、嵌入JS、WK调用111处、原sleep表达式、control/pause及物理清理顺序保持；原arm之后至关闭前的整段单例字节一致，含返程窄屏和双向原字断言 |
| 保护核验 | 619输入仅约定5项变化，其余614保持；4848旧证据记录、Build30 IPA/TestKit及普通HEAD/index保持 |
| 原生/full/Release/设备/IPA | 本轮均未执行/生成；旧full191/192、I6/Release/手机缺口保持 |

本机`swift`/`swiftc`不可用，Docker Linux engine管道不存在；WSL仅安装docker-desktop、无运行发行版。原始环境返回已保存，不启动或重置用户工具，不把环境问题当原生CancellationError原因。首错保全、旧owner一次完整交付和取消路径行为未实际验证，因此派发前必要证据不成立：**本轮停止于本地阶段，不派CI。**

## 原生证据与判读仍保留

最后实际run39946614486仍为一次build/link0、安全原case0/1/test及driver65、冲突未运行null。原错误是准备期CancellationError，未arm、诊断交付0；fixture.failure=none和空清理集合都不是通过。真实WebKit framework版本、来源标签、scrollTo实际参数和属性恢复仍未核实。新代码尚未改变这些历史事实，也未证明取消由WK、timeout、cleanup或新观察器引起。

将来只有实际拿到首错阶段/取消标志及同owner时间线后，才能按审阅方案区分原WK失败、轮询取消、加载保护或后续清理；单凭错误类型或打印先后不能确定发起者。缺首错、旧缓冲、身份、完整诊断或发生overflow时继续判为证据不足，不放宽guard/断言或原预算。

唯一下一步建议：先在可用Swift6.1.2环境执行已保存的原样helper检查，建立首错与旧sink行为证据后，再判断条件授权的一轮现有配对CI是否具备派发条件；不先自然重放或继续叠诊断。

## 恢复

[持久验证记录](ValidationLogs/project-isolation-i6-preparation-diagnostics.json)。`build/maintenance/I6-preparation-cancellation-implementation-20261023/`保留5原件、before、环境错误、完整定向日志、语法报告、source-audit及结果/checkpoint。私有恢复ref见checkpoint；普通工作区和Git index保留，未推送、合并或发布，不关机。
