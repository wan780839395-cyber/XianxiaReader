# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。

## 下一步与设备范围

1. 当前Build9源码/包已完成完整自动门槛，编码设备结果尚未收到；用户Build8三项基本工作流已确认。继续时先读状态→本文件→ROADMAP→ARCHITECTURE，再实核文件/Git/任务/日志。
2. 下一阶段按既定M3：列表/网格、编辑/封面、删除一致性与重复导入策略；先形成最小可恢复文件/DB事务，不提前铺开世界观/云账号。M4主题/字体/排版之后，M5完整设备性能持续独立记录。
3. 用户目标自用可用；不熟悉/反复失败先核官方对应版本和成熟实现并记录差异，不持续盲补。Build9已记录SDK CP936差异与读取窗口元数据方案。

## 运行来源与保留

- 真正编译来源c2a037aa6765cd56319cf8a61e8ca1c34f047e22 / CI38612220954，诊断在build/ci/38612220954；根/download/workspace六pins锁逐字节一致，Vendor/Readium3.11、SDK SQLite、SourceFileCopying协调分支、schema不改。463源码Git blob hash匹配；当前文档变化不是新runtime。
- 最新IPA `build/XianxiaReader-ANSI-Build9.ipa`，7740766bytes / SHA256 `0b3f0ec86898a27c4d462658e2ed74f3a3974d93834b31c54365f639e76e9d1d`；CRC/iPhoneOS/arm64/0755/最低iOS16/系统SQLite/第三方声明通过。测试ZIP `build/XianxiaReader-ANSI-Build9-TestKit.zip`，8172387bytes / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，11原创样本与内部IPA全hash/CRC通过。
- Main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，原空暂存区保留，所有既有未提交工作不重置；候选codex/m2-txt-index通过独立index快照。文档最终快照另查branch tip，不把文档tip当编译源。original370备份 .cache/recovery/20261014-092934/interrupted-worktree.zip 与验证原件保留。
- Build4–8共10旧IPA/ZIP及长书样本ZIP保持原hash，build/XianxiaReader.ipa仍Build4；未覆盖/删除旧书库、个人小说或DB。build/.cache忽略文件不随clone。CI artifacts保留14天，过期后依锁重新真实CI。
- 首轮38608225245 Linux80中1项NUL错误偏移失败；第二轮38608713016 Linux80/4探针通过、macOS80中1项单字节euro失败；第三轮38610052379各80Core/4探针/TXT通过、旧EPUB模式切换iOS57/58，后续Release未执行。完整日志/artifacts、三个候选报告、失败原因/实际修复已保留ValidationLogs；原断言保持。此前Build4–8失败也不覆盖。
- 无遗留自身工具任务/进行中CI须在结束前实核，Windows无Xcode/本机Docker管道不可用，不启动/重置。Windows语法与工具检查不是Swift编译。完整原生窗口PNG观察/运行诊断见本轮证据，不等同完整主题排版或普通/TrollStore设备矩阵。

## 恢复文件

- Documentation/M2_TXT_ANSI_VALIDATION_REPORT.json：当前80/58/Release/源hash/锁/桌面范围/新旧包与设备门槛。
- Documentation/TXT_ANSI_COMPATIBILITY.md：编码API、CP936官方映射、自动歧义、旧位置兼容、范围cache合同。
- Documentation/ValidationLogs/m2-txt-build8-device-feedback.json：直接用户确认的三个工作流。
- Documentation/PERFORMANCE_TEST_PLAN.md：四样本真实数值与测量边界。
- HANDOFF_M2_ANSI_HISTORY_2026-10-15.md：本轮按步骤检查点/失败历史。其他HANDOFF历史保留。

## 尚未实现

全部Windows ANSI代码页、已导入书原地换编码界面；只读元数据秒开、手机耗时/p95/耗电/旋转/普通签名设备完整矩阵；M3完整书库与M4排版/主题。读者查询与知识库仍只有协议草案，不能提前实现世界观CRUD或抓取小说。

## 本轮收尾与关机安排（2026-10-15）

完整CI/包/源hash/锁/旧包/原生正文观察/运行诊断及608文件inventory已保存，收尾文档快照620fdaeea97827ccab0854552b310775300fc651已推送；运行源仍c2a037a，不把文档tip当编译源。最终实核无自身gh/python/swift/docker遗留任务，所有四轮CI均completed，最新success。运行诊断：SQLite unlink0、DocumentManager dead-host0、AppIntents metadata6/WebKit assertions38原样保留，不宣称runtime全零。

用户明确要求“我要睡觉了 你跑完了帮我关机吧”。已启动隐藏关机helper，PID 23728，从UTC 10/14/2026 18:28:09 起等待90秒后执行shutdown.exe /s /t 0，不强制关闭其他应用。真实收据在build/shutdown-build9-receipt.json，公开摘要在ValidationLogs/m2-txt-ansi-shutdown.json；只记录已安排，不宣称实际已断电，系统应用可能阻止正常关机。本段/摘要写入后再刷新inventory和独立文档快照，保留main/index和已测源码。恢复时核实际收据/branch tip与最新文件，不因已安排关机而假定命令已成功执行。
