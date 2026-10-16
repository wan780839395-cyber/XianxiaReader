# 上下整屏阅读

2026-10-16，Build19完整自动门槛通过，原生复核记录反向短空帧未验收，手机矩阵单列。M4独立切片。

用户认可Build18并要求继续。延续灰绿原生菜单与轻按压层次；新增“上下整屏”，原左右翻页、上下连续滚动仍可选。复用Readium3.11本地维护的有界跨章容器、DOM排版与完整Locator，TXT仍按窗口加载；不创建另一套正文排版、截图翻页或全书占位。

## 输入与位置

连续容器新增可关闭的输入策略。使用原生UIScrollViewDelegate修改松手目标：正常轻划停一屏，屏步为有效高度90%，留10%重叠；小拖动回到本次起点，有意长拖可覆盖多个整屏，快速短甩不因远端惯性目标连冲数屏。首尾按真实有限contentSize钳制，仍保留既有加载/重试边界。

前序资源载入造成原点补偿时，同步平移本次手势起点；旋转/重载/显式跳转/关闭清旧起点。普通连续模式保持原目标与正常减速率，整屏使用原生fast减速。点按页面上下30%翻屏，中间40%菜单；Readium先处理链接/选择，不叠透明手势层。菜单整屏按钮采用上下箭头。

显式翻屏复用同一90%高度，正在手势/惯性/原生翻屏动画期间拒绝重复命令，不积压。原生滚动动画结束或新拖动释放锁；减少动效时显式命令立即应用，直接手指操作和原生惯性仍跟手。无CADisplayLink循环、无haptic或自动滚动。

整屏/连续互换只改变输入策略，保持同一个正文容器，不重建或强制对齐章首。左右模式转换仍走既有完整DOM锚点保护。interaction-v1.json增加verticalScreenPaging字段，旧v1缺字段默认为false，原四字段仍严格解码；不合法类型/整屏却非连续的组合报错并保留文件。无数据库/schema3/reading-v1/Locator/原书/依赖锁变更。固定布局/RTL/竖排保持既有分页适用范围，保留用户全局偏好供其他书使用。

## 参考与取舍

- [Apple UIScrollViewDelegate目标偏移](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/scrollviewwillenddragging(_:withvelocity:targetcontentoffset:))：官方公开接口允许调整滚动落点，iOS5起可用，项目最低iOS16适用；本轮下载官方DocC JSON核过合同和版本。
- [Apple isPagingEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/ispagingenabled)：按bounds整倍数停屏。本项目资源高度与窗口原点动态变化，且需要正文重叠，选上述公开目标偏移合同，不直接启用固定bounds分页。
- [Apple setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/setcontentoffset(_:animated:))：iOS2起可用；显式按钮沿用原生滚动，减少动效禁动画。
- [Readest官方阅读说明](https://www.readest.com/docs/reading)：参考中心呼出工具栏和区分分页/连续的既有体验；其当前文档还列自动滚动，本轮没有复制该功能或其跨平台代码。网页布局不作原生验收。
- 本地Readium基线3.11.0/revision d82f44f4，实际实现审阅EPUBNavigatorViewController的go与有界EPUBInfiniteScrollView，仅扩展这两个维护文件并更新UPSTREAM hash。无新第三方依赖/代码或美术复制。

## 验证边界（开发前计划，最终实际结果见文末）

预期各122Core、iOS106（94集成+12真实UI），以最终实际日志/xcresult为准。新增三Core覆盖旧设置兼容/持久化/坏字段保留；两生命周期覆盖原生会话不重建/不支持布局偏好保留；三实际容器测试覆盖落点取消/正反/边界/普通连续不变、真实跨章/重复命令/即时减少动效、非零字符/3px重开；一实际UI测试包含普通及额外减少请求的拖动/按钮/设置/重启/切回，保留录屏及截图。旧断言与测试主体保留。

Windows语法/工具不是Apple编译；完整Core/iOS/严格无签名Release19、四长TXT Release探针和三份六pins锁须真实通过。静态截图不当动效验收，实际原生录屏/连续采样与手机手感/FPS/耗电、普通签名/TrollStore分别记录。旧分页孤立透明图、巨段TXT满页、系统Reduce Motion/增强对比度/VoiceOver/旋转矩阵仍待验证；本轮不得追认。自动慢滚/卷页/字体导入等仍后续，M4未完成。

## 第一候选主动取消与最小修正

第一候选d4908df6/CI38842135511的Linux122/四探针通过；Agent在Apple运行期间发现确定的算法错误，最终主动取消；完整日志随后确认94集成中1新增跳章准备失败，原有集成断言均过。长拖+1.8屏后反向负速度，旧目标为起点-2屏；改为从离手坐标按速度选相邻屏格，此例停+1屏。新增双向反向快甩断言，普通同向/小拖/边界/连续原样保留。显式布局补偿或resize中断原生动画时清命令锁，避免等不到结束回调。新字段缺省仍false，但显式null/字符串报错并保留原件。完整取消日志确认实际未完成阶段，第二候选必须完整重跑。

## 完整取消日志复核后的准备修正

首轮实际Apple各122Core已过，94集成中93过，新增跨章case在jump处navigationFailed（0.496秒，尚未到几何断言）。取消发生在第4书库UI中，3书库UI已过，读者UI未执行；Release/IPA未生成。不能因最终cancelled遮掉已观察的新测试失败。三个新增渲染case在open后直接jump，遗漏既有probe的真实DOM/原生位置就绪门槛；现沿用同一cover.xhtml probe/20秒，不改任何旧测试或后续3px/跨章/重入断言。唯一navigationFailed根因仍不据猜测宣称已证，须新完整CI核。第二轮c847210d/38843421879为及时纳入该准备修正而Agent取消，生产代码与最终第三轮完全一致。

## 最终实际结果

Build19上下整屏通过[完整CI38843884440](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38843884440)，实际编译源`e1eee79f1dfac3f61b642c1f4e7f9bc1671fb77f`。Linux/macOS各122Core，iOS106/106（94集成+12真正UI）、失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release19/min16。每平台四长TXT Release探针、真实三份六pins锁和504源码blob已核。Windows423语法新增0/54 pristine限制、17工具通过；语法不是编译。

用户认可Build18基本自用/观感。本轮沿用原生灰绿层次，菜单/手感增加“上下整屏”：既有有界跨章容器用原生松手目标停稳，90%有效高度留少量重叠，小拖回位、长拖可跨多个整屏，快速短甩不因惯性连冲多屏。正文上下30%点按/菜单上下按钮翻屏，中央40%仍呼出菜单；Readium先处理链接/选择。显式翻屏在手势/惯性/原生动画期间防重入，减少动效点按立即应用、直接手指操作仍原生跟手。连续/整屏互换只改输入策略，保持同一正文，模式/外观/完整位置分别保存。旧interaction-v1缺字段兼容、不合法类型和不一致组合报错保留；不支持布局仍分页且保留偏好。两个维护Vendor文件与UPSTREAM合同/hash同步，无原书/schema3/Locator/reading-v1/JS bundle/六pins/工具/工作流变更。参考及取舍READING_SCREEN_DESIGN.md。

安装`build/XianxiaReader-VerticalScreen-Build19.ipa` / SHA256 `213ec780735bc396f95749a1770fa4558b3d534b9d7077df4fb1bd47ecfa4151`；原创样书测试包`build/XianxiaReader-VerticalScreen-Build19-TestKit.zip` / SHA256 `c80a3b0372c54452964e259432a0e9e1856ef79c8f021127db439a9b93e87332`。正常覆盖更新保留书库，+菜单确认0.0.1 (19)。31旧包+2新包hash、ZIP CRC/内部IPA/原创Samples-Evidence-Cover和6张本轮Preview核过。入口阅读方式→上下整屏，可随时切回连续滚动/左右翻页。

本轮41张原生截图全部复核，40张含非透明像素；三模式入口、上下箭头、普通/额外减少动效的设置与拖动后/重开图片文字清楚，跨章整窗可见前章长段185–199和第二章标题/正文。当前巨段TXT深色孤立图已见满屏正文；这是本轮光栅证据，不能追认旧留白捕获或宣称手机/全部巨段问题根因已修复。分页孤立WKWebView图仍RGBA全0，另有本轮完整EPUB整窗可见正文。

两段实际UI录屏全时段1秒总览已看：新整屏测试189.14秒、既有额外减少动效手势17.90秒；其余5阅读/5书库录屏只保留，不声称逐段复核。新整屏视频33.50–35.90及40.00–42.40秒共96张20fps时间采样已看，未插帧，VFR重复不等于手机FPS。可见拖动时收菜单、原生位移后停稳、菜单恢复与按钮正反翻屏；但42.05–42.20秒采样可见正文短时空白后恢复，显式反向切换的无空帧视觉门槛未通过，需真机复现/定位，不能归因成单纯采集问题。录屏时间与XCTest活动时间未建立一一映射，不把同一片段虚称为普通/减少动效两路完整连续过程；两路状态与操作分别有测试及原生PNG证据。

日志2次XCTest动画结束通知缺失，完整日志/回执保留；新测试t126.80进入idle、t186.84通知缺失、t186.85才请求下一次tap，不算App收到点击后卡60秒。系统RBS/扩展退出、AppIntents等诊断与源编译warning/error分别记录。系统真实Reduce Motion/VoiceOver/增强对比度/旋转/普通签名/TrollStore、手机响应/FPS/耗电仍待测。此为素材复核完成，未宣布视觉全通过或M4整体验收。

系统真实减少动效/VoiceOver/增强对比度/旋转/普通签名/TrollStore、手机手感/FPS/耗电继续分列；本轮TXT满屏光栅不追认历史留白根因或全部真机样书，分页孤立图仍全透明。反向翻屏短空帧明确未验收，先真机复现/定位再推进下一切片。自动慢滚/卷页/触感反馈/字体文件导入等仍后续，M4整体未完。报告M4_SCREEN_VALIDATION_REPORT.json。

第一候选d4908df6/CI38842135511最终由Agent主动取消；实际各122Core/四Release探针通过，94集成中93过，1新增跨章case在初始jump报navigationFailed，随后3书库UI过、第4书库UI中取消，ReaderUI/严格Release未完成。取消前审阅另发现反向长拖落点算法缺陷，已按离手位置相邻格修正并加双向断言。第二候选c847210d/CI38843421879因补新测试初始DOM/原生位置准备主动取消，实际Linux122/四探针通过，Apple停在XcodeGen依赖构建，macOS/iOS/Release未开始；生产与第三候选相同。第三候选仅为三个新增渲染case加既有cover probe/20秒准备，所有原断言不改。两轮完整取消日志/xcresult（首轮）/诊断ZIP和源快照保留；navigationFailed唯一根因不据猜测追认。
