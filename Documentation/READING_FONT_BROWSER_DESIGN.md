# 设置内字体浏览与排版扩展（Build24）

2026-10-17。用户明确指出两款内置不足、设置应直接展示字形，并要求更多自定义。这是M4独立切片，不提前知识库或在线字体商店。当前完整独立自动门槛及所列原生复核通过并交付，手机矩阵仍待验收。

内置增至六款：原思源宋体、霞鹜文楷，加思源黑体、朱雀仿宋、马善政楷书、站酷小薇。四新增字体和原OFL从官方固定revision或发布资产取原字节；朱雀官方v0.212 ZIP只含TTF，原OFL另从同一tag对应commit取得；ZIP SHA与GitHub发布摘要一致。PROVENANCE.json记录源URL、revision、字节数和摘要，原件未裁字/转换。旧两UUID保持，新增使用后续稳定编号。Adapter资源目录上限18（6内置+12用户），正文窗口仍12。

字体列表每行显示实际字体绘制的同一中文样例，主预览随选中字体/字号/配色变化；导入字体也走同一真实文件路径。SwiftUI的系统字体仅用于名称、说明和系统字体选项，不以普通系统字冒充自定义字形。预览明确是字形样例，段落重排以Readium正文为准。字号放在长列表前，避免为了浏览六款而遮住常用字号操作。

使用Apple公开CGDataProvider/CGFont/CTFontCreateWithGraphicsFont/CTFramesetter，在独立actor上从真实文件绘制短原创中文样例，再返回小PNG给原生设置界面；不注册进程全局字体、不增加WebView/HTTP服务、不把整本正文读入预览。保留一个CGFont和最多12个预览结果；Lazy列表按需请求，关闭/换字取消及await后检查，失败明确显示预览不可用，不偷偷换成系统字。UIImage解码只处理小图，手机首次字体解析/内存/滚动流畅度仍须实际设备核验。

自定义新增字距0–0.5（Readium公开值，CSS为一半rem）、字重50–175%（保留原字重为nil，Readium倍率乘400），首行缩进0–4字/0.5步长。行距扩为1.2–2.8、段距0–3、左右留白0.25–2.5，保留原书样式禁用规则、系统字体/主题/缩进开关和恢复默认。单字重字库的实际粗细范围由字体/系统决定，不承诺可变轴；预览只承诺原字形/字号/配色，不冒充与WebKit每个段落像素一致。

reading-v1只新增可选字段，旧JSON缺字段继续按原字距、原字重、两字/无缩进恢复；不升schema、不删设置。新的非有限或越界值拒绝写入并保留原文件。Adapter沿3.11公开Preferences映射；字距/字重纳入资源字体完整锚点重排判定，原EPUB DOMRange/TXT byte+UTF16、关闭取消和回看返回点保持。无排版JS或依赖锁升级；仅补充下述同版中文横排CSS模块并登记Vendor差异。

当前验证：受改56个原测试主体保持，1个原文件选择器测试只加强系统Button/真正消失/hittable同步并审计双hash，全部原操作和断言保持；共11新增（2Core、真实六字体CoreText预览、六字体正文/CSS/完整锚点、隐藏重排中再换字、六款设置持久化UI及5个新鲜保存生命周期回归）。Windows435语法新增0/54既有Vendor限制、17工具通过；Linux/macOS Core各135、iOS143/143（123集成+20UI）和严格无签名Release24实际通过。六款原字形/正文/设置和所列录屏原帧已人工复核，4张旧隔离图明确未接受；详见本文实际结果及独立native-review，不把素材检查当手机流畅度。

参考与取舍：

- [Apple公开CoreText字库入口](https://developer.apple.com/documentation/coretext/ctfontcreatewithgraphicsfont(_:_:_:_:))与[Framesetter](https://developer.apple.com/documentation/coretext/ctframesettercreateframe(_:_:_:_:))：直接绘制文件字形，无全局名称冲突；使用有界短样例，不自建EPUB排版。
- [Adobe思源黑体](https://github.com/adobe-fonts/source-han-sans)、[朱雀仿宋](https://github.com/TrionesType/zhuque)、[Google Fonts马善政](https://github.com/google/fonts/tree/main/ofl/mashanzheng)、[站酷小薇](https://github.com/google/fonts/tree/main/ofl/zcoolxiaowei)：取未修改原件及原OFL，各固定来源见Fonts/PROVENANCE.json。
- Readium偏好实际签名/值域/倍率以仓内锁定3.11的EPUBPreferences、EPUBPreferencesEditor、ReadiumCSS为准，避免自写全书CSS或升级依赖。

字体删除/集合/可变轴、单书覆盖、自定义配色、独立四边距等留后续M4小切片；普通签名/TrollStore/系统辅助功能/旋转、大字库手机首次加载与耗电/FPS仍单列。旧Build23截图/残影限制保留，不追认根因修复。

补充快速连选：Adapter对preserve返回false不再继续提交新字体，采用3s/32ms有界等待及每await会话/取消检查，超时可见。避免字体前次恢复尚未完成时以隐藏初始化页覆盖正确位置；真实800ms字体ready阶段再选择第三字体回归保留原非零词。所有旧38测试主体保持，完整门槛按最新候选。

## 构建前最终断点

872fc755f12f3afa83eb1aa736015d5a50ec4502 已实际触发独立完整CI38954435197，新的135 Core/118集成+20 UI/Release24门槛只归该源。此前3a97与c661候选未取消，各自旧137项预期保持，不能把最新新增竞态测试追溯算入旧轮。Linux135及四长TXT已核，Apple/原生/手机仍待相应独立结果。最新快照已推送，正常HEAD和空index不变。

原生早查发现compact样例原底色与选择卡不同，出现硬矩形。现在列表PNG透明背景，直接融入既有灰绿圆角卡；大样例仍填阅读主题底色。同一真实CoreText回归核compact的透明背景与实墨，最终效果须从最新源原生截图核验。早查使用首候选选定ZIP成员CRC，仅诊断、无全ZIP验证，不替代主源。

分页竞态新测试准备修正：872结果表明失败发生在第一次真实换字之前，初始800ms字体ready未结束即发翻页，href已更新但当前页仍隐藏，goForward可返回false。核官方3.11固定revision的Navigator.swift（https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/Navigator.swift）和现有spreadLoaded/window/alpha gate；新测试改等待初始真实可见与字体ready，再逐页确认scrollX增长。没有减小char>100、800ms重排中再换字或最终原字可见断言，原测试38主体保持，运行源码未改。

## 中文样式包差异的实际修正

cc7/454完整日志显示六字体连续检查已取得非零完整锚点，但组合排版断言不满足。核官方固定d82f44/3.11资源及本地相同副本，cjk-horizontal/ReadiumCSS-after.css没有--USER__paraIndent/--USER__letterSpacing规则，默认after.css已有模块；Swift公开偏好仅设置变量，不能使缺失的选择器自动生效。现在把同版默认资源中这两组原选择器/声明原样加入中文横排资源，仍须readium-advanced-on且变量存在，沿用原书排版时不强行覆盖。只改一个CSS资源并在UPSTREAM记录本地sha/取舍，无JS/依赖/渲染器重写；真实WKWebView仍核缩进3.5rem、字距0.125rem、字重600和原Y3px，而非只核UI值。

官方固定来源：https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/Assets/Static/readium-css/ReadiumCSS-after.css 与同目录cjk-horizontal/ReadiumCSS-after.css。中文竖排/RTL不在本次资源补丁范围。

分页新测试即便等待初始ready，2次真实移动仍处大段起始char2，属于准备几何与>100要求不符；采用已有字体锚点回归的3页准备方式并减少无关翻页动画，保留800ms加载窗口和最终原非零字可见。后续结果必须独立实际验证，不把准备修正称阅读运行故障修复。

## 换字后立即保存与选择器同步补强

同源重试39003048184实136/138，原换字重开断言在377行回到h1/char0，不改该断言；saveNow此前仅持久化cached currentPosition，现经ReadingInterfaces采样新鲜完整锚点，未就绪3s/32ms有界等待、失败保留原记录/可见重试、每await核会话/保存UUID/取消，旧结果不写新进度。固定布局保持完整页Locator。新增5生命周期回归，完整当前CI已实际通过Core135各/iOS143=123集成+20UI；此节保留失败诊断与修正原因。原picker测试用系统Button/公开hittable与真正消失同步，所有原操作/持久化断言保持；精确原/新主体hash登记Windows冻结证据，其余原主体保持。来源/失败及取舍见m4-font-preview-build24-fresh-save-design.json。

## 实际结果

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

