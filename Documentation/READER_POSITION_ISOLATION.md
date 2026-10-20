# R3 阅读位置隔离

2026-10-20。当前为切片设计，尚未实现/编译/验收。用户最新选择本轮只查清定位、R3顺延；候选仅在.cache暂存，不接入构建根目录。不将R2的53/53复用为本片结果。

## 先核定位疑点

39418977905小薇连续模式的断言后观察为anchorCondition=false，原断言通过；原始保存/关闭/打开锚点为p25/436，切换前模型p25/443，viewportOffset=-9.9375。原图仍在长段016处。旧附件缺少两个点的Range几何，既不能证明章头回跳，也不能认定只是采样误报。改前对照的两个同类观察同样保留。

只读诊断源5e2209c/CI39428259337保留原断言与预算，补切换前/实际保存两点的Range边界、片段、scrollY、实际viewport offset与连续模式两呈现帧后采样；只执行原真实字体长链一例。生产源码/字体/工程/依赖不变。未重复出错不等于旧问题已修，结论须来自实际几何和保存锚点的对应关系。

参考[W3C CSSOM View Range规范](https://www.w3.org/TR/cssom-view/#extensions-to-the-range-interface)，Range片段列表与合并矩形有不同定义；本地固定Readium3.11的EPUBSpreadView.continuousAnchorRectFunction优先第一片段，测试使用合并矩形。记录这一差异作为待测分支，不预先选定根因。

2026-10-20只读补证：old-canonical-comparison.json核两轮原件。小薇保存p25/436、offset=-9.9375，匹配/不匹配nativeY分别4818/4808；思源黑体保存p25/448、同offset，为4832/4822；朱雀保存p25/448、同offset，为4834/4824。其余三字体相同锚点下offset一致。不能再仅以“保存锚点编号不同”解释这些样本；但此对照仍缺当帧的两个Range几何和写入者，不直接认定唯一根因。

当前代码路径：EPUBInfiniteScrollView.navigationOffset/measure用canonical字位置减去xianxiaViewportOffset；EPUBReflowableSpreadView的精确domRange路径当前只用于分页，连续内层go仍用Readium文本匹配。迟到内层go忽略偏移、浏览器原生滚动调整、不同Range矩形等仍需区别。若新几何证明实际保存锚点也偏移约10点，下一有区分力的实验可在真实连续页面用显式队列屏障延后通用scrollToLocator，再放行：校验同一保存字与原3点合同，避免靠短sleep制造竞态。必须先证明负对照的指定失败，再在同一runner/构建目录验证最小修正；不得直接凭此假设修改Vendor或宣称根因已修。该控制实验尚未实现或派发。

## R3a：完整位置状态与保存请求身份

定位前置核查最新：39439273417给出有效几何，楷体与思源黑体在原断言后及原生截图后，保存字top=0.0625、expected=-9.9375、delta10，rect/rects完全相同。候选最小修正复用初始load已有updateViewports，在显式go设置外层offset后同样无条件同步一次，避免同坐标时没有外层回调导致内层DOM坐标残留。负对照冻结bc95fac只加强测试/诊断、生产不变：连续同一完整字/offset=-10的重复go，外层保持原坐标，显式不送scroll delegate回调，生命周期恢复该delegate。只有旧源在唯一指定断言失败，再运行一行修正和五个直接边界，才接受本片；暂无结果，不能预先宣称实际异步写入者或所有定位问题已修。R3候选仍未接线。

本小片计划把完整不透明ReadingPosition、显式保存请求身份、失败状态及同步结果接纳迁入真实ReaderPositions模块；App进度视图只观察显示摘要。通过原Core业务值复用版本化Locator，不解析/重写EPUB Locator或TXT锚点，不改变SQLite规则。

沿用现有XianxiaCore包，增加独立Foundation-only产品/target与直接测试target，避免引入新顶层包或Readium/UIKit依赖；XianxiaCore业务target不反向依赖ReaderPositions。project.yml实际链接产品，架构登记同步增加独立区域/节点及禁止UI/引擎导入的反例。与原ReaderSettings、Readium TestApp设置存储借鉴同一原则：状态/保存有效性拥有明确负责人，平台动作在调用方协调；不引入第三方框架。

App调用方保留原采样循环、3秒预算、32毫秒不可用间隔、暂停/flush先后、原数据库await、固定版式分支及错误文字。请求创建/核验/失效/结果应用为MainActor同步方法，避免职责提取新增async封装或改变原挂起点。close继续允许原引擎最终位置回调，保存请求先失效；打开/关闭生命周期仍属于后续R4。

直接合同覆盖完整字节/版本保留、同一会话新请求替代旧请求、旧defer不清空新请求、关闭/换会话失效、失败保旧及成功重试清错误。通过同步显式步骤模拟挂起前后状态，不加入依赖固定时间窗的竞态。

受影响生产文件限新模块、ReaderViewModel、ReaderProgressView、Core manifest/project.yml/架构登记；独立测试与边界工具反例另列。原设置、字体、导航/书签、引擎、Vendor、资源/锁及数据库实现保持。

最小验证：Windows仓库语法及工具；Linux/macOS真实模块测试；iOS原生命周期28、设置7、进度1及真实位置/字体的直接交界用例。仅在源码稳定后一次冻结派发，不逐编辑打包。完整187、严格设备Release、原生动效与手机验收仍属I6。

R3a只隔离状态和请求结果的接纳，完整采样/保存编排迁移仍属后续R3b。不能把R3a写成R3全部完成。

## 当前断点：连续偏移第二候选，分页另查（2026-10-21）

用户确认本轮只收口连续偏移，分页字体章头问题独立排查，R3顺延。39447634363/129e3506已完成失败：旧runtime负对照在指定断言失败10.875点；补updateViewports候选同样失败，不能验收，已只撤回其InfiniteScrollView和UPSTREAM两文件。完整156223138字节原件已核SHA/CRC并提取，原始退出65与两个失败保留；修正组3/5，另一项为分页字体重开章头，未走连续修改路径。

下一实验只改ReflowableSpreadView已有canonical DOM定位：无限连续模式在WebKit内部消费同一个字锚点与xianxiaViewportOffset；分页原分支保持。相同测试输入先运行原生产1例指定负对照，再运行6个直接用例（明确加入原分页完整字锚点回归；本次私有诊断字体链仅连续，默认仓库仍两模式）。原3点断言/预算、完整Locator/依赖/字体/App/Core保持，不增加等待重试，不导出IPA。新假设是内层默认文本定位忽略保存的viewport偏移；此前一行同步失败只排除该候选，不能冒称已捕获迟到写入者。

生成/检查/冻结前更新本断点；当前尚未实施/编译第二候选。完整187、设备Release、手机验收未执行，R3候选仍只在.cache不接线。旧分页字体问题继续作为发布阻塞项。

