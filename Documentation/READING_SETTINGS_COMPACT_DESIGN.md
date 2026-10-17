# Build25 设置页精简与字形预览

用户实测Build24主要在上下滑动字体列表时卡顿，主样例存在不协调的内部矩形，页面过长。目标为原生可读/紧凑和减少实际重复工作，不改正文默认排版、Readium、Core、DB或Locator。旧Build24自动验收不继承到本轮。

已有代码的具体重复工作：ReadingFontPreview.body中UIImage(data:)在每次SwiftUI刷新重新构造图像；异步spinner和按字库测量图片高度不一致引发行高变化；六个长字体行及嵌套卡片增加滚动距离。手机根因和FPS尚无Instruments实录，以上是可验证的代码路径，并非已证明全部卡顿根因。

沿项目已有CoverImagePipeline的CGImage/actor边界：CoreText在actor直接绘制透明CGImage，SwiftUI持有结果，不在滚动路径PNG编解码；保留一个CGFont与最多12张/8MiB已绘制图片。原render仅用于原生测试导出附件，旧回归主体不删除。图片以黑色alpha mask缓存，由原生随主题着色，改底色不重新读字体或重绘样例；无图片内底色/边线，主样例外层只留柔和纸色，无阴影框线。

图片/加载/失败固定同一个槽位，字库就绪不改变网格行高；换请求时不冒用上一次字形，取消及恢复可用状态有明确ID守卫。六款字体通常两列，辅助功能大字时单列，保留真实字形、选中值、44pt目标与减少动效。名称足够辨识，风格副标题转无障碍标签；字号仍在列表前。分组固定于顶部；排版/手感页不重复放不反映段落参数的字形卡片，段落/留白合并连续行，控件与旧偏好范围不变。

参考Apple官方Creating performant scrollable stacks与Understanding and improving SwiftUI performance（https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks 、https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance），采用稳定尺寸/身份、减少body同步工作。Apple UIImage.preparingForDisplay文档明确不应在主线程直接预解码（https://developer.apple.com/documentation/uikit/uiimage/preparingfordisplay()）；本轮选择已有的直接CGImage路径，不新增UIKit解码调度层或依赖。最低iOS16与现有SwiftUI网格/API保持，未套用新系统专有滚动接口。

新增真实iOS缓存/透明/有界像素回归和真UI两列/重复滚动行高/换色/排版一屏回归。旧字体/CoreText/重开/选择器与完整正文位置断言保持；Windows语法不算编译，完整Core135各/iOS145（124集成+21UI）与Release25及所列原生材料已实际核验，当前交付仅覆盖这一切片。手机冷加载/实际帧率/内存功耗、系统大字/VoiceOver全矩阵另验，不能宣称模拟器截图等于卡顿根因及手机性能解决。

复查修正：紧凑列采用六字单行样例，避免原9字在156pt源宽下末字折行；原书排版只禁用段落/对齐调整，左右留白维持可调整，真UI新增相应断言。前56e候选因该布局禁用范围复查被替代，独立CI继续完成，未取消、不作为新源门槛。

## 实际结果

## Build25 紧凑设置与透明字形（2026-10-17）

Build25本切片已交付；实际源 f90a33cd476f2ffa468f5577fe4002dd47b690f0 / ref codex/m4-settings-compact-rules / [完整CI 39014160303](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39014160303)。Linux/macOS Core各135，iOS145/145（124集成+21真UI）、失败/跳过0，test/export/summary/recording均退出0，严格无签名iPhoneOS arm64 Release25/min16。三锁六pins、532编译/资源blob、每平台4组长TXT Release探针与IPA六字体/原OFL原字节已核。Windows435语法新增0/54既有Vendor限制、17工具通过，语法不算编译。受改两测试文件9原主体保持、2新增；其他既有测试继续执行。

按用户“样例内框不好看、上下滑动字体列表卡顿、设置别拉太长”的实测反馈，字形改为全透明CGImage，由原生着色；后台CoreText直接绘制并缓存，滚动路径不再PNG编解码。一个CGFont、最多12图/8MiB像素；换主题只着色，字库/字号/可用性改变才请求新图。加载/就绪/失败固定同一槽位，切换请求不冒用旧字形、取消后不发布。旧PNG导出仅供诊断，不在UI热路径。

六款字体通常两列，辅助功能大字为单列，保留实际字形、选中语义和44pt控件。名称前置，风格说明转无障碍标签；分组入口固定顶部。主样例只留柔和纸色，去掉内图底色/边框/阴影；排版和手感页去重复样例，留白与段落调整合成紧凑连续行。字体/字号/字距/字重/缩进/行段距/对齐和原书样式范围、默认值、全部reading-v1旧偏好保持。无Core/DB/Readium/Vendor/Locator/依赖变动，资源目录18/正文窗口12保持。

新增真实iOS透明像素/六字体24次重复浏览复用同一CGImage/12图及8MiB上限回归，真UI核两列、反复滚动行高不变、换色、固定分组及当前模拟器排版页一屏可操作。代码中的重复解码/行高变动已移除；没有手机Instruments证据，不把这些检查写成全部卡顿根因或手机FPS验收。

安装 build/XianxiaReader-SettingsCompact-Build25.ipa（SHA256 7a73f85220864770717def140409a429e83852017229399cb82c55b68f735284），原创样书/21张本轮原生Preview与6张透明字形诊断/原许可与导入字体样本包 build/XianxiaReader-SettingsCompact-Build25-TestKit.zip（SHA256 4982895832fa29582967d53767e9d0ee62b9ad26e6410fc31003e56e9fbb5fc8）。覆盖更新保留书库，+菜单确认0.0.1 (25)。43旧包与未提交源码/恢复备份保留。

原生复核：113张原生PNG/19表均已实际查看；本轮字体两列/六字单行/无内框与紧凑排版、浅深色/持久化等所列状态可接受，21张原生界面/正文Preview与6张透明CoreText字形诊断分开。16条阅读UI原视频保留，本轮只看4条完整1秒总览/19表，以及3个选定原始VFR窗口83帧/8表，保留原PTS、无fps滤镜或插值。滚动末段/回弹、初加载槽位和深色过渡尾段已逐帧看过；未宣称全手势、全部视频、全动效或手机FPS通过。旧TXT字体隔离图空白、加载中及若干安全区/顶栏画面明确未作为可读稳态验收，原生页与透明字形诊断不混同。

手机首次进入/快速反复滚动的实际流畅度、内存/功耗、普通签名/TrollStore、系统大字/VoiceOver/减少动效与旋转完整矩阵仍待验收；不把自动检查或原生素材当手机性能。旧暂停安全区与分页快照问题仍按独立范围记录。字体删除、集合/可变轴、单书覆盖、自定义配色/独立四边距尚未实现。M4未完，下一步先收本片手机滚动/易读反馈并核旧安全区，再按计划统一目录/书签/搜索主题，不提前M5。

本地CI保留本轮39014160303完整诊断，历史大原件按AGENTS收敛，旧文字日志/summary/metadata/验证记录保留；精确边界见m4-settings-build25-ci-retention.json。历史“大原件仍在本地”描述只代表当时快照，不能越过清理回执；交付包/素材/源码/恢复ZIP不清理。历史结果不继承为本源门槛。

以下Build24及更早为历史。


历史验证边界：56e/39012448991实际142/145，0源码compiler诊断；新增缓存与紧凑UI过，两个原集成及一个原字体UI失败，Release未执行。失败AX确有“当前位置尚未稳定”的保存错误，旧日志WebContent启动最大33.558788s；原因未证实。f90主源只恢复页边距规则/六字样例和对应新UI断言，ReaderEngine未改。当前独立145全过不能称旧加载/系统初始化根因已修复，具体history与first-preflight保留，旧大原件清理以后以retention回执为准。

Build25收尾保留已完成：旧两轮2464项/1649.9MiB已清理，100项文字/元数据留存；本轮完整诊断、45交付包和15恢复ZIP保留，详见m4-settings-build25-ci-retention.json。测试包仅修正TESTING菜单版本为(25)，其他成员原字节不变，最终摘要与回执同步。手机性能/M4仍待验收，保持开机。
