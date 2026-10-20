# 阅读模块隔离实施方案

2026-10-20用户确认将隔离范围扩展到整个项目，并优先于新增功能。[全项目隔离与维护计划](PROJECT_ISOLATION_PLAN.md)负责整体依赖/测试/新功能接入与后续产品清单；本文保留R1证据及R2/R3/R4的具体职责。当前R1已通过软件门槛，其他切片未完成；总方案登记不改变其验收状态。

## I1维护更新（2026-10-20）

R1持久化已进一步封装为ReaderSettings本地模块，只依赖Core；原算法和测试主体保持。当前维护源1545a3c/CI39398382008真实macOS逻辑7/7、原iOS设置/生命周期35/35，无失败/跳过；快速步骤115秒含编译，未跑本维护源完整180或设备Release，未生成新IPA。I0/I1本片完成，下一片R2字体编排；R3/R4仍待实施。完整方案/接入规则见PROJECT_ISOLATION_PLAN，证据见ValidationLogs/project-isolation-i1.json。

## 当前交付验收（2026-10-20，Build30）

R1本片已通过39373881574/aa0a119：先行6/6、完整151+29=180/180、两Core各137与严格设备Release30，556输入/三锁/实际Vendor/字体和53旧包已核。当前8原图与四次旋转38原始帧已查看，手机/TrollStore/帧率待反馈。交付包及摘要以PROJECT_STATUS/HANDOFF和ValidationLogs/m4-settings-isolation-build30-delivery.json为准；不做R2/R3/R4/M5。以下按时间保留的失败和“下一步”仅为历史分析，不能替代当前验收或触发旧脚本重跑。

2026-10-19。39235769577/2f93独立段首重开1/1通过；原完整字体链路原因未定。下一候选只增强测试分项证据，Windows语法/26工具过、新探针未编译，先fonts原两项。生产R1/关闭修正保留；当前149+28=177完整门槛/严格Release待，Build29最后交付。

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

R1当时新增 App 层具体对象 `ReaderSettingsPersistence`（I1已移入独立ReaderSettings包），迁移 `appearanceSaveTask`、`interactionSaveTask` 和相应的排队、等待与错误结果；延续既有 BookFileStore actor 写入路径和文件格式。为控制写入完成顺序与错误注入加入窄存储接口，没有通用事件总线或重构框架。

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


## 0283922定向结果与位置检查点实验

39226220147真实65/66；刚改的竞态测试9.257秒通过，另一个旧字体回归在第一个分页sourceHanSerif的save-close-open后回到h1/char0。该caseWebContent启动约1～1.7秒，没有历史慢启动证据；不能把这一失败改说成环境慢。旧用例字节保持到这轮，保留其原失败和完整原件。

下一实验只加测试中的同步位置检查点，不改生产：四阶段保存model/engine完整Locator、updatedAt、saveFailure；不额外await/capture或延迟，失败后才查询数据库。若save-returned已经错误，查fresh保存；若closed变错误，查最终回调；若open-returned输入正确而画面错，查渲染恢复。只选择fonts2保留刚修竞态的直接回归。不是无新证据重跑或删断言；实测通过不自动宣称唯一根因已修。


## 段首完整Locator的独立恢复实验

39230331856虽然因job30分钟取消，但test开始前已约28分钟，首字体case留下四阶段完整记录：p25/char0一直保留到open返回，saveFailure为nil，之后真实页面回h1。这次排除设置JSON/SQLite读回丢失；完整summary与失败后DB补读未完成，0完整case，不能称两项失败。记录font-reopen-checkpoints-39230331856.json。

下一项单独从管理存储EPUB、六原字体、思源宋体150%深色，直接用已观察到的p25/char0 Locator打开，要求真实字/字体可见。额外脚本只同步观察window.scrollTo及字体ready/段首rect，没有追加await、固定延时、重试或断言删除；完全不改生产代码。若独立路径重现，查Readium恢复步骤；若不重现，回到原链路的差异，不将偶然通过当修复。Readium3.11对应源码 https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift 已核，标准FontFaceSet.ready涉及字体和布局但不能仅凭它认定本次根因，故记录调用时状态与rect：https://www.w3.org/TR/css-font-loading-3/#fontfaceset-ready-attribute 。

新增直接回归使当前总149集成+28UI=177，所有原有case保留；对应计数门槛同步增加。所有原生诊断job预留60分钟以覆盖实测冷编译及导出，完整120，生产20/3/15秒及测试等待预算不变。

## 直接控制通过与原字体链路分项观察

39235769577/2f93的直接引擎p25/char0重开实际1/1、13.019秒通过；原生步骤至首测约28分12秒，整个准备包含解析、编译和启动，不冒充测试耗时。artifact12180054563完整digest/CRC核验。说明相同段首输入并非必然恢复错误；不能将原联合等待失败直接归成字不可见、字体失效或R1存储错误。测试Optional插值警告下一候选显式修正。

下一候选只改测试：两个用例共用有界同步scrollTo探针，增加实际FontFace状态和内容宽度；原导入字体用例仅在原断言之后记录字体/目标字两个独立条件与原生offset/size、模型字体/错误信息。原保存关闭打开之间不加await，不改联合断言、15/20/3/30秒预算或生产路径。选择原fonts两项，不重复整套。通过也只记录当轮，原失败和因果未定风险保留；失败则用分项条件选择最小修正。

## 当前两项字体结果及进入完整门槛的理由

39240216459/024真实2/2通过，117.689秒与14.696秒，test/summary/export退出0，Swift源码警告/错误0，artifact12182053807完整digest/CRC验证。六分页重开实际字体和目标字均true，原生x=2010，30份分项原件保留。连续模式断言之后的观察并非与原断言原子同步，预载/空白页false不是新测试失败；旧失败根因仍未唯一确定。生产未改，不将本轮成功写成历史根因已修。

当前554构建输入与024复核一致。此前be7完整失败的字体翻页准备已经更换为确定性完整Locator并定向通过，新增直接段首1项与原字体2项也已有实际结果。因此下一步是当前输入首次完整149集成+28UI=177和严格无签名Release30，而非无新条件重复旧完整CI；不再重复fonts-full前置。若完整失败，保留证据并按关联边界处理；不得导出验收IPA。

## 完整39243868846失败与下一单变量对照（2026-10-19）

完整CI[39243868846](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39243868846)/`024fc87e37cbc1f39af4fff42a7b1ee1f7fd059f`于2026-10-19 21:11（上海）结束failure。实际xcresult 171/177，6失败、0跳过：集成146/149、UI25/28；设置/生命周期35及关闭合同2项通过。test65，summary/export/recording均0；Swift源码编译警告/错误0，Release被阻止，无Build30 IPA。artifact12188251448完整digest/CRC核验，本地原件见build/ci/39243868846/artifacts/XianxiaReader-build-diagnostics。

当前只做recording-control诊断：同一Intel/Xcode16.4/iOS18.5 runner、相同reader-session67，先开额外simctl录屏，再关掉，保留两份独立xcresult/原始退出及进程内存采样；第二次通过也不会覆盖第一次失败。源码/全部Swift测试/功能预算不改，原完整发布门槛不改。开/关顺序与环境预热仍有混杂，不能以一次通过宣称根因已修。本次不再盲跑full；不启动R2/R3/R4，不关机。此处为派发前计划，实际结束结果见下节39263942566。

本轮iOS job约109分18秒：原31项renderer累计583.418秒、完整149集成854.649秒；28UI3344.186秒。准备/编译/启动和附件导出另计，未执行设备Release。完整原件校验见ValidationLogs/full-39243868846-failure.json。

对照依据：原fonts诊断没有额外simctl录屏，完整流程有贯穿构建与测试的后台recordVideo；当前失败有WebContent/GPU失去响应，但尚无两者因果证据。复用既有ci_reader_diagnostic.sh reader-session和同runner DerivedData，功能预算、fixture、所有67项断言不改；新包装脚本仅控制外部录屏和保留两份原件。按上轮实际583秒renderer、冷准备约28分钟估算，两组加导出在现有60分钟诊断job范围内；若未完成，记录实际断点，不将未执行计通过。

参考[Apple Xcode测试报告（Xcode15起的原生测试录屏）](https://developer.apple.com/videos/play/wwdc2023/10175/)，本项目Xcode16.4已真实导出每用例视频；[fastlane2.228.0 scan命令生成器](https://github.com/fastlane/fastlane/blob/2.228.0/scan/lib/scan/test_command_generator.rb)保留指定DerivedData、resultBundle和only-testing及pipefail。采用同构建目录及独立结果文件的办法，不引入fastlane依赖、不启用其失败重试、不删除原生视频或断言。顺序预热与runner状态仍需独立判断：on失败/off成功只支持继续核查；两者同失败或全成功不能宣称后台录屏是唯一根因。

派发时记录：对照39263942566/f02ce135已实际派发，repository-checks在Linux真实29/29通过（含3项退出码保全fixture）；原生结果待。复核原始旋转图另找到40像素中心879/1600纸色、门槛880的字形污染，原生geometry screenPaper=false；该片正文/底色实际可见。只在缓存准备120像素代表区域候选并保留55%比例、RGB+/-5与alpha>250，新增错误主题/孤立正确色块反例；未应用、未Apple编译。参考[SnapshotTesting1.18.6的UIImage像素比例与CGContext抽样](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.18.6/Sources/SnapshotTesting/Snapshotting/UIImage.swift)及[Apple XCUIScreenshot](https://developer.apple.com/documentation/xcuiautomation/xcuiscreenshot)。它是独立观测问题，不解释about:blank或101秒进程启动。

## 39263942566实际结果与纸色测试独立切片

同一runner ON64/67、OFF66/67，均真实test65、summary/export/recording0，两个原始xcresult及artifact digest/CRC已核。ON最大已记录WebContent启动60.481889秒，OFF3.59652秒（仅日志报告集合，不代表所有启动）；ON三项失败，OFF仍有原hidden-reflow用例在更换字体前捕获h1/char0，未满足深段落前置条件。两组设置/生命周期35、关闭2和框架控制1/8loads通过。顺序和预热仍混杂，既不宣称录屏唯一根因，也不以OFF66/67作为发布成功。完整数据见ValidationLogs/recording-control-39263942566.json。

原生job45分35秒；ON至首测20分45.925秒、67项513.388秒，OFF至首测48.259秒、67项333.371秒，开始前模拟器准备、诊断导出与上传另计。测试期1分钟load median分别291.49/116.83，不能把它当CPU百分比或单独的因果证明。

当前只应用已证实的纸色观测修正：Tests/UI/ReaderInterfaceUITests.swift的40像素中心改120，纸色55%、RGB±5和alpha>250全部保留，新原生正反例要求暖/深底色密集笔画仍接受、错误底色及孤立正确色块拒绝。原16测试主体逐项相同；无生产变更。脚本/workflow只增加reader-ready-ui四项定向（新反例、原旋转、原两项白屏重开），继续保留真正可读、无alert/loading、原等待预算。Windows453语法新增0、29工具中26通过3POSIX跳过、Bash语法通过；原生编译及4UI尚待，不计作178全套通过。

## 原生4UI结果与捕获前置条件诊断

下一独立实验只触及Tests/iOS/ReaderRenderingTests.swift：原fonts两项增加有界ResizeObserver/rAF前后轨迹、准备视图和捕获位置记录；原深段落断言失败后，先留证再停止字体后续步骤，所有原断言/时间预算保留。对照已有2010→0真实回跳，区分ResizeObserver布局回调、原生offset/视图选择与字体变更前的捕获错误。生产、依赖、UI与默认完整门槛不改；源码已应用，待Windows语法预检和新冻结后原生2项。探针读取几何可能影响时序，一次重放通过不代表根因已修。Readium3.11对应修订参考与差异见Documentation/READER_ISOLATION_PLAN.md。

已有原始轨迹204AD45B-3492-4791-8AD9-3F29561B4AC3.txt确认scrollX到2010后回0，首字x68→2078，width402/docWidth10452/font ready保持。不能将它简化为Locator丢失。官方固定版本[Readium3.11 utils.js](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/Scripts/src/utils.js)的ResizeObserver调度rAF，再由snapCurrentPosition写scrollLeft；本地bundled JS相符。仅将其视为待证候选，探针转发原回调参数/返回/时序，不改生产脚本；观察geometry可能触发布局，成功不能单独证明修复。另两项UI失败原件独立保留，下一轮不混入UI fixture修补或全套CI。

## 39279664338实际结果与滚动写入者诊断

最新fonts2[39279664338](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39279664338)/f32cc933已实际结束0/2，0跳过，test65/summary0/export0，Swift编译诊断0；556输入逐项匹配，artifact12203080049完整digest/CRC已核。无本轮watcher/下载进程残留。sourceHanSans分页重开字体已加载但锚点失败，DOM在1650ms到2010、1746ms回0，已记录RO帧1747ms才开始；402x750/docWidth10452/font ready不变，不能将该RO回调当作回跳起点。另一项在换字体前准备深段落失败，新捕获后探针未执行。原生job32分22秒，两个case累计111.933秒；准备/编译/启动/导出不能统称用例耗时。完整记录Documentation/ValidationLogs/capture-probe-39279664338.json。

当前下一独立实验只改同一ReaderRenderingTests测试文件：为Readium实际使用的Element.scrollTo及scrollLeft setter保留原参数/this/返回并记录有界调用栈；准备wait失败也导出轨迹。原断言、预算、生产及依赖不改，现有RO轨迹与独立写入轨迹各最多16条，不收集正文。区分JS主动写回0与未被这些公开路径记录的回跳；没有记录到写入也不能独自证明是WebKit内部错误。先Windows/JS语法、冻结，再执行原fonts2；禁止无新证据full重跑。当前已应用，原生待验证。

参考固定Readium3.11 utils.js的document.scrollingElement.scrollTo与scrollLeft调用；[MDN Element.scrollTo](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollTo)与[scrollLeft](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollLeft)核对公开签名。MDN当前包含较新Promise返回说明，不假定iOS18.5支持；探针原样返回运行时真实值，既不await也不更改调度。只在configurable原setter存在时转发，不缺省模拟或吞错。观察仍可能影响时序，不把通过当作根因修复。

补充参考核对（2026-10-20，仅诊断，未升级/移植）：Readium upstream相关文件最近提交列表中，EPUBReflowableSpreadView最新02508bc为页边距滑动、PaginationView最新6691403为离屏媒体，utils.js仍以3e8f317的相邻章节动效为最近变更，未找到直接对应当前2010→0的现成修补。[R2D2BC v3.0.0-alpha.19](https://github.com/d-i-t-a/R2D2BC/releases/tag/v3.0.0-alpha.19)修的是document.write替换iframe.src后，progression0被truthy guard忽略而保留旧偏移；与本项目WKWebView加载、已实际到2010后被归0的证据不同，不移植其guard或引入该引擎。继续用当前固定Readium3.11和原生写入轨迹选择最小修复。

## 39348950147实际结果与后台UI前置条件（2026-10-20）

96e913a的fonts2实际2/2，0失败/跳过，test/summary/export0，Swift编译诊断0；556输入、完整artifact12233013451的SHA/CRC已核。原六字体两模式与隐藏重排断言执行通过，六个分页实例都恢复x2010，未复现旧2010→0。探针增加几何读取和调用栈会影响时序，不能将通过解释成生产修复。连续模式若干采样仍带既有排版错误消息；邻接资源/隐藏WebView也被逐项记录，单条anchor=false既不自动构成用例失败，也不能用2/2推断无错误用户流程。验证记录见[原生结果](ValidationLogs/scroll-writer-probe-39348950147.json)，旧0/2原件保留。

用户确认当前交付Build29慢滚后回桌面、再打开为“已暂停”。最近4UI中Home→立即activate没有确认App进入后台，截图采样也未显示桌面；证据不足以改生产暂停逻辑。下一切片只修改原慢滚UI方法并增加background-ui单项入口。运行前确认正在慢滚，一次Home后最多10秒等待App处于后台/挂起且Springboard至少一个可点击图标，再activate；原立即暂停断言保持。前置条件失败即附状态和整屏原图并失败退出，无重按Home、无功能重试、无延长暂停等待。

参考[Apple XCUIApplication.state](https://developer.apple.com/documentation/xcuiautomation/xcuiapplication/state-swift.property)和固定[Firefox iOS c603c9c BaseTestCase.swift](https://github.com/mozilla-mobile/firefox-ios/blob/c603c9cd2274930f5011fbb243745caadb6abe08/firefox-ios/firefox-ios-tests/Tests/XCUITests/BaseTestCase.swift#L66)。采用其Home→确认后台/桌面→activate顺序；允许真实后台或已挂起，不复制Firefox特定runner图标名、忽略wait结果或额外idle sleep。当前CI使用Xcode16.4/iOS18.5，行为仍须原生验证。深灰横屏加载失败继续单列，当前切片不改变旋转或字体生产路径。

## 后台1/1通过后：连续模式旋转的最小生产切片

[39352276145](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39352276145)/ff196499实际1/1，0失败/跳过，test/summary/export0，编译诊断0，556输入与artifact12234387680完整SHA/CRC已核。日志53.23秒Home、56.76秒桌面图标、59.18秒activate，原立即暂停断言通过；已查看62.56秒原图，真实正文和已暂停控制可见，完整录屏未逐帧验收。生产暂停逻辑不改，旧未确认后台的失败仍保留，Build29手机反馈独立记录。

从39272564753原始xcresult只读补出UI runner/app/session/scheduling四份日志，不再依据超时的simctl空日志。深灰横屏替换视图D3E58E25在15:19:49.963755请求、15:19:50.286479附窗，直到15:20:14.529868被清理仍未记录navigation/initialization，loading=true。此失败发生在DOM和Locator恢复之前，尚不能唯一归因WebKit内部或宿主。

已定位一个可消除的触发链：本地infiniteScroll协议写明关闭双页、Navigator创建连续章节时也固定单页，但EPUBSettings仍解析spread=.auto；ViewModel在横竖变化时翻转spreadEnabled，队列失效后销毁/重载整组连续WebView。固定[Readium3.11 ViewModel](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBNavigatorViewModel.swift)的自动双页逻辑适用于原分页；[PR811](https://github.com/readium/swift-toolkit/pull/811)最新核实head5e22cb7仍open/unmerged，其Settings/ViewModel补丁也保留该缺口。该PR仅集成参考，不当作正式上游修复。

当前仅在EPUBSettings偏好解析中令infiniteScroll使用spread=.never，保留分页auto/always/never与defaults/显式模式优先级。连续frame/ResizeObserver测量路径继续承担旋转重排；不改字体、完整Locator、预算、依赖和原UI断言。一个新增纯设置回归覆盖三种分页偏好、继承默认连续以及显式切回分页；旧RenderingTests方法主体保持。UPSTREAM摘要登记对应源，CI新continuous-rotation选择6项：该回归、原两字体、原章跳转、原连续六字体和原浅深旋转UI。Windows453语法新增0/54限制、工具26通过3POSIX本地跳过、Bash语法通过，尚非Swift编译；预期150集成+29UI=179，完整179和设备Release待验证。单元复用守卫同步150，当前旧失败UI不能作为可复用基线。


## 原生链接断点39354867480与测试依赖修复

最新39354867480/abbcf18已结束，仓库/Core通过，iOS源码无编译诊断但XianxiaReaderTests链接失败，原生用例执行0项；不是6项行为失败或通过。完整artifact12235502581 SHA/CRC已核，原件build/ci/39354867480。新增测试直接使用ReadiumNavigator/Shared，测试target缺少显式产品链接；按XcodeGen2.46官方声明，只在project.yml给测试target增加已有本地包两产品，不更改Readium/远程pins/生产源码。下一步Windows预检/实际Git来源清单后同6项验证。当前无旧watcher/receiver残留。记录Documentation/ValidationLogs/continuous-rotation-39354867480-link-failure.json。 采用固定[XcodeGen2.46包产品依赖规范](https://github.com/yonaskolb/XcodeGen/blob/2.46.0/Docs/ProjectSpec.md#dependency)，复用同一个Vendor/ReadiumToolkit本地包，App目标及包版本保持。未应用缓存中的live-resize/rotation-full候选，先完成当前6项。


### 2026-10-20 测试依赖边界收敛（原生待验证）

39357294714/832fbaa在xcodebuild依赖解析退出74：测试target新增顶层Readium本地包后要求swift-docc-plugin，现有六pins锁拒绝该新依赖；0项执行。原始artifact12236241412完整SHA/CRC与556来源核实。前一轮链接失败不等于加直接包就足够；源码import、产品链接、锁定依赖图必须分别验证。

选择恢复abbcf18已真实解析的project.yml，而不是为新增内部设置测试加入文档插件和新锁。官方[Swift-DocC插件说明](https://github.com/swiftlang/swift-docc-plugin#adding-the-swift-docc-plugin-as-a-dependency)说明它用于文档生成；本Vendor Package.swift确实声明插件，本轮解析原始错误证明顶层包带来的图差异。未修改上游manifest或伪造锁。

新增且从未执行的内部EPUBSettings case改为现有Adapter挂窗集成回归：非零DOM字在宽/窄viewport仍可见、同WebView、资源窗口有界；其viewport变化不是物理旋转，原UI case继续执行真实浅深横竖旋转。分页与六字体原断言保持。默认三处fixture退出临时root-scroll/RO探针，避免测量几何影响时序；原字体屏障、失败后取证、断言及预算保持。旧有探针原件不删，2/2不算根因已修。

rotation-full只复用同job环境/编译产物，严格先6预检，成功后新鲜全179及无签名设备Release；不复用旧case结果。各阶段日志/summary/xcresult分开保留，失败不能交付IPA。总job上限150分钟容纳历史109.3分钟完整执行及新增预检/导出/Release，个别生产和测试时限不放宽。


### 重复偏好与初始化定位分别隔离（2026-10-20，原生待验证）

e2c7990/39358438791预检5/6，完整179及设备Release自动跳过；无Agent取消。连续单页策略对应的同字viewport与浅深实际旋转通过，但不能称所有旧WebKit故障消失。hidden-font失败在初始1200th字准备，尚未进行字体替换，当前页h1/offset0；作为独立初始化/定位边界保留。

另一个实证是连续字体在原断言通过后12条errorMessage。ReaderView会将它呈为阅读提示；原字体fixture只挂引擎，不能由截图无弹窗推断真实UI无错。源码发现ReaderViewModel.open在引擎已按initial preferences创建后重复continuous=true，Adapter即使偏好等值仍开始3秒DOM采样，字体初始化未定时会报“页面仍在排版”。

本片仅在Adapter取消旧请求后，用[固定Readium3.11 Hashable偏好协议](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/Preferences/Configurable.swift)比较请求与appliedPreferences；相同则不采样。官方initial配置与本地open中的appliedPreferences赋值共同说明无需重新应用。这是本地Adapter判断，非声称上游已修复。真实变化、3秒预算、错误回调、完整Locator保持。

新增可独立验的公共行为：重复相同连续模式/外观仍可立即fresh捕获原DOM字；撤销尚未提交的模式切换回已应用状态也保持原WebView和连续模式。原真实字体重开保留全部字形/锚点断言，增加无errorMessage断言。最小preferences-idempotency选择这2项；hidden初始化问题不混改/不通过重跑掩盖。151集成+29UI=180最终门槛未执行。


### 初始化定位的最小对照（2026-10-20，生产未改）

幂等片39362754281/176303d已2/2，30字体观测errorMessage均nil，test/summary/export0，源码编译诊断0，完整原件SHA/CRC和556输入核实。它证明重复偏好公共合同和本次字体流程清除错误消息；不把首次真实模式变化等同于重复，也不代替完整180/设备验收。

剩余hidden原始5/6失败仅发生在第一次准备深字。固定[Readium3.11 ReflowableSpreadView](https://github.com/readium/swift-toolkit/blob/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift)在isSpreadLoaded之后仍延迟pendingLocation恢复，本地字体ready等待扩大该窗口；外部go在isSpreadLoaded=true时不更新pendingLocation。因此最小对照只改原test fixture：真实字体已ready但显式暂停初始定位，先导航到1200th字并证明可见，再放行；原30秒ready+字可见断言不放宽。失败后再采集released/faceReady/readyObserved/settled、native attached/alpha和scrollX/字可见，保留原错误。

只有放行前目标明确可见、放行后文档ready且显示却回到x0、目标字不可见，才支持初始化默认start覆盖新seek；更早失败或旧实现字仍保留都不能套用补丁。首次initialization-pending仅此1项，Vendor/Adapter生产及锁不变；候选仅将pendingLocation更新移到早期loaded判断之前，暂不应用。该实验不是重试字体切换，它在字体变化前区分定位覆盖与实际加载/字体重排故障。


对照的ready信号来自保留的原生FontFaceSet.ready getter；仅对返回的Promise追加显式放行，不用固定短延迟假定字体/布局已完成。其语义依据[W3C CSS Font Loading 3](https://www.w3.org/TR/css-font-loading-3/#font-face-set-ready)：ready等待当前字体加载和相关布局结束，后续文档变化仍可能开始新加载。具体字形/实际字体加载由独立原字体回归继续验证；初始化对照只验证已稳定页面的定位是否被覆盖。


### 宿主启动边界与对照前置修正

39365686520/c9dcba9被Agent取消，原生0项；完整artifact/CRC/SHA和556来源核。原Session最后04:12:47.590启动宿主（wait_for_debugger=1）未返回，stdout0，未进入fixture；不能把37.6分钟写成测试或定位源码失败，也不能唯一归因平台。取消为修正静态前置并止损，记录initialization-pending-39365686520-cancelled.json。

已核[Apple XCTest executionTimeAllowance](https://developer.apple.com/documentation/xctest/xctestcase/executiontimeallowance)用于已执行用例、须启用测试超时；增加它不处理当前无用例宿主阶段。本轮不修改该预算。查[runner-images同Xcode16.4/macOS15相似报告13129](https://github.com/actions/runner-images/issues/13129)，其平台为visionOS，不能搬作当前iOS18.5/Intel根因或照搬降级；维护者也要求原始系统/启动证据。先复用项目有界进程/内存观察，记录App与testmanagerd/debugserver/xctest/xcodebuild，保留原Session，下轮若再启动失败能区分进程是否出现；不盲改编译器/SDK/权限。

对照fixture独立修正：先公开导航至one.xhtml让其进入viewport，再等rAF驱动的font-ready阶段，只查询几何当前WKWebView；失败诊断对隐藏/未准备窗口仅记录native几何，保留原断言/错误/30秒预算，不等待隐藏DOM。生产仍为176303d，Vendor候选不应用。

## 2026-10-20 初始化覆盖的合格对照与最小候选

39370263590/d28feaa原生1项0/1，真实编译0诊断。公开导航目标章节进入viewport，真实FontFaceSet.ready已完成后保持显式屏障，证明char1200可见，再放行初始化；原30秒联合断言失败，当前WK attached/alpha1、released/faceReady/readyObserved/settled均true，x0且原字不可见。完整artifact SHA/CRC与556来源核，支持旧初始化位置覆盖新seek，排除“尚未换字体却归因后续字体替换”的错误边界。原件/报告initialization-pending-39370263590.json，不能将前一轮0执行的Agent取消当作同一失败。

与固定Readium3.11 d82f44f4f05d87add9e22a8b75abbd61dce745dd的ReflowableSpreadView对照：isSpreadLoaded在0.2秒初始化恢复前已true，本地真实字体等待进一步暴露该窗口。只将既有pendingLocation赋值移到该判断前，最新完整位置成为初始化恢复目标；不新增等待或改变任何预算，保持当前d28测试fixture，UPSTREAM登记真实LF摘要。Windows预检后冻结同一输入，rotation-full同job先6项、再完整180、最后严格Release；候选验收仍待执行。
