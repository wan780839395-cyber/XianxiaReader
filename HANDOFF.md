# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

**连续候选完整自动CI成功，Build4测试包已核验；下一步是实际阅读/设备验收，完整M1未放行。**

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
