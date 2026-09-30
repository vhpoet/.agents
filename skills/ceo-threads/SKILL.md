---
name: ceo-threads
description: Track every working session on the founder's CEO threads board. Use at the start of any real task, the moment a question turns into work, when blocked on him, and when the task completes.
---

# CEO threads board

The founder runs many parallel Claude sessions and tracks all in-flight work on one board (the `ceo` project). Every session doing real work must be attached to a **thread** there, so that when he closes this terminal, the work's state — and the command to resume this exact session — survives on the board.

All interaction goes through one CLI: `~/localhost/ceo/bin/ceo`. It auto-attaches the current session (ID + cwd) on `new` and `log` — never look up session IDs yourself. Keep total usage to ~2–4 calls per session.

## The two concepts

- **Area** — a stable piece of the product or business: something the founder would still name a year from now (esora examples: `cinema`, `events`, `ticketing`, `crm`, `admin`, `organizer-app`, `web`, `growth`). **Areas don't end.** Each project has a mapped set — see `ceo map <project>`.
- **Thread** — a finite stream of effort inside an area ("seat map picker", "cross-cinema list"). **Threads end.** This is what sessions attach to. A feature or fix is a thread, never an area.

## At every new request from the founder — not just session start

The attachment decision happens for EVERY new ask: at session start, on mid-session follow-ups that change what you're working on, and especially in RESUMED sessions (`claude -r`) — a resumed session getting a fresh request must re-check the board exactly like a new one. Having done this earlier in the session does not cover a new line of work. "Done" is not forever: if the new ask continues a thread that was closed, reopen it (below) instead of orphaning the work.

**A question is not an exemption.** The exempt case is narrow: an ask you answer from what's already in context, with no tool use. The moment you reach for a tool to answer it — reading code, querying a database, searching the repo, driving a browser — this session is doing real work and goes on the board *before* you go further. This is how sessions most often go missing: the first message read as a casual question ("there are two of these, or is this a mistake?"), the attach decision was made once against that framing, and the hour of investigation that followed never re-triggered it. Judge against what the ask has become, not how it was phrased.

```
~/localhost/ceo/bin/ceo map <project>
```

`<project>` = this repo's folder name (e.g. `esora`). In esora the session-start
status card already says how many threads are open and how many await him, and
the threads themselves come from `esora status --threads <word>` (the open ones
whose line mentions that word) or `esora status --all` — either replaces `ceo ls`
there. Elsewhere, `ceo ls <project>`. Then one of:

- **Reopen a closed thread** — the new ask continues finished work:
  `~/localhost/ceo/bin/ceo log <id> "reopened: <what's being done now>" --open` (updates ≤200 chars)

- **Attach to the matching open thread** — the user is continuing work that's already on the board:
  `~/localhost/ceo/bin/ceo log <id> "picked up: <what this session is doing>"`
- **Create a new thread** in the fitting area from the map, classified under an allocation domain:
  `~/localhost/ceo/bin/ceo new <project> <area> "<short outcome-shaped title>" --domain <domain>`
  Where the project declares domains (`ceo domains <project>` lists them; esora does), the CLI **refuses a `new` without `--domain`** — a thread without one lands in the founder's "needs review" quarantine, which he must clear by hand. Pick the domain by the work's dominant intended business outcome — never by where the code lives or who asked. For esora, the boundary rules live in the esora repo's `backlog` skill. Genuinely torn between two domains? Pass `--needs-review` instead and say why in the thread's state — the explicit, deliberate way into needs-review. Projects with no domains take `new` without either flag.

**Choosing the area**: always prefer an existing mapped area — that's what makes the board legible. Only if the task genuinely belongs to a stable part of the product/business that isn't mapped yet, add it first with a lowercase single word (`ceo area <project> <name> "one-line note"`), then create the thread in it. Never invent near-duplicates (`marketing` vs `mktg`) and never create an area for a one-off effort. If a project has no map at all yet, map its 5–10 obvious stable parts from the codebase/context before creating the thread.

**Single-session tasks need one call, not a cycle.** A task that starts and finishes inside this session gets `ceo new <project> <area> "<title>" --domain <domain> && ceo done <id> "<one line>"` at the end. The attach → log → done cycle is for work that parks or hands off. Target ≤4 `ceo` calls per session (measured average: 9.9).

## Writing for the founder — the board is CEO-altitude, not a dev log

Everything on the board is read by a founder scanning 20 parallel efforts. Every extra word or insider term is a tax on him. Hard rules:

- **Titles are stable effort names** — a short noun phrase naming what the effort is about ("Seat maps for external cinemas"), never containing status ("...designed and implemented"), phase numbers, or session-plan vocabulary. The title must still be correct when the work is half-done or redirected.
- **Updates are one short plain sentence of what is now true.** No implementation detail parentheticals (schema names, migration mechanics, review tool names), no activity narration ("edited three files"). "Refunds work and are tested" beats "refund idempotency implemented (31 tests, webhook retry TBD)".
- **Input requests are literal questions/asks aimed at him**, phrased so he can answer from the board: "Approve the unified hall layout design?" — ONE ask per update. Two asks = two updates (or two threads).
- **A new --input update replaces the previous ask** on that thread — restate the full current ask each time; never assume he read the earlier ones.
- **Length is suggested, not absolute** — the CLI bounces titles > 80, updates > 200, state > 600 chars with a reminder. Rewrite shorter first; only if the content genuinely cannot be shorter, re-run with `--force`. Never reach for `--force` to skip the rewrite. `--force` exists only on `new`, `log`, `vote` and `state`; `ceo done` takes no flags (passing one is an error) and is never length-checked, so keep its line within the 200-char update limit yourself.

Before/after (real examples of failing vs passing the bar):

| ✗ Dev log | ✓ Board |
|---|---|
| "approval of venue-halls spec v3 — research review adopted (observation boundary added, authored-copy + fake halls + topology fingerprint + orientation subsystem trimmed); one naming call: venue_space vs venue_hall" | "Approve the seating spec (3rd revision)? One naming call inside: 'venue space' vs 'venue hall'." |
| "refund idempotency implemented (31 tests, webhook retry TBD, see PAY-17)" | "Refunds are safe against double-charging and tested. Webhook retries still unverified." |
| "frontend dev server restart (suspended in your terminal, port 5173 dead), then eyeball film pages + simulator pass, then commit call" | "Ready for your look: restart your dev server, check the film pages, then say commit." |

The test: could he act on it without ever having seen the session? Words that only mean something inside the session (subsystem names, spec filenames, version tags, ticket IDs) don't go on the board.

## During work

Log only meaningful transitions:

```
~/localhost/ceo/bin/ceo log <id> "<what is now true>"
```

Recording user demand (a real ask, quoted from the source conversation — never paraphrased or invented):

```
~/localhost/ceo/bin/ceo vote <id> --via <channel> --who "<@handle or Name>" --said "<their words>" [--on <YYYY-MM-DD>]
```

One call per person who asked, never two merged; it writes the standard `User ask via …` update and does not change status. `ceo show` counts them as `votes N`.

Whenever the overall picture changes (milestone done, direction changed, new phase), ALSO refresh the thread's living state — the first thing the founder sees on the thread:

```
~/localhost/ceo/bin/ceo state <id> "<2-4 plain sentences>"
```

State is written for the founder returning after hours away: what this effort has achieved so far, what direction was taken, what's happening now or blocked. It REPLACES the previous state — always write the complete current picture, standalone. Same CEO-altitude writing rules as updates.

## What is his to decide — the founder charter

He decides product; agents decide engineering. Before parking anything on him, classify it:

- **His call** — what a buyer, organizer or partner sees or is promised; money moving or being refunded; anything that cannot be undone (deleting data, contract wording, a message sent to a partner); scope, priority, or an exception to an approved brief or appetite; taste on a screen he will look at.
- **Agent's call, notified** — how code is shaped, which order things ship in, migration routes, module or table names, slice boundaries, test strategy: everything inside an approved brief and appetite. Decide it, then say so in one line on the thread ("Chose the 80/20 route; say so if you want it flipped"). If an engineering choice would make something noticeably worse for users or cost real money, that line goes on a card before doing it.
- **Not a question at all** — options a standing rule already forbids (the appetite, the brief, an earlier ruling on this thread or a sibling). Never show them.

Test: would a strong CTO bring this to the CEO? If not, decide it.

## When blocked on him — the decision card

An ask is a card he can answer in one glance with one word, written in his world: what a buyer, organizer or he experiences — never table, column, service, file or decision-ID names. "Today" appears only when today is a harm. He has not seen the session, the spec or the code, and he holds no map of the current system; the card must not require him to build one.

The card is the thread's `state` (≤600 chars); the question is its `--input` line (≤200):

```
~/localhost/ceo/bin/ceo state <id> "<Situation as a scenario: who does what, with real numbers.> Recommended: <what happens, one sentence>. Downside: <the strongest cost of saying yes>. Precedent: <an earlier ruling of his this follows, if any>."
~/localhost/ceo/bin/ceo log <id> "<one yes/no question>? Yes = I proceed as recommended." --input
```

Rules: one card per thread, one recommendation, yes/no. Options only when genuinely torn — at most three, the status quo always one of them, each stated as what the user experiences, differing on one named axis. Several questions about the same scenario become one card; unrelated questions wait their turn. The old "I'll do X on <date> unless you say otherwise" form is retired: either it is the agent's call (no card) or it waits for his answer — silence never authorizes money or an irreversible step. A page (artifact) may accompany a card as the place to *see* something — a screen, a mock — but the decision is answered on the board, never on the page.

## When the work completes

Completed = committed / deployed / delivered as requested:

```
~/localhost/ceo/bin/ceo done <id> "<one-line outcome>"
```

If the session ends with work still ongoing, leave status as is — an open thread on the board is the reminder.

## Rules

- Subagents never run these commands — top-level session only.
- Noticing mid-session that this session is doing real work and isn't on the board means attaching it right then. Late is far better than never — a session that finishes untracked is invisible to the founder, and he cannot tell it apart from work that never happened.
- One thread per line of work; if this session's task is genuinely two unrelated lines of work, two threads.
- Don't log secrets or long output; one sentence per update.
