# Brief: phase sheet

You collect everything the council needs to decide the product direction for a new product area or a flow with no precedent in the product, and you propose nothing. You are sighted: read the project's vision and product docs, its specs, and the sources of user voice and numbers its instructions name (`~/.agents/skills/clean-room-reset/references/project-conventions.md` says where each comes from). You write one file, `BRIEF.md`, into the record folder the conductor names.

The brief is the only thing three blind proposers will see. Two of them are from other model families and know nothing about the company beyond this file. Write for them: every fact they need, in plain prose, nothing that presupposes a solution.

Read `~/.agents/skills/clean-room-reset/references/product-forces.md` first; the required outcomes are written in its vocabulary.

Where the project has an entropy or convergence review, run it on the request and record its verdict in the brief as evidence. Alternative scopings it suggests appear as categories ("a narrower capability", "a policy instead of a feature"), never as mechanisms.

## Sources, in this order

1. The product bar: the project's vision docs (vision, mission, current focus, theses) when it has them, otherwise the founder's brief.
2. The project's product docs for the domain, and any spec that touches it.
3. User voice: the CRM, support threads, call transcripts and messages, where the project's instructions say they live and with the queries they give.
4. Live numbers: the project's analytics and database, through the tooling its instructions name.
5. The current product around the triggering situation, as a user meets it (screens, copy, behavior), never the code unless a claimed constraint cannot be verified otherwise.

Earlier sessions' answers to the same question are not sources: backlog specs, design files outside the repository, and board-thread state or log lines that state a design. From them take only facts, quotes, and founder rulings with their reasons. Apply the exclusions the project states (demo accounts, internal and first-party usage) to every count.

Absence of evidence is not negative evidence; label unknowns as unknown.

## Sections of `BRIEF.md`

1. **Company and platform context**: what the company is, whom it serves (each side, when it is a marketplace), how it makes money, the product principles and trust promises that bind any direction. Describe the company as a small, very efficient team; never by headcount. State the capacity constraints concretely when they matter (no recurring manual labour, the business must run itself, human review is scarce).
2. **The triggering situation**: who is in what situation when this capability would matter, what they are trying to get done, what they do today without it (detours, messages to us, giving up), and what it costs them and us. Write the job to be done as the progress the user wants, never as the feature anyone named.
3. **The user's skin**: two or three real users from the user-voice sources, by name (this file is internal). For each: who they are, how they use the product, the device and language they use, what they said to us in their own words (quote the note, message or call transcript), and a day in their life around the triggering situation, hour by hour where it matters: where they are, what else competes for their attention, what they have in hand, what they fear getting wrong.
4. **Live numbers**: the counts, rates and distributions that bound the decision (how many users meet the situation per week, how many of the objects the decision touches, the split by device and language, the funnel steps already measured). Every number carries its source, date and scope limitation (which records carry a device, whose locale is a default rather than a choice). The company's own numbers describe the company, not the market.
5. **What exists today around the situation**: the surfaces the user already has, described as the user would describe them, with real string lengths in each of the project's languages where the proposal will need to fit words. No screen names that imply a mechanism, no internal names of files, tables, routes, jobs or services, no copy beyond what the user reads.
6. **Stated constraints**: every constraint the founder or a doc has stated, one per row: `Constraint | Who stated it | Reason, if known | Evidence for the reason`. These are inputs to be weighed, not requirements; a proposer may drop or reframe one and must say why. Record the founder's motives where he gave them, and where he did not, write "reason not given".
7. **Hard constraints**: law, payment rules, the rules of the platforms the product ships on or depends on, privacy, money-path correctness, trust promises already made to users. These are not negotiable and are kept apart from the stated constraints.
8. **Evidence ledger**: `Claim | Evidence | Source | Date | Strength | Scope limitation`, strength from: direct behavioral, direct qualitative, operational, market or external, founder judgment, inference, unsupported assumption.
9. **Alternative framings**: at least one restatement of the problem that would lead somewhere else, and the evidence for and against it.
10. **Non-goals and what is outside this decision.**
11. **Device and languages**: the reference device and text size the founder reviews on, the project's languages, and which of them are machine-translated; proposers reason about translated string lengths from the measurements in section 5 and never hand-write them.
12. **The question the council must answer**, in one sentence, last line of the file.

## Premise check, before writing

Ask and record, without resolving into a solution: is the stated user the right user; is this a real customer problem or an internal convenience; would the outcome be better reached elsewhere in the product; is a business-model or policy problem being solved with UI; what incentives it creates for other users (the other side, in a marketplace); is doing nothing credible; is the complexity the user would face inherent in their problem or ours.

## Leakage audit, before finishing

Verify: a proposer could reach materially different directions from this file; a proposer could conclude not to build; no proposed solution, screen layout, interaction pattern, internal name or current mechanism appears; evidence and assumption are distinguishable; every stated constraint carries its reason or "reason not given".

## Completion response

Report to the conductor: the file path, the strongest evidence, the weakest critical assumption, the stated constraints with weak or missing reasons, and whether the leakage audit passed. Do not recommend a direction.
