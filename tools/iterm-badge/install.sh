#!/bin/bash
# Installs iTerm2 badge support for Claude Code.
# Fully automated — no manual steps required.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="$HOME/.claude/hooks"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
SETTINGS="$HOME/.claude/settings.json"
PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
BADGE_VAR='\\(user.claudeProject)'

# --- 1. Install the badge script ---

mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/set-badge.sh" "$HOOKS_DIR/set-badge.sh"
chmod +x "$HOOKS_DIR/set-badge.sh"
echo "Copied set-badge.sh → $HOOKS_DIR/"

# --- 2. Add CLAUDE.md instruction ---

read -r -d '' INSTRUCTION << 'BLOCK' || true
## iTerm2 Badge

After your first response in a new conversation, set the iTerm2 badge so the user can identify this session. Run: `~/.claude/hooks/set-badge.sh "max 3 words"` where the text is a short label for what you are working on (e.g. "event pipeline", "mobile auth", "badge setup"). Update it if the task changes significantly.
BLOCK

if [ ! -f "$CLAUDE_MD" ]; then
  echo "$INSTRUCTION" > "$CLAUDE_MD"
  echo "Created $CLAUDE_MD"
elif grep -q "set-badge.sh" "$CLAUDE_MD"; then
  echo "CLAUDE.md already configured"
else
  printf '%s\n\n' "$INSTRUCTION" | cat - "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  echo "Added badge instruction to CLAUDE.md"
fi

# --- 3. Add SessionEnd hook to clear badge on quit ---

if [ -f "$SETTINGS" ] && command -v jq &>/dev/null; then
  if jq -e '.hooks.SessionEnd' "$SETTINGS" &>/dev/null; then
    echo "SessionEnd hook already exists"
  else
    jq '.hooks.SessionEnd = [{"matcher":"","hooks":[{"type":"command","command":"~/.claude/hooks/set-badge.sh \"\"","timeout":3000,"async":true}]}]' \
      "$SETTINGS" > "$SETTINGS.tmp"
    mv "$SETTINGS.tmp" "$SETTINGS"
    echo "Added SessionEnd hook to clear badge on quit"
  fi
else
  echo "Add a SessionEnd hook manually to clear the badge when Claude quits."
fi

# --- 4. Configure iTerm2 profiles ---

if [ ! -f "$PLIST" ]; then
  echo ""
  echo "iTerm2 plist not found. Set the badge format manually:"
  echo "  Settings → Profiles → General → Badge → \\(user.claudeProject)"
  echo ""
  echo "Done."
  exit 0
fi

i=0
while /usr/libexec/PlistBuddy -c "Print ':New Bookmarks:$i:Name'" "$PLIST" &>/dev/null; do
  PROFILE=$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:$i:Name'" "$PLIST")
  CURRENT=$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:$i:Badge Text'" "$PLIST" 2>/dev/null || echo "")

  if [ "$CURRENT" = "$BADGE_VAR" ]; then
    echo "Profile \"$PROFILE\" — already set"
  elif [ -z "$CURRENT" ]; then
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:$i:Badge Text' string '$BADGE_VAR'" "$PLIST" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:$i:Badge Text' '$BADGE_VAR'" "$PLIST"
    echo "Profile \"$PROFILE\" — badge configured"
  else
    echo "Profile \"$PROFILE\" — has custom badge, skipped"
  fi
  i=$((i + 1))
done

echo ""
echo "Done. Restart iTerm2, then each new Claude Code session will badge itself."
