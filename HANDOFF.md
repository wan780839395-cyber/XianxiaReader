# 当前交接与恢复点

## 实际最新断点（先看这里）

新实际结果38906278076/ff824已failure，full.log只有新EPUB字体用例一例失败，其余133（含原124与TXT/两字体UI/关闭迟到）通过，summary待原件核。失败位置在continuous首次导入后的anchorScript，canonical仍p25,char476，xianxiaViewportOffset=-9.84375，DOM caret476，正文正常；测试错误要求rect.top>=-1/整块在屏内，把顶部仍部分可见文字误判丢失。现仅新用例按字形rect与视口相交判断，continuous额外加原字符Y与导入前/每次fresh canonical offset差<3px（更精确），paged仍核同一文字可见；首>100、加载字形/150%/静止重开/同名路由等不减。App运行源保持7ab，需Windows再冻/完整新CI。旧1.312GB诊断download43796，临时分块和原ZIP放C:/Users/78083/.cache/XianxiaReader-Build23-CI，实际解压日志/xcresult仍build/ci/38906278076；尚未CRC不能写完成。未交付，普通HEAD/index不动。

2026-10-16T13:21:58.048304+00:00（UTC证据时间，用户时区Asia/Shanghai）。用户授权内置几个字体，已实现思源宋体SC Regular OTF2.003、霞鹜文楷Regular TTF1.530（原字库合计50,472,272B），原OFL/固定官方revision/摘要/实际CoreText中文glyph与独立真UI初步通过；完整新候选尚未交付，Build22仍可安装基线。

主源`ff82423a9a4092873d9d9f26d513e34064af0fc1` / `codex/m4-font-anchor-tests` / CI38906278076，当前in_progress/pending，https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38906278076。唯一主watcher工具session91856，写build/ci/38906278076/run.json/full.log/artifacts.json；先查OS进程再恢复，不重复dispatch。Windows433语法新增0/54既有限制、17工具、35原测试主体保持/16新增、522源码/资源blob冻结。预期Linux/macOS Core133各、iOS134=115集成+19UI、严格无签名Release23/min16、各四长TXT Release探针；实门槛以M4_FONT_VALIDATION_REPORT.json为准，当前{'linuxCorePassed': True, 'macOSCorePassed': False, 'iOSTestsPassed': False, 'deviceReleaseBuilt': False, 'desktopLongTXTValidated': False, 'Build23DeviceAccepted': False, 'M4Complete': False}。

实现：App两只读Bundle字体不复制/摘要开书，不占12用户导入名额；Adapter最多14faces/正文窗口仍12，旧可选UUID偏好兼容。后台本地TTF/OTF导入/目录/缺失重导/错误可见，完整锚点受控重开；资源字体排版走Readium已有完整锚点invalidate，系统连续排版仍动态。初始pendingLocator等待标准document.fonts.ready Promise完成，通过原evaluateScript轮询观察，15s上限/32ms/取消/可见资源错误；不引入受WebKit293831影响的refined Swift API。每FileURL独立UUID资源路由、章节复用，真实两个同名TTF回归。两Vendor Swift/UPSTREAM明确登记，无依赖/锁/JS资产升级。

历史均保留：首轮38880257296为Agent取消；38881623233=129/131，两新初始定位失败；e758/38886008057=128/131（连续字体150%定位/TXT构造/UI目标）；277/38887978313=131/133（两新初始定位，原124全过、两字体UI/CoreText通过，另一次新TXT helper编译warning）。后43e/38890891607、bc6/38892156952、2b5/38892611316、255/38893802693均dyld缺libswiftWebKit、集成host启动前abort，不能写134主体失败或通过；bc6结论cancelled且原因未核，未由本Agent取消。四原AppleZIP均CRC/解压与summary/log证据已留（overlay-*.json），其他fail原件保留。此问题已查官方WebKit293831后改回原JS桥；7ab/38901198541实际130/134（0跳过/0编译warning/error，启动问题消失），两旧回归fresh capture unavailable/减少动效关闭hit失败与两新测试第二字体期望、TXT临时空DOM失败原件已核，证据compatibility-130of134.json。当前ff824仅改两新测试：每个独立换字前采fresh完整canonical DOMRange并核该point可见，原首>100/字号/重开断言保留；TXT先验证DOM p存在。App/Adapter/Vendor运行源码与7ab一致，旧35主体不改，旧失败根因未定，完整新轮待结果。此前详录HANDOFF_M4_FONT_ITERATIONS_2026-10-16.md。

普通HEAD6d761749/空index/M2e6f31d85/M344af41f0保持，原875路径/39旧包/13ZIP备份均核并保留，只使用私有index快照codex/m4-reading-appearance；当前私有tip以git实际为准，主编译ref独立。没有Build23 IPA；源码冻结后只补文档与helper，若运行源再变则新CI。所有旧watcher/download均已结束，主watcher仍跑（恢复时重核）。38901198541原件43791曾截断失败，82150断点续传后已CRC/解压结束0；原失败保留。尝试清本轮重复分块被自动策略拒绝，未删除任何原件或分块；后续新artifact临时分块用C:/Users/78083/.cache/XianxiaReader-Build23-CI，最终ZIP和日志仍在项目。

下一步：主CI真实结果→原件CRC→inspect_continuous_ipa.py IPA23→validate_font.py finish（134/19视频/字体与许可原字节/522blob/三锁/旧包）→runtime诊断→review_font.py prepare/overview font+bundled+选定旧外观/回看+review_font_raw.py原VFR窗口→人工manual-notes→finalize_font_native.py。本轮原生通过才执行deliver_bundled_fonts.py package/docs/preserve→最终私有快照→verify/远端树/无任务回执。旧deliver_font.py已过期，禁止用其13新增/131版本打包。OTF内置真实页面将由主回归验证；外部OTF真UI/所有Provider、大中文手机首次加载/内存/FPS/功耗/普通签名/TrollStore/旋转辅助功能仍单列。M4未完、不M5、不关机。

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
