# 本地字体导入

## 用户补充：内置中文字体（本轮待完整编译）

后续实际诊断/修正候选：e758/38886008057真实128/131。TTF FontFace与导入后可见锚点通过，连续模式150%字号阶段落到p16；TXT测试仅selector未构造fragment导致初始定位超时；字体真UI单次滚动未到主题。采用锁定Readium3.11已有完整锚点invalidate/reload路径，Adapter仅对资源字体（旧/新）排版请求完整重载；普通系统字体连续编辑及配色仍原动态CSS。初次pendingLocation用原evaluateScript观察FontFaceSet.ready的Promise完成后恢复，15秒超时报可见Readium资源错误并允许系统fallback，clear取消旧Task，旧await结果不得通知新reader；依赖/锁/JS资产保持，两个Vendor Swift修改和摘要明确登记。参考[W3C FontFaceSet.ready规范](https://www.w3.org/TR/css-font-loading-3/#font-face-set-ready)、[Apple公开API](https://developer.apple.com/cn/documentation/webkit/wkwebview/callasyncjavascript(_:arguments:in:contentworld:))及仓内3.11完整锚点重载实现，不继续盲加固定延迟。新增真实延迟FontFaceSet.ready关闭/重开竞态，原非零/字体字形/完整锚点/字号断言保留。修正尚须新完整CI和原生复核，不能写成根因全部证实或已修复。

按用户“可以内置几个字体”加入两款离线原件：思源宋体SC Regular静态OTF（24,543,332B，Adobe Source Han Serif 2.003 release revision 7889f11bf31170b5d092a083b357c8c8130f89e0）与霞鹜文楷Regular静态TTF（25,928,940B，官方revision ff2008376313060b2c3f04a61523aaeac4b0b0bf）。完整原OFL与版权、固定来源URL/摘要放在App/Resources/Fonts。原字形未裁剪/转换/修改，二进制及许可保持原字节，.gitattributes显式-text。来源为[Adobe官方仓库](https://github.com/adobe-fonts/source-han-serif/tree/7889f11bf31170b5d092a083b357c8c8130f89e0)与[霞鹜文楷官方仓库](https://github.com/lxgw/LxgwWenKai/tree/ff2008376313060b2c3f04a61523aaeac4b0b0bf)，各自SIL OFL1.1随App分发。

App通过BundledReadingFont稳定UUID读取只读Bundle URL，与最多12款用户字体合并后交给ReadingInterfaces；Adapter有界上限14，既有正文资源窗口仍12，两者无关。内置不复制到用户目录、不占用户名额、不在每次打开时摘要50MB；安装包核字体原字节与许可，WebKit沿现有资源通道按实际选择加载。原importedFontID字段兼容承载已导入或内置资源身份，无schema迁移。设置页同卡片提供两款44pt选择，保留原三选项与文件导入；自定义资源仍明确“配色预览”，不假称上方系统字为实际字体。

新增回归核Bundle两字体/许可/摘要、CoreText中文真实glyph与用户目录为空；扩展新EPUB双模式/TXT非零文字锚点用例，核实际FontFace loaded/CSS family与中文canvas字形签名不同于系统serif，逐款换字并保存/静止重开；新增真UI内置选择/持久化/深色切换及截图/视频。Windows、编译、原生与手机性能分别记录；在新候选成功前不称内置已验收。扩展前38886008057/e758仍跑完取原件，不能替代本版门槛。

2026-10-16，Build23源码候选，尚未完整编译/原生复核/交付。Build22用户反馈基本功能正常；不扩大完整设备矩阵。

阅读设置的“我的字体”选择单字体TTF/OTF，32MiB/文件、12款。文件复制与流式摘要在BookFileStore actor，App的独立actor使用公开CoreText描述器并创建字体校验字形数；拒绝字体集合/伪扩展名/无效字体。上限用于限制首次解析和目录规模，尚无大型中文字体手机性能结论。默认轴可用的单字体不提供可变轴调节，不额外支持集合/字体删除/单书覆盖。

字体路径是应用生成UUID/固定文件名，展示名不进CSS/路径。独立fonts-v1小元数据原子写入，Core保持Foundation边界；重复摘要保留原身份，缺失原文件可重导修复。不改SQLite schema/原小说/Locator/正文缓存。复制后复查实际节点和大小，所有管理路径继续逐级拒绝父级与dangling symlink。写失败保留原错和草稿，移动后元数据失败回移，清理失败可见；启动只清StagingFonts，崩溃发生在文件移动与元数据提交间时可能留一个未列入目录的文件，保留不猜删。坏目录保留并提示，不能通过覆盖空目录“修复”。缺文件或摘要改变暂用默认正文、保留用户的原选择并显示说明。

ReadingAppearance的reading-v1只增加可选importedFontID，旧JSON无字段仍合法，坏UUID/类型失败。设置卡沿用灰绿表面/44pt/减少动效按压，导入进行时阻止关闭和并发编辑，有明确进度及失败文本；取消文件选择保持原字体。自定义选择时预览明确是“配色预览”，不把系统预览字假称实际导入字体。字体应用于正文，缺中文字交由系统fallback，导入不承诺字体含中文。

ReadingInterfaces提供可选字体目录capability；ReadiumAdapter用锁定3.11公开CSSFontFamilyDeclaration/CSSFontFace及既有readium资源通道。与主Navigator初始化配置绑定，不注入临时JS、不注册全局字体、不启HTTP服务、不改Vendor或依赖。已有字体切换走原排版保护；新目录则暂停慢滚、采集新完整位置、先保存，再同一host受控重开。每个await核open/request/cancel，关闭作废，迟到结果不能关新reader或清新状态。旧返回点保持；新字体应用失败尝试按旧目录/外观与同一完整锚点恢复，失败显示重试打开。已经提交的字体不会因为离开页面而删除。字体重排、普通字号和重开沿用完整EPUB DOMRange/TXT byte+UTF16，不使用百分比替代。

API与成熟实现：重读[Readium官方字体指南](https://github.com/readium/swift-toolkit/blob/develop/docs/Guides/Navigator/EPUB%20Fonts.md)、[Readium CSS字体说明](https://readium.org/css/docs/CSS10c-custom_fonts.html)，具体签名/参数顺序以本仓3.11文件为准。现有WebViewServer已包含[issue802](https://github.com/readium/swift-toolkit/issues/802)字体CORS修复，本片不重复补。Apple的[CTFontManagerCreateFontDescriptorsFromURL](https://developer.apple.com/documentation/coretext/ctfontmanagercreatefontdescriptorsfromurl(_:))用于文件内描述，不把descriptor可读当实际WebKit渲染通过。沿既有文档选择器coordinator保活/单次完成回调，避免曾经首轮无响应的问题；取消UI采用既有封面测试验证过的DocumentManager本地AX框架。

测试字体复用仓内Readium随附IA Writer Duospace Regular（81636B TTF），按原bytes复制到Fixtures/Fonts，OFL同行保存。属于验证样本，不内建字体商店；含中文小说测试中的汉字仍可能fallback。生产不下载字体或读取个人样书。测试需要实际FontFace loaded+CSS family+拉丁canvas宽度不同，EPUB两模式非零文字可见/TXT稳定byte+UTF16及视口、150%字号与静止重开、原件bytes、12资源上限、错误和关闭竞态。真UI覆盖字体选择/持久化/深色/恢复默认及原生选择器取消；有效字体输入由真实CoreText服务/ReaderViewModel集成测试覆盖，不能宣称真UI已走通所有File Provider。

Windows语法与工具测试、Linux/macOS Core、真实iOS集成/界面、无签名Release23及PNG/录屏/原始帧复核分别设门槛。普通签名/TrollStore、真系统辅助功能/旋转、大中文字体首次加载/内存/FPS/功耗和全样书矩阵继续单列，M4整体未完成。

## 同名字体路由

3.11原资源闭包取file.lastPathSegment，WebViewServer.serve按给定route精确插入、没有自动区分同名文件。用户目录使用稳定UUID/font.ttf，因此给每个FileURL的route加独立UUID段，原servedFonts仍在同一Navigator跨章节复用。不迁移目录、不复制别名字体、不改原字节或font-face公开配置。新EPUB双模式用例真实导入IA与文楷到两个同名font.ttf路径，断言内联CSS的源URL独立、实际中文字形、切回首款字宽一致与原文字可见，随后核原两内置及重开。此为新运行候选，须完整新CI。

## iOS18.5模拟器的WebKit293831

43e/bc6/2b5/255候选原始日志显示dyld在执行测试前找不到libswiftWebKit.dylib，不能将其后UI缺少PID当各功能回归的源码故障或通过。官方WebKit293831明确两种callAsyncJavaScript Swift入口均受影响（min<=18.3+18.5sim）；不提高iOS16门槛、不改用户/CI模拟器、不注入DYLD。最终候选使用既有非refined evaluateScript注册标准document.fonts.ready.then状态，最多15s/32ms检查Promise是否完成，真正完成而非固定延时决定pendingLocator恢复；失败可见，clear取消Task，原关闭迟到/字体重开回归不减。Swift语法/全CI/原生仍待新门槛，官方资料 https://bugs.webkit.org/show_bug.cgi?id=293831 。
