# I6 Swift版本前缀解析本地修正（2026-10-23）

**已修正已知swift-driver前缀解析，本地26/26通过；零CI，未执行原生双臂。**基线为0143f1f5，旧CI39886254329的完整原件和结论保持：显式Double版原生编译/链接通过，随后旧解析器退出2，两臂未启动/退出null，尚无完整同构建配对验收。

## 改动与保留合同

仅改两项运行输入：`scripts/ci_viewport_pair.py`、`scripts/test_viewport_pair_ci.py`。其余617项逐文件SHA保持，包括所有Swift/SDK、原smoke、配对机制、隔离、定位修复、S诊断、默认值、比较条件、生产guard、原字可见断言与预算。

`version_fields`仅在行首识别完整`swift-driver version: 数字.数字.数字 Apple Swift version ...`格式，把已知driver前缀规范化后，交回原七字段解析。完整保留编译器版本及swiftlang/clang build、Target、Xcode版本/build、OS名称/版本/build；七字段完整相等比较与Xcode16.4要求原样保留。不从任意警告中搜索/截断Apple子串；未知额外token、缺失、空值和重复/冲突继续拒绝。

固定[Swift6.1.2官方源码](https://raw.githubusercontent.com/swiftlang/swift-driver/swift-6.1.2-RELEASE/Sources/SwiftDriver/Driver/Driver.swift)在执行编译器版本请求前向stderr写driver前缀并flush；[xtool安装文档](https://github.com/xtool-org/xtool/blob/main/Documentation/xtool.docc/Installation-macOS.md)有同类实际输出。本片只适配固定环境实际出现的无额外token形式，未扩展可选blocklist等未出现格式，也未升级工具链或增加依赖。

驱动其他AST完全一致：源码/Git blob、锁文件、产物/计划冻结、真实环境比较、安全失败停止、真实退出码、原件保存、单构建/双臂路由和预算均未改。

## 直接验证

| 检查 | 结果及边界 |
| --- | --- |
| 真实样本 | 旧CI的环境和三份命令输出内嵌在测试文件，四份SHA与原始字节一致；不依赖下载历史artifact才能运行 |
| 旧/新同样本对照 | 从冻结源码提取旧函数仍报Missing or ambiguous；新函数七字段与真实prepared逐项完全一致 |
| 定向Python | `python -m unittest discover -s scripts -p test_viewport_pair_ci.py -v`：26/26，12.374秒，零失败/跳过 |
| 新拒绝检查 | 七字段逐项变化均在安全测试前停止；缺失/空值/重复/冲突、规范化后重复Swift行和未知driver形态拒绝 |
| 既有驱动合同 | 安全失败不启动冲突、冲突65保持65、提取/来源/产物/实例失败守卫和原件保留均在同一工具模块内通过 |
| 项目静态/语法 | `python scripts/check_repository.py --swift-syntax`通过；484文件、上游54既有限制、新增0；语法不是Swift编译 |
| 范围/保护 | 2项工具输入改变，其余617、76项原件、Build30和普通HEAD/index保持 |
| 原生/完整/设备 | 本轮均未执行；本地runner是假命令/假产物，不授予真实同构建双臂验收 |

恢复目录`build/maintenance/I6-viewport-version-parser-20261023/`保存before、原交接、工具/静态日志、真实字节旧/新对照与范围审计、限定diff、result及最终本地私有快照。旧原件在`build/ci/39886254329/`，未删除/覆盖。[持久验证记录](ValidationLogs/project-isolation-i6-viewport-version-parser.json)。

## 剩余门槛

本轮仅完成解析器实现和本地验证。新版本尚未在真实CI驱动中执行，不能把旧编译成功或本地模拟双臂转为新源原生验收。后续只有用户另行授权才做一次配对原生验证；保持一次构建、安全全部合格才冲突、两臂真实退出，失败先留证且不自动重派。

旧full39735403242仍191/192；连续缩放旧故障、旧S第三次拒绝及I6/Release/手机缺口保持，最后交付Build30，无新IPA。电脑保持运行。
