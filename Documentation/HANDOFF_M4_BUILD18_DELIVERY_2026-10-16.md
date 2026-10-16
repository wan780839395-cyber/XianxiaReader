# 当前交接与恢复点

更新时间：2026-10-16（Asia/Shanghai）

## 实际断点

Build18面板层次与按压反馈通过[完整CI38835963502](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38835963502)，实际编译源`76ede6b266304749db37029b66d89b0d27eb39e2`。Linux/macOS各119Core，iOS100/100（89集成+11真正UI），失败/跳过0，test/export/summary/recording退出0；无签名iPhoneOS arm64 Release18/min16、系统SQLite/真实三锁/每平台四长TXT Release探针与504源码blob核过。Windows423语法新增0/54 pristine限制、17工具测试通过；语法不是编译。

用户认可Build17基本自用/整体观感，反馈部分扁平生硬。本轮保留灰绿风格，原生菜单增加实色浮层、轻边光/双层小投影，设置分组补图标层次。投影仅作用于单一背景fill，文字/图标不投影；标准ButtonStyle提供按下0.975/0.5pt微沉和短回弹。普通/减少动效实际长按松手每次只激活一次与44pt命中区域已回归。系统/用户/额外减少动效禁缩放位移/过渡但保留即时底色，增强对比度加强边线。菜单仍10pt短幅，spring response 0.3/dampingFraction 0.92，不把response等同完整动画时长，不重排正文。仅App三样式文件、UI测试和project.yml版本变更；Core/Adapter/Vendor/锁/scripts/workflow/原书/schema3/完整Locator与成功Build17保持。参考Apple公开ButtonStyle/Motion/Materials原则并核iOS13 API适用最低iOS16，不引入LiquidGlass新系统API、外部代码或素材；设计READING_DEPTH_DESIGN.md。

安装`build/XianxiaReader-ReadingDepth-Build18.ipa`，SHA256 `8ada416c25c47fdec80fec0735c9db6c69f7d5584f465589981413c991011656`；原创样书测试包`build/XianxiaReader-ReadingDepth-Build18-TestKit.zip`，SHA256 `7d30ab3e4d34c14bd65ae46b787dc6e612f1273e893f892632ec0a22973aa5ac`。正常覆盖更新保留书库，+菜单确认0.0.1 (18)。原29包与本轮2包/ZIP CRC/内部IPA/原创Samples-Evidence-Cover及六张本轮Preview核过。手机手感/FPS、普通签名/TrollStore与完整可访问性矩阵单列；卷页/上下整屏/自动慢滚/触感反馈和字体文件导入等仍后续，M4整体未完。报告M4_DEPTH_VALIDATION_REPORT.json。

本轮32张实际原生截图已检查，31张有非透明像素；三组Build17前后对照与三组被拒收候选对照已看，白菜单不再有文字/图标投影灰晕，菜单轮廓投影与设置层次清楚。实际按压42.16秒、正常手势116.71秒、额外减少动效16.82秒三视频全时段1秒总览已看；普通/减少动效两按压窗口各20裁切帧、正常/减少动效菜单恢复各16帧，共72实际20fps时间采样已看，无插帧且可有VFR重复。普通约11.15秒出现按压色/微沉，11.35秒110变120，松手迅速收敛；减少动效约33.15秒按下色、33.35秒变120，无新缩放过渡。正常菜单约16.10–16.40秒短幅恢复，额外减少动效约13.05秒直接显示，正文未因菜单重排。其余3阅读/5书架视频只保留，未宣称本轮逐段审阅；三段选定视频不等于全部11段审阅。

长静帧/系统桌面不当流畅度证据：日志3次XCTest动画结束通知缺失；本例t19.16等idle、t79.20通知未收到、t79.22才发下一次tap，不能算App收到点击后卡60秒，根因/手机响应未建立，专门回执m4-depth-build18-xctest-idle-diagnostics.json。分页孤立WKWebView PNG又RGBA全0，不是可见黑页证明；实际新EPUB整窗有完整文字，DOM/原非零字180%/完整DOM重开回归通过仍不等价该孤立光栅验收。巨段TXT孤立图仍顶部约两行、其余留白，满页成因/手机结果继续未验收。系统真实Reduce Motion/增强对比度/VoiceOver/旋转/其他设备/普通签名/TrollStore、手机FPS/耗电/响应仍单列。旧Build15–17命名图片均来自本轮实际CI，不追认历史失败或第二轮视觉拒收。

首候选f957f465/CI38831994670因新增样式modifier与既有ReaderSurface重名而Swift编译失败，iOS零执行/test65，无Release/IPA；第二候选750191d0/CI38833282829自动100/100及Release18通过，但原生对照发现文字/图标投影灰晕，明确视觉拒收、未生成用户交付包。第三候选仅将两层投影移到单一背景fill，完整重新构建与本轮原生复核通过。首轮失败、第二轮视觉拒收、全部原始日志/xcresult/素材和候选IPA继续保留；回执m4-depth-build18-first-failure.json与m4-depth-build18-second-native-rejection.json，不以最终通过追认前两轮。

## 保护与下一步

原main HEAD6d761749/空index/M2 e6f31d85/M3 44af41f0保持，codex/m4-reading-appearance仅私有index快照；真实编译源与其后纯文档tip分列。开始783路径与全部八份备份保持，最终31包逐hash、八ZIP逐CRC、504编译源blob及801维护文件清单已核，依据build/ci/38835963502/final-preservation-check.json。交付安装/样本包已完成，当前无遗留CI或下载任务；后续仅私有index纯文档快照，文档tip与远端同名ref核，不当新编译。Build17交接归档HANDOFF_M4_BUILD17_DELIVERY_2026-10-16.md，本轮发展记录HANDOFF_M4_DEPTH_DEVELOPMENT_2026-10-16.md。

下次先AGENTS→状态→交接→路线→架构，再核实际Git/文件/任务/完整日志，保留未提交改动。手机核浅深色浮层边界/按压松手/减少动效/菜单收放与非零位置重开；巨段TXT满页与系统访问性/FPS继续独立核，确认反馈后按独立切片推进上下整屏/自动慢滚，卷页先兼容小样；不铺开XBook，不沿用旧关机请求。
