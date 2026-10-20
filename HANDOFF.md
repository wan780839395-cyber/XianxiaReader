# 项目交接（2026-10-20 12:33上海，初始化对照恢复）

## 当前实际断点

39365686520/c9dcba9由Agent取消（非源码失败），完整artifact12240662458/87685字节SHA74e133954dc71cd597b14db46a4f11225ad3d2d508cb818941740a0bcb1f5ba9/CRC与556来源核。原生测试0执行，无summary/测试退出码，xcresult仅Staging未完成。Session日志04:12:47.590发出宿主App launch请求（wait_for_debugger=1）后未记录bundle连接或case开始，标准输出0字节，Agent04:21取消；源码已构建/安装至宿主启动阶段。不能说这37.6分钟由测试fixture、定位或环境独有原因造成。fixture本体没有运行，也未证明pendingLocation假设。

watcher38944/PID26412与receiver40407/PID20560均退出0，恢复核CIM实际CommandLine。普通HEAD/index、旧包/已完成生产改动保持。当前无原生任务。

## 下一项（同一生产源，只修fixture与观测）

initialization-visible-control已应用（before-initialization-visible-control备份）：先用公开导航把one.xhtml移进viewport，再仅检查几何当前的WKWebView等待原生font-ready屏障；失败时隐藏/未准备窗口只记native几何，不再等待其DOM。原30秒字可见断言、原字体替换/锚点合同保持。仅修测试前置顺序，不能当成前轮未进入测试的原因。

同时把现有30分钟有界capture_native_resources监测用于initialization-pending，并保留testmanagerd/debugserver/xctest进程名（不含参数/书文），下次若宿主仍起不来能分清App进程存在与否及内存状态；不改真实功能预算/不重试用例。预计3源文件（测试/诊断选择monitor/监测器），生产仍为176303d。已备份并应用，Windows453语法0新增/54限制、工具26pass3本地POSIX跳过、Bash通过；冻结/派发1项待执行。

只有首个target-resource-in-viewport、原3阶段完整，失败后attached/alpha可见、released/faceReady/readyObserved/settled均true、x0且wordVisible=false才支持初始化覆盖。若更早失败/原字保留就不应用缓存Vendor候选；候选仅将pendingLocation更新移至isSpreadLoaded判断前。

## 已验证和发布边界

39362754281/176303d幂等片2/2，真实编译0诊断、test/summary/export0，完整artifact12238663866 SHA/CRC与556核；30字体观测errorMessage全nil。首开真实模式变化与后续重复偏好有别，不声称guard唯一解释所有历史初始化故障。

39358438791/e2c7990原6项5/6：same-word viewport、真实字体重开、跨章、六字体连续、浅深旋转通过；hidden最初深字失败（未换字体），另有12条连续字体错误，后来幂等2项清零。本轮full/Release自动跳过，无Agent取消。已看深灰横/恢复竖和宽viewport3原图；未整段录屏/手机FPS。

最终151集成+29UI=180从未完整通过，设备Release未执行，无Build30；Build29最后交付。后台UI39352276145已1/1，用户Build29手机已暂停。39354867480链接0执行、39357294714docc锁解析0执行都独立保留，原project图已恢复。

普通HEAD6d761749911233122bcd031fcf718d22a19f9e77、普通index空，历史未提交/未跟踪源码、Vendor、53旧包/恢复ZIP保持；不重跑旧apply/freeze、不做R2/R3/R4/M5、无关清理或关机。历史Documentation/HANDOFF_R1_RECOVERY_HISTORY_2026-10-20.md。

## 工具

cua本地浏览器仍报Work设置禁用，未改权限。job REST日志用gh api --allow-escape-sequences原样捕获；404可能未flush，尾部也可能缓冲7分钟，不能据尾部推断挂起。以上宿主断点来自收齐的原始Session与空stdout，不是网页尾部猜测。
