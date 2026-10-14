# GitHub 与本地 Git 接续

当前账户和连接以现场查询为准，不从旧聊天推断。2026-10-13 已确认 connector 账户 `wan780839395-cyber`，用户选择 `XianxiaReader` 私有仓库。

当前已完成 CLI 授权、建仓及 main 推送，origin 为 https://github.com/wan780839395-cyber/XianxiaReader.git 。2026-10-14用户明确同意公开，仓库已从PRIVATE改为PUBLIC并经API确认；账单/付款/支出限额未修改。成功 CI run 38390862584 已输出真实 IPA；以下是维护/首次设置流程，不是当前授权阻塞。无需重新生成设备码。

## 公开仓库与构建费用

用户选择公开源码后，继续使用标准GitHub-hosted Ubuntu/macOS runner；公开仓库标准runner免费，自托管runner也免费，大型runner仍收费。不要为本项目切到大型runner或启用付费超额。依据：[GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)。

公开前已核对两个远程分支的27个可达commit、718个历史blob、四本原创样书的六个历史版本及64份已下载CI日志，未发现模式匹配的凭据、个人小说、证书、IPA或大构建缓存。审计范围与限制见ValidationLogs/publication-audit-2026-10-14.json。仓库历史与Actions记录均会公开；个人导入文件和本地build/.cache仍保持忽略。

首次公开后完整验证为run38511938460，实际head=008e6075bb9acd4418d539608cebde19f4ef1dfc，与89a46ce运行源码一致，bootstrap=false。该run已经执行并通过repository-checks，原先账单启动拒绝已不再阻止该步骤；Core/iOS/Release结果以真实完成状态为准。

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
4. 默认按用户选择创建私有仓库，设置 HTTPS origin，正常推送 main。用户明确同意公开时，先核对可达历史与待公开内容，再修改可见性并查询确认；不自行公开用户源码。
5. 读取首次 GitHub Actions 的实际状态和完整日志。若账号额度/计费/权限阻止 macOS runner，记录服务端原因；不得擅自修改支付/支出限额。用户授权的公开或自托管路线可继续实施；不要宣称尚未执行的CI已运行或构建通过。
6. 有真实编译错误时修复源码/工程并重新检查受影响任务。M0 iOS gate 通过之前不大规模进入 TXT。

后续仓库/提交/CI 的实际状态写入 PROJECT_STATUS 与 HANDOFF。没有认证时仍可在本地提交与维护，不伪造远端或发布成功。
