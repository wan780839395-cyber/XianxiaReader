# I5a 书库边界

原生有1项新编译警告（同处发出2次）：LibraryAssembly:7对本仓库Core类型/LibraryShelf协议做外部符合，未来重复声明可能冲突；本片保留单一App组装声明，不静音、不为此改Core协议归属扩片。它不是编译错误或功能失败，完整原警告保留。已查看本次书架网格、非空回收站、保存封面三张原生图，均有预期内容；不代表手机或动效验收。

2026-10-22 I5a书库本片完成：LibraryShelf真实Foundation/Core包拥有同步列表、刷新身份及提交合并，窄仓库不暴露导入/搜索/位置写入。App组装原引擎/导入器，书库不再持有AppServices/创建Readium；原await、导入/搜索流程、Reader/R1/R2/R3/R4及定位/字体保持。最终1532b863 / CI39707770264独立6/6、原17+新增延迟初始化1=18/18，包和App/测试真实编译通过。书库UI仍同App target，特定类型静态检查不等于完整类型隔离。完整163+29=192/Release/设备/手机未跑，无新IPA，最后交付Build30；导入/搜索留后续。见Documentation/LIBRARY_ISOLATION.md和ValidationLogs/project-isolation-i5-library.json。

本片只维护书库；导入和全文搜索留后续。LibraryShelf为真实Foundation/Core包，LibraryCollection拥有当前书架/回收站、刷新身份与提交后同步合并。LibraryRepository仅暴露snapshot/rename/trash/restore/cover五个异步要求，不提供导入、搜索、位置/书签写入或引擎。SQLite在App组装声明已有实现符合协议，无转发await或数据库变化。

App/Library的原互斥、错误/提示、布局/排序/元数据筛选、默认设置、导入Task/picker和所有await仍在原调用位置。仅将同步状态段提取到LibraryCollection；变化前同步willChange保持原两个列表分别通知，VM弱引用转发objectWillChange。已提交元数据保留原progression/lastReadAt，回收站列表移动顺序与原实现一致。旧snapshot成功/错误均按原身份过滤，不新增取消规则或重试。

LibraryAssembly单点构建原EPUBImportService+ReadiumPublicationLoader及ReaderView+ReadiumEngineFactory；书库仅接files、窄repository、已有importer与呈现闭包。原init(services:)兼容入口在App组装，原测试/调用者不改。引擎仍每次实际呈现创建，原presentation UUID、dismiss身份检查和关闭后refresh保持。AnyView只在既有全屏呈现边界擦除SDK视图类型。LibraryInteractionFixture原件移至App组装，不混入库模块。

CoverImportService和BookCoverEditorModel只收窄repository/显式files，原图片/取消/回滚事务不改。AppServices去除无用SDK import；三个旧App Readium例外删除。Library仍在App target，静态禁止AppServices/SQLiteBookRepository/具体reader与SDK工厂标识，防止借同target绕过组装；该特定名字检查不等同完整类型访问隔离。Foundation状态由真实SwiftPM target提供编译边界。

沿用项目已有ReaderPositions同步状态+原调用方await模式和Core async协议/SQLite actor实现模式；避免R4b具体同步actor方法值不可partial apply问题：本片只经async协议直接调用既有actor，不取同步方法值、不新增Task/await层。无依赖升级。

## 本片合同与门槛

独立6项：双列表最新刷新、元数据保留阅读摘要并拒旧快照、回收站/恢复顺序与拒旧快照、未知提交不造书、同步变更前通知、提交后fresh快照。无引擎/模拟器App宿主。

原生只选原LibraryTests5、LibraryRemovalTests4、BookCoverTests8，共17；覆盖偏好/排序/改名/完整定位原件、原库重启回收站与书签/章节、封面失败回滚/取消/照片与窗口截图。导入仅作为原书库fixture使用，不单跑DocumentImport/全文搜索/阅读生命周期/191全套。6与17精确名称、真实exit、xcresult/完整日志核验；Windows语法/工具/依赖正反例先行，再冻结一次原生。所有原生测试正文不改。修正输入已通过上述真实包/原生定向编译与验收。

审阅纠正：首候选cc5929的组装转交会提前创建默认model，丢失原StateObject thunk。按[Apple StateObject说明](https://developer.apple.com/documentation/swiftui/stateobject)将LibraryView的model参数保留为escaping autoclosure，原App默认model表达式也进入同一thunk。新增1原生合同验证构造书库值不创建model、挂载后只创建一次；此后定向为原17+1=18，完整为163+29=192（不运行）。首CI39707366902由Agent主动停止，不称源码失败，实际已完成阶段以完整日志为准；仅对修正输入重新编译。

完整191/Release/普通设备/TrollStore/手机与IPA不在本片门槛。源码保护覆盖全部Reader/Core/Adapter/Vendor/资源/锁及导入/搜索；仅允许列明书库/组装/包接线/检查/文档变化。其他失败先留证，不为凑绿扩大。


最终源1532b86300247bb8c6697323bfd6230d88a39bbb / refs/heads/codex/preserve-library-model-initialization / CI39707770264 completed/success。独立6和原17+新增StateObject挂载1原生18全部通过，无失败/跳过，test/summary/export=0。Windows476语法新增0/54既有，90工具83过7 POSIX跳过，修正影响4+8另验；最终Linux90/90。静态150第一方Swift/21区域/22图节点/2精确测试例外。

成本：两派发、首候选由Agent主动停止在包编译、无包测试完成或原生执行；修正源一次实际原生执行。包Swift构建62.12秒，包+原生步骤1519.0秒，包合同完成至首原生suite1373.218秒，18项实际合计18.019秒；准备/编译成本不称用例执行。

权威Documentation/ValidationLogs/project-isolation-i5-library.json；原件build/ci/39707770264/diagnostic，artifact12396681750/9630545字节/SHAde1ce10e2392a7b45c8d7ca63f77bee2023c6155cc182255da8fe97826427ca3，digest/CRC/完整解压已核；取消轮39707366902/full.log与artifact12395048460同样保留。只精确删重复ZIP，无历史/源码清理。
