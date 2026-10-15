# 项目状态

更新时间：2026-10-15（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | 自动门槛通过 | 编译/Core/iOS/Release/真实IPA |
| M1 基础 EPUB | 完整自动门槛通过，用户确认连续阅读与重开位置可用；可继续既定路线 | 未逐项确认的原书图像、其他设备/旋转/性能继续单独记录 |
| M2 TXT | Build9 ANSI/范围缓存各80Core/58iOS/Release通过；Build8手机基础确认 | Build9自用反馈正常；个别编码/其他设备矩阵单列 |
| M3 完整书库 | 完整自动门槛及Build14基本自用通过 | 自用阶段收口，其他设备与实测性能单列 |
| M4 设置与主题 | Build15自动门槛/原生设置复核完成；巨段TXT满页、手机待测 | 五主题/基础排版/全局保存；字体导入等后续，整体未完 |
| M5 性能 | 未开始 | 百万字/数千章基线 |

## Build16 当前切片（源码实现中）

用户确认Build15基本自用正常，要求UI更美观并参考成熟项目。M4继续打磨原生阅读菜单/外观与排版分组、灰绿配色/点按尺寸，见READING_UI_DESIGN.md。未改变引擎/schema/锁文件，字体资产导入等后续。本轮Windows检查/Apple编译/原生复核/手机结果尚待，不将下方Build15证据当作Build16验证。

## Build15 历史切片

收尾已保存实际Build15 IPA/TestKit、交接和验证证据；498源码blob/25包/两份恢复备份/732维护文件清单与原HEAD/index/M2/M3已核。最终编译源a6251ea2与其后纯文档分支tip分别记录，详见HANDOFF.md及build/ci/38722474043/final-preservation-check.json。当前无遗留本轮构建/下载任务。

Build15阅读主题/基础排版通过[完整CI38722474043](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38722474043) / `a6251ea23e6e126acd27f16b3fe4886fed74dd77`：Linux/macOS各115Core、iOS90/90（84集成+6真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名iPhoneOS arm64 Release15及真实IPA、各四长TXT Release探针。Windows417Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是Swift编译。498运行/验证源Git blob hash、三份真实六pins锁核过。编译警告/错误与系统runtime消息分开，见专门诊断。

阅读菜单→阅读设置：日间/暖白/纸色/深灰/OLED黑五主题，深色正文#C6CCC5；默认/通用衬线/无衬线字体、80–200%字号、行高、段距、左右留白、两字缩进及对齐。默认暖白110%/1.75行高/0.8rem段距/两字缩进。全局Preferences/reading-v1.json在存储actor上有界读取/原子保存，打开前恢复，连续编辑顺序保存，错误可见/可重试；坏/未来版本设置原件保留。“沿用原书排版”时高级排版停用，固定布局不提供正文重排。

Adapter走3.11 Preferences与现有DOM锚点保护；连续当前/已加载/指定资源脚本派发已补齐（既有Vendor扩展及provenance记录），并以真实字号/颜色/CJK缩进和非零UTF16/byte定位回归。原书/资源ID/schema3/六pins/完整Locator/NSFileCoordinator合同保持。原生设置与实际TXT/EPUB截图、成功XCTest视频及连续帧已复核；不等价手机FPS、耗电、完整书籍/Provider矩阵或普通签名设备验收。

明确未验收：巨段TXT单个WKWebView截图只绘顶部少量文字、下方大片留白。实际DOM/CSS、非零位置及3px重排/重开测试通过；截图时序/层级裁切或真实满页缺陷尚未确认。须优先在手机或原生整窗检查调整字号后的满页正文与重开；确认前不能写成完整TXT排版验收，若复现留白则先修复再扩大M4范围。原生设置弹出22帧、纸色转深灰22帧与62.49秒录屏已看；20fps时间采样可有VFR重复帧，无插帧，不是手机FPS。

安装包`build/XianxiaReader-Appearance-Build15.ipa` / SHA256 `e65e5b349de4943ec05dc5651f7e2668de3141a73e769c3806dc38b66897a553`；测试ZIP`build/XianxiaReader-Appearance-Build15-TestKit.zip` / SHA256 `6967660ad5199a121b49e53fa0055edea47698a4d929da7ea6ffc195039c0fd8`。新旧共25包逐hash保留，ZIP内部IPA/11原创样本/封面样本/CRC核验。正常覆盖更新保留书库，+菜单确认0.0.1 (15)。M4第一片自动门槛通过，手机待测，M4整体未完成；字体文件导入、单书覆盖、独立四边距、字重/字距、亮度和音量键后续，M5真机性能单列。设计READING_APPEARANCE_DESIGN.md，报告M4_APPEARANCE_VALIDATION_REPORT.json。

首候选14444c58/CI38711095224为Agent主动取消：Linux115Core/四探针通过，Apple停在XcodeGen依赖编译，macOSCore/iOS/Release未开始。因复核发现连续动态CSS遗漏而取消，不是源码失败；完整取消/阶段/日志保留于m4-appearance-build15-agent-cancel.json。第二候选587ff09/CI38711610037各115Core/四探针通过、iOS87/89，旧boundary初始about:blank与新增TXT首窗非零UTF16等待失败，根因当轮未确认；6UI与新EPUB五主题通过，严格test65阻止Release，无IPA。完整失败与候选原件second-candidate-failure.json/second-candidate.json保留。新TXT改用既有第二窗口流程并补DOM诊断，仍600点/>100UTF16/3px；旧断言/超时未改。分页与快速连发设置回归随后补齐，新候选完整重跑；最终通过不能追认早期失败或宣称已证明空白页根因。 第三候选773df424/CI38714955473各115Core/四探针与全部旧回归、6UI、连续EPUB主题通过，新增分页和TXT位置失败（88/90），test65阻止Release。分页按官方3.11及配套JS确认无domRange路径，改为仅自标记LTR分页按精确DOM点选页；TXT实际scrollY612/offset577等accepted但未保存，精确byte65536样本复现旧64单位上下文拆emoji代理对，新增有效Unicode边界并保留caret身份。第三轮完整诊断、校正分析与候选原件均保留；最终结论须以最终成功原生回归为准。 第四候选62f0035e/CI38718644990仍88/90，但TXT已通过非零保存、无引擎错误、真实CSS与3px reflow，仅reopen探针提前访问缺失DOM抛TypeError；第五轮等节点就绪，3px保留。分页测试原1647在旧页20%高度，180%字体后不保证仍在当前页，改测顶部可见非零字，并验证实际字号>=原1.7倍。Adapter采样后即发完整Locator，防重排期间保存读旧百分比。完整失败/纠正依据和首四轮交接归档HANDOFF_M4_FIRST_FOUR_RUNS_2026-10-15.md保留；没有放宽旧回归。

下方Build14及更早内容为历史记录，最新状态以上述Build15为准。

## 2026-10-15 M3 自用验收收口

用户回复Build14“没问题 正常”，按既定基本自用门槛关闭M3。自动门槛沿用已验证源码b67a08bc与CI38703788390；本次仅记录反馈和同步文档，无新源码/构建/安装包。下一阶段M4尚未开始，证据见[用户反馈](Documentation/ValidationLogs/m3-library-build14-user-feedback.json)。

## Build14 当前切片

Build14重复导入通过[完整CI38703788390](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38703788390) / `b67a08bc7f6d0db0c97ec152a87e2128a3209c82`：Linux/macOS各110 Core、iOS84/84（79集成+5真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名设备Release14及真实IPA、各四长书Release探针。Windows411 Swift语法新增0/54 pristine限制、17 Python tooling通过；语法不是Swift编译。492运行/验证源Git blob hash、三份真实六pins锁和21旧包hash核对一致。

相同原件再次导入保留原书UUID/改名/封面/完整Locator/目录/书签/导入时间，底部展示新增与重复数量并可查看。回收站里的重复书由用户显式恢复，恢复后原有进度保留。格式+原件SHA256/64位bytes精确匹配；TXT另比正文正规化身份，自动与手选编码同正文去重、不同有效解码可独立导入。同名不同内容、新BOM/换行或EPUB重新打包不自动合并。

schema3新增003迁移及指纹表/索引，旧payload和已有重复书全部保留。旧原件后台延迟流式补齐，可取消；缺失旧原件警告但不阻止其他书，已登记匹配项原件缺失/损坏则可见错误，不冒充重复成功。最终BEGIN IMMEDIATE事务复查并提交Book/Chapter/指纹，多连接仅一个新UUID获提交；败方清自己暂存/cache。Reader/codec/Vendor/六pins/Locator和NSFileCoordinator合同保持。旧版不支持schema3降级读取，禁止删库修复。

原生重复项/回收站/恢复截图与实际XCTest视频及连续帧已复核，网格恢复和原生反馈保持同一灰绿风格、现有Reduce Motion合同。截图/模拟器录屏不当手机FPS、耗电或全部File Provider验收。用户最新反馈“没问题 正常”，Build14按基本自用范围通过，M3既定自用功能阶段收口；下一阶段M4主题/字体/正文排版尚未开始。设备型号/系统版本、逐项导入矩阵与手机FPS未重新核实，其他设备与M5性能继续单列。无自动合并旧重复书/替换原件/永久删除/GC；M5设备性能后续。

安装包`build/XianxiaReader-Duplicates-Build14.ipa` / SHA256 `40779ea86e068666fe3e7af70b3179738ce76cbeb5d2e73ee2e7f06777d68204`；测试ZIP`build/XianxiaReader-Duplicates-Build14-TestKit.zip` / SHA256 `c7feefc8c6a5f45632712e28a38c75d874f553eaa2c05e8b7a36c25a82a15b61`。新旧包共23份逐hash保留，ZIP内部IPA/11原创小大样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (14)。设计LIBRARY_DUPLICATE_DESIGN.md、报告M3_DUPLICATES_VALIDATION_REPORT.json。

首轮CI38700353531/84397ad实际失败于新增Core测试对照Data缺try；Core测试运行、macOS、iOS、Release未开始。修正try与合法双解码样本后完整重跑，未删除/放宽断言。完整首轮Core/full日志与ValidationLogs/m3-library-build14-first-compilation-failure.json保留；Apple artifact当轮不存在，下载helper因此返回1，不冒充产品失败。

第二轮CI38700674784/5278d286各110 Core与四长书通过、iOS83/84：79集成/旧4UI通过，仅新UI父容器AX标识覆盖Done使查询失败。实际视频发现重复反馈与状态叠放、单项136pt留白，修正产品VStack/内容高度/叶控件标识；保留原查询、15秒和断言。原件ValidationLogs/m3-library-build14-feedback-layout-ax-failure.json保留，最终成功不覆盖失败历史。

以下Build13及更早段落保留历史，最新状态以上述Build14为准。

## Build13 当前切片

Build13更换封面切片通过[完整CI38694877516](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38694877516) / `708d02d0ecadcb3d22d653965aa94203bf4ab227`：Linux/macOS各100Core、iOS79/79（75集成+4真正XCUITest），failed/skipped0，test/export/summary/recording退出0、无签名设备Release13与真实IPA、各四长书Release探针。Windows407Swift语法新增0/54 pristine限制、17tooling通过；语法不是Swift编译。487运行/验证源Git blob hash、三份真实六pins锁与19旧包hash匹配。

长按书籍→更换封面，从系统相册或文件选图，预览后保存；恢复默认先预览再保存，取消不提交。原书、默认封面、目录、完整位置、书签、书名与UUID保留。后台有界ImageIO下采样和缩略缓存，网格/列表更新有短淡入淡出并尊重Reduce Motion。真实DB失败保留草稿可重试；迟到/关闭/旧回调不能覆盖新选择。重复save已提交草稿不能回移已提交原图。schema2与旧迁移/Reader/codec/Vendor/依赖锁不变。

原生错误/待保存预览/书架/默认预览和实际XCUITest的Files取消/默认取消/保存/重开截图及视频已单独复核。测试夹具只在DEBUG隔离目录，Release恒nil且Mach-O无XR_LIBRARY_UI_*旗标。自动测试/录屏不当手机相册/File Provider权限、全部图像格式/旋转、手机FPS/耗电或普通签名设备验收。单图20MiB/8000万像素限制；旧自选原图保留，不自动GC或释放存储；自由裁切未提供。M3还剩重复导入策略，M4完整主题/正文排版和M5设备性能未开始。

安装包`build/XianxiaReader-Cover-Build13.ipa` / SHA256 `57a6e0c9639af654abd106bcd187ee7b37d721d3cedf315d2a1677aa5e4d6009`；测试ZIP`build/XianxiaReader-Cover-Build13-TestKit.zip` / SHA256 `85e5f5aef4886416d2aed4126b3e142be8749b3dc3bdceae29366e953628ac9c`，内部IPA/11原创样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (13)。设计LIBRARY_COVER_DESIGN.md、报告M3_COVER_VALIDATION_REPORT.json。Build12用户已接受当前观感，具体硬件/实测FPS未独立读出，Build13手机待测。

中间候选CI38688984422由Agent为提交边界保护主动取消，各100Core通过、Linux四探针通过，Apple长书探针未结束/iOS/Release未运行；完整日志与取消原因保留ValidationLogs/m3-library-build13-first-cancellation.json，不写成源码失败。

第二轮CI38689366894各100Core/四探针通过，iOS78/79（75集成全通过、原3UI通过，新UI标题查询失败），test65使Release未运行；原生AX树/视频确认系统Files已正常打开，修正子label查询并保留10秒/后续全部断言。另修纯row builder的MainActor警告，未禁用诊断。原件ValidationLogs/m3-library-build13-file-picker-ax-failure.json，最终成功不覆盖失败历史。

第三轮CI38691894649各100Core/四探针通过，iOS77/79：Files取消的全局indexed AX查找失败，以及旧fragment/DOM书签回归navigationFailed；8新封面集成与旧3UI通过。最终用本地AX包装实际frame/public coordinate点取消并断言Files确实消失；布局改为值初始化的独立子View和MainActor body，消除Spacer隔离警告。旧Reader只增阶段打印，原导航/几何/timeout和生产Reader均未改；一次navigationFailed的唯一原因仍未确认，后续全绿不写成已修复全部WebKit时序。原件ValidationLogs/m3-library-build13-cancel-ax-and-reader-failure.json。

以下Build12及更早段落保留历史，当前门槛以上述Build13为准。

## 2026-10-15 Build12 当前切片

Build12书架左滑与动效已通过[完整CI38677706936](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38677706936) / `786c154402075e4885905db554ba7179e9c6d085`：Linux/macOS各91Core，iOS70/70（原67集成+3真正XCUITest），failed/skipped0、test/export/summary/recording退出0、无签名设备Release/真实IPA、四长书Release探针。Windows397Swift语法新增0/54 pristine限制、17tooling/bash语法通过，语法不是编译。476运行/验证源Git blob hash、三份真实六pins锁及Build4–11共17旧包hash匹配。

列表采用原生List/swipeActions，左滑露出灰绿色短按钮“移出”，不全滑直接执行；点后确认、取消不移出、数据库提交后才改变显示。保留长按入口。网格移出淡出/轻缩放、相邻书籍短spring补位，恢复/排序/筛选与布局切换过渡，回收站恢复行也有过渡；系统Reduce Motion关闭自定义移动/缩放及继承动画。VoiceOver标签明确书名/作者/进度。Core/schema2/Reader/codec/Vendor/文件协调/位置和依赖锁均不改。

三项XCUITest实际滑动/点击/取消/提交/重开回收站/恢复及网格真实frame补位/原序断言通过，六张原生图及实际XCTest录屏选定连续帧已单独查看；静态终态不是动画验收，录屏也不是手机60fps/p95/耗电证明。DEBUG夹具只用隔离UUID存储/偏好及正常小样导入；Release prepare恒nil，Mach-O不含XR_LIBRARY_UI_*开关，不能开启种书入口。CI录屏/导出/摘要失败均阻止IPA，原test错误码优先保留。

用户已确认Build11“都能正常使用”，按回收站/恢复自用范围记录接受；并要求全项目尽量好看流畅，已写入AGENTS，当前阶段同步打磨手势/必要动效，不统一推M4。Build12手机体验待反馈，其他设备矩阵不扩写。M3还剩封面替换/重复导入处理；完整主题/字体/正文排版仍M4，手机性能矩阵M5。

安装包`build/XianxiaReader-Shelf-Build12.ipa` / SHA256 `3aaa0c7813aab3262686738234fc627e6687755abfcaa4499dd6cfa2355fb163`；测试ZIP`build/XianxiaReader-Shelf-Build12-TestKit.zip` / SHA256 `a71ffe0d7792857ef99da00e03949837074c93f2a2c61e083c05243b748de22c`，内部IPA/11原创小大样本/CRC核验通过。正常更新保留书库，+菜单确认0.0.1 (12)。设计LIBRARY_INTERACTION_DESIGN.md；报告M3_INTERACTION_VALIDATION_REPORT.json。

本轮较早失败的完整原件另存：Documentation/ValidationLogs/m3-library-build12-first-compilation-failure.json, Documentation/ValidationLogs/m3-library-build12-menu-ax-failure.json；最终成功不覆盖失败记录。

第三轮由Agent为修正成功case录屏保留配置主动取消，非源码失败，证据Documentation/ValidationLogs/m3-library-build12-third-cancellation.json。最终动效仅按实际XCTest case录屏审阅；基座模拟器simctl视频仅诊断，不作App动效证明。

## Build11 历史切片与用户反馈

以下保留Build11交付时的历史状态，当前用户反馈与门槛以上方Build12记录为准。

Build11可恢复移出书架切片已通过[完整CI38668921850](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38668921850) / `bd68a48dc0fa41d07d839e4ddf07128d9069fe0f`：Linux/macOS各91Core、iOS67/67、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA；四长书Release探针继续通过。Windows394Swift语法新增0（54 pristine限制）与16tooling通过，语法不是编译。473运行/验证源Git blob hash、三份真实六pins锁、Build4–10共15旧包hash一致。

长按书籍→移出书架→原生确认，右上显示与排序菜单或空书架入口进入回收站，逐本恢复。002新迁移仅记录移出状态；不删除/移动Book原件或cache，不改章节、完整位置、书签、Book元数据。启动恢复清理使用全部已提交UUID，包含回收站。单SELECT快照与刷新请求ID防旧数据覆盖；真实写入失败/取消显示错误并保留状态。回收站不自动清空、不释放原件空间，不提供永久删除；schema2升级后旧Build10会显式拒绝打开新版库，不以删除数据库恢复降级。

已验证真实001旧库升级/重开、未提交迁移回滚、实际迁移失败保留数据、移出/恢复trigger失败与重试/幂等、多连接/取消，以及App真实TXT+EPUB移出后经生产启动清理再恢复原件与关联。原生确认/有书回收站/空状态三图已实际查看；模拟器不等于手机验收。用户Build10后的“没问题 继续”记录为该切片基本自用接受，未扩写逐项硬件/编码/性能矩阵。Build11手机结果待反馈，M3还剩封面替换和重复导入处理，M4字体/排版/主题尚未开始。

安装包`build/XianxiaReader-Trash-Build11.ipa` / SHA256 `9af1348004e1e150c3e9d9a68b02b754a5915328201287eee7e00d4c6cf8b1e9`；测试包`build/XianxiaReader-Trash-Build11-TestKit.zip` / SHA256 `616810a2fe3e6f031a3e9576f8d670e2081a556129892186017a930db1530700`，含真实Build11 IPA和11原创小/大样本，CRC/内部IPA/样本bytes核验通过。正常更新保留书库，+菜单确认0.0.1 (11)。设计LIBRARY_REMOVAL_DESIGN.md；报告M3_REMOVAL_VALIDATION_REPORT.json。

## Build10 历史切片与用户反馈

2026-10-15 M3书库浏览/改名切片Build10已通过完整自动门槛：[CI38666201246](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38666201246) / 4ba69e58cdaa325cfd08e31ba5c3db42b1595b82。Linux/macOS各85Core、iOS63/63、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA。Windows390 Swift语法新增0（pristine54限制保留）/16tooling，语法不是编译；468源码Git blob hash、根/download/workspace六pins锁与13旧包一致。保护Readium/Vendor/codec/Locator/schema/文件协调不变，原main/HEAD6d76174和空index、所有未提交工作保留。

书架支持网格/列表、最近阅读/导入/书名排序并保存偏好、书名/作者筛选、无匹配状态、已保存进度。长按修改书名，最新DB payload在BEGIN IMMEDIATE事务内只改title，保留UUID/原件路径/cover/目录/完整位置/书签/importedAt；失败显示且不假装保存。刷新请求ID防旧读取覆盖提交新名。缺失/坏封面后台读取降级且有可见/无障碍警告。原生网格/列表/筛选无结果/改名错误四图已查看，观察与测试、设备门槛分开记录。 网格封面统一顶部对齐，筛选后的数量标作本匹配。中间候选d7cbc1d/CI38664441495完整自动门槛已通过，原图发现这两处UI问题后才做最小视觉修正并再次完整验证；中间成功原件/四图观察/运行诊断保留m3-library-pre-alignment-*，不把中间包当最终源码。

新测试包`build/XianxiaReader-Library-Build10-TestKit.zip`，SHA256 `3111d7fdfab3fb91f61f659001cbe6e26ba9173a5d27bd7ca7537aff0fe1215e`，含Build10 IPA和沿用的11原创样本/证据；正常更新保留书库，+菜单确认0.0.1 (10)。用户在Build9上下文回复“ok没问题 可以继续了”，记录基本自用接受，不扩写逐个编码/手机性能或普通设备矩阵。Build10手机布局/改名体验待测；M3尚有封面替换、可恢复删除、重复导入策略，M4字体/排版/主题随后。真实桌面4样本仍核全文digest/范围复用/锚点，不当手机性能。实现与来源见LIBRARY_BROWSING_DESIGN.md、M3_LIBRARY_VALIDATION_REPORT.json。

首轮cd76b4d/38662816246各85Core/四探针及5新Library回归通过，旧TXT首定位20秒超时使iOS62/63、test65/export0/summary0，Release未执行，完整原件保留。Library夹具清理3条SQLite unlink诊断通过保留小repository/目录至worker退出处理；原生sheet等待真实关闭，TXT仅加同步原生诊断，20秒/600点/字符/3px门槛保持。首定位唯一根因未证实，不宣称修复全部WebKit时序问题。最近阅读按实际已读优先、未读导入时间置后，有对应回归。

## Build9 历史证据（当前切片见上方 Build11）

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。

## 当前实际实现

- SwiftUI网格/列表书库，封面/书名/作者/已保存进度，最近阅读/最近导入/书名排序与偏好持久化，书名/作者筛选、长按改名与明确写入错误。
- EPUB Files多选副本导入、可见成功/失败；后台文件协调复制、Readium元数据/缩略封面、缓存TOC。原创EPUB2/3内置导入入口。
- Core的SQLite actor保存Book/Chapter/ReadingPosition/Bookmark，事务/导入恢复/路径和符号链接边界。位置保存完整版本化Locator，拒绝旧异步覆盖。
- ReadiumAdapter隔离引擎；分页、章内上下滚动、横向跨资源、中央菜单、目录/内部链接、书签、搜索/结果跳转、位置保存/恢复。关闭/重开过滤旧异步回调。
- ReaderSurface独立完整viewport、官方frame/autoresizing容器；横排重排媒体保护按实际innerHeight校准，固定/竖排保留原路径。目录/书签跳转后收起菜单；原创长短章/高封面样书和实际窗口回归。
- 安全SearchService扩展保留issue876回归；每批40、上下文64、UI最多1000；不跨文本元素/资源匹配，不收集全书结果。
- project.yml唯一工程源；两个Swift Packages；连续候选使用Readium3.11.0本地扩展及真实解析的6个远程pins（Build3历史为11 pins）；保留macOS完整CI和无签名IPA门槛。

## Build8 及更早历史证据与设备边界

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](Documentation/M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](Documentation/PERFORMANCE_TEST_PLAN.md)。

2026-10-14最新确认：用户回复“ok 能正常导入了 没问题”，Build7交付上下文的首次导入问题已验收通过，报告deviceFirstImportAccepted=true。来源为用户实测，格式/本地或iCloud/实际Build与OS未逐项核读；不扩写为完整TXT/普通签名设备/长书通过，M2Accepted=false。未改运行源码/包，55iOS/各68Core/Release自动证据不变。接续M2长篇与剩余设备验证，再按门槛M3/M4。证据Documentation/ValidationLogs/m2-import-build7-device-feedback.json。

2026-10-14最新用户设备反馈：Build6首次导入仍无反应/提示，第二次正常，已记录为首次设备验收失败。随后Build7直接delegate→Task、书架持有弱delegate至终止、单item sheet及持续错误反馈已通过[CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917) / 0afe45ef6764f3954b41c7f383fe98ff9f662181：各68Core、55/55iOS、设备Release、0 failed/skipped，457运行hash和三份锁一致。新增6项，完整LibraryView/无dismiss/关闭后弱回调/旧回调拒绝与终止释放均通过；初轮53项候选52/53系统DocumentManager异常原件保留，未降低断言。真实错误/成功书架PNG已核对反馈，完整页面布局/用户Files/iCloud未验收；tmp数据库清理SQLite诊断单列，不隐藏。新包build/XianxiaReader-Import-Build7-TestKit.zip / SHA5f280447e39b106cb096074a21d7d0a3954c8435a2131d4c038a8889309f4172，菜单可确认实际(7)，六个Build4/5/6旧包不变。用户设备首次导入随后已确认正常（最新反馈见上方）；M2长书/设备未完成，M3/M4未开始。最新报告M2_IMPORT_DELEGATE_VALIDATION_REPORT.json，设计IMPORT_DELEGATE_FIX.md。

2026-10-14首次文件导入修复已通过[CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849) / 5522489906224a089c91e92180bdcebbe9be2095 / Build6：结果由LibraryViewModel持有并在sheet关闭后消费一次，EPUB/TXT共用；各68Core/iOS49/49/Release通过，456运行hash与三份锁一致，源码compiler warnings/errors0。新增首次TXT、首次EPUB及取消/空选择/重试/迟到文件原生回归通过；两个先前48/49系统DocumentManager崩溃完整原件保留，最新仅修测试过渡/生命周期等待，不降低断言/增加timeout。iOS18.5旧交接未复现用户iOS16.6.1首次关闭无书无提示，设备唯一根因不宣称已证实，Build6设备首次选择仍待确认。新包build/XianxiaReader-Import-Build6-TestKit.zip，SHA256 112113c0e939c5d8aabdc5ad2280c8faf77f3f1d9288145e902d8ec3cc4a815c；Build4/5原件不变。报告M2_IMPORT_HANDOFF_VALIDATION_REPORT.json，设计IMPORT_HANDOFF_FIX.md。M2长书/设备未完成，M3/M4未开始，恢复点见HANDOFF。

TXT产品接入自动门槛已通过：[CI38559906005](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38559906005)，运行源码 `37eb86a46dc9002af381a44204f9bc36d07e11a4`，Linux/macOS各68 Core、46/46 iOS、test/export/summary全0，Build5设备Release/IPA通过；455运行hash匹配、三份锁一致，Windows379 grammar新增0/14 tooling通过。已接入受管理原件/cache/事务TXT导入、编码选择重试/取消、Readium公开Publication+Container最多64KiB窗口、字节/字符/完整Locator位置、目录/书签/搜索/连续。真实iOS模拟器三编码导入、长段600点滑动/3px重开、错正文/字符边界拒绝回归通过；原41 EPUB/lifecycle回归保留。五次真实失败原件保留，包含字节selector实际修复与测试就绪修正，未降低断言。新包另存 `build/XianxiaReader-TXT-Build5.ipa`、测试ZIP `build/XianxiaReader-TXT-Build5-TestKit.zip`；原Build4不覆盖。数十MB/cache重开耗时/巨段边界与用户设备中文页面未验收，完整M2尚未完成，暂不大规模M3/M4。报告M2_TXT_PRODUCT_VALIDATION_REPORT.json，设计TXT_READING_DESIGN.md。

M2编码/cache第二切片完整自动CI通过：[CI 38547339868](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38547339868)，运行源码 `65c1b8d6dbebf311c1e6b4b9534cda59373940b6`，Linux/macOS各60 Core（原33+新增27）、41/41既有iOS集成及设备Release CODE_SIGNING_ALLOWED=NO/IPA通过；445运行文件hash与当次已测快照匹配、三份锁一致。Windows372 grammar新增诊断0/14 tooling通过。支持严格UTF8/UTF16 LE/BE/GB18030分块转换、原/正规正文/目录SHA与编码/版本绑定cache。首轮Apple iconv两项四字节真实失败保留，现改用公开SDK CoreFoundation并通过同样及扩展向量；Linux保持glibc iconv，无新远程依赖。自动编码仅BOM/严格UTF8，其他要求选择；cache复用仍流式核验摘要，TXT导入/阅读/位置未接入，iOS真实TXT codec/导入/页面与设备未验收，完整M2尚未完成。当前Build4用户包保持不动，报告M2_TXT_NORMALIZATION_VALIDATION_REPORT.json。

2026-10-14用户反馈：“这个功能可以了，重开位置也是正常的”，并要求按计划继续。依据上一轮Build4上下文记录连续跨章/重开位置的用户设备确认，沿用iPhone13/iOS16.6.1/TrollStore背景；未报告的普通设备、原书图片、旋转和性能不扩写为通过。M1已有完整CI构建/测试门槛，现推进M2独立Core切片。UI完整书库在M3，排版/主题在M4。

M2新源码：独立标题识别器、UTF-8有界流式扫描/卷章目录/Int64范围、严格跨块UTF-8校验与有界窗口读取，19个新增Swift回归。Windows367文件grammar/新诊断0/14项Python通过，CI38538141364/0643093首轮Linux/macOS各33 Core通过，iOS编译后40/41、0 skipped，旧EPUB首次打开等待位置超时；test exit65，Release未执行。首次原文/诊断已保留；同一源码只重试失败iOS job一次，attempt2全部success：各33 Core、41/41 iOS及设备Release/IPA。438运行源码hash及根/workspace/下载锁匹配，旧Build4用户包保持不动；首轮超时原因未确认，不宣称已修复。TXT新组件未接入导入阅读，不冒称TXT可用。Docker管道查询错误已保留，未启动/重置工具。见M2_TXT_INDEX_VALIDATION_REPORT.json、TXT_INDEX_DESIGN.md和HANDOFF。

[CI 38530334549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38530334549)，已测源码 `d62af3b7576a11a1b7318e029355ef1847710113`：Linux/macOS各14 Core、iOS41/41、0 failed/0 skipped，测试/附件/summary退出码均0，设备Release `CODE_SIGNING_ALLOWED=NO`与Build4 IPA成功。完整下载日志、原始xcresult、锁文件和433个运行源码Git blob SHA核验一致；没有继续修改运行源码或重复触发CI。源码编译warning/error=0，6条AppIntents metadata提示及WebKit运行诊断原样保留。

- 当前 `build/XianxiaReader.ipa` 是Build4，7,502,213 bytes，SHA256 `7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1`；CRC/iPhoneOS/arm64/0755/最低16.0/系统SQLite/第三方声明核验通过。
- `build/XianxiaReader-Continuous-Build4-TestKit.zip`：7,429,683 bytes，SHA256 `f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7`，四本原创样书与UTF-8说明，内部IPA hash一致。旧Build3原件保留在 `build/ci/38434939423/ipa/`，旧测试ZIP保留。
- 连续模式支持横排LTR重排EPUB：有限窗口最多12资源、章间物理滚动、加载/失败重试、字符与局部视口锚点、目录/搜索/书签和模式往返。双章/逆向、600点长段滑动后charOffset>100及重开误差<3px、图片高度变化、千资源回收、迟到termination、rAF桥受阻初始化均过自动回归。
- 历史CI边界PNG只显示第一章末尾与空白，原因未判定；其截图证据不完整仍保留。最新用户设备反馈已确认连续功能和重开位置可用，不再把旧PNG当设备功能失败；封面分页/章内滚动上下色带完整。未单独报告的逆向/惯性细项、完整手动模拟器阅读、峰值内存、普通设备和原书图像继续记录待确认。
- 证据见 `Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json` 和 `Documentation/ValidationLogs/m1-continuous-build4-success.json`。用户要求自用、卡点参考成熟方案、微信读书交互、其余按原方案；原则已记入AGENTS及 `Documentation/MATURE_READER_REFERENCES.md`，未替换引擎或扩大阶段。

## 历史 Build3 证据（不代表当前包）

[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)（源码0b30d539d7eb6d557d8b5e5e8efad600c4c4435b）全部成功：Linux/macOS各14 Core、31 iOS tests、设备Release与Build3 IPA。源码compiler warnings=0；metadata提示另列。原创封面分页/滚动快照已人工查看，上下色带完整；用户原书与iOS16.6.1真机仍待复测。

- Windows结构/SQL/三本EPUB/42 Swift grammar通过（不是编译）；9 Python/tooling测试与bash -n通过。Linux/macOS Core各14，iOS实际31，结果范围分别记录。
- 新报告 `Documentation/M1_READER_VALIDATION_REPORT.json`：69个构建/验证来源hash匹配已测提交，11依赖pins不变，日志/IPA/快照hash。完整日志 `build/logs/ios-build.log`，原始日志/xcresult/快照/工程保留在 `build/ci/38434939423/ios/`。
- 历史 `build/ci/38434939423/ipa/XianxiaReader.ipa`：7,393,693 bytes；SHA-256 `12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2`，Build3/iPhoneOS/arm64/系统SQLite/0755/最低iOS16/ZIP核验通过，CODE_SIGNING_ALLOWED=NO。
- 测试ZIP `build/XianxiaReader-iPhone13-TestKit.zip`：7,296,582 bytes，包含IPA、三本原创EPUB和TESTING.txt，CRC与内部IPA hash一致。Build2及更早原件保留在对应run目录。
- 用户iPhone13/iOS16.6.1/TrollStore：安装正常、EPUB可以导入（用户报告，来源未细分）；原书图像窄横条。当前Build3安装/原书图片/完整阅读仍待复测；没有普通设备签名验收。
- remote compact恢复：本地main/6d76174和原暂存区保留，370文件ZIP已核验CRC/全部hash；候选codex/m1-continuous-recovery。此前各失败候选与完整日志保留在ValidationLogs及HANDOFF历史，不能将旧进行中状态当成当前结果；当前断点见上方Build4证据与HANDOFF。

## 失败历史与报告范围

Build3首轮38424689048 test bundle链接失败，第二轮38426725252导航探针超时，第三轮38430692977图片超限；原记录/完整日志保留在ValidationLogs与各run目录。修正后本轮全部通过，未删除测试/降低原图片断言/升级依赖。

M1_IMPORT_VALIDATION_REPORT.json属于Build2的26 tests；M1_SEARCH_VALIDATION_REPORT.json属于此前搜索；IOS_VALIDATION_REPORT.json属于M0；CORE_VALIDATION_REPORT.json是本机Linux；VALIDATION_REPORT.json仅静态。历史导入run38409222759由Agent提前取消，实际26iOS已通过、Release中断，不能写成源码失败。M0的SDK SQLite与缺AppIcon失败已在run38390862584修复验证。

Windows11/PowerShell7.6.5/Git2.54/Python3.11，本机无Xcode。GitHub origin/main已建立且CLI已授权；2026-10-14用户同意公开，API已确认PUBLIC，采用公开仓库标准runner免费构建，没有修改账单/支付/支出限额。最新Build9 CI已完成成功，无本项目进行中的验证任务。Docker曾恢复并升级4.95.0，原容器/备份保留；本轮未启动Docker。GitHub artifacts保留14天，忽略的build/.cache不随clone；过期后按锁文件重新CI。

## 下一步

M2 TXT导入/Readium阅读/完整字节文本位置与Build6首次文件交接已过自动门槛；先确认Build7设备首次TXT/EPUB选择，再验证TXT设备阅读、数十MB冷导入/cache重开与巨段边界，落实M2验收后再M3书库。已有Build4与用户书库保持不动。完整书库布局在M3、字体/主题/行距等在M4，百万字性能在M5；XBook知识库仅草案。其他设备细项继续单独记录，不将用户一句反馈扩大成完整矩阵。
