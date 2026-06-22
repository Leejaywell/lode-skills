---
name: lode-build
description: "Lodestar 主线⑤项目开发。按 dev-plan 逐个 Face 开发,每个 Face 走四步审计闭环直到通过。当开发计划已就绪、要写代码实现时使用。Trigger: /lode-build"
---

# Dev Builder（项目开发）

主线第 ⑤ 环。按 `dev-plan.md` **逐个 Face** 开发。重点在**闭环**：每个 Face 写完，必须派一个独立子 Agent 审查，审过才算完，审不过就改到审过为止。

## Usage（什么时候用）

- `dev-plan.md` 已确认，开始实现。
- 某个 Face 的代码要写/补/调到可验收。
- 通常配合一条 **Go**（见 `lode-go`）进入自驱循环。

## 开发开始自动落 `verify.sh`（确定性门禁的载体，用户零判断）

第一个 Face 动手前，**build 自动**在 `.lode/<project>/verify.sh` 写好**本项目真实的编译 + 测试命令**（全过 `exit 0`，任一失败非 0）——**不是留骨架让用户填**：

- 命令哪来：改现有代码看 `system-map.md` 的「怎么跑」一节（recon 已摸到真实命令）；从零新建用你定的技术栈（如 `npm run build && npm test`）。
- 这把"编译零报错 / 测试全过"这类**确定性判断**交给 Stop 门禁实跑，不靠模型口头自评。
- 门禁收工时实跑它兜底：没写、或写成空壳（占位未配置），收工直接被卡死。

## 四步审计（每个 Face 必走）

前两步是**确定性的**，交给 hook 实跑；后两步是**不确定的**，靠人/子 Agent 判断：

1. **编译验证（确定性·hook）** —— `verify.sh` 编译退出码为 0。
2. **测试完整性（确定性·hook）** —— 单元 + 端到端 + 界面点击测试齐全且 `verify.sh` 全绿；**测试必须覆盖该 Face 的「验收场景」**（plan 里先于开发定的那几条），不是你写完代码再凑的弱测试。先写覆盖验收场景的测试，再让它们绿。
3. **Code Review（判断·子 Agent）** —— 派一颗干净脑子的子 Agent 审（见 `lode-review`），覆盖代码质量、对齐 Spec、Web 项目的 a11y/响应式/关键页性能。
4. **功能测试（判断）** —— 按 Face 的**验收场景**逐条实际跑通（不是泛泛"能跑"）。

四步全过 → 本地 commit 作为回滚点（**不 push**）→ 把审查结论写进 `.lode/<project>/review-passed`（注明被审 Face/commit，并附一行 `tree: <当前代码指纹>`——用 `lode-gate.sh fingerprint` 取，或直接抄门禁阻止时打印的那行；门禁会校验它与当前代码一致，审完又改即失效）→ **更新 `.lode/<project>/system-map.md`**（把本 Face 的结构/约定/新接口同步进现状图，让它始终是最新的活地图——下个目标的 spec 直接拿它当现状，不必重新侦察自己刚写的代码）→ 写审计报告 → 这个 Face 才算 Done。

## Done（什么算合格）

对当前 Face：
- 满足它在计划里写明的完成标准。
- 通过四步审计，并把变更追加到 `.lode/<project>/changelog.md`（做了什么/为什么/影响面）。
- 每个 Face 审过后做一次**本地 commit**（不 push）作为回滚点——长自驱循环里崩了能退回上一个可跑通的 Face。
- 涉及设计或需求改动时，回写 `design-brief.md` / `product-spec.md` / `dev-plan.md`，保持文档同步。

## Guardrails（红线）

- **一次只推进一个 Face**，跑通再下一个；**一个 Session 只开发一个功能**，下个功能开新 Session，保持上下文小而干净。
- 直接**复用已有的设计/原型代码**，不要凭空重写——重写既费 token 又还原不了原设计。
- 自测失败自己定位修复，别把红测试留给审查或人。
- 遵守 `CLAUDE.md` 规则库每一条（都是真实踩坑换来的）。
- 只有互不依赖的 Face 才考虑并行拆子 Agent；给能力、不堆工具，不夹带计划外的"顺手优化"。

## → 下一步
本 Face Done → 还有 Face 就做下一个;全部完成 → `/lode-release`。
