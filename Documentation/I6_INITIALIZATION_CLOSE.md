# I6c 初始化中关闭：探针生命周期修正

2026-10-22。本片完成原单例准备缺陷诊断与测试修正，生产代码未改。冻结运行源 `598aedd02ab6f6d95876ccac5f17658b8cc11905`，[CI39729365995](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39729365995)成功；原单例1/1、分页与连续两个分支均有准备/关闭/清理证据，test/summary/export退出全部0。只派一轮，没有跑23项或整套。

## 卡在准备探针的机制

原脚本把ready getter覆盖装在document.fonts最初返回的JavaScript包装对象上，既没有稳定的挂接点，也没有保留该包装对象。后续读ready的包装对象若已更换，原实例hook就不会执行，__xrCloseProbeStarted自然不会设置；继续等待也无效。

这轮没有仅凭通过来推断原因。分页原生记录直接同时出现以下事实：

| 原生观测 | 值 | 含义 |
| --- | --- | --- |
| installed / installHref | true / OEBPS/cover.xhtml | hook确实装在封面文档，排除本样本脚本没安装 |
| fontSetAliveAtCall / sameFontSetAtCall | false / false | WeakRef已取不到初始JavaScript对象，当前读取对象不同 |
| instanceCalls / ownReadyAtCall | 0 / false | 原实例hook未执行，当前包装对象也没有该实例覆盖 |
| prototypeCalls | 1 | 后备hook接住了生产的真实ready读取 |
| nativeReady / nativeFontState | true / pending | 真实字体已就绪，初始化仍被显式屏障挂起 |
| released / settledCalls | false / 0 | 关闭发生前没有放行或完成初始化 |

连续分支本次仍使用原包装对象，instanceCalls=1、prototypeCalls=0，不能说两模式本次都发生对象回收。初始包装对象被回收、实例hook随之失效的机制在当前分页样本已直接观测；前轮39721680702没有对象身份探针，不能追认其精确GC事件/时刻，更不能说底层原生FontFaceSet也被销毁。

前轮确实在准备等待处失败，关闭断言和连续分支未运行；共用错误中的Continuous不是模式证据。保留其22/23与test65，不把历史失败修改成通过，也不把两轮相加写成当前同源23/23。

## 修正及保留的行为

仅原ReaderRenderingTests这一方法改动：保留原实例hook及WeakRef诊断，在FontFaceSet.prototype提供同一ready屏障以覆盖后续包装对象，避免准备条件依赖一个临时包装对象。屏障同时等待真实native ready及显式放行，替换原2000ms固定释放；原30秒测试准备、15秒生产字体预算均不增加，没有重试。

准备仅查询挂窗、几何上位于当前视口的封面，不用隐藏邻页冒充当前文档；初始化时scroll内容可以仍为alpha0，不能要求正文已经淡入才测试初始化中的关闭。必须观测installed/nativeReady/start均成立、生产字体pending、屏障未释放且未完成。

原retired视图保留、三个delegate为空、WebView及children移除断言逐字不变。分页retired2个、连续1个，全部delegate断开、remainingWebViews/children均0。原窗口/引擎XCTest teardown及该文件其他方法保持；真实断言后有记录的best-effort门清理不能掩盖原始断言失败。无需修改App/模块/Readium关闭、加载、字体或定位行为。

CI新增initialization-close精确单例入口和严格回执：必须是一例各执行一次、summary通过、两模式各有一次prepared/closed/cleanup，门已释放、漏模式/重复记录、旧视图未断开均拒绝。Core、其他独立包、23项、完整192、Release和IPA路由均未运行。

## 检查与证据

617运行输入中只改一个原生方法、workflow及3个工具脚本，其余612及全部生产/工程/资源/依赖/锁保持。该文件其他方法、原关闭断言、原ci_reader_diagnostic主体命令及旧logic/native/acceptance函数AST保持。普通HEAD/index保留，未重置既有未提交工作。

Windows相关9工具8通过/1 POSIX跳过；CI Linux109工具全部通过。实际JS脚本3个夹具核对实例、更换包装对象、native/gate两种放行顺序，仅用于检查屏障语义，不等于WebKit验收。语法484新增0/既有Vendor54（非编译）；本轮真实Apple编译通过，8条唯一源码warning与前轮信息逐条相同，仅因方法增长导致后方行号变化，没有新增warning消息。

6个原生文本附件与完整日志/summary/回执均已逐项核对，完整DiagnosticTests/PositionBuild xcresult保留。artifact12405307611为427326字节，SHA256 `363949aa0042eb3c224a68ab118dcf0bdf043e42de9524842df9abb72d89a233` 与GitHub digest一致、ZIP CRC通过；完整展开在build/ci/39729365995，重复ZIP核验后已删。恢复资料、冻结输入、原件hash、范围审计与最终保存点见build/maintenance/I6-close-20261022；[机器记录](ValidationLogs/project-isolation-i6-close.json)保留全部6条探针记录。

成本：原生步骤901秒（15分1秒），到首个Selected suite前817.675秒（13分37.7秒，含准备/解析/编译/启动，不能全叫纯编译），实际单例17.101秒；剩余为导出等开销。没有因等待或准备失败盲重跑。

## 参考与边界

核对[Apple document-start注入时机](https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/atdocumentstart)、Readium [3.11.0 Spread](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift)及[同版本Navigator](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)装配顺序；本地原生bootstrap/关闭补丁和其顺序不改。WebKit[FontFaceSet接口](https://raw.githubusercontent.com/WebKit/WebKit/main/Source/WebCore/css/FontFaceSet.idl)、[字体fixture](https://raw.githubusercontent.com/WebKit/WebKit/main/LayoutTests/fast/text/font-face-set-document.html)及[CSS字体加载规范](https://drafts.csswg.org/css-font-loading/)用于核对真实字体Promise、显式测试完成和字体/布局就绪含义；main或规范不是iOS18.5的二进制实现证据，原因结论依赖本次真实身份/进入记录。复用本项目已通过的显式字体门方式，保持原真实关闭断言。

本单例切片收口；I6整体仍未验收。前轮23项22/23作为历史保留，本轮仅一例两分支通过；完整192、设备Release、普通/TrollStore设备、手机和动效未执行，无新App IPA。下一片回到I6最终验收范围核对，不能未经范围确认自动跑整套或开始新产品功能。电脑保持开机。
