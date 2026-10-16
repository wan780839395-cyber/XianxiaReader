# 当前交接与恢复点

更新时间：2026-10-16（Asia/Shanghai）

## 最新断点

第二候选750191d0370fcab4a7889d3a0765c43fa5b470b0，CI38833282829已completed/success；完整日志已核89集成+11UI零失败、test/export/summary/recording均0和Release18构建成功。658588276字节诊断/实际IPA下载中，联合验证与原生复核未完成，未生成交付包。Linux119/四Release探针已下载核过；Apple/iOS100/Release18尚待。首候选f957f465/CI38831994670因为我新增modifier与App已有ReaderSurface同名而Swift编译失败，iOS0执行、test65无IPA；只改自己新modifier名称ReaderPanelSurface后重跑，原正文wrapper/引擎/全部旧断言不动。423语法新增0与17工具过，原HEAD/空index/M2/M3/29包/备份保持。下一步下载完整Apple结果，检查实际100iOS/119各平台/Release18/真实锁/504blob，再用review_depth.py看原生图/视频/连续帧与compare_depth.py对照Build17；完成前不运行package_depth.py/finalize_depth_docs.py，最后preserve_depth.py与私有index快照。以下为发展检查点。

## Build18 开始检查点

用户认可Build17整体可用/观感，指出部分扁平、生硬并授权继续。本轮先做与反馈直接相关的M4原生面板层次/按压反馈/菜单柔和过渡；不铺开新引擎和卷页/自动滚动。仅记基本自用，未逐项确认巨段TXT满页/FPS/设备矩阵。

按AGENTS顺序读文档并核实际Git/文件/日志/任务：Build17 CI38775427080成功，504编译源blob/782维护文件/29包/七旧备份及原HEAD/空index/M2/M3核过，当前tip e5f6a44a。783路径开始备份与hash见m4-depth-build18-start.json；Build17完整交接归档HANDOFF_M4_BUILD17_DELIVERY_2026-10-16.md。无遗留构建/下载进程。源码尚未修改/编译，不写成已验收。

## 范围与验证

拟只改App阅读原生chrome/设置样式、增加实际UI按压核验并升Release18，不动Core/Adapter/Vendor/完整Locator/锁/原书/schema3。静态检查/17工具、各119Core、原99项iOS保持并加1项普通/减少动效按压回归；完整Release18、真实截图/手势视频/连续帧另核。手机FPS/真实系统可访问性/普通签名/TrollStore与巨段TXT满页限制继续分列。所有正常index/HEAD与旧包保持；只用私有index快照。

## 下一步

查Apple公开ButtonStyle/层级/动效文档，落实适用iOS16的最小样式；再完整验证，设计/交接逐步记，不假定上一命令成功。

## 源码落地，Windows验证前

已在ReaderVisualStyle/菜单/设置实现实色层次、边光/轻投影、原生ButtonStyle按压/短回弹和减少动效即时色彩反馈、短菜单弹簧；project.yml升18，新增1实际UI长按单次激活/44pt/浅深色回归。只改App/TestsUI/project配置，不动Core/Adapter/Vendor/锁。官方API适用版本及LiquidGlass仅参考原则的区别见READING_DEPTH_DESIGN.md。源码未编译；现在先423语法/17工具，随后私有index审阅保存候选、完整119/100/Release18与原生复核。

## Windows通过，候选审阅与完整CI前

423语法新增0/54 pristine限制与17工具测试通过；第一次静态发现我编辑版本号时YAML缩进错误，已在送检前修正，原错误日志保留m4-depth-build18-windows.json。现按实际六文件生产/测试差异审阅，私有index保存候选后完整CI，源文件无编译结论；预期119Core各平台/100iOS/Release18。

## 首候选完整CI已启动

实际候选f957f46547bfd729e04e3963234626a9bb67c2bb，CI38831994670。504运行/验证blob已按真实Git读取，Packages/Vendor/锁/scripts/workflow与已过Build17完全一致；原UI test bodies完整未动。Windows423新增0/54限制与17工具通过，原HEAD/空index/M2/M3/29包保持。等待119Core各平台/100iOS/Release18，之后逐项原生截图/视频连续帧；没有交付包。

## 首轮Linux已核，Apple尚待

CI38831994670 Linux完整artifact已下载核119/119Core及四组Release长TXT探针通过。Apple job进行中，尚无Swift编译/iOS/Release18结论；本地仅本轮watcher，生产/测试源保持候选不动，待完整结果和真实原生素材。

## 首轮真实编译失败，命名修正后第二轮验证前

CI38831994670各119Core/四Release探针每平台通过；Swift错误为新增private ReaderSurface与既有App/Reader/ReaderSurface.swift同名，iOS0执行、test65，严格无IPA。完整日志/xcresult/472KB ZIP CRC与回执m4-depth-build18-first-failure.json保留。只将自己的装饰modifier改名ReaderPanelSurface，原正文渲染wrapper/引擎/旧断言不动，不追认旧候选成功。现在Windows重核后第二候选完整重跑。

## 第二候选完整CI已启动

实际候选750191d0370fcab4a7889d3a0765c43fa5b470b0/CI38833282829。相对首候选生产/测试差异仅ReaderVisualStyle中新modifier的两个名称位置；其余产品/测试保持，423语法新增0再次通过，17工具仍为同一未变脚本已通过记录。504真实blob已刷新；候选严格等待119各平台/100iOS/Release18，不能把首轮0测试unknown写成通过。

## 第二轮CI成功，实物下载与联合/原生验证前

API三个job成功、完整日志已核，仍需下载真实658MB诊断ZIP/xcresult/原生素材和IPA，验CRC/三锁/119各平台/100iOS/504blob/Release18；再审原生对照与按压采样。不能把API success直接当手机验收，当前无用户交付包。

## 完整诊断已下载CRC通过，联合验证与原生复核前

第二轮659MB ZIP/完整xcresult/日志/原生素材已解出，真实IPA检查Release18/min16/iPhoneOS arm64/0755/系统SQLite/Notices/CRC通过。源码编译警告错误0，系统WebKit40/AppIntents7消息仍保留，不称所有日志零告警。现在validate_depth.py finish联合119Core/100iOS/四探针/三锁/504blob/旧29包，再对照原生画面与按压采样，未核原生前不生成交付包。

## 第二轮自动全过但原生视觉不收，第三轮前

CI38833282829各119Core/100iOS/Release18及真实IPA/三锁/504blob/29旧包联合核过；32原生截图与三组Build17对照已看，底部白菜单有文字/图标投影灰晕，自动通过不等于视觉通过。新按压三录屏只做总览提取未审阅，不写完成。659MBZIP/完整xcresult/实物/视觉拒收回执m4-depth-build18-second-native-rejection.json保留，不交付第二候选。只把新ReaderPanelSurface阴影从内容容器移到单一背景fill，再叠渐变与边线；不改正文/引擎/按钮/测试。分页孤立PNG本轮又全透明，EPUB整窗可见完整文字；巨段TXT仍两行/留白，限制保持。现在Windows重核后第三候选全跑119/100/Release18，再重新原生验收。
