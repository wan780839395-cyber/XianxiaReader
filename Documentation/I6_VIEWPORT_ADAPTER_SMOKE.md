# Adapter桥接修正版：唯一smoke原生验证（2026-10-22）

[CI39782692503](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39782692503) / `65a82618fb1174c84be6c10729de92e828b79e25` / attempt1已收齐。**原生编译/链接通过，六项控制器机制通过，原单例0/1；smoke未验收。** 失败停在缩放前S资格，M与原缩放后字可见断言未执行。仅本次授权一次dispatch，无CI重试。

## 本轮范围与可复用结果

冻结1256路径、617运行输入，与保存候选f675c39b逐项零漂移；冻结提交只更新HANDOFF。没有新Swift/SDK/Vendor/算法/断言/预算/工程/依赖改动。复用该相同候选本地484语法/静态与14工具通过/1 POSIX跳过结果，不重复预检。有效job只有repository-checks及reader-positions；Core、独立组件、UI、23项/full和设备Release全部跳过。CI Linux111工具通过（35.963秒），不算192项原生验收。

Xcode16.4/Swift6.1.2、macOS15.7.9 Intel、iPhone16Pro iOS18.5模拟器真实build-for-testing与测试包链接通过；上轮5组SDK符号未再阻断，本次Adapter自有DTO/协议与私有转换桥已获原生编译依据。九处既有Swift警告保持，未抑制。测试只启动/结束原方法一次，12.506秒，xcresult total1/failed1/passed0/skipped0；同一失败在方法抛错与teardown各记录一次，并非执行两例。真实test=65、summary=0、export=0保留。

## 失败已确定到哪一步

1. 六项控制器自检真实执行完毕，唯一`CONTINUOUS_FIXTURE_MECHANICS passed=6 liveSDKReceiptsRequired=true`。使用合成事件及真实Swift Task/continuation，包含释放前置、重复释放、持有期间取消、注册前取消、M组drain、关闭后晚进入；这不等于持有真实SDK请求时的取消实验。
2. 真实S `68457F71-D05E-4F7B-A5C7-BAF6243184D4` 依次进入（序号2）、held（3）、released/run（10）、sample-finished/rejected（14）。已证桥两向调用、命中和放行后真实终结，但**没有committed成功回执**。不能把release指令或终结rejected计为通过。
3. 期间另一native采样在7 committed，原capture在9 cached；它们与S终结记录的当前锚点相同。S放行后同次JS的三次记录（11/12/13）均为native localTop2367、DOM scrollY1767、宽402/高778，差值600；仅这次S outcome不合格已足以触发`safe-S-or-preexisting-measure-unqualified`。
4. 夹具stage1检查失败，尚未设置横屏window.frame；16项事件中没有measure事件。M命中/放行、M原guard与横竖两轮字可见均未得到验证，不能说旧full缩放故障已复现。
5. 失败路径明确closing（15）在abort-issued（16）之前、abort count0。附件与stdout JSON逐项一致，teardown时active/tasks/waiters全空；未见清理残留或关闭后committed。本次真实reader证明的是失败后关闭静止清理；真实SDK持有中取消仍未执行。

## 归因边界与下一项最小动作

源码核对：S在首次真实DOM读取前暂停；生产采样原有guard和3次/32ms不匹配分支均保持。`EPUBSpreadView.continuousVisibleAnchorSnapshot`返回的`documentTop=scrollY+visibleTop`，而现事件未记录S捕获的clipTop/clipBottom、返回documentTop或每个guard结果。因此，**不能只用1767与2367宣称已证明某个拒绝分支，更不能证明谁把DOM移回1767、是夹具还是其他既有任务造成**。本轮确定的是安全顺序的S前置未成立；桥接链接修正通过，旧full根因仍未证。

下一片应先无CI审阅并明确这三个缺口的最小诊断：S捕获clip及view.frame、同次JS documentTop、guard拒绝原因；对齐本条事件序列后再决定是否调整夹具准备。不得无新证据直接重复smoke、放宽committed/原断言、延长预算、强写滚动位置、清缓存或改定位算法。新原生运行需另获授权，本轮到保存断点为止。

## 成本、原件与恢复

原生步骤1286秒（21分26秒）：到build成功637.471秒；build后到首suite 423.414秒（模拟器准备/启动）；方法12.506秒；首suite后扣方法其余212.609秒（测试收尾/诊断导出等）。这些分项来自外层日志时间，不能把整段写成用例执行；artifact上传约20秒、下载/核验另计。

artifact12429490803，55,890,913字节，SHA256 `d5e5fdc06047887a4636005a59a58e83fe93e86ce97292f0042a577b2c0d43a2`，GitHub摘要及ZIP CRC通过，1035文件/解压58,055,820字节。下载前剩余116,093,808,640字节；核验后只删除该重复ZIP。完整原件在`build/ci/39782692503/`：run/run-api（attempt1）、full.log、artifact清单/收件、diagnostic中的PositionBuild.xcresult、DiagnosticTests.xcresult、失败summary、原附件及build环境。权威审计见[JSON](ValidationLogs/project-isolation-i6-viewport-adapter-smoke.json)。

恢复目录`build/maintenance/I6-viewport-smoke-adapter-20261022`含before/frozen/唯一dispatch-attempt/dispatch/result、fixture与resize原记录、failure-analysis及最终checkpoint。617输入保持，普通HEAD/index和Build30 IPA/TestKit哈希保持。旧full39735403242仍191/192，I6/Release/普通手机/TrollStore未验收，无新IPA；保留全部既有隔离与定位修复，不关机。
