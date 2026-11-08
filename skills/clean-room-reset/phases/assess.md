# Assess: phase sheet

A read-only judgement of something that exists, against the named forces. There is no target and no design: you say whether the thing is optimal and elegant or overcomplicated and crowded, and what the cuts would be. The conductor names the line (product or architecture), the directory, and the thing pointed at.

## Inputs

- Product line: `CURRENT_PRODUCT_BEHAVIOR.md` with its scorecard and concept count, `~/.agents/skills/clean-room-reset/references/product-forces.md`, and the live product (screens, copy, analytics, support threads) to verify. Do not read the code.
- Architecture line: `CURRENT_ARCHITECTURE.md` with its scorecard and concept count, `~/.agents/skills/clean-room-reset/references/architecture-forces.md`, and the code it names. The appetite is the scope's spec `## Appetite` when one exists, else the standing budget in the forces file ("Appetite").

Never the collector's conversation.

## Method

1. Recount the concepts yourself (the rule is in the forces file). Files, lines and layers are evidence for a force row, never a finding.
2. Rank the forces the thing fails by the cost they carry here, at most five, each with one line of evidence and the scorecard's severity. Confirm or correct the collector's severities; the structural rows decide the headline, so a row is `structural` only when a local fix would add a setting, a step, an explanation or a special case.
3. List the cuts, ranked by what each removes (a concept, a decision, a step, a setting, a screen, a message; a runtime component, an abstraction, a duplicate path, a special case). A cut is a removal or an inference in place of a question; a cut that adds a mechanism is not a cut. For each: what it removes, and what breaks for which user or maintainer if it is taken. Deletion, inline, merge, guard and manual repair come before any new abstraction.
4. Do not design a replacement; that is the reset's job if the verdict warrants one.

## Output: `PRODUCT_ASSESSMENT.md` or `ARCHITECTURE_ASSESSMENT.md`

`scripts/assess-verdict.sh` reads this file, so keep the shape:

```markdown
Concepts: <n>
<the numbered list>

## Scorecard
<the forces table from the forces file, corrected severities>

## Fails
- <force>: <one line of evidence> (<severity>)

## Cuts
1. <cut>, removes <what>; <what breaks, if anything>
```

Literal prose, no metaphors, no effort or timeline figures.
