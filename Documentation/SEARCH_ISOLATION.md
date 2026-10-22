# I5c 搜索边界隔离

2026-10-22：实现候选，尚未编译或验收。用户范围为搜索职责，不改界面、搜索算法、阅读定位或其他功能。

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
