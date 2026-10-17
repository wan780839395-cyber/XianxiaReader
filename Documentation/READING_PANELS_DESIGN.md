# M4 阅读面板主题统一（Build26）

当前：Build26完整自动门槛与下列实际原生复核通过并交付；手机性能/全设备矩阵与M4整体未完。

用户反馈Build25菜单仍卡顿但可用，允许按计划继续；这不是手机流畅度通过。本片统一目录、书签、书内搜索的灰绿浅深表面、文字层级、紧凑行距与空状态，不扩展到阅读引擎或性能阶段。

## 实现与边界

- 目录/书签拆成独立值视图，用同一ReaderPalette的原生insetGrouped List。目录保留原ordinal/深度、所有原目录条目和选择闭包；ordinal只是导航条目，不作为小说canonical chapter，不推断当前章高亮。书签仍由原model持久删除、原生左滑，日期及完整位置保持。
- 搜索框固定在列表上方；原生键盘、明确清空和搜索按钮、空查询禁用；清空通过既有setQuery取消旧会话与结果。提交收键盘，结果上下文用同一柔和文本色、关键词用灰绿加粗。结果仍增量、现有1000上限/加载更多/停止/取消/错误/关闭逻辑保持，ViewModel和Readium服务不动。
- 主题明确传入sheet，列表隐藏系统默认滚动底色，设置本地表面与导航栏背景/色系；五正文颜色不改。不使用全局UIAppearance、新动画/逐行阴影、整表自建VStack、数据复制/重新索引。新按钮保留44pt与原生/既有减少动效行为。
- 原生sheet与List继续负责滚动、键盘、安全区和删除手势；不添加主题过渡截屏或强制动画。旧Reader自动慢滚暂停安全区问题仍单列，不把本片新sheet复核当作旧问题已修复。
- Core/DB/schema/完整Locator/ReaderViewModel/SearchViewModel/ReadingInterfaces/ReadiumAdapter/Vendor/字体/依赖与资源窗口均保持，project.yml仅升26。

## 参考与取舍

2026-10-17核Apple公开文档：
- [scrollContentBackground](https://developer.apple.com/documentation/swiftui/view/scrollcontentbackground(_:))用于隐藏List系统底色，再明确本地背景。
- [toolbarBackground](https://developer.apple.com/documentation/swiftui/view/toolbarbackground(_:for:))用于原生导航栏背景；显式visible避免滚动前后色面不一致。
- [scrollDismissesKeyboard](https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:))沿用系统交互式键盘收起。

这些是iOS16已有公开接口，当前工程最低16/Xcode16.4，不引入最新系统独占外观或全局导航栏覆盖。实际API可用性/SwiftUI类型检查由本源完整CI确认，文档阅读和Windows语法不算编译。

## 验证计划

保留ReaderInterfaceUITests全部原test主体，增加五主题目录/空书签/搜索首屏与44pt检查，以及深色额外减少动效下真实书签左滑删除→退出/重开持久化、搜索结果→清空→新词无匹配→重新搜索跳转/回看入口。既有目录/书签/搜索跳转、迟到请求/取消、字体完整位置及三阅读模式回归完整重跑。

Windows运行仓库/Swift语法与工具tests；独立CI Core各135+iOS预计147(124集成+23真UI)+严格无签名设备Release26。真实原生截图、对应录屏和选定原始连续帧复核后才交付，手机FPS/内存/耗电、所有设备/辅助功能/旋转矩阵单列。尚未执行不标通过，M4未完成。

构建前审查补充：首候选新增搜索按钮仅接系统/测试环境减少动效，遗漏持久化interaction.reduceMotion；已在View参数和既有按压样式之间显式传递。新增真实UI从设置开关开启并退出/重开核值，原11个test主体不变。旧CI39023086030由Agent取消（iOS完成0，无Release成功），新源ac8b387e/39023478476独立重跑，不能把取消写成源码失败或复用旧门槛。

## 原生输入尺寸修正（尚待新源验证）

ac8b387e/39023478476实际145/147。SwiftUI TextField外层frame44并未使原生编辑AX元素超过22，因此保留44断言，采用Apple公开[UIViewRepresentable sizeThatFits](https://developer.apple.com/documentation/swiftui/uiviewrepresentable/sizethatfits(_:uiview:context:))（官方availability iOS16起）直接布局UITextField，最低44且随系统正文字号增高。原生[UITextFieldDelegate](https://developer.apple.com/documentation/uikit/uitextfielddelegate)同步焦点/键盘Return、editingChanged仍走setQuery，dismantle解除代理；更新不覆盖[markedTextRange](https://developer.apple.com/documentation/uikit/uitextinput/markedtextrange)的活动中文组合及光标，用户明确清空可丢弃组合。新增真实UIWindow中文组合→切深色→保持marked range/光标→清空→新词/收键盘集成检查；两原新增UI保持44与原定位断言。手工查看当前4图发现删除继承浅绿/白字对比不足，显式柔和砖红删除tint，普通匹配/搜索保持灰绿。

另一失败为未修改的旧字体隐藏重排字定位超时，ReaderEngine/原test均与Build25相同；本片不盲补引擎或放宽断言。新源将完整重跑；即使通过也不宣称旧字体时序根因已修复。详细历史与实际4图见m4-panels-build26-history-39023478476.json，失败轮无设备包。

本轮旧字体失败只做源码核对：ReaderEngine的偏好请求身份/3s采样与Vendor分页spreadLoaded/alpha/offset守卫均与Build25一致，UI sheet的改动不进入该集成路径。未证实定位超时根因，不因系统RBS/WebKit日志推断唯一原因；新轮仍执行原完整字体测试，若重复需独立定位而非放宽。当前焦点是公开UIKit输入尺寸/中文组合与面板外观，详见对应冻结源。

## 517候选失败后的定向诊断

source5176821d/39027324303原xcresult实际146/148（2失败0跳过），test65/export0/summary0/recording0，设备Release未执行。两项新真UI通过：五主题原生编辑区域44pt、深色书签删除重开及搜索清空/换词/原生Return；前轮失败的旧隐藏重排test本轮7.493s通过。另一个原字体导入/重开test在连续章节ready=false、加载超时、WebView href=blank时失败，完整保存位置仍在；新中文组合集成test的旧通用超时不能证明是哪一步失败。均保留原断言，未称根因已修。

新增选项诊断仅重跑原生输入、两项旧字体或两项新面板；主workflow默认full仍走原完整Core/iOS/严格设备Release，显式diagnostic不产IPA、不替代交付门槛。GitHub[官方手动运行规则](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)要求注册的workflow位于默认分支，因此复用已注册文件与分支ref，不推主分支注册新文件。输入test只补分阶段状态输出，先核原生挂载/主题/清空/焦点中的实际失败点。

核Apple公开[UIWindow(windowScene:)](https://developer.apple.com/documentation/uikit/uiwindow/init(windowscene:))用于真实scene挂载；项目既有真实UIKit测试都沿此路径，而新增test当前仅frame窗口，需由原诊断确认。另[unmarkText](https://developer.apple.com/documentation/uikit/uitextinput/unmarktext())保证markedTextRange为nil，若清空阶段确认为组合未结束，采用此公开方法，不在普通主题更新时打断中文组合。

失败源21张新原生状态已实际查看4张接触表：五主题目录层级/空书签/搜索首屏可读，深色灰绿关键字与柔和砖红左滑删除对比可接受，删除后重开为空/无匹配/实际跳转状态一致。此为失败源的局部视觉诊断，不是新修正源或设备流畅度验收。完整原件SHA/CRC与实际summary见m4-panels-build26-history-39027324303.json；历史大文件后续只按交付后的保留回执收敛。

定向39037628899的原日志已证实No UITextField，失败发生在native field layout，未执行中文组合/换色/清空。新增test修为真实connected UIWindowScene挂载、layoutIfNeeded、结束恢复旧key window，并额外断言窗口为key且scene身份一致；原2秒预算、44pt/中文/光标断言不变，产品代码未因该诊断修改。新源1e4ae348/完整39038829961独立重跑148（125集成+23真UI）、Core各135及严格Release26，定向结果不替代完整门槛；旧字体来源及根因仍单列。

旧字体定向39037690400实际1/2：导入字体的分页关闭重开后line294仍blank；WebContent启动日志两条47.520322/47.657906秒，超过原30秒等待，这是环境/加载时序排障线索，不能单独证明唯一根因。另一隐藏重排test9.241s通过。核同版Readium页面初始化、分页回收、spread clear与显式连续shutdown、现有engine身份守卫，仍未证实应改哪处业务代码，保持测试与引擎。查官方[Readium变更记录](https://github.com/readium/swift-toolkit/blob/3.11.0/CHANGELOG.md)与当前固定3.11源码；不引入4.x/Swift6升级或把旧字体问题归咎于本轮UI。完整新源仍须从头通过原门槛，重跑成功也不称根因修复。

## 实际交付与限制

Build26本切片已交付；实际编译源`1e4ae348a39679df8476bda6c74380d4615078b0` / ref `codex/m4-reading-panels` / [完整CI 39038829961](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39038829961)。Linux/macOS Core各135、iOS148/148（125集成+23真UI），失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release26/min16。三锁六pins、536源码/资源/配置blob、每平台4组长TXT Release探针及IPA六字体/原OFL原字节已核。Windows438语法新增0/54既有Vendor限制、17工具通过；语法不算编译。11个原UI test主体保持；新增2项真UI与1项原生输入集成回归。

目录、书签和书内搜索统一使用阅读菜单的灰绿浅深表面、柔和正文色、清晰间距与空状态，系统原生List复用/滚动/安全区和书签左滑删除保留。目录保留原ordinal/深度/所有条目，不把TOC序号当canonical章序或猜当前章。搜索框固定顶部、清空经既有setQuery取消旧会话/结果；提交收键盘、匹配词灰绿加粗。增量批次/1000条上限/加载更多/停止/错误/关闭取消、原生完成/下拉关闭、原导航/完整位置/删除事务保持。新搜索按压显式尊重系统与持久化额外减少动效。书签删除显式柔和砖红色，避免全局浅绿tint/白字对比不足。不增加逐行阴影、自建整表、依赖或正文重排；Core/DB/schema/Reader与Search ViewModel/ReadingInterfaces/Readium/Vendor/字体/资源窗口均未变。

新真UI覆盖五主题目录/空书签/搜索首屏/44pt，以及真实设置开启额外减少动效→删除书签→退出/重开持久化、搜索结果→清空→新词无匹配→重搜跳转与回看入口。新增真实UIWindow内的中文marked-text/光标→换色保持→清空→新词/收键盘回归也通过；原生输入按系统正文字号增高，原UI的44pt断言保留。既有目录/书签/搜索完整定位、取消与字体/三阅读模式回归均重跑。本片未声称解决用户报告的菜单轻微卡顿；Build25基本可继续使用而流畅度仍待优化，证据m4-settings-build25-device-feedback.json。

安装[XianxiaReader-ReadingPanels-Build26.ipa](build/XianxiaReader-ReadingPanels-Build26.ipa)，SHA256 `5a5483916f7b22e527ad938094b5eece897e5cd6a35214512ff22eb74c37d61e`；原创样书/21张本源原生Preview/沿用字体样本与原许可包[XianxiaReader-ReadingPanels-Build26-TestKit.zip](build/XianxiaReader-ReadingPanels-Build26-TestKit.zip)，SHA256 `913275a151771470a2c61e1251394af1d403721acfd12ce6cd02a95b00bb497f`。覆盖安装保留书库，+菜单确认0.0.1 (26)。45旧包及未提交源码/恢复备份保留，ZIP CRC/内部IPA/原材料逐摘要核验。

原生人工复核范围：本源21张新面板PNG/4表已实际查看；五主题目录层级/空书签/搜索首屏、深色砖红左滑删除/删除后重开为空、搜索结果/无匹配及稳定跳转PNG可读。两条原录屏89.80s/63.64s全部1fps总览11表，以及目录入场33帧、左滑13帧、清空键盘17帧共63原始VFR帧/7表已查看，保留源PTS、无fps滤镜或插值。113张旧功能PNG及其余16阅读/5书库录屏保留而未逐看。本片加载/重开/搜索跳转片尾spinner与渐显不作为稳态正文验收；旧正文标题/菜单安全区、全动效及手机FPS不追认。

手机菜单/字体列表实际卡顿、FPS/内存/耗电、普通签名/TrollStore、系统大字/VoiceOver/减少动效/旋转和全部File Provider矩阵仍待专项验收。旧阅读暂停安全区/分页快照问题按各自证据保留，不因新面板通过而追认；字体删除/集合/可变轴、单书覆盖、自定义配色/独立四边距等尚未实现。M4未完，先收本片手机面板/键盘/左滑反馈并核旧安全区，再按M4设置与主题路线推进，不提前M5。

首候选3c250618/39023086030由Agent在审查发现新增搜索遗漏持久化额外减少动效传递后取消。实际completed/cancelled、两平台Core各135、iOS完成0/无设备Release成功标记、源码compiler诊断0；完整日志/metadata/整包校验后的历史文字诊断留存。不是源码失败，旧结果不继承为本源门槛，见m4-panels-build26-first-agent-cancel.json。初始界面和受改原测试保留，无降低断言或删除测试。另ac8b387e/39023478476实际145/147：旧字体隐藏重排非零字定位超时、新TextField原生AX22pt未满足44；无Release。原引擎和该旧test与Build25相同，未证实旧超时根因；修正原生字段尺寸/中文组合与删除tint后本源独立全过，不把重跑通过写成旧字体时序根因已修复。完整失败日志/summary/4张实际查看图及artifact摘要见m4-panels-build26-history-39023478476.json。

另5176821d/39027324303实际146/148，两项新真UI均过，但新输入测试未创建UITextField即超时、另一旧字体重开失败；输入定向39037628899证实新测试缺少真实scene挂载，修测试窗口/恢复key后本源独立全过，原中文/光标/44pt及2秒预算保持。旧两字体定向39037690400实际1/2，分页快速重开blank且两条WebContent启动日志47.520322/47.657906秒，另一隐藏重排9.241s过。未改原字体测试或引擎，未证实旧字体/环境时序唯一根因；本源全过只表本轮门槛，不把重跑写成该根因已修。两条定向诊断均无Release/IPA、不替代完整门槛，完整原summary/日志摘要与来源见ValidationLogs/m4-panels-build26-diagnostic-*及history-39027324303记录。

本地CI按AGENTS保留本轮完整诊断；历史原件保留范围服从m4-panels-build26-ci-retention.json实际回执，文字日志/summary/metadata及交付包/源码/恢复ZIP保留。旧文“大原件在本地”只代表当时快照。用户取消关机持续生效，本轮不发关机命令或调度。
