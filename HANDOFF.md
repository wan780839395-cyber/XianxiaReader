# 当前交接与恢复点

2026-10-18（Asia/Shanghai），Build27 字体管理、排版预设与书架生命周期修复开工。

用户反馈：导入字体底部逐行铺开且样例过大/割裂；希望排版简化或预设；系统暗黑下书架搜索突变白且不恢复；退出后偶发点书无响应；其他应用直接“打开”TTF/OTF进入本应用；菜单仍可能卡顿，不能凭60Hz归因。

已按AGENTS→状态→交接→路线→架构读档，核正常HEAD6d761749/空index、私有tipd378e0ec、真实CI39038829961与最终receipt。没有运行中的项目助手。1014原路径、47根交付包、16旧恢复ZIP摘要/CRC核验并新建第17份开工ZIP；见ValidationLogs/m4-experience-build27-start.json。现有未提交改动全部保留，关机授权已取消，不触发关机。

当前断点：尚未修改Build27运行源码、未编译/测试/交付。Build26完整已交付事实保存在HANDOFF_BUILD26_DELIVERY_2026-10-18.md。新切片独立门槛，旧结果不继承。

拟先核系统主题/阅读presentation身份与关闭回调，再补外部字体文档声明及冷/暖启动URL队列（复用后台协调复制/验证，不抢占当前阅读/设置）。字体改为紧凑入口与独立惰性浏览页，排版提供明确可选预设、常用项与更多调整；保留旧自定义偏好，不主动重置。卡顿先收窄页面与无意义重绘/预览缩放，真机帧率与Instruments仍单列。每个恢复子步骤及构建前继续更新此档。

## 源码完成、测试前检查点（2026-10-18）
字体入口/独立惰性网格与自然字号限制、三排版预设/更多调整已落源码。阅读主题改局部控制器override且不触及窗口；每次开书新presentation UUID，保存后显式关闭/清空同会话。外部TTF/OTF声明/onOpenURL冷暖队列、逐文件scope/原服务验证、只加收藏与显式选中后完整锚点重开已写入。5项新集成+1外部选择生命周期+2新真UI待跑；既有4个原生书架fixture仅补inbox依赖，原字体UI按新导航/展开步骤适配，原功能断言保留。设计/官方来源/风险在READING_EXPERIENCE_DESIGN.md。Windows语法445文件/新增0/54既有Vendor限制已过，仍不等于编译。下一步工具测试、复审并冻结完整CI，尚无Build27 IPA/新门槛。

## 冻结全量构建前
Windows445/新增0/54既有Vendor限制、17工具、bash -n已过。冻结清单543源码/资源/config blob；37原test主体未变、6适配/8新增，没有删除原test；预期Core各135、iOS156（131集成+25真UI）。新增退出按钮保存中反馈。私有index即将保存codex/m4-reading-appearance并建立codex/m4-reading-experience构建ref；正常HEAD/index继续保留，待CI真实source SHA回填。
