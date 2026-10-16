# 本地字体导入

原生取图门槛：ff候选的宋体分页截图还在spinner、初始TXT导入截图为空底色，虽DOMFontFace/位置已就绪仍不能当可读页面通过。锁定3.11的EPUBSpreadView先isSpreadLoaded、待pendingLocation及delegate初始化完成后showSpread才设scrollView.alpha=1。新字体测试active()因此再核实际window和scrollView.alpha>0.99；其后核glyph/位置/原生截图，不修改图片像素、不让静态DOM断言替代已显示正文。运行App源码不变，仍须新完整CI及原生复核。

当前新EPUB验证语义修正：ff824/38906278076仅一条新字体用例失败，原canonical char476与DOM caret476相同、viewport offset=-9.84375，原字符实际部分位于视口内。完整位置允许保留负的viewportOffset（第一行部分裁切），不能以range.top>=0要求整字外框在屏内。最新仅测试改为glyph rect与viewport相交，continuous另核该文字Y与切换前/新采canonical offset差<3px；保留首>100、实际字形、字号/重开/同名路由检查。原124全过，不再改App运行源，尚待新完整CI与原生验收。

## 用户补充：内置中文字体（完整自动门槛及选定原生通过，手机待核）

后续实际诊断/修正候选：e758/38886008057真实128/131。TTF FontFace与导入后可见锚点通过，连续模式150%字号阶段落到p16；TXT测试仅selector未构造fragment导致初始定位超时；字体真UI单次滚动未到主题。采用锁定Readium3.11已有完整锚点invalidate/reload路径，Adapter仅对资源字体（旧/新）排版请求完整重载；普通系统字体连续编辑及配色仍原动态CSS。初次pendingLocation用原evaluateScript观察FontFaceSet.ready的Promise完成后恢复，15秒超时报可见Readium资源错误并允许系统fallback，clear取消旧Task，旧await结果不得通知新reader；依赖/锁/JS资产保持，两个Vendor Swift修改和摘要明确登记。参考[W3C FontFaceSet.ready规范](https://www.w3.org/TR/css-font-loading-3/#font-face-set-ready)、[Apple公开API](https://developer.apple.com/cn/documentation/webkit/wkwebview/callasyncjavascript(_:arguments:in:contentworld:))及仓内3.11完整锚点重载实现，不继续盲加固定延迟。新增真实延迟FontFaceSet.ready关闭/重开竞态，原非零/字体字形/完整锚点/字号断言保留。修正尚须新完整CI和原生复核，不能写成根因全部证实或已修复。

按用户“可以内置几个字体”加入两款离线原件：思源宋体SC Regular静态OTF（24,543,332B，Adobe Source Han Serif 2.003 release revision 7889f11bf31170b5d092a083b357c8c8130f89e0）与霞鹜文楷Regular静态TTF（25,928,940B，官方revision ff2008376313060b2c3f04a61523aaeac4b0b0bf）。完整原OFL与版权、固定来源URL/摘要放在App/Resources/Fonts。原字形未裁剪/转换/修改，二进制及许可保持原字节，.gitattributes显式-text。来源为[Adobe官方仓库](https://github.com/adobe-fonts/source-han-serif/tree/7889f11bf31170b5d092a083b357c8c8130f89e0)与[霞鹜文楷官方仓库](https://github.com/lxgw/LxgwWenKai/tree/ff2008376313060b2c3f04a61523aaeac4b0b0bf)，各自SIL OFL1.1随App分发。

App通过BundledReadingFont稳定UUID读取只读Bundle URL，与最多12款用户字体合并后交给ReadingInterfaces；Adapter有界上限14，既有正文资源窗口仍12，两者无关。内置不复制到用户目录、不占用户名额、不在每次打开时摘要50MB；安装包核字体原字节与许可，WebKit沿现有资源通道按实际选择加载。原importedFontID字段兼容承载已导入或内置资源身份，无schema迁移。设置页同卡片提供两款44pt选择，保留原三选项与文件导入；自定义资源仍明确“配色预览”，不假称上方系统字为实际字体。

新增回归核Bundle两字体/许可/摘要、CoreText中文真实glyph与用户目录为空；扩展新EPUB双模式/TXT非零文字锚点用例，核实际FontFace loaded/CSS family与中文canvas字形签名不同于系统serif，逐款换字并保存/静止重开；新增真UI内置选择/持久化/深色切换及截图/视频。Windows、编译、原生与手机性能分别记录；在新候选成功前不称内置已验收。扩展前38886008057/e758仍跑完取原件，不能替代本版门槛。

2026-10-16，Build23已完整编译并经选定原生复核交付，手机仍单列。Build22用户反馈基本功能正常；不扩大完整设备矩阵。

阅读设置的“我的字体”选择单字体TTF/OTF，32MiB/文件、12款。文件复制与流式摘要在BookFileStore actor，App的独立actor使用公开CoreText描述器并创建字体校验字形数；拒绝字体集合/伪扩展名/无效字体。上限用于限制首次解析和目录规模，尚无大型中文字体手机性能结论。默认轴可用的单字体不提供可变轴调节，不额外支持集合/字体删除/单书覆盖。

字体路径是应用生成UUID/固定文件名，展示名不进CSS/路径。独立fonts-v1小元数据原子写入，Core保持Foundation边界；重复摘要保留原身份，缺失原文件可重导修复。不改SQLite schema/原小说/Locator/正文缓存。复制后复查实际节点和大小，所有管理路径继续逐级拒绝父级与dangling symlink。写失败保留原错和草稿，移动后元数据失败回移，清理失败可见；启动只清StagingFonts，崩溃发生在文件移动与元数据提交间时可能留一个未列入目录的文件，保留不猜删。坏目录保留并提示，不能通过覆盖空目录“修复”。缺文件或摘要改变暂用默认正文、保留用户的原选择并显示说明。

ReadingAppearance的reading-v1只增加可选importedFontID，旧JSON无字段仍合法，坏UUID/类型失败。设置卡沿用灰绿表面/44pt/减少动效按压，导入进行时阻止关闭和并发编辑，有明确进度及失败文本；取消文件选择保持原字体。自定义选择时预览明确是“配色预览”，不把系统预览字假称实际导入字体。字体应用于正文，缺中文字交由系统fallback，导入不承诺字体含中文。

ReadingInterfaces提供可选字体目录capability；ReadiumAdapter用锁定3.11公开CSSFontFamilyDeclaration/CSSFontFace及既有readium资源通道。与主Navigator初始化配置绑定，不注入临时JS、不注册全局字体、不启HTTP服务、不改Vendor或依赖。已有字体切换走原排版保护；新目录则暂停慢滚、采集新完整位置、先保存，再同一host受控重开。每个await核open/request/cancel，关闭作废，迟到结果不能关新reader或清新状态。旧返回点保持；新字体应用失败尝试按旧目录/外观与同一完整锚点恢复，失败显示重试打开。已经提交的字体不会因为离开页面而删除。字体重排、普通字号和重开沿用完整EPUB DOMRange/TXT byte+UTF16，不使用百分比替代。

API与成熟实现：重读[Readium官方字体指南](https://github.com/readium/swift-toolkit/blob/develop/docs/Guides/Navigator/EPUB%20Fonts.md)、[Readium CSS字体说明](https://readium.org/css/docs/CSS10c-custom_fonts.html)，具体签名/参数顺序以本仓3.11文件为准。现有WebViewServer已包含[issue802](https://github.com/readium/swift-toolkit/issues/802)字体CORS修复，本片不重复补。Apple的[CTFontManagerCreateFontDescriptorsFromURL](https://developer.apple.com/documentation/coretext/ctfontmanagercreatefontdescriptorsfromurl(_:))用于文件内描述，不把descriptor可读当实际WebKit渲染通过。沿既有文档选择器coordinator保活/单次完成回调，避免曾经首轮无响应的问题；取消UI采用既有封面测试验证过的DocumentManager本地AX框架。

测试字体复用仓内Readium随附IA Writer Duospace Regular（81636B TTF），按原bytes复制到Fixtures/Fonts，OFL同行保存。属于验证样本，不内建字体商店；含中文小说测试中的汉字仍可能fallback。生产不下载字体或读取个人样书。测试需要实际FontFace loaded+CSS family+拉丁canvas宽度不同，EPUB两模式非零文字可见/TXT稳定byte+UTF16及视口、150%字号与静止重开、原件bytes、12资源上限、错误和关闭竞态。真UI覆盖字体选择/持久化/深色/恢复默认及原生选择器取消；有效字体输入由真实CoreText服务/ReaderViewModel集成测试覆盖，不能宣称真UI已走通所有File Provider。

Windows语法与工具测试、Linux/macOS Core、真实iOS集成/界面、无签名Release23及PNG/录屏/原始帧复核分别设门槛。普通签名/TrollStore、真系统辅助功能/旋转、大中文字体首次加载/内存/FPS/功耗和全样书矩阵继续单列，M4整体未完成。

## 同名字体路由

后续38901198541实际运行不再启动缺库，关闭字体ready迟到回归与两字体UI/CoreText通过；原件仍完整保存。新EPUB连续多次换字体测试须按每次操作前新采canonical DOMRange判断保留，而不能把第一轮分页中靠后仍可见的文字当作任意后续字体的第一行位置。保留首次>100UTF16/TTF/150%字号/重开条件，后续每次采完整point后核真实字体及该point可见；同名URL独立和切回首字宽断言不变。TXT重载可能暂时没有p，等待谓词先验证元素存在，再读取样式和位置；不是吞掉脚本异常或放宽锚点。两旧回归本轮也有瞬时失败，原主体不改，不宣称其根因已修。测试修正候选与7ab运行源码一致，仍须独立全量验证。

3.11原资源闭包取file.lastPathSegment，WebViewServer.serve按给定route精确插入、没有自动区分同名文件。用户目录使用稳定UUID/font.ttf，因此给每个FileURL的route加独立UUID段，原servedFonts仍在同一Navigator跨章节复用。不迁移目录、不复制别名字体、不改原字节或font-face公开配置。新EPUB双模式用例真实导入IA与文楷到两个同名font.ttf路径，断言内联CSS的源URL独立、实际中文字形、切回首款字宽一致与原文字可见，随后核原两内置及重开。此为新运行候选，须完整新CI。

## iOS18.5模拟器的WebKit293831

43e/bc6/2b5/255候选原始日志显示dyld在执行测试前找不到libswiftWebKit.dylib，不能将其后UI缺少PID当各功能回归的源码故障或通过。官方WebKit293831明确两种callAsyncJavaScript Swift入口均受影响（min<=18.3+18.5sim）；不提高iOS16门槛、不改用户/CI模拟器、不注入DYLD。最终候选使用既有非refined evaluateScript注册标准document.fonts.ready.then状态，最多15s/32ms检查Promise是否完成，真正完成而非固定延时决定pendingLocator恢复；失败可见，clear取消Task，原关闭迟到/字体重开回归不减。Swift语法/全CI/原生仍待新门槛，官方资料 https://bugs.webkit.org/show_bug.cgi?id=293831 。

## 隐藏初始化页面的位置采样

92ad/38911801177真实log在第二次导入时变为h1/char0/章节头，上一阅读位置仍在长段；与实际showSpread之前的隐藏DOM读取吻合。用户连续换字也可能在初始化恢复中触发捕获，不能只让测试等待。现在Vendor分页preserve先/后核scrollView.window与alpha1，隐藏初始化页返回不可用；Adapter捕获以32ms让步、最多3s等待可用样本，每次await前后核取消、openRequest、navigator和排版任务，不采过渡章节头，不用百分比替代。上限到期仍显式unavailable，关闭/新会话抛CancellationError。真实font-ready延迟用例新增关闭中的capture task，必须取消，不能给出旧临时头部或新reader位置。依赖/锁/排版JS不变，三个Vendor Swift改动均明示摘要；运行源码已有这次必要修改，之前仅测试变化区间另列，须新全量CI。

## 实际交付结果

Build23内置思源宋体、霞鹜文楷与本地字体导入已交付；[完整CI 38918803378](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38918803378)，实际源`62700a159cffc72ef256eabdc24184bf6092b0a7`，验证ref `codex/m4-font-readable-capture`。Linux/macOS Core各133、iOS 134/134（115集成+19真UI）、失败/跳过0；test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release23/min16。三锁六pins、522源码/资源blob、每平台四长TXT Release探针、内置字库/原OFL在IPA内原字节已核。Windows433语法新增0/54既有语法限制、17工具通过；语法不算编译。

阅读设置→外观→字体与字号可离线直接选两款内置，约48.1MiB原字库，不裁字、不占12款用户导入名额。原默认/衬线/无衬线保留；我的字体可导入TTF/OTF单字体，≤32MiB/款。后台协调复制/流式摘要/CoreText验证，目录与全局选择保存；重复复用、缺失重导修复、取消保持、失败提示。缺文件/损坏暂用默认且保留原选择，自定义资源明确配色预览，正文实际字体/缺字fallback独立生效。44pt/主题/减少动效按压沿用原界面。

App只读Bundle稳定UUID与导入资源合并≤14 faces，原正文窗口仍≤12；内置不在开书时复制或扫描50MB。首次定位在FontFaceSet.ready后恢复，15秒上限/取消与可见错误；位置捕获等待实际native可读（最多3s/32ms），避免连续换字读到隐藏初始化页的章节头；关闭迟到字体回归单列。每个FileURL独立UUID资源路由、章节复用，两个同名导入TTF的URL/中文字形/切回字宽保持有真实回归。Core Foundation相对路径与fonts-v1目录，reading-v1可选UUID兼容资源身份，无schema/小说/缓存/完整Locator变更。ReadingInterfaces→Adapter公开Readium3.11 CSSFontFace/既有资源通道；无全局注册/HTTP/JS资产或依赖升级；Vendor三个Swift文件维护已有重载路径、字体就绪、独立路由及可读位置采样守卫，UPSTREAM明确登记。新增字体暂停慢滚、采完整锚点先保存再受控重开，资源字体排版走完整锚点重载，系统字体连续编辑保留原重排；每await核会话/请求，迟到关闭不改新reader，失败恢复旧目录/位置。原回看返回点保持。受改35原测试主体保持，16新增（6Core+8集成+2真UI）。取舍与固定来源见READING_FONT_IMPORT_DESIGN.md及m4-font-build23-bundled-provenance.json。

下载`build/XianxiaReader-LocalFonts-Build23.ipa`，SHA256 `116de6e07de131019ea70197f9e36cb07a89fc7c773a1311c2922d8be74958f2`；原创样书/15实际Preview/1未验收诊断/许可与拉丁导入样本包`build/XianxiaReader-LocalFonts-Build23-TestKit.zip`，SHA256 `9be4d45909b6dffff8adc6008cddcf1a25d718c8f258930a5d269875dab52286`。覆盖安装，+菜单确认0.0.1 (23)。39旧包与所有未提交文件保留。

原生人工复核范围：当前CI的78张原生PNG/13联系表全部人工查看；含两内置EPUB连续/分页和TXT共6张可见中文正文，文楷与宋体字形有区别，深色柔和。iA EPUB两模式也有实际正文，但iA TXT隔离图只剩底色，旧巨段TXT隔离图仅两行，两图明确不作可读全页通过。19条真UI原视频保留，本轮只复核其中4条、共207.98s的完整1秒总览15表，以及4个窗口235个原始VFR帧/22表；无fps滤镜或插值，原PTS保留。字体选择/取消/重开、返回及减少动效退出的选定最终状态可接受；个别过渡原帧有区域重复/重叠，未验收全动效无瑕疵，原因及手机观感仍待核。

实际CoreText中文glyph、Bundle原件/许可、WebKit FontFace loaded/CSS与中文canvas签名、EPUB双模式/TXT非零byte+UTF16/字号/逐款换字与静止重开有回归。内置OTF真实页面已核；外部有效字体由真实服务/VM集成输入，真UI覆盖选择/持久化/深色/默认及原生文件选择器取消，不假称UI已点击导入所有File Provider。手机首次加载/内存/FPS/功耗、普通签名/TrollStore/辅助功能/旋转/全样书矩阵仍待验收；字体集合/可变轴调节/删除/单书覆盖尚未实现，M4整体未完。

历史分列：38880257296由Agent补强而取消；38881623233=129/131（两新初始定位）；e758/38886008057=128/131（连续字体150%位置/TXT构造/UI滚动）；277/38887978313=131/133（两新初始定位、原124全过、内置CoreText与两字体UI过，另有新TXT helper警告）。43e/38890891607、bc6/38892156952、2b5/38892611316、255/38893802693的集成host均在测试前因libswiftWebKit缺失abort，后续UI进程缺失；bc6最终cancelled且原因未核、未由本Agent取消，其余failure，不冒称134主体实际执行。原ZIP/summary/full.log与各receipt保留；查官方WebKit293831后当前改用原evaluateScript观察fonts.ready Promise，不改模拟器/最低iOS或锁。7ab/38901198541实际130/134、0跳过/0源warning，关闭字体ready迟到及两字体UI/CoreText通过，但两旧瞬时回归和两新测试失败，完整原件保留；当前ff824只修两新测试取样（每次独立换字采fresh完整point、TXT等待p存在），首非零/首次字号/静止重开/同名URL/实际字形/字宽断言及旧35主体均保留。旧回归根因未定，不追认旧失败。后ff824/38906278076实133/134、旧124全过，只新EPUB整字外框可见判定错误；原char476/DOM476/offset-9.84375已保留。新测试改视口相交并加continuous3px原Y，19db再等待实际window和scrollView.alpha1后取原生正文，避免DOMready但showSpread未完成的spinner/空图；这段仅测试变化，此前测试修正区间运行源码保持7ab；后来92ad原始log确认隐藏初始化页采样可能取得h1/char0，现Vendor分页采样核window/alpha1，Adapter最多3s/32ms等待并在每await核会话/取消，新真实关闭capture回归保持。此运行源码变更用新全量门槛，不追认旧结果。当前完整独立结果才用于交付。单独临时ref用于保留各旧轮结果，本版手机门槛不继承Build22基本功能反馈。
