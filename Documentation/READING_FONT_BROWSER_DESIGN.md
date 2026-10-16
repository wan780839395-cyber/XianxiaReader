# 设置内字体浏览与排版扩展（Build24）

2026-10-17。用户明确指出两款内置不足、设置应直接展示字形，并要求更多自定义。这是M4独立切片，不提前知识库或在线字体商店。当前Windows语法/工具门槛已过，完整Apple构建、原生与手机门槛尚未验收，不能用Build23结果替代。

内置增至六款：原思源宋体、霞鹜文楷，加思源黑体、朱雀仿宋、马善政楷书、站酷小薇。四新增字体和原OFL从官方固定revision或发布资产取原字节；朱雀官方v0.212 ZIP只含TTF，原OFL另从同一tag对应commit取得；ZIP SHA与GitHub发布摘要一致。PROVENANCE.json记录源URL、revision、字节数和摘要，原件未裁字/转换。旧两UUID保持，新增使用后续稳定编号。Adapter资源目录上限18（6内置+12用户），正文窗口仍12。

字体列表每行显示实际字体绘制的同一中文样例，主预览随选中字体/字号/配色变化；导入字体也走同一真实文件路径。SwiftUI的系统字体仅用于名称、说明和系统字体选项，不以普通系统字冒充自定义字形。预览明确是字形样例，段落重排以Readium正文为准。字号放在长列表前，避免为了浏览六款而遮住常用字号操作。

使用Apple公开CGDataProvider/CGFont/CTFontCreateWithGraphicsFont/CTFramesetter，在独立actor上从真实文件绘制短原创中文样例，再返回小PNG给原生设置界面；不注册进程全局字体、不增加WebView/HTTP服务、不把整本正文读入预览。保留一个CGFont和最多12个预览结果；Lazy列表按需请求，关闭/换字取消及await后检查，失败明确显示预览不可用，不偷偷换成系统字。UIImage解码只处理小图，手机首次字体解析/内存/滚动流畅度仍须实际设备核验。

自定义新增字距0–0.5（Readium公开值，CSS为一半rem）、字重50–175%（保留原字重为nil，Readium倍率乘400），首行缩进0–4字/0.5步长。行距扩为1.2–2.8、段距0–3、左右留白0.25–2.5，保留原书样式禁用规则、系统字体/主题/缩进开关和恢复默认。单字重字库的实际粗细范围由字体/系统决定，不承诺可变轴；预览只承诺原字形/字号/配色，不冒充与WebKit每个段落像素一致。

reading-v1只新增可选字段，旧JSON缺字段继续按原字距、原字重、两字/无缩进恢复；不升schema、不删设置。新的非有限或越界值拒绝写入并保留原文件。Adapter沿3.11公开Preferences映射；字距/字重纳入资源字体完整锚点重排判定，原EPUB DOMRange/TXT byte+UTF16、关闭取消和回看返回点保持。无Vendor/排版JS/依赖锁升级。

验证：受改测试文件38个原测试主体逐字保持，新增6项：2Core旧JSON兼容/新值读写及拒绝覆盖；1真实CoreText六字库PNG不同且有墨迹/缓存/坏文件报错；1真实Readium六字库中文字形/字距字重缩进CSS/非零完整锚点/重开；1字体ready未完成时快速再换字保护原非零词；1真正UI六款浏览和自定义持久化。Windows435语法（54既有Vendor限制、新增0）与17工具通过；语法不是编译。预期Linux/macOS Core135各、iOS138（118集成+20UI）与严格无签名Release24，必须核实际原件。六款真实字形图、正文/设置截图与关键录屏/原帧另设人工复核，不能只用截图或自动测试当手机流畅度。

参考与取舍：

- [Apple公开CoreText字库入口](https://developer.apple.com/documentation/coretext/ctfontcreatewithgraphicsfont(_:_:_:_:))与[Framesetter](https://developer.apple.com/documentation/coretext/ctframesettercreateframe(_:_:_:_:))：直接绘制文件字形，无全局名称冲突；使用有界短样例，不自建EPUB排版。
- [Adobe思源黑体](https://github.com/adobe-fonts/source-han-sans)、[朱雀仿宋](https://github.com/TrionesType/zhuque)、[Google Fonts马善政](https://github.com/google/fonts/tree/main/ofl/mashanzheng)、[站酷小薇](https://github.com/google/fonts/tree/main/ofl/zcoolxiaowei)：取未修改原件及原OFL，各固定来源见Fonts/PROVENANCE.json。
- Readium偏好实际签名/值域/倍率以仓内锁定3.11的EPUBPreferences、EPUBPreferencesEditor、ReadiumCSS为准，避免自写全书CSS或升级依赖。

字体删除/集合/可变轴、单书覆盖、自定义配色、独立四边距等留后续M4小切片；普通签名/TrollStore/系统辅助功能/旋转、大字库手机首次加载与耗电/FPS仍单列。旧Build23截图/残影限制保留，不追认根因修复。

补充快速连选：Adapter对preserve返回false不再继续提交新字体，采用3s/32ms有界等待及每await会话/取消检查，超时可见。避免字体前次恢复尚未完成时以隐藏初始化页覆盖正确位置；真实800ms字体ready阶段再选择第三字体回归保留原非零词。所有旧38测试主体保持，完整门槛按最新候选。

## 构建前最终断点

872fc755f12f3afa83eb1aa736015d5a50ec4502 已实际触发独立完整CI38954435197，新的135 Core/118集成+20 UI/Release24门槛只归该源。此前3a97与c661候选未取消，各自旧137项预期保持，不能把最新新增竞态测试追溯算入旧轮。Linux135及四长TXT已核，Apple/原生/手机仍待相应独立结果。最新快照已推送，正常HEAD和空index不变。

原生早查发现compact样例原底色与选择卡不同，出现硬矩形。现在列表PNG透明背景，直接融入既有灰绿圆角卡；大样例仍填阅读主题底色。同一真实CoreText回归核compact的透明背景与实墨，最终效果须从最新源原生截图核验。早查使用首候选选定ZIP成员CRC，仅诊断、无全ZIP验证，不替代主源。
