# M1 阅读视口恢复历史

以下是恢复过程的原检查点，历史“运行中”不代表最新状态；以 HANDOFF.md 为准。

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 当前断点

2026-10-14 00:40检查：CI38430692977已获macOS runner，iOS job开始完整构建；仓库/Linux Core通过。旧IPA SHA-256仍为fb3bf3adb825e1d40e97c962188aac238a05012ba1e36e07367d5d3eab38b181。Windows无遗留构建进程；不得根据网页日志尾部推断构建挂起。

2026-10-14恢复推进：双轴可见性/原生Locator就绪修正已通过41 Swift grammar和6 tooling tests，提交722127447057ef4555832d3950d98a2cb80114fd已推送。完整CI38430692977运行中：https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38430692977 。未覆盖旧IPA；当前只在CI中运行，Windows无遗留构建/测试进程。完成后先下载完整日志/xcresult/实际渲染附件，检查31tests及Release，再生成独立M1_READER_VALIDATION_REPORT；失败则继续修复，不能将图片局部测试通过写成全CI成功。

恢复检查：CI38426725252已结束且failure；仓库/Linux/macOS Core通过，31 iOS执行，30通过/1滚动跨资源等待超时。图片尺寸/菜单viewport两测试通过，Release/IPA未执行；完整日志/xcresult已下载build/ci/38426725252，旧Build2包保留。无遗留构建进程或登录。正在修正测试的就绪条件：DOM完成之外等待对应原生Locator，并检查可见WebView双轴交集，保留原断言和失败诊断。实际原因仍需重跑确认，不能把推断写为已修复。新失败记录Documentation/ValidationLogs/m1-reader-navigation-failure.json；测试前检查点。

2026-10-13 新真机反馈：用户确认 EPUB 可以导入；图像只显示窄横条，并明确想要上下滚动时无缝跨章（不是下一章按钮）。已写入 ReaderSurface 明确完整 viewport、Readium 官方 frame/autoresizing 容器、目录/书签菜单与迟到导航过滤；恢复章内滚动的默认横向跨资源手势并明确界面标签。Build 3，新增原创图像/长短章样书、3真实页面/2导航竞态回归，待静态检查及完整CI，旧包未覆盖。真连续滚动尚未实现：3.11仅章内滚动，issue684/PR811未合并；独立 M1 引擎切片见 CONTINUOUS_SCROLL_DESIGN.md，不能将本次横向跨节写成无缝纵向。图像原因仅据源码布局合同推断，用户书CSS未提供。导入来源未细分，其他设备体验未验收；字体/主题等M4后续，不跳入M2。

构建检查点：Windows 结构/样书/41 Swift grammar 与6 tooling tests通过。首轮源码336b21a / CI38424689048：仓库/Linux/macOS Core通过，App Debug编译完成；新增测试直接引用静态ReadiumNavigator具体类型导致test bundle链接metadata失败，31 iOS tests未执行，Release/IPA未执行。原失败日志/xcresult保留在build/ci/38424689048。已改测试通过UIKit容器的公开子视图访问实际WKWebView并保留同一DOM/快照/导航检查，避免重复SDK链接；待重跑检查和完整CI。不是删除测试/关闭错误。旧Build2包未覆盖。

2026-10-14：修正后41 Swift grammar通过，源码43d4b374b7ad9c76bae676ddcffe55ad8dbb581c已推送；完整CI38426725252运行中：https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38426725252 。首轮失败的完整日志/项目/xcresult和Core日志已下载。PR811仅在忽略的cache做了apply --check（通过，未修改/执行）；初查有整本估算空白及只按progression定位的缺口，正式依赖仍3.11不变。

## 媒体断言失败后的最终检查点

CI38430692977导航已过、原图像上限断言失败。新公开视口媒体保护提交0b30d53 /CI38434939423完整通过；31 tests、Release/IPA及两张真实封面快照通过。最终产物与范围以HANDOFF/M1_READER_VALIDATION_REPORT为准，所有先前失败记录保留。
