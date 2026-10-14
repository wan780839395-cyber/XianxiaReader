# M2 TXT索引第一切片

状态：2026-10-14 Core源码及19项Swift回归已写入，Windows367文件grammar/14项tooling通过；真实Swift编译待执行。用户已确认Build4连续阅读和重开位置正常，并要求按既定路线继续。M1完整CI通过；其他未逐项确认的设备项目保留，不把核心功能反馈扩写为完整设备矩阵。

本轮完成独立Core能力：识别章节/卷/序章、扫描已规范化UTF-8正文、返回稳定字节范围和分组目录、按有界窗口读取正文。后续接入编码检测/转码、内容与parser版本缓存、事务导入和ReadingInterfaces阅读。原始书籍始终保留；不会把整本String放入ObservableObject，不重写EPUB排版。

## 数据边界

- 输入是已规范化UTF-8文件；本轮严格校验UTF-8。拒绝损坏编码，不用替换字符修补后假称转码成功。UTF-16/GB18030尚未转换。
- 读取使用FileHandle有界chunk，跨块保留UTF-8校验状态、CRLF与标题候选；超长正文行仍扫描/校验，但标题候选有上限，不缓存整行。
- 字节偏移使用Int64，范围[start,end)；标题所在行包括在对应章节正文中，前言/卷序不丢失。卷作为目录分组，分组不拥有重复正文范围；叶子章节范围按顺序连续覆盖正文。
- 章节ID基于同一bookID与标题行字节位置，重复标题不碰撞；parser规则改变及正文改变的缓存失效属于下一切片。
- 无标题非空文件作为单个正文；空文件报错。卷下章节depth=1；不把EPUB目录ordinal直接借用为小说canonical chapter。
- 窗口读取只接受叶子范围和有效UTF-8字节边界，最多固定上限，返回同章局部起止字节；不得读取未来章节。书籍路径必须来自BookFileStore已验证的受管理路径，底层读取器不代替存储路径授权。

## 必须验证

八类标题与反例、序章/卷章/重复标题、跨1字节chunk的多字节/CRLF/BOM/末行、UTF-8损坏及截断、超长行的固定候选内存、无章/空文件、取消、64位offset及窗口末尾字符边界。Windows grammar与Python检查独立；真实Swift测试须Linux/macOS，最终iOS完整CI保留既有41项，不降低断言。

UI布局仍遵循M3完整书库、M4排版/主题。该Core切片完成后不称用户已可导入TXT。

## 参考与选择

查阅[Readest TXT转换器](https://github.com/readest/readest/blob/3cc39ad7a558e6612e1a8135058fbd6f3c90b3e3/apps/readest-app/src/utils/txt.ts)及其标题回归，借鉴中文数字覆盖和卷/章不同边界的原则，独立实现整行识别：章标题允许紧接标题文字；卷类要求分隔或行尾，避免“第一卷的故事”误判。不识别“第一封信/第四本书”等量词正文，标题上限80字符；长行按正文保留，不丢失数据。英文支持Chapter 1及chapter.844。未复制其整本转换/自动按页分章路径；本项目采用原字节范围索引和受限窗口。

FileHandle有界读取依据[Apple read(upToCount:)](https://developer.apple.com/documentation/foundation/filehandle/read(uptocount:))。扫描器/窗口为独立actor，避免主线程全文读取。Docker现场查询失败：`dockerDesktopLinuxEngine`命名管道不存在；没有启动/重置Docker，也未把未执行容器测试记成成功。真实编译由现有完整CI验证33 Core与原41 iOS。
