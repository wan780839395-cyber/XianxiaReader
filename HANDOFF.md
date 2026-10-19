## 本地助手修正

同源字体39179687615仍运行，watch30380/collector28184为当前助手；旧collector37268因watch尚未写run.json退出，旧42244只在本地等待时终止以匹配fonts artifact名，原错保留，没有取消/重派CI。当前源码仍f320，无Build29交付。用户最新取消关机，保持开机。

## 当前恢复点：同源字体2项复核中（2026-10-19）

39179687615/sourcef320/codex/m4-edges-screen/selection=fonts运行原有2个字体case一次；watch30380/collector37268，核实际run.json与owned-helpers，不重复dispatch。生产/测试均未再改。C39155583794实际10/11、新旋转81.659秒通过；唯一旧字体case初次cover定位20秒未发位置，未到换字体动作，根因不确定，保留失败。当前C完整artifact SHA/digest/CRC已校验并去重；10原图/2表、81秒视频6总览和3窗口114原始帧/11表已看，浅深横屏/恢复竖屏及所列安全边缘可接受，旋转加载/短暂章头仍不算无缝动效。详screen-native-review和screen-diagnostic-result。

完整A39147081645/a650自动163/Release29保持真实通过，旧原生旋转拒绝历史不改；同生产的C正确新序列补充证据分列，待字体复核结果再决定交付，不冒称C11全过或C重建Release。Build29未打包，最后交付Build28，正常HEAD/index和全部未提交改动保持。

最新用户已明确“改完别关机了”：覆盖此前完成后关机授权。保持开机，本轮没有发出关机命令或安排关机。

## 初始位置失败的有界同源字体复核（派发前）

39155583794实际10/11，新旋转全序列81.659秒通过；10 PNG/2表及81秒原视频6表已实际查看，暖白/charcoal横屏与恢复竖屏正文均正确、未见排版错误alert，App横屏裁图黑区由双原图/几何probe证实。完整下载SHA/GitHub digest/CRC已核，分片ZIP去重。

唯一旧字体case在首次cover.xhtml的20秒probe未收到引擎位置；DOM封面ready，两个spread初始化约2.5秒完成，未到字体切换/重排动作。代码有隐藏页保护与初始化/位置采样时序线索，但没有足够证据宣称唯一根因或修改生产逻辑。本轮仅用现有f320/source、现有fonts选择运行原2字体case一次，验证干净job的初始位置及完整双模式/隐藏重排；不扩大超时、不改任何test、不重跑全量或反复重试直到绿。若失败转具体采样/可见性诊断、继续不交付；若通过仍记录C失败与根因不确定，不宣称旧问题已修。完整A163/Release、新C旋转、同源字体复核的来源和结果分别列出。

## 最新恢复实核（2026-10-19，覆盖旧运行中状态）

整屏诊断39155583794/f320已经completed/failure，实际10/11：本轮加强的旋转case通过81.659秒，旧隐藏字体重排case在初始cover.xhtml定位未发出时20秒probe失败，尚未执行换字体。不能将补充11写成全过；完整a650的163/Release通过与其原生拒绝历史继续独立保留。正常HEAD6d761749、空index、628项改动未重置；本轮恢复前没有遗留Python/GH/下载助手。

上轮collector在本地空间前检assert处结束、未完成收取；本轮D盘135654141952可用，保持原12GiB前检通过后重新收取同run完整artifact，不重新派CI、不删除历史。先SHA/CRC/真实summary，再复核新旋转双截图/几何/录屏及旧字体失败。生产不变，不放宽20秒/3秒或删除旧测试。Build29未交付，最后包仍Build28。

最新用户明确“ok 做完帮我关机”，取代旧取消关机指令；仅在本轮开发、必要验收、交付及交接全部完成后执行关机。当前工作未完成，没有发出关机命令或调度。

# 当前交接与恢复点

## 恢复先看：整屏采样定向11执行中（2026-10-19）

当前run39155583794/sourcef32002880ebe7702321cce90f1d030823c047c53/codex/m4-edges-screen/recovery11。watch PID29904、collector PID43684有界运行；先核build/ci/39155583794/run.json、owned-helpers.json和实际进程，复用不重派。此前全部本地助手已结束。push曾TLS失败、同ref重推成功；状态API曾EOF、重查同run成功，均未重复dispatch。

第五完整39147081645/a650真实Core137各/iOS163=136+27/设备Release29、547源/原字体/锁/51旧包全部严格核验，但新旋转用例在未稳定时切色，出现排版失败alert和暖白正文配深色边缘/控件；原生拒绝，无根Build29交付。最后交付仍Build28。第五37原图/7表、6原录屏/31总览、3窗口134原始帧/13表已实际查看；45帧确认36.78s alert。不能把自动过当原生过。

随后5e新用例增加真实正文/no-spinner/no-alert/主色条件，定向39153021005实际10/11，唯新旋转test在暖白横屏predicate截止时AX查询被waiter中断，原10均过。1图/49秒录屏4表已看，43-49s横屏实际已可读，无charcoal或alert。另查App横屏PNG2622×1206中心1600纯黑，物理整屏录屏1206×2622的48s暖白中心81.5%，指向App frame裁图坐标的观测问题。

当前f320只把新用例采样/3类留图换为Apple公开XCUIScreen.main.screenshot，并加首个横屏App/Screen双原图及几何/纸色判定probe。所有readability/no-spinner/no-alert/20秒/55%/RGB容差5、原方向10秒不变；生产App/Core/Adapter/Vendor/默认完整CI与a650完全同字节、299其他test主体不改。Windows449语法新增0/54既有限制、17工具过；新Apple11与原生仍待，不能先交付。

源与结果分开保留：完整Release分支edges仍a650；旧10诊断a650成功，rotation分支5e/11项失败；screen与appearance源f320。具体m4-edges-build29-screen-diagnostic-start、rotation-diagnostic-result、history-39147081645及READING_EDGES_DESIGN。四次更早完整真实失败亦独立保存，a9同源复验已用尽。

保全：正常HEAD6d761749/空index、1062原路径/51旧包/19恢复ZIP与各轮before原字节保持。未改变生产排版/加载20秒/保存3秒/完整Locator逻辑。第五完整原件和当前相关诊断都仍在使用，暂不做历史批量清理。用户取消关机持续生效，不关机。

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

39147081645/a650真实Core137各/iOS163/Release29全部严格校验，完整artifact1825047831字节SHA/digest/CRC已核并去重复；仍无根Build29交付。实际37 PNG/7表、新旋转61.54s/5总览看过，33s在旋转加载期间切深色，37-41s有页面仍在排版alert，随后浅色正文配深色边缘/控件，不能放行。新UI只等app横竖比例，未等真实正文或断言主题/alert；先加强此新test，不改299旧主体/生产预算。待改2文件原字节备份.cache/recovery/20261019-build29-rotation/before，先选定包含新旋转用例诊断，不能用本轮自动通过冒充原生接受。其余5条预备录屏尚未人工看，不声称已看。详m4-edges-build29-history-39147081645.json。

新用例已加强待检查：只在本轮新增旋转test内，主题应用后及横/竖恢复后等待实际正文可见、无可见加载spinner/alert，并核截图中央纸张主色（暖白F8F5ED/深灰242826，允许文字笔画），原frame10秒/其他动作及全部旧test保持；每个新就绪条件有20秒上限，不加sleep或重试点击。recovery加入该新用例共11项。生产App/Core/Adapter/Vendor/默认完整CI不改。Apple orientation与XCTNSPredicateExpectation官方markdown已实际读取并留摘要（当前Xcode16.4适用；文档明确设备物理方向不直接等同App界面方向），不把比例变动当WebKit排版完成。下一步Windows449/17、299旧主体对照/原截图判定检查后才派定向11。

旋转新断言冻结前检查已完成：Windows449新增语法0/54既有限制、17工具通过；对a650逐方法核299其他test（含Core137+iOS/UI162）字节一致，仅本轮新增旋转test改；生产App/Core/Adapter/Vendor/默认CI字节完全同a650。保留真实图中央主色检查能拒绝错误深色0/1600而接受正确深色1594/1600及暖白1237/1600，不冒充Apple执行。下一步私有快照/独立rotation诊断分支recovery11，先不改当前a650完整自动门槛或交付IPA。


## 定向11项旋转补强已实际启动

run39153021005/source5e893514f31862a8b5e8d7c338e9e3b89e55374b/codex/m4-edges-rotation/selection=recovery。仅新UI就绪断言和诊断名单变化，生产完全同a650；edges仍保持第五完整真实Release源a650，不移动。先核本run与owned-helpers.json，不重复派发。第五完整自动门槛保留true，但原生旋转拒绝/无Build29交付；定向11本身不生成IPA。


第五完整补充原生复核已实际看完6原视频/31总览表（37图/7表仍已看），另3窗口134原始帧/13表：旋转alert45帧明确36.78s出现排版错误，PTS有源回退单列；慢滚窗口仅3帧不足完整动效，返回86帧窗口只到加载，最终介绍在总览后续见到。菜单重启设置、字体查询/预设/0.05重开、浅深进度67%/返回、慢滚触摸后台和重开所列状态可接受，但新旋转仍拒绝，不打包。reviewed-rejected.json与第五history已同步。新recovery11继续独立等结果，无生产改动。


## 定向11实际10/11与截图观测问题（修改前）

39153021005/5e真实10/11，唯一加强的新旋转test在暖白横屏predicate截止时AX查询被waiter中断，旧10全部过；完整artifact已SHA/GitHubdigest/CRC校验，重复42分片/ZIP清除。1暂停PNG和49秒原视频4总览已看：43-49s横屏正文已可读，未到charcoal且未见alert。现有App横屏PNG2622×1206中央40方块为1600个纯黑像素；物理整屏录屏1206×2622的48s同类暖白中央纸张81.5%，支持App frame裁图坐标导致采样误判线索，不宣称唯一根因。Apple官方XCUIScreen/XCUIScreenshotProviding文档已读，下一步只把新用例的截图/采样改为公开XCUIScreen.main.screenshot并保留首个landscape App/Screen对照图和安全几何/颜色结果，不删readability/no-spinner/no-alert/20秒/55%/容差5要求，旧299与生产不改。待改新UI文件5e原字节备份.cache/recovery/20261019-build29-screen/ReaderInterfaceUITests.before.swift。第五完整A仍原生拒绝，不交付。

整屏观测修正待Apple：只改新用例采样/三个留图为XCUIScreen.main.screenshot，首个横屏就绪时保存App/Screen原图和几何/纸色判定对照；不删任何就绪/颜色/错误条件或改等待预算。Windows449新增0/17工具通过、299其他主体对a650不变、生产与默认完整CI全同a650。源/547blob/2原路径差异见screen-diagnostic-start与恢复目录source.diff，下一步独立screen诊断分支11项，原B失败保留，不交付。


## 整屏采样定向11已实际启动

run39155583794/sourcef32002880ebe7702321cce90f1d030823c047c53/codex/m4-edges-screen/recovery11。初次push遇schannel TLS失败，在dispatch前抛错；同ref安全重推成功后只派发一次run。初次状态API EOF重查同run成功，未重新派发。仅新UI整屏采样/留图及对照probe，生产全同a650、299其他test保持；旧B10/11失败和第五完整163/Release通过但原生拒绝均保留。先核本run与owned-helpers，不交付未过Native源。


## 验证来源的条件方案（尚未放行）

a650完整163/Release实际通过，f320仅新UI断言/截图方式与选定诊断名单变化；Git逐路径证明App/Packages/Vendor/原Fixtures/锁/project/默认完整CI完全相同，547记录项中545仍同，唯一2差异是Tests/UI/ReaderInterfaceUITests.swift和ci_reader_diagnostic.sh。已记production-provenance.json，当前postFullTestsPassed/nativeAccepted/IPAReuse均false。若本次11与实际原生确认全部过，可复用a650真实Release，并把其完整163与f320补充11分开记载，不能说f320执行完整163或新设备Release；任何生产/构建/资源/锁变化则必须新完整CI。这样保留既有完整门槛事实，同时只重新执行实际发生变化的新测试；未取得结果前不打包、不修改已知失败。此为条件计划，尚未采用交付。
