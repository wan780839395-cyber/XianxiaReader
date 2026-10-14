# 长篇性能测试计划（M5 验收，M2 提前使用）

当前设备性能尚未验收；本轮新增Release桌面Core探针，首轮Linux/macOS编译和测量已完成，发现Apple长循环临时对象增长，修复候选尚待完整CI。以下目标不是已达成指标。

## M2 长篇探针（本轮进行中）

`scripts/run_txt_performance.py`流式生成原创UTF8约5MiB/1000章、约50MiB/3000章、约50MiB无换行单章、UTF16约5MiB/1000章（实际大小/hash记录在结果）。每个样本启动独立`TXTPerformanceProbe` Release进程，实际走BookFileStore复制、TXTBookImportService、SQLite事务、缓存重开和reading plan；三个重开保持OS文件缓存，不称磁盘冷启动，不计算仅三次的p95。核验Python独立生成的原始/规范化SHA256、所有目录byte范围、SQLite/cache一致、三次稳定资源锚点和全文窗口无缝覆盖。所有正文临时生成，进程退出后再清理，不提交/上传大样书。

记录冷导入、目录查询、cache全文校验、reading plan和窗口遍历的单调时钟耗时，另列每个阶段进程生命周期RSS高水位。它包含Swift/Foundation/元数据，阶段间高水位差不是阶段瞬时内存，不是iPhone的Allocations/VM Tracker，不能把桌面峰值当设备验收。Linux ru_maxrss为KiB；当前Apple XNU为bytes，采用[Apple XNU getrusage手册源码](https://github.com/apple/darwin-xnu/blob/main/bsd/man/man2/getrusage.2)与[Linux man-pages](https://www.man7.org/linux/man-pages/man2/getrusage.2.html)核对，避免旧Apple归档手册的单位差异。无共享runner硬耗时门槛；正确性失败/timeout保留日志并失败，不生成成功IPA。

Linux/macOS都跑真实Release探针并上传完整JSON/log；iOS原长段回归扩展到超过64KiB巨段的第二个资源，继续要求600点滑动后非零字符锚点和重开误差<3px。新增多MB单章首/中/末Readium资源与位置回归。窗口UTF8 scalar边界不会丢字节，但组合字形/跨窗口段落节奏仍须M4真实页面验收。正文缓存重开仍全文校验和重新构造reading plan，目标“不重新读全文”尚未达成；先以实测决定后续最小优化。

### 首轮发现与最小修复（待验证）

38583014146/908ee29各68Core编译通过，4个Release探针均完成正确性核验，新增iOS巨章与第二窗口600点/3px回归均通过；但已有完整书架测试遭DocumentManager迟到host proxy异常，iOS55/56，test65/export0/summary0，Release未执行。macOS15.7.9数据：51.23MB/3000章导入后RSS高水位258.67MiB，最终319.89MiB；52.43MB无换行单章导入后257.42MiB。Linux同样本峰值32.49/23.38MiB，差异不能被Linux有界窗口结果覆盖。

参照[Apple WWDC24 Analyze heap memory](https://developer.apple.com/videos/play/wwdc2024/10173/)对Swift循环autorelease增长的说明，以及[Apple swift-mmio FileManager+Hashing](https://github.com/apple/swift-mmio/blob/main/Tests/SVDTests/FileManager%2BHashing.swift)的文件hash实践，采用Foundation公开autoreleasepool，将读取及处理放在每chunk的同步作用域内，摘要/decoder/章节等Swift值状态跨chunk保留；窗口完整读取也有同步pool，Linux直接执行原操作。不跨await持有pool、不改文件协调、字节校验/错误/取消合同、不升级parser/cache/Locator版本。探针的独立参考读也包住自己的临时对象，导入后RSS采样早于参考读，不能把探针清理当产品修复。源码变化会交付Build8，必须重新完整CI和设备验证。

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
