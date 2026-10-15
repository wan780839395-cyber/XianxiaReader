# M3 可恢复移出书架（Build11候选，待编译）

2026-10-15。用户在Build10交付后回复“没问题 继续”，仅记录书库浏览/改名切片的基本自用接受。Build11先完成回收站；封面替换、重复导入处理及M4字体/主题继续后续。

## 数据和中断边界

采用保留原件的移出状态，而非跨文件系统搬移后删除Book行。新迁移002创建removed_books(book_id外键/主键、removed_at)及日期索引，原001保持原字节，user_version升级2。0版本依次执行001和002，1版本只执行002，高于2仍拒绝打开；每次迁移在显式SQLite事务内连同版本号提交。错误或未提交连接关闭会回滚，不删除旧库或已提交Book。

移出/恢复均在既有BEGIN IMMEDIATE事务内校验UUID对应Book存在，插入/删除移出标记，不更新Book payload或删除关联行。同一操作重试幂等，移出重试不刷新原移出时间。原件、缩略图、TXT cache、章节、完整版本化位置、书签和importedAt保留。晚到位置写入仍受原updated_at回归保护，未改Reader/Locator。回收站不会自动清空，也不释放原件存储空间；不提供永久删除或擦除用户小说的功能。

`librarySnapshot()`以一次SELECT联结读出书架和回收站，避免两个await读取不同提交状态。`books()`只返回书架，但启动导入恢复必须使用`allBookIDs()`（包含回收站），不能按可见书架清理Books或Cache/TXT。UUID损坏时显式拒绝恢复清理，不把它当无主文件。AppServices生产入口可注入存储根目录进行真实重开回归，默认路径不变。

## 界面与失败反馈

长按书籍选择“移出书架”，原生确认框说明可恢复及保留原书/位置/书签，取消不写入。右上显示与排序菜单增加回收站入口；空书架也有直达入口。回收站列出书名、作者、格式与已保存进度，逐本恢复，空状态可见。只在数据库提交后修改显示状态；请求ID拒绝旧刷新覆盖新提交，写入中串行管理操作并禁止关闭回收站/打开书籍/导入。失败在书架和回收站内显示，保留原有记录并可重试。

## 依据与取舍

已阅读[SQLite事务说明](https://www.sqlite.org/lang_transaction.html)、[user_version说明](https://www.sqlite.org/pragma.html#pragma_user_version)与[外键说明](https://www.sqlite.org/foreignkeys.html)。沿用本项目已通过真实写入失败/回滚/多连接回归的SQLite事务和原生共享sheet方案。所用CREATE TABLE、外键、事务和user_version均为既有SDK SQLite能力，不增加依赖或使用新版专属语法。保留Book和原件，令一次SQLite提交成为可恢复显示状态的唯一变化，避免文件移动与数据库提交之间的新崩溃窗口。不会把本方案描述成已完成永久删除、封面编辑或内容去重。

## 验证合同

新增6 Core：真实001旧库数据升级及多次重开、未提交002连接关闭回滚/重试、实际迁移失败保留旧版本与数据、真实TXT移出/清理/恢复保留原件cache及关联数据、trigger拒绝移出/恢复与幂等重试、缺失/取消/多连接隔离。原改名schema断言从1更新为2以反映真实新迁移，业务保留断言不变。未来版本拒绝测试保留。

新增4 iOS：真实TXT+EPUB导入移出后调用生产AppServices启动恢复再恢复全部关联；取消/错误/重试；刷新重叠；原生确认/回收站有书/空回收站截图。小fixture repository与目录保持到worker退出，避免SQLite仍打开时删除目录。原85 Core/63 iOS、四个长书Release探针、锁与设备Release全部继续运行，目标91 Core/67 iOS。Windows394 Swift语法新增0、54 pristine限制、16tooling已通过，仍不是编译。源码、编译、模拟器画面与用户设备分别记录，M3完整阶段尚未完成。
