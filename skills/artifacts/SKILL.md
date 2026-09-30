---
name: artifacts
description: Framing, content, and delivery rules for any artifact built for the founder — they are React components in his local CEO platform. Load whenever he asks for an artifact or something visualized.
---

# Artifacts for the founder

## Why this exists

The founder runs many parallel LLM sessions over a system too large to hold in one head. When he asks for an artifact, that IS the request: "I don't want to read a wall of text or mentally reconstruct how this works — do that work for me." The artifact's only success metric is **understanding per second of attention**. Judge every element — every section, diagram, sentence — by one question: *does this reduce the effort of understanding, or add to it?* If it adds, cut it.

An artifact that requires effort to parse has failed even if it's complete, accurate, and beautiful.

## The reader

- **CEO altitude first.** He needs the shape of the thing — what it is, why it matters, what's decided vs. open — before any mechanism. Detail exists in the page, but never in the way.
- **Zero recall.** Assume he hasn't seen the spec, the session, or the code. Never lean on a term, field name, decision ID, or codename without a one-line inline reminder of what it means.
- **He scans, he doesn't read.** The page must work when eyes jump from heading to heading and diagram to diagram, reading body text only where a heading earned the stop.
- **Step back one level higher than asked.** Before explaining the thing, orient it: where does it sit in the whole system, what problem forced it into existence, what changes because of it. A perfect explanation of an un-situated mechanism is useless to him.

## Structure: three altitudes, top to bottom

Every artifact is layered so the reader chooses their own depth. Never interleave altitudes — depth always sits *below* or *inside*, never mixed into the top.

1. **10-second layer (top of page).** One glance answers: what is this, why does it matter, and — if a decision is involved — what's being decided and what you recommend. One short hero block: a headline that states the takeaway, 1–3 sentences of context, and the single most load-bearing visual if one exists. If the reader closed the tab here, they'd still leave with the point.
2. **2-minute layer (body).** The CEO tour: the main diagram(s), the key flows or comparisons, the open questions. Mostly visual; text as captions and short assertion-led paragraphs. This layer alone must deliver full working understanding of the topic.
3. **Drill-down layer (collapsed).** Technical depth — exact field names, edge cases, code paths, alternatives considered, methodology — lives in `<details>` blocks, tabs, or clearly demarcated end-of-page sections. Adding depth must never lengthen the layers above it.

## Visual-first rules

- **Anything with structure gets drawn, not described.** Flows, architectures, timelines, state machines, before/after, comparisons, funnels, hierarchies, tradeoffs — if the reader would have to build a mental picture from prose, build the picture instead. Prose describing structure is the #1 failure mode this skill exists to prevent.
- **Diagrams show the real mechanism.** Real names from the actual system (services, tables, screens, statuses), real cardinalities, the actual failure path — not generic box-and-arrow clip art. A diagram that couldn't be wrong isn't informative. Load `artifact-diagramming` for mechanics; load `dataviz` before any chart/metric/stat-tile.
- **Label the takeaway on the visual itself.** Callouts, highlighted paths, a one-line caption stating what to notice. Never make the reader derive the point of a diagram.
- **Comparisons are tables or side-by-sides**, with the recommended option visually marked — never sequential paragraphs.

## Text rules

- **Headings are assertions, not topics.** "Payouts settle daily via the bank, not per-order" — not "Settlement process". A reader consuming only the headings gets the whole argument.
- **Zero filler.** No restating the request, no "this document describes", no throat-clearing intros, no summaries that repeat what's already visible, no hedging boilerplate. Start at the point.
- **Short paragraphs, first sentence carries the load.** 1–3 sentences each. Bold the key phrase when it helps scanning.
- **Plain language over spec jargon** — but full understanding beats brevity: never cut context the reader actually needs to get it. Concise means dense, not incomplete.
- **Never state effort or timelines.** No "takes 1–2 weeks", "a few days", phase durations, or delivery dates anywhere on the page. LLM-era coding effort bears no relation to calendar time, so such numbers are noise at best and misleading at worst. Size work only by shape when it matters (slices, what rides first), never by duration.
- **Numbers over adjectives.** "3 of 12 organizers" beats "some organizers"; "adds one table + one cron" beats "modest complexity".

## Decisions are not pages

A decision is answered on the CEO board as a card (the `ceo-threads` skill: founder charter + decision card), never on an artifact page. Pages exist to *understand* — a screen, a flow, a research verdict, how something works. If a page accompanies a card, the card points to it as the place to see the thing; the page carries no option lists, no selection widgets, no Copy-and-paste-back line, no "recommended" badges. A ruling the page relies on gets a one-line reminder in his words ("You ruled on 09-11 that refunds never run on partner data"), never a decision ID.

## Anti-patterns — never ship an artifact that

- Opens with background prose before the point (inverted pyramid violations).
- Contains any paragraph over ~4 sentences, or any structure-describing prose that should be a diagram.
- Uses a codename, field, or decision ID without an inline gloss.
- Mixes technical depth into the top two layers instead of collapsing it.
- Pads with sections included "for completeness" (glossaries of obvious terms, restated requirements, changelog-style narration of the work session).
- Is a text document with decorations. If removing every diagram would lose little, the artifact isn't visual — it's a wall of text with CSS.

## Delivery — the CEO platform, never the built-in Artifact tool

Founder artifacts are React components in his CEO platform (`~/localhost/ceo`), rendered at `https://ceo.test/<project>/artifacts/<slug>`. Do NOT publish via the built-in Artifact tool.

1. **Read the library rules first**: `~/localhost/ceo/viz/README.md` — it points at the full visualization research (read the pointed-to doc in full when choosing a format; it is deliberately not summarized) and states the component contract. `~/localhost/ceo/viz/index.ts` is the inventory of reusable components: import what fits; custom one-off components live inside your artifact file; when reusing a viz component whose abstraction doesn't fit, widen it per the README (never fork, migrate all call sites).
2. **Write the artifact**: `~/localhost/ceo/artifacts/<project>/<slug>.tsx` — `<project>` is the repo folder name (same value as the ceo-threads board project), slug matches `^[a-z0-9][a-z0-9-]*$`. Self-contained: `'use client'` if interactive, default-export component, its own hoisted `<style>` tag. Tokens are the `:root` block in `~/localhost/ceo/app/styles/tokens.css`; the shared `art-*` class vocabulary every artifact writes in is `~/localhost/ceo/app/styles/artifacts-primitives.css` — read it in full before writing any CSS of your own. The platform is dark-only — skip light-theme handling from companion skills, and there is no CSP sandbox. Full-viewport width; the founder is on a big monitor. Mermaid does NOT render here — draw diagrams as inline SVG/JSX.
3. **Typecheck**: `cd ~/localhost/ceo && npx tsc --noEmit` (artifact files are part of the project's typecheck).
4. **Rebuild the board so the artifact is served**: the CEO platform runs as a production build, so a new `artifacts/<project>/<slug>.tsx` does not appear until it is compiled in. Run `~/localhost/control-panel/bin/svc ceo prod` (rebuilds and restarts, ~20 s), then verify the build succeeded (`svc` prints `prod: ceo on https://ceo.test`; the slug will not appear as its own file under `.next/server/`, it is bundled into the `[project]/artifacts` route). A brand-new slug returns **404 until step 5 registers it** — the route resolves against the board database first — so run the `curl -sf -o /dev/null https://ceo.test/<project>/artifacts/<slug>` check after step 5, not before. Never start `npm run dev` for this.
5. **Register, attach, open**: `~/localhost/ceo/bin/ceo artifact <project> <slug> "Title" --thread <id> --open` — `<id>` is this session's board thread from the ceo-threads skill (repeat `--thread` for several). `--open` pops the artifact in his browser: that IS the delivery, so don't paste the URL as the deliverable. Screenshotting an artifact: the page scrolls inside `main.artifact-page`, so a devtools `fullPage` capture shows only the visible pane; set a tall viewport first (`emulate` `1600x2560x2`) — `resize_page` is capped by the display. When later updating the artifact, edit the file, run `~/localhost/control-panel/bin/svc ceo prod` again (it is compiled into the build), and re-run the command without `--open` unless he asked to see it again.

## Workflow

1. Load this skill's companions as required: `artifact-design` always (mandatory before writing any artifact page), `artifact-diagramming` when diagramming (near-always under these rules), `dataviz` before any chart.
2. Before writing, decide the 10-second layer first: what is the single takeaway, and what is the one visual that carries it. If you can't state the takeaway in a sentence, you don't understand the material well enough to build the artifact yet.
3. Build top-down through the three altitudes. Then do a cut pass: remove everything that doesn't pay for its attention cost, and push surviving detail down into collapsed sections.
