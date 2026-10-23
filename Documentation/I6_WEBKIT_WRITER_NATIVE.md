# I6 DEBUG writer观察：唯一原生CI结果（2026-10-23）

[CI39946614486](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39946614486)，源`0b55a4ea35e81663b0c0aa0ac4634c92616bb310`，attempt1。只派一次continuous-resize-pair、构建一次；安全臂失败后停止，冲突臂未启动。没有修改运行输入或追加CI。

## 结果

| 验证项 | 实际结果 |
| --- | --- |
| 工作流原仓库检查 | 157工具/484语法通过；54原上游限制、0新增语法诊断。不是完整iOS测试 |
| 原生编译链接 | 一次build-for-testing成功，退出0；仅编译通过，不是观察行为验收 |
| 来源与产物 | 619冻结输入匹配，609产物与安全臂前/后快照一致；原计划及两模式计划匹配，仅模式不同；实际七版本字段一致 |
| 安全臂 | 原单例仅一次，0/1，38.343秒；原test65、driver65 |
| 冲突臂 | 未启动，原退出码`null`；没有第二次构建/测试 |
| 双臂验收 | `matchedBuildVerified=false`、`semanticPairCompatible=false`；局部来源一致不能写成配对通过 |
| 失败边界 | `CancellationError()`，fixture仍在seal，stage0、effect=pending；没有sampleID/measureID，未armSample |
| 真实观察 | 无交付的WebKit版本、来源标签、scrollTo参数或属性恢复明细，均未验 |
| 业务与发布 | 未到S/M、resize、返程窄屏或原字双向断言；旧回跳根因、I6/full191/192/Release/手机门槛保持，无新IPA |

实际环境为Xcode16.4/16F6、Swift6.1.2、macOS15.7.9/24G830；模拟器iPhone16Pro、iOS18.5/22F77。OS版本不能替代本轮尚缺的WebKit framework版本，不能据它宣布与参考发布tag为同二进制源码。

## 已缩小的断点及仍缺的证据

- 原始XCTest summary、完整日志与唯一附件一致：测试抛出CancellationError；控制账本只有closing和abort-issued，`failure=none`只是未进入fixture的fail路径，不能当通过。active/tasks/waiters/queued/running全空，但没有真实S/M活动，因此不能当所有取消路径已验证。
- 已有RENDER_HOST_READY确认host appeared/key及非零viewport。唯一可见spread生命周期从request、window.attached到clear/detached，清理时仍loading且initialization=false/false；没有正文准备完成或resize证据。清理日志可能来自错误后的defer/teardown，不能仅按它先于XCTest错误打印就认定它发起了取消。
- 原测试734–747行在open、封面probe、jump与正文DOM准备后才armSample。本轮未到armSample；首个抛错await和原始取消发起者仍不能从`<unknown>:0`确定。不能直接归咎新观察器、原定位算法或运行环境。
- `EPUBInfiniteScrollView.fixtureRecordInnerDiagnostic`在live之前缓存元数据，`fixtureFlushInnerDiagnostics`到采样才交付；fixture也要求armed后接收诊断。准备期提前失败存在交付缺口。0条诊断/0条已交付丢弃计数不证明没有执行writer、不证明已恢复属性，也不能证明预arm缓冲没有丢弃。
- 原128控制、256诊断、32 waiter、16栈帧、原采样/可见/capture/cleanup预算和真实SDK回执均保持。不删除返程3请求，不豁免原guard，不以合成机制2组通过代替原生结果。

本片只核验现有证据和源码，没有修正取消传播、修改观察器或增加阶段探针。下一步建议先本地审阅准备期取消链路及失败前元数据交付，明确最小阶段/首错回执合同；保留原异常传播和所有时序预算，不立即派CI或自然重放。需要再次原生验证时须另获用户授权。

## 耗时与取证

定向驱动步骤1606秒（26分46秒）：进入构建前518.008秒、原生构建294.072秒、构建后793.921秒。安全臂bootstatus272.564秒、appearance94.512秒、test-without-building命令389.250秒；原测试本身38.343秒。不能将26分钟全部称为单例执行。

完整文字日志/API首先保留。约58MB的同一artifact下载遇到EOF/SSL中断，保留前缀、成功分段与错误，之后只接续未取得字节；这是取证传输恢复，不是CI或测试重试。最终压缩58,000,143字节、展开61,898,179字节/1047文件，GitHub SHA256与ZIP CRC通过：

`bc2753177cf1028a45b8b39a24fd595091fe6019ed2fb7305688a5056a457245`

校验/提取确认后只移除重复传输ZIP、前缀和分段；保留manifest/各段哈希/校验receipt、原完整日志、xcresult及提取文件。下载中断不作为原生CancellationError的原因证据。

## 恢复与保护

[持久验证记录](ValidationLogs/project-isolation-i6-webkit-writer-native.json)。恢复`build/maintenance/I6-webkit-writer-native-20261023/`有before、frozen、唯一派发锁、原生/来源/耗时/诊断/准备边界分析、result和最终checkpoint；原件在`build/ci/39946614486/`。

619运行输入、3742旧证据记录、Build30及普通HEAD/index均保持；没有重跑本地24项/484语法预检，没有算法、guard、原断言、预算、WK调用、等待或测试重试变化。AGENTS已有文字变化原样保留。最终本地保存revision见恢复目录final-checkpoint.json；结果文档不再触发CI，不关机。
