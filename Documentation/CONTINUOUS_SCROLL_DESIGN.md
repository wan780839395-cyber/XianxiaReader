# M1 真正纵向连续滚动技术边界

## 用户需求与当前差距

当前断点：CI38530334549/d62af3b完整success，Linux/macOS各14 Core、iOS41/41/0 skipped、设备Release与Build4 IPA成功。下载日志/summary/xcresult/锁文件及433运行源码hash核验一致；原31及全部连续、长段字符/重开、旧termination、rAF桥回归通过。当前边界PNG人工查看只见第一章末尾和空白，未显示第二章，原因未确认；程序窗口/DOM断言通过不等于实际显示验收。完整M1、手动拖动/惯性、峰值内存、原书与设备仍不放行。Build4候选测试包已准备，不再无依据追加同一竞态补丁；旧失败/账单日志保留。

2026-10-13 用户明确要求上下滚动时本章末尾和下一章开头连在同一滚动流中，参考微信读书的交互。不是增加“下一章”按钮，不是到章末瞬间跳页。

当前 Readium exact3.11.0：EPUBReflowableSpreadView 内部垂直滚动，PaginationView 外部横向且 paging；框架的 scroll 偏好不会堆叠多个章节。项目原 disablePageTurnsWhileScrolling=true 还屏蔽了默认的跨资源手势，Build 3 恢复该通路并标注章内模式，但 **seamlessChapterScrollImplemented=false**。

依据：[issue684](https://github.com/readium/swift-toolkit/issues/684)、[PR766](https://github.com/readium/swift-toolkit/pull/766)、[PR811](https://github.com/readium/swift-toolkit/pull/811)。GitHub API核实：766 closed/unmerged，811 open/unmerged；不能用“最新版本已有”或已关闭PR冒充正式支持。

## 当前 M1 实现

中断原370文件快照及main/原index保留；运行源码已在候选分支快照d62af3b通过完整CI，本地main工作区仍保留原未提交状态。候选只显示已ready的连续窗口（最多12资源、前后按距离回收），短章包裹层按实际DOM高度排列，WKWebView始终固定viewport，外部滚动时同步内部局部offset。加载失败/超时显示边界重试，不设置全书估计空白。字符级DOMRange、64字符上下文、局部视口偏移只覆盖标记过的连续保存锚点，搜索Locator复用上游文本定位。布局/位置await结果过滤旧epoch/revision，关闭主动清理pending任务/JS handlers。固定/RTL/竖排不启用连续能力。

官方3.11来源与BSD许可逐文件登记；PR811只作为Navigator集成参考，不直接采用整本placeholder。首轮macOS真实解析38496501326保留6个旧版本pins，裁剪四个未使用server/SQLite/LCP传递依赖及远程Readium；38530334549根锁/生成workspace锁/下载锁逐字节一致，严格锁完整CI通过。Windows362文件grammar delta、完整来源hash与14tooling通过，静态不是编译；iOS编译依据独立CI。当前候选分支codex/m1-continuous-recovery，本地main及原未提交状态保留。

本次关键位置修正：跳转在同一次JS执行原Readium定位与读取scrollY；保存位置原子采样Locator/documentY/documentTop，对视口不一致最多重采样3次并过滤过期状态。完整初始化可由公开WK didFinish探针启动，不依赖后台rAF桥及时触发；已清理视图不再执行脚本或积累等待。

最初PR811审查（历史）：原始补丁在3.11.0上 `git apply --check` exit0，仅表示上下文匹配。其全书估算高度/未加载边界/Locator风险因此没有原样采用；本地有限窗口与完整定位已独立回归。2026-10-14再次查询PR811仍为open/draft/unmerged，上游维护者因v4准备暂缓新功能审查；本地扩展不能标为官方稳定发行。

优先评估 Readium 层的可维护扩展，而非重新实现 EPUB 排版：原 PaginationView 增加垂直连续布局，重用 resource serving、ReadiumCSS、DOM locator、内部链接、搜索及状态机。适配保持在引擎侧，UI/数据库继续只操作 ReadingInterfaces/ReadingPosition。

必须有可审阅的版本/补丁和许可证记录；不能临时修改 CI 的 SourcePackages 缓存，不能将未合并PR伪装成官方3.11。若采用维护分支/本地源码依赖，要真实解析、审查锁文件与完整 CI，再替换当前稳定路径。

用户最新原则和实际参考epub.js/Foliate的窗口/Range锚点实现见 `MATURE_READER_REFERENCES.md`。这轮保持Readium架构，先交付Build4并验证实际体验；若出现空白/跳动，先建立最小复现及参考差异，再选改动，不无限调等待次数。

关键门槛：

- 仅加载当前/相邻资源窗口，并按距离回收；不拼接整本、不加载全书 WKWebView，不为3000章分配巨大空白滚动内容区。
- 资源未加载时不允许滑过空白；加载失败有重试/可见反馈。短章、超长章、延迟图像/字体造成的高度变化不得移动正在看的文字。
- 正向及反向跨章，边界上下两章能同时出现；保留拖动/惯性，不用强制跳到新章来冒充无缝。
- 完整版本化 Locator 映射回原 EPUB href/fragment/CSS/text 锚点，搜索/书签/目录、滚动↔分页、后台/重启仍恢复同一段。
- 中文横排、竖排、fixed-layout、RTL 有明确支持范围，不能不匹配布局却仍展示“连续模式已生效”。TOC ordinal 不当小说 canonical chapter。
- 保持默认 Readium 分页路径可用；当前阶段不升级世界观/TXT/主题设置来绕过核心阅读问题。

验证至少包括：真实窗口中跨边界上下双章显示、逆向滚动、短章、窗口回收/峰值内存、图片迟加载、高度变化锚点、全套搜索/位置/生命周期回归；最后 iPhone13/iOS16.6.1/TrollStore 复测。最终门槛仍属于 M1，M4负责字体/主题/排版自定义。
