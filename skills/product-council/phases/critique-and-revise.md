# Critique: phase sheet

You wrote one of three proposals. Now you read the other two, score all three by the named forces, and decide whether to hold your direction, adopt another, or merge. The goal is the cleanest, simplest world-class direction for the user in the brief, not the defence of your own text and not politeness to the others.

## Allowed inputs

Only the files in your working directory: `BRIEF.md`, `product-forces.md`, `OWN.md` (your proposal from the previous round), `PROPOSAL_<letter>.md` for each of the two other proposals (letters are labels, not evidence; authorship is hidden and order is shuffled), and this sheet. Public primary sources are allowed. Do not read anything else on disk.

## Method

1. **Scorecard**: score all three proposals, your own included, on the forces scorecard from `product-forces.md`. Evidence is the proposal text and the brief. Recount each proposal's concepts as that file says. Score at least: conceptual model, concept count, decision load, golden path and escape hatches, dead ends and recovery, sensible defaults and configuration burden, coordination cost, operational burden, implementation and jargon leakage, trust surface, job to be done, time to value.
2. **The user test**: for each proposal, walk the brief's named users through the typical and error states. Where would each of them stop, hesitate, or message us? Quote the brief's own words from them where they settle a point.
3. **Constraints**: compare the three constraint tables. Where the proposals disagree on dropping or keeping a stated constraint, say who is right and why, from the evidence in the brief.
4. **Steal and flaw**: for each of the three, the strongest idea you would take from it (one paragraph) and the biggest flaw (one paragraph, naming the force it fails and the user it fails for). Your own proposal gets the same treatment.
5. **Decide**: `hold`, `adopt <letter>`, or `merge`. Adopt only when the other direction closes a force yours fails and opens none you can name; merge only when the result adds fewer or equal concepts than the better of the two parts; hold when the critique found nothing that changes the direction. "The other proposal reads confidently" and "two of us agree" are not reasons. Your reason names forces and users.

## Output: two files

`CRITIQUE.md`: the three scorecards, the user test, the constraint comparison, and the steal-and-flaw paragraphs, in that order.

`REVISED.md`, at most 1200 words, with the same eight sections and headings as a proposal (Direction in two sentences; Constraints; Why this and not the alternatives; The experience per state; Concepts; What is not built and what is inferred; Forces scorecard; What would change my mind), plus a first line reading `Decision: hold | adopt <letter> | merge` followed by the reason in two sentences and, for merge, which parts came from where.

Literal prose. No metaphors. No technical architecture or code. Never hand-write strings in a machine-translated language.
