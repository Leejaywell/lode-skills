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
echo "   skills:  lode-recon lode-spec lode-brief lode-design lode-plan lode-build lode-release lode-drive lode-go lode-review lode-fix lode-skill lode-evolve lode-init"
echo "   agents:  lode-review  lode-evolve"
echo
echo "Try it: run  /lode-init  in a project, then  /lode-spec  →  /lode-plan  →  /lode-go"
echo
echo "── Optional: per-project deterministic gate ─────────────────────────────"
echo "In a project where you want the 'no wrap-up until build/test + review pass' gate:"
echo "   cp -R \"$SRC/hooks\" ./hooks && chmod +x ./hooks/*.sh"
echo "   # merge the \"hooks\" block from ./hooks/settings.json into .claude/settings.json"
echo "   # then run  /lode-init  to scaffold CLAUDE.md + .lode/<project>/verify.sh"
echo "─────────────────────────────────────────────────────────────────────────"
echo
echo "Prefer a one-step install where the gate auto-activates? Install as a plugin instead:"
echo "   /plugin marketplace add <this repo on GitHub  OR  ./local-clone>"
echo "   /plugin install lodestar@lodestar      # commands become /lodestar:lode-spec …"
echo "   (see README -> Plugin install.)"
