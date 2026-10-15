# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

Build11可恢复移出书架切片已通过[完整CI38668921850](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38668921850) / `bd68a48dc0fa41d07d839e4ddf07128d9069fe0f`：Linux/macOS各91Core、iOS67/67、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA；四长书Release探针继续通过。Windows394Swift语法新增0（54 pristine限制）与16tooling通过，语法不是编译。473运行/验证源Git blob hash、三份真实六pins锁、Build4–10共15旧包hash一致。

长按书籍→移出书架→原生确认，右上显示与排序菜单或空书架入口进入回收站，逐本恢复。002新迁移仅记录移出状态；不删除/移动Book原件或cache，不改章节、完整位置、书签、Book元数据。启动恢复清理使用全部已提交UUID，包含回收站。单SELECT快照与刷新请求ID防旧数据覆盖；真实写入失败/取消显示错误并保留状态。回收站不自动清空、不释放原件空间，不提供永久删除；schema2升级后旧Build10会显式拒绝打开新版库，不以删除数据库恢复降级。

已验证真实001旧库升级/重开、未提交迁移回滚、实际迁移失败保留数据、移出/恢复trigger失败与重试/幂等、多连接/取消，以及App真实TXT+EPUB移出后经生产启动清理再恢复原件与关联。原生确认/有书回收站/空状态三图已实际查看；模拟器不等于手机验收。用户Build10后的“没问题 继续”记录为该切片基本自用接受，未扩写逐项硬件/编码/性能矩阵。Build11手机结果待反馈，M3还剩封面替换和重复导入处理，M4字体/排版/主题尚未开始。

安装包`build/XianxiaReader-Trash-Build11.ipa` / SHA256 `9af1348004e1e150c3e9d9a68b02b754a5915328201287eee7e00d4c6cf8b1e9`；测试包`build/XianxiaReader-Trash-Build11-TestKit.zip` / SHA256 `616810a2fe3e6f031a3e9576f8d670e2081a556129892186017a930db1530700`，含真实Build11 IPA和11原创小/大样本，CRC/内部IPA/样本bytes核验通过。正常更新保留书库，+菜单确认0.0.1 (11)。设计LIBRARY_REMOVAL_DESIGN.md；报告M3_REMOVAL_VALIDATION_REPORT.json。

## 下一步

1. 先读PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核实际Git/文件/任务/完整日志，不假定中断前最后步骤完成。
2. Build11手机结果待反馈；按正常更新测试TXT/EPUB取消移出、确认移出、重启回收站、逐本恢复后的原章中段/目录/书签；空书架也须能打开回收站。普通设备/完整排版/耗电/性能矩阵独立。
3. 继续M3封面替换、重复导入处理，先设计文件与数据库提交/恢复，不碰原书或全库清空。未知问题参考官方适用版本及成熟实现，不盲补。M4字体/排版/主题后续；XBook/知识库仍草案。

## 运行来源与包

- 真正编译来源`bd68a48dc0fa41d07d839e4ddf07128d9069fe0f` / CI38668921850；完整run/full/Core/Apple/xcresult/锁/三张新原生图/四长书探针/IPA保留于build/ci/38668921850。91Core包含6新增BookRemoval，67iOS包含4新增LibraryRemoval；原85/63及四探针继续全跑。源码compiler warning/error0，运行诊断{'sqliteVnodeUnlink': 0, 'documentManagerDeadHost': 0, 'appIntentsMetadata': 6, 'webKitProcessAssertions': 28}原样保留，不宣称runtime全零。
- 473源Git blob hash匹配，根/download/workspace六pins锁一致。schema只新增002到v2，001原件不变；Readium/Vendor/codec/Locator与文件协调API不改，BookFileStore仅补含回收站清理的API合同注释。
- IPA `build/XianxiaReader-Trash-Build11.ipa`，7878880bytes / SHA256 `9af1348004e1e150c3e9d9a68b02b754a5915328201287eee7e00d4c6cf8b1e9`；arm64/iPhoneOS/0755/最低16/SDK SQLite/声明/CRC通过。ZIP `build/XianxiaReader-Trash-Build11-TestKit.zip`，8309414bytes / SHA256 `616810a2fe3e6f031a3e9576f8d670e2081a556129892186017a930db1530700`；内部IPA及11原创样本hash/CRC通过。
- Windows394语法新增0/54 pristine限制、16tooling不是Swift编译。无本机Xcode；不启动/重置不可用Docker，不用localhost作主要预览。

## Git与恢复

原main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，原空暂存区/所有未提交工作保留。codex/m3-library用独立index快照并推送；编译源与最终文档tip须区别，文档tip实查branch，不需要为纯文档再构建。M2分支保持e6f31d8。普通git diff候选对main工作目录可能将untracked文件误显删，用私有index/Git blob核验。

Build4–10共14IPA/ZIP及长书样本ZIP共15旧包逐hash保留，build/XianxiaReader.ipa仍Build4。Original370备份.cache/recovery/20261014-092934/interrupted-worktree.zip及全部M1/M2/M3成功/失败历史保留。build/.cache不随clone，CI artifacts14天；过期按真实锁重跑，不伪造包或锁。恢复时旧关机收据仅历史，本轮没有新关机请求，未安排关机。

## 用户反馈与剩余

Build10后“没问题 继续”仅该切片基本自用接受，证据ValidationLogs/m3-library-build10-device-feedback.json；未独立核读具体安装Build/硬件/OS或逐项功能。旧连续/重开、首次导入、Build8三项、Build9基本使用按各自证据保留。Build11设备=false，普通签名设备=false，M3全部完成=false。

剩余M3封面替换/重复导入处理，M4字体/排版/主题，M5完整手机性能/耗电/设备矩阵；全部ANSI页、已导入书换编码界面、只读元数据秒开仍未实现。回收站无永久删除，不释放原件空间。

## 历史与收尾

本轮按步骤检查点已保存HANDOFF_M3_REMOVAL_HISTORY_2026-10-15.md；报告M3_REMOVAL_VALIDATION_REPORT.json及ValidationLogs/m3-library-build11-*。收尾已实核本轮及前三轮CI均completed（本轮success），下载和查询结束后无自身gh/python/swift/docker遗留进程。最终Windows394语法新增0/54 pristine限制复核通过，16tooling及真实Swift门槛见报告；下一步只刷新inventory并保存独立文档快照，核对相对bd68a48只有文档变化，原main/index仍保留。纯文档tip不是编译来源，不再触发纯文档CI。
