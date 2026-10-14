# 项目状态

更新时间：2026-10-14（Asia/Shanghai）

| 阶段 | 状态 | 验收 |
| --- | --- | --- |
| M0 结构与技术验证 | 自动门槛通过 | 编译/Core/iOS/Release/真实IPA |
| M1 基础 EPUB | 最新已编译38/41；初始化备用路径已进入跳转，位置发布诊断CI运行中；完整M1未验收 | 章节位置/长段字符/完整CI/设备仍待完成 |
| M2 TXT | 未开始 | 后台流式分章、窗口加载/缓存、长文件 |
| M3 完整书库 | 未开始 | 列表/编辑/封面/删除一致性 |
| M4 设置与主题 | 未开始 | 字体/排版/主题/亮度/音量键 |
| M5 性能 | 未开始 | 百万字/数千章基线 |

## 当前实际实现

- SwiftUI网格书库，封面/书名/作者/可用进度/最近阅读。
- EPUB Files多选副本导入、可见成功/失败；后台文件协调复制、Readium元数据/缩略封面、缓存TOC。原创EPUB2/3内置导入入口。
- Core的SQLite actor保存Book/Chapter/ReadingPosition/Bookmark，事务/导入恢复/路径和符号链接边界。位置保存完整版本化Locator，拒绝旧异步覆盖。
- ReadiumAdapter隔离引擎；分页、章内上下滚动、横向跨资源、中央菜单、目录/内部链接、书签、搜索/结果跳转、位置保存/恢复。关闭/重开过滤旧异步回调。
- ReaderSurface独立完整viewport、官方frame/autoresizing容器；横排重排媒体保护按实际innerHeight校准，固定/竖排保留原路径。目录/书签跳转后收起菜单；原创长短章/高封面样书和实际窗口回归。
- 安全SearchService扩展保留issue876回归；每批40、上下文64、UI最多1000；不跨文本元素/资源匹配，不收集全书结果。
- project.yml唯一工程源；两个Swift Packages；连续候选使用Readium3.11.0本地扩展及真实解析的6个远程pins（Build3历史为11 pins）；保留macOS完整CI和无签名IPA门槛。

## 最新证据与设备边界

[CI 38434939423](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38434939423)（源码0b30d539d7eb6d557d8b5e5e8efad600c4c4435b）全部成功：Linux/macOS各14 Core、31 iOS tests、设备Release与Build3 IPA。源码compiler warnings=0；metadata提示另列。原创封面分页/滚动快照已人工查看，上下色带完整；用户原书与iOS16.6.1真机仍待复测。

- Windows结构/SQL/三本EPUB/42 Swift grammar通过（不是编译）；9 Python/tooling测试与bash -n通过。Linux/macOS Core各14，iOS实际31，结果范围分别记录。
- 新报告 `Documentation/M1_READER_VALIDATION_REPORT.json`：69个构建/验证来源hash匹配已测提交，11依赖pins不变，日志/IPA/快照hash。完整日志 `build/logs/ios-build.log`，原始日志/xcresult/快照/工程保留在 `build/ci/38434939423/ios/`。
- 最新 `build/XianxiaReader.ipa`：7,393,693 bytes；SHA-256 `12504757c6900a83acc107bfee9cc360a737859effd9dda005ad7d18237b66f2`，Build3/iPhoneOS/arm64/系统SQLite/0755/最低iOS16/ZIP核验通过，CODE_SIGNING_ALLOWED=NO。
- 测试ZIP `build/XianxiaReader-iPhone13-TestKit.zip`：7,296,582 bytes，包含IPA、三本原创EPUB和TESTING.txt，CRC与内部IPA hash一致。Build2及更早原件保留在对应run目录。
- 用户iPhone13/iOS16.6.1/TrollStore：安装正常、EPUB可以导入（用户报告，来源未细分）；原书图像窄横条。当前Build3安装/原书图片/完整阅读仍待复测；没有普通设备签名验收。
- **真正纵向连续跨章候选已写入未提交源码，上一版编译/38项回归通过，最终版本尚未全套验收**：Vendor/ReadiumToolkit 是3.11.0本地扩展，最多12资源窗口、固定WKWebView viewport、加载边界/重试、DOMRange+视口偏移、迟到布局过滤和关闭清理。旧Build3仍为章内滚动/横向切换；候选不能作为完整M1已验收功能；已经查看原创双章同屏截图，原生拖动/惯性与峰值内存未验收。
- remote compact恢复：本地main/6d76174和原暂存区保留，370文件ZIP已核验CRC/全部hash；候选codex/m1-continuous-recovery。最新完整38523628789/eb07c4e为Linux/macOS各14 Core、iOS38/41、0 skipped；native bootstrap已在抑制rAF桥后取得首次位置，边界/长段/rAF测试都在jump helper阻塞（页面已one.xhtml，位置仍cover）。93ef44f补充有界数字诊断与清理后等待释放，Windows362grammar/14tooling通过，完整CI38526015806运行中。未执行新Release/IPA；旧账单拒绝仅是历史，标准公开runner正常。详情M1_CONTINUOUS_VALIDATION_REPORT.json与HANDOFF。

## 失败历史与报告范围

Build3首轮38424689048 test bundle链接失败，第二轮38426725252导航探针超时，第三轮38430692977图片超限；原记录/完整日志保留在ValidationLogs与各run目录。修正后本轮全部通过，未删除测试/降低原图片断言/升级依赖。

M1_IMPORT_VALIDATION_REPORT.json属于Build2的26 tests；M1_SEARCH_VALIDATION_REPORT.json属于此前搜索；IOS_VALIDATION_REPORT.json属于M0；CORE_VALIDATION_REPORT.json是本机Linux；VALIDATION_REPORT.json仅静态。历史导入run38409222759由Agent提前取消，实际26iOS已通过、Release中断，不能写成源码失败。M0的SDK SQLite与缺AppIcon失败已在run38390862584修复验证。

Windows11/PowerShell7.6.5/Git2.54/Python3.11，本机无Xcode。GitHub origin/main已建立且CLI已授权；2026-10-14用户同意公开，API已确认PUBLIC，采用公开仓库标准runner免费构建，没有修改账单/支付/支出限额。正在重跑连续候选完整CI，尚未产生新结果。Docker曾恢复并升级4.95.0，原容器/备份保留；本轮未启动Docker。GitHub artifacts保留14天，忽略的build/.cache不随clone；过期后按锁文件重新CI。

## 下一步

先用Build3在现有TrollStore应用上正常更新，保留数据；复测原书图像及reader-layout上下标记、目录/内部链接、搜索/书签/位置。继续M1真正纵向连续跨章引擎切片，完成有限窗口、原Locator、双章边界/逆向/图片高度变化回归。完整M1未放行，不大规模进入M2/M4。TXT、完整书库、字体/主题/音量键、百万字性能及XBook知识库均未实现。
