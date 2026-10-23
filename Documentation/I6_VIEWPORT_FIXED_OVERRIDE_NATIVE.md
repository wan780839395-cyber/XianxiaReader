# I6 FixedSpread修正版唯一原生CI（2026-10-23）

[CI39912011242](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39912011242)，冻结`dfc20131232a76061bf074bc1cc739c013ccd8df`，attempt1。**一次构建/链接通过，FixedSpread签名错误已通过原生编译验证；安全原单例只执行一次，0/1、19.164秒，S资格失败原test/driver65，冲突null。**没有改输入、补跑或重派。

## 分层结果

| 门槛 | 真实结果 |
| --- | --- |
| 仓库检查 | Linux Python142/142、35.719秒；484语法、54既有上游限制/新增0；语法不是编译 |
| 一次build-for-testing | 原退出0，原生编译/链接成功，上一轮FixedSpread override错误消除 |
| 来源/版本/计划 | 实际619个源码Git blob与冻结一致；609产物、原计划与两份仅模式不同的计划摘要一致；安全命令前后冻结一致，实际七版本字段一致，无重复/重试配置 |
| FixedSpread运行透传 | 签名与转发源码已编译；此同例使用reflowable连续阅读，并未专门执行固定版式子类运行行为，不能扩大为FixedSpread运行专项验收 |
| 配对机制 | paired-safe两机制组通过，含已接入的同步journal检查；不等于真实S资格通过。原smoke未重跑 |
| 安全原单例 | 1次执行、0通过/1失败/0跳过，19.164秒；`pair-safe-S-unqualified`，oldSample/stage0，尚未resize/主M/缩放后的原字断言 |
| 原退出 | 安全test与driver均65，summary/export均0未覆盖原失败；冲突未启动/null |
| 清理 | active/tasks/waiters/queued/running五类集合全空；验证器“preparation and cleanup”通用错误来自准备资格不成立，不能据此称清理失败 |
| 完整双臂同构建/语义 | 未完成、matchedBuildVerified=false；安全前后来源相符不能替代完整双臂验收 |
| full/Core/UI/Release/设备 | 均未追加，无新IPA；旧full191/192及I6/Release/手机缺口保持，最后交付Build30 |

## 本轮新增证据：内层滚动在S提交前已经回退

原33条控制事件与独立18条诊断，diagnosticsDropped=0。辅助S在读取前被持有，另一native请求先读1767、再读2367并提交A；original-capture命中A缓存，然后封口放行S。这与上轮相同；新增关联记录把内层状态补齐：

| 点位 | Swift systemUptime | 内层native Y | 同次DOM/判定 |
| --- | --- | --- | --- |
| native有效样本提交 | 1726.523030652 | 2367 | 随后JS返回2367 |
| native有效样本回调 | 1726.613194084 | 2367 | 此次结果供后续提交A |
| native snapshot返回 | 1726.615739598 | 2367 | 此时live anchor仍为旧指纹，之后原生产流程提交A |
| S attempt0实际WK提交 | 1726.999230717 | 1767 | live anchor已经是A |
| S attempt0回调/返回 | 1727.027363025 / 1727.028825293 | 1767 / 1767 | JS起/止/返回均1767 |
| S attempt1提交/回调/返回 | 1727.063264390 / 1727.075796186 / 1727.077258786 | 均1767 | JS起/止/返回均1767 |
| S attempt2提交/回调/返回 | 1727.113950693 / 1727.118657521 / 1727.119907568 | 均1767 | JS起/止/返回均1767 |

每次提交都在原加载等待后、实际WK调用前；完成回执位于原continuation恢复前。三次requestID/attempt、提交→回调→返回顺序及同次JS数值完整，nativeAvailable/slotCurrent成立。JS内部performance.now前后单调；表中跨点比较只用Swift同一时钟，不与JS时钟相减。

因此，最后确认内层2367至S首次提交读1767的观测窗口上限为**0.383491119秒**，不是已确定的写入时间。S首次JS尚未提交时native内层已是1767；不能再用本次S脚本布局读取、屏障前DOM快照重放或回调乱序解释这次回退。不能外推所有历史故障都具有相同原因。

S的outer localTop/frame.minY仍2367，clipTop0，revision/index/slot/epoch等九上下文条件全true；DOM documentTop1767与期望2367相差-600，原guard以`document-top-mismatch-exhausted`拒绝。A指纹在三次live观测和终结时仍保留，没有被旧S覆盖。

## 写入来源核对与证据缺口

同一WebView的`viewport-sync`共3条，实际只有**2个writerID/调用**：

- `scroll-delegate`一调用：frame从1767移至2367，inner原1767；原差值条件实际赋值，最终inner2367。
- `layout-slots`一调用：分别关联native请求和被持有S，所以记两条；frame/inner前后均2367，未执行offset赋值。

没有该同步点写回1767的回执；上述两次调用均在native有效样本完成之前，回退窗口内没有新的该点记录。新增诊断完整无丢弃，但仅覆盖既有updateViewports及读取边界，**不能排除go/canonical JS、窗口/根元素滚动或WebKit内部native变更等未覆盖路径，也不能据此选定写入者。**本例仅证明native内层已经回退后S如实读到1767；1767具体写入来源、旧full连续缩放根因及定位修复验收仍待证。

下一最小片建议只在本地审阅这0.383秒观测窗口对应的内层写入路径，明确尚未覆盖的入口；不先加等待、重采样或修改guard来让S通过。本轮没有实施新探针或算法修复。

## 成本、原件与恢复

定向目标1299秒：准备315.814秒、编译至成功313.886秒，其后版本/模拟器/测试/提取669.300秒。boot214.857秒、外观32.377秒；test命令379.809秒中原单例19.164秒，其余为宿主/会话及收尾，不能算作App用例执行。macOS job1407秒、workflow1470秒；没有追加本地预检。

完整原件`build/ci/39912011242/`含run/API/全日志、构建xcresult、安全原始xcresult/summary/附件、实际命令与原退出、prepared/manifest/三计划、before/after及完整控制/journal回执。artifact12483609769：61314212压缩字节、65390762展开字节、1057文件；SHA-256`d22a3b66ea8a0ff16292f41e852d56859810c157cafc5c4434b6222ea2868101`与GitHub一致，CRC通过，仅删除核验后的重复ZIP。

恢复`build/maintenance/I6-viewport-fixed-override-native-20261023/`含before/frozen、唯一派发锁/dispatch、native/correlation/sample/source/timing分析、rollback-window/result和最终私有快照；[持久验证记录](ValidationLogs/project-isolation-i6-viewport-fixed-override-native.json)。619输入、1305先前证据、Build30与普通HEAD/index保持。失败已留证，不自动重派、整套或更改算法/guard/原断言预算，不关机。
