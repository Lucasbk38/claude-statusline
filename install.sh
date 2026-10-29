#!/bin/sh
# Installs the status line and the subagent panel into ~/.claude and points settings.json at them.
# Works from a checkout (sh install.sh) or piped from curl.
set -e
BASE=${CLAUDE_STATUSLINE_BASE:-https://raw.githubusercontent.com/Lucasbk38/claude-statusline/main}
DIR="$HOME/.claude/statusline"
SETTINGS="$HOME/.claude/settings.json"

command -v jq >/dev/null 2>&1 || { echo "jq is required (macOS: brew install jq, Debian/Ubuntu: apt install jq)"; exit 1; }

mkdir -p "$DIR"
for f in statusline.sh subagent.sh theme.json; do
  if [ -f "./$f" ]; then cp "./$f" "$DIR/$f"; else curl -fsSL "$BASE/$f" -o "$DIR/$f"; fi
done
[ -f "$DIR/agent-parents.json" ] || echo '{}' > "$DIR/agent-parents.json"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak"
jq '.statusLine = {type: "command", command: "sh ~/.claude/statusline/statusline.sh"}
  | .subagentStatusLine = {type: "command", command: "sh ~/.claude/statusline/subagent.sh"}' "$SETTINGS.bak" > "$SETTINGS"

echo "Installed in $DIR (previous settings saved as settings.json.bak). Restart Claude Code."
