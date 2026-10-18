# XianxiaReader · 仙侠阅读

## Build28 阅读进度依赖与菜单顶部（2026-10-18）

实际源`8acc3f2f7980b3d291155936184f36ddc42d4c84` / `codex/m4-reader-chrome` / [完整CI 39113019568](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39113019568)。Linux/macOS Core各137，iOS161/161（135集成+26真UI）失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release28/min16。三锁六pins、546编译资源blob、六原字体/OFL与每平台4组长TXT Release探针已核。Windows448语法新增0/54既有Vendor限制、17工具通过，语法不是编译；受改测试文件38个原test主体不变，3新增，其他旧回归完整重跑。Core/Adapter/Vendor/CI/schema/依赖均保持Build27。

进度从ReaderViewModel广泛发布改为独立稳定对象，只有章名/进度条小视图观察摘要；相同显示摘要不发布，但每个完整Locator及原异步SQLite写入都保留。真实ViewModel/SQLite的65事件回归：root通知0、摘要通知2，最后完整字节/版本保存且关闭后迟到事件拒绝。该计数不是手机FPS、全部卡顿根因或数据库写入减少。顶部浮动菜单补页面色底与24pt渐隐，无blur、不接收触摸，不改引擎viewport、安全区/排版/位置；原44pt和系统/额外减少动效保持。

安装[XianxiaReader-ReadingChrome-Build28.ipa](build/XianxiaReader-ReadingChrome-Build28.ipa) SHA256 `700551af9cecd5b98fd22b7043eba690657392064dc5091de8f45c2925dd3958`；[原创样书/字体许可/原生Preview测试包](build/XianxiaReader-ReadingChrome-Build28-TestKit.zip) SHA256 `7a57affea60a83fb6c6519edecf7709ac07266c2f57da412441396dc4f36636d`。覆盖安装保留书库，+菜单确认0.0.1 (28)，49旧交付包和全部未提交工作/1047原路径/18恢复ZIP保留。

实际原生复核：本源22张选定PNG/4表已实际查看，另直接查看浅深色正常菜单两原图；4条完整原录屏一秒总览15表已查看；3个原始窗口120帧/12表已查看。浅深色正常/减少动效静态菜单、第二章67%进度、目录跳转及所列手势可接受。正常显隐窗口各有一次源PTS回退，减少动效窗口仅1帧，仅接受列明画面，不推断全时序/FPS。

用户对Build27总体认可并要求继续，不推定全部手机矩阵通过。iPhone13/iOS16.6.1/TrollStore的阅读/设置帧时间、内存/功耗仍待专项；Build27标准字体打开/导入已由用户确认成功（实际来源/样例），微信QQ/Alook与TTF/OTF逐项组合、普通签名/全部File Provider/VoiceOver/系统大字/旋转/减少动效完整矩阵仍单列待核。旧章首留白/分页快照不由此追认；慢滚隐藏菜单时状态栏透字仍可见，全页安全区未验收；无Share Extension、字体删除/无限字体、可变轴、单书覆盖或M5功能。先收本片菜单/跨章进度/设置手感反馈，再按PERFORMANCE_TEST_PLAN测正文DOM采样、主线程与渲染；本片不盲改定位管线。取舍及Apple官方来源READING_CHROME_DESIGN.md。M4整体未完，取消关机继续生效。

以下Build27及更早为历史，本地大原件范围服从最新CI保留回执。

## Build27 字体收藏与排版、书架阅读边界（2026-10-18）

Build27本切片已交付，实际源`bc611bc2acb886d0d8a4e15798633ac29979c24a` / `codex/m4-reading-experience` / [完整CI 39107016454](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39107016454)。Linux/macOS Core各137，iOS158/158（133集成+25真UI），失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release27/min16。三锁六pins、544源码/资源/config blob、各平台4组长TXT Release探针及六完整字体/原OFL原字节已核。Windows446语法新增0/54既有Vendor限制、17工具通过，语法不算编译。受改测试文件中73个原测试主体保持，6原主体仅依赖/新导航与折叠预期适配、12新增，无删除旧test；旧异步打开/关闭/重试/迟到位置/字体回归全部重跑。

导入字体缩成“我的字体”入口，独立两列惰性网格/大字单列/名称查找，样例最多按绘制字号显示，避免宽容器上采样。内置六款与12款导入/每款32MiB限制、透明预览及12图/8MiB后台缓存保持。排版加入舒适/宽松/紧凑三个显式预设，首页留字号/行距/左右留白，段距/字距/字重/缩进/对齐在“更多调整”。打开面板不改旧自定义，点预设才改段落/留白，字体/字号/底色保持；原书排版禁用规则保持。

阅读主题改为自身呈现控制器的公开override与局部环境，不改窗口/书架root。每次开书新presentation UUID，保存后原生dismiss并清空同会话、既有onDisappear统一close/失效，过渡保留正文；重复返回有守卫/保存中反馈，失败仍可见重试。标准外部TTF/OTF文档声明与AppRoot onOpenURL队列支持冷/暖启动，立即持有scope、串行复用原后台协调复制/CoreText/摘要去重，完毕配对释放；外部字体先加收藏，不自动改正文，明确选中才在完整锚点受控重开。Core仅Apple系统流式文件摘要后端，DB/schema/Readium版本/依赖/Locator格式不变。Vendor只补既有横排分页位置通知的附窗/可见前后守卫，拒绝隐藏字体重排的页头覆盖原锚点；UPSTREAM已登记摘要，原隐藏重排/重开测试完整保留。菜单叠加层独立于正文加载布局。设置完成先等待设置持久化，原生关闭后才从可见阅读界面fresh保存完整位置；不扩大3秒采样预算或用旧缓存位置替代，失败可见且旧进度保留，完成按钮有保存中反馈与设置写入错误提示。

安装[XianxiaReader-ReadingExperience-Build27.ipa](build/XianxiaReader-ReadingExperience-Build27.ipa)，SHA256 `7c3d6684929492d36181974e892226800a36e543f76ed22ebb3c1394f9a52e63`；原创样书/本轮实际接受原生Preview/原字体样本与许可[XianxiaReader-ReadingExperience-Build27-TestKit.zip](build/XianxiaReader-ReadingExperience-Build27-TestKit.zip)，SHA256 `4abcce4a33ce87e9fee896db9a5544130e953db912ee5c951d861910da809ca8`。覆盖安装保留书库，+菜单确认0.0.1 (27)。47旧交付包及全部未提交源码/原路径/17恢复ZIP保留，ZIP CRC/内部IPA/原材料逐摘要核验。

实际原生复核：本源64张选定PNG/11表已查看（另直接查看字体网格、查询和紧凑预设3原图）；6条完整原录屏的一秒总览27表已查看；4个原始解码窗口318帧/29表已查看，保留PTS、不补帧。字体独立收藏/查询/三预设/高级0.05重开、暗黑书架搜索与三次阅读往返、设置完成关闭、本次Files取消/封面重开、五主题阅读面板/书签删除和搜索清空所列行为可接受。旧正文顶栏遮挡/安全区、退出小保存spinner及书架重排瞬时交叠不作为全动效验收；TOC窗口源PTS有一次回退，仅接受画面状态。其余114张PNG及3条选定录屏未逐看，手机FPS/功耗/所有来源应用和设备矩阵未验收。

本轮用户再次确认测试设备为iPhone13/iOS16.6.1/TrollStore；字体主要来自微信/QQ/Alook，正文及设置都感觉不够顺畅。配置确认不等于Build27设备验收。当前模拟器真实系统暗黑搜索/取消/浅深阅读反复往返和本轮记录仅证明所列测试与素材，不等于手机根因唯一已定或所有设备修复。字体服务输入不冒充实际外部来源点击；标准Open In入口的列出取决于来源应用，未加Share Extension。普通签名/TrollStore、所有File Provider/大字/VoiceOver/旋转/减少动效矩阵仍待核。

性能本片落实短预览停止上采样、收藏独立惰性构建和低频项折叠；没有手机Release/Instruments帧时间、内存/功耗证据，不归因60Hz，不声称正文/菜单卡顿已全部修复。连续滚动每次回调请求DOM定位、execute未串行化已执行async采样是具体待测线索，未盲改位置管线；另外消除了目录未变时的重复字体校验、改系统流式SHA并保留完整性/跨块取消回归；m4-experience-build27-performance-review.json留有路径/摘要/下一单飞尾沿合并的回归要求。旧字体CI超时与录屏中的启动延迟、旧阅读安全区/分页快照限制仍独立，不由新通过追认。

首候选b799754/39086068358实际152/156且无Release：1新预设原始JSON键顺序比较、2高级行点击未展开、1新3字体首次ready超时。分别规范化测试JSON、改整行44pt展开、系统流式文件SHA及省去重复设置校验；原20s预算与功能断言保留。历史完整文字日志/summary/metadata与验证记录保留，旧xcresult/失败图的本地大原件以最新CI保留回执为准，不将新通过倒写成旧候选通过；第二候选cb63367/39089264017实际14/15，仅字体自动search drawer的AX滚入失败；第三候选固定44pt原生查询栏，加入既有中文输入回归16/16通过。随后c518d70/39092416032完整155/157：原隐藏字体重排定位及切模式后目录两项失败，无Release/IPA；自动分页通知的隐藏页守卫、菜单viewport overlay及退出闪排版边界另修，新增定向包含原两字体和原菜单共19项，与最后完整门槛分列。不将重跑成功追认为所有旧时序失败唯一根因已定。随后18c130c/39098863950仍155/157，无Release/IPA：原TXT continuous初次位置20s超时、原封面Files已呈现但内部空白；该continuous不经过新增paged守卫。bc3c573仅补无正文同步失败状态、原退出码不变的有界文档服务/进程上下文及5项定向，生产App/Core/Vendor不变；其定向与最后完整门槛仍独立，不把下一次通过追认为旧两项唯一根因已解决。bc3完整39103144069随后实际156/157、无Release/IPA；原TXT和封面Files已过，唯一新用例失败的原录屏/89连续帧和AX证实设置Done因fresh位置未稳定而留在面板，错误落在屏幕下方、返回按钮被遮挡。随后分开设置提交与原生关闭后的fresh保存，新增覆盖页不可采样/偏好写入失败/完整位置失败与重试回归；不削弱原保存错误或3秒预算，不把原失败归成单纯AX问题。字体删除/无限导入/可变轴、单书覆盖、自定义配色等尚未实现；M4未完，下一步优先手机主题/重开/微信QQ/Alook反馈与正文/菜单性能专项，不进入M5。具体取舍/精确Readium3.11及Apple官方来源见READING_EXPERIENCE_DESIGN.md，完整结果见M4_READING_EXPERIENCE_VALIDATION_REPORT.json。用户取消关机持续生效。

以下Build26及更早为历史，旧本地大原件描述服从最新CI保留回执。

## Build26 阅读面板主题统一（2026-10-17）

Build26本切片已交付；实际编译源`1e4ae348a39679df8476bda6c74380d4615078b0` / ref `codex/m4-reading-panels` / [完整CI 39038829961](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39038829961)。Linux/macOS Core各135、iOS148/148（125集成+23真UI），失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release26/min16。三锁六pins、536源码/资源/配置blob、每平台4组长TXT Release探针及IPA六字体/原OFL原字节已核。Windows438语法新增0/54既有Vendor限制、17工具通过；语法不算编译。11个原UI test主体保持；新增2项真UI与1项原生输入集成回归。

目录、书签和书内搜索统一使用阅读菜单的灰绿浅深表面、柔和正文色、清晰间距与空状态，系统原生List复用/滚动/安全区和书签左滑删除保留。目录保留原ordinal/深度/所有条目，不把TOC序号当canonical章序或猜当前章。搜索框固定顶部、清空经既有setQuery取消旧会话/结果；提交收键盘、匹配词灰绿加粗。增量批次/1000条上限/加载更多/停止/错误/关闭取消、原生完成/下拉关闭、原导航/完整位置/删除事务保持。新搜索按压显式尊重系统与持久化额外减少动效。书签删除显式柔和砖红色，避免全局浅绿tint/白字对比不足。不增加逐行阴影、自建整表、依赖或正文重排；Core/DB/schema/Reader与Search ViewModel/ReadingInterfaces/Readium/Vendor/字体/资源窗口均未变。

新真UI覆盖五主题目录/空书签/搜索首屏/44pt，以及真实设置开启额外减少动效→删除书签→退出/重开持久化、搜索结果→清空→新词无匹配→重搜跳转与回看入口。新增真实UIWindow内的中文marked-text/光标→换色保持→清空→新词/收键盘回归也通过；原生输入按系统正文字号增高，原UI的44pt断言保留。既有目录/书签/搜索完整定位、取消与字体/三阅读模式回归均重跑。本片未声称解决用户报告的菜单轻微卡顿；Build25基本可继续使用而流畅度仍待优化，证据m4-settings-build25-device-feedback.json。

安装[XianxiaReader-ReadingPanels-Build26.ipa](build/XianxiaReader-ReadingPanels-Build26.ipa)，SHA256 `5a5483916f7b22e527ad938094b5eece897e5cd6a35214512ff22eb74c37d61e`；原创样书/21张本源原生Preview/沿用字体样本与原许可包[XianxiaReader-ReadingPanels-Build26-TestKit.zip](build/XianxiaReader-ReadingPanels-Build26-TestKit.zip)，SHA256 `913275a151771470a2c61e1251394af1d403721acfd12ce6cd02a95b00bb497f`。覆盖安装保留书库，+菜单确认0.0.1 (26)。45旧包及未提交源码/恢复备份保留，ZIP CRC/内部IPA/原材料逐摘要核验。

原生人工复核范围：本源21张新面板PNG/4表已实际查看；五主题目录层级/空书签/搜索首屏、深色砖红左滑删除/删除后重开为空、搜索结果/无匹配及稳定跳转PNG可读。两条原录屏89.80s/63.64s全部1fps总览11表，以及目录入场33帧、左滑13帧、清空键盘17帧共63原始VFR帧/7表已查看，保留源PTS、无fps滤镜或插值。113张旧功能PNG及其余16阅读/5书库录屏保留而未逐看。本片加载/重开/搜索跳转片尾spinner与渐显不作为稳态正文验收；旧正文标题/菜单安全区、全动效及手机FPS不追认。

手机菜单/字体列表实际卡顿、FPS/内存/耗电、普通签名/TrollStore、系统大字/VoiceOver/减少动效/旋转和全部File Provider矩阵仍待专项验收。旧阅读暂停安全区/分页快照问题按各自证据保留，不因新面板通过而追认；字体删除/集合/可变轴、单书覆盖、自定义配色/独立四边距等尚未实现。M4未完，先收本片手机面板/键盘/左滑反馈并核旧安全区，再按M4设置与主题路线推进，不提前M5。

首候选3c250618/39023086030由Agent在审查发现新增搜索遗漏持久化额外减少动效传递后取消。实际completed/cancelled、两平台Core各135、iOS完成0/无设备Release成功标记、源码compiler诊断0；完整日志/metadata/整包校验后的历史文字诊断留存。不是源码失败，旧结果不继承为本源门槛，见m4-panels-build26-first-agent-cancel.json。初始界面和受改原测试保留，无降低断言或删除测试。另ac8b387e/39023478476实际145/147：旧字体隐藏重排非零字定位超时、新TextField原生AX22pt未满足44；无Release。原引擎和该旧test与Build25相同，未证实旧超时根因；修正原生字段尺寸/中文组合与删除tint后本源独立全过，不把重跑通过写成旧字体时序根因已修复。完整失败日志/summary/4张实际查看图及artifact摘要见m4-panels-build26-history-39023478476.json。

另5176821d/39027324303实际146/148，两项新真UI均过，但新输入测试未创建UITextField即超时、另一旧字体重开失败；输入定向39037628899证实新测试缺少真实scene挂载，修测试窗口/恢复key后本源独立全过，原中文/光标/44pt及2秒预算保持。旧两字体定向39037690400实际1/2，分页快速重开blank且两条WebContent启动日志47.520322/47.657906秒，另一隐藏重排9.241s过。未改原字体测试或引擎，未证实旧字体/环境时序唯一根因；本源全过只表本轮门槛，不把重跑写成该根因已修。两条定向诊断均无Release/IPA、不替代完整门槛，完整原summary/日志摘要与来源见ValidationLogs/m4-panels-build26-diagnostic-*及history-39027324303记录。

本地CI按AGENTS保留本轮完整诊断；历史原件保留范围服从m4-panels-build26-ci-retention.json实际回执，文字日志/summary/metadata及交付包/源码/恢复ZIP保留。旧文“大原件在本地”只代表当时快照。用户取消关机持续生效，本轮不发关机命令或调度。

以下Build25及更早为历史。

## Build25 紧凑设置与透明字形（2026-10-17）

Build25本切片已交付；实际源 f90a33cd476f2ffa468f5577fe4002dd47b690f0 / ref codex/m4-settings-compact-rules / [完整CI 39014160303](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39014160303)。Linux/macOS Core各135，iOS145/145（124集成+21真UI）、失败/跳过0，test/export/summary/recording均退出0，严格无签名iPhoneOS arm64 Release25/min16。三锁六pins、532编译/资源blob、每平台4组长TXT Release探针与IPA六字体/原OFL原字节已核。Windows435语法新增0/54既有Vendor限制、17工具通过，语法不算编译。受改两测试文件9原主体保持、2新增；其他既有测试继续执行。

按用户“样例内框不好看、上下滑动字体列表卡顿、设置别拉太长”的实测反馈，字形改为全透明CGImage，由原生着色；后台CoreText直接绘制并缓存，滚动路径不再PNG编解码。一个CGFont、最多12图/8MiB像素；换主题只着色，字库/字号/可用性改变才请求新图。加载/就绪/失败固定同一槽位，切换请求不冒用旧字形、取消后不发布。旧PNG导出仅供诊断，不在UI热路径。

六款字体通常两列，辅助功能大字为单列，保留实际字形、选中语义和44pt控件。名称前置，风格说明转无障碍标签；分组入口固定顶部。主样例只留柔和纸色，去掉内图底色/边框/阴影；排版和手感页去重复样例，留白与段落调整合成紧凑连续行。字体/字号/字距/字重/缩进/行段距/对齐和原书样式范围、默认值、全部reading-v1旧偏好保持。无Core/DB/Readium/Vendor/Locator/依赖变动，资源目录18/正文窗口12保持。

新增真实iOS透明像素/六字体24次重复浏览复用同一CGImage/12图及8MiB上限回归，真UI核两列、反复滚动行高不变、换色、固定分组及当前模拟器排版页一屏可操作。代码中的重复解码/行高变动已移除；没有手机Instruments证据，不把这些检查写成全部卡顿根因或手机FPS验收。

安装 build/XianxiaReader-SettingsCompact-Build25.ipa（SHA256 7a73f85220864770717def140409a429e83852017229399cb82c55b68f735284），原创样书/21张本轮原生Preview与6张透明字形诊断/原许可与导入字体样本包 build/XianxiaReader-SettingsCompact-Build25-TestKit.zip（SHA256 4982895832fa29582967d53767e9d0ee62b9ad26e6410fc31003e56e9fbb5fc8）。覆盖更新保留书库，+菜单确认0.0.1 (25)。43旧包与未提交源码/恢复备份保留。

原生复核：113张原生PNG/19表均已实际查看；本轮字体两列/六字单行/无内框与紧凑排版、浅深色/持久化等所列状态可接受，21张原生界面/正文Preview与6张透明CoreText字形诊断分开。16条阅读UI原视频保留，本轮只看4条完整1秒总览/19表，以及3个选定原始VFR窗口83帧/8表，保留原PTS、无fps滤镜或插值。滚动末段/回弹、初加载槽位和深色过渡尾段已逐帧看过；未宣称全手势、全部视频、全动效或手机FPS通过。旧TXT字体隔离图空白、加载中及若干安全区/顶栏画面明确未作为可读稳态验收，原生页与透明字形诊断不混同。

手机首次进入/快速反复滚动的实际流畅度、内存/功耗、普通签名/TrollStore、系统大字/VoiceOver/减少动效与旋转完整矩阵仍待验收；不把自动检查或原生素材当手机性能。旧暂停安全区与分页快照问题仍按独立范围记录。字体删除、集合/可变轴、单书覆盖、自定义配色/独立四边距尚未实现。M4未完，下一步先收本片手机滚动/易读反馈并核旧安全区，再按计划统一目录/书签/搜索主题，不提前M5。

本地CI保留本轮39014160303完整诊断，历史大原件按AGENTS收敛，旧文字日志/summary/metadata/验证记录保留；精确边界见m4-settings-build25-ci-retention.json。历史“大原件仍在本地”描述只代表当时快照，不能越过清理回执；交付包/素材/源码/恢复ZIP不清理。历史结果不继承为本源门槛。

以下Build24及更早为历史。

## Build24 六款字体、真实样式浏览与排版扩展（2026-10-17）

Build24本切片已交付；[完整CI 39005962891](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39005962891)，实际编译源`76a423fec2b855eb6e429d40741a02145727830e`，验证ref `codex/m4-font-browser-save`。Linux/macOS Core各135，iOS143/143（123集成+20真UI）、失败/跳过0；test/export/summary/recording均退出0，严格无签名iPhoneOS arm64 Release24/min16。三锁六pins、532个编译源/资源blob、每平台4个长TXT Release探针和IPA中六字体/原OFL原字节已核。Windows435语法新增0/54既有限制、17工具通过，语法不等于编译。受改56个原测试主体保持、11新增；原1个文件选择器测试只加强真正按钮/消失/可点击同步，取消/选中/深色/恢复/重开断言保持。

阅读设置→外观现在可直接浏览思源宋体、霞鹜文楷、思源黑体、朱雀仿宋、马善政楷书、站酷小薇的真实中文样例；导入字体也显示实际字形。主样例随选中字库/字号/配色变化，明确段落排版以正文为准。字号放在六行列表前。六完整原字体约83.9MiB，官方固定版本/OFL记录在App/Resources/Fonts/PROVENANCE.json，不裁字，缺字系统补全，旧两UUID保持。

排版新增字距0–0.5、字重50–175%和首行缩进0–4字/0.5步长；行距扩至1.2–2.8、段距0–3、左右留白0.25–2.5。原字重缺省和reading-v1旧JSON兼容，原书样式禁用规则保持。中文横排补入同版官方默认CSS中的字距/首行缩进规则，UPSTREAM登记了资源差异；竖排/RTL未扩展此模块。单字重字体的粗细能力由字库/系统决定。字体/排版变更沿用完整锚点；新增连续模式六款逐次换字/CSS/原Y及重开回归，分页在前次字体仍隐藏排版时再次切换也保持原非零文字。取消/关闭/迟到回调和旧位置竞态保持。

保存/退出现在先取得当前完整文字锚点，再写入数据库；不直接用重排后的滞后缓存。暂未就绪时有界等待，失败保留原记录并显示重试，关闭/重开/重叠/取消的迟到结果均过滤。新增5项生命周期回归，旧字体逐次换字重开断言保持；失败样本与取舍另见m4-font-preview-build24-fresh-save-design.json。文件选择器使用真正系统取消按钮并等其消失及完成按钮可点击，不能只凭背后控件存在就继续。

安装`build/XianxiaReader-FontBrowser-Build24.ipa`，SHA256 `55ec9079e00e5e29e83c91acce45712b85e1c0885c07ec75b760e0c5ef4a280a`；原创样书/本轮原生Preview/原许可与拉丁导入样本包`build/XianxiaReader-FontBrowser-Build24-TestKit.zip`，SHA256 `bc0c8b54320e198a90919ce2de5b9db3197746c57c4edc97c64b8ec3b117a099`。覆盖安装保留书库，+菜单确认0.0.1 (24)。41旧包与未提交源码/恢复备份保留。

原生人工复核：110张原生PNG/19表已全部查看，其中4张旧功能孤立图按实际黑屏/加载中/状态栏重叠明确不接受为稳定正文，未放入本轮Preview。新20张Build24六款正文/真实CoreText字形/设置行/排版重开均可读。15条阅读UI原录屏留存，本轮只看3条完整1秒总览11表，以及5个选定窗口301个原始VFR帧/28表；无fps过滤/插值，原PTS顺序核验。六款样式区别、紧凑透明样例、字距/字重/缩进及重开、系统选择器取消保留与衬线重置的所列最终状态接受。样例准备/行高重排/主题过渡与旧暂停安全区仍有限制，不把自动全过或采样视为全动效/手机验收。

手机首次字体加载、内存/实际流畅度/FPS/耗电、全部File Provider、普通签名/TrollStore、系统减少动效/VoiceOver/旋转矩阵仍未验收。所有保留视频不等于逐条复核；具体原图、视频和原PTS窗口及未接受画面见m4-font-preview-build24-native-review.json。字体删除、集合、可变轴、单书覆盖、自定义配色/独立四边距尚未实现。M4整体未完，后续优先按手机字体体验反馈与目录/书签/搜索主题统一推进，不提前M5。

本地CI按AGENTS保留最近交付的完整诊断，历史仅保留文字日志/summary/metadata/验证记录；旧文“大原件仍在本地”均受local-disk-cleanup-2026-10-17.json及m4-font-preview-build24-ci-retention.json清理回执约束，安装包/源码/恢复快照保留。历史候选各自结果独立，不能替代当前主源门槛。

以下Build23及更早为历史记录。

## Build23 内置字体与导入（2026-10-17）

Build23内置思源宋体、霞鹜文楷与本地字体导入已交付；[完整CI 38918803378](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38918803378)，实际源`62700a159cffc72ef256eabdc24184bf6092b0a7`，验证ref `codex/m4-font-readable-capture`。Linux/macOS Core各133、iOS 134/134（115集成+19真UI）、失败/跳过0；test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release23/min16。三锁六pins、522源码/资源blob、每平台四长TXT Release探针、内置字库/原OFL在IPA内原字节已核。Windows433语法新增0/54既有语法限制、17工具通过；语法不算编译。

阅读设置→外观→字体与字号可离线直接选两款内置，约48.1MiB原字库，不裁字、不占12款用户导入名额。原默认/衬线/无衬线保留；我的字体可导入TTF/OTF单字体，≤32MiB/款。后台协调复制/流式摘要/CoreText验证，目录与全局选择保存；重复复用、缺失重导修复、取消保持、失败提示。缺文件/损坏暂用默认且保留原选择，自定义资源明确配色预览，正文实际字体/缺字fallback独立生效。44pt/主题/减少动效按压沿用原界面。

App只读Bundle稳定UUID与导入资源合并≤14 faces，原正文窗口仍≤12；内置不在开书时复制或扫描50MB。首次定位在FontFaceSet.ready后恢复，15秒上限/取消与可见错误；位置捕获等待实际native可读（最多3s/32ms），避免连续换字读到隐藏初始化页的章节头；关闭迟到字体回归单列。每个FileURL独立UUID资源路由、章节复用，两个同名导入TTF的URL/中文字形/切回字宽保持有真实回归。Core Foundation相对路径与fonts-v1目录，reading-v1可选UUID兼容资源身份，无schema/小说/缓存/完整Locator变更。ReadingInterfaces→Adapter公开Readium3.11 CSSFontFace/既有资源通道；无全局注册/HTTP/JS资产或依赖升级；Vendor三个Swift文件维护已有重载路径、字体就绪、独立路由及可读位置采样守卫，UPSTREAM明确登记。新增字体暂停慢滚、采完整锚点先保存再受控重开，资源字体排版走完整锚点重载，系统字体连续编辑保留原重排；每await核会话/请求，迟到关闭不改新reader，失败恢复旧目录/位置。原回看返回点保持。受改35原测试主体保持，16新增（6Core+8集成+2真UI）。取舍与固定来源见READING_FONT_IMPORT_DESIGN.md及m4-font-build23-bundled-provenance.json。

下载`build/XianxiaReader-LocalFonts-Build23.ipa`，SHA256 `116de6e07de131019ea70197f9e36cb07a89fc7c773a1311c2922d8be74958f2`；原创样书/15实际Preview/1未验收诊断/许可与拉丁导入样本包`build/XianxiaReader-LocalFonts-Build23-TestKit.zip`，SHA256 `9be4d45909b6dffff8adc6008cddcf1a25d718c8f258930a5d269875dab52286`。覆盖安装，+菜单确认0.0.1 (23)。39旧包与所有未提交文件保留。

原生人工复核范围：当前CI的78张原生PNG/13联系表全部人工查看；含两内置EPUB连续/分页和TXT共6张可见中文正文，文楷与宋体字形有区别，深色柔和。iA EPUB两模式也有实际正文，但iA TXT隔离图只剩底色，旧巨段TXT隔离图仅两行，两图明确不作可读全页通过。19条真UI原视频保留，本轮只复核其中4条、共207.98s的完整1秒总览15表，以及4个窗口235个原始VFR帧/22表；无fps滤镜或插值，原PTS保留。字体选择/取消/重开、返回及减少动效退出的选定最终状态可接受；个别过渡原帧有区域重复/重叠，未验收全动效无瑕疵，原因及手机观感仍待核。

实际CoreText中文glyph、Bundle原件/许可、WebKit FontFace loaded/CSS与中文canvas签名、EPUB双模式/TXT非零byte+UTF16/字号/逐款换字与静止重开有回归。内置OTF真实页面已核；外部有效字体由真实服务/VM集成输入，真UI覆盖选择/持久化/深色/默认及原生文件选择器取消，不假称UI已点击导入所有File Provider。手机首次加载/内存/FPS/功耗、普通签名/TrollStore/辅助功能/旋转/全样书矩阵仍待验收；字体集合/可变轴调节/删除/单书覆盖尚未实现，M4整体未完。

历史分列：38880257296由Agent补强而取消；38881623233=129/131（两新初始定位）；e758/38886008057=128/131（连续字体150%位置/TXT构造/UI滚动）；277/38887978313=131/133（两新初始定位、原124全过、内置CoreText与两字体UI过，另有新TXT helper警告）。43e/38890891607、bc6/38892156952、2b5/38892611316、255/38893802693的集成host均在测试前因libswiftWebKit缺失abort，后续UI进程缺失；bc6最终cancelled且原因未核、未由本Agent取消，其余failure，不冒称134主体实际执行。原ZIP/summary/full.log与各receipt保留；查官方WebKit293831后当前改用原evaluateScript观察fonts.ready Promise，不改模拟器/最低iOS或锁。7ab/38901198541实际130/134、0跳过/0源warning，关闭字体ready迟到及两字体UI/CoreText通过，但两旧瞬时回归和两新测试失败，完整原件保留；当前ff824只修两新测试取样（每次独立换字采fresh完整point、TXT等待p存在），首非零/首次字号/静止重开/同名URL/实际字形/字宽断言及旧35主体均保留。旧回归根因未定，不追认旧失败。后ff824/38906278076实133/134、旧124全过，只新EPUB整字外框可见判定错误；原char476/DOM476/offset-9.84375已保留。新测试改视口相交并加continuous3px原Y，19db再等待实际window和scrollView.alpha1后取原生正文，避免DOMready但showSpread未完成的spinner/空图；这段仅测试变化，此前测试修正区间运行源码保持7ab；后来92ad原始log确认隐藏初始化页采样可能取得h1/char0，现Vendor分页采样核window/alpha1，Adapter最多3s/32ms等待并在每await核会话/取消，新真实关闭capture回归保持。此运行源码变更用新全量门槛，不追认旧结果。当前完整独立结果才用于交付。单独临时ref用于保留各旧轮结果，本版手机门槛不继承Build22基本功能反馈。

以下Build22及更早为历史。

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
