# Reconsider: phase sheet

The founder answered the card with a note instead of a plain yes. The note is not applied; it is weighed. Two roles run on this sheet; `PROMPT.md` in your working directory says which one you are and what to write.

The rule both roles apply: a new fact or the founder's explicit override changes the direction; a restated preference does not by itself. "I would prefer X" without a reason is a restated preference. "Customer N told me Y last week" is a new fact. "Do X, I have decided" is an override. "We must keep Z" with no reason is a new stated constraint, weighed like the others. A question is answered, and the direction stands.

## Allowed inputs

Only the files in your working directory: `BRIEF.md`, `product-forces.md`, `DECISION.md` (the current decision, with its dissent table and falsifiers), `NOTE.md` (the founder's note, verbatim), this sheet, and for the councillor role `OWN.md` (your final revised direction), for the judge role `RECONSIDER_<letter>.md` from each councillor who was asked. Public primary sources are allowed. Do not read anything else on disk.

## Role: councillor

You are the councillor whose position is closest to the point the note raises (or one of all three, when the note adds a constraint). Write `RECONSIDER.md`, at most 600 words:

1. **Classification** of the note: new fact, new constraint, override, restated preference, question; one sentence of reason.
2. **Test against the decision**: which dissent row and which falsifier the note touches, if any, and whether the note settles that falsifier (quote the number or the words that do).
3. **Position**: `accept` (the direction should change, and how, in two sentences) or `hold` (the direction stands, and the evidence that answers the note). For a new constraint, your keep, drop or reframe ruling with the reason. For an override, what it costs the user in forces, so the record shows it; the direction still changes.
4. **What would change your mind** now, if you hold.

## Role: judge

You are a fresh judge, blind to authorship. Read the note, the councillors' reconsider notes and the decision, and write two files:

`ROUND.md`: the founder's note verbatim under its own heading; the classification; the councillors' positions by letter; the ruling, as one line beginning `Accepted because` or `Held because`, followed by the evidence; for a new constraint, the keep, drop or reframe ruling; for an override, `Accepted: founder override`, with the cost the council recorded.

`DECISION.md`: the updated decision in the same format as before (the judge sheet's sections), with every changed section rewritten, the dissent table extended with the new point, the falsifiers updated, the header kept at `Status: PROPOSED`, and the founder card re-issued. A held decision re-issues the card with the answer to his note folded into the state text in one sentence, in his world, never as "the council disagrees". The card still asks one yes/no question at most 200 characters.

Literal prose. No metaphors. No technical architecture or code. No effort or timeline figures.
