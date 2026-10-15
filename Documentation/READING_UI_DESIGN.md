# M4 原生阅读界面：Build16

状态：2026-10-15 设计与源码实施中，尚未Apple编译/原生复核/手机验收。

## 本片范围

延续书库灰绿与自然纸页风格，正文保持优先。阅读菜单把章节/进度、翻页/阅读方式、目录/书签/搜索/设置分成三层；顶部书名和返回/加书签提供足够触控面积。设置用“外观/排版”原生分段切换，颜色与字体在外观页，行/段距与缩进对齐在排版页。卡片留白统一、少边框、不过度阴影、不添加装饰图片。深色控件维持柔和文字和绿色点缀。

全部控件通过现有ReaderViewModel、ReadingInterfaces工作，不改引擎/持久化/全局优先级/Locator/缓存/schema。默认仍暖白110%、1.75行高、0.8rem段距、两字缩进。沿用原书排版/固定布局disabled规则、保存失败和重试保持。动态字体、VoiceOver、44pt最小点按区域与空间不足时的重排一起考虑；仅用短淡入淡出/原生sheet，尊重Reduce Motion/Reduce Transparency。

字体文件资产导入、单书覆盖、独立四边距、字距/字重、亮度/音量键继续按M4切片推进。

## 成熟方案与取舍

- [Readest DESIGN.md](https://github.com/readest/readest/blob/cc236be49a6e3b2c2c0763e7096c36efe631e4b2/apps/readest-app/DESIGN.md)，2026-10-15核官方main真实revision cc236be49a6e3b2c2c0763e7096c36efe631e4b2。采用正文优先、中性色层级、boxed rows、克制动效。它是Tauri/React/Adwaita跨平台界面；这里只参考层级，用SwiftUI原生实现，不引入其引擎/依赖、不复制代码。
- [Foliate GTK4](https://github.com/johnfactotum/foliate/tree/67b6676d3f936c5edea91d4d903385ef39dd25c0)，同日核官方gtk4 revision67b6676d3f936c5edea91d4d903385ef39dd25c0。参考专注页面与轻量工具栏，GTK桌面尺寸不能直接搬到iPhone。网页与README引用属于视觉调研，不等价安装运行验证。
- [Apple Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)、[Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)。最低iOS16/Xcode16.4，采用已有NavigationStack/large detent/分段/开关；不使用新系统专属玻璃API。官方网页正文依赖JS，可用性以既有SDK/实际CI编译核实。

下载参考原件在.cache/recovery/20261015-build16/，不提交外部源码或图像到产品。

## 验证边界

保留原90项iOS测试、各115Core及17工具测试，新增原生菜单/分组切换/保存重开/浅深色截图及录屏回归。完整CI/Release16后交付。原生截图和视频连续帧只说明模拟器具体case，手机触控/FPS、系统减少动态效果、巨段TXT整窗和其他设备单列；Build15基本自用接受不扩写这些矩阵。
