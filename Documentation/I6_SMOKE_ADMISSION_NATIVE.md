# 统一准入与逐条排空：唯一原生smoke结果（2026-10-23）

[CI39806769382](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39806769382) / `2a9fdfb51281407472b01f1729591d09690a5efd` / attempt1已完成，唯一一次dispatch，无重跑。**原生编译/链接通过，原smoke单例1/1（17.851秒），机制6组及真实回执校验通过。** 本片只验证受控安全顺序，旧full及旧S第三次拒绝根因未证。

## 输入、执行与证据

冻结源以5b2047cd候选为父，1266源路径、617运行输入逐项一致；冻结只更改HANDOFF。本轮未改任何运行源码、定位算法、S诊断、原断言/预算、工程或依赖。未叠加本地预检。CI默认仓库静态/语法与Linux工具111项通过；原生仅ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView精确执行一次，xcresult total1/passed1/failed0/skipped0。Core、组件、23项、UI/full、设备Release均跳过，无IPA。

Xcode16.4/Swift6.1.2、macOS15.7.9 Intel；iPhone16Pro/iOS18.5模拟器。原build-for-testing成功，test/summary/export退出码均0，CI及本地同源verify_viewport_smoke均通过。既有警告单列在审计和完整日志，未扩修。一次状态读取EOF已保存并恢复；未造成重复派发、取消或重跑。

## 79项真实事件核对

- S在旧尺寸首采样committed：clipTop0、documentTop2367、expected2367、delta0，同次snapshot与JS一致，原逐项上下文观察全true。没有第二/三次，不能据此解释旧第三次rejected。
- 序号24关闭入场；27/30分别有两条目标slot M在捕获前排队。主M `17E81E12-A4D8-4B1A-A5AE-163B1B39EED0` 于31准入、34命中原提交屏障、35显式放行；36的ownerMatches、anchorEqual、anchorCurrentAtStart、anchorCurrentNow、revisionMatches、localMatches、mayRestore全部true。
- 主M在37记录真实域终结、38记录方法work-finished；revision2/local2367变为3/2151，补偿沿原算法执行。另一条M只在42准入，46/47终结；41排队的sample只在48准入，53/54终结；55确认排空并恢复普通准入。每条生产上下文均在准入后捕获，未批量resume或回放旧测量结果。
- 原保存字charOffset499在横屏874和返回竖屏402时均通过原DOM宽度/Range可见联合条件；同一WebView、已挂窗、alpha1，原资源上限断言通过。此处证明原字可见，不宣称精确像素复位或手机动画流畅度。
- stage4/failure none；78 closing在79 abort-issued前，abort count0。active/tasks/waiters/queued/running均空；stdout与导出的fixture附件逐项一致，79事件未超原128上限，入场与提交continuation共享原32上限。

排空中的后续M不要求重新满足主M全部恢复资格，仍由原算法判断；本样本后续M的mayRestore=false、height照原规则提交，未改guard来取绿。主M完成前未准入这些后续操作。

六组机制使用真实Swift Task/CheckedContinuation及合成事件，覆盖先放行/重复放行、取消前后、入场+提交waiter取消、两M+一采样串行排空和关闭后的晚请求拒绝。**未注入“真实SDK请求仍悬挂时取消”的原生故障；邻章M排队本样本也未命中。** 实际SDK路径本次证明主M/后续请求真实退出和正常关闭无残留，不能扩大为上述未执行场景的验收。

## 成本与恢复

workflow 1381秒，原生job 1325秒；其中原生诊断步骤1275秒：到build成功643.592秒，build后至首suite 576.023秒（模拟器准备/测试启动等），单例17.851秒，首suite后扣case其余37.534秒（收尾/导出等）。这些准备/编译成本不计为用例执行时间；下载和本地留证另计。

artifact12440115959，2271604字节，SHA256 `daa595d549932c5a26f4dfd47962972844b24279b515d3661399ced0b1ef9b8c`；GitHub摘要、ZIP CRC通过，77文件/解压4690655字节。build/ci/39806769382保留run/run-api、完整full.log、收件摘要，以及diagnostic中的完整reader日志、PositionBuild.xcresult、DiagnosticTests.xcresult、summary、环境和全部原附件。仅删除校验后的重复ZIP。

权威[审计](ValidationLogs/project-isolation-i6-smoke-admission-native.json)；恢复目录build/maintenance/I6-smoke-admission-native-20261022保留before/frozen、唯一dispatch-attempt/dispatch、result、admission-analysis、s-diagnostic-analysis、fixture/resize原记录及final-checkpoint。目录日期沿用派发日，完成于次日。普通HEAD/index、617运行输入、Build30 IPA/TestKit保持，不关机。

本轮到保存结果为止，不追加CI、匹配冲突对照或full。旧full仍191/192，I6/Release/手机未验收，最后交付Build30，无新IPA。后续若继续查旧故障，应先单独审阅可控H1冲突对照的匹配性；本次串行准入通过不能证明自然并发正确或旧故障已修好。
