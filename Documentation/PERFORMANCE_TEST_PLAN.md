# 长篇性能测试计划（M5 验收，M2 提前使用）

## Build27 正文与设置流畅度专项（待真机测量）

用户确认正文和设置都感到不顺畅；不能归因60Hz。当前Windows/模拟器及字体散列计时不替代真机帧时间，尚未取得手机trace。历史设备为iPhone13/iOS16.6.1/TrollStore，每轮仍需核实际设备、系统、安装方式、IPA SHA、低电量/温度与刷新率条件。

对同一原创样书、字体/目录数量、字号/主题和完整位置做Build26与最终Build27的可比记录：首次开设置与热缓存重复各3轮，字体列表上下浏览，反复开关菜单；正文分别连续滑动30秒、分页点按20次。先普通动效，再单列减少动态效果；自动慢滚另列，不混入手动滚动样本。保持原件和数据库，不能卸载/删库制造基线。

在可连接真机且具有可分析的工具配置后，用实际可用的Time Profiler及Animation Hitches区分主线程提交和渲染阶段；保存原trace/符号、环境和操作时间，不只报平均FPS。报告帧间隔p50/p95/p99、最长停顿、hitch time ratio与持续区间，并对齐耗时栈；60Hz的约16.67ms仅是显示周期，不能据此认定具体卡顿原因。录屏和trace的额外开销需单列，模拟器/XCTest录屏不能充当设备帧率。

待测路径：ReaderViewModel位置发布/SQLite写入频率、Readium连续滚动DOM采样调用/完成数与最大并发、SwiftUI菜单/字体预览更新次数与耗时、CoreText解析、文件摘要与缓存命中。只用操作ID/耗时/计数，诊断不记录未来章节正文。当前Readium3.11源码只证明execute未串行化已经开始的异步采样，未证明手机实际重叠或其为唯一根因。

只有trace确认冗余DOM请求后，才考虑latest-only单飞/尾沿合并；停止滚动和saveNow必须完成最新fresh完整锚点，保留关闭/重开/切模式/排版时迟到结果与重试回归。若主要是SwiftUI依赖更新，则先按实际耗时缩小子视图依赖并保留稳定ID，不盲改整个ObservableObject或丢弃位置事件。任何修复都需相同条件重新测量、完整自动门槛和手机体验分列。

官方方法已于2026-10-18核阅：[Demystify SwiftUI performance (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10160/)用于先测量、缩小依赖/降低每次body成本；[Explore UI animation hitches and the render loop](https://developer.apple.com/videos/play/tech-talks/10855/)用于提交/渲染与hitch time ratio；[Analyze hangs with Instruments (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10248/)用于耗时栈定位。另核[WWDC25 SwiftUI instrument](https://developer.apple.com/videos/play/wwdc2025/306/)明确其新工具要求Xcode/Instruments26与更新系统；本项目当前Xcode16.4、最低iOS16，不能照搬其新面板或把升级用户系统当作前提，也不为此迁移到需更高系统的Observation。未加入调试私有API、signpost日志或新运行依赖。

以下长TXT桌面数据为既有M2历史范围。

当前Build8完整自动CI与Release桌面实测已通过，Apple长循环临时对象增长已由同hash样本验证改善；设备性能仍未验收。以下目标保持独立，不把桌面结果当iPhone指标。

## M2 长篇探针（本轮进行中）

`scripts/run_txt_performance.py`流式生成原创UTF8约5MiB/1000章、约50MiB/3000章、约50MiB无换行单章、UTF16约5MiB/1000章（实际大小/hash记录在结果）。每个样本启动独立`TXTPerformanceProbe` Release进程，实际走BookFileStore复制、TXTBookImportService、SQLite事务、缓存重开和reading plan；三个重开保持OS文件缓存，不称磁盘冷启动，不计算仅三次的p95。核验Python独立生成的原始/规范化SHA256、所有目录byte范围、SQLite/cache一致、三次稳定资源锚点和全文窗口无缝覆盖。所有正文临时生成，进程退出后再清理，不提交/上传大样书。

记录冷导入、目录查询、cache全文校验、reading plan和窗口遍历的单调时钟耗时，另列每个阶段进程生命周期RSS高水位。它包含Swift/Foundation/元数据，阶段间高水位差不是阶段瞬时内存，不是iPhone的Allocations/VM Tracker，不能把桌面峰值当设备验收。Linux ru_maxrss为KiB；当前Apple XNU为bytes，采用[Apple XNU getrusage手册源码](https://github.com/apple/darwin-xnu/blob/main/bsd/man/man2/getrusage.2)与[Linux man-pages](https://www.man7.org/linux/man-pages/man2/getrusage.2.html)核对，避免旧Apple归档手册的单位差异。无共享runner硬耗时门槛；正确性失败/timeout保留日志并失败，不生成成功IPA。

Linux/macOS都跑真实Release探针并上传完整JSON/log；iOS原长段回归扩展到超过64KiB巨段的第二个资源，继续要求600点滑动后非零字符锚点和重开误差<3px。新增多MB单章首/中/末Readium资源与位置回归。窗口UTF8 scalar边界不会丢字节，但组合字形/跨窗口段落节奏仍须M4真实页面验收。正文缓存重开仍全文校验和重新构造reading plan，目标“不重新读全文”尚未达成；先以实测决定后续最小优化。

### 首轮发现与最小修复（待验证）

38583014146/908ee29各68Core编译通过，4个Release探针均完成正确性核验，新增iOS巨章与第二窗口600点/3px回归均通过；但已有完整书架测试遭DocumentManager迟到host proxy异常，iOS55/56，test65/export0/summary0，Release未执行。macOS15.7.9数据：51.23MB/3000章导入后RSS高水位258.67MiB，最终319.89MiB；52.43MB无换行单章导入后257.42MiB。Linux同样本峰值32.49/23.38MiB，差异不能被Linux有界窗口结果覆盖。

参照[Apple WWDC24 Analyze heap memory](https://developer.apple.com/videos/play/wwdc2024/10173/)对Swift循环autorelease增长的说明，以及[Apple swift-mmio FileManager+Hashing](https://github.com/apple/swift-mmio/blob/main/Tests/SVDTests/FileManager%2BHashing.swift)的文件hash实践，采用Foundation公开autoreleasepool，将读取及处理放在每chunk的同步作用域内，摘要/decoder/章节等Swift值状态跨chunk保留；窗口完整读取也有同步pool，Linux直接执行原操作。不跨await持有pool、不改文件协调、字节校验/错误/取消合同、不升级parser/cache/Locator版本。探针的独立参考读也包住自己的临时对象，导入后RSS采样早于参考读，不能把探针清理当产品修复。源码变化会交付Build8，必须重新完整CI和设备验证。

版本/差异核对：2026-10-14实际读取swift-mmio main的[原始源码](https://raw.githubusercontent.com/apple/swift-mmio/main/Tests/SVDTests/FileManager%2BHashing.swift)，它使用System.FileDescriptor和2048byte可重用临时buffer，依赖CryptoKit/System，**没有autoreleasepool**；这是可选底层buffer路线，未照搬其try?关闭或引入新依赖。此项目锁定Swift tools5.10/Xcode16.4/iOS16，保持已有Foundation错误/close合同，以WWDC24明确的嵌套pool例子作最小改动；Linux无Objective-C时直接原操作。效果必须由同hash的Apple Release实测确认，不能根据参考方案推定已修复。

已有picker测试只保留picker到case teardown，仍销毁SwiftUI host tree；完整日志异常在前一case结束后通过XPC迟到布局回调送达，不证明当前TXT测试/用户首次导入失败。[WebKit官方问题269615](https://bugs.webkit.org/show_bug.cgi?id=269615)有iOS16/17同类异常；它只证明系统晚回调风险，不能证明本项目唯一根因。测试工具保留六个已隐藏完整native host到worker进程结束，所有原生呈现/关闭/迟到/编码/导入断言和15秒门槛保持；其tmp数据库也保留到worker结束，避免在存活repository下unlink。仅测试fixture生命周期变更，生产App picker路径保持Build7用户已确认方案，未捕获/禁用系统异常或删除失败测试。

## 数据集

生成原创可重复的 100/300/500 万中文字 TXT，1000/3000/5000 个章节；组合 UTF-8（含/不含 BOM）、UTF-16 LE/BE、GB18030、CRLF/LF、跨块多字节字符/章节名。额外样本：50 MB、多 MB 单章、没有换行/没有章节、超长行、卷章混合。

EPUB 样本分别覆盖一个巨大 XHTML、3000 个小 XHTML、嵌套 TOC、大图片与正常图片；避免只测小包。版权书只能由用户本地测试，不进仓库。

## 指标与初始目标

| 操作 | 初始目标 | 测量 |
| --- | --- | --- |
| 导入过程中 UI 响应 | 无连续超过 250ms 的主线程阻塞 | Instruments Hangs / signpost |
| TXT 导入内存 | 正文内存不随全文长度线性增长；增量额外峰值先争取 <80MB | Allocations / VM Tracker，扣除基线 |
| 翻页/滚动 | 正常设备持续阅读无可见卡顿 | Core Animation + 录屏/实际体验 |
| 缓存重开 | 不重新读全文、不重做分章；先争取 <1s 进入正文 | 冷/热启动 signpost，各 10 次 |
| 打开 3000 章目录 | 不触发全文解析；先争取 <300ms | 数据库与 UI signpost |
| 搜索 | 增量结果可取消、内存有界 | 索引/首次结果/取消时延 |

目标需在明确 iPhone 型号/iOS 版本/发布构建条件下校准，不把不同设备数字混为一谈。记录样本 hash、大小、字数、章数、缓存状态、构建 SHA、p50/p95/峰值、后台行为与电量。

## 故障与恢复

导入复制/解析/文件提交/DB 事务四个位置分别中断；测取消、杀进程、磁盘不足、iCloud 暂未下载、数据库升级、索引版本变更及损坏 cache。原始用户书籍不能因失败丢失。索引正确性检查首末 byte range、随机 100 个章节标题、文件末尾、UTF-8 边界与重复章身份。

当前 Readium 每次打开 publication 的 manifest/position 计算仍可能成为大 EPUB 瓶颈。M5 先测量再通过服务扩展或持久 cache 优化，不用“接入了 Readium”代替性能保证。


### Build8完整实测（设备仍待验收）

Build8长篇TXT自动门槛通过：[CI38587015887](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38587015887) / 1d4ee302daf32534fb367ccc1c4f4b5af8489fcd，Linux/macOS各68Core、iOS56/56、test/export/summary0、无签名设备Release/IPA。Windows382语法新增0/54 pristine限制、16tooling；460候选Git blob hash及三份锁核对一致。四个桌面Release样本分别验证约5/50MiB、1000/3000章、50MiB无换行巨章及UTF16，hash/目录/完整窗口覆盖通过。Apple逐chunk同步autoreleasepool修复后51.23MB/3000章最终RSS高水位从319.89降到25.83MiB，导入后从258.67降到14.08MiB；数字为桌面完整进程，不能当iPhone峰值。原生巨章第二窗口600点滑动/非零字符/3px重开，以及多MB首中末资源/位置回归通过。

新包`build/XianxiaReader-TXT-Memory-Build8-TestKit.zip` / SHA256 `7ed19e6a595b8bd14624298689efbd68a81b39be0021e7335dbe211e7c875533`，含Build8 IPA与8个原创大小样本；正常更新保留书库，+菜单确认0.0.1 (8)。8个旧Build4/5/6/7包及基线长样本ZIP逐hash保留。App导入/UI、Readium3.11/Vendor/6 pins/文件协调/Locator和cache版本不改。首轮38583014146/908ee29各68Core/探针通过、iOS55/56系统DocumentManager迟到host异常且Apple内存增长，完整失败/测量原件保留；修复测试仅保留六个隐藏完整host与tmp repository到worker结束，原所有断言/15秒门槛保留，未宣布修复Apple系统bug。缓存重开仍全文流式校验/构造plan；只读元数据秒开尚未实现。Build7首次导入已获用户确认，Build8及长书/普通设备/完整中文排版仍待设备验证，M2Accepted=false；M3/M4未开始。报告[M2_TXT_LONGBOOK_VALIDATION_REPORT.json](M2_TXT_LONGBOOK_VALIDATION_REPORT.json)，性能合同[PERFORMANCE_TEST_PLAN.md](PERFORMANCE_TEST_PLAN.md)。

| 平台/样本 | 实际原始MB | 章数 | 冷导入s | 三次cache校验+plan s | 最终进程RSS MiB |
| --- | ---: | ---: | ---: | --- | ---: |
| Linux/utf8-5MiB-1000chapters | 4.90 | 1000 | 0.54 | 0.39–0.39 | 26.53 |
| Linux/utf8-50MiB-3000chapters | 51.23 | 3000 | 5.36 | 2.62–2.64 | 32.77 |
| Linux/utf8-50MiB-no-newline | 52.43 | 1 | 5.38 | 2.28–2.32 | 23.38 |
| Linux/utf16-5MiB-1000chapters | 5.23 | 1000 | 1.05 | 0.45–0.45 | 26.29 |
| macOS/utf8-5MiB-1000chapters | 4.90 | 1000 | 0.47 | 0.22–0.24 | 14.42 |
| macOS/utf8-50MiB-3000chapters | 51.23 | 3000 | 4.82 | 1.98–2.33 | 25.83 |
| macOS/utf8-50MiB-no-newline | 52.43 | 1 | 4.24 | 1.79–2.07 | 9.16 |
| macOS/utf16-5MiB-1000chapters | 5.23 | 1000 | 0.88 | 0.31–0.35 | 14.88 |

## Build9 范围缓存实测（2026-10-15）

2026-10-15 Build9 ANSI兼容/范围缓存完整自动门槛通过：[CI38612220954](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38612220954) / c2a037aa6765cd56319cf8a61e8ca1c34f047e22。Linux/macOS各80Core，iOS58/58、failed/skipped0、test/export/summary0，无签名设备Release/IPA。Windows385 Swift语法新增0（pristine54限制保留）、16tooling，语法不是编译；463候选源码Git blob hash、三份真实6pins锁一致。中文Windows ANSI/GBK默认严格自动导入，Big5/CP950与Windows-1252明确手选，GB18030自动回退；Apple CP936单独euro与合法trail80差异经官方映射核实和跨块回归。Normalizer/parser/resource/Locator v1及旧UTF/GB18030 codec身份保持，自动cache策略独立v2。范围cache复用严格核对所有范围/最大scalar切点，仍全文digest验证，不能保证只读元数据秒开。完整方案见TXT_ANSI_COMPATIBILITY.md。

新包`build/XianxiaReader-ANSI-Build9-TestKit.zip` / SHA256 `c13c2310b62341bf6f1249eda526c26c41bb398f08030c0adb9fb8233172847b`，含Build9 IPA和11个原创样本（新增GBK/Big5/1252）；正常更新保留书库，+菜单确认0.0.1 (9)。Build4–8旧10个IPA/ZIP和长书样本ZIP逐hash保留。用户直接回复Build8手机长TXT导入、目录跳转和重开位置“已测试，功能正常”，仅此范围记录接受；Build9编码/普通设备/完整排版与设备性能另待测试。当前M2自用基础已确认，下一阶段M3完整书库，M4字体/排版/主题随后。首轮94b10c6/38608225245 Linux NUL偏移断言失败、第二轮541b7ae/38608713016 Apple CP936 euro失败完整日志保留，实际源码修正后完整CI通过；未删除或放宽原断言，不把失败轮未执行阶段写通过。

第三轮b6f1228/38610052379各80Core/4探针及全部TXT通过，旧EPUB模式切换就绪超时导致iOS57/58；源码只增强测试的分页目标实际可见等待，原30秒/最终恢复断言保持，完整原件保留。新一轮通过不证明唯一根因或产品模式切换永久修复，生产EPUB/Vendor未改。

四样本与Build8大小/规范化摘要/所有章节边界逐项一致，Linux/macOS都验证首次构造和后两次范围复用、边界单字节读取上限及全文窗口覆盖。macOS以下为同runner的桌面Release基线，逐样本独立进程，warm3不是p95/设备性能；缓存加速范围构造，完整摘要校验仍在。

| 样本 | 冷导入 | 首次plan构造 | 后两次plan复用 | 后两次全文摘要校验 | 最终RSS高水位 |
| --- | --- | --- | --- | --- | --- |
| utf8-5MiB-1000chapters | 0.42s | 70.3ms | 17.3–17.7ms | 0.14–0.14s | 15.44MiB |
| utf8-50MiB-3000chapters | 4.42s | 559.8ms | 48.9–71.0ms | 1.52–1.54s | 29.84MiB |
| utf8-50MiB-no-newline | 4.82s | 476.0ms | 8.8–8.8ms | 1.42–1.42s | 10.25MiB |
| utf16-5MiB-1000chapters | 0.84s | 91.7ms | 16.7–19.8ms | 0.17–0.18s | 15.80MiB |
