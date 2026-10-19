# 当前交接与恢复点

## R1设置隔离与关闭合同修正（2026-10-19，恢复点）

最新39230331856/e960已由GitHub30分钟job限额取消，非Agent取消。原生编译通过、0源码编译诊断；首个字体case实际到09:59UTC才开始，约10:00:53输出恢复等待超时，但还没完整报告用例结束/summary；0项完整用例，第二项未执行。原artifact12178013971（143480字节）完整digest/CRC已核，包含Staging原始stdout及reader-diagnostic.log。不能把这轮写成2项失败或通过。

关键新证据：四阶段model/engine完整Locator都指向one.xhtml第25段char0，saveFailure为空，open返回也持有正确输入；随后真实可见页面却是h1/char0。该次错误发生在打开后的排版恢复，非SQLite读回或设置JSON丢失。完整数据Documentation/ValidationLogs/font-reopen-checkpoints-39230331856.json；失败后的数据库补读未完成，不能假称已取得。

当前最小红灯实验待编译：新增一个直接引擎用例testPagedReopenRestoresFirstCharacterOfLongParagraph，在管理存储原样书/六原字体/思源宋体150%深色条件下，绕开App设置/SQLite写入，直接用同一段首char0完整Locator重开，要求实际字和真实字体可见。只在测试WKUserScript同步记录scrollTo目标/字体ready/段首rect，不改生产。新paged-restore入口只跑此1项；如失败核目标计算/字体布局，若通过则说明还需原完整字体链路对照，不称根因已修。新总149集成+28UI=177，原来148与所有旧断言保留；unit-release计数随新回归增加，不复用旧UI。当前无远端任务，下一次只派发paged-restore1。

本轮原生冷编译已经耗约28分钟才首测，原30分钟job没有导出余量；将所有原生诊断总job设60分钟，完整仍120，加载20秒/位置3秒/字体15秒/测试原等待30秒均不变。不是放宽功能预算。Windows453语法新增0/26工具检查通过；尚未编译新增直接用例。正常HEAD/index与53旧包保持，不关机。

最新39226220147/0283922已结束，65/66，实际test65/summary0/export0；刚改的完整Locator字体竞态用例9.257秒通过，设置/生命周期35及2关闭合同通过。唯一失败改为旧testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes第一个分页sourceHanSerif的save-close-open后同字不见，实际可见且loaded的one.xhtml回到h1 char0；该case未见长WebContent启动，不归咎环境。完整artifact12176542366（124970618字节）digest/CRC已核，目录build/ci/39226220147/diagnostic直接含summary（没有build子目录）；真实证据reader-session-locator-fixture-39226220147.json。没有进入完整CI/Release，无新IPA。

当前最小实验待验证：仅在该原有用例加入同步有界检查点，记录字体可见、saveNow返回、close后、open返回四阶段的model/engine完整Locator与时间戳/错误；不加await或额外capture，不改原save-close-open顺序/功能断言。只有原等待失败后才读取SQLite位置并保留原错误，以区分保存前、close最终回调或打开恢复阶段在哪里丢失。生产代码保持。下一次仅fonts两项（包含上一刚修竞态），不无假设重跑66/完整。

实际断点：39215839905/be7c415已结束，GitHub明确报告job超过1小时，由平台取消，不是Agent取消。字体前置实际2/2通过；随后完整148单元/集成执行完，147通过/1用例失败（两条断言），UI仅11项通过，剩余未完成；无完整summary、无Release、无Build30 IPA。完整artifact12172841432（253309118字节）SHA/digest/CRC已核，保留原始build.log及未完成xcresult；gh整轮日志只含旧片段，不能据此说测试没执行。Linux/macOS Core各137及各4组Release探针通过。真实记录Documentation/ValidationLogs/fonts-full-timeout-39215839905.json。

失败发生于ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord原第100行：准备深处文字时连续三次翻页，其中一次未观察到X增加；此时尚未请求中间/最终字体。最终页面已有one.xhtml完整正文与char430完整Locator。独立翻页/重叠导航、全部其他渲染测试和新2关闭合同在本轮通过；不能由此推断全部历史慢启动唯一根因已修。

本地恢复已落地，尚未编译验证：该字体用例改用既有版本化完整Locator跳至long-paragraph的char1200，并要求准备的该字真实可见/scrollX>100；随后仍fresh捕获实际深字、制造中间字体屏障，再请求最终字体并检查同一字/最终字体可见。原生产代码、3秒位置/20秒加载/字体15秒预算、所有最终断言保留，不改独立翻页回归。修改前备份在.cache/recovery/20261019-webkit-loading/after-timeout-before。

流水线预算修正尚未验证：完整iOS job由60设为120分钟，reader-session定向设60分钟，其他定向仍30；区别于生产/单测试预算。已有真实耗时：字体preflight21分21秒（含首次编译）、后续Core/编译约9分钟、148测试约13分42秒，UI历史约31分37秒，还需设备Release/导出/上传。先Windows语法/26工具，再冻结并只跑reader-session66，检验有前序状态时的新准备是否成立；通过后才同输入完整148+28和严格无签名Release，最终不重复fonts-full前检、不复用旧UI。

当前无本地python/gh测试进程，远端in_progress/queued列表为空；正常HEAD6d761749911233122bcd031fcf718d22a19f9e77、空index及大量既有未提交改动保持。最后冻结源be7c415的554输入证明仍是历史基线；本地随后只改字体测试/CI超时及文档，须另建新候选证明，不可再称当前554与be7全同。53旧交付包已核摘要且不覆盖。不要关机。

项目长期教训已在根AGENTS.md和Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md，含总job耗时与证据上传余量。只推进R1；R2/R3/R4未提取，Build29仍最后交付，手机/TrollStore/M4整体验收待。浏览器config enabled=true但cua重置后仍报Work禁用，无修改该开关接口；用户已明确授权，不再反复索要授权，不挡CLI验证。

完整方案Documentation/READER_ISOLATION_PLAN.md。此前运行快照已归档，不把历史“正在运行”当现状。

## Build29 阅读安全区边缘（2026-10-19）

本切片已交付。实际Release源`a65086c1151831b54d90ed083fa36fc27848b5cb` / `codex/m4-reading-edges` / [完整CI39147081645](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39147081645)：Linux/macOS Core各137，iOS163/163（136集成+27真UI）、失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release29/min16。547编译资源blob、三锁六pins、六完整原字体/OFL、每平台4长TXT Release探针已核。Windows449语法新增0/54既有Vendor限制、17工具测试通过；语法不算编译。

补充源`f32002880ebe7702321cce90f1d030823c047c53`仅加强本轮新增旋转测试及recovery名单：App/Core/Adapter/Vendor/原Fixtures/锁/project/默认完整CI与上述Release全同字节，547记录中545相同、2测试/诊断路径不同。C[39155583794](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39155583794)实际10/11，新旋转81.659秒通过，唯一旧字体case在初次cover位置未发出时20秒probe失败，尚未执行换字体；完全同源原两个字体case单独复核[39179687615](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39179687615)实际2/2。保留原失败及根因未定风险，不称C11全过、f320完整163/设备Release或旧时序根因已修。299其他原test主体不改；预算/断言保持。精确来源见m4-edges-build29-production-provenance.json。

ReaderSurface保留原完整viewport/控制器，以UIKit真实safeAreaInsets和CAShapeLayer evenOdd绘制页面色不安全四边，中心透明，触摸/辅助功能穿透；明确zPosition高于迟到navigator。仅布局、安全区或颜色变化重绘，无逐滚动回调/blur，禁隐式动画。正文排版/contentInset/offset/完整Locator、数据库/依赖、加载20秒及保存3秒保持。App/Vendor有界Debug安全阶段元数据已登记，Release开关false不记录日志或AX。

安装[XianxiaReader-ReadingEdges-Build29.ipa](build/XianxiaReader-ReadingEdges-Build29.ipa)，SHA256 `2c8ef157dbe26d921c08d3a5ffa10a3ef6ee4d481c7b831ff3eb1191ae42901c`；[原创样书/字体许可/原生Preview测试包](build/XianxiaReader-ReadingEdges-Build29-TestKit.zip)，SHA256 `adfab4519e80cca8357e5b243be21bfeba5d9fcd0843be8e2067986c5b9a9cb9`。覆盖安装保留书库，不卸载或删库；+菜单确认0.0.1 (29)。51旧包、未提交工作、1062原路径及19恢复ZIP保持。

实际原生复核：A37原图/6完整录屏31总览/3窗口134帧已核，A旧旋转的排版alert与颜色错配历史继续拒绝；同生产的C10原图/81秒录屏6总览/3窗口114原始帧（11表）已核，浅深暂停、横屏和恢复竖屏正文与所列安全边缘可接受。App横屏裁图带黑区，公开XCUIScreen整屏图正确，双图/几何probe证明观测差异；Preview只收C的6张正确阅读整屏图。旋转仍显示加载并短暂章头再恢复锚点，不作为无缝动效或手机FPS验收。

旧四轮完整失败、a650早期定向10/10、第五完整自动通过但原生拒绝、B旋转10/11、C10/11和同源字体2/2全部独立留证，不追认旧失败。已核当前无生产变动，采用真实完整Release加同生产补充验证，未跳过失败CI生成IPA。原件本地范围服从最新CI保留回执，文字日志/summary/metadata与项目验证记录保留。

M4整体未完，普通设备/TrollStore、大字/VoiceOver/完整旋转及减少动效矩阵、手机Release帧时间/内存/功耗未验收。Build28“目前感觉流畅”仅实际手机主观反馈；Build27外部字体导入仅用户实际样例。未含字体删除/无限字体/可变轴/单书覆盖、Share Extension或M5。下一步收本片手机状态栏/手势条/旋转与慢滚触摸反馈，按性能计划推进，不盲改定位管线。

最新用户“改完别关机了”：保持开机，本轮不发出关机命令或安排关机。

## 保全与恢复

正常HEAD6d761749/空index、M2 e6f31d85/M3 44af41f0保持。edges源a650为完整Release，screen源f320为补充旋转/字体复核，appearance为最终文档私有快照；正常工作树未提交改动全部保持。最终实际审计见build/ci/39147081645/final-preservation-check.json和final-delivery-receipt.json；它们未生成前不要假定最后收尾成功。547当前源对f320验证，545与Release同字节，不能将对a650的两测试差异说成“只改文档”。

本轮验收依赖A完整、C整屏和同源字体D三组诊断，均属本版本使用中证据；历史轮只保留完整文字日志/summary/metadata，精确清单与证据边界见m4-edges-build29-ci-retention.json。根53交付包、源/原创素材/19恢复ZIP不在历史CI清理范围。旧原件路径是否仍在本地以回执为准。

恢复先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，核实际Git/文件/完整日志/任务。完整开发过程归档HANDOFF_BUILD29_DEVELOPMENT_2026-10-19.md。本片完成后的下一项是手机反馈/性能专项，M4未完不进入M5；保持开机。

## 本地历史诊断收尾已完成

旧7轮20566项、9954.8MiB已按审定绝对路径/链接/摘要清理，独立核对删除项均不存在；482项完整文字日志/summary/metadata保留，53根交付包摘要保持。A39147081645/C39155583794/D39179687615是本版验收依赖，三组完整诊断仍保留至下一交付；源/原创素材/19恢复ZIP未纳入删除。实际精确回执Documentation/ValidationLogs/m4-edges-build29-ci-retention.json。旧大原件路径为历史引用，不表示仍在本地。下一步最终源/包/备份/私有树/远端与任务核对，未见final-delivery-receipt.json前不假定其完成；保持开机。
