# I5b 导入事务边界

2026-10-22 I5b导入事务本片完成：BookImports为真实Foundation/Core独立包，拥有原EPUB/TXT导入服务与元数据合同；App/ReadingInterfaces以typealias保留旧调用名称/协议身份，无async包装、原11await与服务body保持。最终c8b53e38 / CI39712813755独立macOS8/8、原生14/14，包及App/测试接线编译通过。App批次UI/Task/picker/FontInbox、书库、搜索及阅读/字体/定位/会话/Core/Adapter/Vendor/资源/锁保持；批次呈现仍在App，不能称全部导入编排或全项目已隔离。完整163+29=192/Core137全组/Release/设备/手机未跑，无新IPA，最后交付Build30。搜索后续。详见Documentation/IMPORT_ISOLATION.md及ValidationLogs/project-isolation-i5-import.json。

本片将原App/Import/EPUBImportService完整事务移入真实BookImports SwiftPM包（Foundation/Core，iOS16/macOS13）。ImportedPublication/EPUBMetadataReading也归入该包，ReadingInterfaces以public typealias保留原API名称；阅读引擎协议的其余正文完全不变。App同名三个alias维持原UI/测试调用，不增加包装对象、async转发或Task。原ReadiumPublicationLoader在Adapter中仍实现同一协议身份，App/LibraryAssembly仍为唯一具体组装点。

按[Swift官方类型别名说明](https://raw.githubusercontent.com/swiftlang/swift-book/main/TSPL.docc/ReferenceManual/Declarations.md)保留旧名称，不创建新的值转换/协议适配层；沿用项目ReaderSettings/LibraryShelf的Core-only独立包与实际XcodeGen接线模式。Swift tools5.10，实际构建仍以Xcode16.4/Swift6.1.2为准，不升级依赖或改锁文件。Foundation security-scoped URL API只声称当前Apple平台支持；本片独立合同在macOS运行，不声称Linux包验收。

原service仅增加public可见性；importBook/初始化/错误说明body、全部11个await、Task检查、暂存→身份→预检去重→元数据→取消检查→finalize→commit→提交竞争去重校验/清理、异常保留原错+清理错、security scope整段都做机械对照。Core的TXT流水线、BookFileStore协调复制/路径防护/去重/DB事务与恢复不改；完整位置、书签、原始文件永久保留。

本片不提取LibraryViewModel的批次UI状态/导入Task编排，不改picker/FontInbox、LibraryShelf、搜索、Readium实现、阅读/字体/定位/会话。它是导入事务的编译边界；App批次/呈现仍是App桥接，不能称整个App或所有导入编排均独立。

定向门槛：BookImports8项（无效输入、EPUB真实存储/TOC/封面/警告、TXT既有归一化、预检重复保全回收站/完整历史、元数据失败、解析后取消、真实DB拒写后清理、symlink清理失败保留两错）。metadata fake不代表Readium解析，故另选原生14项：DocumentImport7+重复书籍4+真实EPUB metadata/import/rollback3；原测试正文/预算全部不改。正常旧服务body匹配，不为纯提取再跑负对照。原生新产品接线先build-for-testing，再启动模拟器；包与原生步骤分开计成本。完整163+29=192、Core137全组、所有阅读重放、Release/手机/IPA不在本片门槛。当前修正冻结输入已通过上述真实编译及定向门槛。


Windows480语法新增0（54既有Vendor限制，非编译）、96工具89通过7 POSIX跳过；首工具用例名生成错误原日志保留，修正后全96复核。最终Linux96/96；包合同仅macOS，不声称Linux包可编译。静态153第一方源/23区/24节点/2精确例外。原所有iOS测试正文与预算不变；原生只选DocumentImport7、BookDuplicate4、真实EPUB metadata/import/rollback3。真实test/summary/export=0，早期build-for-testing在模拟器启动前通过。新导入源码编译警告数量0；上片LibraryAssembly外部符合警告仍按原记录保留，不静音。

本轮仅1次派发、1次原生执行：独立包步骤65.0秒（Swift构建48.08秒），原生步骤775.0秒，其中首原生suite前713.681秒；14个用例实际合计18.4秒。准备/工程生成/依赖解析/编译/模拟器成本与用例执行分开；不补旧负对照或全套凑绿。

原件build/ci/39712813755/diagnostic，artifact12397619362/1673922字节/SHAb5bb4ab86d11dc20f8e2a03577d57e4b2c5ef460db51f0e96be3e7efa5ff5d32，digest/CRC/完整解压已核，仅精确清除重复ZIP。权威Documentation/ValidationLogs/project-isolation-i5-import.json；build/maintenance/I5-import-20261022含before/frozen/scope-audit/result与final-checkpoint，610运行输入冻结。普通HEAD/index与1219原路径基线保留，实际例外以检查点精确清单为准；不reset/clean旧WIP，恢复先核现场/ref/进程，不重派本片CI。电脑保持开机。
