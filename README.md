# Lodestar —— Claude Code 版

**中文** · [English](https://github.com/Leejaywell/lode-skills-en)

Lodestar 是一套跑在 Claude Code 上的结构化开发流程，把模糊想法拆成 **需求 → 设计 → 计划 → 开发 → 发布** 五个能独立验收的环节。

它不替你保证做出好产品——它保证的是：每一环都有明确的「什么算完成」；确定性的事（编译/测试）由程序卡死、过不了不许收工；不确定的事（需求、审查）逼问到清楚为止。

做法就三条：

- **确定性判断交给 hook**：编译/测试不过，收工被卡死，不只信模型说的「应该没问题」。
- **审查交给没参与开发的子代理**：一颗没参与开发的干净脑子，才审得准。
- **规则从真实失败里长**：踩了坑才立规则，没用的主动删——规则只许更精练，不许越堆越多。

---

## 五个环节

```
需求 ──→ 设计 ──→ 计划 ──→ 开发 ──→ 发布
逼问要   翻成具   拆成可   每个     隐私审计
做什么   体决策   验收的   Face 走  + 打包
        (可选)   Face     四步审计
```

每环产出一份文档，落在 `.lode/<project>/`，作为下一环的输入——AI 跨环节不靠记忆，靠这些文档。

**四步审计**（每个 Face 必走，按「确定性 → 判断」排序）：编译验证 → 测试完整性 → 代码审查 → 功能测试。前两步交给门禁实跑，后两步交给子代理/人，全过才算 Done。

> **测试绑需求**：每个 Face 的「验收场景」在计划阶段**先于开发定**，测试照场景写、审查照场景验——堵住「测试绿但功能跑偏」。

---

## 14 个技能（七主线 + 七扩展）

> 命令 = 技能名（在 Claude Code 里 slash 命令就是 skill 名；模型也会按 description 自动触发）。

主线（`⓪→⑥`）：

| # | 命令（= 技能名） | 干什么 | 产出 |
|---|---|---|---|
| 0 | `/lode-recon` | **（棕地）** 摸清现有架构/约定/命令/基线 | `system-map.md` |
| 1 | `/lode-spec` | 把模糊想法**逼问**成可开发需求（棕地走 delta） | `product-spec.md` |
| 2 | `/lode-brief` | 把"感觉"翻译成具体设计决策（可选） | `design-brief.md` |
| 3 | `/lode-design` | 出高保真设计 / 可交互原型（可选） | 设计稿/原型 |
| 4 | `/lode-plan` | 拆 Face（棕地带影响分析/迁移/基线） | `dev-plan.md` |
| 5 | `/lode-build` | 按计划开发，走四步审计闭环 | 代码 + `changelog.md` |
| 6 | `/lode-release` | 隐私审计 + 打包发布（团队走 PR/CI） | Release |

扩展（按需）：

| 命令（= 技能名） | 用途 |
|---|---|
| `/lode-drive` | **自主驱动器**：给一个目标，agent 拆里程碑→Face 跑到底，进度账本可续可审 |
| `/lode-go` | 写一条好 **Go**（目标/标准/验收/约束/执行策略） |
| `/lode-review` | 派**没参与开发的子代理**独立审查（含回归/安全/可追溯） |
| `/lode-fix` | 复现→定位→最小修复→回归 |
| `/lode-skill` | 造新技能：给完整能力，别拆碎工具 |
| `/lode-evolve` | 把真实失败沉淀成规则（自进化引擎） |
| `/lode-init` | 项目初始化：一键铺 `CLAUDE.md` + `.lode/<project>/verify.sh`（插件装后开跑用） |

---

## 安装

> 前置：[Claude Code](https://claude.com/claude-code)。**推荐走插件**——更新、卸载、门禁挂载都自动；插件支持两种来源：**GitHub** 或**本地 clone**。装好后在项目里跑一次 `/lode-init` 把按项目文件铺好。脚本安装仅作老环境兜底。

### 插件安装（推荐）

**来源 1：GitHub（最简）**
```bash
/plugin marketplace add Leejaywell/lode-skills
/plugin install lodestar@lodestar
```

**来源 2：本地 clone（离线 / 想改源码）**
```bash
git clone https://github.com/Leejaywell/lode-skills.git
# 在 Claude Code 里：
/plugin marketplace add ./lode-skills
/plugin install lodestar@lodestar
```
> 更新：在仓库里 `git pull` 后 `/plugin marketplace update`。卸载：`/plugin uninstall lodestar@lodestar`。

**两种来源装好后都一样：**

- 命令命名空间化为 `/lodestar:lode-spec`、`/lodestar:lode-plan`、`/lodestar:lode-go`…（模型也会按 description 自动触发）；子代理 `lode-review`、`lode-evolve` 一并就位。
- **门禁随插件自动生效**——不用手动合并 hooks；门禁脚本在没有 `.lode/` 工作区时自动放行，故全局启用无副作用。
- **在目标项目里跑一次 `/lodestar:lode-init`**：把顶层规则 `CLAUDE.md` + `.lode/<project>/verify.sh` 骨架铺好（这两个按项目文件插件不会自动落地）。然后 `/lodestar:lode-spec` 开跑。

### 脚本安装（兜底：插件系统不可用的老环境）

```bash
git clone https://github.com/Leejaywell/lode-skills.git
cd lode-skills && bash install.sh
```
把 `skills/lode-*`、`agents/lode-*` 拷进 `~/.claude/`，命令为**裸** `/lode-spec`、`/lode-plan`…（只想装当前项目：把 `skills/`、`agents/` 拷进项目 `.claude/`）。脚本装没有插件的自动门禁，需在项目里手动：① 把 `hooks/settings.json` 的 `hooks` 块合并进 `.claude/settings.json`（脚本走 `$CLAUDE_PROJECT_DIR/hooks/`，记得 `cp -R hooks ./` 并 `chmod +x`）；② 跑 `/lode-init` 铺 `CLAUDE.md` + `verify.sh`。

---

## 怎么用

### A. 自主跑完（推荐）——一个目标，agent 跑到底

```
/lode-drive 把 <目标> 做完
```
`lode-drive` 自己判断**新/老项目**与**单人/团队**，拆里程碑→Face，逐个走四步审计+回归，维护进度账本（崩了能续、跑完能审计），偏离就重规划、卡住就熔断。你只在**审 PR**和**接熔断**时出现。

### B. 手动分步——想自己把着每一环

绿地最小闭环：
```
/lode-spec    # 逼问需求 → product-spec.md
/lode-plan    # 拆 Face（每个 Face 先定验收场景）→ dev-plan.md
/lode-go      # 生成单个 Face 的 Go，复制发它执行 → 四步审计闭环
```

- **老项目**：先 `/lode-recon` 出 `system-map.md`，spec 自动走 delta（现状→目标 + 绝不能破坏）。
- 全链路：plan 前可插 `/lode-brief`（+可选 `/lode-design`）；收尾 `/lode-release`（团队走 PR/CI）。
- 执行单个 Face 的三种粒度：主 Agent 直接 `lode-build` 跑完计划 / 逐个 Face 写 Go（最常用）/ 一条 Go 跑全部（熟练后最高效）。

---

## 适用边界 + 模式

精简主线按 **单人 · 绿地 · 0→1** 调校；靠**两个模式开关**扩到老项目和团队（`lode-drive` 开局自动判定）：

- **绿地 ↔ 棕地**：老项目先 `/lode-recon` 出系统地图，spec 走 delta，plan 做影响分析/迁移/基线，verify 跑**全量回归**。
- **单人 ↔ 团队**：单人用本地 `review-passed` 门禁；团队/长生命周期切 **PR/CI 门禁**，子代理审查降为 PR 前过滤（不替代人审）。
- **安全/合规**：再加强制安全审 + 需求-代码-测试可追溯。

绿地走精简流程，老项目和团队才上重护栏。**自主 ≠ 无人**：即便用 `lode-drive` 自主跑，人仍在「审 PR」和「接熔断」两处出现。

---

## 设计原理：三条铁律

1. **少造工具，多给能力** —— 别把一项能力拆成一堆专用小工具，那样反而笨；给完整的通用能力，让模型自己组合。模型的聪明是**放出来的，不是设计出来的**。
2. **规则不要提前写，踩了坑再立** —— 一条规则必须对应一次真实失败；删了它问题会复现，才配留着。没踩过的坑不立规则，立了没用的主动删。
3. **把劲花在设计上，不在钉哨上** —— 别再琢磨提示词；真正值钱的是把流程和循环设计好（每环产出什么、什么标准算过、踩坑怎么办、怎么进化），剩下交给 AI 自己决定。

### 它怎么映射到 Claude Code

| 概念 | Claude Code 机制 | 本仓库位置 |
|---|---|---|
| 14 个技能 | `SKILL.md` 技能 | `skills/lode-*` |
| 顶层规则 | `CLAUDE.md` | `CLAUDE.md` |
| 独立审查子代理 | `Agent` 工具 + 子代理 | `agents/lode-review.md` |
| 确定性规则 → 门禁 | **Hooks**（插件 `hooks/hooks.json` / 项目 `.claude/settings.json`） | `hooks/` |
| 自进化（signals→proposals→规则库） | `CLAUDE.md` 规则库 + `lode-evolve` | `CLAUDE.md` + `skills/lode-evolve` |
| 文档驱动 | 运行期 artifacts | `.lode/`（`product-spec → design-brief → dev-plan → code → changelog`） |
| Go = 目标+标准+验收+约束+执行策略 | 结构化 Go 指令 | `skills/lode-go` |
