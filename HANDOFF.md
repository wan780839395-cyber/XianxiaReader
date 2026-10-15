# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## Build17 开始检查点

用户确认Build16界面好看并授权阅读动效方案。先实施第一片：保留Readium原生跟手翻页，补阅读交互偏好保存、尊重系统减少动态效果的导航、翻页防重入、滑动自动收起菜单及连续模式防误横滑。仿真卷页、上下整屏、自动慢滚仍后续，先不铺开。源码尚未修改/编译。

已按规范读文档、核实际任务：无遗留CI/下载；Build16 CI38748113867 success。501源码blob、756维护文件、27包与四备份已核。main HEAD/原空index/M2/M3保持，当前M4 tip5d18fa569570e5a7d39c37395eafd9e958f1e77c。开始备份/逐文件hash见ValidationLogs/m4-motion-build17-start.json；Build16完整交接归档HANDOFF_M4_BUILD16_DELIVERY_2026-10-15.md。

## 验证门槛

实现后先Windows语法/17工具测试，再完整Linux/macOS Core、iOS集成/真实手势UI及无签名Release17。原定位/异步竞态/字体重排/所有旧断言保持；原生整窗截图与手势录屏、连续帧独立复核。普通签名/TrollStore/手机FPS和减少动态效果设备实测分列。Build16分页透明和巨段TXT孤立快照限制保留，优先用整窗证据核实，不把旧图追认为通过。

## 下一步

核Readium3.11公开输入observer/导航options与当前存储协议，写设计取舍，再实现并追加可恢复检查点。只用私有index快照，不改变原HEAD/index，不重置未提交文件。

## 源码落地，Windows检查前

已落地ReadingInteraction/独立存储、可选接口、被动drag与统一导航动效/分页防重入、连续防横滑配置、菜单10pt/0.2秒过渡、手感设置/顺序保存/重开恢复。4 Core+3生命周期+1实际WebKit+2原生UI新增，旧断言保持。设计READING_MOTION_DESIGN.md含精确Readium/Readest来源与限制；仿真卷页/整屏/自动滚动未实现。当前均未编译，不将源码写成验收。现在先Windows语法和17工具测试，之后审阅私有index候选再完整CI。

## 首轮CI已派发

源码8c548dce119899e6a0be9a17937c86ef34b39df6，CI38760598889，完整日志/结果待取。Windows423语法新增0/54 pristine限制与17工具测试已过，静态不是编译。当前预期各119Core/99iOS，完整Release17尚未产生。候选504运行/验证blob与27旧包hash已记录M4_MOTION_VALIDATION_REPORT.json。首次私有index diff --check误以原main为基线，输出上游既有whitespace；改为比较5d18fa5..8c548dc后干净，未修改Vendor。本轮源码提交只用私有index，原HEAD/index保持。

## Linux已核，Apple仍运行

CI38760598889 Linux119/119 Core和4原创长TXT Release探针原完整下载日志/summary已核，新增4交互存储回归通过。Apple job116511591232进行中，尚未确认macOS/iOS/Release，不根据旧网页片段推断。当前本地仅本轮gh watcher，无下载遗留。

## 中断恢复：首轮实际失败待诊断

重新按AGENTS顺序读文档并核任务，无遗留gh/python/下载进程。实际CI38760598889已completed/failure，repository与Linux成功，Apple失败，尚未下载完整结果，不能把首候选当成功。源码与8c548dce私有index比对仅文档差异，原HEAD/空index/M2/M3保持；恢复ZIP/hash见m4-motion-build17-resume.json。现在下载完整日志/xcresult找真实失败，保留原改动，不放宽旧断言。此前整批更新状态/路线/架构patch因架构标题不匹配全部未应用，待诊断后同步。

## 修正源码及第二轮CI前（2026-10-16）

首候选97/99实际失败/原完整日志已核，严格test65无IPA，失败回执first-failure.json。WebKit test hook最终返回null；不删instant/smooth/重叠翻页断言。普通拖动未收菜单，原始pointer可能被原生scroll取消，唯一时序未隔离；改用当前原生UIScrollViewDelegate willBeginDragging被动回调，覆盖章内/跨章/连续，保留选择清理/原delegate/手势物理。四Vendor文件/README/provenance准确更新，无JS/锁升级。第二次Windows423语法新增0/54限制、17工具测试通过，仍非编译。现在私有index审阅后保存第二候选/完整重跑；第一轮554MB诊断zip下载进行，定向取失败录屏同步进行，下载EOF/慢速仅本地网络问题不写产品失败。
