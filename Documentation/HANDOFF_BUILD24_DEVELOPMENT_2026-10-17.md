> 这是Build24开发过程历史存档。当前交付/任务/关机状态以根HANDOFF.md及当前验证报告为准；所有旧关机授权已撤销，禁止执行历史计划。

# 当前交接与恢复点

原生复核可恢复点：110PNG/19表、3完整1秒总览/11表、5窗口301原始VFR帧/28表均已实际查看；4张旧黑屏/加载/安全区孤立图明确未接受，见FontReview/manual-notes.json。532当前Git规范化blob与76a423编译源一致，正常HEAD/index不变。接下来落盘复核报告、打包、同步交接与历史CI收敛；不再改运行源码。关机已取消。

恢复实核：CI39005962891/76a423f已完成成功；Linux/macOS Core各135、iOS143/143（123集成+20真UI）、严格Release24和全产物摘要/CRC/三锁/532blob已核，实际证据m4-font-preview-build24-success.json。尚未生成Build24根目录交付包，断点为原生复核：110PNG与3录屏总览已查看，5窗口301原始VFR帧/28表待继续确认；之后打包/同步文档/清历史CI/保全与私有快照，不重复CI。用户已取消关机，禁止启动任何关机助手。以下旧待核段落是历史检查点，以本条和验证报告为准。

用户最新指令：2026-10-17“别触发关机了”。已撤销本轮关机授权，助手从未启动/未调度/未发关机命令。继续开发验收，完成后保持开机；历史关机说明均已被本条取代。实际取消记录：Documentation/ValidationLogs/m4-font-preview-build24-shutdown.json。

当前唯一主候选：76a423fec2b855eb6e429d40741a02145727830e / codex/m4-font-browser-save / CI39005962891，已实际dispatch。新鲜完整位置保存+失败可见重试/每await身份守卫及真实Cancel按钮同步已写；Windows435/新增0/17工具、56原主体保持/1原UI同步有精确双hash审计/11新增/532blob已冻。预期Core135各/iOS143=123集成+20UI/Release24，当前全部新门槛待核；旧字体重开断言保持，无Build24包，不得复用旧门槛。用户已撤销关机，保持开机。

最新断点：39003048184/b943613完整失败136/138（新6全过、旧字体逐次换字重开位置回到h1、旧picker取消后Done不可点），Release未运行，watcher82717已退出，无Build24交付。已查官方Readium固定版与Apple exists/isHittable文档；saveNow仅写cached currentPosition，拟最小改为新鲜完整capture、会话/保存请求每await守卫、失败可见保留原记录；新增4生命周期回归。旧Readium字体测试断言保持，旧picker测试只加强真正dismiss/hittable同步、不跳过取消/持久化。写入源码前检查点，尚未新编译。关机已经明确取消。

当前唯一主验证：CI39003048184 / b9436136a26cad4f62140f0df960e99657c1ff1e / codex/m4-font-browser-cjk，已实际dispatch；与上一轮源码及原测试完全相同，仅独立全CI重试。所有新门槛重置待核，无Build24交付；先前137/138与选择器白页/AX诊断独立保留。关机已撤销。恢复唯一watcher须核OS和本地run；不要重复dispatch。

最新实际结果：b943613/CI39000103869已完成失败137/138，118集成全过、六新增全过，19/20真UI过；旧导入字体取消测试127行查询Cancel超时，但失败AX树包含系统Cancel按钮。Release因真实失败未执行，不交付；正在提取该录屏/AX诊断后决定最小下一步。中文CSS现六款实核600字重/0.125rem字距/3.5rem缩进/非零原Y均过。无活动CI watcher（原4458已正常退出）；只本人PickerFailure选定成员下载62423在跑。关机已撤销。

以下为该轮开始时检查点：

当前唯一交付主候选：b9436136a26cad4f62140f0df960e99657c1ff1e / codex/m4-font-browser-cjk / CI39000103869。已实际dispatch，435语法/17工具/38原主体/6新增/532blob已冻，中文横排加入同版官方字距/缩进规则。新Linux Core135及四长TXT Release已实核通过；macOS Core135/iOS138/Release24/原生待核。旧六轮均已完成且失败完整留档，尚无Build24交付，关机未启动。

## Build24 当前可恢复操作（实际仍在验证）

主源b943613/CI39000103869，Windows435/17已重核；新Linux/Apple/138项/Release/原生未通过前不交付、不关机。旧六轮已各自完成，实际失败分别已写m4-font-preview-build24-history-*.json；没有取消或追认成功。当前只有39000103869尚在运行。源码保持冻结，当前私有tip仅纯文档更新，normal HEAD/index仍原样。

本机Python3.11与gh在.cache/tools/gh_2.102.0/bin/gh.exe。以下帮手都在.cache/recovery（忽略但已落盘），不要调用旧Build23交付帮手：watch_autoscroll.py RUN；download_font_preview_artifact.py RUN ARTIFACT core|apple|ipa（完整摘要/CRC/提取后清重复分片ZIP）；inspect_continuous_ipa.py IPA 24；validate_font_preview.py finish（135Core/138iOS/Release24/三锁/532blob/真实许可）。full.log/artifacts.json来自实际完成run，不能仅看网页尾部。Python17与435语法是Windows检查，不算编译。

实际全门槛后：review_font_preview.py prepare，再overview browser/bundled/font；以原始PNG及原录屏联系表人工逐看，review_font_preview_raw.py取所选原始VFR区间（禁止focus的fps采样当原帧）；manual-notes.json只填实际看到的事实，再finalize_font_preview_native.py。完整成功源PNG预期110（旧78+新20+旧六字体循环增加12；此前98漏算循环扩展已更正），本轮20新附件，15阅读UI原视频/共20UI原视频；未接受的孤立图明确排除Preview，手机FPS/普通签名/TrollStore仍待测。

随后deliver_font_preview.py package；finish_font_preview_docs.py（有实际门槛、独占archive保护）；retain_font_preview_ci.py plan/apply（最新交付全量保留，旧CI仅文本/summary/metadata，43根包/源码/14恢复备份保护，明确历史raw被删）；deliver_font_preview.py preserve；snapshot_m4.ps1以[skip ci]保存；deliver_font_preview.py verify并核远端/当前树一致。所有原930路径保持、532编译blob一致、43包/14备份核验及本人watcher/下载/ffmpeg均结束后完成交付。用户已撤销关机，禁止触发。shutdown_font_preview.ps1有90s延迟与交付保存门槛，未启动，禁止提前触发或添加强制关闭参数。关机计划必须先写ValidationLogs并完成最终保存；随后才启动隐藏助手，实际PID与命令回执写对应build/ci/RUN本地忽略诊断。


2026-10-17，Build24字体浏览与排版扩展开工。用户明确要求更多内置字体、设置内真实字体样式预览及更多自定义；已保留所有未提交改动，开工930路径备份/41旧包/正常HEAD及空index核对。原Build23完整交接归档HANDOFF_BUILD23_DELIVERY_2026-10-17.md，尚无Build24源码或构建验收。

本轮拟六款风格选择、CoreText后台真实字形预览（不全球注册、不用系统字冒充）、字距/字重/可调首行缩进及行段距范围扩展；兼容reading-v1旧JSON，沿用Readium3.11公开偏好和完整锚点。先核官方字库/许可/API，再最小实现、Core/iOS/原生/Release完整门槛。M4未完，不提前M5。

Build24第一可恢复子步：六款字体原件及原OFL已按官方固定revision/发布zip校验加入；旧两UUID不变、目录上限18（12用户+6内置）、正文窗口12不变。Core新增可选字距/字重/缩进与旧JSON兼容，Adapter映射公开偏好并补完整锚点重排判定；设置真实字形行与单CGFont/12PNG后台预览缓存已写。尚未编译；开始补兼容、真实CoreText预览、Readium文字锚点与真UI回归，原测试不删除。

## 2026-10-17 本地磁盘清理检查点（已完成）

用户要求清理 `D:\ai项目` 不需要的占用。已仅移除旧CI大文件89,928项、51.172 GiB，目录总量55.622→4.450 GiB，D盘可用约53.255 GiB；删除错误0、非计划删除0。完整保留最近已交付run38918803378的2,260文件、所有build根目录安装包/测试包、3,316份历史文字日志/摘要、`.cache/recovery`及所有未提交源码。安装包SHA256全部保持；清理期间另有源码/测试并发更新，仅记录差异、不回滚。1000项源码/安装包基线与精确清单已保存于清理聊天work区，项目摘要为 `Documentation/ValidationLogs/local-disk-cleanup-2026-10-17.json`。旧轮ZIP/分片/录屏/xcresult和审阅图片已删除，历史文档“原件保留”只代表当时快照；远端可下载性未核实。AGENTS已补本地产物保留规则。Build24上方开发断点和验收状态不变，未执行构建/测试，不代表Build24或设备验收。

Build24构建/测试前检查点：六字体原件/OFL、后台单CGFont+12PNG原字形预览、六行样式选择、字号前置、字距/字重/0–4字缩进与更宽行段距/留白已接入；旧字体UUID/reading-v1兼容。新增2Core、2集成（六字体CoreText PNG/真实Readium全部六字体+CSS+完整位置）、1真UI六款浏览/排版持久化，旧测试主体保持。现在Windows语法/17工具与源码冻结；尚未Apple编译或Build24交付，Build23原件全部保留。

Windows435语法新增0/54既有限制、17工具通过；受改38原测试主体保持、5新增、532编译/资源blob已冻。预期Core135各/iOS137=117集成+20UI，严格Release24；现在创建私有index快照与独立验证ref codex/m4-font-browser，再dispatch唯一完整CI。现有普通HEAD/空index/M2/M3保持。字体来源/API/缓存与后续边界已写READING_FONT_BROWSER_DESIGN.md。

实际已dispatch唯一CI 38950061245 / 3a97ebc1dab142b9b4ed67ec254f95bab3696fef / https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38950061245。接下来只核此源完整新门槛；不重复dispatch、不改冻结运行源码。系统新增AGENTS本地CI清理要求已读：历史大产物已由独立清理操作收敛（local-disk-cleanup-2026-10-17.json），最新Build23完整诊断仍在，源码/安装包/恢复备份未删。以前“所有旧大原件都仍在本地”的描述已被清理回执取代。当前D约53GiB可用；本轮分块合并CRC后清分块、完整解压确认后清重复ZIP，旧版本仅保留日志/summary/metadata/验证记录，交付包与快照保留。

补强新预览的高清/错误状态：3a97ebc/38950061245仍独立完整运行（已Linux135），不把它写源码失败或取消。代码审查发现新预览固定2x会在3x设备放大，且AX在失败时仍报正在准备；新候选改3x短字形和准确不可用/失败朗读状态，真实PNG宽度断言900保留实际墨迹/6不同字库。仅这两运行行+新测试预期更新；需重新Windows冻结/新ref全CI，旧轮跑完保留文字诊断，门槛不继承。

最新主源 c66157d669e047152ea2246a24c674cbe0c6f281 / codex/m4-font-browser-quality / CI38951246101 / https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38951246101。532blob已重冻、Windows435/17/38原主体/5新增保持；所有新门槛重置false，主watcher以本工具回执为准。旧38950061245不取消，最终仅留日志/summary/metadata，不复制历史全量大产物。

用户新增直接指令：本轮全部完成、可做验收无明确失败后帮忙关机。授权仅本轮：先完成字体/预览/排版、完整新Core/iOS/Release、原生关键素材复核、交付/文档/保存/任务核对，再正常Windows关机（不加强制关闭参数）；手机专属项目仍明确待实测，不冒称通过。当前仍开发/测试中，禁止提前关机。

快速切字审查补强：既有submitPreservingLocation忽略采样Bool，在前次字体hidden reflow中仍可能继续使用临时DOM。现在同显式capture一致，最多3s/32ms让步等待真实采样成功，每await核取消/请求/navigator，defer仅清本任务；到期可见提示，不把失败当成功。新增真实分页800ms字体ready期间再选第三字体，原非零文字仍可见的回归。3a97和c661两轮继续独立跑完，仅保留适用历史文字诊断。最新源码须再完整验证；本次6新增、预期Core135各/iOS138=118集成+20UI。

主候选38954435197实际Linux135/4长TXT Release已通过，116199B Core artifact12070201994已校验GitHub digest+CRC、完整提取并按AGENTS清除重复ZIP/分片，回执build/ci/38954435197/core-download-receipt.json。Windows与主源门槛保持，Apple/原生/Release仍待核；CI/下载帮手修正135编号集合及历史最小提取回执的范围描述，未改冻结运行源码。

38950061245实际失败：完整文字日志和artifact manifest已留，源compiler warning/error0，20真UI其中2旧失败、新六字体UI通过；原FreshReturn旧瞬时回归失败；新六字体连续位置测试Swift插入负Y形成JS `b.top--9.84375` 语法错误（确定测试构造问题）。现在仅给新测试的Y操作数加括号，保留原fresh非零/原Y±3/CSS/字形/重开断言；不改任何原测试主体。872主候选仍独立跑完不可代替新测试修正源码。下一步重跑Windows/冻结/独立完整CI，前轮实际失败不追认成功，关机继续等待本切片门槛。

首轮原生早查：经GitHub签名URL HTTP Range只取14张新字体/设置PNG，成员CRC逐个核，完整ZIP digest/CRC未核且未下载全归档，不能当最新主源门槛。已实际查看排版设置、六字体列表下半与马善政原字形：无倒字、风格确实区分，但compact字形有暖白硬矩形贴在灰绿卡片上。现仅compact绘制保留透明背景（文字仍按主题颜色），主大样例背景保持，新增于同一新测试核透明alpha0与实墨255，无新增test计数。需435/17/原38主体/6新增/532重冻并用新源全CI，后续不再推测性改动，等待实际结果。

c661/38951246101也已实际失败，0源compiler诊断：同一个新测试负Y拼接错误及一个原整屏UI等待失败，原FreshReturn和库封面本轮通过。两轮旧UI失败分布不同，原因未定，不宣称已修复；原测试主体/完整文字日志均留。前三轮未取消，主交付仅454/38956512671。首轮早查只取14 PNG成员共10,078,891网络字节，未下载1,373,489,835B全归档，成员CRC真、全ZIP摘要未核，范围在EarlyFontReview/selected-members.json。

454d950/38956512671 主源实际Linux135/四长TXT Release通过，artifact12071320371（116252B）完整摘要/CRC核完并清重复分片ZIP。当前仅Apple完整编译/138项/Release与最新原生待核；源码冻结。原生早查发现的硬矩形已用compact透明背景处理，需最新图确认，不能拿首轮画面替代。

872/38954435197实际135/138失败（0源compiler诊断）：负Y已知新测试错误、原返回UI一项等待失败、新800ms字体竞态测试在29行准备非零分页前失败；尚未执行中间/最终换字。完整位置为h1/char0，两个早发turn未移动。核Readium3.11官方Navigator.swift与实际spreadLoaded gate：翻页可因当前不可移动返回false，报告href不等于可读页面已就绪。现仅新测试先等真实one.xhtml/window/alpha1与注入ready已settled，再每次翻页等待scrollX增长，保留两次翻页、char>100、800ms中间隐藏窗口、最终原字可见断言；运行源码自454起不变。需再435/17/38原主体/6新增/532重冻和全CI，旧失败均保留，不关机。

63a44eb/38961037839实际Linux135/四Release长TXT再通过，artifact12073160376/116265B已GitHub摘要+CRC+完整提取、重复ZIP分片已清。核心运行源与454一致、只新测试准备增加等待，仍需当前Apple完整138/Release/原生实际结果。正常关机帮助脚本仍未启动。

恢复检查点（2026-10-17）：normal HEAD6d761749/空index/private tip8fdb0dd、877未提交条目/删除0核过，上一轮无watcher/下载/ffmpeg/关机助手存活；D盘约53.3GiB空闲。旧38961037839本地run.json停在in_progress，现重新读取实际completed/failure并下载完整文字log/artifact manifest；实134/138、0源compiler诊断、20真UI全过。两新增失败（分页准备char2、连续测试cover首次aboutblank）及两旧集成（自动慢滚初次aboutblank、整屏防重入）均留实录，不追认通过。已有六字库/原许可/真实预览/透明卡片/新排版源码保持；尚无Build24 IPA，关机从未启动。

当前正在落实断点：cc7/454两轮实136/138、20真UI全过，连续新测试实际已保留char474与Y约-9.48，但组合CSS断言不满足。核固定Readium3.11官方与本地同版资源，CJK-horizontal缺paraIndent和letterSpacing模块，默认资源包含；现只把默认文件的原规则原样复制到中文横排after.css，沿用advanced标志使原书样式保留规则不变，UPSTREAM登记本地差异与sha，JS/依赖不改。新测试另输出有界无正文的family/weight/spacing/indent/Y诊断，不降低char>100/Y3px/CSS/字形/重开断言。分页新测试按原成熟测试用3次已确认移动，减少无关翻页动画；800ms隐藏重排中再换字及原字可见仍保留。修改后须重新435语法/17工具/38原主体/6新增/532blob冻结及独立完整CI；当前补丁未编译，不算通过。源验证通过和原生/交付/保存后再执行本轮已授权正常关机。

中文CSS补丁构建前检查点：已从同版默认after.css原样补两模块、UPSTREAM原baseline保持并登记本地差异；新分页用3次确认翻页与已有reduceMotion准备，800ms隐藏重排/char>100/最终原字断言保留，连续测试保留3px/CSS/真实字形/重开并输出无正文指标。Windows435/新增0、17工具、38原主体/6新增/532blob通过。现在冻结快照并新ref全量CI，不继承63a旧结果；尚未新Apple编译/原生/Release，Build23仍唯一已交付包。

b943613/39000103869实际Linux135及四Release长TXT通过，artifact12088563226/116230B已摘要/CRC/完整提取并清重复ZIP/分片；新Apple/138/Release与原生尚待。未启动关机，旧安装包/恢复备份仍保留。

137/138失败现场已实际看完3张完整1秒总览：系统选择器约19.5s后白色初始化到片尾，AX有Cancel但查询10s没命中；不是新字体位置回归失败。完整17选定成员CRC核过，仅range11,240,071B、全ZIP摘要未核；具体picker-initialization-failure.json。相同旧用例前轮实过，原因未定。现在仅对完全相同b943613进行一次独立全流程重试，原测试/源码不改、不跳过、不追认为根因修复；先核实际dispatch/新run再登记唯一主轮。关机已明确取消。

已实际逐看上一失败轮20新PNG（6正文+6CoreText原字形+6设置行+2排版/重开），正文可读/字形确实不同/透明底卡已融合，具体cjk-preflight-native.json；只是旧轮预检，不替代39003048184新门槛。17失败附件与20PNG成员CRC后已按规则清重复range块，完整归档未下载。当前主源不改。

主重试39003048184实际Linux135/四长TXT Release已通过；artifact12089763577/116252B已摘要+CRC+完整提取，并清重复ZIP/分片。Apple完整138/Release24与最新原生仍待核；关机保持取消，旧137/138及其预检不继承门槛。

选择器诊断限定补充：原录屏白色远程区域与失败AX完整Cancel层级同时保留，尚不能分辨系统初始化延迟、AX查询时序或跨进程录制限制，不把录屏白色直接当成真机文件选择器渲染故障；原因未定，当前一次同源完整重试无代码放宽。

新鲜保存/选择器同步构建前检查点：App经完整capture再保存，3s/32ms未就绪重试、固定布局完整页fallback、会话/保存UUID/取消每await守卫、失败保留数据库原记录并可见重试/阻止无声离开；新增5生命周期，旧字体重开测试不改。原picker只一主体改为真实Cancel按钮+公开可点击/实际消失/Done恢复，其余旧断言保持，原/新sha固定审计。Windows435新增0/54既有与17工具实过；现在重冻11新增/预期135各+143iOS/Release24，旧源门槛清零，尚未新编译/交付，关机维持取消。

136/138旧失败选择器已实看完整1秒总览2表；片尾才见系统最近项目/取消，失败AX仍包含覆盖Done的Cancel，与旧exists误判dismiss相符。18选定成员CRC/14,392,133 range字节、全ZIP未核；重复range块已清，记录picker-dismiss-diagnosis.json。该原test现公开Button+hittable/消失同步，取消/恢复/持久化断言保持；新143项门槛只归76a423/39005962891。

主候选39005962891/76a423f实际Linux135/四长TXT Release已通过，完整Core artifact摘要/CRC/来源身份核完并清重复ZIP/分片；Apple完整143项/Release24和最新原生仍待核，旧轮结果不继承。关机取消。

原生附件数预检修正：旧78基线+20新增附件+原EPUB双模式/TXT的allCases扩展12=完整110张，而非早先98估计。137/138轮实际manifest106张，恰缺失败picker的4张；136/138轮95张对应其失败缺图。当前143项成功后须核实际110 PNG/15阅读UI视频，并逐看19张图联系表；预检只20张不能冒充全部。review prepare已加真实manifest数量守卫，无运行源码改动。

76a423/39005962891实际全部job completed/success，完整文字log3,965,006B已取；watcher首次取log遇网络错误（stderr保留）已正常结束，重取成功，不是源码失败。现在开始全量Apple diagnostic1,570,121,299B与IPA68,453,209B下载/摘要/CRC/完整提取，再核143统计/Release24/532blob/三锁原件和110PNG/15阅读视频；尚未本地安装包/原生交付。D约53.2GiB可用，下载完成清重复分片ZIP。关机已取消。

实际完整文字日志核：新5生命周期、原字体双模式逐款重开、真实picker取消均过，iOS123集成+20UI=143全过/0失败，Release BUILD SUCCEEDED。IPA artifact已全摘要/CRC/来源核并清重复包，安装包68,602,023B、SHA25655ec9079e00e5e29e83c91acce45712b85e1c0885c07ec75b760e0c5ef4a280a，inspect24/min16/arm64/0755/systemSQLite/notices/ZIP CRC全过。Apple全诊断下载仍在进行，未跑最终validate/native/package；不能只凭IPA就交付。关机取消。

最新完整自动门槛已实际通过：Apple diagnostic全1,570,121,299B/摘要+CRC+来源身份+完整提取已核并清分片ZIP（首轮网络断流错误与187块续传记录保留），validate finish核Linux/macOS135各/iOS143全过/严格Release24/三锁六pins/532blob/六原字体与许可原字节/41旧包及四长TXT每平台；源compiler warning/error0。RBS/ExtensionKit运行诊断计数另列，不叫全部系统日志无警告。当前开始真实110 PNG/15阅读UI原视频的选定字体序列及原VFR帧人工复核，尚无Build24最终交付，手机/M4仍待。关机取消。
