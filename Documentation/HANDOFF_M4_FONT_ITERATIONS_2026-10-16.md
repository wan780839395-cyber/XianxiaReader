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

