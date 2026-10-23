# I6 单次命令修正版唯一原生CI（2026-10-23）

后续本地审阅已完成，见[S读取时序与尚缺证据](I6_VIEWPORT_S_READ_REVIEW.md)。已排除屏障前DOM结果重放并查清缓存检查位置；具体写入者仍未证。本页原生结果保持。

[CI39895434704](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39895434704)，冻结`eb7b46628905797e15b1bc3115c77de7dd20e1ac`，attempt1。**一次编译/链接通过，单次命令被Xcode接受；安全单例真实执行一次，0/1、16.061秒，停在缩放前S资格。原test/driver65，冲突null。**没有重派、取消或输入修改。

## 分层验收

| 门槛 | 真实结果 |
| --- | --- |
| 仓库语法/工具 | 484语法、上游54限制/新增0；Linux Python141/141，35.293秒、零跳过；语法不是编译 |
| 一次build-for-testing | 原生退出0，完整测试包编译/链接通过 |
| 真实版本 | 三条命令各0，七字段完整一致，driver前缀解析保持 |
| 源码/产物/计划 | 619真实Git blob匹配冻结；609产物；三份计划摘要正确、仅模式不同，未发现重复/重试配置 |
| 安全命令前/后 | 源码/产物/计划/环境均与冻结完整一致 |
| 单次命令 | test-without-building只有一次调用，无重复/失败重试参数；真实原单例开始/失败各一条记录 |
| Swift配对机制 | paired-safe两个机制组通过，不等于全部真实夹具资格通过；旧smoke未重跑 |
| 安全原单例 | 0通过/1失败/0跳过，16.061秒；两条XCTest失败信息来自同一夹具失败与抛错，不算两次用例 |
| 安全与驱动原退出 | 均65，summary/export各0不覆盖原失败 |
| 冲突臂 | 安全未全合格，正确阻止；命令/单例均未运行，原退出null |
| 完整双臂来源/实例/语义 | 未完成，matchedBuildVerified=false，不能用安全前后来源通过替代 |
| 其他Core/独立模块/原生/UI/full/Release | 跳过，无新IPA，最后交付Build30 |

## 本例已确定的失败分支

真实失败为`pair-safe-S-unqualified`，phase=oldSample、stage0，尚未执行pair-resize、主M或缩放后的原字断言。33条有序事件与同次sample-decision明确给出：

| 顺序 | 观测 |
| --- | --- |
| 1–5 | test-auxiliary S捕获localTop2367、宽402，并在sample-before-read被持有 |
| 6–15 | 另一个native采样先读1767，第二次读2367并committed |
| 16–21 | original-capture从已提交锚点得到cached A，坐标2367；统一准入随后开启 |
| 22–23 | pair封口并放行持有的S；仍未改变窗口尺寸 |
| 24–29 | S的attempt0/1/2均报DOM documentTop/scrollY1767，期望2367、clipTop0，相差-600 |
| 30–33 | S终结rejected，reason=document-top-mismatch-exhausted；安全资格失败并关闭 |

S三次snapshotAvailable和九项上下文条件均为true，包括取消/owner/epoch/index/slot/revision/local/viewport；documentTopMatches为false。原生产guard与固定三次采样按原规则拒绝，未通过放宽条件继续。清理后active/tasks/waiters/queued/running五类集合全空。

因此，本轮已证明**这次S拒绝的具体原因**，并证明安全资格不成立；没有进入安全M或冲突对照，不能把它当连续缩放故障复现或算法错误。原生采样已经读到2367后，为何持有的辅助S又连续报1767，现有原件仍未解释，不归咎于网络或仅凭“异步”下结论。历史39782692503的第三次拒绝和旧full失败也不能据此追认根因已证。

下一最小片应先在本地审阅辅助S与native采样的调用/DOM回调时序，围绕同一reader/slot/WebView和固定clip解释上述差异。保留实际guard、原字断言与预算；不先改定位算法，不直接加等待/重试或再自然重放。**本轮没有实施新夹具/诊断或再派CI。**

## 成本与证据

目标步骤1335秒：准备至构建394.784秒，构建至成功358.434秒，其后版本/模拟器/测试/提取581.782秒。boot179.350秒、外观55.807秒；test命令321.560秒，其中原单例16.061秒，其余为宿主启动/测试会话及收尾，不能全部算作App用例耗时。macOS job1439秒，workflow1497秒；本地只复用既有28项与484语法，无额外预检或原生运行。

完整原件`build/ci/39895434704/`包含run/API/attempt/full.log、artifact元数据/摘要回执和diagnostic下完整PositionBuild.xcresult、安全原始xcresult/summary/附件、所有命令与真实退出、prepared/build-manifest/三份计划、before/after、机制与33事件回执。artifact12477785730，压缩58545584字节，SHA-256 `17ba9ee23fc0dcf4ef03308eea6f4ba6b2ab4fb4de11913bdc167592ab825bb9`与GitHub一致，CRC通过；解压1059文件/62518843字节，核验后仅删除重复ZIP。

恢复目录`build/maintenance/I6-viewport-single-native-20261023/`含before/frozen、单次派发锁、dispatch、native/sample/source/timing分析、result与最终本地私有快照。派发前Git查询一次空响应已留证，之后仅以单命令HTTP/1.1核对/上传同一源；没有重复CI POST，也不改变全局工具设置或归咎本例失败于网络。[持久验证记录](ValidationLogs/project-isolation-i6-viewport-single-native.json)。

本轮619运行输入零漂移，原smoke、隔离、定位修复、S诊断、生产guard、默认值/比较、原字断言与预算保持，旧原件/Build30/普通HEAD/index保持。旧full39735403242仍191/192，I6/Release/手机缺口和无新IPA保持。后续CI须新指令，电脑不关机。
