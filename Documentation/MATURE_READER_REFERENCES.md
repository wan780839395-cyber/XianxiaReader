# 阅读器参考与开发取舍（2026-10-14）

用户最新原则：用于自用，优先做出能用的产品；卡住时参考成熟方案，微信读书作为阅读交互参考，其余按原方案推进。这不改变Readium、ReadingInterfaces、完整Locator、本地存储或M0→M5路线。以后重复失败时，先写清观测值、最小复现和参考实现的差异，再决定改动；已有完整验证通过时先交付可测试包。

## 实际查看的官方项目源码

| 参考 | 精确来源 | 本次观察 | 本项目取舍 |
| --- | --- | --- | --- |
| epub.js continuous manager | [eee359d / index.js](https://github.com/futurepress/epub.js/blob/eee359d0790002115a1156a9833c54f4bcd44c1d/src/managers/continuous/index.js) | `check`按视口补相邻section；`trim/erase`回收远端并补偿顶部偏移；`scrolled`以request ID过滤过期位置通知；当前实现还延后惯性中的回收 | 借鉴窗口管理、补偿及异步失效思路。它的iframe/浏览器坐标不能直接证明iOS多个WKWebView的同步正确；不把它换进产品或复制整套代码 |
| foliate-js paginator | [78914ae / paginator.js](https://github.com/johnfactotum/foliate-js/blob/78914aef4466eb960965702401634c2cb348e9b1/paginator.js) | `scrollToAnchor`使用Range/Element矩形，`getVisibleRange/afterScroll`保存可见文本锚点；章节切换仍通过当前view及index管理 | 参考布局改变后恢复同一文本的思路；不能把章内scrolled宣称为无缝跨章。[Foliate发布记录](https://github.com/johnfactotum/foliate/releases)也有移除continuous模式的历史，项目成熟不代表每种模式已具备 |
| Readium Swift连续PR | [PR811](https://github.com/readium/swift-toolkit/pull/811)，head `5e22cb79782d667778a1c9516ad713171853b3f6` | 现场API：open、draft、merged=false；维护者说明v4准备期间新功能暂缓；不是正式发行能力 | 保留3.11.0本地扩展及来源/hash/许可。PR作为Navigator集成参考，窗口/位置/生命周期由本项目真实回归验证 |

资料下载原件在忽略的 `.cache/continuous-scroll/mature-references/`；上述链接固定到所查提交，不把浮动main/master当成当前运行依赖。本轮只做设计参考，没有引入epub.js或foliate-js依赖，也没有更改Package.resolved。

## 连续阅读的坐标与锚点

当前Readium扩展由外部UIScrollView接收拖动与惯性，章节WKWebView固定视口，内部偏移跟随本章可见区。两种坐标需要明确同步：目录/搜索跳转在同一次JS执行中完成原Readium定位并读取DOM偏移；保存位置在同一DOM样本中读取Locator/documentY/documentTop，拒绝过期epoch/revision与不一致视口，最多采样3次。仍保存完整标准Locator及版本化字符/视口锚点，最多12资源。此设计已过CI自动回归，触摸惯性/峰值内存仍须实际验收。

2026-10-14核对CI38530334549/d62af3b：41/41 iOS、各14 Core、设备Release和Build4 IPA成功。本轮不因前几轮失败推翻已通过的候选，也不继续无依据补竞态。

但当前边界PNG视觉检查只看到第一章末尾与空白，未显示第二章；原因未确定。DOM/窗口交集断言通过只能记录为自动证据。先使用Build4在iPhone13/iOS16.6.1复测跨章、逆向、拖动惯性、长段恢复与原书图片，记录实际表现。如果复现空白/跳动，先对照上述成熟实现的窗口/回收/锚点原则建立最小复现，再决定改动，不直接增加等待次数或降低断言。

微信读书的具体目标来自用户偏好：正文连续、章末和下一章开头自然衔接、反向顺畅、重开停在原行附近。未获得其内部源码，不推断其引擎实现；字体、主题等仍按M4安排。
