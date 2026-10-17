# M4 阅读面板主题统一（Build26）

当前：App源码与两项真UI回归已接入，尚未Apple编译/原生验收/交付。Build25仍是已交付版本。

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
