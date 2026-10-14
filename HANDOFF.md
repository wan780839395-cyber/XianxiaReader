# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 最新可验证断点

remote compact恢复与本轮开发已完成到可恢复检查点。工作区仍在main，HEAD `6d76174`，原暂存区保持为空，所有原未提交改动保留；没有reset/stash/清理个人数据。原370文件恢复ZIP在`.cache/recovery/20261014-092934/`，CRC及每个SHA-256全部匹配。完整阶段检查点和原Build3证据保存在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。

**最新已执行：CI38506979070 / 源码8908e98151ff021092721639aed274c660335d87，Linux/macOS各14 Core、38/39 iOS通过，0 skipped。完整M1未验收，没有新Release/IPA。** 唯一未通过的是长段字符锚点回归，其余双章同屏/逆向、fragment恢复、图像高度变化锚点、可见失败重试、搜索/模式往返、迟到模式切换、千章窗口与释放均通过。真实双章同屏PNG已人工查看，但不代表拖动惯性、全模拟器阅读或设备验收。

**最新候选：codex/m1-continuous-recovery / 89a46cee6ec96f665ae8b7b8d39047214fb11459。** 在上述已测版本基础上仅进一步要求reflow使用的anchorRevision等于viewportRevision，防止滚动后的resize恢复旧锚点。该行已过Windows grammar，尚未重新编译/运行。

**CI38508277189未启动任何job步骤。** GitHub check annotation原文：The job was not started because recent account payments have failed or your spending limit needs to be increased. Please check the 'Billing & plans' section in your settings。没有Core、Swift编译、iOS test、Release执行；不是源码失败，也不是Agent取消。该run的步骤为空，无build log可下载。原始run/annotations在build/ci/38508277189，拒绝证据在Documentation/ValidationLogs/m1-continuous-billing-not-started.json。不要无意义重试，也不要擅自改账单/付款/支出限额。

## 已实现的候选范围

- Vendor/ReadiumToolkit为官方3.11.0/revision d82f44f4f05d87add9e22a8b75abbd61dce745dd的本地维护扩展；原BSD许可、作者出处、基线/修改SHA及审阅依赖在UPSTREAM.json。不是官方合并功能；不修改SourcePackages缓存。
- 真正纵向连续资源窗口，最多12个WKWebView；章节wrapper按实际DOM高度排列，WKWebView保持固定viewport。前后资源回收，未ready章节保留加载/重试边界，不为全书分配巨大空白。已测两章物理同屏及逆向，不用章末go冒充无缝。
- 完整Locator保留href/CSS/text/位置与progression；新增DOMRange字符锚点、版本1局部视口偏移、64字符上下文。搜索Locator继续用Readium文本匹配。长段最后一项仍待新候选验收。
- MainActor采集UI数值快照，异步纯计算不读UIScrollView；epoch/revision/identity过滤迟到位置与测量。原有31个回归保持。
- 完整初始化等待（不是只看isSpreadLoaded/DOM readyState），原生go期间暂停同步；读取DOM scrollY，目录/搜索/书签原子定位。模式转换取真实DOM，关闭取消旧切换任务/待加载窗口及JS handlers；普通drag/deceleration和按屏滚动保留。
- 横排LTR重排支持范围按publication/settings检查；固定/RTL/竖排保留原分页路径。混合布局、真实字体/图片与设备体验继续按M1验证，不进入M2/M4。

## 验证与产物范围

Windows结构/SQL/四本原创EPUB、362 Swift grammar delta、14 Python tooling、bash -n通过。tree-sitter在原始3.11源码有54条精确已知限制，基线内容与真实Git blob核验，新增diagnostic为0；grammar不是编译。完整来源hash检查通过。

首次真实macOS解析**38496501326**，其原始6-pin Package.resolved已原样采用：保留版本/revision/location不变，SwiftPM裁剪未使用server/SQLite/LCP的四个传递pin和远程Readium。以后resolve/test/build严格锁文件，bootstrap保持false。

报告：Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json（最新候选未编译、上轮38/39、外部拒绝与五种验收结果分开）；M1_CONTINUOUS_STATIC_REPORT.json仅静态；每轮失败在ValidationLogs/m1-continuous-*.json。完整下载日志、summary、xcresult/附件在build/ci/38496501326、38497134015、38498560012、38500755762、38503347131、38505001863、38506979070。

现有build/XianxiaReader.ipa仍是Build3：7,393,693 bytes，SHA-256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2。旧测试ZIP/Build2/Build3/报告与日志保留，未覆盖或伪造Build4包。用户iPhone13/iOS16.6.1/TrollStore原书图像、阅读、位置仍待复测；普通设备签名/完整模拟器阅读/原生惯性/峰值内存未验收。

## 下一可恢复步骤

1. 先读AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核对实际Git/进程/hash/运行CI。所有改动仍未提交到本地main；候选分支用于可审阅快照。
2. 由用户处理GitHub Billing & plans的付款/支出限额拒绝，或提供获授权的可用macOS环境；不擅自改账单。工具恢复后对候选89a46cee6ec96f665ae8b7b8d39047214fb11459重新执行完整workflow，resolve_local_readium=false。不要只重跑旧38/39源码。
3. 必须核对39条测试与summary 0 skipped；若长段仍失败，读取timeout附件中的Locator/outer/inner/DOM坐标继续定位，不降charOffset/像素断言。检查全套生命周期/搜索/导入/viewport回归、Core与设备Release CODE_SIGNING_ALLOWED=NO，任一失败禁止IPA。
4. 全套成功后再核验IPA hash/arm64/系统SQLite/0755/最低iOS16/许可，备份旧Build3再提供Build4测试包。iPhone13正常更新保留数据，不卸载、不删数据库；设备/惯性/原书/字体与图像仍分别验收。
5. 更新本文件/状态/设计与FILE_INVENTORY；完整M1尚未放行，TXT、完整书库、M4设置与主题、百万字性能、XBook知识库均不提前铺开。

## 环境

Windows/PowerShell/Git/Python可用；本机无Xcode/Swift。Docker先前实际错误为dockerDesktopLinuxEngine pipe不存在，本轮没有启动/重置Docker或任何localhost服务，也没有遗留自己的本地测试/下载任务。其他项目进程保持原状。GitHub artifacts保留14天；忽略build/.cache不随clone，过期时需在真正可用的macOS环境按锁文件重建。
