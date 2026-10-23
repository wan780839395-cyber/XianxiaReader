# I6 显式Double修正版唯一CI（2026-10-23）

运行 [39886254329](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39886254329)，源 `978816c9dfaed955d0bca2a2fd7be21e2fe8a741`，attempt1。**测试包原生编译/链接通过，原342行错误未再出现；随后驱动版本解析返回2，两臂均未启动。**没有重派、取消或源码修改。

## 分层结果

| 门槛 | 实际结果 |
| --- | --- |
| 仓库静态/Swift语法 | 通过，484文件语法非编译，上游54项既有限制保留 |
| Linux工具 | 127/127，36.499秒，零跳过 |
| 一次build-for-testing | 成功，原生构建退出0，完整测试包编译/链接通过 |
| 构建前来源 | 619项Git blob与冻结源完全匹配 |
| 构建后冻结 | 609项Products登记，原计划和两份仅模式不同的计划摘要/内容可核；首个before与冻结一致 |
| 实际版本检查 | 3命令各0，7项真实字段相同；解析器未识别行首driver前缀而返回2 |
| 模拟器启动、Swift机制、安全/冲突XCTest | 均未执行；两臂原始退出均null |
| 完整同构建双臂来源/实例/语义 | 未到达，matchedBuildVerified=false |
| 其他Core/模块/原生/UI/full/设备Release | 未执行；无新IPA，最后交付Build30 |

与上轮失败源b2c17c9d相比，只有同一个Swift运行输入改变，Xcode16.4/16F6、Swift6.1.2及OS字段一致。本轮完成构建，验证了显式Double候选可在该环境编译，不能据此认定配对机制或定位故障已验收。

## 已复现的版本解析缺口

构建前`build-environment.txt`记录stdout，以`Apple Swift version`开头。驱动`execute`合并stdout/stderr，实际原件为：

```text
swift-driver version: 1.120.5 Apple Swift version 6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5)
Target: x86_64-apple-macosx15.0
```

`version_fields`使用`line.startswith("Apple Swift version ")`，因此找不到该字段，记录`Missing or ambiguous tool version: Apple Swift version`。这发生在安全臂前置检查中，尚未调用test-without-building；安全目录存在不代表XCTest启动。驱动退出2属于准备解析，不能把它记成安全原测试失败或65。

已用本轮真实字节作离线对照：原解析器稳定拒绝；仅在诊断副本移除这一条已知driver前缀后，原解析器解析出的全部7项字段与prepared逐项完全相同。记录在恢复目录version-output-analysis.json，原输出/原件保持。该诊断没有改运行代码、跳过检查或启动新CI。

已查固定[Swift6.1.2官方Driver源码](https://raw.githubusercontent.com/swiftlang/swift-driver/swift-6.1.2-RELEASE/Sources/SwiftDriver/Driver/Driver.swift)：版本请求先向stderr写driver版本和空格并flush，再运行编译器版本请求；前缀没有换行，解释了合并输出形态。[xtool项目安装文档](https://github.com/xtool-org/xtool/blob/main/Documentation/xtool.docc/Installation-macOS.md)也保留同一driver1.120.5前缀示例。参考仅用于核对格式，不引入依赖/升级或照搬其他工具的版本门槛。

下一最小切片仅修版本输出解析并补真实样本正反例：识别官方已知driver前缀，仍完整比对编译器/build/Target/Xcode/OS；未知、重复/冲突、缺失与真实版本变化继续拒绝。不宽泛截取任意文本，不修改Swift夹具、算法、guard或预算。**本轮未实施该修正，也未追加CI。**

## 时间与原件

目标步骤652秒：至构建命令346.699秒、构建至成功299.707秒、成功至驱动失败6.134秒；原生用例0秒。macOS job669秒，workflow创建至完成更新725秒。工具/依赖准备、编译与原生执行分开计，不把等待写成测试耗时。

完整原件在`build/ci/39886254329/`：run/run-api/full.log、artifact清单/回执及diagnostic下完整PositionBuild.xcresult、构建日志、环境、prepared/build-manifest、三份计划、首次before、三条命令与原始版本输出、exits和result。没有两臂测试xcresult/summary，因为都未启动。

artifact12473036887，压缩579610字节，SHA-256 `ae441a50bd4b233b160adb8709830c983507d5ce1edf661e00a9de087d0c9cec`与GitHub一致；CRC通过，解压23文件/3270330字节。核验后只删除重复ZIP，完整原件保留。

恢复目录`build/maintenance/I6-viewport-pair-width-native-20261023/`保存before/frozen、单次派发锁、dispatch、native/version-output/build-source/timing分析、result与final-checkpoint；[持久记录](ValidationLogs/project-isolation-i6-viewport-pair-width-native.json)。本轮619运行输入零漂移，原smoke/隔离/定位修复/S诊断/默认值/比较/生产guard/原字断言预算保持，普通HEAD/index、旧证据和Build30包保持。阶段末仅文档静态核对和恢复快照，不重复工具或原生验证。

旧full39735403242仍191/192，历史根因及旧S第三次拒绝未证；I6/Release/手机缺口保持。下一次执行需新的明确指令，不复用本轮授权，电脑保持运行。
