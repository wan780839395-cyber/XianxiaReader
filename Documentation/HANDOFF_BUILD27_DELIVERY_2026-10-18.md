# 当前交接与恢复点

2026-10-18（Asia/Shanghai）

## Build27 字体收藏与排版、书架阅读边界（2026-10-18）

Build27本切片已交付，实际源`bc611bc2acb886d0d8a4e15798633ac29979c24a` / `codex/m4-reading-experience` / [完整CI 39107016454](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39107016454)。Linux/macOS Core各137，iOS158/158（133集成+25真UI），失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release27/min16。三锁六pins、544源码/资源/config blob、各平台4组长TXT Release探针及六完整字体/原OFL原字节已核。Windows446语法新增0/54既有Vendor限制、17工具通过，语法不算编译。受改测试文件中73个原测试主体保持，6原主体仅依赖/新导航与折叠预期适配、12新增，无删除旧test；旧异步打开/关闭/重试/迟到位置/字体回归全部重跑。

导入字体缩成“我的字体”入口，独立两列惰性网格/大字单列/名称查找，样例最多按绘制字号显示，避免宽容器上采样。内置六款与12款导入/每款32MiB限制、透明预览及12图/8MiB后台缓存保持。排版加入舒适/宽松/紧凑三个显式预设，首页留字号/行距/左右留白，段距/字距/字重/缩进/对齐在“更多调整”。打开面板不改旧自定义，点预设才改段落/留白，字体/字号/底色保持；原书排版禁用规则保持。

阅读主题改为自身呈现控制器的公开override与局部环境，不改窗口/书架root。每次开书新presentation UUID，保存后原生dismiss并清空同会话、既有onDisappear统一close/失效，过渡保留正文；重复返回有守卫/保存中反馈，失败仍可见重试。标准外部TTF/OTF文档声明与AppRoot onOpenURL队列支持冷/暖启动，立即持有scope、串行复用原后台协调复制/CoreText/摘要去重，完毕配对释放；外部字体先加收藏，不自动改正文，明确选中才在完整锚点受控重开。Core仅Apple系统流式文件摘要后端，DB/schema/Readium版本/依赖/Locator格式不变。Vendor只补既有横排分页位置通知的附窗/可见前后守卫，拒绝隐藏字体重排的页头覆盖原锚点；UPSTREAM已登记摘要，原隐藏重排/重开测试完整保留。菜单叠加层独立于正文加载布局。设置完成先等待设置持久化，原生关闭后才从可见阅读界面fresh保存完整位置；不扩大3秒采样预算或用旧缓存位置替代，失败可见且旧进度保留，完成按钮有保存中反馈与设置写入错误提示。

安装[XianxiaReader-ReadingExperience-Build27.ipa](build/XianxiaReader-ReadingExperience-Build27.ipa)，SHA256 `7c3d6684929492d36181974e892226800a36e543f76ed22ebb3c1394f9a52e63`；原创样书/本轮实际接受原生Preview/原字体样本与许可[XianxiaReader-ReadingExperience-Build27-TestKit.zip](build/XianxiaReader-ReadingExperience-Build27-TestKit.zip)，SHA256 `4abcce4a33ce87e9fee896db9a5544130e953db912ee5c951d861910da809ca8`。覆盖安装保留书库，+菜单确认0.0.1 (27)。47旧交付包及全部未提交源码/原路径/17恢复ZIP保留，ZIP CRC/内部IPA/原材料逐摘要核验。

实际原生复核：本源64张选定PNG/11表已查看（另直接查看字体网格、查询和紧凑预设3原图）；6条完整原录屏的一秒总览27表已查看；4个原始解码窗口318帧/29表已查看，保留PTS、不补帧。字体独立收藏/查询/三预设/高级0.05重开、暗黑书架搜索与三次阅读往返、设置完成关闭、本次Files取消/封面重开、五主题阅读面板/书签删除和搜索清空所列行为可接受。旧正文顶栏遮挡/安全区、退出小保存spinner及书架重排瞬时交叠不作为全动效验收；TOC窗口源PTS有一次回退，仅接受画面状态。其余114张PNG及3条选定录屏未逐看，手机FPS/功耗/所有来源应用和设备矩阵未验收。

本轮用户再次确认测试设备为iPhone13/iOS16.6.1/TrollStore；字体主要来自微信/QQ/Alook，正文及设置都感觉不够顺畅。配置确认不等于Build27设备验收。当前模拟器真实系统暗黑搜索/取消/浅深阅读反复往返和本轮记录仅证明所列测试与素材，不等于手机根因唯一已定或所有设备修复。字体服务输入不冒充实际外部来源点击；标准Open In入口的列出取决于来源应用，未加Share Extension。普通签名/TrollStore、所有File Provider/大字/VoiceOver/旋转/减少动效矩阵仍待核。

性能本片落实短预览停止上采样、收藏独立惰性构建和低频项折叠；没有手机Release/Instruments帧时间、内存/功耗证据，不归因60Hz，不声称正文/菜单卡顿已全部修复。连续滚动每次回调请求DOM定位、execute未串行化已执行async采样是具体待测线索，未盲改位置管线；另外消除了目录未变时的重复字体校验、改系统流式SHA并保留完整性/跨块取消回归；m4-experience-build27-performance-review.json留有路径/摘要/下一单飞尾沿合并的回归要求。旧字体CI超时与录屏中的启动延迟、旧阅读安全区/分页快照限制仍独立，不由新通过追认。

首候选b799754/39086068358实际152/156且无Release：1新预设原始JSON键顺序比较、2高级行点击未展开、1新3字体首次ready超时。分别规范化测试JSON、改整行44pt展开、系统流式文件SHA及省去重复设置校验；原20s预算与功能断言保留。历史完整文字日志/summary/metadata与验证记录保留，旧xcresult/失败图的本地大原件以最新CI保留回执为准，不将新通过倒写成旧候选通过；第二候选cb63367/39089264017实际14/15，仅字体自动search drawer的AX滚入失败；第三候选固定44pt原生查询栏，加入既有中文输入回归16/16通过。随后c518d70/39092416032完整155/157：原隐藏字体重排定位及切模式后目录两项失败，无Release/IPA；自动分页通知的隐藏页守卫、菜单viewport overlay及退出闪排版边界另修，新增定向包含原两字体和原菜单共19项，与最后完整门槛分列。不将重跑成功追认为所有旧时序失败唯一根因已定。随后18c130c/39098863950仍155/157，无Release/IPA：原TXT continuous初次位置20s超时、原封面Files已呈现但内部空白；该continuous不经过新增paged守卫。bc3c573仅补无正文同步失败状态、原退出码不变的有界文档服务/进程上下文及5项定向，生产App/Core/Vendor不变；其定向与最后完整门槛仍独立，不把下一次通过追认为旧两项唯一根因已解决。bc3完整39103144069随后实际156/157、无Release/IPA；原TXT和封面Files已过，唯一新用例失败的原录屏/89连续帧和AX证实设置Done因fresh位置未稳定而留在面板，错误落在屏幕下方、返回按钮被遮挡。随后分开设置提交与原生关闭后的fresh保存，新增覆盖页不可采样/偏好写入失败/完整位置失败与重试回归；不削弱原保存错误或3秒预算，不把原失败归成单纯AX问题。字体删除/无限导入/可变轴、单书覆盖、自定义配色等尚未实现；M4未完，下一步优先手机主题/重开/微信QQ/Alook反馈与正文/菜单性能专项，不进入M5。具体取舍/精确Readium3.11及Apple官方来源见READING_EXPERIENCE_DESIGN.md，完整结果见M4_READING_EXPERIENCE_VALIDATION_REPORT.json。用户取消关机持续生效。

## 保全与恢复

原正常HEAD6d761749/空index、M2 e6f31d85/M3 44af41f0保持，私有index维护codex/m4-reading-appearance；实际编译源与最终纯文档tip分列，恢复时核远端、文件、完整日志和进程，不假定最后一步成功。开工1014原路径、47旧包和16旧ZIP核验后新增第17份恢复ZIP，详见m4-experience-build27-start.json；最终544编译blob/维护文件动态清单/49交付包/17ZIP与远端树核验见build/ci/39107016454/final-preservation-check.json及final-delivery-receipt.json，必须核其实际存在再引用。

本轮完整CI诊断保留；历史仅文字/summary/metadata/验证记录，服从m4-experience-build27-ci-retention.json的实际完成回执；若回执不存在，不假定已清。根安装包/TestKit、原字体/样书、源码与恢复ZIP不清理。原生只接受本轮实际查看的图/录屏/原PTS窗口，不能把所有旧功能图或手机FPS追认。

下一步先收手机系统暗黑搜索/快速重开、字体收藏与预设和微信QQ/Alook标准Open In反馈，再测正文/菜单主线程、渲染/缓存/未完成DOM采样数；线索和边界已存m4-experience-build27-performance-review.json。未做Share Extension/字体删除/无限名额/单书覆盖/系统字体安装。旧字体不稳定和安全区单列，M4未完，不提前M5。用户取消关机持续生效，不发关机命令/调度。

## 交付后历史CI收敛执行前

Build27根IPA/TestKit已生成且CRC/摘要通过。已逐规则核对精确清单7373016字节：仅9个完成历史run的21641个旧xcresult/媒体/帧/重复产物，约10054.7MiB；保留当前39107016454完整原件、455个历史文字/metadata、49根交付包和17恢复ZIP。已保存同字节reviewed-plan，接下来执行时再次重算/hash/绝对边界/reparse校验，实际删除完成前不假定成功。

## 历史CI收敛完成，最终保全前

实际删除21641个历史原件，共10543070542字节（约9.82GiB），455份历史文字/metadata与49根交付包逐摘要保持；当前39107016454完整xcresult/录屏/原帧保留。已复扫清单全部不存在、保留文字存在；完成回执Documentation/ValidationLogs/m4-experience-build27-ci-retention.json。接下来最终维护文件/544编译blob/49包/17ZIP核验及纯文档私有快照，正常HEAD/index不变；最终receipt实际产生才算完成。
