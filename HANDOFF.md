# 当前交接与恢复点

2026-10-16，Build21自动慢滚开工，尚未实现/编译。

用户“没问题 继续吧”记录为Build20基本自用反馈，不扩大设备/FPS验收。已按AGENTS顺序读文档，核实际HEAD6d761749/空index/私有tip02ecc460、837清单hash、35包、十份备份；838原路径ZIP备份/原hash见m4-autoscroll-build21-start.json，Build20交接归档HANDOFF_M4_BUILD20_DELIVERY_2026-10-16.md。最新完整CI38850709820成功，无遗留开发任务/活动CI。保留所有未提交改动，仅私有index快照。

下一片：自动慢滚，阅读菜单主动进入，仅连续模式；可调速、触摸立即暂停、后台/关闭/跳转/布局变化停止，重开静止。减少动态效果或VoiceOver启用时禁用并解释；不自动绕过用户系统偏好。先核设计与有界窗口，按真实时间/小数移动，不后台追赶，不逐帧DOM/写库；旧Readium execute实际不节流，需明确低频位置采样与暂停后最终完整Locator。完整Core/iOS/Release21及真实UI视频/原始帧门槛在前，不能用Windows语法替代编译。

## 源码子步骤/测试前检查点

Build21基础源码与5 Core/7 iOS回归已接入；设计READING_AUTOSCROLL_DESIGN.md。Core纯时钟、速度偏好旧兼容；可选capability→Adapter短时CADisplayLink→Vendor有界step；约每秒完整位置/暂停flush，触摸/后台/模式/排版/resize/错误停，重开静止。尚未执行Windows检查或Apple编译，不宣称通过。接下来Windows语法/17工具及私有index旧测试主体/差异审阅，再冻结源码送完整CI。

## Build21 Windows通过/Apple构建前

426 Swift语法新增诊断0（54上游语法限制原留）、17 Python tooling tests通过；不是Swift编译。私有review-index相对02ecc460核无删除，49个受改文件内原测试主体逐AST保持，新增12测试（5Core+5集成+2真正UI），507源blob冻结；证据m4-autoscroll-build21-windows.json。当前普通HEAD/index未变，原838路径/35包备份保留。现在创建私有源码候选并显式dispatch完整CI；预期Core127每平台、iOS115（100集成+15UI），实际结果仍待读取日志，不预写通过。暂未交付Build21，Build20仍可安装基线。
