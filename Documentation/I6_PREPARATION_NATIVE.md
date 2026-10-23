# I6 准备期诊断解阻与唯一原生配对结果（2026-10-23）

**原生编译成功；同构建安全臂通过、冲突臂按原字可见断言失败，真实退出[0,65]。本轮准备期CancellationError未复现；旧2367→1767链路与旧full故障根因仍未证。** 不自动追加CI或改算法。

## 实施与验证范围

用户通过协调线程再次对具体动作批准“你开吧”：隐藏启动已安装Docker，只用现有Swift6.1.2镜像补唯一缺失行为检查；通过后推送当前补丁，最多一轮既有continuous-resize-pair。已完成，无其他活跃同类CI或并行源码助手。

- 现有锁定镜像swift:6.1.2-jammy@sha256:1122c18e938491180820e9b4902c489dadd5a89f7e6bd99ff9b64e7f1b18f41f；没有安装、拉镜像、重置或清理Docker数据。容器禁网、只读绑定原harness，保留退出状态；Docker未关闭，未停止别的任务。
- 原样harness SHA256 `fc58e570180ea234de5f5e945a3da1e208994dc006a7b52d210e5f836095fcea`，与当前实际helper抽取一致。Swift6.1.2/Target x86_64-unknown-linux-gnu，一次编译执行退出0：首错只写一次、原NSError重抛、真实Task取消、完成后忽略、255溢出、旧sink及一次排空通过。它只验证Foundation/Swift并发helper，mock owner不代替UIKit/WK接线。
- 复用上一轮本地28项/484语法，没有本地重跑；本轮CI自带仓库门槛162/162、484语法通过，54上游登记限制/新增0，含实际Swift helper执行。
- 619运行输入保持a6457cdb的5输入诊断修正，本轮新增运行源码变化0。算法、armed、guard、清理顺序、WK调用、原预算与双向原字/返程断言均保持。

## 唯一CI与同构建来源

[run39962812139](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39962812139)，attempt1、唯一POST，源码`410b14affcb1e6afa87b422ce14adde5deb116c3`，分支codex/continuous-viewport-preparation-diagnostics-native。只一次build-for-testing，每臂原case一次，安全全部合格后才冲突。build/link退出0，driver真实65；没有full、Release、设备或新IPA。

619路径/Git blob及其实际规范化内容SHA256与冻结输入匹配；47项Windows原文件为CRLF、CI为LF，逐项与Git blob比较已核，无内容漂移。609产物、三份xctestrun、实际七版本及两臂前后四份快照一致，validationErrors均空。驱动最终`matchedBuildVerified=true`、`semanticPairCompatible=true`，`oldFullRootCauseProven=false`。

工具链为Xcode16.4/16F6、Apple Swift6.1.2、macOS15.7.9/24G830、target x86_64-apple-macosx15.0；模拟器iOS18.5/22F77。单臂receipt自身matchedBuildVerified=false不能代替最终配对来源判断。

| 实际结果 | 安全臂 | 冲突臂 |
| --- | --- | --- |
| 原单例/真实退出 | 1/1，0，13.221秒 | 0/1，65，44.702秒 |
| 原夹具资格 | unchanged；SDK请求全部登记/终结，排空合格 | candidate-controlled-word-failure；SDK请求全部登记/终结，排空合格 |
| 准备记录 | completed=true；firstError空 | completed=true；firstError空 |
| 记录点Task取消标志 | 最新准备点/cleanup均false | 最新准备点/cleanup均false |
| 主S | 2367，DOM宽402，提交 | 2367，DOM宽874，提交；捕获时native宽402 |
| 主M | 7项原guard全true，mayRestore=true | 其余6项true，anchorEqual=false，mayRestore=false |
| 原字与返程 | 宽874/窄402均可见；返程3个SDK请求完整 | 宽874原字top=-219.125/bottom=-196.125，valid/同WebView/宽度正确但visible=false，原30秒超时；未到返程窄屏 |
| 诊断journal | 191/191，dropped0 | 200/200，dropped0 |

主M本身仍真实终结为committed，mayRestore=false指锚点恢复资格，不把它改写为请求取消。受控冲突改变anchor并伴随宽屏原字失败，支持下一次本地因果审阅；单对样本不能直接证明旧full自然时序根因。

## 准备期取消与诊断交付

两臂都已完成准备，因此本轮没有可填写的准备期首次错误，firstError空符合实现合同。不能把它解释成旧CancellationError已修复；首个抛错await、发起者及旧WK错误/超时/清理先后仍未知。两臂均无timeout-fired。记录点Task.isCancelled=false也不能回填旧run或代表整个测试全部时刻。

本轮真实预arm退休出口有效：两臂各一次viewport-clear receipt交付38条旧缓冲，再由正常sampling出口交付60条。逐条核reader/epoch、连续顺序、coverage-end时间早于交付，4组coverage起止与slot/WebView身份配对；零preArmDropped/overflow。它证明本次clear退休样本，fixture-replaced预arm与全部取消/迟到分支仍未原生命中。

安全臂正常engine.close的shutdown先于最终fixture cleanup；冲突臂failed-874记录uptime1613.9296621，随后cleanup1614.014151025、shutdown1614.017723972。此顺序支持冲突臂关闭是断言失败后的清理，不能用它解释上一轮准备期取消。五类跟踪集合都空只是本轮清理快照，不等于所有取消路径通过。

## WK观察的实际所得与缺口

- 已获得公开runtime Bundle身份：com.apple.WebKit，CFBundleShortVersionString=8621，CFBundleVersion=8621.2.5.10.10，来源runtime-public-bundle；不是从OS版本推算。精确源码匹配仍unknown，原16帧来源标签不能认定IPC发起者。
- 两臂各有一次选定JS观察，callCount=1、receiverMatches=true、terminal=returned、restored=true。**同时incomplete=true、reason=options-value、parameters=null**，实际scrollTo参数仍未验证，不能称原生writer观察整体已通过，不能为此放宽安全读取规则。
- 当前主S均实际读2367；未记录到旧2367→1767链路。安全首次body回退2367→2151关联viewport-scroll-delegate，冲突首次回退是封面index0的18.333→0，不得混充旧body故障。原参数/来源缺口继续保留。

## 耗时与原件

原生定向步骤1644秒（27分24秒）。按步骤/完整日志分界：构建前约383.112秒，编译约317.691秒，构建后约943.197秒。真实test命令分别212.151/238.977秒，包含模拟器/runner开销；两个case本身合计57.923秒。bootstatus分别196.191/65.796秒，appearance144.556/14.379秒。没有把环境/编译成本写成用例执行时间；取证下载另计。

原件build/ci/39962812139/含完整repository/native日志、run/jobs/artifact API、1046个提取文件及两份xcresult。artifact12507775826，压缩62,275,323字节、展开71,076,630字节，SHA256 `5bcd95244b56cffdd4ed9fc5686fba958d5ec29c3827905cd7fd6a2be6cc5ead` 与GitHub一致，CRC及全部提取文件哈希通过。首次下载180秒超时留39,256,064字节；仅按同artifact Range续取并核验，无CI重派。完整确认后依精确清单删除重复ZIP/断传副本101,531,387字节，原错误、prefix哈希、Range元数据与原诊断保留。初次metadata本地GBK解码失败已改为原字节保存；这不是CI源码失败。

恢复build/maintenance/I6-preparation-diagnostics-native-20261023/保留before、Docker/镜像/唯一Swift执行、freeze/push/dispatch锁、实际来源/交付/原字/耗时分析、result与最终checkpoint；[持久验证记录](ValidationLogs/project-isolation-i6-preparation-native.json)。4867旧证据、Build30 IPA/TestKit、普通HEAD/index和全部旧改动保持。最后交付仍Build30，旧full191/192、I6/Release/设备缺口保持。

本轮停止。唯一下一步建议：只用这组已保存的同构建S/M证据做本地因果审阅，判断跨尺寸提交如何改变anchor、令M抑制恢复；先明确最小方案，不追加诊断/CI或改定位算法。此轮CI额度已经用完。
