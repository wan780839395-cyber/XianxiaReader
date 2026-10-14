# TXT ANSI 兼容扩展（Build9 候选，待编译）

日期：2026-10-15（Asia/Shanghai）。用户已确认 Build8 手机长 TXT 导入、目录跳转和重开位置正常；设备型号、系统和完整性能矩阵未独立读取。本增量优先回应用户的 ANSI 兼容需求，同时完成已开始的阅读窗口范围缓存，尚未通过真实编译或新包设备验收。

## 编码方案

ANSI 取决于 Windows 的语言代码页。[Microsoft code page identifiers](https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers) 列出中文简体 936、繁体 950 和西文 1252；[官方代码页说明](https://github.com/MicrosoftDocs/globalization/blob/main/globalization/encoding/code-pages.md) 说明它不是统一编码。选择器新增 ANSI / GBK（中文 Windows）、Big5 / ANSI（繁体 Windows）和 Windows-1252（西文 ANSI），保留自动、UTF-8、UTF-16 LE/BE、GB18030。日文、韩文等其他 ANSI 代码页未包含。

自动模式先处理 BOM 和严格 UTF-8，仅无 BOM 且严格 UTF-8 判定失败时清理该次临时输出，再依次严格尝试 GBK、GB18030。IO、取消、NUL 和清理错误保持可见，不作为换编码重试的理由。Big5 和 Windows-1252 手选，避免把任意字节都当作有效西文。GBK/Big5 和不带 BOM 的截断 UTF-8 存在字节歧义，自动检测不能保证辨别所有文件；选择页说明手动纠正方式，自动识别成功信息显示实际编码，原始文件始终保留。已导入书籍原地修改编码的管理界面尚未实现。

Apple 使用 SDK 的公开 `CFStringConvertWindowsCodepageToEncoding` 和严格 CoreFoundation 转码；[简体编码](https://developer.apple.com/documentation/corefoundation/cfstringencodings/doschinesesimplif) 与[繁体编码](https://developer.apple.com/documentation/corefoundation/cfstringencodings/doschinesetrad) 对应 SDK 文档。Linux 使用系统 glibc iconv 的 CP936、CP950、WINDOWS-1252。没有引入第三方依赖、宿主 Homebrew 路径或宽松替换。转换仍按块进行，沿用 Apple 同步 autoreleasepool，不在主线程读取整本。

Normalizer、parser、resource、Locator 仍为 v1；已有 UTF/GB18030 codec 身份不变。自动检测策略独立 v2 进入自动 cache key，升级仅重建旧自动缓存一次，不改规范化字节、章节、href 或旧锚点。新增代码页有独立 codec 身份。数据库 schema、文件协调、Readium 3.11 和真实锁文件不变。

## 实际 SDK 差异与最小修正

第二轮541b7ae / CI38608713016 Linux80 Core/4探针通过，macOS编译后80项仅CP936单字节euro回归失败：Apple SDK对应转换拒绝0x80，iOS/Release未执行。核对Unicode托管的[Microsoft CP936官方映射表](https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP936.TXT)：单独0x80映射U+20AC，而双字节0x8180映射U+4E90；[WHATWG成熟解码规范](https://encoding.spec.whatwg.org/#gb18030-decoder)也按字符状态区分此单字节扩展。[Apple公开CF代码页表](https://github.com/apple-oss-distributions/CF/blob/main/CFStringEncodingDatabase.c)是SDK映射的参考，不能替代当前平台测试。

仅Apple CP936分支在已验证完整字符边界拆分连续SDK转换段，单独0x80输出euro的准确UTF8三字节，合法双字节trail 0x80继续交SDK。所有其他映射仍由SDK完成；GB18030原路径不变，未采用WHATWG对GB18030全部映射/错误恢复策略。新增混合单字节/双字节0x80与跨块向量，原自动euro/四字节扩展断言保持。首轮NUL偏移与本轮平台差异完整失败原件分别保留，新源码须重新完整CI，不记录失败轮未执行门槛通过。

## 已开始的范围缓存

已阅读锁定 Readium 3.11 / d82f44f 的 InMemoryPositionsService、PerResourcePositionsService：它们把位置元数据与正文资源分开。本实现保持现有 TXTIndexCache 的原子与安全路径方式，不修改 Readium 服务，也不让 Core 引入 Readium。

`reading-plan-v1.json` 只缓存章节 ID 与 64KiB 最大资源范围，限制 8MiB，身份绑定源/规范化摘要、编码、parser/normalizer/resource 版本和章节摘要。复用仍经过 TXTIndexCache 的原件与规范化全文摘要验证，然后检查完整连续范围和确定性最大 UTF-8 scalar 切点（每资源最多两次单字节读取）。缺失、版本旧、格式或摘要/边界损坏会重建；IO、符号链接和取消错误不吞。写入前重新解析路径并原子发布。正文不进缓存元数据；完整 digest 和阅读窗口/UTF-16 锚点校验仍在，不能称为只读元数据秒开。

## 回归与门槛

新增 5 项 Core 编码回归：独立 GBK/CP950/1252 字节向量、CP936 euro、GB18030 扩展字、跨块与非法字节/NUL、实际导入及新 codec、模拟 Build8 自动缓存和旧 Locator。7 项范围缓存回归覆盖复用、损坏/伪造摘要、UTF-8 非边界及提前切点、源变化、路径、取消与 IO。原首次导入/错误/重试断言保留，旧需手选的 GBK 向量现自动有效，重试用例改用仍需手选的西文字节。

新增 2 项 iOS App/Readium 编码与位置回归，保留所有 EPUB、首次导入、搜索、生命周期、巨章第二窗口 600 点/非零字符/3px 重开约束。目标 Linux/macOS 各 80 Core、iOS 58；四个同 hash Release 样本比较首次 plan 构建与后两次复用，边界读取上限和完整资源覆盖均校验。三次重开不是 p95，桌面测量不是手机性能。

Windows 385 个 Swift 文件语法新增诊断 0（pristine 54 项限制保留）、16 项 Python tooling tests 通过。语法不是编译；Linux/macOS、iOS、设备 Release 及 Build9 真机结果分别记录。完整 CI 与 Build9 包尚未完成。
