# 项目状态

更新时间：2026-10-14（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | 自动门槛通过 | 编译/Core/iOS/Release/真实IPA |
| M1 基础 EPUB | 完整自动门槛通过，用户确认连续阅读与重开位置可用；可继续既定路线 | 未逐项确认的原书图像、其他设备/旋转/性能继续单独记录 |
| M2 TXT | 两Core切片自动门槛通过；TXT产品接入源码已写入，完整CI验证中 | 待各68 Core/46 iOS/Build5 Release、长书与设备 |
| M3 完整书库 | 未开始 | 列表/编辑/封面/删除一致性 |
| M4 设置与主题 | 未开始 | 字体/排版/主题/亮度/音量键 |
| M5 性能 | 未开始 | 百万字/数千章基线 |

## 当前实际实现

- SwiftUI网格书库，封面/书名/作者/可用进度/最近阅读。
- EPUB Files多选副本导入、可见成功/失败；后台文件协调复制、Readium元数据/缩略封面、缓存TOC。原创EPUB2/3内置导入入口。
- Core的SQLite actor保存Book/Chapter/ReadingPosition/Bookmark，事务/导入恢复/路径和符号链接边界。位置保存完整版本化Locator，拒绝旧异步覆盖。
- ReadiumAdapter隔离引擎；分页、章内上下滚动、横向跨资源、中央菜单、目录/内部链接、书签、搜索/结果跳转、位置保存/恢复。关闭/重开过滤旧异步回调。
- ReaderSurface独立完整viewport、官方frame/autoresizing容器；横排重排媒体保护按实际innerHeight校准，固定/竖排保留原路径。目录/书签跳转后收起菜单；原创长短章/高封面样书和实际窗口回归。
- 安全SearchService扩展保留issue876回归；每批40、上下文64、UI最多1000；不跨文本元素/资源匹配，不收集全书结果。
- project.yml唯一工程源；两个Swift Packages；连续候选使用Readium3.11.0本地扩展及真实解析的6个远程pins（Build3历史为11 pins）；保留macOS完整CI和无签名IPA门槛。

## 最新证据与设备边界

TXT产品接入验证中：最新CI38558425326/1bb8f6cb660821160724643fb3646c52ba417463验证中，Linux68已通过，Apple/iOS46/Build5 Release待最终结果。前轮38555669042为44/46：TXT非零字符与截图通过但重开invalidPosition，核实连续路径selector丢字节ID，导致正文char误配短标题；已仅对显式TXT保留唯一CSS.escape字节ID并更新UPSTREAM hash、增真实paragraph byte断言，严格恢复校验保留。旧EPUB冷首开超时同轮重现，未宣称解决。四次真实失败与完整原件分别留档；原Build4不覆盖，新TXT产品源码/样书已接入，数十MB/缓存重开/设备仍未验收，完整M2未完成。报告M2_TXT_PRODUCT_VALIDATION_REPORT.json/设计TXT_READING_DESIGN.md。

M2编码/cache第二切片完整自动CI通过：[CI 38547339868](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38547339868)，运行源码 `65c1b8d6dbebf311c1e6b4b9534cda59373940b6`，Linux/macOS各60 Core（原33+新增27）、41/41既有iOS集成及设备Release CODE_SIGNING_ALLOWED=NO/IPA通过；445运行文件hash与当前源码匹配、三份锁一致。Windows372 grammar新增诊断0/14 tooling通过。支持严格UTF8/UTF16 LE/BE/GB18030分块转换、原/正规正文/目录SHA与编码/版本绑定cache。首轮Apple iconv两项四字节真实失败保留，现改用公开SDK CoreFoundation并通过同样及扩展向量；Linux保持glibc iconv，无新远程依赖。自动编码仅BOM/严格UTF8，其他要求选择；cache复用仍流式核验摘要，TXT导入/阅读/位置未接入，iOS真实TXT codec/导入/页面与设备未验收，完整M2尚未完成。当前Build4用户包保持不动，报告M2_TXT_NORMALIZATION_VALIDATION_REPORT.json。

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

M2 Core分章/窗口、编码/转码与内容版本cache已完整自动验证；接着推进受管理TXT导入、Readium阅读与完整字节/文本位置。已有Build4与用户书库保持不动。完整书库布局在M3、字体/主题/行距等在M4，百万字性能在M5；XBook知识库仅草案。其他设备细项继续单独记录，不将用户一句反馈扩大成完整矩阵。
