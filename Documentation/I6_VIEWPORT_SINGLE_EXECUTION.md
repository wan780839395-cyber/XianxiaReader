# I6 配对单次执行命令本地修正（2026-10-23）

**已删除无效的`-test-iterations 1`，本地28/28通过，零CI。**只修改CI驱动与对应工具测试；当前未执行新源原生，不把本地回放写成Xcode已验收。

## 最小改动与单次合同

`scripts/ci_viewport_pair.py`仅删除两个参数token，完整源码与基线297627ef相比无其他运行逻辑差异。既有循环每臂只调用一次`test-without-building`，不添加重复、失败重试或运行到失败参数；精确单例选择、并行关闭、安全全部合格才冲突、真实退出/原件保存和所有来源门禁保持。

旧CI39890156016真实原始xctestrun递归检查未发现重复/重试配置；当前arm_plan输出仍与当时两份计划逐项相同，仅模式不同。不升级Xcode或改变计划/定位算法/生产guard/原字断言/预算。

已复核[Apple测试重复说明](https://developer.apple.com/videos/play/wwdc2021/10296/)与[Bazel基础xctestrun驱动](https://raw.githubusercontent.com/bazelbuild/rules_apple/main/apple/testing/default_runner/ios_xctestrun_runner.template.sh)。前者说明该参数用于重复执行，后者基础调用不添加它；固定Xcode16.4对值1的明确拒绝由旧CI原stderr证明。本片不照搬其额外参数、重试或清理策略。

## 本地验证

| 检查 | 结果 |
| --- | --- |
| 定向Python工具 | `python -X utf8 -m unittest discover -s scripts -p test_viewport_pair_ci.py -v`，28/28、13.325秒、零跳过 |
| 每臂一次 | 成功路径安全/冲突各一次，精确一个原单例；命令禁止iterations/retry/until-failure/repetition-relaunch参数 |
| 真实64保留 | 本地真实Python子进程写旧CLI原错误字节并退出64；executor回执、驱动结果、exits和原件保留64 |
| 安全失败停止 | 安全64后不调用任何冲突命令，原退出为[64,null]，不授予匹配双臂/Release验收 |
| 后续失败优先级 | 原64后export23仍返回64，保留两条实际退出与原件；既有65/来源/版本/产物失败回归保持 |
| 真实样本 | 错误字节SHA和所选摘要字段与旧39890156016原件一致；不需要下载旧artifact即可运行工具测试 |
| 静态/语法 | 项目检查通过；484语法、上游54限制、新增0，语法不是Swift编译 |
| 范围/保护 | 仅2项工具输入改变，其他617项、133项旧原件、Build30和普通HEAD/index保持 |

64子进程是本地CLI失败回放，真实执行者为Python，不是Xcode；其回执保留真实Python argv/PID/64，不伪造Xcode执行。测试用结果目录和摘要只用于驱动失败合同，不代表原生用例已启动。旧原生摘要中`(Transient Testing)`的totalTestCount=1仍只是一条命令错误。

首次28项为27通过/1失败：Windows文本stderr把LF转换成CRLF，精确字节断言发现了差异。原日志`local-pair-tools-first.log`保留；夹具改成`stderr.buffer.write`写原字节，再复核同一模块28/28。断言未放宽，生产驱动未追加修改；首次结果与外层日志显示编码错误均不改写为通过。

## 结果与剩余门槛

恢复目录`build/maintenance/I6-viewport-single-execution-20261023/`保存before/原交接、两次本地日志、静态语法日志、真实样本/计划审计、限定diff、result、文档检查及最终本地私有快照。[持久验证记录](ValidationLogs/project-isolation-i6-viewport-single-execution.json)。

本轮没有CI、原生编译/执行、完整门槛或设备Release，无新IPA。旧39890156016的编译/真实版本/已到达来源检查通过只属于6254e866，安全命令64/冲突null、XCTest执行0和完整双臂未完成的历史结果保持。新命令是否被固定Xcode接受及真实配对机制仍待后续单轮原生验证，须新的用户指令。

现有smoke、隔离、定位修复、S诊断、默认值/比较/生产guard/原断言与预算全部保持。旧full39735403242仍191/192，旧缩放与S第三次拒绝根因及I6/Release/手机缺口保持，最后交付Build30。电脑保持运行。
