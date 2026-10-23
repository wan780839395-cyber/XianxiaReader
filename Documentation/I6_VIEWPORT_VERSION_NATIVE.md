# I6 版本前缀修正版唯一原生CI（2026-10-23）

[CI39890156016](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39890156016)，冻结`6254e86620863361e37acff83d35ce8c5ac0632c`，attempt1。**原生编译/链接、真实版本解析及已到达的来源门禁通过；安全命令因不合法的重复参数返回64，尚未执行XCTest，冲突臂未启动。**仅派一次，没有取消、重派或运行输入修改。

## 分层结果

| 门槛 | 真实结果 |
| --- | --- |
| 仓库/语法 | 484文件通过，上游54限制保持、新增0；语法不是编译 |
| Linux Python工具 | 139/139，26.946秒、零跳过 |
| 原生build-for-testing | 一次，退出0，测试包编译和链接通过 |
| 真实版本检查 | Xcode/Swift/OS三条命令各0；带driver前缀的7字段与prepared完整相等，解析修正已原生验证 |
| 源码/产物/计划 | 619项真实Git blob与冻结一致；609项产物；三份计划摘要正确、两臂仅模式不同 |
| 安全臂命令前/后 | 均与冻结源码/产物/计划/环境完整一致 |
| 安全test-without-building | 命令执行约3.362秒，原退出64；未进入XCTest，Swift配对机制亦未运行 |
| 冲突臂 | 正确阻止，原退出null |
| 驱动/完整双臂 | 退出64保持，matchedBuildVerified=false；尚未完成新鲜实例/双臂语义验收 |
| 其他模块/Core/原生/UI/full/Release | 跳过；无新IPA，最后交付Build30 |

实际版本为Xcode16.4/16F6、Swift6.1.2（swiftlang6.1.2.1.2/clang1700.0.13.5）、Target x86_64-apple-macosx15.0、macOS15.7.9/24G830。原始合并输出保留，不截断build/Target或放宽字段相等条件。

## 本轮实际阻塞

我新增的CI驱动把单次执行写成`-test-iterations 1`，Xcode16.4原始命令明确返回：

```text
xcodebuild: error: Must specify -test-iterations with more than 1 iteration.
```

`paired-safe/exits.json`和命令回执记录原始64，驱动最终也返回64，summary/export各0未覆盖原失败。安全验证器拒绝非0/65结果，冲突臂未创建；这是CLI用法错误，不是原字断言失败或定位算法故障。

Xcode生成了`(Transient Testing)`失败摘要，`testName`为`xcodebuild encountered an error (64)`、开始/结束时间相等。该摘要的totalTestCount=1只代表命令错误条目；原单例、配对事件及机制记录均未出现，**原生用例执行数为0**。driver的executed=true表示调用过xcodebuild，不能据此写成XCTest已启动。

本地假runner此前仅检查命令“含有该参数”，没有验证真实CLI对值1的限制，26工具通过未覆盖这一层。这是新增驱动的检查缺口，不能归咎于旧项目、网络或产品代码。

已查[Apple测试重复说明](https://developer.apple.com/videos/play/wwdc2021/10296/)及[Bazel rules_apple测试驱动](https://raw.githubusercontent.com/bazelbuild/rules_apple/main/apple/testing/default_runner/ios_xctestrun_runner.template.sh)：前者将test-iterations用于重复，后者基础test-without-building不添加该重复参数。确切的“1被拒绝”由本轮固定Xcode16.4原始stderr证明；参考不替代本轮证据，也不引入其其他参数/清理策略。本轮原始xctestrun未发现重复/重试配置，两份模式计划除模式外完全相同。

下一最小片应仅删除无效的两个参数token，核对原计划无重复配置，补“真实64保留/安全失败停止”和禁止重复/重试参数的本地检查；保留每臂一次、原断言/预算和所有生产guard。不改成2，不加重试，不改验收器吞掉64。**本轮未实施修正或再派CI。**

## 成本与原件

目标步骤1019秒：至构建413.123秒，构建至成功356.905秒，之后版本/模拟器/CLI拒绝及提取248.972秒。其中boot178.400秒，外观设置31.435秒，测试命令3.362秒、原生XCTest0秒。macOS job1207秒，workflow1254秒；任务收尾与原生用例耗时分开。

完整原件在`build/ci/39890156016/`，含run/API/attempt、full.log、artifact元数据与摘要回执；diagnostic有完整PositionBuild.xcresult、安全命令错误xcresult/summary、全部命令日志与真实退出、prepared/build-manifest/三份计划及安全before/after。artifact12475171979、压缩815799字节，SHA-256 `0d5999b2dd702a84849dacc1f40f965c7c724b86a1e6f345b58338c50cc3b957`与GitHub一致、CRC通过；解压48文件/4684251字节，核验后只删除重复ZIP。

恢复目录`build/maintenance/I6-viewport-version-native-20261023/`保存before/frozen、单次锁/dispatch、原始版本/来源/时间分析、result、文档静态检查和最终本地私有快照。派发前Windows原字节与Git行尾规范化差异已用真实Git属性核验，未修改运行输入、未多派CI；本地分析编码/统计错误已修正，不算源码或CI失败。[持久验证记录](ValidationLogs/project-isolation-i6-viewport-version-native.json)。

619输入和旧原件/Build30/普通HEAD/index保持，smoke/隔离/定位/S诊断/默认值/比较/guard/原字断言与预算未改。旧full39735403242仍191/192，历史缩放根因及旧S第三次拒绝、I6/Release/手机缺口保持。下一原生执行须新指令，电脑不关机。
