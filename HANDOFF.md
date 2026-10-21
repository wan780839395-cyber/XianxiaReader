# 当前断点：EPUB加载缺口对照有效，连续返回仍失败，已按用户选择保存（2026-10-21）

用户最新选择：先保存本片和失败证据，下一轮只查连续返回。停止追加CI/修正，不进R4；保持开机。普通HEAD/index和全部旧WIP保留，禁止reset/clean。

## 实际输入与结果

控制基线609cbd03463b64f312216a1c397616cd2be0659f（codex/epub-ready-control-baseline），候选0de44ba6d2d5875816f1a42a06d04f4313e21d9c（codex/fix-epub-native-readiness），远程refs已核；候选是精确子提交，仅Vendor SpreadView/UPSTREAM两文件差异。CI39594313793实际head为基线，脚本在合格旧负例后覆盖精确两文件候选，两相位584冻结输入均核Git blob，不能把基线head误当候选执行源。最终文档检查点另记于本地final-checkpoint.json，不是重跑源。

[CI39594313793](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39594313793) completed/failure。旧1项39.575秒合格复现指定断言失败，test65/tee0；候选6项为5过1失败，test65/tee0，无跳过/重试。两相位真实build-for-testing过，0源码编译错误。新分页加载屏障、原连续bootstrap、双模式关闭、隐藏字体、同宽writer过；原FreshReturnCapture用例首次跳正文及分页完整返回分支已过，连续返回981失败。因此只确认加载缺口修正有直接证据，整组/R3及全部定位未验收，R4未开始。

## 已改与实际断点

正文DOM complete不等于原生正文已经可读。旧页真实one.xhtml桥pending1时内层alpha0、currentPosition cover；候选用连续模式原有native didFinish+viewport/script探针启动同一完整初始化一次，字体/完整pending Locator完成后才alpha1/上报one/full DOM锚点，放行原桥后保持。仅扩大到重排分页；固定布局、连续语句/await次序、关闭取消、位置guard、Readium JS/R1/R2/R3/Core/依赖锁和原断言预算保持。精确3.11参考与取舍见READER_POSITION_ISOLATION及UPSTREAM。旧日志position先采样再await DOM，外层可见矩形没检查内层alpha；历史69秒延迟精确原因仍未证。

当前唯一失败为连续分支返回完整origin后的原3px断言，非初始封面问题。返回后DOM one、内层alpha1、初始化完成，scrollY2367、long top=-599.125，完整锚点char499/viewportOffset-3.125。原before值没有附件，不能确定delta或根因，不能归咎新代码或环境。分页原生截图与连续失败原件均保留；连续路径直接语句没变也不能排除前序分页状态影响。

## 下一轮唯一实验

只查原FreshReturnCapture单例的连续返回：先补模式/阶段、采样前后同一视图DOM、完整origin、跳出前before及返回后测量，保留false/true顺序、原3px/30秒及独立观察。先区分origin采样与恢复/测量时刻；需要远程才做同fixture旧/新一个单例对照，必须进入该返回阶段，不能把前置失败算返回负例或把单次重放成功写成已修。不要先改连续算法，不跑19/189或进入R4。若涉及更改预算/时序/范围，及时问用户。

## 验证、原件与成本

Windows464语法新增0/54既有限制（不是编译），76工具70过6 POSIX跳过（24.333秒），Bash通过；Linux76/76。原生driver1527秒，基线首suite前914.855秒含工具/依赖/编译/启动，旧case39.575秒；候选suite91.675秒（6项合计91.483），其余含增量准备和导出。不把冷准备当测试，不把5/6写成修复全过。未重跑独立24/Core137/完整189、设备Release/普通设备/TrollStore/手机，无新IPA，最后交付Build30。

权威Documentation/ValidationLogs/epub-native-readiness-control.json。完整原件119059067字节，artifact12344571830，SHA ae42d5dfee5f8e07cb4a509c07e9042cb29a300da7ba34a81a51ef0ef594f993，GitHub digest/CRC/完整展开均核；保留build/ci/39594313793/diagnostic中两相位xcresult、日志、summary、截图/附件、输入证明及baseline-verification。只清本轮重复ZIP，不动历史原件/包/源码。冻结、保全、工具结果、连续失败原件在build/maintenance/EPUB-first-jump-20261021，开发过程交接保存HANDOFF-development.md。watcher及下载均已结束、临时浏览器页已关闭；恢复查真实run/进程，旧exec/PID不当当前事实。

以下为上一片R3c当时的已保存断点，当前以本页上文和专项结果为准。

# 当前断点：R3c实现已保存，下一轮只查一个EPUB疑点（2026-10-21）

用户已选择先保存本片与断点，下一轮单查唯一失败；本轮不追加CI，不进入R4，保持开机。

实际运行源c180e1126cb1283f5599644a9232b8ee6ccf717e，codex/maintenance-navigation-return-r3c，[CI39585860717](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39585860717) completed/failure。最终文档检查点见build/maintenance/R3c-20261021/final-checkpoint.json，不能把文档提交写成新运行源。

导航/返回点已迁入现有ReaderPositions，完整原点、单次采样、原guard/go顺序、内部同步发布/菜单及只清自身锁保持。字体事务只换共享锁两行，close仅换同位置导航清空；R3a/b保存、其余33个VM方法、原16合同、原测试/fixture、Core/Vendor/字体/资源/manifest/锁保持。581冻结输入与Git树、普通HEAD/index及全部旧WIP已核；禁止reset/clean。

实际独立24/24（原16+8）、原生18/19无跳过，各一次；原6导航和保存/进度/双模式六字体/同宽writer/TXT均过，整组不能验收。真实编译0源码错误，Linux工具71/71；Windows464语法新增0/54既有限制、71工具65过6 POSIX跳过，Bash过。连续字体截图后六delta0，同宽root写入0、真实1608/injected=false。

唯一失败：ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes，初始分页跳正文时，DOM已为/OEBPS/one.xhtml且complete/long top0，engine.currentPosition仍OEBPS/cover.xhtml；jump helper1640原30秒条件未满足，尚未捕获/恢复原点，也没有首轮分页截图。此case直接构造原ReadiumReaderEngine，没有调用新VM/导航负责人；通用Continuous错误标签不能判为连续分支失败。引擎和fixture与上一片同字节，根因、环境归因及回归因果尚未证；不能称定位已完全修好或R3整组完成。

下一轮只查这一个跳正文/位置上报疑点：先比较currentPosition/currentLocation、go返回与初始化完成时序的原始证据，再定义可区分原因的单例对照；保留原断言/30秒预算，不无假设重跑19或188，不直接铺开Vendor修改。R4顺延，产品计划仍保留。

权威Documentation/ValidationLogs/project-isolation-r3c.json，设计/参考Documentation/READER_POSITION_ISOLATION.md，过程归档Documentation/HANDOFF_R3C_DEVELOPMENT_2026-10-21.md。完整92811656字节原件/两个xcresult/附件/日志在build/ci/39585860717，SHA/digest/CRC及完整展开已核，重复ZIP精确清除；保全/冻结/失败单例日志及工具首轮失败在build/maintenance/R3c-20261021。

仅一轮CI：独立142秒（Swift构建93.38秒），原生1633秒，首suite前1116.23秒准备，19项执行合计357.974秒；其余含导出诊断，不把准备算作纯编译/测试。完整Core137/iOS188、严格设备Release、普通设备/TrollStore、手机/动态验收未执行，无新IPA，最后交付Build30。恢复须核实际run/进程，旧exec/PID不能直接复用。
