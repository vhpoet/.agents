---
name: codex-review
description: Run an independent code review using the Codex CLI. Use for "codex review", "second opinion", or when an external LLM should review uncommitted or branch changes.
---

# Codex Review

Run `codex review` CLI to get an independent code review from a separate LLM (OpenAI Codex). Useful as a second opinion on uncommitted changes or branch diffs.

## Usage

### Review uncommitted changes (default)

```bash
codex review --uncommitted
```

### Review changes against a base branch

```bash
codex review --base main
```

### Review a specific commit

```bash
codex review --commit <sha>
```

### Review with custom instructions (or a spec / untracked file)

`--uncommitted` cannot be combined with a custom prompt — `codex review --uncommitted "<prompt>"` errors out. To review with instructions, use `codex exec` in a read-only sandbox and pipe the prompt via stdin:

```bash
codex exec -s read-only - <<'EOF' > review-output.txt 2>&1
Review docs/spec/foo.md against the code in src/. Findings by severity, terse.
EOF
```

## Workflow

1. Run the appropriate `codex review` command based on what the user wants reviewed
   - Codex runs for minutes. Run it as ONE background Bash task (`run_in_background`) and wait for that task's own completion notification. Never poll with `sleep` loops or `pgrep -f "codex exec"`: other sessions run Codex too, so a machine-wide check never ends and leaks shells.
2. Output may be large — if truncated, read the full output from the persisted file
3. Present the findings to the user as-is without editorializing or injecting your own opinion
