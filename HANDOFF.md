# 当前交接与恢复点

## R1设置隔离：纸色反例通过，原生加载/定位仍阻止发布

完整39243868846/024fc87仍为171/177失败，Release未执行，无Build30 IPA；Build29是最后交付。录屏同机对照39263942566/f02为ON64/67、OFF66/67，原失败和完整原件保留，不能归因于录屏单一因素。

最新4UI[39272564753](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39272564753)/e85c25f2实际2/4，0跳过，test65、summary/export0，Swift编译诊断0；556冻结输入和artifact12199630365的digest/CRC已核。120像素纸色正反例与菜单重开通过；慢滚在Home/activate后仍显示运行，测试未确认真实后台；旋转在深灰横屏后持续显示“正在准备”，原可读/无加载守卫正确拒绝，不再归咎于纸色。暖色横竖屏、深灰竖屏原生正文可见。记录Documentation/ValidationLogs/reader-ready-ui-39272564753.json；本地watcher88241及下载75255均已完成，无该轮运行任务。纸色修正已Apple编译，旋转未验收，178完整门槛未执行。

最新fonts2[39279664338](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39279664338)/f32cc933已实际结束0/2，0跳过，test65/summary0/export0，Swift编译诊断0；556输入逐项匹配，artifact12203080049完整digest/CRC已核。无本轮watcher/下载进程残留。sourceHanSans分页重开字体已加载但锚点失败，DOM在1650ms到2010、1746ms回0，已记录RO帧1747ms才开始；402x750/docWidth10452/font ready不变，不能将该RO回调当作回跳起点。另一项在换字体前准备深段落失败，新捕获后探针未执行。原生job32分22秒，两个case累计111.933秒；准备/编译/启动/导出不能统称用例耗时。完整记录Documentation/ValidationLogs/capture-probe-39279664338.json。

当前下一独立实验只改同一ReaderRenderingTests测试文件：为Readium实际使用的Element.scrollTo及scrollLeft setter保留原参数/this/返回并记录有界调用栈；准备wait失败也导出轨迹。原断言、预算、生产及依赖不改，现有RO轨迹与独立写入轨迹各最多16条，不收集正文。区分JS主动写回0与未被这些公开路径记录的回跳；没有记录到写入也不能独自证明是WebKit内部错误。先Windows/JS语法、冻结，再执行原fonts2；禁止无新证据full重跑。当前已应用；Windows453语法新增0/54Vendor限制、探针JS语法和本地转发合同检查通过（均非Swift编译/原生验收），原生待验证。

正常HEAD6d761749、普通index及既有交付包保持，不做R2/R3/R4/M5，不关机。长期规则在AGENTS.md和Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md。

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

当前fonts2诊断已派发：https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39279664338 / f32cc9333418a2ca30e97e2e47676f5f07bad175。Windows453语法新增0/54Vendor限制已通过（非编译），556输入冻结；仅ReaderRenderingTests测试诊断变化，无生产变更，原断言与预算保留。不移动冻结输入，不追加full。首次dispatch HTTP500后两次只读确认无新run，才重发一次成功。
