# Build27 字体收藏、简化排版与书架边界

2026-10-18 开发记录。当前开发中：首全量152/156、第二定向14/15的实际Apple Debug编译/失败记录分列；第三候选待新的定向与完整验证，尚无Build27 Release交付，手机和外部应用联动仍未验收。Build26交付与历史故障边界单独保留。

用户要求导入字体不要在底部铺成长列表，样式与内置一致；排版减少低频项目并加预设。还反馈系统暗黑书架搜索突变浅色、退出阅读后偶发无法再次打开、希望其他应用直接传入TTF，以及菜单仍可能卡顿。

## 字体与排版

外观首页保留六款内置两列字形，导入字体缩为单个“我的字体”入口与收藏数量。独立原生导航页采用两列惰性网格、辅助功能大字单列和名称搜索；导入在此页完成，当前12款/每款32MiB上限沿用原存储规则。没有新增字体删除或无限名额。导入字形与内置使用同一预览组件/字号；限制CGImage最多按原绘制point尺寸显示，修复短图随宽容器上采样而过大的实际代码路径。透明样例、一个CGFont、12图/8MiB后台缓存保持。

排版首页提供舒适/宽松/紧凑三个显式动作，以及字号/行距/左右留白；段距、字距、字重、缩进和对齐放在“更多调整”。原书样式开关保留且仍禁用对应段落项。预设仅在用户点选时重设段落/留白，不动底色、字体、字号、完整位置或交互偏好；检查当前是否匹配预设只读，旧自定义值不会因开面板被重置。仍使用reading-v1现有字段，无领域模型/schema/依赖升级。

## 系统主题与阅读会话

Apple的preferredColorScheme作用于最近presentation而非单个子视图，不能把页内主题当窗口偏好。当前源码全部移除reader preferredColorScheme传播，改为局部SwiftUI环境与公开UIViewController.overrideUserInterfaceStyle；桥接只寻找自己的已呈现控制器，构建时没有该控制器就保持自身override，禁止触及UIWindow/书架root。撤销桥接时恢复原值，导航栏继续使用局部toolbarColorScheme。新增真实窗口/呈现控制器集成与真实系统暗黑模拟器的书架搜索/浅深阅读往返UI回归。没有复现前，不能宣称已证实用户手机唯一根因。

书架原来直接用Book.id作为fullScreenCover的会话身份、退出仅调用环境dismiss。现在每次打开使用新UUID，保存成功后显式关闭旧model并清空持有者的同一presentation；迟到回调校验presentation UUID，重复返回只执行一次，真正disappear再次使旧异步工作失效。保存失败保持可见可重试。沿用原ReaderViewModel请求ID、取消、完整Locator和迟到位置回归；新增真实同书反复打开/主题搜索往返，不用删除数据库或重置书架修复。

## 外部字体文件

Info.plist只声明系统TTF/OTF文档类型、Alternate Viewer与原件就地读取能力；不声明接管所有data，也不注册全局字体或安装系统字体。AppRoot的onOpenURL立即持有security scope，冷启动先排队等服务，暖启动顺序调用既有ReadingFontImportService/BookFileStore的协调复制、大小/签名/CoreText校验、摘要去重。复制完成才释放各自scope，失败可见且后续文件仍可导入，最多16项等待；原文件保持不写。

外部字体只加入收藏，不抢占阅读sheet或自动修改当前排版。打开设置或收到目录变更通知时刷新浏览资源，既有引擎字体表不立即改变。用户明确选择新资源后走原先保存完整锚点→受控重开→持久化的路径。已有12字体/18总资源与12正文窗口限制不变。原有文件选择器EPUB/TXT导入、首次回调修复与编码保留。

该文档接收足以支持提供标准iOS“打开方式”的来源应用；某些来源仅提供分享扩展不会自动出现普通应用，此轮未增加Share Extension。是否在具体下载应用中列出本应用、普通签名/TrollStore注册与所有File Provider，仍需手机验证。不能用服务单元输入冒充实际外部应用点击验证。

## 性能与验收

已确定的改动是短样例停止上采样、外观首页减少导入样例构建、独立字体页惰性两列、折叠低频控件。不增加逐帧文件I/O、全文、阴影层或WebKit重建；外部导入不自动重建正文。60Hz最多说明每帧16.7ms预算，不能证明用户卡顿原因；本轮不凭自动通过或原生录屏推断真机FPS/内存/功耗。还需手机Release的首次/重复滚动与Instruments主线程、渲染/缓存时间证据。

旧字体重开/隐藏重排的偶发CI超时与WebContent启动47秒日志仍独立保留，不把换presentation身份或新全过当其唯一根因修复。所有修改后需Windows工具、两平台Core、完整iOS/严格Release、原生截图/原录屏窗口复核，普通设备/TrollStore/辅助功能矩阵单列；M4未完、不进入M5。

## 参考与适用性

- [Apple preferredColorScheme](https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:))：iOS13+，presentation级传播；本项目最低iOS16，取舍是只对reader自己的呈现控制器设公开override，不改窗口。
- [Apple UIViewController.overrideUserInterfaceStyle](https://developer.apple.com/documentation/uikit/uiviewcontroller/overrideuserinterfacestyle)：iOS13+局部控制器样式，与SwiftUI值域组合；无私有API/全局appearance。
- [Apple CFBundleDocumentTypes](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundledocumenttypes)、[Xcode支持文档类型](https://help.apple.com/xcode/mac/current/en.lproj/devddd273fdd.html)：采用现有系统字体UTI/Alternate，避免自称Owner或接管所有文件。
- [Apple onOpenURL](https://developer.apple.com/documentation/swiftui/view/onopenurl(perform:))、[NSURL security scope](https://developer.apple.com/documentation/foundation/nsurl)：scene接收和严格成对释放；本轮只接字体文件，不实现通用下载器/网络服务。
- [Apple字体概览](https://developer.apple.com/documentation/technologyoverviews/fonts)：CoreText直接descriptor可局部使用而不全局注册；沿既有Readium3.11资源通道，不升级依赖或改排版引擎。
- 网格、搜索与导航沿本项目已用的原生SwiftUI/Readium3.11界面边界；文档选择回调继续保留Readium TestApp成熟处理，不自建文件选择器或阅读引擎。

已另核Readium 3.11.0精确基线`d82f44f4f05d87add9e22a8b75abbd61dce745dd`的[TestApp AppDelegate](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/TestApp/Sources/AppDelegate.swift)、[LibraryViewController](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/TestApp/Sources/Library/LibraryViewController.swift)与[Info.plist](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/TestApp/Sources/Info.plist)。URL-open与文档选择delegate都汇入既有异步导入服务；文档角色按格式设置。本项目采用同样的单一导入服务边界，UIKit AppDelegate换成现有SwiftUI scene的onOpenURL，字体采用Alternate Viewer，不照搬其书籍Owner声明、网络导入或try!启动。版本差异/摘要记录在m4-experience-build27-reference-review.json；没有复制第三方源码或升级SDK。

## 用户补充与性能只读线索（CI期间）

用户确认字体主要来自微信、QQ、Alook并希望通用兼容；卡顿在正文和设置都能感到。当前标准文档打开声明覆盖能力仍须逐来源实测，不承诺所有分享面板都会列出普通App。读取本地Readium3.11源码确认连续滚动每次UIScroll回调会请求位置更新；Shared.execute只在等待idle时合并调用，不会串行化已启动的async采样。这是DOM定位排队/主线程开销的具体测量疑点，尚未取得手机触发次数、耗时或FPS，不能当唯一原因。此轮未盲改Vendor位置管线；下一性能片先测未完成采样数，再决定latest-only单飞/尾沿合并，并保留最终fresh完整锚点、关闭/切模式/重开迟到回归。路径/摘要与边界在m4-experience-build27-performance-review.json。当前已经落实的性能范围只有预览停止上采样、导入字体独立惰性网格与折叠低频项，不声称正文流畅度已解决。

## 首候选实际诊断及第二候选修复

b799754/39086068358完整xcresult152/156，4失败、0跳过，源码compiler0/无设备Release。系统暗黑搜索/4次开书、原真实字体位置两例等记录本候选通过，不继承新源。已实际查看失败相关9 PNG/2表和字体首次开书53–54秒原视频帧，仍为spinner；没有认定WebKit唯一原因。原更多DisclosureGroup在整行中央点击后未展开，改44pt整行Button/显式内容，原高级功能断言与预算保持。新预设测试仅将JSON输出sortedKeys以消除不承诺的键顺序，原语义/持久化断言保持。

发现每次readingFontURL逐字节Swift SHA256遍历25MB字体，原新增设置.task还会在目录没变时重复全量校验。设置打开现在先比较32KiB内小目录，未变就复用已验证资源；外部变更通知强制刷新以覆盖同UUID缺失重导修复，首次开书/新资源/显式通知仍完整验证，不跳过完整性。

TXTContentDigest.file的Apple路径使用系统CryptoKit SHA256的init/update(data:)/finalize，沿原64KiB消费、取消/错误/计数上限；Linux仍原portable实现。流式算法的SHA256结果、路径/原件、缓存版本和Parser完全不变。Core只多一个条件系统摘要后端，保持业务/SQLite与UI/Readium隔离，没有swift-crypto/CryptoSwift新包或锁变更。新增两Core已知NIST/跨块131089字节与取消/原件回归，对Apple系统和Linux portable都跑；新增iOS完整文楷25MB导入/三次URL校验计时，原3字体开书20秒预算保持。该修复针对已查明的重复CPU/校验工作，仍不冒称手机正文FPS问题已测完。

[Apple SHA256 init](https://developer.apple.com/documentation/cryptokit/sha256/init())、[update](https://developer.apple.com/documentation/cryptokit/sha256/update(data:))和[finalize](https://developer.apple.com/documentation/cryptokit/sha256/finalize())是iOS13+/macOS10.15+公开增量API，适用本项目iOS16/macOS13/Xcode16.4；[apple/swift-crypto](https://github.com/apple/swift-crypto)也采用可用时委托系统CryptoKit的成熟边界。仅参考API与分平台模式，没有引入其最新Swift6.3实现、私有编译标记或依赖。

## 第三候选：固定字体查询栏
第二候选39089264017实际14/15，字体首次20秒ready/旧高级与持久化回归通过；唯一失败为系统.searchable折叠drawer的AX滚入动作。改复用现有ReaderSearchField，参数化提示/标识，固定顶部44pt原生查询/清空栏，不新增整表重建或引擎搜索。原中文marked-text/光标逻辑不变，panels加入原ReaderSearchFieldTests共16；字体UI仍保留3款/两列/显式选中/实时筛选/预设保留字号/高级持久化，另核44pt/清空恢复/Return收键盘。未增加原20秒预算、未删原断言；尚待真实Apple编译与全量门槛。

## 最终全量前异步复核
应用字体开始时使旧fontCatalogRequestID失效：刷新在导入前读取的目录，不能在导入完成且fontBusy归false之后迟到覆盖新资源列表。关闭/重开及每次浏览请求ID守卫继续保留；不改变导入事务、引擎目录重建或完整锚点策略。第三候选定向只验证其原冻结源；该守卫纳入独立最终完整源，并跑原字体竞态/捕获失败/关闭/重开与全部回归。

## 原生返回录屏新增发现（尚待修正）
第三定向16/16后实际看全新会话录屏1fps总览5表和122原帧/11表，第三返回按下后短暂出现打开排版spinner，再向下关闭。代码成功路径过早close将isReady归false并提前重置returning标记，与录屏一致。拟沿原生dismiss→既有onDisappear清理，成功返回中保持标记并隐藏打开spinner，保存失败仍恢复按钮/可见错误；不加快照、计时等待或动画私有API。当前完整c518源先完成实际验证后归档，不把该诊断的功能过关当动效过关，再对修正源完整回归。第一返回原视频PTS有反转，已记录，不能用于设备帧率结论。


2026-10-18 恢复边界修正：固定Readium3.11 d82f44f源码中JS loaded早于初始位置完成；本地额外等待字体会扩大隐藏期。自动paged位置通知现在与既有显式DOM捕获一样，await前后拒绝未附窗/alpha不足的页，保留原完整Locator；不是性能优化或引擎升级。官方源 https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBSpreadView.swift 。退出原生dismiss前不close模型，以既有onDisappear统一使会话失效。菜单改viewport overlay隔离加载内容布局；目录点击失败是否解决需原测试/原生录屏，不能从代码推断。全量39092416032实际155/157，记录另存，不继承该源门槛。
