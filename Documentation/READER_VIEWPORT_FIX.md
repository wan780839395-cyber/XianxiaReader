# M1 阅读视口与图像修复（Build 3）

用户 iPhone13 / iOS16.6.1 / TrollStore 确认 EPUB 已能导入，后续截图中图像只显示窄横条。书籍正文/CSS 没有提供，因此不能从截图确定唯一裁切原因，也不提交用户封面或书籍。

## 本轮实现

- ReaderSurface 通过 GeometryReader 给 UIKit Navigator 明确的完整阅读尺寸，独立于菜单/加载状态；背景阅读区域忽略 SwiftUI safe area，正文留白仍交给 Readium 的安全区和内容 inset。
- 子 Navigator 挂载时立即设置 frame/autoresizing，采用 Readium 3.11 官方 SwiftUI 容器示例的方式，避免在异步排版开始时只有零尺寸等待约束计算。
- 真实页面回归随后发现默认95vh媒体上限仍可能高于WKWebView正文视口（图像830.3点、innerHeight812点）。使用公开setupUserScripts钩子，将现有ReadiumCSS媒体上限按真实innerHeight的95%计算，随resize更新；不重写作者width/aspect/fit，不改原文件。固定布局和竖排继续使用原路径。此修正待完整CI，不据此宣布用户原书裁切已修复。
- 目录/书签成功跳转后收起菜单；关闭/重开后迟到导航不能改新 session 的菜单或提示。搜索跳转同样核对 request ID。
- 恢复滚动模式的跨正文资源横向手势；原配置禁用了它。界面明确写“章内上下滚动”，滚动时按钮为上一节/下一节。
- 原创 reader-layout.epub：带上下颜色标记的高纵横比封面、长/短章节、fragment 链接。与原2本搜索样书分离，不修改原有80命中回归。
- 新增3个实际页面测试（屏幕尺寸/菜单切换、分页与滚动的完整封面、跨资源/目录跳转），2个迟到导航回归。WKWebView snapshot 作为 XCTest attachment 保留在 xcresult，并导出供视觉复查。

官方容器依据：[Readium 3.11 SwiftUI guide](https://github.com/readium/swift-toolkit/blob/3.11.0/docs/Guides/Navigator/SwiftUI.md)。本轮不改原 EPUB、不全局强制覆盖作者 CSS、不升级 Readium。

媒体上限依据：[Readium CSSRSProperties](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/CSS/CSSProperties.swift) 的公开maxMediaHeight，以及默认ReadiumCSS-before.css的95vh媒体保护。只校准阅读系统现有边界，保留作者的较小尺寸和object-fit。失败附件也须导出；CI先记录真实test/export退出码，任一失败均停止Release/IPA。

## 明确未完成的体验

用户要求的真正纵向无缝跨章滚动**尚未实现**。恢复横向手势/上一节下一节只是解除卡在章末的通路，不算连续滚动；本轮真实页面测试也不证明用户那本 EPUB 的图像已恢复。

Readium 3.11 稳定版内，scroll 仅改变资源内部滚动，外层 PaginationView 仍横向。最新稳定发布经 GitHub API 核实为3.11.0（2026-07-17）。上游 issue684仍开放，PR766已关闭且未合并，PR811未合并。不能仅切换配置、拼接整本 HTML 或直接采用未经验证的分支声称完成。后续作为独立 M1 引擎适配切片，见 CONTINUOUS_SCROLL_DESIGN.md。

当前源码待完整 CI；构造 Navigator、静态检查、DOM 几何、模拟器快照、用户真机各有独立边界。Build 3 提供后先复测用户原书，并导入原创 reader-layout.epub 对照；分页/滚动分别检查上下两条色带完整显示，再核对目录、图片、搜索/书签和位置恢复。
