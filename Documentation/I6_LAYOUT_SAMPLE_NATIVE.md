# I6 跨布局采样修正：单轮原生验收通过（2026-10-24收口）

**来源72b07cc的安全/冲突两臂均1/1通过，真实退出[0,0]。新布局保护在原生冲突臂实际命中，旧S未覆盖A，M原guard/补偿、宽屏原字及窄屏返程均通过。** 本轮只验证保存补丁，没有再改运行源码、重复派发或执行full/Release。

## 唯一执行与来源

用户在明确“推送72b07cc、只一轮最小原生测试，不合并发布或自动重跑”后要求继续。已推送codex/continuous-layout-sample-invalidation-saved，准确源`72b07cc52bff3b2900e48c83d520dba15aac1236`。[CI39979277641](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39979277641)于10月23日启动，attempt1、唯一POST，一次build-for-testing，每臂原case一次，安全全部合格才冲突。最终success，build/link0、driver0，无PR合并/发布或新IPA。

619源文件/Git blob及规范化内容SHA256全部匹配冻结输入；47项仅Windows CRLF与Git/CI LF差别，逐项核对原Git blob。609产物、原始/安全/冲突三份运行计划、实际七版本、两臂前后四份快照一致，驱动matchedBuildVerified=true、semanticPairCompatible=true。没有把单臂receipt自带的false当最终配对判断。

工具链：Xcode16.4/16F6、Swift6.1.2、macOS15.7.9/24G830、target x86_64-apple-macosx15.0；iOS18.5/22F77。CI自带167工具测试/484语法通过，新增语法诊断0；复用已冻结的33项本地结果，未叠加本地预检。

## 实际业务与SDK回执

| 验收 | 安全臂 | 冲突臂 |
| --- | --- | --- |
| 原单例/真实退出 | 1/1，0，16.668秒 | 1/1，0，9.898秒 |
| 主S | 402宽启动/读取，代次相同，committed | 402宽启动，874宽读取，真实代次改变、layoutMatches=false，rejected/layout-invalidated |
| A与M | A保持，原7项guard全true，mayRestore=true | A保持，原7项guard全true，mayRestore=true |
| M实际补偿 | anchorY2147.875、原偏移-3.125，最终localTop2151 | 相同 |
| 原字宽874 | 原WebView/attached/valid/visible/accepted均true，top=-3.125 | 相同 |
| 原字返回窄402 | 原WebView/attached/valid/visible/accepted均true，top=23.875 | 相同 |
| 返程SDK请求 | 3个，逐个read/result/guard/terminal及结束区间审计通过 | 3个，逐个审计通过 |
| 最终跟踪集合 | active/tasks/waiters/queued/running全空 | 全空 |

返程验收是原先的“同一原字可见”合同；不把23.875写成逐像素回到原偏移。未改变原Locator、原字双向断言、M真正新锚点保护、等待/重试预算或SDK终结要求，未忽略返程请求。

与旧39962812139对照，href/selector/textNodeIndex/charOffset/viewportOffset、原窗口/目标尺寸和采样来源全部相同。旧冲突S在874宽提交B，M anchorEqual=false而未恢复，原字top=-219.125；新冲突S虽同样读到2367，但布局代次已变，因此作废并保留A，M恢复到2151，原字top=-3.125。M整段代码及原测试方法未改；结合本地原样旧/新S对照，支持这次受控跨布局竞态修正。它不证明旧full自然失败、旧2367→1767或准备期取消的全部根因。

## 诊断与保留的未知

- journal分别198/194条，dropped0。安全旧退休缓冲38条、冲突35条均交付原reader/epoch；正常sampling各57条。连续顺序与4组coverage起止/slot/WebView身份配对，原件齐全。
- 两臂准备completed=true、firstError空，记录点准备/cleanup取消标志false；准备期CancellationError本轮未复现，不能据此声称其来源已查明。空跟踪集合也不等于所有原生取消/迟到分支已被执行。
- runtime公开Bundle仍为com.apple.WebKit、version8621/build8621.2.5.10.10。原JS观察restored=true，但incomplete=true/reason=options-value，实际参数仍缺证，精确WebKit源码匹配unknown；本轮没有新增诊断或修改这条分支。
- 记录的body2367→2151与viewport-scroll-delegate及M补偿相符，没有拿它冒充旧2367→1767链路。历史自然根因继续未知。

## 耗时与交付原件

原生定向步骤1358秒（22分38秒）：按步骤/完整日志分界，构建前约445.344秒、编译约355.049秒、构建后约557.607秒。真实test命令分别176.592/61.313秒，含runner启动；case本身合计26.566秒。bootstatus157.525/53.046秒，appearance44.814/15.446秒。远程准备/编译/模拟器成本与测试执行分别记录，artifact取证另计。

build/ci/39979277641/保留完整repo/native日志、run/jobs/artifact API、181个提取原件及两份xcresult。artifact12513783206：压缩5,419,291字节、展开14,046,911字节；SHA256 `0a742766afa1d11cd11760763bc1760d2cb54bbcdf61d7e9bbbf654306e36671` 与GitHub一致，CRC及全部提取文件哈希通过。复用原同artifact Range工具一次完整取得，无下载失败或CI重派；只按精确清单删除已验证的重复ZIP/空传输文件，原件与receipt保留。

恢复build/maintenance/I6-layout-sample-native-20261023/保存before、freeze/push/唯一dispatch、完整状态、来源/业务/SDK/旧新对照/耗时分析及result/checkpoint；[持久验证记录](ValidationLogs/project-isolation-i6-layout-sample-native.json)。5992旧证据、Build30 IPA/TestKit、普通HEAD/index及无关工作全部保持。当前验证轮运行输入变化0。

## 当前门槛

本片定向原生验收通过。最后交付仍Build30；完整I6/full、设备Release及手机/流畅度验收没有执行，不生成新安装包，也未完成全部项目发布门槛。UPSTREAM中的native=false是72b07cc创建时的本地审阅快照，本轮真实验收状态以本记录/ValidationLogs为准，没有为改状态而改变冻结运行输入。

下一步回到I6最终验收核对，确认能复用的结果、必要的冻结full/Release范围后另行授权；不再自然重放本配对或追加本轮CI。
