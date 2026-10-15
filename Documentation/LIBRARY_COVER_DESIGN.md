# M3 更换封面（Build13）

状态：完整CI、原生截图/录屏复核已通过，手机选图与观感待验证。不是M3全阶段完成；重复导入仍下一切片。

长按书架书籍进入“更换封面”，显示当前封面、从相册/文件选择、预览、保存、恢复默认。取消不提交；恢复默认先预览再保存。沿用书架灰绿底色、圆角卡片、原生NavigationStack及系统选图器。自选图按2:3居中填充预览与书架，默认EPUB封面保持完整比例；不提供额外裁切工具。保存失败保留草稿与错误，可重试。保存期间禁取消/交互关闭，处理期间可取消；辅助功能沿用系统Reduce Motion，书架封面只有短透明度过渡。

## 数据与中断恢复

Book增加可选coverOverride（仅assetID UUID）；旧payload缺字段仍可解码。displayCoverPath优先派生自选thumbnail，否则原coverPath。数据库schema2/迁移不变；BEGIN IMMEDIATE内读取最新Book，只改override，原件、默认封面、标题、导入日期、目录、完整ReadingPosition及Bookmark不改。清空override就是恢复默认。

Core BookFileStore只处理文件，不引入UIKit/ImageIO。复制经既有Apple NSFileCoordinator，来源必须非空普通文件且不超过20MiB，复制后再核验实际节点/大小。先放StagingCovers/<assetUUID>/original；ImageIO验证后产生最长边1080px JPEG（quality0.85，透明底合成灰绿），Core接受1…2MiB缩略图。移动整个草稿目录到Books/<bookUUID>/Artwork/<assetUUID>/后再提交DB。路径全由UUID派生，每次经resolve验证父节点与dangling link，禁止受管理路径符号链接。

DB失败将本次新资产移回草稿，保存按钮可再次提交；只有本次finalize成功才允许回移，重复保存已提交草稿不得回移旧资产；取消/坏图清理未提交草稿，清理失败连同原始错误可见。数据库提交后不再因取消删除资产。启动清理StagingCovers，Books清理以包含回收站的allBookIDs为准。文件移动和DB不能跨系统原子：移动后、提交前崩溃可能留一份未引用Artwork；本轮保留所有已移动原图，不自动GC，避免错误删除已提交资产。替换/恢复默认不回收旧自选图，不承诺释放磁盘。照片provider临时文件在FileRepresentation回调内复制到应用临时目录，再转入书库草稿；正常流程显式清理，硬中断临时副本由系统临时目录回收。

## 并发与内存

CoverImportService/BookFileStore/CoverImagePipeline均actor。原图保留完整字节，来源security scope持有到准备完成，不在主线程整图Data解码。ImageIO源shouldCache=false，读像素尺寸并拒绝超过8000万像素，thumbnailWithTransform修正EXIF一次，输出CGImage后不附加旧方向。后台立即解码有界缩略图，列表最长边252px、网格600px、编辑1080px；NSCache配置12MiB/64项的可回收缓存限额（并非严格内存硬上限），不能作为设备峰值内存保证。自选缩略图缺失时从保留原图有界读取并显示“已从原图恢复封面”；双失败保留两条诊断并显示标题封面。

编辑模型的requestID、Task取消及closed状态同时核对。新选择使旧任务失效；迟到完成只清理自己的草稿，不覆盖新预览或新editor；退出使Coordinator失效。文件选择沿用首次导入已验证的一次性终止delegate，editor持有到回调，覆盖旧单URL与多URL回调。保存完成后刷新请求ID失效旧快照，仅当前editor可关闭自己的sheet；不清空后来新建的editor。

## 参考与取舍

- [Apple ImageIO方向转换](https://developer.apple.com/documentation/imageio/kcgimagesourcecreatethumbnailwithtransform)及[WWDC2018图片最佳实践](https://devstreaming-cdn.apple.com/videos/wwdc/2018/219mybpx95zm9x/219/219_image_and_graphics_best_practices.pdf)：采用URL来源、后台下采样和立即缩略解码，避免先UIImage全图解码再缩放。
- [Apple SwiftUI PhotosPicker示例](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app)、[FileRepresentation](https://developer.apple.com/documentation/coretransferable/filerepresentation)：iOS16公开API，临时文件在回调有效期内复制，避免DataRepresentation整张大图缓冲。
- [Nuke 13.0.1 decoder](https://github.com/kean/Nuke/blob/13.0.1/Sources/Nuke/Decoding/ImageDecoders%2BDefault.swift)和[上游方向重复应用问题870](https://github.com/kean/Nuke/issues/870)：审阅成熟下采样/方向处理。Nuke13需要新工具链，与当前Xcode16.4不同，本项目不引入依赖或照搬其unchecked Sendable/网络管线；当前纯本地ImageIO actor即可，显式验证EXIF输出不携带旧方向。Readium3.11及六pins锁不变。

## 验证范围

Core新增9项：旧payload、完整关联/重开/回收站/默认、最新payload、真实SQLite失败/重试、暂存/回滚/恢复、大小/普通文件、父级及dangling链接、取消/根目录系统别名。iOS新增8项：真实ImageIO方向/尺寸/原图、缺缩略图警告、真实TXT+EPUB启动恢复与默认、真实DB失败预览重试、确定性迟到/关闭、首个delegate回调/错误重选、照片provider副本、原生错误/预览/书架/默认四图。新增真实XCUITest走长按/Files取消/默认预览取消/默认保存/重启，成功case视频保留。自动测试和视频不代替手机相册/File Provider权限、各种HEIC/旋转/FPS与其他设备验收。所有旧70iOS、91Core、四长书Release探针及无签名设备Release继续完整运行，最终结果以独立报告为准。


## 最终证据

Build13更换封面切片通过[完整CI38694877516](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38694877516) / `708d02d0ecadcb3d22d653965aa94203bf4ab227`：Linux/macOS各100Core、iOS79/79（75集成+4真正XCUITest），failed/skipped0，test/export/summary/recording退出0、无签名设备Release13与真实IPA、各四长书Release探针。Windows407Swift语法新增0/54 pristine限制、17tooling通过；语法不是Swift编译。487运行/验证源Git blob hash、三份真实六pins锁与19旧包hash匹配。

长按书籍→更换封面，从系统相册或文件选图，预览后保存；恢复默认先预览再保存，取消不提交。原书、默认封面、目录、完整位置、书签、书名与UUID保留。后台有界ImageIO下采样和缩略缓存，网格/列表更新有短淡入淡出并尊重Reduce Motion。真实DB失败保留草稿可重试；迟到/关闭/旧回调不能覆盖新选择。重复save已提交草稿不能回移已提交原图。schema2与旧迁移/Reader/codec/Vendor/依赖锁不变。

原生错误/待保存预览/书架/默认预览和实际XCUITest的Files取消/默认取消/保存/重开截图及视频已单独复核。测试夹具只在DEBUG隔离目录，Release恒nil且Mach-O无XR_LIBRARY_UI_*旗标。自动测试/录屏不当手机相册/File Provider权限、全部图像格式/旋转、手机FPS/耗电或普通签名设备验收。单图20MiB/8000万像素限制；旧自选原图保留，不自动GC或释放存储；自由裁切未提供。M3还剩重复导入策略，M4完整主题/正文排版和M5设备性能未开始。

安装包`build/XianxiaReader-Cover-Build13.ipa` / SHA256 `57a6e0c9639af654abd106bcd187ee7b37d721d3cedf315d2a1677aa5e4d6009`；测试ZIP`build/XianxiaReader-Cover-Build13-TestKit.zip` / SHA256 `85e5f5aef4886416d2aed4126b3e142be8749b3dc3bdceae29366e953628ac9c`，内部IPA/11原创样本/封面样本/CRC核验。正常更新保留书库，+菜单确认0.0.1 (13)。设计LIBRARY_COVER_DESIGN.md、报告M3_COVER_VALIDATION_REPORT.json。Build12用户已接受当前观感，具体硬件/实测FPS未独立读出，Build13手机待测。

中间候选CI38688984422由Agent为提交边界保护主动取消，各100Core通过、Linux四探针通过，Apple长书探针未结束/iOS/Release未运行；完整日志与取消原因保留ValidationLogs/m3-library-build13-first-cancellation.json，不写成源码失败。

第二轮CI38689366894各100Core/四探针通过，iOS78/79（75集成全通过、原3UI通过，新UI标题查询失败），test65使Release未运行；原生AX树/视频确认系统Files已正常打开，修正子label查询并保留10秒/后续全部断言。另修纯row builder的MainActor警告，未禁用诊断。原件ValidationLogs/m3-library-build13-file-picker-ax-failure.json，最终成功不覆盖失败历史。

第三轮CI38691894649各100Core/四探针通过，iOS77/79：Files取消的全局indexed AX查找失败，以及旧fragment/DOM书签回归navigationFailed；8新封面集成与旧3UI通过。最终用本地AX包装实际frame/public coordinate点取消并断言Files确实消失；布局改为值初始化的独立子View和MainActor body，消除Spacer隔离警告。旧Reader只增阶段打印，原导航/几何/timeout和生产Reader均未改；一次navigationFailed的唯一原因仍未确认，后续全绿不写成已修复全部WebKit时序。原件ValidationLogs/m3-library-build13-cancel-ax-and-reader-failure.json。
