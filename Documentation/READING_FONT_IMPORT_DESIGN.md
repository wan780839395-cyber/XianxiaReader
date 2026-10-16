# 本地字体导入

2026-10-16，Build23源码候选，尚未完整编译/原生复核/交付。Build22用户反馈基本功能正常；不扩大完整设备矩阵。

阅读设置的“我的字体”选择单字体TTF/OTF，32MiB/文件、12款。文件复制与流式摘要在BookFileStore actor，App的独立actor使用公开CoreText描述器并创建字体校验字形数；拒绝字体集合/伪扩展名/无效字体。上限用于限制首次解析和目录规模，尚无大型中文字体手机性能结论。默认轴可用的单字体不提供可变轴调节，不额外支持集合/字体删除/单书覆盖。

字体路径是应用生成UUID/固定文件名，展示名不进CSS/路径。独立fonts-v1小元数据原子写入，Core保持Foundation边界；重复摘要保留原身份，缺失原文件可重导修复。不改SQLite schema/原小说/Locator/正文缓存。复制后复查实际节点和大小，所有管理路径继续逐级拒绝父级与dangling symlink。写失败保留原错和草稿，移动后元数据失败回移，清理失败可见；启动只清StagingFonts，崩溃发生在文件移动与元数据提交间时可能留一个未列入目录的文件，保留不猜删。坏目录保留并提示，不能通过覆盖空目录“修复”。缺文件或摘要改变暂用默认正文、保留用户的原选择并显示说明。

ReadingAppearance的reading-v1只增加可选importedFontID，旧JSON无字段仍合法，坏UUID/类型失败。设置卡沿用灰绿表面/44pt/减少动效按压，导入进行时阻止关闭和并发编辑，有明确进度及失败文本；取消文件选择保持原字体。自定义选择时预览明确是“配色预览”，不把系统预览字假称实际导入字体。字体应用于正文，缺中文字交由系统fallback，导入不承诺字体含中文。

ReadingInterfaces提供可选字体目录capability；ReadiumAdapter用锁定3.11公开CSSFontFamilyDeclaration/CSSFontFace及既有readium资源通道。与主Navigator初始化配置绑定，不注入临时JS、不注册全局字体、不启HTTP服务、不改Vendor或依赖。已有字体切换走原排版保护；新目录则暂停慢滚、采集新完整位置、先保存，再同一host受控重开。每个await核open/request/cancel，关闭作废，迟到结果不能关新reader或清新状态。旧返回点保持；新字体应用失败尝试按旧目录/外观与同一完整锚点恢复，失败显示重试打开。已经提交的字体不会因为离开页面而删除。字体重排、普通字号和重开沿用完整EPUB DOMRange/TXT byte+UTF16，不使用百分比替代。

API与成熟实现：重读[Readium官方字体指南](https://github.com/readium/swift-toolkit/blob/develop/docs/Guides/Navigator/EPUB%20Fonts.md)、[Readium CSS字体说明](https://readium.org/css/docs/CSS10c-custom_fonts.html)，具体签名/参数顺序以本仓3.11文件为准。现有WebViewServer已包含[issue802](https://github.com/readium/swift-toolkit/issues/802)字体CORS修复，本片不重复补。Apple的[CTFontManagerCreateFontDescriptorsFromURL](https://developer.apple.com/documentation/coretext/ctfontmanagercreatefontdescriptorsfromurl(_:))用于文件内描述，不把descriptor可读当实际WebKit渲染通过。沿既有文档选择器coordinator保活/单次完成回调，避免曾经首轮无响应的问题；取消UI采用既有封面测试验证过的DocumentManager本地AX框架。

测试字体复用仓内Readium随附IA Writer Duospace Regular（81636B TTF），按原bytes复制到Fixtures/Fonts，OFL同行保存。属于验证样本，不内建字体商店；含中文小说测试中的汉字仍可能fallback。生产不下载字体或读取个人样书。测试需要实际FontFace loaded+CSS family+拉丁canvas宽度不同，EPUB两模式非零文字可见/TXT稳定byte+UTF16及视口、150%字号与静止重开、原件bytes、12资源上限、错误和关闭竞态。真UI覆盖字体选择/持久化/深色/恢复默认及原生选择器取消；有效字体输入由真实CoreText服务/ReaderViewModel集成测试覆盖，不能宣称真UI已走通所有File Provider。

Windows语法与工具测试、Linux/macOS Core、真实iOS集成/界面、无签名Release23及PNG/录屏/原始帧复核分别设门槛。普通签名/TrollStore、真系统辅助功能/旋转、大中文字体首次加载/内存/FPS/功耗和全样书矩阵继续单列，M4整体未完成。
