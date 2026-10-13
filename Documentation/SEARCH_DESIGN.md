# M1 搜索设计与边界

2026-10-13：首次搜索切片 CI 38399996364 已通过全部 20 iOS tests、设备 Release 与 IPA。保持 Readium exact 3.11.0 与现有锁文件；清理一处冗余类型转换后再次验证，完整阶段/设备体验未验收。

## 引擎边界

ReadingInterfaces 定义可选 ReaderSearchProviding 和独立 ReaderSearchSession；UI 仅看到 Sendable 结果 DTO、完整版本化 ReadingPosition。关闭搜索或修改关键词取消当前 task/session，并使用 request ID 拒绝迟到结果。搜索结果位置经 ReaderEngine.go 跳转，不把 Locator/href 解析搬到 SwiftUI。

## Readium 搜索扩展

上游 [issue 876](https://github.com/readium/swift-toolkit/issues/876) 与 [修复 PR 878](https://github.com/readium/swift-toolkit/pull/878) 指出 3.11 ContentSearchService 在拼接/裁剪字符串时组合字形边界可能导致越界。3.11 标签源码确实使用滑动窗口整数偏移，锁文件 revision 没有该修复。不能据此直接换到尚未验证的 4.0 alpha。

使用 Readium 官方 SearchService factory 扩展点，提供按 TextContentElement 搜索的服务；正文解析、reading order、CSS locator 和内容迭代仍全部由 Readium 提供。每个元素的 segments 先拼成一个完整 String，再始终使用该 String 的原生索引；不把独立片段 character count 相加或在裁剪后重用整数偏移。支持同一元素内跨 inline segment 的匹配，不跨段落/资源匹配；M1 仅字面关键词，英文忽略大小写，不开放 regex。

每次 next 最多 40 个匹配；上下文各最多 64 字符，不先收集资源全部命中。UI 最多保留 1000 条，明确提示使用更具体的关键词；不是精确全书总命中数。只有点击加载更多才请求下一批。搜索任务运行于独立 actor，捕获/传播资源错误，不静默跳过坏正文。旧 session 的释放和 task cancellation 分开处理。

## 性能与验收限制

应用不读取整本正文、不调用 Content.text/elements/forEach 收集全文；Readium 3.11 HTMLResourceContentIterator 内部仍按单个 XHTML 读取和解析全部元素，大单章内存/取消延迟须 M5 实测。取消请求不代表上游正在解析的 XHTML 已立即停止，但迟到结果绝不能进入新 UI/session。

测试覆盖：真实中文 EPUB 2/3、批次上限与结束、组合字符/emoji/inline 边界、损坏读取、并发 next 拒绝、关闭/改词后的迟到结果、加载更多与 UI 上限、结果完整位置和跳转委托。真实页面的搜索高亮/命中定位另需模拟器/设备验收。
