#!/usr/bin/env bash
# Lodestar 卸载器(脚本装用)。只移除用户级的 Lodestar 文件 + 把门禁从 settings.json 摘掉。
# 你项目里的 .lode/、项目 CLAUDE.md、verify.sh 是你的产物,绝不动——要删自己删。
#
# 用法:
#   bash ~/.claude/lode-uninstall.sh                 # 安装后留在这,离线可用
#   curl -fsSL https://raw.githubusercontent.com/Leejaywell/lode-skills/main/uninstall.sh | bash
#   CLAUDE_HOME=/path bash uninstall.sh              # 自定义 Claude home
set -euo pipefail
DEST="${CLAUDE_HOME:-$HOME/.claude}"

# 1) 从 settings.json 摘掉 Lodestar 门禁(只删我们这两条,其它 hooks 原样保留;空数组顺手清掉)
if [ -f "$DEST/settings.json" ] && command -v python3 >/dev/null 2>&1; then
  python3 - "$DEST/settings.json" <<'PY'
import json, shutil, sys
path = sys.argv[1]
try:
    with open(path) as f: s = json.load(f)
    if not isinstance(s, dict): raise ValueError
except Exception:
    sys.exit(0)  # 解析不了就不动
def ours(cmd): return "lode-hooks/lode-gate.sh" in cmd or "lode-hooks/lode-signal.sh" in cmd
hooks = s.get("hooks", {}); changed = False
for event in list(hooks.keys()):
    groups = []
    for g in hooks.get(event, []):
        kept = [h for h in g.get("hooks", []) if not ours(h.get("command", ""))]
        if len(kept) != len(g.get("hooks", [])): changed = True
        if kept: g["hooks"] = kept; groups.append(g)
    if groups: hooks[event] = groups
    else: hooks.pop(event, None)
if not hooks: s.pop("hooks", None)
if changed:
    shutil.copy(path, path + ".bak")
    with open(path, "w") as f: json.dump(s, f, indent=2, ensure_ascii=False); f.write("\n")
    print("→ 已从 settings.json 摘掉门禁(原文件备份 settings.json.bak)")
PY
fi

# 2) 删 Lodestar 自己的文件(不碰你别的 skill/agent)
rm -rf "$DEST/lode-hooks" "$DEST/lodestar"
rm -rf "$DEST"/skills/lode-* 2>/dev/null || true
rm -f "$DEST"/agents/lode-review.md "$DEST"/agents/lode-recon.md "$DEST"/agents/lode-evolve.md 2>/dev/null || true

echo "✅ 已从 $DEST 移除 Lodestar(技能/子代理/门禁脚本/源资产)。"
echo "   你项目里的 .lode/、项目 CLAUDE.md、verify.sh **没动**——想清就在该项目里自己删:"
echo "      rm -rf .lode   # 运行期产物;CLAUDE.md/verify.sh 视情况手动删"
echo "   (插件装的话改用:/plugin uninstall lodestar@lodestar 和 /plugin marketplace remove lodestar)"

# 3) 最后删掉卸载器自身(放在 $DEST 根,不在被删目录里)
rm -f "$0" 2>/dev/null || true
