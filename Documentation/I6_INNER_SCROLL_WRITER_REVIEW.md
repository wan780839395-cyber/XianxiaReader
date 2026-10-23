# I6 内层2367→1767写入入口审阅（2026-10-23）

本片仅本地审阅与补证设计，零CI、零运行输入改动。基线`d0b94066`，运行源码仍是已编译的`dfc20131`；没有实施以下探针。保留smoke、既有隔离/定位修复/S诊断、生产guard、原字断言和原预算，不增加等待或重试。

## 结论与证据边界

39912011242中，同一WebView最后确认inner=2367的Swift uptime为1726.615739598；S第一次实际WK提交前已为1767，uptime1726.999230717。**0.383491119秒是两次观测之间的上限，具体写入时刻和写入者均未知。**现有viewport-sync记录只覆盖InfiniteScrollView.updateViewports，不能代表所有内层变更。

本次重新提取原完整日志，补充核对：

- 原测试`initialDOMY=1767`、`initialOuterY=1769`；测试给outer加600后outer=2369，inner local=2367。因此1767确为本例滚动前的旧值。这支持“某路径保留/恢复旧位置”的候选解释，不能单凭相差600就归因缓存或WebKit。
- before-resize原件的uptime=1726.778888759，处在观测窗口内；current slot1为ready/positioning=false、revision2、frameY2367、savedTop2367。它没有记录inner offset，不能用来进一步缩小回退时间。
- 当前章trace=DAF2BC8A，initialization.finished=1725.680；reflowTrace最后一条=1726.008888261，均早于窗口。该原件未见窗口内新的当前章measure/resize/apply，preferences trace为空。邻章slot0仍在加载，不能把邻章初始化直接当成当前WebView的写入。
- 测试窗口内依次是native采样提交A、原capture命中A、解码/绑定origin、记录附件、封口/释放S；安全臂须等S合格才resize。本轮尚未resize、主M或执行缩放后的原字断言。附件nativeState为字符串/原生属性读取，没有发现显式滚动写入；这些观察和任务调度仍可能影响时序。
- 同WebView已有2个唯一viewport writer调用：先显式同步2367，后layout-slots未赋值；都早于有效native结果。18条诊断零丢弃，但未覆盖下表其余入口。S自身JS尚未提交时inner已经1767，不能把这次回退归因于该次S的caret/rect读取。

根因状态仍是**未证**。旧full连续缩放失败与本次安全臂准备失败也未建立共同因果，不能写成旧故障已修。

## 实际入口清单

行号对应本片冻结源码；JS用本地bundle字符偏移定位，不能把minified符号名当稳定接口。

| 入口 / 路径 | 实际写入对象与触发 | 现有覆盖及本例约束 |
| --- | --- | --- |
| InfiniteScrollView:648–668 `updateViewports` | 设置spread.frame.y，再按原差值条件写当前WKWebView.scrollView.contentOffset.y | 已有3来源/前后回执；窗口内没有新记录。原生赋值返回不保证之后没有内部回调 |
| ReflowableSpreadView:431–447 `scroll(toProgression:)` | 连续/非竖排且progression=0或1时直接写inner contentOffset；其他progression转JS | 未覆盖。0/1目标按当时inset/contentSize计算，并不是源码中硬编码1767；需记录实际计算值，不能凭最终slot高度排除瞬时clamp |
| ReflowableSpreadView:361–417 canonical locator | 同一原JS内算rect.top+scrollY−viewportOffset，调用`window.scrollTo({top,behavior:'instant'})` | 未覆盖；DEBUG canonicalTarget只是旧值快照，没有调用身份/提交时间。初始定位已完成，仍缺延后提交/平台应用的完整链 |
| ReflowableSpreadView:450–480 / InfiniteScrollView:376–424 | 片段、文本、progression导航进入`readium.scrollToId/Locator/Position` | 未覆盖。Infinite.navigationOffset可能在跳转后再次发出该类JS，不能只检查显式window.scrollTo |
| reflowable JS helper `M`，约69752 | 最终调用`document.scrollingElement.scrollTo`；`C`把rect.top+window.scrollY传入，progression用scrollHeight×比例 | 原读数诊断不覆盖。源码调用的receiver是根元素，不是window；只拦window.scrollTo将漏掉它 |
| ReflowableSpreadView:217–248 分页翻页 | 非scroll模式的`window.scrollBy({left:...})` | 当前连续模式guard走super，测试未发翻页，不作为本例首选解释；保留库存记录 |
| reflowable JS load→ResizeObserver→rAF，约67793–68515 | 虚拟分页元素调整；仅`!R() && oldWidth>0 && oldWidth!=newWidth`时写根元素scrollLeft | 无直接纵向scrollTop赋值。R()读取CSS的--USER__view，不能仅凭Swift模式排除CSS短暂不一致；本例未开始resize，无命中证据 |
| ReflowableSpreadView:90–119 / Infinite.layoutSubviews/layoutSlots | inset/约束、web/spread/wrapper尺寸与位置、外层contentSize；可间接触发内部裁剪/同步 | 只有viewport同步点记录了局部frame；缺inner contentSize/bounds/inset变化与首次offset变更证据 |
| WebKit/UIKit内部 | UIProcess/WebProcess滚动同步、内容尺寸裁剪、恢复、focus/导航等内部路径可以改变UIScrollView | 未覆盖；现有证据不能判定是哪一种。不得使用私有API或修改SDK；公开delegate回调也不是全部内部setter的完整审计 |

外围写入也已核：Infinite.go/load/measure/layoutSlots、Navigator连续翻屏修改的是**外层**offset；随后通常经updateViewports同步inner，不能混成未记录的第二个显式inner setter。App及Packages未找到直接contentOffset/JS滚动写入。当前`reader-layout.epub`无JS文件和script标签；不能外推用户其他EPUB。FixedSpread与PaginationView不是当前连续reflowable内层滚动对象。

## 官方/成熟实现对照与取舍

- [Readium固定revision的ReflowableSpreadView](https://raw.githubusercontent.com/readium/swift-toolkit/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/EPUBReflowableSpreadView.swift)及[同revision脚本](https://raw.githubusercontent.com/readium/swift-toolkit/d82f44f4f05d87add9e22a8b75abbd61dce745dd/Sources/Navigator/EPUB/Assets/Static/scripts/readium-reflowable.js)：上游也同时使用native首尾定位和JS根元素滚动。本地另有连续/canonical/字体等待补丁，不能直接用上游替换。
- 本地bundle SHA256=`b9cd6bff152af694720549b1e1111b016c5ef482e1842c3bab506695ff471833`，上游=`81c10d2e378b24ebfddf758c8e99e3548730df17d5db135ef0797ec15155bf1c`，均与UPSTREAM登记相符。精确变换只有ResizeObserver中保存oldWidth及给原横向scrollLeft赋值增加宽度变化条件；`M`根元素scrollTo及纵向导航链保持。不是单纯换行差异，本片未改bundle。
- [Apple scrollViewDidScroll](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/scrollviewdidscroll(_:))用于取得offset变化；文档未保证回调含写入者身份或覆盖内部每次setter。适用于当前iOS基线，使用项目已持有的delegate，无需替换WK内部scrollView。
- [WebKit官方WKWebViewIOS源码](https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/API/ios/WKWebViewIOS.mm)存在更新滚动尺寸、恢复滚动状态、从内容位置转换并设置native offset等内部路径。所取main文件哈希保存于primary-references.json；不是iOS18.5模拟器二进制的精确源码匹配，**仅证明“无应用setter回执不等于无内部写入”这个观测边界**，不能据此认定WebKit缺陷或套用修复。提交查询遇API403，未重试，也不为此升级依赖。

## 最小补证方案：先补原生被动链，不包揽浏览器所有入口

目标：在同例同一WebView上，区分“应用明确发出新的定位/赋值”“已有命令后续应用或几何变化关联”“没有已覆盖应用写入、内部变化仍待证”。先不拦截JS原型、修改minified bundle、注入滚动或增加屏障；若出现navigation提交而仍缺JS计算target，下一片再只补命中的那种writer。

建议下一实现片最多**5个运行输入**：EPUBSpreadView.swift、EPUBReflowableSpreadView.swift、EPUBInfiniteScrollView.swift、必需UPSTREAM.json摘要、现有provenance工具定向合同检查。不改Adapter/CI/原视口用例/fixture协议或FixedSpread override签名。新增字段走原`sample-read-`前缀独立256条journal，沿用丢弃计数，不消耗128控制事件，不改变fixture准入/任务/放行状态。

1. **观察变化**：在已存在的inner `scrollViewDidScroll`基类回调里，检查严格同一scrollView、当前slot/epoch、配对模式后记录“上次观察Y→本次Y”。附Swift uptime、frame/bounds、contentSize、contentInset/adjustedContentInset、zoom、attached、拖动/减速/动画状态以及最近应用writer/evaluation ID。记录发生在原Reflowable通知调度之前，原super和setNeedsNotifyPagesDidChange顺序不变。它是变化回执，不冒充setter入口；无回调时结论仍不完整。
2. **覆盖显式native入口**：在Reflowable首尾progression原setter前后同步记同一writerID、计算target、旧/新inner、上述几何值和go来源；不代写、不改变计算/原赋值。扩充既有viewport-sync的几何字段，并在frame赋值后、原offset条件判断前记inner，区分frame间接变化与显式赋值；不增await或触发布局。
3. **覆盖JS提交链**：仅在原`evaluateScript`内部创建局部evaluationID，不加参数、不改override。按已核的精确调用形状归类canonical/window/Readium导航、CSS、读取、other，并只记脚本摘要/类别，不记录正文、selector、locator或原脚本。记录原加载await前的进入、await后的实际WK提交、原完成回调及错误状态/inner几何；原JS字节、receiver、参数、Result、异常、唯一continuation恢复和原guard均不变。现有S的requestID/attempt诊断继续保留，通用链不能替代它。
4. **覆盖窗口前的命令**：在配对实例slot构造返回后、原go/后续await之前同步绑定nil可选观察sink，直到清理，不仅在S三次读取时临时启用。现有fixture属性若在slot之后设置，setter须同步绑定当前slots。每次绑定记录coverage-start、当前加载/初始化状态；构造器本身已经调用loadSpread，不能声称覆盖了绑定前所有导航或浏览器命令。已有请求进入但无提交/终结或覆盖开始过晚时明确标记不完整。只关联reader/epoch/slot/WebView/资源索引，不拿邻章offset填当前章；未知早期命令仍留在候选中。
5. **首次倒退附证**：仅同一已观察实例首次Y下降超过0.5时，在读取值后附一次有界`Thread.callStackSymbols`（至多16帧，移除地址和用户路径，无正文）。它可能只有UIKit层或缺符号，不作为完整调用者证明，不增加轮询/调度/重试。非倒退只保留数字；零丢弃及覆盖起止回执是完整性条件。256条不足时标记观测不完整，不能默默扩大预算。

以上只读取现有属性/写日志；新增工作仍可能扰动竞态，重放通过不等于根因消失。不得以该被动链检测到差值后“同步回来”、重采样、刷新缓存或放宽S资格。

## 放行、取消与清理合同

使用原sample-before-read continuation及原逐条排空，不增加新的等待或放行点。观察sink弱持有owner；记录按同步事件携带固定身份，不能依赖回调时TaskLocal猜来源。同步setter周围的writer上下文用defer恢复栈，不能跨await共享一个“当前来源”。JS completion捕获局部evaluationID；完成前关闭则只形成有界迟到/已关闭回执，不向新slot追加或变更其状态。

clear/fixture移除时先使诊断owner失效、解除sink并清空本实例观察状态，再沿原流程取消/释放；槽替换、取消、重复clear和测试tearDown均幂等。记录器不能延长WebView生命、发Task、调用layoutIfNeeded、evaluate额外JS或从delegate读取DOM。保留原五类清理集合为空的验收；无owner不记录，Release/smoke不启用新路径。

## 结果判读与直接检查

| 新证据 | 允许结论 / 后续 |
| --- | --- |
| 同实例native writer明确target1767且前后2367→1767 | 锁定该应用写入分支，结合go来源审阅调用条件；先留证，不现场改算法 |
| 窗口前/内导航JS有实际提交，回调或delegate观察倒退 | 证明该命令在候选链上，不等于实际target1767；下一片仅补这个命中writer的JS计算值/执行回执，不能归因完成时间最接近的一条 |
| inner几何改变，范围上限变成1767，随后offset倒退 | 支持clamp/布局关联；需同时核对先后/调用栈，不仅以数值巧合定因 |
| 无已覆盖应用写入，delegate记录倒退，栈含内部同步/恢复 | 缩小到内部路径候选；缺准确平台匹配/异步源时仍不宣称WebKit根因已证 |
| 无delegate倒退、丢弃>0、身份不符、绑定太晚、未复现 | 观测不足或本次未复现；不能把“没有新日志”当成不存在写入，更不能宣布修好 |

下一实现片先本地检查启用/关闭、身份/生命周期、首尾原赋值与原JS/await/guard不变、只一次continuation恢复、独立journal无控制预算污染、关闭/迟到/重复清理；语法检查仍非编译。该设计不包含CI接线变更或新CI授权；如以后单例原生运行，保留真实安全退出，安全不合格仍停止，冲突不启动/null，不自动重跑。原smoke/隔离/定位/S诊断不退回，原30秒/3px等断言预算保留。

## 本轮保存与验收状态

恢复`build/maintenance/I6-inner-scroll-writer-review-20261023/`保存before、分别提取的before-resize/failed-874原件、上游参考及哈希、source-audit/result、文档检查与最终私有快照。619运行输入、2390条受保护证据记录（可能含重复路径）、Build30与普通HEAD/index逐项复核。仅文档静态检查，不重跑Python整套/Swift语法/原生/full/Release/设备；没有新IPA。

最新真实原生结果仍为39912011242：编译链接0；安全单例0/1，原test/driver65，冲突null。I6、旧full191/192、Release与手机缺口保持。此片完成的是候选入口审阅和最小设计，不是探针实现或定位修复验收。
