# 连续视口缩放：可控复现设计

2026-10-23 可控冲突配对方案审阅完成，未实施、零CI。用户已确认保留smoke原样，另设安全/冲突模式；两臂在旧S仍持有时共同封入口，仅指定S/M允许交错，其余请求保持捕获前排队和逐条排空。只改变S相对resize/M的放行顺序，生产guard/原字断言/预算保持；锚点替换、M放弃恢复和原字不可见分层判读，不拿旧smoke当新安全臂。未来本地夹具最多5项运行输入，CI接线/构建复用另审，均未实施。617输入及原件保持，旧full191/192、I6/Release/手机缺口和Build30不变。见[方案与边界](I6_VIEWPORT_CONFLICT_REVIEW.md)。

以下记录保留当时范围，当前审阅结论以上文为准。

2026-10-22 后续已按本页方案实现最小DEBUG准入/逐条排空候选，本地检查通过、零CI；未Swift编译/原生验收。见[实现与状态](I6_SMOKE_ADMISSION.md)，以下审阅/设计保持当时结论。

2026-10-22 安全顺序审阅发现旧宽measure和后续采样未被隔离，原宽度过滤M组不足以保证资格。当前最小修正方案见[单独审阅](I6_SMOKE_SAFE_ORDER_REVIEW.md)，仅设计、未实施、零CI；下文实现/历史实测保持原义。原H1冲突设计不能未经匹配性审阅直接套用新的串行准入。

2026-10-22 Adapter桥修正版仅一轮CI39782692503/65a82618/attempt1：原生编译/链接通过，Linux111及控制器机制6项通过；原视口smoke 0/1（12.506秒），停在缩放前S资格。S实际命中/放行但终结rejected，M未执行；失败后active/tasks/waiters均空。1767/2367现场不足证明具体拒绝分支，clip/documentTop/guard诊断仍缺；旧full根因未证。本轮617运行输入零漂移、未改算法/原断言预算、未重派。原件与断点已保存，旧full191/192、Release/手机缺口和Build30保持。见[本片结果](I6_VIEWPORT_ADAPTER_SMOKE.md)。

以下记录保留其当时范围；最新本轮状态以上文为准。

2026-10-22 原生smoke仅派1轮，9f1c503a/CI39777683114在测试包链接失败，原生/机制0例。5组SDK诊断类型符号证明Adapter typealias未隔离；已作两文件Adapter自有DTO/协议候选修正，本地检查通过、未重新原生验证。未重派CI，不改算法。当前断点见[smoke实际结果](I6_VIEWPORT_SMOKE.md)，以下设计及实现片保留历史状态。

2026-10-22 后续实现状态：用户已授权最小夹具；六个源/摘要文件已接线，默认关闭，仅原单例显式Debug smoke使用。**未派CI、未编译/运行Swift夹具，不能称屏障已实际命中。**本页1–8节保留原设计时状态，当前实现及证据边界见第9节。

2026-10-22。本片仅完成设计和静态审阅：**不实现屏障、不修改定位算法或测试源码、不派CI**。实现、编译、原生复现及根因验证均未完成。设计基线为保存源7048594f，运行输入仍为82b35f76 / CI39759498210的617项。

## 1. 已知事实与待验证假设

旧full39735403242唯一失败是原`testContinuousViewportResizeKeepsOriginalWordAndLiveWebView`首次变宽后的30秒联合等待。旧原件没有缩放前原字及measure决策，不能追认具体根因。后续原字499的观察版与仅撤一个观察await的版本均单例通过；后者11.293秒，同WebView、横竖后原字可见。见[同例对照](I6_VIEWPORT_RESIZE_CONTROL.md)。

源码事实（当前行号，后续按符号核对）：

| 符号与位置 | 实际行为 | 对设计的影响 |
| --- | --- | --- |
| `EPUBInfiniteScrollView.firstVisibleElementLocator` 630–640 | 记epoch/index/revision/localTop；有效缓存直接返回 | 屏障不能假定每次调用都会读DOM；必须证明目标请求经过缓存未命中分支 |
| 同方法646–666 | await真实DOM采样后核所有者、revision/localTop，再写savedAnchor | 返回校验未单独比较尺寸；采样可能跨await交错，但是否发生仍待证 |
| `layoutSubviews` 477–489 | 改尺寸并排入measure；此处不递增viewportRevision | 原尺寸身份不因这一处变化自动失效；不可用强行递增revision来制造/修补实验 |
| `measure` 398–448 | 先记保存锚点，再await测量；恢复须锚点仍相等、revision/localTop仍匹配 | 需要同时观察另一采样是否替换锚点，以及恢复guard究竟哪项变化 |
| `EPUBSpreadView.continuousVisibleAnchorSnapshot` 632–713 | 真实JS计算有界字锚点，返回locator/documentY/documentTop | 不伪造locator、偏移或返回值；JS实际执行时的布局必须有证据 |
| `EPUBNavigatorViewController` 221–226、870–888 | 上层也检查连续视口身份，但内部缓存写入发生在其返回之前 | 必须区分内部锚点已写入与上层结果是否发布，不因上层丢弃就认定无影响 |

**H1（假设，不是已证缺陷）**：请求S在旧尺寸下保存了请求上下文，但其DOM读取延至新尺寸；如果epoch/index/revision/localTop仍相等，结果B可能被接收并覆盖原锚点A，令已开始的measure因`anchorEqual=false`不再恢复A，最终原字不可见。

仅扣住已经计算好的旧结果通常不足以触发H1：它可能仍包含A。故选择“旧请求上下文 + 新布局下的真实读取”，并阻止重排先完成补偿。若真实数据不满足这些条件，判实验未成立，不改值凑失败。

## 2. 唯一实验边界与保留合同

后续若获实现授权，仍只接线原同例、原原创EPUB；不运行前序模式切换、23项、字体组、UI、full或设备Release。不以先前用例污染解释失败；只读前序线索尚无因果证据。

原字offset>100、同一个WebView、挂窗、alpha>0.99、DOM宽差<2、原字Range四边与视口相交、最多12资源视图、先横后竖、原100ms采样及每次30秒等待全部保留。原字最终可见不等于像素完全相等，也不等于整个过渡无瞬态移动。现有样本回竖屏top23.875不得改成零才能算通过。

不清缓存、不手写savedAnchor、不改DOM/scrollY/原Locator、不关闭delegate，不以Task.yield、固定sleep、提高优先级或假定FIFO来抢顺序。所有旧guard与原子提交顺序保持；新增只限被本实例显式安装的Debug测试控制。正常路径无控制器时不新增await，Release不含可安装控制入口，不新增依赖或target。

## 3. 两道原生屏障、一个原始锚点

A是原方法通过现有`engine.captureCurrentPosition()`取得的完整保存Locator。S是同一读者/资源、滚动+600之后的第一个合格新鲜采样请求。M0是变宽后第一个合格的重排测量。均分配本轮nonce、请求ID与递增事件序号；不能只按书名、href或“下一次回调”认领。

| 屏障 | 拟插入点 | 扣住什么 | 明确不做什么 |
| --- | --- | --- | --- |
| S：读取前屏障 | `firstVisibleElementLocator`缓存未命中后，原646行DOM await之前；已保存本请求的epoch/index/revision/localTop与尺寸 | 只暂停一个合格请求，让它保留旧尺寸上下文；原JS尚未执行 | 不暂停MainActor线程，不改采样函数或其返回值；不把缓存命中伪装成S命中 |
| M：提交前屏障组 | `measure`原431行await取得真实result后、原432行所有者guard及后续任何状态写入之前 | 扣住目标资源中符合新布局的M0及并发合格Mi，避免另一measure抢先补偿 | 不重算result，不改变height/anchorY，不跳过原guard，不阻塞其他资源的正常流程 |

M不能只拦一次：ResizeObserver/布局任务可并发进入。控制器记录所有measure的开始、结果、原guard和提交；对目标新布局的合格Mi共同扣住。旧布局或其他资源请求保持原样；若它们先改变了本实验要求保持的revision/localTop/所有者，实验条件失效，留证退出，不能压制它们维持假设。

真实DOM的width/height/scrollY/字锚点元数据从**原有那次JS返回**旁路记录，按请求ID绑定；不另加DOM观察await来建立屏障。M0须有本轮目标新DOM宽（既有样本为874，从本次实际原始窗口尺寸推导，不硬编码机型）及真实anchorY，不能只凭UIKit frame已变就放行S。S也须记录其实际执行尺寸，禁止读一个共享“最后采样”字段来拼接不同请求。

S只在本请求第一次DOM读取前扣留一次；原`documentTop/localTop`校验、最多3次采样及其32ms间隔保留，每次attempt记录同一请求ID下的独立序号。放行后必须收到该请求最终返回/提交的收件，不能把第一次JS结果误当作已写入B。M0/各Mi也分别保留原结果与原guard；不通过新增超时重发其中任一步。

### 准备与放行时间线

1. `mount`完成后、`open`之前登记本实例复合清理，安装控制器并记录原窗口；连续容器创建时即接入该实例，以免漏掉已开始的measure。原章头准备不变。暂停自动滚动为既有capture行为，不引入另一个阅读模式。
2. 在原+600动作前武装S，限定同epoch、当前资源、目标物理localTop、非moving/positioning、ready。通过正常采样调用链认领第一个缓存未命中请求并到达S；若正常调度未产生请求，可由测试经Adapter触发**一次**同一原生采样入口，记录来源为test辅助请求。不得循环补发、清缓存或改返回值。
3. 原滚动准备等待仍要求原`scrollY>500`，另把“S确实已扣住且所有者正确”作为注入准备资格；使用原同一个30秒等待。缓存命中/错资源/过期请求不能算命中；已知不成立立即记夹具失败，而非耗满后重试。
4. S暂停时，原方法原来的capture产生A；它可来自另一次真实采样或已验证的旧布局缓存。S只能认领一次，其余请求不被S扣住。A必须能关联到真实旧尺寸采样的请求记录，且有完整Locator及旧视口几何；缓存没有可追溯来源就不能宣称准备合格。原3秒capture预算不延长。
5. 在原第一次横屏等待的一个30秒截止时间内编排下列顺序。窗口真实变宽；M0先保存A、读取新布局result后停在M。确认当前保存锚点仍A，且S原epoch/index/revision/localTop仍有效，无别的测量已先补偿、无未归属旧measure在途。
6. **冲突顺序**：只放行S去执行原JS，等待S的真实“原guard判读/缓存提交或拒绝”收件。要求记录B及A→B的实际变化；B若为空或等于A，不能强行替换，H1注入未成立。放行不是任务已运行的证明。
7. 再放行M0，等待其原`mayRestoreAnchor`各子条件和实际提交完成记录；然后将M组设为draining，放行其余Mi和后续正常请求。若有其他路径恢复A，也必须记录，不能继续扣住它来制造失败。
8. 所有屏障放行/受控请求收件与原可见性联合条件都须在上述**同一个**横屏等待期限内满足；不重启30秒。之后原竖屏恢复及其原30秒等待保持，竖屏不再注入。本片不实际执行以上步骤。

拟匹配的**安全顺序对照**使用相同Hook、S/A和M资格，只把S放行移到窗口变宽前，待其完成再变宽/放行M组。须记录S读取时仍为旧DOM尺寸、S完成后保存锚点仍为A、随后M0确实捕获A；不满足则不是匹配对照。安全/冲突每个选项各运行原方法一次，不在方法内循环重试；原生次数及是否共用一次准备需另行明确范围，本设计不授权执行。

安全顺序也使用第一个横屏等待的同一30秒时钟：其状态机先处理S完成再执行一次真实resize，而不是在等待开始前额外等一个30秒。冲突顺序先resize，再按M就绪→S完成→M完成编排。原联合条件不改，只增加“实验已经按顺序放行并收齐”的准备资格，防止屏障没生效却直接拿到绿灯。

“等待收件”是有截止时间的状态推进：原100ms轮询读取已到回执、同步发出下一许可；不能在谓词内部无限await屏障entered/finished而绕过30秒检查，也不新增独立等待时钟。原DOM谓词所用JS仍沿用原路径；若底层WebKit求值本身不返回，按现有失败/运行取消留证及关闭清理处理，不宣称控制器能强制终止任意WebKit执行。

## 4. 有界、可取消、不会遗漏放行的控制器

控制器由该测试实例持有，运行在MainActor；无全局单例或跨reader共享状态。Native事件通过Adapter内部Debug桥接，UI/ReadingInterfaces/Core不接触Readium类型。事件载荷为有界、可Sendable的身份/几何值；不传递UI对象到非隔离回调，不用`@unchecked Sendable`或新增warning压制。

| 状态/事件 | 必须执行的转换 |
| --- | --- |
| armed + 合格进入 | 先存唯一waiter/ID并发布entered收件，再真正挂起；不合格请求旁路 |
| held + release(id) | 先移除waiter、登记run结果，再resume一次；等finished收件才推进下阶段 |
| release先于enter | 对该ID保存已放行状态，后到者立即获得run，不能丢信号 |
| draining | 当前所有Mi明确放行；后续匹配请求不再挂起 |
| abort/取消/关闭/超限 | 先进入不可逆aborted；全部waiter得到abort，后到者立即abort；禁止当作普通run放行 |
| 重复release/重复cancel/晚回调 | 保留幂等终态，只记重复事件，绝不再次resume |

选用CheckedContinuation及显式取消结果，不照搬成熟fixture的UnsafeContinuation。不依赖`Task.cancel()`自动释放continuation；注册前检查取消，注册/取消竞态均汇入同一终态，取消处理不得阻塞主线程。非MainActor取消通知只把事件转交控制器，进入时再次核取消/终态，避免“取消先到、注册后永久悬挂”。不使用信号量、`DispatchQueue.main.sync`或XCTest同步wait阻塞执行器。

M组上限32个扣留请求、关键事件上限128条；达到上限记fixture-overflow并abort全部waiter，不静默丢弃最旧continuation/关键证据。上限不是业务容错，后续不得为拿绿随意增大。证据不记录小说正文/全段文本，仅记录当前原创fixture的Locator标识或其指纹及原字范围。

## 5. 放行与清理：先使提交失效，再恢复窗口

复合清理在mount之后立即登记，须比mount原清理更晚登记以按XCTest LIFO先执行。它负责屏障，不改全局mount对其他用例的行为。受控方法原112行的裸frame teardown与113行的裸frame defer须一并由此复合清理替代：不能再较晚登记一个只恢复frame的teardown，也不能先执行裸frame defer，否则屏障仍武装时会再触发measure。只替换本方法的清理接线，不修改其他测试的mount。

正常显式结束、方法defer同步部分及XCTest teardown共用一个幂等cleanup状态机：

1. 所有abort/取消/关闭/超限均进入同一终止入口；同步切为aborting、禁止新认领/停止注入，取消测试自持任务。清理开始后不再产生run许可。
2. 同步关闭本reader，使原open请求与SDK epoch/slot失效；不清数据库、不影响别的窗口/reader。
3. 对所有S/M waiter以abort恰好resume一次，保留原始失败及退出原因；不为“赶紧收工”把它们普通放行去提交旧位置。
4. 异步teardown有界等待已登记请求finished/aborted收件、计数归零，核对0 waiter、0受控任务、没有关闭后缓存提交。最多3秒清理上限，单独记录；它不加给30秒定位等待或3秒capture、不重置原断言预算，不为业务成功提供额外机会。超时仍是夹具失败，不能写通过或吞错。
5. 先失效/abort后才恢复本窗口原frame并layout；拆除控制入口。mount原清理随后继续hide/root移除/恢复前一个key window。局部defer只做同步abort-close-恢复，真正drain及检查仍在生命周期teardown。

Swift的任务取消是合作式；不能在teardown无限await某个任务.value，或假设cancel会唤醒WebKit回调。只等有界收件，卡住必须保留残留ID/阶段/原始失败，禁止自动重跑。进程崩溃可能不执行teardown：该原生运行应失败并保留xcresult，不宣称已清理；后续不能重用其App进程作为健康证据。

## 6. 证据与结果判读

每条记录含本轮nonce、reader/epoch/resource/WebView身份、S/A/M请求ID、事件序号、caller来源、native与DOM尺寸、revision/localTop、缓存命中/未命中、原Locator指纹/原字坐标、原guard逐项结果、锚点提交前后、M的desiredLocal及实际应用。入口/返回/提交均有收件；完整日志保留原顺序，不以尾部截图代替。每个原wait输出截止时间、采样次数、首末谓词；准备资格、原业务断言和清理结果分开记。

| 实际证据 | 分类与允许结论 |
| --- | --- |
| S缓存早退/错ID、M未命中、DOM未真正变宽、revision/localTop提前改变，或已有其他补偿抢先完成 | 夹具准备不成立；不归因产品、不称负对照，不补发凑次数 |
| S真实返回B且替换A；M0原anchorEqual变false；全部放行后原字在原30秒内仍不可见；安全顺序原断言通过 | 支持H1所定义的可控竞态路径；先保存原件，再另行界定最小修复，**不等于已证明旧full就是这条路径** |
| B实际出现但被原guard拒绝，且所有资格/拒绝原因完整 | 这条受控路径被现有保护拦下；若是所有者/物理位置被别的事件改变，则回到准备不成立，不能借此宣称尺寸保护已存在 |
| B替换A、M0跳过，但原字最终仍可见或其他路径恢复了A | 观察到状态交错，未复现原故障；不把内部状态变化直接升格为阅读缺陷 |
| 安全/冲突均通过但注入不合格 | 无结论，不再自然重放；修订准备设计，不改算法 |
| 安全顺序也失败 | 对照不合格或独立故障；先留证定位，不继续比较新旧算法 |
| 缺原始收件、continuation残留、cleanup超时或晚提交 | 夹具失败，即使可见性曾通过也不验收，不删断言掩盖 |

实验准备不成立仍须作为失败报告，不能用XCTSkip改成成功门槛。失败只观察到一次不证明稳定复现；匹配的新旧样本只支持对应样本。若以后要认定旧full根因，仍需要实际命中相同的“请求尺寸→S提交→锚点替换→恢复被过滤→原字不可见”链路；旧原件缺失的信息不能补造。

## 7. 后续实现的最大接线范围（本轮未改）

1. `Tests/iOS/ReaderRenderingTests.swift`：本同例私有控制状态机/证据/生命周期清理，不增测试target、不改其余方法。
2. `Packages/XianxiaReading/Sources/ReadiumAdapter/ReadiumReaderEngine.swift`：仅实例级内部Debug桥；ReadingInterfaces及App不扩协议。
3. `Vendor/.../EPUBNavigatorViewController.swift`：Debug桥把控制交给现有连续容器，关闭时释放；正式公开阅读API不变。
4. `Vendor/.../EPUBInfiniteScrollView.swift`：上述S/M测试插点及同步收件，默认无控制器不新增await、不改原guard/结果发布/提交顺序。
5. `Vendor/.../EPUBSpreadView.swift`：仅本请求的Debug元数据旁路，沿用原有JS求值；不改locator算法、返回的业务值或JS Promise语义。
6. `Vendor/ReadiumToolkit/UPSTREAM.json`：实际实现后更新对应审阅摘要；工程、依赖/锁、资源及架构登记无新归属/导入时不动。

此列表是未来实现上限，不是已存在API或已通过编译。若需要更多文件、新target、改生产await或更多业务断言，先停下解释偏移。下一步若获授权应先实现最小fixture、检查命中/取消/默认关闭路径，再明确原生匹配对照范围；不得凭本设计直接派CI、宣称修复或合并旧191/192为全绿。

## 8. 参考与适用取舍

- [Swift SE-0306](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)：await处可交错；不假定MainActor事务跨await保持。适用于当前Swift6.1.2；只用已实现的actor规则，不引入较新执行器特性。
- [Swift SE-0300](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0300-continuation.md)：每条路径必须恰好resume一次，resume不等于主体已执行。只借语义，不复制文中旧版取消API写法。
- [Async Algorithms1.0.4 Gate](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/Gate.swift)与[GatedSequence](https://github.com/apple/swift-async-algorithms/blob/1.0.4/Tests/AsyncAlgorithmsTests/Support/GatedSequence.swift)：显式推进，包含先open后enter的许可。该版本tools5.8；只借fixture模式，不加包，不照搬其单waiter/UnsafeContinuation或对重复等待的处理，M组须支持多waiter和取消。
- [Apple addTeardownBlock](https://developer.apple.com/documentation/xctest/xctestcase/addteardownblock(_:)-2guon)及[生命周期说明](https://developer.apple.com/documentation/xctest/set-up-and-tear-down-state-in-your-tests?changes=_1)：按逆注册顺序串行清理；适用现有已编译的异步teardown，不假设崩溃也能执行。
- 本地Readium3.11锁定源`EPUBSpreadView.evaluateScript`254–268使用带completion的evaluateJavaScript并封装continuation；没有在此调用callAsyncJavaScript。因此不通过塞一个JS Promise冒充可暂停的原始对象结果，避免重演“屏障未命中却已通过”。本项目连续容器是本地扩展，不能把上游分页重载当作此处修复。

本片只核文档/源码合同和617输入保持；无fixture实现、无Swift编译、无新增测试执行、无CI。旧full191/192、Release/手机未验收和最后交付Build30全部保持。

## 9. 最小夹具实现片（2026-10-22，尚待原生验证）

本片仅实现安全顺序的夹具检查，不实现/执行H1冲突顺序，不增加测试方法或改CI选择器。运行时由原单例的测试进程环境变量`XIANXIA_VIEWPORT_FIXTURE=smoke`显式启用；未设置时保持原路径，未知非空值失败，不能静默回到普通单例。此开关尚未接CI/新scheme，不能凭源码存在就宣称可远程运行。

实际范围仍为第7节六文件：Adapter内部实例桥与一次辅助采样入口；Navigator在连续容器创建、挂载前传递控制器；InfiniteScroll的S/M与真实提交收件；Spread同次JS的width/height/scrollY元数据；原单例私有控制器/机制检查/生命周期清理；Vendor摘要及3文件SHA256。ReadingInterfaces、UI、Core、隔离模块、项目、依赖锁、资源、脚本/工作流没有修改。

- S只认领+600后的实际物理位置、当前资源的一个缓存未命中请求。必要时只补一次Adapter辅助调用，以TaskLocal标记来源；原capture另标为original-capture，A须追溯到同次真实旧布局采样/缓存来源。+600请求值和实际值均保留，不强行纠正坐标。
- 安全顺序在原第一次30秒/100ms谓词内分阶段推进：S放行→实际finished及旧宽/原A不变→真实resize→新DOM宽匹配的M组命中→M0放行及原guard回执→其余Mi显式drain。未收到结束回执不能通过；M0的原owner/anchor/revision/local条件不成立时归夹具未合格。原竖屏等待、offset>100、同WebView/挂窗/alpha、DOM宽/原字Range可见、12资源和截屏断言保留。S原3次/32ms和capture原3秒不变。
- CheckedContinuation由MainActor管理；先移除再resume，重复release幂等，先release后enter保存许可，M组支持多waiter。取消前/后注册均检查；终止先关闭/使所有者失效，再给abort；关闭后的晚进入不能得到run。32waiter/128事件超限直接失败并清理，不丢continuation来拿绿。
- 只在本同例启用六项控制器机制检查：先放行后进入、已挂起后放行/重复放行、挂起时取消、注册前取消、两个M共同drain、关闭后晚进入。它们是待执行的Swift代码，**本片没有运行这些检查**；合成事件也不替代真实SDK S/M收件。各fixture expectation的3秒只限机制检查；清理另有3秒截止，不延长原业务30秒或capture3秒。
- mount后/open前登记复合teardown，显式defer共用幂等清理；fixture启用时不再登记两处裸frame清理。取消自持任务，关闭reader/释放abort后才恢复frame、移除安装入口；teardown有界检查活动请求/任务/waiter归零和晚提交，输出完整事件日志及XCTest附件。局部defer不是唯一清理保证。

本地解析器不支持类内条件成员声明，初检如实失败并保留原日志。已改成文件级Debug扩展，未扩充语法白名单/架构例外。Release只留下三个私有nil `AnyObject`存储槽及内部默认nil元数据参数，没有安装器、控制器类型或新增await；元数据JS仅显式安装时附加。逐文件去除Debug分支并对这些明确的空存储/空插值/未使用参数做归一化后，5个Swift文件的Release业务逻辑与f167a752相同。该文本对照不是编译/ABI或运行验收。

本片验证：`check_repository.py --swift-syntax`通过7类静态检查及484文件语法，新增诊断0，原Vendor54限制保持；13项相关Python检查中12通过、1 POSIX跳过。原断言/预算与非目标测试体的源差异另核。Windows无Swift编译器，Docker Linux引擎实际不可用（保留exit1），未启动容器/重置工具。Swift编译、机制检查实际运行、SDK屏障命中/放行/取消、可控复现均未验收；零CI，旧full191/192及Release/手机缺口保持，无新IPA，最后交付Build30。

后续必须先对这一个smoke选择取得真实编译、6项机制检查和S/M收件/清理原件，再讨论冲突顺序；不得跳过夹具命中资格直接改算法、扩大组数或宣称根因已证。当前用户未授权CI，本片保存后停止。权威记录：[实现片审计](ValidationLogs/project-isolation-i6-viewport-fixture.json)，本地恢复`build/maintenance/I6-viewport-fixture-20261022/final-checkpoint.json`。

补充参考：[Swift SE-0311 TaskLocal](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0311-task-locals.md)用于逐任务来源，不用共享last-result字段；[Swift6.1.2取消实现](https://github.com/swiftlang/swift/blob/swift-6.1.2-RELEASE/stdlib/public/Concurrency/TaskCancellation.swift)核对operation/handler顺序与并发通知，只采用已实现的语义。前述Gate只借显式许可模式，不复制UnsafeContinuation。
