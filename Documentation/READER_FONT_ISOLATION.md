# R2 字体编排隔离

2026-10-20。本文描述本片实现合同；编译/执行状态以HANDOFF及ValidationLogs/project-isolation-r2.json为准。未验证的源码不作为已验收功能。

## 范围与状态负责人

- XianxiaReading新增真实ReaderFonts product/target，直接依赖ReadingInterfaces和XianxiaCore，App及iOS测试显式接线。ReaderFontCoordinator拥有目录、可预览资源、已安装ID、busy/message、刷新与导入令牌；不持有引擎、完整位置、AppServices、数据库或页面。
- ReaderViewModel保留原UI方法，读取单一字体状态并转发objectWillChange。明确选中才由原阅读编排执行设置或完整锚点捕获/保存/重开；不借R2提前提取R3位置/R4会话。
- App保留原ReadingFontImportService、ReadingFontPreviewRenderer、picker生命周期与Bundle字体/许可。BundledReadingFont只增加向模块提供资源值的桥接，文件、稳定ID、校验和预览算法保持。
- 原ReadingFontTests、生命周期、真实字体渲染与UI用例保持原文；新增ReaderFontCoordinatorTests直接导入模块，用可控continuation验证目录竞态。新增精确依赖负例，拒绝ReaderFonts导入App/ReadiumAdapter/ReadiumNavigator/UIKit/SwiftUI。

不更换框架、引擎、依赖版本、JSON/schema、字体原件、排版、采样预算或用户操作流程；不加入删除字体等未来功能。

## 保留合同

| 动作/边界 | 行为 |
| --- | --- |
| 打开 | 先准备内置及已导入资源，保留缺失警告，再由原编排设置字体/偏好与恢复位置 |
| 浏览 | 先读取有界目录；相同目录不重读所有字体，force才刷新；不安装、不重开正文 |
| 选择 | 已安装字体只请求原偏好应用；新目录字体仅在明确选择时请求导入安装/完整锚点重开 |
| 缺失 | 仅运行时暂用原字体，保留已保存的选择，显示可见错误，可重新导入 |
| 导入 | 复用原CoreText验证/原存储；加载与发布分离，引擎重开成功才提交资源/选中值 |
| 失败/取消 | 文件已导入可保留；捕获失败不关闭reader，重建失败走原恢复路径；旧任务不得关闭新reader |
| 刷新竞争 | 新刷新替代旧刷新；导入开始使旧浏览失效；旧defer不清空新请求 |
| 关闭/重开 | 失效字体会话及请求、清已安装ID/busy，保留原资源显示行为；旧结果不污染新会话 |

UI的isReady、导航互斥、picker/Task取消仍由原阅读协调层拥有；模块只拥有字体请求身份。导入成功、回滚、位置保存的提交顺序保持。当前完整门槛因新增7项直接模块合同，从原151集成+29UI变为158集成+29UI=187；原180项不删除或降断言。verify_ui_baseline的原unit-release精确计数同步由151提高至158，对应工具用例覆盖157项缺失/失败/跳过仍被拒绝；源码/环境保护条件不变，本片不复用旧UI。

## 本片验证入口

Windows先执行check_repository.py --swift-syntax、Python tooling和Bash语法；静态/语法不代表Swift编译。核对R2基线中的旧字体/生命周期/UI/引擎测试、Core/Vendor、资源、锁及普通HEAD/index不变。

冻结输入后仅一次workflow的font-isolation选择：新增字体模块7、原字体8、原设置7、生命周期28、原真实字体2及原生picker1，共53项。使用原ci_reader_diagnostic.sh的退出码、xcresult、完整日志/附件及超时，不新增重试。默认Core任务保持原137项与TXT探针，本片不修改其入口。若其他边界失败，保留原件、判断关联再决定最小对照，不自动改整个项目。

完整187、原生动效/更多UI、严格设备Release和普通设备/TrollStore验收留I6；本片不生成IPA。新增模块沿用iOS16/Swift tools5.10。因为现有ReaderFontResource在依赖UIKit的ReadingInterfaces，R2通过iOS target真实编译和直接模块测试验证，不宣称已有macOS无App字体快速入口，也不为得到该入口扩改接口类型/移动资源。I1设置快速路径不受影响。

## 已核参考与取舍

- [Readium固定基线3.11字体指南](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/docs/Guides/Navigator/EPUB%20Fonts.md)：资源声明用于构造Navigator，已有字体通过偏好选择。复用本项目既有适配/重开合同，不改变Readium API或Vendor。
- [Readest字体store](https://github.com/readest/readest/blob/2d37bbfc2e94725e1343ab2a825573545aa59f5f/apps/readest-app/src/store/customFontStore.ts)与[fontService](https://github.com/readest/readest/blob/2d37bbfc2e94725e1343ab2a825573545aa59f5f/apps/readest-app/src/services/fontService.ts)：目录、可用状态与文件导入职责分离，资源加载不等同当前阅读应用。只参考责任划分；该版本是Zustand/Web/Tauri，未移植其Blob/CSS注入、云同步、删除或缓存机制。
- [Apple WWDC21 actors](https://developer.apple.com/videos/play/wwdc2021/10133/)：await后重新核对状态。沿用MainActor和明确session/request ID，用可控continuation构造反序完成，不靠固定短延时碰竞态。

上述三份源码原件与R2基线在build/maintenance/R2-20261020，供当前开发阶段核对；外部资料不是新增运行依赖。
