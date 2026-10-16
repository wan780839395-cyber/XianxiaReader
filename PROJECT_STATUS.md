当前新增进行中：Build21自动慢滚源码候选，Windows426语法/17工具通过，Apple完整编译/原生视频/交付尚待验证；详见HANDOFF和READING_AUTOSCROLL_DESIGN.md。Build20以下结果仍为已交付基线。

# 项目状态

## Build20 当前切片（2026-10-16）

Build20安装包/原创样书包已生成，504编译源blob、837维护文件清单、35新旧包及十份备份核过，全部原路径和原HEAD/空index保持；CI和下载均结束。源0b1fe877与之后纯文档tip分列，最终远端/树核验见build/ci/38850709820/final-preservation-check.json。

Build20即时整屏翻屏画面保护通过[完整CI38850709820](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38850709820)，实际编译源`0b1fe87704713e668231ad36ab73ceb13bd3b077`。Linux/macOS各122Core、iOS108/108（95集成+13真正UI）、失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release20/min16，三份六pins锁、504源blob及每平台四长TXT Release探针已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不等于编译。

沿Readium3.11现有issue737/PR763方案，仅给上下整屏的显式无动画翻屏保留一个原生视口画面200ms；底层位置立即更新，无新增位移/淡入，视觉等待有限且需手机验证。新拖动立即接管，模式/resize/跳转/关闭清理，保留期间拒绝新显式命令且不排队；无每帧截图/PNG编码/新正文缓存，原直接手势、连续模式、DOM/完整Locator与依赖锁保持。新增真实容器清理/重入与真正UI重复反向录屏，26个受改文件内原测试主体保持。设计READING_SCREEN_STABILITY_DESIGN.md，候选特色READING_FEATURE_IDEAS.md。

安装`build/XianxiaReader-ScreenStability-Build20.ipa` / SHA256 `ae6897c0e2e0387b1550fce67570d9bcbd57a7eb09f5d1330007f8baa080cf27`；原创样书测试包`build/XianxiaReader-ScreenStability-Build20-TestKit.zip` / SHA256 `2e9381d77aca6c1762dab1f14d002bcae538333d84e02d04a37c692701120319`。正常覆盖更新保留书库，+菜单确认0.0.1 (20)；原33包与两新包/原创样书/Preview/ZIP内部IPA均核。原Build19问题证据不追认，详情M4_SCREEN_STABILITY_VALIDATION_REPORT.json与m4-screen-build20-native-review.json。

本轮44张原生PNG均已看，43张含非透明像素；整屏即时命令整窗、跨章整窗、普通/额外减少动效拖动后和重开均有正文。当前巨段TXT深色孤立图满屏文字；不追认旧留白成因或全部真机样书。分页孤立WKWebView PNG仍RGBA全0，另有完整EPUB整窗正文；旧Build15–19图片名来自本轮实际CI，不追认历史失败。

两段实际UI视频全时段1秒总览已看：新增即时正反39.76秒、原整屏双模式81.30秒。其余6阅读/5书库视频只保留，未宣称全13段逐段复核。新即时视频31.5–38.8秒保留的36原始VFR帧已看，可见3/4段与6/7段六次交替，最后回到原处，保护画面未一直盖住正文。旧整屏视频所选两个PTS区间另有99和15原帧，99中前52为可见位移正反翻屏、后47为设置弹层；15为另一组即时正反。共150原帧全部看，其中103为阅读翻屏正文，未见全空正文帧；无fps重采样/插帧。墨迹计数只定位人工检查，不单独当验收。

旧整屏视频的所选原始PTS在设置弹层前有回退，已在frames.json记录；不将PTS直接映射XCTest/真实墙钟，也不将这些原帧数量当手机FPS。200ms是源码保留上限意图，实际切换观感/响应需真机。本轮覆盖动作未复现Build19记录中的整段空白，属于上游原生保护思路下的局部改进，不声明WebKit根因修复、所有翻屏无空帧或完整设备通过。2次XCTest idle通知、系统RunningBoard/AppIntents诊断保留，画面保护warning为0，源编译warning/error另核0。

真实系统Reduce Motion、深色整屏过渡、VoiceOver/增强对比度/旋转、普通签名/TrollStore、手机等待感/触摸接管/FPS/耗电仍未验收。M4整体未完成。

普通签名/TrollStore、手机响应/FPS/耗电与真实系统Reduce Motion/可访问性/旋转继续单列。自动慢滚、回看返回、续读提示、字体导入等仍后续；人物/境界卡留M5查询层章节门槛。M4整体未完。

以下Build19及更早为历史。

## Build19 当前切片（2026-10-16）

Build19候选安装包与原创样书包已生成，原生反向短空帧仍待定位/真机核验。504编译源blob、823维护文件清单、33新旧交付包及九份备份已核，所有原路径及原HEAD/空index保持；完整CI与下载已结束，最终保存/远端tip核验见build/ci/38843884440/final-preservation-check.json。交接HANDOFF.md。

Build19上下整屏通过[完整CI38843884440](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38843884440)，实际编译源`e1eee79f1dfac3f61b642c1f4e7f9bc1671fb77f`。Linux/macOS各122Core，iOS106/106（94集成+12真正UI）、失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release19/min16。每平台四长TXT Release探针、真实三份六pins锁和504源码blob已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不是编译。

用户认可Build18基本自用/观感。本轮沿用原生灰绿层次，菜单/手感增加“上下整屏”：既有有界跨章容器用原生松手目标停稳，90%有效高度留少量重叠，小拖回位、长拖可跨多个整屏，快速短甩不因惯性连冲多屏。正文上下30%点按/菜单上下按钮翻屏，中央40%仍呼出菜单；Readium先处理链接/选择。显式翻屏在手势/惯性/原生动画期间防重入，减少动效点按立即应用、直接手指操作仍原生跟手。连续/整屏互换只改输入策略，保持同一正文，模式/外观/完整位置分别保存。旧interaction-v1缺字段兼容、不合法类型和不一致组合报错保留；不支持布局仍分页且保留偏好。两个维护Vendor文件与UPSTREAM合同/hash同步，无原书/schema3/Locator/reading-v1/JS bundle/六pins/工具/工作流变更。参考及取舍READING_SCREEN_DESIGN.md。

安装`build/XianxiaReader-VerticalScreen-Build19.ipa` / SHA256 `213ec780735bc396f95749a1770fa4558b3d534b9d7077df4fb1bd47ecfa4151`；原创样书测试包`build/XianxiaReader-VerticalScreen-Build19-TestKit.zip` / SHA256 `c80a3b0372c54452964e259432a0e9e1856ef79c8f021127db439a9b93e87332`。正常覆盖更新保留书库，+菜单确认0.0.1 (19)。31旧包+2新包hash、ZIP CRC/内部IPA/原创Samples-Evidence-Cover和6张本轮Preview核过。入口阅读方式→上下整屏，可随时切回连续滚动/左右翻页。

本轮41张原生截图全部复核，40张含非透明像素；三模式入口、上下箭头、普通/额外减少动效的设置与拖动后/重开图片文字清楚，跨章整窗可见前章长段185–199和第二章标题/正文。当前巨段TXT深色孤立图已见满屏正文；这是本轮光栅证据，不能追认旧留白捕获或宣称手机/全部巨段问题根因已修复。分页孤立WKWebView图仍RGBA全0，另有本轮完整EPUB整窗可见正文。

两段实际UI录屏全时段1秒总览已看：新整屏测试189.14秒、既有额外减少动效手势17.90秒；其余5阅读/5书库录屏只保留，不声称逐段复核。新整屏视频33.50–35.90及40.00–42.40秒共96张20fps时间采样已看，未插帧，VFR重复不等于手机FPS。可见拖动时收菜单、原生位移后停稳、菜单恢复与按钮正反翻屏；但42.05–42.20秒采样可见正文短时空白后恢复，显式反向切换的无空帧视觉门槛未通过，需真机复现/定位，不能归因成单纯采集问题。录屏时间与XCTest活动时间未建立一一映射，不把同一片段虚称为普通/减少动效两路完整连续过程；两路状态与操作分别有测试及原生PNG证据。

日志2次XCTest动画结束通知缺失，完整日志/回执保留；新测试t126.80进入idle、t186.84通知缺失、t186.85才请求下一次tap，不算App收到点击后卡60秒。系统RBS/扩展退出、AppIntents等诊断与源编译warning/error分别记录。系统真实Reduce Motion/VoiceOver/增强对比度/旋转/普通签名/TrollStore、手机响应/FPS/耗电仍待测。此为素材复核完成，未宣布视觉全通过或M4整体验收。

系统真实减少动效/VoiceOver/增强对比度/旋转/普通签名/TrollStore、手机手感/FPS/耗电继续分列；本轮TXT满屏光栅不追认历史留白根因或全部真机样书，分页孤立图仍全透明。反向翻屏短空帧明确未验收，先真机复现/定位再推进下一切片。自动慢滚/卷页/触感反馈/字体文件导入等仍后续，M4整体未完。报告M4_SCREEN_VALIDATION_REPORT.json。

第一候选d4908df6/CI38842135511最终由Agent主动取消；实际各122Core/四Release探针通过，94集成中93过，1新增跨章case在初始jump报navigationFailed，随后3书库UI过、第4书库UI中取消，ReaderUI/严格Release未完成。取消前审阅另发现反向长拖落点算法缺陷，已按离手位置相邻格修正并加双向断言。第二候选c847210d/CI38843421879因补新测试初始DOM/原生位置准备主动取消，实际Linux122/四探针通过，Apple停在XcodeGen依赖构建，macOS/iOS/Release未开始；生产与第三候选相同。第三候选仅为三个新增渲染case加既有cover probe/20秒准备，所有原断言不改。两轮完整取消日志/xcresult（首轮）/诊断ZIP和源快照保留；navigationFailed唯一根因不据猜测追认。

以下Build18及更早条目为历史。

## Build18 当前切片（2026-10-16）

Build18交付包与交接已生成；504编译源blob、801维护文件清单、31新旧包及八份备份核过，全部开始路径与原HEAD/空index/M2/M3保持。CI/下载均结束；真实编译源与其后纯文档快照分列，最终保留/远端核验见build/ci/38835963502/final-preservation-check.json。

Build18面板层次与按压反馈通过[完整CI38835963502](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38835963502)，实际编译源`76ede6b266304749db37029b66d89b0d27eb39e2`。Linux/macOS各119Core，iOS100/100（89集成+11真正UI），失败/跳过0，test/export/summary/recording退出0；无签名iPhoneOS arm64 Release18/min16、系统SQLite/真实三锁/每平台四长TXT Release探针与504源码blob核过。Windows423语法新增0/54 pristine限制、17工具测试通过；语法不是编译。

用户认可Build17基本自用/整体观感，反馈部分扁平生硬。本轮保留灰绿风格，原生菜单增加实色浮层、轻边光/双层小投影，设置分组补图标层次。投影仅作用于单一背景fill，文字/图标不投影；标准ButtonStyle提供按下0.975/0.5pt微沉和短回弹。普通/减少动效实际长按松手每次只激活一次与44pt命中区域已回归。系统/用户/额外减少动效禁缩放位移/过渡但保留即时底色，增强对比度加强边线。菜单仍10pt短幅，spring response 0.3/dampingFraction 0.92，不把response等同完整动画时长，不重排正文。仅App三样式文件、UI测试和project.yml版本变更；Core/Adapter/Vendor/锁/scripts/workflow/原书/schema3/完整Locator与成功Build17保持。参考Apple公开ButtonStyle/Motion/Materials原则并核iOS13 API适用最低iOS16，不引入LiquidGlass新系统API、外部代码或素材；设计READING_DEPTH_DESIGN.md。

安装`build/XianxiaReader-ReadingDepth-Build18.ipa`，SHA256 `8ada416c25c47fdec80fec0735c9db6c69f7d5584f465589981413c991011656`；原创样书测试包`build/XianxiaReader-ReadingDepth-Build18-TestKit.zip`，SHA256 `7d30ab3e4d34c14bd65ae46b787dc6e612f1273e893f892632ec0a22973aa5ac`。正常覆盖更新保留书库，+菜单确认0.0.1 (18)。原29包与本轮2包/ZIP CRC/内部IPA/原创Samples-Evidence-Cover及六张本轮Preview核过。手机手感/FPS、普通签名/TrollStore与完整可访问性矩阵单列；卷页/上下整屏/自动慢滚/触感反馈和字体文件导入等仍后续，M4整体未完。报告M4_DEPTH_VALIDATION_REPORT.json。

本轮32张实际原生截图已检查，31张有非透明像素；三组Build17前后对照与三组被拒收候选对照已看，白菜单不再有文字/图标投影灰晕，菜单轮廓投影与设置层次清楚。实际按压42.16秒、正常手势116.71秒、额外减少动效16.82秒三视频全时段1秒总览已看；普通/减少动效两按压窗口各20裁切帧、正常/减少动效菜单恢复各16帧，共72实际20fps时间采样已看，无插帧且可有VFR重复。普通约11.15秒出现按压色/微沉，11.35秒110变120，松手迅速收敛；减少动效约33.15秒按下色、33.35秒变120，无新缩放过渡。正常菜单约16.10–16.40秒短幅恢复，额外减少动效约13.05秒直接显示，正文未因菜单重排。其余3阅读/5书架视频只保留，未宣称本轮逐段审阅；三段选定视频不等于全部11段审阅。

长静帧/系统桌面不当流畅度证据：日志3次XCTest动画结束通知缺失；本例t19.16等idle、t79.20通知未收到、t79.22才发下一次tap，不能算App收到点击后卡60秒，根因/手机响应未建立，专门回执m4-depth-build18-xctest-idle-diagnostics.json。分页孤立WKWebView PNG又RGBA全0，不是可见黑页证明；实际新EPUB整窗有完整文字，DOM/原非零字180%/完整DOM重开回归通过仍不等价该孤立光栅验收。巨段TXT孤立图仍顶部约两行、其余留白，满页成因/手机结果继续未验收。系统真实Reduce Motion/增强对比度/VoiceOver/旋转/其他设备/普通签名/TrollStore、手机FPS/耗电/响应仍单列。旧Build15–17命名图片均来自本轮实际CI，不追认历史失败或第二轮视觉拒收。

首候选f957f465/CI38831994670因新增样式modifier与既有ReaderSurface重名而Swift编译失败，iOS零执行/test65，无Release/IPA；第二候选750191d0/CI38833282829自动100/100及Release18通过，但原生对照发现文字/图标投影灰晕，明确视觉拒收、未生成用户交付包。第三候选仅将两层投影移到单一背景fill，完整重新构建与本轮原生复核通过。首轮失败、第二轮视觉拒收、全部原始日志/xcresult/素材和候选IPA继续保留；回执m4-depth-build18-first-failure.json与m4-depth-build18-second-native-rejection.json，不以最终通过追认前两轮。

以下Build17及更早条目保留历史。

## Build17 当前切片（2026-10-16）

Build17阅读手感第一片通过[完整CI38775427080](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38775427080)，实际编译源`63134f1aa4787e3067453e2fe8b15bf17b449ca2`。Linux/macOS各119Core，iOS99/99（89集成+10真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release17。Windows423Swift语法新增0/54 pristine限制、17工具测试通过；语法不是编译。四长TXT Release探针/平台、三份真实六pins锁和504运行/验证源码blob已核。原生截图/手势录屏/连续帧与手机手感/FPS、普通签名/TrollStore设备结果分列。

保留Readium原生跟手翻页/回位和真正跨章连续阅读；滑动时可收起菜单、中央轻点显示，菜单0.2秒/10pt克制过渡。设置新增“手感”：记住阅读方式、滑动收菜单、减少动效。独立interaction-v1.json在BookFileStore actor上有界读/原子保存、写入顺序/错误重试；打开先恢复偏好，支持时走既有DOM锚点模式切换，不支持布局保留用户偏好而使用适用分页。用户/系统减少动效作用于点按导航和自定义菜单，手指保持原生跟手；DEBUG额外减少请求只在运行时合并。分页命令防重入/关闭身份保护；连续模式禁误横滑切资源，按屏命令仍用Readium原路径，不宣称动画期间完整节流。Vendor仅普通分页通知补齐局部锚点及provenance；不改JS bundle/schema3/原书/完整Locator格式/远程锁或依赖版本。

首候选8c548dce/CI38760598889为97/99，WebKit测试hook返回JS函数不支持、普通拖动发生在加载spinner时未收菜单，严格test65无IPA，原旧回归通过。实际两段失败/减少动效录屏总览确认准备门槛过早；第三候选只修正hook末尾null和真实可读样本文字等待，原手势/10秒菜单断言及旧定位回归保持。c9bae997/CI38765644376的原生滚动回调实验经录屏证据后Agent主动取消，停在LinuxRelease探针，Apple未运行；七文件ZIP/Git候选保留，产品路径撤回，不能把未证pointer取消假设当根因。第三候选1d1f2763/CI38765962839新动效全部过、两旧回归失败97/99，修正普通分页通知丢DOM范围与设置滚错底层连续阅读区，第四轮50ecf291/CI38771271584全89集成通过，2UI准备失败：顶部多余下滑dismiss与切模式未等原生就绪；最终只修测试准备，原断言不放宽。全部失败/取消日志/xcresult/素材与下载限制保留，设计READING_MOTION_DESIGN.md。

安装`build/XianxiaReader-ReadingMotion-Build17.ipa` / SHA256 `9d2af110466c03746e67929da58118ad60b4296f8001e408c4b2fb8ac29fa53e`；原创样本测试包`build/XianxiaReader-ReadingMotion-Build17-TestKit.zip` / SHA256 `5d09ad4d3536c644533e3a7b324561f8ace14cea0ba5a7fb8d119ec95de3e81b`。正常覆盖更新保留书库，+菜单确认0.0.1 (17)。原27包与本轮2包逐hash、测试ZIP CRC/内部IPA/原创Samples/Evidence/Cover/6张本轮真实Preview核过。仿真卷页/上下整屏/自动慢滚/触感反馈尚未实现，按独立后续切片推进；字体文件导入等M4内容仍后续，M4整体未完。报告M4_MOTION_VALIDATION_REPORT.json。

本轮24张实际原生截图已复核，全部非透明；分页EPUB深灰180%重排快照与新增EPUB整窗文字均已实际可见，旧透明采集不追认。巨段TXT孤立快照仍仅顶部约两行/下方留白，满页成因与手机结果仍未验收；普通TXT实际UI录屏有整页正文。正常65.60秒/额外减少动效16.54秒两段新手势视频全时段1秒总览，以及正常收菜单21帧/中央恢复20帧、减少动效跟手横拖17帧/恢复20帧共78实际20fps时间采样已看，无插帧且允许VFR重复，不当手机FPS。正常约18.00–18.20秒菜单短渐退同时正文原生上滑，约22.10–22.30秒中央恢复，正文视口未因菜单重排；额外减少动效约13.00秒菜单直接出现且保留手指横拖。手感三组/关闭自动收起/减少动效开关/连续模式重开可读；重启间31–46秒系统桌面不作阅读证据。其余3段阅读与5段书架原生视频只保留，未宣称本轮逐段审阅。系统真实Reduce Motion/VoiceOver/旋转/其他设备、普通签名/TrollStore、手机手感/FPS/耗电仍待测。

以下Build16及开发中条目保留历史，当前状态以上述Build17为准。

## Build17 最新实际检查点（2026-10-16）

第五候选63134f1aa4787e3067453e2fe8b15bf17b449ca2/CI38775427080现API completed/success，完整日志已核89集成+10UI零失败、test/export/summary/recording均0及Release17构建成功；完整诊断素材/锁/性能摘要/源码hash联合核验和原生录屏复核仍进行，尚未生成用户交付包。下面各轮条目保留历史，实时断点见HANDOFF.md。

更新时间：2026-10-16（Asia/Shanghai）

## Build17 阅读手感（当前恢复点）

用户认可Build16界面，授权阅读动效方案；仅记基本自用/视觉反馈，不扩写手机FPS或其他设备验收。本轮首片为手感偏好/阅读方式保存、被动滑动收菜单、菜单短过渡、统一减少动效及连续防误横滑。首候选8c548dce/CI38760598889实际失败97/99：各119Core/四长TXT Release探针与旧iOS回归通过，新WebKit测试返回函数不支持和正常拖动未收菜单失败，严格test65阻止IPA。完整诊断下载/修正中，不能写成已交付。卷页/上下整屏/自动慢滚为后续切片；M4整体未完。设计READING_MOTION_DESIGN.md，恢复点HANDOFF.md。

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | 自动门槛通过 | 编译/Core/iOS/Release/真实IPA |
| M1 基础 EPUB | 完整自动门槛通过，用户确认连续阅读与重开位置可用；可继续既定路线 | 未逐项确认的原书图像、其他设备/旋转/性能继续单独记录 |
| M2 TXT | Build9 ANSI/范围缓存各80Core/58iOS/Release通过；Build8手机基础确认 | Build9自用反馈正常；个别编码/其他设备矩阵单列 |
| M3 完整书库 | 完整自动门槛及Build14基本自用通过 | 自用阶段收口，其他设备与实测性能单列 |
| M4 设置与主题 | Build18基本自用认可；Build20整屏局部保护自动/选定原生动作通过，完整手机矩阵待核 | 字体导入等后续，整体未完 |
| M5 性能 | 未开始 | 百万字/数千章基线 |

## Build16 当前切片

交付/交接收尾已核：501编译源blob、756维护文件清单、27新旧包及四份恢复备份保持，原HEAD/index/M2/M3未动；当前无遗留CI/下载任务。真正编译源ce5bde4d与其后纯文档tip分列，详见HANDOFF和build/ci/38748113867/final-preservation-check.json。分页透明快照与巨段TXT满页仍为明确验证限制。

Build16原生阅读菜单/设置界面通过[完整CI38748113867](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38748113867)，真正编译源`ce5bde4d9d73e6979265a7b1f1bdf0f92d318970`。Linux/macOS各115Core、iOS93/93（85集成+8真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release16。原四长TXT Release探针/平台、三份真实六pins锁及501源码blob已核，原90项iOS和全部旧断言保留。Windows420Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是编译。原生图片/成功case视频/连续采样与源码编译、普通设备/TrollStore、手机FPS分别记录。

阅读菜单使用浅色/深色灰绿实心卡片，分开章节进度、翻页和目录/书签/搜索/设置四入口；阅读方式菜单切左右翻页/上下连续滚动。阅读设置分“外观/排版”，主题/字体/字号与段落控件分别成组，44pt加减按钮与窄空间重排。五阅读底色/柔和深色正文、全局保存/重开/错误重试、原书样式/固定布局禁用规则保留。UI之外，旧分页回归反复失败后按官方3.11 needsInvalidation合同将字号重排并入原失效路径，使注入CSS/cache重建与动态CSS互斥；纯换色/连续模式保持动态路径。两维护Vendor文件/provenance与有界无正文诊断更新，新增真实WebKit动态调用计数回归。快速连发路径另在Adapter采样前过滤取消/旧请求并保留await后检查，普通分页采样使用官方spreadLoaded边界，完整continuous bootstrap等待仍只用于连续加载。原非零文字/180%/重开断言不变。Core/ReadingInterfaces/schema3/原件/六pins/JS bundle/Locator协议保持，不升级引擎版本，所有旧集成回归继续通过。

参考Readest真实revision cc236be49a6e3b2c2c0763e7096c36efe631e4b2的层级/留白/克制色彩，采用项目自己的原生SwiftUI实现，无外部源码/美术/依赖复制。Foliate仅阅读官方文档，其截图抓取超时未作视觉验收依据；差异、链接与取舍见READING_UI_DESIGN.md。

原生复核回执`Documentation/ValidationLogs/m4-polish-build16-native-review.json`，18图逐项检查（17图有非透明像素；1张分页EPUB全透明），3段59.55/50.38/18.26秒视频全时段1秒总览已看，正常sheet弹出23帧及减少动效请求分组切换22帧已看。本轮浅/深色菜单、模式选择、分组/原书开关/重开均可读；旧Build15命名的附件来自本轮实际测试，保留原名。连续帧是实际视频时间采样，可能重复，无插帧，不当手机FPS。额外Reduce Motion请求不设置系统偏好，系统分段/sheet仍可有原生动画；中央点击菜单淡入淡出尚未独立采样。appearance录屏25–43秒处为退出/重启间的系统桌面，不作阅读动效证据。

明确限制：巨段TXT隔离快照仅顶部文字、下方留白原因未确认；分页EPUB截图RGBA所有通道均0，像素全透明，不是可见黑页证据，采集/绘制就绪与真实整窗显示仍须确认。DOM/字号/非零原文字/3px重排和重开回归通过，不等价完整光栅页面验收。用户Build15“没问题 可以继续”仅按基本自用记录；手机分页EPUB和巨段TXT满页、大字体/VoiceOver/旋转/耗电继续单列。

安装`build/XianxiaReader-ReadingUI-Build16.ipa` / SHA256 `c55b94177e8ee3f7f9ea3ba50dd93cf49f67b784cc02b5994905c04b8bdd2638`；原创样本测试包`build/XianxiaReader-ReadingUI-Build16-TestKit.zip` / SHA256 `182f23473f89cded7c124324af411b30fd18593200c8b580c7f69f402a87821d`，附6张本轮原生浅深色Preview图。正常覆盖更新保留书库，+菜单确认0.0.1 (16)。新旧27包、ZIP CRC/内部IPA/原有样本/Preview hash已核。Build16手机待测；M4整体未完，字体文件资产导入/单书覆盖/独立四边距/字距字重/亮度/音量键/阅读方式跨启动保存仍后续，M5设备性能单列。报告M4_POLISH_VALIDATION_REPORT.json。

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-first-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-second-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-third-failure.json

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

