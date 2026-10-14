# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 2026-10-15 本轮检查点：M2 窗口范围缓存（进行中）

用户刚明确回复Build8“已测试，功能正常”（提问范围为手机长TXT导入、目录跳转、重开位置），这些设备工作流记录通过；实际Build/OS/硬件未独立读取，不扩写搜索/书签/普通设备/耗时完整矩阵。随后要求扩容ANSI兼容性，优先纳入本轮M2增量。已写窗口范围cache、Loader挂接和探针字段/Build9，尚未编译/测试，不假定成功，所有改动保留并完成回归后才交付。

ANSI兼容方案先核Microsoft codepage与Apple SDK公开API：中文Windows ANSI通常CP936/GBK；增加明确GBK/ANSI、Big5/CP950、Windows1252选择，自动优先BOM/严格UTF8，再严格GBK及GB18030，模糊Big5/Western保持手选。避免将ANSI统一等同UTF8/GB18030或宽松替换。原Normalizer/Locator版本与已有codec身份保留；自动识别策略独立版本进入cache key，新格式codec单独身份，测试旧位置升级兼容。错误/取消/清理失败不可吞。完成ANSI/窗口cache全套构建后，按已确认的M2基础门槛进入M3书库，其他设备细项继续单列。

用户继续后按顺序恢复并实核：main/HEAD与空index不变，460源码hash匹配已编译1d4ee30，候选文档tip3315ba9，旧8包保留，最新CI38587015887 completed/success，无遗留任务。Build8手机长书反馈尚未收到，不记录设备通过；已询问状态，独立继续M2工作。

重开当前在全文摘要校验后还用TXTReadingPlanner全文读取构造64KiB范围。本轮只缓存该范围元数据；复用前保留TXTIndexCache对原/normalized全文摘要和目录身份的校验，再验证所有范围、最大窗口、UTF8切点与确定性边界。损坏/旧版本/缺失元数据重建；不存正文，不改parser/Locator/resource版本、不删除原件/DB，不以mtime替代内容摘要。预计新增Core cache/损坏/取消/路径回归，原生完整位置/目录/搜索/生命周期全跑，四Release同hash样本比较首次构建与后两次复用；未编译源码不写验收。先完成方案与源码，再Windows检查→独立快照/完整CI→审阅日志/数据/包→同步交接。

## 2026-10-15 构建前检查点：ANSI 与范围缓存源码就绪

已补严格流式 GBK/CP936、Big5/CP950、Windows-1252 及自动 GBK→GB18030 回退，保留已有 UTF/GB18030 codec 与 Locator v1；自动 cache key 独立 v2。App 显示选择说明和自动识别编码。范围缓存只保存资源范围、严格核对最大 scalar 切点，完整 digest 仍在。新增 5 编码 / 7 cache Core 与 2 iOS 回归，目标各80 Core /58 iOS。Windows 385 Swift 语法新增0（pristine54限制保留）、16tooling通过，尚非编译。方案与来源见 Documentation/TXT_ANSI_COMPATIBILITY.md。下一步先写inventory并保留 main/index 建独立候选快照，完整CI后审阅日志/锁/资源与旧位置结果，未通过前不交付Build9或宣称设备接受。上次文档补丁匹配失败未落盘，已逐项核实并重新分开应用；没有构建/快照成功可假定。

## 2026-10-15 首轮 CI 实际失败与修复

候选94b10c6 / CI38608225245 completed/failure：repository checks通过，Linux真实编译成功并执行80项，新增NUL精确位置断言失败（实际0/期望1）；Release探针及Apple/iOS/IPA未执行，不写成已通过。完整日志、run.json、Core artifact在build/ci/38608225245保留。原因是legacy分支只在转换后检测NUL并报告整个源块起点，拒绝文件但诊断偏移不精确；源码在转换前按这些无状态codepage的ASCII NUL原字节检查，补GBK多字节前缀、Big5跨块与1252跨块同类回归，原断言不放宽。语法检查后新快照完整CI，不同源重跑而非碰运气。首次快照命令曾路径空格笔误退出1且未执行，纠正后94b10c6成功；原main/index均保留。

## 2026-10-15 最新运行：541b7ae / CI38608713016

新快照541b7aec871b719643d50fdd0bd5a4c88d3f96b3已正常推送，main/HEAD6d76174与原空index不变。CI38608713016 repository-checks、Linux80 Core及4个Release长书样本已通过，Apple job进行中；完整Core artifact已下载至build/ci/38608713016/core。当前报告记录463源码Git blob hash和11个旧包（Build4–8 IPA/ZIP及长书样本ZIP），不把未完成Apple/iOS/Release写成通过。Build8手机三项直接回复已写ValidationLogs/m2-txt-build8-device-feedback.json，状态文档已同步范围；其他设备细项保持待测。build/.cache的包与报告工具不提交，最终包尚未生成。全套Apple完成后核对真实run/head、80Core/58iOS/锁/源hash/IPA及桌面cache边界，再单独打包Build9、更新handoff/inventory和文档快照；不得覆盖旧包。注意原main index不跟踪Vendor/TXT新增文件，普通git diff候选→工作目录会误显删文件，需独立index纳入现有文件核对。

## 2026-10-15 Apple CP936 实际断点与修正

541b7ae / CI38608713016 completed/failure：Linux80 Core/4Release探针通过，macOS真实编译/80项中新增CP936单字节0x80 euro回归失败encodingChoiceRequired，Apple探针/iOS/Release未执行；完整run/full/Core/Apple artifact保留。先核Unicode托管Microsoft CP936.TXT、WHATWG解码状态与Apple公开CF表，确认0x80单独=U20AC、0x8180=U4E90。仅Apple CP936增加按完整字符边界拆分SDK转换段及单独euro三字节映射，不能把trail80替换；所有其他字符仍SDK，原GB18030不变。扩展同测试的混合euro/trail80及五种chunk回归，原断言保留，先静态检查再新快照完整CI。引用/适用差异见TXT_ANSI_COMPATIBILITY.md。本轮没有成功IPA，旧包未动。

## 2026-10-15 最新候选已调度

b6f12286d935465e1591b95afb2286037c21091f / CI38610052379已调度完整自动流程，repository-checks已通过，后续以实际job结果为准；前两轮失败不能误当当前。当前463源码hash与11旧包报告已录，原HEAD/index不动，Build9尚未生成。Apple euro失败完整证据与官方参考另见ValidationLogs/m2-txt-ansi-apple-euro-failure.json；更新状态已定位此run。后续若遇平台/API问题先核官方或成熟对应实现，不反复盲补。

## 2026-10-15 用户离开与关机指令

用户明确要求“我要睡觉了 你跑完了帮我关机吧”。继续完成当前ANSI/范围cache完整CI及必要修复，最终保存包、全部失败/成功证据、状态/handoff/inventory并推送文档快照，核实无自身残留任务后再安排本机Windows关机。不提前关掉未收尾任务，不强制结束其他应用或删库；关机指令已获直接授权，无需再次询问。当前CI38610052379仍在Apple job，不能根据耗时推断成功。实际关机调度结果需记录，系统应用若阻止退出则保留真实限制，不能宣称机器已断电。

## 2026-10-15 iOS 模式切换实际失败

b6f1228 / CI38610052379 completed/failure：Linux/macOS各80 Core与各4Release探针全通过；所有8项TXT（含新增ANSI/旧位置/巨章窗口）通过，iOS总57/58、failed1/skipped0、test65/export0/summary0，设备Release/IPA未执行。旧EPUB testContinuousSearchJumpAndModeRoundTripKeepTheParagraph在连续→分页→连续后line18不可见，最终诊断是章首h1、offset0；测试此前仅等分页document.readyState/title，不核Readium实际恢复目标段落。参考同文件probe中已注明的spreadLoaded/native定位晚于DOM与锁定3.11 Navigator异步load状态，最小改动只增强测试：分页切回前等待line18实际横纵viewport可见，原30秒每个wait门槛/最终line18/原全部断言保持，生产引擎/Vendor不改。此为就绪竞态推断，根因未完全证明，不宣称修复产品模式切换bug。完整原件先保留，再新源码快照完整CI；如果同条件仍失败继续查对应官方/成熟实现，不无限盲补。用户睡觉后关机指令仍在最终收尾后执行，尚未调度。

## 实际断点

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](Documentation/M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](Documentation/PERFORMANCE_TEST_PLAN.md)。

## 实现范围

1. 独立Release TXTPerformanceProbe（Core package的桌面executable，iOS App不链接）和流式原创样本脚本，真实复制/normalization/SQLite/目录/cache/plan/全窗口遍历；每样本独立进程，三个warm OS-cache重开，所有样本hash/完整章节范围由Python独立生成核验。
2. 实测发现Apple Foundation长循环临时NSData/NSString累积。Core TXTFileAccess同步pool包住每chunk读取+处理，应用到digest/normalizer/scanner和window读取；Linux原操作。错误/取消/关闭失败原文保留，不跨await持有pool，Swift decoder/索引状态继续流式。版本不改，内容字节相同，旧位置/cache仍兼容。依据Apple WWDC24；swift-mmio可重用System buffer路线已读取并说明差异，未引入新依赖/try?关闭。
3. 原iOS真实长段扩至第二窗口，仍char>100/600点/3px，新增多MB单章首中末Readium资源与完整位置重开，不放宽正文/下一章/UTF16/旧回调约束；原EPUB/lifecycle/search/首次导入回归保留。
4. 测试DocumentImportTests的六个隐藏native host及其临时repo留到test worker结束，防迟到XPC给已销毁host送布局消息及活SQLite下unlink。生产App picker不改，不用私有API或吞异常，未扩写为系统bug永远修复。诊断原样另记。

## 最新验证与原件

运行源码1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，完整run/full/Core/Apple日志、xcresult、ReaderSnapshots、4样本JSON/log和新IPA在build/ci/38587015887；源/compiler gate与设备gate分开。根/download/workspace锁逐字节一致，6真实remote pins/Readium3.11与Vendor provenance不变。Windows语法不是编译。旧失败run38583014146与baseline JSON保留，不重跑同源碰运气；内存修复是新的实际源码。

最新真实第二窗口WK PNG已查看并记录m2-txt-longbook-build8-native-review.json，仅验收测试viewport/锚点，不扩写为完整布局/主题。运行诊断单列m2-txt-longbook-build8-runtime-diagnostics.json：本run tmp SQLite unlink与DocumentManager dead-host均0，AppIntents metadata6/WebKit process assertion31仍原样保留，不宣称所有runtime诊断0或系统bug永久修复。最终artifact抓取曾gh API EOF，读取重试后成功核对完整原件；这是只读网络错误，不是CI源码失败。

macOS51.23MB/3000章冷导入4.82s，三次cache校验+plan 1.98–2.33s，最终RSS25.83MiB；52.43MB无换行单章800窗口，最大65536bytes，最终RSS9.16MiB。桌面RSS不是iPhone分配/主线程/滚动流畅度，3次不算p95；完整表见PERFORMANCE_TEST_PLAN。

## 新旧包与设备

- Build8 IPA：build/XianxiaReader-TXT-Memory-Build8.ipa，7705388bytes，SHA256 db344d2b7da478639b79d7e7cf64554ef59e003dd8dd9fd1266cd21dd9ed15f4。
- Build8测试ZIP：build/XianxiaReader-TXT-Memory-Build8-TestKit.zip，8136508bytes，SHA256 7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533；8原创样本/内部IPA/CRC/hash核验，0755/arm64/iPhoneOS/最低16.0/系统SQLite/第三方声明通过。
- 8旧Build4/5/6/7 IPA/ZIP及build/XianxiaReader-M2-LongTXT-Samples.zip原hash保留；build/XianxiaReader.ipa仍Build4，没有覆盖。

TrollStore正常更新保留书库，不卸载/删DB；+菜单确认(8)。先冷首次TXT/EPUB复测，再用3000章和50MiB无换行样本核目录/搜索/书签/连续/章中段重开及大致导入/重开秒数。用户先前已确认Build7导入正常、Build4连续/位置可用；实际Build/OS/硬件尚未独立读取，不等于Build8或完整M2设备通过。普通签名设备独立待测。

## 接续与恢复

M2自动长篇门槛本轮已补齐并修正实测内存问题；剩余Build8设备长书/中文页面/目录搜索书签等实际验收。cache快开尚未只读元数据，不贸然删除摘要校验。M2满足门槛后M3完整书库，M4字体/主题/排版，M5更完整性能矩阵；XBook/知识库仍草案。

main/HEAD6d761749911233122bcd031fcf718d22a19f9e77与原空index不变，所有未提交改动保留。候选经独立GIT_INDEX_FILE快照/正常push；后续文档快照不冒充新编译。370文件原备份、全部旧包与历史交接保留。最新长篇过程见HANDOFF_M2_LONGBOOK_HISTORY_2026-10-14.md。无自己启动的挂起进程/运行CI，Windows没有Xcode，不启动/重置Docker/localhost/账单。

恢复AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核实际Git/files/logs/tasks；每可恢复步/生成/构建/测试前checkpoint。build/.cache不随clone，artifacts14天，过期按锁重跑；不要exclusive重建已存在包。源编译、自动断言、原生PNG、普通/TrollStore设备结果分开记录。
