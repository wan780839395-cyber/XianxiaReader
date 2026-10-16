# 功能矩阵（2026-10-15）

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

当前Build16：原生阅读菜单/外观与排版分组、灰绿浅深色面板、触控尺寸与留白打磨；五主题及既有排版/全局保存继续保留。完整CI各115Core/iOS93/Release16与原生图/视频复核完成，手机待测；M4整体仍未完。安装`build/XianxiaReader-ReadingUI-Build16.ipa`，测试ZIP`build/XianxiaReader-ReadingUI-Build16-TestKit.zip`附原创样本和6张本轮原生Preview。设计READING_UI_DESIGN.md，验证M4_POLISH_VALIDATION_REPORT.json。以下旧切片为历史。

当前Build15：M4第一片五主题/基础排版/全局保存完整自动门槛与原生设置图/视频复核完成，巨段TXT截图下方留白原因未确认，满页/手机待测，M4整体未完。M3基本自用已收口；以下旧切片保留历史。

当前Build14：重复导入完整自动门槛及原生图/视频通过，用户基本自用反馈正常，M3按自用门槛收口，M4尚未开始。schema3升级保留全部原书与历史。以下旧切片保留历史。

Build13历史封面替换节点：各100Core/79iOS/Release及原生图/录屏复核通过，手机选图和观感待确认；Build12观感用户接受。重复导入仍后续M3。以下旧切片文字保留历史。

Build12历史节点：原生列表左滑、网格/恢复/布局短过渡与Reduce Motion，91Core/70iOS/Release及六图/录屏连续帧通过；手机流畅度待确认。Build11回收站/恢复已获用户自用确认，具体其他设备矩阵单列。

Build11回收站/恢复切片已获用户自用确认；Build10浏览/改名及更早阶段的历史门槛继续保留。其他设备范围分别记录。

Build10书库浏览/改名切片CI38666201246已通过Linux/macOS各85 Core、63 iOS和无签名设备Release，真实IPA/测试包及四张原生书库图已核验；用户随后反馈基本自用正常，具体设备矩阵不扩写，M3未全部完成。用户已确认既有连续阅读/重开、首次导入和Build8长TXT基本工作流；Build9后的反馈仅按基本自用范围记录，不扩写其他设备、逐个编码或性能。“计划”表示未实现，历史验证原件保留。

| 能力 | 当前 | 阶段 |
| --- | --- | --- |
| Files / Document Picker EPUB 多选导入 | 已写入；副本模式修复过 CI，用户确认 EPUB 可导入，来源未细分 | M0/M1 |
| 原创内置 EPUB 2/3 样书入口 | 已写入；同一导入流程的模拟器测试通过，设备阅读待验收 | M1 |
| EPUB 元数据、封面缩略图/标题占位封面 | 已写入 | M0/M1 |
| 网格/列表书架、书名/作者筛选、最近阅读/导入/书名排序与偏好 | Build10完整自动门槛及原生四图通过，用户基本自用接受；其他设备矩阵单列 | M3 |
| 修改书名、保留原件/完整位置/书签、写入错误可见 | Build10真实SQLite事务及App持久化/重叠刷新回归通过，用户基本自用接受；逐项矩阵未扩写 | M3 |
| 可恢复移出书架、回收站/恢复、v1→v2升级与启动文件保留 | Build11各91Core/67iOS/Release与原生三图通过，用户确认可用；原件永久保留，不释放存储 | M3 |
| 原生列表左滑确认、网格移出/恢复/排序/切换动效、Reduce Motion | Build12完整自动门槛/真实手势/六图及录屏连续帧通过，手机流畅度待测 | M3 |
| 封面选择/预览/保存/恢复默认、后台缩略缓存/失败重试 | Build13完整自动门槛及原生图/录屏通过；手机相册/Files/观感待测，旧图不自动回收 | M3 |
| 原件精确去重、TXT解码身份、旧库指纹补齐、并发提交、回收站显式恢复 | Build14各110Core/84iOS/Release与原生图/录屏通过；基本自用确认 | M3 |
| EPUB 2/3、reflowable | 原创样书解析/目录测试通过；真实排版体验待验收 | M1 |
| TOC、分页、章内上下滚动、章节跳转 | 已写入；跨资源及viewport回归通过，设备待复测 | M0/M1 |
| 真正纵向连续跨章 | Build4完整自动CI41/41，用户确认连续功能与重开位置可用；未单独报告的设备细项继续记录 | M1 |
| 内部链接、图片、CSS | Readium 排版；Build 3 视口修复与原创图像回归，用户原书图片待复测 | M1 |
| 搜索和结果跳转 | Readium SearchService 扩展、增量/取消/上限 UI 与 11 新回归已过真实 CI；页面命中定位待验收 | M1 |
| 位置保存/恢复 | 完整 Locator 持久化；Build4用户确认重开位置正常，其他设备细项待验收 | M0/M1 |
| 中央菜单、两侧点击翻页、手势分页 | 已写入；手势使用 Readium | M1 |
| 阅读进度/当前章节 | 已写入（未知进度不伪装为 0%） | M1 |
| 总章节数 | 当前仅报告目录条目；TXT canonical 章数在 M2 | M1/M2 |
| 书签添加/跳转/删除 | 已写入 | M1 |
| TXT 导入/正文阅读 | Build5已接入并过CI38559906005：编码选择/重试/取消、有界Readium资源/目录/书签/搜索/完整位置；设备/长书仍待验收 | M2 |
| TXT长篇/巨章/Apple临时内存 | Build8各68Core/56iOS/Release；四Release样本/hash/全窗口覆盖，第二窗口600点/3px重开；Apple RSS实测下降，设备性能待验收 | M2 |
| TXT UTF8/UTF16/GB18030、摘要与版本cache | 第二Core切片完整CI38547339868通过各60 Core/41 iOS/Release；首轮Apple iconv失败保留，更换公开CoreFoundation后向量通过；cache复用仍流式计算摘要 | M2 |
| TXT中文ANSI/GBK、Big5/CP950、Windows-1252与范围cache | Build9各80 Core/58 iOS/Release，Build10完整回归保持；GBK自动、Big5/1252手选，旧位置身份保持；缓存仍全文digest，不称手机秒开 | M2 |
| 八种标题识别、streaming、chunk、窗口 | 新增19项在各33 Core内通过，完整CI38538141364 attempt2为41/41 iOS及Release；首轮EPUB超时留档 | M2 |
| 内置通用字体/字号、字体导入/字重 | Build15通用字体与字号自动门槛通过，手机待测；导入/字重未做 | M4 |
| 行距/段距/边距/缩进/对齐/字间距 | Build15行距/段距/左右留白/缩进/对齐通过；独立四边距/字距未做 | M4 |
| 上下整屏/模式记忆/原生停屏与重叠 | Build19各122Core/iOS106/Release19通过；原生反向短空帧未验收，手机矩阵单列 | M4 |
| 阅读原生面板层次/按压反馈 | Build18各119Core/iOS100/Release18及原生截图视频/连续帧复核通过；手机手感待测 | M4 |
| 阅读方式持久化、滑动收菜单、减少阅读动效 | Build17各119Core/iOS99/Release17及实际原生录屏/78连续采样核过；独立偏好保存/重开/错误重试，手机待测 | M4 |
| 页面亮度 | 未实现 | M4 |
| 仿真卷页、上下整屏、自动慢滚、触感反馈 | 尚未实现；按独立后续切片推进 | M4 |
| 五种阅读主题 | Build15五主题、全局持久化、实际TXT/EPUB回归与原生图/视频通过；手机待测 | M4 |
| 默认中文实体书排版 | Build15默认两字缩进/1.75行高/0.8rem段距/柔和深色；实际页面过自动回归，手机体验待测 | M4 |
| 音量键翻页 | 未实现，先公开 API 可行性验证 | M4 |
| 百万字/数千章性能 | 有存储/索引边界；无实测 | M5 |
| Highlight/Note | 领域扩展设计；未建运行实体 | V0.6+ |
| Readium Decorations/TTS | 适配层可扩展；未接入产品 | V0.6+ |
| XBook、人物等知识、地图和剧情摘要 | 仅草案；不接受导入 | V1.0 后 |

基础 EPUB 和架构切片不能代替产品需求中的完整阶段一 MVP。必须完成 M1–M5 与稳定化验收后才可称“真正可用且稳定”。

2026-10-14首次文件交接增量：Build6 / [CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849)各68 Core、49 iOS及设备Release通过，EPUB/TXT共用引用模型结果交接；新增原生sheet首次/取消/空选择/重试回归。旧交接未在iOS18.5复现用户iOS16.6.1现象，设备首次导入仍待实测，M2长书/设备未完成。新包build/XianxiaReader-Import-Build6-TestKit.zip；旧Build4/5不变。详见Documentation/IMPORT_HANDOFF_FIX.md与HANDOFF。

2026-10-14后续首次导入：用户否定Build6设备首次体验；最新Build7 / [CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917)各68Core/55iOS/Release通过，直接从delegate启动导入、保持关闭后的delegate、统一sheet/持久错误反馈；完整书架/无dismiss/弱回调与原生命周期回归保留。新包build/XianxiaReader-Import-Build7-TestKit.zip，旧4/5/6均保留。用户随后确认首次导入正常，M2长书/设备及M3/M4门槛不变；详见IMPORT_DELEGATE_FIX.md与HANDOFF。

2026-10-14用户验收补充：Build7交付后回复“ok 能正常导入了 没问题”，首次导入问题已确认解决，deviceFirstImportAccepted=true；源码/安装包未变。格式/文件来源未逐项报告，完整M2长书/设备及M3/M4门槛不变；证据Documentation/ValidationLogs/m2-import-build7-device-feedback.json。
