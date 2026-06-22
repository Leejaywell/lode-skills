#!/usr/bin/env bash
# Lodestar 卸载器(脚本装用)。移除用户级 Lodestar 文件 + 把门禁从 settings.json 摘掉。
# 默认**不动**你项目里的 .lode/、项目 CLAUDE.md、verify.sh(那是你的产物)。
# 加 --purge-project:额外删【当前目录】的 .lode/(交互运行会先确认;项目根 CLAUDE.md 仍不动)。
#
# 用法:
#   bash ~/.claude/lode-uninstall.sh                      # 只卸工具
#   bash ~/.claude/lode-uninstall.sh --purge-project      # 顺带清当前项目的 .lode/
#   curl -fsSL https://raw.githubusercontent.com/Leejaywell/lode-skills/main/uninstall.sh | bash -s -- --purge-project
#   CLAUDE_HOME=/path bash uninstall.sh                   # 自定义 Claude home
set -euo pipefail
DEST="${CLAUDE_HOME:-$HOME/.claude}"
PURGE=0; if [ "${1:-}" = "--purge-project" ]; then PURGE=1; fi

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
def ours(cmd): return "lode-hooks/lode-gate.sh" in cmd or "lode-hooks/lode-signal.sh" in cmd or "lode-hooks/lode-session.sh" in cmd
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

# 3) 可选:清【当前目录】的 .lode/(运行期文档)
if [ "$PURGE" = "1" ]; then
  if [ -d ".lode" ]; then
    ans=yes
    if [ -t 0 ]; then
      printf "再删【当前目录】的 ./.lode(本项目所有运行期文档,不可恢复)?[y/N] " >&2
      read -r reply; case "$reply" in y|Y|yes|YES) ans=yes;; *) ans=no;; esac
    fi
    if [ "$ans" = "yes" ]; then rm -rf ./.lode && echo "→ 已删 ./.lode"; else echo "→ 跳过 ./.lode"; fi
  else
    echo "→ 当前目录没有 ./.lode,无需清。"
  fi
  echo "   注:项目根 CLAUDE.md / verify.sh 仍未动(可能是你自己的规则)——要删请自己删。"
else
  echo "   你项目里的 .lode/、CLAUDE.md、verify.sh **没动**。想连产物一起清:在项目目录里 \`rm -rf .lode\`,或加 --purge-project 重跑。"
fi
echo "   (插件装的话改用:/plugin uninstall lodestar@lodestar 和 /plugin marketplace remove lodestar)"

# 4) 最后删掉卸载器自身(仅当 $0 确是本脚本的真实路径时,避免 curl|bash 下误删)
case "$0" in */lode-uninstall.sh) rm -f "$0" 2>/dev/null || true ;; esac
