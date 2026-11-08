---
name: clean-room-reset
description: First-principles product-then-architecture reset of an existing feature, run by context-isolated agents judging by named forces, plus a read-only assess pass that says whether anything pointable is optimal or overcomplicated. Use for "clean-room reset", "architecture reset", "rethink from scratch", "assess <feature>", "is <feature> too complicated"; never routine work.
---

# Clean-Room Reset

One model, used twice. A **sighted collector** studies the thing that exists and scores it on named forces; it writes a **brief** that states the problem and the required outcomes without revealing today's solution. **Blind designers** in an isolated workspace, from different model families, design from the brief and the forces alone. A **blind judge** picks. A **sighted reviewer** then reveals today's thing, compares, and writes the target the founder approves. Migration lands in slices, each built and reviewed by separate fresh contexts, and the reset's working folders are deleted when it closes. The **product line** runs this to decide what the right product is ("do not build it" is a legal answer); the **architecture line** runs it to decide how to build the approved product. Never let one context study the current system, design its replacement, implement it and certify the result.

**Forces** carry every judgement: `references/product-forces.md` and `references/architecture-forces.md` name them, define the scorecard (`Force | Finding | Evidence | Cost | Severity local/structural/none`), how concepts are counted, and for the architecture line the risk tiers, edge-case treatments, topology rungs and the appetite format. A finding, a design choice or a verdict names its force; what no force names is taste and does not count. The `structural` rows are what a reset exists to fix: the brief restates them as required outcomes, the target answers them, the slice plan names the rows each slice closes, the reviewer checks they closed.

**What the project provides** (record folders, the product bar, the sources of user voice and numbers, where the appetite comes from, and what "the project's UX bar" or "the project's entropy review" resolve to) is stated once in `references/project-conventions.md`; read it before the first phase.

## Phases

Each phase is a fresh subagent pointed at one sheet in `phases/` plus that phase's inputs, nothing from this conversation. The sheets are not skills.

| Phase | Sheet | Sees |
|---|---|---|
| Product collector | `extract-product-brief.md` | everything; writes `CURRENT_PRODUCT_BEHAVIOR.md` and `BRIEF.md` |
| Product decision | the `product-council` skill ("With clean-room-reset") | blind: `BRIEF.md` and the forces; three model families propose, critique, a judge writes `DECISION.md` |
| Product reveal | `review-product-direction.md` | `DECISION.md` plus the current product; writes the review and the draft `TARGET_PRODUCT_BRIEF.md` |
| Architecture scout | `extract-architecture-brief.md` | code, the approved target product; writes `CURRENT_ARCHITECTURE.md`, `ARCHITECTURE_APPETITE.md` when the spec has none, `CLEAN_ROOM_BRIEF.md` |
| Architect, two model families | `clean-room-architect.md` | blind: brief, appetite, forces; writes `CANDIDATE.md` |
| Simplifier, one per candidate | `simplify-architecture-candidate.md` | blind: brief, appetite, forces, one candidate; writes `SIMPLIFIED.md` |
| Architecture judge | `select-target-architecture.md` | blind: brief, appetite, forces, the simplified candidates as `SIMPLIFIED_<letter>.md`; writes `TARGET_ARCHITECTURE.md` |
| Migration planner | `plan-architecture-migration.md` | everything; writes `MIGRATION_PLAN.md` |
| Slice builder | `execute-refactor-slice.md` | plan, one slice, code |
| Slice reviewer | `review-architecture-refactor.md` | brief, targets, slice, diff, evidence; never the builder's conversation |
| Assess | `assess.md` | the collector's current-state file and the live thing; writes `*_ASSESSMENT.md` |

**Which line.** An approved `TARGET_PRODUCT_BRIEF.md` (`Status: APPROVED`), or the founder's statement that the product shape is settled, starts the architecture line. Product premise, workflow, channel, policy or scope materially uncertain starts the product line first; the architecture line refuses to start while a product decision that changes behavior is open. A screen whose scope is fixed is not a reset: its product step is the derivation of the project's UX bar. If the ask is a feature tweak or an ordinary refactor, say so and do not run this. A convergence small enough for a spec to state is done in-spec; the project's entropy or convergence review, when it has one, decides which route.

## Blind workspace

`scripts/architecture-round.sh <reset-folder> <architect|simplify|judge> [--vendors fable,gpt] [--dry-run]` runs a round's blind jobs in parallel (one background Bash task): each gets a fresh workspace from `make-clean-room-workspace.sh` holding only the brief, the appetite, the forces and its staged candidates, its sheet as `PROMPT.md`, and one headless vendor through the product council's `run-model.sh`. Outputs land in `candidates/<vendor>/CANDIDATE.md` and `SIMPLIFIED.md`, the judge's shuffled letters in `candidates/LETTER_MAP.txt`, and `TARGET_ARCHITECTURE.md` in the reset folder. The two architects are different model families (`fable` and `gpt`); when one vendor is unavailable, `--vendors fable,fable-2` runs a second fresh `fable` and the run notes say so. Never edit, summarize or fix what a blind agent wrote. A blind designer that returns a list of contract conflicts instead of a design is the sheet working: answer each conflict from the code in an amendment at the end of the brief and re-run that round.

## Assess mode

`/clean-room-reset assess <feature, route, screen or paths>`: read-only, designs nothing, starts no reset. Scope is the thing pointed at plus everything that exists because of it (tables, routes, jobs, screens, copy, tests). Run it when the founder asks; at the close of a feature that needed post-ship fixes, offer it in one line and run on his yes.

1. In parallel, into a scratch directory: the product collector and the architecture scout with the word **assess** in their prompt (each stops after its current-state file and scorecard). Skip the product half when the target has no user-facing surface, the architecture half when it has no code of its own.
2. In parallel, after 1: `phases/assess.md` once per line, each receiving the collector's file and the live thing, never the collector's conversation.
3. `scripts/assess-verdict.sh <dir> "<feature>"` computes the verdict block from the scorecards: `reset warranted on <forces>` only when a `structural` row exists; `simplify: <N> concrete cuts` when every row is local and cuts exist; `keep as is` otherwise. Post it verbatim on the board thread. A `reset warranted` verdict becomes a backlog thread carrying the structural rows; the reset starts only when the founder says so. Product cuts are his; engineering cuts the conductor files as threads or takes when inside the current task's scope.

## Appetite

The appetite is the yardstick of the architecture line: where it comes from is in `references/project-conventions.md`, its four parts and the engineering budget beneath them are in `references/architecture-forces.md` ("Appetite"). Every candidate passes a fresh-context simplifier before judging, and the judge selects against the minimum sufficient baseline.

## Founder gates

Gates follow the `ceo-threads` rule that he decides product and agents decide engineering: he rules on the target product brief, the appetite's promises to users and money rules, anything customer-facing or irreversible; the conductor rules on route, slice boundaries, module shape and deploy order, and logs one line on the thread. Every gate is a decision card on the board; a page is published only when he must see something and it carries no decisions. No effort or timeline figures anywhere.

- After the product reveal: the review's product rulings, grouped by scenario into as few cards as the scenarios allow; `TARGET_PRODUCT_BRIEF.md` stays `DRAFT` until his yes, then the conductor flips it.
- After the scout's appetite: one card with the appetite's user-facing rules only; the budget is the conductor's, recorded in the thread state. When the founder's own brief already prescribes the appetite, the conductor records `Status: APPROVED BY CONDUCTOR (prescribed in the founder's brief)` and he approves the resulting architecture with the design.
- After the plan: the conductor picks the route on the judge's and planner's recommendation; it becomes a card only when the route changes what users experience in the interim or moves money.

## Closure

When the final slice has passed review, the cutover is settled and the temporary-structure register is empty, the closing session deletes both reset folders, in the same commit as the last cleanup slice where possible. No distillation: a summary doc rots into a second source of truth; the durable record is the code, its tests and constraints, and git history. Before deleting, sweep for inbound references (memory files, specs, deploy notes, instructions) and reword them. Log the deleting commit hash on the thread; `git show <hash>^:docs/architecture-resets/<slug>/TARGET_ARCHITECTURE.md` re-reads the reset later.

## Constraints, both lines

- The current feature is evidence, not the default target; the stated problem is itself a hypothesis.
- No current internal name, screen or workflow leaks into a brief; the collector audits before the wall.
- Nobody generates and judges in the same context when the decision matters; a fatal flaw is not averaged away.
- A suspected bug is classified, not preserved because tests encode it.
- Implementation cost never defines the ideal product; it enters the final decision.
- An architecture agent never renegotiates approved product direction; a builder never smuggles in product changes.
- Every temporary structure has an owner, a removal condition, the slice that removes it, and a usage signal.
- No Frankenstein: finished code reads as written from scratch for the target. Everything that exists because of a replaced mechanism (file, function, type, constant, route, schema shape, test, fixture, env var, telemetry name, deploy note, doc line, i18n key, comment) is rewritten or deleted in the same slice; `scripts/leftover-sweep.sh` proves it, builder and reviewer each running it, and any hit that is not a frozen wire name blocks the slice.
- A slice passes review on evidence, never on absence of complaints; mechanisms beyond the appetite are findings, as underengineering is.
- Deferred concerns get an observable trigger and a one-paragraph upgrade path, never an implementation.
- A reset is started by the project's entropy or convergence review nominating an area, an assess verdict of `reset warranted`, or the founder; the assess pass is the only part an agent may offer unasked. A slice that needs anything on prod beyond the deploy records it the way the project records deploy steps.
