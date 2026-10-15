# 当前交接与恢复点

更新时间：2026-10-16（Asia/Shanghai）

## 实际断点

Build17阅读手感第一片通过[完整CI38775427080](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38775427080)，实际编译源`63134f1aa4787e3067453e2fe8b15bf17b449ca2`。Linux/macOS各119Core，iOS99/99（89集成+10真正UI），failed/skipped0；test/export/summary/recording均0，严格无签名iPhoneOS arm64 Release17。Windows423Swift语法新增0/54 pristine限制、17工具测试通过；语法不是编译。四长TXT Release探针/平台、三份真实六pins锁和504运行/验证源码blob已核。原生截图/手势录屏/连续帧与手机手感/FPS、普通签名/TrollStore设备结果分列。

保留Readium原生跟手翻页/回位和真正跨章连续阅读；滑动时可收起菜单、中央轻点显示，菜单0.2秒/10pt克制过渡。设置新增“手感”：记住阅读方式、滑动收菜单、减少动效。独立interaction-v1.json在BookFileStore actor上有界读/原子保存、写入顺序/错误重试；打开先恢复偏好，支持时走既有DOM锚点模式切换，不支持布局保留用户偏好而使用适用分页。用户/系统减少动效作用于点按导航和自定义菜单，手指保持原生跟手；DEBUG额外减少请求只在运行时合并。分页命令防重入/关闭身份保护；连续模式禁误横滑切资源，按屏命令仍用Readium原路径，不宣称动画期间完整节流。Vendor仅普通分页通知补齐局部锚点及provenance；不改JS bundle/schema3/原书/完整Locator格式/远程锁或依赖版本。

首候选8c548dce/CI38760598889为97/99，WebKit测试hook返回JS函数不支持、普通拖动发生在加载spinner时未收菜单，严格test65无IPA，原旧回归通过。实际两段失败/减少动效录屏总览确认准备门槛过早；第三候选只修正hook末尾null和真实可读样本文字等待，原手势/10秒菜单断言及旧定位回归保持。c9bae997/CI38765644376的原生滚动回调实验经录屏证据后Agent主动取消，停在LinuxRelease探针，Apple未运行；七文件ZIP/Git候选保留，产品路径撤回，不能把未证pointer取消假设当根因。第三候选1d1f2763/CI38765962839新动效全部过、两旧回归失败97/99，修正普通分页通知丢DOM范围与设置滚错底层连续阅读区，第四轮50ecf291/CI38771271584全89集成通过，2UI准备失败：顶部多余下滑dismiss与切模式未等原生就绪；最终只修测试准备，原断言不放宽。全部失败/取消日志/xcresult/素材与下载限制保留，设计READING_MOTION_DESIGN.md。

安装`build/XianxiaReader-ReadingMotion-Build17.ipa` / SHA256 `9d2af110466c03746e67929da58118ad60b4296f8001e408c4b2fb8ac29fa53e`；原创样本测试包`build/XianxiaReader-ReadingMotion-Build17-TestKit.zip` / SHA256 `5d09ad4d3536c644533e3a7b324561f8ace14cea0ba5a7fb8d119ec95de3e81b`。正常覆盖更新保留书库，+菜单确认0.0.1 (17)。原27包与本轮2包逐hash、测试ZIP CRC/内部IPA/原创Samples/Evidence/Cover/6张本轮真实Preview核过。仿真卷页/上下整屏/自动慢滚/触感反馈尚未实现，按独立后续切片推进；字体文件导入等M4内容仍后续，M4整体未完。报告M4_MOTION_VALIDATION_REPORT.json。

本轮24张实际原生截图已复核，全部非透明；分页EPUB深灰180%重排快照与新增EPUB整窗文字均已实际可见，旧透明采集不追认。巨段TXT孤立快照仍仅顶部约两行/下方留白，满页成因与手机结果仍未验收；普通TXT实际UI录屏有整页正文。正常65.60秒/额外减少动效16.54秒两段新手势视频全时段1秒总览，以及正常收菜单21帧/中央恢复20帧、减少动效跟手横拖17帧/恢复20帧共78实际20fps时间采样已看，无插帧且允许VFR重复，不当手机FPS。正常约18.00–18.20秒菜单短渐退同时正文原生上滑，约22.10–22.30秒中央恢复，正文视口未因菜单重排；额外减少动效约13.00秒菜单直接出现且保留手指横拖。手感三组/关闭自动收起/减少动效开关/连续模式重开可读；重启间31–46秒系统桌面不作阅读证据。其余3段阅读与5段书架原生视频只保留，未宣称本轮逐段审阅。系统真实Reduce Motion/VoiceOver/旋转/其他设备、普通签名/TrollStore、手机手感/FPS/耗电仍待测。

## 下一步

先按AGENTS读文档并核Git/实际文件/日志/任务；保留所有未提交改动。手机核Build17正文显示后跟手翻页/收菜单/中央恢复、连续接章/模式和位置重开、手感开关/系统减少动态效果。按反馈再推进上下整屏/自动慢滚等独立切片，卷页先小样，不铺开XBook。旧分页透明与巨段TXT孤立截图限制按本轮实际原生审阅记录，未覆盖的满页/重开/手机矩阵继续单列。

## 保护与证据

main HEAD6d761749911233122bcd031fcf718d22a19f9e77/原空index/M2 e6f31d857c0d73e25622a941db0b76e11f7bfe39/M3 44af41f0b8e700db1c6815558cb95ce3b8ed08fc保持。同一codex/m4-reading-appearance只用私有index快照，真正编译源与后续纯文档tip必须分列。27旧包保留，开始757项备份、恢复766项备份、7文件实验ZIP与Build15/16四份备份均保留。Build16交接归档HANDOFF_M4_BUILD16_DELIVERY_2026-10-15.md，本轮发展过程HANDOFF_M4_MOTION_DEVELOPMENT_2026-10-16.md。已执行504blob/782维护文件/29包/七备份/全部原路径/HEAD-index-M2-M3保护核验；最终清单为Documentation/FILE_INVENTORY.json，完整本地保护回执build/ci/38775427080/final-preservation-check.json。编译后的变化仅文档，当前文档tip从git rev-parse codex/m4-reading-appearance及远端同名ref核对，不等同上述真正编译源。旧一次性关机请求不沿用。

## 收尾检查点

Build17实物已生成并核hash/ZIP，完整CI日志/xcresult/24图片/10段测试视频均保留，本轮实际审阅范围如上。构建/下载任务现已结束，无遗留gh/python/build进程。仅剩本轮纯文档快照推送、远端同名ref与最终清单再核；此记录在快照前写入，实际完成状态以Git与final-preservation-check.json为准，不根据本段假定推送成功。
