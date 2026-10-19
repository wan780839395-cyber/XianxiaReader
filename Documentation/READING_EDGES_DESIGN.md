# Build29 当前结果

## Build29 阅读安全区边缘（2026-10-19）

本切片已交付。实际Release源`a65086c1151831b54d90ed083fa36fc27848b5cb` / `codex/m4-reading-edges` / [完整CI39147081645](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39147081645)：Linux/macOS Core各137，iOS163/163（136集成+27真UI）、失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release29/min16。547编译资源blob、三锁六pins、六完整原字体/OFL、每平台4长TXT Release探针已核。Windows449语法新增0/54既有Vendor限制、17工具测试通过；语法不算编译。

补充源`f32002880ebe7702321cce90f1d030823c047c53`仅加强本轮新增旋转测试及recovery名单：App/Core/Adapter/Vendor/原Fixtures/锁/project/默认完整CI与上述Release全同字节，547记录中545相同、2测试/诊断路径不同。C[39155583794](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39155583794)实际10/11，新旋转81.659秒通过，唯一旧字体case在初次cover位置未发出时20秒probe失败，尚未执行换字体；完全同源原两个字体case单独复核[39179687615](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39179687615)实际2/2。保留原失败及根因未定风险，不称C11全过、f320完整163/设备Release或旧时序根因已修。299其他原test主体不改；预算/断言保持。精确来源见m4-edges-build29-production-provenance.json。

ReaderSurface保留原完整viewport/控制器，以UIKit真实safeAreaInsets和CAShapeLayer evenOdd绘制页面色不安全四边，中心透明，触摸/辅助功能穿透；明确zPosition高于迟到navigator。仅布局、安全区或颜色变化重绘，无逐滚动回调/blur，禁隐式动画。正文排版/contentInset/offset/完整Locator、数据库/依赖、加载20秒及保存3秒保持。App/Vendor有界Debug安全阶段元数据已登记，Release开关false不记录日志或AX。

安装[XianxiaReader-ReadingEdges-Build29.ipa](build/XianxiaReader-ReadingEdges-Build29.ipa)，SHA256 `2c8ef157dbe26d921c08d3a5ffa10a3ef6ee4d481c7b831ff3eb1191ae42901c`；[原创样书/字体许可/原生Preview测试包](build/XianxiaReader-ReadingEdges-Build29-TestKit.zip)，SHA256 `adfab4519e80cca8357e5b243be21bfeba5d9fcd0843be8e2067986c5b9a9cb9`。覆盖安装保留书库，不卸载或删库；+菜单确认0.0.1 (29)。51旧包、未提交工作、1062原路径及19恢复ZIP保持。

实际原生复核：A37原图/6完整录屏31总览/3窗口134帧已核，A旧旋转的排版alert与颜色错配历史继续拒绝；同生产的C10原图/81秒录屏6总览/3窗口114原始帧（11表）已核，浅深暂停、横屏和恢复竖屏正文与所列安全边缘可接受。App横屏裁图带黑区，公开XCUIScreen整屏图正确，双图/几何probe证明观测差异；Preview只收C的6张正确阅读整屏图。旋转仍显示加载并短暂章头再恢复锚点，不作为无缝动效或手机FPS验收。

旧四轮完整失败、a650早期定向10/10、第五完整自动通过但原生拒绝、B旋转10/11、C10/11和同源字体2/2全部独立留证，不追认旧失败。已核当前无生产变动，采用真实完整Release加同生产补充验证，未跳过失败CI生成IPA。原件本地范围服从最新CI保留回执，文字日志/summary/metadata与项目验证记录保留。

M4整体未完，普通设备/TrollStore、大字/VoiceOver/完整旋转及减少动效矩阵、手机Release帧时间/内存/功耗未验收。Build28“目前感觉流畅”仅实际手机主观反馈；Build27外部字体导入仅用户实际样例。未含字体删除/无限字体/可变轴/单书覆盖、Share Extension或M5。下一步收本片手机状态栏/手势条/旋转与慢滚触摸反馈，按性能计划推进，不盲改定位管线。

最新用户“改完别关机了”：保持开机，本轮不发出关机命令或安排关机。

以下为原始设计与各候选检查点，历史失败不追认。
# 阅读安全区边缘

Build29 开发中，最后已交付仍是Build28。新源码需独立完整CI及实际原生复核。

Build28实际慢滚暂停/后台截图在隐藏菜单时，正文进入状态栏区域。锁定Readium3.11的`EPUBInfiniteScrollView.safeAreaInsetsDidChange`设置了滚动contentInset；inset给起终点留白，不限制中途滚动的绘制。App的ReaderSurface保持全屏，Build28浮动header背景只随菜单显示。因此不能只加高菜单背景或移动滚动坐标。

本片沿用原引擎控制器，在其view上附加一个不接收触摸、对辅助功能隐藏的UIKit装饰。用[Apple safeAreaInsets](https://developer.apple.com/documentation/uikit/uiview/safeareainsets)描述当前视图安全边缘，依[安全区变更回调](https://developer.apple.com/documentation/uikit/uiview/safeareainsetsdidchange())和layout更新，`CAShapeLayer`用[evenOdd fillRule](https://developer.apple.com/documentation/quartzcore/cashapelayer/fillrule)只绘制bounds减去安全矩形的四边。颜色使用当前页面色，无blur、采样正文、额外DisplayLink/手势/滚动回调；禁用隐式layer动画，不依赖减少动效的过渡来隐藏正文。

不替换/包裹原导航控制器，不改Readium/Vendor、viewport、contentInset、contentOffset、排版、加载窗口、数据库或完整Locator保存。装饰在Representable协调器创建一次，主题更新只更新颜色，dismantle移除。初始页仍由引擎安全区留白显示，装饰只挡不安全区域，不能据此验收全书排版/章首留白或手机FPS。

新增真实UIWindow/ReaderSurface挂载回归：安全区四边实际像素、中心透明、主题变色、额外安全区变化、原视图frame与命中保持。新增真UI保留浅深慢滚/暂停/旋转/返回竖屏截图与原录屏；既有减少动效、位置重开、跨章、字体/设置/导航回归不删改。Windows语法和工具检查仅静态门槛；Linux/macOS Core及全部iOS tests和无签名设备Release29通过后，再实际查看本源PNG/原录屏/原始帧并打包。手机普通签名/TrollStore性能及完整设备矩阵仍单列，M4未完、不提前M5。

## 首候选与修正

首候选13812bd/39118070518实际162/163，新增window/慢滚UI通过但原生慢滚仍透字；Adapter在cover建立后异步addSubview(navigator)，所以本片补[CALayer.zPosition](https://developer.apple.com/documentation/quartzcore/calayer/zposition)公开绘制层级1，不重排或移动原视图。真实window测试追加迟到红色正文视图，核父级实际合成上/下黑边与中心红色、原frame和命中保持；只渲染cover自身的测试不足以捕捉层级错误。旧字体收藏失败原视频显示字体重排/退出fresh保存位置未稳定并可见alert，无Release/IPA，不改旧test/3秒预算或用缓存替代fresh；唯一根因未定，下一完整验证独立记录，重试通过不追认为根因修复。

第二候选c30ff2d/39122142797实际159/163，无Release/IPA；真实原生边缘已遮盖，新增父级layer.render像素失败，另3原用例失败分列。依Apple文档，CALayer.render读取层树，UIView.drawHierarchy读取可见屏幕层级；本源实测前者parent z绘制结果与原生截图不一致，故只纠正新测试的合成采样方式，不改颜色断言/预算或生产App。孤立shape仍核精确透明/颜色，新完整UIKit快照作为附件保留。原字体收藏这次过，不追认首轮根因；旧跨章/summary/书架开书失败仍记录不归因遮罩，不盲改Readium或旧测试。

## 第三候选菜单失败的参考与诊断边界

39126639352真实162/163，唯一旧菜单重启设置未打开，失败原视频/最终AX/原生归档事件已核：点击339.33,786落在设置按钮308.7,758/61.3×56内；无设置sheet或保存alert。此证据尚不能判断action未收到、状态更新未呈现或UIKit presentation冲突。窗口截图不能读取SwiftUI私有状态，不用猜测替代根因。

已查Apple公开 `sheet(item:onDismiss:content:)`（https://developer.apple.com/documentation/swiftui/view/sheet(item:ondismiss:content:)）及Point-Free维护的Swift Navigation README（https://github.com/pointfreeco/swift-navigation#swiftui）。成熟方案以单一可选enum表达互斥destination，避免多个Bool同时要求不同呈现。该项目README示例使用@Observable和case-path宏，与本项目iOS16/ObservableObject不同；本轮没有引入库、宏或改依赖，公开item-sheet思路可用不等于已证明能修复本次单面板失败。当前证据没有同时两个目标，故不借参考名义盲重构。

只做一次a9f4f8a完全同源的完整复验39131131911，旧断言/等待/名单保持。若再次出现相关失败，先在Debug/UI-test专用入口记录不含书名/正文的session、tap/action计数、destination变化、sheet appeared/dismissed和UIKit presenter transition状态，再用既有recovery定向诊断；验证退出码保持，无诊断IPA。不得通过延长等待、再点按钮、删除断言或无限重跑得到绿灯。复验通过也不倒写第三轮为通过，不把未证实菜单唯一根因标成已修。

## 2026-10-19 定向诊断

第四同源完整160/163已失败，原始诊断补齐并保留；不继续完整盲重跑。新窗口测试用UIHostingController子类接真实viewDidAppear/DidDisappear回调完成挂载与收尾，不手调UIKit生命周期方法，不改旧主题用例2秒/原像素断言。参考Apple viewDidAppear与beginAppearanceTransition文档。Vendor沿精确Readium3.11原公开WKNavigationDelegate回调补Debug上限24条阶段元数据及watchdog清理前快照，覆盖请求/导航/初始化/进出窗口/进程退出；App在Debug UI样例入口记录设置action→binding→content与公开presenter状态，上限16条，1px不拦触摸的AX节点及统一日志。记录无书名/URL/正文/Locator；Release编译期开关false，不分配trace UUID、不生成日志/AX，空诊断字段保留。未新增重试、异步采样、JS或延长预算。框架文档https://developer.apple.com/documentation/webkit/wknavigationdelegate；Readium参考https://raw.githubusercontent.com/readium/swift-toolkit/3.11.0/Sources/Navigator/EPUB/EPUBSpreadView.swift。UPSTREAM两文件摘要更新；依赖/JS/Core/DB/锁/默认完整CI保持。recovery额外选相关病例共10项，原退出码与30分钟job限保持，20秒有界收取安全元数据日志；诊断成功也不等于全量/Release/设备通过。Windows449/17通过，Apple定向尚待实际运行。


## 定向结果与完整验收边界

39144858281/sourcea65086c真实10/10，失败跳过0；新窗口实际出现/退出与原主题2秒测试均通过，完整测试日志appearance不平衡警告0。42原图/7表、4原视频一秒总览18表已查看，只接受所列功能状态，不当帧时间/完整动效/手机矩阵。113个trace共1156阶段事件，72个初始化完成记录最慢6.779s，没有超过20秒的启动延迟消息（实际11条启动耗时消息，最慢5.897秒）；部分预加载取消正常，不能把无复现当所有旧时序根因解决。额外统一日志20秒超时，未取得完整UI呈现trace，不放宽采集时限或原功能断言。实际记录m4-edges-build29-diagnostic-result.json。

在有证据的新窗口生命周期修正与有界Debug诊断基础上，独立完整39147081645/sourcea65086c执行Core137各/iOS163/Release29。它不是旧a9同源再次盲重跑；299既有test主体、加载20秒/保存3秒等预算及既有业务逻辑保持。默认完整CI保持，recovery诊断选择扩大而已；Vendor/App Debug元数据变更已登记，Release无日志/AX，不能继续笼统写Vendor完全未变。未取得本轮全部结果、原生复核和包校验前，Build29仍未交付。


## 第五完整的原生拒绝与新旋转用例补强

39147081645/a650真实163/163与设备Release29通过，但37PNG/7表和新旋转61.54秒/5总览显示：设备方向与app比例改变后WebKit仍在重排，新用例已开始下一次切色，原3秒fresh捕捉失败并显式alert，深色边缘配旧暖白正文；因此原生拒绝、不打包。Apple当前Xcode16.4适用的orientation文档明确物理方向不直接等于App界面方向（https://developer.apple.com/documentation/xcuiautomation/xcuidevice/orientation），XCTNSPredicateExpectation以可观察条件为准（https://developer.apple.com/documentation/xctest/xctnspredicateexpectation），官方原markdown与摘要留在rotation恢复目录。

仅补本轮新旋转test：主题完成、横屏和竖屏后分别在20秒上限内要求真实正文可点击、无可见spinner/alert、截图中央40×40纸张主色占比至少55%（文字可穿过，RGB容差5），不改原方向10秒、旧主体299或任何生产/保存预算。保留图离线核对：正确深色1594/1600、正确暖白1237/1600，错误深色0/1600；这是检查新断言能拒绝已观察坏图，不是iOS编译。recovery加入该case为11项，Windows449/17通过、原生产全相同；Apple新test未跑前不作验收。本源新断言可能揭示实际旋转重排问题，失败应查证不删除条件。


## 横屏截图的观测修正（定向11失败后）

39153021005/5e实际10/11，只有新旋转case在暖白横屏就绪predicate截止时AX查询被waiter打断。1暂停PNG与49秒原录屏4总览已看，43-49s实际横屏正文已可读，无charcoal步骤或alert。第五完整保留App横屏PNG均2622×1206，中央40×40完全纯黑；物理录屏1206×2622在48s中央暖白81.5%，支持App frame裁图坐标带黑区的具体观测问题，不把异常归成实际正文一直空白。

依Apple公开XCUIScreen（https://developer.apple.com/documentation/xcuiautomation/xcuiscreen）与XCUIScreenshotProviding，新增case改用XCUIScreen.main.screenshot采样/留图，首个横屏可读时附App/Screen双原图及frame/image尺寸/各自纸色判定对照。全部原readability/no-spinner/no-alert/20秒/55%/容差5与方向10秒不变，不改其他旧test、App或引擎。没有据此宣布排版失败唯一根因已修；先再次定向11验证，若失败看双图事实再定，不无限改预算。

## 当前恢复点：同源字体2项复核中（2026-10-19）

39179687615/sourcef320/codex/m4-edges-screen/selection=fonts运行原有2个字体case一次；watch30380/collector37268，核实际run.json与owned-helpers，不重复dispatch。生产/测试均未再改。C39155583794实际10/11、新旋转81.659秒通过；唯一旧字体case初次cover定位20秒未发位置，未到换字体动作，根因不确定，保留失败。当前C完整artifact SHA/digest/CRC已校验并去重；10原图/2表、81秒视频6总览和3窗口114原始帧/11表已看，浅深横屏/恢复竖屏及所列安全边缘可接受，旋转加载/短暂章头仍不算无缝动效。详screen-native-review和screen-diagnostic-result。

完整A39147081645/a650自动163/Release29保持真实通过，旧原生旋转拒绝历史不改；同生产的C正确新序列补充证据分列，待字体复核结果再决定交付，不冒称C11全过或C重建Release。Build29未打包，最后交付Build28，正常HEAD/index和全部未提交改动保持。

最新用户已明确“改完别关机了”：覆盖此前完成后关机授权。保持开机，本轮没有发出关机命令或安排关机。


## C初次封面位置超时的审查取舍（2026-10-19）

已重新查阅固定revision d82f44f4f05d87add9e22a8b75abbd61dce745dd的官方[EPUBSpreadView](https://raw.githubusercontent.com/readium/swift-toolkit/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBSpreadView.swift)与[EPUBNavigatorViewController](https://raw.githubusercontent.com/readium/swift-toolkit/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)，对照本项目隐藏重排保护、初始化后showSpread和分页更新入口。C两spread已初始化、DOM可见但位置未发出；缺少采样时alpha/offset及请求身份的证据，不能宣布某一guard或上游唯一根因。因此本片保留原保护和预算，不盲补新加载重试。选完全同源fonts2原测试一次隔离复核；成功也只表该次结果，旧超时/未来专项保留。
