# 当前断点：R3a位置状态/保存身份隔离本片完成（2026-10-21）

用户要求继续R3、保留现有功能及已修定位行为、控制范围。已完成这一独立切片并收齐定向证据，本轮不进入R3下一片。保持电脑开机，无关机任务。

## 实现与源码

- 实际验收源755b428a60143d8f649372e6c545cc1e03f82ecb，branch codex/maintenance-position-state-r3a，CI39573863939成功。最终文档检查点见build/maintenance/R3a-20261021/final-checkpoint.json；文档提交不能冒充新的运行源。
- 独立Packages/ReaderPositions Foundation包只依赖Core产品，负责完整不透明位置、显式保存请求/会话身份、失效及保存错误；App的进度摘要去重/错误通知接线保持。原3秒/32ms预算、每个await顺序及同步发布顺序保持；不增async封装。
- Core manifest/实现、SQLite SDK配置、设置/字体模块、所有原测试/fixture、Vendor四项定位修复、资源与锁保持；576冻结输入核SHA/Git树，35个非本片VM方法/35个原测试输入保持，普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index SHA256 b0f65fcef8c336009cf63acec064446b8627a71ef0231d161a9e8bb2e1dc0f28保持。所有旧WIP保留，禁止reset/clean。

## 验证与原件

- macOS独立6/6；真实iOS模拟器编译及原13项全部通过，各一次，无失败/跳过：8保存/生命周期、1进度、4真实EPUB/TXT/双模式六字体/同宽writer。原断言/预算/用例主体保持。Linux工具71/71；Windows459语法新增0/54既有Vendor限制，71工具65过6 POSIX跳过，Bash通过。语法不是编译。
- 六字体在两模式原字/字体条件通过；连续native snapshot后六保存位置delta全0。同宽writer无root写入，唯一进度读原生1608/injected=false，真实owner/frame匹配JS，原位置/原字断言通过。不能由此宣称所有定位时序或手机动效已完成。
- 独立步骤103秒含81.5秒构建；原生1392秒，首suite前1149.924秒含工具/依赖/编译/启动，13项累计202.182秒。新target只本片先build-for-testing再boot/test，提前暴露接线错误，不改变原用例预算。
- 完整17612505字节artifact/完整日志/两个xcresult/附件在build/ci/39573863939，GitHub digest/SHA/ZIP CRC核验；重复ZIP精确清除。权威Documentation/ValidationLogs/project-isolation-r3a.json，保全与接线回执build/maintenance/R3a-20261021。

## 首轮失败保留

首源a9d4e8424c01c6163af89d2f127f5a4caedffee7 / CI39569845077，独立6/6、原生test65/0项执行；Xcode规划Core自动dynamic产品时引用缺失CSQLite。完整59180字节原件在build/ci/39569845077，失败回执project-isolation-r3a-39569845077-failure.json。改用项目已有ReaderSettings独立包/原Core产品依赖，状态/6测试/App字节保持；没有强制Core链接方式或升级依赖。接线可用已验，Xcode内部精确根因未证；不能把首轮失败覆盖成成功。

## 下一独立切片与交付边界

R3整体仍未完成：下一片迁移捕获/持久化编排，之后导航/返回点，再R4会话负责人。先明确最小采样/存储能力、同步提交/取消/迟到规则、直接回归，保留本片6+13证据；不自动重跑全套或提前新增产品功能。设计/参考见READER_POSITION_ISOLATION；全项目及未来功能计划仍在PROJECT_ISOLATION_PLAN/ROADMAP/READING_FEATURE_IDEAS。

完整159集成+29UI=188、设备Release、普通设备/TrollStore、手机/动态验收均未执行，无新IPA。最后交付仍Build30；不能复用其发布结果作为本源码验收。当前未遗留本轮活动CI，最终本地进程见final-processes.json；旧exec/PID不能复用，恢复须核实际任务。

此前已修分页/连续定位原件、对照边界保持在paged-font-investigation及paged-font-control-39561815911回执；R3a未改该生产修复。历史完整过程归档HANDOFF_R3_DEVELOPMENT_2026-10-21.md，旧R2交接仍在HANDOFF_R2_DEVELOPMENT_2026-10-20.md。
