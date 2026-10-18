# 当前交接与恢复点

Build29 安全区边缘开工（2026-10-18）。已核正常HEAD6d761749/空index、私有文档tip cfe5e65、Build28源8acc3f2/CI39113019568完整成功和交付。用户反馈没问题后继续；本轮先修连续滚动/慢滚在隐藏菜单时正文进入状态栏和home indicator区域。1062原路径/51旧交付包/18旧ZIP核验，新增第19份恢复ZIP，见m4-edges-build29-start.json；无遗留开发任务，不关机。

实际源码：ReaderSurface保持fullsize/ignoresSafeArea；锁定Readium3.11的EPUBInfiniteScrollView对safeArea设置contentInset，但中途滚动仍能绘制到inset区；Build28 header遮罩在隐藏/慢滚时不显示。拟使用UIKit已有safeAreaInsets与CAShapeLayer evenOdd在引擎视图上仅绘制不安全四边，颜色跟随当前纸张，触摸/辅助功能穿透、不改变viewport/contentInset/offset/完整Locator或Readium。旋转/布局变动更新几何，关闭/重建移除装饰。需要真实UIKit像素/命中测试和原UI慢滚浅深/旋转录屏复核，再完整新CI才交付。当前未实现/Apple编译，Build28仍最后交付，手机FPS/M4整体单列。

## 实现后、正式检查与构建前

ReaderSurface追加只绘制实际不安全四边的UIKit/CAShapeLayer装饰，保留原控制器/fullsize、位置/滚动管线；主题色随更新、自动布局/安全区变动重绘，dismantle移除，不接收触摸。新增真实window像素/命中/几何回归1项及浅深慢滚旋转UI1项，全部原test主体计划保持；新文件已由XcodeGen App/Tests路径覆盖，无SwiftPM业务文件。已一轮Windows449语法/17工具通过（语法不算编译），补兼容既有直接ReaderSurface初始化后会重新正式检查。下一步冻结源/原test对照、私有branch完整CI，再收取原生证据；尚未Apple编译。
