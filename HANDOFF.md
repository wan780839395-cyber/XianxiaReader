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
