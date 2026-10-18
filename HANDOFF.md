# 当前交接与恢复点

## 恢复先看：Build29 修正版完整验收执行中（2026-10-19）

实际断点：完整run39147081645 / source a65086c1151831b54d90ed083fa36fc27848b5cb / codex/m4-reading-edges。原watch PID44248、collector PID28904有界运行；先核build/ci/39147081645/run.json、owned-helpers.json、完整日志和实际进程，复用现有任务，不重复派发。GitHub只有本轮完整任务正在运行。

本轮Linux137/137与4组长TXT Release探针已真实校验，Apple/iOS163/设备Release29尚待；不得继承旧macOS结果或把定向10算成163。最后交付仍Build28，根目录没有Build29交付IPA/TestKit。完成完整门槛后仍须本源原生录屏/原始帧复核和包校验，若失败保留实际阶段，不继续同源盲重跑。

已完成：recovery39144858281/source同a650真实10/10，新增窗口真实出现/退出收尾，appearance不平衡警告0，旧主题2秒测试通过；42原图/7表与4原视频一秒总览18表已查看。加载阶段113 trace/1156事件，已完成72条最慢6.779s；系统额外日志20秒超时，UI完整呈现trace未取得。诊断完整原件SHA/GitHubdigest/CRC已核，重复ZIP/分片清除，详情m4-edges-build29-diagnostic-result.json。四次旧完整失败记录独立保存，a9完全同源复验次数已用尽；本轮a650含有实证的新窗口生命周期修正及Debug元数据，不更改299旧test主体/加载或保存预算。

保全：正常HEAD6d761749/空index保持，1062原路径与51旧包保留；19恢复ZIP和.cache/recovery诊断前6文件原字节保留。appearance文档恢复tip f603617cb8f964e2a6cccd5978ac10d4a8ee25db，实际compiled source和diagnostic branch仍a650。应用源码冻结，后续只改文档/ignored本地收取工具。用户已取消关机，不关机、不设置自动化。

下方为本片开发历史，不能覆盖以上实际断点。


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

## 2026-10-19 恢复：第四轮已失败，诊断下载待续

实际39131131911/a9f4f8a已失败，完整full.log/run/artifact清单在；旧字体连续重开DOM blank/加载超时、旧主题呈现2秒超时、旧chrome返回定位失败。collector因artifact临时链接403退出，留下176个完整分片（1476395008字节），条件准备超时退出；当前无本项目Python/GH/FFmpeg助手。正常HEAD/index、1062原路径、51旧包逐SHA核对保持。先刷新临时下载地址续传同artifact12139382561并核SHA/CRC/实际summary，更新第四失败记录；不再完整盲重跑，转生命周期/加载定向诊断。源码仍a9f4f8a，Build29未交付/无ReleaseIPA；最后交付Build28，不关机。

## 2026-10-19 定向诊断改动前

第四完整160/163、Core各137，完整artifact1917043323字节已续传并核SHA/GitHubdigest/CRC/提取，重复229分片/ZIP已删除；实际失败记录m4-edges-build29-history-39131131911.json。不再派发同源全量。先保留6个待修改文件原字节/摘要到.cache/recovery/20261019-build29-diagnostic/before。拟仅补Debug无正文/书名的加载阶段、清理前快照与设置呈现追踪；新窗口测试等待真实viewDidAppear/DidDisappear，不改14原UI主体/旧断言/2秒旧主题或20秒加载/3秒保存预算。现有recovery定向诊断加本次相关病例，不产生IPA、不冒充全量门槛。尚未修改/检查/编译新诊断源，Build29未交付。

定向诊断源已接入待检查：新window测试用真实viewDidAppear/DidDisappear有界回调收尾（旧主题2秒不变）；Vendor两文件只补Debug24条无正文/URL阶段和20秒watchdog清理前快照，公开导航回调只记录状态不重试；App只在Debug UI样例入口加1px不接触触摸的AX追踪与安全元数据日志；recovery选定新增相关病例共10项，另20秒有界日志采集保留原退出码。第四原生4 PNG/1表+50.85秒4总览看过：返回前浅深第二章67%正确，~30秒返回后全页spinner直至失败，不能写成定位通过。下一步Windows449/17、旧test对照/差异冻结→只跑定向10，不进行交付。

首次Windows语法检查未过：现有tree-sitter不接受class body内#if DEBUG成员区，未忽略新增诊断。已改文件顶层编译期开关/方法内守卫：Release开关false，不生成诊断日志或AX节点；字段空默认值保留，Release不分配trace UUID/阶段记录、不新增重试或预算。仍需重新检查/编译；不是编译通过声明。

诊断冻结前检查通过：Windows449语法新增0/54既有Vendor限制、17工具通过，bash -n通过；299个既有test方法主体逐字对照保持，唯一改本轮新增window测试生命周期。6源文件改动白名单/摘要与诊断计划见m4-edges-build29-diagnostic-start.json，差异.cache/recovery/20261019-build29-diagnostic/diagnostic-source.diff。下一步私有快照/独立诊断分支→recovery10，不能改写a9四轮完整失败或签发IPA。

## 2026-10-19 定向10项已实际启动

run39144858281/sourcea65086c1151831b54d90ed083fa36fc27848b5cb/codex/m4-edges-diagnostic，selection=recovery。正常HEAD/index保持，实际edges编译分支仍a9f4f8a；appearance快照a650保存诊断改动，未改默认完整CI/版本29。只监看/收取本轮诊断，不签发IPA；恢复先核实本run状态和owned助手，不重派。第四完整160/163失败与源码a9仍独立记载。

定向执行中实核：run39144858281/sourcea65086c，watch PID16756、诊断collector PID6064存活，无其他本轮助手；诊断run的547 Git-filtered编译资源blob已记录，不用raw CRLF冒充CI字节。第四完整full.log同一字体失败前明确WebContent进程启动32.046339秒，超过原20秒资源看门狗；仅记为可测贡献线索，不定为全部失败/手机根因，所有旧时限仍保持。


## 定向诊断执行期间恢复实核

2026-10-18T16:41:32.517747+00:00：实际39144858281仍原source a65086c；6个诊断改动文件原字节摘要一致，1062原路径在、正常HEAD/index保持。watch16756/collector6064继续复用；不重新派发，不从运行耗时判断挂起。实际断点仍为recovery10结果及生命周期原始日志。resume-source-audit.json保存本次核验；不关机。


## 定向实际通过与新完整验收前

2026-10-18T16:53:36.043228+00:00：39144858281/a65086c真实10/10、失败跳过0，Linux137/4探针；新window实际出现/退出0.373s、紧随主题呈现0.276s，appearance不平衡警告0。42 PNG/7表、4条完整视频一秒总览18表全部实际查看，所列菜单重启设置、跨章67%/返回、字体收藏查询三预设及0.05重开/Files取消恢复状态可接受；不当完整动效/手机或163门槛。完整Apple226610009字节已校验SHA/GitHubdigest/CRC，重复28分片/ZIP删除；ignored collector初次错认build前缀的本地异常已保留并改正，不重下。1156条加载阶段/113 trace、72完成初始化最慢6.779s，非UI进程记录；系统reading-lifecycle额外采集20秒超时，无UI呈现完整trace，不冒充取得。

即将同一已诊断a65086c送独立完整163+Core137各/Release29，包含有证据的新增窗口生命周期修正与Debug阶段记录，不再是旧a9同源盲重跑。299旧test主体、全部时限/保存/排版/位置逻辑保持；四次旧完整失败及本轮定向门槛独立，最后交付仍Build28。预先重置主report完整门槛为false；不得把10项通过写成163或IPA。


## 修正版完整CI已实际启动

2026-10-18T16:54:17.810810+00:00：run39147081645/sourcea65086c1151831b54d90ed083fa36fc27848b5cb/codex/m4-reading-edges，selection=full，实际正常HEAD/index保持。547冻结编译资源blob，预期Core137各/iOS163=136+27/Release29；定向10及原生复核不替代本轮完整门槛。继续监看和完整收取，禁止重复派发、未过源不交付。恢复先核本run与owned助手。


修正版完整39147081645的Core artifact12143123626已真实下载并核GitHubdigest/SHA/CRC，137/137及4组长TXT Release探针通过，仅置linuxCorePassed=true；Apple仍执行。原定向采集20秒超时和四次旧失败保留，新完整源a650冻结，watch44248/collector28904有界运行。


## 修正版完整作业成功，完整收取与原生准备前

39147081645/sourcea65086c实际run success；完整full.log已核iOS163个case passed/0 failed、TEST/BUILD SUCCEEDED、test/export/summary/recording退出0、Swift/C编译警告错误0、appearance不平衡警告0。此时完整Apple artifact仍在下载，IPA已校验、Core复用本轮已校验receipt；尚未执行最终source/包/全部原生门槛，不标交付。拟条件助手只在collector严格验证全门槛后生成PNG联系表和六录屏总览，不代替人工看图/原始帧。源继续冻结，历史失败独立保留。


## 第五完整自动通过，但原生发现新用例假通过（修改前）

39147081645/a650真实Core137各/iOS163/Release29全部严格校验，完整artifact1820MiB级SHA/digest/CRC已核并去重复；仍无根Build29交付。实际37 PNG/7表、新旋转61.54s/5总览看过，33s在旋转加载期间切深色，37-41s有页面仍在排版alert，随后浅色正文配深色边缘/控件，不能放行。新UI只等app横竖比例，未等真实正文或断言主题/alert；先加强此新test，不改299旧主体/生产预算。待改2文件原字节备份.cache/recovery/20261019-build29-rotation/before，先选定包含新旋转用例诊断，不能用本轮自动通过冒充原生接受。其余5条预备录屏尚未人工看，不声称已看。详m4-edges-build29-history-39147081645.json。

新用例已加强待检查：只在本轮新增旋转test内，主题应用后及横/竖恢复后等待实际正文可见、无可见加载spinner/alert，并核截图中央纸张主色（暖白F8F5ED/深灰242826，允许文字笔画），原frame10秒/其他动作及全部旧test保持；每个新就绪条件有20秒上限，不加sleep或重试点击。recovery加入该新用例共11项。生产App/Core/Adapter/Vendor/默认完整CI不改。Apple orientation与XCTNSPredicateExpectation官方markdown已实际读取并留摘要（当前Xcode16.4适用；文档明确设备物理方向不直接等同App界面方向），不把比例变动当WebKit排版完成。下一步Windows449/17、299旧主体对照/原截图判定检查后才派定向11。

旋转新断言冻结前检查已完成：Windows449新增语法0/54既有限制、17工具通过；对a650逐方法核299其他test（含Core137+iOS/UI162）字节一致，仅本轮新增旋转test改；生产App/Core/Adapter/Vendor/默认CI字节完全同a650。保留真实图中央主色检查能拒绝错误深色0/1600而接受正确深色1594/1600及暖白1237/1600，不冒充Apple执行。下一步私有快照/独立rotation诊断分支recovery11，先不改当前a650完整自动门槛或交付IPA。
