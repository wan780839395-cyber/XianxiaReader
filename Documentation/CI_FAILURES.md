# CI 失败与修复证据

## 首次构建：38385729586

- [GitHub Actions](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38385729586)
- Head：`f9c3520f361f6f4b73546c6c5af195071b32c727`
- 仓库检查与 Linux Core job 成功；macOS Core 14 XCTest 执行通过。
- Xcode 16.4 / iOS 18.5 模拟器，iOS App 编译完成后在链接失败，exit 65；iOS tests 未运行，IPA 未生成。
- 完整诊断 artifact 已下载至忽略目录 `build/ci/38385729586/ios/`，包含 build.log、SimulatorTests.xcresult、环境、生成工程和真实 Package.resolved。

关键错误：

```text
ld: building for 'iOS-simulator', but linking in dylib (/opt/homebrew/Cellar/sqlite/3.53.4/lib/libsqlite3.3.53.4.dylib) built for 'macOS'
clang: error: linker command failed with exit code 1
** TEST FAILED **
```

根因：Core 的 systemLibrary 配置 `pkgConfig: "sqlite3"` 将宿主 Homebrew 的 `-L/opt/homebrew/opt/sqlite/lib` 带入 iOS 交叉编译，链接器优先找到 macOS dylib。

修复：去除 pkgConfig 和 Homebrew provider；Apple 直接使用目标 SDK 的 SQLite，Linux 使用系统开发包。保留 modulemap、数据库实现和全部失败/成功测试；重新运行 Linux Core 和完整 macOS CI，不能把源码修改当修复已验证。

首次依赖解析实际成功，11 个远程依赖的原始 lockfile 已复制至根 `Package.resolved`；Readium 3.11.0 revision 与已审查源码一致。下次 CI 严格锁定版本，避免修复期间传递依赖漂移。

## 第二次构建：38389603242

- [GitHub Actions](https://github.com/wan780839395-cyber/XianxiaReader/actions/runs/38389603242)
- Head：`7a2263b4ae75abf733d2edd188e4b298bf80369c`
- 仓库、Linux/macOS Core 通过；严格依赖锁解析通过。未再报告宿主 SQLite 链接错误。
- iOS 构建在 asset catalog 失败：`None of the input catalogs contained a matching stickers icon set or app icon set named "AppIcon"`。exit 65，tests 取消，未生成 IPA。
- 完整诊断下载至 `build/ci/38389603242/ios/`。

修复：新增真正的 AppIcon.appiconset、1024 RGB 不透明 PNG，并显式指定工程 AppIcon。图案为原创书页/山峰/月亮；保留 SVG 与生成脚本，PNG 直接提交供 Xcode 使用，构建不依赖图标生成环境。采用 [Apple 单张高分辨率 asset catalog 配置](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)，不删除图标设置来绕过错误。静态检查现在核对图标文件引用、PNG 尺寸和 RGB 格式；仍须第三次真实 CI。
