# 阅读安全区边缘

Build29 开发中，最后已交付仍是Build28。新源码需独立完整CI及实际原生复核。

Build28实际慢滚暂停/后台截图在隐藏菜单时，正文进入状态栏区域。锁定Readium3.11的`EPUBInfiniteScrollView.safeAreaInsetsDidChange`设置了滚动contentInset；inset给起终点留白，不限制中途滚动的绘制。App的ReaderSurface保持全屏，Build28浮动header背景只随菜单显示。因此不能只加高菜单背景或移动滚动坐标。

本片沿用原引擎控制器，在其view上附加一个不接收触摸、对辅助功能隐藏的UIKit装饰。用[Apple safeAreaInsets](https://developer.apple.com/documentation/uikit/uiview/safeareainsets)描述当前视图安全边缘，依[安全区变更回调](https://developer.apple.com/documentation/uikit/uiview/safeareainsetsdidchange())和layout更新，`CAShapeLayer`用[evenOdd fillRule](https://developer.apple.com/documentation/quartzcore/cashapelayer/fillrule)只绘制bounds减去安全矩形的四边。颜色使用当前页面色，无blur、采样正文、额外DisplayLink/手势/滚动回调；禁用隐式layer动画，不依赖减少动效的过渡来隐藏正文。

不替换/包裹原导航控制器，不改Readium/Vendor、viewport、contentInset、contentOffset、排版、加载窗口、数据库或完整Locator保存。装饰在Representable协调器创建一次，主题更新只更新颜色，dismantle移除。初始页仍由引擎安全区留白显示，装饰只挡不安全区域，不能据此验收全书排版/章首留白或手机FPS。

新增真实UIWindow/ReaderSurface挂载回归：安全区四边实际像素、中心透明、主题变色、额外安全区变化、原视图frame与命中保持。新增真UI保留浅深慢滚/暂停/旋转/返回竖屏截图与原录屏；既有减少动效、位置重开、跨章、字体/设置/导航回归不删改。Windows语法和工具检查仅静态门槛；Linux/macOS Core及全部iOS tests和无签名设备Release29通过后，再实际查看本源PNG/原录屏/原始帧并打包。手机普通签名/TrollStore性能及完整设备矩阵仍单列，M4未完、不提前M5。

## 首候选与修正

首候选13812bd/39118070518实际162/163，新增window/慢滚UI通过但原生慢滚仍透字；Adapter在cover建立后异步addSubview(navigator)，所以本片补[CALayer.zPosition](https://developer.apple.com/documentation/quartzcore/calayer/zposition)公开绘制层级1，不重排或移动原视图。真实window测试追加迟到红色正文视图，核父级实际合成上/下黑边与中心红色、原frame和命中保持；只渲染cover自身的测试不足以捕捉层级错误。旧字体收藏失败原视频显示字体重排/退出fresh保存位置未稳定并可见alert，无Release/IPA，不改旧test/3秒预算或用缓存替代fresh；唯一根因未定，下一完整验证独立记录，重试通过不追认为根因修复。
