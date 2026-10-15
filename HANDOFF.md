# 当前交接与恢复点

## Build16 当前实际断点（优先于下方历史）

源码子步：已增加ReaderVisualStyle/ReaderMenuView，重整ReaderAppearanceView外观/排版分段和ReaderView组装，版本16。保持原偏好功能/ID/模型/引擎，44pt按钮、ViewThatFits避免窄空间数值挤压，菜单短淡入淡出沿用系统和既有额外Reduce Motion请求；实心面板不依赖透明效果。保留旧90测试，新增2真正XCUITest覆盖菜单触控尺寸/模式/分组/排版保存重开/原书开关disabled规则及Reduce Motion请求。准备Windows检查和完整CI；新增截图/动效尚未实看，不记通过。

构建前：Windows仓库/420Swift grammar新增0、54 pristine限制和17Python tooling通过，报告M4_POLISH_STATIC_REPORT.json；语法不等于编译。现在私有index保存并推同一M4分支候选，随后workflow_dispatch完整CI（115Core各平台、92iOS=84集成+8UI、严格Release16）。新增test用既有XR_LIBRARY_UI_REDUCE_MOTION追加减少动效请求，不宣称改变系统设置。此前运行源a625与本次新候选分别记录，所有旧文件/25包保留。

2026-10-15用户在Build15后回复“没问题 可以继续”，记录基本自用通过，并明确希望UI更好看、可以参考成熟项目。设备型号/逐项巨段TXT整窗/FPS/普通签名设备矩阵未额外报告，不扩写。Build15真正编译源a6251ea23e6e126acd27f16b3fe4886fed74dd77 / 成功CI38722474043，各115Core/iOS90/Release15，纯文档tip a0c677c43ff350da7c9f4a75260c852a2c502e53。完整旧交接已保存Documentation/HANDOFF_M4_APPEARANCE_HISTORY_2026-10-15.md；反馈m4-appearance-build15-user-feedback.json。

现在开始M4第二切片Build16：打磨原生阅读菜单与阅读设置的信息层级/视觉/触控，外观和排版分组，保留全部既有偏好功能及Accessibility ID。参考Readest pinned cc236be4的design规范、Foliate gtk4 pinned67b6676d及Apple原生控件；差异和取舍记录READING_UI_DESIGN.md。不换引擎/加依赖；字体文件导入、亮度/音量键等仍为M4后续。当前未改运行源码、未编译/未生成Build16。

main/HEAD6d761749911233122bcd031fcf718d22a19f9e77和原空index、M2/M3旧tip均保留。按实际inventory核732维护文件+inventory共733项，备份.cache/recovery/20261015-build16/initial-worktree.zip；CRC与25旧包hash通过，详细hash/路径见m4-polish-build16-start.json。只用私有index保留候选，不改正常HEAD/index，不覆盖旧包和日志。

下一步先实现App层UI，复用现有model/provider/设置文件与完整Locator，不改schema/Vendor/原件/六pins。Windows check_repository.py --swift-syntax及17 Python tooling（本机Python3.11匹配cp311绑定）；随后完整CI，各115Core、原90测试全部保留并新增必要原生交互测试、严格Release16。成功后下载完整日志/xcresult/锁/实际IPA；复核本轮实际原生截图/成功case视频及连续帧，完成打包与文档同步。模拟器与手机验收分列。当前无遗留本轮构建/下载/watch进程，Build16尚未启动。

---

## Build15 历史原文

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

Build15阅读主题/基础排版通过[完整CI38722474043](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38722474043) / `a6251ea23e6e126acd27f16b3fe4886fed74dd77`：Linux/macOS各115Core、iOS90/90（84集成+6真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名iPhoneOS arm64 Release15及真实IPA、各四长TXT Release探针。Windows417Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是Swift编译。498运行/验证源Git blob hash、三份真实六pins锁核过。编译警告/错误与系统runtime消息分开，见专门诊断。

阅读菜单→阅读设置：日间/暖白/纸色/深灰/OLED黑五主题，深色正文#C6CCC5；默认/通用衬线/无衬线字体、80–200%字号、行高、段距、左右留白、两字缩进及对齐。默认暖白110%/1.75行高/0.8rem段距/两字缩进。全局Preferences/reading-v1.json在存储actor上有界读取/原子保存，打开前恢复，连续编辑顺序保存，错误可见/可重试；坏/未来版本设置原件保留。“沿用原书排版”时高级排版停用，固定布局不提供正文重排。

Adapter走3.11 Preferences与现有DOM锚点保护；连续当前/已加载/指定资源脚本派发已补齐（既有Vendor扩展及provenance记录），并以真实字号/颜色/CJK缩进和非零UTF16/byte定位回归。原书/资源ID/schema3/六pins/完整Locator/NSFileCoordinator合同保持。原生设置与实际TXT/EPUB截图、成功XCTest视频及连续帧已复核；不等价手机FPS、耗电、完整书籍/Provider矩阵或普通签名设备验收。

明确未验收：巨段TXT单个WKWebView截图只绘顶部少量文字、下方大片留白。实际DOM/CSS、非零位置及3px重排/重开测试通过；截图时序/层级裁切或真实满页缺陷尚未确认。须优先在手机或原生整窗检查调整字号后的满页正文与重开；确认前不能写成完整TXT排版验收，若复现留白则先修复再扩大M4范围。原生设置弹出22帧、纸色转深灰22帧与62.49秒录屏已看；20fps时间采样可有VFR重复帧，无插帧，不是手机FPS。

安装包`build/XianxiaReader-Appearance-Build15.ipa` / SHA256 `e65e5b349de4943ec05dc5651f7e2668de3141a73e769c3806dc38b66897a553`；测试ZIP`build/XianxiaReader-Appearance-Build15-TestKit.zip` / SHA256 `6967660ad5199a121b49e53fa0055edea47698a4d929da7ea6ffc195039c0fd8`。新旧共25包逐hash保留，ZIP内部IPA/11原创样本/封面样本/CRC核验。正常覆盖更新保留书库，+菜单确认0.0.1 (15)。M4第一片自动门槛通过，手机待测，M4整体未完成；字体文件导入、单书覆盖、独立四边距、字重/字距、亮度和音量键后续，M5真机性能单列。设计READING_APPEARANCE_DESIGN.md，报告M4_APPEARANCE_VALIDATION_REPORT.json。

首候选14444c58/CI38711095224为Agent主动取消：Linux115Core/四探针通过，Apple停在XcodeGen依赖编译，macOSCore/iOS/Release未开始。因复核发现连续动态CSS遗漏而取消，不是源码失败；完整取消/阶段/日志保留于m4-appearance-build15-agent-cancel.json。第二候选587ff09/CI38711610037各115Core/四探针通过、iOS87/89，旧boundary初始about:blank与新增TXT首窗非零UTF16等待失败，根因当轮未确认；6UI与新EPUB五主题通过，严格test65阻止Release，无IPA。完整失败与候选原件second-candidate-failure.json/second-candidate.json保留。新TXT改用既有第二窗口流程并补DOM诊断，仍600点/>100UTF16/3px；旧断言/超时未改。分页与快速连发设置回归随后补齐，新候选完整重跑；最终通过不能追认早期失败或宣称已证明空白页根因。 第三候选773df424/CI38714955473各115Core/四探针与全部旧回归、6UI、连续EPUB主题通过，新增分页和TXT位置失败（88/90），test65阻止Release。分页按官方3.11及配套JS确认无domRange路径，改为仅自标记LTR分页按精确DOM点选页；TXT实际scrollY612/offset577等accepted但未保存，精确byte65536样本复现旧64单位上下文拆emoji代理对，新增有效Unicode边界并保留caret身份。第三轮完整诊断、校正分析与候选原件均保留；最终结论须以最终成功原生回归为准。 第四候选62f0035e/CI38718644990仍88/90，但TXT已通过非零保存、无引擎错误、真实CSS与3px reflow，仅reopen探针提前访问缺失DOM抛TypeError；第五轮等节点就绪，3px保留。分页测试原1647在旧页20%高度，180%字体后不保证仍在当前页，改测顶部可见非零字，并验证实际字号>=原1.7倍。Adapter采样后即发完整Locator，防重排期间保存读旧百分比。完整失败/纠正依据和首四轮交接归档HANDOFF_M4_FIRST_FOUR_RUNS_2026-10-15.md保留；没有放宽旧回归。

## 下一步

先按AGENTS顺序读文档并实核Git/文件/日志/任务。Build14“没问题 正常”已使M3按既定基本自用范围收口。本轮M4第一片到Build15，下一步优先核手机五主题、字号/行距/缩进/复杂EPUB与改排版/退出重开的文字位置，再继续M4字体资产/细排版与设置持久化；不进入XBook/知识库。

## 保护与证据

main/HEAD仍6d761749911233122bcd031fcf718d22a19f9e77、原index空。新codex/m4-reading-appearance仅私有index候选，真正编译源码与最终纯文档tip区分；M3 tip44af41f0b8e700db1c6815558cb95ce3b8ed08fc和M2 e6f31d857c0d73e25622a941db0b76e11f7bfe39保持。开始706维护文件及inventory共707项已备份.cache/recovery/20261015-build15/initial-worktree.zip，SHA256 7255eebe26b5f015284509a76b4f8ebbc85c0ad8f242e9ba047bfe5a8b657e0c；Build14/13/最早备份与全部失败记录保留。上次交接原件Documentation/HANDOFF_M4_SETTINGS_HISTORY_2026-10-15.md。

完整build/ci/38722474043保留full/Core/Apple日志/xcresult/ReaderSnapshots/各case视频/三锁/四长书/实际IPA；原生复核与runtime诊断单列。完成前须最终核验498运行/验证blob、25包、707项备份CRC与原路径、当前inventory及HEAD/index/M2/M3，保存纯文档快照再核远端tip；文档改动不写成新编译。无手机验收声明，不沿用旧一次性关机请求。

打包/文档子步完成：Build15 IPA/TestKit已从最终成功CI实际产物生成，CRC/内部IPA/旧样本/23旧包hash通过。原生复核明确保留巨段TXT满页不确定性。现在进行文档更新后的Windows仓库/语法和17项tooling检查，再核498源blob、25包、两份恢复备份及最终文件清单；产品源码仍为a6251ea2，不把此后纯文档快照当作重新编译。

文档后的Windows复查完成：使用本机Python3.11匹配既有.cache/check-deps的cp311语法解析器，417Swift grammar新增0/54 pristine限制、17Python tooling全过。最初误用工具自带其他Python ABI导致tree_sitter._binding缺失，另有GBK输出错误，原始错误日志保留在CI目录final-windows-initial-encoding-error.log与final-windows-wrong-python-abi.log；未改源码/跳过检查/重装用户工具。最终日志final-windows-0/1.log，回执m4-appearance-build15-final-windows.json。恢复中719项resumed-worktree.zip也保留，SHA256 7bf0969ed8d71300443dcdc4e0521130b90f2506c57751c641f49d8180ea2619。

最终保护核验已过：498运行/验证Git blob仍精确匹配真正编译源a6251ea2；其后仅文档变动。当前732维护文件（不含inventory自身）均入清单，新旧25交付包hash一致，两份707/719项备份hash/CRC/原路径保留，原HEAD/index/M2/M3未动。最新五次CI均已结束，最终38722474043 success；无遗留本轮下载/验证/watch进程。完整核验在build/ci/38722474043/final-preservation-check.json。此后只保存并核对codex/m4-reading-appearance纯文档tip与远端、再验证inventory；下次从手机长TXT满页/主题/改排版位置确认继续。
