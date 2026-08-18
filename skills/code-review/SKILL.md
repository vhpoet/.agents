---
name: code-review
description: Entropy-reducing code review for any codebase — backend, frontend, and mobile (React, Next.js, React Native/Expo) via conditional layers. Parallel review agents report findings; the orchestrator judges and plans fixes, then delegates them to fixer subagents.
---

## How This Review Works

Three phases: **parallel review** (all agents simultaneously, report-only), **consolidation** (deduplicate, judge, and present findings), **fix** (the orchestrator plans fixes globally, then delegates batches to fixer subagents).

Every selected layer is reviewed by a Claude subagent (via the Agent tool). The **critical layers additionally get a Codex twin** (via `codex review` CLI) — an independent second model on the lenses where a missed defect costs the most: L4 Security, L5 Correctness, L6 Data Safety by default, plus any other selected layer the orchestrator judges critical for this diff (money-path UI, auth flows, migrations). Reviewers report findings — none edits code. After all complete, findings from both models across all layers are consolidated; the orchestrator decides which findings stand and fixer subagents apply the approved fixes.

### Prompts

Static prompt files live in `prompts/` relative to this skill file:

- **`common.md`** — Shared review template: task steps, guiding principles, entropy signatures, output format (System Model + findings). Read first by every reviewer.
- **`L0-approach.md`** through **`L16-design-quality.md`** — Layer-specific review lenses. L11 covers both hygiene and readability (one agent, two methods). `L13-react-patterns.md` is a **companion lens with no agent of its own** — the L14 (web) and L15 (mobile) platform agents each read it alongside their own prompt. L14-L16 are platform layers that triage selects only when the diff touches frontend code. (There is no L12 — it was merged into L11.)

### Scripts

Helper scripts live in `scripts/` relative to this skill file:

- **`layers.js --triage-help`** — Print layer names, prompt filenames, and skip guidelines for triage decisions.
- **`layers.js --list`** — Print the full layer table for reference.
- **`codex-review.js --layer <N> --intent "<summary>" [--scope "<file1> <file2> ..."]`** — Runs a single Codex review for one layer. Reads the same prompt files as Claude agents. Returns findings text to stdout. Optional `--scope` limits the review to specific files.

---

## Scope

The review can optionally be scoped to a subset of changed files — a feature, flow, or domain. The skill args (everything after `/code-review`) supply it, in three forms:

1. **Domain number** — `/code-review 2` — look up the domain with that `id` in `/tmp/review-scopes.json` (written by the `/diff-map` skill); use its `files` list and carry its `name`/`description` into the intent summary.
2. **File paths** — an explicit file list (anything with `/` or `.`).
3. **No args** — no scope; review all uncommitted changes.

When a scope is active, EVERY `git diff` in the review (intent, approach review, reviewer prompts, Codex calls) becomes `git diff -- <file1> <file2> ...`, and the intent summary describes what the scoped subset does, not the whole diff. `SCOPE_FILES` below is this resolved list — empty if unscoped.

---

## Orchestration

0. **Resolve scope** per the Scope section above.

1. **Understand intent + build the context pack**: `git diff [-- SCOPE_FILES]` + `git log` → 1-2 sentence summary of what changed and why. If scoped, describe what this specific domain/feature does. If a spec file exists for this work, read it.

   Then build a **context pack** every reviewer will receive — this is what stops N agents from each re-deriving the same picture:
   - **Effort map**: if the diff holds more than one effort, name each and its file areas. (If the efforts are genuinely unrelated, consider recommending a `/diff-map` split into separate scoped reviews instead of one giant run.)
   - **File inventory**: changed files grouped by area, with the key new files called out. **Untracked new files are invisible to bare `git diff`** — list them explicitly (`git status --porcelain | grep '^??'`) so reviewers read them directly.
   - **Check results, run ONCE by you**: run the project's typechecks and unit test suite(s) now, and record pass/fail with any failure output in the pack. Reviewers must NOT re-run whole suites (a single reviewer doing so cost 27 minutes in one run) — they may run individual test files relevant to a finding. A red suite at review start is itself a finding; hand it to the reviewers as fact.

   The context pack rides in every reviewer prompt (and later in fixer prompts) alongside the intent summary.

2. **Approach review** (Layer 0): You (the orchestrator) do this step yourself — do not delegate it. Read `prompts/common.md` and `prompts/L0-approach.md`. Then run `git diff [-- SCOPE_FILES]`, read the changed files, and evaluate the implementation approach through that lens. Present findings to the user before proceeding. If the approach needs rethinking, the user should decide whether to continue or course-correct first.

3. **Triage**: Run `scripts/layers.js --triage-help` to get layer names, prompt filenames, and skip guidelines. Decide which layers to run based on the **scoped** diff. Present triage to the user (which layers run and why, which are skipped and why), then proceed without waiting.

   When in doubt, run the layer. The cost of a false positive is low. The cost of missing something is high.

   **Assign each selected layer its scope.** When the diff spans distinct surfaces (backend + web + mobile, or several efforts), give each layer the file subset its lens actually applies to — platform layers get their platform's files, L6/L7 get the DB-touching files, and so on — rather than every agent reviewing everything. Whole-diff layers (L1 architecture, L5 correctness) may deliberately keep the full scope, and files central to several lenses may appear in several scopes: overlap by design is confirmation signal, overlap by default is duplicate findings. Record the per-layer scope; it goes into that layer's SCOPE section and Codex `--scope` in step 4.

   **Also mark which selected layers are critical** — these get the Codex twin in step 4. Default critical set: L4 Security, L5 Correctness, L6 Data Safety (when selected). Add another layer only when this diff makes it critical (money-path UI, auth flows, migrations, data-destructive operations).

4. **Parallel review**: Launch everything in **one message**: one Claude Agent call per selected layer, plus one Codex Bash call per **critical** layer (marked in step 3). Both run in the background — Bash calls via `run_in_background: true` (10-minute timeout), Agent calls by default. Each announces completion via notification.

   Use the **same intent summary and context pack from step 1** for every call. Do not compose unique per-layer intents — the layer-specific focus comes from the prompt file and the per-layer scope, not the intent.

   **Codex calls** (critical layers only): Each script run deletes its own stale result file on startup, writes findings to `/tmp/codex-review-L<N>.txt`, and prints "done" to stdout. If the `codex` CLI is not installed (`which codex` fails), skip the Codex half entirely and note it — the Claude agents carry the review. A Codex run can also complete successfully with an **empty result file** — treat that as "no findings from Codex for this layer", not as a failure to investigate or retry.

   **Codex can only review UNCOMMITTED changes.** When the review targets already-committed work (a commit range, a deployed feature), skip the Codex half and note it. Do not pass a SHA or branch to `codex review --base`: with a custom prompt (or any piped stdin) the flag is rejected, and in some invocations Codex silently reviews the wrong diff (it has reviewed the base commit's own changes). A wrong-diff Codex report looks plausible — check its System Model against the intent before trusting any of its findings.

   **CRITICAL — always pass `--repo <repo-root>`** (the absolute path of the repository under review, i.e. the cwd where `/code-review` was invoked) and invoke the script by its **absolute path**. `codex review` diffs its own working directory: if you `cd` into the skill dir and omit `--repo`, Codex silently reviews the *skill's* repo instead of the target repo, and the whole Codex half of the review is wasted.
   ```bash
   node <skill-dir>/scripts/codex-review.js --repo "<repo-root>" --layer <N> --intent "<intent summary from step 1>" --scope "<this layer's scope from step 3, space-joined>"
   ```
   Omit `--scope` if the layer has no assigned scope.

   **Claude agent calls** (`subagent_type: "general-purpose"`): Pass `model: "opus"` for every layer **except L1 (Architecture & Boundaries)** — L1 is the judgment-heaviest layer, so omit `model` there and let it inherit the orchestrator's model. Use **absolute paths** in the prompt — subagents start in the repo cwd, so relative `prompts/...` paths will not resolve:
   ```
   Read these files in order, then execute the review they describe:
   1. <skill-dir>/prompts/common.md (shared review template)
   2. <skill-dir>/prompts/<PROMPT_FILE> (your specific review lens)
   [3. <skill-dir>/prompts/<EXTRA_PROMPT_FILE> — when the layer lists extra prompt files (L14/L15 carry L13)]

   Context: <intent summary from step 1>

   <context pack from step 1: effort map, file inventory incl. untracked, check results>

   SCOPE: Only review changes in these files (use `git diff -- <file1> <file2> ...`):
   <this layer's scope from step 3, one file per line>

   You MUST use tools — run git diff, read the changed files, grep for patterns. Do not generate a review without reading code first. Do not re-run whole test suites — the context pack carries their results; run individual test files only where a finding needs it.
   ```
   If the layer has no assigned scope, omit the SCOPE section — the agent reviews the whole diff.

   **DO NOT CUT CORNERS**: Every selected layer gets its own Claude subagent, and every critical layer additionally gets its Codex call. Do not skip selected layers, and do not fold two layers into one agent beyond the pairings the layer table itself defines.

5. **Consolidate**: Wait for the completion notifications — both the Codex Bash tasks and the Claude agents run in the background and announce when done. Collect each Claude agent's report from its result, and read Codex results from `/tmp/codex-review-L<N>.txt` files using the Read tool. If a file doesn't exist yet, that Codex task is still running — wait for its notification rather than polling.

   - Check each reviewer's **System Model** section against your own understanding from steps 1-2. If a reviewer misunderstood what the change does or what the subsystem is for, discount its findings accordingly — findings built on a wrong model are noise. Note the discount when presenting.
   - Deduplicate across models AND across layers — the same underlying issue often surfaces through two lenses (e.g. Correctness and Data Safety flagging the same race). Merge by file, location, and root cause, noting who caught it.
   - Re-rank severities with your own judgment — reviewer labels are uncalibrated across independent agents; yours is the ranking that counts.
   - If findings conflict between layers, favor the higher-impact layer. If Claude and Codex conflict on the same code within the same layer, present both perspectives and flag the disagreement for the user.
   - Tag each finding with its source: `[Claude: Layer Name]` or `[Codex: Layer Name]`
   - Collect any **Skill feedback** notes from reviewer reports (cases where a reviewer overrode skill guidance with reasoning). Evaluate them with your own judgment — agree or push back — and present the ones with merit to the user in a separate "Skill feedback" section, with the concrete edit to the skill they imply. This is how the skill stays current as models and practices improve.
   - Present the unified findings list to the user
   - If no findings survive filtering: report "No issues found" and stop

6. **Fix**: You own the judgment; fixer subagents do the edits.

   1. **Understand the whole picture first**: Read the code around every surviving finding until you hold a unified model of everything that's broken. Findings interact — the right fix for one often dissolves or reshapes others, and you can't see that one finding at a time.
   2. **Judge each finding**: Decide whether you agree. Reviewers can be wrong — they see limited context and may misunderstand intent. Only fix findings that genuinely improve the code. Skip findings you disagree with and explain why.
   3. **Plan globally**: Structural/root-cause fixes first — a structural fix that touches more files beats a patch at the symptom site, and after planning it, re-check which local findings it dissolves. Group the surviving fixes into batches by file/area so no two fixers touch the same code, and give each fixer an **explicit file-ownership list** ("you own ONLY these files") in its prompt — batches drift into shared files (call sites, tests, types) without one, and two fixers editing one file corrupts both edits. Findings whose fix must touch another batch's file get reassigned to that batch, and shared call-site fallout (e.g. a rename's import updates) is assigned to exactly one owner.
   4. **Delegate**: Launch fixer subagents (`subagent_type: "general-purpose"`, `model: "opus"`) in parallel, one per batch. Each fixer prompt includes: the findings verbatim (Where/Evidence/Issue/Root cause/Fix), the intent summary, and any project rules that govern the change (conventions from the project's CLAUDE.md, workflows like i18n translation skills — the fixer must follow them, not improvise). Instruct fixers: prefer deletion and simplification over additive fixes; fix causes, not symptoms; when unsure about API usage or library behavior, look up the documentation (context7 MCP tools) — do not guess. A trivially small fix set (a couple of one-line edits) may be applied directly instead of delegated.
   5. **Review the results**: Read each fixer's diff when it returns — you are the quality bar. Rework or revert anything that misses the point of the finding.

7. **Report**: Summarize what was fixed. Update spec review checkboxes if applicable. Then check whether the reviewed changes (plus your fixes) invalidate any agent-facing context — the project's CLAUDE.md / AGENTS.md and docs they reference (architecture notes, schema docs, conventions). Stale agent context is worse than none: it steers every future agent wrong. Update what's stale or flag it to the user.
