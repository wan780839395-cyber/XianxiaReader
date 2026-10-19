# 当前交接与恢复点

## 用户同意优先隔离阅读职责（2026-10-19）

用户明确要求实施并参考成熟项目。R1 已审阅同基线 Readium 3.11 UserPreferencesStore、固定 revision Readest 设置/书籍存储及 Apple actors 并发合同，具体链接与取舍在方案。源码已接入共享设置队列、窄存储接口和按会话过滤的完成订阅；新增7项独立存储边界+2项生命周期回归，原test主体待冻结对照。新增 settings 定向入口只跑存储与生命周期，不生成 IPA。恢复基线在 `.cache/recovery/20261019-settings-isolation/start.json`/`before/`。Windows451语法新增0/54既有Vendor限制、17工具、bash -n通过；版本30待Apple定向，随后同源完整门槛，尚未编译/交付。旧完整位置采样与3秒/20秒预算不改。

冻结源 `b1119d0b79601d0537c7208533d2b079e5706e7e` / `codex/refactor-reader-settings` 的 settings 定向 [39182894124](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39182894124)真实35/35、失败/跳过0（26原生命周期主体逐字保持+2新生命周期+7存储），实际测试0.85秒，Swift编译诊断0；Linux137通过。完整日志、xcresult summary及两artifact的GitHub digest/CRC已核，原生大材料仅约0.4MB，不生成IPA。8运行/测试/配置路径白名单和正常HEAD/index保持；同恢复目录 `candidate.json`/`candidate.diff`/`diagnostic-result.json` 可恢复。接下来唯一同源完整137各平台/172iOS（145集成+27UI）/Release30，完整门槛仍未通过，不拿定向代替交付。

同源完整已唯一派发 [39184148461](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39184148461)，运行代码不再变化，预计137各/172iOS/Release30。正式范围与定向结果在 `Documentation/ValidationLogs/m4-settings-isolation-r1.json`。本地核Linux时首次误用macOS的Executed汇总格式断言失败，已按实际并行日志核137个唯一XCTest索引；原件与CI未变，不重跑。恢复先核本run实际状态和日志，不另派完整。

本完整run的Linux原件已GitHub digest/CRC核收，137唯一XCTest及4组长TXT Release探针的allChecksPassed均正确；只置Linux门槛。Apple仍运行，gh watch为exec80920，完整日志/summary/Release30尚待，不修改冻结源码。

完整39184148461已真实失败：145集成全过，27UI中25过/2失败，预期170/172待xcresult原件核实；无Release/IPA。旧progress/header用例在第一次目录跳第二章后等待“灯下第1段”20秒失败（尚未改设置或执行回看），旧安全区用例完成浅深旋转后返回按钮AX高度43.999999999999986低于原44断言。所有9新增用例、旧字体/设置UI均过。当前下载同run完整1922089479字节artifact12158577919（exec5356）看原图/录屏/AX，旧预算和生产源码暂不改。先查官方浮点精度合同并定位真实页态，之后只定向这两项；不盲重派完整。

原件已GitHub digest/CRC全收，xcresult确为170/172；下载5356/监看58689都已结束。已实看2张完整录屏1fps总览、点按原帧、深色恢复竖屏与设置重开原PNG，解码点按事件为portrait402x874下x201/y424.333。记录中第二章点击后目录仍停留，没有设置编辑/回看操作，独因未定，不改引擎。依据Apple FloatingPoint.ulp，只将安全区用例的高度测量限定为4ULP近整数归一化，保留原44阈值；新增纯测量反例43/43.5/43.999999仍不合格。旧progress函数逐字不改；其他原test只有此1处测量适配。App/Packages/Vendor相对b111保持。Windows451新增0/17工具/bash -n通过，下一唯一settings-ui3诊断（两失败原case+1纯测量），不拿它当完整门槛。详情first-full-failure.json。

状态监看gh watch80920因GitHub API EOF退出1，独立API已核run39184148461仍in_progress。一次提前请求完整日志明确返回“仍在运行、结束后可用”，不算源码/测试失败。改复用已有watch_autoscroll.py同run，仅接续查询和最终取日志，不dispatch；旧watch错误在full-watch.log，恢复须查真实run，不凭本地监看退出码判CI失败。

实施顺序和第一片边界见 [READER_ISOLATION_PLAN.md](Documentation/READER_ISOLATION_PLAN.md)。恢复时先核实际工作树、同源run与任务，再按单片范围推进；Build29 交付和既有未定根因继续按下文记录。定向watch已结束；完整当前复用watch_autoscroll.py39184148461，日志在build/ci/39184148461/watch.log，不另起重复监看/dispatch。源码冻结，运行时不要更新构建ref或把未完成结果写成通过。

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
