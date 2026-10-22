# I6b 位置与加载定向验收

后续（2026-10-22）：[I6c关闭单例](I6_INITIALIZATION_CLOSE.md)已取得实例hook丢失机制证据并修正测试准备，真实1/1（含两模式）通过，生产未改。下文仍保留本轮源075c2cc的22/23历史，不相加成新源23/23。

2026-10-22，冻结源 `075c2ccfbc597eba2afa57c6622f44ecba1cf6ce`，[CI39721680702](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39721680702)。只派发一次 `position-acceptance`，原生23项实际执行，22通过、1失败、0跳过；原生编译通过，test退出65，summary/export退出0。I6仍未验收，不能进入发布。

## 实现范围

只增加精确23项入口、独立workflow路由和严格结果校验及对应工具测试。原19项加审计确定的4项加载/关闭合同；按真实开始/完成事件、精确集合、summary和退出码验收。CI保留完整日志、构建/测试xcresult、原附件与环境。生产Swift、原生测试正文、定位/字体/关闭行为、依赖、工程、资源、原断言和预算全部未改。

当前617运行输入已冻结；相对前一保存点只有workflow、ci_reader_diagnostic.sh、verify_reader_positions.py及其工具测试4个运行输入变化。verify_logic函数AST不变，旧24项原始xUnit经当前校验器重新核对；未重新执行Swift独立包，也不把该历史失败workflow改成成功。

## 实际结果及失败断点

15项状态/保存/导航合同通过；7项真实引擎合同通过：EPUB分页和连续返回、六字体两模式保位、分页同宽resize、隐藏重排换字体、分页/连续原生加载、TXT字节/UTF16返回。完整23项事件见[机器记录](ValidationLogs/project-isolation-i6-position.json)。

唯一失败为 `ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews`，在原测试298行等待 `__xrCloseProbeStarted`。这是循环第一轮 `continuous=false`（分页）；错误文字中的“Continuous”来自共用waitUntil助手，不能当作实际模式。原case内的engine.close及delegate/移除断言均未运行，连续分支也没运行；随后XCTest teardown正常清理。两条XCTest issue对应这一个失败case。

原日志显示两个分页spread均已initialization.finished，可见封面complete、alpha=1，准备探针仍未出现。测试在document-start覆盖FontFaceSet.ready，使用2000ms固定延迟，只查询递归找到的第一个WebView；没有记录脚本安装标记、安装异常、getter次数或页面身份。因此只能定位为“准备条件没有成立”，尚不能证明产品关闭失效，也不能认定只是环境或哪个具体注入竞态。单纯延长2000ms不能解释一个本应持久存在的started标记为何缺失。

已核对[Apple注入时机](https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/atdocumentstart)及Readium [3.11.0 Spread初始化](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift)、[3.11.0 Navigator脚本装配](https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)。本地沿用spread构造中开始加载、构造后委托安装用户脚本的顺序，并有既存原生bootstrap/关闭补丁；这使安装时机值得诊断，但源码顺序本身不能证明本轮脚本漏装。没有改动该生产顺序。

下一实验只应运行这个case：保留生产和30秒准备/15秒字体预算，记录脚本安装/错误、每个WebView的href/身份、getter次数和原生字体状态，区分没安装、查错页面或没有进入拦截；关闭前必须证明门仍处于pending。若改故障注入，采用显式放行并保留原关闭断言和失败清理，不能用更长sleep/重试凑绿。用户已选择本轮保存证据，下一轮单查这一例。当前不改原生测试、不派第二轮；下次恢复仅诊断该case，不能默认重跑23项或整套。

## 文本与像素证据

已查看六字体两模式12张原生正文图的联系表，以及分页返回、连续重复seek更新后的窗口/WK原图。六个连续字体在原生截图后的独立观察均为saved.visible=true、delta=0、anchorCondition=true；重复seek原3px断言通过，最后字top=-9.125（目标-10），更新后的窗口/WK均有正文。

原即时UIKit图仍有空白，原件保留；不能把稍后WebKit更新后的可读图解释为手机瞬态显示/流畅度已验收。测试通过只支持其明确的准备、几何和更新后渲染合同，不追认历史返回失败根因。没有为截图观察另开生产修复。

## 成本与证据保留

原生步骤30分21秒；步骤开始至首个Selected tests约22分15.8秒（准备、解析、编译与启动合计，不能全写成纯编译）；case合计314.763秒，剩余为结果导出等步骤开销。没有跑独立包/Core、全套192、设备Release或IPA。

artifact12401799234为102227599字节，SHA256 `9a56a41979b0ee22fb7ef702ec990069288aabe6eba3ea0e102bb97ba6f84626`，与GitHub digest一致、ZIP CRC通过。完整展开、日志、summary、环境和xcresult保留在 `build/ci/39721680702`；校验后只删除重复ZIP。恢复资料与失败切片在 `build/maintenance/I6-position-20261022`，本轮observer/download均已完成。

Windows107工具100通过/7 POSIX跳过；Linux107通过；484文件语法无新增诊断、保留54个Vendor限制（语法不是编译）。本轮真实Apple编译通过；原生22/23失败；完整192、Release、普通/TrollStore设备、手机均未执行，无新App包。原有隔离、定位修复和所有未提交工作保留，普通HEAD/index未改，电脑保持开机。
