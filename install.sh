#!/usr/bin/env bash
# Lodestar script installer (fallback for environments without the plugin system).
# Installs skills + subagents + gate scripts under ~/.claude so /lode-* works in any project.
#
# No clone needed — pipe it:
#   curl -fsSL https://raw.githubusercontent.com/Leejaywell/lode-skills/main/install.sh | bash
# Or run from a checkout:
#   bash install.sh
#   CLAUDE_HOME=/path  overrides the target Claude home.
set -euo pipefail

REPO="Leejaywell/lode-skills"
BRANCH="main"
DEST="${CLAUDE_HOME:-$HOME/.claude}"

# Sources: use a checkout if skills/ sits next to this script; otherwise fetch a tarball
# (so `curl | bash` works with no git and no leftover repo).
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -z "$SRC" ] || [ ! -d "$SRC/skills" ]; then
  command -v curl >/dev/null || { echo "需要 curl(或 git clone 本仓库后 bash install.sh)"; exit 1; }
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  echo "→ Fetching $REPO@$BRANCH …"
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" | tar -xz -C "$TMP"
  SRC="$TMP/$(basename "$REPO")-$BRANCH"
fi

mkdir -p "$DEST/skills" "$DEST/agents" "$DEST/lode-hooks"

echo "→ Installing skills       →  $DEST/skills/"
cp -R "$SRC/skills/." "$DEST/skills/"

echo "→ Installing agents       →  $DEST/agents/"
cp -R "$SRC/agents/." "$DEST/agents/"

echo "→ Installing gate scripts →  $DEST/lode-hooks/"
cp -R "$SRC/hooks/." "$DEST/lode-hooks/"
chmod +x "$DEST/lode-hooks/"*.sh 2>/dev/null || true

echo
echo "✅ Installed user-wide:"
echo "   skills:  lode-spec lode-brief lode-design lode-plan lode-build lode-release lode-drive lode-go lode-review lode-fix lode-skill lode-evolve lode-init"
echo "   agents:  lode-review  lode-evolve  lode-recon"
echo
echo "Try it: run  /lode-init  in a project, then  /lode-spec  →  /lode-plan  →  /lode-go"
echo
echo "── Optional: per-project deterministic gate ─────────────────────────────"
echo "In a project where you want the 'no wrap-up until build/test + review pass' gate:"
echo "   cp -R \"$DEST/lode-hooks/.\" ./hooks && chmod +x ./hooks/*.sh"
echo "   # merge the \"hooks\" block from ./hooks/settings.json into .claude/settings.json"
echo "   # then run  /lode-init  to scaffold CLAUDE.md + .lode/<project>/verify.sh"
echo "─────────────────────────────────────────────────────────────────────────"
echo
echo "Prefer a one-step install where the gate auto-activates? Install as a plugin instead:"
echo "   /plugin marketplace add $REPO     #  then:  /plugin install lodestar@lodestar"
echo "   (commands become /lodestar:lode-spec …; see README.)"
