# I6 验收区间修正版原生结果（2026-10-23）

唯一[CI 39930462353](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39930462353)，attempt1，冻结源`d3f59cd272e78e863c2bc75a38fcb735e0d768ab`。只选择continuous-resize-pair，一次构建，安全全部合格才运行冲突，保留两臂真实退出；没有修改算法/guard/原字双向断言/预算、等待重试或再派CI。

## 结论和未到达的验收

| 项目 | 本轮实际结果 |
| --- | --- |
| 仓库工具/语法 | Linux150/150，24.249秒；484 Swift语法通过，54上游既有限制/新增0，语法不是编译 |
| 原生编译/链接 | build-for-testing仅一次，成功，退出0 |
| 来源与产物 | 实际619 Git blob匹配冻结源；609产物清单、三份原生计划仅mode差异，安全前后快照及真实7项版本匹配 |
| 安全原同例 | 只执行一次，0/1，39.160秒，原退出65；配对机制两组通过，不能替代原业务结果 |
| 原驱动 | 注解、原日志及原exits/result共同确认退出65，未以校验/导出错误覆盖 |
| 冲突原同例 | 未启动，退出null；安全失败停止生效 |
| 失败点 | oldSample阶段`pair-safe-S-unqualified`，S真实终结为rejected/document-top-mismatch-exhausted |
| 本片验收区间与返程 | 主M、首次resize、admission-complete和返程均未到达；本轮没有返程请求可核验，未获得区间修正的新原生验收 |
| 原字双向断言 | 源码及预算保留，本轮尚未执行至其宽窄通过点，不能写成通过 |
| 完整发布门槛 | 没有full/Core/普通UI/设备Release/IPA；I6、旧full191/192和手机缺口保持 |

Xcode16.4/16F6，Swift6.1.2，Target x86_64-apple-macosx15.0，macOS15.7.9/24G830；iPhone16Pro模拟器iOS18.5/22F77。两臂完整同构建判定仍为false，只有已执行安全臂的来源/前后产物核验完成。

619运行输入相对本片冻结源完全保持；相对39920796794旧原生源，仅上轮两Python工具不同，Swift/SDK/夹具相同。Swift在第881行先抛错误，Python在原生退出之后才读取清理记录并拒绝旧阶段，因此本轮没有进入新增返程核验逻辑；不能把提前失败归因于验收区间改写，也不能说新验收器已通过配对。

## 新取得的2367→1767证据

保留31条原控制事件、87条独立诊断且零丢弃。以下均来自同一WebView/reader/epoch，不以日志最终尾部猜测：

1. 原外层+600后已显式写入内层2367；最近应用writer `35DB0B44`（viewport-layout-slots）前后均2367，结束于1685.828824975。
2. 先行**native**样本`4485E689`在控制seq6–13工作，非被持有的S，也不是后来返回cached的original-capture。它的range-read `8AE2F005`在1685.873001697实际提交，内层仍2367。
3. 1685.951182483首次观测内层回到1767，距最近2367记录约78.181毫秒；外层局部位置与web frame仍2367，currentWriterID=none。观测栈含`WKWebView::_scrollToContentScrollPosition:scrollOrigin:animated:`→UIScrollView offset setter→WebKit delegate forwarder→本项目滚动观察入口。
4. 先行native JS回调到达时内层已1767，但那次DOM结果仍documentTop2367；seq11九项原上下文检查全真，因原外层localTop仍2367而提交A。紧接的original-capture `CA89BCF1`于seq14–18走cached，不含另一次JS读取。
5. 指定S `02A950BC`随后seq21被放行；三次实际WK提交/回调、JS结果均1767，clipTop0，期望2367，差-600。九项原上下文检查仍全真；documentTop条件拒绝，最终rejected，A保持，尚无resize或主M。

因此这轮明确复现了先前的**同型2367→1767回退**，也捕获了此前缺失的首个回退入口。旧约0.383秒窗口不能被本次78毫秒样本改写。观测栈证明这次offset变化经过WebKit位置回写入口；`recentEvaluationID`/最近应用writer只作相关记录，不能把它们当成发起原因。仍未证明哪条更早的JS/平台滚动请求触发该回写，也未证明旧full视口缩放失败的完整根因。

源码和诊断没有降低原guard，无法用忽略事件、增加采样次数或延迟放行将本轮改绿。原先39920796794返程3请求的离线7/7/8核验仍保留其离线边界，本轮没有新的返程证据替代它。

## 覆盖与取消清理

目标WebView一组coverage-start/end，13组实际evaluation enter/submit/callback有序完整，9组显式writer before/after完整。关闭pending evaluation/writer均0，active/tasks/waiters/queued/running五类集合全空。首次回退有有界栈，诊断87/87、丢弃0，inner73条。新取消前提交和迟到回调分支仍未命中，不能写成全取消专项通过。

## 这轮时间花在哪里

| 区间 | 实际秒数 |
| --- | ---: |
| 配对步骤总计 | 1568.000 |
| 步骤开始至构建命令（冷准备） | 547.389 |
| 原生构建至成功 | 307.165 |
| 构建后至步骤结束 | 713.445 |
| 其中模拟器boot / appearance命令 | 204.532 / 69.946 |
| test-without-building整个命令 | 401.524 |
| 其中原单例本体 | 39.160 |

测试命令包含启动/测试基础设施及结果处理，不能把401秒都算成用例本体；39秒也不能抹去冷准备成本。没有本地重复预检或整套原生测试，远端保留了工作流既有150工具检查。

## 原件与恢复

原件`build/ci/39930462353/`：run/job/annotations API、完整原job日志及合并full.log、prepared/build-manifest/原始与两臂计划、安全before/after/exits/完整原生日志/summary/xcresult/附件与manifest。artifact12492239303，原ZIP56,722,406字节，展开61,004,518字节/1067文件，SHA256 `d7bf3f6719ae8505e78c2e1c78e64a28e3cd9229a3a2e3612e90c2b2ff9b211c`匹配GitHub digest且CRC通过；提取确认后仅删除重复ZIP，未清理历史原件。

恢复`build/maintenance/I6-pair-interval-native-20261023/`：before、frozen、一次dispatch持久锁、native/source/timing/inner分析、rollback-correlation原始关联、result与最终私有快照。[持久结果](ValidationLogs/project-isolation-i6-pair-interval-native.json)。2593旧证据记录、619冻结输入、Build30及普通HEAD/index保持，AGENTS既有额外文字原样保留。无运行助手遗留，不关机。

下一最小切片建议仅本地审阅已捕获的WebKit滚动位置同步入口、先行native range-read提交/回调和旧请求关系；先核对官方/成熟实现与iOS18.5版本差异，再提出能区分触发来源的方案。尚未授权该片算法修改、新等待重试或下一CI，不自然重放碰运气。
