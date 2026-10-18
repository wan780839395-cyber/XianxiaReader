# 当前交接与恢复点

Build28 开工：进度更新隔离与阅读菜单边缘（2026-10-18）。

用户认可Build27并要求继续。按顺序读档并核实际文件/原HEAD6d761749/空index、私有tip13dcfeb7、完整39107016454和最终receipt。49旧包、17旧ZIP和1047原路径核验，新建第18份恢复ZIP；初始记录m4-chrome-build28-start.json。所有未提交工作保留，不关机。

实际代码：ReaderViewModel.position的@Published每个完整Locator事件会通知ReaderView、ReaderMenuView和ReaderAppearanceView；菜单只有章标题/进度显示需要依赖此事件。按Apple WWDC23缩小依赖的方案，拟把完整位置保留在独立进度状态，只让进度小视图观察显示摘要；保存每个原事件及fresh完整锚点不变。不盲改Readium execute或DOM采样/SQLite写入频率，手机trace仍待测。

顶部菜单计划加无blur、无事件接收的页面色底和短渐隐，遮住卡片边缘/状态栏下透出的正文；不改变引擎viewport、安全区、排版或位置。原44pt/手势/减少动效保持，需原生图/完整录屏/原帧复核，不能以源码或静态图宣称全动效。

以上为开工时断点：当时尚未改Build28源码/编译/交付。后续按下方最新检查点和实际CI恢复；Build27在新门槛通过前仍是最后交付版本。

## Windows检查后、完整Apple构建前

App已接入独立ReaderProgressState/ReaderProgressView，原position接口保留完整Locator，只缩小显示通知；原每个事件异步SQLite保存/fresh保存不变。重复阅读手势不再反复发布同一个隐藏状态。菜单header加不接收触摸的页面色底与24pt渐隐，不动引擎viewport。版本28。2项集成与1项真UI新增，原用例主体待冻结核对；新增文件由现有App/Tests路径自动纳入工程。

Windows实际448个Swift语法新增诊断0、54既有Vendor语法限制，17工具测试通过；日志.cache/recovery/20261018-build28/windows.log与tooling.log。语法不是编译，尚无Build28 IPA。下一步冻结当前源并独立全量Core各137/iOS161（135集成+26UI）/Release28，真实结果与原生素材待收取复核，不继承Build27成功。设计/官方来源及取舍READING_CHROME_DESIGN.md。

## 完整CI已实际启动

2026-10-18T08:52:22.719767+00:00：run39113019568 / codex/m4-reader-chrome / source8acc3f2f7980b3d291155936184f36ddc42d4c84。私有index核本片38原test主体未改、3新增、546编译/资源blob；原HEAD/index/M2M3保持。Windows448/17通过但不等于Swift编译，完整独立Core137各/iOS161(135+26)/Release28正在执行；Build27仍最后交付。只有完整通过且原生素材复核后打包。日志与状态build/ci/39113019568，恢复时先查实际任务和完整结果，不重复派发。

## 构建期间实现复核

冻结源8acc3f2对Build27编译源实际git树比较：Packages/Vendor/scripts/.github/根锁均无差异；normal index仍空。新进度摘要只在小视图发布，相同显示仍更新完整位置，原数据库保存代码不变；新增测试计数不是body执行次数/FPS，测量边界已补PERFORMANCE_TEST_PLAN。用户Build27认可另存m4-experience-build27-device-feedback.json，仅总体反馈，不推定全部真机矩阵通过。当前完整39113019568的Linux检查完成，Applejob执行中；不根据旧日志尾部推定挂起。

Linux已实际下载完整Core artifact12131506124，digest/CRC通过且重复ZIP/分片移除；逐项137/137与4个Release长TXT探针全部正确，窗口<=65536且全文覆盖。仅linux门槛置true，Apple及iOS/Release仍待，不能当已交付。

## Build27 字体联动真机反馈

用户答复“能看到并成功导入”：已接受其实际测试来源/字体样例的标准打开入口与成功导入，见m4-experience-build27-device-feedback.json.standardFontOpenIn；未说明具体是哪几个来源及两种格式组合，不推定微信/QQ/Alook每项全通过，不扩大为Build28/手机FPS/所有矩阵验收。记录standardFontOpenInDeviceAccepted=true，逐来源/格式及M4门槛仍单列。当前Build28完整39113019568仍运行，未改冻结源码。

## 09:29 UTC 监看恢复

本地watch/collector进程实际均不存在（原exec session ID已失效），run.json最后09:26；重新查询GitHub39113019568仍in_progress/原source8acc3f2/Apple作业运行，Linux与repository已success。未取消/重派CI，只恢复本地有界监看与收取，复用已校验Core收据，日志改写本轮resume文件留存。


## 完整CI实际成功，下载/原生复核前

39113019568/source8acc3f2已completed/success（repository/Core/ios均success，定向job按full选择跳过）。完整GH日志已保存，新增真实ViewModel/SQLite65事件计数root0/summary2、最后完整位置与关闭后迟到过滤回归通过，0.017秒；新菜单正常/减少动效UI64.444秒过。计数证据m4-chrome-build28-progress-measurement.json，不是body次数/FPS。当前Apple完整artifact2022101891字节正在按242分片下载，IPA已校摘要/CRC，Core已先核；尚未原生复核/根Build28交付。下一步收齐后严格finish→实际查看新菜单PNG/原录屏/原始帧→打包，不把job成功单独当最终交付。

## 原生素材准备前检查点

完整artifact digest/CRC收齐、重复ZIP/分片已删除；严格finish通过：Core各137/iOS161=135+26/0失败0跳过/Release28，546源blob、49旧包保护（两新包尚未生成）、三锁六pins/六字体OFL/各平台四长TXT探针核验。即将准备ChromeReview选定PNG/原录屏总览与原始帧，尚未人工看过，不以自动成功代替视觉或真机验收。


## 原生复核完成，打包前检查点

完整原件严格核验通过；实际22 PNG/4表、4原录屏全程1fps总览15表、3原始窗口120帧/12表和浅深两原图已查看。正常显隐窗口各1次PTS回退，仅接受正常连续子段；减少动效仅1帧，不能作连续动效验收。旧隐藏菜单慢滚状态栏透字/安全区仍单列，手机FPS未验收。即将生成根Build28 IPA/TestKit，完成后再按精确计划收敛旧Build27 CI大原件，保护最新完整诊断/所有旧包/恢复ZIP。
