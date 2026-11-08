# Execute refactor slice: phase sheet

You implement one approved slice of the migration plan, and only that slice. The result reads as if written from scratch for the target.

## Inputs

The approved `TARGET_PRODUCT_BRIEF.md` when present, `ARCHITECTURE_APPETITE.md`, `CLEAN_ROOM_BRIEF.md`, `TARGET_ARCHITECTURE.md`, `MIGRATION_PLAN.md`, the named slice, the code and tests, `~/.agents/skills/clean-room-reset/references/architecture-forces.md`. Git rules are the project's and the global instructions'; nothing here changes them.

## Before editing

Write the execution contract: slice type, goal, behavior preserved, intentional product changes, Tier A invariants, the appetite limits that bind this slice, acceptance criteria, rollback boundary, manual-recovery path where relevant, temporary structures allowed, concepts and code to be deleted. Run the baseline checks and record pre-existing failures.

## Rules

- Where the old shape and the new differ, write the new and delete the old. No name, file layout, type, test or comment survives only because it already existed; no `legacy`, `compat` or `formerly` anywhere (the greenfield doctrine in `~/.agents/greenfield-convergence.md` names the forbidden shapes).
- Only the slice's changes. Deletion, consolidation and concrete code before layers. No service, store, queue, cache, broker, vendor, protocol or background workflow outside the budget; no generic wrapper, factory, provider, strategy, repository or interface the target does not justify; no automation of a deferred or manually recoverable case; no second owner for important state; no mixing product behavior and structure outside a coordinated slice; no silent change to error, retry, ordering, transaction, permission or notification semantics.
- Temporary compatibility stays visibly temporary and linked to its removal condition. Tests pin approved behavior and invariants, not implementation shape.
- When repository evidence contradicts the target, appetite or plan, stop and route it back. Do not improvise a more sophisticated design.

## Verification

Run the checks the slice names (acceptance, Tier A invariant, focused unit and integration, characterization and contract, typecheck and lint, schema, permission, fitness checks, a runtime smoke test, a manual-recovery drill for a Tier B path where relevant). Inspect the diff for unapproved behavior, concepts not in the target, speculative extension points, new runtime dependencies, duplicate paths, state written from several places, automated deferred cases, compatibility branches without a removal signal, scope expansion. Then read the result, not the diff, against the forces file: the structural rows this slice was planned to close are closed and no new one opened.

**Leftover sweep**: `scripts/leftover-sweep.sh --names <file> --frozen <file>` with the slice's names from the plan. Rewrite or delete every hit; record the names file and the zero-hit result in the report. The reviewer runs it again.

## Completion report

1. What changed; 2. behavior preserved and intentionally changed; 3. Tier A protections retained; 4. complexity added, removed, net, and the force rows closed; 5. files touched as a machine-readable block (`A|M|D|R <repo-relative path>` one per line, migrations, deploy notes, docs and tests included; files that also carry another session's hunks under `## Files shared with other work` with your line ranges); 6. verification commands and results, the sweep included; 7. manual and temporary procedures remaining; 8. risks or contradictions; 9. whether the slice is ready for independent review. Do not begin the next slice.
