# M4 阅读外观与排版：第一片

状态：2026-10-15 源码实现中，尚未经 Apple 编译与原生验证。M3 已按 Build14 用户基本自用反馈收口；本片不代表完整 M4 完成。

## 范围与优先级

阅读内五种底色（日间白、暖白、纸色、深灰、OLED 黑），深色正文使用 #C6CCC5；原生设置面板可选默认/通用衬线/通用无衬线字体、字号 80–200%、行高 1.2–2.0、段距 0–1.5rem、左右留白 0.5–2.0 倍、首行两字缩进、自然/两端对齐。默认暖白、110%、1.75 行高、0.8rem 段距、两字缩进；可切“沿用原书排版”，此时自定义行距/段距/缩进/对齐停用，避免显示有效却被引擎忽略。

当前只有一份全局偏好，后开书籍沿用。无单书覆盖、字体文件导入或库界面主题。通用字体由系统 WebKit 按文字选择回退字体，不承诺系统未安装的具体中文字库。示例卡片只展示底色/字号/通用字体风格，真实排版验收依据实际 TXT/EPUB 页面。固定布局只提供底色偏好，禁用正文排版；不把图片书误称可重排。

独立四边距、字重/字距、字体导入与生命周期、单书覆盖、亮度、音量键/公开 API 实验及手机性能仍是 M4/M5 后续，未实现未验收。

## 持久化与边界

Core 的 ReadingAppearance 是 Foundation Codable/Sendable/Equatable 模型，版本 1。BookFileStore actor 读取/原子写入 Preferences/reading-v1.json，最大 16KiB，复用逐级符号链接/越界检查；缺文件才使用默认，损坏、未知版本、非法值和写入失败均显式报告，原件不自动删除。数据库保持 schema3，不通过删库重置。

ReaderViewModel 在 engine.open 前读取并提交偏好。连续修改按输入次序串行保存；完成/返回书库等待保存，失败在设置面板展示并提供重试。读取失败阻止打开并显示原错误，允许重试；不会自动用默认覆盖坏文件。读取期间关闭由既有 request ID/cancellation 隔离。ReadingInterfaces 暴露可选外观能力，UI 不接触 Readium Preferences/Locator。

Adapter 将模型映射至既有 EPUBPreferences，保留当前分页/连续模式。模式与排版复用一个可取消的提交任务，提交前读取真实 DOM anchor，并在 await 后验证任务、请求 ID、navigator 身份；关闭取消旧任务。仍保存完整版本化 EPUB Locator / TXT 稳定 byte + UTF16 文字锚点，不能用百分比代替。不开全书、不重写 EPUB，也不升级锁或修改 vendored 原件。

## 参考与选择

核对本地精确 Readium 3.11.0 / d82f44f4f05d87add9e22a8b75abbd61dce745dd 的 EPUBPreferences、EPUBPreferencesEditor、ReadiumCSS、Types，及官方同 tag [Preferences 指南](https://github.com/readium/swift-toolkit/blob/3.11.0/docs/Guides/Navigator/Preferences.md)、[EPUBPreferences 源码](https://github.com/readium/swift-toolkit/blob/3.11.0/Sources/Navigator/EPUB/Preferences/EPUBPreferences.swift)。沿用官方动态 submitPreferences 与自有 JSON 持久化模式；不采用旧版用户设置 API。fontSize 是倍率，pageMargins 为横向倍率，paragraphIndent/Spacing 映射 rem；不把倍率标作物理 pt。

上游 CJK Horizontal 样式未实现 paraIndent（editor 的 isEffective 仅 default/rtl），但会输出该 CSS 变量。依据中文两字缩进要求，在 Adapter 的静态本地 WKUserScript 添加与 upstream default 同形的 p 规则，只作用于横排 :lang(zh)、advanced-on 和已指定 paraIndent；沿用原书排版时退出，h2 标题不受影响。无需改 Vendor、缓存协议或资源 ID。后续真实页面回归验证该补充，而非仅检查 Preferences 数值。

## 验证门槛

新增 Core：重建恢复、坏/未来版本原件保留、非法数值不覆盖、大小上限与真实写失败、父级/悬空叶 symlink 拒绝。iOS：偏好先于 open、快速修改保存顺序、写失败重试、实际 EPUB 五主题及 reflow/reopen、TXT 非零 UTF16/byte anchor 与真实中文 CSS。XCUITest：原生设置/五主题中主要选项、字号调整、完成、退出/重启持久化，导出实际录屏/截图。全部既有生命周期/搜索/连续/导入回归保留。

每次候选必须完整 Linux/macOS Core、iOS 集成+UI、无签名设备 Release、四长 TXT 探针、三份六 pin 锁及源码 hash。Windows 语法/Python 与 Swift 编译分开；模拟器帧复核与手机流畅度分开。最终结论写入专门报告及交接，不能预先宣称通过。
