# XBook 容器协议草案 0.1（未实现）

`.xbook` 候选为 ZIP container。App M0–M5 不接受此扩展名；仅保留 `BookFormat.xbook` 与阅读引擎工厂扩展点。此草案不是格式兼容性承诺。

```text
book.epub
metadata.json
knowledge/characters.json
knowledge/realms.json
knowledge/factions.json
knowledge/items.json
knowledge/techniques.json
knowledge/locations.json
knowledge/relationships.json
knowledge/events.json
maps/
assets/
```

`metadata.json` 未来至少声明 schemaVersion、bookID、body SHA-256、正文文件、语言、canonical chapters。canonical chapter 是从 1 开始的稳定章序，含稳定 chapterID 与 EPUB href/fragment 映射；卷、封面、目录和广告不进入知识揭示章序。每次更改正文或映射必须检查位置/知识兼容性。

外部知识文件采用按揭示章切片的增量 records，不能在同一可见实体上附带未来摘要。资源引用也必须有 chapter scope。封面/地图必须声明首次可见章序；标题、别名和关系端点本身可能剧透，同样受范围控制。

未来导入器必须验证 ZIP entry 路径、符号链接、数量/解压体积限制、压缩比、metadata schema、body hash 与实体引用；禁止路径逃逸，禁止网络脚本或任意执行。正文继续交给 Readium，不建立另一套 EPUB 引擎。

未来 Reader 仍只接收解析后的可读正文；增强数据查询走 Knowledge 接口，不能让 Reader/UI 直接解压并遍历整个知识库。进入该阶段前需单独定稿 schema、迁移与泄漏回归测试。
