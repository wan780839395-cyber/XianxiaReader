# 真机阅读验收

## Build9 交付与Build8已确认范围

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。

Build9请正常更新，先核对既有UTF/GB18030/EPUB中段位置，再以自动模式冷首次导入中文ANSI/GBK；确认文字/目录/成功反馈及退出重开。Big5与1252分别手选，测试包三个新原创小样可直接复测。保留旧书库和原件，不删除数据库；编码歧义可以重新选编码导入，现有书原地修改编码界面尚未实现。设备型号/OS/实际安装Build未独立读取，不把Build8回复扩写成Build9或完整设备矩阵通过。


以下为历史阶段记录，当前范围以上述Build9与设备反馈为准。

## 当前设备与状态

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](PERFORMANCE_TEST_PLAN.md)。

2026-10-14最新用户确认：“ok 能正常导入了 没问题”。在Build7交付与软件首次导入问题复测的上下文中，记录首次导入正常；此次验收通过。具体格式/本地或iCloud/实际Build和OS未分别核读，不延伸为全矩阵。普通签名设备、TXT目录/搜索/书签/位置/旋转及数十MB长篇性能仍单列待验收；Build6失败及之前待确认记录保留为历史。证据m2-import-build7-device-feedback.json。

2026-10-14最新：用户报告Build6上下文首次导入仍无反应/提示，第二次可成功/报错，设备首次验收失败；实际安装Build/OS尚未独立读取。Build7随后通过CI38572197917（各68Core/55iOS/Release），新包build/XianxiaReader-Import-Build7-TestKit.zip / SHA5f280447e39b106cb096074a21d7d0a3954c8435a2131d4c038a8889309f4172。正常更新保留书库，+菜单确认0.0.1 (7)，完全退出重开后第一次选TXT，再重开第一次选EPUB，分别本地/已下载iCloud、取消/错误、旧书库。引用生命周期/无关闭事件/完整书架回归通过不代替真实Files/用户设备确认；M2完整设备/长书仍待验收。

2026-10-14 后续反馈：用户报告TXT可导入，但第一次选择后系统选择器关闭、书架无新增且无提示，之前EPUB也相同。Build6引用模型交接已通过CI38566503849（各68Core/49iOS/Release），新包build/XianxiaReader-Import-Build6-TestKit.zip / SHA 112113c0e939c5d8aabdc5ad2280c8faf77f3f1d9288145e902d8ec3cc4a815c。正常更新并保留书库，完全退出重开后首次选TXT，再重开首次选EPUB，分别测本地/已下载iCloud及取消后再选择。自动原生sheet回归提供fixture URL到delegate，不代替真实File Provider/iCloud/用户设备；首次设备故障的唯一根因仍未证实，待Build6实测。部分导入可用不等于完整TXT阅读/性能通过。

### TXT Build5准备（尚未设备验收）

2026-10-14 TXT Build5已过完整CI38559906005：各68 Core、46 iOS与设备Release。新测试包build/XianxiaReader-TXT-Build5-TestKit.zip，SHA256 7d547c7582230e35860e0b591bb51adcf51f988a20470ff421d8805c6d1ac668，含原生设备IPA与三个原创编码TXT/说明；原Build4原件保留。TrollStore正常更新，不卸载/删库；TXT实际设备尚未验收，自动CI不能写成设备通过。

Build5设备复测范围：内置原创TXT、UTF8/带BOM UTF16自动导入；GB18030明确编码选择/失败重试；取消/混合导入保留成功书籍；卷/章目录、长章窗口、搜索/书签与连续跨章；章中段关闭/重开、模式切换/旋转及中文标点/两字缩进/标题节奏。使用自己长篇TXT记录数十MB冷导入、cache重开时间与内存/卡顿。完整字体/主题仍在M4，不把基础样书CSS当全局排版完成。普通设备与TrollStore分别记录，用户Build4连续/重开已确认可用的原记录保持。

2026-10-14最新用户反馈：“这个功能可以了，重开位置也是正常的”，并要求按计划继续。按本聊天上下文记录Build4连续跨章与重开位置可用，来源为用户实测；设备背景仍为iPhone13/iOS16.6.1/TrollStore。未逐项报告的原书图片、旋转、普通签名设备和性能保持待验收，不把此反馈扩写为所有项目通过。

2026-10-14 当前反馈：iPhone 13、iOS 16.6.1、TrollStore。用户此前报告安装正常、iCloud 选中后“打开”无反应；导入修复后已明确确认 EPUB 可以导入（具体来源尚未细分）。阅读截图中图像只显示窄横条，并要求上下滑动无缝跨章。安装/导入用户报告不等于完整阅读验收；用户原书未提供，不提交截图中的个人书籍或文件列表。

最新可用包与构建 SHA/校验值见 HANDOFF 和对应 CI 验证报告。M0 包原件保存在 `build/ci/38390862584/ipa/XianxiaReader.ipa`；M1 包只在新 CI 通过、下载和核验后提供。请保留原有应用/书籍数据，使用 TrollStore 的正常安装/更新操作，不通过卸载或删除数据库解决阅读/升级问题。

最新候选测试包为Build4（CI38530334549/d62af3b，41/41 iOS、各14 Core、设备Release通过），IPA/ZIP已核验，旧Build3原件与测试包保留。新包 `build/XianxiaReader-Continuous-Build4-TestKit.zip` 含四本原创EPUB及UTF-8 TESTING.txt。在iPhone“文件”解压后分享内部IPA给TrollStore正常更新，保留书库数据。当前CI边界PNG只显示第一章末尾和空白，未完整显示第二章；原因未确认，优先在设备检查真实显示，不能凭自动断言写成体验通过。

## 阅读视口与图片复测

1. 更新后先打开此前显示窄横条的原书，分别核对分页、章内滚动、菜单隐藏/显示和横竖屏。记录原书图片是否完整。
2. 导入原创 `Tests/Fixtures/reader-layout.epub`（测试包 Samples 中提供）；封面图像上方绿色、下方米黄色，两条色带均应完整显示并保持比例。菜单开关不应将图像压成窄横条。
3. 从目录跳到第一章/第二章、点击章末内部链接；正文资源正确，成功跳转后收起菜单。章内模式的左右滑动/上一节/下一节可切资源。
4. 阅读菜单启用“上下连续滚动”，滑到第一章末尾，确认本章末尾与第二章开头同时出现；连续拖动、惯性和反向分别检查。Build4自动回归通过，但当前边界PNG不足以视觉验收；若空白/跳动，请记录所在位置与操作，保持数据不删除。固定布局/RTL/竖排不启用此候选能力。

## 导入与基础阅读回归

Build 2 的导入回归优先：更新后先点击“导入内置样书”（书架有书时使用 + 菜单），确认无需 File Provider 的真实导入和阅读；再导入“我的 iPhone”本地 EPUB；最后重试截图中的 iCloud 选中/打开流程。文件类型过滤放宽，TXT 等其他文件明确报错；不能把本地/内置成功写成 iCloud 通过。

使用项目原创 `Tests/Fixtures/chinese-epub2.epub`、`chinese-epub3.epub`，再使用自己合法持有的中文 EPUB。将测试文件放到 iPhone“文件”中，点击应用“导入 EPUB”。记录以下每项的实际结果：

1. 启动进入“藏书阁”；两个原创样书均成功导入，书名/作者/封面/目录正确。损坏文件明确失败，已有书籍保留。
2. 打开 EPUB2/3，观察中文标点、段落、标题、图片；点击左右翻页、滑动翻页、中央隐藏/显示菜单。正文和链接不能被不可见控件阻挡。
3. 从“目录”跳转两章，点击正文末尾“前往另一章”，确认 fragment 链接定位和返回后的菜单正常。
4. 搜索“修行”：逐批加载最终 80 个正文命中，章节标题和片段可读；点击第二章的结果应定位到该段。搜索不存在关键词明确显示无结果。
5. 连续改词/停止/关闭搜索并重新打开，旧结果不能混入新查询；点击结果后搜索页关闭、正文可继续操作。
6. 添加书签并跳转；切换分页/上下滚动，测试竖屏与横屏。记录是否丢失当前段落或遮挡正文。
7. 停留在章中段，返回书库，再打开；切后台再返回；正常关闭再重启应用。确认位置和书架进度恢复。
8. 用真实长篇 EPUB 验证目录缓存、搜索首次结果、停止操作与持续翻页；记录卡顿/异常。M5 性能指标不在此提前标通过。

## 记录模板

| 项目 | 当前 |
| --- | --- |
| 设备/iOS/安装方式 | iPhone 13 / 16.6.1 / TrollStore（用户确认） |
| 安装结果 | 先前安装正常；本次用户确认连续/重开功能可用，按上下文对应Build4，未独立读取Build号 |
| 构建 SHA / IPA hash | 使用实际测试包填写 |
| EPUB 样本 hash / 文件来源 | 待填写，不上传个人小说到 Git |
| EPUB 导入总体 | 用户确认已经可以导入；来源未细分 |
| 内置样书 / 本机 / iCloud 各来源 | 仍需分别记录；旧 iCloud“打开”失败历史保留 |
| 目录 / 图片 / 内部链接 | 旧原书图像窄横条；Build4原书及目录/链接设备待复测 |
| 真正纵向无缝跨章 | Build4自动CI通过，用户本次确认功能可用；逆向/惯性未单独量化，不以旧CI PNG否定用户实测 |
| 点击 / 手势 / 分页 / 滚动 / 旋转 | 待测试 |
| 搜索 / 结果定位 / 取消 / 无结果 | 待测试 |
| 书签 / 后台 / 重启位置恢复 | 用户确认重开位置正常；书签/后台其他动作未逐项确认 |
| 问题复现步骤 / 页面截图 | 当前图片裁切；原书 CSS/资源未取得，不能认定唯一原因；不提交用户截图 |

测试失败时保留现有数据、记录操作与具体提示。普通设备签名安装与 TrollStore 结果分开；本表不将模拟器 XCTest 或用户“已安装巨魔”视为应用验收。
