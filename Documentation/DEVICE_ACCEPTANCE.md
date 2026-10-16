# 真机阅读验收

## Build22 当前切片（2026-10-16）

Build22回看返回通过[完整CI38871744221](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38871744221)，实际编译源`3cb1d220f324303a979d6dee5c6803f1c9a1bc38`。Linux/macOS各127Core、iOS124/124，失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release22/min16。三份六pins锁、507源码blob、每平台四长TXT Release探针已核。Windows426语法新增0/54既有语法限制、17工具通过；语法不是编译。

目录、书签或搜索跳转后显示轻量“回到跳转前/留在此处”小条，沿用灰绿浅深色表面/44pt按钮，160ms淡入淡出尊重减少动效。连续查看多个位置保留最初完整文字锚点，成功返回/留在此处清除；失败保留可重试。进度仍保存当前所在处，后台/关闭不隐式返回，重开当前实际进度；临时返回点会话内单个、不跨关闭保存。慢滚跳转前暂停，返回不自动运行。普通翻页/拖动/正文链接暂不创建返回记录。

ReadingInterfaces完整位置capture→Adapter有界DOM锚点；Vendor既有采样仅补Bool成功和取消校验，布局/JS/依赖锁不变。每个await后核open/request/navigator身份，重复跳转拒绝，旧请求不能清新session。原完整EPUB Locator/TXT byte+UTF16和12资源上限保持，无新Core/schema/正文缓存。受改测试文件中57个原测试主体保持，新增8项回归（4生命周期+真实EPUB双模式/TXT各1+2真正UI）；实际取舍见READING_RETURN_DESIGN.md。

安装`build/XianxiaReader-ReadingReturn-Build22.ipa` / SHA256 `97760b91f7d5e15950083b9b2116d8a9d1e1a6e2903542a8cc39b902e56b01c9`；原创样书包`build/XianxiaReader-ReadingReturn-Build22-TestKit.zip` / SHA256 `55e7496dc26bf7a7459894a1fc8be93773bce71792323e2e9a709b54c2f618d2`。正常覆盖更新保留书库，+菜单确认0.0.1 (22)。37旧包+两新包、ZIP内部IPA/原创材料/10原生Preview核过。

原生复核范围：本轮62张原生PNG/11表全部复核，alpha全255（含新增EPUB连续/分页与TXT完整位置3张、新返回UI7张）；三段实际UI录屏138.16/36.24/28.25s的完整1秒总览15表及四窗口126个原始VFR帧/12表已逐张看过，PTS倒退0、无插值。浅深色单返回条、返回/留在此处/书签与搜索、重开当前第二章和原减少动效退出菜单在这些素材中符合语义；普通动效淡入淡出、额外减少动效即时控制保留，选定序列通过。跳转存在明确spinner；目录/书签/搜索sheet沿用浅色；启动白页/测试清理主屏不作阅读画面或性能证据。17条真UI原视频均保存，本轮只复核其中3条，不宣称全部视频/设备矩阵通过。

普通签名/TrollStore、真实系统Reduce Motion/VoiceOver/增强对比度/旋转、手机响应/FPS/功耗与全样书矩阵仍待核。自动检查/Swift编译/模拟器阅读/普通设备/TS分列，M4整体未完成；历史各轮限制不追认。

首轮3637dac/CI38866913465实际123/124（旧115过/1失败、新8全过），原减少动效UI退出慢滚后reader.mode未命中。完整1.13GB诊断/原summary/失败录屏留存；根因未确认。当前完整重试的507运行源码object与首轮相同，仅文档不同；不把重试成功称根因修复。用户已反馈Build21手机减少动效退出慢滚能正常回到菜单，仅接受该具体行为，不扩大为Build22或完整设备矩阵。既有系统目录/书签/搜索sheet的完整深色样式仍需后续统一，本片主题复核仅覆盖返回条及正文。

以下Build21及更早为历史。

## Build21 当前切片（2026-10-16）

Build21自动慢滚通过[完整CI38861273421](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38861273421)，实际编译源`891114e252758cf93cb2d0158900badae0f7bb20`。Linux/macOS各127Core、iOS116/116（101集成+15真正UI），失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release21/min16，三份六pins锁、507源码blob及每平台四长TXT Release探针已核。Windows426语法新增0/54 pristine限制、17工具通过；语法不是编译。

菜单“慢滚”进入现有连续正文，初始静止，再点开始；0.5—6.0屏/分/0.5步长，默认1.5。小控制条支持开始/暂停/调速/退出，沿用原主题表面。轻触正文即暂停，链接/选择/拖动保持Readium处理；后台/关闭/新书/跳转/排版/模式/旋转停，回来不自动跑；只保存速度。系统/应用/阅读减少动态效果或旁白开启时停用，明确说明。运行/等待临时保持亮屏，暂停等恢复原值。加载边界停住等待，失败沿用原可见重试，书尾结束。

Core纯时钟按真实时间与小数位移，>250ms间隙直接丢弃；Adapter短时CADisplayLink弱目标/session UUID，ReadingInterfaces可选能力，Vendor只在已有ready窗口内移动，最大12资源/完整DOMRange和TXT字节锚点保持。约每秒串行完整位置采样，暂停/保存补最后位置；每帧不查DOM、不写SQLite、不截屏。受改测试文件中的49个原测试主体保持，新增5Core+6集成+2真正UI。设计与官方/成熟实现取舍READING_AUTOSCROLL_DESIGN.md。

安装`build/XianxiaReader-AutoScroll-Build21.ipa` / SHA256 `be07227e9ce74eb1d4e65095dbe65ffe702ba50523f6bbf36079bebad2953219`；原创样书测试包`build/XianxiaReader-AutoScroll-Build21-TestKit.zip` / SHA256 `fa90c2d621768020b630b002d11c32006870fbd9f47321080dbd12c0f00d5c9a`。正常覆盖更新保留书库，+菜单确认0.0.1 (21)；35旧包、两新包/ZIP内部IPA与原创样书/8原生Preview已核。

原生复核范围：52张实际PNG逐图查看；两条新UI录屏总览（51.21s慢滚/15.76s应用减少动效停用）及418张原始VFR帧（浅色移动122、触摸暂停89、深色暂停207）逐帧联系表已核。选定已就绪正文片段持续可见、逐步上移后停稳，后台返回和非零位置重开静止，控制条沿用浅深色主题。减少动效图/视频尚处章节加载，仅验停用提示；其余8条reader/5条library原视频保留而未本轮逐看。本轮分页孤立WK图已有正文，历史间歇捕获成因仍未确认。所选片段未见整窗正文空白，不推广为全视频/全部机型或手机FPS/功耗结论。

普通签名/TrollStore、真实系统Reduce Motion/VoiceOver/增强对比度/旋转、手机低速/120Hz/亮屏与功耗/实际流畅度仍未验收。自动检查/Swift编译/模拟器阅读/普通设备/TrollStore分列，M4整体未完。旧Build20/19证据与设备限制保留，不追认全矩阵或WebKit根因修复。

以下Build20及更早为历史。

## Build20 当前切片（2026-10-16）

Build20即时整屏翻屏画面保护通过[完整CI38850709820](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38850709820)，实际编译源`0b1fe87704713e668231ad36ab73ceb13bd3b077`。Linux/macOS各122Core、iOS108/108（95集成+13真正UI）、失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release20/min16，三份六pins锁、504源blob及每平台四长TXT Release探针已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不等于编译。

沿Readium3.11现有issue737/PR763方案，仅给上下整屏的显式无动画翻屏保留一个原生视口画面200ms；底层位置立即更新，无新增位移/淡入，视觉等待有限且需手机验证。新拖动立即接管，模式/resize/跳转/关闭清理，保留期间拒绝新显式命令且不排队；无每帧截图/PNG编码/新正文缓存，原直接手势、连续模式、DOM/完整Locator与依赖锁保持。新增真实容器清理/重入与真正UI重复反向录屏，26个受改文件内原测试主体保持。设计READING_SCREEN_STABILITY_DESIGN.md，候选特色READING_FEATURE_IDEAS.md。

安装`build/XianxiaReader-ScreenStability-Build20.ipa` / SHA256 `ae6897c0e2e0387b1550fce67570d9bcbd57a7eb09f5d1330007f8baa080cf27`；原创样书测试包`build/XianxiaReader-ScreenStability-Build20-TestKit.zip` / SHA256 `2e9381d77aca6c1762dab1f14d002bcae538333d84e02d04a37c692701120319`。正常覆盖更新保留书库，+菜单确认0.0.1 (20)；原33包与两新包/原创样书/Preview/ZIP内部IPA均核。原Build19问题证据不追认，详情M4_SCREEN_STABILITY_VALIDATION_REPORT.json与m4-screen-build20-native-review.json。

本轮44张原生PNG均已看，43张含非透明像素；整屏即时命令整窗、跨章整窗、普通/额外减少动效拖动后和重开均有正文。当前巨段TXT深色孤立图满屏文字；不追认旧留白成因或全部真机样书。分页孤立WKWebView PNG仍RGBA全0，另有完整EPUB整窗正文；旧Build15–19图片名来自本轮实际CI，不追认历史失败。

两段实际UI视频全时段1秒总览已看：新增即时正反39.76秒、原整屏双模式81.30秒。其余6阅读/5书库视频只保留，未宣称全13段逐段复核。新即时视频31.5–38.8秒保留的36原始VFR帧已看，可见3/4段与6/7段六次交替，最后回到原处，保护画面未一直盖住正文。旧整屏视频所选两个PTS区间另有99和15原帧，99中前52为可见位移正反翻屏、后47为设置弹层；15为另一组即时正反。共150原帧全部看，其中103为阅读翻屏正文，未见全空正文帧；无fps重采样/插帧。墨迹计数只定位人工检查，不单独当验收。

旧整屏视频的所选原始PTS在设置弹层前有回退，已在frames.json记录；不将PTS直接映射XCTest/真实墙钟，也不将这些原帧数量当手机FPS。200ms是源码保留上限意图，实际切换观感/响应需真机。本轮覆盖动作未复现Build19记录中的整段空白，属于上游原生保护思路下的局部改进，不声明WebKit根因修复、所有翻屏无空帧或完整设备通过。2次XCTest idle通知、系统RunningBoard/AppIntents诊断保留，画面保护warning为0，源编译warning/error另核0。

真实系统Reduce Motion、深色整屏过渡、VoiceOver/增强对比度/旋转、普通签名/TrollStore、手机等待感/触摸接管/FPS/耗电仍未验收。M4整体未完成。

普通签名/TrollStore、手机响应/FPS/耗电与真实系统Reduce Motion/可访问性/旋转继续单列。自动慢滚、回看返回、续读提示、字体导入等仍后续；人物/境界卡留M5查询层章节门槛。M4整体未完。

以下为历史。

## Build19 当前切片（2026-10-16）

Build19上下整屏通过[完整CI38843884440](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38843884440)，实际编译源`e1eee79f1dfac3f61b642c1f4e7f9bc1671fb77f`。Linux/macOS各122Core，iOS106/106（94集成+12真正UI）、失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release19/min16。每平台四长TXT Release探针、真实三份六pins锁和504源码blob已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不是编译。

用户认可Build18基本自用/观感。本轮沿用原生灰绿层次，菜单/手感增加“上下整屏”：既有有界跨章容器用原生松手目标停稳，90%有效高度留少量重叠，小拖回位、长拖可跨多个整屏，快速短甩不因惯性连冲多屏。正文上下30%点按/菜单上下按钮翻屏，中央40%仍呼出菜单；Readium先处理链接/选择。显式翻屏在手势/惯性/原生动画期间防重入，减少动效点按立即应用、直接手指操作仍原生跟手。连续/整屏互换只改输入策略，保持同一正文，模式/外观/完整位置分别保存。旧interaction-v1缺字段兼容、不合法类型和不一致组合报错保留；不支持布局仍分页且保留偏好。两个维护Vendor文件与UPSTREAM合同/hash同步，无原书/schema3/Locator/reading-v1/JS bundle/六pins/工具/工作流变更。参考及取舍READING_SCREEN_DESIGN.md。

安装`build/XianxiaReader-VerticalScreen-Build19.ipa` / SHA256 `213ec780735bc396f95749a1770fa4558b3d534b9d7077df4fb1bd47ecfa4151`；原创样书测试包`build/XianxiaReader-VerticalScreen-Build19-TestKit.zip` / SHA256 `c80a3b0372c54452964e259432a0e9e1856ef79c8f021127db439a9b93e87332`。正常覆盖更新保留书库，+菜单确认0.0.1 (19)。31旧包+2新包hash、ZIP CRC/内部IPA/原创Samples-Evidence-Cover和6张本轮Preview核过。入口阅读方式→上下整屏，可随时切回连续滚动/左右翻页。

本轮41张原生截图全部复核，40张含非透明像素；三模式入口、上下箭头、普通/额外减少动效的设置与拖动后/重开图片文字清楚，跨章整窗可见前章长段185–199和第二章标题/正文。当前巨段TXT深色孤立图已见满屏正文；这是本轮光栅证据，不能追认旧留白捕获或宣称手机/全部巨段问题根因已修复。分页孤立WKWebView图仍RGBA全0，另有本轮完整EPUB整窗可见正文。

两段实际UI录屏全时段1秒总览已看：新整屏测试189.14秒、既有额外减少动效手势17.90秒；其余5阅读/5书库录屏只保留，不声称逐段复核。新整屏视频33.50–35.90及40.00–42.40秒共96张20fps时间采样已看，未插帧，VFR重复不等于手机FPS。可见拖动时收菜单、原生位移后停稳、菜单恢复与按钮正反翻屏；但42.05–42.20秒采样可见正文短时空白后恢复，显式反向切换的无空帧视觉门槛未通过，需真机复现/定位，不能归因成单纯采集问题。录屏时间与XCTest活动时间未建立一一映射，不把同一片段虚称为普通/减少动效两路完整连续过程；两路状态与操作分别有测试及原生PNG证据。

日志2次XCTest动画结束通知缺失，完整日志/回执保留；新测试t126.80进入idle、t186.84通知缺失、t186.85才请求下一次tap，不算App收到点击后卡60秒。系统RBS/扩展退出、AppIntents等诊断与源编译warning/error分别记录。系统真实Reduce Motion/VoiceOver/增强对比度/旋转/普通签名/TrollStore、手机响应/FPS/耗电仍待测。此为素材复核完成，未宣布视觉全通过或M4整体验收。

系统真实减少动效/VoiceOver/增强对比度/旋转/普通签名/TrollStore、手机手感/FPS/耗电继续分列；本轮TXT满屏光栅不追认历史留白根因或全部真机样书，分页孤立图仍全透明。反向翻屏短空帧明确未验收，先真机复现/定位再推进下一切片。自动慢滚/卷页/触感反馈/字体文件导入等仍后续，M4整体未完。报告M4_SCREEN_VALIDATION_REPORT.json。

第一候选d4908df6/CI38842135511最终由Agent主动取消；实际各122Core/四Release探针通过，94集成中93过，1新增跨章case在初始jump报navigationFailed，随后3书库UI过、第4书库UI中取消，ReaderUI/严格Release未完成。取消前审阅另发现反向长拖落点算法缺陷，已按离手位置相邻格修正并加双向断言。第二候选c847210d/CI38843421879因补新测试初始DOM/原生位置准备主动取消，实际Linux122/四探针通过，Apple停在XcodeGen依赖构建，macOS/iOS/Release未开始；生产与第三候选相同。第三候选仅为三个新增渲染case加既有cover probe/20秒准备，所有原断言不改。两轮完整取消日志/xcresult（首轮）/诊断ZIP和源快照保留；navigationFailed唯一根因不据猜测追认。

以下为历史切片。

## Build18 当前切片（2026-10-16）

Build18面板层次与按压反馈通过[完整CI38835963502](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38835963502)，实际编译源`76ede6b266304749db37029b66d89b0d27eb39e2`。Linux/macOS各119Core，iOS100/100（89集成+11真正UI），失败/跳过0，test/export/summary/recording退出0；无签名iPhoneOS arm64 Release18/min16、系统SQLite/真实三锁/每平台四长TXT Release探针与504源码blob核过。Windows423语法新增0/54 pristine限制、17工具测试通过；语法不是编译。

用户认可Build17基本自用/整体观感，反馈部分扁平生硬。本轮保留灰绿风格，原生菜单增加实色浮层、轻边光/双层小投影，设置分组补图标层次。投影仅作用于单一背景fill，文字/图标不投影；标准ButtonStyle提供按下0.975/0.5pt微沉和短回弹。普通/减少动效实际长按松手每次只激活一次与44pt命中区域已回归。系统/用户/额外减少动效禁缩放位移/过渡但保留即时底色，增强对比度加强边线。菜单仍10pt短幅，spring response 0.3/dampingFraction 0.92，不把response等同完整动画时长，不重排正文。仅App三样式文件、UI测试和project.yml版本变更；Core/Adapter/Vendor/锁/scripts/workflow/原书/schema3/完整Locator与成功Build17保持。参考Apple公开ButtonStyle/Motion/Materials原则并核iOS13 API适用最低iOS16，不引入LiquidGlass新系统API、外部代码或素材；设计READING_DEPTH_DESIGN.md。

安装`build/XianxiaReader-ReadingDepth-Build18.ipa`，SHA256 `8ada416c25c47fdec80fec0735c9db6c69f7d5584f465589981413c991011656`；原创样书测试包`build/XianxiaReader-ReadingDepth-Build18-TestKit.zip`，SHA256 `7d30ab3e4d34c14bd65ae46b787dc6e612f1273e893f892632ec0a22973aa5ac`。正常覆盖更新保留书库，+菜单确认0.0.1 (18)。原29包与本轮2包/ZIP CRC/内部IPA/原创Samples-Evidence-Cover及六张本轮Preview核过。手机手感/FPS、普通签名/TrollStore与完整可访问性矩阵单列；卷页/上下整屏/自动慢滚/触感反馈和字体文件导入等仍后续，M4整体未完。报告M4_DEPTH_VALIDATION_REPORT.json。

本轮32张实际原生截图已检查，31张有非透明像素；三组Build17前后对照与三组被拒收候选对照已看，白菜单不再有文字/图标投影灰晕，菜单轮廓投影与设置层次清楚。实际按压42.16秒、正常手势116.71秒、额外减少动效16.82秒三视频全时段1秒总览已看；普通/减少动效两按压窗口各20裁切帧、正常/减少动效菜单恢复各16帧，共72实际20fps时间采样已看，无插帧且可有VFR重复。普通约11.15秒出现按压色/微沉，11.35秒110变120，松手迅速收敛；减少动效约33.15秒按下色、33.35秒变120，无新缩放过渡。正常菜单约16.10–16.40秒短幅恢复，额外减少动效约13.05秒直接显示，正文未因菜单重排。其余3阅读/5书架视频只保留，未宣称本轮逐段审阅；三段选定视频不等于全部11段审阅。

长静帧/系统桌面不当流畅度证据：日志3次XCTest动画结束通知缺失；本例t19.16等idle、t79.20通知未收到、t79.22才发下一次tap，不能算App收到点击后卡60秒，根因/手机响应未建立，专门回执m4-depth-build18-xctest-idle-diagnostics.json。分页孤立WKWebView PNG又RGBA全0，不是可见黑页证明；实际新EPUB整窗有完整文字，DOM/原非零字180%/完整DOM重开回归通过仍不等价该孤立光栅验收。巨段TXT孤立图仍顶部约两行、其余留白，满页成因/手机结果继续未验收。系统真实Reduce Motion/增强对比度/VoiceOver/旋转/其他设备/普通签名/TrollStore、手机FPS/耗电/响应仍单列。旧Build15–17命名图片均来自本轮实际CI，不追认历史失败或第二轮视觉拒收。

首候选f957f465/CI38831994670因新增样式modifier与既有ReaderSurface重名而Swift编译失败，iOS零执行/test65，无Release/IPA；第二候选750191d0/CI38833282829自动100/100及Release18通过，但原生对照发现文字/图标投影灰晕，明确视觉拒收、未生成用户交付包。第三候选仅将两层投影移到单一背景fill，完整重新构建与本轮原生复核通过。首轮失败、第二轮视觉拒收、全部原始日志/xcresult/素材和候选IPA继续保留；回执m4-depth-build18-first-failure.json与m4-depth-build18-second-native-rejection.json，不以最终通过追认前两轮。

以下为旧切片历史。

## Build17 当前切片（2026-10-16）

Build17阅读手感第一片通过[完整CI38775427080](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38775427080)，实际编译源`63134f1aa4787e3067453e2fe8b15bf17b449ca2`。Linux/macOS各119Core，iOS99/99（89集成+10真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release17。Windows423Swift语法新增0/54 pristine限制、17工具测试通过；语法不是编译。四长TXT Release探针/平台、三份真实六pins锁和504运行/验证源码blob已核。原生截图/手势录屏/连续帧与手机手感/FPS、普通签名/TrollStore设备结果分列。

保留Readium原生跟手翻页/回位和真正跨章连续阅读；滑动时可收起菜单、中央轻点显示，菜单0.2秒/10pt克制过渡。设置新增“手感”：记住阅读方式、滑动收菜单、减少动效。独立interaction-v1.json在BookFileStore actor上有界读/原子保存、写入顺序/错误重试；打开先恢复偏好，支持时走既有DOM锚点模式切换，不支持布局保留用户偏好而使用适用分页。用户/系统减少动效作用于点按导航和自定义菜单，手指保持原生跟手；DEBUG额外减少请求只在运行时合并。分页命令防重入/关闭身份保护；连续模式禁误横滑切资源，按屏命令仍用Readium原路径，不宣称动画期间完整节流。Vendor仅普通分页通知补齐局部锚点及provenance；不改JS bundle/schema3/原书/完整Locator格式/远程锁或依赖版本。

首候选8c548dce/CI38760598889为97/99，WebKit测试hook返回JS函数不支持、普通拖动发生在加载spinner时未收菜单，严格test65无IPA，原旧回归通过。实际两段失败/减少动效录屏总览确认准备门槛过早；第三候选只修正hook末尾null和真实可读样本文字等待，原手势/10秒菜单断言及旧定位回归保持。c9bae997/CI38765644376的原生滚动回调实验经录屏证据后Agent主动取消，停在LinuxRelease探针，Apple未运行；七文件ZIP/Git候选保留，产品路径撤回，不能把未证pointer取消假设当根因。第三候选1d1f2763/CI38765962839新动效全部过、两旧回归失败97/99，修正普通分页通知丢DOM范围与设置滚错底层连续阅读区，第四轮50ecf291/CI38771271584全89集成通过，2UI准备失败：顶部多余下滑dismiss与切模式未等原生就绪；最终只修测试准备，原断言不放宽。全部失败/取消日志/xcresult/素材与下载限制保留，设计READING_MOTION_DESIGN.md。

安装`build/XianxiaReader-ReadingMotion-Build17.ipa` / SHA256 `9d2af110466c03746e67929da58118ad60b4296f8001e408c4b2fb8ac29fa53e`；原创样本测试包`build/XianxiaReader-ReadingMotion-Build17-TestKit.zip` / SHA256 `5d09ad4d3536c644533e3a7b324561f8ace14cea0ba5a7fb8d119ec95de3e81b`。正常覆盖更新保留书库，+菜单确认0.0.1 (17)。原27包与本轮2包逐hash、测试ZIP CRC/内部IPA/原创Samples/Evidence/Cover/6张本轮真实Preview核过。仿真卷页/上下整屏/自动慢滚/触感反馈尚未实现，按独立后续切片推进；字体文件导入等M4内容仍后续，M4整体未完。报告M4_MOTION_VALIDATION_REPORT.json。

本轮24张实际原生截图已复核，全部非透明；分页EPUB深灰180%重排快照与新增EPUB整窗文字均已实际可见，旧透明采集不追认。巨段TXT孤立快照仍仅顶部约两行/下方留白，满页成因与手机结果仍未验收；普通TXT实际UI录屏有整页正文。正常65.60秒/额外减少动效16.54秒两段新手势视频全时段1秒总览，以及正常收菜单21帧/中央恢复20帧、减少动效跟手横拖17帧/恢复20帧共78实际20fps时间采样已看，无插帧且允许VFR重复，不当手机FPS。正常约18.00–18.20秒菜单短渐退同时正文原生上滑，约22.10–22.30秒中央恢复，正文视口未因菜单重排；额外减少动效约13.00秒菜单直接出现且保留手指横拖。手感三组/关闭自动收起/减少动效开关/连续模式重开可读；重启间31–46秒系统桌面不作阅读证据。其余3段阅读与5段书架原生视频只保留，未宣称本轮逐段审阅。系统真实Reduce Motion/VoiceOver/旋转/其他设备、普通签名/TrollStore、手机手感/FPS/耗电仍待测。

以下Build16及开发中条目保留历史，当前状态以上述Build17为准。

## Build16 当前切片

Build16原生阅读菜单/设置界面通过[完整CI38748113867](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38748113867)，真正编译源`ce5bde4d9d73e6979265a7b1f1bdf0f92d318970`。Linux/macOS各115Core、iOS93/93（85集成+8真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release16。原四长TXT Release探针/平台、三份真实六pins锁及501源码blob已核，原90项iOS和全部旧断言保留。Windows420Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是编译。原生图片/成功case视频/连续采样与源码编译、普通设备/TrollStore、手机FPS分别记录。

阅读菜单使用浅色/深色灰绿实心卡片，分开章节进度、翻页和目录/书签/搜索/设置四入口；阅读方式菜单切左右翻页/上下连续滚动。阅读设置分“外观/排版”，主题/字体/字号与段落控件分别成组，44pt加减按钮与窄空间重排。五阅读底色/柔和深色正文、全局保存/重开/错误重试、原书样式/固定布局禁用规则保留。UI之外，旧分页回归反复失败后按官方3.11 needsInvalidation合同将字号重排并入原失效路径，使注入CSS/cache重建与动态CSS互斥；纯换色/连续模式保持动态路径。两维护Vendor文件/provenance与有界无正文诊断更新，新增真实WebKit动态调用计数回归。快速连发路径另在Adapter采样前过滤取消/旧请求并保留await后检查，普通分页采样使用官方spreadLoaded边界，完整continuous bootstrap等待仍只用于连续加载。原非零文字/180%/重开断言不变。Core/ReadingInterfaces/schema3/原件/六pins/JS bundle/Locator协议保持，不升级引擎版本，所有旧集成回归继续通过。

参考Readest真实revision cc236be49a6e3b2c2c0763e7096c36efe631e4b2的层级/留白/克制色彩，采用项目自己的原生SwiftUI实现，无外部源码/美术/依赖复制。Foliate仅阅读官方文档，其截图抓取超时未作视觉验收依据；差异、链接与取舍见READING_UI_DESIGN.md。

原生复核回执`Documentation/ValidationLogs/m4-polish-build16-native-review.json`，18图逐项检查（17图有非透明像素；1张分页EPUB全透明），3段59.55/50.38/18.26秒视频全时段1秒总览已看，正常sheet弹出23帧及减少动效请求分组切换22帧已看。本轮浅/深色菜单、模式选择、分组/原书开关/重开均可读；旧Build15命名的附件来自本轮实际测试，保留原名。连续帧是实际视频时间采样，可能重复，无插帧，不当手机FPS。额外Reduce Motion请求不设置系统偏好，系统分段/sheet仍可有原生动画；中央点击菜单淡入淡出尚未独立采样。appearance录屏25–43秒处为退出/重启间的系统桌面，不作阅读动效证据。

明确限制：巨段TXT隔离快照仅顶部文字、下方留白原因未确认；分页EPUB截图RGBA所有通道均0，像素全透明，不是可见黑页证据，采集/绘制就绪与真实整窗显示仍须确认。DOM/字号/非零原文字/3px重排和重开回归通过，不等价完整光栅页面验收。用户Build15“没问题 可以继续”仅按基本自用记录；手机分页EPUB和巨段TXT满页、大字体/VoiceOver/旋转/耗电继续单列。

安装`build/XianxiaReader-ReadingUI-Build16.ipa` / SHA256 `c55b94177e8ee3f7f9ea3ba50dd93cf49f67b784cc02b5994905c04b8bdd2638`；原创样本测试包`build/XianxiaReader-ReadingUI-Build16-TestKit.zip` / SHA256 `182f23473f89cded7c124324af411b30fd18593200c8b580c7f69f402a87821d`，附6张本轮原生浅深色Preview图。正常覆盖更新保留书库，+菜单确认0.0.1 (16)。新旧27包、ZIP CRC/内部IPA/原有样本/Preview hash已核。Build16手机待测；M4整体未完，字体文件资产导入/单书覆盖/独立四边距/字距字重/亮度/音量键/阅读方式跨启动保存仍后续，M5设备性能单列。报告M4_POLISH_VALIDATION_REPORT.json。

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-first-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-second-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-third-failure.json

以下Build15及更早条目为历史。

## Build15 M4第一片当前门槛

Build15阅读主题/基础排版通过[完整CI38722474043](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38722474043) / `a6251ea23e6e126acd27f16b3fe4886fed74dd77`：Linux/macOS各115Core、iOS90/90（84集成+6真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名iPhoneOS arm64 Release15及真实IPA、各四长TXT Release探针。Windows417Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是Swift编译。498运行/验证源Git blob hash、三份真实六pins锁核过。编译警告/错误与系统runtime消息分开，见专门诊断。

阅读菜单→阅读设置：日间/暖白/纸色/深灰/OLED黑五主题，深色正文#C6CCC5；默认/通用衬线/无衬线字体、80–200%字号、行高、段距、左右留白、两字缩进及对齐。默认暖白110%/1.75行高/0.8rem段距/两字缩进。全局Preferences/reading-v1.json在存储actor上有界读取/原子保存，打开前恢复，连续编辑顺序保存，错误可见/可重试；坏/未来版本设置原件保留。“沿用原书排版”时高级排版停用，固定布局不提供正文重排。

Adapter走3.11 Preferences与现有DOM锚点保护；连续当前/已加载/指定资源脚本派发已补齐（既有Vendor扩展及provenance记录），并以真实字号/颜色/CJK缩进和非零UTF16/byte定位回归。原书/资源ID/schema3/六pins/完整Locator/NSFileCoordinator合同保持。原生设置与实际TXT/EPUB截图、成功XCTest视频及连续帧已复核；不等价手机FPS、耗电、完整书籍/Provider矩阵或普通签名设备验收。

明确未验收：巨段TXT单个WKWebView截图只绘顶部少量文字、下方大片留白。实际DOM/CSS、非零位置及3px重排/重开测试通过；截图时序/层级裁切或真实满页缺陷尚未确认。须优先在手机或原生整窗检查调整字号后的满页正文与重开；确认前不能写成完整TXT排版验收，若复现留白则先修复再扩大M4范围。原生设置弹出22帧、纸色转深灰22帧与62.49秒录屏已看；20fps时间采样可有VFR重复帧，无插帧，不是手机FPS。

安装包`build/XianxiaReader-Appearance-Build15.ipa` / SHA256 `e65e5b349de4943ec05dc5651f7e2668de3141a73e769c3806dc38b66897a553`；测试ZIP`build/XianxiaReader-Appearance-Build15-TestKit.zip` / SHA256 `6967660ad5199a121b49e53fa0055edea47698a4d929da7ea6ffc195039c0fd8`。新旧共25包逐hash保留，ZIP内部IPA/11原创样本/封面样本/CRC核验。正常覆盖更新保留书库，+菜单确认0.0.1 (15)。M4第一片自动门槛通过，手机待测，M4整体未完成；字体文件导入、单书覆盖、独立四边距、字重/字距、亮度和音量键后续，M5真机性能单列。设计READING_APPEARANCE_DESIGN.md，报告M4_APPEARANCE_VALIDATION_REPORT.json。

手机步骤：分页/连续阅读中切五主题、改字号/行距/留白、确认原文字位置；开关缩进/对齐并检查标题/标点；退出重开软件确认设置与位置；复杂EPUB试沿用原书排版。Reduce Motion、横竖屏、真实流畅度/耗电、普通设备签名和具体系统型号分别记录。

以下为Build14及更早历史与完整路线；M4整体未完成。

## Build14 当前切片与验收范围

Build14重复导入通过[完整CI38703788390](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38703788390) / `b67a08bc7f6d0db0c97ec152a87e2128a3209c82`：Linux/macOS各110 Core、iOS84/84（79集成+5真正XCUITest），failed/skipped0，test/export/summary/recording退出0，无签名设备Release14及真实IPA、各四长书Release探针。Windows411 Swift语法新增0/54 pristine限制、17 Python tooling通过；语法不是Swift编译。492运行/验证源Git blob hash、三份真实六pins锁和21旧包hash核对一致。

相同原件再次导入保留原书UUID/改名/封面/完整Locator/目录/书签/导入时间，底部展示新增与重复数量并可查看。回收站里的重复书由用户显式恢复，恢复后原有进度保留。格式+原件SHA256/64位bytes精确匹配；TXT另比正文正规化身份，自动与手选编码同正文去重、不同有效解码可独立导入。同名不同内容、新BOM/换行或EPUB重新打包不自动合并。

schema3新增003迁移及指纹表/索引，旧payload和已有重复书全部保留。旧原件后台延迟流式补齐，可取消；缺失旧原件警告但不阻止其他书，已登记匹配项原件缺失/损坏则可见错误，不冒充重复成功。最终BEGIN IMMEDIATE事务复查并提交Book/Chapter/指纹，多连接仅一个新UUID获提交；败方清自己暂存/cache。Reader/codec/Vendor/六pins/Locator和NSFileCoordinator合同保持。旧版不支持schema3降级读取，禁止删库修复。

原生重复项/回收站/恢复截图与实际XCTest视频及连续帧已复核，网格恢复和原生反馈保持同一灰绿风格、现有Reduce Motion合同。截图/模拟器录屏不当手机FPS、耗电或全部File Provider验收。用户最新反馈“没问题 正常”，Build14按基本自用范围通过，M3既定自用功能阶段收口；下一阶段M4主题/字体/正文排版尚未开始。设备型号/系统版本、逐项导入矩阵与手机FPS未重新核实，其他设备与M5性能继续单列。无自动合并旧重复书/替换原件/永久删除/GC；M5设备性能后续。

安装包`build/XianxiaReader-Duplicates-Build14.ipa` / SHA256 `40779ea86e068666fe3e7af70b3179738ce76cbeb5d2e73ee2e7f06777d68204`；测试ZIP`build/XianxiaReader-Duplicates-Build14-TestKit.zip` / SHA256 `c7feefc8c6a5f45632712e28a38c75d874f553eaa2c05e8b7a36c25a82a15b61`。新旧包共23份逐hash保留，ZIP内部IPA/11原创小大样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (14)。设计LIBRARY_DUPLICATE_DESIGN.md、报告M3_DUPLICATES_VALIDATION_REPORT.json。

首轮CI38700353531/84397ad实际失败于新增Core测试对照Data缺try；Core测试运行、macOS、iOS、Release未开始。修正try与合法双解码样本后完整重跑，未删除/放宽断言。完整首轮Core/full日志与ValidationLogs/m3-library-build14-first-compilation-failure.json保留；Apple artifact当轮不存在，下载helper因此返回1，不冒充产品失败。

第二轮CI38700674784/5278d286各110 Core与四长书通过、iOS83/84：79集成/旧4UI通过，仅新UI父容器AX标识覆盖Done使查询失败。实际视频发现重复反馈与状态叠放、单项136pt留白，修正产品VStack/内容高度/叶控件标识；保留原查询、15秒和断言。原件ValidationLogs/m3-library-build14-feedback-layout-ax-failure.json保留，最终成功不覆盖失败历史。

手机步骤：正常更新→重复导入原件/改名副本→数量/改名/封面/完整位置/书签保持；回收站重复导入先留原处，显式恢复后重开进度正常；批次新书/重复/坏书计数和错误可见；不同内容同名可保留。首次旧库补齐可取消。普通签名设备、手机FPS和供应商矩阵不由模拟器结果推断。

以下历史原件保留。

## Build13 当前切片与待测

Build13更换封面切片通过[完整CI38694877516](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38694877516) / `708d02d0ecadcb3d22d653965aa94203bf4ab227`：Linux/macOS各100Core、iOS79/79（75集成+4真正XCUITest），failed/skipped0，test/export/summary/recording退出0、无签名设备Release13与真实IPA、各四长书Release探针。Windows407Swift语法新增0/54 pristine限制、17tooling通过；语法不是Swift编译。487运行/验证源Git blob hash、三份真实六pins锁与19旧包hash匹配。

长按书籍→更换封面，从系统相册或文件选图，预览后保存；恢复默认先预览再保存，取消不提交。原书、默认封面、目录、完整位置、书签、书名与UUID保留。后台有界ImageIO下采样和缩略缓存，网格/列表更新有短淡入淡出并尊重Reduce Motion。真实DB失败保留草稿可重试；迟到/关闭/旧回调不能覆盖新选择。重复save已提交草稿不能回移已提交原图。schema2与旧迁移/Reader/codec/Vendor/依赖锁不变。

原生错误/待保存预览/书架/默认预览和实际XCUITest的Files取消/默认取消/保存/重开截图及视频已单独复核。测试夹具只在DEBUG隔离目录，Release恒nil且Mach-O无XR_LIBRARY_UI_*旗标。自动测试/录屏不当手机相册/File Provider权限、全部图像格式/旋转、手机FPS/耗电或普通签名设备验收。单图20MiB/8000万像素限制；旧自选原图保留，不自动GC或释放存储；自由裁切未提供。M3还剩重复导入策略，M4完整主题/正文排版和M5设备性能未开始。

安装包`build/XianxiaReader-Cover-Build13.ipa` / SHA256 `57a6e0c9639af654abd106bcd187ee7b37d721d3cedf315d2a1677aa5e4d6009`；测试ZIP`build/XianxiaReader-Cover-Build13-TestKit.zip` / SHA256 `85e5f5aef4886416d2aed4126b3e142be8749b3dc3bdceae29366e953628ac9c`，内部IPA/11原创样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (13)。设计LIBRARY_COVER_DESIGN.md、报告M3_COVER_VALIDATION_REPORT.json。Build12用户已接受当前观感，具体硬件/实测FPS未独立读出，Build13手机待测。

中间候选CI38688984422由Agent为提交边界保护主动取消，各100Core通过、Linux四探针通过，Apple长书探针未结束/iOS/Release未运行；完整日志与取消原因保留ValidationLogs/m3-library-build13-first-cancellation.json，不写成源码失败。

第二轮CI38689366894各100Core/四探针通过，iOS78/79（75集成全通过、原3UI通过，新UI标题查询失败），test65使Release未运行；原生AX树/视频确认系统Files已正常打开，修正子label查询并保留10秒/后续全部断言。另修纯row builder的MainActor警告，未禁用诊断。原件ValidationLogs/m3-library-build13-file-picker-ax-failure.json，最终成功不覆盖失败历史。

第三轮CI38691894649各100Core/四探针通过，iOS77/79：Files取消的全局indexed AX查找失败，以及旧fragment/DOM书签回归navigationFailed；8新封面集成与旧3UI通过。最终用本地AX包装实际frame/public coordinate点取消并断言Files确实消失；布局改为值初始化的独立子View和MainActor body，消除Spacer隔离警告。旧Reader只增阶段打印，原导航/几何/timeout和生产Reader均未改；一次navigationFailed的唯一原因仍未确认，后续全绿不写成已修复全部WebKit时序。原件ValidationLogs/m3-library-build13-cancel-ax-and-reader-failure.json。

手机步骤：从相册首次选图并保存；从Files选择/取消/坏图重试；默认预览取消与保存；重开封面保持；回收站恢复后封面/位置/书签保持；系统减少动态效果。其余设备不推断。

以下历史原件保留。

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

## Build9 交付与Build8已确认范围

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。

Build9请正常更新，先核对既有UTF/GB18030/EPUB中段位置，再以自动模式冷首次导入中文ANSI/GBK；确认文字/目录/成功反馈及退出重开。Big5与1252分别手选，测试包三个新原创小样可直接复测。保留旧书库和原件，不删除数据库；编码歧义可以重新选编码导入，现有书原地修改编码界面尚未实现。设备型号/OS/实际安装Build未独立读取，不把Build8回复扩写成Build9或完整设备矩阵通过。


以下为历史阶段记录，当前范围以上述Build9与设备反馈为准。

## 当前设备与状态

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](PERFORMANCE_TEST_PLAN.md)。

2026-10-14最新用户确认：“ok 能正常导入了 没问题”。在Build7交付与软件首次导入问题复测的上下文中，记录首次导入正常；此次验收通过。具体格式/本地或iCloud/实际Build和OS未分别核读，不延伸为全矩阵。普通签名设备、TXT目录/搜索/书签/位置/旋转及数十MB长篇性能仍单列待验收；Build6失败及之前待确认记录保留为历史。证据m2-import-build7-device-feedback.json。

2026-10-14最新：用户报告Build6上下文首次导入仍无反应/提示，第二次可成功/报错，设备首次验收失败；实际安装Build/OS尚未独立读取。Build7随后通过CI38572197917（各68Core/55iOS/Release），新包build/XianxiaReader-Import-Build7-TestKit.zip / SHA5f280447e39b106cb096074a21d7d0a3954c8435a2131d4c038a8889309f4172。正常更新保留书库，+菜单确认0.0.1 (7)，完全退出重开后第一次选TXT，再重开第一次选EPUB，分别本地/已下载iCloud、取消/错误、旧书库。引用生命周期/无关闭事件/完整书架回归通过不代替真实Files/用户设备确认；M2完整设备/长书仍待验收。

2026-10-14 后续反馈：用户报告TXT可导入，但第一次选择后系统选择器关闭、书架无新增且无提示，之前EPUB也相同。Build6引用模型交接已通过CI38566503849（各68Core/49iOS/Release），新包build/XianxiaReader-Import-Build6-TestKit.zip / SHA 112113c0e939c5d8aabdc5ad2280c8faf77f3f1d9288145e902d8ec3cc4a815c。正常更新并保留书库，完全退出重开后首次选TXT，再重开首次选EPUB，分别测本地/已下载iCloud及取消后再选择。自动原生sheet回归提供fixture URL到delegate，不代替真实File Provider/iCloud/用户设备；首次设备故障的唯一根因仍未证实，待Build6实测。部分导入可用不等于完整TXT阅读/性能通过。

### TXT Build5准备（尚未设备验收）

2026-10-14 TXT Build5已过完整CI38559906005：各68 Core、46 iOS与设备Release。新测试包build/XianxiaReader-TXT-Build5-TestKit.zip，SHA256 7d547c7582230e35860e0b591bb51adcf51f988a20470ff421d8805c6d1ac668，含原生设备IPA与三个原创编码TXT/说明；原Build4原件保留。TrollStore正常更新，不卸载/删库；TXT实际设备尚未验收，自动CI不能写成设备通过。

Build5设备复测范围：内置原创TXT、UTF8/带BOM UTF16自动导入；GB18030明确编码选择/失败重试；取消/混合导入保留成功书籍；卷/章目录、长章窗口、搜索/书签与连续跨章；章中段关闭/重开、模式切换/旋转及中文标点/两字缩进/标题节奏。使用自己长篇TXT记录数十MB冷导入、cache重开时间与内存/卡顿。完整字体/主题仍在M4，不把基础样书CSS当全局排版完成。普通设备与TrollStore分别记录，用户Build4连续/重开已确认可用的原记录保持。

2026-10-14最新用户反馈：“这个功能可以了，重开位置也是正常的”，并要求按计划继续。按本聊天上下文记录Build4连续跨章与重开位置可用，来源为用户实测；设备背景仍为iPhone13/iOS16.6.1/TrollStore。未逐项报告的原书图片、旋转、普通签名设备和性能保持待验收，不把此反馈扩写为所有项目通过。

2026-10-14 当前反馈：iPhone 13、iOS 16.6.1、TrollStore。用户此前报告安装正常、iCloud 选中后“打开”无反应；导入修复后已明确确认 EPUB 可以导入（具体来源尚未细分）。阅读截图中图像只显示窄横条，并要求上下滑动无缝跨章。安装/导入用户报告不等于完整阅读验收；用户原书未提供，不提交截图中的个人书籍或文件列表。

最新可用包与构建 SHA/校验值见 HANDOFF 和对应 CI 验证报告。M0 包原件保存在 `build/ci/38390862584/ipa/XianxiaReader.ipa`；M1 包只在新 CI 通过、下载和核验后提供。请保留原有应用/书籍数据，使用 TrollStore 的正常安装/更新操作，不通过卸载或删除数据库解决阅读/升级问题。

最新候选测试包为Build4（CI38530334549/d62af3b，41/41 iOS、各14 Core、设备Release通过），IPA/ZIP已核验，旧Build3原件与测试包保留。新包 `build/XianxiaReader-Continuous-Build4-TestKit.zip` 含四本原创EPUB及UTF-8 TESTING.txt。在iPhone“文件”解压后分享内部IPA给TrollStore正常更新，保留书库数据。当前CI边界PNG只显示第一章末尾和空白，未完整显示第二章；原因未确认，优先在设备检查真实显示，不能凭自动断言写成体验通过。

## 阅读视口与图片复测

1. 更新后先打开此前显示窄横条的原书，分别核对分页、章内滚动、菜单隐藏/显示和横竖屏。记录原书图片是否完整。
2. 导入原创 `Tests/Fixtures/reader-layout.epub`（测试包 Samples 中提供）；封面图像上方绿色、下方米黄色，两条色带均应完整显示并保持比例。菜单开关不应将图像压成窄横条。
3. 从目录跳到第一章/第二章、点击章末内部链接；正文资源正确，成功跳转后收起菜单。章内模式的左右滑动/上一节/下一节可切资源。
4. 阅读菜单启用“上下连续滚动”，滑到第一章末尾，确认本章末尾与第二章开头同时出现；连续拖动、惯性和反向分别检查。Build4自动回归通过，但当前边界PNG不足以视觉验收；若空白/跳动，请记录所在位置与操作，保持数据不删除。固定布局/RTL/竖排不启用此候选能力。

## 导入与基础阅读回归

Build 2 的导入回归优先：更新后先点击“导入内置样书”（书架有书时使用 + 菜单），确认无需 File Provider 的真实导入和阅读；再导入“我的 iPhone”本地 EPUB；最后重试截图中的 iCloud 选中/打开流程。文件类型过滤放宽，TXT 等其他文件明确报错；不能把本地/内置成功写成 iCloud 通过。

使用项目原创 `Tests/Fixtures/chinese-epub2.epub`、`chinese-epub3.epub`，再使用自己合法持有的中文 EPUB。将测试文件放到 iPhone“文件”中，点击应用“导入 EPUB”。记录以下每项的实际结果：

1. 启动进入“藏书阁”；两个原创样书均成功导入，书名/作者/封面/目录正确。损坏文件明确失败，已有书籍保留。
2. 打开 EPUB2/3，观察中文标点、段落、标题、图片；点击左右翻页、滑动翻页、中央隐藏/显示菜单。正文和链接不能被不可见控件阻挡。
3. 从“目录”跳转两章，点击正文末尾“前往另一章”，确认 fragment 链接定位和返回后的菜单正常。
4. 搜索“修行”：逐批加载最终 80 个正文命中，章节标题和片段可读；点击第二章的结果应定位到该段。搜索不存在关键词明确显示无结果。
5. 连续改词/停止/关闭搜索并重新打开，旧结果不能混入新查询；点击结果后搜索页关闭、正文可继续操作。
6. 添加书签并跳转；切换分页/上下滚动，测试竖屏与横屏。记录是否丢失当前段落或遮挡正文。
7. 停留在章中段，返回书库，再打开；切后台再返回；正常关闭再重启应用。确认位置和书架进度恢复。
8. 用真实长篇 EPUB 验证目录缓存、搜索首次结果、停止操作与持续翻页；记录卡顿/异常。M5 性能指标不在此提前标通过。

## 记录模板

| 项目 | 当前 |
| --- | --- |
| 设备/iOS/安装方式 | iPhone 13 / 16.6.1 / TrollStore（用户确认） |
| 安装结果 | 先前安装正常；本次用户确认连续/重开功能可用，按上下文对应Build4，未独立读取Build号 |
| 构建 SHA / IPA hash | 使用实际测试包填写 |
| EPUB 样本 hash / 文件来源 | 待填写，不上传个人小说到 Git |
| EPUB 导入总体 | 用户确认已经可以导入；来源未细分 |
| 内置样书 / 本机 / iCloud 各来源 | 仍需分别记录；旧 iCloud“打开”失败历史保留 |
| 目录 / 图片 / 内部链接 | 旧原书图像窄横条；Build4原书及目录/链接设备待复测 |
| 真正纵向无缝跨章 | Build4自动CI通过，用户本次确认功能可用；逆向/惯性未单独量化，不以旧CI PNG否定用户实测 |
| 点击 / 手势 / 分页 / 滚动 / 旋转 | 待测试 |
| 搜索 / 结果定位 / 取消 / 无结果 | 待测试 |
| 书签 / 后台 / 重启位置恢复 | 用户确认重开位置正常；书签/后台其他动作未逐项确认 |
| 问题复现步骤 / 页面截图 | 当前图片裁切；原书 CSS/资源未取得，不能认定唯一原因；不提交用户截图 |

测试失败时保留现有数据、记录操作与具体提示。普通设备签名安装与 TrollStore 结果分开；本表不将模拟器 XCTest 或用户“已安装巨魔”视为应用验收。

Build14基本自用反馈证据：[m3-library-build14-user-feedback.json](ValidationLogs/m3-library-build14-user-feedback.json)。其余未逐项报告的矩阵继续待记录，不由“正常”推断全覆盖。
