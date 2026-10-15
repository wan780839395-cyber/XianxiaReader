# 开发路线与阶段门槛

## Build15 M4第一片当前门槛

Build15阅读主题/基础排版通过[完整CI38722474043](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38722474043) / `a6251ea23e6e126acd27f16b3fe4886fed74dd77`：Linux/macOS各115Core、iOS90/90（84集成+6真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名iPhoneOS arm64 Release15及真实IPA、各四长TXT Release探针。Windows417Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是Swift编译。498运行/验证源Git blob hash、三份真实六pins锁核过。编译警告/错误与系统runtime消息分开，见专门诊断。

阅读菜单→阅读设置：日间/暖白/纸色/深灰/OLED黑五主题，深色正文#C6CCC5；默认/通用衬线/无衬线字体、80–200%字号、行高、段距、左右留白、两字缩进及对齐。默认暖白110%/1.75行高/0.8rem段距/两字缩进。全局Preferences/reading-v1.json在存储actor上有界读取/原子保存，打开前恢复，连续编辑顺序保存，错误可见/可重试；坏/未来版本设置原件保留。“沿用原书排版”时高级排版停用，固定布局不提供正文重排。

Adapter走3.11 Preferences与现有DOM锚点保护；连续当前/已加载/指定资源脚本派发已补齐（既有Vendor扩展及provenance记录），并以真实字号/颜色/CJK缩进和非零UTF16/byte定位回归。原书/资源ID/schema3/六pins/完整Locator/NSFileCoordinator合同保持。原生设置与实际TXT/EPUB截图、成功XCTest视频及连续帧已复核；不等价手机FPS、耗电、完整书籍/Provider矩阵或普通签名设备验收。

明确未验收：巨段TXT单个WKWebView截图只绘顶部少量文字、下方大片留白。实际DOM/CSS、非零位置及3px重排/重开测试通过；截图时序/层级裁切或真实满页缺陷尚未确认。须优先在手机或原生整窗检查调整字号后的满页正文与重开；确认前不能写成完整TXT排版验收，若复现留白则先修复再扩大M4范围。原生设置弹出22帧、纸色转深灰22帧与62.49秒录屏已看；20fps时间采样可有VFR重复帧，无插帧，不是手机FPS。

安装包`build/XianxiaReader-Appearance-Build15.ipa` / SHA256 `e65e5b349de4943ec05dc5651f7e2668de3141a73e769c3806dc38b66897a553`；测试ZIP`build/XianxiaReader-Appearance-Build15-TestKit.zip` / SHA256 `6967660ad5199a121b49e53fa0055edea47698a4d929da7ea6ffc195039c0fd8`。新旧共25包逐hash保留，ZIP内部IPA/11原创样本/封面样本/CRC核验。正常覆盖更新保留书库，+菜单确认0.0.1 (15)。M4第一片自动门槛通过，手机待测，M4整体未完成；字体文件导入、单书覆盖、独立四边距、字重/字距、亮度和音量键后续，M5真机性能单列。设计READING_APPEARANCE_DESIGN.md，报告M4_APPEARANCE_VALIDATION_REPORT.json。

以下为Build14及更早历史与完整路线；M4整体未完成。

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

## 2026-10-15 Build12当前切片

Build12书架左滑与动效已通过[完整CI38677706936](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38677706936) / `786c154402075e4885905db554ba7179e9c6d085`：Linux/macOS各91Core，iOS70/70（原67集成+3真正XCUITest），failed/skipped0、test/export/summary/recording退出0、无签名设备Release/真实IPA、四长书Release探针。Windows397Swift语法新增0/54 pristine限制、17tooling/bash语法通过，语法不是编译。476运行/验证源Git blob hash、三份真实六pins锁及Build4–11共17旧包hash匹配。

列表采用原生List/swipeActions，左滑露出灰绿色短按钮“移出”，不全滑直接执行；点后确认、取消不移出、数据库提交后才改变显示。保留长按入口。网格移出淡出/轻缩放、相邻书籍短spring补位，恢复/排序/筛选与布局切换过渡，回收站恢复行也有过渡；系统Reduce Motion关闭自定义移动/缩放及继承动画。VoiceOver标签明确书名/作者/进度。Core/schema2/Reader/codec/Vendor/文件协调/位置和依赖锁均不改。

三项XCUITest实际滑动/点击/取消/提交/重开回收站/恢复及网格真实frame补位/原序断言通过，六张原生图及实际XCTest录屏选定连续帧已单独查看；静态终态不是动画验收，录屏也不是手机60fps/p95/耗电证明。DEBUG夹具只用隔离UUID存储/偏好及正常小样导入；Release prepare恒nil，Mach-O不含XR_LIBRARY_UI_*开关，不能开启种书入口。CI录屏/导出/摘要失败均阻止IPA，原test错误码优先保留。

用户已确认Build11“都能正常使用”，按回收站/恢复自用范围记录接受；并要求全项目尽量好看流畅，已写入AGENTS，当前阶段同步打磨手势/必要动效，不统一推M4。Build12手机体验待反馈，其他设备矩阵不扩写。M3还剩封面替换/重复导入处理；完整主题/字体/正文排版仍M4，手机性能矩阵M5。

安装包`build/XianxiaReader-Shelf-Build12.ipa` / SHA256 `3aaa0c7813aab3262686738234fc627e6687755abfcaa4499dd6cfa2355fb163`；测试ZIP`build/XianxiaReader-Shelf-Build12-TestKit.zip` / SHA256 `a71ffe0d7792857ef99da00e03949837074c93f2a2c61e083c05243b748de22c`，内部IPA/11原创小大样本/CRC核验通过。正常更新保留书库，+菜单确认0.0.1 (12)。设计LIBRARY_INTERACTION_DESIGN.md；报告M3_INTERACTION_VALIDATION_REPORT.json。

本轮较早失败的完整原件另存：Documentation/ValidationLogs/m3-library-build12-first-compilation-failure.json, Documentation/ValidationLogs/m3-library-build12-menu-ax-failure.json；最终成功不覆盖失败记录。

第三轮由Agent为修正成功case录屏保留配置主动取消，非源码失败，证据Documentation/ValidationLogs/m3-library-build12-third-cancellation.json。最终动效仅按实际XCTest case录屏审阅；基座模拟器simctl视频仅诊断，不作App动效证明。

以下为历史证据，当前范围以上方Build12及直接用户反馈为准。

## 2026-10-15 Build11当前切片

Build11可恢复移出书架切片已通过[完整CI38668921850](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38668921850) / `bd68a48dc0fa41d07d839e4ddf07128d9069fe0f`：Linux/macOS各91Core、iOS67/67、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA；四长书Release探针继续通过。Windows394Swift语法新增0（54 pristine限制）与16tooling通过，语法不是编译。473运行/验证源Git blob hash、三份真实六pins锁、Build4–10共15旧包hash一致。

长按书籍→移出书架→原生确认，右上显示与排序菜单或空书架入口进入回收站，逐本恢复。002新迁移仅记录移出状态；不删除/移动Book原件或cache，不改章节、完整位置、书签、Book元数据。启动恢复清理使用全部已提交UUID，包含回收站。单SELECT快照与刷新请求ID防旧数据覆盖；真实写入失败/取消显示错误并保留状态。回收站不自动清空、不释放原件空间，不提供永久删除；schema2升级后旧Build10会显式拒绝打开新版库，不以删除数据库恢复降级。

已验证真实001旧库升级/重开、未提交迁移回滚、实际迁移失败保留数据、移出/恢复trigger失败与重试/幂等、多连接/取消，以及App真实TXT+EPUB移出后经生产启动清理再恢复原件与关联。原生确认/有书回收站/空状态三图已实际查看；模拟器不等于手机验收。用户Build10后的“没问题 继续”记录为该切片基本自用接受，未扩写逐项硬件/编码/性能矩阵。Build11手机结果待反馈，M3还剩封面替换和重复导入处理，M4字体/排版/主题尚未开始。

安装包`build/XianxiaReader-Trash-Build11.ipa` / SHA256 `9af1348004e1e150c3e9d9a68b02b754a5915328201287eee7e00d4c6cf8b1e9`；测试包`build/XianxiaReader-Trash-Build11-TestKit.zip` / SHA256 `616810a2fe3e6f031a3e9576f8d670e2081a556129892186017a930db1530700`，含真实Build11 IPA和11原创小/大样本，CRC/内部IPA/样本bytes核验通过。正常更新保留书库，+菜单确认0.0.1 (11)。设计LIBRARY_REMOVAL_DESIGN.md；报告M3_REMOVAL_VALIDATION_REPORT.json。

以下为历史证据，当前范围以上方Build11与直接用户反馈为准。

## 2026-10-15 Build10当前切片

2026-10-15 M3书库浏览/改名切片Build10已通过完整自动门槛：[CI38666201246](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38666201246) / 4ba69e58cdaa325cfd08e31ba5c3db42b1595b82。Linux/macOS各85Core、iOS63/63、failed/skipped0、test/export/summary0、无签名设备Release/真实IPA。Windows390 Swift语法新增0（pristine54限制保留）/16tooling，语法不是编译；468源码Git blob hash、根/download/workspace六pins锁与13旧包一致。保护Readium/Vendor/codec/Locator/schema/文件协调不变，原main/HEAD6d76174和空index、所有未提交工作保留。

书架支持网格/列表、最近阅读/导入/书名排序并保存偏好、书名/作者筛选、无匹配状态、已保存进度。长按修改书名，最新DB payload在BEGIN IMMEDIATE事务内只改title，保留UUID/原件路径/cover/目录/完整位置/书签/importedAt；失败显示且不假装保存。刷新请求ID防旧读取覆盖提交新名。缺失/坏封面后台读取降级且有可见/无障碍警告。原生网格/列表/筛选无结果/改名错误四图已查看，观察与测试、设备门槛分开记录。 网格封面统一顶部对齐，筛选后的数量标作本匹配。中间候选d7cbc1d/CI38664441495完整自动门槛已通过，原图发现这两处UI问题后才做最小视觉修正并再次完整验证；中间成功原件/四图观察/运行诊断保留m3-library-pre-alignment-*，不把中间包当最终源码。

新测试包`build/XianxiaReader-Library-Build10-TestKit.zip`，SHA256 `3111d7fdfab3fb91f61f659001cbe6e26ba9173a5d27bd7ca7537aff0fe1215e`，含Build10 IPA和沿用的11原创样本/证据；正常更新保留书库，+菜单确认0.0.1 (10)。用户在Build9上下文回复“ok没问题 可以继续了”，记录基本自用接受，不扩写逐个编码/手机性能或普通设备矩阵。Build10手机布局/改名体验待测；M3尚有封面替换、可恢复删除、重复导入策略，M4字体/排版/主题随后。真实桌面4样本仍核全文digest/范围复用/锚点，不当手机性能。实现与来源见LIBRARY_BROWSING_DESIGN.md、M3_LIBRARY_VALIDATION_REPORT.json。

首轮cd76b4d/38662816246各85Core/四探针及5新Library回归通过，旧TXT首定位20秒超时使iOS62/63、test65/export0/summary0，Release未执行，完整原件保留。Library夹具清理3条SQLite unlink诊断通过保留小repository/目录至worker退出处理；原生sheet等待真实关闭，TXT仅加同步原生诊断，20秒/600点/字符/3px门槛保持。首定位唯一根因未证实，不宣称修复全部WebKit时序问题。最近阅读按实际已读优先、未读导入时间置后，有对应回归。

以下为历史记录，当前范围以上述Build10及用户反馈为准。

## 2026-10-15 门槛与后续

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。


以下为历史阶段记录，当前范围以上述Build9与设备反馈为准。

所有状态以 PROJECT_STATUS.md 和真实验证结果为准。前一 milestone 未通过构建与测试前，不大规模推进下一阶段；Windows 可提前准备必要源码，但不得绕过验收门槛。

| 版本 | Milestone | 交付与门槛 |
| --- | --- | --- |
| V0.0.x | M0 项目结构与技术验证 | 工程可生成；Core 测试通过；Readium 2/3 元数据与 Navigator 集成测试通过；Release 设备构建及 unsigned IPA artifact；无隐藏失败 |
| V0.1 | M1 基础 EPUB 阅读器 | 导入/封面/TOC/分页/滚动/内部链接/图像/CSS；搜索；位置恢复；基础书签；中文 EPUB 2/3 与重排样书模拟器及真机验收 |
| V0.2 | M2 TXT 与分章 | 编码识别/转码、独立识别器、流式索引、章节缓存、按章阅读、取消/失败恢复；八类标题规则及跨块回归；数十 MB 冷导入与缓存重开 |
| V0.3 | M3 完整书库 | 网格/列表、删除、改名、改封面、最近阅读与进度；文件/数据库一致性、重复导入策略与中断恢复 |
| V0.4 | M4 设置与主题 | 字体及导入、字号/字重/行距/段距/四边距/两字缩进/对齐/亮度/翻页；五种主题；设置持久化；音量键翻页技术验证与设备验收 |
| V0.5 | M5 性能与长篇验证 | 100/300/500 万字、1000/3000+章样本；导入/阅读/重开/目录/搜索的耗时、内存、卡顿、耗电基线；修复瓶颈 |
| V0.6–0.8 | MVP 稳定化 | 无障碍、iPad/横竖屏、导入 File Provider、升级迁移、书签/位置恢复、异常和设备矩阵；Readium 高亮/TTS 的独立增量阶段 |
| V0.9 | 发布候选 | 签名发行流程、隐私/第三方许可核对、长时间阅读及升级回归；普通设备与 TrollStore 测试分别记录 |
| V1.0 | 稳定阅读器 | EPUB/TXT MVP 功能全部验收，文档/数据迁移/性能门槛落实；XBook 与知识库继续作为后续独立版本 |

## M0 当前切片

2026-10-13 已通过 M0 自动门槛（run 38390862584）；详情见 Documentation/M0_ACCEPTANCE.md。下一阶段 M1，真实页面/设备验收仍待完成。

完成源码结构、工程定义、CI、独立模型/repository/引擎接口、基础 EPUB 导入和 Reader、最基本测试。它包含 M1 所需的技术验证切片，不代表整个 M1 已通过。

M0 放行证据必须包括：完整 build log、Core 测试结果、iOS tests `.xcresult`、设备构建与生成 IPA 的 hash。CI 通过仍不能替代 M1 的真实阅读体验验收。

## M1 验收清单

2026-10-14恢复结果：CI38530334549/d62af3b完整成功，Linux/macOS各14 Core、41/41 iOS、设备Release/Build4 IPA及测试包已核验，433个运行源码hash一致。用户随后确认连续功能/重开位置正常并授权按计划继续，现开始M2 Core切片。CI边界PNG证据不完整仍保留，未单独确认的其他设备细项/原书图像/性能继续记录，不扩写为完整矩阵。新阶段见下方M2及HANDOFF。

历史Build3：[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)（源码0b30d539d7eb6d557d8b5e5e8efad600c4c4435b）各14 Core、31 iOS及设备Release成功，原创封面上下色带完整。它仅支持章内滚动与横向资源切换；连续候选的最新证据以上方Build4为准。该历史节点当时尚未完成设备验收；最新用户连续/重开反馈与当前M2断点以上方记录为准。详情Documentation/READER_VIEWPORT_FIX.md / DEVICE_ACCEPTANCE.md。

- EPUB 2 NCX / EPUB 3 nav、nested TOC、图片、CSS、fragment 链接与脚注；损坏文件和 DRM 错误可解释。
- Files 本地/iCloud 导入；取消、批次部分失败、后台/退出恢复不丢已提交书籍。
- 搜索增量结果及跳转；不能一次读取全书到主线程。
- 首次位置回调、关页/后台/重启恢复，含章节中段与链接 fragment；旋转和分页/滚动转换后恢复。
- 中心菜单、两侧翻页、手势、目录与书签；不同字号、VoiceOver、横竖屏下不遮正文。
- 用户要求的真正纵向连续跨章：章末/下一章能同时显示、保留拖动与惯性；有限资源窗口、逆向滚动、图片高度变化、原始 Locator 恢复。作为独立 M1 引擎切片执行，不能把现有章内滚动标为完成。见 Documentation/CONTINUOUS_SCROLL_DESIGN.md。
- 真机体验记录及关键截图/录屏；不能把“构造了 Navigator”当成排版已验证。

## M2 识别回归

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](Documentation/M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](Documentation/PERFORMANCE_TEST_PLAN.md)。

2026-10-14用户确认Build4连续功能与重开位置正常，并授权按计划继续；结合M1完整CI构建/测试通过，M2 Core分章/有界读取第一切片现已通过38538141364/0643093的完整验证：attempt2各33 Core、41 iOS及设备Release。首轮旧EPUB冷启动超时原文保留，原因未确认；不把同源重试通过写成已修复。随后编码/cache第二Core切片已通过CI38547339868/65c1b8d：各60 Core、41 iOS及设备Release；首轮Apple iconv失败保留，更换公开SDK CoreFoundation后原/扩展向量通过。TXT产品导入/Readium阅读/完整位置随后通过CI38559906005/37eb86a各68 Core、46 iOS及Build5 Release；设备TXT与数十MB冷导入/cache重开尚未验收，详见TXT_READING_DESIGN.md。M1未逐项确认的设备细项保持独立记录；M3完整书库、M4排版/主题顺序不变。

必须覆盖 `第一章`、`第一百二十三章`、`第123章`、`第 123 章`、`第一卷`、`卷一`、`正文 第一章`、`Chapter 1`；还需超长章节名、空行/BOM/CRLF、分隔符、跨 chunk、正文中的同样短语、无章节等反例。

卷是分组而非重复正文边界；Chapter 的稳定身份和阅读位置不能随重新索引随意变化。编码检测不确定时必须可由用户更正，不能用不可逆乱码文本覆盖原件。

## M4 排版要求

默认双中文字符首行缩进、合理中文标点换行/行距/字间距/段距、独立章节标题与明确章节分隔。Readium Preferences 优先实现；额外 CSS 必须局部且尊重 EPUB 结构，禁止重写整本正文。

主题至少日间白色、暖白、羊皮纸/米黄、深灰、OLED 黑。深色主题使用柔和浅色正文，不使用刺眼纯白大面积正文。自定义字体存入本地受管理资产，按书/全局设置明确优先级。

音量键翻页需先验证公开 API、系统音量与音频行为，分别记录普通设备/TrollStore。若 API 无法稳定实现，先记录证据与产品取舍，不使用私有 API 偷渡实现，也不宣称完成。

## 长期维护节奏

每个可恢复子步骤及长构建前更新 HANDOFF；每个阶段后更新状态和验证证据。依赖升级独立处理，锁定版本与 migration 一起审阅。编译失败优先修复具体 API/类型/工程问题，保留原功能和失败日志。

2026-10-14首次文件交接增量：Build6 / [CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849)各68 Core、49 iOS及设备Release通过，EPUB/TXT共用引用模型结果交接；新增原生sheet首次/取消/空选择/重试回归。旧交接未在iOS18.5复现用户iOS16.6.1现象，设备首次导入仍待实测，M2长书/设备未完成。新包build/XianxiaReader-Import-Build6-TestKit.zip；旧Build4/5不变。详见Documentation/IMPORT_HANDOFF_FIX.md与HANDOFF。

2026-10-14后续首次导入：用户否定Build6设备首次体验；最新Build7 / [CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917)各68Core/55iOS/Release通过，直接从delegate启动导入、保持关闭后的delegate、统一sheet/持久错误反馈；完整书架/无dismiss/弱回调与原生命周期回归保留。新包build/XianxiaReader-Import-Build7-TestKit.zip，旧4/5/6均保留。用户随后确认首次导入正常，M2长书/设备及M3/M4门槛不变；详见IMPORT_DELEGATE_FIX.md与HANDOFF。

2026-10-14用户验收补充：Build7交付后回复“ok 能正常导入了 没问题”，首次导入问题已确认解决，deviceFirstImportAccepted=true；源码/安装包未变。格式/文件来源未逐项报告，完整M2长书/设备及M3/M4门槛不变；证据Documentation/ValidationLogs/m2-import-build7-device-feedback.json。
