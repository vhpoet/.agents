---
name: code-review
description: Entropy-reducing code review for any codebase — backend, frontend, and mobile (React, Next.js, React Native/Expo) via conditional layers. Parallel review agents report findings, then a single agent applies all fixes.
---

## How This Review Works

Three phases: **parallel review** (all agents simultaneously, report-only), **consolidation** (deduplicate and present findings), **fix** (one agent per finding applies changes).

Each layer is reviewed independently by **two models in parallel**: a Claude subagent (via the Agent tool) and a Codex instance (via `codex review` CLI). Both analyze changes through the same lens and report findings — neither edits code. After all complete, findings from both models across all layers are consolidated and fixer agents apply everything.

### Prompts

Static prompt files live in `prompts/` relative to this skill file:

- **`common.md`** — Shared review template: task steps, guiding principles, entropy signatures, output format (System Model + findings). Read first by every reviewer.
- **`L0-approach.md`** through **`L16-design-quality.md`** — Layer-specific review lens, one per layer. L13-L16 are platform layers (React, Next.js web, RN/Expo mobile, design quality) that triage selects only when the diff touches frontend code.

### Scripts

Helper scripts live in `scripts/` relative to this skill file. They handle mechanical work. You focus on judgment.

- **`layers.js --triage-help`** — Print layer names, prompt filenames, and skip guidelines for triage decisions.
- **`layers.js --list`** — Print the full layer table for reference.
- **`codex-review.js --layer <N> --intent "<summary>" [--scope "<file1> <file2> ..."]`** — Runs a single Codex review for one layer. Reads the same prompt files as Claude agents. Returns findings text to stdout. Optional `--scope` limits the review to specific files.

---

## Scope

The review can optionally be scoped to a subset of changed files — a feature, flow, or domain — instead of reviewing the entire diff.

**How scope is provided:** The skill args (everything after `/code-review`) specify the scope. Three forms are supported:

1. **Domain number** — `/code-review 2` — reads `/tmp/review-scopes.json` (written by the `/diff-map` skill) and uses domain 2's file list.
2. **File paths** — `/code-review backend/src/eventIngestion/enrichment/orchestrator.ts backend/src/event/types.ts` — explicit file list.
3. **No args** — `/code-review` — reviews all uncommitted changes (default behavior).

**How to resolve scope:**
- If args is a single integer and `/tmp/review-scopes.json` exists, read the JSON file and find the domain with that `id`. Use its `files` array and `name`/`description` for context.
- If args contains file paths (anything with `/` or `.`), use them directly.
- If no args, no scope — review everything.

**How scope affects the review:** When a scope is active, ALL `git diff` commands throughout the review become `git diff -- <file1> <file2> ...`. This applies to:
- Step 1 (understand intent)
- Step 2 (approach review)
- Step 4 (subagent prompts and codex calls)

The intent summary (step 1) should describe what THIS scoped subset of changes does, not the entire uncommitted diff.

When passing scope to subagents and codex, include the file list explicitly so they know to scope their `git diff` commands. The scope variable below is referred to as `SCOPE_FILES` — it's the resolved list of file paths, or empty if unscoped.

---

## Orchestration

0. **Resolve scope**: If args were provided, resolve them into a file list (`SCOPE_FILES`) using the rules above. If a domain was referenced, note its name and description — include these in the intent summary. If no args, `SCOPE_FILES` is empty (review everything).

1. **Understand intent**: `git diff [-- SCOPE_FILES]` + `git log` → 1-2 sentence summary of what changed and why. If scoped, describe what this specific domain/feature does. If a spec file exists for this work, read it.

2. **Approach review** (Layer 0): You (the orchestrator) do this step yourself — do not delegate it. Read `prompts/common.md` and `prompts/L0-approach.md`. Then run `git diff [-- SCOPE_FILES]`, read the changed files, and evaluate the implementation approach through that lens. Present findings to the user before proceeding. If the approach needs rethinking, the user should decide whether to continue or course-correct first.

3. **Triage**: Run `scripts/layers.js --triage-help` to get layer names, prompt filenames, and skip guidelines. Decide which layers to run based on the **scoped** diff. Present triage to the user (which layers run and why, which are skipped and why), then proceed without waiting.

   When in doubt, run the layer. The cost of a false positive is low. The cost of missing something is high.

4. **Parallel review**: Launch Codex first (background), then Claude agents (foreground).

   Use the **same intent summary from step 1** for every call. Do not compose unique per-layer intents — the layer-specific focus comes from the prompt file, not the intent.

   This is a **two-message sequence**:

   **Message 1 — Launch Codex instances in background**: Send one message with all Codex Bash calls (`run_in_background: true`, 10-minute timeout). Each script deletes its own stale result file on startup, writes findings to `/tmp/codex-review-L<N>.txt`, and prints "done" to stdout. If the `codex` CLI is not installed (`which codex` fails), skip the Codex half entirely and run the review with Claude agents only — note this to the user.

   **CRITICAL — always pass `--repo <repo-root>`** (the absolute path of the repository under review, i.e. the cwd where `/code-review` was invoked) and invoke the script by its **absolute path**. `codex review` diffs its own working directory: if you `cd` into the skill dir and omit `--repo`, Codex silently reviews the *skill's* repo instead of the target repo, and the whole Codex half of the review is wasted.
   ```bash
   node <skill-dir>/scripts/codex-review.js --repo "<repo-root>" --layer <N> --intent "<intent summary from step 1>" --scope "<SCOPE_FILES joined by spaces>"
   ```
   Omit `--scope` if `SCOPE_FILES` is empty.

   **Message 2 — Launch Claude subagents in foreground**: Send a second message with all Claude Agent calls (`subagent_type: "general-purpose"`; if the feature-dev plugin is enabled and provides `feature-dev:code-reviewer`, that may be used instead). No `run_in_background` — these run as foreground parallel calls:
   ```
   Read these two files in order, then execute the review they describe:
   1. prompts/common.md (shared review template)
   2. prompts/<PROMPT_FILE> (your specific review lens)

   Context: <intent summary from step 1>

   SCOPE: Only review changes in these files (use `git diff -- <file1> <file2> ...`):
   <SCOPE_FILES, one per line>

   You MUST use tools — run git diff, read the changed files, grep for patterns. Do not generate a review without reading code first.
   ```
   If unscoped, omit the SCOPE section entirely — agents will run bare `git diff`.

   By launching Codex first, they run in the background while Claude agents work.

   **CRITICAL — DO NOT CUT CORNERS**: Every selected layer gets exactly 1 Claude subagent AND 1 Codex Bash call. If you selected 7 layers, you send 7 Bash calls in message 1, then 7 Agent calls in message 2 = 14 total. Do not skip layers. Do not combine layers.

5. **Consolidate**: Collect Claude agent results (returned directly from the foreground calls). Then read Codex results from `/tmp/codex-review-L<N>.txt` files using the Read tool. If a file doesn't exist yet, the Codex task may still be running — background tasks announce completion via notification, so wait for that rather than polling.

   - Collect findings from each Claude agent (returned in the agent's result) and each Codex review (read from `/tmp/codex-review-L<N>.txt`)
   - Check each reviewer's **System Model** section against your own understanding from steps 1-2. If a reviewer misunderstood what the change does or what the subsystem is for, discount its findings accordingly — findings built on a wrong model are noise. Note the discount when presenting.
   - Merge all findings (Claude + Codex) across all layers, grouping by file and location
   - Deduplicate when both models flag the same issue in the same layer — merge into one finding, noting both caught it
   - If findings conflict between layers, favor the higher-impact layer. If Claude and Codex conflict on the same code within the same layer, present both perspectives and flag the disagreement for the user.
   - Tag each finding with its source: `[Claude: Layer Name]` or `[Codex: Layer Name]`
   - Collect any **Skill feedback** notes from reviewer reports (cases where a reviewer overrode skill guidance with reasoning). Evaluate them with your own judgment — agree or push back — and present the ones with merit to the user in a separate "Skill feedback" section, with the concrete edit to the skill they imply. This is how the skill stays current as models and practices improve.
   - Present the unified findings list to the user
   - If no findings survive filtering: report "No issues found" and stop

6. **Fix**: Apply fixes yourself, one finding at a time. For each finding: read the code around it, understand the full context, and **decide whether you agree**. Reviewers can be wrong — they see limited context and may misunderstand intent. Only fix findings that genuinely improve the code. Skip findings you disagree with and explain why. When a finding names a root cause, fix the cause — a structural fix that touches more files beats a patch at the symptom site. Prefer deletion and simplification over additive fixes. When unsure about correct API usage or library behavior, look up the documentation first (use context7 MCP tools). Do not guess.

7. **Report**: Summarize what was fixed. Update spec review checkboxes if applicable. Then check whether the reviewed changes (plus your fixes) invalidate any agent-facing context — the project's CLAUDE.md / AGENTS.md and docs they reference (architecture notes, schema docs, conventions). Stale agent context is worse than none: it steers every future agent wrong. Update what's stale or flag it to the user.
