#!/bin/bash
# Usage: set-badge.sh "short label"
# Sets an iTerm2 user variable that displays as a badge.
osascript <<EOF 2>/dev/null
tell application "iTerm2"
  tell current session of current tab of current window
    set variable named "user.claudeProject" to "$1"
  end tell
end tell
EOF
