# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 当前实际断点

用户再次要求恢复后已按AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE核对文件、Git、进程、完整CI日志及xcresult。仓库经用户授权已公开，API为PUBLIC；标准runner可以正常启动，没有修改账单/付款/限额。旧账单拒绝38508277189仅是历史。

工作区仍在main，HEAD6d761749911233122bcd031fcf718d22a19f9e77，原暂存区为空，所有原未提交改动保留。候选分支codex/m1-continuous-recovery当前ad555abf11b5362cf457904c49b12d5630aacd41。没有reset/stash/覆盖原小说。原370文件备份在.cache/recovery/20261014-092934，已核验全部SHA/ZIP CRC；原始恢复及逐轮检查点在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。

**最新已执行为CI38513634971/ad555ab：Linux/macOS各14 Core，iOS39/40通过、1 failed、0 skipped。** 原31测试、双章同屏/逆向、fragment、图像高度变化、可见失败重试、搜索/模式往返、迟到模式切换、千章窗口/释放及新增旧WebKit termination回归均通过。仍未通过长段字符回归343：页面实际outer3119/DOMscrollY2367/长段top约-599，但Locator仍charOffset2。测试exit65，附件/summary各exit0；设备Release与IPA未执行。完整下载日志/xcresult/附件在build/ci/38513634971/artifacts/XianxiaReader-build-diagnostics/build。

没有仍在运行的CI或本地测试/下载任务（以恢复时查询为准）。旧缓存candidate.json/documentation-snapshot.json里89a/008e607是历史，不替代实际Git ref和CI head。

## 当前尚未编译改动

在已测ad555ab基础上补充锚点缓存的实际文档localTop key，避免布局先于scroll delegate时revision未变而复用旧字符锚点；measure恢复与await返回也核对同一文档窗口。失败诊断增加公开DOM caretOffsets。40条测试保持，charOffset>100与重开3px断言不降低。该补充已过Windows362文件grammar（原始54限制/新增0）和14 tooling；仍不是Swift编译，下一步完整CI。来源UPSTREAM修改hash已更新，6-pin真实锁不变。

## 实现范围与架构

Vendor/ReadiumToolkit是官方3.11.0/d82f44f4f05d87add9e22a8b75abbd61dce745dd的本地维护扩展，保留BSD许可、PR811参考及逐文件来源。不是官方合并功能，不修改SourcePackages缓存。UI经ReadingInterfaces调用引擎，Core保持Foundation/SQLite。

连续模式最多12个资源，章节按真实DOM高度布置，WKWebView固定viewport；显示加载/重试边界并回收窗口。标准Locator href/CSS/text/progression保留，附加DOMRange字符、版本1视口偏移与64字符上下文。搜索复用Readium原文本定位。MainActor快照隔离UIKit，epoch/revision/identity过滤迟到结果；关闭取消任务/JS handlers，回收spread断开UI/WebKit delegate，已clear或取消加载不回调当前Navigator。横排LTR重排支持，fixed/RTL/竖排保留分页。

双章截图人工复查属于原创程序化回归；没有完成原生手动拖动/惯性、峰值内存、完整模拟器阅读、普通设备签名或iPhone13/iOS16.6.1/TrollStore验收。完整M1未放行，不进入M2/M4。

## 验证和旧产物

报告Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json按候选源码hash/实际执行结果记录；M1_CONTINUOUS_STATIC_REPORT.json仅静态。逐轮失败与公开审计见Documentation/ValidationLogs。首次真正解析38496501326的6-pin Package.resolved原样保留；bootstrap保持false，resolve/test/build严格锁文件。

build/XianxiaReader.ipa仍为Build3，7393693 bytes，SHA256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2；原件在build/ci/38434939423/ipa。旧测试ZIP和Build2/3均保留，不把失败CI产物写成Build4。用户原书图像/位置/阅读仍待复测；更新应用保留书籍数据，不卸载/删库。

## 下一可恢复步骤

1. 核对实际Git/文件/hash/运行任务；不要从过时缓存或旧CI可见尾部推断最后成功。
2. 对当前localTop补充创建独立index候选快照并正常推送原codex分支，完整workflow_dispatch，resolve_local_readium=false。若本文件下方已有新run，先查询它，禁止重复触发。
3. 核对40 tests、0 skipped及实际长段结果；若仍失败，读取caretOffsets/Locator/outer/DOM坐标，不降断言。全部Core/iOS通过后才执行设备Release CODE_SIGNING_ALLOWED=NO/IPA。
4. 成功后下载完整日志/xcresult/快照/IPA，核验CRC/arm64/系统SQLite/0755/最低iOS16/第三方许可，保留旧Build3，再提供Build4测试包。原书、手动惯性、普通设备/TrollStore分别验收。
5. 同步PROJECT_STATUS/本文件/必要设计/FILE_INVENTORY。TXT、完整书库、设置/主题/音量键、百万字性能和XBook知识库仍未实现。

## 环境

Windows/PowerShell/Git/Python可用，无本机Xcode/Swift。本轮未启动/重置Docker、未启动localhost、未改变其他项目进程。GitHub artifacts保留14天，build/.cache忽略不随clone；过期需在可用macOS按锁重建。

## 当前运行任务

localTop锚点修复已创建候选54ffd91b1f532debf3a43be73d6a051e1c43bbe3并正常推送；完整CI38519173808已触发，bootstrap=false，预期40项iOS。本地HEAD6d76174/index为空继续保留。恢复先查询此run，不重跑ad555ab/39-of-40，也不假定最后修复或IPA成功。

CI38519173808已完成并下载完整日志/xcresult：Linux/macOS各14 Core，iOS38/40、2 failed、0 skipped；失败在首次currentPosition等待334和重试恢复396，长段charOffset断言未执行，不能判定localTop补充的结果。stock Readium脚本window load后通过requestAnimationFrame发spreadLoaded，未ready的屏外资源可能暂停该回调。现补充WK didFinish/真实viewport+Readium脚本探针启动同一个完整初始化管线，单次启动防止native/JS重复完成取消；clear取消bootstrap task。新增抑制确切spreadLoaded rAF桥的真实窗口回归，验证正文跳转仍完成（预期41 tests）。这不是只凭DOM ready标记ready；CSS/原初始定位/decoration仍全部等待。新补充未编译，即将静态核验/来源hash并完整CI。
