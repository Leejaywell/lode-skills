---
name: lode-init
description: "Lodestar 扩展技能·项目初始化。在当前项目一键铺好 Lodestar 跑起来需要、但插件装不会自动落地的按项目文件:顶层规则 CLAUDE.md + .lode/<project>/verify.sh 骨架 + .lode 目录。当用户刚装好 Lodestar(尤其插件装)、要在一个项目里第一次开跑、项目里还没有 CLAUDE.md/verify.sh 时使用。Trigger: /lode-init"
---

# Init（项目初始化）

扩展技能。把 Lodestar 跑起来必需、但**按项目**生效、插件装不会自动落地的文件一次铺好。装好技能/子代理/门禁(插件或脚本)后,在**目标项目根目录**跑一次即可开跑。

> 为什么需要它:插件能带 skills/agents/hooks,但顶层运行约定 `CLAUDE.md` 是按项目的,插件不会写进你的项目。lode-init 就是收掉这个「最后的手动残留」。

## Usage（什么时候用）

- 刚装好 Lodestar,要在某个项目**第一次**开跑。
- 项目里还没有顶层 `CLAUDE.md`(运行约定)或 `.lode/<project>/verify.sh`。

## 干什么（铺三样，缺啥补啥）

`<project>` = 当前项目目录名。

1. **顶层规则 `CLAUDE.md` → 项目根**:Lodestar 的运行约定。
   - 源文件位置:插件装在 `${CLAUDE_PLUGIN_ROOT}/CLAUDE.md`;脚本装在你克隆的仓库根。先 `echo "$CLAUDE_PLUGIN_ROOT"` 探一下,空就去 `~/.claude` 或克隆目录找;**都找不到就停下问用户 Lodestar 装在哪**,别凭记忆生成一份(会过时)。
2. **`.lode/<project>/verify.sh` 骨架**:从 `docs/templates/verify.sh` 拷一份,`chmod +x`。这是收工门禁实跑的编译+测试脚本——**先放骨架,真实命令留给 `lode-recon`/首个 `lode-build` 填**。
3. **`.lode/<project>/` 目录**:建好,后续所有产物(spec/plan/changelog…)都落这。

> 脚本安装(非插件)还需把 `hooks/settings.json` 的 hooks 块合并进 `.claude/settings.json`——那不是 lode-init 的活,见 README。插件装则门禁已自动生效。

## Done（什么算合格）

- 项目根有 `CLAUDE.md`(本次新建,或确认已存在并提示了合并)。
- `.lode/<project>/verify.sh` 存在且可执行。
- 收尾给用户一句话指路:绿地下一步 `lode-spec`,棕地下一步 `lode-recon`。

## Guardrails（红线）

- **绝不覆盖已有 `CLAUDE.md` / `verify.sh`**:存在就提示用户怎么合并,不静默盖掉用户的东西。
- **只铺骨架**:不替项目猜编译/测试命令——那是 `lode-recon` 的活。
- 找不到源文件就停下问,别瞎生成一份过时的 `CLAUDE.md`。
