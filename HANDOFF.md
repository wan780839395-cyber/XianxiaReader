# 当前交接与恢复点

更新时间：2026-10-15（Asia/Shanghai）

## M4 第一片：开始检查点

用户“继续”授权进入 M4。已按 AGENTS 顺序恢复文档，核过 main HEAD 6d761749911233122bcd031fcf718d22a19f9e77、原 index 空、M2 tip 未动、M3 文档 tip 44af41f0b8e700db1c6815558cb95ce3b8ed08fc。706 维护文件、492 已编译运行/验证源 Git blob、23 新旧交付包、Build14 原始备份逐 hash/CRC 核过；只有文档晚于 Build14 编译。未发现自身遗留构建/监视/下载/视频任务。

开始前原始 706 文件及 inventory 共 707 项已独立备份到 .cache/recovery/20261015-build15/initial-worktree.zip，并检查 CRC；不改原 HEAD/index，保留全部未提交改动。前交接原件见 Documentation/HANDOFF_M4_SETTINGS_HISTORY_2026-10-15.md。

本轮限定五种阅读主题、内置字体选择与基础排版、全局偏好持久化和排版变化保持完整阅读位置。先核实锁定 Readium 3.11 Preferences/既有 DOM anchor API，再实现 ReadingInterfaces 能力和原生设置面板。字体文件导入、单书覆盖、四边独立间距、亮度、音量键及完整 M4 门槛后续推进。此刻源码尚未实现/编译，Build15 尚不存在；不得把计划写成验收。每可恢复步骤及构建/测试前继续更新此文。

## 已验证基线

Build14 b67a08bc7f6d0db0c97ec152a87e2128a3209c82 / CI38703788390：Linux/macOS 各110 Core、iOS84/84（79集成+5UI）、无签名设备 Release14、各四长 TXT Release探针。五种结果分开：Windows语法411/17 Python、Apple编译/模拟器通过；用户“没问题 正常”基本自用通过，其他设备/Provider/手机FPS矩阵未验。包与旧失败日志全部保留，不覆盖。详见 M3_DUPLICATES_VALIDATION_REPORT.json 及历史交接。M3 既定自用阶段收口，M4整体尚未完成。

M4源码子步骤已保存：Core版本化外观/受管理原子存储、可选ReadingInterfaces能力、Adapter Preferences映射/取消与DOM保护、原生设置面板、全局加载/串行保存与可见失败、DEBUG真实Reader UI样本；新增Core/iOS/UI回归。设计READING_APPEARANCE_DESIGN.md记录3.11官方资料和CJK缩进局部取舍。现在运行Windows语法与Python tooling，尚未编译，不宣称功能通过。

Windows检查完成：417 Swift语法文件，新增diagnostics0/上游pristine限制54；17 Python tooling通过，非Swift编译。准备通过新codex/m4-reading-appearance私有index候选推送/完整CI；原main/HEAD及index不动。预计115 Core各平台、89 iOS（83集成+6UI）；未完成测试前不打包。
