# Extract product brief: phase sheet

You are the sighted collector for a product reset of an existing feature. You describe what exists today, score it on the product forces, and write the brief that blind proposers will design from without being able to reconstruct today's solution. You propose nothing.

Read `~/.agents/skills/clean-room-reset/references/product-forces.md` first. Write into the directory the conductor names.

## 1. `CURRENT_PRODUCT_BEHAVIOR.md`

The existing solution, described fully and with its real names: entry points and triggers, end-to-end journeys, eligibility, permissions, defaults and policies, what the user sees, provides and controls, notifications, edge cases and recovery, effects on other users and on the business, the operational and support work it creates, its success measures, the known rationale and sunk constraints, observed confusion, the detours users take around it, non-use and complaints. Distinguish implemented from intended behavior. Work built but unshipped goes in its own section marked with its shipping state: it is evidence of intent and of the founder's latest rulings, and its decisions enter the brief only as outcome-shaped constraints.

End with the **forces scorecard** (format in `product-forces.md`; score at least conceptual model, surface area, decision load, essential against accidental complexity, progressive disclosure, golden path and escape hatches, dead ends and recovery, reversibility, defaults and configuration burden, coordination cost, operational burden, implementation and jargon leakage, consistency, trust surface) and a line `Concepts: <n>` with the numbered list behind it, counted as `product-forces.md` says.

When the conductor said **assess**, stop here and report the scorecard's structural rows and the count.

## 2. `BRIEF.md`

The only file the blind proposers see; two of them are from other model families and know nothing beyond it. Follow the sections and sources of `~/.agents/skills/product-council/phases/brief.md` (company context, the triggering situation, the user's skin, live numbers, what exists today as the user meets it, stated and hard constraints, evidence ledger, alternative framings, non-goals, device and languages, the one-sentence question), with three additions for an existing feature:

- The scorecard's `structural` rows restated as required outcomes, never as screens: "the user changes this without contacting us", not "move the setting to the first tab".
- Every current screen name, step sequence, copy, layout, interaction pattern, internal name and the feature's own name when it implies a mechanism stay out. "What exists today" describes the user's situation and the surfaces around it, not the solution under review.
- Solution-shaped problems become outcome-shaped opportunities: not "a better export screen with more filters" but "a low-effort, trustworthy way to get the data where the user needs it without asking us".

The premise check is the council brief sheet's; where the project has an entropy or convergence review, run it on the reset's question too and record its verdict in the brief as evidence, alternative scopings as categories, never mechanisms.

## 3. Leakage audit, before finishing

A proposer could reach materially different directions from the brief; could conclude not to build; cannot reconstruct the current solution from it; can tell evidence from assumption; finds every stated constraint with its reason or "reason not given".

## Completion response

The two file paths, the structural rows one line each, the concept count, the strongest evidence, the weakest critical assumption, the decisions that need the founder, and whether the leakage audit passed. No direction.
