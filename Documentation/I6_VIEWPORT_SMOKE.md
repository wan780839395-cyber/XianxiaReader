# 连续视口smoke：单轮原生验证（2026-10-22）

用户授权只派一轮CI，验证[最小夹具](I6_VIEWPORT_REPRODUCTION_DESIGN.md)的原生编译、六项控制器机制、真实S/M命中/放行收件及取消/关闭清理。当前准备完成、尚未派发，冻结及dispatch记录为实际运行身份依据。失败保存原件后查清，禁止自动重跑；不改定位算法、原断言或预算，不跑23项/整套/Core/组件/UI/设备Release，不产IPA。

夹具源2d490b6a的5Swift及Vendor摘要逐字保持。本轮只补4个现有CI/tooling文件：workflow选择continuous-resize-smoke，诊断脚本严格选择原方法1例，使用TEST_RUNNER_XIANXIA_VIEWPORT_FIXTURE=smoke传给测试进程，原生成功后由位置证据校验器核原始收件；对应工具测试含正例及缺标记/未命中/漏放行/晚提交/残留/错序等反例。

实际scope是原testContinuousViewportResizeKeepsOriginalWordAndLiveWebView一次，先执行6项合成事件的控制器机制检查，再执行真实reader安全顺序。合成取消覆盖真实Swift continuation/Task取消，但不能称为持有真实SDK请求时的取消复现；真实reader本轮核S/M、原断言及关闭后活动请求/任务/waiter归零。H1冲突顺序不在本片，旧full根因仍未证。

CI只保留现有repository-checks及reader-positions（Xcode16.4/Swift6.1.2/Intel）两个有效job，其余跳过。原准备/resolve、build-for-testing及一次test保留，不新增原生预检或重复测试。现有Linux Python工具检查属于固定CI守卫，不代表原生整套/发布验收。

成功要求：精确原方法start/pass一次、xcresult1/1/0skip；mechanics passed=6恰好一次；单实例有界事件序列，真实S缓存未命中held/released/committed、M组held/released/guard/committed且顺序一致；safe M0原guard全true；stage4、failure none、cleanup活动/任务/waiter全空、明确closing/abort记录。缺一项就失败，普通单例绿不能冒充smoke通过。

当前本地定向工具15项中14通过/1 POSIX跳过，仓库7类静态及484语法通过（新增0，Vendor54保持，非编译）。运行输入617中只改变4个CI/tooling文件；保护原5Swift、Vendor、依赖/项目/资源和其他613输入。普通HEAD/index保持，工作目录未重置。

运行后保存真实job/run身份、完整日志、编译xcresult和测试xcresult/原附件、artifact摘要/digest；本地目录build/ci/<run>/diagnostic，先核大小/空间再下载。证据与单次派发锁在build/maintenance/I6-viewport-smoke-20261022。旧full191/192、Release/手机未验收和最后交付Build30保持。电脑保持运行。

环境变量选择依据：[Apple变量参考](https://developer.apple.com/documentation/xcode/environment-variable-reference)、[WWDC22-110361](https://developer.apple.com/videos/play/wwdc2022/110361/)中TEST_RUNNER_传入测试进程并剥前缀的说明；不依赖仅设置shell中同名变量会自动进入iOS进程的假定。
