# Build14 原生复核完成，准备交付包

实际三原生图、38.53秒真实XCTest片1秒概览与26.6–27.7秒的22连续采样全部已看。恢复按钮提交后书架从2→3本，原封面/42%保持，网格原生淡入和补位在采样中可见；过渡中卡片路径有短暂相交、终态对齐，不能当无重叠全程或手机FPS证明。状态/重复详情竖排无旧叠放，单项按内容高度。原生/系统runtime独立报告已写，自动门槛和Release校验已过。下一步新建独立Build14 IPA/TestKit（不覆盖旧21包）并核内部IPA/样本/CRC，再同步最终文档和inventory。

# Build14 自动门槛与三原生图已核，连续帧待核

完整CI38703788390/b67a08bc各110Core、84/84（79集成+5UI）0失败/0跳过、test/export/summary/recording0、Release14 arm64无签名/0755/系统SQLite/notices/CRC、各四长书、492源Git blob/三份六pins锁/21旧包核过。IPA内003迁移与候选Git blob byte一致。三新原生图全部已看，实际38.53秒XCTest片的3页1秒概览已看，旧叠放和单项空白已修。接下来提取26.6秒起1.1秒连续采样，逐帧复核恢复补位，尚未宣告手机FPS或生成交付包。

# Build14 完整CI成功，正在下载与原生复核

第三轮CI38703788390/b67a08bc7f6d0db0c97ec152a87e2128a3209c82三个job均success；实际Linux110/四探针已核。正在下载完整Apple/xcresult/实际视频/ReleaseIPA，尚未实核84总数/三份锁/Release内容或原生图与连续帧；下载进程需等exit0。下一步检查实际IPA并核完整报告，再提取实际UIcase原生图和视频/连续帧。尚未生成交付包。

# Build14 第三候选：原生反馈布局修正，待完整CI

第二轮38700674784/5278d286各110 Core/四Release长书探针通过、iOS83/84（79集成与旧4UI通过），新UI仅因Done标识被父VStack继承覆盖失败，test65阻止Release。完整AX树/25.5秒实际视频已核，重复功能/3本书/42%正确；视频也发现safeAreaInset多子view相叠、单项ScrollView占136pt空白。已显式VStack竖排、单项按内容高度/多项滚动、移除父容器标识；保留原测试查询/15秒和全部断言。语法411新增0/54限制重新通过。源改动仅App LibraryView，Core业务/旧Reader/Vendor/锁未改；第三轮CI38703788390/b67a08bc7f6d0db0c97ec152a87e2128a3209c82已派发，repository-checks和Linux job通过、Apple进行中；待完整日志/原生图和连续帧/Release。失败原件ValidationLogs/m3-library-build14-feedback-layout-ax-failure.json。

# Build14 当前断点：完整CI运行中

已实核Build13初始687维护文件逐hash、21包逐hash、HEAD及空index；初始688项ZIP已保存.cache/recovery/20261015-build14/initial-worktree.zip。无gh/python/Swift/ffmpeg运行进程。用户“没问题 继续”按Build13基本自用接受记录，未扩大设备矩阵。

源码完成、10新Core/4新iOS/1新UI回归已写，Windows411 Swift语法新增0/54 pristine限制、17 Python tooling已通过（不是编译）。首轮CI38700353531/84397ad实际失败于新Core测试读取对照Data缺try；Core运行/Apple/iOS/Release未开始，完整Core日志与失败receipt保留。已修测试try及不同解码的合法café样本（UTF8/1252均有效），准备重新静态检查与完整CI，第二轮CI38700674784/5278d28623a235506c5e00c589782d9afdf25821已通过repository-checks与Linux Core job，Apple进行中；实际Linux日志已核110 Core/四长书Release探针/0源码编译警告错误，Apple仍进行中，iOS预期84；原生图/视频/Release未验证。实现M3精确重复导入：原件SHA256/bytes/格式，TXT另按正规化正文身份区分不同解码；保留已有UUID/位置/封面，回收站显式恢复。计划schema3指纹索引、旧库后台延迟补齐及事务内重复复查；源码/测试/CI/Release尚未完成。

以下为Build13已验证交接，保留作基线。

# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

Build13更换封面切片通过[完整CI38694877516](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38694877516) / `708d02d0ecadcb3d22d653965aa94203bf4ab227`：Linux/macOS各100Core、iOS79/79（75集成+4真正XCUITest），failed/skipped0，test/export/summary/recording退出0、无签名设备Release13与真实IPA、各四长书Release探针。Windows407Swift语法新增0/54 pristine限制、17tooling通过；语法不是Swift编译。487运行/验证源Git blob hash、三份真实六pins锁与19旧包hash匹配。

长按书籍→更换封面，从系统相册或文件选图，预览后保存；恢复默认先预览再保存，取消不提交。原书、默认封面、目录、完整位置、书签、书名与UUID保留。后台有界ImageIO下采样和缩略缓存，网格/列表更新有短淡入淡出并尊重Reduce Motion。真实DB失败保留草稿可重试；迟到/关闭/旧回调不能覆盖新选择。重复save已提交草稿不能回移已提交原图。schema2与旧迁移/Reader/codec/Vendor/依赖锁不变。

原生错误/待保存预览/书架/默认预览和实际XCUITest的Files取消/默认取消/保存/重开截图及视频已单独复核。测试夹具只在DEBUG隔离目录，Release恒nil且Mach-O无XR_LIBRARY_UI_*旗标。自动测试/录屏不当手机相册/File Provider权限、全部图像格式/旋转、手机FPS/耗电或普通签名设备验收。单图20MiB/8000万像素限制；旧自选原图保留，不自动GC或释放存储；自由裁切未提供。M3还剩重复导入策略，M4完整主题/正文排版和M5设备性能未开始。

安装包`build/XianxiaReader-Cover-Build13.ipa` / SHA256 `57a6e0c9639af654abd106bcd187ee7b37d721d3cedf315d2a1677aa5e4d6009`；测试ZIP`build/XianxiaReader-Cover-Build13-TestKit.zip` / SHA256 `85e5f5aef4886416d2aed4126b3e142be8749b3dc3bdceae29366e953628ac9c`，内部IPA/11原创样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (13)。设计LIBRARY_COVER_DESIGN.md、报告M3_COVER_VALIDATION_REPORT.json。Build12用户已接受当前观感，具体硬件/实测FPS未独立读出，Build13手机待测。

中间候选CI38688984422由Agent为提交边界保护主动取消，各100Core通过、Linux四探针通过，Apple长书探针未结束/iOS/Release未运行；完整日志与取消原因保留ValidationLogs/m3-library-build13-first-cancellation.json，不写成源码失败。

第二轮CI38689366894各100Core/四探针通过，iOS78/79（75集成全通过、原3UI通过，新UI标题查询失败），test65使Release未运行；原生AX树/视频确认系统Files已正常打开，修正子label查询并保留10秒/后续全部断言。另修纯row builder的MainActor警告，未禁用诊断。原件ValidationLogs/m3-library-build13-file-picker-ax-failure.json，最终成功不覆盖失败历史。

第三轮CI38691894649各100Core/四探针通过，iOS77/79：Files取消的全局indexed AX查找失败，以及旧fragment/DOM书签回归navigationFailed；8新封面集成与旧3UI通过。最终用本地AX包装实际frame/public coordinate点取消并断言Files确实消失；布局改为值初始化的独立子View和MainActor body，消除Spacer隔离警告。旧Reader只增阶段打印，原导航/几何/timeout和生产Reader均未改；一次navigationFailed的唯一原因仍未确认，后续全绿不写成已修复全部WebKit时序。原件ValidationLogs/m3-library-build13-cancel-ax-and-reader-failure.json。

## 下一步

1. 先读PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核对Git/实际文件/完整日志/任务，不假定最后一步完成。
2. 用户安装Build13后验证相册/文件首次选图、预览/取消/坏图重试、默认恢复与重启、回收站恢复、位置和书签；手机观感/流畅度独立记录。
3. 按M3继续重复导入策略及中断恢复；按既定方案，不提前进入M4/XBook/知识库。当前同步打磨原生手势/必要动效/间距，M4仍负责完整主题与正文排版，M5设备性能矩阵。

## 保护与验证边界

main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77，原空index与所有未提交改动保留；M3使用私有index快照并推codex/m3-library，真正编译源708d02d0ecadcb3d22d653965aa94203bf4ab227与最终文档tip区分。M2仍e6f31d857c0d73e25622a941db0b76e11f7bfe39。487候选运行/验证源hash与现工作目录Git blob核对，文档更新不冒充编译。旧19包与新Build13二包分别保留；不覆盖build/XianxiaReader.ipa（Build4）。

原始661文件inventory/19包在本轮开始逐hash核过，Build13初始工作目录备份.cache/recovery/20261015-build13/initial-worktree.zip（2268113bytes）保留；最早370备份.cache/recovery/20261014-092934/interrupted-worktree.zip和历次失败/成功原件保留。build/.cache不随clone，CI artifacts14天。已提交封面原图保留，恢复默认不释放磁盘，硬中断可能保留未引用Artwork；无永久删除/GC/自由裁切。

Windows407语法/17tooling与Swift编译分开；Linux/macOS100Core、iOS79/79（75集成+4XCUITest）、四长书探针和Release分别有原件。实际XCTest视频与基座simctl视频区分，后者只诊断；图/连续帧不是手机FPS或其他设备接受。Readium3.11/Vendor/codec/Locator/文件协调/根六pins锁保持；三份实际锁一致。Build13普通签名设备/TrollStore手机待测，M3全阶段未完成。

## 日志与收尾

当前成功完整证据build/ci/38694877516：run.json/full.log/Core/Apple日志/xcresult/ReaderSnapshots/每case视频/四长书/真实IPA。报告M3_COVER_VALIDATION_REPORT.json，原生复核与runtime诊断见其链接；源码警告/错误和系统运行诊断分别记录。首轮Agent取消38688984422完整原件单列。检查点历史HANDOFF_M3_COVER_HISTORY_2026-10-15.md。

收尾已实核本轮四个CI均completed（首轮Agent取消、两轮实际失败、最终success），无自身下载/构建/录屏检查进程。Windows407语法新增0/54限制、17tooling与完整Swift门槛分别保留。687维护文件inventory、487源Git blob和21新旧包/原备份/原HEAD及空index/M2分支已核对，现仅保存独立文档快照并再次核验；真正编译源708d02d，最终文档tip实查codex/m3-library，不为纯文档重跑完整CI。旧关机只历史，本轮用户活跃且未新授权关机，未安排关机。
