# 回看不丢位置

2026-10-16，Build22候选已接入，尚未Apple编译或交付；Build21仍是已交付版本。

目录、书签、搜索是本片的显式跳转入口。第一次跳走前获取完整文字Locator，成功跳转后显示一个轻量底部条：“回到跳转前”及“留在此处”。多次查看仍保留最初出发处；成功返回或主动留在此处清除。失败保留旧返回点，显示原错误并允许重试。返回不会创建反向历史，无无限栈、正文副本或新schema。条沿用ReaderPalette/ReaderPanelSurface/ReaderPressStyle，44pt命中区，短160ms透明过渡服从系统/应用/阅读减少动效；正文视口不因条出现重新排版。

进度语义保持现有规则：正常位置回调仍保存当前所在处，不冻结到出发位置。背景/关闭不隐式返回，重开仍在实际当前进度；返回点只在本次打开会话的内存中，关闭清除。此处不承诺跨关闭保留临时返回点。普通手动翻页/滑动、正文内部链接及未来地图导航不创建返回记录；只覆盖这三个已有产品入口，后续扩展另设门槛。

ReadingInterfaces新增captureCurrentPosition，App只持ReadingPosition，不持Readium Locator。ReadiumAdapter先暂停/完成慢滚位置采样，再用已有有界DOM锚点方法获取当前位置；要求稳定视口/已就绪布局/完整采样成功，失败拒绝跳转，避免仅用落后的通知位置。Vendor的preserveCurrentDOMLocationForModeChange只增加可忽略Bool结果及取消检查，原采样、布局不动时的身份校验和完整DOMRange/viewport offset不改。EPUB沿用ReadiumPositionCodec，TXT沿用内容身份/章节与局部byte/UTF16锚点，不新增百分比回退或读取整本正文。

ReaderViewModel为每次显式导航分配request ID，拒绝重入；获取锚点和导航每次await后核取消/open session/request。关闭清空请求和返回点，旧请求defer只清自身身份，不能清掉重开后的新导航。成功才发布返回点，失败保持原状态。慢滚在进入/返回前暂停，不自动恢复；排版/模式变化仍由既有锚点机制负责，返回使用完整文字位置。

参考：本轮重读[KOReader官方手册“Go back to previous location”及Skim](https://koreader.rocks/user_guide/)，其目录/书签跳走后便捷返回与Skim出发点是交互依据。该项目有多级前后导航、电子墨水刷新及Lua实现；本片只取一个出发点的明确交互，不复制UI/代码，不引入多级历史或其他引擎。实际API依据本仓锁定Readium3.11及维护Vendor源码；未升级依赖/JS bundle或引入新库。

验证要求：保留原测试主体；新增获取失败/导航失败重试/连续三入口/当前位置持久化/关闭重开/捕获取消及迟到回调不影响新session。真实EPUB分页与连续模式非零文字/3px往返，TXT巨段第2有界资源/byte+UTF16+3px往返和静止重开、原件hash；真UI目录/书签/搜索/留在此处/浅深色/额外减少动效及实际原生录屏。完整Linux/macOS Core、iOS与严格无签名Release22后，检查原PNG/视频/原始帧再打包。Windows语法不是编译，模拟器不等于手机流畅度、辅助功能或普通签名/TrollStore验收。M4整体未完成。
