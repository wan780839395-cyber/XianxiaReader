# 当前交接与恢复点

Build28 开工：进度更新隔离与阅读菜单边缘（2026-10-18）。

用户认可Build27并要求继续。按顺序读档并核实际文件/原HEAD6d761749/空index、私有tip13dcfeb7、完整39107016454和最终receipt。49旧包、17旧ZIP和1047原路径核验，新建第18份恢复ZIP；初始记录m4-chrome-build28-start.json。所有未提交工作保留，不关机。

实际代码：ReaderViewModel.position的@Published每个完整Locator事件会通知ReaderView、ReaderMenuView和ReaderAppearanceView；菜单只有章标题/进度显示需要依赖此事件。按Apple WWDC23缩小依赖的方案，拟把完整位置保留在独立进度状态，只让进度小视图观察显示摘要；保存每个原事件及fresh完整锚点不变。不盲改Readium execute或DOM采样/SQLite写入频率，手机trace仍待测。

顶部菜单计划加无blur、无事件接收的页面色底和短渐隐，遮住卡片边缘/状态栏下透出的正文；不改变引擎viewport、安全区、排版或位置。原44pt/手势/减少动效保持，需原生图/完整录屏/原帧复核，不能以源码或静态图宣称全动效。

当前尚未改Build28源码/编译/交付。Build27仍最后已交付版本；独立新门槛，不能继承。每个可恢复步骤及测试/构建前更新此档。

## Windows检查后、完整Apple构建前

App已接入独立ReaderProgressState/ReaderProgressView，原position接口保留完整Locator，只缩小显示通知；原每个事件异步SQLite保存/fresh保存不变。重复阅读手势不再反复发布同一个隐藏状态。菜单header加不接收触摸的页面色底与24pt渐隐，不动引擎viewport。版本28。2项集成与1项真UI新增，原用例主体待冻结核对；新增文件由现有App/Tests路径自动纳入工程。

Windows实际448个Swift语法新增诊断0、54既有Vendor语法限制，17工具测试通过；日志.cache/recovery/20261018-build28/windows.log与tooling.log。语法不是编译，尚无Build28 IPA。下一步冻结当前源并独立全量Core各137/iOS161（135集成+26UI）/Release28，真实结果与原生素材待收取复核，不继承Build27成功。设计/官方来源及取舍READING_CHROME_DESIGN.md。
