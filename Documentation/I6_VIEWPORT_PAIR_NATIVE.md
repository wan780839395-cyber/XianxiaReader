# I6 配对夹具唯一一轮原生 CI（2026-10-23）

唯一运行 [39882224654](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39882224654)，源 `b2c17c9d3312e942ad2448d4d9ecf244f78062e8`，attempt1，selection=`continuous-resize-pair`。**失败于原生测试包编译，build-for-testing 原退出65；安全/冲突均未启动。**没有重派、取消、追加原生或整套，也没有源码改动。

## 实际完成的门槛

| 层次 | 实际结果 |
| --- | --- |
| 仓库/架构/锁/Vendor 等静态 | 通过 |
| Swift 语法 | 484文件通过，上游54项既有限制保留，新增0；不是编译 |
| Linux工具 | 127/127，35.606秒，零跳过 |
| 构建前来源 | prepared中619项Git blob与冻结源全部一致，Xcode16.4/16F6、Swift6.1.2、macOS15.7.9 |
| 原生build-for-testing | 仅一次，65；未取得完整测试包编译/链接 |
| 两臂、配对Swift机制、原字断言 | 全部未执行；不是0/2或原字断言失败 |
| 产物冻结、两臂同构建/实例/语义校验 | 未到达，不能授予matchedBuildVerified |
| 其他Core/组件/原生/UI/full/设备Release | 未执行，无新IPA，最后交付Build30 |

两臂真实退出分别为 `null`、`null`，原因是构建失败在两臂启动之前；不能写0、65或假定安全失败。65属于构建/步骤。安全全合格才启动冲突的门禁源码保持，但本轮没有原生执行证据证明其运行行为。

## 失败位置与最小后续候选

编译器在 `Tests/iOS/ReaderRenderingTests.swift:342` 报：`the compiler is unable to type-check this expression in reasonable time`。原始日志同处出现5条批次诊断，不是5次实验或5个独立问题。

位置在新增 `advancePairResize` 的 `.oldSample` 安全臂准备检查，将字典可选字符串转换、Double缺省无穷值、差值/abs与其他guard条件放在同一表达式。此处属于配对测试夹具，尚未进入任何SDK采样交错；现有证据只定位编译器类型检查超时，不能由此推断定位算法运行失败或旧full根因。

下一最小候选：把该处宽度读取/转换拆成显式 `Double` 局部值，保留原正负infinity缺省、`abs(sampled-native)<2`、committed/A相等门槛、失败原因与原时序。只降低编译器单个表达式的推断负担，不增加await、重试、预算或改生产guard。**本轮没有应用这项候选，也没有证明它可编译。**不增加Swift编译超时来掩盖问题，不把语法检查视为编译证明。

## 耗时拆分

| 阶段 | 时间 |
| --- | --- |
| 配对目标步骤 | 706秒（11分46秒） |
| 目标步骤开始至build-for-testing命令 | 427.926秒，包含工具准备/工程生成/锁定依赖解析 |
| build-for-testing命令至编译失败 | 278.314秒（约4分38秒） |
| 原生用例 | 0秒，0次 |
| macOS目标job含checkout/上传等 | 730秒（12分10秒） |
| workflow创建至完成更新 | 787秒（约13分7秒，含仓库检查/调度） |

没有把环境准备/构建计入测试耗时，也没有消耗于测试重跑。编译器原错误是本轮新增夹具的实现缺口；本轮127项工具和旧smoke通过不能覆盖它。

## 原件、输入与恢复

`build/ci/39882224654/` 已保存 run/run-api、完整 `full.log`、artifact清单及下载核验回执。`diagnostic/` 保留完整 `PositionBuild.xcresult`、目标步骤全日志、环境和 `ViewportPair/prepared.json`。没有两臂测试xcresult/summary，因为两个测试臂未启动。

artifact12471895707，压缩292900字节，SHA-256 `fbeeb90323651c88fdaf50dff45b2a9af14885a175b1630de290839ef11d54b0` 与GitHub摘要一致；ZIP CRC通过，解压10文件/1919545字节。解压确认后仅删除重复ZIP，原件和核验回执保留；没有清理先前在用证据。

恢复目录 `build/maintenance/I6-viewport-pair-native-20261023/` 含 before/frozen、单次派发锁、dispatch、native-analysis、timing-analysis、result与final-checkpoint。持久记录见 [ValidationLogs/project-isolation-i6-viewport-pair-native.json](ValidationLogs/project-isolation-i6-viewport-pair-native.json)。

本轮全部619运行输入零变化：现有smoke、隔离、定位修复、S诊断、生产guard、原字可见断言和预算保持。普通HEAD/index、旧12项原件与Build30包摘要保持。阶段末只同步项目状态/交接及静态文档检查，不重复工具全组或语法/原生验证。

当前唯一后续是上述夹具表达式的最小修正和本地核对；再次CI需新的明确执行指令，不能复用本轮授权。旧full39735403242仍191/192，历史根因和旧S第三次拒绝未证；I6/Release/手机未验收，最后成功原生旧smoke仍2a9fdfb5/39806769382的1/1，不代表配对已通过。电脑保持运行。
