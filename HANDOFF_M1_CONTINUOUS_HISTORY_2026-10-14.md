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
