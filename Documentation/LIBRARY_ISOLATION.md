# I5a 书库边界

本片只维护书库；导入和全文搜索留后续。LibraryShelf为真实Foundation/Core包，LibraryCollection拥有当前书架/回收站、刷新身份与提交后同步合并。LibraryRepository仅暴露snapshot/rename/trash/restore/cover五个异步要求，不提供导入、搜索、位置/书签写入或引擎。SQLite在App组装声明已有实现符合协议，无转发await或数据库变化。

App/Library的原互斥、错误/提示、布局/排序/元数据筛选、默认设置、导入Task/picker和所有await仍在原调用位置。仅将同步状态段提取到LibraryCollection；变化前同步willChange保持原两个列表分别通知，VM弱引用转发objectWillChange。已提交元数据保留原progression/lastReadAt，回收站列表移动顺序与原实现一致。旧snapshot成功/错误均按原身份过滤，不新增取消规则或重试。

LibraryAssembly单点构建原EPUBImportService+ReadiumPublicationLoader及ReaderView+ReadiumEngineFactory；书库仅接files、窄repository、已有importer与呈现闭包。原init(services:)兼容入口在App组装，原测试/调用者不改。引擎仍每次实际呈现创建，原presentation UUID、dismiss身份检查和关闭后refresh保持。AnyView只在既有全屏呈现边界擦除SDK视图类型。LibraryInteractionFixture原件移至App组装，不混入库模块。

CoverImportService和BookCoverEditorModel只收窄repository/显式files，原图片/取消/回滚事务不改。AppServices去除无用SDK import；三个旧App Readium例外删除。Library仍在App target，静态禁止AppServices/SQLiteBookRepository/具体reader与SDK工厂标识，防止借同target绕过组装；该特定名字检查不等同完整类型访问隔离。Foundation状态由真实SwiftPM target提供编译边界。

沿用项目已有ReaderPositions同步状态+原调用方await模式和Core async协议/SQLite actor实现模式；避免R4b具体同步actor方法值不可partial apply问题：本片只经async协议直接调用既有actor，不取同步方法值、不新增Task/await层。无依赖升级。

## 本片合同与门槛

独立6项：双列表最新刷新、元数据保留阅读摘要并拒旧快照、回收站/恢复顺序与拒旧快照、未知提交不造书、同步变更前通知、提交后fresh快照。无引擎/模拟器App宿主。

原生只选原LibraryTests5、LibraryRemovalTests4、BookCoverTests8，共17；覆盖偏好/排序/改名/完整定位原件、原库重启回收站与书签/章节、封面失败回滚/取消/照片与窗口截图。导入仅作为原书库fixture使用，不单跑DocumentImport/全文搜索/阅读生命周期/191全套。6与17精确名称、真实exit、xcresult/完整日志核验；Windows语法/工具/依赖正反例先行，再冻结一次原生。所有原生测试正文不改。此处尚无新Swift编译/验收结果。

完整191/Release/普通设备/TrollStore/手机与IPA不在本片门槛。源码保护覆盖全部Reader/Core/Adapter/Vendor/资源/锁及导入/搜索；仅允许列明书库/组装/包接线/检查/文档变化。其他失败先留证，不为凑绿扩大。
