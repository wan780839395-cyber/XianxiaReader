# 项目交接（2026-10-20 11:08上海）

## 当前断点

39358438791/e2c7990已完成：6项5通过1失败，源码编译诊断0，test65/summary与export0；完整179/设备Release自动跳过，无IPA，非Agent取消。apple12236824414完整187916017字节SHA09192d5bbda1695402ec5d6b894c12da5fa6a87e32b1df716a3a362862807560/CRC核，Core原件亦核；556冻结输入匹配。watcher78684/PID46912和receiver74065/PID42400均退出0，恢复仍核实际CommandLine，普通HEAD/index/旧包保持。

新窗口同字/同WebView、导入字体重开、跨章、六字体连续排版、浅深真实旋转通过；实际看了深灰横屏/恢复竖屏与宽viewport3张原图，正文和暂停控件可读。没有完整录屏/手机FPS验收。

失败：hidden-font在最初准备1200th字的前置条件就回到h1/offset0，尚未切字体；保留原30秒断言，不把重放通过当根因修复。同时导入字体case虽然通过，连续流程12条保留“页面仍在排版…”错误，真实ReaderView会弹阅读提示，阻止交付。详ValidationLogs/continuous-rotation-39358438791.json。

## 下一片：重复设置的幂等边界

只改Adapter submitPreservingLocation已应用偏好等值判断：先cancel旧请求，再比较现有Hashable EPUBPreferences，完全相同则不启动3秒DOM采样；真变化的采样/错误保持。依据固定Readium3.11 ConfigurablePreferences协议、初始config偏好及本地appliedPreferences记录。ReaderViewModel.open在engine.open后重复continuous=true，正是无变化却重新采样的路径。新回归验证重复模式/外观能立即fresh捕获同DOM字，撤销尚未提交模式也不重建；原字体重开断言后增加无阅读错误校验。计划最小preferences-idempotency2项（新合同+原字体case），不先跑已知hidden失败或full。新预期151集成+29UI=180，未运行。此片与hidden初始化/导航覆盖分开验收；后者准备可控字体屏障实验，禁止顺手混改。

先保全实际e2c7990输入/备份，再应用、Windows预检、alternate-index冻结及派发。本片已应用：before-idempotent-preferences备份，6文件（Adapter单guard、测试/名单/计数）。Windows453语法0新增/54Vendor限制、工具26pass3本地POSIX跳过、Bash通过。冻结/定向2项待执行，尚未原生编译。

## 历史/保全

39354867480为测试target链接失败0执行；39357294714为新增顶层本地包引出docc的解析失败0执行，恢复原project依赖图后本轮真正完成原生6项。不要重跑旧apply/freeze。Build29为最后交付；R1最后完整39243868846仍171/177，无Build30。后台UI39352276145已1/1、用户Build29手机已暂停。旧字体39348950147插桩2/2不代表2010→0根因已修。

普通HEAD6d761749911233122bcd031fcf718d22a19f9e77、普通index空，历史未提交/未跟踪源码、Vendor、53旧包/恢复ZIP均保留。无R2/R3/R4/M5、无关清理或关机。历史全文Documentation/HANDOFF_R1_RECOVERY_HISTORY_2026-10-20.md。

## 工具实证

cua.createBrowserTab仍报Work设置禁用本地浏览器；未改权限/配置。gh run view日志在run未完成时被CLI拒绝；job REST日志可读，但gh2.102终端转义保护须--allow-escape-sequences后捕获原始文件，不能把保护错误说成服务不开放。API原件可能缓冲，不能按尾部推断挂起。完成后的full.log/xcresult/artifact才是最终结果。
