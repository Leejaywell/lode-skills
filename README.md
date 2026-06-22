# Lodestar —— Claude Code 版

**中文** · [English](https://github.com/Leejaywell/lode-skills-en)

Lodestar 是一套跑在 Claude Code 上的结构化开发流程，把模糊想法拆成 **需求 → 设计 → 计划 → 开发 → 发布** 五个能独立验收的环节。

它不替你保证做出好产品——它保证的是：每一环都有明确的「什么算完成」；确定性的事（编译/测试）由程序卡死、过不了不许收工；不确定的事（需求、审查）逼问到清楚为止。

做法就三条：

- **确定性判断交给程序（hook，即 Claude Code 的钩子脚本）**：编译/测试不过，收工被卡死，不只信模型说的「应该没问题」。
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

> **什么是 Face**：一块**独立、能单独验收**的开发切片。计划阶段（`lode-plan`）把目标拆成若干 Face，开发时逐个做、逐个验收，做完一个再下一个。

**四步审计**（每个 Face 必走，按「确定性 → 判断」排序）：编译验证 → 测试完整性 → 代码审查 → 功能测试。前两步交给门禁实跑，后两步交给子代理/人，全过才算 Done。

> **测试绑需求**：每个 Face 的「验收场景」在计划阶段**先于开发定**，测试照场景写、审查照场景验——堵住「测试绿但功能跑偏」。

---

## 13 个技能（六主线 + 七扩展）

> 命令 = 技能名（在 Claude Code 里 slash 命令就是 skill 名；模型也会按 description 自动触发）。

主线（`①→⑥`）：

| # | 命令（= 技能名） | 干什么 | 产出 |
|---|---|---|---|
| 1 | `/lode-spec` | 把模糊想法**逼问**成可开发需求；开局把现状图备好（改现有代码时走 delta=只写"改什么"） | `product-spec.md` + `system-map.md` |
| 2 | `/lode-brief` | 把"感觉"翻译成具体设计决策（可选） | `design-brief.md` |
| 3 | `/lode-design` | 出高保真设计 / 可交互原型（可选） | `mockups/` |
| 4 | `/lode-plan` | 拆 Face（改现有代码时带影响分析/迁移/基线） | `dev-plan.md` |
| 5 | `/lode-build` | 按计划开发，走四步审计闭环 | 代码 + `changelog.md` |
| 6 | `/lode-release` | 隐私审计 + 打包发布（团队走 PR/CI） | Release |

> 「代码侦察」（读现有代码出 `system-map.md`）已并入 `lode-spec` 开局，不再是单独命令；遇到大型/陌生代码库，spec 会派 `lode-recon` **子代理**（见 `agents/lode-recon.md`）用干净脑子去读。`system-map.md` 是任何项目都有的活地图，由 spec 建立、build 持续更新。

扩展（按需）：

| 命令（= 技能名） | 用途 |
|---|---|
| `/lode-drive` | **自主驱动器**：给一个目标，agent 拆里程碑→Face 跑到底，进度账本可续可审 |
| `/lode-go` | 写一条好 **Go**（目标/标准/验收/约束/执行策略） |
| `/lode-review` | 派**没参与开发的子代理**独立审查（含回归/安全/可追溯） |
| `/lode-fix` | 复现→定位→最小修复→回归 |
| `/lode-skill` | 造新技能：给完整能力，别拆碎工具 |
| `/lode-evolve` | 把真实失败沉淀成规则（自进化引擎） |
| `/lode-init` | 项目初始化（**可选手动逃生口**）：正常由 spec/build 自动铺，本命令仅用于手动预铺 / 自动没生效时补救 |

---

## 安装

> 前置：[Claude Code](https://claude.com/claude-code)。**推荐插件装（方式 1）**——装一次,之后任意项目直接 `/lode-spec`,其余全自动。**脚本装（方式 2）** 是插件系统不可用时的兜底——现在也是一行搞定、门禁自动挂。

### 方式 1：插件安装（推荐）

```bash
/plugin marketplace add Leejaywell/lode-skills
/plugin install lodestar@lodestar
```
> 更新：`/plugin marketplace update`。卸载：`/plugin uninstall lodestar@lodestar`。

**装好后只管用,你不用判断任何脚本何时装:**

- 命令命名空间化为 `/lodestar:lode-spec`、`/lodestar:lode-plan`、`/lodestar:lode-go`…（模型也会按 description 自动触发）；子代理 `lode-review`、`lode-evolve`、`lode-recon` 一并就位。
- **门禁随插件常驻、自动生效**——不用手动合并、不用"启用";门禁在没有 `.lode/` 工作区时自动放行,全局开着无副作用。
- **按项目文件由流程在对的时机自动铺**:`CLAUDE.md`（运行规则）`lode-spec` 一进项目就落、`verify.sh` `lode-build` 开发开始时用真实命令写。**你只敲 `/lode-spec` 即可。**（想手动一次性预铺:可选 `/lodestar:lode-init`,一般用不到。）

### 方式 2：脚本安装（兜底：插件系统不可用的老环境）

不用 clone，**一行搞定，跟方式 1 一样省事**：
```bash
curl -fsSL https://raw.githubusercontent.com/Leejaywell/lode-skills/main/install.sh | bash
```
> 想先看再跑：`curl -fsSL <同一 URL> -o /tmp/lode.sh && bash /tmp/lode.sh`。`CLAUDE_HOME=/path` 改装机目录；`LODE_NO_HOOKS=1` 跳过自动挂门禁。

**装好后跟方式 1 一样——任意项目直接 `/lode-spec`，你不用配置任何东西：**

- 技能/子代理装进 `~/.claude/`；源资产（`CLAUDE.md` + 模板）放 `~/.claude/lodestar/`，供自动铺设取用。
- **门禁自动写进 `~/.claude/settings.json`**（全局生效、幂等、原文件备份为 `settings.json.bak`）——不再需要你手动合并。无 `.lode/` 工作区时自动放行，全局开无副作用。
- `CLAUDE.md`/`verify.sh` 由流程自动铺。
- **跟方式 1 唯一的区别**：命令是**裸** `/lode-spec`（没有 `/lodestar:` 前缀）。

### 不用了怎么卸

- **插件装**：`/plugin uninstall lodestar@lodestar`，再 `/plugin marketplace remove lodestar`。
- **脚本装**：`bash ~/.claude/lode-uninstall.sh`（安装时已放好，离线可用；或远程 `curl -fsSL https://raw.githubusercontent.com/Leejaywell/lode-skills/main/uninstall.sh | bash`）。它删掉 Lodestar 的技能/子代理/门禁脚本/源资产，并**把门禁从 `~/.claude/settings.json` 摘掉**——只摘我们这两条，你别的 hooks 原样保留，原文件备份 `.bak`。
- 默认都**不碰**你项目里的 `.lode/`、项目 `CLAUDE.md`、`verify.sh`（那是你的产物）。想连产物一起清：在该项目目录里跑 `bash ~/.claude/lode-uninstall.sh --purge-project`（删**当前项目**的 `.lode/`，交互运行先确认；项目根 `CLAUDE.md` 仍不动），或直接 `rm -rf .lode`。

---

## 怎么用

### A. 自主跑完（推荐）——一个目标，agent 跑到底

```
/lode-drive 把 <目标> 做完
```
`lode-drive` 自己判断**从零新建 / 改现有代码**与**单人/团队**，拆里程碑→Face，逐个走四步审计+回归，维护进度账本（崩了能续、跑完能审计），偏离就重规划、卡住就**熔断**（连续失败/超预算就停下交给你，不无限烧）。你只在**审 PR**和**接住熔断**时出现。

### B. 手动分步——想自己把着每一环

从零新建项目的最小闭环：
```
/lode-spec    # 逼问需求 → product-spec.md
/lode-plan    # 拆 Face（每个 Face 先定验收场景）→ dev-plan.md
/lode-go      # 生成单个 Face 的 Go，复制发它执行 → 四步审计闭环
```

- **改现有代码**：还是直接 `/lode-spec`——它开局会自动把 `system-map.md` 备好（自己刚建的项目读已有图、外来大库派 `lode-recon` 子代理去读），再走 delta（现状→目标 + 绝不能破坏）。你不用先敲别的。
- 全链路：plan 前可插 `/lode-brief`（+可选 `/lode-design`）；收尾 `/lode-release`（团队走 PR/CI）。
- 执行单个 Face 的三种粒度：主 Agent 直接 `lode-build` 跑完计划 / 逐个 Face 写 Go（最常用）/ 一条 Go 跑全部（熟练后最高效）。

---

## 适用边界 + 模式

精简主线按**一个人 · 从零新建 · 第一版**来调校；靠**两个开关**扩到更复杂的场景（`lode-drive` 开局自动判断，你不用手动设）：

> 两种项目情况：**从零新建** = 还没有任何代码、从头做一个新东西；**改现有代码** = 项目已经有一套代码，你要在上面改或加功能。

- **从零新建 ↔ 改现有代码**：改现有代码时，spec 开局自动把现状摸清成一张系统地图（大库派 `lode-recon` 子代理去读），需求按"改什么"写（delta），计划做影响分析/迁移/基线，验证跑**全量回归**（把原来好的也一起测，别改坏）。
- **一个人 ↔ 多人团队**：一个人用本地 `review-passed` 门禁；多人/长期项目切到 **PR/CI 门禁**，子代理审查降为 PR 前的预筛（不替代人来审）。
- **涉及安全/合规**：再加强制安全审查 + 需求-代码-测试能一一对应。

从零新建走最简流程；要**改现有代码**、或**多人协作**，才上更重的护栏。**自动跑 ≠ 没人管**：即便用 `lode-drive` 全程自动，你仍要在「审 PR」和「接住熔断」两处出现。

---

## 设计原理：三条铁律

1. **少造工具，多给能力** —— 别把一项能力拆成一堆专用小工具，那样反而笨；给完整的通用能力，让模型自己组合。模型的聪明是**放出来的，不是设计出来的**。
2. **规则不要提前写，踩了坑再立** —— 一条规则必须对应一次真实失败；删了它问题会复现，才配留着。没踩过的坑不立规则，立了没用的主动删。
3. **把劲花在设计上，不在钉哨上** —— 别再琢磨提示词；真正值钱的是把流程和循环设计好（每环产出什么、什么标准算过、踩坑怎么办、怎么进化），剩下交给 AI 自己决定。

### 它怎么映射到 Claude Code

| 概念 | Claude Code 机制 | 本仓库位置 |
|---|---|---|
| 13 个技能 | `SKILL.md` 技能 | `skills/lode-*` |
| 顶层规则 | `CLAUDE.md` | `CLAUDE.md` |
| 独立子代理（审查 / 代码侦察 / 进化） | `Agent` 工具 + 子代理 | `agents/lode-{review,recon,evolve}.md` |
| 确定性规则 → 门禁 | **Hooks**（插件 `hooks/hooks.json` / 项目 `.claude/settings.json`） | `hooks/` |
| 自进化（signals→proposals→规则库） | `CLAUDE.md` 规则库 + `lode-evolve` | `CLAUDE.md` + `skills/lode-evolve` |
| 文档驱动 | 运行期 artifacts | `.lode/`（`system-map → product-spec → design-brief → dev-plan → code → changelog`） |
| Go = 目标+标准+验收+约束+执行策略 | 结构化 Go 指令 | `skills/lode-go` |
