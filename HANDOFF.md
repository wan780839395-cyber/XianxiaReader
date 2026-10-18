# 当前交接与恢复点

用户补充Build28正文/设置“目前感觉流畅”，已记录主观手感认可，未扩大为实测FPS/所有设备。Build29继续安全区片，不盲改位置/采样管线，见m4-chrome-build28-device-feedback.json.readingAndSettingsFeel。

Build29 安全区边缘开工（2026-10-18）。已核正常HEAD6d761749/空index、私有文档tip cfe5e65、Build28源8acc3f2/CI39113019568完整成功和交付。用户反馈没问题后继续；本轮先修连续滚动/慢滚在隐藏菜单时正文进入状态栏和home indicator区域。1062原路径/51旧交付包/18旧ZIP核验，新增第19份恢复ZIP，见m4-edges-build29-start.json；无遗留开发任务，不关机。

实际源码：ReaderSurface保持fullsize/ignoresSafeArea；锁定Readium3.11的EPUBInfiniteScrollView对safeArea设置contentInset，但中途滚动仍能绘制到inset区；Build28 header遮罩在隐藏/慢滚时不显示。拟使用UIKit已有safeAreaInsets与CAShapeLayer evenOdd在引擎视图上仅绘制不安全四边，颜色跟随当前纸张，触摸/辅助功能穿透、不改变viewport/contentInset/offset/完整Locator或Readium。旋转/布局变动更新几何，关闭/重建移除装饰。需要真实UIKit像素/命中测试和原UI慢滚浅深/旋转录屏复核，再完整新CI才交付。当前未实现/Apple编译，Build28仍最后交付，手机FPS/M4整体单列。

## 实现后、正式检查与构建前

ReaderSurface追加只绘制实际不安全四边的UIKit/CAShapeLayer装饰，保留原控制器/fullsize、位置/滚动管线；主题色随更新、自动布局/安全区变动重绘，dismantle移除，不接收触摸。新增真实window像素/命中/几何回归1项及浅深慢滚旋转UI1项，全部原test主体计划保持；新文件已由XcodeGen App/Tests路径覆盖，无SwiftPM业务文件。已一轮Windows449语法/17工具通过（语法不算编译），补兼容既有直接ReaderSurface初始化后会重新正式检查。下一步冻结源/原test对照、私有branch完整CI，再收取原生证据；尚未Apple编译。

## 完整CI已实际启动

2026-10-18T10:08:46.996002+00:00：run39118070518/source13812bd2ae4f446ce0ebba8c48bdb8b0946946ba/codex/m4-reading-edges。正常HEAD/index保持；547源码/资源blob，14原test主体不改，新增1真实window集成+1慢滚旋转真UI。预期Core137各/iOS163=136+27/Release29，未完成不交付。build/ci/39118070518/run.json核实际状态，原生复核与手机FPS分列，不重复dispatch。

## Linux实际门槛与来源核对

完整Core artifact12132867613已下载并校验GitHub SHA/CRC，重复ZIP/分片删除；137/137与4长TXT Release探针实际通过，只置linuxCorePassed=true，Apple/iOS/Release仍待。Apple官方markdown已实际读取，safeArea API最低iOS11、fillRule最低iOS3均适用iOS16；来源/摘要见m4-edges-build29-reference-review.json。装饰不包装引擎控制器，不改contentInset/offset/Locator；当前原test保留且冻结源未再改变。

## Apple作业监看

状态查询一次EOF已保留build/ci/39118070518/watch-error.log，独立复查原source13812bd/Applejob仍in_progress、前两job成功；没有取消/重派。运行日志接口尚未提供完整job logs（有界单次尝试记录保留），不从日志片段/运行耗时推断挂起或通过。watch/collector仍为原有界进程，源码冻结不变。

## 中断恢复核验

2026-10-18T10:46:18.566406+00:00：实际run39118070518仍in_progress/原source13812bd；watch PID7164与collector PID13424均存活，未重新派发或重启。547冻结源码范围无变化（仅后续文档），1062原路径仍在，51旧包逐SHA匹配、正常HEAD/index保持。原449语法/17工具、Linux137/4探针证据存在；尚无Build29根IPA，Apple未完成，不推断最后一步成功。继续等待同一完整作业→收取完整artifact/严格门槛→原生复核→打包。具体恢复快照build/ci/39118070518/interruption-resume.json。

## 恢复期间源码审查新增线索

2026-10-18T10:52:20.994715+00:00：Adapter host为UIViewController，open异步在host.view.addSubview(navigator.view)，而ReaderSurface make时先附加cover；当前cover默认z=0，潜在后挂载内容遮住装饰。真实window测试当前只验证无迟到子视图的像素，需收本源原生画面确认，若证实再补显式render层级与迟到子视图合成像素回归。此时未改冻结源、不取消/重派正在运行CI，不把静态推断当本源原生修复已验收。

## 首候选实际失败与原生拒绝，修正前

39118070518/source13812bd完整162/163（Core137各），旧字体收藏测试在返回书架后entry.isHittable失败；原录屏56.98s/4表及49.8–50.4原始20帧/2表实际查看，证实正文仍在reader加载/保存spinner，随后明确位置未稳定的保存失败alert，书架在下面不能点。不是仅AX等待；原3秒fresh保存预算/可见错误/旧test均保留，字体重排时序唯一根因未定。新增window/慢滚旋转UI均过，但28选定PNG/5表与新慢滚59.65s/4表看过，原浅色触摸/后台状态栏和底部仍透字，cover被后挂载navigator挡住线索成立，不能交付。横屏截图位于旋转中黑区，录屏后来有稳定横屏，静态图不验收。完整2010192282byte artifact SHA/CRC与完整解压已核，重复ZIP/240分片删除；无Release/IPA。证据m4-edges-build29-history-39118070518.json。拟仅补cover显式绘制层级与后挂载内容合成像素回归；不盲改字体/DOM/保存管线，旧字体用例原样重新完整核验。

## 最小层级修正已接入，检查/构建前

cover.layer.zPosition=1明确高于后挂载navigator默认层；真实window测试追加迟到红色内容后核父视图合成上下黑边/中心红色，不再只看cover自身。原frame/触摸/完整位置管线保持，旧字体测试与保存预算完全不改，失败首轮及实际录屏/帧保留。即将正式Windows449/17与原test主体对照，再独立完整CI；未编译新源不交付。
