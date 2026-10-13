# Windows Docker 启动故障与恢复记录

日期：2026-10-13（Asia/Shanghai）。此问题发生在 Core 编译验证的工具环境中，尚未涉及 iOS 应用构建。

## 已证实的原因

Docker Desktop 4.77.0.228796 初始化 Inference manager 时退出。backend 日志记录：

```text
initializing Inference manager: listening on unix://C:/Users/78083/AppData/Local/Docker/run/dockerInference:
remove ...dockerInference: The file cannot be accessed by the system.
(listener: The filename, directory name, or volume label syntax is incorrect.)
```

停止 Docker 后，`Docker/run` 下的 `dockerInference`、`dockerEthernetVfkit`、`userAnalyticsOtlpHttp.sock` 和 `docker-secrets-engine/engine.sock` 仍是 2026-10-06 留下的零字节 reparse point。Win32 `FindFirstFileW` 返回 tag `0x80000023`（AF_UNIX），以 `FILE_FLAG_OPEN_REPARSE_POINT` 打开仍失败，错误为 1920。父目录可读、为普通目录，当前用户在父目录的权限正常。

直接故障是失效的旧 AF_UNIX 通信端点阻塞服务初始化。尚未证实造成端点失效的更深层 Windows/WSL/文件系统原因，不能据此断言磁盘损坏。

## 已执行的有限修复

确认 Docker Desktop/backend 已停止，并核对以下目录仅包含失效的零字节 socket 后，用原生 PowerShell 改名保存原目录，再创建空运行目录：

| 原路径 | 保留备份 |
| --- | --- |
| `%LOCALAPPDATA%/Docker/run` | `%LOCALAPPDATA%/Docker/run.xianxia-backup-20261013-174018` |
| `%LOCALAPPDATA%/docker-secrets-engine` | `%LOCALAPPDATA%/docker-secrets-engine.xianxia-backup-20261013-174018` |

没有删除 socket 备份、镜像、容器、VHDX、凭据或配置，没有 factory reset。之后调用 `docker desktop start --detach`，再用 `docker version --format '{{json .Server}}'` 验证：服务已响应，Docker Engine 29.5.3、Linux amd64、WSL kernel 6.18.33.1。这验证了本次启动恢复，不保证旧版本永不复发。

端点证据和备份计划保存在 `ValidationLogs/docker-socket-probe.json` 与 `ValidationLogs/docker-runtime-quarantine.json`。备份不能在 Docker 运行中恢复；后续处理先停 Docker、核对目录与数据边界。不要把本次特殊故障的操作作为每次启动前的自动清理步骤。

## 后续处理

Docker 维护者在 [同类故障 issue #625](https://github.com/docker/desktop-feedback/issues/625) 中表示 4.92 已包含此区域的修复。本机仍是 4.77；应通过 Docker Desktop 的官方更新流程升级到包含修复的稳定版本。2026-10-13 查阅的 [官方 release notes](https://docs.docker.com/desktop/release-notes/) 最新稳定版本为 4.95.0（2026-10-12）。本次没有执行安装或系统重启。

后续用户已明确授权升级。官方 updater 确认可用 4.95.0.242831，安装包签名 Valid / Docker Inc，SHA-256 与官方 checksum 一致。调用 `docker desktop update --quiet` 后，installer 请求管理员授权，2026-10-13 18:02:49 日志返回“操作已被用户取消”；因此本次尝试没有完成升级。失败日志为 `ValidationLogs/docker-upgrade-cancelled.log` 与 `docker-upgrade-error.json`。已终止自己的挂起更新命令，旧 engine 保持运行；等待用户选择是否重试并确认 Windows UAC，不能通过忽略该错误宣称新版已安装。

若复发，保留新的 backend 日志，核实失败端点和 Docker 版本；不要删除项目、重置 Docker 全部数据或反复无证据改名目录。

## 与项目验证的关系

恢复后运行 `scripts/test_core_container.ps1`，使用 digest 锁定的官方 Swift 6.1.2 Linux 容器，源码只读挂载，未映射端口。完整输出在 `build/logs/core-container.log`。这只验证 Foundation/SQLite Core；UIKit、Readium Navigator、Apple 文件协调和 IPA 仍须 macOS/Xcode 验证。最终结果以 `VALIDATION.md` 和 Core 验证报告为准。
