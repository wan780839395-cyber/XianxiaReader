# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 实际断点

### 编码与cache第二切片开始（覆盖下方旧断点）

2026-10-14用户要求继续，已核对main/原空index、M2 ref e779b82与真实38538141364 attempt2 success，当前没有自己启动的挂起任务。下一步实现有界编码正规化（UTF-8/UTF16 LE/BE/GB18030）、流式SHA256、版本化cache与完整TXTIndexing facade；先独立Core验证，再接产品导入/Readium阅读。遇到不确定编码明确选择，不做猜测替换原件；GB18030复用Apple/Linux公开iconv系统实现，不引入第三方编码表或全书String。

当前尚未写入/编译第二切片；准备内部C系统codec桥（Apple SDK libiconv/Linux glibc）与独立增量摘要，以跨平台真实向量测试验证。cache路径全部经BookFileStore逐节点校验，manifest只存相对路径，损坏/版本失配重建，提交前保持旧cache与原书。构建前更新本文件，保留Build4包与全部原未提交改动。

测试前检查点：编码/摘要/cache源码已写入，尚未Swift/C编译。UTF-8/UTF16 LE/BE严格有界转换，GB18030采用公开iconv桥，BOM不一致/损坏/截断/NUL拒绝；新sidecar成功后提交，失败删除本次临时文件并保留原始错误。增量SHA256已配独立已知向量；cache绑定原/normalized/目录摘要、编码与版本，仅相对路径，所有节点校验，生成后原子发布manifest，旧cache保留。新回归覆盖小chunk、GB四字节、源同长度改变、损坏cache/manifest、版本失配、越界/符号链接、取消与facade。现在运行Windows检查，再保存源快照到M2分支/完整CI；编码自动检测仅BOM/严格UTF8，其他要求选择，cache lookup仍流式校验摘要并未承诺快速元数据重开。

**M2 Core UTF-8分章/窗口第一切片完整自动CI通过；下一步编码正规化/cache与TXT导入阅读。**

CI38538141364，运行源码0643093d32fdc9801cba34671d9eba3d1eb35de4，codex/m2-txt-index，bootstrap=false。attempt1：Linux/macOS各33 Core（含19项TXT）通过、iOS编译后40/41/0 skipped，旧EPUB首次打开等位置超时，exit65，Release未执行。完整日志/summary/xcresult/超时后slot诊断保留；不能从clear后的blank推断加载前根因。App/Reading/Vendor/iOS测试与已测d62无变更。

仅重试同源码失败iOS job一次，**attempt2全部success：Linux/macOS各33 Core、41/41 iOS、0 failed/skipped，test/export/summary退出码全0，设备Release CODE_SIGNING_ALLOWED=NO与IPA成功。** 原首轮失败未覆盖，根因未确认，不能宣称冷启动问题已修复。当前无进行中的CI或自己启动的挂起工具。

全部438运行源码Git blob SHA与当前工作文件核验一致；根锁/下载锁/workspace锁逐字节一致。Windows367 grammar（pristine54限制/新增0）与14项tooling通过；源码编译warning=0，metadata/WebKit诊断原样保留。报告Documentation/M2_TXT_INDEX_VALIDATION_REPORT.json；成功/首轮失败分别在ValidationLogs/m2-txt-index-first-slice-success.json及m2-txt-index-attempt1-ios-load-timeout.json。

原始attempt1：build/ci/38538141364/attempt-1.full.log、attempt-1.run.json及artifacts/XianxiaReader-build-diagnostics/build；attempt2：build/ci/38538141364/attempt-2/full.log、run.json及artifacts；Linux33原件在同run的core目录。新CI IPA仅归档到attempt-2/artifacts/XianxiaReader-unsigned-ipa，7540025 bytes/SHA256 aae8e360ae2946761d2a0b1db31ef3fd0b096dc5b69537d57f5c16332a37b163，Build4/arm64/iPhoneOS/最低16.0/0755/系统SQLite/第三方声明/CRC已核验。TXT入口未接入，不提供相同UI的新测试包，用户7983e6bc...原包保持不动。

后续文档快照可在0643093之后，运行源码以438个已测hash为准，不把文档commit当另一版编译；main/原index/未提交改动保持原样。

## 用户实测、阶段推进与UI

用户确认“这个功能可以了，重开位置也是正常的”，要求按既定方案继续；据前文记录Build4连续跨章/重开位置可用。已知设备背景iPhone13/iOS16.6.1/TrollStore，未独立重读Build号/设备状态；不扩写为旋转、原书图像、所有逆向/惯性/普通签名设备和性能全通过。证据ValidationLogs/m1-build4-user-feedback.json。

M1完整CI38530334549/d62af3b：Linux/macOS各14 Core、41/41 iOS、设备Release/Build4 IPA成功，原始日志/xcresult/锁/433运行源码hash已核验。真实构建/测试加本次用户核心功能反馈支持按计划进入M2，其他设备项目单独留待记录。旧CI边界PNG缺第二章为历史截图证据限制，不否定用户实测，不继续无依据补同一竞态。

当前基础书架/阅读操作已存在；完整书库布局/编辑在M3，字号/字体/行距/边距/五种主题/亮度等在M4。用户没有要求跳到M4或换引擎。卡点先查成熟方案，微信读书交互目标、其余按原路线；AGENTS与MATURE_READER_REFERENCES.md保留此原则。

## M2已实现的独立Core组件

- TXTChapterHeadingRecognizer：八类标题、中文/全角数字、序章/卷、英文Chapter 1/chapter.844、整行/长度/量词反例。参考Readest边界原则、独立实现，固定来源见TXT_INDEX_DESIGN.md。
- TXTUTF8ChapterScanner：actor有界FileHandle读取（默认64KiB/上限256KiB），严格UTF-8、CRLF/BOM/末行/跨1字节chunk；长行只保留最多512字节标题候选，其余仍校验。卷为无正文分组，前言/卷序不丢失，叶子Int64/end-exclusive范围连续覆盖正文，重复标题ID稳定。
- TXTChapterWindowReader：actor按当前叶子范围读最多256KiB，不越章；只返回完整UTF-8字符，检查局部锚点/实际文件长度/取消。>4GiB稀疏偏移真实读取回归通过，不等于长篇性能验收。
- TXTUTF8Stream：严格Unicode标量校验，拒绝overlong/surrogate/截断，不做替换字符；文件关闭保留原始读取/取消失败。
- TXTIndexTests：19项新增Swift回归，Linux已通过；Core仍只依赖Foundation/SQLite，无Readium/UIKit/SwiftUI。

## M2尚未实现

完整TXT导入/阅读入口、UTF16/GB18030自动检测与流式转码、SHA内容/parser版本cache、TXT完整版本化Locator/缓存重开尚未接入。TXTIndexing是完整facade协议，当前扫描输入必须已规范化UTF-8；不把Core组件写成用户已能导入TXT。URL由BookFileStore验证受管理路径，读取器不代替存储授权。原书/数据库schema/EPUB引擎未改。

## Git、工具与产物保留

本地main/HEAD6d761749911233122bcd031fcf718d22a19f9e77与原空index保留。M1 ref dedf9e4435d14f6884212f971292183cfcde5a60；M2源码快照0643093已通过独立index正常push，所有原未提交改动保留，未reset/stash/删库/覆盖原书。旧370文件备份.cache/recovery/20261014-092934已核验，历史交接归档到HANDOFF_M1_CONTINUOUS_HISTORY_2026-10-14.md。不要用旧candidate.json替代实际ref。

Docker只读查询exit1：dockerDesktopLinuxEngine命名管道不存在，命令已退出，未启动/重置Docker。Windows无Xcode，Apple验证用公开标准macOS runner，无账单/付款/支出变更，无localhost服务。根Package.resolved保持6个真实pins、真实解析38496501326，resolve/test/build严格根锁，bootstrap关闭。

build/XianxiaReader.ipa仍为用户已确认功能的Build4，7502213 bytes，SHA256 7983e6bcbb6be5363ccbe5381533c86e696d949665a6c36591d747cc2933f5c1；Continuous-Build4-TestKit.zip SHA f37cda047f5bcf7357d0865635cd7d4e0129a88401f9127ac92ad443a5caf9f7。旧Build3/原测试包/日志全部保留。本轮CI即使生成同Build号IPA，也只保存各run目录，不覆盖用户包；TXT入口未实现，无需另提供相同界面的安装包。

## 接续

1. M2下一切片：编码检测/UTF16与GB18030流式正规化、SHA内容/encoding/normalizer/parser版本绑定cache，再接入TXT导入与ReadingInterfaces原生阅读。第一切片完成不等于完整M2或用户可导入TXT。
2. 原书/书库/数据库保留，已有Build4用户包不覆盖；M3书库布局/编辑、M4字体/排版/主题顺序不变。未单独报告的设备细项不扩写通过。
3. 首轮EPUB冷启动超时诊断仍保留，根因未判定；同源码重试全套通过也不等于该现象已修复。以后遇到可重现问题先查成熟实现及最小复现，不能继续盲加等待/降低测试。
4. 构建前及每个可恢复步骤写检查点，阶段同步状态/设计/报告/FILE_INVENTORY；中断先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，并查实际Git/日志/任务。build/.cache不随clone，GitHub artifacts到期后按锁重跑。
