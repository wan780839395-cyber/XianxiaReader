# I6 配对 CI 接线与同构建来源校验（2026-10-23）

本片完成 `continuous-resize-pair` 的路由、同构建来源守卫及真实退出保存，**只做本地检查，零 CI 派发**。安全臂的原测试、证据提取、夹具或来源校验任一失败，都不启动冲突臂。配对夹具本身仍未 Swift 编译/原生运行，不能认定旧故障复现或修好。

## 范围与保留合同

相对 `94df7632d74547bc3e9e83c9dc0c4432cb1c79fd` 只改四项运行输入：

| 文件 | 变化 |
| --- | --- |
| `.github/workflows/ios-build.yml` | 显式新增选择，进入 reader-positions，其他原生/Core/Release 路由不同时启动；失败也上传完整配对目录 |
| `scripts/ci_reader_diagnostic.sh` | 新选择复用原环境/锁解析/单次 build-for-testing，随后 exec 配对驱动，跳过原 test 动作 |
| `scripts/ci_viewport_pair.py` | 构建前冻结、两臂 test-without-building、来源核对、证据与真实退出保存 |
| `scripts/test_viewport_pair_ci.py` | 独立临时 Git/产物/工具夹具与失败路径测试 |

基线 617 项中两项变化、615 项保持，新增两个工具文件后共 619 项。Swift/SDK、现有 smoke 和配对夹具、隔离/定位修复、S 诊断、生产 guard、原字断言与全部原预算均逐文件摘要保持。没有新增原生用例、重试、依赖、target 或设备打包入口。

删除本片专属选择/分支后，原 shell 逐字节一致，原工作流语义一致。原 full、smoke、其他定向入口的编译/测试/产物规则不变；不是借接线重跑或改写旧结果。

## 同构建执行与来源

只有一次原 `build-for-testing`。驱动要求 Products 中恰有一份原 xctestrun，保持它原样；生成同目录的两份运行计划，仅给选定 hosted `XianxiaReaderTests` 的 EnvironmentVariables 增加模式值。支持已审阅的 FormatVersion 1/2，目标不唯一、未知格式或已有 fixture override 均停止。两份计划只在该模式值上不同，原测试选择/其他配置保持。

两臂都使用 `test-without-building -xctestrun`，只选原视口方法、关闭并行且迭代一次；每臂独立进程、日志、xcresult 和附件目录。每臂先确认同一 iOS18.5 模拟器配置，已启动则成功 shutdown 后再 boot，并统一 light；第二臂不能继承第一臂的进程。记录 xcodebuild PID 与原生 fixture nonce，不把 PID 本身当作 App 进程证明；成功的重新启动与不同原生实例回执共同构成新进程证据。

来源守卫包括：

- 构建前核 Git HEAD 与 GITHUB_SHA、全部登记源码/工具/工作流/工程/锁/原创书籍的原始内容与 Git blob，拒绝未追踪运行输入；构建前快照不得被后续源码漂移替代。
- 构建后冻结 App/XCTest 及 Products 文件/内部链接清单，原 xctestrun 和两臂计划分别保存摘要；两臂执行前后都与同一冻结清单逐项核对。越界链接、缺产物或运行计划除模式外变化均拒绝。
- 保存 Xcode/Swift/OS 原始环境与 DEVELOPER_DIR、run/attempt/job 身份；每臂实际读取版本字段复核，要求实际 Xcode16.4。无关 stderr 警告仍保留在日志，不冒充版本变化。
- 固定同一 simulator ID/runtime/name/device type；两臂原 Locator/尺寸/物理起点/采样来源等继续交给既有语义比较。两个 test 调用或原生 nonce 重复都不能形成合格配对。

只有来源核对、两臂真实 SDK 回执校验及语义兼容都成立，驱动才可在**本次实际执行**的 result 中标记 `matchedBuildVerified=true`。原来的语义比较器保持原样，单独调用仍不授予同构建结论。本轮离线构造样本的 true 仅验证守卫分支，不是项目真实构建证据。

## 停止与退出规则

| 现场 | 驱动行为 |
| --- | --- |
| 构建失败 | shell 原退出，未进入任何测试臂；已有日志/准备快照由 always artifact 保存 |
| 安全臂原测试失败 | 先保存真实退出、summary、附件/xcresult，再停止；冲突原退出为 null，而非伪造 0 |
| 安全原测试 0，但提取、夹具、来源或清理不合格 | 保存该层失败退出/原因并停止，不启动冲突 |
| 冲突原测试 65，且符合原字故障候选 | 保留候选判读与真实 65，整个步骤仍返回 65，CI 不能变绿或生成 IPA |
| 原测试失败又遇提取/校验失败 | 原测试非零优先，其他失败单列；不覆盖真实测试退出 |
| 两臂均 0 且全部守卫成立 | 只支持本次配对的真实观察；Release/手机及旧 full 根因始终不授予通过 |

原生退出在提取之前落盘到每臂 `exits.json`，每条工具调用也有独立原始退出/日志。负返回值保留信号事实，驱动向 shell 使用对应 128+signal。目录已存在/已经运行时拒绝自动重试，不清理旧证据再跑。

未来实际证据在 `build/ViewportPair/`：prepared、build-manifest、三份运行计划、各臂 before/after、命令/退出、完整原生日志、summary、xcresult、ReaderSnapshots、fixture-receipt 与最终 result；编译原件仍在 `build/PositionBuild.xcresult`。同 job 复用产物，不新增跨 job 构建缓存或下载复用机制。

## 本地验证与剩余门槛

受影响工具组共 31 项，30 通过、1 原有 POSIX 用例在 Windows 跳过；包含 14 项新驱动检查及原位置/Readium 来源工具。真实 Python 子进程验证 0/65/23 原样落盘；构造的 Xcode/模拟器回执验证安全失败即止、冲突 65 保持失败、提取失败、源码/产物/计划/版本/实例混杂和已运行拒绝。执行了 Bash 语法与工作流静态校验，未运行 Xcode、Swift 机制或模拟器。

首次本地运行因临时 Git 样本写为 CRLF、blob 为 LF 被严格来源校验拒绝，改为仅测试样本固定 LF，未放宽守卫；原日志保留。随后发现输出 pipe 未关闭的 ResourceWarning，修正关闭并启用该警告为错误后重验通过。版本核对同时避免把额外 stderr 警告算成版本漂移，实际版本变化反例仍拒绝。

恢复目录 `build/maintenance/I6-viewport-pair-ci-20261023/` 保存 before、各轮原始工具日志、scope-audit、document-check、result 和 final-checkpoint；持久记录见 [ValidationLogs/project-isolation-i6-viewport-pair-ci.json](ValidationLogs/project-isolation-i6-viewport-pair-ci.json)。本轮没有 Swift 变化，不重复跑 484 文件语法或工具整套。

下一片只有另获授权后才运行一次该入口：先编译及安全臂，安全全合格才冲突臂；失败留证，不自动重跑。尚未证明 Xcode16.4 实际产物布局/运行计划与驱动兼容，也未取得项目真实同构建来源或原生配对结果。旧 smoke1/1 仍仅属于 2a9fdfb5/39806769382；旧 full39735403242 仍191/192，历史根因及旧S第三次拒绝未证，I6/Release/手机缺口和最后交付Build30保持，无新IPA，不关机。

## 参考与取舍

[Apple TN2339](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)及[WWDC19 Testing in Xcode](https://developer.apple.com/videos/play/wwdc2019/413/)说明 build-for-testing 产物可通过 xctestrun 交给 test-without-building。采用该公开方式，保留本项目 Xcode16.4/锁文件和原单例，不继续调用会触发构建的 test。

参考固定 [fastlane2.229.1 的测试命令生成器](https://github.com/fastlane/fastlane/blob/2.229.1/scan/lib/scan/test_command_generator.rb)区分构建与免构建动作；不引入 fastlane，也不套用其重试策略。公开接口不保证本项目实际文件布局已经验过，未知布局/格式按准备失败停止，由后续唯一原生执行取得证据。
