# 当前交接与恢复点

## 实际最新断点（先看这里）

实际12:29UTC恢复核查：原四轮已结束，无活watcher。43e/38890891607 failure、bc6/38892156952 cancelled（未由本Agent发取消，原因未核，不称源码failure）、2b5/38892611316 failure、255/38893802693 failure。原full.log/artifacts各已保存；共同dyld缺libswiftWebKit导致测试host启动前abort，随后UI缺PID/找不到书，不能冒称134主体执行。255原件artifact12044612730/315957624B下载11541已完成chunks待解压回执。官方WebKit293831证实min<=18.3+18.5sim的refined Swift API缺陷，回调与async两形式都受影响；现移除callAsyncJavaScript，标准document.fonts.ready.then由既有evaluateScript观察完成，32ms有界轮询/15s/取消/可见错误，完整位置/路由保护保留。接下来更新两Vendor摘要、Windows433/17与旧35/16新增/522源后冻结新compatibility候选全CI，不复用旧失败门槛。两原中文字体已在源码，尚无Build23IPA。

最新主候选实际已dispatch：255537fe9cda12601c7b414149e8bec7337e93e4 / codex/m4-font-routes / CI38893802693，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38893802693 。包含两内置/导入、fonts.ready/完整锚点重载、原子测试取样及同名独立资源路由。Windows433/17、35原主体保持/16新增/522blob已重冻；Core133各/iOS134=115集成+19UI/Release23/原生全pending，report切最新源并全部重置。2b5/38892611316（watch18566）、bc6/38892156952（75733）、43e/38890891607（74374）仍独立跑，均未含最新路由修正，不替本候选验收；各自结果/日志应取完保存。当前没有Build23 IPA，不关机，普通HEAD/index及全部原文件/包保持。

源审计再确认一实际问题：3.11 ViewModel按file.lastPathSegment挂载字体、WebViewServer.serve不自动去重；两个用户字体都固定名font.ttf时URL路由相同。现沿原公开server为每个FileURL加独立UUID路由段、原servedFonts仍跨章节复用，不改已持久化目录或字体原件；扩展新EPUB双模式用例真实导入IA与文楷两同名TTF，核路由不同/中文真实字体/切回首款拉丁字宽不变和原锚点，再走原两内置重开。此运行源码新增修正不在2b5/38892611316中，须重冻另ref全跑后才交付。原35主体/16新增数量保持，仍须实际核验。当前未交付，原各CI继续独立取证。

最终待验主候选：源2b5a156acaee634f820254473f2692e3a298c96b，ref codex/m4-font-viewport，实际CI38892611316（https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38892611316）。Windows433/17、原35主体/16新增/522blob已重冻；Core133各/iOS134=115集成+19UI/Release23/原生全pending，report已切新run并重置。相对bc6只改新TXT取样helper及文档，App/Adapter/Vendor运行Swift与43e一致。旧43e/38890891607（watch74374）、bc6/38892156952（watch75733）正常独立跑；277/38887978313已131/133失败，原件92586与watch74660结束。禁止重复派发或拿旧局部结果替当前门槛。现在只准备验证/交付助手与文档，不再改冻结源码，尚无Build23 IPA。

277原件完整summary已核131/133、2失败/0跳过、旧124全过，两个字体UI与内置原件/许可/中文字形CoreText通过；prior-38887978313-result.json保留。该原件还含新TXT嵌套async helper第91行一次“try无throw”Swift警告（不能称编译warning0），现将字体实际字形和原文字Y合成同一JS快照，在已有wait closure内检查，保留原glyph/loaded/3px锚点/重开门槛，避免嵌套helper与两次await取样。尚待Windows重核并另ref完整新CI；bc6/38892156952与43e/38890891607继续运行，运行源码相同/测试各有差异，不能替新候选宣称全过。

现在主候选已切新源bc6c32c9ed48fe72d2e7c927a558e8d8d0dd06f7 / codex/m4-font-ready / CI38892156952（https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38892156952），gates重置pending，预期Core133各/iOS134=115集成+19UI；Windows433/17、35旧主体保持/16新增/522源已重核。与43e的App/Packages/字体/Vendor运行Swift完全一致，实际只改一个新测试文件及UPSTREAM checkpoint字段命名和文档（Git已核）。43e/38890891607独立继续，不取消，最终按新bc6完整门槛交付。277failure原件下载92586仍运行，核完summary/原生局部后再写receipt，不把字体CoreText/真UI通过扩大为正文/Release通过。当前所有运行source冻结，普通HEAD/index保持，尚无Build23 IPA。

又一实际证据：277/38887978313已failure，完整log显示仅新EPUB初始caret的二次读取为空、新TXT无fragment初始定位失败；内置原件/OFL/CoreText中文字形以及两个字体真UI均通过，Release仍未执行；1.342GB原件下载session92586，结束后核summary原件再记录。相邻两次JS取样之间页面会动，故新EPUB原非零断言改为连续两次同一>100 caret并一次保存样本，取消独立二次读取竞态；新增font-ready关闭用例明确等新页延迟Promise已settled再查旧回调，断言保持。仅这两测试及Vendor元数据checkpoint字段命名更明确，App运行修正仍与43e一致；Windows/旧35/16新增/522blob重核后另ref全跑，43e/38890891607继续取实际结果，不取消/不追认前轮。主待切换，勿重复dispatch。

恢复核实值（更新）：主43e837/38890891607的Linux133与四Release TXT探针原件artifact12042260878已CRC核，settling-linux.json记录；Apple仍pending，唯一主watcher74374。277/38887978313由watcher74660独立取最终原件（不含后续修正）；e758/38886008057已真实128/131失败/Release未执行、原件下载99454和watcher71340均已结束。当前仍522源冻结/16新增/预期134 iOS；最终采用deliver_bundled_fonts.py，不用旧deliver_font.py。验证helper已核134/19视频、16新Preview与两个内置原件/许可逐字节；这些均为预备条件，尚未实际全过/打包。

当前主候选已实际dispatch：43e837bece74bfc930d774e36b3834e96f6f18d5 / codex/m4-font-settling / CI38890891607，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38890891607 。433/17与35旧主体/16新增/522源blob已核，预期Core133各/iOS134=115集成+19UI，gates全部重置pending。两Vendor Swift改动已按实际原字节更新UPSTREAM及README，公开WK API和W3C fonts.ready已核，无依赖/锁/JS资产变更。先前277/38887978313仍独立跑，主结果只按新38890891607原件；不重复dispatch。尚无Build23 IPA。

新的实际断点：扩展前e758/38886008057真实failure，131中128过3失败/0跳过，旧124全过，Core133各/编译诊断0，Release未执行；1.205GB诊断CRC/structured summary/原log已保留（import-only-third-result.json）。新EPUB已过实际TTF加载与导入后锚点，连续150%重排落到p16；新TXT初始定位超时（构造位置仅selector无fragment，3.11普通导航使用fragment/text/progression），新字体UI单次下滑未到theme。正在按已核Readium3.11完整锚点重载路径+W3C FontFaceSet.ready/Apple公开异步JS补资源字体排版/首次定位，保留系统连续实时路径、15秒上限/取消/可见错误；加真实关闭迟到font-ready回归，TXT用成熟fragment构造，UI滚到真实目标。16新增/预期134 iOS，原35主体仍保持待Windows重核。内置277/38887978313继续跑完取原件，但其源码尚不含此修正，不能作最终门槛。接下来重冻源码另ref完整新CI，不取消已有运行、不交付待编译源码。

2026-10-16T10:38:04.075370+00:00。用户新增“可以内置几个字体”，本轮已实现内置思源宋体SC Regular OTF2.003、霞鹜文楷Regular TTF1.530与本地导入；两原字库50,472,272B，固定官方revision/摘要/原OFL已核，App只读Bundle URL按需加载，不占12用户导入名额（Adapter≤14faces/正文窗口仍≤12）。尚未交付，Build22仍安装基线，禁止把源码候选当验收。

当前主验证：源277dca99bde3eabb9eb657ce4ee50e6adf537baa，ref codex/m4-bundled-fonts，CI38887978313（in_progress/pending），https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38887978313 。Windows433语法新增0/17工具、35原测试主体保持/15新增、522编译源/资源blob；Linux133与四Release TXT探针原件CRC已核。Apple/Core/iOS133=114集成+19UI/严格Release23/原生中文页面尚待完整原件，所有门槛以report实值为准。

扩展前独立CI38886008057/e7586a80目前in_progress/pending，因新需求使用另一ref而未取消，证据只覆盖此前13项字体导入版本。旧首轮Agent取消/第二轮129of131初始定位失败保留原件，不追认为通过。149caa08→e758仅新测试准备，当前277dca增加实际内置App资源/界面与中文测试，二者范围不能混写。

观察工具主74660、旧71340各对应本轮/扩展前；若工具ID失效，先核OS进程/run.json/真实API再恢复唯一watcher，禁止重复dispatch。当前维护主ref codex/m4-reading-appearance私有快照277dca99，普通HEAD6d761749/空index/M2/M3/875开工路径/39旧包/13备份保持。522运行源冻结，后续只补文档与验证/交付助手；源变必须完整新CI。没有Build23 IPA，不关机。

下一步核两CI真实完整结果。主候选成功后下载原件CRC→inspect IPA23/validate_font.py finish→font_runtime_diagnostics.py→review_font.py prepare/overview（含bundled）及review_font_raw.py原VFR帧→人工manual-notes→finalize_font_native.py。原生通过才运行deliver_bundled_fonts.py package/docs/preserve与最终快照/verify。所有helpers已准备但未冒称执行成功。手机/TS/首次大字库加载与内存/FPS/功耗/全部Provider/外部OTF真UI仍单列；M4整体未完。

## 本轮历史检查点

内置源片完成待编译：App只读Fonts文件夹（两原字体50,472,272B+OFL+PROVENANCE+README）和稳定UUID资源，最多12导入+2内置，正文窗口仍12；目录坏时保留内置可用并提示，不把原JSON覆盖为空。设置页两内置选项，按需加载不每次拷贝摘要，原导入与偏好兼容。新增两回归（CoreText中文原件/真UI）并扩展两新渲染测试核实际中文字形及逐款换字/重开完整锚点。现在先跑Windows433语法/17工具及旧35主体核验；当前e758 CI未因扩展取消，等真实结果后新候选独立全跑。尚无新IPA。

2026-10-16，用户反馈Build22功能没问题并继续；只接受基本自用功能，不扩大完整设备/FPS/功耗或M4验收。Build23本地字体导入开工，尚未实现/编译/交付。

已按AGENTS→状态→交接→路线→架构核实际文件/Git/完整CI38871744221成功/任务。私有tip24d311e/源3cb1d2，874维护文件/507源码blob/39旧包/12旧备份已核，新875路径备份见m4-font-build23-start.json。正常HEAD6d761749/空index/M2/M3保持，无运行CI/本轮任务。Build22交付独立归档。

下一片TTF/OTF单字体：文件选择与异步验证/协调复制/相对路径元数据/可见错误；全局阅读字体选择及恢复默认；Readium既有font-face资源通道，不全局注册、不加HTTP服务。字体目录变化需完整文字锚点保护，迟到请求不能改新会话。先核公开API/版本及成熟实现，记录设计取舍。字体集合/可变轴/永久删除/单书设置不提前铺开。完整Core/iOS/Release23和原生页面/视频复核之前不交付。

Build23源码首片：Core相对字体身份与有界存储事务/重复与缺失重导、TTF-OTF签名+CoreText后台验证；ReadingInterfaces目录capability，Adapter使用Readium3.11公开CSSFontFace、目录在open配置、无Vendor/JS新改。VM新增字体时采完整位置并保存后受控重开，选已有字体走原重排；会话/请求/await校验、关闭取消，失败恢复旧目录/外观。设置页沿用原卡片/44pt并保留选择器coordinator，原reading-v1只加可选UUID。正在补真实font-face/锚点和取消失败回归，尚未编译。测试字体复用仓内IA Writer Duospace 81636B与原OFL，不引入个人字体。

Windows432语法新增0/54既有语法限制、17工具通过，35受改原测试主体保持，13新增=6Core+6iOS集成+1真正UI，515编译/资源blob已冻结。预期Core133各、iOS131（113集成+18UI），必须核真实结果。补retryOpen先正常close避免失败Navigator阻止目录安装。现进入完整Linux/macOS/iOS/严格Release23构建前检查点；尚未Apple编译，不能写通过。

首候选3bac2015197df9dab8ea8a40fbc464c0d73459bf，已实际dispatch CI38880257296。唯一watcher负责run/full.log/artifacts；先核真实Core133各/iOS131/Release23，失败保留原件，不猜最后步骤。

本轮Linux原件artifact12037835000已CRC核，133/133 Core与四Release TXT探针通过，linux.json记录；Apple仍aggregate构建测试，不能推断具体测试阶段。唯一watcher工具session55283负责38880257296，勿重复dispatch。下一步核真正Apple结果及新字体原生页面/录屏。

首候选38880257296由Agent因源码审查补强而取消，已真实completed/cancelled；并非源码失败。Linux133通过，Apple已进入xcodebuild test但未完成iOS summary/Release/IPA，原1.03MB诊断已CRC/解压，first-agent-cancel.json与完整日志保存；watcher55283已退出0。补新页面就绪守卫/实际字号变化/缺字体降级文案，修Task中throwing fixture取值，原35测试保持，仍13新增/515源。重新冻结后跑完整新候选，不继承上一轮门槛。

当前唯一CI38881623233，实际编译候选149caa08c600999f5b53b74e0900eb1b405b7e8a，等待全新门槛。旧38880257296 Agent取消原件保留。

新轮38881623233真实Linux133/四Release TXT原件artifact12037208602下载CRC/解压已核，revised-linux.json记录。Apple仍aggregate，唯一watcher33131；旧55283结束。当前原HEAD/空index保持，运行源码149caa08冻结，未再修改；后续只准备验证/交付辅助和文档，不能把待编译源码写成通过。

等待检查点：新版149caa08/38881623233尚在Apple aggregate构建测试，原生/Release未写通过；Windows432/17与新Linux133/四探针已核。515源冻结，后续仅准备未执行交付helper（deliver_font.py、validate_font.py、review_font.py等）；所有package/docs动作以实际全门槛+本轮原生人工记录为前置。尚无Build23安装包，不把准备脚本当交付完成。

新版149caa08/38881623233实际failure：131测试129过2失败、跳过待summary核；仅新EPUB渲染取非零caret为空、新TXT font paragraph ready超时，均在导入字体之前。新真实CoreText/3生命周期与真UI字体选择取消/持久化/深色/默认均通过，旧测试不放宽。1.23GB原件artifact12039800586已CRC/解压、下载24476结束0，watcher33131结束0；Release/IPA未执行。与既有成熟用例对照补新测试启动模式稳定capture、目标页probe及原非零caret等待，原非零/字体loaded/锚点/字号断言不减。下一步核summary/本轮部分UI画面，再冻仅测试修正跑完整新轮，源码功能仍未交付。

已核第二轮structured summary131/129/2/0跳过，Linux/macOS133各、源warning/error0，旧124全过，新iOS7中5过/2初始准备失败。五新字体UI PNG和完整50.90s原生字体UI录屏4张1秒总览已看，浅深色/选择/取消/重开/衬线恢复符合这些素材；仅局部证据不替代新轮。现在Windows432/17与35旧主体/13新增/515blob重冻后送第三候选；相对149caa08只改两条新测试准备，不改App运行源码/旧断言。未有Release23/IPA。

当前唯一CI38886008057，实际源e7586a8067515a911d09ac4abf31fd4577fb695b；与149caa08仅两新测试准备和文档不同，App运行源码一致已核。所有新门槛重置pending，第二轮129/131失败不追认为通过；从新原件/summary/渲染附件继续。

第三轮Linux原件artifact12039173669已CRC/解压，133与四探针通过（third-linux.json）；Apple排队/运行状态以run.json真实值为准，唯一watcher91524。当前冻结运行源码e7586a80不再更改，尚无Build23 IPA。
