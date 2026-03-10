#!/bin/bash
# Usage: set-badge.sh "short label"
# Sets an iTerm2 badge on the session where this process is running.
# Uses ITERM_SESSION_ID to target the correct pane.

BADGE="$1"
SESSION_UUID="${ITERM_SESSION_ID##*:}"

if [ -z "$SESSION_UUID" ]; then
  exit 0
fi

osascript <<EOF 2>/dev/null
tell application "iTerm2"
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        if unique ID of s is "$SESSION_UUID" then
          tell s to set variable named "user.claudeProject" to "$BADGE"
          return
        end if
      end repeat
    end repeat
  end repeat
end tell
EOF
