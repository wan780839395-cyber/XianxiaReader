# 阅读面板层次与按压反馈

2026-10-16，Build18完整自动门槛及原生复核通过；手机矩阵单列。

用户认可Build17整体，但指出部分扁平、生硬。本轮按反馈先精修现有原生阅读菜单/设置；M4整体未完，卷页、上下整屏、自动慢滚、触感反馈、字体导入等仍为后续独立切片。

## 实际取舍

保留灰绿基调、五种正文底色和既有布局。阅读菜单采用实色底、微弱顶边高光和两层小投影，设置卡片只保留更轻的接触阴影，让菜单、分组、正文有明确前后关系；预览底色仍精确使用阅读主题。装饰层不接收触摸，不加遮盖正文的手势层，不给WebKit做截图变形或全页模糊。

ReaderPressStyle使用系统ButtonStyle/isPressed，保留原生点击、按住松手、拖出取消与可访问性语义；普通按钮按下0.975缩放/0.5pt微沉、0.08秒响应，松手0.28秒短回弹，填充与色彩同时给出反馈。外部命中区保留至少44pt，禁用态明确。用户/系统/额外减少动效任一开启，缩放/位移和自定义动画停用，但仍即时显示按下底色；不使用PrimitiveButtonStyle或自建点击识别器。

菜单进退仍只改变叠加层，不重排正文视口；沿用10pt方向，以0.3秒response/0.92 damping短弹簧收敛，避免长时间或大幅弹跳。设置分组标题用小型灰绿图标块和更明确的文字层次，系统Picker/Toggle/sheet继续使用原生行为。增加对比度环境下补强边线；正文颜色、排版、引擎导航、原书、schema3、完整Locator和六pins均不变。

## 参考与版本边界

- [Apple ButtonStyle](https://developer.apple.com/documentation/swiftui/buttonstyle)：公开标准交互样式协议，而非改写激活语义；官方Markdown元数据标示iOS13起，适用本项目最低iOS16。参考原理，自行实现，没有复制外部代码。
- [Apple colorSchemeContrast](https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast)：读取系统增强对比度，不以App设置覆盖系统；元数据iOS13起。
- [Apple Motion](https://developer.apple.com/design/human-interface-guidelines/motion)：反馈紧贴操作、短而克制，动效可减少，不靠运动单独传达状态。
- [Apple Materials](https://developer.apple.com/design/human-interface-guidelines/materials)：仅借鉴功能层与内容层区分；当前文档包含新系统Liquid Glass，本项目使用iOS16可用的实色/渐变/阴影，没有引入新系统API或声称实现Liquid Glass。

web工具打开Markdown返回不支持content-type，已用只读HTTPS直接下载官方原文至.cache/recovery/20261016-build18并核APIavailability；不是引用第三方转述。既有Readest参考与Readium3.11维护路径不变，未复制素材、引入依赖或升级版本。

## 验证

原99项iOS回归保持；新增一项实际UI回归，在普通/额外减少动效两种请求下长按松手设置和字号按钮，验证110→120→130→120每次只激活一次、暗色切换及44pt控件命中尺寸，并保留实际录屏与八张浅深色原生截图。不是镜像样式常量的单元测试；按压/回弹是否自然以原生视频连续帧和手机分别核验。

预期各119Core/iOS100（89集成+11UI）/严格无签名Release18，Windows423语法/17工具与完整真实锁、四长TXT Release探针仍须核验。此处为开工时预期，最终实际结果如下。Build17手机基本自用反馈不扩写为手机FPS、巨段TXT满页或其他设备/系统可访问性验收。

## 首轮编译失败与修正

候选f957f465/CI38831994670各119Core/四探针通过，但我新增的private ReaderSurface与App已存在同名正文包装View冲突，Swift报invalid redeclaration；iOS测试未开始（0项，summary unknown），test65严格无IPA。只将自己的新样式modifier命名改为ReaderPanelSurface，不改既有正文包装View。完整日志/xcresult与失败回执保留；Windows语法不具备跨文件Swift类型编译能力，后续以完整Apple重跑为准。

## 第二轮自动通过与原生拒收

750191d0/CI38833282829各119Core/100iOS/Release18全过，实际IPA/三锁/504blob/四探针核过，但32图及三组对照出现文字图标也被容器shadow染出灰晕，不能作为视觉交付。只把两层投影限定在单一背景fill primitive，再叠边光/渐变，避免给正文、标签或完整内容做离屏合成；按钮、菜单动作与全部100测试保持。素材/实物和明确拒收回执保留，第三轮仍须完整重跑。当前分页孤立截图RGBA0，整窗EPUB有完整文字；巨段TXT孤立图仍仅顶部少量，限制不追认。

投影范围取舍另核[Apple shadow](https://developer.apple.com/documentation/swiftui/view/shadow(color:radius:x:y:))与[compositingGroup](https://developer.apple.com/documentation/swiftui/view/compositinggroup())的效果层级说明：本项目仅需要背景轮廓，不给整个内容子树增加合成组或drawingGroup。第三轮用单一背景fill接收shadow，标签与控件不在阴影子树内。

## 最终结果

Build18面板层次与按压反馈通过[完整CI38835963502](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38835963502)，实际编译源`76ede6b266304749db37029b66d89b0d27eb39e2`。Linux/macOS各119Core，iOS100/100（89集成+11真正UI），失败/跳过0，test/export/summary/recording退出0；无签名iPhoneOS arm64 Release18/min16、系统SQLite/真实三锁/每平台四长TXT Release探针与504源码blob核过。Windows423语法新增0/54 pristine限制、17工具测试通过；语法不是编译。

用户认可Build17基本自用/整体观感，反馈部分扁平生硬。本轮保留灰绿风格，原生菜单增加实色浮层、轻边光/双层小投影，设置分组补图标层次。投影仅作用于单一背景fill，文字/图标不投影；标准ButtonStyle提供按下0.975/0.5pt微沉和短回弹。普通/减少动效实际长按松手每次只激活一次与44pt命中区域已回归。系统/用户/额外减少动效禁缩放位移/过渡但保留即时底色，增强对比度加强边线。菜单仍10pt短幅，spring response 0.3/dampingFraction 0.92，不把response等同完整动画时长，不重排正文。仅App三样式文件、UI测试和project.yml版本变更；Core/Adapter/Vendor/锁/scripts/workflow/原书/schema3/完整Locator与成功Build17保持。参考Apple公开ButtonStyle/Motion/Materials原则并核iOS13 API适用最低iOS16，不引入LiquidGlass新系统API、外部代码或素材；设计READING_DEPTH_DESIGN.md。

安装`build/XianxiaReader-ReadingDepth-Build18.ipa`，SHA256 `8ada416c25c47fdec80fec0735c9db6c69f7d5584f465589981413c991011656`；原创样书测试包`build/XianxiaReader-ReadingDepth-Build18-TestKit.zip`，SHA256 `7d30ab3e4d34c14bd65ae46b787dc6e612f1273e893f892632ec0a22973aa5ac`。正常覆盖更新保留书库，+菜单确认0.0.1 (18)。原29包与本轮2包/ZIP CRC/内部IPA/原创Samples-Evidence-Cover及六张本轮Preview核过。手机手感/FPS、普通签名/TrollStore与完整可访问性矩阵单列；卷页/上下整屏/自动慢滚/触感反馈和字体文件导入等仍后续，M4整体未完。报告M4_DEPTH_VALIDATION_REPORT.json。

本轮32张实际原生截图已检查，31张有非透明像素；三组Build17前后对照与三组被拒收候选对照已看，白菜单不再有文字/图标投影灰晕，菜单轮廓投影与设置层次清楚。实际按压42.16秒、正常手势116.71秒、额外减少动效16.82秒三视频全时段1秒总览已看；普通/减少动效两按压窗口各20裁切帧、正常/减少动效菜单恢复各16帧，共72实际20fps时间采样已看，无插帧且可有VFR重复。普通约11.15秒出现按压色/微沉，11.35秒110变120，松手迅速收敛；减少动效约33.15秒按下色、33.35秒变120，无新缩放过渡。正常菜单约16.10–16.40秒短幅恢复，额外减少动效约13.05秒直接显示，正文未因菜单重排。其余3阅读/5书架视频只保留，未宣称本轮逐段审阅；三段选定视频不等于全部11段审阅。

长静帧/系统桌面不当流畅度证据：日志3次XCTest动画结束通知缺失；本例t19.16等idle、t79.20通知未收到、t79.22才发下一次tap，不能算App收到点击后卡60秒，根因/手机响应未建立，专门回执m4-depth-build18-xctest-idle-diagnostics.json。分页孤立WKWebView PNG又RGBA全0，不是可见黑页证明；实际新EPUB整窗有完整文字，DOM/原非零字180%/完整DOM重开回归通过仍不等价该孤立光栅验收。巨段TXT孤立图仍顶部约两行、其余留白，满页成因/手机结果继续未验收。系统真实Reduce Motion/增强对比度/VoiceOver/旋转/其他设备/普通签名/TrollStore、手机FPS/耗电/响应仍单列。旧Build15–17命名图片均来自本轮实际CI，不追认历史失败或第二轮视觉拒收。

首候选f957f465/CI38831994670因新增样式modifier与既有ReaderSurface重名而Swift编译失败，iOS零执行/test65，无Release/IPA；第二候选750191d0/CI38833282829自动100/100及Release18通过，但原生对照发现文字/图标投影灰晕，明确视觉拒收、未生成用户交付包。第三候选仅将两层投影移到单一背景fill，完整重新构建与本轮原生复核通过。首轮失败、第二轮视觉拒收、全部原始日志/xcresult/素材和候选IPA继续保留；回执m4-depth-build18-first-failure.json与m4-depth-build18-second-native-rejection.json，不以最终通过追认前两轮。
