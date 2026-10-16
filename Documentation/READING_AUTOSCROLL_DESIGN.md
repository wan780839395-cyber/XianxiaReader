# 自动慢滚设计与验证边界

2026-10-16，Build21完整自动门槛及选定原生动作已通过，手机矩阵仍单列。READING_AUTOSCROLL_DRAFT.md保留原始研究草案；本文件记录实际取舍。

菜单增加“慢滚”，明确切到现有上下连续正文并打开底部小控制条，初始静止。用户再点开始；0.5—6.0屏/分、0.5步长，默认1.5。按有效视口高度换算速度，字号变化先暂停；按钮44pt、沿用主题实色表面和按压反馈。轻触正文（包括链接/选择起点）即暂停，原链接/选择/拖动继续交给Readium；暂停保留调速/继续，退出回正常菜单。书尾停止，不自动从头；重开不自动运行。运行/等待时临时保持屏幕点亮，暂停/退出/后台/关闭恢复开始前的isIdleTimerDisabled值；不永久改变系统自动锁定。

减少动态效果（系统/应用/阅读手感任一）或旁白开启时禁止开始；运行中启用立即暂停。小条解释停用，不强制改系统设置。系统前后台、关闭、新书、跳转、模式/排版改变和旋转暂停/停止。恢复必须重新点开始。仅ReadingInteraction v1新增速度偏好，旧字段缺失默认1.5；present字段类型/范围错误必须可见，原设置文件保留；无运行状态序列化、无schema迁移。

UI只经ReadingInterfaces可选ReaderAutomaticScrollProviding能力。Adapter负责CADisplayLink/弱目标/session UUID/公开UIKit触摸观察及生命周期；Core的AutomaticScrollClock只含Foundation纯时间数学。Vendor连续容器增加有界step/状态，复用现有ready窗口、预取、失败重试、完整DOMRange/字节Locator，最大12资源保持。没有新排版、全书正文、全书匹配、JS逐帧查询或每帧截图。

使用实际targetTimestamp差值，保留小数pt，>250ms间隙整段丢弃，暂停/新session重置时钟。请求移动30—60Hz、等待10Hz，系统决定实际频率；这不是手机FPS承诺。只在已就绪连续资源内移动，未就绪边界停住等待；原资源20s watchdog/可见重试继续负责失败。每帧只做有界视口几何/现有预取，旧Readium execute并无节流，现已在慢滚活跃时抑制该通知路径；Adapter约每秒串行采样一次完整位置。移动中采样以同一epoch/index/size验证，并且不把旧采样缓存成新物理viewport锚点；暂停后恢复原revision/physical-offset严检并补最后完整Locator，saveNow先等待它。原手动路径不改变采样保护。

来源和差异：[Apple CADisplayLink](https://developer.apple.com/documentation/quartzcore/cadisplaylink)、targetTimestamp和preferredFrameRateRange官方DocC已核iOS3.1/10/15可用，项目min16适用。Readest固定f4078404f4561bf480dda28759af34f7be7b5e77的autoscroller.ts/PacedScroller和useAutoScroll.ts为成熟参考，采用真实时间/小数/生命周期思路；它是Web/rAF，本项目原生UIKit。其长间隙clamp100ms，本片>250ms直接丢弃；不复制源码，不采用桌面中键/右侧调速或重开恢复运行。实际参考hash见m4-autoscroll-draft-research.json。

新增门槛：Core30/60/120Hz一致性、低速小数、长间隙/复位/非法时钟与速度兼容；真实EPUB跨章/书尾、迟到帧、触摸/后台、完整Locator静止重开；真实TXT窗口/字节锚点/重开；真UI持续慢滚、浅深色控制条/调速、触摸和后台暂停、静止重开、减少动效停用。必须完整Core/iOS/严格Release21，再审本轮原生截图、实际UI视频及原始连续帧，最后打包。Windows语法不是编译；普通签名/TrollStore/真系统辅助功能/手机手感、FPS、功耗继续单列，M4整体未完成。

源码复查补充：显式开始及每帧入口均核UIApplication active，避免resign后排队开始；读取/进度/速度设置写入失败先暂停，控制条显示设置错误和44pt重试入口，重试成功保持暂停。真实临时存储失败/保留原设置/重试回归已随891114e通过完整编译与iOS测试。

## 实际交付结果

Build21自动慢滚通过[完整CI38861273421](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38861273421)，实际编译源`891114e252758cf93cb2d0158900badae0f7bb20`。Linux/macOS各127Core、iOS116/116（101集成+15真正UI），失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release21/min16，三份六pins锁、507源码blob及每平台四长TXT Release探针已核。Windows426语法新增0/54 pristine限制、17工具通过；语法不是编译。

菜单“慢滚”进入现有连续正文，初始静止，再点开始；0.5—6.0屏/分/0.5步长，默认1.5。小控制条支持开始/暂停/调速/退出，沿用原主题表面。轻触正文即暂停，链接/选择/拖动保持Readium处理；后台/关闭/新书/跳转/排版/模式/旋转停，回来不自动跑；只保存速度。系统/应用/阅读减少动态效果或旁白开启时停用，明确说明。运行/等待临时保持亮屏，暂停等恢复原值。加载边界停住等待，失败沿用原可见重试，书尾结束。

Core纯时钟按真实时间与小数位移，>250ms间隙直接丢弃；Adapter短时CADisplayLink弱目标/session UUID，ReadingInterfaces可选能力，Vendor只在已有ready窗口内移动，最大12资源/完整DOMRange和TXT字节锚点保持。约每秒串行完整位置采样，暂停/保存补最后位置；每帧不查DOM、不写SQLite、不截屏。受改测试文件中的49个原测试主体保持，新增5Core+6集成+2真正UI。设计与官方/成熟实现取舍READING_AUTOSCROLL_DESIGN.md。

安装`build/XianxiaReader-AutoScroll-Build21.ipa` / SHA256 `be07227e9ce74eb1d4e65095dbe65ffe702ba50523f6bbf36079bebad2953219`；原创样书测试包`build/XianxiaReader-AutoScroll-Build21-TestKit.zip` / SHA256 `fa90c2d621768020b630b002d11c32006870fbd9f47321080dbd12c0f00d5c9a`。正常覆盖更新保留书库，+菜单确认0.0.1 (21)；35旧包、两新包/ZIP内部IPA与原创样书/8原生Preview已核。

原生复核范围：52张实际PNG逐图查看；两条新UI录屏总览（51.21s慢滚/15.76s应用减少动效停用）及418张原始VFR帧（浅色移动122、触摸暂停89、深色暂停207）逐帧联系表已核。选定已就绪正文片段持续可见、逐步上移后停稳，后台返回和非零位置重开静止，控制条沿用浅深色主题。减少动效图/视频尚处章节加载，仅验停用提示；其余8条reader/5条library原视频保留而未本轮逐看。本轮分页孤立WK图已有正文，历史间歇捕获成因仍未确认。所选片段未见整窗正文空白，不推广为全视频/全部机型或手机FPS/功耗结论。

普通签名/TrollStore、真实系统Reduce Motion/VoiceOver/增强对比度/旋转、手机低速/120Hz/亮屏与功耗/实际流畅度仍未验收。自动检查/Swift编译/模拟器阅读/普通设备/TrollStore分列，M4整体未完。旧Build20/19证据与设备限制保留，不追认全矩阵或WebKit根因修复。
