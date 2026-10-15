# 功能矩阵（2026-10-15）

当前Build16：原生阅读菜单/外观与排版分组、灰绿浅深色面板、触控尺寸与留白打磨；五主题及既有排版/全局保存继续保留。完整CI各115Core/iOS93/Release16与原生图/视频复核完成，手机待测；M4整体仍未完。安装`build/XianxiaReader-ReadingUI-Build16.ipa`，测试ZIP`build/XianxiaReader-ReadingUI-Build16-TestKit.zip`附原创样本和6张本轮原生Preview。设计READING_UI_DESIGN.md，验证M4_POLISH_VALIDATION_REPORT.json。以下旧切片为历史。

当前Build15：M4第一片五主题/基础排版/全局保存完整自动门槛与原生设置图/视频复核完成，巨段TXT截图下方留白原因未确认，满页/手机待测，M4整体未完。M3基本自用已收口；以下旧切片保留历史。

当前Build14：重复导入完整自动门槛及原生图/视频通过，用户基本自用反馈正常，M3按自用门槛收口，M4尚未开始。schema3升级保留全部原书与历史。以下旧切片保留历史。

Build13历史封面替换节点：各100Core/79iOS/Release及原生图/录屏复核通过，手机选图和观感待确认；Build12观感用户接受。重复导入仍后续M3。以下旧切片文字保留历史。

Build12历史节点：原生列表左滑、网格/恢复/布局短过渡与Reduce Motion，91Core/70iOS/Release及六图/录屏连续帧通过；手机流畅度待确认。Build11回收站/恢复已获用户自用确认，具体其他设备矩阵单列。

Build11回收站/恢复切片已获用户自用确认；Build10浏览/改名及更早阶段的历史门槛继续保留。其他设备范围分别记录。

Build10书库浏览/改名切片CI38666201246已通过Linux/macOS各85 Core、63 iOS和无签名设备Release，真实IPA/测试包及四张原生书库图已核验；用户随后反馈基本自用正常，具体设备矩阵不扩写，M3未全部完成。用户已确认既有连续阅读/重开、首次导入和Build8长TXT基本工作流；Build9后的反馈仅按基本自用范围记录，不扩写其他设备、逐个编码或性能。“计划”表示未实现，历史验证原件保留。

| 能力 | 当前 | 阶段 |
| --- | --- | --- |
| Files / Document Picker EPUB 多选导入 | 已写入；副本模式修复过 CI，用户确认 EPUB 可导入，来源未细分 | M0/M1 |
| 原创内置 EPUB 2/3 样书入口 | 已写入；同一导入流程的模拟器测试通过，设备阅读待验收 | M1 |
| EPUB 元数据、封面缩略图/标题占位封面 | 已写入 | M0/M1 |
| 网格/列表书架、书名/作者筛选、最近阅读/导入/书名排序与偏好 | Build10完整自动门槛及原生四图通过，用户基本自用接受；其他设备矩阵单列 | M3 |
| 修改书名、保留原件/完整位置/书签、写入错误可见 | Build10真实SQLite事务及App持久化/重叠刷新回归通过，用户基本自用接受；逐项矩阵未扩写 | M3 |
| 可恢复移出书架、回收站/恢复、v1→v2升级与启动文件保留 | Build11各91Core/67iOS/Release与原生三图通过，用户确认可用；原件永久保留，不释放存储 | M3 |
| 原生列表左滑确认、网格移出/恢复/排序/切换动效、Reduce Motion | Build12完整自动门槛/真实手势/六图及录屏连续帧通过，手机流畅度待测 | M3 |
| 封面选择/预览/保存/恢复默认、后台缩略缓存/失败重试 | Build13完整自动门槛及原生图/录屏通过；手机相册/Files/观感待测，旧图不自动回收 | M3 |
| 原件精确去重、TXT解码身份、旧库指纹补齐、并发提交、回收站显式恢复 | Build14各110Core/84iOS/Release与原生图/录屏通过；基本自用确认 | M3 |
| EPUB 2/3、reflowable | 原创样书解析/目录测试通过；真实排版体验待验收 | M1 |
| TOC、分页、章内上下滚动、章节跳转 | 已写入；跨资源及viewport回归通过，设备待复测 | M0/M1 |
| 真正纵向连续跨章 | Build4完整自动CI41/41，用户确认连续功能与重开位置可用；未单独报告的设备细项继续记录 | M1 |
| 内部链接、图片、CSS | Readium 排版；Build 3 视口修复与原创图像回归，用户原书图片待复测 | M1 |
| 搜索和结果跳转 | Readium SearchService 扩展、增量/取消/上限 UI 与 11 新回归已过真实 CI；页面命中定位待验收 | M1 |
| 位置保存/恢复 | 完整 Locator 持久化；Build4用户确认重开位置正常，其他设备细项待验收 | M0/M1 |
| 中央菜单、两侧点击翻页、手势分页 | 已写入；手势使用 Readium | M1 |
| 阅读进度/当前章节 | 已写入（未知进度不伪装为 0%） | M1 |
| 总章节数 | 当前仅报告目录条目；TXT canonical 章数在 M2 | M1/M2 |
| 书签添加/跳转/删除 | 已写入 | M1 |
| TXT 导入/正文阅读 | Build5已接入并过CI38559906005：编码选择/重试/取消、有界Readium资源/目录/书签/搜索/完整位置；设备/长书仍待验收 | M2 |
| TXT长篇/巨章/Apple临时内存 | Build8各68Core/56iOS/Release；四Release样本/hash/全窗口覆盖，第二窗口600点/3px重开；Apple RSS实测下降，设备性能待验收 | M2 |
| TXT UTF8/UTF16/GB18030、摘要与版本cache | 第二Core切片完整CI38547339868通过各60 Core/41 iOS/Release；首轮Apple iconv失败保留，更换公开CoreFoundation后向量通过；cache复用仍流式计算摘要 | M2 |
| TXT中文ANSI/GBK、Big5/CP950、Windows-1252与范围cache | Build9各80 Core/58 iOS/Release，Build10完整回归保持；GBK自动、Big5/1252手选，旧位置身份保持；缓存仍全文digest，不称手机秒开 | M2 |
| 八种标题识别、streaming、chunk、窗口 | 新增19项在各33 Core内通过，完整CI38538141364 attempt2为41/41 iOS及Release；首轮EPUB超时留档 | M2 |
| 内置通用字体/字号、字体导入/字重 | Build15通用字体与字号自动门槛通过，手机待测；导入/字重未做 | M4 |
| 行距/段距/边距/缩进/对齐/字间距 | Build15行距/段距/左右留白/缩进/对齐通过；独立四边距/字距未做 | M4 |
| 页面亮度、翻页方式持久化 | 计划；当前只有分页/滚动会话切换 | M4 |
| 五种阅读主题 | Build15五主题、全局持久化、实际TXT/EPUB回归与原生图/视频通过；手机待测 | M4 |
| 默认中文实体书排版 | Build15默认两字缩进/1.75行高/0.8rem段距/柔和深色；实际页面过自动回归，手机体验待测 | M4 |
| 音量键翻页 | 未实现，先公开 API 可行性验证 | M4 |
| 百万字/数千章性能 | 有存储/索引边界；无实测 | M5 |
| Highlight/Note | 领域扩展设计；未建运行实体 | V0.6+ |
| Readium Decorations/TTS | 适配层可扩展；未接入产品 | V0.6+ |
| XBook、人物等知识、地图和剧情摘要 | 仅草案；不接受导入 | V1.0 后 |

基础 EPUB 和架构切片不能代替产品需求中的完整阶段一 MVP。必须完成 M1–M5 与稳定化验收后才可称“真正可用且稳定”。

2026-10-14首次文件交接增量：Build6 / [CI38566503849](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38566503849)各68 Core、49 iOS及设备Release通过，EPUB/TXT共用引用模型结果交接；新增原生sheet首次/取消/空选择/重试回归。旧交接未在iOS18.5复现用户iOS16.6.1现象，设备首次导入仍待实测，M2长书/设备未完成。新包build/XianxiaReader-Import-Build6-TestKit.zip；旧Build4/5不变。详见Documentation/IMPORT_HANDOFF_FIX.md与HANDOFF。

2026-10-14后续首次导入：用户否定Build6设备首次体验；最新Build7 / [CI38572197917](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38572197917)各68Core/55iOS/Release通过，直接从delegate启动导入、保持关闭后的delegate、统一sheet/持久错误反馈；完整书架/无dismiss/弱回调与原生命周期回归保留。新包build/XianxiaReader-Import-Build7-TestKit.zip，旧4/5/6均保留。用户随后确认首次导入正常，M2长书/设备及M3/M4门槛不变；详见IMPORT_DELEGATE_FIX.md与HANDOFF。

2026-10-14用户验收补充：Build7交付后回复“ok 能正常导入了 没问题”，首次导入问题已确认解决，deviceFirstImportAccepted=true；源码/安装包未变。格式/文件来源未逐项报告，完整M2长书/设备及M3/M4门槛不变；证据Documentation/ValidationLogs/m2-import-build7-device-feedback.json。
