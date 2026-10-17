# Build25 设置页精简与字形预览

用户实测Build24主要在上下滑动字体列表时卡顿，主样例存在不协调的内部矩形，页面过长。目标为原生可读/紧凑和减少实际重复工作，不改正文默认排版、Readium、Core、DB或Locator。旧Build24自动验收不继承到本轮。

已有代码的具体重复工作：ReadingFontPreview.body中UIImage(data:)在每次SwiftUI刷新重新构造图像；异步spinner和按字库测量图片高度不一致引发行高变化；六个长字体行及嵌套卡片增加滚动距离。手机根因和FPS尚无Instruments实录，以上是可验证的代码路径，并非已证明全部卡顿根因。

沿项目已有CoverImagePipeline的CGImage/actor边界：CoreText在actor直接绘制透明CGImage，SwiftUI持有结果，不在滚动路径PNG编解码；保留一个CGFont与最多12张/8MiB已绘制图片。原render仅用于原生测试导出附件，旧回归主体不删除。图片以黑色alpha mask缓存，由原生随主题着色，改底色不重新读字体或重绘样例；无图片内底色/边线，主样例外层只留柔和纸色，无阴影框线。

图片/加载/失败固定同一个槽位，字库就绪不改变网格行高；换请求时不冒用上一次字形，取消及恢复可用状态有明确ID守卫。六款字体通常两列，辅助功能大字时单列，保留真实字形、选中值、44pt目标与减少动效。名称足够辨识，风格副标题转无障碍标签；字号仍在列表前。分组固定于顶部；排版/手感页不重复放不反映段落参数的字形卡片，段落/留白合并连续行，控件与旧偏好范围不变。

参考Apple官方Creating performant scrollable stacks与Understanding and improving SwiftUI performance（https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks 、https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance），采用稳定尺寸/身份、减少body同步工作。Apple UIImage.preparingForDisplay文档明确不应在主线程直接预解码（https://developer.apple.com/documentation/uikit/uiimage/preparingfordisplay()）；本轮选择已有的直接CGImage路径，不新增UIKit解码调度层或依赖。最低iOS16与现有SwiftUI网格/API保持，未套用新系统专有滚动接口。

新增真实iOS缓存/透明/有界像素回归和真UI两列/重复滚动行高/换色/排版一屏回归。旧字体/CoreText/重开/选择器与完整正文位置断言保持；Windows语法不算编译，完整Core135各/iOS145（124集成+21UI）与Release25/原生录屏逐帧核验后再交付。手机冷加载/实际帧率/内存功耗、系统大字/VoiceOver全矩阵另验，不能宣称模拟器截图等于卡顿根因及手机性能解决。

复查修正：紧凑列采用六字单行样例，避免原9字在156pt源宽下末字折行；原书排版只禁用段落/对齐调整，左右留白维持可调整，真UI新增相应断言。前56e候选因该布局禁用范围复查被替代，独立CI继续完成，未取消、不作为新源门槛。
