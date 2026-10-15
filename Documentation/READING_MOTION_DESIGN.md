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

## 首轮失败与修正（2026-10-16）

首候选8c548dce/CI38760598889，各119Core与四长TXT探针通过，iOS97/99（89集成中1新测试失败、10UI中1新普通拖动失败），全部旧回归通过，严格test65无IPA。新增测试安装scrollBy计数hook时最终表达式是JS函数，WebKit Code5无法桥接；补显式null，不删除实际instant/smooth/防重入断言。普通拖动收菜单失败而额外减少动效同手势通过；官方DragPointerObserver依赖原始move，UIKit可能先取消触摸观察器，当前证据尚未隔离唯一时序因果。改用已存在的[原生开始拖动回调](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/scrollviewwillbegindragging(_:))，只被动报告当前spread/分页容器/连续容器；保留现有delegate/selection clear/手势物理，不增加覆盖层或sleep重试、不改旧断言与10秒门槛。四文件hash在UPSTREAM登记。完整失败日志/xcresult/录屏保留，最终仍以完整重跑验证。

## 实际失败录屏纠正与第二候选取消

首轮两段原生录屏全时段1秒总览已复核：普通case在拖动时仍有加载spinner，正文直到约12.5秒视频时间才出现；减少动效case约4.5秒已有正文，随后拖动收菜单。菜单按钮启用只表示Navigator已挂载，早于WebKit可读，不能据此推断原始pointer取消为根因。第二候选c9bae997/CI38765644376因此Agent主动取消，实际未完成阶段记录second-agent-cancel.json，不写源码失败。新增原生回调七文件实验完整保存在该Git候选及本地ZIP，恢复至首候选既有引擎/Vendor，仅保留WebKit null返回修正。UI在原20秒open准备门槛内额外等原创样书可读文字，再执行原拖动和10秒菜单收起断言；不增加重试拖动，不放宽旧断言。新的完整CI验证真实已绘正文拖动。前述原始pointer时序仅为被录像否定的未证假设，不作为交付取舍。

## 第三轮旧回归及必要修正

1d1f2763/CI38765962839仍97/99，但所有新增动效/实际手势/重开偏好测试通过。旧设置测试在持久连续模式重开后app.scrollViews.firstMatch实际选中readium.continuous-scroll，滚动读者而非设置页；设置ScrollView提供独立id，原滑动/控件/数值断言范围改为这个真实面板。旧EPUB180%字体原非零字在重排后可见，但保存后重开回章首。核[官方精确3.11 Navigator](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBNavigatorViewController.swift)普通paged计算只返回progression，当前维护扩展的手工DOM采样能被后续普通位置通知覆盖。于是仅水平LTR重排分页合并既有有界DOM采样和官方metadata，核当前spread/offset/size及外层revision/container身份；固定/RTL/竖排保持原合同。复用64字符局部采样，不引入全文，不改Locator格式。只维护Vendor Controller/provenance，不修改JS/锁或恢复已撤回的原生滚动实验。原非零字/180%/重开断言及超时保持，并补重开前DOM范围断言/原创fixture附件，以实际完整回归为准，当前尚未验收。
