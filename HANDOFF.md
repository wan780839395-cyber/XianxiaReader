# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 实际断点

Build16原生阅读菜单/设置界面通过[完整CI38748113867](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38748113867)，真正编译源`ce5bde4d9d73e6979265a7b1f1bdf0f92d318970`。Linux/macOS各115Core、iOS93/93（85集成+8真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release16。原四长TXT Release探针/平台、三份真实六pins锁及501源码blob已核，原90项iOS和全部旧断言保留。Windows420Swift语法新增0/54 pristine限制、17Python tooling通过；语法不是编译。原生图片/成功case视频/连续采样与源码编译、普通设备/TrollStore、手机FPS分别记录。

阅读菜单使用浅色/深色灰绿实心卡片，分开章节进度、翻页和目录/书签/搜索/设置四入口；阅读方式菜单切左右翻页/上下连续滚动。阅读设置分“外观/排版”，主题/字体/字号与段落控件分别成组，44pt加减按钮与窄空间重排。五阅读底色/柔和深色正文、全局保存/重开/错误重试、原书样式/固定布局禁用规则保留。UI之外，旧分页回归反复失败后按官方3.11 needsInvalidation合同将字号重排并入原失效路径，使注入CSS/cache重建与动态CSS互斥；纯换色/连续模式保持动态路径。两维护Vendor文件/provenance与有界无正文诊断更新，新增真实WebKit动态调用计数回归。快速连发路径另在Adapter采样前过滤取消/旧请求并保留await后检查，普通分页采样使用官方spreadLoaded边界，完整continuous bootstrap等待仍只用于连续加载。原非零文字/180%/重开断言不变。Core/ReadingInterfaces/schema3/原件/六pins/JS bundle/Locator协议保持，不升级引擎版本，所有旧集成回归继续通过。

参考Readest真实revision cc236be49a6e3b2c2c0763e7096c36efe631e4b2的层级/留白/克制色彩，采用项目自己的原生SwiftUI实现，无外部源码/美术/依赖复制。Foliate仅阅读官方文档，其截图抓取超时未作视觉验收依据；差异、链接与取舍见READING_UI_DESIGN.md。

原生复核回执`Documentation/ValidationLogs/m4-polish-build16-native-review.json`，18图逐项检查（17图有非透明像素；1张分页EPUB全透明），3段59.55/50.38/18.26秒视频全时段1秒总览已看，正常sheet弹出23帧及减少动效请求分组切换22帧已看。本轮浅/深色菜单、模式选择、分组/原书开关/重开均可读；旧Build15命名的附件来自本轮实际测试，保留原名。连续帧是实际视频时间采样，可能重复，无插帧，不当手机FPS。额外Reduce Motion请求不设置系统偏好，系统分段/sheet仍可有原生动画；中央点击菜单淡入淡出尚未独立采样。appearance录屏25–43秒处为退出/重启间的系统桌面，不作阅读动效证据。

明确限制：巨段TXT隔离快照仅顶部文字、下方留白原因未确认；分页EPUB截图RGBA所有通道均0，像素全透明，不是可见黑页证据，采集/绘制就绪与真实整窗显示仍须确认。DOM/字号/非零原文字/3px重排和重开回归通过，不等价完整光栅页面验收。用户Build15“没问题 可以继续”仅按基本自用记录；手机分页EPUB和巨段TXT满页、大字体/VoiceOver/旋转/耗电继续单列。

安装`build/XianxiaReader-ReadingUI-Build16.ipa` / SHA256 `c55b94177e8ee3f7f9ea3ba50dd93cf49f67b784cc02b5994905c04b8bdd2638`；原创样本测试包`build/XianxiaReader-ReadingUI-Build16-TestKit.zip` / SHA256 `182f23473f89cded7c124324af411b30fd18593200c8b580c7f69f402a87821d`，附6张本轮原生浅深色Preview图。正常覆盖更新保留书库，+菜单确认0.0.1 (16)。新旧27包、ZIP CRC/内部IPA/原有样本/Preview hash已核。Build16手机待测；M4整体未完，字体文件资产导入/单书覆盖/独立四边距/字距字重/亮度/音量键/阅读方式跨启动保存仍后续，M5设备性能单列。报告M4_POLISH_VALIDATION_REPORT.json。


历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-first-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-second-failure.json

历史未通过/主动取消证据：Documentation/ValidationLogs/m4-polish-build16-third-failure.json

## 下一步

先按AGENTS顺序读文档、检查实际Git/文件/任务/完整日志，保留全部未提交工作。用户Build15基本自用通过并要求UI更好看，本轮回应到Build16。先核手机菜单/分组/五主题/排版调整后的满页与重开位置、减少动态效果和流畅度，按反馈继续M4字体资产/细排版，不进入XBook/知识库。

## 保护与证据

main/HEAD6d761749911233122bcd031fcf718d22a19f9e77和原空index、M2 e6f31d857c0d73e25622a941db0b76e11f7bfe39、M3 44af41f0b8e700db1c6815558cb95ce3b8ed08fc不动。同一codex/m4-reading-appearance仅私有index候选/纯文档快照；真正编译源与其后文档tip必须分列。开始733项备份.cache/recovery/20261015-build16/initial-worktree.zip及旧两份707/719项备份保留，hash见start回执；所有25旧包和2新包逐hash保持。此前Build15完整交接在HANDOFF_M4_APPEARANCE_HISTORY_2026-10-15.md，本片发展过程在HANDOFF_M4_POLISH_DEVELOPMENT_2026-10-15.md。

完整build/ci/38748113867保留Linux/Apple/full日志、xcresult、三锁、探针、实际IPA、ReaderSnapshots和实际UI视频/连续帧。完成前核501源码blob、27包、备份CRC/路径、最终inventory、原HEAD/index/M2/M3，然后保存纯文档快照并核远端tip；此后文档不是新编译。旧一次性关机请求不沿用。

交付包与阶段文档已落地，6张Preview原图字节已核，ZIP CRC/内部IPA/11原创样本保持。最终Windows420语法/17tooling通过，回执m4-polish-build16-final-windows.json（PY311匹配cp311绑定）；此后只文档变动不重编译。额外raster-limits.json核分页图2,713,500像素RGBA全0透明，保留满页待测；NativeReview/appearance-comparison.png仅两张本轮真实原生图并排缩小，原图未改。现在执行最终501blob/27包/四份恢复ZIP/原HEAD-index-M2-M3与当前inventory保护核验，再私有index保存纯文档tip并核远端。没有遗留本轮CI/watch/下载进程，四次CI均已完成。

最终保护核验完成：501运行/验证blob与真正编译ce5bde4d精确匹配，其后仅文档变化；756维护文件（不含inventory自身）已重建清单。27新旧包与4份707/719/733/743项备份hash/CRC/原路径保持，原HEAD/空index/M2/M3保持。核验在build/ci/38748113867/final-preservation-check.json。现在只保存codex/m4-reading-appearance纯文档tip、核远端并再--verify-only；该文档tip不等于新编译。下次从手机UI/分页EPUB与巨段TXT满页/重开位置/真实流畅度反馈继续，再推进字体资产等M4后续。
