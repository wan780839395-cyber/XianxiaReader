# 架构与技术决策

2026-10-23 本地配对夹具已实现、零CI：保留原smoke，另设paired-safe/conflict，共同提前封入口，仅指定S/M交错，实际退出后逐条排空；只补3项M标量诊断及本地回执正反例。5项运行输入变化，其余612保持；Release代码/原JS/S诊断/原guard/断言预算保持。484语法通过（非编译），工具16通过/1 POSIX跳过；新Swift机制及原生未执行。同构建来源核验与CI接线后续，当前比较不授予配对验收。旧smoke1/1只属旧源，旧full191/192与I6/Release/手机缺口、Build30保持。见[实现与验证边界](Documentation/I6_VIEWPORT_PAIR_FIXTURE.md)。

以下记录保留各自当时范围，本轮实现以上文为准。

2026-10-23 可控冲突配对方案审阅完成，未实施、零CI。用户已确认保留smoke原样，另设安全/冲突模式；两臂在旧S仍持有时共同封入口，仅指定S/M允许交错，其余请求保持捕获前排队和逐条排空。只改变S相对resize/M的放行顺序，生产guard/原字断言/预算保持；锚点替换、M放弃恢复和原字不可见分层判读，不拿旧smoke当新安全臂。未来本地夹具最多5项运行输入，CI接线/构建复用另审，均未实施。617输入及原件保持，旧full191/192、I6/Release/手机缺口和Build30不变。见[方案与边界](Documentation/I6_VIEWPORT_CONFLICT_REVIEW.md)。

以下记录保留当时范围，当前审阅结论以上文为准。

2026-10-23 统一准入/逐条排空修正版仅一轮CI39806769382/2a9fdfb5/attempt1：原生编译、机制6组、原smoke单例1/1（17.851秒）及回执校验通过。主M原7项guard全true，真实退出后另一M及sample逐条准入；79事件，五类清理集合全空。S首采样committed，原字499横/竖均可见。617输入/算法/S诊断/原断言预算保持；未重跑或执行full/Release，旧191/192与I6/手机缺口、Build30不变。见[本轮结果](Documentation/I6_SMOKE_ADMISSION_NATIVE.md)。

以下保留当时实现/验证范围，本轮结果以上文为准。

2026-10-22 smoke统一准入/逐条排空候选已实现，本地检查通过，零CI：捕获前管理同reader/epoch的measure与sample；主M实际退出后其余请求逐条新捕获，许可按入场/提交点区分，取消清理跟踪至真实终结。只改5项运行输入，其余612保持；Release投影、原脚本、S诊断、定位算法、断言及预算保持。484语法/静态通过、14工具通过/1 POSIX跳过；未Swift编译/原生运行，旧smoke0/1、full191/192、I6/Release/手机缺口及Build30不变。见[本片实现与验证边界](Documentation/I6_SMOKE_ADMISSION.md)。

以下历史记录保留其当时状态，新候选结果以上文为准。

2026-10-22 smoke安全顺序审阅完成，未实施、零CI：已证旧宽M1绕过屏障使revision/local改变，后续native采样又改写锚点指纹；held M2的原恢复guard因而失效。最小方案是在捕获上下文前，对受控reader/epoch的measure/sample统一准入，主M实际完成后逐条新捕获排空；保留原提交屏障/guard、S诊断、断言及全部预算。不能只扩大旧结果屏障或放宽guard。617运行输入保持，旧smoke0/1及full191/192未变。见[审阅与方案](Documentation/I6_SMOKE_SAFE_ORDER_REVIEW.md)。

2026-10-22 新S诊断仅一轮CI39793517830/2274ba25/attempt1：原生编译/链接、机制6项及Linux111工具通过；smoke 0/1（10.318秒），失败在M资格。本次S clipTop0/documentTop2367与期望一致，首采样committed，未出现第三次，旧S拒绝原因仍未证。未持有过渡measure和后续native采样改变版本/锚点，held M原恢复guard为false；失败后清理全空。617运行输入/算法/原断言预算保持，未重派，旧full191/192与Release/手机缺口、Build30保持。见[本轮结果](Documentation/I6_VIEWPORT_S_NATIVE.md)。

2026-10-22 S rejected被动诊断切片完成，零CI：旧同请求attempt0/1/2可证明前两次有效snapshot后documentTop不匹配，第三次终止原因仍缺。只补两Swift DEBUG诊断（冻结clip/frame、同次documentTop、逐项guard观察/实际reason）及两项Vendor摘要，原JS/await/算法/测试/断言预算保持；其余614运行输入不变。484语法/静态及14工具通过/1 POSIX跳过，未编译/原生运行。不能称S已通过或旧full根因已证，旧191/192及Release/手机缺口、Build30保持。见[诊断与判读](Documentation/I6_VIEWPORT_S_DIAGNOSTICS.md)。

2026-10-22 Adapter桥修正版仅一轮CI39782692503/65a82618/attempt1：原生编译/链接通过，Linux111及控制器机制6项通过；原视口smoke 0/1（12.506秒），停在缩放前S资格。S实际命中/放行但终结rejected，M未执行；失败后active/tasks/waiters均空。1767/2367现场不足证明具体拒绝分支，clip/documentTop/guard诊断仍缺；旧full根因未证。本轮617运行输入零漂移、未改算法/原断言预算、未重派。原件与断点已保存，旧full191/192、Release/手机缺口和Build30保持。见[本片结果](Documentation/I6_VIEWPORT_ADAPTER_SMOKE.md)。

2026-10-22 smoke唯一CI已收口：9f1c503a/39777683114/attempt1，Linux111通过，原生准备/构建819秒后测试包链接失败（5组SDK诊断类型符号），原生/机制执行0。原因是夹具Adapter typealias未建立自有类型；已修2文件Debug桥候选，484语法/静态及本地14工具通过/1 POSIX跳过，尚未重新编译/原生验证。未重派、算法/原断言预算保持。旧full191/192、Release/手机缺口和Build30保持。见[结果与断点](Documentation/I6_VIEWPORT_SMOKE.md)。

2026-10-22 连续视口最小Debug夹具已接线，默认关闭，仅原单例smoke检查S/M命中、放行回执和取消/关闭清理；6源/摘要文件内完成，原断言/预算与定位算法保留。484语法/静态检查通过（非编译），相关Python12通过/1 POSIX跳过。没有Swift编译或夹具实际运行，不能写屏障已命中；零CI，旧full191/192及Release/手机缺口保持，最后交付Build30。见[实现与验证边界](Documentation/I6_VIEWPORT_REPRODUCTION_DESIGN.md)第9节。

2026-10-22 连续视口可控复现设计已完成，尚未实施：只检验“旧尺寸请求跨到新DOM读取后，是否覆盖A并令重排放弃恢复”的假设。设计明确缓存未命中采样屏障、并发测量提交屏障组、放行回执、关闭失效后清理，以及准备不成立/状态交错/原字故障的判读。原断言、预算及617运行输入保持；零CI、零源码/测试修改，旧full191/192与Release/手机未验收保持，最后交付Build30。见[可控复现设计](Documentation/I6_VIEWPORT_REPRODUCTION_DESIGN.md)。

2026-10-22 连续视口同例对照已保存：仅撤指定缩放前DOM观察await，82b35f76/CI39759498210原单例1/1（11.293秒），原499字在横/竖完成时均可见、补偿实际生效；before DOM为null，不伪造前置证据。其他616运行输入及原断言/预算不变。旧故障未复现、根因未证，不称已修复；用户决定下一轮先做无CI可控复现设计，本轮不追加实验。旧full191/192、Release未执行、最后交付Build30保持。见[本片结果与断点](Documentation/I6_VIEWPORT_RESIZE_CONTROL.md)。

2026-10-22 连续视口缩放诊断本片已保存：b618ca86/CI39754777198原单例1/1（20.730秒），前后原字499可见、同WebView、重排补偿记录齐；旧失败未复现，根因未证，定位算法不改。首轮探针编译错误已单独留证；共2轮CI、实际方法仅执行1次。用户决定本轮到此、下一轮仅撤去一个缩放前DOM观察await作同例对照，patch未应用，不追加CI。旧full191/192、Release未执行和最后交付Build30保持。见[本片证据与断点](Documentation/I6_VIEWPORT_RESIZE.md)。

2026-10-22 I6最终full已完成一次，源77eebf40/CI39735403242/Build31：192全部执行，191通过、1失败、0跳过（集成162/163、UI29/29）。六模块68、两平台Core各137/TXT Release各4、Linux109工具通过；模拟器编译通过。唯一失败为连续视口变宽后的原字/WebView联合等待，缺缩放前原锚点及子条件诊断，未证明根因或修复。test65、summary/export/recording0；Release被阻止、未执行，无新IPA，最后交付仍Build30。无额外原生预检/重跑，完整原件已核；用户已决定本轮保存完整断点，下一轮只查此单例；本轮不追加诊断或CI。I6未通过，不进入新功能。 见[本轮结果与下一实验](Documentation/I6_FINAL_ACCEPTANCE.md)。以下I6d等为历史阶段记录。

2026-10-22 I6d只复核验收与剩余边界，156第一方Swift/25区域/26图节点/2精确例外保持，617运行输入无变化。Reader宿主广泛AppServices、App批次/呈现与同target UI类型访问仍明确登记，静态守卫不等于完整类型隔离；不为形式增加target。六模块合同分项可引用，原生共享顺序及发布验收仍需当前192/Release；本轮不执行。见[最终范围](Documentation/I6_FINAL_ACCEPTANCE_SCOPE.md)。

2026-10-22 I6c未改变生产依赖或异步顺序，仅修初始化关闭测试的探针生命周期与显式字体门。原生分页记录证明实例hook随初始JS包装对象丢失，prototype后备捕获实际读取；在初始化仍pending时，分页/连续原关闭断言全部通过。原隔离/定位行为保持，完整验收仍待I6下一片。见[原因与证据](Documentation/I6_INITIALIZATION_CLOSE.md)。

2026-10-22 I6b未调整模块或生产行为，只增加精确23项原生入口与严格结果门禁。源075c2cc真实编译通过，22/23，初始化关闭用例准备探针失败、关闭合同未验到；不能以其他定位用例通过宣称I6整体验收。所有既有隔离/await顺序/定位修复保持。见[I6b实际结果](Documentation/I6_POSITION_ACCEPTANCE.md)；后续仅诊断该case，以下I6a等段为历史记录。

2026-10-22 I6a边界/证据审计及两处发布门禁修补完成：原始合同与传递输入核实后，6个独立模块只可分项引用，不能相加成同源验收。补齐完整artifact的设置/导入/搜索证据目录，并在Release前增加full192全部通过、零失败/跳过摘要门禁。105项本地工具98通过/7 POSIX跳过，语法484无新增诊断（非编译）；首旧夹具失败及修正保留。仅5个CI/tooling输入变化，其余612及全部生产Swift/原生测试/工程/资源/锁保持。Reader宿主AppServices、UI/批次桥接和字体iOS依赖仍是边界限制；下一片只做原19位置+4加载=23项，不复用旧28项UI配置。当前零CI派发、未跑原生/完整192/Release/手机、无新App IPA，I6整体未验收。详见[审计与精确门槛](Documentation/I6_ACCEPTANCE_AUDIT.md)及ValidationLogs/project-isolation-i6-audit.json。

2026-10-22 I5c搜索本片完成：ReaderSearch真实独立包拥有原搜索DTO/可选协议与请求/分页/取消/选择编排，只依赖Core及Foundation/Combine。App与ReadingInterfaces保留typealias兼容，无新异步层，原12await、函数正文、发布与清理顺序不变。最终53f7e1f2 / CI39715718761独立macOS8/8、原生13/13，包及App/测试接线真实编译通过。搜索界面/输入、Readium3.11安全搜索服务/限制、ReaderPositions及书库/导入/字体/会话/Core/Adapter/Vendor/资源/锁不改；原生测试正文不改。完整163+29=192、Core137全组、Release/设备/手机未跑，无新IPA，最后交付Build30。详见Documentation/SEARCH_ISOLATION.md与ValidationLogs/project-isolation-i5-search.json。

2026-10-22 I5b导入事务本片完成：BookImports为真实Foundation/Core独立包，拥有原EPUB/TXT导入服务与元数据合同；App/ReadingInterfaces以typealias保留旧调用名称/协议身份，无async包装、原11await与服务body保持。最终c8b53e38 / CI39712813755独立macOS8/8、原生14/14，包及App/测试接线编译通过。App批次UI/Task/picker/FontInbox、书库、搜索及阅读/字体/定位/会话/Core/Adapter/Vendor/资源/锁保持；批次呈现仍在App，不能称全部导入编排或全项目已隔离。完整163+29=192/Core137全组/Release/设备/手机未跑，无新IPA，最后交付Build30。搜索后续。详见Documentation/IMPORT_ISOLATION.md及ValidationLogs/project-isolation-i5-import.json。

2026-10-22 I5a书库本片完成：LibraryShelf真实Foundation/Core包拥有同步列表、刷新身份及提交合并，窄仓库不暴露导入/搜索/位置写入。App组装原引擎/导入器，书库不再持有AppServices/创建Readium；原await、导入/搜索流程、Reader/R1/R2/R3/R4及定位/字体保持。最终1532b863 / CI39707770264独立6/6、原17+新增延迟初始化1=18/18，包和App/测试真实编译通过。书库UI仍同App target，特定类型静态检查不等于完整类型隔离。完整163+29=192/Release/设备/手机未跑，无新IPA，最后交付Build30；导入/搜索留后续。见Documentation/LIBRARY_ISOLATION.md和ValidationLogs/project-isolation-i5-library.json。

2026-10-22 R4b：ReaderSessions的ReaderSessionLifecycle拥有打开/重试/关闭顺序，类型化Host保持SDK/领域值不透明；App/ReaderSessionHost只是现有方法值和同步应用，VM用一次调用上下文的绑定方法值入口避免async转发/Task包装，同时保留原接收者生命期。原7打开await/检查位置、章节书签同步发布、字体降级、取消与普通失败、retry清理/清错、close最终位置后失效均保持。SQLite actor的同步方法不能直接取值，现经已有BookRepository async协议要求取得函数值，不改actor实现；同型桥接合同已加入。最终15+13及实际原生编译通过，5个精确例外不增加，静态145文件/19区域/20节点。详见[本片设计](Documentation/READER_SESSION_LIFECYCLE_ISOLATION.md)及[R4b原始结果](Documentation/ValidationLogs/project-isolation-r4b.json)。

2026-10-22 R4a：App → ReaderSessions → Foundation，真实SwiftPM产品已接入XcodeGen并实际编译。包拥有started/request/book身份与同步accept门；App每次open绑定owner，完整位置还校验book，迟到写入只过滤错误发布。engine.close最后位置先接收，随后invalidate；原Task写入和全部原await顺序保留，字体失败allowReopening保留旧owner直到下一次begin。原生同机旧1项负对照/候选13项、包6项通过；没有新增生产await，R4b异步编排后续。5个精确依赖例外不增加，静态142文件/19区域/20节点。详细合同见[会话隔离](Documentation/READER_SESSION_ISOLATION.md)与[R4a原始结果](Documentation/ValidationLogs/project-isolation-r4a.json)。

2026-10-21重复定位本片只修测试渲染边界，未改生产或引入新异步生产层。原go/字符坐标可先于截图像素生效；当前挂窗WebView/alpha正确时即时drawHierarchy也可白，即使返回true。测试在原坐标断言之后用WK afterScreenUpdates=true纳入pending updates，再验实际窗口非白和字/外层仍不变；viewport与生产同样扣contentInset。9aac4d / CI39619940734真实编译、原单例1/1。原即时图保留而不当渲染完成证明；手机瞬态/精确GPU时序未验。分页bootstrap及R1/R2/R3保持；下一独立片R4。见[权威结果](Documentation/ValidationLogs/repeated-seek-snapshot-boundary.json)。

2026-10-21连续返回专项：生产、Readium分页bootstrap和R1/R2/R3模块均保持，未增加异步生产层。e234b2b只强化原测试准备为本次initialY+600真实完成；CI39607326744原单例1/1、原生编译通过，原返回3px/30秒与截图后观察保留。诊断样本完整字符/viewport偏移与实际DOM返回一致，旧失败缺before不能追认根因。后续重复seek坐标虽过、原生截图空白（诊断旧版同样），可见性未验收；R4未开始。详见[本片结果](Documentation/ValidationLogs/continuous-return-preparation.json)与READER_POSITION_ISOLATION。

2026-10-21 Readium3.11重排分页候选沿用已有连续模式的原生bootstrap：WK didFinish/真实viewport和Readium脚本就绪后只启动同一完整初始化一次，字体与pending完整Locator恢复完成后才显示和上报；固定布局、关闭取消、位置guard及连续JS保持。候选运行源0de44ba，仅SpreadView和UPSTREAM相对控制基线变化，原生编译通过、加载屏障对照有效；整组仍5/6，原例后续连续返回981失败，不能当作全定位验收。R4未开始，下一轮按用户选择单查连续返回；连续语句/await次序保持不等于已排除前序分页的运行时影响。详见[专项原始结果](Documentation/ValidationLogs/epub-native-readiness-control.json)与READER_POSITION_ISOLATION。

以下保留各自源与日期的历史记录；当前只以本段及HANDOFF为准。

R3b本片完成（2026-10-21）：现有ReaderPositions接管显式保存的捕获、原预算等待、写库、错误与同步结果发布，App只提供原引擎/仓库的窄桥接；每个已接收进度事件的原Task写入保持。实际源421a5786e2be65baf661bc889c166ac8f22aff41 / [CI39580846569](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39580846569)，独立16/16（原6+新增10）、原iOS定向13/13、Linux工具71/71。导航/返回点与字体导入重开事务、原flush顺序、Core/Vendor/锁及原测试保持。下一片R3导航/返回点；R3整体和全项目隔离尚未完成。未跑完整188、设备Release或手机，无新IPA，最后交付仍Build30。详见READER_POSITION_ISOLATION及ValidationLogs/project-isolation-r3b.json。

以下为各自源与阶段的历史记录，当前断点以本段及HANDOFF为准。

R3a本片完成（2026-10-21）：独立ReaderPositions Foundation包接管完整位置、显式保存身份/失效和保存错误；原捕获/写库await、预算及同步发布顺序保留。实际源755b428a60143d8f649372e6c545cc1e03f82ecb / CI39573863939，macOS独立6/6、原iOS定向13/13、Linux工具71/71；双模式六字体/EPUB/TXT锚点及同宽分页writer回归通过。首轮Core产品接线规划失败已留证并改用既有ReaderSettings包模式。R3捕获/持久化编排和导航/返回点后续继续；完整188、设备Release、手机未验，无新IPA。



2026-10-21最新：分页字体回章头缺陷定向收口，CI39561815911同fixture旧1608→0失败、新1608→1608原字可见且无位置写入，实际回调与536+536输入已核。首组屏障进度污染失败保留，生产仍9bb6c86，原断言/预算不改。下一独立切片R3，尚未实施；完整188/设备Release/手机未做、无新IPA。全项目隔离未完成；详见HANDOFF与ValidationLogs/paged-font-control-39561815911.json。

定位维护边界（2026-10-21）：无限连续canonical DOM seek内部消费完整字锚点及viewportOffset，防止内外层定位目标不同；生产仅ReflowableSpreadView及Vendor摘要变化，未提取R3。直接控制与连续字体检查通过，整组5/6、分页字体失败仍阻塞发布，因果未定；不把该结果写成R3或整体位置验收。详见HANDOFF及ValidationLogs/continuous-offset-39456749155.json。

## 当前维护边界（2026-10-20，I0/I1/I2完成，I3起待实施）

ReaderSettings保持Core-only独立包，原设置7项合同保留；ReaderFonts是XianxiaReading内已实际接线/编译的target，只依赖ReadingInterfaces/Core，拥有目录、资源/已安装ID、选中判断、busy/message与请求身份。App转发通知并保留原导入/预览/Bundle/picker和完整锚点/引擎重开；原await加载后在调用方核会话、同步提交并应用，不为纯提取额外包装async prepare。R2源410343b/39418977905真实53/53、0源码诊断，旧失败/A-B及未定时序风险独立保留。

当前133 Swift源/15区域/16图节点/4包图条目（含Vendor），5个精确import例外；check_architecture解析import、SwiftPM/XcodeGen依赖/源码归属并拒绝越界和循环。23项边界正反例随Linux62/62工具通过，Windows59通过3既有POSIX跳过，456语法新增0/54既有限制。语法不代替编译，静态守卫仍不能隔离同一个App target内全部类型；3个具体适配组装依赖待I5消除，2个真实Readium fixture例外单列。

原151集成增加7字体合同成为158，UI仍29，总187；完整发布、原生动态/手机、严格设备Release留I6。R3/I6须单独复核断言后的连续锚点诊断不匹配（改前也有），不从53项通过推出后续每一帧均稳定。R2未做位置算法/Readium修复，字体逻辑仍通过iOS验证，不宣称已有无App/macOS字体入口。设计/参考/证据见READER_FONT_ISOLATION、FAST_VALIDATION及ValidationLogs/project-isolation-r2.json；下一片先定义R3合同。

## R1设置持久化边界（Build30软件门槛通过，手机待验）

AppServices共享ReaderSettingsPersistence，通过ReaderSettingsStorage四方法接口调用既有BookFileStore。外观/手感分别有序提交，完成结果过滤最新请求和实际阅读会话；关闭后的已提交写入继续完成，新reader恢复先等待旧队列。该对象不持有引擎、Locator、页面或数据库；ReaderViewModel保留向引擎应用偏好和位置捕获的现有编排。设置完成仅等待设置，回到可见正文后才请求fresh完整位置。JSON格式、3秒位置预算和20秒资源预算保持。参考Readium 3.11偏好存储及Readest设置/书籍状态分离，具体版本与取舍见[方案](Documentation/READER_ISOLATION_PLAN.md)。

此为渐进提取第一片，未整体拆分字体/位置/会话服务。Build30源aa0a119/39373881574已通过定向6、完整151集成+29UI、Core各137及严格设备Release；8原图/四次旋转38原始帧已复核，手机性能/实际体验仍待验。历史024完整171/177与后续失败/取消独立保留，不能用最终成功倒写历史或统一归因旧加载故障。完整结果见ValidationLogs的r1-success和native-review回执。

## 偏好提交的幂等边界（Build30已验证）

ReadiumAdapter在取消被替代的请求后，比较完整EPUBPreferences与最后实际提交的appliedPreferences；相同偏好不再进入DOM采样或重排。撤销尚未提交的编辑回到已应用状态同样终止旧请求。真实变化仍保留fresh完整锚点、原3秒采样及可见错误，不清空错误来伪造通过。39362754281/176303d原生2/2：重复模式/外观与撤销请求保持原DOM字、同WebView，原六字体两模式重开30条观测errorMessage均nil。首次真实模式恢复与重复提交仍有区别；Build30完整180/严格设备Release已通过，手机待验。

## 连续旋转的双页策略边界（Build30已验证）

Readium本地infiniteScroll始终以单页章节组成有界连续窗口；EPUBSettings解析时关闭spread，避免原分页的auto双页状态在旋转时使整组WebView失效重载。分页模式保留原spread偏好，连续frame/ResizeObserver仍处理几何与锚点重排。仅修设置解析，不更换排版引擎、Locator或加载预算。39352276145后台UI原1项已通过；39358438791的6项实际5/6：同字viewport及实际浅深旋转通过，hidden初始深字失败另立初始化对照；后续幂等与初始化覆盖修复后39373881574最终180/严格Release已通过，手机待验。证据与固定上游差异见READER_ISOLATION_PLAN.md。

## Build29 阅读安全区

ReaderSurface协调器持有单个ReaderSafeAreaCover，直接附加原控制器view，保持fullsize/原层级。UIKit实际safeAreaInsets/layout驱动CAShapeLayer evenOdd四边页面色，中心透明、触摸和辅助功能穿透，zPosition高于迟到的navigator；布局/安全区/页面色变化才更新，dismantle移除。无逐帧滚动回调，不改引擎viewport/inset/offset、Locator、Core/schema/依赖。真window像素/命中/迟到子视图合成及浅深慢滚旋转验证分列；完整Release源a650，补充仅测试源f320，生产输入相同。详READING_EDGES_DESIGN和M4_READING_EDGES_VALIDATION_REPORT；手机性能和初始封面位置偶发超时根因仍待专项。

## Build28 进度显示隔离

App独立ReaderProgressState保存完整位置，ReaderViewModel保留position getter/setter接口而不再以自身Published发布位置；只有ReaderProgressView观察去重的章名/归一化进度摘要。原每次位置事件SQLite保存、fresh完整捕获和会话失效不变。ReaderMenu header添加页面色实底/短渐隐装饰，不改变引擎几何与输入。无Core/Adapter/Vendor/依赖/schema变更，iOS16 Combine/SwiftUI。门槛和设备边界见READING_CHROME_DESIGN.md与M4_READING_CHROME_VALIDATION_REPORT.json。

## Build27 字体收藏、排版与呈现边界

App层独立字体惰性网格/搜索，CGImage按原point尺寸上限显示；现有reading-v1字段上的显式排版预设及高级折叠，无领域模型/schema/引擎资源窗口变化。Core文件摘要在Apple委托系统CryptoKit增量SHA256，Linux保留portable实现，仍64KiB流式/取消/相同摘要；两Core已知向量/跨块/取消及iOS25MB字体三次校验回归保留。设置先比较小目录，未变复用已验证资源，外部通知强制刷新以覆盖同UUID修复。AppRoot字体inbox立即取得scope，冷启动等待BookFileStore，串行既有import actor后成对释放；目录通知只刷新浏览，明确选择才在完整锚点受控重开。ReaderPresentation以每次UUID隔离StateObject与返回回调，保存成功后原生dismiss并清空同会话、onDisappear统一关闭/失效，退出时保留页面，不闪重新排版；重复返回反馈明确。分页完整位置通知补与显式捕获一致的可见前后守卫，隐藏字体初始化不发布章头覆盖原锚点，Vendor摘要/理由登记；原隐藏重排真实WebKit回归保留。菜单通过viewport overlay与正文加载布局隔离。设置先提交文件，onDismiss后再fresh保存完整位置、可见失败；不从覆盖的导航器强行保存，不增加采样等待或回退旧位置。阅读主题只在自己的已呈现UIViewController设置公开override并恢复，不传播preferredColorScheme到书架/窗口。详细门槛与手机/性能限制见READING_EXPERIENCE_DESIGN.md及M4_READING_EXPERIENCE_VALIDATION_REPORT.json。

## Build26 阅读面板

App层独立ReaderContentsView/ReaderBookmarksView按值接收现有条目与回调，统一原生List和本地导航栏表面；ReaderSearchField用公开UIViewRepresentable/UITextField直接布局至少44pt真实编辑区域，保持中文marked text/光标且经既有setQuery取消旧会话；ReaderSearchView接当前theme/持久化reduceMotion，固定搜索框与键盘焦点，沿原SearchViewModel取消/增量/请求身份。无Core/schema/引擎/依赖/完整Locator变更，不解析opaque位置或推测canonical章序。公开iOS16 List/toolbar接口、无全局appearance和逐行阴影。实际自动/原生/手机边界见READING_PANELS_DESIGN.md及M4_READING_PANELS_VALIDATION_REPORT.json。

## Build25 原生字形与紧凑设置

ReadingFontPreviewRenderer actor直接给SwiftUI传递已绘制CGImage，透明alpha由原生template着色，UI不PNG编解码；保留一个CGFont与12图/8MiB像素上限。State保留请求身份和图，取消/过期结果不发布；加载/失败/图使用稳定尺寸，主题不触发字体I/O。固定分组、两列字体/辅助功能大字单列、紧凑排版行只调整App界面，不改Core/Readium/DB/完整位置/资源窗口/默认偏好。全部实现/验证与手机限制见READING_SETTINGS_COMPACT_DESIGN.md及M4_SETTINGS_COMPACT_VALIDATION_REPORT.json。


## Build24 设置内字形与排版

Core保留Foundation可选字距/字重/缩进字段和旧JSON；Adapter映射Readium3.11公开偏好，资源字体重排先等真实DOM采样成功（3s/32ms、请求/nav/取消守卫），避免隐藏初始化页锚点覆盖。中文横排CSS复用同版默认样式的显式字距/缩进规则，仍受advanced标志限制并登记UPSTREAM。App独立CoreText actor保留一个CGFont和12张短样例PNG，真实fileURL不全局注册，Lazy列表取消过期请求。六只读Bundle字体/原OFL不占12用户名额，资源目录18、正文窗口12；无新schema、整本正文、JS或依赖变更。详细来源/范围及实际门槛见READING_FONT_BROWSER_DESIGN.md与M4_FONT_PREVIEW_VALIDATION_REPORT.json。

## Build17 阅读手感第一片（早期开发记录）

Foundation领域ReadingInteraction与独立BookFileStore actor JSON保存交互偏好，不改变reading-v1/schema3/Locator。ReadingInterfaces可选ReaderInteractionProviding隔离动效与被动手势，Adapter统一导航options/关闭身份与分页防重入，UI只持领域值。首候选97/99，正常拖动未收菜单仍诊断，源码不等价验收；当前精确边界与后续修正见READING_MOTION_DESIGN.md及HANDOFF.md。

## 依赖方向

```text
App (SwiftUI / 组装 / Library / Import / Reader)
 ├── XianxiaCore (Foundation 模型、SQLite、文件事务、TXT 索引接口)
 ├── ReadingInterfaces (UIKit 渲染边界、领域类型、EPUB 元数据接口)
 └── ReadiumAdapter → ReadingInterfaces + XianxiaCore + Readium
```

`XianxiaCore` 没有 SwiftUI、UIKit 或 Readium 依赖，可在 macOS 独立测试。额外的 Linux Core 测试使用普通本地文件复制分支，Apple 构建必须保留 `NSFileCoordinator`；两条路径分别验证，不等价。`ReadingInterfaces` 与 `ReadiumAdapter` 是同一 Swift Package 中不同 target：App 通过协议控制阅读，只在组装位置创建具体工厂。替换引擎时实现同样的协议并替换组装，不改变数据库和书库视图。

相比把所有目录平铺在根目录，使用 `App/` + 两个 `Packages/` 强制依赖边界，并允许 Windows 编辑、macOS Core 测试及 iOS 适配测试分别进行。Search/Themes/Settings 在对应 milestone 才新增实际模块，避免用空文件和假实现表示完成。

## 布局

```text
App/
  XianxiaReaderApp.swift / AppRootView.swift / AppServices.swift
  Library/             基础网格、缩略封面、状态
  Import/              security-scoped URL 生命周期、导入编排
  Reader/              引擎桥接、菜单、目录、书签与保存
  Resources/           Info.plist、颜色资源
Packages/
  XianxiaCore/
    Sources/CSQLite/    系统 SQLite3 modulemap
    Sources/XianxiaCore/
      Models/          Book、Chapter、ReadingPosition、Bookmark
      Database/        repository、连接、版本化 SQL migration
      Import/          文件暂存、提交、回滚、恢复
      TXT/             M2标题识别/有界窗口/严格正规化/摘要cache/产品导入与读取范围
    Tests/
    Benchmarks/TXTPerformanceProbe/  独立桌面Release测量工具，iOS App不链接
  XianxiaReading/
    Sources/ReadingInterfaces/
    Sources/ReadiumAdapter/
Tests/iOS/             Readium、真实导入、Locator 测试
Tests/Fixtures/        原创 EPUB 2/3
Future/XBook/          容器协议草案
Future/Knowledge/      无剧透数据设计草案
Documentation/         功能矩阵、验证与性能计划
scripts/               结构验证、样书、CI 与 IPA 打包
.github/workflows/     macOS 构建及诊断输出
```

M2长篇验证使用Core package内独立`TXTPerformanceProbe` executable，依赖公开Core API，不把Darwin/Glibc测量调用放入Core业务target。`scripts/run_txt_performance.py`流式生成原创临时样本并逐样本分进程运行，实际Apple/Linux复制、缓存和数据库路径分别测量；进程退出后再清理临时数据库。iOS App仅依赖library product，测试工具不进安装包。完整测量JSON/log作为CI诊断上传，小摘要进入交接；契约见PERFORMANCE_TEST_PLAN.md。

## 平台与语言

- iOS 16 起步，优先覆盖普通设备及部分 TrollStore 使用场景；不代表所有系统版本都有 TrollStore 安装能力。
- SwiftData 需要更高系统基线，因此 M0 使用系统 SQLite3。Apple 构建通过 modulemap 使用目标 SDK 的头文件和库；不能使用宿主 Homebrew 的 pkg-config，否则 iOS 会误链接 macOS dylib。Linux 安装 libsqlite3-dev，使用标准系统搜索路径。ORM 可以以后替换，`BookRepository` 屏蔽 UI 对具体存储的依赖。
- Swift tools 5.10、Swift 5 语言模式配合 Xcode 16.4。M1 搜索 CI 38402285563 已通过，targeted 模式的 Binding 警告已修复，应用源码编译零警告。Readium Publication 在后台 actor 与 MainActor 间的交接以及 Swift 6 严格模式迁移仍须独立审查，不用无依据的 `@unchecked Sendable` 或关闭检查伪造通过。
- `project.yml` 为工程配置源。`.xcodeproj` 由锁定 XcodeGen 生成并在 CI 输出，不手写 PBX 文件，避免 Windows 维护重复配置。
- Build3使用官方Readium3.11.0/11 pins。连续模式候选切换为 `Vendor/ReadiumToolkit` 本地维护扩展，基线revision仍为 `d82f44f4f05d87add9e22a8b75abbd61dce745dd`；来源/精确文件hash/许可/本地修改在UPSTREAM.json，不是官方合并功能。根 `Package.resolved` 原样来自macOS真实解析run38496501326，实际6 pins与旧锁版本/revision/location相同；未使用的server/SQLite/LCP依赖被SwiftPM裁剪，细项保留在来源记录。首轮解析不代表编译验收。生成工程后复制锁到workspace，resolve/test/build严格使用 `-onlyUsePackageVersionsFromResolvedFile`；bootstrap仅用于明确首次解析，采用真实artifact后必须关闭并完整重跑。

## 持久化与文件一致性

领域模型使用稳定 UUID；路径是应用存储根目录下的相对路径，避免 iOS 沙盒绝对路径随安装变化。正文存为文件，数据库仅存元数据、目录和 Locator，不把数百万字正文塞进数据库 JSON。

存储根目录先创建再解析系统父级链接（例如 Apple 的系统路径别名）；其内部由项目管理的路径不允许符号链接。解析相对路径时逐级检查已存在的节点，也拒绝 dangling link，不能只对完整路径调用 `resolvingSymlinksInPath`：Linux Foundation 在末端不存在时可能原样返回并遗漏父级链接。普通尚未创建的书籍目录仍可解析，其他文件错误正常传播。此校验适用于应用私有存储，不声称提供抵抗外部进程并发替换目录的操作系统级文件句柄隔离。

SQLite 由 `SQLiteBookRepository` actor 独占连接。启用外键、WAL、busy timeout、预编译绑定；迁移通过 `user_version` 管理。未知高版本数据库显式拒绝打开，不删除用户数据。Book 与其目录在同一事务插入；章节按 `(book_id, ordinal)` 索引，书签按书籍索引。

M0 为简单演进，将领域 record 编码为 JSON BLOB，并保留关系、排序和查询列。后续全文搜索使用单独 FTS/增量索引，不能扫描全部 BLOB；schema 变化需要 migration 和升级测试。未来关系库不在当前 schema 提前铺开。

导入顺序：

1. App 使用 UIKit Document Picker 的 `asCopy: true` 请求本地导入副本，允许 data 类型选择，再验证 `.epub` / `.txt` 后缀与实际内容。一次 delegate 完成后，LibraryViewModel 立即开始导入或报告错误，不等待 onDismiss；Coordinator 由书架持有到终止回调，completion 弱捕获 model，新presentation失效旧Coordinator，结果消费后释放。文件/编码共用单个 LibrarySheet item sheet，错误持久显示在书架，避免另一个alert争抢呈现。若 URL 提供 security-scoped access，持有到导入完成。首次关闭无书籍/无提示的新反馈及原生回归见 IMPORT_DELEGATE_FIX.md（Build6设备首次失败，旧交接文档仅保留历史）；此前类型/副本修复 CI38411028842 / 26 tests 是历史证据，不能证明首次 sheet 或真实 File Provider 通过。
2. FileStore actor 通过 `SourceFileCopying` 复制到 `Staging/<id>/book.epub`，避免将全部文件读成内存 Data。默认 Apple copier 使用 `NSFileCoordinator`；Linux 验证使用普通 local copy，测试可注入写入部分文件后失败的 copier。
3. Loader actor 通过 Readium 识别实际格式、检查 DRM/reading order，读取元数据、TOC 和限定尺寸封面。
4. 移动到 `Books/<id>/`，再提交 Book + TOC 数据库事务。
5. 失败时移除该 UUID 暂存/成品。重启先查询数据库，再清理未提交的 UUID 文件夹；已知书籍不会被清理。清理仅在导入开始前运行。

文件移动与 SQLite 不是跨系统原子事务；上述提交顺序与重启恢复覆盖“文件已移动、DB 未提交”的中断窗口。若清理失败，向用户报告；不能吞掉错误声称导入成功。M3 删除采用单独可恢复事务方案，当前没有草率添加删除功能。

封面错误可以降级为标题封面，但必须保留导入警告。暂无内容 hash 去重；相同文件再次导入生成独立 UUID，不将其描述为去重完成。

## 阅读与位置

Readium 负责 EPUB 解析、EPUB Navigator、分页/滚动、CSS、图片、内部链接及后续搜索/Decoration/TTS/Preferences；本项目只构建控制层和产品 UI。M0 不覆盖全套 Readium 能力。

SwiftUI 的 `ReaderSurface` 使用显式 viewport 尺寸，菜单只叠加在阅读区域之上，不参与正文尺寸计算。Adapter 在挂载 Navigator 时设置有效 frame 和 autoresizing，与上游 SwiftUI 容器合同一致。图像/CSS 仍由 Readium 解析、排版，不修改用户 EPUB 或全局强制覆盖作者图像样式。

横排重排媒体仅校准 ReadiumCSS 已有的 `--RS__maxMediaHeight` 保护：公开 setupUserScripts 钩子按真实 `innerHeight` 的95%设定像素上限，resize同步；避免WebKit的device-height/vh与实际正文视口不一致。不改作者width/aspect/object-fit，固定布局和竖排不接入此修正。原图/CSS仍保留，实际图像尺寸与原书体验分别验收。

Build3的官方Readium3.11 `scroll` 仅章内滚动。Build4连续候选通过 `ReadingInterfaces` 可选能力接入本地Navigator扩展，外部UIScrollView只分配有界已加载资源，每章WKWebView保持视口尺寸；显示加载边界，最多12个资源并按可见距离回收。仍复用Readium资源服务/CSS/正文DOM，不拼接全书或分配数千章空白。横排LTR重排支持范围显式检查；固定布局/RTL/竖排保留原路径。CI38530334549/d62af3b完整自动回归、设备Release/IPA通过，用户已确认连续功能和重开位置可用。旧边界PNG证据限制保留，未逐项确认的设备/内存/旋转等继续记录，详见 `Documentation/CONTINUOUS_SCROLL_DESIGN.md`。

连续候选位置保持标准Locator href/CSS/text/progression，并附加DOMRange字符位置及版本化局部视口偏移；只取64字符上下文。超长单段不退回段首。原搜索Locator继续走Readium文本定位；仅标记过的连续保存锚点使用精确字符恢复。异步位置/测量结果核对资源epoch和视口revision，未加载资源不发出假位置。close显式取消窗口任务、恢复待定位continuation并移除JS handlers。上述自动回归及600点滑动后字符/重开3px门槛在CI38530334549通过，不能代替实际设备体验。

模式转换先异步取得实际DOM锚点，request ID/Task取消与Navigator identity防止迟到切换作用于新session。Readium的isSpreadLoaded早于延迟初始定位/decoration完成，因此增加显式完整初始化等待，clear也恢复等待者；原生go期间暂缓容器覆盖inner offset。go后读取DOM scrollY作为实际坐标，显式目录/搜索/书签定位原子提交外层offset，普通拖动/惯性与按屏滚动保留原路径。所有修复以完整CI为准，不能仅凭可见DOM就把位置恢复写成验收通过。

显式跳转通过同一次JS执行原Readium定位并读取scrollY；位置保存则原子读取Locator/documentY/documentTop，发生DOM与原生视口不一致时最多采样3次，每次都核对epoch/revision/当前slot，不无限等待。原生didFinish公开WK探针启动同一完整初始化管线，避免后台rAF加载桥暂停；回收取消任务并解除等待链。已通过41项iOS自动验证，用户确认连续功能/重开位置正常；未单独报告的其他页面/设备项目仍待验收。用户要求卡点参考成熟实现，已审阅epub.js/Foliate/Readium连续方案；具体适用范围与保持原架构的取舍见 `Documentation/MATURE_READER_REFERENCES.md`。

回收章节的clear还必须断开spread、WKNavigationDelegate/WKUIDelegate和内层scroll delegate；已clear的WebKit进程终止以及取消加载完成回调不能要求当前Navigator重载。公开后首次CI38511938460为37/39，历史失败已保留；迟到termination真实窗口回归及全部41项在38530334549通过，不能据此把每一处旧失败都归为同一原因。

实际窗口测试通过公开 UIKit/WebKit API 检查 DOM、完整原生 Locator 和可视区域。DOM `readyState` 与 Readium 原生位置就绪分别等待；预加载 WebView 必须在两个轴上与 viewport 重叠才算当前页。快照保存在 xcresult，几何断言与视觉复查分别记录；原创样书通过不代表用户书籍完成设备验收。

`ReaderEngine` 提供渲染控制器、分页、章节/位置跳转、滚动模式、事件回调；业务层只持有 `ReadingPosition`。持久化完整 Locator JSON，包括 href、fragment、资源/全书 progression 与文本上下文，并带 `engineID`/版本。不能用一个浮点百分比代替可靠位置恢复。

保存每次位置回调；SQLite UPSERT 按 `updated_at` 拒绝过期写入，处理异步任务顺序颠倒。关闭阅读与进入后台额外保存。损坏/不兼容 Locator 显式报错，不能静默归零。首次成功定位前“正在打开”不等于已读。

TOC 导入时持久化，打开目录只读取现有数组。EPUB TOC 可能含卷、分组、子节，界面使用“目录条目”，不能把数量伪装成精确小说章节总数。未来 XBook 知识范围需要独立 canonical chapter mapping。

输入通过 Readium observers 处理，不叠加透明 SwiftUI 点击层遮挡链接和选择。当前左右 30% 翻页、中间 40% 切换菜单；滚动模式保留正常滚动。菜单覆盖空间、字体变化与旋转定位需 M1/M4 真机验收。

引擎和 ViewModel 的每次打开请求具有独立 UUID。`close` 使悬挂的 publication load 失效；load 返回时先检查请求仍有效，再挂载控制器/发布 ready。旧请求不能关闭较新的 session，旧 Navigator 的 delegate 回调也不能更新当前书的阅读位置。关闭后的迟到 position 回调在 ViewModel 被拒绝；正常关闭时的最终位置回调仍保留。

## M1 搜索切片

引擎提供可选 ReaderSearchProviding / ReaderSearchSession，actor 隔离读取游标。UI 仅持有 Sendable 命中 DTO 与完整 ReadingPosition；位置跳转复用 ReaderEngine.go。关闭/改词取消 task 和 session，通过 request ID 拒绝迟到数据；清理前先解除当前 session 引用，避免 await 返回后覆盖较新查询。

锁定的 Readium3.11 默认 ContentSearchService 存在组合字形拼接偏移缺陷，因此使用官方 SearchService factory 扩展；Readium 仍负责正文解析/DOM locator。服务按 TextContentElement 的 joined String 原生索引匹配，每批40、上下文各64；界面最多1000条、手动加载更多，不报告未计算的全书总数。跨 inline segment 可匹配，跨元素/资源不可；不开放 regex。实现与上游依据见 Documentation/SEARCH_DESIGN.md。

原9+新增11 iOS tests 已过真实 CI，尚未验收页面命中定位。Readium 内部按整个 XHTML 解析，超大单资源内存/取消延迟留 M5 实测；正文全文搜索与未来知识库的章节范围查询分别管理。

## TXT 实现边界（M2）

产品接入已过CI38559906005/37eb86a各68 Core/46 iOS/Build5 Release。Core TXTBookImportService复用原件协调复制/cache/文件提交/数据库事务与UUID恢复，Book可选txtEncoding兼容旧payload；Adapter通过公开Publication/Container/惰性DataResource仅按64KiB窗口转XHTML。TXT独立readium.txt完整位置envelope绑定内容/版本、稳定章ID、byte/UTF16与原生Locator，后台边界验证及await后request/Navigator检查。UI经ReadingInterfaces.currentChapters与可选search操作，Readium不进入Core，SQL schema/远程锁/Readium版本未改；本地连续selector仅对显式TXT标记保留唯一字节ID，准确更新UPSTREAM hash，普通EPUB仍原路径。设计TXT_READING_DESIGN.md；设备/长书/排版边界仍待验收。

第二切片已过完整CI38547339868/65c1b8d：各60 Core、41 iOS与设备Release。业务仍为Foundation/SQLite，与Readium/UI隔离。GB18030内部CTextCodec：Apple使用公开SDK CoreFoundation（GB_18030_2000/lossByte=0），Linux用glibc iconv，无新远程依赖/Homebrew路径。Apple系统iconv首轮实际四字节回归失败原件保留，更换接口后原断言及扩展向量全部通过。UTF8/UTF16严格增量校验/解码，SHA256绑定原/normalized/目录身份；cache generation原子manifest只存校验过的相对路径。平台codec ID用于缓存失效，复用仍流式核验摘要；当时产品TXT导入/阅读尚未接入；最新接入以上方Build5为准。细节见TXT_INDEX_DESIGN.md。

第一切片新增 `TXTChapterHeadingRecognizer`、`TXTUTF8ChapterScanner`与`TXTChapterWindowReader`；在Core actor扫描已规范化UTF-8正文，严格跨块校验、CRLF/BOM/长行处理，返回卷分组与叶子Int64/end-exclusive范围，按不越章的有界窗口读取。已过CI38538141364/0643093（attempt2各33 Core、41 iOS、设备Release）；`StreamingTXTIndexer`已实现正规化+索引facade，`TXTIndexCache`已实现cache；该历史节点产品导入/阅读未接入；目前已由上方Build5独立集成验证。

实现独立于UI，后续后台流式转码必须处理UTF-16/GB18030边界，将正文标准化为UTF-8旁路文件并保留原件；阅读只加载当前/相邻窗口，不能将整本String发布到UI。卷不重复正文范围；卷标题与卷序文字保留在叶子范围，不丢失未识别前言。标题ID以同bookID/字节位置稳定生成，内容改变须cache失效，不能跨不同正文复用位置。

索引 cache key 至少包含内容 SHA-256、编码/标准化版本、parser version；实现一次索引、重开复用。支持无章节、序章、卷与章层级、超长单行、误识别正文以及取消/磁盘不足恢复。具体阈值见性能测试计划。

## 后续扩展

Highlight / Note 和 Character / Realm / Faction / Item / Technique / Location / Relationship / StoryEvent 目前仅登记设计边界，不建空实体库。引擎 Decoration/Search/TTS 与产品服务分离；用户选择与已揭示知识由应用自己的服务维护。

无剧透原则是数据读取边界：查询接口必须接收已验证的章节范围，只返回此范围内的记录；不能先读未来内容再在 UI 隐藏。XBook 协议和知识草案位于 `Future/`，不进入应用 target。

## 2026-10-15 TXT ANSI 与范围缓存

Build9新增GBK/CP936、Big5/CP950、Windows-1252严格流式转换；App枚举选择、实际检测结果仍通过Core/导入协议，不持有Readium Locator。自动BOM/严格UTF8后按中文GBK/GB18030，其他手选；Apple SDK与Linux系统iconv独立向量验证。Apple CP936单独euro官方映射小桥接仅在完整字符边界，不改GB18030。Normalizer/parser/Locator v1、旧codec身份保持，自动策略独立v2 cache key；新codec由index携带以验证anchor，旧自动UTF8cache重建后旧完整位置回归通过。

TXTReadingPlanCache只持久resource范围与内容/章节/codec/版本身份，8MiB元数据限额、原子写入、重新路径检查；新Loader先获取TXTIndexCache完整摘要已验证index，后读范围cache。仍全量digest，复用边界最多每resource两次单字节读取，与旧planner最大scalar窗口一致；损坏重建、取消/IO/路径错误可见。Core仍无UIKit/SwiftUI/Readium，ReadiumAdapter公开Publication服务/有界正文与Locator边界不变。完整设计与官方/成熟参考见Documentation/TXT_ANSI_COMPATIBILITY.md，真实各80Core/58iOS及Release9证据见最新报告；设备结果独立。

## M3 书库浏览与改名

LibraryPresentation仅处理书名/作者元数据筛选、稳定排序和已保存进度；LibraryViewModel注入UserDefaults持久化布局/排序，用refresh请求ID拒绝较旧结果；LibraryView基于原生LazyVGrid/LazyVStack和共享LibrarySheet，长按进入BookRenameSheet。File Provider原delegate生命周期不变；新sheet以book.id区分状态，保存中不能互动关闭，错误留在表单。

Core新增BookTitle验证与BookRepository.renameBook，SQLite事务helper返回泛型提交值，BEGIN IMMEDIATE后读最新payload只改title。无schema变更、不用UI旧Book覆盖author/cover、不变原件路径/目录/位置/书签，真实写失败/回滚/重试与多连接最新元数据有回归。封面读取仍后台执行，取消后拒绝旧结果，失败有可见/无障碍降级警告。Build10各85Core/63iOS/设备Release已通过，但仅M3第一切片；封面替换、可恢复删除、重复导入策略继续单独设计和验证。详见Documentation/LIBRARY_BROWSING_DESIGN.md及最新报告。

## M3 可恢复移出书架（Build11）

数据库通过新增002迁移升级到v2；removed_books仅记录移出时间，Book/原件/cache/章节/位置/书签保持。librarySnapshot一次读取书架/回收站；books只返回书架。AppServices启动恢复必须用allBookIDs包含回收站，不能根据可见书架清理已提交文件。移出/恢复仅在SQLite事务内变更标记，重复操作幂等，失效UUID/取消/写入失败正常抛错；没有新增文件搬移或跨存储提交窗口。001旧迁移原字节保留，新版库由旧App拒绝打开。

LibraryView共享sheet加入回收站，长按移出有原生确认，空书架也能恢复；管理操作串行且提交后才发布。回收站不自动清空、不回收磁盘空间；没有永久删除。Build11的91Core/67iOS/Release及真实启动清理/原生三图通过，用户已确认该切片可用；Build12新增手势/流畅度设备反馈另记。Readium/Vendor/codec/Locator/真实六pins锁和Apple文件协调复制均不升级。封面替换与重复导入策略仍下一M3切片，详见LIBRARY_REMOVAL_DESIGN.md。

## M3 原生左滑与动效（Build12）

LibraryView按布局选择原生List或ScrollView/LazyVGrid；List行接尾侧swipeActions，禁全滑直接执行，灰绿色普通按钮进入既有确认，数据提交后才移出。固定UUID身份驱动短spring补位/scale+opacity过渡，布局切换短淡入淡出；LibraryTrashSheet恢复行有短过渡，系统Reduce Motion关闭自定义移动/缩放和继承动画。未新增Core/DB/schema/Reader依赖变化。

新增独立bundle.ui-testing target与三个XCUITest，旧67iOS不跳过。AppRoot通过可选LibraryInteractionFixture接入隔离小样；只有DEBUG分支读启动配置/建立fixture，Release prepare恒nil且Mach-O无XR_LIBRARY_UI_*旗标。CI显式保留每项XCTest的成功录屏，基座simctl录屏只用于诊断并收集真实退出；录屏或原test/导出/summary失败都不能生成IPA；完整视频/六图用于独立视觉核验，不当手机帧率或完整主题验收。详见LIBRARY_INTERACTION_DESIGN.md与最新报告。

## M3 封面替换（Build13）

Core Book可选coverOverride与UUID派生Artwork路径，最新payload事务只改此字段，schema2/迁移不变。BookFileStore独立StagingCovers与不可变Artwork，Apple协调复制；文件先finalize再DB，DB失败回移草稿，只有本次finalize成功才回滚。启动清临时stage，回收站UUID也保留；已提交/旧自选原图不GC。原书/默认EPUB封面/正文缓存和完整位置/书签分离。

App新增CoverImagePipeline/CoverImportService actor与BookCoverEditorModel/Sheet，公开PhotosPicker FileRepresentation/共享UIDocumentPicker，20MiB/8000万像素限制，后台1080px JPEG和600/252px显示缩略缓存，CGImage方向只转换一次。requestID/closed/Task/Coordinator防旧结果覆盖，提交后仅当前editor可关闭；缩略图坏时有界原图恢复有警告。Release不带DEBUG种书入口。完整门槛和具体风险见LIBRARY_COVER_DESIGN.md/M3_COVER_VALIDATION_REPORT.json。

## M3 精确重复导入（Build14）

003迁移到schema3新增book_import_identities，不改Book JSON/Locator；非唯一索引保留旧重复书。BookImportDeduplicator在Core actor流式补齐旧原件摘要，匹配TXT时才按其编码恢复正规化身份；BookFileStore继续执行根目录/逐级symlink合同。BookRepository新增指纹记录/查询和事务内复查提交，SQLite BEGIN IMMEDIATE串行化多连接竞争，Book/Chapter/指纹一起提交。已有匹配原件必须再次核实；取消/失败只清理未提交的新UUID。UI结果区分新增与重复、回收站恢复仍显式调用既有repository动作。详细限制和验证见LIBRARY_DUPLICATE_DESIGN.md/M3_DUPLICATES_VALIDATION_REPORT.json。

## M4 外观偏好第一片（验证中）

ReadingAppearance属于Core Foundation领域模型，持久化由现有BookFileStore actor负责Preferences/reading-v1.json，最大16KiB、逐级路径检查与原子写。ReadingInterfaces以ReaderAppearanceProviding可选能力隔离具体Preferences，UI只持领域值。ReaderViewModel在打开前加载，并按输入序列保存；Adapter映射3.11偏好，复用DOM anchor与取消/身份保护。已维护Vendor的Navigator派发增加连续视图分支，仍只作用于有界loaded/current/resource；锁/原始基线不变，UPSTREAM记录hash与取舍。具体范围、原书排版优先级及未做项见READING_APPEARANCE_DESIGN.md。源码不等价编译或手机验收。

## M4 Build16 原生界面

ReaderMenuView承载阅读菜单，ReaderVisualStyle管理App层灰绿浅深色语义表面，ReaderAppearanceView以外观/排版分组调用既有ReaderViewModel。UI不持有Readium类型，版本化偏好模型/Locator/schema/原件和缓存合同保持。必要分页修复在Adapter采样前取消检查与维护Vendor的分页就绪/CSS失效路径中，未升级引擎/锁或修改JS bundle；原非零文字/180%重开回归和新增真实WebKit互斥回归通过。参考及实际原生验证见READING_UI_DESIGN.md。

## Build17 阅读交互偏好

ReadingInteraction属于Core Foundation模型，与ReadingAppearance/完整Locator分离；BookFileStore actor保存独立有界/原子interaction-v1.json，使用逐级路径校验。ReadingInterfaces可选ReaderInteractionProviding隔离被动手势和动效；Adapter复用Readium公开drag observer与NavigatorGoOptions，并核session/Navigator身份。UI的手感组/菜单过渡只持领域值、保持正文视口，系统/用户减少动效与DEBUG额外请求分别合并且不把额外请求落盘。首轮原生加载时序失败按实际录屏修正测试准备条件，Vendor回调实验已撤回，最终保留必要分页完整锚点修正及Vendor provenance，不改JS或依赖版本。完整119Core/99iOS/Release17及原生复核见READING_MOTION_DESIGN.md，手机手感另验。

## Build18 原生表面与按钮反馈

ReaderVisualStyle中的ReaderPanelSurface将有限阴影仅施加到单一背景fill primitive，再叠不拦截触摸的渐变/边线；避免整个内容子树的文字和图标带阴影，复用实色背景；ReaderPressStyle基于标准ButtonStyle保留原生激活/取消，只改变标签视觉层，并在外层保持44pt命中区。减少动效合并系统、用户与运行时额外请求，仍保留即时颜色状态；colorSchemeContrast读取系统增强对比度。无正文、引擎、存储或Locator变动。设计/实际验证见READING_DEPTH_DESIGN.md。

## Build19 上下整屏输入策略

ReadingInteraction v1增加可缺省的verticalScreenPaging，原字段严格解码；领域/Foundation与存储路径保持。ReaderMode仅UI选择，能力和具体应用仍通过ReadingInterfaces的interactionProvider；Readium具体API只在Adapter。Navigator与有界连续容器增加原生目标偏移/90%高度/手势原点补偿及命令防重入，不引入全书正文/新排版/缓存或JS修改。跨模式/字号仍使用既有完整DOM锚点，生命周期/原有竞态与新非零3px重开回归通过。具体合同及实际设备限制见READING_SCREEN_DESIGN.md。

## Build20 即时整屏过渡保护

沿Readium3.11现有PaginationView的公开UIView.snapshotView保护思路，仅在无动画整屏命令保留一帧当前原生视口200ms，作为静止兄弟视图；底层位置立即应用，视图不截触摸/可访问性。一个可取消Task/请求ID管清理和迟到结果，新拖动/模式/resize/跳转/关闭释放。没有新引擎、每帧捕获、PNG缓存或Core/接口变更；性能/真实系统与手机视觉仍单列，详细证据见READING_SCREEN_STABILITY_DESIGN.md。

## Build21 自动慢滚

Core的AutomaticScrollClock只含Foundation时间数学；ReadingInterfaces提供可选ReaderAutomaticScrollProviding，UI不持有Readium类型。Adapter用短时CADisplayLink/弱目标/sessionID驱动Vendor已有连续容器的ready窗口，原12资源上限及完整Locator保持，无新排版或每帧DOM/DB/截图。移动约每秒串行完整锚点采样，暂停/保存补最后位置；await后验证epoch/index/size/request，旧回调不能重启或清新session。ReadingInteraction v1只保存速度，缺字段旧兼容，运行状态不持久化；前后台/触摸/跳转/布局/错误停，减少动效/VoiceOver拒绝开始，idleTimer恢复原值。Build21完整自动门槛与选定原生复核和手机矩阵分列，详见READING_AUTOSCROLL_DESIGN.md和M4_AUTOSCROLL_VALIDATION_REPORT.json。

## Build22 回看返回

ReadingInterfaces提供完整位置capture，Adapter沿用有界DOM采样，Vendor既有preserve方法提供可忽略Bool成功结果及取消检查。ReaderViewModel用单个ReadingPosition和导航UUID保存会话内出发点，三类显式导航共用async身份保护；成功返回/留在此处清除，失败保留，关闭作废且迟到defer不能清新请求。当前位置回调/数据库进度照旧，关闭不自动返回；无新schema/Core/缓存或历史栈。原生小条沿用主题/按压/44pt/减少动效，不重排正文。完整门槛与选定原生证据和手机矩阵分列，见READING_RETURN_DESIGN.md及M4_RETURN_VALIDATION_REPORT.json。

## Build23 字体资源

App只读Bundle两原中文字体/稳定UUID与最多12用户资源合并（≤14 faces），内置不复制/摘要；Core身份/独立目录与App后台CoreText验证、ReadingInterfaces目录capability→Adapter公开CSSFontFace/既有资源通道。新增目录以完整位置保护重开，资源字体排版完整锚点重载；每await校验，关闭取消/迟到隔离，失败恢复旧目录。原schema/正文/Locator/依赖保持，可选UUID旧偏好兼容。原生与手机性能门槛分列，见READING_FONT_IMPORT_DESIGN.md。

## 初始化定位的先后顺序（Build30已验证）

Readium的isSpreadLoaded早于初始字体/排版和位置恢复。ReflowableSpreadView每次收到完整PageLocation先更新已有pendingLocation，再依原有已加载状态立即定位或等待；初始字体完成后读取最新值。仅移动已有赋值，不增加状态、轮询、重试或预算。39370263590不改生产的显式屏障对照证明真实字体ready/深字可见后放行会回章头；同fixture先行与完整再次通过，Build30全180与严格设备Release已通过，手机实际验收仍待反馈。
