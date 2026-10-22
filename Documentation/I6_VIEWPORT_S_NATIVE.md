# 新增S诊断：唯一原生smoke结果（2026-10-22）

[CI39793517830](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39793517830) / `2274ba253c1d172edbfb05d2efa6ebeba0acc5fd` / attempt1已完成，唯一一次dispatch，无重跑。**新增诊断原生编译/链接通过，控制器机制6项通过；smoke 0/1，10.318秒，失败在M的安全顺序资格。** 本次S首次采样committed，未出现第二/三次；上轮第三次rejected的具体分支仍未重现，不能写成已查明或修复。定位算法和原断言/预算没有改变。

## 输入与范围

冻结源以a446a68e已保存诊断为父，1260路径/617运行输入逐项保持，冻结提交仅HANDOFF；本轮没有新增源码、测试准备、fixture、Vendor、依赖或工程变更。复用同源候选本地484语法/14工具通过及1 POSIX跳过结果，不叠加预检。CI只有repository-checks与reader-positions有效；Core、独立组件、23项、UI/full和设备Release均跳过，无IPA。CI工具111项通过（29.87秒），与原生1例分开记录。

Xcode16.4/Swift6.1.2/Intel真实build-for-testing通过；实际模拟器/系统以原build-environment和summary为准。原方法精确start一次、failed一次；xcresult total1/failed1/passed0/skipped0。方法抛错与teardown报告同一M资格失败，不是执行两例。test=65、summary=0、export=0保持，未抑制失败。现有Swift警告单列在审计及原日志，不因测试失败扩修。

## S新增字段已验证到哪里

- 真实S `61688E44-6D64-409E-923D-BE1C2508ED39`，source=test-auxiliary，held序号3、released/run序号11、sample-dom12、sample-decision13、sample-finished14。冻结clipTop=0、clipBottom=778、viewportTop=2431、wrapperMinY=64、viewMinY=2367、localTop=2367，所有上下文观察项true。
- 同一次JS返回scrollY=2367、visibleTop=0、documentTop=2367、documentY=2363.875、DOM宽402/高778，成功/对象/有限数值/Locator存在标志均有效。snapshot的documentTop/documentY与同次JS一致，expectedDocumentTop=2367、delta=0、documentTopMatches=true；reason与outcome均committed。
- 仅attempt0，**没有第三次样本可用于判读**。这证明新字段可跨原生桥输出并正确关联本请求，不证明它们对所有拒绝分支已运行覆盖；也不能用本轮clipTop=0反填上一轮旧请求的clipTop。
- 旧CI39782692503只能保留“前两次经原不匹配分支重试，第三次终止原因不明”的旧证据结论。新增诊断是被动观察，运行时序可能不同；本次S通过不等于改动已经修复S或旧full故障。

## 本轮唯一失败：M资格为什么不成立

33项真实事件能区分：序号15/16有两个并发measure-start（revision2/local2367、原锚点A）。第一个DB5E61A8在17取得DOM旧宽402/高778，而原生已874×306；它不匹配“目标新DOM宽874”的屏障条件，未被扣住。18的恢复guard全true，19完成时revision已3/local2151。

第二个M `B7886A69-05A0-420F-9EB9-5A876CFE49A1` 在20取得目标DOM宽874，21被held。22–28另一个native采样在新local2151上运行：第一次documentTop2367不匹配后重试，第二次documentTop2151且DOM宽402提交了锚点B。29放行M，30原guard的ownerMatches=true，但anchorEqual、anchorCurrentNow、revisionMatches、localMatches、mayRestore均false。31记录measure完成，32/33关闭及abort。

因此本次夹具要求的“被扣M保持原锚点/版本/局部位置且原恢复guard全true”没有成立，失败是`safe-M-original-guard-not-qualified`。**measure-finished的committed只表示该测量走入提交分支，不等于恢复锚点成功；本例原字可见断言尚未执行。** 未持有的过渡测量、后续采样与M资格相互影响已取得事件依据，但仍不能据此认定产品定位算法错误、旧S第三次原因或旧full根因。

失败路径active/tasks/waiters全空，closing先于abort-issued、count0；夹具附件与stdout JSON一致。机制6项使用合成事件和真实Swift任务/continuation；本次真实S/M命中/放行和失败后静止清理与“持有真实SDK请求时取消”不同，后者本轮仍未执行。没有修改屏障条件、增加等待/重试或放宽断言来得到绿。

下一项最小工作应先审阅fixture如何处理“目标新DOM前已完成的未持有测量”，明确安全顺序前提及可区分的证据；先不改定位算法或重派。另一次原生实验需要新授权；本轮到保存原件和断点为止，旧S第三次原因继续列为未解决。

## 成本、原件与恢复

原生步骤1003秒：到build成功499.246秒，build后到首suite 380.018秒，case10.318秒，首suite后扣case其余113.418秒（测试收尾/导出等）。从run创建到总状态最终更新共1700秒：原生步骤前68秒，原生步骤结束至总状态更新629秒（包括artifact上传、post步骤及job/run状态收尾等待）；下载另计。不能把这些归为用例执行，也不能仅凭状态等待断言某个基础设施根因。

artifact12432398908，59823458字节，SHA256 `1b5c7a317cfafb24a3a362bc2862be31ef323808ba186ff38b1b6747e3a78304`，GitHub摘要及ZIP CRC通过，1071文件/解压62012600字节；下载前剩余49029431296字节。只删除了校验后的重复ZIP。build/ci/39793517830保留run/run-api/完整full.log/清单与收件，以及diagnostic中完整reader日志、PositionBuild.xcresult、DiagnosticTests.xcresult、summary、build环境及全部原附件。

权威[审计](ValidationLogs/project-isolation-i6-viewport-s-native.json)；恢复目录build/maintenance/I6-viewport-s-native-20261022含before/frozen、唯一dispatch-attempt/dispatch、result、s-diagnostic-analysis、m-failure-analysis、fixture/resize原记录及final-checkpoint。普通HEAD/index、617输入与Build30 IPA/TestKit哈希保持。旧full仍191/192，I6/Release/手机未验收，最后交付Build30，无新IPA，不关机。
