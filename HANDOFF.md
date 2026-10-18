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
