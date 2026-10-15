# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

Build14重复导入通过[完整CI38703788390](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38703788390) / `b67a08bc7f6d0db0c97ec152a87e2128a3209c82`：Linux/macOS各110 Core、iOS84/84（79集成+5真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名设备Release14及真实IPA、各四长书Release探针。Windows411 Swift语法新增0/54 pristine限制、17 Python tooling通过；语法不是Swift编译。492运行/验证源Git blob hash、三份真实六pins锁和21旧包hash核对一致。

相同原件再次导入保留原书UUID/改名/封面/完整Locator/目录/书签/导入时间，底部展示新增与重复数量并可查看。回收站里的重复书由用户显式恢复，恢复后原有进度保留。格式+原件SHA256/64位bytes精确匹配；TXT另比正文正规化身份，自动与手选编码同正文去重、不同有效解码可独立导入。同名不同内容、新BOM/换行或EPUB重新打包不自动合并。

schema3新增003迁移及指纹表/索引，旧payload和已有重复书全部保留。旧原件后台延迟流式补齐，可取消；缺失旧原件警告但不阻止其他书，已登记匹配项原件缺失/损坏则可见错误，不冒充重复成功。最终BEGIN IMMEDIATE事务复查并提交Book/Chapter/指纹，多连接仅一个新UUID获提交；败方清自己暂存/cache。Reader/codec/Vendor/六pins/Locator和NSFileCoordinator合同保持。旧版不支持schema3降级读取，禁止删库修复。

原生重复项/回收站/恢复截图与实际XCTest视频及连续帧已复核，网格恢复和原生反馈保持同一灰绿风格、现有Reduce Motion合同。截图/模拟器录屏不当手机FPS、耗电或全部File Provider验收。用户最新反馈“没问题 正常”，Build14按基本自用范围通过，M3既定自用功能阶段收口；下一阶段M4主题/字体/正文排版尚未开始。设备型号/系统版本、逐项导入矩阵与手机FPS未重新核实，其他设备与M5性能继续单列。无自动合并旧重复书/替换原件/永久删除/GC；M5设备性能后续。

安装包`build/XianxiaReader-Duplicates-Build14.ipa` / SHA256 `40779ea86e068666fe3e7af70b3179738ce76cbeb5d2e73ee2e7f06777d68204`；测试ZIP`build/XianxiaReader-Duplicates-Build14-TestKit.zip` / SHA256 `c7feefc8c6a5f45632712e28a38c75d874f553eaa2c05e8b7a36c25a82a15b61`。新旧包共23份逐hash保留，ZIP内部IPA/11原创小大样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (14)。设计LIBRARY_DUPLICATE_DESIGN.md、报告M3_DUPLICATES_VALIDATION_REPORT.json。

首轮CI38700353531/84397ad实际失败于新增Core测试对照Data缺try；Core测试运行、macOS、iOS、Release未开始。修正try与合法双解码样本后完整重跑，未删除/放宽断言。完整首轮Core/full日志与ValidationLogs/m3-library-build14-first-compilation-failure.json保留；Apple artifact当轮不存在，下载helper因此返回1，不冒充产品失败。

第二轮CI38700674784/5278d286各110 Core与四长书通过、iOS83/84：79集成/旧4UI通过，仅新UI父容器AX标识覆盖Done使查询失败。实际视频发现重复反馈与状态叠放、单项136pt留白，修正产品VStack/内容高度/叶控件标识；保留原查询、15秒和断言。原件ValidationLogs/m3-library-build14-feedback-layout-ax-failure.json保留，最终成功不覆盖失败历史。

## 下一步

先按AGENTS指定顺序读文档并实核文件/Git/任务。用户“没问题 正常”已记录于Documentation/ValidationLogs/m3-library-build14-user-feedback.json，M3按既定基本自用门槛收口。下一次开发从M4主题、字体与正文排版开始；M4源码尚未开始，本次仅同步文档，无新构建。手机性能矩阵M5；不提前展开XBook/知识库。

## 保护与证据

main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77、原index空，所有未提交改动保留。M3用私有index快照推codex/m3-library；真正编译源b67a08bc7f6d0db0c97ec152a87e2128a3209c82与最终文档tip区分，最终tip实查分支。M2仍e6f31d857c0d73e25622a941db0b76e11f7bfe39。492运行/验证源Git blob hash核过，纯文档收尾不能写成新编译。初始687维护文件/21旧包逐hash核过，.cache/recovery/20261015-build14/initial-worktree.zip保存688项；最早370及Build13原备份/旧失败全部保留。原件永久保存，不自动合并旧重复或GC。schema3不能用旧版降级读取，不删库。

完整证据build/ci/38703788390含run.json/full.log/Core/Apple日志/xcresult/ReaderSnapshots/每case视频/四长书/实际IPA；报告M3_DUPLICATES_VALIDATION_REPORT.json、原生复核与runtime诊断原件分别记录。历史检查点HANDOFF_M3_DUPLICATES_HISTORY_2026-10-15.md。上轮已实际核对705维护文件inventory、23新旧包、492运行/验证源Git blob、初始688项ZIP CRC/原路径、原HEAD及空index/M2，仅文档与编译源不同。三轮CI实查均completed（两次真实失败、最终success），无自身监视/下载/Swift/视频处理进程。接下来只保存独立文档快照并再次核验inventory与远端tip；真正编译源仍b67a08bc，不为纯文档收尾重跑完整CI。用户未新授权关机，不沿用旧一次性请求。


本次反馈更新检查点：先核过上轮705文件inventory、492运行/验证源Git blob、23包、原HEAD/空index/M2及备份；仅新增用户反馈与文档。本次已核706维护文件inventory、492运行/验证源Git blob与23包一致，仅文档更新，repository checks通过，无自身构建/监视/视频处理任务。接下来保存私有index文档快照并最终复核，编译源和Build14包保持原样。
