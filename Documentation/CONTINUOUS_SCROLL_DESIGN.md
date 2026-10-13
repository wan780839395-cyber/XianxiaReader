# M1 真正纵向连续滚动技术边界

## 用户需求与当前差距

2026-10-13 用户明确要求上下滚动时本章末尾和下一章开头连在同一滚动流中，参考微信读书的交互。不是增加“下一章”按钮，不是到章末瞬间跳页。

当前 Readium exact3.11.0：EPUBReflowableSpreadView 内部垂直滚动，PaginationView 外部横向且 paging；框架的 scroll 偏好不会堆叠多个章节。项目原 disablePageTurnsWhileScrolling=true 还屏蔽了默认的跨资源手势，Build 3 恢复该通路并标注章内模式，但 **seamlessChapterScrollImplemented=false**。

依据：[issue684](https://github.com/readium/swift-toolkit/issues/684)、[PR766](https://github.com/readium/swift-toolkit/pull/766)、[PR811](https://github.com/readium/swift-toolkit/pull/811)。GitHub API核实：766 closed/unmerged，811 open/unmerged；不能用“最新版本已有”或已关闭PR冒充正式支持。

## 下一 M1 切片

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
