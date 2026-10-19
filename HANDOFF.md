# 当前交接与恢复点

## R1设置隔离与关闭合同修正（2026-10-19）

用户要求把教训写入整个项目并继续完成。根AGENTS.md已新增长期规则，并引用Documentation/CHANGE_AND_DIAGNOSIS_WORKFLOW.md；一次一个切片，每次远程实验明确假设和最小范围，不无假设重复整套，不把定向通过当发布通过。

最新39211610770/383b11a已结束，65/66，两个新关闭合同和原三个加载失败用例全部通过；唯一失败是旧分页字体用例等待800ms中间态，尚未请求最终字体。103条有界资源样本观察到主机压缩内存峰值2763MiB、空闲最低55MiB；调度/资源压力确实存在，但不证明历史慢启动唯一原因。原始结果及采样摘要见Documentation/ValidationLogs/reader-session-close-39211610770.json。

当前准备最后候选：生产修正代码与383b11a相同；只把该旧字体测试的800ms故障注入改为原生fonts.ready加显式屏障，要求中间字体仍未完成时发出最终选择，再主动放行，保留深字锚点/最终字体可见断言和生产预算；失败后的teardown也显式放行。原28个renderer主体中27个逐字保持，1个只改竞态注入同步；新增2关闭合同与1control，总148单元/集成、28 UI。

CI按GitHub官方主机规格改为显式macos-15-intel（4核14GB，Xcode16.4/16F6及iOS18.5保持）。fonts-full先在同一runner跑原两项字体定向，失败真实阻止后续完整门槛和IPA并保留原件；通过后再跑全部148+28及严格Release，重用同runner构建目录避免再准备一台机器。旧ARM UI不复用。26工具测试含新preflight的65/23退出码拒绝和原件保留回归；未派发前不能假定原生通过。

已核实的实验：
- 39209145399/cb14211实际3/4。微型scheme连续8次加载释放通过，旧六字体第6次重建WebContent启动62.154176秒而失败，不能断言全部是环境问题。加载/关闭100ms观测不证明永久泄漏；临时弱采样已移除，control排末尾避免预热reader。
- 39209591549/99acd92实际0/2，在未修改生产上复现：分页关闭后导航/UI/scroll回调与预加载视图未清；立即关闭后分页和连续均能迟到创建WebView。两组原件digest/CRC已核，完整日志/summary及断言记录Documentation/ValidationLogs/webkit-loading-control-39209145399.json和webkit-close-contract-red-39209591549.json。

当前修正仅Adapter close调用和Vendor navigator关闭合同（另UPSTREAM准确摘要）：统一终止两容器，先清分页delegate再移除，触发Readium 3.11原始PaginationView/spread clear；initialize开始及await返回后拒绝已关闭会话，完成初始化等待。未改App/UI/Core、存储格式、Locator、排版、锁文件或版本，保留20秒/3秒/字体15秒预算；原28个renderer函数正文不改，新增2关闭合同+1control，总单元/集成为148，UI28。旧UI保护已实际拒绝复用，因此66项通过后必须完整148+28和严格设备Release，不能走unit-release。

R1设置持久化已实现，App生产范围仍3文件，原设置/生命周期35项最新旧run全过。上个完整39196134450/8f的28 UI全过但整体失败；39203522040/cb为142/145、3旧WebKit失败，严格Release阻止。Build29仍最后交付，没有Build30 IPA。R2/R3/R4未实现，手机/M4整体验收未完成。关闭缺口已复现不等于全部慢启动独因已修。

正常HEAD6d761749911233122bcd031fcf718d22a19f9e77、空index及大量既有未提交源码保持。精确备份/差异/554输入见.cache/recovery/20261019-webkit-loading/production-before、close-fix-candidate.json、source-proof-close-fix.json；53旧交付包SHA保全见build/ci/39203522040/recovery-checkpoint.json，旧恢复ZIP未触及。后续若改Vendor/UPSTREAM.json的验证状态，也属于保护输入变化；最终完整门槛冻结前移除临时pending状态，之后只更新项目文档，不回改已构建Vendor元数据。不关机。

完整方案：[READER_ISOLATION_PLAN.md](Documentation/READER_ISOLATION_PLAN.md)。此前断点及所有旧失败历史归档Documentation/HANDOFF_R1_SETTINGS_DEVELOPMENT_2026-10-19.md，不把归档中的运行状态当当前任务。

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
