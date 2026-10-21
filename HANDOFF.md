## 当前恢复点：受控旧1/新6准备冻结（尚未Swift编译，2026-10-21）

已实现测试/诊断入口，生产源码仍为原R3c版本。新增一个分页rAF桥屏障用例，只挂起one.xhtml真实spreadLoaded回调，保留cover和其他rAF；必须证明DOM complete、窗口挂载、桥仍held，才进入原30秒位置/内层alpha断言。候选通过后才放行原桥并核完整DOM锚点不回退。失败诊断新增采样时刻、内层alpha、DOM返回后的位置，原断言/预算不变。严格核真实旧退出65/合格失败1与新退出0/6通过，共用runner/DerivedData；不合格即停，不重试。

当前仅语法/5项新工具用例通过，接下来完整Windows工具76项、Bash语法后冻结旧源码+相同fixture，再只改SpreadView和UPSTREAM形成精确子提交。尚无本片远程run/原生结果。未来完整iOS计数由159集成+29UI改为160+29=189，仅新增回归带来的计数更新，本片不跑完整门槛。普通HEAD/index和全部旧WIP保留；R4尚未开始。

参考已核锁定Readium3.11.0原始SpreadView/ReflowableSpreadView/PaginationView/Navigator源码（.cache/recovery/epub-first-jump）；沿用本项目已经回归的连续模式原生bootstrap和桥屏障fixture，不升级依赖、不另建排版器。原失败诊断先读position再await DOM，且外层可见矩形不含内层scrollView alpha，因此不能据旧附件证明正文当时已经可读。新对照只能证明/排除这一桥通知缺口，不能倒推历史69秒延迟的精确原因。

## 单例实验假设（尚未验证）

旧Paged没有native bootstrap，目标one的spreadLoaded rAF被挂起时，DOM complete但原生alpha仍0、currentPosition仍cover；当前连续模式已经有安全fallback。待实验复用既有rAF屏障，只控one资源（cover正常），证明实际进入held=true/DOMready，再保持同30秒断言观察是否bodyalpha和currentPosition到one。候选只扩已有完整bootstrap到重排分页，保留JS/viewport检查、初始化一次、字体/完整锚点保护、close取消，不直接发伪造位置。旧1项严格负例、候选受控1+原失败1及连续fallback/关闭/隐藏字体/同宽writer各1，共新6项；同runner/相同fixture与原预算，不跑19/188/设备Release。历史39585860717初始化过迟的精确69秒原因不能由新对照倒推，诊断位置与DOM采样时间也需分别标明。

# 当前断点：单查EPUB首次跳正文与位置上报（2026-10-21）

用户最新授权：先查清正文DOM已到one但仍上报cover，有缺陷就修复，收口后才继续R4。范围只围绕原FreshReturnCapture单例/首次跳转-初始化-位置发布，不混R4或全量验证。原R3a/b/c、字体/分页writer/连续定位修复保留。当前581输入与R3c冻结相同，普通HEAD/index和旧WIP保持，无活动原CI任务。

已核CI39585860717 completed/failure与完整原件：24独立/6原导航过，整组18/19；失败首次分页go时目标spread loaded=false，目标didFinish/initialization.start迟到，诊断DOM one/complete/long top0但engine position cover。尚不能据DOM complete判为原生可读初始化已完成。优先核isSpreadLoaded、currentLocation发布guard、go完成及目标pending位置；不直接伪造位置或放宽30秒用例/3秒保存/20秒资源预算。先查当前锁定3.11官方和成熟实现，再决定最小修正及受控实验。尚未改源码/编译/派发本片CI。基线及原交接见build/maintenance/EPUB-first-jump-20261021。

# 当前断点：R3c实现已保存，下一轮只查一个EPUB疑点（2026-10-21）

用户已选择先保存本片与断点，下一轮单查唯一失败；本轮不追加CI，不进入R4，保持开机。

实际运行源c180e1126cb1283f5599644a9232b8ee6ccf717e，codex/maintenance-navigation-return-r3c，[CI39585860717](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39585860717) completed/failure。最终文档检查点见build/maintenance/R3c-20261021/final-checkpoint.json，不能把文档提交写成新运行源。

导航/返回点已迁入现有ReaderPositions，完整原点、单次采样、原guard/go顺序、内部同步发布/菜单及只清自身锁保持。字体事务只换共享锁两行，close仅换同位置导航清空；R3a/b保存、其余33个VM方法、原16合同、原测试/fixture、Core/Vendor/字体/资源/manifest/锁保持。581冻结输入与Git树、普通HEAD/index及全部旧WIP已核；禁止reset/clean。

实际独立24/24（原16+8）、原生18/19无跳过，各一次；原6导航和保存/进度/双模式六字体/同宽writer/TXT均过，整组不能验收。真实编译0源码错误，Linux工具71/71；Windows464语法新增0/54既有限制、71工具65过6 POSIX跳过，Bash过。连续字体截图后六delta0，同宽root写入0、真实1608/injected=false。

唯一失败：ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes，初始分页跳正文时，DOM已为/OEBPS/one.xhtml且complete/long top0，engine.currentPosition仍OEBPS/cover.xhtml；jump helper1640原30秒条件未满足，尚未捕获/恢复原点，也没有首轮分页截图。此case直接构造原ReadiumReaderEngine，没有调用新VM/导航负责人；通用Continuous错误标签不能判为连续分支失败。引擎和fixture与上一片同字节，根因、环境归因及回归因果尚未证；不能称定位已完全修好或R3整组完成。

下一轮只查这一个跳正文/位置上报疑点：先比较currentPosition/currentLocation、go返回与初始化完成时序的原始证据，再定义可区分原因的单例对照；保留原断言/30秒预算，不无假设重跑19或188，不直接铺开Vendor修改。R4顺延，产品计划仍保留。

权威Documentation/ValidationLogs/project-isolation-r3c.json，设计/参考Documentation/READER_POSITION_ISOLATION.md，过程归档Documentation/HANDOFF_R3C_DEVELOPMENT_2026-10-21.md。完整92811656字节原件/两个xcresult/附件/日志在build/ci/39585860717，SHA/digest/CRC及完整展开已核，重复ZIP精确清除；保全/冻结/失败单例日志及工具首轮失败在build/maintenance/R3c-20261021。

仅一轮CI：独立142秒（Swift构建93.38秒），原生1633秒，首suite前1116.23秒准备，19项执行合计357.974秒；其余含导出诊断，不把准备算作纯编译/测试。完整Core137/iOS188、严格设备Release、普通设备/TrollStore、手机/动态验收未执行，无新IPA，最后交付Build30。恢复须核实际run/进程，旧exec/PID不能直接复用。
