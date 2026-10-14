# 项目状态

更新时间：2026-10-15（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | 自动门槛通过 | 编译/Core/iOS/Release/真实IPA |
| M1 基础 EPUB | 完整自动门槛通过，用户确认连续阅读与重开位置可用；可继续既定路线 | 未逐项确认的原书图像、其他设备/旋转/性能继续单独记录 |
| M2 TXT | Build8完整自动门槛及手机长书/目录/重开用户确认；Build9 ANSI增量验证中 | 手机基础自用门槛通过；新编码/普通设备/完整中文排版单列 |
| M3 完整书库 | 未开始 | 列表/编辑/封面/删除一致性 |
| M4 设置与主题 | 未开始 | 字体/排版/主题/亮度/音量键 |
| M5 性能 | 未开始 | 百万字/数千章基线 |

## 2026-10-15 当前增量（未完成）

用户明确回复 Build8 手机长 TXT 导入、目录跳转和重开位置“已测试，功能正常”，此范围已记录接受，其他设备/性能/中文排版不扩写。随后新增 ANSI 兼容要求：GBK/CP936 默认自动导入，Big5/CP950 与 Windows-1252 手选；已有 UTF/GB18030 与位置身份保持兼容，同时完成范围缓存。候选541b7ae / CI38608713016正在完整验证，源码尚未交付Build9；首轮94b10c6/38608225245 Linux NUL诊断偏移断言失败已保留并实际修正，Apple/iOS/IPA当轮未执行。完整门槛通过后交付Build9，再进入M3完整书库，M4排版主题仍随后。详见 Documentation/TXT_ANSI_COMPATIBILITY.md、HANDOFF.md 与新报告，以下Build8及以前证据为历史记录。

## 当前实际实现

- SwiftUI网格书库，封面/书名/作者/可用进度/最近阅读。
- EPUB Files多选副本导入、可见成功/失败；后台文件协调复制、Readium元数据/缩略封面、缓存TOC。原创EPUB2/3内置导入入口。
- Core的SQLite actor保存Book/Chapter/ReadingPosition/Bookmark，事务/导入恢复/路径和符号链接边界。位置保存完整版本化Locator，拒绝旧异步覆盖。
- ReadiumAdapter隔离引擎；分页、章内上下滚动、横向跨资源、中央菜单、目录/内部链接、书签、搜索/结果跳转、位置保存/恢复。关闭/重开过滤旧异步回调。
- ReaderSurface独立完整viewport、官方frame/autoresizing容器；横排重排媒体保护按实际innerHeight校准，固定/竖排保留原路径。目录/书签跳转后收起菜单；原创长短章/高封面样书和实际窗口回归。
- 安全SearchService扩展保留issue876回归；每批40、上下文64、UI最多1000；不跨文本元素/资源匹配，不收集全书结果。
- project.yml唯一工程源；两个Swift Packages；连续候选使用Readium3.11.0本地扩展及真实解析的6个远程pins（Build3历史为11 pins）；保留macOS完整CI和无签名IPA门槛。

## 最新证据与设备边界

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](Documentation/M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](Documentation/PERFORMANCE_TEST_PLAN.md)。

2026-10-14最新确认：用户回复“ok 能正常导入了 没问题”，Build7交付上下文的首次导入问题已验收通过，报告deviceFirstImportAccepted=true。来源为用户实测，格式/本地或iCloud/实际Build与OS未逐项核读；不扩写为完整TXT/普通签名设备/长书通过，M2Accepted=false。未改运行源码/包，55iOS/各68Core/Release自动证据不变。接续M2长篇与剩余设备验证，再按门槛M3/M4。证据Documentation/ValidationLogs/m2-import-build7-device-feedback.json。

2026-10-14最新用户设备反馈：Build6首次导入仍无反应/提示，第二次正常，已记录为首次设备验收失败。随后Build7直接delegate→Task、书架持有弱delegate至终止、单item sheet及持续错误反馈已通过[CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917) / 0afe45ef6764f3954b41c7f383fe98ff9f662181：各68Core、55/55iOS、设备Release、0 failed/skipped，457运行hash和三份锁一致。新增6项，完整LibraryView/无dismiss/关闭后弱回调/旧回调拒绝与终止释放均通过；初轮53项候选52/53系统DocumentManager异常原件保留，未降低断言。真实错误/成功书架PNG已核对反馈，完整页面布局/用户Files/iCloud未验收；tmp数据库清理SQLite诊断单列，不隐藏。新包build/XianxiaReader-Import-Build7-TestKit.zip / SHA5f280447e39b106cb096074a21d7d0a3954c8435a2131d4c038a8889309f4172，菜单可确认实际(7)，六个Build4/5/6旧包不变。用户设备首次导入随后已确认正常（最新反馈见上方）；M2长书/设备未完成，M3/M4未开始。最新报告M2_IMPORT_DELEGATE_VALIDATION_REPORT.json，设计IMPORT_DELEGATE_FIX.md。

2026-10-14首次文件导入修复已通过[CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849) / 5522489906224a089c91e92180bdcebbe9be2095 / Build6：结果由LibraryViewModel持有并在sheet关闭后消费一次，EPUB/TXT共用；各68Core/iOS49/49/Release通过，456运行hash与三份锁一致，源码compiler warnings/errors0。新增首次TXT、首次EPUB及取消/空选择/重试/迟到文件原生回归通过；两个先前48/49系统DocumentManager崩溃完整原件保留，最新仅修测试过渡/生命周期等待，不降低断言/增加timeout。iOS18.5旧交接未复现用户iOS16.6.1首次关闭无书无提示，设备唯一根因不宣称已证实，Build6设备首次选择仍待确认。新包build/XianxiaReader-Import-Build6-TestKit.zip，SHA256 112113c0e939c5d8aabdc5ad2280c8faf77f3f1d9288145e902d8ec3cc4a815c；Build4/5原件不变。报告M2_IMPORT_HANDOFF_VALIDATION_REPORT.json，设计IMPORT_HANDOFF_FIX.md。M2长书/设备未完成，M3/M4未开始，恢复点见HANDOFF。

TXT产品接入自动门槛已通过：[CI38559906005](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38559906005)，运行源码 `37eb86a46dc9002af381a44204f9bc36d07e11a4`，Linux/macOS各68 Core、46/46 iOS、test/export/summary全0，Build5设备Release/IPA通过；455运行hash匹配、三份锁一致，Windows379 grammar新增0/14 tooling通过。已接入受管理原件/cache/事务TXT导入、编码选择重试/取消、Readium公开Publication+Container最多64KiB窗口、字节/字符/完整Locator位置、目录/书签/搜索/连续。真实iOS模拟器三编码导入、长段600点滑动/3px重开、错正文/字符边界拒绝回归通过；原41 EPUB/lifecycle回归保留。五次真实失败原件保留，包含字节selector实际修复与测试就绪修正，未降低断言。新包另存 `build/XianxiaReader-TXT-Build5.ipa`、测试ZIP `build/XianxiaReader-TXT-Build5-TestKit.zip`；原Build4不覆盖。数十MB/cache重开耗时/巨段边界与用户设备中文页面未验收，完整M2尚未完成，暂不大规模M3/M4。报告M2_TXT_PRODUCT_VALIDATION_REPORT.json，设计TXT_READING_DESIGN.md。

M2编码/cache第二切片完整自动CI通过：[CI 38547339868](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38547339868)，运行源码 `65c1b8d6dbebf311c1e6b4b9534cda59373940b6`，Linux/macOS各60 Core（原33+新增27）、41/41既有iOS集成及设备Release CODE_SIGNING_ALLOWED=NO/IPA通过；445运行文件hash与当次已测快照匹配、三份锁一致。Windows372 grammar新增诊断0/14 tooling通过。支持严格UTF8/UTF16 LE/BE/GB18030分块转换、原/正规正文/目录SHA与编码/版本绑定cache。首轮Apple iconv两项四字节真实失败保留，现改用公开SDK CoreFoundation并通过同样及扩展向量；Linux保持glibc iconv，无新远程依赖。自动编码仅BOM/严格UTF8，其他要求选择；cache复用仍流式核验摘要，TXT导入/阅读/位置未接入，iOS真实TXT codec/导入/页面与设备未验收，完整M2尚未完成。当前Build4用户包保持不动，报告M2_TXT_NORMALIZATION_VALIDATION_REPORT.json。

2026-10-14用户反馈：“这个功能可以了，重开位置也是正常的”，并要求按计划继续。依据上一轮Build4上下文记录连续跨章/重开位置的用户设备确认，沿用iPhone13/iOS16.6.1/TrollStore背景；未报告的普通设备、原书图片、旋转和性能不扩写为通过。M1已有完整CI构建/测试门槛，现推进M2独立Core切片。UI完整书库在M3，排版/主题在M4。

M2新源码：独立标题识别器、UTF-8有界流式扫描/卷章目录/Int64范围、严格跨块UTF-8校验与有界窗口读取，19个新增Swift回归。Windows367文件grammar/新诊断0/14项Python通过，CI38538141364/0643093首轮Linux/macOS各33 Core通过，iOS编译后40/41、0 skipped，旧EPUB首次打开等待位置超时；test exit65，Release未执行。首次原文/诊断已保留；同一源码只重试失败iOS job一次，attempt2全部success：各33 Core、41/41 iOS及设备Release/IPA。438运行源码hash及根/workspace/下载锁匹配，旧Build4用户包保持不动；首轮超时原因未确认，不宣称已修复。TXT新组件未接入导入阅读，不冒称TXT可用。Docker管道查询错误已保留，未启动/重置工具。见M2_TXT_INDEX_VALIDATION_REPORT.json、TXT_INDEX_DESIGN.md和HANDOFF。

[CI 38530334549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38530334549)，已测源码 `d62af3b7576a11a1b7318e029355ef1847710113`：Linux/macOS各14 Core、iOS41/41、0 failed/0 skipped，测试/附件/summary退出码均0，设备Release `CODE_SIGNING_ALLOWED=NO`与Build4 IPA成功。完整下载日志、原始xcresult、锁文件和433个运行源码Git blob SHA核验一致；没有继续修改运行源码或重复触发CI。源码编译warning/error=0，6条AppIntents metadata提示及WebKit运行诊断原样保留。

- 当前 `build/XianxiaReader.ipa` 是Build4，7,502,213 bytes，SHA256 `7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1`；CRC/iPhoneOS/arm64/0755/最低16.0/系统SQLite/第三方声明核验通过。
- `build/XianxiaReader-Continuous-Build4-TestKit.zip`：7,429,683 bytes，SHA256 `f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7`，四本原创样书与UTF-8说明，内部IPA hash一致。旧Build3原件保留在 `build/ci/38434939423/ipa/`，旧测试ZIP保留。
- 连续模式支持横排LTR重排EPUB：有限窗口最多12资源、章间物理滚动、加载/失败重试、字符与局部视口锚点、目录/搜索/书签和模式往返。双章/逆向、600点长段滑动后charOffset>100及重开误差<3px、图片高度变化、千资源回收、迟到termination、rAF桥受阻初始化均过自动回归。
- 历史CI边界PNG只显示第一章末尾与空白，原因未判定；其截图证据不完整仍保留。最新用户设备反馈已确认连续功能和重开位置可用，不再把旧PNG当设备功能失败；封面分页/章内滚动上下色带完整。未单独报告的逆向/惯性细项、完整手动模拟器阅读、峰值内存、普通设备和原书图像继续记录待确认。
- 证据见 `Documentation/M1_CONTINUOUS_VALIDATION_REPORT.json` 和 `Documentation/ValidationLogs/m1-continuous-build4-success.json`。用户要求自用、卡点参考成熟方案、微信读书交互、其余按原方案；原则已记入AGENTS及 `Documentation/MATURE_READER_REFERENCES.md`，未替换引擎或扩大阶段。

## 历史 Build3 证据（不代表当前包）

[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)（源码0b30d539d7eb6d557d8b5e5e8efad600c4c4435b）全部成功：Linux/macOS各14 Core、31 iOS tests、设备Release与Build3 IPA。源码compiler warnings=0；metadata提示另列。原创封面分页/滚动快照已人工查看，上下色带完整；用户原书与iOS16.6.1真机仍待复测。

- Windows结构/SQL/三本EPUB/42 Swift grammar通过（不是编译）；9 Python/tooling测试与bash -n通过。Linux/macOS Core各14，iOS实际31，结果范围分别记录。
- 新报告 `Documentation/M1_READER_VALIDATION_REPORT.json`：69个构建/验证来源hash匹配已测提交，11依赖pins不变，日志/IPA/快照hash。完整日志 `build/logs/ios-build.log`，原始日志/xcresult/快照/工程保留在 `build/ci/38434939423/ios/`。
- 历史 `build/ci/38434939423/ipa/XianxiaReader.ipa`：7,393,693 bytes；SHA-256 `12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2`，Build3/iPhoneOS/arm64/系统SQLite/0755/最低iOS16/ZIP核验通过，CODE_SIGNING_ALLOWED=NO。
- 测试ZIP `build/XianxiaReader-iPhone13-TestKit.zip`：7,296,582 bytes，包含IPA、三本原创EPUB和TESTING.txt，CRC与内部IPA hash一致。Build2及更早原件保留在对应run目录。
- 用户iPhone13/iOS16.6.1/TrollStore：安装正常、EPUB可以导入（用户报告，来源未细分）；原书图像窄横条。当前Build3安装/原书图片/完整阅读仍待复测；没有普通设备签名验收。
- remote compact恢复：本地main/6d76174和原暂存区保留，370文件ZIP已核验CRC/全部hash；候选codex/m1-continuous-recovery。此前各失败候选与完整日志保留在ValidationLogs及HANDOFF历史，不能将旧进行中状态当成当前结果；当前断点见上方Build4证据与HANDOFF。

## 失败历史与报告范围

Build3首轮38424689048 test bundle链接失败，第二轮38426725252导航探针超时，第三轮38430692977图片超限；原记录/完整日志保留在ValidationLogs与各run目录。修正后本轮全部通过，未删除测试/降低原图片断言/升级依赖。

M1_IMPORT_VALIDATION_REPORT.json属于Build2的26 tests；M1_SEARCH_VALIDATION_REPORT.json属于此前搜索；IOS_VALIDATION_REPORT.json属于M0；CORE_VALIDATION_REPORT.json是本机Linux；VALIDATION_REPORT.json仅静态。历史导入run38409222759由Agent提前取消，实际26iOS已通过、Release中断，不能写成源码失败。M0的SDK SQLite与缺AppIcon失败已在run38390862584修复验证。

Windows11/PowerShell7.6.5/Git2.54/Python3.11，本机无Xcode。GitHub origin/main已建立且CLI已授权；2026-10-14用户同意公开，API已确认PUBLIC，采用公开仓库标准runner免费构建，没有修改账单/支付/支出限额。最新连续CI已完成成功，无本项目进行中的验证任务。Docker曾恢复并升级4.95.0，原容器/备份保留；本轮未启动Docker。GitHub artifacts保留14天，忽略的build/.cache不随clone；过期后按锁文件重新CI。

## 下一步

M2 TXT导入/Readium阅读/完整字节文本位置与Build6首次文件交接已过自动门槛；先确认Build7设备首次TXT/EPUB选择，再验证TXT设备阅读、数十MB冷导入/cache重开与巨段边界，落实M2验收后再M3书库。已有Build4与用户书库保持不动。完整书库布局在M3、字体/主题/行距等在M4，百万字性能在M5；XBook知识库仅草案。其他设备细项继续单独记录，不将用户一句反馈扩大成完整矩阵。
