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
