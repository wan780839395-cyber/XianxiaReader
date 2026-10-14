# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 最新实际断点

2026-10-14 remote compact 失败后恢复检查点：已按 AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE 读取。实际 HEAD 为 `6d76174`，工作区有 10 个已跟踪改动及未跟踪 Vendor/ReadiumToolkit、许可、千章样书与生成器；均保留并在 `.cache/recovery/` 保存含逐文件 SHA-256 的恢复快照。尚无本轮连续模式编译/CI/设备验收证据，不能将下文旧“Git clean/尚未实现”当当前源码事实。未发现属于本项目的遗留构建/测试进程；其他项目及 Codex 进程保持原状。恢复从本地扩展源码/工程/测试审查开始，先修复验证入口与可验证缺口，再真实解析及完整 CI。

恢复子步骤1（测试/CI前）：370个中断文件快照在 `.cache/recovery/20261014-092934/`。GitHub 最近run仍是38434939423/Build3，无连续模式run；`build/logs/continuous-docker.stderr.log` 的实际失败是 dockerDesktopLinuxEngine pipe不存在，没有挂起的项目Docker任务。本轮不重置Docker。已补Vendor完整文件/hash核验和Vendor Swift grammar覆盖，新增真实首次解析开关；只有真实resolver生成并通过原10个传递pins对比的锁才能进入测试。首轮解析artifact须原样纳入根锁文件，并关闭开关完整重跑，不能手造锁文件。现准备Windows结构/语法/tooling验证，再以独立 `codex/` 候选分支快照运行macOS CI；本地main及所有未提交改动保持可恢复。

恢复子步骤2（首轮CI前）：Windows结构/SQL/四本EPUB、362 Swift语法delta通过，9原tooling通过。新增Vendor来源/锁漂移回归待运行。tree-sitter在原始3.11源码有54条已知语法限制，已逐文件与真实3.11 Git blob/hash核对并记录精确诊断签名；没有新增诊断，这不是Swift编译通过。连续候选已有双章同屏/逆向、fragment+DOM恢复、高度变化、千章窗口与关闭回归，但均尚待实际执行。候选分支拟为 `codex/m1-continuous-recovery`，以独立Git index生成快照，不暂存/清理本地main改动；首次真实解析run需保留完整diagnostics和锁文件。

恢复子步骤3（样书生成/再测试前）：首轮真实解析/CI `38496501326` 在候选 `4c78f77` 已启动，repository-checks和Linux Core job成功，macOS job进行中，尚未取得resolver锁/编译结果；本地仍main/6d76174且原暂存区未改动。13 Python/tooling通过。继续源码审查后补字符级DOMRange+局部视口偏移（原生Readium Locator的扩展字段）、异步视口identity过滤、未ready禁止发出假位置、显式关闭连续资源/JS handler；新增超长单段恢复/搜索与模式切换/释放WebView回归。以下生成更新原创reader-layout并核验来源hash/静态检查，新增代码不属于已启动run，必须再跑完整CI。

恢复子步骤4（实际解析后、下一完整CI前）：38496501326已结束，repository-checks成功、Linux14 Core成功；macOS真实依赖解析成功，随后依赖核验拒绝了意外精简，Swift/iOS tests/Release/IPA未执行。完整下载日志与diagnostics在 `build/ci/38496501326/`。逐pin对比实际resolver输出：保留的6 pins版本/revision/location与Build3全部一致；因裁剪未使用target/product移除GCDWebServer、SQLite.swift、CSQLite、SQLCipher.swift和远程swift-toolkit，没有升级。已明确登记四个未使用传递pin的移除范围，原样采用该run生成的6-pin `Package.resolved`；不得手写pin/originHash。新增修复/回归现在走关闭bootstrap的严格锁文件完整CI。首轮失败是校验器要求保留未使用依赖，不是编译/测试失败。旧Build3 IPA仍为唯一已通过完整CI的产物。

恢复子步骤5（后续可恢复点）：严格锁CI38497134015在候选1a56205运行，static/Linux Core jobs成功，macOS job进行中；不得根据UI旧尾部推断未运行阶段。后续本地修正已限制精确锚点恢复只作用于标记的连续保存Locator，防止覆盖搜索命中的文本定位；新增布局失败可见重试+原锚点恢复，模式往返等待真实页面就绪，长段测试先等待导航动画完成。现在共7项连续渲染回归（预期31+7=38 iOS tests），尚未执行最终版本；须候选更新后完整CI。阶段状态/架构/设计文档已同步“候选未验收”，不进入M2/M4。第一轮实际解析失败范围已写入ValidationLogs/m1-continuous-resolution-guard.json。

恢复子步骤6（修复/再次构建前）：38497134015完整结束，已下载全日志/xcresult/Crash .ips/快照到build/ci/38497134015。strict resolve与Swift/iOS编译通过；Linux/macOS各14 Core、原31 iOS通过，6个连续tests崩溃，test exit65/attachment export0，Release/IPA未执行。Crash堆栈证实EPUBViewportAndLocationCalculator的非隔离async路径调用progression闭包，后台读取UIScrollView.contentOffset被Main Thread Checker终止；不是CI取消或工具挂起。修复为在MainActor先快照可见范围/progression数值，再传纯数值闭包，两条阅读路径都处理；不禁用checker/测试。另补等待未加载DOM的探针和保留原搜索Locator语义、布局失败重试/长段等待/释放回归。CI新增完整xcresult汇总artifact，保留原test/export/summary失败退出码。接下来刷新已审阅来源hash，Windows验证和38 tests完整CI；旧Build3产物不覆盖。

恢复子步骤7：Windows362 Swift grammar delta/四本EPUB/hash及14 Python tooling通过；严格锁全套CI38498560012已在候选871518c917b5f44c48595105253b6cb4cfb054b7启动。预计38个iOS tests须核对完整xcresult汇总；不得把前轮最后重启suite的12 tests成功当整轮成功。当前本地main/6d76174、原index/未提交改动仍保留；没有本地挂起工具或新IPA。等待这轮实际结果，再按完整日志/xcresult/快照修复或验收自动门槛；真机/惯性/原书仍独立待测。

恢复子步骤8（进一步修复/构建前）：38498560012已完成并下载到build/ci/38498560012；xcresult summary实际34 passed/4 failed/0 skipped/38 total，test65、export0、summary0；无Main Thread Checker违规/重启。原31保留，双章同屏+逆向、失败重试、千章窗口/释放三项新回归通过；已人工查看真实跨章PNG，前章尾与第二章标题/正文同屏。fragment恢复、高度变化、长段恢复、搜索/模式往返四项超时，没有Release/IPA。现补timeout的实际Locator/DOM/物理viewport诊断和等待最后位置回调（保留原几何断言）；模式重建前异步采集当前实际DOM锚点，request ID/Task取消防止旧切换作用于重开session，并加迟到模式切换回归。加载失败将无效旧offset重置到可见重试区，加强重试按钮实际在屏内断言。预期31+8=39 tests，下一完整CI；未把部分通过写成完整验收。

恢复子步骤9：Window362grammar/hash/四本EPUB和14tooling再次通过。完整严格锁CI38500755762已在候选18f528d07d6fe75a6e07bc2e1ad742549299fdc7启动，repository/Core jobs成功，macOS执行中。本地main/index/未提交改动保留；仅HANDOFF/状态后续记录不同于候选，其余待验证源码保持同一快照。最新自动门槛仍是前轮34/38部分通过；下一可恢复点是取本轮完整summary/log/timeout附件，按具体坐标修复剩余锚点或核验39tests与Release产物。不要用旧Build3/前轮截图代替本轮结果。

恢复子步骤10（实际坐标诊断/下一构建前）：38500755762完整下载到build/ci/38500755762，summary为36/39 passed、3 failed、0 skipped；fragment恢复、迟到模式切换/重开新增回归通过。高度变化/长段/模式往返仍超时；height实测inner offset446，line12 top857.875（对应documentY1303.875），long手动+600后inner offset仅600而long top1167.875，mode往返落到h1。源码审查发现容器layout可在原生go期间重写inner offset，且Readium isSpreadLoaded在0.2s延迟初始定位前置true；这两处是本轮候选原因，未假定唯一根因。已增加slot.positioning暂停同步，完整初始定位/decoration就绪await，clear/超时必恢复continuation；分页转连续也等待该初始化完成再取真实DOM。保留39个tests/原断言/Main Thread Checker，接下来刷新hash/grammar并完整CI。旧Build3仍唯一成功Release IPA，本轮没有新IPA或本地挂起任务。

恢复子步骤11：严格锁全套CI38503347131已在1182a8fd2f193256950dc18faa974f8881f5e061启动，Windows362grammar/hash通过，14tooling未修改仍通过。repository/Core jobs成功，macOS进行中；下一步核对39tests summary及Release。原恢复ZIP的CRC与370个文件SHA-256全部重新核验匹配（verified.json），本地main/index仍原样。build/XianxiaReader.ipa现有SHA仍为Build3的12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2，未覆盖。当前已测断点仍36/39部分通过；完整M1/设备均不放行。

恢复子步骤12（又一完整结果后/下一CI前）：38503347131结果/全日志/summary已下载，模式往返通过，但height/long及retry坐标仍失败，Release/IPA未执行；准确数量见ValidationLogs/m1-continuous-native-offset-lag.json。暂停layout同步/完整初始化等待没有解决全部重置，不把前轮猜测当已证实单一原因。继续修正为从JS window.scrollY读取go后的实际文档坐标（原生UIScrollView值可滞后）；显式目录/搜索/书签go用原子外层定位，避免旧动画覆盖高度补偿，正常用户drag/deceleration及上一屏/下一屏不改。caret额外验证横轴可见性。以下仅刷新hash/grammar后全套39 tests CI；保留失败日志和原断言，没有新IPA。

恢复子步骤13：严格锁CI38505001863正在测试候选b68ac63deed11d009992b6d8d861e81eb862d2dc，静态/Core jobs成功；Windows362grammar/hash通过，14tooling无源码变更。仅文档更新不同于候选源码。已检查本地gh进程，无旧下载/挂起任务（只有本轮状态查询瞬时进程），Git暂存区仍为空，所有原改动保留。下一步必须读取本轮实际summary、39条test结果/完整日志与Release产物；当前最新已完成结果仍36/39部分通过，没有新IPA，不放行完整M1或设备。

恢复子步骤14（新诊断后/再次CI前）：38505001863失败，完整日志/附件已下载；长段实际innerY2367、long top-599.125已正确，但Locator仍charOffset2，说明旧缓存未失效；height仍inner446，另首个boundary cold load停about:blank/position nil。源码发现layoutSlots无条件覆盖lastTrackedOffset可掩盖didScroll增量，已只在主动锚点补偿/空窗口重置时更新；measure锁定同一savedAnchor/revision后采用绝对DOM锚点目标，拒绝旧异步测量覆盖新锚点。未ready WebView提供非hidden/有效frame启动Readium rAF，不扩展contentSize或展示未加载邻章，loading/retry控件置前。Windows362grammar/hash通过，保留39 tests和20s watchdog/原断言；下一全套CI，未生成Release/IPA。准确summary稍后核对，不将新修复写成已通过。

恢复子步骤15（第七轮完整结果/下一CI前）：38506979070/8908e98实际38/39 passed、1 failed、0 skipped，Linux/macOS各14 Core；跨章/逆向、fragment、高度重排、可见重试、搜索/模式往返、迟到模式、千章/释放均通过。仅长段字符缓存回归超时，完整日志/summary/附件在build/ci/38506979070。继续收紧measure补偿要求slot.anchorRevision也等于本轮viewportRevision，避免滚动后触发的resize使用旧savedAnchor；新行尚待完整CI。Windows362grammar/hash通过；不得将38/39写成全通过，Release/IPA仍未生成，Build3与原改动继续保留。

2026-10-14继续开发检查点：已核对Git clean、最新Build3报告和无遗留任务。当前开始真正纵向连续跨章独立M1切片。方案为保留Readium3.11上游来源与BSD许可的本地Navigator扩展（非官方已合并功能），使用有界章节窗口及固定尺寸WKWebView viewport，复用Readium解析/资源/CSS/DOM定位。正式源码/依赖/锁文件变更均须真实解析与完整CI，当前尚未实现/编译。旧Build3产物与原分页/章内滚动/搜索回归保留。

M0自动门槛通过；M1搜索、导入、阅读视口/图片切片已通过完整CI，**完整M1尚未验收，真正纵向无缝跨章未实现**。本轮构建/下载/产物核验/原创样书快照复查已完成；无运行中的项目构建/测试或未完成登录/UAC。下一步是现有iPhone13上复测原书图片，并继续独立M1连续滚动引擎切片，不进入M2/M4。

已测源码 `0b30d539d7eb6d557d8b5e5e8efad600c4c4435b`；[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)三jobs全部success。Linux/macOS各14 Core、31 iOS tests、设备Release、Build3 IPA通过。9 Python/tooling和42 Swift grammar通过，grammar不是编译；应用源码compiler warnings=0，6 AppIntents metadata提示单列保留。11依赖pins不变。

本轮保留前次所有导入、viewport、导航、搜索和生命周期改动；没有删除测试、降低图片断言、修改原书/数据库/依赖版本。源码提交已推送main，证据文档收尾提交用skip-ci。

## 产物与验证范围

- 最新IPA `build/XianxiaReader.ipa`：7,393,693 bytes；SHA-256 `12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2`。Build3 /version0.0.1 /com.xianxiareader.app /最低iOS16 /iPhoneOS arm64 /系统SQLite /0755 /ZIP核验通过，CODE_SIGNING_ALLOWED=NO。
- 测试ZIP `build/XianxiaReader-iPhone13-TestKit.zip`：7,296,582 bytes；SHA-256 `02df81e145ffbe4f6a30dbceb6e23c6e69a52e07d78fcbe56e44d5935086722a`。包含上述IPA、chinese-epub2/3和reader-layout三本原创样书、TESTING.txt；CRC与内部IPA hash已核对。
- 完整日志 `build/logs/ios-build.log`；原IPA/Core日志、生成工程/环境/锁文件、SimulatorTests/DeviceBuild xcresult、ReaderSnapshots和测试ZIP备份在 `build/ci/38434939423/`。旧Build2和更早包仍在各原run目录。
- `Documentation/M1_READER_VALIDATION_REPORT.json`：69个构建/验证来源hash匹配已测提交、实际test列表、完整日志/IPA/快照hash、命名附件和DOM尺寸。
- 分页实际正文视口750点、图像712点；滚动812点、图像771点。两张WKWebView快照已查看，原创新封面上下色带完整、比例正常。模拟器为iPhone16Pro/iOS18.5，**只验收原创样书图像，不代表完整模拟器产品/原书/普通设备/TrollStore体验验收**。

## 用户反馈与本轮实现

设备iPhone13 /iOS16.6.1 /TrollStore。用户报告先前安装正常；导入修复后EPUB可以导入（本地/iCloud来源未细分），原书阅读图片仅显示窄横条。用户明确要求上下滑动时本章末尾与下一章开头在同一滚动流中，参考微信读书，不是加下一章按钮。

- ReaderSurface显式完整viewport，独立于菜单；Adapter采用官方frame/autoresizing挂载。
- 横排重排媒体通过公开setupUserScripts按实际innerHeight校准ReadiumCSS原95%媒体保护；不改作者width/aspect/object-fit或原文件，固定布局和竖排保留原路径。
- 目录/书签成功跳转收菜单，关闭/重开过滤迟到导航；搜索跳转同样核对请求ID。
- 当前滚动是章内模式，恢复默认横向跨资源/上一节下一节通路；这**不是**真正纵向连续跨章。
- 3实际页面测试、2导航竞态回归新增；原26 iOS/Core及原2本搜索80命中回归保留。新reader-layout.epub为独立高封面/长短章样书。

原书/CSS未取得，不能认定原书唯一裁切原因；当前Build3安装与原书图像仍待用户复测。TXT仅索引协议，导入/正文/分章未实现。完整书库、字体/主题/排版/音量键、百万字性能、XBook知识库仍按原路线。

## 本轮失败与修复证据

1. 38424689048 /336b21a：App Debug编译完成，test bundle链接静态ReadiumNavigator具体类型metadata失败，31 tests/Release/IPA未执行。改用已有容器的公开UIKit/WebKit查询，保留断言。
2. 38426725252 /43d4b37：31 tests执行，30通过/1导航探针超时。改为双轴可见性交集+对应原生Locator就绪，保留超时最后DOM/位置；不能只看DOM readyState或垂直交集。
3. 38430692977 /7221274：导航/菜单回归通过，图像830.3点大于正文812点，原上限断言失败。校准实际媒体上限并增加尺寸附件；失败也导出快照再返回原test exit，test/export任一失败都停止Release/IPA。9 tooling tests覆盖此控制流，最终本轮完整通过。

三条原失败记录在Documentation/ValidationLogs/m1-reader-*-failure.json，完整日志/xcresult在各原run目录。过程检查点 `HANDOFF_M1_READER_HISTORY_2026-10-14.md` 保留，历史“运行中”不覆盖本文件。

## 下一可恢复步骤

1. 将测试ZIP传到现有iPhone并解压，分享IPA给TrollStore正常更新；保留应用/书籍数据，不卸载或删除数据库。先复测原书图片，再导入reader-layout检查上下标记；目录/链接、搜索/书签、章中段后台/重启恢复分别记录。见DEVICE_ACCEPTANCE.md。
2. 按CONTINUOUS_SCROLL_DESIGN.md实施真正纵向连续跨章：有界资源窗口、双章同屏/正反向惯性、延迟图像高度变化、原始Locator/搜索/书签/恢复全套回归。保持Readium排版/稳定分页路径，不拼接整本HTML，不用瞬间跳章冒充无缝。
3. PR811仅在忽略cache做apply --check通过，未应用/运行；初查整本估算空白与仅按progression定位缺口。正式依赖仍3.11，不直接切未经验证的PR，不改SourcePackages缓存。引擎扩展须明确版本/许可证/补丁、真实解析锁文件并完整CI。
4. 每个可恢复子步骤/生成/构建/测试前更新本文件，阶段后同步PROJECT_STATUS/ROADMAP/ARCHITECTURE及FILE_INVENTORY。没有新任务/自动化时不宣称后台永久维护。

## 环境与历史边界

Windows11 /PowerShell7.6.5 /Git2.54 /Python3.11，本机无Xcode/Swift；CI macOS15/Xcode16.4/Swift6.1.2/iOS18.5，设备最低iOS16。Docker Desktop4.95.0/engine29.8.2已恢复，用户原容器/socket备份保留，不reset/prune。

私有仓库 https://github.com/wan780839395-cyber/XianxiaReader ，main跟踪origin/main，CLI已授权，路径.cache/tools/github-cli.json，不输出令牌/重新生成设备码。Root Package.resolved来自真实CI，复制到workspace，resolve/test/build严格使用11 pins。project.yml唯一工程源；禁止localhost HTTP主要预览。

旧M1_IMPORT_VALIDATION_REPORT.json属于Build2的26 tests/54 hashes，M1_SEARCH属于此前搜索，IOS属于M0，CORE是本机Linux，VALIDATION_REPORT仅静态；不混合覆盖。旧38409222759由Agent提前取消，当时26 tests已过、Release中断，不写成源码失败。各历史handoff/失败记录保留。

GitHub artifacts保留14天；忽略的build/.cache不随clone。当前cache有inspect_ci_ipa/record_reader_ci/make_reader_testkit/finalize_reader_docs辅助脚本；不存在时按README重建CI并核对报告，不能假定cache已保存。恢复先读PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核对实际Git/进程/完整日志与hash，不用聊天记忆替代事实。


## 公开仓库后恢复检查点归档 2026-10-14T05:54:27.544181+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 当前进行中的恢复步骤

再次中断恢复核验（2026-10-14）：远程公开状态PUBLIC；main/HEAD6d76174、原index为空、候选ad555ab及所有未提交源文件仍在。CI38513634971已完成，不再运行；完整日志/xcresult已下载，Linux/macOS各14 Core、iOS39/40通过/1 failed/0 skipped。模式往返和新增迟到termination回归通过；仅长段字符回归343失败：outer3119/DOMscrollY2367/长段top约-599，Locator仍charOffset2。没有新Release/IPA，没有挂起的本地构建或下载。缓存元数据里89a/008e607是旧记录，最新候选以实际Git ref和CI head ad555ab为准。

本轮继续：给DOM锚点缓存补充实际可见文档localTop作为key，避免UIKit布局先于scroll delegate回调时revision未改变而复用旧字符锚点；measure恢复也核对相同文档窗口，await返回核对localTop。失败诊断增加公开DOM caretOffsets。原charOffset>100/恢复3px断言不降低，40条测试保持；即将静态核验/更新来源hash，再完整CI。新改动尚未编译，39/40属于ad555ab历史候选。

2026-10-14：用户明确同意将GitHub仓库公开，采用公开仓库标准runner的免费构建方案；没有授权付款或增加支出限额。正在核对远程main与codex/m1-continuous-recovery的所有可达历史，检查凭据、个人小说及构建包。检查完成后修改可见性并通过API确认，再对最后候选重跑完整CI（resolve_local_readium=false）。本地HEAD/main与暂存区仍保留，候选分支当前文档快照008e6075bb9acd4418d539608cebde19f4ef1dfc包含89a46ce的同一运行源码；尚未重新编译。

公开前核验：远程仅main与上述候选两个分支，无tag/release；27个可达commit、718个历史blob和64份已下载CI日志未发现匹配的凭据。历史书籍仅四本原创样书（六个版本），无证书、个人小说、数据库、IPA或大构建缓存；两份requirements TXT误报已核对为依赖清单。模式扫描不能保证检测所有秘密，但本轮检查没有待处理发现。原始审计结果保存在.cache/recovery/publication-audit.json。即将修改仓库可见性；尚未执行新CI。

可见性步骤已完成：gh repo edit成功，GitHub API返回visibility=PUBLIC/isPrivate=false。没有修改账单、支付方式或付费限额。下一步对候选分支008e607（与89a46ce相同运行源码）手动执行完整workflow，bootstrap=false；仍使用标准ubuntu/macOS runner，原先账单拒绝记录保留为历史，不能提前把新候选写成通过。

公开后完整CI已触发：run38511938460 / head008e6075bb9acd4418d539608cebde19f4ef1dfc / resolve_local_readium=false。repository-checks已有真实步骤并成功，Core正在执行；iOS与Release尚未产生结果。恢复时先查询该run，禁止重复触发同一验证或从旧账单错误推断仍被阻止。最新候选未编译/38-of-39结论在本run完成前继续有效。

run38511938460现已完成：Linux/macOS各14 Core、iOS37/39通过、2 failed/0 skipped。长段测试在跳转阶段返回navigationFailed，未到字符断言；模式往返回到h1/scrollY=0。测试真实exit65、附件导出与summary各exit0，设备Release/IPA未执行。完整日志/xcresult与37/39 summary已下载到build/ci/38511938460。新候选已编译，但完整M1仍未验收。

继续定位发现已clear的EPUBSpreadView仍保留delegate，WebKit迟到termination可通过无资源身份参数的回调触发Navigator reload；取消的加载任务也在检查取消前调用delegate。该路径是可验证代码缺口，是否解释以上两项失败仍待回归。当前补充clear断开全部UI/WebKit delegate、加载完成前检查clear/cancel、termination拒绝已clear回调，并增加真实窗口的旧WKNavigationDelegate迟到事件回归。即将核对来源hash、Windows静态/tooling并重跑完整40项iOS CI，不能提前宣称修复通过。

生命周期修复与新增回归已通过Windows362文件grammar（原始54限制/新增0），14 Python tooling通过，来源hash/真实6-pin锁核验通过。即将使用独立临时Git index创建候选快照并推送原codex分支，再手动完整CI；本地main/HEAD6d76174和原暂存区继续保持不动。

新源码候选ad555abf11b5362cf457904c49b12d5630aacd41已正常推送，完整CI38513634971实际head匹配，bootstrap=false；repository-checks通过，Core执行中，40项iOS尚无结果。新候选历史与68份日志再次模式扫描无待处理发现；旧Build3 IPA hash仍一致。中断恢复先查这个run，不要重跑旧008e607/37-of-39源码，也不要假定新修复已经编译。

## 最新可验证断点

remote compact恢复与本轮开发已完成到可恢复检查点。工作区仍在main，HEAD `6d76174`，原暂存区保持为空，所有原未提交改动保留；没有reset/stash/清理个人数据。原370文件恢复ZIP在`.cache/recovery/20261014-092934/`，CRC及每个SHA-256全部匹配。完整阶段检查点和原Build3证据保存在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。

**最新已执行：CI38506979070 / 源码8908e98151ff021092721639aed274c660335d87，Linux/macOS各14 Core、38/39 iOS通过，0 skipped。完整M1未验收，没有新Release/IPA。** 唯一未通过的是长段字符锚点回归，其余双章同屏/逆向、fragment恢复、图像高度变化锚点、可见失败重试、搜索/模式往返、迟到模式切换、千章窗口与释放均通过。真实双章同屏PNG已人工查看，但不代表拖动惯性、全模拟器阅读或设备验收。

**最新候选：codex/m1-continuous-recovery / 89a46cee6ec96f665ae8b7b8d39047214fb11459。** 在上述已测版本基础上仅进一步要求reflow使用的anchorRevision等于viewportRevision，防止滚动后的resize恢复旧锚点。该行已过Windows grammar，尚未重新编译/运行。

**CI38508277189未启动任何job步骤。** GitHub check annotation原文：The job was not started because recent account payments have failed or your spending limit needs to be increased. Please check the 'Billing & plans' section in your settings。没有Core、Swift编译、iOS test、Release执行；不是源码失败，也不是Agent取消。该run的步骤为空，无build log可下载。原始run/annotations在build/ci/38508277189，拒绝证据在Documentation/ValidationLogs/m1-continuous-billing-not-started.json。不要无意义重试，也不要擅自改账单/付款/支出限额。

## 已实现的候选范围

- Vendor/ReadiumToolkit为官方3.11.0/revision d82f44f4f05d87add9e22a8b75abbd61dce745dd的本地维护扩展；原BSD许可、作者出处、基线/修改SHA及审阅依赖在UPSTREAM.json。不是官方合并功能；不修改SourcePackages缓存。
- 真正纵向连续资源窗口，最多12个WKWebView；章节wrapper按实际DOM高度排列，WKWebView保持固定viewport。前后资源回收，未ready章节保留加载/重试边界，不为全书分配巨大空白。已测两章物理同屏及逆向，不用章末go冒充无缝。
- 完整Locator保留href/CSS/text/位置与progression；新增DOMRange字符锚点、版本1局部视口偏移、64字符上下文。搜索Locator继续用Readium文本匹配。长段最后一项仍待新候选验收。
- MainActor采集UI数值快照，异步纯计算不读UIScrollView；epoch/revision/identity过滤迟到位置与测量。原有31个回归保持。
- 完整初始化等待（不是只看isSpreadLoaded/DOM readyState），原生go期间暂停同步；读取DOM scrollY，目录/搜索/书签原子定位。模式转换取真实DOM，关闭取消旧切换任务/待加载窗口及JS handlers；普通drag/deceleration和按屏滚动保留。
- 横排LTR重排支持范围按publication/settings检查；固定/RTL/竖排保留原分页路径。混合布局、真实字体/图片与设备体验继续按M1验证，不进入M2/M4。

## 验证与产物范围

Windows结构/SQL/四本原创EPUB、362 Swift grammar delta、14 Python tooling、bash -n通过。tree-sitter在原始3.11源码有54条精确已知限制，基线内容与真实Git blob核验，新增diagnostic为0；grammar不是编译。完整来源hash检查通过。

首次真实macOS解析**38496501326**，其原始6-pin Package.resolved已原样采用：保留版本/revision/location不变，SwiftPM裁剪未使用server/SQLite/LCP的四个传递pin和远程Readium。以后resolve/test/build严格锁文件，bootstrap保持false。

报告：Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json（最新候选未编译、上轮38/39、外部拒绝与五种验收结果分开）；M1_CONTINUOUS_STATIC_REPORT.json仅静态；每轮失败在ValidationLogs/m1-continuous-*.json。完整下载日志、summary、xcresult/附件在build/ci/38496501326、38497134015、38498560012、38500755762、38503347131、38505001863、38506979070。

现有build/XianxiaReader.ipa仍是Build3：7,393,693 bytes，SHA-256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2。旧测试ZIP/Build2/Build3/报告与日志保留，未覆盖或伪造Build4包。用户iPhone13/iOS16.6.1/TrollStore原书图像、阅读、位置仍待复测；普通设备签名/完整模拟器阅读/原生惯性/峰值内存未验收。

## 下一可恢复步骤

1. 先读AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核对实际Git/进程/hash/运行CI。所有改动仍未提交到本地main；候选分支用于可审阅快照。
2. 由用户处理GitHub Billing & plans的付款/支出限额拒绝，或提供获授权的可用macOS环境；不擅自改账单。工具恢复后对候选89a46cee6ec96f665ae8b7b8d39047214fb11459重新执行完整workflow，resolve_local_readium=false。不要只重跑旧38/39源码。
3. 必须核对39条测试与summary 0 skipped；若长段仍失败，读取timeout附件中的Locator/outer/inner/DOM坐标继续定位，不降charOffset/像素断言。检查全套生命周期/搜索/导入/viewport回归、Core与设备Release CODE_SIGNING_ALLOWED=NO，任一失败禁止IPA。
4. 全套成功后再核验IPA hash/arm64/系统SQLite/0755/最低iOS16/许可，备份旧Build3再提供Build4测试包。iPhone13正常更新保留数据，不卸载、不删数据库；设备/惯性/原书/字体与图像仍分别验收。
5. 更新本文件/状态/设计与FILE_INVENTORY；完整M1尚未放行，TXT、完整书库、M4设置与主题、百万字性能、XBook知识库均不提前铺开。

## 环境

Windows/PowerShell/Git/Python可用；本机无Xcode/Swift。Docker先前实际错误为dockerDesktopLinuxEngine pipe不存在，本轮没有启动/重置Docker或任何localhost服务，也没有遗留自己的本地测试/下载任务。其他项目进程保持原状。GitHub artifacts保留14天；忽略build/.cache不随clone，过期时需在真正可用的macOS环境按锁文件重建。


## 连续引擎检查点归档 2026-10-14T07:08:10.226047+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 当前实际断点

用户再次要求恢复后已按AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE核对文件、Git、进程、完整CI日志及xcresult。仓库经用户授权已公开，API为PUBLIC；标准runner可以正常启动，没有修改账单/付款/限额。旧账单拒绝38508277189仅是历史。

工作区仍在main，HEAD6d761749911233122bcd031fcf718d22a19f9e77，原暂存区为空，所有原未提交改动保留。候选分支codex/m1-continuous-recovery当前ad555abf11b5362cf457904c49b12d5630aacd41。没有reset/stash/覆盖原小说。原370文件备份在.cache/recovery/20261014-092934，已核验全部SHA/ZIP CRC；原始恢复及逐轮检查点在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。

**最新已执行为CI38513634971/ad555ab：Linux/macOS各14 Core，iOS39/40通过、1 failed、0 skipped。** 原31测试、双章同屏/逆向、fragment、图像高度变化、可见失败重试、搜索/模式往返、迟到模式切换、千章窗口/释放及新增旧WebKit termination回归均通过。仍未通过长段字符回归343：页面实际outer3119/DOMscrollY2367/长段top约-599，但Locator仍charOffset2。测试exit65，附件/summary各exit0；设备Release与IPA未执行。完整下载日志/xcresult/附件在build/ci/38513634971/artifacts/XianxiaReader-build-diagnostics/build。

没有仍在运行的CI或本地测试/下载任务（以恢复时查询为准）。旧缓存candidate.json/documentation-snapshot.json里89a/008e607是历史，不替代实际Git ref和CI head。

## 当前尚未编译改动

在已测ad555ab基础上补充锚点缓存的实际文档localTop key，避免布局先于scroll delegate时revision未变而复用旧字符锚点；measure恢复与await返回也核对同一文档窗口。失败诊断增加公开DOM caretOffsets。40条测试保持，charOffset>100与重开3px断言不降低。该补充已过Windows362文件grammar（原始54限制/新增0）和14 tooling；仍不是Swift编译，下一步完整CI。来源UPSTREAM修改hash已更新，6-pin真实锁不变。

## 实现范围与架构

Vendor/ReadiumToolkit是官方3.11.0/d82f44f4f05d87add9e22a8b75abbd61dce745dd的本地维护扩展，保留BSD许可、PR811参考及逐文件来源。不是官方合并功能，不修改SourcePackages缓存。UI经ReadingInterfaces调用引擎，Core保持Foundation/SQLite。

连续模式最多12个资源，章节按真实DOM高度布置，WKWebView固定viewport；显示加载/重试边界并回收窗口。标准Locator href/CSS/text/progression保留，附加DOMRange字符、版本1视口偏移与64字符上下文。搜索复用Readium原文本定位。MainActor快照隔离UIKit，epoch/revision/identity过滤迟到结果；关闭取消任务/JS handlers，回收spread断开UI/WebKit delegate，已clear或取消加载不回调当前Navigator。横排LTR重排支持，fixed/RTL/竖排保留分页。

双章截图人工复查属于原创程序化回归；没有完成原生手动拖动/惯性、峰值内存、完整模拟器阅读、普通设备签名或iPhone13/iOS16.6.1/TrollStore验收。完整M1未放行，不进入M2/M4。

## 验证和旧产物

报告Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json按候选源码hash/实际执行结果记录；M1_CONTINUOUS_STATIC_REPORT.json仅静态。逐轮失败与公开审计见Documentation/ValidationLogs。首次真正解析38496501326的6-pin Package.resolved原样保留；bootstrap保持false，resolve/test/build严格锁文件。

build/XianxiaReader.ipa仍为Build3，7393693 bytes，SHA256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2；原件在build/ci/38434939423/ipa。旧测试ZIP和Build2/3均保留，不把失败CI产物写成Build4。用户原书图像/位置/阅读仍待复测；更新应用保留书籍数据，不卸载/删库。

## 下一可恢复步骤

1. 核对实际Git/文件/hash/运行任务；不要从过时缓存或旧CI可见尾部推断最后成功。
2. 对当前localTop补充创建独立index候选快照并正常推送原codex分支，完整workflow_dispatch，resolve_local_readium=false。若本文件下方已有新run，先查询它，禁止重复触发。
3. 核对40 tests、0 skipped及实际长段结果；若仍失败，读取caretOffsets/Locator/outer/DOM坐标，不降断言。全部Core/iOS通过后才执行设备Release CODE_SIGNING_ALLOWED=NO/IPA。
4. 成功后下载完整日志/xcresult/快照/IPA，核验CRC/arm64/系统SQLite/0755/最低iOS16/第三方许可，保留旧Build3，再提供Build4测试包。原书、手动惯性、普通设备/TrollStore分别验收。
5. 同步PROJECT_STATUS/本文件/必要设计/FILE_INVENTORY。TXT、完整书库、设置/主题/音量键、百万字性能和XBook知识库仍未实现。

## 环境

Windows/PowerShell/Git/Python可用，无本机Xcode/Swift。本轮未启动/重置Docker、未启动localhost、未改变其他项目进程。GitHub artifacts保留14天，build/.cache忽略不随clone；过期需在可用macOS按锁重建。

## 当前运行任务

localTop锚点修复已创建候选54ffd91b1f532debf3a43be73d6a051e1c43bbe3并正常推送；完整CI38519173808已触发，bootstrap=false，预期40项iOS。本地HEAD6d76174/index为空继续保留。恢复先查询此run，不重跑ad555ab/39-of-40，也不假定最后修复或IPA成功。

CI38519173808已完成并下载完整日志/xcresult：Linux/macOS各14 Core，iOS38/40、2 failed、0 skipped；失败在首次currentPosition等待334和重试恢复396，长段charOffset断言未执行，不能判定localTop补充的结果。stock Readium脚本window load后通过requestAnimationFrame发spreadLoaded，未ready的屏外资源可能暂停该回调。现补充WK didFinish/真实viewport+Readium脚本探针启动同一个完整初始化管线，单次启动防止native/JS重复完成取消；clear取消bootstrap task。新增抑制确切spreadLoaded rAF桥的真实窗口回归，验证正文跳转仍完成（预期41 tests）。这不是只凭DOM ready标记ready；CSS/原初始定位/decoration仍全部等待。新补充未编译，即将静态核验/来源hash并完整CI。

native bootstrap补充已过Windows362 grammar/14 tooling，源码候选2a43ccdd42c3333d379bf2a442cfd936e7509424已正常推送。完整CI38521310543已触发，bootstrap=false，预期41 tests；恢复先查该run，不重跑已完成的38519173808。原HEAD6d76174/index为空、Build3和所有旧日志仍保留。

CI38521310543已完成，原始日志/xcresult下载保留：native bootstrap回归失败在首次位置489；长段失败343时已退回章节local600，长段top+1167，Locator仍charOffset2，活跃caretOffsets是2/9/17（不是长段字符）。源码检查确认bootstrap错误地调用了会await spreadLoaded的Readium evaluateScript，构成循环等待；现改用原生WK evaluateJavaScript启动探针，并在clear释放该等待链/过滤清理后脚本。另阻止positioning时缓存/测量恢复，校验documentY减viewportOffset与实际localTop一致，拒绝UI/DOM不同步快照；模式/reload revision及view identity过滤旧异步位置，nil结果不清空可靠位置。41条回归保持，未降低任何字符/像素断言。新改动尚未编译，即将静态/来源hash与完整CI。

该补充已过Windows362 grammar/14 tooling，已正常推送源码eb07c4ea61de3a57b39c048ebb289177e55a37d5。完整CI38523628789已触发，bootstrap=false/预期41 tests。恢复先查此run；2a43ccd的原生探针循环等待是已记录历史，不能重复把它当当前候选。原HEAD/index/Build3/旧日志继续保留。

CI38523628789已完成：原生rAF抑制回归通过首次位置与blocked=true检查，失败转移到jump helper等待目标href；页面实际第一章scrollY0，存储仍封面。边界/长段/rAF回归均在jump helper阻塞，字符断言未执行；其他模式/fragment/高度/重试通过。当前增加失败时的有界窗口/positioning/缓存documentY-offset-localTop诊断（只数字/布局，不输出正文），定位一致性拒绝原因；清理后新spreadLoaded调用立即释放，避免向已complete的CompletionList重新挂等待。预期仍41 tests，不降低断言、不伪造目标位置。


## 连续引擎检查点归档 2026-10-14T07:27:47.981671+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 先核对这个实际断点

当前候选分支codex/m1-continuous-recovery，实际Git ref=93ef44fbd12ca85d03ad57acda5db955d6a35c93。
正在验证的CI：38526015806，源码93ef44fbd12ca85d03ad57acda5db955d6a35c93，resolve_local_readium=false，预期41项iOS；恢复先查该run，禁止重复启动/假定通过。

最新已经执行的CI为38523628789，源码eb07c4ea61de3a57b39c048ebb289177e55a37d5：Linux/macOS各14 Core，iOS 38/41通过、3 failed、0 skipped；设备Release/IPA未执行。失败详情：
- failed - Continuous reader did not reach expected state at jump(_:book:href:):236 (testContinuousBoundaryShowsTwoResourcesAndScrollsBack())
- failed - Continuous reader did not reach expected state at jump(_:book:href:):236 (testContinuousLongParagraphRestoresCharacterAndViewportOffset())
- failed - Continuous reader did not reach expected state at jump(_:book:href:):236 (testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge())

本地仍为main/HEAD6d761749911233122bcd031fcf718d22a19f9e77，原index为空，原未提交改动全部保留；通过独立临时index创建候选快照，没有reset/stash/删库/改原书。原370文件备份.cache/recovery/20261014-092934已核验所有SHA/ZIP CRC；各次原始交接和检查点保存在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。旧candidate.json/documentation-snapshot.json不是最新Git状态。

## 当前源码与待验证内容

Add numeric anchor/window rejection diagnostics and make post-clear load waits return immediately。该候选通过Windows362文件grammar（pristine54限制/新增0）与14 tooling；当前新候选尚未Swift编译，最后已编译版本见上方真实CI。

原生bootstrap已能在抑制spreadLoaded rAF后取得首次位置，当前阻塞转移为章节已显示one.xhtml但位置仍cover.xhtml。新诊断仅记录当前index/revision/ready/positioning/wrapper/frame以及documentY-offset-localTop，不输出正文；需读取失败附件/完整日志确认何处拒绝，不把推测写成根因。

已加候选行为：完整初始化等待；原生didFinish直接WK探针启动同一CSS/初始定位/decoration管线（不再通过会等待spreadLoaded的包装器）；单次启动避免native/JS重复完成互相取消。clear取消bootstrap/load task、断开UI/WebKit delegate并释放两条加载等待链；清理后脚本拒绝执行、后到加载等待立即结束。positioning期间不捕获位置/做anchor补偿；cache使用实际localTop，DOM/UI origin不一致拒绝；mode/reload revision与view identity过滤迟到计算，nil不覆盖可靠位置。

41条回归保持（原31+连续8+旧termination1+rAF桥1），charOffset>100、重开3px、双章/逆向/高度/重试断言均未降低。长段最近几轮未到字符断言，不能宣称字符修复通过。

## 架构和范围

Vendor/ReadiumToolkit为官方3.11.0/d82f44f4f05d87add9e22a8b75abbd61dce745dd本地维护扩展，保留BSD许可/PR811参考/逐文件来源和hash；不是官方合并功能，不修改SourcePackages缓存。最多12资源，固定WK viewport、实际DOM章节高度、前后回收/加载边界/重试。保留标准href/CSS/text/progression并附加DOMRange字符/版本1视口偏移/64字符上下文；搜索保持原Readium文本定位。UI经ReadingInterfaces，Core仅Foundation/SQLite；fixed/RTL/竖排保留分页。

Package.resolved来自真实解析38496501326，6远程pins版本/revision未变；bootstrap=false，resolve/test/build严格锁定。

## 证据和旧产物

完整原始日志、summary、xcresult与附件在build/ci/各实际run/artifacts/XianxiaReader-build-diagnostics/build；最新38523628789日志已下载。Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json记录433候选Git blob SHA与最后真实测试；M1_CONTINUOUS_STATIC_REPORT.json仅静态，各失败原文见ValidationLogs。

build/XianxiaReader.ipa仍是Build3，7393693 bytes，SHA256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2；原件build/ci/38434939423/ipa，旧测试ZIP/Build2/3全部保留。没有新成功Build4包。普通设备签名、iPhone13/iOS16.6.1/TrollStore、原书图像/位置、原生手动拖动惯性、峰值内存及完整模拟器阅读均未验收；旧双章原创截图复查不能代替以上门槛。

## 下一步

CI38526015806/93ef44f已结束，长段字符与重开恢复这次通过，边界也通过；fragment/重试/rAF回归在jump等待失败。数字证据：index1/ready=true/positioning=false，候选documentY859.875-offset2.875=857，而外层localTop0、DOM后到scrollY0，说明定位与坐标读取分属两个WebKit回调时目标被原生同步覆盖。当前将Readium原scrollToLocator/scrollToId/scrollToPosition与window.scrollY读取放在同一JS调用；保持原搜索文本匹配，不编造locator、不降低断言。静态核验后完整41-test CI，当前补充未编译。

1. 先核对上方正在运行的CI实际状态/head/完整日志/xcresult，不重跑旧候选。读取数字诊断解决正确章节位置发布，再验证长段字符与完整41项；失败禁止Release/IPA。
2. 全套Core/iOS成功后设备Release CODE_SIGNING_ALLOWED=NO，下载核验CRC/arm64/系统SQLite/0755/最低iOS16/许可，保留旧Build3再提供Build4测试包。
3. 用户设备正常更新保留数据，不卸载/删库；原书、拖动惯性、普通设备/TrollStore分别验收。完整M1未放行，不进入M2/M4；TXT、完整书库、字体主题/音量键、百万字性能/XBook知识库均未实现。
4. 每个可恢复步骤和构建前更新本文件，阶段结束同步PROJECT_STATUS/设计/FILE_INVENTORY；不将未编译代码写成已通过。

## 环境与公开

用户已授权GitHub仓库公开，API PUBLIC；标准Ubuntu/macOS runner正常启动，旧38508277189账单拒绝是历史，没有修改付款/支出限额。公开审计原27 commits/718 blobs/64 logs及四本原创样书无待处理发现，模式扫描有范围限制；后续来源/日志也复核。Windows/PowerShell/Git/Python可用，无本机Xcode；未启动/重置Docker或localhost，其他项目进程保留。GitHub artifacts保留14天，build/.cache不随clone。


## 连续引擎检查点归档 2026-10-14T07:45:02.634379+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 先核对这个实际断点

当前候选分支codex/m1-continuous-recovery，实际Git ref=2590801d2d60314728ab8f9062dc33b5e661a4c1。
正在验证的CI：38528382505，源码2590801d2d60314728ab8f9062dc33b5e661a4c1，resolve_local_readium=false，预期41项iOS；恢复先查该run，禁止重复启动/假定通过。

最新已经执行的CI为38526015806，源码93ef44fbd12ca85d03ad57acda5db955d6a35c93：Linux/macOS各14 Core，iOS 38/41通过、3 failed、0 skipped；设备Release/IPA未执行。失败详情：
- failed - Continuous reader did not reach expected state at jump(_:book:href:):237 (testContinuousFragmentAndDOMBookmarkRestore())
- failed - Continuous reader did not reach expected state at jump(_:book:href:):237 (testContinuousLayoutFailureShowsRetryAndRecoversTheAnchor())
- failed - Continuous reader did not reach expected state at jump(_:book:href:):237 (testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge())

本地仍为main/HEAD6d761749911233122bcd031fcf718d22a19f9e77，原index为空，原未提交改动全部保留；通过独立临时index创建候选快照，没有reset/stash/删库/改原书。原370文件备份.cache/recovery/20261014-092934已核验所有SHA/ZIP CRC；各次原始交接和检查点保存在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。旧candidate.json/documentation-snapshot.json不是最新Git状态。

## 当前源码与待验证内容

Atomic Readium target command plus scroll coordinate read in one JS callback。该候选通过Windows362文件grammar（pristine54限制/新增0）与14 tooling；当前新候选尚未Swift编译，最后已编译版本见上方真实CI。

原生bootstrap已能在抑制spreadLoaded rAF后取得首次位置，当前阻塞转移为章节已显示one.xhtml但位置仍cover.xhtml。新诊断仅记录当前index/revision/ready/positioning/wrapper/frame以及documentY-offset-localTop，不输出正文；需读取失败附件/完整日志确认何处拒绝，不把推测写成根因。

已加候选行为：完整初始化等待；原生didFinish直接WK探针启动同一CSS/初始定位/decoration管线（不再通过会等待spreadLoaded的包装器）；单次启动避免native/JS重复完成互相取消。clear取消bootstrap/load task、断开UI/WebKit delegate并释放两条加载等待链；清理后脚本拒绝执行、后到加载等待立即结束。positioning期间不捕获位置/做anchor补偿；cache使用实际localTop，DOM/UI origin不一致拒绝；mode/reload revision与view identity过滤迟到计算，nil不覆盖可靠位置。

41条回归保持（原31+连续8+旧termination1+rAF桥1），charOffset>100、重开3px、双章/逆向/高度/重试断言均未降低。长段最近几轮未到字符断言，不能宣称字符修复通过。

## 架构和范围

Vendor/ReadiumToolkit为官方3.11.0/d82f44f4f05d87add9e22a8b75abbd61dce745dd本地维护扩展，保留BSD许可/PR811参考/逐文件来源和hash；不是官方合并功能，不修改SourcePackages缓存。最多12资源，固定WK viewport、实际DOM章节高度、前后回收/加载边界/重试。保留标准href/CSS/text/progression并附加DOMRange字符/版本1视口偏移/64字符上下文；搜索保持原Readium文本定位。UI经ReadingInterfaces，Core仅Foundation/SQLite；fixed/RTL/竖排保留分页。

Package.resolved来自真实解析38496501326，6远程pins版本/revision未变；bootstrap=false，resolve/test/build严格锁定。

## 证据和旧产物

完整原始日志、summary、xcresult与附件在build/ci/各实际run/artifacts/XianxiaReader-build-diagnostics/build；最新38526015806日志已下载。Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json记录433候选Git blob SHA与最后真实测试；M1_CONTINUOUS_STATIC_REPORT.json仅静态，各失败原文见ValidationLogs。

build/XianxiaReader.ipa仍是Build3，7393693 bytes，SHA256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2；原件build/ci/38434939423/ipa，旧测试ZIP/Build2/3全部保留。没有新成功Build4包。普通设备签名、iPhone13/iOS16.6.1/TrollStore、原书图像/位置、原生手动拖动惯性、峰值内存及完整模拟器阅读均未验收；旧双章原创截图复查不能代替以上门槛。

## 下一步

CI38528382505/2590801已完成：40/41通过，0 skipped；章节fragment/重试/rAF桥/边界/模式均通过。只剩长段344：outer3119/local2367/DOMscrollY2367，实时caret499/506/513，但第一次候选仍是滚动前documentY1769.875、offset2.875、savedTop1767，一致性检查正确拒绝后没有再次采样。当前把Locator/documentY/documentTop放在同一JS快照，DOM尚未跟上原生视口时最多3次32ms重采样；epoch/revision/localTop/关闭取消仍核对，不无限轮询，不降低字符/3px断言。静态核验后完整41-test CI，补充尚未编译。

1. 先核对上方正在运行的CI实际状态/head/完整日志/xcresult，不重跑旧候选。读取数字诊断解决正确章节位置发布，再验证长段字符与完整41项；失败禁止Release/IPA。
2. 全套Core/iOS成功后设备Release CODE_SIGNING_ALLOWED=NO，下载核验CRC/arm64/系统SQLite/0755/最低iOS16/许可，保留旧Build3再提供Build4测试包。
3. 用户设备正常更新保留数据，不卸载/删库；原书、拖动惯性、普通设备/TrollStore分别验收。完整M1未放行，不进入M2/M4；TXT、完整书库、字体主题/音量键、百万字性能/XBook知识库均未实现。
4. 每个可恢复步骤和构建前更新本文件，阶段结束同步PROJECT_STATUS/设计/FILE_INVENTORY；不将未编译代码写成已通过。

## 环境与公开

用户已授权GitHub仓库公开，API PUBLIC；标准Ubuntu/macOS runner正常启动，旧38508277189账单拒绝是历史，没有修改付款/支出限额。公开审计原27 commits/718 blobs/64 logs及四本原创样书无待处理发现，模式扫描有范围限制；后续来源/日志也复核。Windows/PowerShell/Git/Python可用，无本机Xcode；未启动/重置Docker或localhost，其他项目进程保留。GitHub artifacts保留14天，build/.cache不随clone。


## Build4产物与用户原则检查点归档 2026-10-14T08:14:30.477718+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 最新核对检查点（覆盖下方旧状态，产物核验进行中）

产物核验已完成，准备生成测试包：38530334549 的原始 xcresult summary 为41 passed/0 failed/0 skipped；Linux/macOS各14 Core，日志有 TEST SUCCEEDED / BUILD SUCCEEDED，测试/附件导出/summary退出码均0。Build4原件7502213 bytes，SHA256 7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1，CRC/arm64/iPhoneOS/最低16.0/0755/系统SQLite/第三方声明通过。旧Build3原件已保留，下一步生成单独UTF-8测试包并同步证据、源码hash与文档。无需再触发CI。

已实际查看当前run边界PNG：只有第一章末尾和大片空白，未显示第二章标题，不能将DOM/几何测试通过等同于视觉验收；原因未判定，不归因于截图管线或源码。分页/章内滚动封面两条色带完整。当前双章视觉、原生拖动/惯性及iOS16.6.1设备仍待实测；测试包标明候选范围。参考实现已查询并锁定源码，沿原Readium架构推进，没有替换引擎。

2026-10-14 已通过 GitHub API 核对：CI 38530334549 / d62af3b7576a11a1b7318e029355ef1847710113 completed/success，repository-checks、core-tests、ios 三个 job 全部 success。此刻尚未下载该 run 的 summary/xcresult/IPA，因此先不宣称具体测试数或替换本地旧 Build3。接下来下载完整日志及三个 artifacts，核对41项测试、设备Release与IPA，再制作Build4测试包；旧包保留。

用户补充开发原则：项目用于自用，遇到卡点先参考成熟实现，微信读书作为交互参考，其余按现有方案走。不因上一轮反复调试直接推翻已定架构；这轮不再追加同一竞态补丁或重复触发CI。参考实现研究与真实产物核验后同步全部状态文档。当前 main/原index/未提交改动继续保留，未发现本项目挂起的 gh/python/swift/docker 任务，其他 node 进程未动。

## 先核对这个实际断点

当前候选分支codex/m1-continuous-recovery，实际Git ref=d62af3b7576a11a1b7318e029355ef1847710113。
正在验证的CI：38530334549，源码d62af3b7576a11a1b7318e029355ef1847710113，resolve_local_readium=false，预期41项iOS；恢复先查该run，禁止重复启动/假定通过。

最新已经执行的CI为38528382505，源码2590801d2d60314728ab8f9062dc33b5e661a4c1：Linux/macOS各14 Core，iOS 40/41通过、1 failed、0 skipped；设备Release/IPA未执行。失败详情：
- failed - Continuous reader did not reach expected state at testContinuousLongParagraphRestoresCharacterAndViewportOffset():344 (testContinuousLongParagraphRestoresCharacterAndViewportOffset())

本地仍为main/HEAD6d761749911233122bcd031fcf718d22a19f9e77，原index为空，原未提交改动全部保留；通过独立临时index创建候选快照，没有reset/stash/删库/改原书。原370文件备份.cache/recovery/20261014-092934已核验所有SHA/ZIP CRC；各次原始交接和检查点保存在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。旧candidate.json/documentation-snapshot.json不是最新Git状态。

## 当前源码与待验证内容

Atomic locator/documentY/documentTop snapshot with at most3 viewport-mismatch samples。该候选通过Windows362文件grammar（pristine54限制/新增0）与14 tooling；当前新候选尚未Swift编译，最后已编译版本见上方真实CI。

原生bootstrap已能在抑制spreadLoaded rAF后取得首次位置，当前阻塞转移为章节已显示one.xhtml但位置仍cover.xhtml。新诊断仅记录当前index/revision/ready/positioning/wrapper/frame以及documentY-offset-localTop，不输出正文；需读取失败附件/完整日志确认何处拒绝，不把推测写成根因。

已加候选行为：完整初始化等待；原生didFinish直接WK探针启动同一CSS/初始定位/decoration管线（不再通过会等待spreadLoaded的包装器）；单次启动避免native/JS重复完成互相取消。clear取消bootstrap/load task、断开UI/WebKit delegate并释放两条加载等待链；清理后脚本拒绝执行、后到加载等待立即结束。positioning期间不捕获位置/做anchor补偿；cache使用实际localTop，DOM/UI origin不一致拒绝；mode/reload revision与view identity过滤迟到计算，nil不覆盖可靠位置。

41条回归保持（原31+连续8+旧termination1+rAF桥1），charOffset>100、重开3px、双章/逆向/高度/重试断言均未降低。长段最近几轮未到字符断言，不能宣称字符修复通过。

## 架构和范围

Vendor/ReadiumToolkit为官方3.11.0/d82f44f4f05d87add9e22a8b75abbd61dce745dd本地维护扩展，保留BSD许可/PR811参考/逐文件来源和hash；不是官方合并功能，不修改SourcePackages缓存。最多12资源，固定WK viewport、实际DOM章节高度、前后回收/加载边界/重试。保留标准href/CSS/text/progression并附加DOMRange字符/版本1视口偏移/64字符上下文；搜索保持原Readium文本定位。UI经ReadingInterfaces，Core仅Foundation/SQLite；fixed/RTL/竖排保留分页。

Package.resolved来自真实解析38496501326，6远程pins版本/revision未变；bootstrap=false，resolve/test/build严格锁定。

## 证据和旧产物

完整原始日志、summary、xcresult与附件在build/ci/各实际run/artifacts/XianxiaReader-build-diagnostics/build；最新38528382505日志已下载。Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json记录433候选Git blob SHA与最后真实测试；M1_CONTINUOUS_STATIC_REPORT.json仅静态，各失败原文见ValidationLogs。

build/XianxiaReader.ipa仍是Build3，7393693 bytes，SHA256 12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2；原件build/ci/38434939423/ipa，旧测试ZIP/Build2/3全部保留。没有新成功Build4包。普通设备签名、iPhone13/iOS16.6.1/TrollStore、原书图像/位置、原生手动拖动惯性、峰值内存及完整模拟器阅读均未验收；旧双章原创截图复查不能代替以上门槛。

## 下一步

1. 先核对上方正在运行的CI实际状态/head/完整日志/xcresult，不重跑旧候选。读取数字诊断解决正确章节位置发布，再验证长段字符与完整41项；失败禁止Release/IPA。
2. 全套Core/iOS成功后设备Release CODE_SIGNING_ALLOWED=NO，下载核验CRC/arm64/系统SQLite/0755/最低iOS16/许可，保留旧Build3再提供Build4测试包。
3. 用户设备正常更新保留数据，不卸载/删库；原书、拖动惯性、普通设备/TrollStore分别验收。完整M1未放行，不进入M2/M4；TXT、完整书库、字体主题/音量键、百万字性能/XBook知识库均未实现。
4. 每个可恢复步骤和构建前更新本文件，阶段结束同步PROJECT_STATUS/设计/FILE_INVENTORY；不将未编译代码写成已通过。

## 环境与公开

用户已授权GitHub仓库公开，API PUBLIC；标准Ubuntu/macOS runner正常启动，旧38508277189账单拒绝是历史，没有修改付款/支出限额。公开审计原27 commits/718 blobs/64 logs及四本原创样书无待处理发现，模式扫描有范围限制；后续来源/日志也复核。Windows/PowerShell/Git/Python可用，无本机Xcode；未启动/重置Docker或localhost，其他项目进程保留。GitHub artifacts保留14天，build/.cache不随clone。


## M2 Linux编译完成检查点 2026-10-14T09:02:05.960444+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

**当前CI：38538141364 / 0643093d32fdc9801cba34671d9eba3d1eb35de4 / codex/m2-txt-index，bootstrap=false。** 已实际启动，repository-checks成功、Linux Core运行中；33 Core/原41 iOS/Release尚未完成。恢复先查此run及完整日志，禁止重复dispatch/假定通过。本轮源快照已正常push，main/原index不变。

可恢复检查点：Linux Core job已success，artifact/core-tests.log已下载到build/ci/38538141364/core，日志真实编译完成并执行33项（14旧+19新）无失败。新TXT组件Linux已编译；macOS/iOS/Release仍运行中，不将Linux结果扩大成最终iOS成功。M2报告记录438个候选运行源码Git blob SHA。后续编译/产物核验保持Build4用户包不动。

### 2026-10-14 用户实测与M2开始检查点

用户明确反馈“这个功能可以了，重开位置也是正常的”，并授权按计划继续。结合上一条上下文，记录为Build4连续跨章与重开位置的用户设备功能验收；沿用已知iPhone13/iOS16.6.1/TrollStore背景，不扩写为旋转、普通签名设备、原书图像或峰值内存全部通过。此前CI边界PNG缺第二章仍保留历史，不再把它当用户设备功能未通过的阻塞。

M1自动构建/41项iOS及用户本次核心功能反馈已满足继续开发的依据；M2从独立Core组件切片开始。UI阶段答复：当前基础界面，完整书库布局/编辑在M3；字体、字号、行距、边距、主题和亮度在M4。用户没有要求跳到M4或替换Readium。

下一可恢复步骤：实现UTF-8正规正文的独立标题识别器、跨块/长行/CRLF/BOM流式扫描、卷章分组/序章及64位end-exclusive范围、有界章节窗口读取，并新增真实Swift回归。此切片不冒称完整TXT支持；编码自动检测/UTF16与GB18030转码、版本化内容缓存、导入与阅读接入随后完成。先核对现有协议/Chapter模型，再实现、Windows检查、真实Core/macOS/iOS CI；任何未编译源码都明确标记。main/原index与旧Build4保持不动。

测试前检查点：四个Core TXT实现文件和TXTIndexTests.swift已写入，尚未Swift编译。标题参考Readest中文规则的卷/章差异与中文数字范围，使用独立实现；候选line缓存上限512字节、chunk/正文窗口上限256KiB，严格UTF-8、不覆盖原书，卷不重复正文。新增回归覆盖八类标题/反例、1字节分块、多字节/CRLF/BOM、卷序/重复ID、长行/损坏/取消、窗口边界及>4GiB稀疏偏移。现在运行Windows结构/语法与tooling检查，并只读查询Docker是否可用于锁定Swift容器；不可用则记录实际错误、继续真实CI，不启动/重置用户工具。

**Build4连续/重开位置已由用户确认；当前进入M2 Core切片，准备真实编译。** 上方M2检查点覆盖旧“下一步设备测试”的断点，下方M1证据/待确认的其他设备项目保留。

M2构建前检查点：Windows367文件grammar（pristine54限制/新增0）和14项Python tooling已通过，git diff --check通过；Docker查询exit1，dockerDesktopLinuxEngine管道不存在，命令已退出，未启动/重置用户工具。Core预期33项（14旧+19新），iOS保留原41项。将独立index快照推送codex/m2-txt-index并运行现有完整CI，bootstrap=false；读取实际run/head后记录，不重复启动或把未编译代码标为已验收。已有Build4/旧测试包不覆盖。

- CI [38530334549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38530334549)，已测运行源码 `d62af3b7576a11a1b7318e029355ef1847710113`，三个job completed/success，bootstrap=false。
- Linux/macOS各14 Core、iOS41 passed/0 failed/0 skipped，测试/附件导出/summary退出码均0；设备Release `CODE_SIGNING_ALLOWED=NO`与IPA成功。
- 下载原始日志/summary/xcresult/工程/锁/IPA；433个运行源码Git blob SHA与当前工作文件匹配，根锁/下载锁/workspace锁逐字节一致。本轮只更新文档/证据，不再追加运行代码补丁或重复CI。源码编译warning/error=0，6条AppIntents metadata提示及WebKit运行诊断原样保留。
- 当前无本项目进行中的CI或gh/python/swift/docker任务；其他项目node进程未修改。文档快照可在候选分支d62之后，不能把文档commit当成另一版已测试源码；恢复时查Git实际ref。

## 用户最新开发原则

用户用于自用，希望尽快实际能用。遇到陌生问题/反复失败，先参考官方文档与成熟实现，核对适用版本和差异再改，不持续盲补。微信读书是交互参考，其余按既定方案走。已写入AGENTS.md；本轮审阅epub.js连续窗口、Foliate Range锚点与Readium PR811，固定来源/取舍见 `Documentation/MATURE_READER_REFERENCES.md`。未换引擎、未升级依赖或扩展下一阶段。

## 已实现与验证边界

Readium3.11.0/d82f44f本地扩展，UI经ReadingInterfaces，Core保持Foundation/SQLite。最多12资源窗口、固定WK视口、实际章节高度、加载边界/重试、前后回收；完整Locator+字符/版本化局部视口锚点，64字符上下文。fixed/RTL/竖排保留原路径；搜索保留issue876扩展。

标准定位与DOMscrollY同次JS执行，保存位置原子采集Locator/documentY/documentTop，不一致最多采样3次；过滤epoch/revision/旧slot。公开didFinish探针启动同一完整初始化管线，清理取消任务、断开delegate并释放等待链。自动回归含双章/逆向窗口、fragment/书签、图片高度、失败重试、600点长段滑动后charOffset>100/重开误差<3px、搜索/模式往返、千资源回收、迟到termination及rAF桥暂停。

**当前边界PNG只显示第一章末尾和空白，未显示第二章标题，已查看并记录，原因未判定。** DOM/可见窗口测试通过不能等同于视觉通过，不推断只是截图管线问题。分页/章内滚动封面上下色带完整。手动模拟器阅读、原生拖动/惯性、峰值内存、普通设备、iPhone13/iOS16.6.1/TrollStore和原书仍待验收。

## 产物

- `build/XianxiaReader.ipa`：Build4/0.0.1，7502213 bytes，SHA256 `7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1`。ZIP CRC、iPhoneOS/arm64、最低16.0、0755、系统SQLite及第三方声明通过；不冒充普通签名安装包。
- `build/XianxiaReader-Continuous-Build4-TestKit.zip`：7429683 bytes，SHA256 `f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7`，四本原创EPUB、UTF-8说明、CRC/内部IPA hash通过。
- 原件：`build/ci/38530334549/artifacts/XianxiaReader-unsigned-ipa/XianxiaReader.ipa`；诊断位于同run的 `XianxiaReader-build-diagnostics/build/`，完整Actions日志 `build/ci/38530334549/full.log`。
- 旧Build3原件 `build/ci/38434939423/ipa/XianxiaReader.ipa`（12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2）保留，旧 `build/XianxiaReader-iPhone13-TestKit.zip`/更早包未覆盖。

## Git与恢复保障

本地仍main/HEAD `6d761749911233122bcd031fcf718d22a19f9e77`，原index为空，所有原未提交改动保留；候选分支codex/m1-continuous-recovery通过独立临时index快照/正常push，不reset/stash/删库/改原书。原370文件备份 `.cache/recovery/20261014-092934/` 已核验CRC/全部SHA；历史交接和所有失败原文保留在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md与ValidationLogs，旧candidate.json/documentation-snapshot.json不代表最新ref。

Package.resolved来自真实解析38496501326，6远程pins版本/revision不变，resolve/test/build严格用根锁；不要重新bootstrap或伪造锁。运行源码以成功报告433个Git blob SHA为准，FILE_INVENTORY用于当前文档/文件恢复，不把新增文档hash说成已编译。

## 检查点与接下来的工作

本轮文档同步后Windows结构/来源/锁文件/SQL/四本EPUB检查通过；362文件Swift grammar（pristine54限制/新增0）及14项Python tooling全部通过，git diff --check通过。静态不等于编译，iOS编译/Release证据仍只绑定d62/38530334549。当前证据与FILE_INVENTORY同步后，通过独立index保存/推送文档快照至候选分支；运行源码不变，不触发重复CI，main/原index继续保留。

1. 使用Build4测试ZIP在现有TrollStore应用正常更新，保留数据、不卸载/删库。菜单启用“上下连续滚动”，核对reader-layout章末/下一章同屏、反向、拖动与惯性；长段中部书签、重开/后台、分页↔连续、目录/搜索/链接及原书图像分别记录。
2. 若出现空白/跳动/位置漂移，先记录实际步骤、章节/位置与最小复现，对照成熟窗口/锚点实现后选择修改；不增加无限等待、不降低断言。未取得新证据不重复跑同一源码CI。
3. 普通设备与TrollStore、自动CI与手动阅读分开；M1尚未完整放行，不大规模进入M2/M4。TXT、完整书库编辑、字体/主题/音量键、百万字性能及XBook知识库仍未实现。
4. 恢复先AGENTS→PROJECT_STATUS→本文件→ROADMAP→ARCHITECTURE，再核对Git、文件、日志、任务，阶段结束同步文档；不要把旧进行中/失败状态覆盖最新成功。

## 环境与公开

Windows/PowerShell/Git/Python可用，无本机Xcode。用户已授权GitHub公开，API PUBLIC，公开标准Ubuntu/macOS runner已成功执行，未修改付款/支出限额；旧账单拒绝仅历史。本轮未启动/重置Docker或localhost。GitHub artifacts保留14天，忽略build/.cache不随clone，过期后按锁重新完整CI。证据见M1_CONTINUOUS_VALIDATION_REPORT.json及ValidationLogs/m1-continuous-build4-success.json。


## M2完整CI与产物核验完成 2026-10-14T09:34:58.617664+00:00

# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

### 38538141364 第一次尝试已完成（重试前检查点）

attempt1实际failure：Linux/macOS各33 Core（含19项TXT）通过，iOS编译成功后40/41、0 skipped，test exit65/附件及summary各0，Release/IPA未执行。失败为现有testContinuousBoundaryShowsTwoResourcesAndScrollsBack():249首次等待位置，诊断position=nil/slot0章节加载超时/clear后blank。这个blank是超时后状态，不能推断加载前根因。App/Reading/Readium/iOS测试源码与用户已测d62无差异；Core新增TXT未接入UI。完整日志/summary/xcresult已下载到build/ci/38538141364，M2新组件Linux/macOS真实测试全部通过。

现在只用**同一0643093源码重试失败iOS job一次**判断可重现性，不改阅读器、不降低测试/扩大超时。首次失败证据单独保留，重试产物放attempt-2目录避免覆盖；旧Build4用户包保持不动。失败不能生成成功IPA，完整CI结果仍以重试真实状态为准；原因尚未确认，不先标为环境偶发。恢复查run_attempt及各attempt完整结果，不根据旧网页尾部判断。

M2 Core UTF-8分章/窗口第一切片。CI38538141364，已测源0643093d32fdc9801cba34671d9eba3d1eb35de4，分支codex/m2-txt-index，bootstrap=false。repository-checks及Linux Core已success；33项Core（14旧+19新）真实编译/测试通过，完整Core artifact已下载到build/ci/38538141364/core。**macOS/Core、原41项iOS与设备Release仍在运行，完整CI尚未完成**；恢复先查询该run/head/完整日志，禁止重复dispatch/假定通过。

当前运行源码438个Git blob SHA记录在Documentation/M2_TXT_INDEX_VALIDATION_REPORT.json。此后只修改文档，未改运行代码。Windows367文件grammar（pristine54限制/新增0）和14项Python tooling通过，语法不是编译；Linux当前成功也不等于Apple/iOS成功。

## 用户实测、阶段推进与UI

用户确认“这个功能可以了，重开位置也是正常的”，要求按既定方案继续；据前文记录Build4连续跨章/重开位置可用。已知设备背景iPhone13/iOS16.6.1/TrollStore，未独立重读Build号/设备状态；不扩写为旋转、原书图像、所有逆向/惯性/普通签名设备和性能全通过。证据ValidationLogs/m1-build4-user-feedback.json。

M1完整CI38530334549/d62af3b：Linux/macOS各14 Core、41/41 iOS、设备Release/Build4 IPA成功，原始日志/xcresult/锁/433运行源码hash已核验。真实构建/测试加本次用户核心功能反馈支持按计划进入M2，其他设备项目单独留待记录。旧CI边界PNG缺第二章为历史截图证据限制，不否定用户实测，不继续无依据补同一竞态。

当前基础书架/阅读操作已存在；完整书库布局/编辑在M3，字号/字体/行距/边距/五种主题/亮度等在M4。用户没有要求跳到M4或换引擎。卡点先查成熟方案，微信读书交互目标、其余按原路线；AGENTS与MATURE_READER_REFERENCES.md保留此原则。

## M2已实现的独立Core组件

- TXTChapterHeadingRecognizer：八类标题、中文/全角数字、序章/卷、英文Chapter 1/chapter.844、整行/长度/量词反例。参考Readest边界原则、独立实现，固定来源见TXT_INDEX_DESIGN.md。
- TXTUTF8ChapterScanner：actor有界FileHandle读取（默认64KiB/上限256KiB），严格UTF-8、CRLF/BOM/末行/跨1字节chunk；长行只保留最多512字节标题候选，其余仍校验。卷为无正文分组，前言/卷序不丢失，叶子Int64/end-exclusive范围连续覆盖正文，重复标题ID稳定。
- TXTChapterWindowReader：actor按当前叶子范围读最多256KiB，不越章；只返回完整UTF-8字符，检查局部锚点/实际文件长度/取消。>4GiB稀疏偏移真实读取回归通过，不等于长篇性能验收。
- TXTUTF8Stream：严格Unicode标量校验，拒绝overlong/surrogate/截断，不做替换字符；文件关闭保留原始读取/取消失败。
- TXTIndexTests：19项新增Swift回归，Linux已通过；Core仍只依赖Foundation/SQLite，无Readium/UIKit/SwiftUI。

## M2尚未实现

完整TXT导入/阅读入口、UTF16/GB18030自动检测与流式转码、SHA内容/parser版本cache、TXT完整版本化Locator/缓存重开尚未接入。TXTIndexing是完整facade协议，当前扫描输入必须已规范化UTF-8；不把Core组件写成用户已能导入TXT。URL由BookFileStore验证受管理路径，读取器不代替存储授权。原书/数据库schema/EPUB引擎未改。

## Git、工具与产物保留

本地main/HEAD6d761749911233122bcd031fcf718d22a19f9e77与原空index保留。M1 ref dedf9e4435d14f6884212f971292183cfcde5a60；M2源码快照0643093已通过独立index正常push，所有原未提交改动保留，未reset/stash/删库/覆盖原书。旧370文件备份.cache/recovery/20261014-092934已核验，历史交接归档到HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。不要用旧candidate.json替代实际ref。

Docker只读查询exit1：dockerDesktopLinuxEngine命名管道不存在，命令已退出，未启动/重置Docker。Windows无Xcode，Apple验证用公开标准macOS runner，无账单/付款/支出变更，无localhost服务。根Package.resolved保持6个真实pins、真实解析38496501326，resolve/test/build严格根锁，bootstrap关闭。

build/XianxiaReader.ipa仍为用户已确认功能的Build4，7502213 bytes，SHA256 7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1；Continuous-Build4-TestKit.zip SHA f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7。旧Build3/原测试包/日志全部保留。本轮CI即使生成同Build号IPA，也只保存各run目录，不覆盖用户包；TXT入口未实现，无需另提供相同界面的安装包。

## 接续

1. 核对当前38538141364完成状态、完整下载Core/macOS/iOS summary/xcresult及Release产物。失败保留原文/真实exit，按实际错误修复，不能跳过失败或降低测试。
2. 完整通过后验证438源码hash/锁/产物，更新M2报告、PROJECT_STATUS、TXT_INDEX_DESIGN和本文件；所有当前文件再写FILE_INVENTORY并保存文档快照，不把文档commit当另一个已测试源码。
3. 下一M2切片为编码正规化/内容版本cache，再接入TXT导入与ReadingInterfaces阅读；M3完整书库、M4排版/主题顺序不变。M2完整验收/数十MB/设备体验与M5性能仍未完成。
4. 构建前及每个可恢复步骤写检查点；中断恢复先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，并查Git/实际文件/日志/任务。build/.cache不随clone，GitHub artifact14天过期后按锁重跑。
