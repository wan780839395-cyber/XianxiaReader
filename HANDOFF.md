# 当前交接与恢复点

当前唯一交付主候选：63a44eb1f86a3619e7b16fa5ea1028214ece37c0 / codex/m4-font-browser-initial-ready / CI38961037839。已实际dispatch，435语法/17工具/38原主体/6新增/532blob重冻；运行源码与454相同，仅新竞态测试先等真正可读页与每次翻页成功。完整新Core135各/iOS138/Release24和原生待核，旧结果不能代替。关机尚未启动。

## Build24 当前可恢复操作（实际仍在验证）

主源63a44eb/CI38961037839，Windows435/17已重核；新Linux/Apple/138项/Release/原生未通过前不交付、不关机。旧872/38954435197与cc7/38956008602仍独立运行，首两轮实际133/137、135/137失败已写m4-font-preview-build24-history-*.json，未取消。源码保持冻结，当前私有tip仅纯文档更新，normal HEAD/index仍原样。

本机Python3.11与gh在.cache/tools/gh_2.102.0/bin/gh.exe。以下帮手都在.cache/recovery（忽略但已落盘），不要调用旧Build23交付帮手：watch_autoscroll.py RUN；download_font_preview_artifact.py RUN ARTIFACT core|apple|ipa（完整摘要/CRC/提取后清重复分片ZIP）；inspect_continuous_ipa.py IPA 24；validate_font_preview.py finish（135Core/138iOS/Release24/三锁/532blob/真实许可）。full.log/artifacts.json来自实际完成run，不能仅看网页尾部。Python17与435语法是Windows检查，不算编译。

实际全门槛后：review_font_preview.py prepare，再overview browser/bundled/font；以原始PNG及原录屏联系表人工逐看，review_font_preview_raw.py取所选原始VFR区间（禁止focus的fps采样当原帧）；manual-notes.json只填实际看到的事实，再finalize_font_preview_native.py。PNG预期98，本轮20新附件，15阅读UI原视频/共20UI原视频；未接受的孤立图明确排除Preview，手机FPS/普通签名/TrollStore仍待测。

随后deliver_font_preview.py package；finish_font_preview_docs.py（有实际门槛、独占archive保护）；retain_font_preview_ci.py plan/apply（最新交付全量保留，旧CI仅文本/summary/metadata，43根包/源码/14恢复备份保护，明确历史raw被删）；deliver_font_preview.py preserve；snapshot_m4.ps1以[skip ci]保存；deliver_font_preview.py verify并核远端/当前树一致。所有原930路径保持、532编译blob一致、43包/14备份核验及本人watcher/下载/ffmpeg均结束后，才执行当前用户已授权的普通关机。shutdown_font_preview.ps1有90s延迟与交付保存门槛，未启动，禁止提前触发或添加强制关闭参数。关机实际调度必须先写ValidationLogs回执并保存。


2026-10-17，Build24字体浏览与排版扩展开工。用户明确要求更多内置字体、设置内真实字体样式预览及更多自定义；已保留所有未提交改动，开工930路径备份/41旧包/正常HEAD及空index核对。原Build23完整交接归档HANDOFF_BUILD23_DELIVERY_2026-10-17.md，尚无Build24源码或构建验收。

本轮拟六款风格选择、CoreText后台真实字形预览（不全球注册、不用系统字冒充）、字距/字重/可调首行缩进及行段距范围扩展；兼容reading-v1旧JSON，沿用Readium3.11公开偏好和完整锚点。先核官方字库/许可/API，再最小实现、Core/iOS/原生/Release完整门槛。M4未完，不提前M5。

Build24第一可恢复子步：六款字体原件及原OFL已按官方固定revision/发布zip校验加入；旧两UUID不变、目录上限18（12用户+6内置）、正文窗口12不变。Core新增可选字距/字重/缩进与旧JSON兼容，Adapter映射公开偏好并补完整锚点重排判定；设置真实字形行与单CGFont/12PNG后台预览缓存已写。尚未编译；开始补兼容、真实CoreText预览、Readium文字锚点与真UI回归，原测试不删除。

## 2026-10-17 本地磁盘清理检查点（已完成）

用户要求清理 `D:\ai项目` 不需要的占用。已仅移除旧CI大文件89,928项、51.172 GiB，目录总量55.622→4.450 GiB，D盘可用约53.255 GiB；删除错误0、非计划删除0。完整保留最近已交付run38918803378的2,260文件、所有build根目录安装包/测试包、3,316份历史文字日志/摘要、`.cache/recovery`及所有未提交源码。安装包SHA256全部保持；清理期间另有源码/测试并发更新，仅记录差异、不回滚。1000项源码/安装包基线与精确清单已保存于清理聊天work区，项目摘要为 `Documentation/ValidationLogs/local-disk-cleanup-2026-10-17.json`。旧轮ZIP/分片/录屏/xcresult和审阅图片已删除，历史文档“原件保留”只代表当时快照；远端可下载性未核实。AGENTS已补本地产物保留规则。Build24上方开发断点和验收状态不变，未执行构建/测试，不代表Build24或设备验收。

Build24构建/测试前检查点：六字体原件/OFL、后台单CGFont+12PNG原字形预览、六行样式选择、字号前置、字距/字重/0–4字缩进与更宽行段距/留白已接入；旧字体UUID/reading-v1兼容。新增2Core、2集成（六字体CoreText PNG/真实Readium全部六字体+CSS+完整位置）、1真UI六款浏览/排版持久化，旧测试主体保持。现在Windows语法/17工具与源码冻结；尚未Apple编译或Build24交付，Build23原件全部保留。

Windows435语法新增0/54既有限制、17工具通过；受改38原测试主体保持、5新增、532编译/资源blob已冻。预期Core135各/iOS137=117集成+20UI，严格Release24；现在创建私有index快照与独立验证ref codex/m4-font-browser，再dispatch唯一完整CI。现有普通HEAD/空index/M2/M3保持。字体来源/API/缓存与后续边界已写READING_FONT_BROWSER_DESIGN.md。

实际已dispatch唯一CI 38950061245 / 3a97ebc1dab142b9b4ed67ec254f95bab3696fef / https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38950061245。接下来只核此源完整新门槛；不重复dispatch、不改冻结运行源码。系统新增AGENTS本地CI清理要求已读：历史大产物已由独立清理操作收敛（local-disk-cleanup-2026-10-17.json），最新Build23完整诊断仍在，源码/安装包/恢复备份未删。以前“所有旧大原件都仍在本地”的描述已被清理回执取代。当前D约53GiB可用；本轮分块合并CRC后清分块、完整解压确认后清重复ZIP，旧版本仅保留日志/summary/metadata/验证记录，交付包与快照保留。

补强新预览的高清/错误状态：3a97ebc/38950061245仍独立完整运行（已Linux135），不把它写源码失败或取消。代码审查发现新预览固定2x会在3x设备放大，且AX在失败时仍报正在准备；新候选改3x短字形和准确不可用/失败朗读状态，真实PNG宽度断言900保留实际墨迹/6不同字库。仅这两运行行+新测试预期更新；需重新Windows冻结/新ref全CI，旧轮跑完保留文字诊断，门槛不继承。

最新主源 c66157d669e047152ea2246a24c674cbe0c6f281 / codex/m4-font-browser-quality / CI38951246101 / https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38951246101。532blob已重冻、Windows435/17/38原主体/5新增保持；所有新门槛重置false，主watcher以本工具回执为准。旧38950061245不取消，最终仅留日志/summary/metadata，不复制历史全量大产物。

用户新增直接指令：本轮全部完成、可做验收无明确失败后帮忙关机。授权仅本轮：先完成字体/预览/排版、完整新Core/iOS/Release、原生关键素材复核、交付/文档/保存/任务核对，再正常Windows关机（不加强制关闭参数）；手机专属项目仍明确待实测，不冒称通过。当前仍开发/测试中，禁止提前关机。

快速切字审查补强：既有submitPreservingLocation忽略采样Bool，在前次字体hidden reflow中仍可能继续使用临时DOM。现在同显式capture一致，最多3s/32ms让步等待真实采样成功，每await核取消/请求/navigator，defer仅清本任务；到期可见提示，不把失败当成功。新增真实分页800ms字体ready期间再选第三字体，原非零文字仍可见的回归。3a97和c661两轮继续独立跑完，仅保留适用历史文字诊断。最新源码须再完整验证；本次6新增、预期Core135各/iOS138=118集成+20UI。

主候选38954435197实际Linux135/4长TXT Release已通过，116199B Core artifact12070201994已校验GitHub digest+CRC、完整提取并按AGENTS清除重复ZIP/分片，回执build/ci/38954435197/core-download-receipt.json。Windows与主源门槛保持，Apple/原生/Release仍待核；CI/下载帮手修正135编号集合及历史最小提取回执的范围描述，未改冻结运行源码。

38950061245实际失败：完整文字日志和artifact manifest已留，源compiler warning/error0，20真UI其中2旧失败、新六字体UI通过；原FreshReturn旧瞬时回归失败；新六字体连续位置测试Swift插入负Y形成JS `b.top--9.84375` 语法错误（确定测试构造问题）。现在仅给新测试的Y操作数加括号，保留原fresh非零/原Y±3/CSS/字形/重开断言；不改任何原测试主体。872主候选仍独立跑完不可代替新测试修正源码。下一步重跑Windows/冻结/独立完整CI，前轮实际失败不追认成功，关机继续等待本切片门槛。

首轮原生早查：经GitHub签名URL HTTP Range只取14张新字体/设置PNG，成员CRC逐个核，完整ZIP digest/CRC未核且未下载全归档，不能当最新主源门槛。已实际查看排版设置、六字体列表下半与马善政原字形：无倒字、风格确实区分，但compact字形有暖白硬矩形贴在灰绿卡片上。现仅compact绘制保留透明背景（文字仍按主题颜色），主大样例背景保持，新增于同一新测试核透明alpha0与实墨255，无新增test计数。需435/17/原38主体/6新增/532重冻并用新源全CI，后续不再推测性改动，等待实际结果。

c661/38951246101也已实际失败，0源compiler诊断：同一个新测试负Y拼接错误及一个原整屏UI等待失败，原FreshReturn和库封面本轮通过。两轮旧UI失败分布不同，原因未定，不宣称已修复；原测试主体/完整文字日志均留。前三轮未取消，主交付仅454/38956512671。首轮早查只取14 PNG成员共10,078,891网络字节，未下载1,373,489,835B全归档，成员CRC真、全ZIP摘要未核，范围在EarlyFontReview/selected-members.json。

454d950/38956512671 主源实际Linux135/四长TXT Release通过，artifact12071320371（116252B）完整摘要/CRC核完并清重复分片ZIP。当前仅Apple完整编译/138项/Release与最新原生待核；源码冻结。原生早查发现的硬矩形已用compact透明背景处理，需最新图确认，不能拿首轮画面替代。

872/38954435197实际135/138失败（0源compiler诊断）：负Y已知新测试错误、原返回UI一项等待失败、新800ms字体竞态测试在29行准备非零分页前失败；尚未执行中间/最终换字。完整位置为h1/char0，两个早发turn未移动。核Readium3.11官方Navigator.swift与实际spreadLoaded gate：翻页可因当前不可移动返回false，报告href不等于可读页面已就绪。现仅新测试先等真实one.xhtml/window/alpha1与注入ready已settled，再每次翻页等待scrollX增长，保留两次翻页、char>100、800ms中间隐藏窗口、最终原字可见断言；运行源码自454起不变。需再435/17/38原主体/6新增/532重冻和全CI，旧失败均保留，不关机。

63a44eb/38961037839实际Linux135/四Release长TXT再通过，artifact12073160376/116265B已GitHub摘要+CRC+完整提取、重复ZIP分片已清。核心运行源与454一致、只新测试准备增加等待，仍需当前Apple完整138/Release/原生实际结果。正常关机帮助脚本仍未启动。
