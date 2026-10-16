# 当前交接与恢复点

2026-10-16（Asia/Shanghai）

Build21自动慢滚通过[完整CI38861273421](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38861273421)，实际编译源`891114e252758cf93cb2d0158900badae0f7bb20`。Linux/macOS各127Core、iOS116/116（101集成+15真正UI），失败/跳过0，test/export/summary/recording退出0；严格无签名iPhoneOS arm64 Release21/min16，三份六pins锁、507源码blob及每平台四长TXT Release探针已核。Windows426语法新增0/54 pristine限制、17工具通过；语法不是编译。

菜单“慢滚”进入现有连续正文，初始静止，再点开始；0.5—6.0屏/分/0.5步长，默认1.5。小控制条支持开始/暂停/调速/退出，沿用原主题表面。轻触正文即暂停，链接/选择/拖动保持Readium处理；后台/关闭/新书/跳转/排版/模式/旋转停，回来不自动跑；只保存速度。系统/应用/阅读减少动态效果或旁白开启时停用，明确说明。运行/等待临时保持亮屏，暂停等恢复原值。加载边界停住等待，失败沿用原可见重试，书尾结束。

Core纯时钟按真实时间与小数位移，>250ms间隙直接丢弃；Adapter短时CADisplayLink弱目标/session UUID，ReadingInterfaces可选能力，Vendor只在已有ready窗口内移动，最大12资源/完整DOMRange和TXT字节锚点保持。约每秒串行完整位置采样，暂停/保存补最后位置；每帧不查DOM、不写SQLite、不截屏。受改测试文件中的49个原测试主体保持，新增5Core+6集成+2真正UI。设计与官方/成熟实现取舍READING_AUTOSCROLL_DESIGN.md。

安装`build/XianxiaReader-AutoScroll-Build21.ipa` / SHA256 `be07227e9ce74eb1d4e65095dbe65ffe702ba50523f6bbf36079bebad2953219`；原创样书测试包`build/XianxiaReader-AutoScroll-Build21-TestKit.zip` / SHA256 `fa90c2d621768020b630b002d11c32006870fbd9f47321080dbd12c0f00d5c9a`。正常覆盖更新保留书库，+菜单确认0.0.1 (21)；35旧包、两新包/ZIP内部IPA与原创样书/8原生Preview已核。

原生复核范围：52张实际PNG逐图查看；两条新UI录屏总览（51.21s慢滚/15.76s应用减少动效停用）及418张原始VFR帧（浅色移动122、触摸暂停89、深色暂停207）逐帧联系表已核。选定已就绪正文片段持续可见、逐步上移后停稳，后台返回和非零位置重开静止，控制条沿用浅深色主题。减少动效图/视频尚处章节加载，仅验停用提示；其余8条reader/5条library原视频保留而未本轮逐看。本轮分页孤立WK图已有正文，历史间歇捕获成因仍未确认。所选片段未见整窗正文空白，不推广为全视频/全部机型或手机FPS/功耗结论。

普通签名/TrollStore、真实系统Reduce Motion/VoiceOver/增强对比度/旋转、手机低速/120Hz/亮屏与功耗/实际流畅度仍未验收。自动检查/Swift编译/模拟器阅读/普通设备/TrollStore分列，M4整体未完。旧Build20/19证据与设备限制保留，不追认全矩阵或WebKit根因修复。

## 保存与后续

原HEAD6d761749/空index/M2 e6f31d85/M3 44af41f0保持，仅私有index维护codex/m4-reading-appearance。原838开工路径、507编译blob、35旧包+两新包、11份ZIP备份及最终远端/树核验见build/ci/38861273421/final-preservation-check.json。首候选主动取消阶段与本轮发展检查点保留，未将取消写源码失败；第二候选112/115、3条新增回归失败（旧108全过）的完整诊断及修正也保留，第三候选116/116真实通过。Build20完整交接与本轮发展历史均独立归档。

恢复先AGENTS→状态→交接→路线→架构，再核实际Git/文件/hash/完整日志和进程，保留所有未提交改动。优先收集本片手机轻触接管/低速/跨章/静止重开/功耗反馈，再按M4独立切片做“回看不丢位置”及字体导入等；特色候选见READING_FEATURE_IDEAS.md。M4整体未完，不提前铺开M5，不沿用旧关机请求。

最终收尾：本轮API watcher、下载、原始帧解码均已退出，进程复查无遗留本轮开发任务；最新三轮CI分别success/failure/cancelled且均completed。安装包与TestKit实际生成、CRC/内部IPA/hash已核。现在只做清单、保全和私有文档快照/远端核对，507编译源不再改动；后续从本Build21手机反馈继续。
