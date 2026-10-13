# 无剧透知识接口草案（未实现）

登记未来类型：Character、Realm、Faction、Item、Technique、Location、Relationship、StoryEvent；Highlight/Note 是用户阅读数据，后续单独实现。M0 不建这些类型的运行实体或数据库表。

候选 Character 字段：id、name、aliases、firstAppearance、knowledgeByChapter。name/aliases/关系/境界和描述都必须作为有揭示范围的 facts 保存，而不是把最终状态填进全局对象。每个事实具有 `revealedAtChapter` 与可选 `validThroughChapter`，实体可见性与事实有效性分别处理。

候选查询（伪接口，尚无 Swift 实现）：

```text
KnowledgeRepository.visibleEntity(id, at: VerifiedChapterScope) -> VisibleEntity?
KnowledgeRepository.visibleRelationships(entityID, at: VerifiedChapterScope) -> [VisibleRelationship]
KnowledgeRepository.visibleMap(locationID, at: VerifiedChapterScope) -> ScopedAsset?
```

`VerifiedChapterScope` 必须来自正文到 canonical chapter 的验证映射，不能直接相信 UI 的 TOC row 或客户端任意传入数值。读到第 500 章时，查询层不得读取/返回第 501 章揭示的资料。缺少范围/映射时拒绝显示；搜索、自动补全、关系两端、地图图层、摘要、缓存 key、日志和诊断都受同样限制。

将来优先按揭示章分区并在读取层限界；不能一次将全书 facts 解码后仅过滤视图。需要 500/501 边界、别名、嵌套关系、地图 asset、错误 mapping 与越权查询的独立泄漏测试。
