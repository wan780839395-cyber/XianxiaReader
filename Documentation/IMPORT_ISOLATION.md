# I5b 导入事务边界

本片将原App/Import/EPUBImportService完整事务移入真实BookImports SwiftPM包（Foundation/Core，iOS16/macOS13）。ImportedPublication/EPUBMetadataReading也归入该包，ReadingInterfaces以public typealias保留原API名称；阅读引擎协议的其余正文完全不变。App同名三个alias维持原UI/测试调用，不增加包装对象、async转发或Task。原ReadiumPublicationLoader在Adapter中仍实现同一协议身份，App/LibraryAssembly仍为唯一具体组装点。

按[Swift官方类型别名说明](https://raw.githubusercontent.com/swiftlang/swift-book/main/TSPL.docc/ReferenceManual/Declarations.md)保留旧名称，不创建新的值转换/协议适配层；沿用项目ReaderSettings/LibraryShelf的Core-only独立包与实际XcodeGen接线模式。Swift tools5.10，实际构建仍以Xcode16.4/Swift6.1.2为准，不升级依赖或改锁文件。Foundation security-scoped URL API只声称当前Apple平台支持；本片独立合同在macOS运行，不声称Linux包验收。

原service仅增加public可见性；importBook/初始化/错误说明body、全部11个await、Task检查、暂存→身份→预检去重→元数据→取消检查→finalize→commit→提交竞争去重校验/清理、异常保留原错+清理错、security scope整段都做机械对照。Core的TXT流水线、BookFileStore协调复制/路径防护/去重/DB事务与恢复不改；完整位置、书签、原始文件永久保留。

本片不提取LibraryViewModel的批次UI状态/导入Task编排，不改picker/FontInbox、LibraryShelf、搜索、Readium实现、阅读/字体/定位/会话。它是导入事务的编译边界；App批次/呈现仍是App桥接，不能称整个App或所有导入编排均独立。

定向门槛：BookImports8项（无效输入、EPUB真实存储/TOC/封面/警告、TXT既有归一化、预检重复保全回收站/完整历史、元数据失败、解析后取消、真实DB拒写后清理、symlink清理失败保留两错）。metadata fake不代表Readium解析，故另选原生14项：DocumentImport7+重复书籍4+真实EPUB metadata/import/rollback3；原测试正文/预算全部不改。正常旧服务body匹配，不为纯提取再跑负对照。原生新产品接线先build-for-testing，再启动模拟器；包与原生步骤分开计成本。完整163+29=192、Core137全组、所有阅读重放、Release/手机/IPA不在本片门槛。当前尚未编译/验收。
