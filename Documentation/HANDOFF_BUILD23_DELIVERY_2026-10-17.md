# 当前交接与恢复点

2026-10-17（Asia/Shanghai）。用户要求中断恢复、保留全部未提交改动并继续；此前授权内置字体和本地字体导入。本轮从产物下载/复核处恢复，未再修改已经编译的运行源码。

## 当前可安装候选：Build23

- IPA：`build/XianxiaReader-LocalFonts-Build23.ipa`，41562995B，SHA256 `116de6e07de131019ea70197f9e36cb07a89fc7c773a1311c2922d8be74958f2`。
- 原创样书/测试包：`build/XianxiaReader-LocalFonts-Build23-TestKit.zip`，52737137B，SHA256 `9be4d45909b6dffff8adc6008cddcf1a25d718c8f258930a5d269875dab52286`。包含IPA、15张实际可用Preview、1张明确未验收的隔离TXT诊断图、拉丁导入样本和原许可。
- 正常覆盖安装保留书库，不卸载/删库；+菜单确认0.0.1 (23)。无签名iPhoneOS arm64 Release/min16，普通设备沿用既有签名安装方式，TrollStore未验收。

实际编译源`62700a159cffc72ef256eabdc24184bf6092b0a7`，验证ref `codex/m4-font-readable-capture`，[CI 38918803378](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38918803378)。三job实际completed/success；完整run/full.log/summary/xcresults/原生附件在`build/ci/38918803378`。三个完整原ZIP在`C:/Users/78083/.cache/XianxiaReader-Build23-CI/archives/38918803378`，已CRC及GitHub摘要比对，完整解压留存。

## 本片实现

阅读设置→外观→字体与字号新增思源宋体SC Regular OTF2.003、霞鹜文楷Regular TTF1.530，原字库约48.1MiB、不裁字；离线直接选，不占12款导入名额。保留默认/衬线/无衬线、我的字体TTF/OTF导入（单款≤32MiB）、深色与全局保存。原OFL、官方固定revision/URL/摘要在App/Resources/Fonts/PROVENANCE.json。

Core字体身份/独立原子目录与受管理路径、后台协调复制/流式摘要；App后台CoreText校验。内置只读Bundle URL，开书不复制/扫描50MB。ReadingInterfaces目录→Adapter公开Readium3.11字体API和原资源通道，≤14faces、正文窗口仍≤12；无全局注册/HTTP/依赖锁升级。字体ready后恢复完整锚点，每文件独立路由避免同名font.ttf冲突。新增字体先暂停慢滚、采完整位置并保存再受控重开；采样等待实际可读，3s有界且每await核取消/会话，关闭不能采瞬态章节头或改新reader。EPUB完整Locator、TXT byte+UTF16、回看返回点保持，无小说/schema删除或迁移。具体设计见READING_FONT_IMPORT_DESIGN.md。

## 已验证与明确未验收

自动检查：Windows433语法新增0（54既有Vendor语法限制）、17工具测试；语法不是编译。Linux/macOS Core各133，iOS134/134（115集成+19真UI）、失败/跳过0，源编译warning/error0；严格无签名Release23、三份真实六pins锁、522源码/资源blob、每平台四长TXT Release探针均核。35个受改原测试主体保留、16项新增（6Core+8集成+2UI）。字体字节/许可与IPA匹配，无DEBUG字体fixture或受WebKit293831影响的libswiftWebKit依赖。记录M4_FONT_VALIDATION_REPORT.json及ValidationLogs/m4-font-build23-success.json。

原生素材复核：78PNG/13联系表全部看过；两内置EPUB连续/分页与TXT共6张实际中文正文清楚，字形有别、深色柔和；导入字体EPUB两模式有正文。19条真UI原视频全部保留，本轮只看4条（两字体、目录/书签返回、减少动效退出慢滚）完整1秒总览207.98s/15表，另看4窗口235原始VFR帧/22表。选定字体状态、取消/重开、返回/留在此处及慢滚退出结果可接受。

不能写成全画面/全动效通过：iA导入字体TXT隔离快照只有底色，旧巨段TXT隔离图仅两行，已分别记录、不当可读满页通过。部分换色/系统sheet过渡原帧有区域重复/错位，原件未修图，成因尚未确定，待手机对照；PTS密集不当FPS。录屏中的启动白页、加载spinner、关书/重启黑画面另列，不当已就绪正文。原生证据与限制：ValidationLogs/m4-font-build23-native-review.json。其余15条视频未逐看；不追认旧捕获或旧失败。

普通签名、TrollStore、手机首次换字/大中文字体加载/内存/FPS/功耗、全部File Provider外部有效TTF/OTF点击导入、真实系统Reduce Motion/VoiceOver/增强对比度/旋转及全样书矩阵均待核。有效字体服务/VM真实输入已集成测试，真UI只覆盖选择/取消/持久化/默认恢复。字体集合、可变轴调节、删除、单书覆盖尚未实现。Build22基本功能和用户Build21“减少动效退出能回菜单”的具体反馈保留，不扩大成本版设备通过。M4整体未完成，不提前M5。

## 保留与后续

普通HEAD `6d761749911233122bcd031fcf718d22a19f9e77`、空index、M2 `e6f31d85`、M3 `44af41f0`保持；所有未提交改动保留。仅用私有index快照`codex/m4-reading-appearance`，不能把它说成正常工作区已提交。原875路径、522编译blob、39旧包+2新包、13份备份逐hash/ZIP核验，最终清单/远端树/任务回执见`build/ci/38918803378/final-preservation-check.json`与`final-session-state.json`，以实际回执为准。

历史首轮Agent取消、129/131与128/131、131/133、四轮WebKit启动前abort、130/134、133/134等原件均保留。92ad/38911801177原ZIP已补齐并核GitHub摘要，只解压logs/summary/manifest，完整xcresult仍在原ZIP，不能说已全解压。19db/38914038336为成功副候选，只保留run/full.log/manifest，未继承其门槛。当前62700a1运行源码确有采样guard，不能套用较早“仅测试变化/运行源码仍7ab”的历史描述。

此前逐步记录归档HANDOFF_M4_FONT_DEVELOPMENT_2026-10-17.md及HANDOFF_M4_FONT_ITERATIONS_2026-10-16.md。恢复继续先AGENTS→PROJECT_STATUS→HANDOFF→ROADMAP→ARCHITECTURE，再核实际Git/files/logs/tasks；不得按旧watcher session重复dispatch或猜最后成功。

下一M4切片优先按本版手机首次换字/重开反馈修正；并统一目录、书签、搜索sheet浅深主题及必要过渡、排版细节。单书设置/字重字距等按小切片完整验证，不提前知识库/在线书城/云账号。当前没有关机或持续后台运行的新请求。
