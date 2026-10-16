# 自动慢滚设计与验证边界

2026-10-16，Build21源码候选，尚未Apple编译，未交付。READING_AUTOSCROLL_DRAFT.md保留原始研究草案；本文件记录实际取舍。

菜单增加“慢滚”，明确切到现有上下连续正文并打开底部小控制条，初始静止。用户再点开始；0.5—6.0屏/分、0.5步长，默认1.5。按有效视口高度换算速度，字号变化先暂停；按钮44pt、沿用主题实色表面和按压反馈。轻触正文（包括链接/选择起点）即暂停，原链接/选择/拖动继续交给Readium；暂停保留调速/继续，退出回正常菜单。书尾停止，不自动从头；重开不自动运行。

减少动态效果（系统/应用/阅读手感任一）或旁白开启时禁止开始；运行中启用立即暂停。小条解释停用，不强制改系统设置。系统前后台、关闭、新书、跳转、模式/排版改变和旋转暂停/停止。恢复必须重新点开始。仅ReadingInteraction v1新增速度偏好，旧字段缺失默认1.5；present字段类型/范围错误必须可见，原设置文件保留；无运行状态序列化、无schema迁移。

UI只经ReadingInterfaces可选ReaderAutomaticScrollProviding能力。Adapter负责CADisplayLink/弱目标/session UUID/公开UIKit触摸观察及生命周期；Core的AutomaticScrollClock只含Foundation纯时间数学。Vendor连续容器增加有界step/状态，复用现有ready窗口、预取、失败重试、完整DOMRange/字节Locator，最大12资源保持。没有新排版、全书正文、全书匹配、JS逐帧查询或每帧截图。

使用实际targetTimestamp差值，保留小数pt，>250ms间隙整段丢弃，暂停/新session重置时钟。请求移动30—60Hz、等待10Hz，系统决定实际频率；这不是手机FPS承诺。只在已就绪连续资源内移动，未就绪边界停住等待；原资源20s watchdog/可见重试继续负责失败。每帧只做有界视口几何/现有预取，旧Readium execute并无节流，现已在慢滚活跃时抑制该通知路径；Adapter约每秒串行采样一次完整位置。移动中采样以同一epoch/index/size验证，并且不把旧采样缓存成新物理viewport锚点；暂停后恢复原revision/physical-offset严检并补最后完整Locator，saveNow先等待它。原手动路径不改变采样保护。

来源和差异：[Apple CADisplayLink](https://developer.apple.com/documentation/quartzcore/cadisplaylink)、targetTimestamp和preferredFrameRateRange官方DocC已核iOS3.1/10/15可用，项目min16适用。Readest固定f4078404f4561bf480dda28759af34f7be7b5e77的autoscroller.ts/PacedScroller和useAutoScroll.ts为成熟参考，采用真实时间/小数/生命周期思路；它是Web/rAF，本项目原生UIKit。其长间隙clamp100ms，本片>250ms直接丢弃；不复制源码，不采用桌面中键/右侧调速或重开恢复运行。实际参考hash见m4-autoscroll-draft-research.json。

新增门槛：Core30/60/120Hz一致性、低速小数、长间隙/复位/非法时钟与速度兼容；真实EPUB跨章/书尾、迟到帧、触摸/后台、完整Locator静止重开；真实TXT窗口/字节锚点/重开；真UI持续慢滚、浅深色控制条/调速、触摸和后台暂停、静止重开、减少动效停用。必须完整Core/iOS/严格Release21，再审本轮原生截图、实际UI视频及原始连续帧，最后打包。Windows语法不是编译；普通签名/TrollStore/真系统辅助功能/手机手感、FPS、功耗继续单列，M4整体未完成。
