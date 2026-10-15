# M3 书架左滑与动效（Build12候选，待编译）

2026-10-15。用户确认Build11“都能正常使用”，同时要求左滑移出、网格动画，项目尽量好看流畅。本轮先完成该明确体验反馈，封面替换/重复导入继续后续M3；当前阶段的原生手势、动效与布局一起打磨，不统一拖到M4。

## 左滑与数据真实性

原列表是ScrollView/LazyVStack，SwiftUI原生swipeActions要求List行。本轮列表改原生List，去掉系统背景/分隔线，以行内边距保留现有紧凑卡片。右滑入口在尾侧（中文LTR下左滑），只露出灰绿色短文案“移出”按钮（无障碍名称保留“移到回收站”），allowsFullSwipe=false；继续使用既有确认与Core真实提交，取消/写入失败不移出。灰绿色普通按钮不设destructive role，避免把尚待确认的操作交给原生破坏性删行反馈；这是状态一致性取舍，实际取消/提交用UI手势回归核实，不凭推断宣布框架bug。

长按菜单入口保留。语义始终是可恢复移到回收站，不永久删除原书或释放原件空间。Core/schema2/数据库/文件清理/Reader/位置/codec均不改，原67集成测试与91Core完整保留。

## 动效与无障碍

按稳定UUID的可见序列变化，网格用0.34秒response、0.88damping的短spring补位，移出/恢复结合0.94缩放与透明度过渡；排序/筛选沿用稳定身份重排，布局切换0.2秒淡入淡出。回收站行恢复0.25秒过渡。数据仍只在真实提交后变化，不通过提前删卡片伪装保存成功。使用LazyVGrid/List虚拟化，封面加载和数据库不搬到主线程。

读取只读系统accessibilityReduceMotion，或自定义可写libraryReduceMotionRequested附加请求（逻辑OR，不能反向取消系统减少动态）：关闭自定义缩放/移动动画和继承动画，不强行动效。DEBUG夹具通过自定义key请求减少动效，不覆写只读系统key。新增明确书名/作者/进度的VoiceOver标签。不会声称此次已完成全部主题、字体、无障碍或实测60fps；完整主题/排版仍M4，手机长库FPS/p95/耗电仍M5。

## 依据与适用版本

- [Apple swipeActions](https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:))：搜索索引可核对List行与full-swipe语义；正文工具页面要求JS，不能用其页面可达代替实际编译。
- [Apple Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion)与[XCTest swipeLeft](https://developer.apple.com/documentation/xcuiautomation/xcuielement/swipeleft())：公开API，最低系统继续16，真实Xcode16.4/iOS18.5验证另记。
- [c-villain/SwipeActions](https://github.com/c-villain/SwipeActions)：成熟实现可在iOS13任意view自建滑动；本项目iOS16且列表形态适合原生List，因此不增加依赖、不仿造DragGesture去抢滚动手势。仅借鉴取舍，不复制第三方代码。
- [XcodeGen精确2.46.0规范](https://github.com/yonaskolb/XcodeGen/blob/2.46.0/Docs/ProjectSpec.md)：新增bundle.ui-testing target和非并行Test Target，不手改生成工程，真实六pins锁不变。

## 验证与诊断合同

新增独立UI测试target，三项真实XCUITest：列表左滑露出按钮→取消保留→确认移出→重启仍在回收站→恢复；网格长按移出后邻书补位与恢复原序（真实frame断言）；Reduce Motion环境下移出/恢复仍正确。它们调用公开手势与实际App，非直接调用model伪装左滑。六张UI截图与整轮原生录屏保留；看静态终态不算动画验收，须单独查看录屏/连续帧。新总数目标67原iOS+3 UI=70，Core仍各91，四长书Release探针/设备Release全跑。

UI夹具仅在DEBUG接受随机UUID启动配置，使用隔离ApplicationSupport子目录与UserDefaults域，通过正常TXT importer/SQLite API建三本原创小样，不删除生产书库或重置用户偏好。重启同UUID保留状态以验证持久化。Release prepare始终返回nil，不能通过环境开启夹具；交付IPA要核对无XR_LIBRARY_UI_*字符串。Reduced Motion UI测试通过DEBUG的SwiftUI环境验证界面合同，不当用户实际系统设置/手机动效体验已验收。

CI先公开simctl bootstatus/recordVideo录制屏幕，测试后SIGINT结束并等待真实退出、检查MP4存在；录屏、test、summary、附件导出失败均阻止设备包，并优先保留原test失败码。新增工具回归验证录屏失败不能生成成功IPA，原所有失败路径保持。录屏上传完整诊断artifact，正常/失败都保留。没有localhost预览。

Windows397Swift语法新增0/54 pristine限制、17tooling和bash语法通过，仍不是Swift编译。初版AppRoot恢复语法出现Tree-sitter诊断/根节点parent=None诊断崩溃；已将可选await先赋值再解包、保留Release空准备实现，并让根错误节点正常报告而非崩溃，不添加忽略名单/降低门槛。新增Tests/UI进入语法扫描。真正Swift/iOS/Release、截图、录屏和手机验收需分别记录。

首轮083a7d3/CI38674188782 Linux/macOS各91Core/四长书探针通过；App DEBUG编译两处真实错误：Core DatabaseError memberwise initializer为internal，系统accessibilityReduceMotion是KeyPath而非WritableKeyPath。iOS total0、test65/export0/summary0/recording0，Release未执行，完整错误/xcresult/录屏另存首轮失败报告。实际修正仅App局部fixture error和自定义EnvironmentKey（公开iOS13起接口）与系统只读值OR；不为夹具扩大Core公开API或改系统偏好。原67回归及3UI手势门槛保持，修正后须重新完整CI。

第二轮df74aa7/38675354465完成编译，各91Core/四探针与原67iOS通过；3新UI用例均停在打开显示菜单的XCTest AXScrollToVisible，iOS总67/70、test65/export0/summary0/recording0、Release未执行。原生图/AX层级证实菜单位于屏幕内且有嵌套Button包装，日志计算hit point {-1,-1}；实际唯一根因不扩写到所有系统版本。测试改按菜单实际frame中心用公开[XCUICoordinate](https://developer.apple.com/documentation/xcuiautomation/xcuicoordinate)发点击，保留屏内尺寸检查及打开菜单/恢复/进度/原序全部断言，仍是实际手势，不直接调model或跳过恢复。三张首轮手势图已看，左滑/取消/确认/重开及网格补位的前段执行证据保留；最终验收仍需新完整run。

用户看图反馈“移到回收站不好看，和前面不搭”，当前取舍把侧滑大红长按钮改为短文案“移出”与书架灰绿（0.31/0.39/0.36），保留原生手势、完整无障碍名称和回收站确认说明。最终需看实际新图，不把旧红色图当交付视觉。没有因此重写整套主题或更换阅读引擎。


## 成功录屏保留与实画面边界

实际第二轮整轮simctl录屏是基座模拟器桌面，不能证明App动效。XCTest case导出的MP4才显示真实运行App；成功case默认删自动捕获。按锁定[XcodeGen2.46.0 Test Action](https://github.com/yonaskolb/XcodeGen/blob/2.46.0/Docs/ProjectSpec.md#test-action)显式captureScreenshotsAutomatically=true、deleteScreenshotsWhenEachTestSucceeds=false、preferredScreenCaptureFormat=screenRecording，不手改工程。参考[Apple WWDC23测试报告](https://developer.apple.com/videos/play/wwdc2023/10175/)的真实UI录屏审阅流程。最终六图与三个case实际视频另核；基座视频只作诊断，不以文件存在或退出0冒充有效动作画面。不得由视频帧率宣称真机FPS。
