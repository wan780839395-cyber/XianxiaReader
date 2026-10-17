# 当前交接与恢复点

2026-10-17（Asia/Shanghai）

## Build26 阅读面板

Build26本切片已交付；实际编译源`1e4ae348a39679df8476bda6c74380d4615078b0` / ref `codex/m4-reading-panels` / [完整CI 39038829961](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39038829961)。Linux/macOS Core各135、iOS148/148（125集成+23真UI），失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release26/min16。三锁六pins、536源码/资源/配置blob、每平台4组长TXT Release探针及IPA六字体/原OFL原字节已核。Windows438语法新增0/54既有Vendor限制、17工具通过；语法不算编译。11个原UI test主体保持；新增2项真UI与1项原生输入集成回归。

目录、书签和书内搜索统一使用阅读菜单的灰绿浅深表面、柔和正文色、清晰间距与空状态，系统原生List复用/滚动/安全区和书签左滑删除保留。目录保留原ordinal/深度/所有条目，不把TOC序号当canonical章序或猜当前章。搜索框固定顶部、清空经既有setQuery取消旧会话/结果；提交收键盘、匹配词灰绿加粗。增量批次/1000条上限/加载更多/停止/错误/关闭取消、原生完成/下拉关闭、原导航/完整位置/删除事务保持。新搜索按压显式尊重系统与持久化额外减少动效。书签删除显式柔和砖红色，避免全局浅绿tint/白字对比不足。不增加逐行阴影、自建整表、依赖或正文重排；Core/DB/schema/Reader与Search ViewModel/ReadingInterfaces/Readium/Vendor/字体/资源窗口均未变。

新真UI覆盖五主题目录/空书签/搜索首屏/44pt，以及真实设置开启额外减少动效→删除书签→退出/重开持久化、搜索结果→清空→新词无匹配→重搜跳转与回看入口。新增真实UIWindow内的中文marked-text/光标→换色保持→清空→新词/收键盘回归也通过；原生输入按系统正文字号增高，原UI的44pt断言保留。既有目录/书签/搜索完整定位、取消与字体/三阅读模式回归均重跑。本片未声称解决用户报告的菜单轻微卡顿；Build25基本可继续使用而流畅度仍待优化，证据m4-settings-build25-device-feedback.json。

安装[XianxiaReader-ReadingPanels-Build26.ipa](build/XianxiaReader-ReadingPanels-Build26.ipa)，SHA256 `5a5483916f7b22e527ad938094b5eece897e5cd6a35214512ff22eb74c37d61e`；原创样书/21张本源原生Preview/沿用字体样本与原许可包[XianxiaReader-ReadingPanels-Build26-TestKit.zip](build/XianxiaReader-ReadingPanels-Build26-TestKit.zip)，SHA256 `913275a151771470a2c61e1251394af1d403721acfd12ce6cd02a95b00bb497f`。覆盖安装保留书库，+菜单确认0.0.1 (26)。45旧包及未提交源码/恢复备份保留，ZIP CRC/内部IPA/原材料逐摘要核验。

原生人工复核范围：本源21张新面板PNG/4表已实际查看；五主题目录层级/空书签/搜索首屏、深色砖红左滑删除/删除后重开为空、搜索结果/无匹配及稳定跳转PNG可读。两条原录屏89.80s/63.64s全部1fps总览11表，以及目录入场33帧、左滑13帧、清空键盘17帧共63原始VFR帧/7表已查看，保留源PTS、无fps滤镜或插值。113张旧功能PNG及其余16阅读/5书库录屏保留而未逐看。本片加载/重开/搜索跳转片尾spinner与渐显不作为稳态正文验收；旧正文标题/菜单安全区、全动效及手机FPS不追认。

手机菜单/字体列表实际卡顿、FPS/内存/耗电、普通签名/TrollStore、系统大字/VoiceOver/减少动效/旋转和全部File Provider矩阵仍待专项验收。旧阅读暂停安全区/分页快照问题按各自证据保留，不因新面板通过而追认；字体删除/集合/可变轴、单书覆盖、自定义配色/独立四边距等尚未实现。M4未完，先收本片手机面板/键盘/左滑反馈并核旧安全区，再按M4设置与主题路线推进，不提前M5。

首候选3c250618/39023086030由Agent在审查发现新增搜索遗漏持久化额外减少动效传递后取消。实际completed/cancelled、两平台Core各135、iOS完成0/无设备Release成功标记、源码compiler诊断0；完整日志/metadata/整包校验后的历史文字诊断留存。不是源码失败，旧结果不继承为本源门槛，见m4-panels-build26-first-agent-cancel.json。初始界面和受改原测试保留，无降低断言或删除测试。另ac8b387e/39023478476实际145/147：旧字体隐藏重排非零字定位超时、新TextField原生AX22pt未满足44；无Release。原引擎和该旧test与Build25相同，未证实旧超时根因；修正原生字段尺寸/中文组合与删除tint后本源独立全过，不把重跑通过写成旧字体时序根因已修复。完整失败日志/summary/4张实际查看图及artifact摘要见m4-panels-build26-history-39023478476.json。

另5176821d/39027324303实际146/148，两项新真UI均过，但新输入测试未创建UITextField即超时、另一旧字体重开失败；输入定向39037628899证实新测试缺少真实scene挂载，修测试窗口/恢复key后本源独立全过，原中文/光标/44pt及2秒预算保持。旧两字体定向39037690400实际1/2，分页快速重开blank且两条WebContent启动日志47.520322/47.657906秒，另一隐藏重排9.241s过。未改原字体测试或引擎，未证实旧字体/环境时序唯一根因；本源全过只表本轮门槛，不把重跑写成该根因已修。两条定向诊断均无Release/IPA、不替代完整门槛，完整原summary/日志摘要与来源见ValidationLogs/m4-panels-build26-diagnostic-*及history-39027324303记录。

本地CI按AGENTS保留本轮完整诊断；历史原件保留范围服从m4-panels-build26-ci-retention.json实际回执，文字日志/summary/metadata及交付包/源码/恢复ZIP保留。旧文“大原件在本地”只代表当时快照。用户取消关机持续生效，本轮不发关机命令或调度。

## 保全与恢复

实际保全已核：536源码/资源/配置blob与编译源一致，1013维护文件（另有清单本身）、989开工原路径、47根安装包/测试包和16恢复ZIP原摘要/CRC保持。编译后只有文档/验证记录变动；正常HEAD6d761749/空index/M2 e6f31d85/M3 44af41f0保持，未提交工作保留。动态清单为Documentation/FILE_INVENTORY.json，最后核验见build/ci/39038829961/final-preservation-check.json。

历史6轮CI已按精确计划删除10869项/4939891007B，保留222份完整文字日志/summary/metadata；本轮39038829961完整诊断保留，47根包/源码/素材/恢复ZIP不在删除范围。实际边界见m4-panels-build26-ci-retention.json；历史“大原件在本地”描述不能越过此回执。传输TLS失败和curl续传仅属于本地收集，完整CI成功与整包SHA/CRC独立记录，不能混称源码失败。

私有index继续维护codex/m4-reading-appearance；实际编译源1e4ae348与后续纯文档tip分列，最终远端tip/工作树/无遗留助手核验见同目录final-delivery-receipt.json，恢复时核其实际存在与内容，不假定最后步骤成功。

恢复先AGENTS→状态→交接→路线→架构，核实际Git/文件/完整日志与任务。下一M4切片先收手机面板/中文键盘/左滑反馈，再测菜单与字体列表主线程、渲染/缓存/帧时间（只读线索在READING_SETTINGS_COMPACT_DESIGN.md），旧阅读安全区单列；M4与普通签名/TrollStore设备矩阵未完，不提前M5。用户取消关机持续生效，本轮未发关机命令或调度。
