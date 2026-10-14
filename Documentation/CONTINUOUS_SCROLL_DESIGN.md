# M1 真正纵向连续滚动技术边界

## 用户需求与当前差距

恢复收尾事实：最新执行38506979070/8908e98为38/39通过，原31保持；双章同屏/逆向、fragment、高度变化锚点、可见重试、搜索/模式往返、千章窗口与释放通过。仅长段字符缓存未过；89a46ce进一步要求anchorRevision匹配当前viewport，静态通过但未编译。38508277189因GitHub账户付款/支出限额未启动任何步骤，没有新IPA。以下较早候选审查保留为历史，不替代最新报告；完整M1/惯性/峰值内存/设备均不放行。

2026-10-13 用户明确要求上下滚动时本章末尾和下一章开头连在同一滚动流中，参考微信读书的交互。不是增加“下一章”按钮，不是到章末瞬间跳页。

当前 Readium exact3.11.0：EPUBReflowableSpreadView 内部垂直滚动，PaginationView 外部横向且 paging；框架的 scroll 偏好不会堆叠多个章节。项目原 disablePageTurnsWhileScrolling=true 还屏蔽了默认的跨资源手势，Build 3 恢复该通路并标注章内模式，但 **seamlessChapterScrollImplemented=false**。

依据：[issue684](https://github.com/readium/swift-toolkit/issues/684)、[PR766](https://github.com/readium/swift-toolkit/pull/766)、[PR811](https://github.com/readium/swift-toolkit/pull/811)。GitHub API核实：766 closed/unmerged，811 open/unmerged；不能用“最新版本已有”或已关闭PR冒充正式支持。

## 下一 M1 切片

2026-10-14恢复状态：上一聊天在本地已写入Vendor/ReadiumToolkit、接口/UI和渲染回归，未提交且未编译；remote compact后已保存370文件原样快照。现在候选只显示已ready的连续窗口（最多12资源、前后按距离回收），短章包裹层按实际DOM高度排列，WKWebView始终固定viewport，外部滚动时同步内部局部offset。加载失败/超时显示边界重试，不设置全书估计空白。新增字符级DOMRange、64字符上下文、局部视口偏移；只覆盖标记过的连续锚点，搜索Locator复用上游文本定位。布局/位置await结果过滤旧epoch/revision，关闭主动清理pending任务/JS handlers。固定/RTL/竖排不启用连续能力。

官方3.11来源与BSD许可逐文件登记；PR811只作为Navigator集成参考，不直接采用整本placeholder。首轮macOS真实解析38496501326保留6个旧版本pins，裁剪四个未使用server/SQLite/LCP传递依赖及远程Readium，原始锁artifact已纳入；源代码/新回归仍待严格锁完整CI。Windows362文件grammar delta、完整来源hash与13tooling通过，不代表编译/页面/惯性/设备验收。当前候选开发分支codex/m1-continuous-recovery，本地main及未提交原改动保留。

候选技术审查：PR811 原始补丁已下载到忽略的 .cache/continuous-scroll，`git apply --check` 在未修改的3.11.0标签上 exit0。这只验证补丁上下文能匹配，不是编译/运行通过。初查其 `layoutSubviews` 对所有 reading-order 项累加约1400点的估算高度；未加载资源没有阻止快速滑越空白的边界，定位也需要核对 fragment/CSS/text，而非只换算 progression。尚未修改正式依赖或执行候选代码；接入前须解决并回归这些问题。上游维护者也表示新功能因v4准备暂缓审查，不能把候选标为稳定发行。

优先评估 Readium 层的可维护扩展，而非重新实现 EPUB 排版：原 PaginationView 增加垂直连续布局，重用 resource serving、ReadiumCSS、DOM locator、内部链接、搜索及状态机。适配保持在引擎侧，UI/数据库继续只操作 ReadingInterfaces/ReadingPosition。

必须有可审阅的版本/补丁和许可证记录；不能临时修改 CI 的 SourcePackages 缓存，不能将未合并PR伪装成官方3.11。若采用维护分支/本地源码依赖，要真实解析、审查锁文件与完整 CI，再替换当前稳定路径。

关键门槛：

- 仅加载当前/相邻资源窗口，并按距离回收；不拼接整本、不加载全书 WKWebView，不为3000章分配巨大空白滚动内容区。
- 资源未加载时不允许滑过空白；加载失败有重试/可见反馈。短章、超长章、延迟图像/字体造成的高度变化不得移动正在看的文字。
- 正向及反向跨章，边界上下两章能同时出现；保留拖动/惯性，不用强制跳到新章来冒充无缝。
- 完整版本化 Locator 映射回原 EPUB href/fragment/CSS/text 锚点，搜索/书签/目录、滚动↔分页、后台/重启仍恢复同一段。
- 中文横排、竖排、fixed-layout、RTL 有明确支持范围，不能不匹配布局却仍展示“连续模式已生效”。TOC ordinal 不当小说 canonical chapter。
- 保持默认 Readium 分页路径可用；当前阶段不升级世界观/TXT/主题设置来绕过核心阅读问题。

验证至少包括：真实窗口中跨边界上下双章显示、逆向滚动、短章、窗口回收/峰值内存、图片迟加载、高度变化锚点、全套搜索/位置/生命周期回归；最后 iPhone13/iOS16.6.1/TrollStore 复测。最终门槛仍属于 M1，M4负责字体/主题/排版自定义。
