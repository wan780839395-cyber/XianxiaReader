# M4 阅读面板主题统一（Build26）

当前：App源码与两项真UI回归已接入，尚未Apple编译/原生验收/交付。Build25仍是已交付版本。

用户反馈Build25菜单仍卡顿但可用，允许按计划继续；这不是手机流畅度通过。本片统一目录、书签、书内搜索的灰绿浅深表面、文字层级、紧凑行距与空状态，不扩展到阅读引擎或性能阶段。

## 实现与边界

- 目录/书签拆成独立值视图，用同一ReaderPalette的原生insetGrouped List。目录保留原ordinal/深度、所有原目录条目和选择闭包；ordinal只是导航条目，不作为小说canonical chapter，不推断当前章高亮。书签仍由原model持久删除、原生左滑，日期及完整位置保持。
- 搜索框固定在列表上方；原生键盘、明确清空和搜索按钮、空查询禁用；清空通过既有setQuery取消旧会话与结果。提交收键盘，结果上下文用同一柔和文本色、关键词用灰绿加粗。结果仍增量、现有1000上限/加载更多/停止/取消/错误/关闭逻辑保持，ViewModel和Readium服务不动。
- 主题明确传入sheet，列表隐藏系统默认滚动底色，设置本地表面与导航栏背景/色系；五正文颜色不改。不使用全局UIAppearance、新动画/逐行阴影、整表自建VStack、数据复制/重新索引。新按钮保留44pt与原生/既有减少动效行为。
- 原生sheet与List继续负责滚动、键盘、安全区和删除手势；不添加主题过渡截屏或强制动画。旧Reader自动慢滚暂停安全区问题仍单列，不把本片新sheet复核当作旧问题已修复。
- Core/DB/schema/完整Locator/ReaderViewModel/SearchViewModel/ReadingInterfaces/ReadiumAdapter/Vendor/字体/依赖与资源窗口均保持，project.yml仅升26。

## 参考与取舍

2026-10-17核Apple公开文档：
- [scrollContentBackground](https://developer.apple.com/documentation/swiftui/view/scrollcontentbackground(_:))用于隐藏List系统底色，再明确本地背景。
- [toolbarBackground](https://developer.apple.com/documentation/swiftui/view/toolbarbackground(_:for:))用于原生导航栏背景；显式visible避免滚动前后色面不一致。
- [scrollDismissesKeyboard](https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:))沿用系统交互式键盘收起。

这些是iOS16已有公开接口，当前工程最低16/Xcode16.4，不引入最新系统独占外观或全局导航栏覆盖。实际API可用性/SwiftUI类型检查由本源完整CI确认，文档阅读和Windows语法不算编译。

## 验证计划

保留ReaderInterfaceUITests全部原test主体，增加五主题目录/空书签/搜索首屏与44pt检查，以及深色额外减少动效下真实书签左滑删除→退出/重开持久化、搜索结果→清空→新词无匹配→重新搜索跳转/回看入口。既有目录/书签/搜索跳转、迟到请求/取消、字体完整位置及三阅读模式回归完整重跑。

Windows运行仓库/Swift语法与工具tests；独立CI Core各135+iOS预计147(124集成+23真UI)+严格无签名设备Release26。真实原生截图、对应录屏和选定原始连续帧复核后才交付，手机FPS/内存/耗电、所有设备/辅助功能/旋转矩阵单列。尚未执行不标通过，M4未完成。
