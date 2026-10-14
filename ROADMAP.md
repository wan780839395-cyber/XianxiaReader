# 开发路线与阶段门槛

所有状态以 PROJECT_STATUS.md 和真实验证结果为准。前一 milestone 未通过构建与测试前，不大规模推进下一阶段；Windows 可提前准备必要源码，但不得绕过验收门槛。

| 版本 | Milestone | 交付与门槛 |
| --- | --- | --- |
| V0.0.x | M0 项目结构与技术验证 | 工程可生成；Core 测试通过；Readium 2/3 元数据与 Navigator 集成测试通过；Release 设备构建及 unsigned IPA artifact；无隐藏失败 |
| V0.1 | M1 基础 EPUB 阅读器 | 导入/封面/TOC/分页/滚动/内部链接/图像/CSS；搜索；位置恢复；基础书签；中文 EPUB 2/3 与重排样书模拟器及真机验收 |
| V0.2 | M2 TXT 与分章 | 编码识别/转码、独立识别器、流式索引、章节缓存、按章阅读、取消/失败恢复；八类标题规则及跨块回归；数十 MB 冷导入与缓存重开 |
| V0.3 | M3 完整书库 | 网格/列表、删除、改名、改封面、最近阅读与进度；文件/数据库一致性、重复导入策略与中断恢复 |
| V0.4 | M4 设置与主题 | 字体及导入、字号/字重/行距/段距/四边距/两字缩进/对齐/亮度/翻页；五种主题；设置持久化；音量键翻页技术验证与设备验收 |
| V0.5 | M5 性能与长篇验证 | 100/300/500 万字、1000/3000+章样本；导入/阅读/重开/目录/搜索的耗时、内存、卡顿、耗电基线；修复瓶颈 |
| V0.6–0.8 | MVP 稳定化 | 无障碍、iPad/横竖屏、导入 File Provider、升级迁移、书签/位置恢复、异常和设备矩阵；Readium 高亮/TTS 的独立增量阶段 |
| V0.9 | 发布候选 | 签名发行流程、隐私/第三方许可核对、长时间阅读及升级回归；普通设备与 TrollStore 测试分别记录 |
| V1.0 | 稳定阅读器 | EPUB/TXT MVP 功能全部验收，文档/数据迁移/性能门槛落实；XBook 与知识库继续作为后续独立版本 |

## M0 当前切片

2026-10-13 已通过 M0 自动门槛（run 38390862584）；详情见 Documentation/M0_ACCEPTANCE.md。下一阶段 M1，真实页面/设备验收仍待完成。

完成源码结构、工程定义、CI、独立模型/repository/引擎接口、基础 EPUB 导入和 Reader、最基本测试。它包含 M1 所需的技术验证切片，不代表整个 M1 已通过。

M0 放行证据必须包括：完整 build log、Core 测试结果、iOS tests `.xcresult`、设备构建与生成 IPA 的 hash。CI 通过仍不能替代 M1 的真实阅读体验验收。

## M1 验收清单

2026-10-14恢复结果：CI38530334549/d62af3b完整成功，Linux/macOS各14 Core、41/41 iOS、设备Release/Build4 IPA及测试包已核验，433个运行源码hash一致。用户随后确认连续功能/重开位置正常并授权按计划继续，现开始M2 Core切片。CI边界PNG证据不完整仍保留，未单独确认的其他设备细项/原书图像/性能继续记录，不扩写为完整矩阵。新阶段见下方M2及HANDOFF。

历史Build3：[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)（源码0b30d539d7eb6d557d8b5e5e8efad600c4c4435b）各14 Core、31 iOS及设备Release成功，原创封面上下色带完整。它仅支持章内滚动与横向资源切换；连续候选的最新证据以上方Build4为准。该历史节点当时尚未完成设备验收；最新用户连续/重开反馈与当前M2断点以上方记录为准。详情Documentation/READER_VIEWPORT_FIX.md / DEVICE_ACCEPTANCE.md。

- EPUB 2 NCX / EPUB 3 nav、nested TOC、图片、CSS、fragment 链接与脚注；损坏文件和 DRM 错误可解释。
- Files 本地/iCloud 导入；取消、批次部分失败、后台/退出恢复不丢已提交书籍。
- 搜索增量结果及跳转；不能一次读取全书到主线程。
- 首次位置回调、关页/后台/重启恢复，含章节中段与链接 fragment；旋转和分页/滚动转换后恢复。
- 中心菜单、两侧翻页、手势、目录与书签；不同字号、VoiceOver、横竖屏下不遮正文。
- 用户要求的真正纵向连续跨章：章末/下一章能同时显示、保留拖动与惯性；有限资源窗口、逆向滚动、图片高度变化、原始 Locator 恢复。作为独立 M1 引擎切片执行，不能把现有章内滚动标为完成。见 Documentation/CONTINUOUS_SCROLL_DESIGN.md。
- 真机体验记录及关键截图/录屏；不能把“构造了 Navigator”当成排版已验证。

## M2 识别回归

2026-10-14用户确认Build4连续功能与重开位置正常，并授权按计划继续；结合M1完整CI构建/测试通过，M2 Core分章/有界读取第一切片现已通过38538141364/0643093的完整验证：attempt2各33 Core、41 iOS及设备Release。首轮旧EPUB冷启动超时原文保留，原因未确认；不把同源重试通过写成已修复。随后编码/cache第二Core切片已通过CI38547339868/65c1b8d：各60 Core、41 iOS及设备Release；首轮Apple iconv失败保留，更换公开SDK CoreFoundation后原/扩展向量通过。TXT产品导入/Readium阅读/完整位置随后通过CI38559906005/37eb86a各68 Core、46 iOS及Build5 Release；设备TXT与数十MB冷导入/cache重开尚未验收，详见TXT_READING_DESIGN.md。M1未逐项确认的设备细项保持独立记录；M3完整书库、M4排版/主题顺序不变。

必须覆盖 `第一章`、`第一百二十三章`、`第123章`、`第 123 章`、`第一卷`、`卷一`、`正文 第一章`、`Chapter 1`；还需超长章节名、空行/BOM/CRLF、分隔符、跨 chunk、正文中的同样短语、无章节等反例。

卷是分组而非重复正文边界；Chapter 的稳定身份和阅读位置不能随重新索引随意变化。编码检测不确定时必须可由用户更正，不能用不可逆乱码文本覆盖原件。

## M4 排版要求

默认双中文字符首行缩进、合理中文标点换行/行距/字间距/段距、独立章节标题与明确章节分隔。Readium Preferences 优先实现；额外 CSS 必须局部且尊重 EPUB 结构，禁止重写整本正文。

主题至少日间白色、暖白、羊皮纸/米黄、深灰、OLED 黑。深色主题使用柔和浅色正文，不使用刺眼纯白大面积正文。自定义字体存入本地受管理资产，按书/全局设置明确优先级。

音量键翻页需先验证公开 API、系统音量与音频行为，分别记录普通设备/TrollStore。若 API 无法稳定实现，先记录证据与产品取舍，不使用私有 API 偷渡实现，也不宣称完成。

## 长期维护节奏

每个可恢复子步骤及长构建前更新 HANDOFF；每个阶段后更新状态和验证证据。依赖升级独立处理，锁定版本与 migration 一起审阅。编译失败优先修复具体 API/类型/工程问题，保留原功能和失败日志。

2026-10-14首次文件交接增量：Build6 / [CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849)各68 Core、49 iOS及设备Release通过，EPUB/TXT共用引用模型结果交接；新增原生sheet首次/取消/空选择/重试回归。旧交接未在iOS18.5复现用户iOS16.6.1现象，设备首次导入仍待实测，M2长书/设备未完成。新包build/XianxiaReader-Import-Build6-TestKit.zip；旧Build4/5不变。详见Documentation/IMPORT_HANDOFF_FIX.md与HANDOFF。

2026-10-14后续首次导入：用户否定Build6设备首次体验；最新Build7 / [CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917)各68Core/55iOS/Release通过，直接从delegate启动导入、保持关闭后的delegate、统一sheet/持久错误反馈；完整书架/无dismiss/弱回调与原生命周期回归保留。新包build/XianxiaReader-Import-Build7-TestKit.zip，旧4/5/6均保留。用户设备首次选择仍待确认，M2长书/设备及M3/M4门槛不变；详见IMPORT_DELEGATE_FIX.md与HANDOFF。
