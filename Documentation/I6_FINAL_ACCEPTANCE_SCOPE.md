# I6d 最终验收范围与证据复用

## 2026-10-24 当前授权：只做整合，成功后不进入设备Release

当前唯一任务是一次同源I6整合验收，产品基线72b07cc及CI39979277641受控修正保持。旧准备期取消审阅已完成，保留未知，不再作为本轮先行诊断任务；此前压缩后误回旧审阅已在HANDOFF顶部纠正。

库存按project.yml实际测试target的全部source项解析并排除resources：Tests/iOS为156，另外显式编入Packages/ReaderSettings/Tests/ReaderSettingsTests的7项，合计163；Tests/UI29，总192。目录单计156并非丢了7项，原严格192门槛不变。候选CURRENT_PROJECT_VERSION保持31、CFBundleVersion仍为原构建变量；最后交付仍Build30。

必要接线仅3运行输入：workflow、ci_ios.sh、对应CI失败路径工具测试。新增stop_after_full_tests默认false，开启必须完整full；复用既有source_inputs记录运行前后源码/提交与原环境，任何漂移阻止成功回执。原test/附件export/summary/录屏退出及严格192门槛全通过后，写明确整合成功回执并退出0，随后IPA上传跳过。原默认设备Release/打包段原字节保持，未启用停点时仍沿原路径；没有故意失败、取消、unit-release或UI复用。

本轮选择diagnostic_selection=full、stop_after_full_tests=true，保留原六模块/macOS Core/TXT与并行Linux Core/TXT门槛。只派一次，不叠position-acceptance、配对、字体或旋转预检，不增加任何产品日志/等待/重试。失败先保留全部原件、真实退出及首错，不自动重跑、追加实验或扩大修复；同一artifact安全续取允许。

本地仅12项CI真实shell控制流夹具加10项摘要/复用门禁检查通过，484语法/7静态通过，新增语法诊断0。它们是本地接线证据，不是iOS编译或192原生通过。本轮原生/full尚未派发；source-before/source-after、192摘要、附件/录屏以及完整日志都必须以实际run取得后再报告结果。下文旧安排第4项的自动设备Release/IPA不适用于本轮；设备Release、包与手机验收明确留待后续授权。

AppServices广泛能力、App批次/呈现、同target UI类型访问、字体UIKit接口和2处Readium集成fixture例外继续登记，不为整合验收重拆App。未来功能按PROJECT_ISOLATION_PLAN/ROADMAP/READING_FEATURE_IDEAS保留；维护收口后再按模块归属、状态/持久化负责人、依赖、取消/迟到规则及独立/跨模块门槛接入，不提前实现新功能。

恢复及冻结记录：build/maintenance/I6-integration-only-20261024/。正常HEAD/index、用户已有工作、旧原件和Build30保持；不关机、不停止其他任务。派发锁若存在，中断只核同run，不再次POST。

---

以下保留2026-10-22范围核对的当时证据与推荐，执行边界以上述当前授权为准。

2026-10-22 I6最终full已完成一次，源77eebf40/CI39735403242/Build31：192全部执行，191通过、1失败、0跳过（集成162/163、UI29/29）。六模块68、两平台Core各137/TXT Release各4、Linux109工具通过；模拟器编译通过。唯一失败为连续视口变宽后的原字/WebView联合等待，缺缩放前原锚点及子条件诊断，未证明根因或修复。test65、summary/export/recording0；Release被阻止、未执行，无新IPA，最后交付仍Build30。无额外原生预检/重跑，完整原件已核；用户已决定本轮保存完整断点，下一轮只查此单例；本轮不追加诊断或CI。I6未通过，不进入新功能。 见[本轮结果与下一实验](I6_FINAL_ACCEPTANCE.md)。以下I6d等为历史阶段记录。

2026-10-22。本轮只做审计与项目记录，不改生产、原生测试、CI/门禁或版本，不派CI。当前保存源b4e2edc与被测598aedd的617运行输入一致；最新CI39729365995已从远端重新核实为成功，历史原件hash逐项匹配。I6尚未整体验收。

## 当前还缺什么

| 缺口 | 必要结果 | 当前状态 |
| --- | --- | --- |
| 最终输入冻结 | 若交付新包，先确定构建号，再冻结源码/工程/资源/三锁；当前工程及最后交付均为Build30 | 本轮不改号；最终验收后不能再改工程并沿用旧结果 |
| 原生整合 | 当前163集成+29真实UI=192，同一冻结源、零失败/跳过；包含位置/加载23项及修正后的关闭用例，核完整日志/xcresult/真实退出码/文本、像素和录屏 | 未执行；旧22/23和新1/1不能相加成同源23/23或192 |
| 设备构建与包 | 同源CODE_SIGNING_ALLOWED=NO的generic iOS Release，三锁/来源/资源、包内容与摘要核验；全部测试/summary/export/录屏成功后才允许打包 | 当前维护源未做，无新IPA |
| 手机验收 | 普通安装/TrollStore、保留书库升级、EPUB/TXT、字体保位/返回、后台暂停、旋转与动效实际反馈 | 当前维护版本未做；Build29/30历史反馈不能替代 |

当前仍有ReaderViewModel的AppServices广泛能力、App批次/呈现编排、同target UI类型访问、字体iOS接口依赖和2个明确Readium集成fixture例外。它们已有负责人和接入限制，本轮不重写宿主或新增UI targets，不把静态import守卫称作完全的编译级类型隔离。当前登记156第一方Swift、25区域、26图节点、2精确例外均保持；8条既有warning不阻塞当前Swift5编译，也不在本轮混入Swift6迁移。

## 哪些证据可引用

重新读取真实xUnit、依赖图、测试/环境/完整workflow日志，并与当前模块、测试、传递Core、脚本/.gitattributes的Git输入集合逐项比较。以下都是分项证据，不是本轮新执行，不相加成一次整体验收。

| 组件 | 原run / 通过数 | 当前复核 |
| --- | --- | --- |
| ReaderSettings | 39398382008 / 7 | 65项输入完全一致，原xUnit/环境/日志hash匹配 |
| ReaderPositions | 39585860717 / 24 | 69项中仅verify_reader_positions.py变化；logic的imports/常量/函数AST一致，用当前校验器重新核旧24项xUnit；原Swift/测试/依赖/执行脚本一致。不能写成69文件全相同；该原workflow仍原生18/19失败 |
| ReaderSessions | 39703522408 / 15 | 8项输入完全一致、真实原件保持 |
| LibraryShelf | 39707770264 / 6 | 66项输入完全一致、真实原件保持 |
| BookImports | 39712813755 / 8 | 66项输入完全一致、真实原件保持 |
| ReaderSearch | 39715718761 / 8 | 66项输入完全一致、真实原件保持 |

上述Apple Swift6.1.2、Xcode16F6、Intel及macOS15.7.9均与最新环境对应。可作为现阶段模块合同证据，不需要再分别开启六轮CI。

Core在Linux39418977905及macOS39373881574各有137项，源码/.gitattributes保持，原成功步骤与完整日志保留。SwiftPM parallel日志使用[n/137] Testing调度条目，必须按job筛选并核真实成功退出；尾部Swift Testing“0 tests”不是这组XCTest，也不能把同一完整日志的Linux+macOS计作274个macOS测试。TXT Release探针两平台各4项allChecksPassed，Core/probe脚本输入一致。可以引用这些历史组件结果，但SQLite实际版本没有在本轮重新执行/核定，不能用旧Core结果跳过最终环境门槛；Linux也不能替代Apple文件协调。

最新598aedd的真实Apple编译、Linux109工具检查及关闭单例可引用，运行输入保持；本轮没有新Swift执行或重跑109工具。前轮075c2cc的22项通过与新关闭1项均保留原件，生产/工程/资源一致，只有关闭测试一个方法变化；该文件其余方法/助手和其他191个测试方法保持。可用于收口已有疑点，不用于冒充一次共享进程/顺序下的完整通过。ReaderFonts无独立macOS门槛，当前六字体及位置证据仍来自原生用例。

## 哪些不能复用

实际配置的UI基线仍是39196134450/8f5b427的28项ARM结果；当前为29项Intel，54个受保护生产/包/工程输入不同。即便改用最后交付Build30的真实29项结果，仍有51个受保护输入不同。Tests/UI不变也不足以复用；不能改写旧记录或走unit-release绕开新UI验收。

本轮没有发现需要先再修生产代码或增加另一组原生预检的新证据。I6a修补的full192摘要门禁/完整组件artifact目录已在脚本中保留；真实full到Release链路仍需要下一次最终运行确认，旧包或本地门禁夹具不能代替。

## 下一轮最小执行安排

1. 确定要验证/交付的最终构建输入并冻结，先做廉价静态守卫；沿用本轮确认的范围，不插入新的业务、依赖升级或架构提取。
2. 使用现有workflow的diagnostic_selection=full一次，覆盖163+29及其中全部23项。不要另跑position-acceptance，也不要选fonts-full或rotation-full附加预检；若失败先收原件、定位相关边界，不自动全量重试。
3. 保留当前full入口已有六模块、macOS Core/四探针及并行Linux Core/四探针门禁。历史组件可复用为审计/日常证据，执行上不再另开独立CI；现有full脚本仍会执行这些快检，本轮没有引入复杂跳过/复用框架。它们不增加原生用例选择，也不产生额外一次iOS冷准备。
4. 原test/summary/附件导出/录屏退出全部0、summary严格192/192后，同一job执行严格设备Release和打包；失败保留原始状态和诊断，不能生成成功包。
5. 核原始像素/录屏及包，再单列手机验收。CI完成不能代替流畅度或TrollStore验收。

这是推荐的下一轮范围，本轮未启动。发布前只执行一次必要的完整验证，后续若生产/UI输入再变更，重新评估受影响边界与发布门槛，不能拿旧基线无条件跳过。

## 成本依据

最近交付源39373881574的完整主步骤110分47秒，对应旧151集成+29UI=180；实际case合计集成804.415秒、UI3899.124秒（约13.4/65分钟），其余1943.461秒包含准备/Core/解析/启动/导出/设备Release/打包等，不能全叫纯编译。该轮额外旋转预检另1477秒（24分37秒），不应在当前整合前重复。当前192尚未执行，不能把旧180直接当当前结果或把17秒关闭单例当整体耗时估计。

六模块各轮历史冷构建92.18/93.38/68.55/62.12/48.08/51.05秒，合计415.36秒（约7分钟），仅作成本量级，不能直接相加预测同job缓存命中时间。优先省掉无新假设的原生预检/多次冷准备；本轮不为省这段快检另造复用系统。现有full job上限150分钟是工作流预算，非承诺ETA；下一轮应按历史约两小时级的任务安排并分开报告准备、真实case及导出/Release成本。

机器记录：ValidationLogs/project-isolation-i6-final-scope.json；本地恢复与原件/范围核对：build/maintenance/I6-final-audit-20261022。普通HEAD/index和所有既有未提交工作保持，电脑保持开机。

本轮局部工具正反例：test_architecture与test_ui_baseline共42/42通过、0跳过，仅检查边界/复用与摘要门禁；未重跑109工具全组、Swift/Core或原生测试。

最终静态核对：仓库/边界守卫通过，484文件Swift语法新增0、保留54个Vendor语法限制；本轮未执行Apple编译，不能把语法通过当成编译验收。
