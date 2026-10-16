# 自动慢滚草案

当前Build21首片已实现并通过完整自动门槛/选定原生复核，手机矩阵仍待核；实际取舍见READING_AUTOSCROLL_DESIGN.md。以下保留Build19时期研究原稿，历史“未实现”指当时。

2026-10-16，等待Build19完整CI时整理。只有研究/交互草案，未实现、未编译、未进入当前交付；Build19仍只交付上下整屏。需先收集整屏反馈，按独立切片实施。

拟沿用已有有界连续正文和完整Locator，用户主动点“开始”后按稳定速度向下移动；轻触/拖动正文立即暂停，控制条提供继续、调速与退出。进入后台、关闭、切换书籍或跳转目标先暂停/终止，重开从已保存位置静止开始。只保存速度偏好，第一片不自动恢复运行状态。UI仍用既有实色卡片/按压样式，不遮住大量正文。

草案状态为停止、运行、用户暂停、等待下一窗口；文件/布局错误继续显示既有错误并可重试。等待加载时不持续向下推进，不越过未就绪资源；恢复必须核session/资源epoch，结束到书尾后不重新启动。暂停原因不能被旧await回调覆盖，新书/新请求不能复用旧计时器。

速度拟按“每分钟约几屏”表达，以当前有效视口高度换算pt/s；默认和范围必须看实际字号/长TXT/深色手机录屏后确定。禁止每帧固定1px、按假定60Hz位移或在长后台间隔补整段位移；保留小数位移，使用实际时间差并限制长间隔。低速、低电量与120Hz设备的手感/耗电要独立验证，不把模拟器采样帧率当手机结果。系统/用户减少动效如何与用户主动启动慢滚协作，实施前须明确，不能默认绕过已有策略。

## 已核参考及适用差异

- [Apple CADisplayLink](https://developer.apple.com/documentation/quartzcore/cadisplaylink)与[targetTimestamp](https://developer.apple.com/documentation/quartzcore/cadisplaylink/targettimestamp)：官方DocC JSON核到CADisplayLink从iOS3.1、targetTimestamp从iOS10可用；[preferredFrameRateRange](https://developer.apple.com/documentation/quartzcore/cadisplaylink/preferredframeraterange)从iOS15可用，项目最低iOS16适用。显示频率由系统与设备共同决定；结束必须invalidate。拟在原生连续容器使用短时、可取消显示同步更新，每帧只移动视口；不逐帧查询全书DOM或写库。先核既有位置回调节流，必要时增加真实回归。
- [Readest官方阅读说明](https://www.readest.com/docs/reading)与固定revision `f4078404f4561bf480dda28759af34f7be7b5e77` 的[autoscroller.ts](https://github.com/readest/readest/blob/f4078404f4561bf480dda28759af34f7be7b5e77/apps/readest-app/src/app/reader/utils/autoscroller.ts)、[useAutoScroll.ts](https://github.com/readest/readest/blob/f4078404f4561bf480dda28759af34f7be7b5e77/apps/readest-app/src/app/reader/hooks/useAutoScroll.ts)：审阅实际源码，借鉴按真实时间、保留小数/限制长帧间隔和明确停止生命周期。它是Web/rAF与跨平台布局，本项目使用UIKit/Readium；其重开自动恢复运行、桌面中键/右侧调速手势不作为本项目第一片要求。没有复制外部代码/素材或新增依赖。

后续门槛：可注入时钟的时间/暂停/迟到回调回归，加实际连续TXT/EPUB跨窗口/书尾/重开和真UI轻触暂停/前后台录屏；完整Core/iOS/Release与原生连续帧通过后才生成交付包。现有巨段TXT满页、分页孤立快照采集和真实设备矩阵继续分列，草案不消除旧限制。
