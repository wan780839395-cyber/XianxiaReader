# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

2026-10-15 M3书库浏览/改名切片Build10已通过完整自动门槛：[CI38666201246](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38666201246) / 4ba69e58cdaa325cfd08e31ba5c3db42b1595b82。Linux/macOS各85Core、iOS63/63、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA。Windows390 Swift语法新增0（pristine54限制保留）/16tooling，语法不是编译；468源码Git blob hash、根/download/workspace六pins锁与13旧包一致。保护Readium/Vendor/codec/Locator/schema/文件协调不变，原main/HEAD6d76174和空index、所有未提交工作保留。

书架支持网格/列表、最近阅读/导入/书名排序并保存偏好、书名/作者筛选、无匹配状态、已保存进度。长按修改书名，最新DB payload在BEGIN IMMEDIATE事务内只改title，保留UUID/原件路径/cover/目录/完整位置/书签/importedAt；失败显示且不假装保存。刷新请求ID防旧读取覆盖提交新名。缺失/坏封面后台读取降级且有可见/无障碍警告。原生网格/列表/筛选无结果/改名错误四图已查看，观察与测试、设备门槛分开记录。 网格封面统一顶部对齐，筛选后的数量标作本匹配。中间候选d7cbc1d/CI38664441495完整自动门槛已通过，原图发现这两处UI问题后才做最小视觉修正并再次完整验证；中间成功原件/四图观察/运行诊断保留m3-library-pre-alignment-*，不把中间包当最终源码。

新测试包`build/XianxiaReader-Library-Build10-TestKit.zip`，SHA256 `3111d7fdfab3fb91f61f659001cbe6e26ba9173a5d27bd7ca7537aff0fe1215e`，含Build10 IPA和沿用的11原创样本/证据；正常更新保留书库，+菜单确认0.0.1 (10)。用户在Build9上下文回复“ok没问题 可以继续了”，记录基本自用接受，不扩写逐个编码/手机性能或普通设备矩阵。Build10手机布局/改名体验待测；M3尚有封面替换、可恢复删除、重复导入策略，M4字体/排版/主题随后。真实桌面4样本仍核全文digest/范围复用/锚点，不当手机性能。实现与来源见LIBRARY_BROWSING_DESIGN.md、M3_LIBRARY_VALIDATION_REPORT.json。

首轮cd76b4d/38662816246各85Core/四探针及5新Library回归通过，旧TXT首定位20秒超时使iOS62/63、test65/export0/summary0，Release未执行，完整原件保留。Library夹具清理3条SQLite unlink诊断通过保留小repository/目录至worker退出处理；原生sheet等待真实关闭，TXT仅加同步原生诊断，20秒/600点/字符/3px门槛保持。首定位唯一根因未证实，不宣称修复全部WebKit时序问题。最近阅读按实际已读优先、未读导入时间置后，有对应回归。

## 下一步

1. 本轮Build10源码/包已过自动门槛，用户手机结果未收到。读状态→本文件→ROADMAP→ARCHITECTURE，核实际文件/Git/运行任务/日志，不用文档tip当编译源。
2. 继续M3封面替换、可恢复删除、重复导入策略。删除须先设计文件/数据库恢复和原件保留，不直接删DB行/原件；schema变化需新迁移/恢复回归。不要提前铺开XBook世界观/云账号/社交。
3. 用户自用可用优先，不熟悉/反复失败先读官方对应版本和成熟实现，记录差异，不持续盲补。UI主题/字体/正文排版仍M4。

## 来源与包

- 真正编译来源4ba69e58cdaa325cfd08e31ba5c3db42b1595b82 / CI38666201246，完整run/full/Core/Apple/xcresult/锁/ReaderSnapshots/四样本/IPA在build/ci/38666201246。iOS63/63、各85Core/Release；468源码hash匹配，3份六pins锁一致，Core85包含5新增BookEditing、iOS63包含5新增Library回归，旧Reader/import/ANSI/search/lifecycle全跑。
- IPA `build/XianxiaReader-Library-Build10.ipa`，7824099bytes / SHA256 `f5b0d26ec2d532b34c63ff8dbcb060007d149346a988f71e818692b93627daef`，CRC/iPhoneOS/arm64/0755/最低16/SDK SQLite/第三方声明通过。测试包 `build/XianxiaReader-Library-Build10-TestKit.zip`，8254951bytes / SHA256 `3111d7fdfab3fb91f61f659001cbe6e26ba9173a5d27bd7ca7537aff0fe1215e`，内部IPA/11原创小大样本/hash/CRC通过。
- Report Documentation/M3_LIBRARY_VALIDATION_REPORT.json；原生UI图的观察和运行诊断在ValidationLogs本轮证据。自动检查、编译、原生模拟器画面/断言、普通设备、TrollStore实际设备分别记录；M3全部完成=false。
- Windows390语法新增0/54 pristine限制、16tooling不是Swift编译。当前无本机Xcode，不启动/重置Docker；CI原始错误/失败必须保留，不能跳过失败生成IPA。

## Git与恢复

main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，原空index保留；codex/m3-library独立index建源码/文档快照，原codex/m2-txt-index保持e6f31d8。新增文件在main仍untracked属于保留的现有工作，不能reset/checkout/误当丢失；普通git diff候选对main工作目录会把untracked文件误显删，源hash用独立index/Git blob核验。文档最终tip另核，不当编译源。

Build4–9共12旧IPA/ZIP及长书样本ZIP共13旧包逐hash保留，build/XianxiaReader.ipa仍Build4。Original370备份.cache/recovery/20261014-092934/interrupted-worktree.zip、原验证hash、所有M1/M2失败/成功历史保留。build/.cache不随clone，CI artifacts保留14天，过期后依锁真实重跑。

## 用户反馈与范围

Build9交付后用户回复“ok没问题 可以继续了”，基本自用工作流接受，证据ValidationLogs/m2-txt-build9-device-feedback.json；具体编码/实际安装Build/OS/硬件/手机耗时/普通签名设备不扩写。Build8长TXT/目录/重开已确认，Build7首次导入已确认，Build4连续/位置已确认。新Build10需要正常更新后核已有书库/位置、布局排序重开、筛选/清除、长按改名/空白错误/取消及TXT/EPUB阅读位置。

上轮一次性关机收据build/shutdown-build9-receipt.json显示request_accepted/exit0（命令接受不证明物理断电）。本轮是新的继续请求，未重新调度关机，不能沿用旧授权自动关机。结束前仍须核无自身遗留构建/下载任务及CI实际completed状态。

## 尚未实现

M3封面替换/可恢复删除/重复导入策略；M4字体/排版/主题；M5完整设备性能/耗电与其他设备矩阵。TXT全部Windows ANSI代码页、已导入书原地换编码界面和只读元数据秒开未实现，仍全文digest校验。知识库/XBook只有协议草案。

## 历史

本轮按步骤检查点保存在HANDOFF_M3_LIBRARY_HISTORY_2026-10-15.md。历史HANDOFF/M2报告保留，源码无新Reader/Vendor/codec/Locator变更。

## 收尾检查点

Build10 IPA及测试ZIP已独占另存并核对内部IPA/11原创样本/CRC，13旧包原hash保留。最终原生四图已实际查看；运行诊断SQLite vnode unlink0、DocumentManager dead-host0、AppIntents metadata6、WebKit ProcessAssertion31原样保留，源码编译warning/error0，不宣称所有运行诊断为零。首轮失败、中间成功和最终成功三次CI现均completed；已在下载/查询结束后核实无自身gh/python/swift/docker遗留进程。状态/路线/设计/功能矩阵和本交接已同步；下一步仅刷新inventory、保存独立文档快照并验证与4ba69e5运行源码无差异。最终文档tip请实查codex/m3-library，不据文档tip推断重新编译，也不再触发纯文档CI。
