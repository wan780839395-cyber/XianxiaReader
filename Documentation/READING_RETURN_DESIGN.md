# 回看不丢位置

2026-10-16，Build22完整自动门槛及选定原生复核通过并交付，手机矩阵仍单列。

目录、书签、搜索是本片的显式跳转入口。第一次跳走前获取完整文字Locator，成功跳转后显示一个轻量底部条：“回到跳转前”及“留在此处”。多次查看仍保留最初出发处；成功返回或主动留在此处清除。失败保留旧返回点，显示原错误并允许重试。返回不会创建反向历史，无无限栈、正文副本或新schema。条沿用ReaderPalette/ReaderPanelSurface/ReaderPressStyle，44pt命中区，短160ms透明过渡服从系统/应用/阅读减少动效；正文视口不因条出现重新排版。

进度语义保持现有规则：正常位置回调仍保存当前所在处，不冻结到出发位置。背景/关闭不隐式返回，重开仍在实际当前进度；返回点只在本次打开会话的内存中，关闭清除。此处不承诺跨关闭保留临时返回点。普通手动翻页/滑动、正文内部链接及未来地图导航不创建返回记录；只覆盖这三个已有产品入口，后续扩展另设门槛。

ReadingInterfaces新增captureCurrentPosition，App只持ReadingPosition，不持Readium Locator。ReadiumAdapter先暂停/完成慢滚位置采样，再用已有有界DOM锚点方法获取当前位置；要求稳定视口/已就绪布局/完整采样成功，失败拒绝跳转，避免仅用落后的通知位置。Vendor的preserveCurrentDOMLocationForModeChange只增加可忽略Bool结果及取消检查，原采样、布局不动时的身份校验和完整DOMRange/viewport offset不改。EPUB沿用ReadiumPositionCodec，TXT沿用内容身份/章节与局部byte/UTF16锚点，不新增百分比回退或读取整本正文。

ReaderViewModel为每次显式导航分配request ID，拒绝重入；获取锚点和导航每次await后核取消/open session/request。关闭清空请求和返回点，旧请求defer只清自身身份，不能清掉重开后的新导航。成功才发布返回点，失败保持原状态。慢滚在进入/返回前暂停，不自动恢复；排版/模式变化仍由既有锚点机制负责，返回使用完整文字位置。

参考：本轮重读[KOReader官方手册“Go back to previous location”及Skim](https://koreader.rocks/user_guide/)，其目录/书签跳走后便捷返回与Skim出发点是交互依据。该项目有多级前后导航、电子墨水刷新及Lua实现；本片只取一个出发点的明确交互，不复制UI/代码，不引入多级历史或其他引擎。实际API依据本仓锁定Readium3.11及维护Vendor源码；未升级依赖/JS bundle或引入新库。

验证要求：保留原测试主体；新增获取失败/导航失败重试/连续三入口/当前位置持久化/关闭重开/捕获取消及迟到回调不影响新session。真实EPUB分页与连续模式非零文字/3px往返，TXT巨段第2有界资源/byte+UTF16+3px往返和静止重开、原件hash；真UI目录/书签/搜索/留在此处/浅深色/额外减少动效及实际原生录屏。完整Linux/macOS Core、iOS与严格无签名Release22后，检查原PNG/视频/原始帧再打包。Windows语法不是编译，模拟器不等于手机流畅度、辅助功能或普通签名/TrollStore验收。M4整体未完成。

## 实际结果

Build22回看返回通过[完整CI38871744221](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38871744221)，实际编译源`3cb1d220f324303a979d6dee5c6803f1c9a1bc38`。Linux/macOS各127Core、iOS124/124，失败/跳过0；test/export/summary/recording退出0，严格无签名iPhoneOS arm64 Release22/min16。三份六pins锁、507源码blob、每平台四长TXT Release探针已核。Windows426语法新增0/54既有语法限制、17工具通过；语法不是编译。

目录、书签或搜索跳转后显示轻量“回到跳转前/留在此处”小条，沿用灰绿浅深色表面/44pt按钮，160ms淡入淡出尊重减少动效。连续查看多个位置保留最初完整文字锚点，成功返回/留在此处清除；失败保留可重试。进度仍保存当前所在处，后台/关闭不隐式返回，重开当前实际进度；临时返回点会话内单个、不跨关闭保存。慢滚跳转前暂停，返回不自动运行。普通翻页/拖动/正文链接暂不创建返回记录。

ReadingInterfaces完整位置capture→Adapter有界DOM锚点；Vendor既有采样仅补Bool成功和取消校验，布局/JS/依赖锁不变。每个await后核open/request/navigator身份，重复跳转拒绝，旧请求不能清新session。原完整EPUB Locator/TXT byte+UTF16和12资源上限保持，无新Core/schema/正文缓存。受改测试文件中57个原测试主体保持，新增8项回归（4生命周期+真实EPUB双模式/TXT各1+2真正UI）；实际取舍见READING_RETURN_DESIGN.md。

安装`build/XianxiaReader-ReadingReturn-Build22.ipa` / SHA256 `97760b91f7d5e15950083b9b2116d8a9d1e1a6e2903542a8cc39b902e56b01c9`；原创样书包`build/XianxiaReader-ReadingReturn-Build22-TestKit.zip` / SHA256 `55e7496dc26bf7a7459894a1fc8be93773bce71792323e2e9a709b54c2f618d2`。正常覆盖更新保留书库，+菜单确认0.0.1 (22)。37旧包+两新包、ZIP内部IPA/原创材料/10原生Preview核过。

原生复核范围：本轮62张原生PNG/11表全部复核，alpha全255（含新增EPUB连续/分页与TXT完整位置3张、新返回UI7张）；三段实际UI录屏138.16/36.24/28.25s的完整1秒总览15表及四窗口126个原始VFR帧/12表已逐张看过，PTS倒退0、无插值。浅深色单返回条、返回/留在此处/书签与搜索、重开当前第二章和原减少动效退出菜单在这些素材中符合语义；普通动效淡入淡出、额外减少动效即时控制保留，选定序列通过。跳转存在明确spinner；目录/书签/搜索sheet沿用浅色；启动白页/测试清理主屏不作阅读画面或性能证据。17条真UI原视频均保存，本轮只复核其中3条，不宣称全部视频/设备矩阵通过。

普通签名/TrollStore、真实系统Reduce Motion/VoiceOver/增强对比度/旋转、手机响应/FPS/功耗与全样书矩阵仍待核。自动检查/Swift编译/模拟器阅读/普通设备/TS分列，M4整体未完成；历史各轮限制不追认。

首轮3637dac/CI38866913465实际123/124（旧115过/1失败、新8全过），原减少动效UI退出慢滚后reader.mode未命中。完整1.13GB诊断/原summary/失败录屏留存；根因未确认。当前完整重试的507运行源码object与首轮相同，仅文档不同；不把重试成功称根因修复。用户已反馈Build21手机减少动效退出慢滚能正常回到菜单，仅接受该具体行为，不扩大为Build22或完整设备矩阵。既有系统目录/书签/搜索sheet的完整深色样式仍需后续统一，本片主题复核仅覆盖返回条及正文。
