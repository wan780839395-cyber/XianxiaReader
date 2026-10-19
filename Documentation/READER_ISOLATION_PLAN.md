# 阅读模块隔离实施方案

2026-10-19。39215839905已结束：字体前置2/2，完整单元147/148、UI仅11项后job超时；无Release/IPA。唯一失败在换字体前翻页准备，当前改为完整Locator深字准备并补CI总时限，尚未编译。生产关闭修正保持，下一步66项定向后才完整门槛。Build29仍最后交付。

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

已新增 App 层具体对象 `ReaderSettingsPersistence`，迁移 `appearanceSaveTask`、`interactionSaveTask` 和相应的排队、等待与错误结果；延续既有 BookFileStore actor 写入路径和文件格式。为控制写入完成顺序与错误注入加入窄存储接口，没有通用事件总线或重构框架。

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
- 生产或UI输入变化时，冻结同源完成完整Core/iOS/严格设备Release门槛。只改单元测试fixture时可用上文受保护组件路径，必须重跑全部145单元/集成并核真实UI基线，报告分项来源。开发中的每个文件提取无需各自打包一轮IPA。
- 新对象通过可控写入完成顺序与错误注入测试自己的边界；界面与引擎的组合行为沿用真实集成/UI 回归，不以替身测试替代。
- 测试失败先区分设置、位置、会话、原生呈现和运行环境，保留同源完整日志及所需原生诊断。重复失败而证据不足时补最小诊断或查对应官方实现，不继续凭猜测扩大生产改动。
- 界面间距/颜色问题优先进入对应视图；偏好落盘进入设置对象；位置错误进入位置链路；关闭后迟到回调进入会话链路。跨边界才扩大排查。
- 完整回归与手机结果继续分开。历史大诊断按既有保留规则收敛，不为每片重复制作无关页面的全量人工报告。

## 完整门槛暴露的测试隔离边界

完整39189899149/source9b真实169/173，145集成全过，4项UI失败。第一处在charcoal横屏：AX段落frame为(125,-3,610,86)，窗口(0,0,874,402)，isHittable报告无有效点击点；同页完整可见的第7段为(125,145,610,86)。之后没有恢复物理设备方向的命令；3项字体用例截图2622×1206，原生录屏也确为横屏，单用裁切的app截图不能判断真实页面。字体用例原本按竖屏进行定位。错误中止时依靠方法内Swift defer的清理没有形成有效方向复位，后续用例继承共享设备状态。

已查[Apple测试初始化/清理](https://developer.apple.com/documentation/xctest/set-up-and-tear-down-state-in-your-tests)、[XCUIDevice orientation](https://developer.apple.com/documentation/xcuiautomation/xcuidevice/orientation)，并按固定revision审阅[Firefox iOS BaseTestCase](https://github.com/mozilla-mobile/firefox-ios/blob/0bd83b3b97a7dd97b23914030bd2292710b9fb5e/firefox-ios/firefox-ios-tests/Tests/XCUITests/BaseTestCase.swift)的MainActor异步setup/teardown及窗口旋转检查：采用XCTest生命周期公共基类，在每个用例前恢复已知portrait状态，结束/失败后终止测试App并复位方向；不搬入其浏览器导航框架、关闭动效或延长预算。

旋转等待只对完整位于窗口内的正文段落查询原isHittable，避免先探测裁切段落的无效AX点击点；仍须真实可点击正文、无加载、无错误和原纸色像素条件同时成立，原20秒门槛不变。全部28个UI target测试函数正文与9b按LF规范化后逐字保持，只更改公共fixture继承和该等待helper。5个UI类共享一个小基类；生产App、Packages、Vendor、锁文件、project完全不动。先定向重放原进度、安全区、3字体及1纯测量共6项，通过后才考虑最终完整门槛。Windows452语法新增0/17工具/bash通过后，39194509105/8f5b已实际6/6、失败跳过0、源码编译诊断0（5真UI+1纯测量）；GitHub digest/CRC已核，两张原生PNG实看为正确portrait及恢复后的深灰正文/选中文楷。此定向不生成IPA，完整门槛仍待。

## 第三轮断点与验证组件复用

39196134450/8f的原始XCTest记录145项单元/集成（144过、1失败）和28项UI target全部通过（27真实UI+1纯测量）。xcresult summary给出172总/171过/1失败，与173个唯一控制台case存在一项差异；两份原值都保存，不拼成一次完整成功。唯一失败是ReaderRenderingTests的ContinuousLayoutFailureShowsRetryAndRecoversTheAnchor，尚未执行删除DOM的故障注入：request后19.198秒才收到navigation.started，20秒截止触发时初始化尚在原Readium的0.2秒settle阶段。不能据此认定设置写入或字体回归，也不能把一次重放成功当作WebKit慢启动独因已修。

测试宿主按[Apple UIViewController生命周期](https://developer.apple.com/documentation/uikit/uiviewcontroller)及已按固定revision审阅的[SnapshotTesting准备视图实现](https://github.com/pointfreeco/swift-snapshot-testing/blob/28e5de025e3fd98991791bfbf83023ab3708da03/Sources/SnapshotTesting/Common/View.swift)补明确前置条件：选前台scene，等待真实viewDidAppear、key window、已挂载且非零交集后才打开publication；失败记录宿主/窗口/scene状态。28个renderer测试函数主体不改，原30秒测试等待和生产20秒/3秒预算保持；App/Packages/Vendor/UI测试输入保持，未宣称慢启动根因修复。

为避免只改单元测试宿主还重复32分钟的已过UI，增加显式unit-release模式。采用[Apple支持的only-testing](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)按target验证，不引入新测试框架。GitHub官方macos15镜像已提供GitHub CLI，CI用仅actions:read权限读取真实旧run元数据与完整日志；不信任手写passed标志。验证必须同时满足：旧run completed且headSha精确8f；28个指定UI case各通过一次、无失败或跳过；App/Packages/Vendor/Tests/UI/Tests/Fixtures/project.yml/真实锁/.gitattributes/选择器等受保护输入逐字相同；Xcode16.4/16F6、host arm64、iPhone16Pro/iOS18.5匹配。来源输入变化、旧日志不可读、漏项、失败后重跑等情况直接失败，要求full模式。

只有上述UI组件证据成立，才重跑当前全部145项单元/集成（包含旧失败case），实际xcresult必须145/145、失败跳过0，随后运行原严格无签名iPhoneOS Release30。默认full流程仍跑两个完整target，真实test/export/summary/recording/build退出码和完整诊断都保留。新路径是“当前145 + 同输入既有28 + 当前Release”的分项验收，报告不能写成一次全套173/173成功。Core两个平台及TXT探针仍照原门槛执行。25项Python工具测试含漏项、重复、先失败后通过、跳过、源/SDK/设备变化与145数量不齐的拒绝回归；该候选的Windows452语法新增0/25工具/bash通过；Apple结果见下一段。

39203522040/cb的实际结果已返回：真实UI来源/源码/环境保护通过；设置7项及生命周期28项全部通过，Core两平台各137/4探针通过。当前xcresult 145总、142过、3失败、0跳过，test65、export/summary/recording0，故没有执行Release。三项失败分别为自动滚动关闭重开、六字体连续锚点、长封面两模式用例。日志明确记录WebContent进程启动24.550291、30.992426和31.131335秒，自动滚动失败时宿主appeared/key/foreground/可见均满足；旧布局重试用例反而通过。因此新增宿主前置条件未修复慢启动问题，保留其诊断价值，不能写成修复成功；也没有证据将全部失败归为环境或设置提取。

已核[Apple processPool说明](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/processpool)：配置多个池已不再有效，不能凭旧教程补共享processPool来碰运气。当前Readium 3.11使用readium scheme服务，不是localhost HTTP；不套用旧IPv6排查。下一次实验应以同一原生环境的最小WKWebView加载与实际publication加载作对照，并记录启动/导航/关闭阶段，先判断进程启动、资源服务或会话存活哪一段失常，再决定改动。失败原件及完整来源见[m4-settings-isolation-r1-unit-release-failure.json](ValidationLogs/m4-settings-isolation-r1-unit-release-failure.json)。当前不再无假设地重跑完整CI，不提高原预算，不进入下一职责切片。

## 关闭合同的可复现缺口（2026-10-19）

用户要求将教训写入整个项目，已在根AGENTS.md加入长期规则并链接CHANGE_AND_DIAGNOSIS_WORKFLOW.md。后续排障按明确假设和最小对照推进，不继续无假设整套重跑。

加载对照39209145399/cb14211实际3/4：微型自定义scheme不经过Readium、连续8次创建/加载/释放通过（首次3.20秒，后续0.40～0.61秒）；自动滚动重开及长封面两模式通过，六字体第6次重建的WebContent启动62.154176秒而失败。关闭100ms弱引用观测并不能区分永久泄漏与短暂挂起，因此未作为生产修改依据，临时helper已移除；独立control保留并安排在reader用例后，避免预热其首开。

检查实际代码发现close仅显式shutdown连续容器，分页依赖控制器deinit；初始化跨await也未核已关闭。两项明确关闭合同在未改生产的39209591549/99acd92上实际0/2：分页关闭后仍有导航/UI/scroll delegate与预加载视图；立即关闭后，分页及连续都可能由迟到初始化创建WebView。原始断言及artifact digest/CRC见webkit-close-contract-red-39209591549.json。这是已复现的生命周期缺口，尚不是全部子进程慢启动的唯一原因。

修正仅触及ReadiumAdapter的关闭调用和Vendor navigator：统一终止两种容器，分页先清delegate再removeFromSuperview，触发[Readium 3.11原始PaginationView清理](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/Toolkit/PaginationView.swift)和既有spread clear；设置终止标识，initialize开始及await返回后拒绝迟到创建，完成已有初始化等待。旧20秒/3秒/字体15秒预算、存储格式、正文排版、Locator和依赖版本保持。UPSTREAM.json登记准确摘要，不升级Readium，不改通用PaginationView。

先跑reader-session的66项：30个renderer（原28主体不变+2关闭回归）、28生命周期、7设置、1末尾最小WK控制。增加有界只读进程/内存采样应对后续WebContent启动失常，不记录命令参数和书籍内容，不替代真实测试退出。生产/配置源变化后既有UI组件保护必须拒绝复用；定向通过后才冻结同源完整148单元/集成+28 UI和原严格设备Release。当前修正未Apple编译，不能标为已解决或已验收。

## 66项结果与最终验证合同

383b11a/39211610770实际65/66，失败/跳过1/0；新两关闭合同和原三个失败用例通过。唯一旧testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord等待“中间字体开始但800ms延迟尚未结束”，最终字体尚未请求；当前页面已加载完成。103条资源样本观察到压缩内存峰值2763MiB、最低空闲55MiB及较大调度负载，不将这单独当作历史全部慢启动的唯一根因。

故障注入改为可控Promise屏障，并等待真正原生FontFaceSet.ready：初始字体正常完成，中间字体由测试持有；观察同一“中间字体未完成”条件后先发出最终选择再显式放行。原深字锚点/最终字体可见条件不变，teardown也释放屏障，不删除断言、不加重试、不改变生产20秒/3秒/字体15秒预算。27个旧renderer主体不变，此1项同步方式单列变化。

已核[GitHub官方主机规格](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)：macos-15为3核7GB ARM，macos-15-intel为4核14GB；[Intel镜像](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)仍提供Xcode16.4/16F6与iOS18.5。固定显式Intel标签与对应检查，不升级SDK。新的fonts-full在同一runner先跑原两项字体定向；失败保留真实退出及日志，后续完整验证/Release不会执行。通过后重用同runner构建目录跑完整148单元/集成、28 UI及原严格设备Release；两份summary/附件分开保留，不把预检加入完整结果凑数。26工具测试验证preflight的65/23失败传播及成功原件分离。当前候选尚未派发，不能把旧ARM UI作为该候选的通过证据，最终分别记录x86_64模拟器与arm64设备构建/手机待验收。

## 本轮时间成本与已落实的改法

实测35项settings测试本身0.85秒，Apple诊断job为11分13秒（39182894124）；3项settings-ui测试173.87秒，Apple诊断job为11分46秒（39188609488）。差额是构建、环境准备、诊断导出等成本，不能全部算测试时间。最后交付Build29的iOS job为55分38秒；其27项UI用例记录耗时之和1708.856秒、136项集成329.296秒（累计用例时间不等同于job墙钟时间）。本轮首完整失败job为43分35秒。源码隔离本身不会消除这些远程固定成本。

这片已落实的是窄存储接口、共享队列和可控异步测试，以及不打设备包的settings/settings-ui定向入口。定向通过后才冻结版本跑最终完整门槛；原完整失败只定位相关两项，用同生产输入的3项诊断核验后再进入完整门槛。旧目录点击失败保留为未定根因，没有借提取扩大生产改动。

当前workflow没有构建缓存。这是后续可单独验证的CI改进点：按Xcode/SDK/真实锁文件保存依赖与可复用构建输入，核验命中/失效与严格锁定；若同一runner上重复筛选测试，再评估Apple的build-for-testing/test-without-building。当前未实施、未测节省时间，不在正在验证的R1版本中混入流水线改造。完整回归和最终Release门槛仍按实际结果记录；定向入口的收益是减少开发诊断范围及无关打包，而不是承诺每轮CI只需一秒。

本轮也有低收益工作：在设置边界已经稳定后，连续整套回归反复碰到不同旧WebKit时序失败，把职责提取扩大成了运行环境和旧渲染链路排障；宿主准备假设验证失败后若继续重复全套，只会增加等待而不能证明原因。已落实的改法是UI公共清理、设置定向入口和有源码保护的组件验证；最新unit-release实际省去了再次运行已通过的28 UI，但仍保留145项严格门槛并正确阻止发包。剩余WebKit问题单列为发布阻塞，所有后续改动先明确假设、影响面和最小复现，拿到新证据后才扩大回归。

## 回退与交接

每片开始保存源码和必要配置快照，记录输入、触及文件和当前验证状态；回退只恢复该片准确文件，不覆盖其他未提交工作。存储格式和原始书籍保持，用户无需卸载、清库或重新导书。

本方案是唯一详细计划。HANDOFF 和 PROJECT_STATUS 保留入口与当前断点；ARCHITECTURE明确“源码已接入、发布门槛未通过”。R1设置/生命周期35项、UI修正6项与同输入28项UI分别通过；三轮完整失败及最新unit-release失败独立留证。尚无本片Release/IPA或设备验收，R2/R3/R4未实现。


39214692053/9bde173在字体前置步骤由Agent取消，完整验证/Release步骤确为skipped，不记源码失败。代码复核发现屏障还会持有预加载two.xhtml，现限定one.xhtml，与原断言和显式释放句柄一致，避免测试留下人工等待。实际注入JS已在本地检查语法，并以三个协议场景核当前页持有、预加载不持有及仍等待原生ready；这不是Swift/WebKit验收，下一冻结源仍需字体定向和完整原生门槛。


## 39215839905实际断点及本次最小实验

原artifact12172841432已完整digest/CRC核验。字体预检2/2不代表其在完整进程历史中通过：完整test在准备第3次翻页时未满足scrollX增量，尚未请求中间/最终字体，已有char430非零完整位置。147其他单元/集成（含2新关闭合同和独立翻页/重叠导航）通过；UI仅11项完成，整体被GitHub1小时限额取消，不能借其生成IPA。gh整轮log末尾停在编译是旧片段，真实artifact的build.log已有全部148和部分UI，需以原件为准。

本次假设：字体重排回归的三次相对翻页准备引入独立导航状态依赖；用既有公开ReadingPosition完整DOM Locator定位long-paragraph/char1200，并要求该字实际可见，随后仍fresh捕获深字、保持中间字体未完成时请求最终字体和原可见断言。与现有Readium3.11 EPUBReflowableSpreadView的版本化DOM Locator路径一致；不改引擎/字号/字体文件/加载或位置预算，独立翻页回归仍跑。先reader-session66带前序状态检验；若仍失败，核实际新失败阶段而非再随机延时。Apple XCTest setup/teardown方式此前已落实到window及engine清理（https://developer.apple.com/documentation/xctest/set-up-and-tear-down-state-in-your-tests）。

GitHub job的timeout-minutes是整个job限额（https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idtimeout-minutes）。真实本轮preflight21分21秒、随后准备/Core/编译约9分钟、148测试约13分42秒，既有28UI约31分37秒，尚需设备Release及导出上传，因此60分钟不足。总job设120分钟、66项定向60分钟，生产和单项原预算不变；最终完整选择full避免重复预检。不是通过延长功能等待掩盖测试失败。原超时及真实字体失败各自保留，不追认旧run成功。
