# 当前交接与恢复点

## 实际最新断点（先看这里）

2026-10-16T10:38:04.075370+00:00。用户新增“可以内置几个字体”，本轮已实现内置思源宋体SC Regular OTF2.003、霞鹜文楷Regular TTF1.530与本地导入；两原字库50,472,272B，固定官方revision/摘要/原OFL已核，App只读Bundle URL按需加载，不占12用户导入名额（Adapter≤14faces/正文窗口仍≤12）。尚未交付，Build22仍安装基线，禁止把源码候选当验收。

当前主验证：源277dca99bde3eabb9eb657ce4ee50e6adf537baa，ref codex/m4-bundled-fonts，CI38887978313（in_progress/pending），https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38887978313 。Windows433语法新增0/17工具、35原测试主体保持/15新增、522编译源/资源blob；Linux133与四Release TXT探针原件CRC已核。Apple/Core/iOS133=114集成+19UI/严格Release23/原生中文页面尚待完整原件，所有门槛以report实值为准。

扩展前独立CI38886008057/e7586a80目前in_progress/pending，因新需求使用另一ref而未取消，证据只覆盖此前13项字体导入版本。旧首轮Agent取消/第二轮129of131初始定位失败保留原件，不追认为通过。149caa08→e758仅新测试准备，当前277dca增加实际内置App资源/界面与中文测试，二者范围不能混写。

观察工具主74660、旧71340各对应本轮/扩展前；若工具ID失效，先核OS进程/run.json/真实API再恢复唯一watcher，禁止重复dispatch。当前维护主ref codex/m4-reading-appearance私有快照277dca99，普通HEAD6d761749/空index/M2/M3/875开工路径/39旧包/13备份保持。522运行源冻结，后续只补文档与验证/交付助手；源变必须完整新CI。没有Build23 IPA，不关机。

下一步核两CI真实完整结果。主候选成功后下载原件CRC→inspect IPA23/validate_font.py finish→font_runtime_diagnostics.py→review_font.py prepare/overview（含bundled）及review_font_raw.py原VFR帧→人工manual-notes→finalize_font_native.py。原生通过才运行deliver_bundled_fonts.py package/docs/preserve与最终快照/verify。所有helpers已准备但未冒称执行成功。手机/TS/首次大字库加载与内存/FPS/功耗/全部Provider/外部OTF真UI仍单列；M4整体未完。

## 本轮历史检查点

内置源片完成待编译：App只读Fonts文件夹（两原字体50,472,272B+OFL+PROVENANCE+README）和稳定UUID资源，最多12导入+2内置，正文窗口仍12；目录坏时保留内置可用并提示，不把原JSON覆盖为空。设置页两内置选项，按需加载不每次拷贝摘要，原导入与偏好兼容。新增两回归（CoreText中文原件/真UI）并扩展两新渲染测试核实际中文字形及逐款换字/重开完整锚点。现在先跑Windows433语法/17工具及旧35主体核验；当前e758 CI未因扩展取消，等真实结果后新候选独立全跑。尚无新IPA。

2026-10-16，用户反馈Build22功能没问题并继续；只接受基本自用功能，不扩大完整设备/FPS/功耗或M4验收。Build23本地字体导入开工，尚未实现/编译/交付。

已按AGENTS→状态→交接→路线→架构核实际文件/Git/完整CI38871744221成功/任务。私有tip24d311e/源3cb1d2，874维护文件/507源码blob/39旧包/12旧备份已核，新875路径备份见m4-font-build23-start.json。正常HEAD6d761749/空index/M2/M3保持，无运行CI/本轮任务。Build22交付独立归档。

下一片TTF/OTF单字体：文件选择与异步验证/协调复制/相对路径元数据/可见错误；全局阅读字体选择及恢复默认；Readium既有font-face资源通道，不全局注册、不加HTTP服务。字体目录变化需完整文字锚点保护，迟到请求不能改新会话。先核公开API/版本及成熟实现，记录设计取舍。字体集合/可变轴/永久删除/单书设置不提前铺开。完整Core/iOS/Release23和原生页面/视频复核之前不交付。

Build23源码首片：Core相对字体身份与有界存储事务/重复与缺失重导、TTF-OTF签名+CoreText后台验证；ReadingInterfaces目录capability，Adapter使用Readium3.11公开CSSFontFace、目录在open配置、无Vendor/JS新改。VM新增字体时采完整位置并保存后受控重开，选已有字体走原重排；会话/请求/await校验、关闭取消，失败恢复旧目录/外观。设置页沿用原卡片/44pt并保留选择器coordinator，原reading-v1只加可选UUID。正在补真实font-face/锚点和取消失败回归，尚未编译。测试字体复用仓内IA Writer Duospace 81636B与原OFL，不引入个人字体。

Windows432语法新增0/54既有语法限制、17工具通过，35受改原测试主体保持，13新增=6Core+6iOS集成+1真正UI，515编译/资源blob已冻结。预期Core133各、iOS131（113集成+18UI），必须核真实结果。补retryOpen先正常close避免失败Navigator阻止目录安装。现进入完整Linux/macOS/iOS/严格Release23构建前检查点；尚未Apple编译，不能写通过。

首候选3bac2015197df9dab8ea8a40fbc464c0d73459bf，已实际dispatch CI38880257296。唯一watcher负责run/full.log/artifacts；先核真实Core133各/iOS131/Release23，失败保留原件，不猜最后步骤。

本轮Linux原件artifact12037835000已CRC核，133/133 Core与四Release TXT探针通过，linux.json记录；Apple仍aggregate构建测试，不能推断具体测试阶段。唯一watcher工具session55283负责38880257296，勿重复dispatch。下一步核真正Apple结果及新字体原生页面/录屏。

首候选38880257296由Agent因源码审查补强而取消，已真实completed/cancelled；并非源码失败。Linux133通过，Apple已进入xcodebuild test但未完成iOS summary/Release/IPA，原1.03MB诊断已CRC/解压，first-agent-cancel.json与完整日志保存；watcher55283已退出0。补新页面就绪守卫/实际字号变化/缺字体降级文案，修Task中throwing fixture取值，原35测试保持，仍13新增/515源。重新冻结后跑完整新候选，不继承上一轮门槛。

当前唯一CI38881623233，实际编译候选149caa08c600999f5b53b74e0900eb1b405b7e8a，等待全新门槛。旧38880257296 Agent取消原件保留。

新轮38881623233真实Linux133/四Release TXT原件artifact12037208602下载CRC/解压已核，revised-linux.json记录。Apple仍aggregate，唯一watcher33131；旧55283结束。当前原HEAD/空index保持，运行源码149caa08冻结，未再修改；后续只准备验证/交付辅助和文档，不能把待编译源码写成通过。

等待检查点：新版149caa08/38881623233尚在Apple aggregate构建测试，原生/Release未写通过；Windows432/17与新Linux133/四探针已核。515源冻结，后续仅准备未执行交付helper（deliver_font.py、validate_font.py、review_font.py等）；所有package/docs动作以实际全门槛+本轮原生人工记录为前置。尚无Build23安装包，不把准备脚本当交付完成。

新版149caa08/38881623233实际failure：131测试129过2失败、跳过待summary核；仅新EPUB渲染取非零caret为空、新TXT font paragraph ready超时，均在导入字体之前。新真实CoreText/3生命周期与真UI字体选择取消/持久化/深色/默认均通过，旧测试不放宽。1.23GB原件artifact12039800586已CRC/解压、下载24476结束0，watcher33131结束0；Release/IPA未执行。与既有成熟用例对照补新测试启动模式稳定capture、目标页probe及原非零caret等待，原非零/字体loaded/锚点/字号断言不减。下一步核summary/本轮部分UI画面，再冻仅测试修正跑完整新轮，源码功能仍未交付。

已核第二轮structured summary131/129/2/0跳过，Linux/macOS133各、源warning/error0，旧124全过，新iOS7中5过/2初始准备失败。五新字体UI PNG和完整50.90s原生字体UI录屏4张1秒总览已看，浅深色/选择/取消/重开/衬线恢复符合这些素材；仅局部证据不替代新轮。现在Windows432/17与35旧主体/13新增/515blob重冻后送第三候选；相对149caa08只改两条新测试准备，不改App运行源码/旧断言。未有Release23/IPA。

当前唯一CI38886008057，实际源e7586a8067515a911d09ac4abf31fd4577fb695b；与149caa08仅两新测试准备和文档不同，App运行源码一致已核。所有新门槛重置pending，第二轮129/131失败不追认为通过；从新原件/summary/渲染附件继续。

第三轮Linux原件artifact12039173669已CRC/解压，133与四探针通过（third-linux.json）；Apple排队/运行状态以run.json真实值为准，唯一watcher91524。当前冻结运行源码e7586a80不再更改，尚无Build23 IPA。
