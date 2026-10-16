# XianxiaReader · 仙侠阅读

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

## Build17 阅读手感（2026-10-16）

Build17阅读手感第一片通过[完整CI38775427080](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38775427080)，实际编译源`63134f1aa4787e3067453e2fe8b15bf17b449ca2`。Linux/macOS各119Core，iOS99/99（89集成+10真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release17。Windows423Swift语法新增0/54 pristine限制、17工具测试通过；语法不是编译。四长TXT Release探针/平台、三份真实六pins锁和504运行/验证源码blob已核。原生截图/手势录屏/连续帧与手机手感/FPS、普通签名/TrollStore设备结果分列。

保留Readium原生跟手翻页/回位和真正跨章连续阅读；滑动时可收起菜单、中央轻点显示，菜单0.2秒/10pt克制过渡。设置新增“手感”：记住阅读方式、滑动收菜单、减少动效。独立interaction-v1.json在BookFileStore actor上有界读/原子保存、写入顺序/错误重试；打开先恢复偏好，支持时走既有DOM锚点模式切换，不支持布局保留用户偏好而使用适用分页。用户/系统减少动效作用于点按导航和自定义菜单，手指保持原生跟手；DEBUG额外减少请求只在运行时合并。分页命令防重入/关闭身份保护；连续模式禁误横滑切资源，按屏命令仍用Readium原路径，不宣称动画期间完整节流。Vendor仅普通分页通知补齐局部锚点及provenance；不改JS bundle/schema3/原书/完整Locator格式/远程锁或依赖版本。

首候选8c548dce/CI38760598889为97/99，WebKit测试hook返回JS函数不支持、普通拖动发生在加载spinner时未收菜单，严格test65无IPA，原旧回归通过。实际两段失败/减少动效录屏总览确认准备门槛过早；第三候选只修正hook末尾null和真实可读样本文字等待，原手势/10秒菜单断言及旧定位回归保持。c9bae997/CI38765644376的原生滚动回调实验经录屏证据后Agent主动取消，停在LinuxRelease探针，Apple未运行；七文件ZIP/Git候选保留，产品路径撤回，不能把未证pointer取消假设当根因。第三候选1d1f2763/CI38765962839新动效全部过、两旧回归失败97/99，修正普通分页通知丢DOM范围与设置滚错底层连续阅读区，第四轮50ecf291/CI38771271584全89集成通过，2UI准备失败：顶部多余下滑dismiss与切模式未等原生就绪；最终只修测试准备，原断言不放宽。全部失败/取消日志/xcresult/素材与下载限制保留，设计READING_MOTION_DESIGN.md。

安装`build/XianxiaReader-ReadingMotion-Build17.ipa` / SHA256 `9d2af110466c03746e67929da58118ad60b4296f8001e408c4b2fb8ac29fa53e`；原创样本测试包`build/XianxiaReader-ReadingMotion-Build17-TestKit.zip` / SHA256 `5d09ad4d3536c644533e3a7b324561f8ace14cea0ba5a7fb8d119ec95de3e81b`。正常覆盖更新保留书库，+菜单确认0.0.1 (17)。原27包与本轮2包逐hash、测试ZIP CRC/内部IPA/原创Samples/Evidence/Cover/6张本轮真实Preview核过。仿真卷页/上下整屏/自动慢滚/触感反馈尚未实现，按独立后续切片推进；字体文件导入等M4内容仍后续，M4整体未完。报告M4_MOTION_VALIDATION_REPORT.json。

本轮24张实际原生截图已复核，全部非透明；分页EPUB深灰180%重排快照与新增EPUB整窗文字均已实际可见，旧透明采集不追认。巨段TXT孤立快照仍仅顶部约两行/下方留白，满页成因与手机结果仍未验收；普通TXT实际UI录屏有整页正文。正常65.60秒/额外减少动效16.54秒两段新手势视频全时段1秒总览，以及正常收菜单21帧/中央恢复20帧、减少动效跟手横拖17帧/恢复20帧共78实际20fps时间采样已看，无插帧且允许VFR重复，不当手机FPS。正常约18.00–18.20秒菜单短渐退同时正文原生上滑，约22.10–22.30秒中央恢复，正文视口未因菜单重排；额外减少动效约13.00秒菜单直接出现且保留手指横拖。手感三组/关闭自动收起/减少动效开关/连续模式重开可读；重启间31–46秒系统桌面不作阅读证据。其余3段阅读与5段书架原生视频只保留，未宣称本轮逐段审阅。系统真实Reduce Motion/VoiceOver/旋转/其他设备、普通签名/TrollStore、手机手感/FPS/耗电仍待测。


当前Build16：原生阅读菜单/外观与排版分组、灰绿浅深色面板、触控尺寸与留白打磨；五主题及既有排版/全局保存继续保留。完整CI各115Core/iOS93/Release16与原生图/视频复核完成，手机待测；M4整体仍未完。安装`build/XianxiaReader-ReadingUI-Build16.ipa`，测试ZIP`build/XianxiaReader-ReadingUI-Build16-TestKit.zip`附原创样本和6张本轮原生Preview。设计READING_UI_DESIGN.md，验证M4_POLISH_VALIDATION_REPORT.json。以下旧切片为历史。

当前Build15：阅读菜单→阅读设置，提供五主题、内置通用字体/字号、基础中文排版与全局保存；完整自动门槛及原生设置图/视频复核完成，巨段TXT截图下方留白原因未确认，满页/手机待测。安装包`build/XianxiaReader-Appearance-Build15.ipa`，带原创样本测试包`build/XianxiaReader-Appearance-Build15-TestKit.zip`。正常覆盖更新保留书库；M4整体仍未完。详见PROJECT_STATUS.md、HANDOFF.md和Documentation/READING_APPEARANCE_DESIGN.md。以下旧切片保留历史。

## 当前：Build14 / M3重复导入

同一TXT/EPUB原件再次导入保留已有书籍、进度、书签和自选封面，回收站重复项可显式恢复；同名不同内容继续独立保存。书库已具备网格/列表、筛选排序、改名、左滑确认移出、回收站恢复和选图更换封面。[完整CI](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38703788390)各110 Core、84/84 iOS与无签名设备Release通过，原生截图/视频复核完成。Build14基本自用已确认，M3按自用门槛收口；下一阶段M4主题/字体/正文排版尚未开始。安装包与恢复见[PROJECT_STATUS](PROJECT_STATUS.md)、[HANDOFF](HANDOFF.md)，取舍见[重复导入设计](Documentation/LIBRARY_DUPLICATE_DESIGN.md)。

以下Build8及更早段落保留历史证据，阶段状态以上述当前记录为准。

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](Documentation/M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](Documentation/PERFORMANCE_TEST_PLAN.md)。

面向中文玄幻、修仙、仙侠、武侠和超长网文的本地 iOS 阅读器。用户从自己的文件导入书籍；项目不提供小说下载站或在线书城。

**历史Build4自动节点：M0通过、M1连续跨章通过自动门槛，用户随后已确认连续与重开；未逐项设备细项继续单列。** [CI 38530334549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38530334549)（已测源码d62af3b7576a11a1b7318e029355ef1847710113）：Linux/macOS各14 Core、41/41 iOS tests、无签名设备Release与Build4 IPA成功。测试包已核验，旧Build3原件保留；见[项目状态](PROJECT_STATUS.md)。

Build4连续证据：长段字符/重开、目录/搜索/书签、模式往返、窗口回收、迟到回调及加载桥回归通过；用户随后确认连续功能与重开位置正常。旧CI边界PNG缺第二章的截图限制仍保留，不否定用户实测；未单独报告的原书图片、普通设备、旋转及性能继续记录。原 `build/XianxiaReader-Continuous-Build4-TestKit.zip` 保留。自用优先、卡点参考成熟方案、微信读书交互与现有路线原则见[参考记录](Documentation/MATURE_READER_REFERENCES.md)；恢复见[当前交接](HANDOFF.md)和[连续验证报告](Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json)。

历史用户实测：连续阅读功能与重开位置已确认正常，现按计划进入M2 TXT。[分章第一切片](Documentation/TXT_INDEX_DESIGN.md)新增独立Core标题识别、UTF-8流式索引及有界章节窗口，[完整CI38538141364](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38538141364)的同源码attempt2为Linux/macOS各33 Core、41/41 iOS与设备Release成功；初轮EPUB冷启动超时原文保留，原因未确认；随后编码/版本cache第二Core切片通过[CI38547339868](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38547339868)：Linux/macOS各60 Core、41 iOS及设备Release；支持严格UTF8/UTF16/GB18030旁路转换与内容/目录摘要cache，首轮Apple iconv失败及修复证据保留。TXT产品随后接入Build5并通过[CI38559906005](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38559906005)：各68 Core、46 iOS及设备Release。提供编码选择/重试/取消、有界Readium阅读、目录/书签/搜索与完整byte/text位置；设备/长书仍待验收。UI完整书库布局在M3，字体/行距/主题在M4。未逐项报告的原书图片、普通设备/旋转/性能仍单独记录。

## 当前已写入

- SwiftUI 应用入口、基础网格书库、封面/书名/作者/阅读进度/最近阅读时间。
- Files Document Picker 多选 EPUB，明确导入副本模式、后台协调复制、Readium 元数据读取、缩略封面与目录缓存；新增原创内置样书入口。导入修复已过CI，用户确认EPUB可以导入、来源未细分，详见 [导入修复](Documentation/IMPORT_FIX.md)。
- 基于 Readium 的 Reader：目录跳转、手势分页、左右区域点击分页、中央点击菜单、分页/滚动切换、位置保存/恢复、书签添加/跳转/删除。
- SQLite actor、事务迁移、隔离的业务模型和阅读引擎接口、失败导入回滚与重启恢复。
- Reader 关闭时使尚未完成的打开请求失效，过滤旧 Navigator 回调；文件复制支持失败注入，Apple 分支保留 File Provider 协调。
- 原创中文 EPUB 2/3 样书、Core 单元测试、iOS 集成测试、Windows 可运行的结构/语法检查。
- GitHub Actions：macOS 构建、模拟器测试、无签名设备应用、`Payload/` 打包与完整日志 artifact。

M1 搜索切片已过 CI：Readium SearchService 扩展、分批结果、取消/迟到回调过滤和跳转委托；真实命中定位仍待页面验收，详见 [搜索设计](Documentation/SEARCH_DESIGN.md)。TXT 导入/有界Readium阅读/完整位置已接入并过Build5自动CI；书库浏览、改名、回收站和封面编辑已在Build10–13通过自动门槛；重复导入已在Build14通过自动门槛；自定义字体、五种主题、全部排版设置、音量键翻页和完整设备性能验收仍待后续阶段，详见 [功能矩阵](Documentation/FEATURE_MATRIX.md)。XBook 与知识库仅有协议草案。

## 技术基线

| 项目 | 选择 |
| --- | --- |
| 最低系统 | iOS / iPadOS 16.0 |
| UI / 并发 | SwiftUI、UIKit Navigator 桥接、Swift Concurrency |
| 数据 | 系统 SQLite3，经 actor 串行访问；不依赖 iOS 17 的 SwiftData |
| EPUB | Readium **3.11.0 本地维护扩展候选**，基线/许可/差异hash见Vendor/ReadiumToolkit；不自行实现排版引擎 |
| 工程 | `project.yml` 是唯一工程定义，XcodeGen **2.46.0** 生成 `.xcodeproj` |
| CI | `macos-15`、Xcode **16.4**、Swift 5 语言模式；Core 使用 tools 5.10 |

Readium 3.11.0 的 Navigator 使用自定义 URL scheme 提供资源，无需 localhost HTTP server。依赖的 `DefaultHTTPClient` 是客户端，不是监听服务。[官方发布说明](https://github.com/readium/swift-toolkit/releases/tag/3.11.0)

## Windows 开发

可以编辑和维护全部源码、文档、Swift Package manifest、工程及 CI 配置。无需启动本地网页服务。当前工作区没有 Swift/Xcode；Windows 检查不等于 iOS 构建。

```powershell
python -m venv .venv
.venv\Scripts\python -m pip install -r scripts/requirements-checks.txt
.venv\Scripts\python scripts/check_repository.py --swift-syntax
.venv\Scripts\python -m unittest discover -s scripts -p "test_*.py" -v
git status --short
```

Swift 语法检查使用 tree-sitter，只发现语法和结构错误，不能检查 SDK、类型、链接、Swift 隔离规则或运行行为。Python SQLite 检查实际迁移文件，但不能替代 Swift repository 测试。

## macOS / Xcode 构建

安装 Xcode 16.4 并完成首次启动，安装 XcodeGen 2.46.0。若使用其他版本，先修改基线并执行完整 CI，不允许凭空宣称兼容。

```bash
export DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer
xcodegen generate --spec project.yml
mkdir -p XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
cp Package.resolved XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader -onlyUsePackageVersionsFromResolvedFile
swift test --package-path Packages/XianxiaCore
open XianxiaReader.xcodeproj
```

在 Xcode 中选择 `XianxiaReader` scheme 与模拟器。普通 iOS 设备需要设置个人 Team / 唯一 Bundle Identifier 并正常签名。不要将本地签名证书提交到仓库。`XianxiaReading` 使用 UIKit，不能用 macOS 的 `swift test` 验证；它的测试由 iOS test target 执行。

可运行 CI 同款完整流程（要求可用 iOS 18.5 iPhone 模拟器）：

```bash
mkdir -p build/logs
set -o pipefail
bash scripts/ci_ios.sh 2>&1 | tee build/logs/build.log
```

## GitHub Actions / IPA

项目公开仓库为 [wan780839395-cyber/XianxiaReader](https://github.com/wan780839395-cyber/XianxiaReader)，origin/main 已建立并推送。用户已明确同意公开源码；使用公开仓库标准GitHub-hosted runner的免费构建，不启用大型runner或付费超额，说明见[GitHub接续](Documentation/GITHUB_SETUP.md)。`main` push、PR 和手动 `workflow_dispatch` 执行 [.github/workflows/ios-build.yml](.github/workflows/ios-build.yml)。构建结论以 PROJECT_STATUS 和 GitHub Actions 的具体run为准；阅读/设备验收与自动构建结果分开记录。

最新成功产物已下载至 `build/XianxiaReader.ipa`，完整日志 `build/logs/ios-build.log`。来源提交、SHA-256 与独立验证范围见 [M1_READER_VALIDATION_REPORT.json](Documentation/M1_READER_VALIDATION_REPORT.json)；M1_SEARCH_VALIDATION_REPORT.json 和 IOS_VALIDATION_REPORT.json 保留之前的搜索/M0 范围。GitHub artifacts 保留 14 天，忽略的本机构建目录不会随 clone；过期后重新运行锁定版本的 workflow。

用户测试设备为iPhone13/iOS16.6.1/TrollStore，先前安装/EPUB导入用户报告正常；Build4原书图片、连续双章/逆向、惯性与重开位置待实测。当前 `build/XianxiaReader-Continuous-Build4-TestKit.zip` 包含Build4 IPA、四本原创EPUB和UTF-8说明；保留数据正常更新，菜单启用“上下连续滚动”。候选自动CI通过，当前边界PNG未完整显示第二章，完整阅读仍待验收；见[真机验收](Documentation/DEVICE_ACCEPTANCE.md)。旧Build3包及测试ZIP原件保留。

CI 先检查仓库、运行 Core 测试与 iOS 集成测试，然后使用 `CODE_SIGNING_ALLOWED=NO` 构建设备 Release `.app`。测试或编译失败会使 job 失败，不会跳过错误输出成功 IPA。

- `XianxiaReader-unsigned-ipa`：包含 **XianxiaReader.ipa**，内部为 `Payload/XianxiaReader.app/`。
- `XianxiaReader-build-diagnostics`：完整 `build/logs/build.log`、环境记录、`.xcresult`、生成的 `.xcodeproj` 及解析后的 `Package.resolved`；失败时也上传已有诊断。
- `XianxiaReader-core-diagnostics`：独立 Linux Core 编译/测试日志，使用 Swift 6.1.2 jammy 的已验证 linux/amd64 image digest；iOS job 等待此项通过。macOS job 仍再次运行 Core 测试以覆盖 Apple 文件协调分支。

无签名 IPA 用于后续 TrollStore 测试，不是普通 iOS 安装签名包；设备是否适合 TrollStore 与实际安装/运行必须另行验证。本项目不会申请平台级权限或植入私有 entitlement 来实现阅读功能。

## 可选 Windows Core 编译测试

本机若已有正常运行的 Docker Desktop，可以执行：

```powershell
pwsh -File scripts/test_core_container.ps1
```

脚本先检查引擎，20 秒无响应则明确失败；不会替你启动或重置 Docker。容器只读挂载项目，不映射端口，编译缓存位于容器临时目录，日志写入 `build/logs/`。Linux 分支仅验证普通本地文件复制、SQLite 和业务模型，不能代替 macOS/iOS 的 `NSFileCoordinator`、Readium 或 UI 测试。

本轮已恢复 Docker 的失效旧 socket 故障，并实际编译 Core、运行全部 14 个 XCTest，退出码为 0；首次失败暴露的路径边界缺陷已修复。成功日志和源码 hash 见 [Core 验证报告](Documentation/CORE_VALIDATION_REPORT.json)，环境修复见 [Docker 恢复记录](Documentation/DOCKER_RECOVERY.md)，完整边界见 [验证记录](Documentation/VALIDATION.md)。官方镜像来源见 [Swift Docker 安装文档](https://www.swift.org/install/linux/docker/)。

## 样书与维护

AppIcon 为原创书页/山峰/月亮图案；Xcode 直接使用提交的 PNG。维护图标时可安装 `scripts/requirements-assets.txt` 并运行 `python scripts/generate_app_icon.py`，同时生成 SVG 源稿和 PNG；这不是构建依赖。

`Tests/Fixtures/chinese-epub2.epub`、`chinese-epub3.epub`的正文与封面均为项目原创测试内容；`reader-layout.epub`为独立高封面/长短章样书。分别运行generate_fixtures.py和generate_reader_fixture.py，不覆盖原搜索回归。

```powershell
python scripts/generate_fixtures.py
```

源码结构和取舍见 [ARCHITECTURE.md](ARCHITECTURE.md)；阶段门槛见 [ROADMAP.md](ROADMAP.md)。后续 Agent 必须先读 [AGENTS.md](AGENTS.md)，按交接文件恢复工作，并明确区分“已写入”“编译通过”“设备验收”。

使用 Git 保存项目阶段；当前远端/提交状态以 `git status`、`git log` 和 PROJECT_STATUS 为准。`Documentation/FILE_INVENTORY.json` 提供维护文件 SHA-256 恢复快照（不包含自身与忽略缓存）。阶段完成后运行 `python scripts/write_inventory.py` 刷新；不要把 hash 快照当成编译验收。维护文本使用 LF，原始验证日志保持字节，不纳入源码格式检查。

2026-10-14首次文件交接增量：Build6 / [CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849)各68 Core、49 iOS及设备Release通过，EPUB/TXT共用引用模型结果交接；新增原生sheet首次/取消/空选择/重试回归。旧交接未在iOS18.5复现用户iOS16.6.1现象，设备首次导入仍待实测，M2长书/设备未完成。新包build/XianxiaReader-Import-Build6-TestKit.zip；旧Build4/5不变。详见Documentation/IMPORT_HANDOFF_FIX.md与HANDOFF。

2026-10-14后续首次导入：用户否定Build6设备首次体验；最新Build7 / [CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917)各68Core/55iOS/Release通过，直接从delegate启动导入、保持关闭后的delegate、统一sheet/持久错误反馈；完整书架/无dismiss/弱回调与原生命周期回归保留。新包build/XianxiaReader-Import-Build7-TestKit.zip，旧4/5/6均保留。用户随后确认首次导入正常，M2长书/设备及M3/M4门槛不变；详见IMPORT_DELEGATE_FIX.md与HANDOFF。

2026-10-14用户验收补充：Build7交付后回复“ok 能正常导入了 没问题”，首次导入问题已确认解决，deviceFirstImportAccepted=true；源码/安装包未变。格式/文件来源未逐项报告，完整M2长书/设备及M3/M4门槛不变；证据Documentation/ValidationLogs/m2-import-build7-device-feedback.json。
