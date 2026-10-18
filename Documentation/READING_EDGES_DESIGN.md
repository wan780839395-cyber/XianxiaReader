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
