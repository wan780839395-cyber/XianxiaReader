# R4b 打开、重试、关闭编排

2026-10-22：实现待编译/验证。本片只提取现有编排，R4a回调归属、R1/R2/R3、定位和字体恢复规则保持；不进入I5或新功能。

现有Foundation-only ReaderSessions新增ReaderSessionLifecycle及类型化Host合同。App的ReaderSessionHost只描述原设置/字体/仓库/引擎方法引用及同步应用，ReaderViewModel构造一次调用上下文后直接暴露其绑定open/retryOpen方法值。没有转发用的async方法、额外Task或为封装新增await；上下文在运行/被引用期间强持有原接收者，VM不持有它，保留原绑定方法生命期且避免环。

保留7个原打开await：读取外观→字体→交互→完整位置→章节→书签→引擎打开。外观/字体/交互后的取消/身份检查、3个仓库读取完成后的共同检查、引擎返回后的检查均在原位置；章节和书签结果仍分别紧接原await同步应用。本片不另改列表发布规则，不把这种纯提取称为所有旧异步边界均已重新设计。

字体读取或commit的普通失败仍报告降级后继续，CancellationError仍传播；设置/文件/引擎普通错误保持当前owner并显示失败，重试执行完整close→清打开错误→原open。取消只关闭自己的引擎并失效，不调用完整close，不触碰已重开的会话。close仍按位置捕获失效→字体/task/picker清理→导航清理→引擎最终位置→会话失效→关闭UI状态执行，全部同步，无新挂起点。

验证只加8个真实包内编排合同，保留原6个R4a合同；受控continuation覆盖每个打开挂起点、旧请求释放、取消、失败/重试、字体降级、最终位置接收和绑定方法生命期。原30个iOS生命周期测试正文全保留，原生仍只选13项；不再跑已成立的旧负对照，不跑Readium19/完整191/设备Release/IPA。

新源码自动归入现有SwiftPM/XcodeGen路径，依赖/产品/target不增加；沿用已有架构区与5个精确例外，边界守卫须实际检查新文件。既有ci_ios会执行同一独立会话入口；session-lifecycle诊断只先包合同、后原13项。完整门槛数量仍162+29=191，独立14项另计，定向成功不能替代发布验收。

参考：Swift [SE-0316](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0316-global-actors.md) 的global-actor函数类型与同actor同步调用合同（Swift5.5起）；[Swift官方Functions](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/functions/) 的方法/函数值转交。沿用本项目ReaderPositions和R4a已编译的包布局，方法值转交依据Swift官方合同；不升级依赖、工具链，不引入调度器或Task包装。

首轮14合同已过、原生13尚在运行时，审阅发现新夹具若在重开身份XCTUnwrap处抛错会先于释放旧continuation。仅测试清理调整为：超时先放行/取消并收完旧Task，正常路径先放行/收完再断言新owner非空；断言、2秒准备超时和生产预算不变，Gate支持先release后wait且无额外重试。对这项测试输入变化只补独立14合同（session-lifecycle配session_logic_only=true），不重跑原生冷准备。首次原生的全部App/库生产源码、原iOS测试、工程/锁/工具链输入与最终生产源逐blob核对后，才分项复用其结果；不把独立14称手机/原生验收。
