# M4 原生阅读界面：Build16

状态：2026-10-15 设计与源码实施中，尚未Apple编译/原生复核/手机验收。

## 本片范围

延续书库灰绿与自然纸页风格，正文保持优先。阅读菜单把章节/进度、翻页/阅读方式、目录/书签/搜索/设置分成三层；顶部书名和返回/加书签提供足够触控面积。设置用“外观/排版”原生分段切换，颜色与字体在外观页，行/段距与缩进对齐在排版页。卡片留白统一、少边框、不过度阴影、不添加装饰图片。深色控件维持柔和文字和绿色点缀。

全部控件通过现有ReaderViewModel、ReadingInterfaces工作，不改引擎/持久化/全局优先级/Locator/缓存/schema。默认仍暖白110%、1.75行高、0.8rem段距、两字缩进。沿用原书排版/固定布局disabled规则、保存失败和重试保持。动态字体、VoiceOver、44pt最小点按区域与空间不足时的重排一起考虑；仅用短淡入淡出/原生sheet，尊重Reduce Motion/Reduce Transparency。

字体文件资产导入、单书覆盖、独立四边距、字距/字重、亮度/音量键和阅读方式跨启动保存继续按M4切片推进。外观/排版全局保存保留，阅读方式仍沿用现有会话状态，未新增跨启动持久化。

## 成熟方案与取舍

- [Readest DESIGN.md](https://github.com/readest/readest/blob/cc236be49a6e3b2c2c0763e7096c36efe631e4b2/apps/readest-app/DESIGN.md)，2026-10-15核官方main真实revision cc236be49a6e3b2c2c0763e7096c36efe631e4b2。采用正文优先、中性色层级、boxed rows、克制动效。它是Tauri/React/Adwaita跨平台界面；这里只参考层级，用SwiftUI原生实现，不引入其引擎/依赖、不复制代码。
- [Foliate GTK4](https://github.com/johnfactotum/foliate/tree/67b6676d3f936c5edea91d4d903385ef39dd25c0)，同日核官方gtk4 revision67b6676d3f936c5edea91d4d903385ef39dd25c0。参考专注页面与轻量工具栏，GTK桌面尺寸不能直接搬到iPhone。网页与README引用属于视觉调研，不等价安装运行验证。
- [Apple Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)、[Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)。最低iOS16/Xcode16.4，采用已有NavigationStack/large detent/分段/开关；不使用新系统专属玻璃API。官方网页正文依赖JS，可用性以既有SDK/实际CI编译核实。

下载参考文档原件在.cache/recovery/20261015-build16/，不提交外部源码或图像到产品。Foliate README截图的浏览器抓取实际TimeoutError，未据此截图作外观观察结论；主要具体层级选择依据已取得的Readest设计文本和项目既有原生页面。

## 验证边界

第三轮b62c0dd1/CI38743111852新增WebKit动态调用计数回归通过，但原快速字号→换色测试继续超时。新生命周期诊断只有初始reload DOM=false，没有采样或提交事件，因此前述CSS互斥修正有独立回归支持，却未解释全部快速请求问题。核官方3.11 EPUBSpreadView.evaluateScript只等spreadLoaded，本地普通分页采样却等完整continuousInitializationReady；第四候选将分页回归到原SDK就绪边界，连续模式仍等完整bootstrap。同时Adapter在进入WebKit前检查取消/请求/实例身份，避免尚未开始的旧Task进入额外等待，原await后检查保留；8条有界请求阶段诊断不含正文。只作必要生命周期修复，不放宽任何原测试/超时。第四轮实际结果前仍未验收。

第二轮fe95dbc/CI38738818996为91/92，全部8原生UI通过，旧分页重排第一次等待仍失败，严格test65阻止Release。重复失败后重新查精确[3.11 ViewModel](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBNavigatorViewModel.swift)及Navigator/ReflowableSpread：官方applyPreferences在needsInvalidation时不提交动态CSS。本地扩展此前先普通submit（排队动态CSS），再独立reload，脚本会在await后取得新loadedViews，存在晚到样式重排新页的竞争路径。本片因此增加必要的最小引擎集成修正：将强制分页重排并入ViewModel原失效决策，更新注入CSS/cache后只重建；纯换色和连续模式保持动态路径。新增实际WebKit调用计数回归（重建页0动态写入、纯换色同页实时更新），原1533等非零文字/180%/重开断言与超时不改；诊断仅12条数字/布尔生命周期，无正文/标题/选择器。更新两Vendor源码hash/provenance，不改锁/JS静态bundle/Locator协议/Core/Adapter。竞争路径是已确认源码差异，原两轮失败是否因此修复仍须第三轮实际原生验证。

首候选9a16572/CI38734879701：各115Core/四Release探针、Apple源码编译通过，iOS90/92，失败为旧EPUB分页重排等待和新上一页44pt区域断言（实际AX宽8）。显式44pt frame不足以扩展plain图标点击形状，参照[SwiftUI contentShape](https://developer.apple.com/documentation/swiftui/view/contentshape(_:eofill:))在label布局后设置矩形命中区域，保留尺寸断言。实际减少动效截图发现顶部旧bookmark.badge.plus没有可见字形，改用已支持bookmark图标并将添加书签入口纳入原44pt检查。首轮图片仅诊断，不当新修正验收。旧分页原测试/Adapter/Vendor同Build15未变，诊断记录原caret1533、重排后回到progression0，根因尚未确认；本片不盲改引擎或放宽20/30秒/180%/原文字可见断言。严格test65阻止Release，无首轮IPA。

保留原90项iOS测试、各115Core及17工具测试，新增原生菜单/分组切换/保存重开/浅深色截图及录屏回归。完整CI/Release16后交付。原生截图和视频连续帧只说明模拟器具体case，手机触控/FPS、系统减少动态效果、巨段TXT整窗和其他设备单列；Build15基本自用接受不扩写这些矩阵。
