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

echo "→ Installing source assets →  $DEST/lodestar/   (CLAUDE.md + templates, so spec/build can auto-provision per-project files)"
mkdir -p "$DEST/lodestar"
cp "$SRC/CLAUDE.md" "$DEST/lodestar/CLAUDE.md"
cp -R "$SRC/docs/templates" "$DEST/lodestar/templates"
cp "$SRC/uninstall.sh" "$DEST/lode-uninstall.sh" 2>/dev/null || true
chmod +x "$DEST/lode-uninstall.sh" 2>/dev/null || true

# Auto-wire the gate into user-level settings (~/.claude/settings.json) so it's active in EVERY
# project with no per-project step — just like the plugin. The gate exit-passes when there's no
# .lode/ workspace, so global activation has no side effect. Idempotent; backs up to settings.json.bak.
# Set LODE_NO_HOOKS=1 to skip.
GATE_WIRED=0
if [ "${LODE_NO_HOOKS:-0}" != "1" ] && command -v python3 >/dev/null 2>&1; then
  if python3 - "$DEST/settings.json" "$DEST" <<'PY'
import json, os, shutil, sys
path, dest = sys.argv[1], sys.argv[2]
cmds = {"Stop": 'bash "%s/lode-hooks/lode-gate.sh"' % dest,
        "UserPromptSubmit": 'bash "%s/lode-hooks/lode-signal.sh"' % dest}
try:
    with open(path) as f: s = json.load(f)
    if not isinstance(s, dict): raise ValueError
except FileNotFoundError:
    s = {}
except Exception:
    sys.exit(3)  # unparseable settings — don't clobber
hooks = s.setdefault("hooks", {})
changed = False
for event, cmd in cmds.items():
    arr = hooks.setdefault(event, [])
    if any(h.get("command") == cmd for g in arr for h in g.get("hooks", [])):
        continue  # already wired (idempotent)
    arr.append({"hooks": [{"type": "command", "command": cmd}]}); changed = True
if not changed:
    sys.exit(0)  # already wired — leave settings.json AND the pristine .bak untouched
if os.path.exists(path) and not os.path.exists(path + ".bak"):
    shutil.copy(path, path + ".bak")  # back up the pristine, pre-Lodestar settings once (never overwrite it)
with open(path, "w") as f:
    json.dump(s, f, indent=2, ensure_ascii=False); f.write("\n")
PY
  then GATE_WIRED=1; fi
fi

echo
echo "✅ Installed user-wide:"
echo "   skills:  lode-spec lode-brief lode-design lode-plan lode-build lode-release lode-drive lode-go lode-review lode-fix lode-skill lode-evolve lode-init"
echo "   agents:  lode-review  lode-evolve  lode-recon"
if [ "$GATE_WIRED" = "1" ]; then
  echo "   gate:    wired into $DEST/settings.json  (active in every project; backup: settings.json.bak)"
else
  echo "   gate:    NOT wired — set LODE_NO_HOOKS, or python3 missing, or settings.json unparseable."
  echo "            To wire by hand: merge the \"hooks\" block of $DEST/lode-hooks/settings.json into $DEST/settings.json."
fi
echo
echo "Done. In any project just run  /lode-spec  (or /lode-drive) — CLAUDE.md / verify.sh / the gate are provisioned automatically; you don't set anything up."
echo "(The plugin install gives the same thing with namespaced /lodestar:lode-spec commands — see README.)"
echo
echo "To remove Lodestar later (un-wires the gate too):  bash \"$DEST/lode-uninstall.sh\""
