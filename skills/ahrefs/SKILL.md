---
name: ahrefs
description: Run Ahrefs SEO research in the browser — search volume, keyword difficulty, competitor organic keywords, content gap, backlinks. Use for keyword research or any Ahrefs lookup; save reports as CSV.
---

# Ahrefs research

The user pays for an Ahrefs **Starter** plan ($29/mo). This skill covers how to actually get data out of it and — critically — how to **persist every result** so the same research never has to be repeated.

## How to access Ahrefs: BROWSER, not API

The Starter/Trial plan gives a valid API key with **0 units** — every data endpoint returns `403 {"error":"Insufficient plan"}`. The API is inert until the plan is upgraded to Lite or higher (`credentials.env` documents how to re-check). **Do all research by driving the logged-in web app** with the `claude-in-chrome` tools (load them via ToolSearch first; see the browser-automation guidance in the system prompt).

- Base: `https://app.ahrefs.com`. The user is already logged in — reuse the existing session; do **not** create a fresh login. Start with `tabs_context_mcp`, then a new tab to the relevant tool.
- If the session is logged out or a tool path 404s, stop and tell the user — don't try to log in.

## Credit budget — spend deliberately

Starter = **200 credits/month**. Cost model:
- **1 credit** per report opened (covers all charts on that page).
- **+1 credit** each time you apply a filter and click "Show results", change the date range, or open a SERP view.
- **Free**: re-opening the *same* report within 30 minutes.

A full one-time keyword-research sprint (seed overviews + ~15 matching-terms expansions + a few SERP checks + 2–3 competitor Site Explorer pulls + content-gap) runs **~60–100 credits**. That fits one month with headroom. What blows the budget is *ongoing* re-pulling and heavy filter combos — avoid that. **Plan the seed list before opening anything** (pull Google Search Console first via the `search-console` skill so you walk in with a tight, demand-validated list and don't burn credits exploring).

## The tools that matter (Starter includes these)

- **Keywords Explorer** — paste a batch of seed keywords for volume + difficulty in one report; use **Matching terms** / **Related terms** / **Questions** to expand a head term into modifiers and long-tail. Set the right **country** (e.g. `am` for Armenia) and mind language (run Russian seeds like `афиша еревана`, `куда сходить в ереване` — RU volume is reliable; Armenian/`hy` data is thin).
- **Site Explorer** — enter a competitor domain (`tomsarkgh.am`, `list.am`, local afisha sites) → **Organic keywords** and **Top pages** to see what they rank for = the gap GSC can't show.
- **Content Gap** — your domain vs 2–3 competitors → keywords they rank for and you don't.
- **Rank Tracker** (50 keywords) — load the target keywords for pages you build, to measure movement over time. Separate from the 200 credits.

Per-report view is capped at **250 rows** on Starter — fine, results are volume-sorted so the top 250 are what matter.

## Data persistence — MANDATORY

> Every report you view in the browser must be saved before you move on. The goal: never research the same thing twice.

Native **Export → CSV is disabled on Starter (0 export rows)**, so don't rely on the download button. Instead, for each report:

1. Extract the visible table (use `get_page_text` / `read_page`, or `javascript_tool` to read the results table DOM — pull header + all visible rows).
2. Write it as a CSV into the project's Ahrefs data dir (below), one file per report.
3. Take a screenshot alongside it (`reports/<same-name>.png`) as a visual backup.
4. Append one row to `manifest.csv`.
5. If a native CSV download *does* work (e.g. after a PAYG export top-up), use it — then still log it in `manifest.csv`.

### Storage layout

Save under the current project's SEO docs. For **esora**: `docs/seo/ahrefs/`. If a project has no `docs/seo/`, use `./ahrefs-data/`.

```
docs/seo/ahrefs/
  manifest.csv            # running index of every pull
  reports/
    YYYY-MM-DD_<tool>_<slug>_<country>.csv   # e.g. 2026-06-28_ke-matching_concerts-yerevan_am.csv
    YYYY-MM-DD_<tool>_<slug>_<country>.png
```

`<tool>` ∈ `ke-overview` | `ke-matching` | `ke-related` | `se-organic` | `se-toppages` | `gap`.

`manifest.csv` columns: `date,tool,query,country,locale,rows,credits_est,file,notes`.

Before starting any new research, **read `manifest.csv` first** and skip anything already pulled (re-use the saved CSV) so credits aren't wasted re-fetching known data.

## If the plan is later upgraded (API becomes live)

Once `units_limit_workspace > 0`, prefer the API for bulk/repeatable pulls (still write results to the same `reports/` + `manifest.csv` layout). Auth: `Authorization: Bearer $AHREFS_API_KEY` from `credentials.env`; base `https://api.ahrefs.com/v3`. Key endpoints: `keywords-explorer/overview`, `keywords-explorer/matching-terms`, `site-explorer/organic-keywords`. Mind per-plan row caps and unit costs.
