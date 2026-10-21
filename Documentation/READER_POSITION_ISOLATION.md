# R3 阅读位置隔离

2026-10-21，R3a本片已实现/编译/定向验收。实际源755b428a60143d8f649372e6c545cc1e03f82ecb / [CI39573863939](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39573863939)。权威分项为ValidationLogs/project-isolation-r3a.json，历史设计/首轮失败过程保留在HANDOFF_R3_DEVELOPMENT_2026-10-21.md。R3整体与全项目隔离仍未完成。

## 状态与依赖负责人

独立Packages/ReaderPositions采用项目既有ReaderSettings布局，最低iOS16/macOS13、tools5.10，只通过显式Core产品依赖使用ReadingPosition。状态target只导入Foundation/XianxiaCore，不持有引擎、仓库、字体、页面或任务，不解析/改写Locator或TXT锚点。Core manifest及SQLite SDK/库配置恢复并保持原件；没有强制改变静态/动态链接或升级依赖。

ReaderPositionState唯一保留完整位置、显式保存令牌/所属会话及保存错误；ReaderProgressState只把同步位置事件转换为原去重摘要，避免两份位置状态。错误在突变前通知ReaderViewModel；不透明位置事件继续不触发整个ViewModel刷新。App组装/调用仍经原ReadingInterfaces。

## 保留的调用合同

saveNow的全部await表达式及顺序保持：暂停慢滚→慢滚flush→设置flush→完整实时捕获→原数据库保存→原同步发布。原3秒截止、32ms不可采样等待、固定布局直接使用完整缓存位置、Task取消与每个会话/请求guard保持。没有为纯提取增加async封装。

新令牌判断等价于原会话ID+请求ID；旧defer只能结束自己的请求，close使令牌失效。失败保留完整位置并发布原可见错误；成功先更新完整位置再清除错误。close仍允许引擎发送最后回调后才使openRequestID失效。原35个其他VM方法、35个原测试/fixture输入及Vendor定位修复保持。

## 入口与验收

- `bash scripts/test_reader_positions.sh <新的输出目录>`：独立真实SwiftPM 6项合同，无App/Readium；拒绝已有目录，保存真实退出码、xUnit和依赖。精确身份各一次、无失败/重复/遗漏/跳过；真实依赖只允许ReaderPositions→XianxiaCore。
- workflow的position-isolation：先6项，再8保存/生命周期+1进度+4真实EPUB/TXT/字体/同宽writer，共13项原用例。原断言/预算/测试主体保持。只本片先build-for-testing再boot/test，保留两个xcresult，优先暴露接线错误。普通完整发布顺序与门槛保持。
- 原完整Core仍137项；ci_ios.sh另外执行同一6项独立位置合同，保留原件。6项不加入iOS测试源，完整iOS仍159集成+29UI=188，当前未跑。

最终macOS6/6、iOS13/13、Linux工具71/71；Windows459语法新增0/既有Vendor限制54，71工具65过6 POSIX跳过。语法不是编译；真实模块与App编译由本轮macOS/iOS构建证明。135 Swift源/17区域/18图节点/5精确例外，新增禁止UI/引擎导入反例，未扩白名单。

两个模式各六字体重开原字/字体条件通过；连续截图后六保存位置delta全0。same-width回归原位置/原字断言通过，真实owner/frame源码匹配冻结JS，root写入0，唯一进度读1608且injected=false。该证据只覆盖这些样本，不证明所有WebKit时序、原生动效或手机体验。

独立步骤103秒含Swift报告81.5秒构建；原生步骤1392秒，首suite前1149.924秒含工具/依赖/编译/启动，实际13项累计202.182秒，余量含导出/诊断。没有把准备成本叫作测试时间或纯编译时间。完整17612505字节artifact经GitHub digest/SHA/ZIP CRC校验，原件build/ci/39573863939；只删除其重复ZIP。

## 首轮失败及取舍

首源a9d4e84 / CI39569845077真实独立6/6，但Xcode16.4规划Core自动dynamic产品时引用缺失PACKAGE-TARGET:CSQLite，原生test65、0项执行；完整59180字节原件及失败回执保留。新包接线与预先编译通过，不把首轮改写成功，也不宣称精确证明Xcode内部根因。

已查[SwiftPM官方target/product与testTarget规则](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)、[isowords实际功能target依赖布局](https://github.com/pointfreeco/isowords/blob/main/Package.swift)及[GRDB维护者对相同dynamic/SQLite缺target报错的说明](https://forums.swift.org/t/errors-on-build-after-add-package-grdb/76189)。GRDB是Xcode16.1同时嵌入两个产品的案例，本项目16.4消费图不同，只借鉴检查产品路径，不能照抄其根因。最终复用本项目已验ReaderSettings独立包布局，不迁移TCA、不提高系统下限。

## 剩余切片与发布边界

下一R3切片是完整捕获/写库编排的责任迁移，再单列导航/返回点；须先定义最小采样/存储能力、同步提交边界、迟到/取消规则及直接回归。R4会话负责人后续推进。不能因状态模块落地而称R3或全项目隔离完成，也不提前实现未来产品功能。

完整188、设备Release、普通设备/TrollStore、手机/动态验收均未执行，无新IPA；最后交付仍Build30。完整发布仍须同源重新验证，不能以本6+13或历史设备结果替代。
