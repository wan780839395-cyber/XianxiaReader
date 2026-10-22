# I5c 搜索边界隔离

完整原生日志有10次/8条唯一源码警告，与I5b CI39712813755逐条完全相同（新增/消失均0）：LibraryAssembly外部符合、BookDuplicateTests的ImportOutcome Sendable、ReaderRenderingTests的UIKit delegate Sendable/preconcurrency；独立搜索包及本片搜索源码警告0。保留真实日志，不静音或扩入本片；现Swift5目标可编译，未来Swift6迁移须另审阅。

2026-10-22 I5c搜索本片完成：ReaderSearch真实独立包拥有原搜索DTO/可选协议与请求/分页/取消/选择编排，只依赖Core及Foundation/Combine。App与ReadingInterfaces保留typealias兼容，无新异步层，原12await、函数正文、发布与清理顺序不变。最终53f7e1f2 / CI39715718761独立macOS8/8、原生13/13，包及App/测试接线真实编译通过。搜索界面/输入、Readium3.11安全搜索服务/限制、ReaderPositions及书库/导入/字体/会话/Core/Adapter/Vendor/资源/锁不改；原生测试正文不改。完整163+29=192、Core137全组、Release/设备/手机未跑，无新IPA，最后交付Build30。详见Documentation/SEARCH_ISOLATION.md与ValidationLogs/project-isolation-i5-search.json。

2026-10-22：本片真实编译及定向门槛完成。用户范围为搜索职责，不改界面、搜索算法、阅读定位或其他功能。

## 所属与合同

- `Packages/ReaderSearch` 是独立SwiftPM product/target，只依赖XianxiaCore；DTO/协议使用Foundation，请求模型使用Combine，支持iOS16/macOS13。编译本模块不需要App、UIKit、SwiftUI、Readium或模拟器；Combine意味着本独立验证使用macOS，不声称Linux支持。
- 原ReadingInterfaces搜索DTO/协议原样迁入，保留公开typealias；App模型保留单一typealias。使用上一片已验证的Swift [typealias](https://github.com/swiftlang/swift-book/blob/main/TSPL.docc/ReferenceManual/Declarations.md)方式，别名指向同一类型，不增加实例、协议转接或异步层。
- 原ReaderSearchViewModel仅将SwiftUI引用改为Combine、删除ReadingInterfaces引用、增加公开访问级别；所有函数正文、Task/await挂起点、requestID检查、发布和清理顺序不变。改词/关闭同步失效旧请求，旧provider返回后释放旧session，旧next/选择错误不能进入新请求，异步取消只持有局部旧session。
- UI仍属于App，ReaderSearchView/Field不变；导航回调沿既有ReaderViewModel/ReaderPositions进入引擎，结果仍携带完整opaque ReadingPosition。新模块不能获取数据库、AppServices、ReaderViewModel或ReaderEngine。
- Readium3.11 TextContentElement扩展、issue876修复路径、40批次/64上下文/1000显示/256查询限制、跨inline而不跨段落合同不变，不收集全书匹配或正文。

## 最小验证与保留

独立8合同保留原5模型合同，并用可控continuation验证关闭期间provider迟到、旧取消完成不得清除新session、旧导航错误不得进入新查询。所有新增屏障都显式释放后再断言。原13原生选择为原5模型、6Readium、1输入法/44pt字段、1搜索/书签/目录返回点合同；原生测试正文不改。

Windows先运行repository语法及Python工具正反例，随后冻结源码，仅一次定向macOS包编译/原生App与测试编译和13例。完整192、Core137、设备Release/IPA、手机/TrollStore验收另属交付门槛，不由本片通过推导。

上一片610运行输入已核对；除本片明确接线与脚本外，书库、导入、Core、字体、会话、位置、ReadiumAdapter/Vendor、资源及锁文件保持原样。失败先保存完整日志/xcresult并证明归属；不修改无关边界换取全绿。


Windows484语法新增0（54既有Vendor限制，非编译）、102工具95通过7 POSIX跳过；最终Linux102/102。首静态projectPackages漏登已被拦截并修正，原repository.log保留，修正后repository-corrected.log通过；未改生产行为来绕过门禁。静态156第一方源/25区/26节点/2精确例外。独立包依赖Combine，仅macOS合同，不声称Linux包通过。新搜索源码编译警告0，实际test/summary/export均0；既有LibraryAssembly外部符合警告按原记录保留。

本轮仅1次派发/1次原生执行：独立包步骤68.0秒（Swift构建51.05秒）；原生步骤965.0秒，其中首原生suite前928.468秒，13用例实际合计4.402秒。独立合同与冷工具/依赖/工程生成/原生编译/模拟器准备成本分开，不以全套重跑补绿。

原件build/ci/39715718761/diagnostic，artifact12399144481/446473字节/SHA8f8530ac60963fa0b4b8f8cc329be301e41256f275d568d0510feadf844c9efa，GitHub digest/CRC/安全完整解压已核，仅清除精确重复ZIP。build/maintenance/I5-search-20261022含before/frozen/scope-audit/result/final-checkpoint，617运行输入与被测源一致；普通HEAD/index及旧WIP保留。恢复先核现场/ref/实际进程，勿重派已完成CI。电脑保持开机。

App界面仍同target，Core依赖仍公开Core自身类型；静态依赖/登记名守卫与独立模块编译各自负责其范围，不宣称整个App或Core类型已形成细粒度防火墙。I6需审阅剩余边界、同源整合及发布门槛；本片不自动启动I6或新功能。
