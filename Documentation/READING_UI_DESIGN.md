# M4 原生阅读界面：Build16

状态：2026-10-15 Build16完整自动门槛与模拟器原生图/视频复核完成，手机待测。

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

第四轮ce5bde4d/CI38748113867现完整success，单job原始日志实查原快速180%/文字位置/重开回归7.1秒通过，新CSS互斥回归5.257秒通过，85集成+8UI全过，test/export/summary/recording0；完整结构化结果/IPA/原生素材仍须在下载后独立核验。前置取消检查与分页就绪边界是组合修正，本轮未单独隔离两者的唯一因果；不把一个通过追认为前三轮失败已通过，也不将计数回归等同于全部布局问题解决。

第二轮fe95dbc/CI38738818996为91/92，全部8原生UI通过，旧分页重排第一次等待仍失败，严格test65阻止Release。重复失败后重新查精确[3.11 ViewModel](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBNavigatorViewModel.swift)及Navigator/ReflowableSpread：官方applyPreferences在needsInvalidation时不提交动态CSS。本地扩展此前先普通submit（排队动态CSS），再独立reload，脚本会在await后取得新loadedViews，存在晚到样式重排新页的竞争路径。本片因此增加必要的最小引擎集成修正：将强制分页重排并入ViewModel原失效决策，更新注入CSS/cache后只重建；纯换色和连续模式保持动态路径。新增实际WebKit调用计数回归（重建页0动态写入、纯换色同页实时更新），原1533等非零文字/180%/重开断言与超时不改；诊断仅12条数字/布尔生命周期，无正文/标题/选择器。更新两Vendor源码hash/provenance，不改锁/JS静态bundle/Locator协议/Core/Adapter。竞争路径是已确认源码差异，原两轮失败是否因此修复仍须第三轮实际原生验证。

首候选9a16572/CI38734879701：各115Core/四Release探针、Apple源码编译通过，iOS90/92，失败为旧EPUB分页重排等待和新上一页44pt区域断言（实际AX宽8）。显式44pt frame不足以扩展plain图标点击形状，参照[SwiftUI contentShape](https://developer.apple.com/documentation/swiftui/view/contentshape(_:eofill:))在label布局后设置矩形命中区域，保留尺寸断言。实际减少动效截图发现顶部旧bookmark.badge.plus没有可见字形，改用已支持bookmark图标并将添加书签入口纳入原44pt检查。首轮图片仅诊断，不当新修正验收。旧分页原测试/Adapter/Vendor同Build15未变，诊断记录原caret1533、重排后回到progression0，根因尚未确认；本片不盲改引擎或放宽20/30秒/180%/原文字可见断言。严格test65阻止Release，无首轮IPA。

保留原90项iOS测试、各115Core及17工具测试，新增原生菜单/分组切换/保存重开/浅深色截图及录屏回归。完整CI/Release16后交付。原生截图和视频连续帧只说明模拟器具体case，手机触控/FPS、系统减少动态效果、巨段TXT整窗和其他设备单列；Build15基本自用接受不扩写这些矩阵。

## 最终证据

Build16原生阅读菜单/设置界面通过[完整CI38748113867](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38748113867)，真正编译源`ce5bde4d9d73e6979265a7b1f1bdf0f92d318970`。Linux/macOS各115Core、iOS93/93（85集成+8真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release16。原四长TXT Release探针/平台、三份真实六pins锁及501源码blob已核，原90项iOS和全部旧断言保留。Windows420Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是编译。原生图片/成功case视频/连续采样与源码编译、普通设备/TrollStore、手机FPS分别记录。

阅读菜单使用浅色/深色灰绿实心卡片，分开章节进度、翻页和目录/书签/搜索/设置四入口；阅读方式菜单切左右翻页/上下连续滚动。阅读设置分“外观/排版”，主题/字体/字号与段落控件分别成组，44pt加减按钮与窄空间重排。五阅读底色/柔和深色正文、全局保存/重开/错误重试、原书样式/固定布局禁用规则保留。UI之外，旧分页回归反复失败后按官方3.11 needsInvalidation合同将字号重排并入原失效路径，使注入CSS/cache重建与动态CSS互斥；纯换色/连续模式保持动态路径。两维护Vendor文件/provenance与有界无正文诊断更新，新增真实WebKit动态调用计数回归。快速连发路径另在Adapter采样前过滤取消/旧请求并保留await后检查，普通分页采样使用官方spreadLoaded边界，完整continuous bootstrap等待仍只用于连续加载。原非零文字/180%/重开断言不变。Core/ReadingInterfaces/schema3/原件/六pins/JS bundle/Locator协议保持，不升级引擎版本，所有旧集成回归继续通过。

参考Readest真实revision cc236be49a6e3b2c2c0763e7096c36efe631e4b2的层级/留白/克制色彩，采用项目自己的原生SwiftUI实现，无外部源码/美术/依赖复制。Foliate仅阅读官方文档，其截图抓取超时未作视觉验收依据；差异、链接与取舍见READING_UI_DESIGN.md。

原生复核回执`Documentation/ValidationLogs/m4-polish-build16-native-review.json`，18图逐项检查（17图有非透明像素；1张分页EPUB全透明），3段59.55/50.38/18.26秒视频全时段1秒总览已看，正常sheet弹出23帧及减少动效请求分组切换22帧已看。本轮浅/深色菜单、模式选择、分组/原书开关/重开均可读；旧Build15命名的附件来自本轮实际测试，保留原名。连续帧是实际视频时间采样，可能重复，无插帧，不当手机FPS。额外Reduce Motion请求不设置系统偏好，系统分段/sheet仍可有原生动画；中央点击菜单淡入淡出尚未独立采样。appearance录屏25–43秒处为退出/重启间的系统桌面，不作阅读动效证据。

明确限制：巨段TXT隔离快照仅顶部文字、下方留白原因未确认；分页EPUB截图RGBA所有通道均0，像素全透明，不是可见黑页证据，采集/绘制就绪与真实整窗显示仍须确认。DOM/字号/非零原文字/3px重排和重开回归通过，不等价完整光栅页面验收。用户Build15“没问题 可以继续”仅按基本自用记录；手机分页EPUB和巨段TXT满页、大字体/VoiceOver/旋转/耗电继续单列。

安装`build/XianxiaReader-ReadingUI-Build16.ipa` / SHA256 `c55b94177e8ee3f7f9ea3ba50dd93cf49f67b784cc02b5994905c04b8bdd2638`；原创样本测试包`build/XianxiaReader-ReadingUI-Build16-TestKit.zip` / SHA256 `182f23473f89cded7c124324af411b30fd18593200c8b580c7f69f402a87821d`，附6张本轮原生浅深色Preview图。正常覆盖更新保留书库，+菜单确认0.0.1 (16)。新旧27包、ZIP CRC/内部IPA/原有样本/Preview hash已核。Build16手机待测；M4整体未完，字体文件资产导入/单书覆盖/独立四边距/字距字重/亮度/音量键/阅读方式跨启动保存仍后续，M5设备性能单列。报告M4_POLISH_VALIDATION_REPORT.json。

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-first-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-second-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-third-failure.json
