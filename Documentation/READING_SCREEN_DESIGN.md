# 上下整屏阅读

2026-10-16，Build19源码已接入，尚未编译/原生验收。M4独立切片。

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

## 验证边界

预期各122Core、iOS106（94集成+12真实UI），以最终实际日志/xcresult为准。新增三Core覆盖旧设置兼容/持久化/坏字段保留；两生命周期覆盖原生会话不重建/不支持布局偏好保留；三实际容器测试覆盖落点取消/正反/边界/普通连续不变、真实跨章/重复命令/即时减少动效、非零字符/3px重开；一实际UI测试包含普通及额外减少请求的拖动/按钮/设置/重启/切回，保留录屏及截图。旧断言与测试主体保留。

Windows语法/工具不是Apple编译；完整Core/iOS/严格无签名Release19、四长TXT Release探针和三份六pins锁须真实通过。静态截图不当动效验收，实际原生录屏/连续采样与手机手感/FPS/耗电、普通签名/TrollStore分别记录。旧分页孤立透明图、巨段TXT满页、系统Reduce Motion/增强对比度/VoiceOver/旋转矩阵仍待验证；本轮不得追认。自动慢滚/卷页/字体导入等仍后续，M4未完成。
