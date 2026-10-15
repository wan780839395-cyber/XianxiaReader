# M3 重复导入设计（Build14 候选）

当前仅源码与Windows检查，真实Core/iOS编译、原生录屏和Release尚待CI。保留Build13完整验收基线。

## 用户行为

同格式、原始文件逐字节SHA-256和64位长度相同才参与重复判断，不按书名/作者猜测。TXT再比较正规化正文SHA-256：自动与显式编码只要解码结果相同即可复用；同原件不同有效解码允许独立导入以纠正编码。不同BOM、换行、内容版本或重新打包的EPUB仍视作不同原件。

已有书架书直接保留UUID/改名/自选及默认封面/完整Locator/目录/书签/导入时间，底部中性提示“已保留已有书籍”，可查看。回收站重复项不自动恢复，显示“恢复”入口，提交后书架原生补位、进度保留。批次分别统计新增/重复，逐文件错误与取消仍可见；重复详情按书UUID合并，扫描顺序执行、列表有界高度可滚动，完成可收起。恢复失败保留入口且展示错误可重试。

## 存储与提交

新增003迁移到schema3，仅添加book_import_identities表和非唯一查找索引；不改旧payload/Locator、001/002或删除旧库。非唯一索引让旧版本已产生的重复书及各自历史全部保留；确定性优先活跃书、最早导入、UUID。指纹不是云身份，没有新增依赖或网络上传。

BookFileStore actor流式64KiB摘要受管理原件，所有路径继续逐级拒绝符号链接。旧库在导入时后台延迟补齐，已核原件不重复全库扫描正文，匹配到旧TXT时才按其保存编码恢复cache/正文身份。第一次同格式导入需要流式读取尚未登记的旧原件，书多会慢，可取消；不在启动或主线程阻塞。无法读取的未登记旧原件/无效解码仅跳过其去重并明确警告，其他书可导入，旧记录与原件均保留；DB写错仍阻止本次导入，不能吞掉。已登记的匹配项在返回重复前再次核实原件，缺失/损坏返回错误，不能伪报成功。

预检查减少EPUB重复解析；TXT须先确定有效解码再去重。最终repository.commitImport在BEGIN IMMEDIATE内重查，随后Book+Chapter+fingerprint同一事务，防多连接并发重复。并发败方只清理自己的新UUID原件/cache；提交完成后不因取消回滚原书。进程在finalize后DB前中断的孤立新目录沿用启动恢复清理，knownIDs包含回收站；DB已提交书永久保留。没有自动合并旧重复书、替换原件、永久删除/GC。

## 来源与取舍

参考[calibre 9.16数据库API](https://manual.calibre-ebook.com/db_api.html)将新增和重复作为独立结果返回的接口形式；其元数据启发式会把同名版本视为候选，本项目选择精确原件+TXT正文身份，未引入calibre代码或自动合并策略。并发边界遵循[SQLite事务官方文档](https://www.sqlite.org/lang_transaction.html)BEGIN IMMEDIATE先取写事务规则，沿用现有5秒busy timeout和失败可见，不嵌套事务。

## 验证计划

新增10 Core回归：改名副本+完整关联、回收站、同名不同内容/不同解码、多连接并发、旧重复补齐及活跃优先、旧原件缺失警告、已登记原件损坏/缺失、指纹写错整体回滚/重试、真实v2升级与中断DDL恢复、真实迁移失败保留v2。旧schema最终版本断言随新增迁移升为3，旧payload断言保留。

新增4 iOS集成覆盖真实Readium EPUB/TXT副本、混合新增/重复/坏书计数、显式恢复重开进度、取消保留提交；新增1真正XCUITest从生产+菜单重复导入样书、保留42%与自选封面、移出后再次导入/恢复/重启，并保留原生图/视频。旧UI夹具的三本原件现在各自不同，生产去重始终启用。DEBUG隔离/Release无入口合同保持。Windows语法不等价Swift编译，模拟器不等价手机流畅度或文件供应商验收。

## 当前实核检查点

第二轮CI38700674784的Linux原件已下载：110 Core（包含10新去重回归）、四个真实Release长TXT探针通过，无源码编译警告/错误。Apple正在执行，不能以Linux结果替代文件协调/iOS编译或设备Release。首轮38700353531仅新测试缺try的编译失败，未运行阶段单列，原件未覆盖。

## 原生反馈布局与AX修正

第二轮真实iOS83/84：79集成和旧4UI通过，仅新UI完成按钮查询失败。实际AX树中完成按钮被父VStack的library.duplicates覆盖，重复状态和3本/42%已存在；实际视频也显示safeAreaInset兄弟反馈叠放、单项列表空白。产品修为显式VStack统一竖排，单项按内容高度、多项再有界滚动，删除父容器测试标识保留叶控件标识；测试等待/断言不放宽。此继承结论来自实际AX树，不宣称Apple文档承诺继承规则。参考[Apple safeAreaInset](https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)-6gwby)、[VStack](https://developer.apple.com/documentation/swiftui/vstack)、[accessibilityIdentifier](https://developer.apple.com/documentation/swiftui/view/accessibilityidentifier(_:))的公开组件合同，未用私有API。
