---
name: lode-review
description: "Lodestar 扩展技能·代码审查。派一颗干净脑子的独立子 Agent 审查刚完成的 Face/变更,作为收工门禁。当一个 Face 自测通过准备收工、或发布前需要质量关时使用。Trigger: /lode-review"
---

# Code Reviewer（代码审查）

扩展技能 · 收工门禁。这是范式里**默认拆子 Agent 的典型场景**——审查员是新派的、没参与开发，没有"这代码是我写的"那种偏心，所以才审得准。

## Usage（什么时候用）

- 一个 Face 在 `lode-build` 里自测通过，准备收工。
- 发布前（`lode-release`）的质量关。
- 任何标记"完成"之前的强制一道关。

## 怎么跑（编排）

主 Agent **拆一个干净脑子的子 Agent**：用 `Agent` 工具调用 `lode-review` 子代理（见 `agents/lode-review.md`），把**整份相关上下文带走**（变更 diff、该 Face 的 Go、Product-Spec/DEV-PLAN 片段）。子 Agent 只返回结论，**主 Agent 合并拍板**。

## Done（什么算合格）

返回结构化审查报告，覆盖**四步审计**：编译验证、测试完整性（单元+端到端+界面点击；Web 项目含 a11y/响应式/关键页性能）、Code Review、功能测试。
- 前两步是确定性的，由 Stop 门禁的 `verify.sh` 实跑兜底，子 Agent 复核退出码即可；重点扛后两步靠判断的审查。
- **测试完整性核的是 spec-bound**：该 Face 的每条「验收场景」都有对应测试，且测试测的是需求而非实现；功能测试**逐条跑验收场景**——不是"测试存在且绿"就算过。
- 逐条问题按严重度分级：CRITICAL / HIGH / MEDIUM / LOW。
- 明确结论：**通过 / 不通过**（有 CRITICAL 即不通过）。
- 通过后由**主 Agent**把结论写进 `.lode/<project>/REVIEW_PASSED`（注明被审 Face/commit），门禁据此放行。
- 不通过时，每个阻塞项写清"为什么 + 怎么改"，由主 Agent 改完再走一轮，直到 Pass。

**棕地 / 团队 / 安全攸关额外审：**
- **回归**：全量既有测试无新红；对比改动前基线，区分「弄坏的」vs「本来就坏的」；spec 里"绝不能破坏"清单逐条确认没被破坏。
- **安全/合规**：触碰认证、用户输入、查询、文件、外部调用、加密、支付时，强制安全审（参照 OWASP）；无硬编码密钥。
- **可追溯**：需求 → 代码 → 测试 三者对得上——每条验收标准有对应测试，每处改动追得回某条需求（受监管系统必需）。
- **团队模式**：本审查是 **PR 前过滤器**，不替代人审；完成 = PR 过 CI + 必需 approval 合并，REVIEW_PASSED 只用于本地/单人模式。

## Guardrails（红线）

- 审查子 Agent **只审查、不改代码**；修复回到 `lode-build` / `lode-fix`。
- 没过审查 → 不允许收工（由 Stop hook 门禁强制，不靠自觉）。
- 审查范围对齐 Go 与 Product-Spec，不借机扩需求。
- 决策权在主 Agent / 人，子 Agent 不替你拍板发布。
