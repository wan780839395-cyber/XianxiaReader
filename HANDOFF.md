# 项目交接：Build30 已交付，手机验收待反馈

## 当前断点（2026-10-20）

R1本片实现、真实编译、定向、完整与严格设备Release已完成；不再派发CI或运行旧apply/freeze/取消脚本。Release源aa0a119a71b10f1f345bc6f4cd54f6c8b4e2871a / codex/refactor-reader-settings，CI39373881574 success。定向6/6，151集成+29真UI=180/180，失败/跳过0；Linux/macOS Core各137、TXT Release各4。源编译0诊断，test/export/summary/recording均0，未复用旧UI，严格无签名iPhoneOS arm64 Release30/min16。

最终自动核验build/ci/39373881574/final-gates.json passed；全556输入、354实际Git Vendor清单、三锁六pins、六原字体摘要、普通HEAD/index和53旧包均核。apple/core/ipa三个artifact完整GitHub SHA/CRC校验/提取后已按精确回执清重复分片/ZIP。原始日志、xcresult、项目、录屏、图、三个收件回执均在本run目录；保留为当前已交付版本完整诊断。

交付IPA：build/XianxiaReader-SettingsIsolation-Build30.ipa，68890724字节，SHA35752183296684a573bf866c84ad34f555adc5d16aadcab7148763c1f839a638。TestKit：build/XianxiaReader-SettingsIsolation-Build30-TestKit.zip，64238089字节，SHAc61538db0ea6f209c1aadcbbbf9f6fc067d82f8af1cd0ddaa597b76e31be7128；24源文件逐字节/CRC核，含原创EPUB/TXT、六套原字体及许可、本轮8原图Preview。实际IPA内容另核版本0.0.1(30)、bundleIDcom.xianxiareader.app、min16、Mach-O arm64/platform iOS、可执行权限、无嵌入签名材料和六字体摘要。覆盖安装，不卸载或删库。

## 实现与因果证据

App ReaderSettingsPersistence隔离外观/手感有序存储；saveSettingsNow不从被覆盖reader采位置，dismiss后fresh保存。ReadiumAdapter取消替代请求后对相同已应用偏好幂等；真实变化仍fresh完整位置/3秒采样预算和可见错误。连续模式spread=never避免无关双页旋转重建；ReflowableSpreadView仅提前既有pendingLocation赋值，使字体初始化结束读取最新完整定位。

合格负对照39370263590/d28feaa不改生产：真实字体ready、深字1200可见时显式屏障放行，随后当前WK attached/alpha1且ready/settled、x0/原字消失，真实0/1；该轮自然结束无Agent取消。只移动既有赋值并登记UPSTREAM真实LF摘要19ab7308346ba538b431e8493d25c1bc7bb3104fc86b89828ea1ceb21f0276f4；同fixture本轮先行7.407秒通过，完整再次通过，原预算/断言保持。此前幂等2/2与后台1/1各自原件保留，未把其余旧启动/加载问题统一归因。

## 原生与设备验收

已查看当前run8张真实原图（浅/深暂停、横屏、恢复竖屏各3；真实字体分页/连续各1）以及四次旋转窗口全部38个原始PTS帧。正文/暂停状态可读，无所选窗口加载或错误提示，系统旋转变换角区可见，恢复竖屏与暂停内容一致。录屏218.07秒、平均4.40fps为稀疏VFR观测；只验所选20秒窗口，不称看过整段或手机FPS。普通设备/TrollStore/手机性能仍待用户实际反馈，Build29“已暂停”不冒充Build30反馈。

下一项仅手机核对：换字体/字号/主题→关面板→回书库重开的位置/错误；连续暂停后浅深旋转；慢滚回桌面再打开已暂停。本轮R2/R3/R4/M5未做，M4整体未验收。CI可观测性拆分作为后续独立切片记录，未混入生产修复。

## 证据与保留

Documentation/ValidationLogs/m4-settings-isolation-r1-success.json、m4-settings-isolation-r1-native-review.json、m4-settings-isolation-build30-delivery.json为当前权威回执；m4-settings-isolation-r1.json顶部最终状态已同步，历史失败字段保留。PROJECT_STATUS/ROADMAP/ARCHITECTURE/方案与DEVICE_ACCEPTANCE已同步。历史交接见Documentation/HANDOFF_R1_RECOVERY_HISTORY_2026-10-20.md。

本轮watcher exec34146/PID20472、receiver exec97148/PID37996均已退出0，CIM核无本轮Python残留；旧会话46581/34898在工具刷新后失效并已恢复过，不再使用。无活跃CI/接收或实现任务。普通HEAD6d761749911233122bcd031fcf718d22a19f9e77/index保持，历史未提交/未跟踪工作、恢复ZIP和53旧交付包保留，新增本轮两交付包。最终仅提交文档回执到私有分支，不把生成包/缓存提交。

保持电脑开机；不安排关机。cua曾报Work设置禁用，未改权限；gh CLI正常。job日志曾落后85分钟，不能用旧尾部判断挂起。完整脚本110分47秒：集成case合计804.415秒、UI3899.124秒，原生case合计不等于独占墙钟；测试/导出退出07:09:05UTC，Release构建成功07:32:30UTC，单设备Release约23分26秒，另有准备/上传。真实成本审计仅覆盖本地completed metadata，不等于账号计费或纯编码时间。
