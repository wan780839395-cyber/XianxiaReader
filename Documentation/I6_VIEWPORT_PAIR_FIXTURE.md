# I6 连续视口本地配对夹具（2026-10-23）

2026-10-23 后续：[配对CI接线及来源守卫](I6_VIEWPORT_PAIR_CI.md)已实现并通过本地检查，尚未派发/原生验证。以下“CI未接线”仅指本地夹具实施当时；Swift夹具此轮没有变化。

按[已批准方案](I6_VIEWPORT_CONFLICT_REVIEW.md)实现本地 `paired-safe` / `paired-conflict` 与最小诊断。**本轮仅本地静态/工具检查通过，未 Swift 编译、未执行原生或 Swift 控制器机制，零 CI。**没有定位算法改动，不宣称旧故障复现或修复。CI 接线与同构建复用仍留后续。

## 实现范围

相对方案快照 `324b58a2f32c1d4afd2642bfc30f36e1301114a6`，617 项运行输入中只改约定的 5 项，其余 612 项摘要保持：

| 文件 | 本片职责 |
| --- | --- |
| `Tests/iOS/ReaderRenderingTests.swift` | 原单例内可选配对状态、公共封入口、两臂放行、实际退出后逐条排空、最后一次原谓词子条件及独立配对机制检查 |
| `Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift` | 仅增加 DEBUG 同次 `result.height`、`result.anchorY` 与 `indexMatches` 三项标量 |
| `Vendor/ReadiumToolkit/UPSTREAM.json` | 仅同步上述 SDK 文件的 SHA-256 |
| `scripts/verify_reader_positions.py` | 本地可调用的单臂回执校验与两臂语义兼容比较，保留真实 0/65 退出 |
| `scripts/test_reader_positions_tools.py` | 配对回执正反例，覆盖状态交错、原字故障候选、原规则拒绝、混杂、缺件、越序及清理残留 |

没有新增 target、依赖、全局 hook、定位 JS 或生产 await。Adapter、SpreadView、现有隔离和定位修复保持。原 35 个 XCTest 方法数量不变，仅原视口单例的 DEBUG 配对入口/诊断变化，其他 34 个方法正文保持。

## 配对顺序与诊断

两臂都在 A 的旧尺寸来源核对后、指定旧 S 仍扣住时封闭所有其他测量/采样入口。公共状态只允许指定 S 与第一条目标主 M 重叠；其他 slot 和采样继续在捕获前排队。主 M 不按结果换选。

- `paired-safe`：S 在 F0 放行并等实际域/工作退出，再真实 resize 到 F1；F1 DOM 就绪后主 M 捕获 A、取得原结果并停在提交前，随后放行。
- `paired-conflict`：保留 S 的 F0 上下文，先真实 resize；主 M 在 F1 捕获 A 并扣在提交前，才放 S；等 S 实际退出后放 M。
- 两条指定工作都实际退出后，其他工作按现有队列逐条准入、重新捕获并等真实退出。记录 `pair-drained` 后才允许原可见谓词验收；出现新工作则重新排空。

S 的原 3 次/32ms、clipTop/documentTop、逐项拒绝原因及原检查保持。M 仍执行原生产 guard，配对模式核 owner/index/positioning/revision/local 与原锚点有效性，只有 `anchorEqual` 及推导 `mayRestore` 可随 S 的真实锚点替换改变。不会因冲突臂预期的这两项 false 提前关闭，仍让原业务断言判定。

附加证据限于几何/身份/标量，不记录正文：配对模式/阶段、S/M ID、原 Locator 的资源与 DOM 范围/viewportOffset、F0/F1、真实 resize、队列许可与实际终结、同次 M 结果、S 终结分类，以及原谓词最后一次子条件。原谓词用一个覆盖更新的快照，避免每次轮询增加 128 事件预算。

配对控制器新增两组机制源码：指定交错与真实退出后的排空；S/M 同时持有且第三条排队时的取消、全部实际退出及迟到准入拒绝。其 5 段等待各 3 秒，在配对模式替代现有 smoke 机制检查，不叠加。**这些 Swift 机制本轮未执行**；离线 JSON 正反例不是 continuation 或 SDK 运行证明。

## 保留合同与预算

范围审计确认：

- 两个 Swift 文件去掉 DEBUG 分支后的 Release 代码逐字节一致；多行 JS 全部一致，SDK await 行序列一致，S 诊断/算法完整后缀一致。
- 原 `advanceSafeResize`、原六组 smoke 机制、清理/30 秒轮询实现及现有 smoke 校验函数保持；既有工具测试正文也保持。
- 原字 Range 可见、同 WebView、挂窗、alpha、宽度和资源上限、横屏再竖屏断言保持；不增加重试或放宽阈值。
- 原捕获/清理 3 秒、100ms/30 秒业务等待、32 waiter/128 事件保持；两臂公共准备/放行/排空都包含在原横屏预算内，不重置时钟。
- CI 工作流、shell 选择器、校验器 CLI 原入口保持；没有让现有 smoke 路由偷偷执行配对模式。

## 本地验证与实际限制

| 检查 | 本轮实际结果 |
| --- | --- |
| `scripts/check_repository.py --swift-syntax` | 文档/工程/工作流/schema/fixture/Vendor/架构通过；484 Swift 语法通过，保留上游 54 项既有语法限制，新增 0；不是编译 |
| `scripts.test_reader_positions_tools` + `scripts.test_readium_provenance` | 17 项中 16 通过、1 POSIX 用例在 Windows 跳过 |
| 改动范围审计 | 5/617 输入变化、其余 612 保持；原件 12 项、Build30 包、普通 HEAD/index 摘要保持 |
| Swift 编译/配对机制/原生/设备 Release/手机 | 全部未执行；本机无 Swift 编译器 |

首次工具检查在新增反例构造中遇到 Python 元组增量赋值错误，原日志 `local-tool-tests.log` 保留；修正测试构造后以 `local-tool-tests-fixed.log` 独立记录通过。不是 SDK 或原生测试失败。没有因此重跑整套或派 CI。

恢复目录：`build/maintenance/I6-viewport-pair-fixture-20261023/`，含 `before.json`、三份原始检查日志、`scope-audit.json`、`document-check.log`、`result.json` 和 `final-checkpoint.json`。持久记录见 [ValidationLogs/project-isolation-i6-viewport-pair-fixture.json](ValidationLogs/project-isolation-i6-viewport-pair-fixture.json)。

## 判读与下一片边界

本地 `verify_viewport_pair_arm(folder, mode, status)` 要求真实单例/summary/机制标记、同 nonce 有序回执、选定 S/M 的实际终结、串行排空和清理集合全空。缺件或资格破坏直接拒绝；原退出 65 保留。分类区分未覆盖、被原规则拒绝、只有状态交错、其他原断言失败和合格原字故障候选。

`compare_viewport_pair_receipts(safe, conflict)` 仅比较语义/物理起点及选择来源；始终返回 `matchedBuildVerified=false`、`matchedPairAccepted=false`。同构建/锁文件/书籍/模拟器配置、新测试进程和 xcresult 来源证明须由后续驱动另接，当前没有这项能力。

现有 CI 仍硬编码 smoke，不能直接用它验新配对。下一片先审 CI 路由、真实退出码保存、安全失败即止及同构建两进程复用；执行需另获指令，本轮不派发。以后即使合格冲突原字失败，也只是支持该受控路径，不能追认旧 full 根因或抹掉 test65。

最新真实原生结果仍是源 `2a9fdfb5` / CI `39806769382` 的旧 smoke 1/1（17.851 秒），不代表本片配对已通过。旧 full `39735403242` 仍为 191/192，旧 S 第三次 rejected 与历史根因均未证；I6/Release/手机未验收，最后交付 Build30，没有新 IPA。电脑保持运行。
