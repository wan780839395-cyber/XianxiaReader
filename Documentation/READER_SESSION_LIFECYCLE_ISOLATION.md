# R4b 打开、重试、关闭编排

2026-10-22：本片实现、实际编译与定向验收完成。本片只提取现有编排，R4a回调归属、R1/R2/R3、定位和字体恢复规则保持；不进入I5或新功能。

现有Foundation-only ReaderSessions新增ReaderSessionLifecycle及类型化Host合同。App的ReaderSessionHost只描述原设置/字体/仓库/引擎方法引用及同步应用，ReaderViewModel构造一次调用上下文后直接暴露其绑定open/retryOpen方法值。没有转发用的async方法、额外Task或为封装新增await；上下文在运行/被引用期间强持有原接收者，VM不持有它，保留原绑定方法生命期且避免环。

保留7个原打开await：读取外观→字体→交互→完整位置→章节→书签→引擎打开。外观/字体/交互后的取消/身份检查、3个仓库读取完成后的共同检查、引擎返回后的检查均在原位置；章节和书签结果仍分别紧接原await同步应用。本片不另改列表发布规则，不把这种纯提取称为所有旧异步边界均已重新设计。

字体读取或commit的普通失败仍报告降级后继续，CancellationError仍传播；设置/文件/引擎普通错误保持当前owner并显示失败，重试执行完整close→清打开错误→原open。取消只关闭自己的引擎并失效，不调用完整close，不触碰已重开的会话。close仍按位置捕获失效→字体/task/picker清理→导航清理→引擎最终位置→会话失效→关闭UI状态执行，全部同步，无新挂起点。

最终包内15合同：原6个R4a、8个编排合同及1个同型actor/协议方法值桥接合同；受控continuation覆盖每个打开挂起点、旧请求释放、取消、失败/重试、字体降级、最终位置接收和绑定方法生命期。原30个iOS生命周期测试正文全保留，原生仍只选13项；不再跑已成立的旧负对照，不跑Readium19/完整191/设备Release/IPA。

新源码自动归入现有SwiftPM/XcodeGen路径，依赖/产品/target不增加；沿用已有架构区与5个精确例外，边界守卫须实际检查新文件。既有ci_ios会执行同一独立会话入口；session-lifecycle诊断只先包合同、后原13项。完整门槛数量仍162+29=191，独立15项另计，定向成功不能替代发布验收。

首轮原生编译失败留证：7ea52d / CI39702147807的14合同通过，但VM直接对具体SQLiteBookRepository同步actor方法取值，触发3个partial-apply编译错误，未执行原生用例；不能记成定位/环境失败。修正只经现有any BookRepository的async协议要求取3个方法值，不改actor实现、无新await/Task；新增1个同型sync actor实现async协议的方法值合同，最终独立门槛成为15（原6+编排/桥接9）。Swift [SE-0306协议一致性](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md#protocol-conformances) 与partial application边界是本次取舍依据；首轮未将具体actor形状纳入快速fixture是本片接线验证缺口，现由该合同先于原生准备验证。

参考：Swift [SE-0316](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0316-global-actors.md) 的global-actor函数类型与同actor同步调用合同（Swift5.5起）；[Swift官方Functions](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/functions/) 的方法/函数值转交。沿用本项目ReaderPositions和R4a已编译的包布局，方法值转交依据Swift官方合同；不升级依赖、工具链，不引入调度器或Task包装。

首轮14合同已过、原生13尚在运行时，审阅发现新夹具若在重开身份XCTUnwrap处抛错会先于释放旧continuation。仅测试清理调整为：超时先放行/取消并收完旧Task，正常路径先放行/收完再断言新owner非空；断言、2秒准备超时和生产预算不变，Gate支持先release后wait且无额外重试。对这项测试输入变化只补独立14合同（session-lifecycle配session_logic_only=true），不重跑原生冷准备。首次原生的全部App/库生产源码、原iOS测试、工程/锁/工具链输入与最终生产源逐blob核对后，才分项复用其结果；不把独立14称手机/原生验收。

## 最终证据与门槛

最终源c00083492fcfccd56fae978178f72e56a5542e35，[CI39703522408](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39703522408) completed/success；独立15/15、原native13/13、App/测试build-for-testing通过，test/summary/export均0。原生用例文件不改、最终594运行输入冻结；7await机械映射、retry/close逐body核对及其他VM方法保持。最初因首轮编译失败，原生分项复用计划未成立；最终是在修正源重新执行15+13，不能用只跑14的清理轮代替本结果。

首轮7ea52d/39702147807是本片接线错误：14合同过但App三处partial apply失败，test未执行；先核真实actor声明并经既有async协议修正，增加同型桥接合同。单独3fa329/39702833284仅验证夹具14项及只逻辑模式，原生明确skipped。三个源/日志/摘要/退出与artifact均独立保存，不改写首失败或称三轮原生通过。

最终包步骤92.0秒（Swift构建68.55秒）；原生步骤1054.0秒，首suite前992.658秒，13项实际合计0.652秒，其余是准备/构建/启动/采集。首失败与夹具轮成本另列于[权威回执](ValidationLogs/project-isolation-r4b.json)。本片总体3派发、2原生构建尝试、实际原生执行1次；没有扩大用例或改断言/预算、没有新依赖/target。

R4a/R4b是各自定向验收，不代表全项目隔离、R3整组、完整191/设备Release/普通设备/TrollStore/手机验收；无新IPA。I5边界后续逐片处理，所有产品计划保留。
