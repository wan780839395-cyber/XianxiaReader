# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

### 2026-10-14 用户实测与M2开始检查点

用户明确反馈“这个功能可以了，重开位置也是正常的”，并授权按计划继续。结合上一条上下文，记录为Build4连续跨章与重开位置的用户设备功能验收；沿用已知iPhone13/iOS16.6.1/TrollStore背景，不扩写为旋转、普通签名设备、原书图像或峰值内存全部通过。此前CI边界PNG缺第二章仍保留历史，不再把它当用户设备功能未通过的阻塞。

M1自动构建/41项iOS及用户本次核心功能反馈已满足继续开发的依据；M2从独立Core组件切片开始。UI阶段答复：当前基础界面，完整书库布局/编辑在M3；字体、字号、行距、边距、主题和亮度在M4。用户没有要求跳到M4或替换Readium。

下一可恢复步骤：实现UTF-8正规正文的独立标题识别器、跨块/长行/CRLF/BOM流式扫描、卷章分组/序章及64位end-exclusive范围、有界章节窗口读取，并新增真实Swift回归。此切片不冒称完整TXT支持；编码自动检测/UTF16与GB18030转码、版本化内容缓存、导入与阅读接入随后完成。先核对现有协议/Chapter模型，再实现、Windows检查、真实Core/macOS/iOS CI；任何未编译源码都明确标记。main/原index与旧Build4保持不动。

测试前检查点：四个Core TXT实现文件和TXTIndexTests.swift已写入，尚未Swift编译。标题参考Readest中文规则的卷/章差异与中文数字范围，使用独立实现；候选line缓存上限512字节、chunk/正文窗口上限256KiB，严格UTF-8、不覆盖原书，卷不重复正文。新增回归覆盖八类标题/反例、1字节分块、多字节/CRLF/BOM、卷序/重复ID、长行/损坏/取消、窗口边界及>4GiB稀疏偏移。现在运行Windows结构/语法与tooling检查，并只读查询Docker是否可用于锁定Swift容器；不可用则记录实际错误、继续真实CI，不启动/重置用户工具。

**Build4连续/重开位置已由用户确认；当前进入M2 Core切片，准备真实编译。** 上方M2检查点覆盖旧“下一步设备测试”的断点，下方M1证据/待确认的其他设备项目保留。

M2构建前检查点：Windows367文件grammar（pristine54限制/新增0）和14项Python tooling已通过，git diff --check通过；Docker查询exit1，dockerDesktopLinuxEngine管道不存在，命令已退出，未启动/重置用户工具。Core预期33项（14旧+19新），iOS保留原41项。将独立index快照推送codex/m2-txt-index并运行现有完整CI，bootstrap=false；读取实际run/head后记录，不重复启动或把未编译代码标为已验收。已有Build4/旧测试包不覆盖。

- CI [38530334549](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38530334549)，已测运行源码 `d62af3b7576a11a1b7318e029355ef1847710113`，三个job completed/success，bootstrap=false。
- Linux/macOS各14 Core、iOS41 passed/0 failed/0 skipped，测试/附件导出/summary退出码均0；设备Release `CODE_SIGNING_ALLOWED=NO`与IPA成功。
- 下载原始日志/summary/xcresult/工程/锁/IPA；433个运行源码Git blob SHA与当前工作文件匹配，根锁/下载锁/workspace锁逐字节一致。本轮只更新文档/证据，不再追加运行代码补丁或重复CI。源码编译warning/error=0，6条AppIntents metadata提示及WebKit运行诊断原样保留。
- 当前无本项目进行中的CI或gh/python/swift/docker任务；其他项目node进程未修改。文档快照可在候选分支d62之后，不能把文档commit当成另一版已测试源码；恢复时查Git实际ref。

## 用户最新开发原则

用户用于自用，希望尽快实际能用。遇到陌生问题/反复失败，先参考官方文档与成熟实现，核对适用版本和差异再改，不持续盲补。微信读书是交互参考，其余按既定方案走。已写入AGENTS.md；本轮审阅epub.js连续窗口、Foliate Range锚点与Readium PR811，固定来源/取舍见 `Documentation/MATURE_READER_REFERENCES.md`。未换引擎、未升级依赖或扩展下一阶段。

## 已实现与验证边界

Readium3.11.0/d82f44f本地扩展，UI经ReadingInterfaces，Core保持Foundation/SQLite。最多12资源窗口、固定WK视口、实际章节高度、加载边界/重试、前后回收；完整Locator+字符/版本化局部视口锚点，64字符上下文。fixed/RTL/竖排保留原路径；搜索保留issue876扩展。

标准定位与DOMscrollY同次JS执行，保存位置原子采集Locator/documentY/documentTop，不一致最多采样3次；过滤epoch/revision/旧slot。公开didFinish探针启动同一完整初始化管线，清理取消任务、断开delegate并释放等待链。自动回归含双章/逆向窗口、fragment/书签、图片高度、失败重试、600点长段滑动后charOffset>100/重开误差<3px、搜索/模式往返、千资源回收、迟到termination及rAF桥暂停。

**当前边界PNG只显示第一章末尾和空白，未显示第二章标题，已查看并记录，原因未判定。** DOM/可见窗口测试通过不能等同于视觉通过，不推断只是截图管线问题。分页/章内滚动封面上下色带完整。手动模拟器阅读、原生拖动/惯性、峰值内存、普通设备、iPhone13/iOS16.6.1/TrollStore和原书仍待验收。

## 产物

- `build/XianxiaReader.ipa`：Build4/0.0.1，7502213 bytes，SHA256 `7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1`。ZIP CRC、iPhoneOS/arm64、最低16.0、0755、系统SQLite及第三方声明通过；不冒充普通签名安装包。
- `build/XianxiaReader-Continuous-Build4-TestKit.zip`：7429683 bytes，SHA256 `f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7`，四本原创EPUB、UTF-8说明、CRC/内部IPA hash通过。
- 原件：`build/ci/38530334549/artifacts/XianxiaReader-unsigned-ipa/XianxiaReader.ipa`；诊断位于同run的 `XianxiaReader-build-diagnostics/build/`，完整Actions日志 `build/ci/38530334549/full.log`。
- 旧Build3原件 `build/ci/38434939423/ipa/XianxiaReader.ipa`（12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2）保留，旧 `build/XianxiaReader-iPhone13-TestKit.zip`/更早包未覆盖。

## Git与恢复保障

本地仍main/HEAD `6d761749911233122bcd031fcf718d22a19f9e77`，原index为空，所有原未提交改动保留；候选分支codex/m1-continuous-recovery通过独立临时index快照/正常push，不reset/stash/删库/改原书。原370文件备份 `.cache/recovery/20261014-092934/` 已核验CRC/全部SHA；历史交接和所有失败原文保留在HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md与ValidationLogs，旧candidate.json/documentation-snapshot.json不代表最新ref。

Package.resolved来自真实解析38496501326，6远程pins版本/revision不变，resolve/test/build严格用根锁；不要重新bootstrap或伪造锁。运行源码以成功报告433个Git blob SHA为准，FILE_INVENTORY用于当前文档/文件恢复，不把新增文档hash说成已编译。

## 检查点与接下来的工作

本轮文档同步后Windows结构/来源/锁文件/SQL/四本EPUB检查通过；362文件Swift grammar（pristine54限制/新增0）及14项Python tooling全部通过，git diff --check通过。静态不等于编译，iOS编译/Release证据仍只绑定d62/38530334549。当前证据与FILE_INVENTORY同步后，通过独立index保存/推送文档快照至候选分支；运行源码不变，不触发重复CI，main/原index继续保留。

1. 使用Build4测试ZIP在现有TrollStore应用正常更新，保留数据、不卸载/删库。菜单启用“上下连续滚动”，核对reader-layout章末/下一章同屏、反向、拖动与惯性；长段中部书签、重开/后台、分页↔连续、目录/搜索/链接及原书图像分别记录。
2. 若出现空白/跳动/位置漂移，先记录实际步骤、章节/位置与最小复现，对照成熟窗口/锚点实现后选择修改；不增加无限等待、不降低断言。未取得新证据不重复跑同一源码CI。
3. 普通设备与TrollStore、自动CI与手动阅读分开；M1尚未完整放行，不大规模进入M2/M4。TXT、完整书库编辑、字体/主题/音量键、百万字性能及XBook知识库仍未实现。
4. 恢复先AGENTS→PROJECT_STATUS→本文件→ROADMAP→ARCHITECTURE，再核对Git、文件、日志、任务，阶段结束同步文档；不要把旧进行中/失败状态覆盖最新成功。

## 环境与公开

Windows/PowerShell/Git/Python可用，无本机Xcode。用户已授权GitHub公开，API PUBLIC，公开标准Ubuntu/macOS runner已成功执行，未修改付款/支出限额；旧账单拒绝仅历史。本轮未启动/重置Docker或localhost。GitHub artifacts保留14天，忽略build/.cache不随clone，过期后按锁重新完整CI。证据见M1_CONTINUOUS_VALIDATION_REPORT.json及ValidationLogs/m1-continuous-build4-success.json。
