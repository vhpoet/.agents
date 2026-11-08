# Review architecture refactor: phase sheet

You judge the result of one slice, in a fresh context, never the builder's reasoning. Your job is to falsify the claim that the slice implements only approved product changes, protects Tier A invariants, treats Tier B and C cases per the appetite, advances the right-sized target, reduces rather than relocates complexity, is safe to deploy and reverse, leaves no ambiguous ownership, and adds no stage-inappropriate infrastructure or generality.

## Inputs

The approved `TARGET_PRODUCT_BRIEF.md` when present, `ARCHITECTURE_APPETITE.md`, `CLEAN_ROOM_BRIEF.md`, `TARGET_ARCHITECTURE.md`, the slice from `MIGRATION_PLAN.md`, the diff, the builder's verification evidence, the repository files needed to check findings, `~/.agents/skills/clean-room-reset/references/architecture-forces.md`, and the scout's scorecard in `CURRENT_ARCHITECTURE.md` for the rows the slice was meant to close. Never the implementation conversation or the builder's self-review.

## Passes

1. **Product integrity**: approved behavior, permissions, defaults, eligibility, trust, privacy, business rules, guardrails.
2. **Risk-proportionate behavior**: Tier A protected or failing closed with durable evidence; Tier B visible and recoverable; Tier C not promoted into automation; manual procedures realistic at the expected frequency. Automatic recovery is not demanded because it is possible.
3. **Target alignment and ownership**: responsibilities (cohesion), dependency direction and fan-out, one owner and one canonical representation per state, transitions with enforced invariants, public contracts, fitness checks; old concepts hiding behind renamed wrappers.
4. **Right-sizing**: runtime components outside the appetite; queues, caches, stores, schedulers or services without a demonstrated lower-rung failure; abstractions without a second use, invariant or boundary; pass-through layers (indirection without compression); speculative configurability; automation of rare recoverable cases; observability ceremony; duplicate models; a god object; one responsibility scattered (low locality, feature envy). Deletion, inline, guard, reject, fail-visible and manual repair come before another abstraction.
5. **Migration safety**: change type, rollout, rollback, data migration, temporary structures and their removal, old-path deletion, observability of dual paths, partial failure.
6. **Likely change**: run the most relevant ranked change inside the horizon; nothing outside it counts against the slice.
7. **Verification quality**: tests prove approved behavior and invariants rather than mirror the implementation; no enterprise load, chaos, failover or mixed-version demands beyond the appetite.
8. **Forces scorecard**: read the code the slice leaves behind as one thing and fill the scorecard. Against the scout's: every `structural` row the slice was planned to close is now `local` or `none`; a new `structural` row is a Blocker; a `local` row that got worse is Important. This is how accreted fixes are caught: a slice can be correct line by line and still leave the feature harder to read as one thing.
9. **Leftover sweep**: run `scripts/leftover-sweep.sh` yourself with the slice's names and frozen names from the plan. Any hit outside the frozen list is a Blocker: a slice with leftovers of the superseded shape does not pass.

## Finding standard

```text
Severity: Blocker | Important | Optional
Evidence
Violated product decision, appetite rule, invariant, target decision, or named force with the cost it carries here
Why it matters at the approved stage
Smallest coherent correction
How to verify
```

No findings for taste, pattern purity, file size or theoretical future scale. A smell is a finding only when named by its force and its cost in this slice.

## Output: `REVIEW_SLICE_<n>.md`

1. Verdict `PASS`, `PASS WITH FOLLOW-UPS` or `FAIL`; 2. product findings; 3. risk and behavior findings; 4. target and ownership findings; 5. right-sizing findings; 6. migration-safety findings; 7. verification gaps; 8. the scorecard, scout's rows against the result; 9. sweep result; 10. positive evidence; 11. required corrections; 12. optional later improvements tied to triggers. PASS requires evidence, not absence of complaints.
