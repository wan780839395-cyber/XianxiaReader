# 当前交接与恢复点

更新时间：2026-10-14（Asia/Shanghai）

## 最新实际断点

2026-10-14 remote compact 失败后恢复检查点：已按 AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE 读取。实际 HEAD 为 `6d76174`，工作区有 10 个已跟踪改动及未跟踪 Vendor/ReadiumToolkit、许可、千章样书与生成器；均保留并在 `.cache/recovery/` 保存含逐文件 SHA-256 的恢复快照。尚无本轮连续模式编译/CI/设备验收证据，不能将下文旧“Git clean/尚未实现”当当前源码事实。未发现属于本项目的遗留构建/测试进程；其他项目及 Codex 进程保持原状。恢复从本地扩展源码/工程/测试审查开始，先修复验证入口与可验证缺口，再真实解析及完整 CI。

恢复子步骤1（测试/CI前）：370个中断文件快照在 `.cache/recovery/20261014-092934/`。GitHub 最近run仍是38434939423/Build3，无连续模式run；`build/logs/continuous-docker.stderr.log` 的实际失败是 dockerDesktopLinuxEngine pipe不存在，没有挂起的项目Docker任务。本轮不重置Docker。已补Vendor完整文件/hash核验和Vendor Swift grammar覆盖，新增真实首次解析开关；只有真实resolver生成并通过原10个传递pins对比的锁才能进入测试。首轮解析artifact须原样纳入根锁文件，并关闭开关完整重跑，不能手造锁文件。现准备Windows结构/语法/tooling验证，再以独立 `codex/` 候选分支快照运行macOS CI；本地main及所有未提交改动保持可恢复。

恢复子步骤2（首轮CI前）：Windows结构/SQL/四本EPUB、362 Swift语法delta通过，9原tooling通过。新增Vendor来源/锁漂移回归待运行。tree-sitter在原始3.11源码有54条已知语法限制，已逐文件与真实3.11 Git blob/hash核对并记录精确诊断签名；没有新增诊断，这不是Swift编译通过。连续候选已有双章同屏/逆向、fragment+DOM恢复、高度变化、千章窗口与关闭回归，但均尚待实际执行。候选分支拟为 `codex/m1-continuous-recovery`，以独立Git index生成快照，不暂存/清理本地main改动；首次真实解析run需保留完整diagnostics和锁文件。

2026-10-14继续开发检查点：已核对Git clean、最新Build3报告和无遗留任务。当前开始真正纵向连续跨章独立M1切片。方案为保留Readium3.11上游来源与BSD许可的本地Navigator扩展（非官方已合并功能），使用有界章节窗口及固定尺寸WKWebView viewport，复用Readium解析/资源/CSS/DOM定位。正式源码/依赖/锁文件变更均须真实解析与完整CI，当前尚未实现/编译。旧Build3产物与原分页/章内滚动/搜索回归保留。

M0自动门槛通过；M1搜索、导入、阅读视口/图片切片已通过完整CI，**完整M1尚未验收，真正纵向无缝跨章未实现**。本轮构建/下载/产物核验/原创样书快照复查已完成；无运行中的项目构建/测试或未完成登录/UAC。下一步是现有iPhone13上复测原书图片，并继续独立M1连续滚动引擎切片，不进入M2/M4。

已测源码 `0b30d539d7eb6d557d8b5e5e8efad600c4c4435b`；[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)三jobs全部success。Linux/macOS各14 Core、31 iOS tests、设备Release、Build3 IPA通过。9 Python/tooling和42 Swift grammar通过，grammar不是编译；应用源码compiler warnings=0，6 AppIntents metadata提示单列保留。11依赖pins不变。

本轮保留前次所有导入、viewport、导航、搜索和生命周期改动；没有删除测试、降低图片断言、修改原书/数据库/依赖版本。源码提交已推送main，证据文档收尾提交用skip-ci。

## 产物与验证范围

- 最新IPA `build/XianxiaReader.ipa`：7,393,693 bytes；SHA-256 `12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2`。Build3 /version0.0.1 /com.xianxiareader.app /最低iOS16 /iPhoneOS arm64 /系统SQLite /0755 /ZIP核验通过，CODE_SIGNING_ALLOWED=NO。
- 测试ZIP `build/XianxiaReader-iPhone13-TestKit.zip`：7,296,582 bytes；SHA-256 `02df81e145ffbe4f6a30dbceb6e23c6e69a52e07d78fcbe56e44d5935086722a`。包含上述IPA、chinese-epub2/3和reader-layout三本原创样书、TESTING.txt；CRC与内部IPA hash已核对。
- 完整日志 `build/logs/ios-build.log`；原IPA/Core日志、生成工程/环境/锁文件、SimulatorTests/DeviceBuild xcresult、ReaderSnapshots和测试ZIP备份在 `build/ci/38434939423/`。旧Build2和更早包仍在各原run目录。
- `Documentation/M1_READER_VALIDATION_REPORT.json`：69个构建/验证来源hash匹配已测提交、实际test列表、完整日志/IPA/快照hash、命名附件和DOM尺寸。
- 分页实际正文视口750点、图像712点；滚动812点、图像771点。两张WKWebView快照已查看，原创新封面上下色带完整、比例正常。模拟器为iPhone16Pro/iOS18.5，**只验收原创样书图像，不代表完整模拟器产品/原书/普通设备/TrollStore体验验收**。

## 用户反馈与本轮实现

设备iPhone13 /iOS16.6.1 /TrollStore。用户报告先前安装正常；导入修复后EPUB可以导入（本地/iCloud来源未细分），原书阅读图片仅显示窄横条。用户明确要求上下滑动时本章末尾与下一章开头在同一滚动流中，参考微信读书，不是加下一章按钮。

- ReaderSurface显式完整viewport，独立于菜单；Adapter采用官方frame/autoresizing挂载。
- 横排重排媒体通过公开setupUserScripts按实际innerHeight校准ReadiumCSS原95%媒体保护；不改作者width/aspect/object-fit或原文件，固定布局和竖排保留原路径。
- 目录/书签成功跳转收菜单，关闭/重开过滤迟到导航；搜索跳转同样核对请求ID。
- 当前滚动是章内模式，恢复默认横向跨资源/上一节下一节通路；这**不是**真正纵向连续跨章。
- 3实际页面测试、2导航竞态回归新增；原26 iOS/Core及原2本搜索80命中回归保留。新reader-layout.epub为独立高封面/长短章样书。

原书/CSS未取得，不能认定原书唯一裁切原因；当前Build3安装与原书图像仍待用户复测。TXT仅索引协议，导入/正文/分章未实现。完整书库、字体/主题/排版/音量键、百万字性能、XBook知识库仍按原路线。

## 本轮失败与修复证据

1. 38424689048 /336b21a：App Debug编译完成，test bundle链接静态ReadiumNavigator具体类型metadata失败，31 tests/Release/IPA未执行。改用已有容器的公开UIKit/WebKit查询，保留断言。
2. 38426725252 /43d4b37：31 tests执行，30通过/1导航探针超时。改为双轴可见性交集+对应原生Locator就绪，保留超时最后DOM/位置；不能只看DOM readyState或垂直交集。
3. 38430692977 /7221274：导航/菜单回归通过，图像830.3点大于正文812点，原上限断言失败。校准实际媒体上限并增加尺寸附件；失败也导出快照再返回原test exit，test/export任一失败都停止Release/IPA。9 tooling tests覆盖此控制流，最终本轮完整通过。

三条原失败记录在Documentation/ValidationLogs/m1-reader-*-failure.json，完整日志/xcresult在各原run目录。过程检查点 `HANDOFF_M1_READER_HISTORY_2026-10-14.md` 保留，历史“运行中”不覆盖本文件。

## 下一可恢复步骤

1. 将测试ZIP传到现有iPhone并解压，分享IPA给TrollStore正常更新；保留应用/书籍数据，不卸载或删除数据库。先复测原书图片，再导入reader-layout检查上下标记；目录/链接、搜索/书签、章中段后台/重启恢复分别记录。见DEVICE_ACCEPTANCE.md。
2. 按CONTINUOUS_SCROLL_DESIGN.md实施真正纵向连续跨章：有界资源窗口、双章同屏/正反向惯性、延迟图像高度变化、原始Locator/搜索/书签/恢复全套回归。保持Readium排版/稳定分页路径，不拼接整本HTML，不用瞬间跳章冒充无缝。
3. PR811仅在忽略cache做apply --check通过，未应用/运行；初查整本估算空白与仅按progression定位缺口。正式依赖仍3.11，不直接切未经验证的PR，不改SourcePackages缓存。引擎扩展须明确版本/许可证/补丁、真实解析锁文件并完整CI。
4. 每个可恢复子步骤/生成/构建/测试前更新本文件，阶段后同步PROJECT_STATUS/ROADMAP/ARCHITECTURE及FILE_INVENTORY。没有新任务/自动化时不宣称后台永久维护。

## 环境与历史边界

Windows11 /PowerShell7.6.5 /Git2.54 /Python3.11，本机无Xcode/Swift；CI macOS15/Xcode16.4/Swift6.1.2/iOS18.5，设备最低iOS16。Docker Desktop4.95.0/engine29.8.2已恢复，用户原容器/socket备份保留，不reset/prune。

私有仓库 https://github.com/wan780839395-cyber/XianxiaReader ，main跟踪origin/main，CLI已授权，路径.cache/tools/github-cli.json，不输出令牌/重新生成设备码。Root Package.resolved来自真实CI，复制到workspace，resolve/test/build严格使用11 pins。project.yml唯一工程源；禁止localhost HTTP主要预览。

旧M1_IMPORT_VALIDATION_REPORT.json属于Build2的26 tests/54 hashes，M1_SEARCH属于此前搜索，IOS属于M0，CORE是本机Linux，VALIDATION_REPORT仅静态；不混合覆盖。旧38409222759由Agent提前取消，当时26 tests已过、Release中断，不写成源码失败。各历史handoff/失败记录保留。

GitHub artifacts保留14天；忽略的build/.cache不随clone。当前cache有inspect_ci_ipa/record_reader_ci/make_reader_testkit/finalize_reader_docs辅助脚本；不存在时按README重建CI并核对报告，不能假定cache已保存。恢复先读PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核对实际Git/进程/完整日志与hash，不用聊天记忆替代事实。
