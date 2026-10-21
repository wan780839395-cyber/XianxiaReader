# R3 阅读位置隔离

## 2026-10-21 R3a 当前实施合同

本轮用户授权继续R3，先交付位置状态与显式保存请求隔离。源码初稿已接线，尚未Swift编译/原生验收。旧候选只复用经过当前差异审阅的10个文件；当前分页控制workflow、断言、故障注入和字体双模式默认值保留。

ReaderPositions是现有Core包内独立产品/target，只依赖XianxiaCore业务值与Foundation。它唯一保存不透明ReadingPosition、显式保存令牌/所属会话和保存错误；不解析Locator、不持有引擎/仓库/字体/界面、不自行创建异步任务。ReaderProgressState仅将同步位置通知转换为原去重摘要，完整位置不再由UI容器另存一份。错误继续在突变前通知ReaderViewModel；位置事件不触发整个ViewModel刷新。

saveNow中的每个await、guard、3秒截止/32ms既有间隔、固定布局分支、慢滚暂停/flush、设置flush和写库调用保持原调用点及顺序。新令牌判断等价于原会话ID+请求ID判断；旧defer只能结束自己的请求，关闭使令牌失效，保存失败保留完整位置，成功先发布完整位置再清除错误。close仍允许引擎发出最后位置回调后才使openRequestID失效。导航/返回点和会话生命周期不是本片迁移对象。

快速入口为`bash scripts/test_reader_positions.sh <新的输出目录>`，真实SwiftPM只执行6项状态合同，要求原始xUnit全部精确身份、无重复/失败/跳过、Core包无外部依赖；保留真实退出码。workflow新增`position-isolation`：仓库/工具检查后，同一macOS runner先6项独立合同，再原13项iOS用例（8保存/生命周期+1进度+4真实EPUB/TXT/字体/同宽writer）；不跑Core性能探针、完整188或设备导包。脚本会编译原scheme其他target，选例不能消除所有冷准备成本。

6项合同不接入iOS测试源，既有159集成+29UI数量保持188；完整发布流程照常测试Core包（原137+本片6=143），不以本定向结果代替I6。现有iOS用例主体、Vendor四项修复及资源/锁/数据库实现按输入哈希保全。运行证据及保护快照在build/maintenance/R3a-20261021，状态以HANDOFF最新记录为准。

取舍参考已复核[SwiftPM官方target/product与testTarget规则](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)和[isowords实际功能target依赖布局](https://github.com/pointfreeco/isowords/blob/main/Package.swift)。仅借用显式target依赖与独立测试的做法；保留本项目tools5.10、iOS16/macOS13、Xcode16.4，不迁移其TCA/iOS下限或远程依赖。纯同步提取避免重演R2新增挂起点的问题。

R3a完成后，捕获/写库编排、导航与返回点的责任迁移仍属于R3后续切片；状态模块落地不能写成R3整体或全项目隔离完成。

2026-10-20。当前为切片设计，尚未实现/编译/验收。用户最新选择本轮只查清定位、R3顺延；候选仅在.cache暂存，不接入构建根目录。不将R2的53/53复用为本片结果。

## 连续直接验证与分页未决（2026-10-21）

连续阅读偏移的直接行为已验证；整组仍失败5/6，不能发布。实际源`5340a5b48aecb554fabeb7f1ad6d5da3903eeee8` / [CI39456749155](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39456749155)，原生产控制`a84b6719d17f6a49c5e709ef9d56aa86faa72a8e`。同runner、同测试输入、534+534实际blob核对：旧源指定断言误差10.875点，修正后0.875点（原<3点断言保持）；连续六字体截图后保存字delta全0、字体ready与目标字可见。实际查看六张原生正文图，不代表动效或手机验收。

修正仅在`EPUBReflowableSpreadView.go(to:)`的无限连续canonical DOM分支同时消费完整字锚点与保存的viewport偏移；另同步UPSTREAM摘要。首个仅补native updateViewports的候选129e3506未修好，已撤回；不修改字体/App/Core/依赖/位置格式或预算。默认工作测试仍执行字体两模式；本次私有诊断源的字体链只选连续，不能声称其分页字体链通过。

5项通过：连续resize、EPUB完整锚点重复定位（含分页/连续）、连续六字体重开、分页长段完整字重开、TXT完整锚点返回。唯一失败为分页隐藏换字体用例397行：准备p25/char1016、x1608，结束h1/char0、x0。它与本改动的因果关系尚未证实，不能归咎环境；原CI保持失败/exit65（XCTest同一失败case两条issue），没有生成成功gate回执。用户已确认分页另查，故本轮保留该发布阻塞，不扩改、不重跑凑绿。

Windows456语法新增0/既有54、63工具59通过4POSIX跳过；Linux63工具、Core137、桌面TXT Release探针4通过；原生真实编译0源码错误。原生步骤28分44秒含准备/编译/测试/导出，实际case共189.091秒；首例在步骤开始1196.844秒后才进入，不能把总步骤算作测试或纯编译耗时。161356828字节diagnostic与116316字节Core完整artifact已SHA/CRC核验；原始日志、xcresult、manifest、正反例输入均在build/ci/39456749155，重复ZIP/分片按回执清除。

R3按用户决定顺延，13候选文件仍仅在.cache未接线，未编译或验收。完整187、设备Release、手机验收未执行，无新IPA，最后交付仍Build30。505保护输入、普通HEAD/index保持；没有运行中的本轮CI/observer/download。下一独立片先用已留原件比较分页两个字体请求的完整采样/重载Locator，必要时只跑同fixture最小对照，不盲重跑6/187。

## R3a：完整位置状态与保存请求身份

定位前置核查最新：39439273417给出有效几何，楷体与思源黑体在原断言后及原生截图后，保存字top=0.0625、expected=-9.9375、delta10，rect/rects完全相同。候选最小修正复用初始load已有updateViewports，在显式go设置外层offset后同样无条件同步一次，避免同坐标时没有外层回调导致内层DOM坐标残留。负对照冻结bc95fac只加强测试/诊断、生产不变：连续同一完整字/offset=-10的重复go，外层保持原坐标，显式不送scroll delegate回调，生命周期恢复该delegate。只有旧源在唯一指定断言失败，再运行一行修正和五个直接边界，才接受本片；暂无结果，不能预先宣称实际异步写入者或所有定位问题已修。R3候选仍未接线。

本小片计划把完整不透明ReadingPosition、显式保存请求身份、失败状态及同步结果接纳迁入真实ReaderPositions模块；App进度视图只观察显示摘要。通过原Core业务值复用版本化Locator，不解析/重写EPUB Locator或TXT锚点，不改变SQLite规则。

沿用现有XianxiaCore包，增加独立Foundation-only产品/target与直接测试target，避免引入新顶层包或Readium/UIKit依赖；XianxiaCore业务target不反向依赖ReaderPositions。project.yml实际链接产品，架构登记同步增加独立区域/节点及禁止UI/引擎导入的反例。与原ReaderSettings、Readium TestApp设置存储借鉴同一原则：状态/保存有效性拥有明确负责人，平台动作在调用方协调；不引入第三方框架。

App调用方保留原采样循环、3秒预算、32毫秒不可用间隔、暂停/flush先后、原数据库await、固定版式分支及错误文字。请求创建/核验/失效/结果应用为MainActor同步方法，避免职责提取新增async封装或改变原挂起点。close继续允许原引擎最终位置回调，保存请求先失效；打开/关闭生命周期仍属于后续R4。

直接合同覆盖完整字节/版本保留、同一会话新请求替代旧请求、旧defer不清空新请求、关闭/换会话失效、失败保旧及成功重试清错误。通过同步显式步骤模拟挂起前后状态，不加入依赖固定时间窗的竞态。

受影响生产文件限新模块、ReaderViewModel、ReaderProgressView、Core manifest/project.yml/架构登记；独立测试与边界工具反例另列。原设置、字体、导航/书签、引擎、Vendor、资源/锁及数据库实现保持。

最小验证：Windows仓库语法及工具；Linux/macOS真实模块测试；iOS原生命周期28、设置7、进度1及真实位置/字体的直接交界用例。仅在源码稳定后一次冻结派发，不逐编辑打包。完整187、严格设备Release、原生动效与手机验收仍属I6。

R3a只隔离状态和请求结果的接纳，完整采样/保存编排迁移仍属后续R3b。不能把R3a写成R3全部完成。

