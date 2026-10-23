# I6 S关联诊断唯一原生CI（2026-10-23）

后续[FixedSpread签名候选已本地修正](I6_VIEWPORT_FIXED_OVERRIDE.md)，零CI；新源仍待原生编译，本页原构建65/两臂null保持。

[CI39908431098](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39908431098)，冻结`3ab0bcbe6a9a15e51eb2423ac526dcc08ac0d52e`，attempt1。**只派一次、只构建一次，编译失败原退出65；安全/冲突臂均未启动，退出均为null。没有新的S关联观测，更没有证明1767根因已修。**

## 明确的失败原因

错误位于`Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBFixedSpreadView.swift:122`：`method does not override any method from its superclass`。

本次诊断补丁把父类`evaluateScript(_:inHREF:)`改成了带第三个`fixtureReadObserver`参数的方法；固定版式子类保留原两参数override。第三参数即使默认nil，也没有保留原override合同。该FixedSpread文件与诊断补丁前`b58b55b9`字节相同，父类签名变化来自本次新增诊断；扫描Navigator仅此一处evaluateScript子类override。

这是**本次诊断改动漏审父子方法关系**，不是旧项目复杂、网络、旧定位故障或S行为断言造成的失败。本地484项语法和离线JS检查没有进行Swift类型编译，未能检出这项错误。本轮冻结源码完全保留，没有临时改代码补跑。

对照[固定Readium3.11子类实现](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBFixedSpreadView.swift)可核其原两参数override及href/iframe脚本包装。后续修正必须保留包装、转义、默认href与原super await，不能删除override或绕过固定版式来让编译通过。

## 验收分层

| 项目 | 结果 |
| --- | --- |
| 工作流派发 | workflow_dispatch一次，attempt1；无取消、重试、第二run |
| 仓库检查 | 484语法、保留54上游限制/新增0；Linux Python141/141、35.800秒；不等于原生编译 |
| 构建前来源 | prepared实际619个Git blob与冻结逐项一致 |
| 构建环境 | Xcode16.4/16F6、Swift6.1.2及macOS15.7.9/24G830等实际七字段与prepared一致；每臂运行前的版本复核尚未执行 |
| 一次build-for-testing | 已执行，Swift编译失败，原退出65；未编译/链接成功 |
| 安全原单例与Swift配对机制 | 均0次执行，原退出null；不可报0/1用例失败 |
| 冲突原单例 | 未执行，原退出null |
| S提交/回调/inner offset/写入journal | 没有新的真实回执，不能核验其原生行为或据此判断1767来源 |
| 构建产物/双臂同构建来源 | build-manifest尚未生成，后续产物/计划/实例/语义配对校验未到达 |
| full/Core/UI/Release/手机 | 选择正确跳过，本轮无新结果、无新IPA；旧full191/192与I6/Release/手机缺口保持，最后交付Build30 |

仓库工具日志中出现的旧`-test-iterations`报错来自预期的负例子进程，整个工具套件141项通过。真实reader-positions失败是上述FixedSpread override编译错误，不能混淆两者。

## 耗时与原件

定向目标步骤467秒：从开始到构建命令约335.161秒，构建命令到明确失败约131.946秒；原生用例0秒。macOS job486秒，workflow547秒。GitHub阶段时间到秒、构建日志到小数秒，不强求子阶段小数之和恰等于整数API时长。没有追加本地语法/工具预检，复用上片结果；保留工作流已有仓库检查。

完整原件在`build/ci/39908431098/`：run/API/完整文字日志/artifact清单和下载回执；diagnostic内有构建xcresult、原driver日志、环境与prepared，合计10文件/1265079字节。artifact12481383819，压缩215192字节，SHA-256`75cb35737cb9f98d1769384b396b5da49a5954636556dc87e9d6a0bff4789939`与GitHub一致，CRC通过；只删除核验后的重复ZIP。

恢复目录`build/maintenance/I6-viewport-s-read-native-20261023/`保留before/frozen、唯一dispatch-attempt锁/dispatch、native-analysis、compile-failure-analysis、timing-analysis、result、文档检查与最终私有快照；[持久验证记录](ValidationLogs/project-isolation-i6-viewport-s-read-native.json)。619项运行输入、1247项先前证据、Build30与普通HEAD/index保持。

本地收证助手有一次PowerShell嵌套引号和一次Python默认GBK解码错误，均发生于收证辅助脚本，不改变运行源码或CI；修正辅助脚本后只读收证完成，没有重新派发。

## 最小后续（尚未实施）

下一片先本地修复这一个继承合同：拟只让FixedSpread的override与新增父类签名一致，默认nil观察者原样透传给super，同时更新必需Vendor摘要。保留href/脚本包装及唯一原super await，不修改定位算法、guard、原字断言、预算或重试。先补对应/不对应签名的本地检查，明确它仍不是原生编译。

这会新增触及一份FixedSpread源码，已经超出上轮三Swift文件的诊断切片；不能在这次CI失败后悄悄扩充实现或自动补跑。当前只记录方案，未实施，后续原生CI仍需新授权。完整冻结输入/失败原件/旧定位疑点保留，不关机。
