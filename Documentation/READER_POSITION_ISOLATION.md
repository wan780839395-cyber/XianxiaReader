# R3 阅读位置隔离

R3b捕获与持久化编排本片已实现、编译并通过定向验收。实际源`421a5786e2be65baf661bc889c166ac8f22aff41` / [CI39580846569](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39580846569)，独立16/16与原iOS13/13。分项回执[project-isolation-r3b.json](ValidationLogs/project-isolation-r3b.json)。导航/返回点下一片，R3整体及全项目隔离仍未完成。

## 责任及依赖

现有独立Packages/ReaderPositions保持Foundation→XianxiaCore、tools5.10、iOS16/macOS13。ReaderPositionState仍唯一持有完整不透明位置、保存令牌/所属会话及保存错误；ReaderProgressState仍只发布原去重进度摘要。新增ReaderPositionPersistence拥有显式捕获/等待/写库/错误/同步发布，也承接每个已接收进度事件的写库。没有新增包、target或远程依赖，原manifest、project.yml、依赖守卫及锁不改。

ReaderPositionSource只有固定布局能力、完整缓存位置和fresh捕获；nil只表示原引擎暂时不可采样。ReaderPositionStorage只有保存完整ReadingPosition。App的ReaderEnginePositionSource只把原unavailable错误转成nil，其他错误原样传播；ReaderPositionRepository只转发到原BookRepository actor，实际数据库I/O及旧时间戳拒绝仍由Core负责。模块不导入UI/Readium，不解析或重写Locator/TXT锚点。

## 保留的时序与行为

VM保留暂停慢滚→beginSave及defer→原慢滚flush→请求/取消检查→原设置flush→会话/ready/引擎检查这一整段。随后调用真正负责工作的captureAndSave；模块入口再核请求、非空会话及取消，采样、写库await后，在原guard内同步state.saved，完成后才返回VM。VM返回后只有原defer，不把状态提交移到新增await之后。此片新增异步职责入口，不能沿用R3a“所有await表达式原样”的说法。

固定布局继续使用完整缓存页，不采样；重排正文仍fresh捕获，原Date+3秒预算、32ms不可用等待及各挂起点后的身份检查保持。错误显示原中文消息、保留旧完整位置，重试成功才更新并清错。旧捕获不写库；已进入仓库的写入可能完成，Core按原时间戳处理，模块只阻止旧结果/错误覆盖新会话状态，不承诺撤销已提交写入。

引擎回调仍先同步接收完整位置，再每事件创建原来的一次Task；不合并或丢弃重复事件，不增加关闭后过滤，以保留close最后回调的写入。回调失败仍调用原暂停慢滚及可见错误处理。其潜在迟到错误属于后续会话切片，本片未宣称修复。open/close、导航/返回点、设置、慢滚及字体导入的capture→save→reopen特殊事务均未改，其他36个VM方法逐字保持。

## 定向合同与结果

- 原ReaderPositionStateTests六项完全保持；新增十项用受控continuation覆盖完整Locator及发布顺序、固定布局、不可用后重试、原3秒预算、采样/存储失败和重试清错、取消/过期入口、悬挂捕获、迟到存储结果，以及每事件完整写入与原错误。没有缩短生产预算或加入测试用生产开关。
- `bash scripts/test_reader_positions.sh <新的输出目录>`独立16/16，无App/Readium；拒绝已有目录，保留真实退出、完整日志、xUnit及真实依赖图。核验每项名字与所属类各一次，错误类/遗漏/多余/重复/失败/跳过均拒绝。
- 原8保存/生命周期+1进度+4 EPUB/TXT/双模式六字体/同宽writer，共13/13；原测试、fixture、断言和预算不动。真实模块及iOS App编译成功，无源码编译错误。Linux工具71/71；Windows462语法新增0/既有Vendor限制54，71工具65通过6 POSIX跳过；Bash通过。语法不是编译。
- 冻结579源码/测试/配置输入核对本地SHA与实际运行Git树；原状态/六合同、原35测试及全部Core/Vendor/字体/设置/资源/锁保持。138 Swift源、17区域、18图节点、5精确import例外，未扩白名单。普通HEAD/index及原有WIP保持。

原字/字体条件在两种模式六套字体通过；连续截图后的六个保存位置delta为[0, 0, 0, 0, 0, 0]。同宽分页回归原位置/原字断言通过，root写入0，真实进度值1608、injected=false，实际owner/frame源码匹配冻结JS。保留全部附件，包括多个挂载或空白WebView观察，不把它们直接当失败或静默删除。以上只支持对应样本，不能证明所有WebKit时序或手机体验。

## 成本与证据

只派发一次position-isolation，未跑完整188或设备Release。独立步骤101秒，Swift报告构建51.54秒；原生步骤1269秒，首suite前949.087秒包含工具/依赖/编译/启动，13项实际执行合计279.299秒，余量含导出及诊断。准备时间不是用例执行或纯编译时间。

完整artifact、两份xcresult、xUnit、依赖图、完整日志与附件在build/ci/39580846569，下载回执核对GitHub digest/SHA、字节数、ZIP CRC与安全展开；只清除该轮重复ZIP。冻结与最终文档检查点在build/maintenance/R3b-20261021。完整发布仍需同源门槛；本片无新IPA，最后交付Build30。

## 参考及实际取舍

参考[Swift SE-0306 actor规则](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)及[SE-0338非actor async执行规则](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0338-clarify-execution-non-actor-async.md)：actor方法在await处可重入，不能用MainActor替代身份复核。沿用当前工具链，不引入新并发模式。对照[Readium 3.11.0 navigator实际实现](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)与项目现有引擎合同：缓存currentPosition不替代正文fresh采样，App桥接不暴露Readium类型。复用本项目已验ReaderSettings/Core窄存储模式和现有ReaderPositions接线，不升级依赖或扩大改造。

## 历史及下一片

R3a源755b428a60143d8f649372e6c545cc1e03f82ecb / CI39573863939曾通过6+13，详见ValidationLogs/project-isolation-r3a.json及HANDOFF_R3_DEVELOPMENT_2026-10-21.md。首轮CI39569845077独立6过、iOS规划Core dynamic/CSQLite失败、0项执行，原件与失败回执仍保留；复用ReaderSettings包布局后接线可用，不宣称Xcode内部精确根因已证。旧[SwiftPM规则](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)、[isowords布局](https://github.com/pointfreeco/isowords/blob/main/Package.swift)及[GRDB不同消费图案例](https://forums.swift.org/t/errors-on-build-after-add-package-grdb/76189)只支持接线取舍，不移植其架构或根因。

下一独立片R3导航/返回点；字体导入特殊重开事务保留其原负责人，R4会话生命周期随后推进。完整Core137/iOS159+29=188、严格设备Release、普通设备/TrollStore、手机及动态体验均未在本片执行，不以16+13替代。原产品计划继续保留，维护期间不提前实现。
