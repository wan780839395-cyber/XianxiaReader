# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## 最新断点（2026-10-16）

实际待验源码50ecf2914a5085716e981adcfbb572a343326083，第四轮CI38771271584已失败97/99；89集成全部通过，两个UI准备手势失败。Windows423语法新增0/54 pristine限制、17工具测试与第四轮Linux119Core/4长TXT Release探针已核；Apple/iOS/Release17不能写通过，尚无Build17交付IPA。当前只补文档，源码冻结。

已实现第一片：手感偏好/模式保存、原生drag收菜单、短菜单过渡、系统/用户减少动效、分页命令身份保护/防连续误横滑。卷页/上下整屏/自动慢滚仍后续。第一轮97/99修测试JS返回null与真实正文可读准备；第二轮原生回调实验由Agent取消并已撤回；第三轮新功能全过，但旧分页重开与设置firstMatch滚错reader失败97/99，完整日志/xcresult/原生素材保留。第四候选必要补普通分页完整DOM锚点回调+offset/size/revision保护、设置面板独立id；原非零文字/180%/重开/10秒收菜单断言不放宽。

下一步核实际CI完成状态，下载完整日志/诊断/IPA；用.cache/recovery/validate_motion.py finish核119各平台/99iOS/真实三锁/四长TXT探针/504源blob；inspect_continuous_ipa.py实际参数17检查IPA。review_motion.py准备24图/5视频并复核本轮新手势两段及连续帧，再记录nativeReview，才可package_motion.py/finalize_motion_docs.py/preserve_motion.py收尾和私有index纯文档快照。报告M4_MOTION_VALIDATION_REPORT.json。原HEAD/空index/M2/M3、27旧包和七份备份保持；不要用普通git add/commit/reset，不沿用旧关机请求。下方为完整发展检查点历史。

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

## 失败录屏确认真实准备时序，撤回未必要实验

已复核首轮普通/减少动效两个完整1秒总览：普通拖动时仍是spinner，12.5秒才正文；减少动效4.5秒正文后拖动成功。不能把原始pointer取消假设写成根因。第二候选c9bae997/CI38765644376主动取消，实际阶段与七文件实验ZIP/hash见second-agent-cancel.json。仅撤回自己新增原生回调到首候选，原Vendor/Adapter恢复，WebKit null修正保留。UI准备阶段加真实样本文字可读门槛再执行原手势/10秒断言，不加重试或放宽旧断言。现在Windows重核后第三候选全跑。

## 第三候选已启动

真正待验源码1d1f2763e743657f25d6ba66ca10c3a5ee922f74，CI38765962839。只相对首候选修正测试JS返回和正文可读门槛，产品源码/Vendor与首候选相同；Windows423新增0/17工具再次通过。前两候选/失败/主动取消证据及ZIP保留，原HEAD/index不变。待99iOS/各119Core/Release17完整结果，所有旧断言保留。

## 第三轮Linux119/四探针已核

CI38765962839 Linux完整下载artifact119/119与四组Release探针通过，Apple进行中。第二轮实际取消停在Linux Release TXT probe，Apple无steps且不曾编译，gh组合log因此报告缺Apple job日志；已单独下载真实Core job日志/artifact，不把网络EOF或缺未运行job日志算源码失败。首轮完整554MB诊断下载还在推进，定向失败录屏已全部取得并复核。

## 完整首轮诊断已核、当前源码冻结

首轮554MB ZIP CRC/xcresult/99总97过2失败/Apple119Core/源编译零警告零错误已核，first-failure.json更新。当前候选1d1f2763运行/验证源冻结，私有index核只文档变化；本地仅第三轮gh watcher，无下载遗留。第三轮Apple job116530134518仍build/test step进行，不能根据单一step假定已编译或测试通过，最终待下载完整结果。

## 第三轮97/99，两个旧回归失败（2026-10-16）

CI38765962839 completed/failure：各119Core/四探针，新增实际instant/smooth/重叠翻页、正常/减少动效真实拖动、模式/开关保存重开均通过；旧字号180%后重开回章首及旧设置firstMatch滑错底层连续阅读区失败，严格test65无IPA。完整日志已保存，598MB诊断/xcresult多段下载进行。

必要修正：设置ScrollView加独立AX id并让原测试只滚设置面板，原控件/数值断言不变。官方3.11普通分页calculator只生成progression locator，存在覆盖先前DOManchor路径；水平LTR重排分页定位通知合并既有有界DOM采样+官方metadata，await后核spread/offset/size并保留外层revision/session过滤。固定/RTL/竖排沿原路，Vendor仅Controller/hash/README变动，无JS/锁升级。原字体非零文字/180%/重开/超时保留，另加重开前完整DOM范围断言及仅原创fixture JSON附件。设计和官方依据更新后跑Windows，再完整第四候选，不把修正源码写成验收。

## 第四候选正式派发

源码50ecf2914a5085716e981adcfbb572a343326083，CI38771271584。首次workflow dispatch API EOF，核实际run列表没有新任务后只重试一次成功，不把网络错误记源码失败。Windows423新增0/54限制、17工具测试通过，diff --check相对第三候选干净；504blob已按真实第四候选记录，原HEAD/index保持。第三轮完整598MB ZIP/xcresult CRC与97/99摘要核过，新增动效/手势/偏好测试均过但两旧回归严格阻止IPA。现在等待第四轮各119Core/99iOS/Release17，记录源和后续纯文档tip分列。

## 第三轮成功新手势case原生复核

已看第三轮67.62秒新正常手势case全时段1秒总览5张contact（实际视频采样，无插帧，不是手机FPS）：正文就绪后横拖收菜单/中央恢复、连续纵拖收菜单、手感组两开关、重开模式/开关及关闭自动收起后的滚动都对应实际画面。属于整体97/99失败轮的局部证据，不作最终Release验收。第四轮仍待实际全部结果；回执third-native-partial-review.json。

## 第四轮Linux已核

CI38771271584 Linux下载原件119/119与4组Release探针全过，Apple仍运行；回执fourth-linux.json。源码50ecf291冻结，只补文档，不假定iOS/Release成功。最新恢复脚本validate_motion.py/review_motion.py/package_motion.py/finalize_motion_docs.py/preserve_motion.py均在.cache/recovery，最终操作受实际99/99/119各平台/Release/原生复核门槛约束，未执行交付打包。

## 第四轮集成89/89，两个UI准备手势失败

源码50ecf291/CI38771271584，各119Core/四探针，89集成全过（原非零字180%重排+完整DOM断言+重开6.457秒通过），实际动效/防重叠通过。UI原设置面板向下滑后外观按钮消失，日志确认target已是reader.appearance.scroll，说明仅标识范围不够，不能在已位于顶部/控件可点时盲滑向下；改先检查目标isHittable再限定面板向下查找。新普通手势case横拖已过，切连续后立即纵拖未收菜单，切换label早于原生异步重建；补等实际readium.continuous-scroll和样本文字可读后执行原纵拖/10秒断言。不增加手势重试、不放宽20秒准备或旧断言。实际失败原生视频待下载复核，下一轮只改测试准备，生产50ecf291不改。

## 第四轮实际录屏确认、第五轮测试准备前

第四轮550MB ZIP/xcresult CRC及97/99摘要已核。真实设置录屏55.5–56.5秒外观tab已可见，向下手势后57.5秒sheet消失；故第五轮revealAtTop先核isHittable，仅目标不可点时在明确设置ScrollView中向下查找，原控件/数值断言不改。正常新case原横拖/菜单恢复画面确认，模式选择后缺少原生连续容器/正文就绪等待，下一候选补此真实准备门槛再执行原纵拖/10秒断言，不增加重试。不将未证的pointer问题当根因，生产50ecf291位置修正和交互实现保持。现在Windows423/17重核，再完整第五轮。
