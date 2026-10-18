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
