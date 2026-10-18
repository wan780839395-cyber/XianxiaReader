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

## 第二完整CI已实际启动

2026-10-18T11:10:34.515691+00:00：run39122142797/sourcec30ff2d2648a8b2e4ca3bbcae2c2f8f6963d6078/codex/m4-reading-edges。首轮完整失败/原生拒绝按独立历史记录，不继承为本源门槛；新显式z层级+父级合成回归，其余生产/旧test未改，Windows449/17/14原UI主体保持。547冻结blob，预期Core137各/iOS163=136+27/Release29；本轮未完成不交付。首轮watch/collector已完成且完整诊断保留，新本地监看/收取另启于新run目录；恢复先核实际任务不重复dispatch。

第二完整源c30ff2d的Core artifact12134856979已真实校验SHA/CRC/完整提取，137/137与4长TXT Release探针正确，只置Linux门槛；Apple已从排队进入运行。本轮原生复核还将查看旧字体收藏完整录屏，不能只靠重跑退出码忽略首轮保存失败。当前源不再变化，余下为自动/原生/交付独立门槛。

## 条件式原生素材准备前检查点

第二完整39122142797仍运行。新增有界本地素材准备助手仅在collector严格验证全部自动门槛后生成选定PNG联系表与6条完整原录屏一秒总览，不进行人工接受或打包；CI失败则终止准备。手工查看、原始帧窗口、手机性能与交付仍独立。源码继续冻结c30ff2d，原watch/collector复用不重派，所有helpers均记录在当前run目录。

## 第二完整结果与最小测试修正（构建前）

39122142797/c30ff2d实际159/163无Release/IPA，Core137各；4失败为新父级layer合成像素、旧continuous跨章边界、旧进度跨章summary及旧书签UI开书。首轮旧字体收藏本轮过，不能追认旧保存时序根因解决。30 PNG/5表与4完整原录屏16表已看：真实浅深安全边缘已盖好；chrome正文第二章但footer旧章、panel失败尚在书架根本未打开reader；后两不通过放宽等待解决。新CALayer.render parent样本红边与屏幕实际黑边不一致，已查Apple层树render与可见UIView.drawHierarchy文档。仅新test合成部分改用UIKit完整屏幕层级快照，保持原像素值/触摸/frame/2秒要求并追加可审原图，孤立shape仍用原render；生产App/Core/Adapter/Vendor/CI/全部旧test不变。完整1744510958byte artifact SHA/CRC/解压已核，重复ZIP/208分片移除。条件准备助手遇失败已退出；下一步Windows→冻结→独立完整验证，不交付未过源。

## 第三完整CI已实际启动

2026-10-18T12:18:13.665372+00:00：run39126639352/sourcea9f4f8ab17bf28707cfc3fb8f171354a13751a3f/codex/m4-reading-edges。Git对c30ff2d核App/Packages/Vendor/scripts/.github/锁/project.yml完全相同，只修本轮新测试UIKit合成采样；原颜色/命中/几何/保存/等待预算与14原UI主体全部保持。547冻结blob，预期Core137各/iOS163=136+27/Release29。前两候选真实失败不追认，本轮尚未编译/交付。原助手均退出，第三watch/collector/条件素材准备另起当前run目录；恢复先核实际任务不重复dispatch。

第三源Core artifact12136805192已核真实SHA/CRC/137测试/4长TXT Release探针；仅Linux门槛true，Apple执行中。对a9f4f8核工作树只有文档变化；对c30ff2d核生产App/全部业务与CI/依赖完全相同。新合成诊断图会与实际阅读截图分列，不混入用户Preview；记录生产不变和旧失败边界。

补查第二轮旧continuous边界失败原诊断：在进入边界移动前初次slot0加载即超时，position=nil、DOM href=blank/ready=complete、slot.ready=false，outer402×874/inset62/34；不是已证实的跨章索引错误，也未据此认定遮罩或环境唯一根因。旧测试/引擎/超时不改，详情已补第二历史记录。第三完整仍运行。

## 再次恢复实核

2026-10-18T13:06:11.476878+00:00：按顺序重读项目文档，正常HEAD/index保持，1062原路径全部仍在，51旧包逐SHA一致；冻结源a9f4f8a后仅文档变化。实际第三CI仍运行，原watch/collector/条件准备三个Python助手存活，未重派或重复启动。断点仍是完整Apple结果，不将前两候选失败或待编译源写成交付；恢复快照build/ci/39126639352/interruption-resume.json。不关机。

## 第三完整实际失败与同源有界复验前

第三39126639352/a9f4f8a为162/163（失败/跳过1/0），Core各137和各4探针正确；新UIKit父级合成像素及浅深慢滚旋转通过，前轮失败旧字体/连续初载/跨章summary/书签开书本轮均过。唯一旧菜单重启后设置无面板（原454断言）。实际4 PNG/1表、57.67秒原视频4总览及44.5–46.2原7帧/1表看过，最终AX有正文/设置但无sheet，无保存alert；根因未定。1889128041byte完整artifact SHA/GitHubdigest/CRC/提取核实，重复ZIP/226分片已清。watch收尾log因EOF退出，独立有界重取真实full.log/manifest成功，原collector已按失败退出；不追认通过/无Release或IPA。只允许一次完全相同a9f4f8a的完整复验，不改生产/旧断言/等待/测试名单；若再失败转定向生命周期诊断，不盲重跑。历史证据m4-edges-build29-history-39126639352.json。

## 同源一次完整复验已启动

2026-10-18T13:21:11.420137+00:00：39131131911/codex/m4-reading-edges/sourcea9f4f8ab17bf28707cfc3fb8f171354a13751a3f。与第三候选源码/测试/CI完全相同，独立门槛全部重置，前3轮失败各自留证。上轮三个助手均已退出，再起本轮有界watch/collector/条件素材准备；恢复时不重复派发。

第三源额外原生复核已看7 PNG/2表和68.99秒安全区录屏5表：迟到内容合成诊断确为黑边红中心；浅深暂停状态边缘可读，旋转PNG是黑区过渡、恢复竖屏PNG是加载，均不当稳定页/Preview。原录屏随后有稳定横屏和竖屏重载后正文，不能等同完整动效/手机验收。已补第三历史记录，第四同源完整仍独立等待。

同源第四完整39131131911的Core artifact12137938207已真实校验SHA/GitHubdigest/CRC/完整提取，137测试与4长TXT Release探针通过，只置本轮Linux门槛；第三失败/原件仍独立。Apple当前执行中，源码a9f4f8a不再变更。

## 同源复验等待期保全检查点

2026-10-18T13:36:04.334882+00:00：39131131911/a9f4f8a仍Apple运行，547编译资源blob全部匹配；当前只有文档/验证记录变化。watch PID19672、collector PID16732、条件准备 PID3372存活；第三轮助手已退出。即将把实际前三轮失败记录和当前恢复点另存appearance私有文档快照[skip ci]，edges仍固定编译源，不触碰正常HEAD/index，也不重派CI。此时Build29仍无IPA/交付。
