# 阅读模块隔离实施方案

2026-10-19。状态：R1 通过35/35定向；首完整170/172、2旧UI失败，无Release/IPA。下一步只定向失败链路与有界浮点测量修正，R1生产输入保持。Build29 仍是最后交付。

用户同意优先整理阅读模块的职责边界。目标是让界面、设置、字体、位置与会话问题能够在明确范围内定位，降低后续改动影响旧功能的概率。隔离不能消除所有集成故障，最终交付仍需完整回归。

## 当前基线

- 已交付 Build29 的生产源是 `a65086c1151831b54d90ed083fa36fc27848b5cb`；`f32002880ebe7702321cce90f1d030823c047c53` 是同生产输入的补充测试源，不能混称完整 Release 源。
- 已检查 `build/ci/39147081645/final-delivery-receipt.json`，交付与保全回执存在。本次进程检查未见原 watch/collect/final 项目助手。
- 当前工作树含大量既有未提交文件，正常 HEAD 仍是早期记录。重构前保存当前维护文件快照，按上一切片快照审查差异，不能用正常 HEAD 推断本轮范围，也不能 reset/清理工作树。
- Core、ReadingInterfaces、ReadiumAdapter 已有依赖边界；Build28 已把进度显示更新单独隔离。继续沿用这些边界。
- 当前 `ReaderViewModel` 仍集中管理设置写入、字体资源、开关书、位置捕获、导航、书签和自动滚动。其职责集中比单个文件行数更值得处理。
- 初始位置偶发超时等未定根因继续单独保留；纯职责提取或同源重跑成功，不能作为旧根因已经修复的证据。

## 按顺序实施

| 切片 | 提取的职责 | 必须保留的边界 |
| --- | --- | --- |
| R1 设置持久化 | 外观/手感的有序写入、完成等待、失败与重试 | 不持有引擎、正文位置、数据库或页面控制器；引擎应用偏好仍由原编排调用 |
| R2 字体资源 | 目录、校验、导入、预览资源与刷新失效 | 浏览刷新不触发正文重开；只有明确选中才请求现有阅读编排；不复制现有 import/preview 服务 |
| R3 阅读位置 | 完整 Locator 捕获、保存、失败保旧与旧请求过滤 | 接收明确会话身份和采样能力；不关闭设置、不改主题、不管理字体目录 |
| R4 阅读会话 | 打开、重试、关闭、任务与回调失效 | 成为引擎生命周期的单一负责人；关闭后的旧结果不能影响新会话 |

每个切片稳定后再进入下一片。既有 `ReaderViewModel` 暂时保留界面所需的入口并转发，逐步成为组装与协调层；不在同一片中顺便改交互、位置算法、Readium 或存储格式。

## 第一片 R1 的具体工作

已实际审阅的成熟实现与取舍：

- [Readium 3.11 Preferences 指南](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/docs/Guides/Navigator/Preferences.md)与[官方 TestApp 的 UserPreferencesStore](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/TestApp/Sources/Data/UserPreferencesStore.swift)，版本与本项目引擎基线相同：设置存储独立，界面/编排负责向 Navigator 提交偏好。采用职责边界；本项目继续使用现有领域值和 BookFileStore JSON，不复制其 UserDefaults/数据库/类型擦除实现，不引入 Readium 类型到 Core。
- [Readest settingsStore](https://github.com/readest/readest/blob/2d37bbfc2e94725e1343ab2a825573545aa59f5f/apps/readest-app/src/store/settingsStore.ts)、[settingsService](https://github.com/readest/readest/blob/2d37bbfc2e94725e1343ab2a825573545aa59f5f/apps/readest-app/src/services/settingsService.ts)、[bookDataStore](https://github.com/readest/readest/blob/2d37bbfc2e94725e1343ab2a825573545aa59f5f/apps/readest-app/src/store/bookDataStore.ts) 已按固定 revision 读取：全局设置与书籍数据分开，状态与持久化有专门入口。它是 React/Zustand/Tauri 实现，只参考边界，不移植框架、跨窗口广播、节流或平台存储代码。
- [Apple WWDC21 actors](https://developer.apple.com/videos/play/wwdc2021/10133/) 明确 await 前后需要重新检查假设。MainActor 同步入队保证用户提交顺序；两条有序任务链跨挂起继续串行，完成结果核最新请求和阅读会话身份。保持 iOS16/Swift5 语言模式，不依赖 Swift6 新隔离语法。

当前接入：AppServices 持有一个共享 ReaderSettingsPersistence，覆盖旧 reader 写入尚未结束时新 reader 打开这一边界；通过四个异步方法的 ReaderSettingsStorage 窄接口调用已有 BookFileStore。独立对象只导入 Combine/Foundation/XianxiaCore，无引擎/Locator/页面依赖。ViewModel 保留原 UI 入口，订阅完成结果并过滤非当前 openRequestID；关闭不丢弃已提交的用户设置。恢复设置先等待该队列，flush 会纳入等待另一条队列期间的新编辑。存储格式、原完整位置捕获、关闭界面时机及原测试预算保持。

新增一个 App 层具体对象，暂名 `ReaderSettingsPersistence`。先迁移 `appearanceSaveTask`、`interactionSaveTask` 和相应的排队、等待与错误结果；延续既有 BookFileStore actor 写入路径和文件格式。需要测试替身时才引入窄接口，不建立通用事件总线或重构框架。

`ReaderViewModel` 的 `setAppearance`、`setInteraction` 仍负责既有引擎应用与阅读编排，成功后把领域值交给设置持久化对象；`saveSettingsNow` 保留当前会话检查，只等待设置提交。`saveNow` 暂时保留既有设置等待顺序和完整位置捕获，避免提取时同时改变行为。

预期修改范围是新增对象、`ReaderViewModel` 与有针对性的测试；`project.yml` 已递归收集 App 与 Tests/iOS，应核新文件实际进入 target。界面调用入口先保持。若提取需要改变 Vendor、数据库、位置算法或大面积 UI，先重新缩小切片。

R1 完成标准：

1. 外观与手感连续快速更改后，落盘结果仍为最后一次有效值；两类设置的既有有序语义保持。
2. 写入失败明确可见，重试成功可以恢复；旧完成结果不能清除较新失败或回写较旧设置。关闭/重开中尚未结束的写入，必须核对所有权和顺序，不能只测单次成功。
3. 既有覆盖页回归继续证明：设置完成不采样正文；位置捕获失败保留旧完整位置，回到正文后仍可重试。
4. 旧保存、关闭、迟到回调、字体与模式回归保持；不删除断言、不加等待预算换通过。
5. 编译与回归通过，原生“改设置→完成→返回书架→重开”行为保持。提取本身不声称手机性能提升。

## 验证与定位方式

- 开发时先 Windows 语法检查、Python tooling 与 R1 定向回归；未改动源码的方案文档无需启动编译。
- 定向验证稳定后冻结同一源，完成既有完整 Core/iOS/严格设备 Release 门槛，再交付。开发过程中的每个文件提取无需各自打包一轮 IPA。
- 新对象通过可控写入完成顺序与错误注入测试自己的边界；界面与引擎的组合行为沿用真实集成/UI 回归，不以替身测试替代。
- 测试失败先区分设置、位置、会话、原生呈现和运行环境，保留同源完整日志及所需原生诊断。重复失败而证据不足时补最小诊断或查对应官方实现，不继续凭猜测扩大生产改动。
- 界面间距/颜色问题优先进入对应视图；偏好落盘进入设置对象；位置错误进入位置链路；关闭后迟到回调进入会话链路。跨边界才扩大排查。
- 完整回归与手机结果继续分开。历史大诊断按既有保留规则收敛，不为每片重复制作无关页面的全量人工报告。

## 回退与交接

每片开始保存源码和必要配置快照，记录输入、触及文件和当前验证状态；回退只恢复该片准确文件，不覆盖其他未提交工作。存储格式和原始书籍保持，用户无需卸载、清库或重新导书。

本方案是唯一详细计划。HANDOFF 和 PROJECT_STATUS 只保留入口与当前切片；验证后才更新架构中的完成状态。目前 R1 源码已接入，尚无本片成功编译、IPA 或设备验收。
