# 当前交接与恢复点

2026-10-18（Asia/Shanghai），Build27 字体管理、排版预设与书架生命周期修复开工。

用户反馈：导入字体底部逐行铺开且样例过大/割裂；希望排版简化或预设；系统暗黑下书架搜索突变白且不恢复；退出后偶发点书无响应；其他应用直接“打开”TTF/OTF进入本应用；菜单仍可能卡顿，不能凭60Hz归因。

已按AGENTS→状态→交接→路线→架构读档，核正常HEAD6d761749/空index、私有tipd378e0ec、真实CI39038829961与最终receipt。没有运行中的项目助手。1014原路径、47根交付包、16旧恢复ZIP摘要/CRC核验并新建第17份开工ZIP；见ValidationLogs/m4-experience-build27-start.json。现有未提交改动全部保留，关机授权已取消，不触发关机。

当前断点：尚未修改Build27运行源码、未编译/测试/交付。Build26完整已交付事实保存在HANDOFF_BUILD26_DELIVERY_2026-10-18.md。新切片独立门槛，旧结果不继承。

拟先核系统主题/阅读presentation身份与关闭回调，再补外部字体文档声明及冷/暖启动URL队列（复用后台协调复制/验证，不抢占当前阅读/设置）。字体改为紧凑入口与独立惰性浏览页，排版提供明确可选预设、常用项与更多调整；保留旧自定义偏好，不主动重置。卡顿先收窄页面与无意义重绘/预览缩放，真机帧率与Instruments仍单列。每个恢复子步骤及构建前继续更新此档。

## 源码完成、测试前检查点（2026-10-18）
字体入口/独立惰性网格与自然字号限制、三排版预设/更多调整已落源码。阅读主题改局部控制器override且不触及窗口；每次开书新presentation UUID，保存后显式关闭/清空同会话。外部TTF/OTF声明/onOpenURL冷暖队列、逐文件scope/原服务验证、只加收藏与显式选中后完整锚点重开已写入。5项新集成+1外部选择生命周期+2新真UI待跑；既有4个原生书架fixture仅补inbox依赖，原字体UI按新导航/展开步骤适配，原功能断言保留。设计/官方来源/风险在READING_EXPERIENCE_DESIGN.md。Windows语法445文件/新增0/54既有Vendor限制已过，仍不等于编译。下一步工具测试、复审并冻结完整CI，尚无Build27 IPA/新门槛。

## 冻结全量构建前
Windows445/新增0/54既有Vendor限制、17工具、bash -n已过。冻结清单543源码/资源/config blob；37原test主体未变、6适配/8新增，没有删除原test；预期Core各135、iOS156（131集成+25真UI）。新增退出按钮保存中反馈。私有index即将保存codex/m4-reading-appearance并建立codex/m4-reading-experience构建ref；正常HEAD/index继续保留，待CI真实source SHA回填。

实际全量构建已派发：source b799754b93f7a967b41b5552014649ca156c85ed / codex/m4-reading-experience / CI39086068358。不是定向诊断，不重复派发；正在核真实job与完整日志，尚无成功结论。监视器为.cache/recovery/watch_autoscroll.py 39086068358，恢复时先核进程及build/ci/39086068358/run.json，再继续同一run。

用户补充：字体来源微信/QQ/Alook及其他来源，正文和设置都感觉不够顺畅。已做只读性能链路审查并记录m4-experience-build27-performance-review.json；连续滚动DOM定位可能重叠是待测疑点，尚未修改Vendor采样或认定根因。当前真实CI继续同run，手机FPS与来源应用Open In矩阵仍待核。

## CI 等待中的可恢复工具断点
当前唯一全量run39086068358/source b799754；2026-10-18 01:59UTC直接查询仍ios/build-test-package运行中，repo/core任务success，定向job按full跳过。状态查询两次unexpected EOF已保留watch-error.log，不能推断源码失败。watch_autoscroll.py 39086068358与collect_experience27.py同run是本轮自有助手；恢复时先核真实进程和run.json，不重复派发。收集器等待完整日志/manifest，完成后按空间预检与GitHub digest/ZIP CRC收Apple/Core/IPA；XR_ARTIFACT_HTTP_BACKEND=curl/WORKERS=8。
后续助手均已语法检查，但尚未执行原生验收/打包：validate_experience27.py严格156/135/Release27/543 blob/三锁/六字体，review_experience27.py prepare/overview/raw，finalize_experience27_native.py必须先实际查看并写manual-notes，deliver_experience27.py package/preserve/verify，finish_experience27_docs.py，retain_experience27_ci.py plan/apply与final_experience27_receipt.py。不要照字面执行Build26旧助手。实际人工图片/原视频/连续帧必须完成后才给门槛；未产Build27 IPA。字体来源微信/QQ/Alook与正文/菜单卡顿补充仍保持待真机验证。

## 首全量实际失败：39086068358/b799754
完整日志已得，repo/core成功，iOS Debug编译与156测试实际执行，日志152过/4失败；无严格设备Release/IPA。源compiler诊断0。1新预设测试把无序JSON键字节直接比较，是测试规范化问题；2原字体UI在点更多后仍未找到高级控件，需核实际原图/点击范围并修整行操作；1新3字体预置UI开书ready超时，尚不能归为环境或源码唯一根因。系统暗黑搜索+4次重开、旧真实字体两位置测试、冷暖inbox与主题控制器通过仅记录本候选。完整1.8GB原生诊断正在digest/CRC下载。下一步查看实际失败图，再修JSON规范化/更多行及定位大字体首次加载开销，保持全部旧断言/20s预算，不用加等待或删测试过关。记录m4-experience-build27-history-39086068358.json。

## 原生失败图已核、性能修复前
首轮xcresult确认为152/156、4失败/0跳过，完整1.8GB artifact已GitHub digest/CRC全展开，重复分片/ZIP清除。实际看了9张失败相关PNG/2联系表及新3字体开书53–54秒原VFR窗第一帧：仍为打开中、无ready，并非已证明WebContent失败；更多行在点按后仍收起。已修新测试JSON sortedKeys（保留所有语义/持久化断言），更多改整行44pt明确Button/内容展开，主题bridge相同style不重复设置。
定位出另一个明确成本：BookFileStore.readingFontURL每次完整SHA；原TXTContentDigest.file逐字节Swift SHA在Debug执行，3个导入含约50MB中文字体，且新设置.task会重复核。拟改Apple系统CryptoKit流式文件SHA（公开iOS13+/Mac10.15+，64KiB有界、相同SHA256/取消/错误，Linux保留原实现），不新增依赖/锁/UI引擎或降低完整性；新增跨块已知摘要/取消回归及完整中文字体3次校验计时。刷设置先小目录比较，仅新变更/显式通知刷新，不因每次开页全量散列。官方CryptoKit init/update/finalize及apple/swift-crypto平台委托已核，详细来源将落设计。尚未Apple编译，先新定向panels诊断（无IPA），通过后再完整新源门槛；旧失败不追认。

第二候选冻结前：Windows446/新增0/54既有Vendor限制、17工具、bash -n通过；544源码/config/resource blob，37旧主体保持/6适配/11新增，预期Core各137、iOS157（132集成+25真UI）。新增流式文件摘要Apple系统后端/两Core测试与完整25MB字体计时、设置小目录未变跳过重复资源校验、开书阶段可见状态；不修改Vendor/Readium/schema/锁。先panels定向15项（无IPA）再完整门槛；原20秒ready和原功能断言保持。先轮本地忽略cache日志别名被第二候选复用，首轮Windows元数据已从b799 Git独立取回，原CI静态/完整日志与xcresult原件保留，边界如history记录，不能把当前cache别名当旧字节。

当前真实定向诊断39089264017/cb633672fa429e9307a4931885adc5747fdf926f，selection=panels现包含15项本片/字体/旧面板回归；不是完整门槛，不生成IPA。旧全量39086068358已经completed/failure且下载完成，两个原助手已退出。新watch_autoscroll.py同run仅查询状态/最终日志manifest，后续下载/断点在.cache/recovery/20261018-build27。正常HEAD/index保持。

## 第二候选定向实际结果与第三候选前
39089264017/cb63367实际completed/failure，15项14过1失败、0跳过；无Release/IPA、不替代完整门槛。25MB文楷导入0.063474s，三次完整URL摘要0.077738s（模拟器Debug计时，非手机FPS）；原3字体20秒ready已过，JSON规范化与2原字体高级展开/持久化回归均过。唯一失败字体收藏页搜索的系统drawer字段被AX尝试滚入视口时报kAXErrorCannotComplete，发生在真实3字体网格选中之后；实际已查看该网格PNG，字体大小/布局协调。
下一步复用已验证ReaderSearchField为字体收藏固定44pt原生查询栏，配置独立prompt/标识，避免折叠导航drawer；保持书内查询原默认与中文marked-text/光标行为，panels定向加入已有ReaderSearchFieldTests共16项。新UI保留3字体/两列/选中/查找/预设/持久化/20秒ready断言，改为固定字段并加强44pt/真实键盘关闭/清空。先新定向，再完整新源Core137/iOS157；当前工作未交付。原第一轮152/156与本轮14/15原件都保留。

第三候选测试前：固定顶部44pt原生字体查询/清空栏已落盘，保留原书内字段默认和marked-text/光标逻辑；Windows446/新增0/54既有Vendor限制与17工具通过，544源blob/37旧主体保持/6适配/11新增。即将新源panels16定向（加原输入回归）；完整Core137/iOS157/Release27仍待跑。正常HEAD/index与旧包备份保留。

第三候选真实定向39091123601/source0c7945c60906b7faa11124b94f1335a36c6647b2已派发，selection=panels16，无设备Release/IPA。新watch_autoscroll.py同run/collect_experience27_diagnostic.py同run是本轮助手，恢复先核run.json/真实进程，不重复派发。

最终全量前补一条目录刷新失效守卫：importReadingFont开始即清fontCatalogRequestID，使导入前已启动的浏览刷新不能在导入/重建完成后覆盖新目录；原请求关闭/重开守卫保持。第三候选39091123601仍在其冻结0c7945c源码执行，结果只属于该源，不取消/重派；此小改另冻结最终源并跑完整Core137/iOS157/Release27，含原字体导入/捕获失败/迟到关闭/重开回归。当前尚未Build27交付。

最终完整待测源已保存私有tip c518d70d91d478f51aa33c660eac2ab67dd8f6de；Windows446/17与544blob核验。构建ref暂仍0c7945c，因为第三诊断39091123601运行中，同ref并发会cancel-in-progress，故不派发/不更新该ref。待旧诊断completed并核实际结果后，CAS更新构建ref到c518d70并派唯一full；不能把0c诊断结果冒充c518全量通过。

第三定向39091123601/0c7945c已completed/success，真实数量/原件正由原收集器下载核验；无设备Release/IPA。最终完整CI39092416032/source c518d70d91d478f51aa33c660eac2ab67dd8f6de已唯一派发，含刷新失效守卫，构建ref已CAS更新到该源。现有watch_autoscroll.py 39092416032与collect_experience27.py同run是本轮助手；旧诊断收集器39091123601可能仍下载，核进程再接续，不重复派发。预期Core各137/iOS157/Release27，尚无本轮成功门槛或安装包。

第三定向原件已全digest/CRC展开并删重复ZIP/分片：实际16/16过、失败/跳过0；中文native44pt/marked-text/光标/换色/清空/收键盘及字体/预设旧回归过。实际查看新字体网格/搜索键盘/紧凑预设/高级展开四PNG，样例与布局协调；该源截图不替代最终c518全量原生门槛。最终完整39092416032继续原run。

完整39092416032等待中已核Apple官方WWDC23/渲染hitches方法及WWDC25工具版本差异，具体手机对比场景、帧分位/主渲染/DOM并发测量与修复回归边界写入PERFORMANCE_TEST_PLAN.md和performance-review；只是待测计划，未取得手机trace，未改运行源码/依赖/最低系统。

原生复核发现需修退出过渡：第三定向0c源新会话录屏全部1fps总览5表和两个原始窗122帧/11表已实看。第三次退出PTS51.182–51.498出现“正在排版书籍”，因ReaderView成功返回时过早model.close使isReady变false；此为原生UI实际发现，不把16/16当动效通过。拟保存成功后保留页面并原生关闭，沿已有onDisappear关闭/失效；返回中不重置flag、不显示打开spinner，失败仍复位可重试。当前完整c518/39092416032继续执行，工作源码暂不变以完成该源严格检查；之后保存其真实自动结果/未交付边界，另冻结最终修正源跑full137/157/Release27。第一返回原窗有PTS反转，不作帧率/全动效验收。


## 2026-10-18 恢复核实：原全量已失败，不再运行
实际GH39092416032/source c518d70已completed/failure（03:48:20UTC），xcresult155/157、2失败0跳过，Linux/macOS Core各137通过；无设备Release/Build27 IPA。完整Apple/Core原件digest/CRC下载完成，watch/collector实际进程均已退出。失败为原隐藏字体重排保持词定位、原菜单切连续后打开目录，原断言/预算未变；不把既有16项定向成功当完整成功。证据m4-experience-build27-history-39092416032.json。普通HEAD/index保持，未提交改动保留。下一步结合原生图/录屏和固定Readium3.11源码修最小生命周期边界，先原失败项及字体/新功能定向，再完整137/157/Release27；退出排版spinner也在本次修复范围。手机帧率与微信/QQ/Alook实际Open In继续待真机，不触发关机。


边界修正已落盘、尚未Apple编译：分页自动位置通知补与显式捕获一致的window/alpha前后守卫，拒绝隐藏字体页头覆盖原锚点；Vendor精确声明摘要已更新，版本/依赖/渲染器不变。退出保存成功保留画面直到onDisappear关闭。菜单放在固定viewport overlay，避免加载内容参与菜单布局；原菜单目录失败根因仍需实际定向/录屏验证，未宣称修复。panels增加原两字体定位/原菜单测试共19项，全部原断言/预算不变，先定向后全量。

19项原生定向已唯一派发39097420131/source18c130ce27c8dd1b3bc3ad1bee22adbae8b17456，含原两字体/原菜单、新切片16项；无完整Release/IPA。watch_autoscroll.py同run和collect_experience27_diagnostic.py同run是本轮助手，恢复核进程/真实run而不重派。Windows446/新增0/54既有语法限制、17工具、bash语法已过；37旧测试主体保持/6既定适配/11新增、544源blob，普通HEAD/index保留。


19项定向39097420131/source18c130c实际19/19、失败跳过0，test/summary/export0、551MB原件GitHub digest/CRC全展开并删重复ZIP/分片。原隐藏字体定位7.001s、原两模式字体63.131s、原菜单44.738s均过，原预算/断言未改。实际查看会话/菜单整条1fps总览7表和第三退出95帧/目录94帧共189原VFR帧16表：退出保留正文、所选窗未见打开排版spinner，模式加载期间目录正常呈现；不归因所有旧失败唯一根因，不当手机FPS。60张预备PNG未在此逐看。收集器末端因未预插diagnosticRuns记录触发StopIteration，已改幂等追加并用已校验原件补登记成功，无重跑CI。接下来同冻结18c130c派唯一full137/157/Release27，定向不替代完整门槛。

完整CI39098863950/source18c130ce27c8dd1b3bc3ad1bee22adbae8b17456已唯一派发。新watch_autoscroll.py与collect_experience27.py同run是本轮助手；原19定向watch/collector已结束。恢复先核真实run/进程，不重复派发。预期Core各137/iOS157/Release27，尚无全量/交付门槛。

用户本轮明确答复测试设备“没变”：iPhone13/iOS16.6.1/TrollStore。性能记录已增加currentDeviceContext，手机FPS与Build27设备功能仍未验收；当前完整39098863950继续，不因新答复重派/改源码。


完整39098863950/18c130c实际completed/failure，155/157、2失败0跳过；Core各137、原隐藏字体定位/原菜单已过；无Release/IPA。1.72GB Apple/Core原件digest/CRC展开，watch/collector已退出。新失败：原TXT连续模式initial position20s超时、原封面Files选择器已弹但内部空白。实际查看封面整条28.61s总览2表及AX；不能把空白写成按钮无反应，也不能认定新增paged守卫导致continuous失败。先只补TXT超时无正文状态诊断和有界系统文档服务/进程上下文，保持原等待/所有断言，新增recovery5项定向（原两字体/菜单+本次两项）。暂不改生产源码，不以孤立平台论坛归因；之后真实完整门槛独立跑。记录history-39098863950。

诊断实现落盘、定向测试前：生产App/Adapter/Vendor相对18c130c未再变；TXT仅mount弱引用/超时helper增加同步几何与既有无正文生命周期指标，不执行超时JS、不改20s预算及任何test函数主体。CI增加有界20s文档服务日志与无参数进程RSS上下文，明确best-effort、保留真实test/export/summary/recording退出；recovery只选原失败2项+原字体2项+原菜单共5。Apple官方UIDocumentPicker标准用法已核，现有桥接已符合，不以其他系统控制器的模拟器论坛报告判定本例唯一根因。下一步定向复现，再独立full157/Release27；尚无Build27交付。

Windows既有CI失败路径7断言首次未过：新增诊断外层python3在Windows控制流夹具退出49覆盖原test65/export23。没有改旧工具测试；已将整个额外诊断命令也显式best-effort捕获/记录，保证工具缺失不覆盖原测试退出，重新运行17项后才冻结。

诊断候选冻结前完成：Windows446语法新增0/54既有Vendor限制、17工具全部过、两CI脚本bash -n及内嵌Python AST过。受改文件49个原test主体逐函数相同、6既定适配/11新增、544源码blob；生产源码与18c130c相同。将派唯一recovery5，无Release/IPA，保留旧全量失败证据。

recovery5已唯一派发39102171529/sourcebc3c573755b3da7344f816318bd578803b9e6c7a；当前watch_autoscroll.py/collect_experience27_diagnostic.py同run为本轮助手，无Release/IPA。旧全量39098863950已结束失败、完整原件已校验收齐、两个助手已退出。恢复核真实进程与run.json后接续，不重派。


recovery39102171529/bc3c573实际5/5、0失败/跳过，test/export/summary均0；完整artifact GitHub digest/ZIP CRC已核收齐，原两个助手退出。保留原断言/20s预算，生产App/Packages/Vendor/project.yml/锁相对18c130c无变化。即将同bc3独立full137/157/Release27，定向通过不追认旧失败根因或手机FPS；先看本定向原生Files录屏，正常HEAD/index/旧包保留。

真实full已唯一派发39103144069/sourcebc3c573755b3da7344f816318bd578803b9e6c7a；后续watch_autoscroll.py及collect_experience27.py同run为本轮助手。先核真实run/log/artifact与进程再恢复，不重派。原全量仍155/157失败，新定向5/5分列，尚无Build27 IPA。

recovery5原生人工复核已记诊断JSON：11PNG两表、封面44.68s三总览/菜单54.99s四总览全部实看。Files启动10.5-14.5s仍空白，15.5s出现标题与tabs、17.5s完整最近项目/取消、18.5s回原editor；本次成功不作旧空白唯一根因结论。完整39103144069持续唯一run；当前助手watch exec24776 / collect exec14954，编译源仍bc3。

完整39103144069继续Apple原生阶段；已提前收同run Core artifact116320字节/digest/CRC全展开并删重复ZIP/分片，实际137唯一Core索引与4组Release长TXT探针检查均过。额外本地JSON读取首次用了Windows默认GBK，改显式UTF8后才核探针，不改变原件/CI结果。最终收集器按同artifact回执复用；完整iOS157/Release27仍未有结论。

完整39103144069仍Apple运行中，源bc3固定；本地已核同run Linux137/4探针与Core摘要/CRC。最终交付助手已AST检查；retain_experience27_ci.py现在要求先生成plan并实际审阅，复制为.cache/recovery/20261018-build27/ci-retention-reviewed-plan.json，apply在任何删除前逐字段比较路径/bytes/SHA/49受保护包，清单有变化立即拒绝。尚未清理旧CI。条件最终文档措辞去掉未证实的WebContent唯一归因，仍保留实际启动延迟和旧失败边界。


完整39103144069/bc3已completed/failure，原始日志132集成全过/25UI一失败，待下载xcresult核实际157总数。原TXT初始位置、封面Files与两字体/菜单均过，唯一新失败在ReadingExperienceUITests字体收藏+预设用例104行，点设置完成后0.5秒立即点返回书库，AX三次计算hit point=-1,-1。尚未判定遮挡、控件禁用、菜单状态或测试同步原因；等待实际失败AX与原录屏后决定，暂不改生产源码或改坐标点绕过。无Release/IPA。Core已全核137/4探针；1.748GB Apple artifact由原collect助手14954继续下载，watch24776已退出，恢复不要重派。bc3 Windows/工具/diff别名已分别留副本，后续若再冻结不覆盖旧证据。

39103144069原件完整digest/CRC下载已完成，实际xcresult156/157、1失败0跳过，两个助手均已退出。已实际看字体收藏42.24s原录屏全部三张总览和失败AX：并非返回按钮移位/关闭动画未结束，设置整个仍停留，AX有屏幕下方reader.position.save-error：阅读进度尚未保存，当前位置尚未稳定。Done当前await saveNow()并因失败拒绝dismiss，测试随后点被遮挡的返回。下一步提取Done窗原始连续帧核验，归档bc3失败；拟只分开设置持久化与面板关闭后的fresh完整位置保存，失败在可见阅读界面显示，旧采样/3s预算/Locator/旧回归不削弱。已核Apple sheet onDismiss与XCTNSPredicateExpectation/exists-vs-hittable官方文档，写设计后实施。

设置关闭修正已落盘，待验证：ReaderViewModel.saveSettingsNow只提交偏好，ReaderAppearance完成有保存中/失败alert、成功关闭后ReaderView原生onDismiss走原saveNow；原3秒预算/fresh Locator/失败/请求ID守卫不变，原字体收藏UI测试函数完全未改。新增1个Lifecycle边界测试含覆盖页不可采样、设置落盘/真实路径错误、位置失败保旧和fresh重试、close拒绝，预期158=133+25/12新增；原测试主体保留数量由freeze实际重新计算。即将Windows446/工具17，之后独立同源完整CI，不增加定向重复等待。bc3失败原件/89原帧已归档history-39103144069，不追认为通过。

设置关闭候选冻结前：Windows446/新增0/54既有Vendor限制、17工具过；544源码blob，新增Lifecycle文件纳入后73原测试主体逐函数相同、6既定适配/12新增；预期Core各137/iOS158（133集成+25UI）/Release27。原字体收藏UI函数及全部旧保存/迟到/重试/关闭回归未改，原采样3秒预算未变。偏好提交允许同会话渲染失败时退出设置回正文重试，不依赖isReady；关闭会话仍拒绝。即将冻结私有源并独立full，不继承bc3的156/157或recovery5成功门槛；无Build27交付。
