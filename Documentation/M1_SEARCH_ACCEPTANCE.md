# M1 搜索切片验收

## 当前自动验证

最终 [CI 38402285563](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38402285563)，提交 `b95aa4d117984ddb85e81b1901b82e42d453758b`：仓库、Linux/macOS Core 各 14 tests、20 iOS tests、设备 Release 与 IPA 均通过。应用源码编译 warning 为 0，Binding Sendable 与多余类型转换均已清理。首轮成功 run38399996364 的日志/包/报告仍保留。

IPA：`build/XianxiaReader.ipa`，7,365,913 bytes，SHA-256 `9673200a941600e2224870da6d006fa35679abc98a166887d5f4bb1151fd2365`。真机测试包 `build/XianxiaReader-iPhone13-TestKit.zip` 已含原始 IPA、两本原创 EPUB 与 TESTING.txt，CRC/内部 IPA hash 已验证。完整日志/xcresult 位于 `build/ci/38402285563/ios/`，最新日志副本 `build/logs/ios-build.log`。

机器可读证据 M1_SEARCH_VALIDATION_REPORT.json 绑定 52 构建来源文件 hash；根锁文件 11 个 pins 与实际 CI 解析一致。收尾仅文档/证据，代码保持成功 SHA 一致，不会把 skip-ci 文档提交冒充新代码构建成功。

## 实现范围

- 可替换引擎的搜索 provider/session 与 Sendable DTO，不让 SwiftUI 持有 Readium 类型。
- Readium SearchService 扩展，原生 String.Index 匹配同一 TextContentElement 内的文本，避开 3.11 滑动窗口组合字形缺陷；使用 Readium 内容解析与 CSS locator。
- 每批最多 40、上下文各最多 64 字符、界面最多 1000 条，按“加载更多”增量推进。
- 改词/停止/关闭取消任务与 session；request ID 防止迟到结果覆盖新查询。资源错误可见，失败不伪装无结果。
- 搜索结果保留完整版本化位置，通过现有引擎跳转；阅读页滚动 Binding 使用显式 closure。

## 新增自动测试

| 回归 | 已通过的检查 |
| --- | --- |
| 真实 EPUB2/3 | 中文关键词 80 个命中、40+40+结束、目录标题、CSS locator/完整位置 |
| 字符与匹配 | 组合重音、variation selector、ZWJ emoji、inline segment 跨界、英文大小写、字面正则字符、跨段落不匹配 |
| 结果边界 | 95 匹配按 40/40/15 返回、上下文各不超 64、游标结束 |
| 读取故障 | 正文读取错误返回 failure |
| 游标并发/取消 | 并发 next 拒绝、取消后迟到完成拒绝、取消 session 不可重启 |
| UI 生命周期 | 迟到 provider/session 释放、迟到页不污染改词结果 |
| UI 上限/跳转 | 显式加载更多、1000 条停止；空/超长输入不调用引擎，opaque 位置委托与跳转错误可见 |

原 9 个 iOS 测试全部保留，加 11 个上述测试，共 20。Linux/macOS Core 14 tests 无变更，CI 均再次独立运行。

## 尚未验收

完整 M1 仍需真实分页/滚动/链接/图片/中文排版、位置恢复及搜索命中定位体验；用户设备为 iPhone 13 / iOS16.6.1 / TrollStore，步骤和记录见 DEVICE_ACCEPTANCE.md。API/模型测试不代表实机页面通过。

搜索不跨段落/资源、不支持 regex/模糊查询；1000 是界面保留上限，不是完整总命中数。Readium 内部一次解析一个 XHTML，大章节内存与取消延迟未实测；详见 SEARCH_DESIGN.md 和 M5 性能计划。
