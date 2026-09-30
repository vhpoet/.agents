---
name: diff-map
description: Identify natural feature/flow boundaries in uncommitted changes for focused code reviews. Use when the diff is large and you want to review specific domains rather than everything at once.
---

## Purpose

Analyze uncommitted changes and cluster them into **review domains** — features, flows, or concerns that should be reviewed together as a coherent unit. The output feeds into `/code-review <domain>` for focused reviews.

A domain is NOT a folder. It's a logical unit of change — a feature, a data flow, a refactor, a migration — where understanding the full picture requires seeing all the files together. Files from different directories that participate in the same logical change belong in the same domain.

## How to Identify Domains

**Files belong TOGETHER when:**
- They implement the same feature or user story
- One defines a type/interface that the others consume in this change
- They form a data flow (input -> transform -> output -> persist)
- They're both sides of a moved/renamed responsibility
- A deleted file and its replacement are part of the same refactor
- A migration + the code that uses the new schema
- A shared module + all its new consumers in this change

**Files belong in SEPARATE domains when:**
- They solve independent problems that happen to be in the same commit
- Understanding one doesn't require understanding the other
- They could be reviewed by different people with different expertise
- They could ship independently without breaking anything

**Edge cases:**
- A file CAN appear in multiple domains if it genuinely serves multiple features (e.g., a types file that adds fields for two independent features). But prefer assigning it to the domain where its changes are most significant.
- Test files belong with the code they test.
- Deleted files belong with the domain that explains WHY they were deleted.
- Migration files belong with the code that depends on the schema change.

## Steps

1. **Get the shape of changes:**
   ```bash
   git diff --stat
   git diff --name-status
   ```

2. **Understand what changed.** For each changed file, read enough of the diff to understand its role. Use `git diff -- <file>` for modified files. For new files, read the file itself. For deleted files, `git diff -- <file>` shows what was removed.

   Be efficient. You don't need every line — focus on:
   - Function signatures, exports, imports
   - Type/interface changes
   - What is being added vs removed vs restructured
   - Cross-file references (imports between changed files)

3. **Check for a spec.** If the changes reference a spec file (check for `.md` files in the diff, or look in `docs/specs/active/`), read it. Specs often describe the intended feature boundaries explicitly.

4. **Build a dependency graph** (mental model, not literal). For each file, note:
   - What other changed files does it import from?
   - What other changed files import from it?
   - What shared types/interfaces does it use that are also being changed?

   Files with strong cross-references belong together. Files with no shared references are likely separate domains.

5. **Cluster into domains.** Name each domain after the feature or flow, not the folder. Aim for 3-7 domains. Fewer than 3 means the changes might be small enough for one review. More than 7 means domains are too granular.

6. **Present the domains:**

   ```
   ## Review Domains

   ### 1. <Domain Name>
   <1-2 sentence description of what this domain covers and why these files go together>
   <N files, ~M lines changed>

   Files:
   - path/to/file1.ts (brief: what changed)
   - path/to/file2.ts (brief: what changed)

   ### 2. <Domain Name>
   ...

   ---
   To review a specific domain: /code-review <number>
   ```

7. **Write scopes to `/tmp/review-scopes.json`** for programmatic consumption by the code-review skill:
   ```json
   [
     {
       "id": 1,
       "name": "Domain Name",
       "description": "What this domain covers",
       "files": ["path/to/file1.ts", "path/to/file2.ts"]
     }
   ]
   ```

## Guidelines

- **Feature-first, not folder-first.** Start from "what features are being built/changed?" and group files around that. Don't start from the folder tree.
- **The reviewer test:** Would a reviewer need to see all these files together to evaluate whether the feature is correct? If yes, same domain.
- **Prefer fewer, larger domains** over many small ones. The goal is focused review, not atomized review. A domain of 15 files is fine if they're all part of one coherent flow.
- **Deleted code needs context.** Don't put all deletions in a "cleanup" domain unless they're truly independent. A deleted module usually belongs with whatever replaced it.
- **Spec phases are hints, not rules.** If a spec defines phases, those phases are good candidates for domains — but the actual file groupings should come from the code, not the spec headings.
