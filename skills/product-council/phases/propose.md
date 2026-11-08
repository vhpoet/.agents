# Propose: phase sheet

You design one product direction from first principles, alone, without seeing what anyone else proposed and without seeing any current implementation. You are one of three councillors from three different model families; the other two receive this same sheet. Your proposal will be read and scored by them and by a judge.

## Allowed inputs

Only the files in your working directory: `BRIEF.md` (the situation, the user, the evidence, the stated constraints, the question), `product-forces.md` (the named forces your proposal is judged by), and this sheet. Public primary sources are allowed (Apple Human Interface Guidelines, NN/g, regulators, vendor help pages, well-known products). Do not read anything else on disk. Do not look at competitor interfaces until step 4 below is done.

## Stance

The brief's stated constraints are inputs, not requirements. The founder wrote them with a motive; the motive may be sound, may be a habit, or may be a fear that the evidence does not support. Your first job is to say which constraints you keep, which you drop and which you reframe, with the reason. Agreeing with the brief is not a virtue; being right about the user is. "Do not build this" and "build a narrower thing" are legal answers and must be considered seriously.

Think as the actual user in the brief's "user's skin" section: in her situation, on her phone, with what competes for her attention. The direction that demands the least thought from a first-time, non-technical user wins when two directions both solve the job: fewer concepts, fewer choices, nothing to remember, recognition over recall, every control named by its outcome in her words, a good default instead of a setting.

## Method, in this order

1. **Constraints**: for each row of the brief's "Stated constraints" table, write `keep`, `drop` or `reframe`, with one sentence of reason grounded in the evidence or the user's situation. Hard constraints are kept without comment.
2. **Outcomes**: restate the customer outcome and the business outcome in one sentence each.
3. **Evidence**: name the strongest evidenced opportunity and the weakest, and reframe the problem at least once to test whether the brief's framing is solution-shaped or too narrow.
4. **Mechanism set**: before choosing, consider each class and say in one line why it fits or does not: no product change; remove or narrow an existing capability; a policy or operational process; education or a better default; an external integration or export; a constrained native workflow; a platform-level capability that solves the need indirectly; a broader native product. Do not pad the list.
5. **Direction**: pick one coherent direction. State the customer promise, the golden path, the escape hatches that keep unusual cases off it, what is inferred instead of asked, which actions are reversible and so need no confirmation, and what you deliberately do not support.
6. **The experience, per state**, on the brief's reference device at default text size, in the user's words, for: empty (nothing exists yet), first use (she has never seen this), typical (the common day in the brief), error (the thing that can go wrong in her situation, and how she recovers). For each state: what she sees, what she does, the exact English words on screen, what tells her it worked. Name one reference product that does this exact thing well (which screen, in which app) and what you take from it. Note which strings are at risk at the brief's measured lengths in its other languages; never hand-write a machine-translated language.
7. **Concept count**: list and count the concepts this direction adds for her, as `product-forces.md` ("How to count concepts") says.
8. **Deletion test**: for every element, what breaks for her if it is removed. Remove what survives the question.
9. **Tests**: incentive (how a rational user exploits or ignores this), other users (the effect on the other side of the market, when there is one), operational reality (can the team run this without a hidden service business), evidence (which parts follow from evidence, which are judgment, which are guesses).
10. **Falsifiers**: the observations that would make you abandon this direction, each stated so that a number or a quote could settle it.

## Output: `PROPOSAL.md`, at most 1200 words

Sections, in this order and with these headings:

1. Direction in two sentences
2. Constraints: keep, drop, reframe (table)
3. Why this and not the alternatives (the mechanism set, one line each)
4. The experience per state (empty, first use, typical, error), with the reference product
5. Concepts the direction adds (numbered, counted)
6. What is not built and what is inferred
7. Forces scorecard for this direction, in the format from `product-forces.md`, with the rows it still fails and why that is accepted
8. What would change my mind (falsifiers)

Literal prose. No metaphors. No technical architecture, component names, or code. No implementation cost reasoning; cost belongs to the final decision, not to the ideal direction.
