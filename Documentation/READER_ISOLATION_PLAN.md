# 阅读模块隔离实施方案

2026-10-19。状态：R1 35/35定向通过；两轮完整分别170/172、169/173失败，原件保留，无新Release/IPA。已定位第二轮旋转AX异常后的测试方向污染，现只补测试隔离，Apple六项定向待验证；生产源与b111保持。Build29仍是最后交付。

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

## 完整门槛暴露的测试隔离边界

完整39189899149/source9b真实169/173，145集成全过，4项UI失败。第一处在charcoal横屏：AX段落frame为(125,-3,610,86)，窗口(0,0,874,402)，isHittable报告无有效点击点；同页完整可见的第7段为(125,145,610,86)。之后没有恢复物理设备方向的命令；3项字体用例截图2622×1206，原生录屏也确为横屏，单用裁切的app截图不能判断真实页面。字体用例原本按竖屏进行定位。错误中止时依靠方法内Swift defer的清理没有形成有效方向复位，后续用例继承共享设备状态。

已查[Apple测试初始化/清理](https://developer.apple.com/documentation/xctest/set-up-and-tear-down-state-in-your-tests)、[XCUIDevice orientation](https://developer.apple.com/documentation/xcuiautomation/xcuidevice/orientation)，并按固定revision审阅[Firefox iOS BaseTestCase](https://github.com/mozilla-mobile/firefox-ios/blob/0bd83b3b97a7dd97b23914030bd2292710b9fb5e/firefox-ios/firefox-ios-tests/Tests/XCUITests/BaseTestCase.swift)的MainActor异步setup/teardown及窗口旋转检查：采用XCTest生命周期公共基类，在每个用例前恢复已知portrait状态，结束/失败后终止测试App并复位方向；不搬入其浏览器导航框架、关闭动效或延长预算。

旋转等待只对完整位于窗口内的正文段落查询原isHittable，避免先探测裁切段落的无效AX点击点；仍须真实可点击正文、无加载、无错误和原纸色像素条件同时成立，原20秒门槛不变。全部28个UI target测试函数正文与9b按LF规范化后逐字保持，只更改公共fixture继承和该等待helper。5个UI类共享一个小基类；生产App、Packages、Vendor、锁文件、project完全不动。先定向重放原进度、安全区、3字体及1纯测量共6项，通过后才考虑最终完整门槛。当前仅Windows452语法新增0/17工具/bash通过，不能写成已Apple编译。

## 本轮时间成本与已落实的改法

实测35项settings测试本身0.85秒，Apple诊断job为11分13秒（39182894124）；3项settings-ui测试173.87秒，Apple诊断job为11分46秒（39188609488）。差额是构建、环境准备、诊断导出等成本，不能全部算测试时间。最后交付Build29的iOS job为55分38秒；其27项UI用例记录耗时之和1708.856秒、136项集成329.296秒（累计用例时间不等同于job墙钟时间）。本轮首完整失败job为43分35秒。源码隔离本身不会消除这些远程固定成本。

这片已落实的是窄存储接口、共享队列和可控异步测试，以及不打设备包的settings/settings-ui定向入口。定向通过后才冻结版本跑最终完整门槛；原完整失败只定位相关两项，用同生产输入的3项诊断核验后再进入完整门槛。旧目录点击失败保留为未定根因，没有借提取扩大生产改动。

当前workflow没有构建缓存。这是后续可单独验证的CI改进点：按Xcode/SDK/真实锁文件保存依赖与可复用构建输入，核验命中/失效与严格锁定；若同一runner上重复筛选测试，再评估Apple的build-for-testing/test-without-building。当前未实施、未测节省时间，不在正在验证的R1版本中混入流水线改造。完整回归和最终Release门槛仍按实际结果记录；定向入口的收益是减少开发诊断范围及无关打包，而不是承诺每轮CI只需一秒。

## 回退与交接

每片开始保存源码和必要配置快照，记录输入、触及文件和当前验证状态；回退只恢复该片准确文件，不覆盖其他未提交工作。存储格式和原始书籍保持，用户无需卸载、清库或重新导书。

本方案是唯一详细计划。HANDOFF 和 PROJECT_STATUS 只保留入口与当前切片；验证后才更新架构中的完成状态。目前 R1 源码已接入且 Apple 定向编译/35项测试及3项UI target诊断通过；两轮完整失败独立保留；最新测试隔离修正待Apple六项定向及最终完整门槛，尚无本片IPA或设备验收。
