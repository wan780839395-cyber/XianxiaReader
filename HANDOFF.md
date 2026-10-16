# 当前交接与恢复点

2026-10-16，用户反馈Build22功能没问题并继续；只接受基本自用功能，不扩大完整设备/FPS/功耗或M4验收。Build23本地字体导入开工，尚未实现/编译/交付。

已按AGENTS→状态→交接→路线→架构核实际文件/Git/完整CI38871744221成功/任务。私有tip24d311e/源3cb1d2，874维护文件/507源码blob/39旧包/12旧备份已核，新875路径备份见m4-font-build23-start.json。正常HEAD6d761749/空index/M2/M3保持，无运行CI/本轮任务。Build22交付独立归档。

下一片TTF/OTF单字体：文件选择与异步验证/协调复制/相对路径元数据/可见错误；全局阅读字体选择及恢复默认；Readium既有font-face资源通道，不全局注册、不加HTTP服务。字体目录变化需完整文字锚点保护，迟到请求不能改新会话。先核公开API/版本及成熟实现，记录设计取舍。字体集合/可变轴/永久删除/单书设置不提前铺开。完整Core/iOS/Release23和原生页面/视频复核之前不交付。

Build23源码首片：Core相对字体身份与有界存储事务/重复与缺失重导、TTF-OTF签名+CoreText后台验证；ReadingInterfaces目录capability，Adapter使用Readium3.11公开CSSFontFace、目录在open配置、无Vendor/JS新改。VM新增字体时采完整位置并保存后受控重开，选已有字体走原重排；会话/请求/await校验、关闭取消，失败恢复旧目录/外观。设置页沿用原卡片/44pt并保留选择器coordinator，原reading-v1只加可选UUID。正在补真实font-face/锚点和取消失败回归，尚未编译。测试字体复用仓内IA Writer Duospace 81636B与原OFL，不引入个人字体。

Windows432语法新增0/54既有语法限制、17工具通过，35受改原测试主体保持，13新增=6Core+6iOS集成+1真正UI，515编译/资源blob已冻结。预期Core133各、iOS131（113集成+18UI），必须核真实结果。补retryOpen先正常close避免失败Navigator阻止目录安装。现进入完整Linux/macOS/iOS/严格Release23构建前检查点；尚未Apple编译，不能写通过。

首候选3bac2015197df9dab8ea8a40fbc464c0d73459bf，已实际dispatch CI38880257296。唯一watcher负责run/full.log/artifacts；先核真实Core133各/iOS131/Release23，失败保留原件，不猜最后步骤。

本轮Linux原件artifact12037835000已CRC核，133/133 Core与四Release TXT探针通过，linux.json记录；Apple仍aggregate构建测试，不能推断具体测试阶段。唯一watcher工具session55283负责38880257296，勿重复dispatch。下一步核真正Apple结果及新字体原生页面/录屏。

首候选38880257296由Agent因源码审查补强而取消，已真实completed/cancelled；并非源码失败。Linux133通过，Apple已进入xcodebuild test但未完成iOS summary/Release/IPA，原1.03MB诊断已CRC/解压，first-agent-cancel.json与完整日志保存；watcher55283已退出0。补新页面就绪守卫/实际字号变化/缺字体降级文案，修Task中throwing fixture取值，原35测试保持，仍13新增/515源。重新冻结后跑完整新候选，不继承上一轮门槛。

当前唯一CI38881623233，实际编译候选149caa08c600999f5b53b74e0900eb1b405b7e8a，等待全新门槛。旧38880257296 Agent取消原件保留。

新轮38881623233真实Linux133/四Release TXT原件artifact12037208602下载CRC/解压已核，revised-linux.json记录。Apple仍aggregate，唯一watcher33131；旧55283结束。当前原HEAD/空index保持，运行源码149caa08冻结，未再修改；后续只准备验证/交付辅助和文档，不能把待编译源码写成通过。

等待检查点：新版149caa08/38881623233尚在Apple aggregate构建测试，原生/Release未写通过；Windows432/17与新Linux133/四探针已核。515源冻结，后续仅准备未执行交付helper（deliver_font.py、validate_font.py、review_font.py等）；所有package/docs动作以实际全门槛+本轮原生人工记录为前置。尚无Build23安装包，不把准备脚本当交付完成。
