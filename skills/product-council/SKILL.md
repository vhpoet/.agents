---
name: product-council
description: Three model families independently propose, critique and revise the product direction for a new product area or a flow with no precedent in the product, a blind judge decides, and the founder receives one yes/no card; his notes go back to the council to be weighed, never applied directly. Use before any design or spec writing, for "product council", "we need to build X", "what should this look like" for a new area or an unprecedented flow. Not for a new screen or a change inside an existing feature (those get the derivation of the project's UX bar), copy tweaks or bug fixes; the founder can say "skip the council".
---

# Product Council

One opinion is not a decision. Three LLMs from different families draft a direction independently from the same brief, critique each other blind, revise, and a blind judge decides by the named product forces and the brief's real users, never by confidence, length or agreement. The founder receives one card and answers yes or no; anything he adds goes back to the council as a fact, a constraint or an override, and is weighed, never applied. The conductor (the top-level session) never proposes, scores, decides or edits what a councillor wrote: it collects, isolates, relays and posts.

## When it runs

Any new feature, product area, screen or flow, before design or spec writing. Inside `clean-room-reset` it is the product decision between the collector's brief and the reveal. Not for copy, labels, styling, bug fixes, or a change inside an existing feature that adds no concept. When the founder says "skip the council", proceed without it and log that on the thread. Wrong for anything with a known shape; right where the direction itself is the decision.

## The record

The council folder the project conventions name (`~/.agents/skills/clean-room-reset/references/project-conventions.md`, which also names the product bar and the sources the brief reads), committed, kept: `BRIEF.md`; `proposals/<vendor>/PROPOSAL.md`; `critiques/round-<n>/<vendor>/CRITIQUE.md` and `REVISED.md`; `DECISION.md` (`Status: PROPOSED` until the founder answers, then `ACCEPTED <date>` or `DECLINED <date>`); `rounds/<n>/` for each founder note after the card; `RUN.md` (vendors, the letter map, why critique stopped, any fallback). A spec written later links `DECISION.md` as its product direction.

Vendors are named as the record names them: `fable`, `gpt`, `grok` or `gemini`, and `fable-2` when a second fresh `fable` run stands in for an unavailable vendor (the judge still gets three directions; `RUN.md` says why). `scripts/run-model.sh` lists what each vendor needs.

## Sequence

Every blind phase runs in a fresh context inside an isolated workspace holding only the brief, `product-forces.md`, its inputs and `PROMPT.md`. `scripts/council-stage.sh` does the deterministic part (letters, input staging, the record layout) and prints the `run-phase.sh` commands; `scripts/council-round.sh <record> <propose|critique-1|critique-2>` runs a round's three councillors in parallel (one background Bash task; `--dry-run` prints them).

1. **Thread and folder.** Attach to the board thread (`ceo-threads`), create the record folder.
2. **Brief**: one sighted subagent on `phases/brief.md` writes `BRIEF.md` (it runs the project's entropy or convergence review, when it has one, and records the verdict). Check its leakage audit passed. Inside `clean-room-reset`, the collector's `BRIEF.md` is this file and the phase is skipped.
3. **Letters**: `council-stage.sh letters <record> fable gpt <grok|gemini|fable-2>` shuffles A, B, C over the vendors once and writes the map to `RUN.md`; every later round and the judge reuse it, because revised texts refer to each other by letter.
4. **Propose**: `council-round.sh <record> propose` (`phases/propose.md`, output `PROPOSAL.md`).
5. **Critique**: `council-round.sh <record> critique-1` (`phases/critique-and-revise.md`; each councillor sees `OWN.md` and the two others as `PROPOSAL_<letter>.md`; outputs `CRITIQUE.md` and `REVISED.md`).
6. **Stop or second round.** Read the three `REVISED.md` "Direction in two sentences". Stop when they are the same shape (`product-forces.md`, "How to count concepts", says what that means). Otherwise `council-round.sh <record> critique-2`. Two rounds is the limit; the judge rules on what remains.
7. **Judge**: `council-stage.sh judge <record> <last round>` prints one fresh `fable` command (`phases/judge.md`, output `DECISION.md` in the record).
8. **Card**: `scripts/card-check.sh <record>/DECISION.md`. Over the limit: send the judge one line ("Shorten the card's state to at most 600 characters") and re-run it in the same workspace; the conductor never edits the card. Then post it verbatim, the only thing that reaches him: the state as `ceo state <id>`, the question as `ceo log <id> ... --input` (the `ceo-threads` skill's decision card).
9. **Answer.** "Yes": flip `Status: ACCEPTED <date>`, log it, hand the direction to design or spec writing. A bare "no": flip `Status: DECLINED <date>`, log it, stop. Anything else is a note: the correction loop.

## Correction loop

A note after the card (a constraint, a preference, a fact, a question, "just do X") is never applied by the conductor.

1. Save it verbatim as `rounds/<n>/NOTE.md`. Pick who runs: the councillor whose position in the dissent table is closest to the point (letter through `RUN.md`), or all three when the note adds a constraint.
2. `council-stage.sh reconsider <record> <n> <vendor>...` prints the councillor commands (`phases/reconsider.md`, role councillor, output `RECONSIDER.md`) and, to run after they return, the fresh `fable` judge command (role judge; writes `ROUND.md` and the updated `DECISION.md`, which the printed command copies to the record root).
3. `card-check.sh`, then post the re-issued card.

The rule the sheet applies: a new fact or his explicit override changes the direction; a restated preference does not by itself, and the re-issued card answers it in one sentence in his world. Dissent surfaces only in that reply, never in the first card.

## With clean-room-reset

The reset's product collector writes `BRIEF.md` (plus the current-product file the council never sees); the conductor copies the brief into a council record and runs steps 3 to 7. The reveal phase then reads `DECISION.md` as the provisional target, and the founder gates follow `clean-room-reset`'s rules after the reveal: the judge's card is not posted before it.
