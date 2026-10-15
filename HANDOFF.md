# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

Build13首轮CI38688984422 / 7189669已通过repository及Linux100Core/四长书探针，Apple job正在总构建步骤；本轮复查发现重复save已提交草稿时原catch范围可能回移已提交资产，已将finalize移出DB回滚catch并加实际文件保留回归。准备停止此中间候选，保留真实取消状态/完整可取得日志；不记作源码失败，不把Apple未完成阶段写通过。随后保存修正候选并重新完整CI。所有原文件/19旧包/原HEAD与index保留。

Build13已恢复核对：原main/HEAD6d76174和空index保持，M3 tip096ed6d；无自身运行任务，GitHub最近仍为Build12成功38677706936，未启动Build13。上轮实际最后验证是Windows406 Swift语法新增0/54限制、17tooling，发生在最后小改之前，不是Swift编译。9项Core封面回归已在磁盘但未编译；本轮补8项iOS集成和1项真正XCUITest（预计Core100/iOS79），Windows407 Swift语法新增0/54 pristine限制、17tooling已重新通过；下一步保存私有index候选并派发完整CI，预期Core100/iOS79，图/视频/Release均尚未通过。

Core可选coverOverride、UUID派生路径与最新payload单字段事务（schema2不动）；StagingCovers→不可变Artwork/asset，DB失败回移草稿供重试、取消清理、启动清理临时stage。旧已提交封面原图保留，不自动回收。App ImageIO后台下采样/12MiB缓存、照片FileRepresentation与共享文件选择器、预览/默认/保存/错误/请求ID；补显式原图恢复警告、真实淡入淡出、保存完成后身份核对关闭editor与迟到旧editor保护。设计见LIBRARY_COVER_DESIGN.md。所有新源码仍待Swift编译/原生图及录屏复核/Release，不写成已验收。

### 新一轮：Build13 更换封面切片（源码与回归已写，未编译）

用户接受当前观感并继续，强调流畅、好看；按用户原话只记录当前观感接受，不扩写安装Build/硬件/FPS。已核661文件inventory和19旧包hash、原main/index与M3 tip096ed6d，无自身运行任务；当前源码与旧包全保留，原始工作目录另备份.cache/recovery/20261015-build13/initial-worktree.zip。先做封面预览/选择/保存/恢复默认完整切片，重复导入紧接后续M3，不进入M4。采用不可变自定义封面资产与独立缩略图，后台复制/下采样，最新DB payload只改override，不动原书/默认EPUB封面/位置/书签。图片选择、取消、失败/重开/回收站恢复与原70iOS/91Core/四长书/Release都须验证；任何新源码尚未当验收。参考Apple ImageIO/公开系统选图API，详细取舍写设计。下一步实现Core存储/元数据事务、App后台处理/预览与原生入口，再完整CI和看最终图/录屏。

Build12书架左滑与动效已通过[完整CI38677706936](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38677706936) / `786c154402075e4885905db554ba7179e9c6d085`：Linux/macOS各91Core，iOS70/70（原67集成+3真正XCUITest），failed/skipped0、test/export/summary/recording退出0、无签名设备Release/真实IPA、四长书Release探针。Windows397Swift语法新增0/54 pristine限制、17tooling/bash语法通过，语法不是编译。476运行/验证源Git blob hash、三份真实六pins锁及Build4–11共17旧包hash匹配。

列表采用原生List/swipeActions，左滑露出灰绿色短按钮“移出”，不全滑直接执行；点后确认、取消不移出、数据库提交后才改变显示。保留长按入口。网格移出淡出/轻缩放、相邻书籍短spring补位，恢复/排序/筛选与布局切换过渡，回收站恢复行也有过渡；系统Reduce Motion关闭自定义移动/缩放及继承动画。VoiceOver标签明确书名/作者/进度。Core/schema2/Reader/codec/Vendor/文件协调/位置和依赖锁均不改。

三项XCUITest实际滑动/点击/取消/提交/重开回收站/恢复及网格真实frame补位/原序断言通过，六张原生图及实际XCTest录屏选定连续帧已单独查看；静态终态不是动画验收，录屏也不是手机60fps/p95/耗电证明。DEBUG夹具只用隔离UUID存储/偏好及正常小样导入；Release prepare恒nil，Mach-O不含XR_LIBRARY_UI_*开关，不能开启种书入口。CI录屏/导出/摘要失败均阻止IPA，原test错误码优先保留。

用户已确认Build11“都能正常使用”，按回收站/恢复自用范围记录接受；并要求全项目尽量好看流畅，已写入AGENTS，当前阶段同步打磨手势/必要动效，不统一推M4。Build12手机体验待反馈，其他设备矩阵不扩写。M3还剩封面替换/重复导入处理；完整主题/字体/正文排版仍M4，手机性能矩阵M5。

安装包`build/XianxiaReader-Shelf-Build12.ipa` / SHA256 `3aaa0c7813aab3262686738234fc627e6687755abfcaa4499dd6cfa2355fb163`；测试ZIP`build/XianxiaReader-Shelf-Build12-TestKit.zip` / SHA256 `a71ffe0d7792857ef99da00e03949837074c93f2a2c61e083c05243b748de22c`，内部IPA/11原创小大样本/CRC核验通过。正常更新保留书库，+菜单确认0.0.1 (12)。设计LIBRARY_INTERACTION_DESIGN.md；报告M3_INTERACTION_VALIDATION_REPORT.json。

本轮较早失败的完整原件另存：Documentation/ValidationLogs/m3-library-build12-first-compilation-failure.json, Documentation/ValidationLogs/m3-library-build12-menu-ax-failure.json；最终成功不覆盖失败记录。

第三轮由Agent为修正成功case录屏保留配置主动取消，非源码失败，证据Documentation/ValidationLogs/m3-library-build12-third-cancellation.json。最终动效仅按实际XCTest case录屏审阅；基座模拟器simctl视频仅诊断，不作App动效证明。

## 下一步

1. 先读PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核实实际Git/文件/运行任务/完整日志，不假定最后步骤成功。
2. Build12手机测试：列表左滑取消/确认、重开回收站/恢复；网格移出补位/恢复/排序/网格列表切换是否自然；系统Reduce Motion开关。原书、书签、目录、完整位置仍须正常。不能用录屏或单一设备推断全部设备/60fps/性能。
3. 后续M3封面替换/重复导入处理；用户要求项目尽量好看流畅，当前阶段同步打磨原生手势/动效/间距，不全拖M4。完整主题/字体/正文排版M4，完整手机性能/耗电矩阵M5；XBook/知识库仍草案。

## 来源与包

- 真正编译源`786c154402075e4885905db554ba7179e9c6d085` / CI38677706936，完整run/full/Core/Apple/xcresult/锁/六新UI图/原生录屏/四长书探针/IPA保留build/ci/38677706936。Core各91、iOS70/70（原67+3UI），test/export/summary/recording均0，Release12。476源hash/三份六pins锁匹配，Core/schema2/两个迁移/Reader/codec/Vendor/文件协调复制未改。
- IPA `build/XianxiaReader-Shelf-Build12.ipa`，7914930bytes / SHA256 `3aaa0c7813aab3262686738234fc627e6687755abfcaa4499dd6cfa2355fb163`；arm64/iPhoneOS/0755/最低16/SDK SQLite/声明/CRC通过。ZIP `build/XianxiaReader-Shelf-Build12-TestKit.zip`，8345636bytes / SHA256 `a71ffe0d7792857ef99da00e03949837074c93f2a2c61e083c05243b748de22c`；内部IPA和11原创样本hash/CRC通过。
- Release空fixture prepare恒nil、Mach-O无XR_LIBRARY_UI_*开关；测试数据仅DEBUG隔离UUID目录/偏好，未清空真实书库。原生图/视频选定连续帧分别记录，视频审阅工具只在.cache，不加入App依赖。报告M3_INTERACTION_VALIDATION_REPORT.json、ValidationLogs/m3-library-build12-*。
- Windows397grammar新增0/54 pristine限制、17tooling/bash语法通过，不是Swift编译。无本机Xcode，不启动/重置Docker或localhost预览。源码compiler warning/error0；运行诊断{'sqliteVnodeUnlink': 0, 'documentManagerDeadHost': 0, 'appIntentsMetadata': 7, 'webKitProcessAssertions': 39}保留，不宣称runtime全零。

## Git与恢复

main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77、原空index及所有未提交工作保留；codex/m3-library通过独立index快照/推送，文档tip与真正编译源区分，最终tip实查branch。M2分支保持e6f31d8；普通diff可能把main的untracked显示成候选文件删除，须用私有index/Git blob核验。

Build4–11共16IPA/ZIP加长书样本ZIP共17旧包逐hash保留，build/XianxiaReader.ipa仍Build4。Original370备份.cache/recovery/20261014-092934/interrupted-worktree.zip和所有M1/M2/M3旧成功/失败历史保留。build/.cache不随clone，CI artifacts14天；过期按真实六pins锁重跑，不伪造。旧关机收据仅历史，本轮无新关机请求，未安排关机。

## 用户反馈与剩余

Build11后用户明确确认“都能正常使用”，移出/回收站/恢复自用接受，证据ValidationLogs/m3-library-build11-device-feedback.json；实际Build/OS/硬件未独立读出，其他设备/性能不扩写。新Build12设备=false，普通签名设备=false，M3全部完成=false。永久删除/磁盘回收未提供；封面替换/重复导入、全部ANSI页、已导入书换编码和只读元数据秒开未实现。

## 历史与收尾

按步骤检查点保存HANDOFF_M3_INTERACTION_HISTORY_2026-10-15.md。已实核本轮四个CI均completed（前两次failure、第三次Agent主动cancelled、最终success），下载/查询结束后无自身gh/python/swift/docker/bash构建任务。最终Windows397语法新增0/54 pristine限制通过，17tooling与真正Swift门槛见报告。当前只刷新inventory并保存独立文档快照；真正编译源786c154，最终文档tip实查codex/m3-library，不为纯文档触发完整CI。
