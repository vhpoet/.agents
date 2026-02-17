# iTerm2 Badge for Claude Code

Each Claude Code session labels itself with a short badge so you can tell your panes apart at a glance.

## How it works

A small script sets an iTerm2 user variable via AppleScript. A `CLAUDE.md` instruction tells Claude to call it once it understands your task. iTerm2 renders the variable as a background badge.

## Install

```bash
bash ~/.agents/tools/iterm-badge/install.sh
```

This copies the script, updates `CLAUDE.md`, and configures the badge format on all iTerm2 profiles. Restart iTerm2 afterward.

## What you get

A 1–3 word label in each terminal pane:

- `event pipeline`
- `mobile auth`
- `fix search bug`

The badge updates if the task changes.

## Requirements

- macOS, iTerm2, Claude Code
