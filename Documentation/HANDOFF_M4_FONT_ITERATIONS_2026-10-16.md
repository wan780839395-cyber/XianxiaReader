# Build23恢复前候选记录

## 实际最新断点（先看这里）

主验证已实际切7ab2e457c82f1193e707c3c85ca5ffd27b76b110 / codex/m4-font-compatibility / CI38901198541，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38901198541 。使用原evaluateScript观察fonts.ready，已移除引入缺失Swift overlay的公开refinedAPI，唯一新watcher见当前工具回执；前四轮已结束。Windows433/17、35原主体保持/16新增/522blob已核并冻结，预期Core133各/iOS134=115集成+19UI/严格Release23/原生仍全pending。255原件artifact12044612730已CRC/解压、11541结束0。先核旧轮实际summary/启动崩溃并保留，主源不再改，完成本轮完整门槛才打包更新交接。普通HEAD/index与875路径/39旧包/13备份保持；无Build23 IPA。

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


## Archived checkpoint 2026-10-16T13:21:58.048304+00:00

## 实际最新断点（先看这里）

实际新主：ff82423a9a4092873d9d9f26d513e34064af0fc1 / codex/m4-font-anchor-tests / CI38906278076，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38906278076 。只改两条新测试与文档，App/Adapter/Vendor运行源与7ab一致；Windows433/17、旧35主体/16新增/522blob已核，预期133Core各/134iOS/Release23+原生全门槛重置。原7ab失败的1.358GB诊断仍download43791，主watcher以当前工具回执为准。保存完整失败后核真实新源结果，不重复派发、不卡UI断言；无Build23 IPA，全部原文件/旧包/备份保持。

本轮38901198541/7ab已真实failure，完整log已下载，Apple原件artifact12048531028/1,358,656,905B正在session43791下载，未CRC不得写已完成。启动缺库已消失，实际执行115集成+19UI，关闭迟到font-ready/内置原件glyph/两字体UI通过，无Swift源warning。失败有两旧（fresh return capture unavailable、减少动效关闭后menu未hit）和两新：EPUB第二字体导入仍以最早字符作跨多次分页的期待，新TXT重载中临时空DOM直接getComputedStyle异常。旧主体不改且根因未扩大断言；新用例保留首非零字符/首次150%/静止重开断言，后续每次独立换字前重新采完整canonical DOMRange并核该文字点可见（按App实际capture语义），TXT用p存在守卫处理真实重载准备期。只改新测试/文档，App/Adapter/Vendor运行源与7ab一致；Windows433/17/35旧/16新增/522blob重核后送全新完整轮，旧失败原件保留，未交付。

2026-10-16T12:56:36.162767+00:00（UTC证据时间，用户时区Asia/Shanghai）。用户授权内置几个字体，已实现思源宋体SC Regular OTF2.003、霞鹜文楷Regular TTF1.530（原字库合计50,472,272B），原OFL/固定官方revision/摘要/实际CoreText中文glyph与独立真UI初步通过；完整新候选尚未交付，Build22仍可安装基线。

主源`7ab2e457c82f1193e707c3c85ca5ffd27b76b110` / `codex/m4-font-compatibility` / CI38901198541，当前in_progress/pending，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38901198541。唯一主watcher工具session10152，写build/ci/38901198541/run.json/full.log/artifacts.json；先查OS进程再恢复，不重复dispatch。Windows433语法新增0/54既有限制、17工具、35原测试主体保持/16新增、522源码/资源blob冻结。预期Linux/macOS Core133各、iOS134=115集成+19UI、严格无签名Release23/min16、各四长TXT Release探针；实门槛以M4_FONT_VALIDATION_REPORT.json为准，当前{'linuxCorePassed': True, 'macOSCorePassed': False, 'iOSTestsPassed': False, 'deviceReleaseBuilt': False, 'desktopLongTXTValidated': False, 'Build23DeviceAccepted': False, 'M4Complete': False}。

实现：App两只读Bundle字体不复制/摘要开书，不占12用户导入名额；Adapter最多14faces/正文窗口仍12，旧可选UUID偏好兼容。后台本地TTF/OTF导入/目录/缺失重导/错误可见，完整锚点受控重开；资源字体排版走Readium已有完整锚点invalidate，系统连续排版仍动态。初始pendingLocator等待标准document.fonts.ready Promise完成，通过原evaluateScript轮询观察，15s上限/32ms/取消/可见资源错误；不引入受WebKit293831影响的refined Swift API。每FileURL独立UUID资源路由、章节复用，真实两个同名TTF回归。两Vendor Swift/UPSTREAM明确登记，无依赖/锁/JS资产升级。

历史均保留：首轮38880257296为Agent取消；38881623233=129/131，两新初始定位失败；e758/38886008057=128/131（连续字体150%定位/TXT构造/UI目标）；277/38887978313=131/133（两新初始定位，原124全过、两字体UI/CoreText通过，另一次新TXT helper编译warning）。后43e/38890891607、bc6/38892156952、2b5/38892611316、255/38893802693均dyld缺libswiftWebKit、集成host启动前abort，不能写134主体失败或通过；bc6结论cancelled且原因未核，未由本Agent取消。四原AppleZIP均CRC/解压与summary/log证据已留（overlay-*.json），其他fail原件保留。此问题已查官方WebKit293831，当前改回原JS桥，仍待新完整验证。此前详录HANDOFF_M4_FONT_ITERATIONS_2026-10-16.md。

普通HEAD6d761749/空index/M2e6f31d85/M344af41f0保持，原875路径/39旧包/13ZIP备份均核并保留，只使用私有index快照codex/m4-reading-appearance；当前私有tip以git实际为准，主编译ref独立。没有Build23 IPA；源码冻结后只补文档与helper，若运行源再变则新CI。所有旧watcher/download均已结束，主watcher仍跑（恢复时重核）。

下一步：主CI真实结果→原件CRC→inspect_continuous_ipa.py IPA23→validate_font.py finish（134/19视频/字体与许可原字节/522blob/三锁/旧包）→runtime诊断→review_font.py prepare/overview font+bundled+选定旧外观/回看+review_font_raw.py原VFR窗口→人工manual-notes→finalize_font_native.py。本轮原生通过才执行deliver_bundled_fonts.py package/docs/preserve→最终私有快照→verify/远端树/无任务回执。旧deliver_font.py已过期，禁止用其13新增/131版本打包。OTF内置真实页面将由主回归验证；外部OTF真UI/所有Provider、大中文手机首次加载/内存/FPS/功耗/普通签名/TrollStore/旋转辅助功能仍单列。M4未完、不M5、不关机。


## Archived checkpoint 2026-10-16T14:18:51.027772+00:00

## 实际最新断点（先看这里）

当前主候选19db1b74af1be780c80994c84a4a324045b657f9 / codex/m4-font-native-visible / 实际CI38914038336，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38914038336 。含新用例部分字形相交+continuous3px原Y、实际native alpha1取图条件；只改新测试/文档，App/Packages/Vendor运行源码仍7ab完全一致。Windows433/17、旧35主体/16新增/522blob重冻，134 iOS=115集成+19UI预期，完整Core/Release23/原生门槛已重置pending。前92ad/38911801177由watch6245继续独立跑（不含native取图条件），本轮主watcher以工具回执为准。原ff只有一用例失败133/134的ZIP已CRC、C缓存绝对路径在partial-glyph-133of134.json；7ab130/134及其余历史原件全保留。禁止再改冻结源码或重复dispatch，尚无Build23IPA。

原ff/38906278076的1.312GB原ZIP已续传CRC/解压，43796曾过期失败、17496恢复结束0，partial-glyph-133of134.json证实133/134且旧124全过，0跳过/0编译warning，原ZIP在C缓存明确绝对路径。只人工看了75张中的contact1~3共18张；其中新font-epub-sourceHanSerif-paged仍spinner、新font-txt-byte-anchor为空底色，另WenKai分页/宋楷TXT显示真实字体正常。Readium3.11 showSpread在DOM/初始化回调之后才把scrollView.alpha置1，原新测试仅DOMready会过早截图；现在仅新字体active()等待实际window且scrollView.alpha>0.99，再核字体/完整点/截图。不是修图或改变产品正文；不能将两空截图当原生通过。当前92ad/38911801177尚不含此取图条件，继续跑完保存，但须Windows再冻后新完整轮才能最终交付。App/Adapter/Vendor运行源仍7ab不变。未有Build23IPA，旧源码/失败原件/正常Git状态全部保留。

当前唯一主已切92ad36a0f8fd45a40c1e31c73f37a117ccb34200 / codex/m4-font-viewport-offset / 实际CI38911801177，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38911801177 。只改一条新EPUB测试的可见语义并加continuous3px原Y核对、文档；App/Packages/Vendor运行源码仍与7ab一致。Windows433/17、35旧主体保持/16新增/522blob重冻，预期Core133各/iOS134=115集成+19UI/严格Release23与本轮原生全pending。前ff/38906278076只有新EPUB一例（原124全过、TXT两CJK字体/字号/重开与同名TTF页通过以原件核准），其1.312GB原件43796仍在C缓存下载；主watcher见当前工具回执。禁止重复dispatch，不用前轮局部代本轮验收，无Build23IPA，所有未提交/旧包/备份保留。

新实际结果38906278076/ff824已failure，full.log只有新EPUB字体用例一例失败，其余133（含原124与TXT/两字体UI/关闭迟到）通过，summary待原件核。失败位置在continuous首次导入后的anchorScript，canonical仍p25,char476，xianxiaViewportOffset=-9.84375，DOM caret476，正文正常；测试错误要求rect.top>=-1/整块在屏内，把顶部仍部分可见文字误判丢失。现仅新用例按字形rect与视口相交判断，continuous额外加原字符Y与导入前/每次fresh canonical offset差<3px（更精确），paged仍核同一文字可见；首>100、加载字形/150%/静止重开/同名路由等不减。App运行源保持7ab，需Windows再冻/完整新CI。旧1.312GB诊断download43796，临时分块和原ZIP放C:/Users/78083/.cache/XianxiaReader-Build23-CI，实际解压日志/xcresult仍build/ci/38906278076；尚未CRC不能写完成。未交付，普通HEAD/index不动。

2026-10-16T13:21:58.048304+00:00（UTC证据时间，用户时区Asia/Shanghai）。用户授权内置几个字体，已实现思源宋体SC Regular OTF2.003、霞鹜文楷Regular TTF1.530（原字库合计50,472,272B），原OFL/固定官方revision/摘要/实际CoreText中文glyph与独立真UI初步通过；完整新候选尚未交付，Build22仍可安装基线。

主源`ff82423a9a4092873d9d9f26d513e34064af0fc1` / `codex/m4-font-anchor-tests` / CI38906278076，当前in_progress/pending，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38906278076。唯一主watcher工具session91856，写build/ci/38906278076/run.json/full.log/artifacts.json；先查OS进程再恢复，不重复dispatch。Windows433语法新增0/54既有限制、17工具、35原测试主体保持/16新增、522源码/资源blob冻结。预期Linux/macOS Core133各、iOS134=115集成+19UI、严格无签名Release23/min16、各四长TXT Release探针；实门槛以M4_FONT_VALIDATION_REPORT.json为准，当前{'linuxCorePassed': True, 'macOSCorePassed': False, 'iOSTestsPassed': False, 'deviceReleaseBuilt': False, 'desktopLongTXTValidated': False, 'Build23DeviceAccepted': False, 'M4Complete': False}。

实现：App两只读Bundle字体不复制/摘要开书，不占12用户导入名额；Adapter最多14faces/正文窗口仍12，旧可选UUID偏好兼容。后台本地TTF/OTF导入/目录/缺失重导/错误可见，完整锚点受控重开；资源字体排版走Readium已有完整锚点invalidate，系统连续排版仍动态。初始pendingLocator等待标准document.fonts.ready Promise完成，通过原evaluateScript轮询观察，15s上限/32ms/取消/可见资源错误；不引入受WebKit293831影响的refined Swift API。每FileURL独立UUID资源路由、章节复用，真实两个同名TTF回归。两Vendor Swift/UPSTREAM明确登记，无依赖/锁/JS资产升级。

历史均保留：首轮38880257296为Agent取消；38881623233=129/131，两新初始定位失败；e758/38886008057=128/131（连续字体150%定位/TXT构造/UI目标）；277/38887978313=131/133（两新初始定位，原124全过、两字体UI/CoreText通过，另一次新TXT helper编译warning）。后43e/38890891607、bc6/38892156952、2b5/38892611316、255/38893802693均dyld缺libswiftWebKit、集成host启动前abort，不能写134主体失败或通过；bc6结论cancelled且原因未核，未由本Agent取消。四原AppleZIP均CRC/解压与summary/log证据已留（overlay-*.json），其他fail原件保留。此问题已查官方WebKit293831后改回原JS桥；7ab/38901198541实际130/134（0跳过/0编译warning/error，启动问题消失），两旧回归fresh capture unavailable/减少动效关闭hit失败与两新测试第二字体期望、TXT临时空DOM失败原件已核，证据compatibility-130of134.json。当前ff824仅改两新测试：每个独立换字前采fresh完整canonical DOMRange并核该point可见，原首>100/字号/重开断言保留；TXT先验证DOM p存在。App/Adapter/Vendor运行源码与7ab一致，旧35主体不改，旧失败根因未定，完整新轮待结果。此前详录HANDOFF_M4_FONT_ITERATIONS_2026-10-16.md。

普通HEAD6d761749/空index/M2e6f31d85/M344af41f0保持，原875路径/39旧包/13ZIP备份均核并保留，只使用私有index快照codex/m4-reading-appearance；当前私有tip以git实际为准，主编译ref独立。没有Build23 IPA；源码冻结后只补文档与helper，若运行源再变则新CI。所有旧watcher/download均已结束，主watcher仍跑（恢复时重核）。38901198541原件43791曾截断失败，82150断点续传后已CRC/解压结束0；原失败保留。尝试清本轮重复分块被自动策略拒绝，未删除任何原件或分块；后续新artifact临时分块用C:/Users/78083/.cache/XianxiaReader-Build23-CI，最终ZIP和日志仍在项目。

下一步：主CI真实结果→原件CRC→inspect_continuous_ipa.py IPA23→validate_font.py finish（134/19视频/字体与许可原字节/522blob/三锁/旧包）→runtime诊断→review_font.py prepare/overview font+bundled+选定旧外观/回看+review_font_raw.py原VFR窗口→人工manual-notes→finalize_font_native.py。本轮原生通过才执行deliver_bundled_fonts.py package/docs/preserve→最终私有快照→verify/远端树/无任务回执。旧deliver_font.py已过期，禁止用其13新增/131版本打包。OTF内置真实页面将由主回归验证；外部OTF真UI/所有Provider、大中文手机首次加载/内存/FPS/功耗/普通签名/TrollStore/旋转辅助功能仍单列。M4未完、不M5、不关机。

