# I1 设置逻辑快速验证

2026-10-20。实现及Windows工具检查进行中；Apple编译/执行须以最终ValidationLogs/project-isolation-i1.json和HANDOFF为准，不因本文存在而宣称通过。

## 最小模块与保留合同

ReaderSettings本地Swift包仅依赖XianxiaCore，最低iOS16/macOS13、Swift tools5.10；原ReaderSettingsPersistence从App移动到该包，仅公开现有调用需要的类型/成员，排队、错误、owner/request过滤、flush和文件路径不变。Combine来自Apple SDK，不引入OpenCombine、Readium或新远程依赖。Linux Core包保持原有依赖与测试入口。

原7项ReaderSettingsPersistenceTests与ControlledReaderSettingsStorage使用同一份包内测试源，函数主体与原文件一致；macOS SwiftPM无App宿主执行，原iOS XianxiaReaderTests也明确编译该文件，ReaderLifecycleTests继续使用原受控fixture。原151集成+29UI发布门槛不删减。

I0的生产源码单一编译归属继续保持。只对这一份精确测试文件登记sharedTestSources、两个unit-test target及理由；守卫拒绝把该许可用于App/其他生产target。共享测试不意味着运行实体重复或用复制测试掩盖错误。

## 执行入口

- macOS：`bash scripts/test_reader_logic.sh <新的输出目录>`。不传目录时使用build/ReaderLogic；已有目录会失败保留，选择新目录再执行，脚本不删除原证据。
- 现有iOS Build and Test workflow的`reader-logic`选择：仓库静态/工具检查后，仅执行macOS逻辑job；不启动Linux性能探针、模拟器、Readium解析或设备打包。
- `reader-logic-integration`选择：先执行完全相同的7项快速逻辑，再执行原settings诊断（设置/生命周期），验证App导入、公开接口、iOS链接及原行为。不执行完整UI或设备Release，也不生成IPA。
- 原默认完整发布路径保持，ci_ios.sh在Core/iOS原门槛之前增加同一逻辑脚本。快速结果不替代完整发布验收，开发迭代无需反复导出IPA。

脚本保留真实SwiftPM退出码、完整日志和xUnit；verify_reader_logic.py要求原7个名字各执行一次，无失败/跳过/重复/遗漏，同时读取真实show-dependencies JSON，依赖树必须只有ReaderSettings与XianxiaCore。零测试、错误类别或额外依赖不能写成功回执。receipt只承认macOS逻辑，不承认iOS集成、原生体验或发布。

## 影响范围映射

`python scripts/plan_validation.py --changed <仓库相对路径...> --report <输出JSON>`。

工具读取I0的真实声明图与逐文件编译归属，计算反向影响；同一测试源的两个target都纳入。文档/工具改动与生产依赖分别规划，设置逻辑优先运行快速入口；App/引擎受影响时仍列出iOS/原生检查。未知/删除文件、锁、工程、资源及共享配置保守转为完整范围。未登记依赖或源码先由架构守卫失败；工具只给计划，不执行命令、跳过门槛、复用UI结果或签发验收。

当前App仍共用target，影响范围会偏保守；R2/R3/R4/I5拆分后再逐步细化。不能凭文件名推断字体、位置和生命周期已经互不影响。

## 已核原始资料

- [SwiftPM swift-6.1.2-RELEASE SwiftTestCommand](https://github.com/swiftlang/swift-package-manager/blob/swift-6.1.2-RELEASE/Sources/Commands/SwiftTestCommand.swift)：核对parallel、xunit-output及XUnitGenerator的真实字段。该版本非parallel路径不生成所需并行xUnit，故入口明确使用parallel；不更换测试框架或放宽原断言。
- [XcodeGen2.46.0 ProjectSpec](https://github.com/yonaskolb/XcodeGen/blob/2.46.0/Docs/ProjectSpec.md#sources)：多个明确源路径与包产品依赖；project.yml仍为唯一工程源，不编辑生成xcodeproj。
- [GitHub workflow_dispatch](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_dispatch)：手动触发的workflow文件须在默认分支登记。因此复用已有ios-build.yml的明确选择，不为分支试验新增重复workflow或改main。

本片只封装已实现的R1并补快速测试，不提取R2字体/R3位置/R4会话，不更改主题、设置完成时机、定位预算、Vendor和原真实锁。
