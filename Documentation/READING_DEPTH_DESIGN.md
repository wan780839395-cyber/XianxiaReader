# 阅读面板层次与按压反馈

2026-10-16，Build18，源码验证中，尚未编译验收。

用户认可Build17整体，但指出部分扁平、生硬。本轮按反馈先精修现有原生阅读菜单/设置；M4整体未完，卷页、上下整屏、自动慢滚、触感反馈、字体导入等仍为后续独立切片。

## 实际取舍

保留灰绿基调、五种正文底色和既有布局。阅读菜单采用实色底、微弱顶边高光和两层小投影，设置卡片只保留更轻的接触阴影，让菜单、分组、正文有明确前后关系；预览底色仍精确使用阅读主题。装饰层不接收触摸，不加遮盖正文的手势层，不给WebKit做截图变形或全页模糊。

ReaderPressStyle使用系统ButtonStyle/isPressed，保留原生点击、按住松手、拖出取消与可访问性语义；普通按钮按下0.975缩放/0.5pt微沉、0.08秒响应，松手0.28秒短回弹，填充与色彩同时给出反馈。外部命中区保留至少44pt，禁用态明确。用户/系统/额外减少动效任一开启，缩放/位移和自定义动画停用，但仍即时显示按下底色；不使用PrimitiveButtonStyle或自建点击识别器。

菜单进退仍只改变叠加层，不重排正文视口；沿用10pt方向，以0.3秒response/0.92 damping短弹簧收敛，避免长时间或大幅弹跳。设置分组标题用小型灰绿图标块和更明确的文字层次，系统Picker/Toggle/sheet继续使用原生行为。增加对比度环境下补强边线；正文颜色、排版、引擎导航、原书、schema3、完整Locator和六pins均不变。

## 参考与版本边界

- [Apple ButtonStyle](https://developer.apple.com/documentation/swiftui/buttonstyle)：公开标准交互样式协议，而非改写激活语义；官方Markdown元数据标示iOS13起，适用本项目最低iOS16。参考原理，自行实现，没有复制外部代码。
- [Apple colorSchemeContrast](https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast)：读取系统增强对比度，不以App设置覆盖系统；元数据iOS13起。
- [Apple Motion](https://developer.apple.com/design/human-interface-guidelines/motion)：反馈紧贴操作、短而克制，动效可减少，不靠运动单独传达状态。
- [Apple Materials](https://developer.apple.com/design/human-interface-guidelines/materials)：仅借鉴功能层与内容层区分；当前文档包含新系统Liquid Glass，本项目使用iOS16可用的实色/渐变/阴影，没有引入新系统API或声称实现Liquid Glass。

web工具打开Markdown返回不支持content-type，已用只读HTTPS直接下载官方原文至.cache/recovery/20261016-build18并核APIavailability；不是引用第三方转述。既有Readest参考与Readium3.11维护路径不变，未复制素材、引入依赖或升级版本。

## 验证

原99项iOS回归保持；新增一项实际UI回归，在普通/额外减少动效两种请求下长按松手设置和字号按钮，验证110→120→130→120每次只激活一次、暗色切换及44pt控件命中尺寸，并保留实际录屏与八张浅深色原生截图。不是镜像样式常量的单元测试；按压/回弹是否自然以原生视频连续帧和手机分别核验。

预期各119Core/iOS100（89集成+11UI）/严格无签名Release18，Windows423语法/17工具与完整真实锁、四长TXT Release探针仍须核验。当前待执行，不将预期计数写成通过。Build17手机基本自用反馈不扩写为手机FPS、巨段TXT满页或其他设备/系统可访问性验收。
