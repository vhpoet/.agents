# Review product direction: phase sheet

The reveal. The product council decided a direction blind; you now compare it with the product that exists, in a fresh context, and write the target the founder approves. You do not favor the council's direction because it was independent, nor the current product because it exists or has users.

## Inputs

`BRIEF.md`, `CURRENT_PRODUCT_BEHAVIOR.md` (with its scorecard and concept count), the council's `DECISION.md` (the provisional target, with its dissent table and falsifiers), `~/.agents/skills/clean-room-reset/references/product-forces.md`, and the live product (screens, copy, analytics, support threads) as needed to verify. Read the code only when a claimed product constraint cannot be verified otherwise. Sunk implementation cost bears on sequencing, never on what the ideal product is.

## Questions

- Do the current product and the decided direction solve the same problem? Is that problem itself well supported?
- Did the current product assume a channel, workflow or feature category prematurely? Does it optimize an internal process over customer value? Is it overbuilt, underbuilt, or built for the wrong user?
- Are its policies, defaults, permissions, eligibility rules or incentives wrong? Does it conflict with the product bar's positioning, with trust, or with the other side of the market when there is one? Does it create hidden operational, support, moderation, legal or deliverability work?
- Which forces does it fail structurally (the scorecard), and does the direction close each without opening another?
- Does the current product hold evidence-backed advantages the brief missed? Does the reveal settle any falsifier in `DECISION.md`?
- Can an 80/20 change capture most of the value without a full reset? Keep, narrow, remove, replace, postpone, or validate first?

## Output 1: `PRODUCT_DIRECTION_REVIEW.md`

1. The current product's thesis as implemented; 2. the decided direction's thesis; 3. where they agree; 4. where they differ; 5. misframed problems and premature assumptions; 6. the forces scorecard, current against direction, row by row; 7. the recommendation table; 8. the 80/20 alternative; 9. the do-nothing or remove alternative; 10. evidence gaps; 11. founder decisions required.

Every recommendation carries exactly one category: `CHANGE BEFORE ARCHITECTURE` (the architecture must not fossilize this), `RECOMMENDED IMPROVEMENT` (architecture may proceed if the target leaves room), `OPTIONAL OPPORTUNITY`, `VALIDATE FIRST`, `KEEP`, `REMOVE OR DO NOT BUILD`; with evidence, confidence, expected impact, product risk and the cost of deferring. Preserve disagreements and unknowns; do not manufacture certainty.

## Output 2: draft `TARGET_PRODUCT_BRIEF.md`

Only the proposed target, no architecture: users and outcomes, the product promise, target behavior and journey, policies (eligibility, permissions, defaults, user control, limits, lifecycle), business rules, trust, privacy and legal constraints, success metrics and guardrails, the appetite (the four parts the architecture forces file defines, "Appetite"), accepted likely future changes (only those likely enough to shape architecture), unresolved hypotheses the architecture must not lock down, explicit non-goals, and behavior that may remain during migration but is not the target.

Header `Status: DRAFT: FOUNDER APPROVAL REQUIRED`. The conductor flips it to `Status: APPROVED <date>` on the founder's yes; architecture then treats accepted behavior as a requirement, unresolved hypotheses as flexibility to keep, optional opportunities as non-requirements, and current behavior as migration context only.
