# smoke捕获前准入与逐条排空（2026-10-22）

2026-10-23 统一准入/逐条排空修正版仅一轮CI39806769382/2a9fdfb5/attempt1：原生编译、机制6组、原smoke单例1/1（17.851秒）及回执校验通过。主M原7项guard全true，真实退出后另一M及sample逐条准入；79事件，五类清理集合全空。S首采样committed，原字499横/竖均可见。617输入/算法/S诊断/原断言预算保持；未重跑或执行full/Release，旧191/192与I6/手机缺口、Build30不变。见[本轮结果](I6_SMOKE_ADMISSION_NATIVE.md)。

以下保留当时实现/验证范围，本轮结果以上文为准。

**候选已实现，本地检查通过；未Swift编译、未原生运行，零CI。** 本片按[已审阅的最小方案](I6_SMOKE_SAFE_ORDER_REVIEW.md)修正测试编排。不能据此称smoke、旧S拒绝或旧full故障已修复。

## 实现边界

相对保存源`07e11c4777a0f4d7145154c11db884ca7cbd73c8`只改5项运行输入，其他612项保持：

| 文件 | 改动 |
| --- | --- |
| `Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBInfiniteScrollView.swift` | 显式安装DEBUG夹具时，measure/sample先经过捕获前入口；随后复核取消、epoch、slot。独立work-start/work-finished覆盖排队、缓存命中、提前退出和实际方法退出 |
| `Tests/iOS/ReaderRenderingTests.swift` | 私有控制器管理入场队列、主M、逐条排空及清理；只改原视口单例的DEBUG横屏编排，扩强既有机制组 |
| `Vendor/ReadiumToolkit/UPSTREAM.json` | 只更新上述InfiniteScrollView的真实SHA-256 |
| `scripts/verify_reader_positions.py` | 核对真实入场/提交许可、实际终结、单条排空及空队列收口；原S/M和定位条件保持 |
| `scripts/test_reader_positions_tools.py` | 同一工具用例增加成功事件样本及错序、错点、漏项、owner/DOM错误和残留反例 |

两个Swift文件的Release投影逐字一致，全部多行脚本一致。Adapter、SpreadView和S采样诊断/算法后缀未改；35个XCTest方法名称不变，其他34个方法体保持。没有新增target、依赖、CI selector或产品功能。

## 实际顺序

1. 原capture和S仍按原逻辑读取、诊断和放行；此阶段入口不排队。S必须在旧尺寸committed且保存A，原capture/辅助请求及既有SDK工作实际退出后才开始resize。
2. 在同一MainActor同步段启用准入，再改变真实窗口尺寸。同reader/epoch的所有measure（包括邻章）和sample都在冻结生产上下文之前排队。
3. 原100ms/30秒横屏谓词复用原domProbe，仅取widthMatches作为主M入场条件，记录`fixture-width-readiness`。只准入目标slot第一条M，不在失败结果中换选；它此时才读取版本、锚点和局部位置。
4. 保留主M的真实JS结果后before-commit屏障；同次DOM宽、owner和A必须合格。提交放行后仍核原7项恢复guard全true，并等SDK域终结与work-finished两种真实回执。
5. 之后按排队顺序一次准入一条，每条都在准入后读取新上下文、执行原算法，并等实际方法退出。没有批量resume、丢弃邻章操作或返回伪成功。
6. 排空后执行原DOM宽度与原字Range可见联合条件。该await返回后再次检查队列/运行/SDK工作/waiter均空，才记录admission-complete并恢复普通准入；期间若新工作入场，沿用同一时钟继续排空。竖屏分支不注入。

入场和提交许可按`(requestID, point)`分开，避免已准入的许可直接穿过提交屏障。所有continuation合计仍最多32，事件最多128；原3次/32ms采样、capture/cleanup 3秒、100ms/30秒等待和六组机制的3秒段数量保持。原charOffset>100、同WebView/挂窗/alpha>0.99、宽度误差<2、原字可见、≤12资源及横竖两方向均保留。

取消或关闭先标终态、关闭reader使owner失效，然后abort所有入场/提交waiter；运行中工作保留登记到SDK实际退出。窗口在失效/abort后恢复。payload新增queued/running，和active/tasks/waiters一起必须为空。上限耗尽或外部加载/布局事件使原资格不成立时明确失败，沿用原watchdog/预算，不换主M或放宽guard。

## 本地验证与尚未验收

| 项目 | 本轮结果 |
| --- | --- |
| 仓库文档/工程/工作流/schema/fixture/Vendor/架构静态检查 | 通过 |
| Swift语法 | 484文件通过；保留上游54项既知grammar限制，无新增诊断；**非编译** |
| 相关Python工具/依赖来源测试 | 15项执行，14通过，1项POSIX测试在Windows跳过 |
| 范围/行为审计 | 5项运行输入变化，612保持；Release投影、脚本、S诊断后缀、34个其他XCTest、预算计数及原件摘要一致 |
| Swift机制检查 | 已扩强原多waiter组验证两M+一sample、两点许可、实际退出后逐条放行；取消组同时覆盖入场/提交waiter。**仅源码接线，未执行** |
| 新候选编译/原生smoke/设备Release/手机 | 均未执行；零CI、无新IPA |

Python正反例核对证据格式与因果顺序，不执行Swift控制器，不能替代屏障真正命中、放行回执和取消清理的原生验收。新增DEBUG await及宽度准备观察有意改变受控时序，不能将将来的串行smoke通过当作自然并发正确或旧故障根因已证。

最后真实原生结果仍是源`2274ba25` / CI`39793517830`：编译通过、机制6项通过、smoke 0/1；S首次committed而M资格失败。旧full仍191/192，I6/Release/手机未验收，最后交付Build30。此前旧S第三次rejected原因、H1冲突复现及旧full根因均未补证。

## 恢复与下一项

本轮原件在`build/maintenance/I6-smoke-admission-20261022`：before、scope-audit、result、本地完整检查日志、fixture差异及final-checkpoint；持久审计见[ValidationLogs](ValidationLogs/project-isolation-i6-smoke-admission.json)。普通HEAD/index和Build30 IPA/TestKit保持，旧CI原件摘要重核一致；不关机。

本片到本地检查为止。下一项需要用户另行指定才编译并运行现有smoke单例，核统一入场、主M原guard、SDK真实终结、逐条排空和取消清理；不自动派CI、追加冲突对照、重跑23项/full或进入新功能。失败先保存真实事件与完整日志，再判断准备/资格/原字条件；禁止将旧CI结果计给新源码。
