# M3 更换封面（Build13）

状态：源码和回归已写，待完整CI、原生截图/录屏与设备验证。不是M3全阶段完成；重复导入仍下一切片。

长按书架书籍进入“更换封面”，显示当前封面、从相册/文件选择、预览、保存、恢复默认。取消不提交；恢复默认先预览再保存。沿用书架灰绿底色、圆角卡片、原生NavigationStack及系统选图器。自选图按2:3居中填充预览与书架，默认EPUB封面保持完整比例；不提供额外裁切工具。保存失败保留草稿与错误，可重试。保存期间禁取消/交互关闭，处理期间可取消；辅助功能沿用系统Reduce Motion，书架封面只有短透明度过渡。

## 数据与中断恢复

Book增加可选coverOverride（仅assetID UUID）；旧payload缺字段仍可解码。displayCoverPath优先派生自选thumbnail，否则原coverPath。数据库schema2/迁移不变；BEGIN IMMEDIATE内读取最新Book，只改override，原件、默认封面、标题、导入日期、目录、完整ReadingPosition及Bookmark不改。清空override就是恢复默认。

Core BookFileStore只处理文件，不引入UIKit/ImageIO。复制经既有Apple NSFileCoordinator，来源必须非空普通文件且不超过20MiB，复制后再核验实际节点/大小。先放StagingCovers/<assetUUID>/original；ImageIO验证后产生最长边1080px JPEG（quality0.85，透明底合成灰绿），Core接受1…2MiB缩略图。移动整个草稿目录到Books/<bookUUID>/Artwork/<assetUUID>/后再提交DB。路径全由UUID派生，每次经resolve验证父节点与dangling link，禁止受管理路径符号链接。

DB失败将本次新资产移回草稿，保存按钮可再次提交；取消/坏图清理未提交草稿，清理失败连同原始错误可见。数据库提交后不再因取消删除资产。启动清理StagingCovers，Books清理以包含回收站的allBookIDs为准。文件移动和DB不能跨系统原子：移动后、提交前崩溃可能留一份未引用Artwork；本轮保留所有已移动原图，不自动GC，避免错误删除已提交资产。替换/恢复默认不回收旧自选图，不承诺释放磁盘。照片provider临时文件在FileRepresentation回调内复制到应用临时目录，再转入书库草稿；正常流程显式清理，硬中断临时副本由系统临时目录回收。

## 并发与内存

CoverImportService/BookFileStore/CoverImagePipeline均actor。原图保留完整字节，来源security scope持有到准备完成，不在主线程整图Data解码。ImageIO源shouldCache=false，读像素尺寸并拒绝超过8000万像素，thumbnailWithTransform修正EXIF一次，输出CGImage后不附加旧方向。后台立即解码有界缩略图，列表最长边252px、网格600px、编辑1080px；NSCache成本12MiB/64项是系统可回收上限，不能作为设备峰值内存保证。自选缩略图缺失时从保留原图有界读取并显示“已从原图恢复封面”；双失败保留两条诊断并显示标题封面。

编辑模型的requestID、Task取消及closed状态同时核对。新选择使旧任务失效；迟到完成只清理自己的草稿，不覆盖新预览或新editor；退出使Coordinator失效。文件选择沿用首次导入已验证的一次性终止delegate，editor持有到回调，覆盖旧单URL与多URL回调。保存完成后刷新请求ID失效旧快照，仅当前editor可关闭自己的sheet；不清空后来新建的editor。

## 参考与取舍

- [Apple ImageIO方向转换](https://developer.apple.com/documentation/imageio/kcgimagesourcecreatethumbnailwithtransform)及[WWDC2018图片最佳实践](https://devstreaming-cdn.apple.com/videos/wwdc/2018/219mybpx95zm9x/219/219_image_and_graphics_best_practices.pdf)：采用URL来源、后台下采样和立即缩略解码，避免先UIImage全图解码再缩放。
- [Apple SwiftUI PhotosPicker示例](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app)、[FileRepresentation](https://developer.apple.com/documentation/coretransferable/filerepresentation)：iOS16公开API，临时文件在回调有效期内复制，避免DataRepresentation整张大图缓冲。
- [Nuke 13.0.1 decoder](https://github.com/kean/Nuke/blob/13.0.1/Sources/Nuke/Decoding/ImageDecoders%2BDefault.swift)和[上游方向重复应用问题870](https://github.com/kean/Nuke/issues/870)：审阅成熟下采样/方向处理。Nuke13需要新工具链，与当前Xcode16.4不同，本项目不引入依赖或照搬其unchecked Sendable/网络管线；当前纯本地ImageIO actor即可，显式验证EXIF输出不携带旧方向。Readium3.11及六pins锁不变。

## 验证范围

Core新增9项：旧payload、完整关联/重开/回收站/默认、最新payload、真实SQLite失败/重试、暂存/回滚/恢复、大小/普通文件、父级及dangling链接、取消/根目录系统别名。iOS新增8项：真实ImageIO方向/尺寸/原图、缺缩略图警告、真实TXT+EPUB启动恢复与默认、真实DB失败预览重试、确定性迟到/关闭、首个delegate回调/错误重选、照片provider副本、原生错误/预览/书架/默认四图。新增真实XCUITest走长按/Files取消/默认预览取消/默认保存/重启，成功case视频保留。自动测试和视频不代替手机相册/File Provider权限、各种HEIC/旋转/FPS与其他设备验收。所有旧70iOS、91Core、四长书Release探针及无签名设备Release继续完整运行，最终结果以独立报告为准。
