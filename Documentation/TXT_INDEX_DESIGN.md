# M2 TXT索引、编码与cache

状态：2026-10-14 两个Core切片已过完整CI，最新38547339868/65c1b8d为Linux/macOS各60 Core、41 iOS、设备Release成功；Windows372 grammar/14项tooling通过。第一切片38538141364/0643093 attempt2的各33 Core/41 iOS/Release证据及首轮超时单独保留。用户已确认Build4连续阅读和重开位置正常，并要求按既定路线继续；其他未逐项确认的设备项目不扩写为完整矩阵。TXT产品入口/完整位置随后在Build5通过CI38559906005；设备/长书仍待验收，完整M2未完成，最新范围见TXT_READING_DESIGN.md。

本轮完成独立Core能力：识别章节/卷/序章、扫描已规范化UTF-8正文、返回稳定字节范围和分组目录、按有界窗口读取正文。第二切片已实现编码正规化/内容版本cache；随后已接事务导入和ReadingInterfaces阅读，产品验证见TXT_READING_DESIGN.md。原始书籍始终保留；不会把整本String放入ObservableObject，不重写EPUB排版。

## 数据边界

- 输入是已规范化UTF-8文件；本轮严格校验UTF-8。拒绝损坏编码，不用替换字符修补后假称转码成功。正规化第二切片已实现UTF-16/GB18030到UTF8 sidecar，原件保留；扫描器输入仍仅规范化UTF8。
- 读取使用FileHandle有界chunk，跨块保留UTF-8校验状态、CRLF与标题候选；超长正文行仍扫描/校验，但标题候选有上限，不缓存整行。
- 字节偏移使用Int64，范围[start,end)；标题所在行包括在对应章节正文中，前言/卷序不丢失。卷作为目录分组，分组不拥有重复正文范围；叶子章节范围按顺序连续覆盖正文。
- 叶子章节ID基于同一bookID与叶子起始字节位置（可包括卷标题/前置空行），分组ID基于卷标题位置；重复标题不碰撞。正文/parser改变由第二切片摘要/版本cache失效，不沿用旧索引。
- 无标题非空文件作为单个正文；空文件报错。卷下章节depth=1；不把EPUB目录ordinal直接借用为小说canonical chapter。
- 窗口读取只接受叶子范围和有效UTF-8字节边界，最多固定上限，返回同章局部起止字节；不得读取未来章节。书籍路径必须来自BookFileStore已验证的受管理路径，底层读取器不代替存储路径授权。

## 必须验证

八类标题与反例、序章/卷章/重复标题、跨1字节chunk的多字节/CRLF/BOM/末行、UTF-8损坏及截断、超长行的固定候选内存、无章/空文件、取消、64位offset及窗口末尾字符边界。Windows grammar与Python检查独立；真实Swift测试须Linux/macOS，最终iOS完整CI保留既有41项，不降低断言。

UI布局仍遵循M3完整书库、M4排版/主题。该Core切片完成后不称用户已可导入TXT。

## 参考与选择

查阅[Readest TXT转换器](https://github.com/readest/readest/blob/3cc39ad7a558e6612e1a8135058fbd6f3c90b3e3/apps/readest-app/src/utils/txt.ts)及其标题回归，借鉴中文数字覆盖和卷/章不同边界的原则，独立实现整行识别：章标题允许紧接标题文字；卷类要求分隔或行尾，避免“第一卷的故事”误判。不识别“第一封信/第四本书”等量词正文，标题上限80字符；长行按正文保留，不丢失数据。英文支持Chapter 1及chapter.844。未复制其整本转换/自动按页分章路径；本项目采用原字节范围索引和受限窗口。

FileHandle有界读取依据[Apple read(upToCount:)](https://developer.apple.com/documentation/foundation/filehandle/read(uptocount:))。扫描器/窗口为独立actor，避免主线程全文读取。Docker现场查询失败：`dockerDesktopLinuxEngine`命名管道不存在；没有启动/重置Docker，也未把未执行容器测试记成成功。真实编译由现有完整CI验证33 Core与原41 iOS。

## 最新验证检查点

CI38538141364 / 源码0643093d32fdc9801cba34671d9eba3d1eb35de4：repository-checks及Linux Core job成功，完整Core日志已下载，真实编译/33项（含19项TXT）通过。后续macOS各33、原41项iOS与设备Release在同源码attempt2全部成功；首次失败另行保留。根依赖锁未升级，正文UI/导入未改；旧Build4测试包保持原样。

attempt1已完成：Linux/macOS各33项Core/新增19项TXT全部通过，iOS编译后40/41，现有EPUB首次打开等待位置超时（exit65），Release未执行。原阅读/测试源码与d62相同，根因未确认；原文见ValidationLogs/m2-txt-index-attempt1-ios-load-timeout.json。只执行一次相同源码的失败job重试，attempt2真实结果为完整success，41/41 iOS/各33 Core及Release通过；不据此修改已由用户确认可用的阅读器或降低断言。

## 编码与cache第二切片（自动门槛通过）

2026-10-14第二切片已过完整CI38547339868/65c1b8d：TXTNormalizer严格UTF8/UTF16/GB18030正规化，TXTContentDigest增量SHA256，TXTIndexCache版本cache与StreamingTXTIndexer facade。新增27项Swift回归，Core共60项；Linux/macOS各60 Core、原41 iOS与设备Release全部成功；445运行文件hash匹配，根/下载/workspace锁一致。Windows372 grammar/14项tooling通过（不是编译）。原书不变，UTF8 sidecar仅成功后发布；自动识别只接受BOM/完整严格UTF8，不确定编码要求选择。cache复用避免转码与分章，但目前仍流式计算原/normalized摘要，尚非仅元数据快开；当时产品入口/位置未接入；最新Build5产品已自动通过，设备仍待验收。

GB18030使用系统编码表。CI38545821529确认Linux iconv通过60项，但Apple系统iconv在emoji/补充汉字两项四字节向量失败；原失败保留，iOS/Release在Core门槛停止。Apple修复改用公开[CFStringCreateWithBytes](https://developer.apple.com/documentation/corefoundation/cfstringcreatewithbytes(_:_:_:_:_:))和[CFStringGetBytes](https://developer.apple.com/documentation/corefoundation/cfstringgetbytes(_:_:_:_:_:_:_:_:))，kCFStringEncodingGB_18030_2000，lossByte=0、NULL/不完整转换明确失败；只链接目标SDK CoreFoundation。内部桥按[WHATWG GB18030字节语法](https://encoding.spec.whatwg.org/#gb18030-decoder)寻找完整块，字符映射交系统，最多保留3尾字节。Linux继续[POSIX iconv](https://pubs.opengroup.org/onlinepubs/9799919799.2024edition/functions/iconv.html)，禁用IGNORE/TRANSLIT，拒绝非可逆/非法转换。无第三方编码表/Homebrew路径。实际系统标准修订差异不假定相同，codecIdentifier区分Apple/Linux并使旧Apple缓存失效；中文/emoji/补充汉字与补充范围两端、损坏/截断向量通过同样测试才放行，修复后完整CI38547339868通过原断言及扩展向量；macOS执行Core codec向量，iOS41项仍是既有EPUB集成，真实TXT iOS运行/导入/设备随后验证。

摘要按[NIST FIPS180-4](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.180-4.pdf)独立实现流式SHA256，仅作为cache内容身份，已写入空串/abc/跨block/百万a/中文emoji独立向量；未声称密码学认证。cache绑定bookID、原SHA/编码/normalizer/parser/codec版本及normalized/目录SHA，manifest上限8MiB，只存经过BookFileStore校验的同key/generation相对路径。新generation完整后原子提交manifest，旧generation先保留；损坏/缺失重建，不删除原书/数据库，链接/越界拒绝。cache原件hash不变但标题元数据损坏也须重建。旧generation清理与快速元数据重开属于后续。

## 产品接入历史次序（现已实现，最新验收见TXT_READING_DESIGN）

1. 编码正规化：先保留并协调复制原件到受管理目录；接入已有BOM/严格UTF-8校验与明确编码选择、UTF16/GB18030跨块转码到UTF-8旁路文件。无法确定时由用户选择，不覆盖原件。取消/截断/磁盘错误须留下明确失败并清理本次暂存，Apple仍使用NSFileCoordinator。
2. 版本cache：绑定原件SHA256、编码/normalizer版本、parser版本；保存normalized摘要、相对路径和索引。缓存损坏/版本失配可重建，数据库和原书不删除。缓存重开只加载有效元数据/当前窗口；正文改变不得沿用旧索引或位置。摘要实现/跨平台一致性须单独验证，不凭文件大小假装内容hash。
3. TXT位置：完整版本化位置包含源/normalized身份、叶子章节ID、局部字节/文本锚点与视口偏移；验证范围和UTF-8边界，沿用旧异步保存拒绝规则。卷目录序号不直接当小说canonical chapter。
4. 原生阅读接入：通过ReadingInterfaces和ReadiumAdapter提供有限章节资源，复用Readium排版；先核对锁定3.11的公开Publication/resource API，再实现导入/目录/位置/取消集成。既有EPUB流程与用户书库升级保留。

真实TXT入口、不同编码、数十MB冷导入、cache重开、设备页面仍须此后的M2验证，不将本轮Core测试写成完整TXT完成。
