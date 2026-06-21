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
- 逐条问题按严重度分级：CRITICAL / HIGH / MEDIUM / LOW。
- 明确结论：**通过 / 不通过**（有 CRITICAL 即不通过）。
- 通过后由**主 Agent**把结论写进 `.lode/<project>/REVIEW_PASSED`（注明被审 Face/commit），门禁据此放行。
- 不通过时，每个阻塞项写清"为什么 + 怎么改"，由主 Agent 改完再走一轮，直到 Pass。

## Guardrails（红线）

- 审查子 Agent **只审查、不改代码**；修复回到 `lode-build` / `lode-fix`。
- 没过审查 → 不允许收工（由 Stop hook 门禁强制，不靠自觉）。
- 审查范围对齐 Go 与 Product-Spec，不借机扩需求。
- 决策权在主 Agent / 人，子 Agent 不替你拍板发布。
