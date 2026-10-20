# 项目交接（2026-10-20，初始化位置覆盖最小修复）

## 当前断点

39370263590/d28feaa自然结束failure，未发出Agent取消。原生1执行0/1、46.530秒、测试65/summary0/export0、Swift编译诊断0；完整artifact12241737946/98953768字节SHA1ba77a568362b9cb6e20f75e14b0c4445d6d6cf73f417a5d492eba720f8fb2db及CRC、556输入全核。watcher93265/PID24684和receiver45461/PID20636已退出0，恢复先核实际CommandLine。

对照合格：目标章节已进viewport、真实原字体ready、屏障保持时char1200可见；显式放行后当前WK attached/alpha1、released/faceReady/readyObserved/settled均true，x0且原字不可见。失败在原30秒联合断言，尚未替换字体，不是宿主未启动。原始build/ci/39370263590，记录Documentation/ValidationLogs/initialization-pending-39370263590.json。

已备份before-latest-initial-location后，仅修改Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift：把既有pendingLocation赋值移到isSpreadLoaded判断前，初始化等字体结束时读取最新定位。同步UPSTREAM真实LF摘要19ab7308346ba538b431e8493d25c1bc7bb3104fc86b89828ea1ceb21f0276f4及固定版本理由。另554构建输入不变，d28修正后的fixture原样保留；没有套用缓存旧测试。

本步源码已应用，Windows预检/原生候选编译、定向6、完整180、设备Release均待执行。下一步先Windows语法/工具/Bash，再按实际Git blob与354 Vendor清单冻结私有候选，rotation-full同job顺序6项→151集成+29UI→严格无签名设备Release30。各阶段失败阻止后续，不复用旧UI，不重复派发。冻结后直到结果/原件收齐不改构建输入。

## 已验证与发布边界

39362754281/176303d幂等2/2，30字体观测errorMessage全nil，完整artifact SHA/CRC与556核；两张真实字体原图已看，限engine harness静态正文。真实偏好变化仍完整fresh采样/原3秒预算，首次模式恢复与重复提交有区别。

39358438791/e2c7990原6项5/6：viewport同字/同WK、真实字体重开、跨章、六字体连续、浅深实际旋转通过，hidden初始深字失败、full/Release自动跳过。连续模式spread=never修复保留；原生3图已看，整段录屏/手机FPS未验收。

39352276145后台UI1/1，用户Build29手机“已暂停”，限该路径；生产暂停逻辑不改。完整旧39243868846仍171/177，当前完整180从未通过、设备Release未执行，无Build30；Build29最后交付。

39365686520前轮Agent取消/0用例，原始Session停宿主launch请求，不能归因fixture或环境独有原因；不能与本轮真实断言失败混写。旧链接/锁解析0执行独立保留，project图已恢复，不重加Readium根产品或修改锁。

## 成本与保留

本轮原生job1972秒，首case05:03:25UTC、job04:36:17，case46.530秒；结束case后仍有结果整理/诊断/上传。资源原件187样本，04:47:35至05:06:37UTC、跨度1142.622秒，未采满30分钟；不能把32.9分钟全记成用例或App启动。35分钟成本取消脚本先复查发现任务已完成，未发出取消API；不得运行该旧脚本处理下一轮。

PROJECT_STATUS/ROADMAP旧R1首页已完整归档恢复历史，当前首页不再带已失效“下一步”。普通HEAD6d761749911233122bcd031fcf718d22a19f9e77、普通index空、53旧包/恢复ZIP/未提交源码保持；不用整树reset/checkout。不做R2/R3/R4/M5、无关清理或关机。

## 工具

gh .cache/tools/gh_2.102.0/bin/gh.exe；cua本地浏览器仍报Work禁用，未改权限，CLI正常。job日志API404不等于挂起，必须收原件后报告实际阶段。使用独立索引创建私有候选，不移动普通HEAD/index。运行任务/验证接收均在派发后补写本页。
