#!/usr/bin/env bash
# Lodestar installer.
# Installs the skills + subagents at the user level (~/.claude), so /lode-* works in any project.
# The deterministic gate (hooks + CLAUDE.md) is per-project — steps printed at the end.
#
# Usage:
#   bash install.sh            # install into ~/.claude
#   CLAUDE_HOME=/path bash install.sh   # custom Claude home
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"

mkdir -p "$DEST/skills" "$DEST/agents"

echo "→ Installing skills  →  $DEST/skills/"
cp -R "$SRC/skills/." "$DEST/skills/"

echo "→ Installing agents  →  $DEST/agents/"
cp -R "$SRC/agents/." "$DEST/agents/"

echo
echo "✅ Installed user-wide:"
echo "   skills:  lode-spec lode-brief lode-design lode-plan lode-build lode-release lode-go lode-review lode-fix lode-skill lode-evolve"
echo "   agents:  lode-review  lode-evolve"
echo
echo "Try it in any project:  /lode-spec   then   /lode-plan   then   /lode-go"
echo
echo "── Optional: per-project deterministic gate ─────────────────────────────"
echo "Run these in a project where you want the 'no wrap-up until build/test + review pass' gate:"
echo "   cp -R \"$SRC/hooks\" ./hooks && chmod +x ./hooks/*.sh"
echo "   cp \"$SRC/CLAUDE.md\" ./CLAUDE.md        # or merge into your existing CLAUDE.md"
echo "   # then merge the \"hooks\" block from ./hooks/settings.json into .claude/settings.json"
echo "   # and create .lode/<project>/verify.sh from docs/templates/verify.sh"
echo "─────────────────────────────────────────────────────────────────────────"
