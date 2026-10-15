# 阅读手感与沉浸动效

2026-10-15，M4 Build17 第一片，当前源码待完整编译/原生核验。

用户认可Build16界面并授权动效方案。保留灰绿原生界面；先完善现有翻页、连续阅读、菜单进退和偏好保存。后续按独立可验证切片增加上下整屏、自动慢滚；纸张卷页先做与Readium排版/选字/Locator兼容的小样，不直接替换引擎。上述后续功能尚未实现。

## 已有能力与本片改动

Readium 3.11 已使用原生UIScrollView分页及WebKit平滑点按翻页，跟手拖动并非本片新造。保留其手势/惯性/松手回位，不叠透明拖动层，不复制正文或给实时文字做变形。

本片通过ReadingInterfaces可选ReaderInteractionProviding配置动效及被动阅读手势回调。Adapter注册官方drag observer，始终返回false，不消费输入；核当前Navigator/session身份并在VoiceOver开启时不自动收菜单。滑动后菜单可自动收起，用户可关闭；中央轻点显示的原路径保留。收起只变叠加菜单，正文视口不重排。上下菜单各10pt+透明度、0.2秒easeInOut；系统/用户/DEBUG额外减少动效请求任一开启都停用自定义菜单过渡。

点按上一页/下一页、目录/书签/搜索跳转共用NavigatorGoOptions，系统或用户减少动效时animated=false，进入实际WebKit instant分支；原生手指拖动仍跟手。分页命令使用带身份的防重入，不积压同一尚未完成的导航；close清身份、旧defer不能解锁新session。连续模式Readium go按屏立即返回，本片不宣称它获得完整动画期间的点按节流。配置disablePageTurnsWhileScrolling=true，保持纵向原生滚动，避免横向手势切相邻资源。未修改Vendor/JS bundle或升级依赖。

新增Foundation领域ReadingInteraction v1和独立Preferences/interaction-v1.json，存阅读方式、减少动效、滑动收菜单；不修改reading-v1.json、schema3或Locator。BookFileStore actor有界16KiB读、逐级安全路径、原子写；坏/未来文件保留且报错。ViewModel按输入顺序串行保存，保存失败可见/重试，离开设置或书架前等待两种设置任务。额外减少动效请求只合并运行时策略，不写用户设置。打开前读偏好，Navigator打开后按能力恢复连续方式并走原锚点保护管线；固定/竖排/RTL书籍用分页且不抹掉用户连续偏好。恢复模式到最终DOM之间仍是异步，原位置/关闭/重试回归必须全跑。

设置第三组“手感”：阅读方式、滑动时收起菜单、减少阅读动效。两种设置各自恢复默认，独立错误可重试；不暴露引擎对象或技术参数给读者。

## 参考与取舍

- [Readium精确3.11 DragPointerObserver](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/Input/Pointer/DragPointerObserver.swift)：使用公开不消费的输入观察；实际被动输入由InputObservingGestureRecognizerAdapter转发。复用API，不拷外部实现。
- [Readium精确3.11 NavigatorGoOptions](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/Navigator.swift)及EPUBReflowableSpreadView：当前分页scrollBy按animated决定smooth/instant，不能只依赖上层SwiftUI减少动效。Adapter统一选项可避免修改已维护Vendor。
- [Readest设计revision cc236be4](https://github.com/readest/readest/blob/cc236be49a6e3b2c2c0763e7096c36efe631e4b2/apps/readest-app/DESIGN.md)：参考克制过渡与阅读优先层级；其React/Tauri实现不直接适用于本项目原生iOS，引入自有SwiftUI小幅菜单过渡，不复制代码/素材。
- [Apple Books](https://support.apple.com/zh-cn/guide/iphone/iphc1af7c57/ios)的多种翻页风格是产品交互参考，不代表Readium已提供卷页API。本片只提供现有原生翻页及减少动效选项。

## 验证与边界

新增4 Core存储回归：独立默认/重建、坏/未来/超大保留、写失败重试、父级/悬空symlink读写。新增3生命周期：恢复/连续编辑/迟到手势、保存错误与运行时减少动效不落盘、不支持布局保留偏好；新增实际WebKit动效/重叠翻页集成及2原生真实拖动/收起/重开UI。所有旧测试保持。

预期119 Core/平台、99 iOS（89集成+10UI），以完整CI实际结果为准。Windows语法不是编译。保留完整日志/xcresult/录屏/退出码和真实锁；Release17禁签名。原生整窗/连续帧检查、手机手感/FPS、普通签名/TrollStore分别记录。Build16旧分页全透明与巨段TXT孤立快照限制不追认为通过；本片补整窗阅读证据，满页/字号/重开限制按真实复核更新。
