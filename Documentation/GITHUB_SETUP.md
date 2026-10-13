# GitHub 与本地 Git 接续

当前账户和连接以现场查询为准，不从旧聊天推断。2026-10-13 已确认 connector 账户 `wan780839395-cyber`，用户选择 `XianxiaReader` 私有仓库。

## 两条授权路径

GitHub connector 用于查询仓库、CI 与 PR；本机 GitHub CLI 用于创建仓库、Git push 和取回构建日志。连接 connector 不等于本机 `gh auth login` 成功。

项目缓存中已安装官方 GitHub CLI 2.102.0 便携版，下载 SHA-256 已与官方 release checksums 对照。`.cache/` 不提交；可以使用系统安装的 gh，或在当前 Windows 工作区读取便携路径：

```powershell
$taskGh = (Get-Content .cache/tools/github-cli.json -Raw | ConvertFrom-Json).executable
& $taskGh auth status
```

首次本机授权使用官方设备登录流程，由账户本人登录并确认。不要把密码、PAT、OAuth token 或一次性代码写进项目文档或 Git。工作流提交需要 workflow scope：

```powershell
& $taskGh auth login --hostname github.com --git-protocol https --web --scopes workflow
```

成功后核实 `gh api user` 的 login/id 与已绑定账户相同。提交作者只在本仓库设置，采用 GitHub ID-based noreply 邮箱，避免提交个人联系邮箱。

## 建仓与推送顺序

1. 检查 local Git 状态、忽略规则、待提交文件和真实验证结果；确认仅项目源文件/小型原创样书/证据进入提交。
2. 创建本地阶段提交。新文本统一 LF，原始日志保持字节。FILE_INVENTORY 与 Core report 必须对应当前文件，不能把格式变更后的旧 hash 当最新证据。
3. 查询账户下是否已有 XianxiaReader；若存在，先核对内容和 remote，禁止覆盖、force push 或擅自复用其他项目。
4. 使用已确认账户创建私有仓库，设置 HTTPS origin，正常推送 main。不要创建 public repo 来规避私有 CI 配额。
5. 读取首次 GitHub Actions 的实际状态和完整日志。若账号额度/计费/权限阻止 macOS runner，记录服务端原因；只有用户能处理账号设置。不要宣称 CI 已运行或构建通过。
6. 有真实编译错误时修复源码/工程并重新检查受影响任务。M0 iOS gate 通过之前不大规模进入 TXT。

后续仓库/提交/CI 的实际状态写入 PROJECT_STATUS 与 HANDOFF。没有认证时仍可在本地提交与维护，不伪造远端或发布成功。
