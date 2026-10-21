# R4a 会话归属与关闭失效

2026-10-21：本片实现待验证。R4 的打开/重试/关闭异步编排提取留到 R4b；不把待编译代码记为验收完成。

`ReaderSessions` 是 Foundation-only SwiftPM 产品，App 的 XcodeGen target 实际依赖它。它拥有打开准入、当前 request/book 身份与同步发布门；不持有引擎、数据库、设置、任务或 UI。静态边界与反例禁止其引入业务、UI 和 Readium。

原 `started` 与 request ID 不能简单合并：字体重建取消或恢复失败原本只重置 started，仍保留 ID。因此 `allowReopening` 只放开下一次打开，下一次 begin 才换身份。重复打开、失败后的 retry、原 await/检查点及同步结果发布顺序保留。

App 每次 begin 后绑定当前 owner 的引擎回调。已捕获的旧 tap/gesture/scroll/error/position 闭包，关闭后或同模型重开后均不能发布；position 还必须属于当前书。回调校验与原同步应用在同一 MainActor turn 内，没有新增生产 await。原引擎内部迟到操作的 generation/取消规则保持，本片不声称替代引擎的回调来源校验。

关闭顺序保留：先使显式捕获/导航/字体请求失效，调用引擎 close 接收最后位置，然后使会话失效。每个已接收位置仍用原独立 Task 写库，包括 close 最终位置；不得因关闭取消这些写入。异步写入的迟到错误必须重新通过同一 owner 门才发布。

验证范围：6 个真实包合同；旧 App VM 单用例负对照；候选 13 个精确 iOS 生命周期用例，包括新旧回调、最终位置写入、原打开/重试/关闭/保存/导航/设置与慢滚。两阶段在同一 runner/DerivedData，冻结所有输入，只有 App VM 使用已保存旧源或候选源；保留真实65、完整日志和 xcresult。禁止接受准备失败代替合格负对照。原 28 个测试方法正文不改，仅 fake 引擎新增默认关闭的 final-position 钩子。

不跑 Readium 排版19、完整191、设备 Release/IPA。之前 R1/R2/R3、分页 bootstrap、连续偏移与截图边界保持。定向通过只支持本片，不宣称全项目隔离完成。

参考与取舍：[Swift SE-0306](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)（Swift5.5起）说明 actor await 可重入，故保留每个原挂起点之后的身份核对；[Readium3.11 Navigator](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/Navigator.swift) 的 MainActor delegate 不替代 App 会话所有权。模块结构复用本项目已实际编译的 ReaderPositions 模式，未升级工具链/Readium，未增加异步封装层。
