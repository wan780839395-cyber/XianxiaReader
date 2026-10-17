# 字体资源与导入（Build23）

本文为Build23导入首片历史记录。Build24已扩至六款并在设置显示真实字形，当前实现/验收边界见READING_FONT_BROWSER_DESIGN.md及M4_FONT_PREVIEW_VALIDATION_REPORT.json。下文两款、配色预览和14目录上限仅代表旧版；当前六款/真实字形/18目录，正文窗口12保持。

2026-10-17。完整自动门槛通过、已打包可安装候选；选定原生状态已核，隔离截图和过渡原帧限制保留，手机与M4整体未验收。实际源62700a159cffc72ef256eabdc24184bf6092b0a7 / CI38918803378。

## 用户操作与边界

阅读设置→外观→字体与字号可离线选思源宋体、霞鹜文楷，保留系统默认/衬线/无衬线。我的字体支持TTF/OTF单字体，单款≤32MiB、最多12款；内置不占名额。全局保存选择、重开沿用，重复内容复用原身份，缺失重导可修复。取消保持、写失败可见，缺失/损坏暂用默认而保留原选择。导入不承诺字库含中文，缺字由系统补全。自定义资源的设置卡明确配色预览，正文另用真实字库。

两内置均是未修改的完整静态原件，原OFL和固定官方revision、路径、大小与SHA在App/Resources/Fonts/PROVENANCE.json，IPA逐字节核对：思源宋体SC Regular OTF2.003（24,543,332B），霞鹜文楷Regular TTF1.530（25,928,940B）。合计50,472,272B，约48.1MiB。不开商店、不运行时下载、不裁字。字体集合、可变轴调节、删除、单书覆盖暂未实现。

## 存储与并发

XianxiaCore保持Foundation/SQLite边界，新增稳定ReadingFontAsset与独立fonts-v1原子目录，字体路径使用UUID和固定文件名，相对路径/父级/dangling symlink规则继续适用。复制/有界流式摘要在存储actor；App独立actor检查SFNT签名、CoreText单descriptor与glyph，持有security-scope至完成。不全球注册字体、不吞原始错误。

原小说、schema、正文缓存与Locator协议不变。目录损坏保留报错，不能覆盖空目录“修复”。移动后元数据失败回移，清理失败保留原错；启动只清StagingFonts，可能存在的未列入目录原件保留不猜删。用户字体开书校验摘要和相对路径，内置只读Bundle URL不每次扫描或复制50MB。大量大用户字库开书成本尚须手机测量。

reading-v1可选importedFontID继续兼容，表示已导入或内置的资源UUID；旧偏好无字段仍合法。两内置资源与最多12用户资源合并后经ReadingInterfaces可选capability送Adapter，最多14faces；正文资源窗口仍≤12，两种上限独立。

## Readium3.11集成与实际取舍

使用锁定3.11公开CSSFontFamilyDeclaration/CSSFontFace、Navigator配置与现有readium资源通道。已有issue802字体CORS修复继续使用；不加HTTP服务、不改JS资产或六pins依赖锁。字体文件按选择由WebKit加载。上游路径只取lastPathSegment会让两个UUID/font.ttf冲突，因此按每FileURL分配独立UUID路由，servedFonts仍跨章节复用，无原字节或存储迁移。

目录新增时暂停慢滚、采完整位置并保存，再受控关闭/重开同一本书；已有资源字体排版使用原完整锚点invalidate/reload，普通系统字体连续编辑/纯换色保留原动态路径。每await校验open/request/navigator、取消和排版任务，旧capture/字体ready不能改变新reader。失败恢复旧目录、外观与完整锚点，原返回点保持；已提交字体不因离开页面而删掉。

字体加载会改变行宽，pendingLocator因此等标准document.fonts.ready真正完成后再恢复；沿已有非refined evaluateScript观察Promise，32ms让步、15s上限，取消/资源失败可见。官方WebKit293831记录iOS18.5模拟器与较低部署目标下refined callAsyncJavaScript缺libswiftWebKit；查证后回到现有JS桥，不提高iOS16、不改模拟器、不注入DYLD。

显式位置捕获不能读取showSpread之前的隐藏初始化DOM。Vendor分页采样前后校验实际window/scrollView.alpha、页/offset身份；Adapter最多3s/32ms等待，所有await前后核取消与会话，到期明确unavailable。完整EPUB DOMRange和TXT byte+UTF16仍为事实，不用百分比替代。三个维护Vendor Swift文件的修改/hash已在UPSTREAM.json登记。

官方/成熟实现参考及差异：

- [Readium字体指南](https://github.com/readium/swift-toolkit/blob/develop/docs/Guides/Navigator/EPUB%20Fonts.md)：只借用字体声明/资源通道，实际API以本仓锁定3.11源码为准。
- [Readium CSS字体说明](https://readium.org/css/docs/CSS10c-custom_fonts.html)、[issue802](https://github.com/readium/swift-toolkit/issues/802)：复用已有字体服务和CORS修复，不另造排版引擎。
- [W3C FontFaceSet.ready](https://www.w3.org/TR/css-font-loading-3/#font-face-set-ready)：以加载Promise而非固定延迟决定恢复。
- [WebKit293831](https://bugs.webkit.org/show_bug.cgi?id=293831)：规避此次已由原始dyld日志验证的Swift overlay入口问题，不改变最低系统或依赖。
- [Apple CoreText公开文件描述器API](https://developer.apple.com/documentation/coretext/ctfontmanagercreatefontdescriptorsfromurl(_:))：只用于后台验证，descriptor可读不当WebKit已经显示。
- 文件选择器复用项目已验证的Coordinator保活/单次消费，避免此前首次导入丢回调问题；原生选择器取消采用既有测试路径。

## 验证与剩余门槛

Windows433语法/17工具；Linux/macOS Core各133；iOS134/134（115集成+19真正UI），失败/跳过0、源warning/error0，严格无签名Release23、522源码blob/三锁/字体原件与许可核对。35原测试主体保留、16新增。真实测试包含CoreText中文字形、同名TTF路由独立、FontFace加载/CSS/canvas字形、EPUB双模式/TXT非零完整锚点/字号/静止重开/关闭取消与旧回归。拉丁TTF样本iA Writer Duospace原bytes和OFL来自仓内Readium，汉字fallback，不当内置中文字体。

78张实际PNG、4条视频完整总览与235原始VFR帧人工复核范围见ValidationLogs/m4-font-build23-native-review.json。两内置六张EPUB/TXT实际中文字形及选定状态可接受；一张导入字体TXT隔离图空底色、旧巨段隔离图仅两行，不作可读满页通过。部分过渡原帧区域重叠/重复，原因未明，未验收全动效，原件不修图、PTS不当手机FPS。15可用Preview与1未验收诊断分别打包。

普通签名/TrollStore、手机大字体首次加载/内存/FPS/功耗、所有File Provider有效外部字体点击导入、真实辅助功能/旋转与全部样书待核。真UI覆盖选择/取消/持久化/深色/系统恢复，有效文件输入另由真实服务/VM集成覆盖。M4未完成，不提前M5。

逐步候选及历史取舍归档READING_FONT_IMPORT_DEVELOPMENT_2026-10-17.md；历史失败/取消不追认，当前门槛见M4_FONT_VALIDATION_REPORT.json和HANDOFF.md。
