# 连续视口smoke：单轮原生验证（2026-10-22）

2026-10-22 Adapter桥修正版仅一轮CI39782692503/65a82618/attempt1：原生编译/链接通过，Linux111及控制器机制6项通过；原视口smoke 0/1（12.506秒），停在缩放前S资格。S实际命中/放行但终结rejected，M未执行；失败后active/tasks/waiters均空。1767/2367现场不足证明具体拒绝分支，clip/documentTop/guard诊断仍缺；旧full根因未证。本轮617运行输入零漂移、未改算法/原断言预算、未重派。原件与断点已保存，旧full191/192、Release/手机缺口和Build30保持。见[本片结果](I6_VIEWPORT_ADAPTER_SMOKE.md)。

以下记录保留其当时范围；最新本轮状态以上文为准。

2026-10-22 本片已收口：唯一[CI39777683114](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39777683114) / 9f1c503a / attempt1 **失败于测试包链接，用例与机制执行0**。已保存原件并修正两文件Debug桥接候选；候选仅本地静态通过，尚未原生验证。下面原计划保留为历史范围，实际结果以本节和[权威审计](ValidationLogs/project-isolation-i6-viewport-smoke.json)为准。

## 实际结果与原因

- Linux111项工具检查全部通过。Xcode16.4/Swift6.1.2/Intel执行对象编译，但build-for-testing在XianxiaReaderTests链接失败，exit65；不能称原生编译验收通过。原生步骤819秒（13分39秒），均为准备/构建，测试0秒；还未进入模拟器用例，30秒业务断言与6项机制检查均没有执行。
- 5组undefined全部属于ReadiumNavigator的EPUBViewportFixtureEvent/Control：TaskLocal source、初始化器、metadata accessor、nominal descriptor、protocol descriptor。测试目标明确只链接Adapter产品；typealias仍表示SDK原类型，并没有建立Adapter自己的类型边界。这是上一片夹具桥的实现缺口，不能归因定位算法或本地网络。
- 完整实际link命令、undefined引用来自ReaderRenderingTests.o的原件，保存在build/maintenance/I6-viewport-smoke-20261022/undefined-symbols.txt及原日志。现有9处Swift警告和2条链接警告均保留，未压制；失败依据是5组缺符号，未另行扩修警告。

## 已做的局部修正，尚未原生验证

只改Adapter和本同例2个Swift文件：由ReadiumAdapter声明自己的Sendable事件DTO/MainActor控制协议，私有bridge转换SDK事件；Tests不再构造/遵循SDK类型或引用SDK TaskLocal，原capture来源通过Adapter内部方法标记。SDK/Vendor/项目/依赖/正常定位算法不动，不给测试目标追加SDK链接项。两个文件DEBUG=false完整投影与已测源逐字一致；默认关闭路径、原断言/预算、34个其他测试体及原waitUntil保持。

候选本地check_repository --swift-syntax通过484文件（新增0，原Vendor54），定向Python15项中14通过/1 POSIX跳过；这不是编译/运行。候选没有新CI，不能称链接已验收、smoke通过或根因复现成功。相对2d490b6a本轮共6项运行输入改变、其他611保持；相对本轮已测9f1c候选仅2项改变、其他615保持。原生确认仍停在0例。单次预算已耗尽，下一轮需用户新授权；不得直接重派。

## 原件与恢复

artifact12426406178，250175字节，SHA256 6e6fa624c7a61f77c40455e37839d85566aadbf09bb0149c1f986d3b01de5d7b。GitHub摘要及ZIP CRC通过，9文件/解压1776693字节；完整日志、build-environment和PositionBuild.xcresult在build/ci/39777683114/diagnostic。由于未进入测试，DiagnosticTests.xcresult/用例summary/屏障附件不存在，不能写为已下载或已验证。校验展开后只删除了重复ZIP。

本地冻结、单次派发锁、measured-result-before-correction、candidate-correction及final-checkpoint在build/maintenance/I6-viewport-smoke-20261022；测得失败源与当前候选分开保留，普通HEAD/index未动。旧full191/192、Release/手机未验收及最后交付Build30保持，无新IPA、不关机。

原因/取舍参考：[Swift typealias声明](https://docs.swift.org/latest/documentation/the-swift-programming-language/declarations/)说明别名不建立新类型；[Apple产品链接](https://help.apple.com/xcode/mac/current/en.lproj/devb83d64851.html)说明目标须实际链接所用package产品。本片按已有Adapter边界修类型归属，未更改工程链接图。

---

用户授权只派一轮CI，验证[最小夹具](I6_VIEWPORT_REPRODUCTION_DESIGN.md)的原生编译、六项控制器机制、真实S/M命中/放行收件及取消/关闭清理。当前准备完成、尚未派发，冻结及dispatch记录为实际运行身份依据。失败保存原件后查清，禁止自动重跑；不改定位算法、原断言或预算，不跑23项/整套/Core/组件/UI/设备Release，不产IPA。

夹具源2d490b6a的5Swift及Vendor摘要逐字保持。本轮只补4个现有CI/tooling文件：workflow选择continuous-resize-smoke，诊断脚本严格选择原方法1例，使用TEST_RUNNER_XIANXIA_VIEWPORT_FIXTURE=smoke传给测试进程，原生成功后由位置证据校验器核原始收件；对应工具测试含正例及缺标记/未命中/漏放行/晚提交/残留/错序等反例。

实际scope是原testContinuousViewportResizeKeepsOriginalWordAndLiveWebView一次，先执行6项合成事件的控制器机制检查，再执行真实reader安全顺序。合成取消覆盖真实Swift continuation/Task取消，但不能称为持有真实SDK请求时的取消复现；真实reader本轮核S/M、原断言及关闭后活动请求/任务/waiter归零。H1冲突顺序不在本片，旧full根因仍未证。

CI只保留现有repository-checks及reader-positions（Xcode16.4/Swift6.1.2/Intel）两个有效job，其余跳过。原准备/resolve、build-for-testing及一次test保留，不新增原生预检或重复测试。现有Linux Python工具检查属于固定CI守卫，不代表原生整套/发布验收。

成功要求：精确原方法start/pass一次、xcresult1/1/0skip；mechanics passed=6恰好一次；单实例有界事件序列，真实S缓存未命中held/released/committed、M组held/released/guard/committed且顺序一致；safe M0原guard全true；stage4、failure none、cleanup活动/任务/waiter全空、明确closing/abort记录。缺一项就失败，普通单例绿不能冒充smoke通过。

当前本地定向工具15项中14通过/1 POSIX跳过，仓库7类静态及484语法通过（新增0，Vendor54保持，非编译）。运行输入617中只改变4个CI/tooling文件；保护原5Swift、Vendor、依赖/项目/资源和其他613输入。普通HEAD/index保持，工作目录未重置。

运行后保存真实job/run身份、完整日志、编译xcresult和测试xcresult/原附件、artifact摘要/digest；本地目录build/ci/<run>/diagnostic，先核大小/空间再下载。证据与单次派发锁在build/maintenance/I6-viewport-smoke-20261022。旧full191/192、Release/手机未验收和最后交付Build30保持。电脑保持运行。

环境变量选择依据：[Apple变量参考](https://developer.apple.com/documentation/xcode/environment-variable-reference)、[WWDC22-110361](https://developer.apple.com/videos/play/wwdc2022/110361/)中TEST_RUNNER_传入测试进程并剥前缀的说明；不依赖仅设置shell中同名变量会自动进入iOS进程的假定。
