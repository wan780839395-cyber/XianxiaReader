# I6 FixedSpread override兼容修正（2026-10-23）

针对[39908431098的明确编译断点](I6_VIEWPORT_S_READ_NATIVE.md)完成最小本地修正。**签名/透传合同与本地语法检查通过，尚未原生编译验证；零CI。**不把候选写成编译已验收，也没有新的S读数或1767根因结论。

## 改动与保持

- `Vendor/ReadiumToolkit/Sources/Navigator/EPUB/EPUBFixedSpreadView.swift`仅两处：override补与父类相同的`fixtureReadObserver: ((String, [String: Double]) -> Void)? = nil`；原`return await super.evaluateScript`调用将同一观察者透传。未改变父类方法或其他调用点。
- `Vendor/ReadiumToolkit/UPSTREAM.json`保留原baseline摘要，新增FixedSpread的本地覆盖摘要；原Readium3.11版本/依赖/语法基线保持。
- `scripts/test_readium_provenance.py`新增一项窄边界合同检查：父子参数对应与观察者直接透传；反例覆盖旧两参数、类型/标签不匹配及转发nil。它不是通用Swift类型检查器。

原href默认空串、`spread.eval`包装、反斜线/反引号转义、唯一原super await及其顺序保持。精确对照before原件，整份FixedSpread除上述两处外字节相同；无新增await/Task/等待/重试/滚动写入。原smoke、隔离、定位修复、S诊断、生产guard、原视口用例及预算均保持，619运行输入仅3项变化，其余616项一致。

## 本地验证

| 检查 | 结果 |
| --- | --- |
| 旧代码负对照 | 新合同检查在原两参数源码按预期失败，原退出1与日志保留；不是新的原生失败 |
| 修正后定向工具 | provenance文件5项全部通过，含新增合同及4个变异拒绝分支；未跑工具整套 |
| 仓库检查 | 七类静态通过；484 Swift语法通过，54项既有Readium限制保留，新增0；语法不是编译 |
| 精确源码对照 | 父子参数一致、观察者默认nil和直接透传、原href/包装/转义/await数量保持；全部evaluateScript override已扫描，仅FixedSpread一处 |
| 来源与恢复保护 | 616输入、1282项既有证据、Build30、普通HEAD/index保持；候选私有Git中的Vendor摘要另逐项核验 |
| 原生/设备 | 本机无Swift编译器；本轮无原生编译/单例/配对/full/Release/手机验收，无新IPA |

新增检查先红后绿，能拦住这次漏审的具体合同；它不能证明其他Swift编译问题不存在。旧CI构建65、两臂未启动/null及旧full191/192、I6/Release/手机缺口原样保留。

恢复目录`build/maintenance/I6-viewport-fixed-override-20261023/`含before/三文件原件、signature-red-expected、provenance/static/source-contract完整命令/退出/输出、精确差异、source-audit/result与最终私有快照；[持久验证记录](ValidationLogs/project-isolation-i6-viewport-fixed-override.json)。

下一门槛仍是新授权下的一次构建及同例配对，安全全合格才冲突，保留两臂真实退出和S关联诊断。当前未派发，也不自动补跑；1767真实来源仍待原生证据，不关机。
