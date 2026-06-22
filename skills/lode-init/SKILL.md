---
name: lode-init
description: "Lodestar 扩展技能·项目初始化（可选手动逃生口）。一次性把按项目文件铺好:顶层规则 CLAUDE.md + .lode/<project>/verify.sh + .lode 目录。注意:正常流程下这些是自动铺的——CLAUDE.md 由 lode-spec 开局落、verify.sh 由 lode-build 开发开始时写,用户无需调本技能。仅当你想手动一次性预铺、或自动铺没生效需补救时用。Trigger: /lode-init"
---

# Init（项目初始化 · 可选手动逃生口）

扩展技能。把 Lodestar 的按项目文件一次性铺好。

> **正常不用敲它**：这些文件由流程自动铺——`CLAUDE.md` 由 `lode-spec` 一进项目就落、`verify.sh` 由 `lode-build` 开发开始时用真实命令写。本技能只是**手动逃生口**：想提前一次性预铺、或自动没生效要补救时才用。

## Usage（什么时候用）

- 想在开跑前**手动一次性**把按项目文件预铺好。
- 自动铺设没生效（如 spec/build 没找到规则源），需要手动补。

## 干什么（铺三样，缺啥补啥）

`<project>` = 当前项目目录名。

1. **顶层规则 `CLAUDE.md` → 项目根**:Lodestar 的运行约定。
   - 源文件位置:插件装 `${CLAUDE_PLUGIN_ROOT}/CLAUDE.md`、脚本装 `~/.claude/lodestar/CLAUDE.md`。先 `echo "$CLAUDE_PLUGIN_ROOT"` 探一下,空就去 `~/.claude/lodestar/` 找;**都找不到就停下问用户 Lodestar 装在哪**,别凭记忆生成一份(会过时)。
2. **`.lode/<project>/verify.sh` 骨架**:从 `~/.claude/lodestar/templates/verify.sh`(插件装则 `${CLAUDE_PLUGIN_ROOT}/docs/templates/verify.sh`)拷一份,`chmod +x`。**先放骨架,真实命令正常由首个 `lode-build` 写**。
3. **`.lode/<project>/` 目录**:建好,后续所有产物(spec/plan/changelog…)都落这。

> 脚本安装(非插件)还需把 `hooks/settings.json` 的 hooks 块合并进 `.claude/settings.json`——那不是 lode-init 的活,见 README。插件装则门禁已自动生效。

## Done（什么算合格）

- 项目根有 `CLAUDE.md`(本次新建,或确认已存在并提示了合并)。
- `.lode/<project>/verify.sh` 存在且可执行。
- 收尾给用户一句话指路:从零新建 → 下一步 `lode-spec`；改现有代码 → 下一步还是 `lode-spec`（它开局自动把 system-map 备好）。

## Guardrails（红线）

- **绝不覆盖已有 `CLAUDE.md` / `verify.sh`**:项目已有 `CLAUDE.md` 就别动它(那多半是用户自己项目的规则),经用户同意再以 `<!-- LODESTAR:BEGIN/END -->` 包块追加;`verify.sh` 存在就保留。绝不静默盖掉用户的东西。
- **只铺骨架**:不替项目猜编译/测试命令——那是 `lode-spec` 开局 / `lode-build` 的活。
- 找不到源文件就停下问,别瞎生成一份过时的 `CLAUDE.md`。
