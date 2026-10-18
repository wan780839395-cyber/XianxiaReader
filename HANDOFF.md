# 当前交接与恢复点

## Build28 阅读进度依赖与菜单顶部（2026-10-18）

实际源`8acc3f2f7980b3d291155936184f36ddc42d4c84` / `codex/m4-reader-chrome` / [完整CI 39113019568](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/39113019568)。Linux/macOS Core各137，iOS161/161（135集成+26真UI）失败/跳过0，test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release28/min16。三锁六pins、546编译资源blob、六原字体/OFL与每平台4组长TXT Release探针已核。Windows448语法新增0/54既有Vendor限制、17工具通过，语法不是编译；受改测试文件38个原test主体不变，3新增，其他旧回归完整重跑。Core/Adapter/Vendor/CI/schema/依赖均保持Build27。

进度从ReaderViewModel广泛发布改为独立稳定对象，只有章名/进度条小视图观察摘要；相同显示摘要不发布，但每个完整Locator及原异步SQLite写入都保留。真实ViewModel/SQLite的65事件回归：root通知0、摘要通知2，最后完整字节/版本保存且关闭后迟到事件拒绝。该计数不是手机FPS、全部卡顿根因或数据库写入减少。顶部浮动菜单补页面色底与24pt渐隐，无blur、不接收触摸，不改引擎viewport、安全区/排版/位置；原44pt和系统/额外减少动效保持。

安装[XianxiaReader-ReadingChrome-Build28.ipa](build/XianxiaReader-ReadingChrome-Build28.ipa) SHA256 `700551af9cecd5b98fd22b7043eba690657392064dc5091de8f45c2925dd3958`；[原创样书/字体许可/原生Preview测试包](build/XianxiaReader-ReadingChrome-Build28-TestKit.zip) SHA256 `7a57affea60a83fb6c6519edecf7709ac07266c2f57da412441396dc4f36636d`。覆盖安装保留书库，+菜单确认0.0.1 (28)，49旧交付包和全部未提交工作/1047原路径/18恢复ZIP保留。

实际原生复核：本源22张选定PNG/4表已实际查看，另直接查看浅深色正常菜单两原图；4条完整原录屏一秒总览15表已查看；3个原始窗口120帧/12表已查看。浅深色正常/减少动效静态菜单、第二章67%进度、目录跳转及所列手势可接受。正常显隐窗口各有一次源PTS回退，减少动效窗口仅1帧，仅接受列明画面，不推断全时序/FPS。

用户对Build27总体认可并要求继续，不推定全部手机矩阵通过。iPhone13/iOS16.6.1/TrollStore的阅读/设置帧时间、内存/功耗仍待专项；Build27标准字体打开/导入已由用户确认成功（实际来源/样例），微信QQ/Alook与TTF/OTF逐项组合、普通签名/全部File Provider/VoiceOver/系统大字/旋转/减少动效完整矩阵仍单列待核。旧章首留白/分页快照不由此追认；慢滚隐藏菜单时状态栏透字仍可见，全页安全区未验收；无Share Extension、字体删除/无限字体、可变轴、单书覆盖或M5功能。先收本片菜单/跨章进度/设置手感反馈，再按PERFORMANCE_TEST_PLAN测正文DOM采样、主线程与渲染；本片不盲改定位管线。取舍及Apple官方来源READING_CHROME_DESIGN.md。M4整体未完，取消关机继续生效。

## 恢复与保全

正常HEAD6d761749/空index/M2 e6f31d85/M3 44af41f0保持；私有codex/m4-reading-appearance保存最终文档tip，实际编译codex/m4-reader-chrome保持上述源。开工1047路径/49旧包/17旧ZIP及新增18th ZIP见m4-chrome-build28-start.json；最终546源码blob/51交付包/18ZIP、正常HEAD/index与远端树结果见build/ci/39113019568/final-preservation-check.json及final-delivery-receipt.json，必须核实际存在。

本轮完整CI原件保留；历史文字/summary/metadata和根IPA/TestKit、源码/素材/恢复ZIP保持，历史大原件清理以m4-chrome-build28-ci-retention.json实际回执为准，不存在不假定成功。用户取消关机持续有效。本轮开发检查点已归档HANDOFF_BUILD28_DEVELOPMENT_2026-10-18.md。先读AGENTS→状态→交接→路线→架构，再核实际文件/日志/进程；不重复启动已有任务。

下一步先收本片手机顶部遮罩/显隐/跨章进度/菜单与设置反馈，再按性能计划定位DOM与渲染成本；不要把root通知计数等同于手机帧时间，不盲改位置事件或丢掉末次完整锚点。M4未完，不提前M5。

## 最终保全前检查点

根Build28 IPA与TestKit已真实生成，ZIP CRC/内部IPA/6张本轮原生Preview及原创样书/字体原许可逐摘要通过。按已审绝对路径/最新run排除/51唯一包摘要计划，已清理旧39107016454的3274个大原件，1895598835字节，76文字/metadata保留，最新39113019568完整诊断未动；旧Build27报告与原生记录已注明本地原件历史边界。下一步核546源码blob、1047原路径、51交付包、18恢复ZIP、正常HEAD/index/M2M3，私有最终文档快照推送并核远端树，最后记录实际无遗留辅助进程。尚无final receipt时不得假定该步完成。
