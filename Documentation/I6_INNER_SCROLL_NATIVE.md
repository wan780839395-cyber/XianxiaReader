# I6 内层回退诊断唯一原生CI（2026-10-23）

[CI39920796794](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39920796794)，冻结`47bb1edd7c9f384c9fdd885a604c0fb34d15ef0d`，attempt1。只派一次、一次build-for-testing、只执行安全原单例一次。**编译链接通过，原单例1/1通过；安全整臂被原夹具校验拒绝，driver真实2、原test真实0、冲突未启动/null。**不修改输入、不补跑、不追认完整配对通过。

## 分层结果

| 门槛 | 实际结果 |
| --- | --- |
| 原repository-checks | Linux Python145/145、38.210秒；484 Swift语法，54既有上游限制/新增0 |
| 原生构建 | 一次build-for-testing成功、退出0；新增诊断已编译并实际运行 |
| 来源/版本/计划 | 构建前619实际Git blob一致；609产物、原计划及仅模式不同的两计划、安全臂执行前后与同一冻结一致，实际七版本字段一致 |
| 原安全单例 | 1次、1通过/0失败/0跳过，15.881秒，原退出0；宽屏874及返回窄屏402的原字可见断言通过 |
| 原配对机制 | paired-safe两组通过，含原取消机制；不能代替新增诊断取消分支实际命中 |
| 安全夹具/控制合同 | `Unregistered SDK work crossed the paired interval`，整臂不合格；源码中原校验未改变 |
| 退出/后续 | test0、summary0、export0，driver2（GitHub job原失败annotation确认）；冲突未启动/null，matchedBuildVerified=false |
| 清理 | active/tasks/waiters/queued/running全空；当前coverage结束时pendingEvaluations/pendingWriters/untracked均0，无writer容量缺口 |
| 取消/迟到新分支 | 本例未命中cancelled-before-submit/late回执；有本地合同和原机制覆盖，但不能声称这些新增分支完成原生专项验收 |
| 发布 | 未跑full/Core/其他UI/Release/设备，原smoke未重跑，无新IPA；旧full191/192、I6/Release/手机缺口保持，最后交付Build30 |

## 诊断回执已取得，旧1767故障本轮未复现

85条原控制事件，142条独立诊断、零丢弃，其中116条内层记录。早期暂存交付56条，preArmDropped=0；原256诊断/128控制上限保持。

目标WebView=`ObjectIdentifier(0x0000000108977000)`，coverage=`74F3667D-B4EA-401E-AD87-23473BD08A9C`：

- coverage-start一次，uptime1535.618147790、当前章尚未初始化/附着；coverage-end一次，uptime1539.752211657、active=false，reason=viewport-clear，pending三类均0。绑定前命令仍明确未覆盖，不能把零丢弃扩大为浏览器全生命周期完整审计。
- 18次evaluation的enter→实际submit→callback均完整且Swift时间顺序成立；18组显式writer前后均成对。另有邻章0的覆盖起止，未冒充当前章回执。
- 原S只采一次便提交：实际WK提交/回调/返回的native inner与同次JS起止/documentTop均2367，clipTop0，原guard通过。native独立采样仍先1767、再2367；但在S实际提交之前没有重现旧的inner回到1767。
- 首次观测回退为**2367→2151**，uptime1538.423951943，位于原控制事件40（主M guard）之后、真实宽屏resize之后。writerID=`B0409405-CCA1-46E8-B282-A62E3338B288`，source=viewport-scroll-delegate，target/after均2151、before2367；同一栈包含`UIScrollView setContentOffset:`及`EPUBInfiniteScrollView.updateViewports`，与同次显式赋值回执吻合。
- 该回退发生时width874、height306、contentHeight5958、inset0，与原封口前1767疑点不是同一阶段。原主M已记录的资格及mayRestore均true，原字宽窄双向检查通过；不能拿这条缩放后赋值去解释历史0.383秒窗口。

以上证明探针可以关联本次实际写入、真实WK提交/回调、覆盖及正常关闭；**不能证明旧2367→1767写入者、旧full缩放根因或诊断代码“修复了”时序。**新增观测有时序扰动可能，单次通过不等于根因已修。

## 本轮失败已定位到控制区间与验收区间不一致

原件明确顺序：

1. seq22封口；S在23–27放行/提交/终结，seq28才宽屏resize。
2. seq29–59为主M、另一个M及一个sample的原准入、真实终结与串行排空；seq60=`pair-drained`，seq61=`admission-complete`。
3. `Tests/iOS/ReaderRenderingTests.swift:590`的acceptVisibleResize在首次宽屏原字合格且quiescent时关闭admissionActive；832–877随后仍按原用例恢复窄屏，但不再走首轮配对准入。
4. seq62–83出现3个真实native请求（2个measure、1个sample），未queued/admitted，但均有终结；seq84才closing。
5. `scripts/verify_reader_positions.py:481`仍要求整个seal→closing期间的SDK工作都在queued登记集合或S内，所以拒绝seq62/64/68、69/71/75、76/78/83这九条事件，合计3个请求。驱动按原规则返回2，停止冲突。

这是有源码和完整事件对应的合同范围不一致，不是新诊断事件被误识别为SDK任务，也没有证据证明是诊断新增了这些业务请求。原fixture与验收器均在本片未改变的614项内。**不能把这3个请求直接忽略、缩短校验窗口、删除返程窄屏断言或放宽原字预算来换绿。**本轮不修该边界。

下一最小片应先在本地审阅pair-drained、admission-complete、返程窄屏及closing各自负责的控制/验收范围，明确保留哪些原生工作登记和双向断言，再选择最小修正；不立即派CI，也不改定位算法。旧1767候选仍保留，不能以自然重放未出现作为修复证据。

## 成本、原件与恢复

原定向步骤1016秒（16分56秒）：准备262.751秒、编译337.967秒、构建后版本/模拟器/测试/提取415.282秒。boot165.636秒、外观31.434秒；test-without-building命令190.630秒中原单例15.881秒，其余是宿主/会话及收尾。job1140秒、workflow1200秒；未追加本地预检。

`build/ci/39920796794/`保存run/API/job/失败annotation、全日志、repository-checks原日志、artifact元数据及完整展开原件；包含构建/安全测试原xcresult、summary、6个附件与manifest、实际命令/原退出、prepared/manifest/三计划、before/after。artifact12488490925，压缩2845667字节、展开7610769字节、96文件；SHA256=`27f88725772acfb0f86dc37d9d07b6f9d00cd2848549fea55ac278049cc6ac06`与GitHub一致，CRC通过，核验后只删除重复ZIP。

日志读取曾遇CLI终端控制字符保护，原错误保存，显式允许原样落盘后读取成功；不是CI重试。driver数值退出由job原failure annotation确认，完整文字日志未包含该annotation；不据缺少某条文本行改写真实结果。

恢复`build/maintenance/I6-inner-scroll-native-20261023/`保存before/frozen、唯一dispatch-attempt/dispatch、native/correlation/inner-receipt/source/timing分析、unregistered原事件、result、文档检查及最终私有快照；[持久验证记录](ValidationLogs/project-isolation-i6-inner-scroll-native.json)。619运行输入、2426旧证据记录、Build30与普通HEAD/index保持。没有源码/算法/guard/原断言预算/等待重试变化、取消或重派，不关机。
