# Lodestar —— Claude Code 版

**中文** · [English](https://github.com/Leejaywell/lode-skills-en)

> **Lodestar** —— 一套构建在 Claude Code 原生能力上的结构化开发流程，带你把一句话的模糊想法，一步步做成可运行、可发布的产品。
> 一句话：**你定星，AI 导航**。
>
> **核心信念**：Prompt 正在贬值，流程设计正在升值。AI 不再是工具，而是整个开发流程的执行者。
> **人定目标，AI 跑循环**：人只做两件事——**做决定**和**验收结果**，连「定目标」都能让 AI 代笔。
>
> 它把开发拆成 **需求 → 设计 → 计划 → 开发 → 发布** 五个可独立验收的环节：用 hook 做确定性门禁（编译/测试不过不许收工）、用独立子代理做干净审查、用真实失败沉淀规则。哪怕你刚接触 vibe coding，跟着走也能做出能用的东西。

---

## Lodestar 如何构建在 Claude Code 上

| 概念 | Claude Code 机制 | 本仓库位置 |
|---|---|---|
| 11 个 Skill | `SKILL.md` 技能 | `skills/lode-*` |
| 顶层规则 | `CLAUDE.md` | `CLAUDE.md` |
| 子代理 | `Agent` 工具 + 子代理 | `agents/lode-review.md` |
| 确定性规则 → 门禁 | **Hooks**（`.claude/settings.json`） | `hooks/` |
| 自进化（signals→proposals→规则库） | `CLAUDE.md` 规则库 + Evolution Runner | `CLAUDE.md` + `skills/lode-evolve` |
| Skill 只写 Usage/Done/Guardrails | Skill frontmatter + 极简正文 | 每个 `SKILL.md` |
| 文档驱动（product-spec→Brief→Plan→Code→Changelog） | 仓库内 artifacts | `.lode/` 运行期产物 |
| Go = 目标+标准+验收+约束+执行策略 | 结构化 Go 指令 | `skills/lode-go` |

> 装机结构：skill 放 `~/.claude/skills/`（或项目 `.claude/skills/`），子代理放 `.claude/agents/`，hook 写 `.claude/settings.json`，顶层规则写 `CLAUDE.md`。

---

## 13 个技能（七主线 + 六扩展）

> 命令 = 技能名（在 Claude Code 里，slash 命令就是 skill 名；模型也会按 description 自动触发）。

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
| `/lode-drive` | **自主驱动器**：一个目标自主跑完，进度账本可续可审 |
| `/lode-go` | 写一条好 **Go**（目标/标准/验收/约束/执行策略） |
| `/lode-review` | 派**干净脑子**的子 Agent 独立审查（含回归/安全/可追溯） |
| `/lode-fix` | 复现→定位→最小修复→回归 |
| `/lode-skill` | 造新技能：给完整能力，别拆碎工具 |
| `/lode-evolve` | 把真实失败沉淀成规则（自进化引擎） |

---

## 适用边界 + 模式

精简主线为**单人 · 绿地 · 0→1** 调校；靠**两个模式开关**扩到老项目与团队（`lode-drive` 开局自动设定）：
- **绿地 ↔ 棕地**：老项目先 `/lode-recon` 出系统地图，spec 走 delta，plan 做影响分析/迁移/基线，verify 跑**全量回归**。
- **单人 ↔ 团队**：单人本地 `review-passed` 门禁；团队/长生命周期切 **PR/CI 门禁**，子代理审查降为 PR 前过滤（不替代人审）。
- **安全/合规**：再加强制安全审 + 需求-代码-测试可追溯。
- 愿景：**设一个目标 → agent 自主跑完 → 新老通吃**。自主 ≠ 无人——人只在「审 PR」「接熔断」两处出现。绿地仍轻，老项目/团队才上重护栏。

## 安装使用

> 前置：[Claude Code](https://claude.com/claude-code)。技能与子代理装在**用户级**（`~/.claude/`，全局可用）；门禁与 `CLAUDE.md` 按**项目**装。

**1. 装技能 + 子代理（一行）**
```bash
git clone https://github.com/Leejaywell/lode-skills.git
cd lode-skills && bash install.sh
```
把 `skills/lode-*` 拷进 `~/.claude/skills/`、`agents/lode-*` 拷进 `~/.claude/agents/`。装好后任意项目里输 `/lode-spec`、`/lode-plan`、`/lode-go`… 即可调用。
（只想装到当前项目：把 `skills/`、`agents/` 拷进项目的 `.claude/` 下即可。）

**2. 给项目装确定性门禁（可选，推荐）**——在你的项目根目录：
1. `cp -R <本仓库>/hooks ./hooks && chmod +x ./hooks/*.sh`（门禁脚本走 `$CLAUDE_PROJECT_DIR/hooks/`）。
2. `cp <本仓库>/CLAUDE.md ./CLAUDE.md`（或合并进你已有的）。
3. 把 `hooks/settings.json` 里的 `hooks` 块合并进项目 `.claude/settings.json`。
4. 开发开始时按 `docs/templates/verify.sh` 落一个 `.lode/<project>/verify.sh`（封装编译+测试）。

装好后：开发已开始的工作区收工前会自动跑 `verify.sh` + 校验审查标记，没过不许收工；纠正/不满会被采集成信号喂给自进化。

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
- 全链路：plan 前可插 `/lode-brief`(+可选 `/lode-design`)；收尾 `/lode-release`（团队走 PR/CI）。
- 执行单个 Face 的三种粒度：主 Agent 直接 `lode-build` 跑完计划 / 逐个 Face 写 Go（最常用）/ 一条 Go 跑全部（熟练后最高效）。

> **测试绑需求**：每个 Face 的「验收场景」在 plan 阶段**先于开发定**，测试照场景写、审查照场景验——堵住"测试绿但功能跑偏"。

### 门禁与钩子（确定性交给程序）

把 `hooks/`（`lode-gate.sh` + `lode-signal.sh` + `settings.json` 的 hooks 块）合并进项目 `.claude/settings.json`：

- **Stop 门禁 `lode-gate.sh`**：开发已开始的工作区收工前，① 实跑 `.lode/<project>/verify.sh`（编译+测试，退出码说话）② 校验非空且不旧于 CHANGELOG 的 `review-passed` 标记。**编译/测试由程序实跑，不只信模型写的 flag。**
- **UserPromptSubmit 钩子 `lode-signal.sh`**：命中纠正/不满关键词，自动把信号追加进 `signals.jsonl`，喂给自进化。
- 开发第一个 Face 前，按 `docs/templates/verify.sh` 落一个项目级 `verify.sh`（封装本项目的编译+测试命令）。

---

## 三条铁律

1. **少造工具，多给能力** —— 别把一项能力拆成一堆专用小工具，那样反而笨；给完整的通用能力，让模型自己组合。模型的聪明是**放出来的，不是设计出来的**。
2. **规则不要提前写，踩了坑再立** —— 一条规则必须对应一次真实失败；删了它问题会复现，才配留着。没踩过的坑不立规则，立了没用的主动删。
3. **把劲花在设计上，不在钉哨上** —— 别再琢磨提示词；真正值钱的是把流程和循环设计好（每环产出什么、什么标准算过、踩坑怎么办、怎么进化），剩下交给 AI 自己决定。
