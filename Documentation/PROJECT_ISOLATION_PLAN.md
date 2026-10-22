# 全项目隔离与维护计划

2026-10-22 连续视口可控复现设计已完成，尚未实施：只检验“旧尺寸请求跨到新DOM读取后，是否覆盖A并令重排放弃恢复”的假设。设计明确缓存未命中采样屏障、并发测量提交屏障组、放行回执、关闭失效后清理，以及准备不成立/状态交错/原字故障的判读。原断言、预算及617运行输入保持；零CI、零源码/测试修改，旧full191/192与Release/手机未验收保持，最后交付Build30。见[可控复现设计](I6_VIEWPORT_REPRODUCTION_DESIGN.md)。

2026-10-22 连续视口同例对照已保存：仅撤指定缩放前DOM观察await，82b35f76/CI39759498210原单例1/1（11.293秒），原499字在横/竖完成时均可见、补偿实际生效；before DOM为null，不伪造前置证据。其他616运行输入及原断言/预算不变。旧故障未复现、根因未证，不称已修复；用户决定下一轮先做无CI可控复现设计，本轮不追加实验。旧full191/192、Release未执行、最后交付Build30保持。见[本片结果与断点](I6_VIEWPORT_RESIZE_CONTROL.md)。

2026-10-22 连续视口缩放诊断本片已保存：b618ca86/CI39754777198原单例1/1（20.730秒），前后原字499可见、同WebView、重排补偿记录齐；旧失败未复现，根因未证，定位算法不改。首轮探针编译错误已单独留证；共2轮CI、实际方法仅执行1次。用户决定本轮到此、下一轮仅撤去一个缩放前DOM观察await作同例对照，patch未应用，不追加CI。旧full191/192、Release未执行和最后交付Build30保持。见[本片证据与断点](I6_VIEWPORT_RESIZE.md)。

2026-10-22 I6最终full已完成一次，源77eebf40/CI39735403242/Build31：192全部执行，191通过、1失败、0跳过（集成162/163、UI29/29）。六模块68、两平台Core各137/TXT Release各4、Linux109工具通过；模拟器编译通过。唯一失败为连续视口变宽后的原字/WebView联合等待，缺缩放前原锚点及子条件诊断，未证明根因或修复。test65、summary/export/recording0；Release被阻止、未执行，无新IPA，最后交付仍Build30。无额外原生预检/重跑，完整原件已核；用户已决定本轮保存完整断点，下一轮只查此单例；本轮不追加诊断或CI。I6未通过，不进入新功能。 见[本轮结果与下一实验](I6_FINAL_ACCEPTANCE.md)。以下I6d等为历史阶段记录。

2026-10-22 I6d：最终验收缺口与复用原件已核，当前不派CI、不改生产/测试/门禁。下一轮采用一次冻结源full（163+29及设备Release），不叠加23/字体/旋转预检，保留现有Core/组件/TXT快检。旧UI因输入/数量/架构变化不可复用；App宿主/批次呈现/同target UI等登记限制保持。见[最新验收范围](I6_FINAL_ACCEPTANCE_SCOPE.md)。

2026-10-22 I6a边界/证据审计及两处发布门禁修补完成：原始合同与传递输入核实后，6个独立模块只可分项引用，不能相加成同源验收。补齐完整artifact的设置/导入/搜索证据目录，并在Release前增加full192全部通过、零失败/跳过摘要门禁。105项本地工具98通过/7 POSIX跳过，语法484无新增诊断（非编译）；首旧夹具失败及修正保留。仅5个CI/tooling输入变化，其余612及全部生产Swift/原生测试/工程/资源/锁保持。Reader宿主AppServices、UI/批次桥接和字体iOS依赖仍是边界限制；下一片只做原19位置+4加载=23项，不复用旧28项UI配置。当前零CI派发、未跑原生/完整192/Release/手机、无新App IPA，I6整体未验收。详见[审计与精确门槛](I6_ACCEPTANCE_AUDIT.md)及ValidationLogs/project-isolation-i6-audit.json。

2026-10-22 I5c搜索本片完成：ReaderSearch真实独立包拥有原搜索DTO/可选协议与请求/分页/取消/选择编排，只依赖Core及Foundation/Combine。App与ReadingInterfaces保留typealias兼容，无新异步层，原12await、函数正文、发布与清理顺序不变。最终53f7e1f2 / CI39715718761独立macOS8/8、原生13/13，包及App/测试接线真实编译通过。搜索界面/输入、Readium3.11安全搜索服务/限制、ReaderPositions及书库/导入/字体/会话/Core/Adapter/Vendor/资源/锁不改；原生测试正文不改。完整163+29=192、Core137全组、Release/设备/手机未跑，无新IPA，最后交付Build30。详见Documentation/SEARCH_ISOLATION.md与ValidationLogs/project-isolation-i5-search.json。

2026-10-22 I5b导入事务本片完成：BookImports为真实Foundation/Core独立包，拥有原EPUB/TXT导入服务与元数据合同；App/ReadingInterfaces以typealias保留旧调用名称/协议身份，无async包装、原11await与服务body保持。最终c8b53e38 / CI39712813755独立macOS8/8、原生14/14，包及App/测试接线编译通过。App批次UI/Task/picker/FontInbox、书库、搜索及阅读/字体/定位/会话/Core/Adapter/Vendor/资源/锁保持；批次呈现仍在App，不能称全部导入编排或全项目已隔离。完整163+29=192/Core137全组/Release/设备/手机未跑，无新IPA，最后交付Build30。搜索后续。详见Documentation/IMPORT_ISOLATION.md及ValidationLogs/project-isolation-i5-import.json。

2026-10-22 I5a书库本片完成：LibraryShelf真实Foundation/Core包拥有同步列表、刷新身份及提交合并，窄仓库不暴露导入/搜索/位置写入。App组装原引擎/导入器，书库不再持有AppServices/创建Readium；原await、导入/搜索流程、Reader/R1/R2/R3/R4及定位/字体保持。最终1532b863 / CI39707770264独立6/6、原17+新增延迟初始化1=18/18，包和App/测试真实编译通过。书库UI仍同App target，特定类型静态检查不等于完整类型隔离。完整163+29=192/Release/设备/手机未跑，无新IPA，最后交付Build30；导入/搜索留后续。见Documentation/LIBRARY_ISOLATION.md和ValidationLogs/project-isolation-i5-library.json。

2026-10-22 维护进度：R4b本片完成，ReaderSessions真实驱动打开/重试/关闭编排，App保留类型化SDK桥接。最终c0008349 / CI39703522408独立15/15、原生生命周期13/13及编译通过；R4a、原await/发布顺序、字体及定位源码保持。首轮actor方法值接线编译失败与单独夹具14项验证分别留证。I4两片定向门槛已形成，下一阶段I5逐片推进；完整191/R3整组/发布/手机尚未验收，原有产品计划保留，无新IPA。见[本片结果](ValidationLogs/project-isolation-r4b.json)。

2026-10-22 维护进度：R4a会话归属/关闭失效本片完成，Foundation-only ReaderSessions已实际接线/编译；独立6/6、旧1项合格负对照、候选13/13，运行源f516c284 / CI39627814766。原await、旧测试和定位保持，R4b打开/重试/关闭编排待下一片。全项目隔离、R3整组及完整191/Release/手机尚未验收，新产品计划保留，无新IPA。见[本片原始结果](ValidationLogs/project-isolation-r4a.json)与READER_SESSION_ISOLATION。

2026-10-21维护进度：重复定位白图按测试截图边界修正并通过原单例1/1（9aac4d / CI39619940734），生产隔离、分页加载与定位保持。更新后原生窗口与WK像素、原字及外层坐标均过；即时白图保留为对照，首诊误测/失败不改写。下一独立片R4先处理会话请求归属/关闭失效的责任与竞态合同，再拆打开重试关闭编排；本片未实施R4，R3/完整189/Release/手机尚无新的整组验收，无新IPA，产品计划继续保留。见[本片结果](ValidationLogs/repeated-seek-snapshot-boundary.json)。

2026-10-21维护进度：连续返回专项仅补诊断与强化原测试准备，生产隔离和分页加载修正保持。e234b2b / CI39607326744原单例1/1、编译通过，不改写旧5/6、18/19或宣称R3整组验收；旧失败根因仍未知。后续重复seek截图空白但坐标断言过，独立可见性疑点留待下一片，本轮不追加CI、不进R4；完整189/设备Release/手机未验，无新IPA，产品计划保留。权威[本片结果](ValidationLogs/continuous-return-preparation.json)。

2026-10-21维护断点更新：本轮只查EPUB首次跳正文，取得旧1项合格失败/新加载屏障成功；候选整组5/6，原例分页分支已过，连续返回3px断言仍失败。用户选择保存本片，下一轮只查连续返回，R4不启动。R1/R2/R3源码、独立合同和产品计划保留；本片不跑完整189/设备Release，无新IPA。权威结果见[专项原始结果](ValidationLogs/epub-native-readiness-control.json)。

以下保留各自源与日期的历史记录；当前只以本段及HANDOFF为准。

R3b本片完成（2026-10-21）：现有ReaderPositions接管显式保存的捕获、原预算等待、写库、错误与同步结果发布，App只提供原引擎/仓库的窄桥接；每个已接收进度事件的原Task写入保持。实际源421a5786e2be65baf661bc889c166ac8f22aff41 / [CI39580846569](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39580846569)，独立16/16（原6+新增10）、原iOS定向13/13、Linux工具71/71。导航/返回点与字体导入重开事务、原flush顺序、Core/Vendor/锁及原测试保持。下一片R3导航/返回点；R3整体和全项目隔离尚未完成。未跑完整188、设备Release或手机，无新IPA，最后交付仍Build30。详见READER_POSITION_ISOLATION及ValidationLogs/project-isolation-r3b.json。

以下为各自源与阶段的历史记录，当前断点以本段及HANDOFF为准。

R3a本片完成（2026-10-21）：独立ReaderPositions Foundation包接管完整位置、显式保存身份/失效和保存错误；原捕获/写库await、预算及同步发布顺序保留。实际源755b428a60143d8f649372e6c545cc1e03f82ecb / CI39573863939，macOS独立6/6、原iOS定向13/13、Linux工具71/71；双模式六字体/EPUB/TXT锚点及同宽分页writer回归通过。首轮Core产品接线规划失败已留证并改用既有ReaderSettings包模式。R3捕获/持久化编排和导航/返回点后续继续；完整188、设备Release、手机未验，无新IPA。



2026-10-21最新：分页writer定向补证39561815911完成，同一单用例旧负例1/1、新正例1/1，原字与无位置写入均核；生产9bb6c86保持，下一切片R3未实施。完整188、设备Release/手机仍待独立门槛，不能把本1+1或历史9/9称全量通过。首组屏障越界失败保留；最新事实见HANDOFF与ValidationLogs/paged-font-control-39561815911.json。

2026-10-20，用户确认：现阶段先维护项目、做好功能隔离，再继续后续功能。本文是当前维护路线与产品计划索引；列入计划不表示实现、编译或验收完成。

## 当前基线与边界

- 最后交付是 Build30，Release 源 aa0a119a71b10f1f345bc6f4cd54f6c8b4e2871a，CI39373881574 定向6/6、完整180/180及严格设备Release通过。手机体验仍待反馈，详见 PROJECT_STATUS/HANDOFF 与原验证回执。
- 当前源码已具备 XianxiaCore、ReadingInterfaces、ReadiumAdapter target 边界、独立进度显示和 R1 设置持久化；搜索、字体导入/预览也有现成组件，应复用。
- R2 字体编排已完成本片接线与验收；R3a位置状态/保存身份已在独立包接线并通过6+13；R3c导航/返回点实现及24+6直接合同通过，但整组18/19未验收；先单查EPUB一例，再R4。书库、导入、阅读等多数 App 代码仍在同一 target，目录划分不等于编译级隔离。
- I0/I1验收时：131个Swift源、14区域、15个图节点、4个package图条目（含Vendor），22项边界正反例已随Linux工具61/61验证。ReaderSettings真实模块及快速测试入口已接线，CI39398382008/1545a3c：独立macOS7/7、原iOS设置/生命周期35/35。快速步骤115秒含92.18秒编译，首次iOS接线1763秒含准备/编译/启动/导出；没有重跑全180或设备Release。原算法/7项设置与28项生命周期主体保持，461个Vendor/Core/Adapter/资源/样书/锁保护输入不变。当前回执见ValidationLogs/project-isolation-i1.json；I0原计数保留在其历史回执。

当前位置维护新增1条可控body resize回归，未来完整门槛159+29=188，尚未全跑；不在分页修复中接线R3。最新只以HANDOFF与paged-font-investigation回执为准。

I2历史验收：ReaderFonts真实target、133源/15区域/16节点、23边界正反例；源410343b/CI39418977905同源53/53，Linux工具62/Core137/TXT4通过。原151集成增加7直接字体合同，最终门槛158+29=187未在本片执行。初版与A/B失败保留；断言后连续锚点不匹配在改前也有，带入R3/I6独立观察，不声称完全解决WebKit时序。

## 总体结构

App 组装层创建具体存储、引擎和服务，向功能模块注入最小能力；功能模块通过明确合同交互。现有可用的 Core/Readium 边界保持。按实际功能与平台依赖决定 target，不为每个类新建包。

| 边界 | 单一负责人 | 依赖约束 |
| --- | --- | --- |
| 书库 | 列表、排序、改名、回收站、封面编排 | 不创建阅读引擎，不修改阅读会话内部状态 |
| 导入 | 文件接收、格式与编码选择、导入结果 | 通过元数据/存储能力调用；不控制阅读界面生命周期 |
| 阅读 | 正文呈现与用户动作协调 | 通过 ReadingInterfaces 操作引擎；不直接了解 SQLite/Readium 实现 |
| 设置 | 外观/交互持久化、顺序、完成与错误 | 不持有 Locator、引擎或页面；设置应用属于阅读协调 |
| 字体 | 目录、导入、校验、预览与失效 | 复用现有 import/preview 服务；浏览不重开正文，明确选中才发出应用请求 |
| 搜索 | 查询、增量结果、取消、跳转请求 | 使用可选搜索能力与不透明完整位置；旧清理不影响新查询 |
| 阅读位置 | 完整位置捕获、保存、失败保旧 | 接收明确会话身份；不管理字体目录/主题/页面关闭 |
| 阅读会话 | 打开、重试、关闭、任务与回调失效 | 唯一生命周期负责人；旧完成不能影响新会话 |
| 基础设施与领域 | 数据库事务、文件、编码/索引、引擎适配 | Core 不引入 UI/Readium；跨文件/数据库操作保留现有事务合同 |

窄协议按需要放在已有边界或所属合同模块，避免建立另一个包含全部业务的共享服务。逐步收紧 AppServices 的使用；先迁移直接依赖，再删除例外，不用空协议或移动文件冒充隔离完成。

## 实施顺序与每片门槛

| 切片 | 范围 | 完成证据 | 当前状态 |
| --- | --- | --- | --- |
| I0 依赖基线与检查 | 实际源/工程/target依赖清单、允许方向、待消除例外、循环与越界检查 | 真实项目可通过；注入禁用依赖/循环/未知功能的反例被拒绝；例外有明确文件和原因 | 已落地，本地与CI守卫通过；当前计数与工具结果见I1 |
| I1 快速验证入口 | 隔离逻辑测试、真实引擎合同测试、原生UI入口与影响映射 | 设置等逻辑可独立验证；未知影响不能静默跳过；保留完整发布门槛与真实退出码 | 本片完成：设置独立7/7、原iOS35/35，原引擎/UI入口保留，映射未知范围保守；完整发布留I6 |
| I2 / R2 字体编排 | 从 ReaderViewModel 提取目录/刷新/选择编排，复用导入和预览 | 浏览不重开、明确选择才应用、取消/修复/迟到结果及旧字体定位回归通过 | 本片完成：实际target编译、修正源53/53；失败历史及独立位置观察保留，完整发布留I6 |
| I3 / R3 阅读位置 | 完整捕获、保存、错误与会话身份 | 完整 Locator/TXT锚点、乱序/关闭/失败保旧及真实重开位置保持 | 原24+6合同及分页加载修正保留；返回原单例与更新后截图本片1/1，历史18/19与5/6不改写，整组/发布未重跑 |
| I4 / R4 阅读会话 | 统一打开、重试、关闭及异步失效 | 打开中关闭、重叠打开、迟到加载/位置/字体结果不能影响新会话 | R4a归属6+13与R4b编排15+13均已实际编译及定向通过，原await/定位保留；全项目/完整发布留I6 |
| I5 App功能边界 | 书库状态/组装、导入事务/元数据、搜索合同/请求三片完成；批次UI与呈现仍App桥接 | LibraryShelf6+原生18、BookImports8+原生14、ReaderSearch8+原生13及各片编译通过；不混称同源完整结果 | 本计划三片定向门槛完成；App UI未整体独立target，整体验收留I6 |
| I6 发布与可维护性验收 | 同源最终回归、原生范围复核、设备反馈、交接与剩余例外 | 逐项报告实现/编译/定向/完整/原生/设备结果；各片输入不混称一次通过 | 最终full191/192、UI29/29；唯一连续视口缩放失败已留证，用户已决定本轮保存断点、下一轮只查该单例；Release未执行，无新IPA/手机验收，不自动整套重试 |

每轮只推进一个可独立验证的切片，不一次完成整表。出现其他边界失败时先留证并判断关联；必要时可阻塞发布，但不自动混入修复。开发检查不为每个小编辑导出 IPA；生产/UI输入变化的最终发布仍须同源完整验证。

I0 的精确依赖与例外应来自实际源码，不用宽泛通配白名单锁住当前坏依赖；测试源码、平台桥接和组装层分别登记。检查器本身需要正反例，证明它能阻止边界回退。

I0现有入口：`python scripts/check_architecture.py --report build/maintenance/architecture-current.json`；默认仓库检查也执行同一守卫。登记见architecture-boundaries.json，工具反例见scripts/test_architecture.py。守卫用现有固定版本tree-sitter解析真实Swift import和三个第一方Package.swift，并读取project.yml，扫描登记根目录及实际target源码路径，拒绝新区域/target、未登记导入/依赖、包/target循环、错误源码归属与失效例外。常规目录外新target曾有漏扫，合格负/正对照与修正后完整结果均保留，不用旧19项结果替代最终20项结果。现有3个App具体适配依赖、2个Readium集成fixture分别登记，不把它们称为隔离完成。Vendor内部依赖仍由既有来源/锁校验负责；动态manifest、新源选择语法需审阅，静态守卫不执行Swift manifest、不做类型或链接检查。

I1 的影响映射需要考虑反向依赖、共享配置、资源、测试宿主与工程变化；无法确定影响时采用保守验证范围。先建立检查入口，再讨论缓存/CI细分；两者是不同交付。本片实际115秒仅为设置逻辑步骤，首次迁移的iOS接线仍约29分钟；不据此承诺其他模块或整条发布CI相同提速。等待CI使用状态变化与有界摘要，完整日志留在产物中，避免反复把无关日志送入上下文。

## 新功能接入合同

以后每个功能开始前明确：所属模块与状态负责人、允许依赖、持久化所有权、任务取消与迟到结果规则、独立测试入口、跨模块合同及发布门槛。缺少这些信息时先补设计，不继续把状态塞进 ReaderViewModel/AppServices。

跨功能调用通过明确能力与组装协调；共享状态只有一个写入负责人。错误归属与诊断标记指向模块/阶段/请求，避免输出正文、个人文件或未来知识。测试使用隔离存储/偏好、清理窗口与方向、显式控制异步屏障。

未来知识库/XBook仅保留既有设计文档及必要接入规则。未进入相应阶段前不建立实体库、空运行target、抓取、云账号或其他新产品能力。

## 后续产品计划保留清单

维护期间暂停新增产品功能；现有可用性回归和用户反馈仍需处理。以下保持原阶段与候选属性，不因本清单扩大授权或提前实现。

| 顺序/性质 | 保留内容 | 来源与限制 |
| --- | --- | --- |
| 已有功能继续保全 | EPUB/TXT、书库、搜索/书签、完整位置、主题/字体导入、自动慢滚、回看返回 | 以最新状态与逐版回执为准；不当作待重做功能 |
| M4剩余与独立候选 | 单书排版记忆、字体删除/管理、自定义配色/独立四边距、页面亮度；音量键公开API可行性验证；仿真翻页/触感为候选 | ROADMAP、FEATURE_MATRIX、READING_FEATURE_IDEAS；不承诺全部一次实现或音量键一定可行 |
| 阅读特色候选 | 续读接头、可隐藏全书进度、本章剩余/预计时间、离线听读与定时停止 | READING_FEATURE_IDEAS；本地有界处理，保持位置与性能合同，听读需另核系统能力 |
| M5性能与长篇验证 | 100/300/500万字、1000/3000+章；导入/阅读/重开/目录/搜索的耗时、内存、卡顿与耗电 | ROADMAP、PERFORMANCE_TEST_PLAN；模拟器或桌面数据不代替手机实测 |
| MVP稳定化与后续增量 | 无障碍、iPad/旋转、File Provider、升级迁移和异常/设备矩阵；高亮/笔记、Readium Decorations/TTS分独立阶段 | ROADMAP V0.6–0.8、FEATURE_MATRIX；高亮/笔记仍未建运行实体 |
| 发布与稳定阅读器 | 签名发行、隐私/许可、长时间阅读与升级回归，普通设备/TrollStore分开验收 | ROADMAP V0.9/V1.0；核心EPUB/TXT先稳定 |
| 更后独立版本 | XBook；无剧透人物/别名/境界/势力/物品/功法/地点/关系/事件、地图与剧情摘要 | Future/XBook/SPEC、Future/Knowledge/README；当前均草案。知识卡文档中的M5候选不等于批准在M5实现；优先服从稳定阅读器之后的阶段门槛 |

无剧透边界继续由已验证 canonical chapter 限制数据读取；缺失映射拒绝显示，不先读未来资料再由界面遮挡。上述“后续”不是新的开发日期或交付承诺。

## 已核参考与取舍

2026-10-20已读取以下原始资料；外部主分支链接为查阅快照，不是本项目锁定依赖或可直接移植的补丁。

- [SwiftPM PackageDescription](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)：target/module及显式依赖。沿用本项目Swift tools5.10、App Swift5模式、iOS16和Xcode16.4，不直接采用新工具链专属API。
- [isowords Package.swift](https://github.com/pointfreeco/isowords/blob/main/Package.swift)：功能target、客户端接口/具体实现及独立测试依赖。查阅版本tools5.9、最低iOS17且使用TCA；只参考依赖方向，不迁移TCA、不提高本项目iOS16下限、不复制其Homebrew SQLite配置或几十个细碎target。
- [Readest代码布局](https://github.com/readest/readest/blob/main/apps/readest-app/docs/code-layout.md)：settings/font/library/ingest等职责分别组织。它是React/Next.js/Tauri架构；只借鉴职责，不引入Web架构、插件运行时或云服务。本项目R1对应固定revision参考见READER_ISOLATION_PLAN。

总体验收标准：越界依赖能被拒绝；每块状态和异步清理有明确负责人；模块逻辑可以独立验证；跨模块流程有真实合同测试；新功能有明确接入规则。完成部分切片不能宣称全项目隔离或所有故障均不会跨模块。
