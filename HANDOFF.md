R3c冻结前：Windows71工具65通过6 POSIX跳过（23.584秒），Bash语法通过；首轮工具fixture仍硬编码13导致的本地失败已保留，摘要改为严格匹配现19项，未改生产断言/预算。即将核对原16合同/原测试/字体事务/close边界并冻结唯一24+19运行。尚未Swift编译。

R3c本地断点：464语法新增0/54既有Vendor限制、依赖守卫通过；尚未Swift编译。正在跑71工具/Bash和保全审阅，之后冻结24+19，不跑完整门槛。

# 当前断点：R3c导航与返回点隔离开始（2026-10-21）

本片只迁移导航请求/互斥锁、单次离开时的完整返回点与capture→guard→go→guard→同步提交顺序，复用现有ReaderPositions；不动R3a/b位置/持久化、Core/Vendor/字体模块、锁或target。VM保留ready/engine入口、原错误呈现和菜单；模块在操作await之后原guard内同步提交返回点并调用原隐藏菜单，再defer清自己的锁，不能在新增await返回之后才提交。新入口核对原会话，不把旧操作绑到新会话。

字体import原流程只把两处导航锁赋值/defer换成同一个负责人调用；捕获/保存/重开事务原文与await保持。close只替换同位置三条导航状态清空；引擎最终回调与openRequestID失效顺序保持。导航只采样一次，不复用保存的3秒重试；取消/错误/跨书原点不跳转，失败保留已有返回点，stay只在空闲时清除。

预计改动：VM、新纯Foundation导航负责人及受控合同、position-isolation原生选择与精确证据守卫/工具fixture、交接/状态/设计。原16独立合同原文保持，新增8导航合同；原13原生保留并补现有6导航用例成为19，原测试/断言/预算完全保持。仅这一轮24+19，先本地检查再冻结；不跑完整188或设备Release，不生成IPA。普通HEAD/index及全部旧WIP基线已存，上一片579输入当前全同。初稿已实现：导航负责人持有返回点/锁，VM同步转发通知；导航结束前内部同步发布返回点/菜单。原16合同及R3a/b实现保持，新增8项受控合同。即将做本地静态/工具/Bash检查，尚未Swift编译，未派发CI，保持开机。

# 当前断点：R3b捕获和持久化编排本片完成（2026-10-21）

用户授权只做本片，导航和返回点下一片；已收齐定向证据，本轮不扩做下一片。保持电脑开机。

## 源码与责任

实际运行源421a5786e2be65baf661bc889c166ac8f22aff41，codex/maintenance-position-persistence-r3b，[CI39580846569](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39580846569)成功。最终文档检查点见build/maintenance/R3b-20261021/final-checkpoint.json，文档提交不能冒充新运行源。

现有ReaderPositions接管显式保存捕获、原3秒/32ms等待、写库、原错误及写库后的同步状态发布；原Core仓库和引擎经App窄桥接使用。VM保留请求起止、慢滚flush→guard→设置flush→ready检查及原每事件Task。新异步入口内部在原guard后同步提交，再返回VM；不在额外await返回后提交。旧捕获不能写入，旧存储结果不能盖新状态，已进入仓库的写入仍可能完成，未改变Core旧时间戳规则。

导航/返回点、字体导入capture→save→reopen事务及其他36个VM方法逐字保持；原状态六合同、原测试/fixture、Core、Vendor定位修复、字体/设置、资源、manifest/project/锁保持。579冻结输入SHA/实际运行Git树已核，普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28保持，全部旧WIP保留，禁止reset/clean。

## 验证及证据

- macOS独立16/16（原6+新10），原iOS13/13，无失败/跳过、各一次；真实编译无源码错误。Linux工具71/71；Windows462语法新增0/54既有Vendor限制，71工具65过6 POSIX跳过，Bash通过。语法不是编译。
- 六字体在两模式原字/字体条件通过，连续截图后六位置delta[0, 0, 0, 0, 0, 0]；同宽分页无root写入、真实进度1608且injected=false，owner/frame匹配冻结JS，原字/位置断言通过。只支持这些样本，未宣称所有时序或手机体验。
- 独立步骤101秒，Swift构建51.54秒；原生步骤1269秒含准备/编译/启动/测试/导出，首suite前949.087秒，13项累计执行279.299秒。只派发这一轮16+13，未跑全套。
- 原件build/ci/39580846569：完整日志、xUnit、依赖图、两个xcresult、附件及下载SHA/digest/CRC回执；重复ZIP精确清除。权威Documentation/ValidationLogs/project-isolation-r3b.json。冻结/保全/最终检查点在build/maintenance/R3b-20261021，旧PID恢复时须重新核实。

## 下一片与验收限制

下一独立片只做R3导航/返回点，先明确捕获/跳转/返回点状态及旧结果规则，再选择直接回归。字体导入特殊事务保留，R4会话负责人随后；不能称R3或整个项目隔离完成。产品计划保留在PROJECT_ISOLATION_PLAN、ROADMAP及READING_FEATURE_IDEAS，不提前实现。

完整Core137/iOS159+29=188、严格设备Release、普通设备/TrollStore、手机/动态验收均未在本片执行，无新IPA，最后交付仍Build30。不能复用旧Release当作新源码验收。

本片过程归档Documentation/HANDOFF_R3B_DEVELOPMENT_2026-10-21.md；R3a及首次接线失败仍在project-isolation-r3a及其failure回执。已修分页/连续定位原件和有效旧/新对照保持在paged-font-control-39561815911及continuous-offset-39456749155回执；本片没有修改该生产修复。
