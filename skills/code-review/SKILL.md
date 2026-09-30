---
name: code-review
description: Defect-finding and entropy-reducing code review for backend, frontend, and mobile code. Group review lenses, run an independent architecture reviewer and Codex twins on critical lenses, consolidate evidence, and verify authorized fixes.
---

## How This Review Works

The review hunts two things at once: defects that matter, and entropy the change adds or exposes. Understand the change, select and group review lenses, investigate in parallel, then consolidate findings. Reviewers report only. The orchestrator judges the evidence and, when fixes are authorized, plans and verifies them. Simplification is conditional and report-only.

### Resources

- `prompts/common.md`: shared investigation method and output format; every reviewer gets it inlined in its brief.
- `prompts/L0-approach.md` through `prompts/L16-design-quality.md`: conditional lenses, not a required agent count. L11 combines hygiene and readability; L12 was merged into L11. L13 is a React companion read with L14 (web) or L15 (mobile). L16 reviews rendered UI.
- `scripts/layers.js --triage-help`: lens names, prompt filenames, selection guidance, and default groups. `--list` prints the full table; its impact labels are not finding severities or a rule for resolving disagreements. `--snapshot` writes the review diff once; `--briefs` writes one self-contained brief per reviewer group.
- `scripts/codex-review.js`: independent Codex review of one or several lenses, with the same context pack. Prints JSON containing status and unique result paths.

## Scope

Resolve skill arguments before reviewing:

1. Domain number (`/code-review 2`): use that domain's files, name, and description from `/tmp/review-scopes.json`, produced by `/diff-map`. Confirm the files still match the current changes.
2. Explicit file paths: review that subset.
3. No arguments: review all uncommitted changes.

For uncommitted reviews, use `git diff HEAD -- <files...>` to include staged and unstaged tracked changes, and `git ls-files --others --exclude-standard -- <files...>` to enumerate untracked files for direct reading. Omit the file arguments for the whole repository. Quote each path separately; use `-z` when consuming inventories programmatically. If HEAD does not exist yet, inspect both `git diff --cached` and `git diff`, plus untracked files. Never stage files to make them visible to review.

For explicitly requested committed work, record the exact comparison in the context pack and use it throughout. Read unchanged callers and dependencies as evidence, even when outside the finding scope. Separate unrelated pre-existing issues from defects caused or exposed by this change.

## Orchestration

### 1. Build the shared context

Read the scoped changes and relevant commit history. Write a 1–2 sentence intent summary and a context pack containing:

- **Scope and revision**: repository, comparison, changed file inventory including untracked files, and effort map if several flows are involved. Split unrelated efforts when that makes review more coherent.
- **Contracts and appetite**: relevant requirements and invariants. If a spec exists, read it and carry its `## Appetite` section verbatim. Otherwise state an inferred appetite briefly, without treating omissions as permission to drop safeguards. Include requested hypotheses to test.
- **Check results**: reuse results only when they cover the current revision and relevant scope. Run missing project-required checks and checks appropriate to the change once; record command, scope, revision, and pass/fail. Distinguish a demonstrated regression from an unrelated failure or environment blocker. Reviewers may run focused checks to establish a finding, but must not repeat whole suites.
- **UI evidence**, when applicable: existing captures and their states for L16; that lens produces missing captures or declares visual coverage incomplete.

Write the diff once, into the session scratchpad: `node <skill-dir>/scripts/layers.js --snapshot --repo "<repo-root>" --out "<scratch-dir>" [--scope-file <scope-json>]` produces `diff.patch` (tracked changes against HEAD, untracked files as new-file patches) and `changed-files.tsv` (status, path, line range in the patch). Reference both from the pack; read the diff from it yourself. For committed comparisons, write the patch and file list by hand into the same two files.

Write the pack once to an absolute-path file. Every Claude and Codex reviewer, and later every fixer, receives the same intent and pack. Keep it factual: share contracts and evidence, not other reviewers' conclusions. If files change during review, reconcile affected reports and check results against the new revision.

### 2. Review the approach (L0)

The orchestrator does this step itself — do not delegate it. Read `common.md` and L0, then the scoped changes, and judge the implementation approach through that lens. Present the findings to the user before proceeding: if the approach needs rethinking, the user decides whether to continue or course-correct first. Preserve reasonable approved designs; recommend a different approach when you can show the problem the current one causes.

Architecture (L1) is not folded into this step. It always gets its own independent reviewer in step 4: a second read of the structure catches what the orchestrator's model of the change already takes for granted.

A **retrofit** is a finding at this level in its own right — an existing shape branched so one case fits (a new `kind`/`mode`/flag column or `if`), a compat or legacy layer, or a second way of doing something the system already does — and the fix is the convergence plus the deletion of the old shape, not the branch: `~/.agents/greenfield-convergence.md` (project adoption records may add to it, e.g. Esora's `docs/vision/theses/greenfield-convergence.md`).

### 3. Select and group lenses

Run `scripts/layers.js --triage-help`. Choose lenses by the scoped change's risks, then group those inspecting the same flow and dependencies. A typical review runs 3–4 Claude reviewers, using the default groups `--triage-help` prints: architecture (L1 alone), behavior and data (L2, L4–L7, L9, L10), tests and hygiene (L3, L8, L11), and platform (L14 or L15 with L13, plus L16) when UI changed. Drop unselected lenses from a group. Each extra agent re-reads the same code and dependencies, so split only when scope or distinct failure modes require independent attention (for example, a large migration next to an unrelated backend flow), and say why in the triage.

When in doubt, run the lens: a false positive is cheap, a miss is not. L1 Architecture & Boundaries always runs as its own group.

Assign each group its lenses and finding scope, then generate the briefs: `node <skill-dir>/scripts/layers.js --briefs --out "<scratch-dir>" --context-file "<pack-path>" --intent "<summary>" --group architecture=1 --group behavior=4,5,6 ...`. Each `brief-<name>.md` inlines the reviewer rules, `common.md`, and the group's lens prompts (companions included), and points at the snapshot. Platform groups get their platform files and the React companion. Each distinct changed behavior needs an owner; a behavior's correctness matters even when its code looks simple. Unchanged dependencies remain readable. Present the triage to the user — which groups run with which scope, which lenses are skipped and why — then proceed without waiting.

**Mark the critical lenses** — these get a Codex twin in step 4, an independent second model on the lenses where a missed defect costs the most. Default critical set: L4 Security, L5 Correctness, L6 Data Safety, whenever selected. Add another lens when this diff makes it critical (money-path UI, auth flows, migrations, data-destructive operations). Combine critical lenses that inspect the same path into one Codex call with the same finding scope as the corresponding Claude group. If Codex is unavailable or a run fails, report the missing coverage rather than treating it as clean.

### 4. Run reviewers

Launch every group and every Codex twin in one message, all in the background. Every selected group gets its own agent and every critical lens gets its Codex call — do not skip selected lenses or fold groups together beyond what triage decided. Use Claude `general-purpose` agents with `model: "opus"` for routine review; pass `model: "fable"` explicitly for L1 Architecture & Boundaries and for any group carrying tricky concurrency or money-path reasoning. Do not rely on implicit model inheritance.

Use this prompt with absolute paths; the brief carries everything else:

```text
Read <scratch-dir>/brief-<name>.md and follow it.
Finding scope: <files, one per line; or "every file in changed-files.tsv">.
```

Reviewers return findings as the text of their final message. Never ask a reviewer to write a report file; subagent writes of report files are rejected.

For Codex, use the script's absolute path and always pass the target repo and context file:

```bash
node <skill-dir>/scripts/codex-review.js --repo "<repo-root>" --layers 4,5,6 --intent "<summary>" --context-file "<pack-path>" --scope-file "<scope-json-path>"
```

`--scope-file` is an optional JSON array of repository-relative paths; omit it for the whole comparison. Give Codex the same finding scope as its corresponding Claude group. The script deduplicates selected prompt files, including companions. Run Bash calls in the background with a 10-minute outer timeout; the script defaults to 9 minutes and terminates the child process group on timeout.

This wrapper supports uncommitted reviews only. For committed comparisons or whole-tree audits, skip the Codex half and note it. Do not combine a custom prompt with `--base` or `--uncommitted`; those combinations have failed or selected the wrong diff in this workflow. Check every report's System Model against the intended scope.

Each invocation creates its own temporary result directory and prints a JSON result with `status`, `findingsPath`, and `rawOutputPath`. Read findings only for `status: "ok"`. `error`, `timeout`, and `incomplete` mean missing coverage, never “no issues found”; an empty or unrecognized report is incomplete even if the process exited zero. `reportFormat` says which shape the report took: `lens` follows common.md; `native` is Codex's own format (a summary, then `Full review comments:` with `- [P2] Title — path:lines` items) and carries no System Model, so check each of its findings against the code before accepting it. If a run is `incomplete` but `findingsPath` is non-empty, read the file before treating the run as missing coverage. Inspect diagnostics for a targeted retry when useful. Wait for task completion notifications, not file polling.

### 5. Consolidate evidence

- Check each System Model against the code and intent. Verify claims built on a questionable model before accepting them.
- Merge findings by root cause and affected behavior across groups and models; retain source labels without duplicating the report.
- Resolve conflicting findings by tracing the disputed scenario or running a focused check. Rank confirmed findings by actual consequence, not lens rank or model identity. Escalate unresolved product tradeoffs; identify unresolved factual claims as unverified rather than making the user adjudicate competing opinions.
- Present confirmed findings with concrete triggers, consequences, and proposed fixes. State material unreviewed scope or failed checks. “No issues found” means no confirmed findings within the assessed scope, not proof that incomplete review passed.
- Evaluate reviewers' Skill feedback and present worthwhile concrete edits separately; do not change skills without approval.

Stop after the report when fixes are not authorized, or when no actionable findings survive.

### 6. Apply authorized fixes

Read the code around every surviving finding until you hold one model of everything that is broken; findings interact, and the right fix for one often dissolves or reshapes others. Judge each finding yourself — reviewers see limited context and can be wrong; skip the ones you disagree with and say why. Then plan globally: structural, root-cause fixes first. A fix that removes the cause beats a patch at the symptom site even when it touches more files, and after planning it, re-check which local findings it already resolves.

Group edits by explicit file ownership so two fixers never edit the same file. Assign shared call-site changes to one owner. Give fixers the findings verbatim, the context pack, confirmed failure scenarios, required invariants, and the project rules that govern the change (conventions from the project's CLAUDE.md, workflows like translation skills — fixers follow them, not improvise). Instruct fixers: prefer deletion and simplification over additive fixes; fix causes, not symptoms; when unsure about an API or library behavior, look up the documentation (context7 MCP tools) rather than guess. Use Opus for routine batches and Fable for novel or tricky logic. Apply a trivially small fix set directly. Review each resulting diff against the confirmed failure — you are the quality bar; rework anything that misses the point of the finding while preserving unrelated changes.

### 7. Simplify only when warranted

If fixes introduce meaningful complexity, request one fresh-context, **report-only** simplification pass. Supply the current diff, intent, appetite, confirmed failure scenarios, and required invariants. Ask for specific removals and evidence that those behaviors remain protected. Missing mention in the appetite is not evidence that a safeguard is unnecessary.

The orchestrator judges each proposal and applies only justified removals. Skip this pass for simple fixes. It never authorizes an agent to remove code by default.

### 8. Verify and report

After the final edits, including simplification, verify the affected behavior and run relevant project-required checks. Reuse prior results only for unchanged code and dependencies; do not present pre-fix checks as validation of the final revision. Where practical, a regression check should fail for the original defect and pass after the fix. Re-run only failing checks while diagnosing; broaden when changes or unresolved risks justify it.

Report what was fixed, how the final revision was verified, and any remaining limitations. Update applicable spec checkboxes and agent-facing context invalidated by the changes, or flag it when outside the authorized scope. Do not commit or deploy without the user's authorization.
