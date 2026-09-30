## iTerm2 Badge

After your first response in a new conversation, set the iTerm2 badge so the user can identify this session. Run: `~/.claude/hooks/set-badge.sh "max 3 words"` where the text is a short label for what you're working on (e.g. "event pipeline", "mobile auth", "badge setup"). Update it if the task changes significantly.

## iTerm2 Pane Color — "done" signal

When my request is fully complete — nothing left to do, nothing you're waiting on from me, no open questions — run `~/.claude/hooks/set-pane-color.sh green` to tint the pane green. That's my glanceable signal the session can be closed. Green means "close this window and never think about it again", so the bar is total quiescence, not just "my part is done":

- **Subagents must NEVER run `set-pane-color.sh` or `set-badge.sh`** — this whole section applies only to the top-level session talking to me. If you are a subagent (Task/Agent tool, workflow agent), your subtask finishing says nothing about the session being done: never touch pane color or badge. Orchestrators: subagents inherit this file, so the green signal is yours alone to send, after all of them have returned.
- **Never set green while ANY work is still in flight**: running or background sub-agents, background Bash tasks, workflows, scheduled wakeups, monitors — anything that will later produce a result, notification, or follow-up turn. Ending your visible turn while agents grind in the background is NOT done.
- Don't set it if you're asking me something, the task is only partially done, or you're waiting on anything (from me, from a background task, from an external system).
- Set it only as the very last action of a turn whose results are already in and verified — after all delegated work has returned and been synthesized, never before or during.
- When in doubt, leave the pane untinted. A missing green costs me a glance; a false green makes me close a window with work still running.

Clearing the green — mechanical rule, no judgment involved: green is cleared at the START of work, never "remembered" mid-flow. Run `~/.claude/hooks/set-pane-color.sh reset` in the FIRST tool-call batch of every turn that responds to a user message and will do any work — a follow-up request reactivates the session, so the green goes away before anything else runs (at conversation start, pair it with setting the badge). Never rely on recalling whether the pane is currently green: reset is a safe no-op on an untinted pane, so just always include it. In particular, launching anything that runs beyond the turn (background Bash, subagents, workflows, monitors) while the pane shows green is the canonical failure this rule exists to prevent — the reset must precede or accompany the launch. A purely conversational turn (no tool calls, nothing newly outstanding) may leave an existing green in place. The only turn allowed to END green is one that re-earned it by finishing everything, per the rules above.

# Machine-local context

@~/.agents/AGENTS.local.md

# Work threads (CEO board)

Every session doing real work must be tracked on my CEO threads board via the `ceo-threads` skill: at task start, attach this session to an existing thread or create one (find the thread with the project's own finder when it has one, otherwise `~/localhost/ceo/bin/ceo ls <project>`; then `log`/`new`); log meaningful transitions; mark `--input` when blocked on me; `done` when complete. Top-level session only — subagents never touch the board. Only questions you answer from context with no tool use skip the board — the moment you reach for a tool to answer, attach first, even if the ask was phrased as a casual question.

# Control-panel services — production when idle, dev while working

Applies only when your working directory is listed in `~/localhost/control-panel/services.json`.

Local apps under `~/localhost/` that are listed in `~/localhost/control-panel/services.json` (their agents file names the service; otherwise match the entry's `dir` to your working directory) are run by the control panel (`https://control.test`) as **production builds** when idle. They do not hot-reload: edits are invisible until the service is rebuilt. Switch modes with `~/localhost/control-panel/bin/svc <name> dev|prod|status`:

- **Before working on the app:** `svc <name> dev` — stops the production service and starts the project's dev server on the same port; log at `~/Library/Logs/dev-services/<name>.dev.log`. Then use the app's `https://<host>.test` URL as usual.
- **When done** — before reporting the change ready, and always before the session ends: `svc <name> prod` — kills the dev server, rebuilds, and brings production back. Never leave a dev server running. A small edit you can verify from the build alone needs no dev server: edit, then `svc <name> prod`.
- The orchestrating session owns the service's mode; a subagent switches it only when its task says so.
- Production is the project's own `serve` script (build, then start on its fixed port). Compounds live in that script, never in `services.json` — launchd `exec`s the registry command. Adding a service: one `services.json` entry (`command`, `dev`, every port the production tree listens on, first = the main URL's port), `pnpm sync-plists` in the control panel, and the one-line pointer in the project's agents file.

# Skill Gap Feedback — propose improvements when a skill under-documents itself

Applies every time you use a skill (project-local or global). If, while following a skill, you have to figure out something the skill itself should have told you — a discovery step you'd repeat on every invocation (locating a file or endpoint, inspecting the database or code to learn a shape, working out a flag or auth detail), a missing gotcha you hit, or an undocumented convention you had to infer — treat that as a gap in the skill, not just friction to absorb:

1. Finish the task at hand first.
2. Then propose the fix to me: name the skill and its file, state what was missing, and quote the exact text you'd add (and where in the file it goes) so I can approve or reject it in one glance.
3. Don't edit the skill without my approval — proposing is the deliverable; the decision is mine.

Only propose knowledge that generalizes — context every future invocation of that skill would need. One-off details of the current task, or things already covered elsewhere in loaded context (CLAUDE.md, referenced docs), don't qualify. If a session surfaces multiple gaps in one skill, bundle them into a single proposal.

# Git & Branching

- **Work directly on `main`** (or whatever branch is already checked out). Do NOT create new branches, and NEVER create git worktrees, temporary/private indexes, detached commits, or any other clever git plumbing — not even to get around a failing hook or another session's uncommitted files. If a plain commit can't go through because of another live session's work, message that session directly (`ListAgents` → `SendMessage`: what blocks you, the smallest thing it can do, what you will and won't take of its files) and keep working on whatever doesn't depend on the answer; tell me only when that session is gone, doesn't answer, or the disagreement is a product decision. If it can't go through for any other reason, stop and tell me. Never mirror or symlink `node_modules`; never build paths from `ls` output.
- **Never commit unless I explicitly ask.** A thread parking or closing is not permission. When I ask, commit only your own paths; never sweep other sessions' files into a commit.
- Pushing and PRs are opt-in: don't `git push` or open PRs unless I ask.

# Context budget

- A session is one task. When the task changes, or the context passes ~150k tokens, write a ≤10-line handoff (`ceo state <id> …`) and `/clear`. Never pile a second feature, a deploy, or another repo's work onto a context that already finished something.
- Never resume a session above ~300k context after a gap of more than an hour, and never park `ScheduleWakeup`/`/loop` on one — the whole context is re-bought at full price on wake. Start fresh from the thread instead.
- Never switch model mid-session on a large context; start a new session.

# Talking to me

- Never assume I remember anything from earlier in the conversation or from earlier sessions. Every message stands on its own: if a decision depends on something you said before (a proposal, a wording, a number, an option), restate it in full right there. Never write "my earlier proposal", "as mentioned", "the option from before" without the content itself. Repeating is fine.
- Keep messages short. Show me only what I need to make the decision in front of me; leave out process, internals and anything I don't have to act on.
- When a spec comes up (reviewing, designing, implementing, answering a question about it), assume I have not read it in weeks. Explain the thing, then name it: never a bare field name, decision ID (`D5`) or phase number without a one-line reminder of what it means. Lead with the takeaway, then the supporting detail. If the answer hinges on something the spec already decided, restate that decision in a sentence.

# Coding Guidelines

Focus on elegant, modular code. Keep codebases simple and maintainable.

## Specialized Guidelines

- **Data pipelines, ETL, scraping, background jobs**: `~/.agents/pipeline-best-practices.md`
- **React Native or Expo apps**: `~/.agents/react-native-best-practices.md`
- **Node.js APIs or backend services**: `~/.agents/node-api-best-practices.md`
- **Knex query builder**: `~/.claude/libs/knex.md`
- **Any code change** (all code here is agent-written): the review card `~/.agents/agent-written-code.md` — meaning, types, failure, compatibility, tests, evidence

## Core Principles

- Clarity over cleverness. Prefer obvious, boring solutions.
- Single responsibility. Functions and modules do one thing well.
- Consistent naming. Use full, descriptive names everywhere.
- Minimal surface area. Small, focused changes beat sweeping rewrites.

## Thoughtful Engineering

Before implementing, understand the broader context and architectural implications. Propose better approaches if the request creates technical debt. Think like a senior engineer—don't just implement the literal request if there's a better way.

## Greenfield Convergence (architecture doctrine)

**Every change leaves the architecture where a fresh team would have put it.** Load `~/.agents/greenfield-convergence.md` (the law, the three rules, what they forbid, how a session applies them) whenever a change adds a concept, a state, a table or column family, or a special case in a shared path. A project may keep its own adoption record next to it.

## Design and Architecture

- Separate concerns by layer. Avoid mixing data access, business logic, and I/O.
- Respect the layer hierarchy strictly: each layer talks only to the layer directly below it. Never punch holes through layers — controllers and UI components must not reach into database queries, raw drivers, or low-level clients directly; route through the intermediate service/abstraction layer.
- Keep boundaries clean. Modules should have clear inputs/outputs and minimal side effects.
- Prefer composition over inheritance and deep nesting.
- Avoid hidden coupling. Make dependencies explicit.
- Use guard clauses to reduce nesting.
- Handle errors close to their source, with context for debugging.

## Code Structure

- One concern per file. Growing size (300+ lines) is a signal to check for a second concern hiding inside — split along concept boundaries, never to hit a line count. A long file telling one cohesive story stays whole; fragmenting it scatters the concern across files.
- One responsibility and one level of abstraction per function. Extract when it clarifies the narrative or removes duplication — never to satisfy a length rule. A chain of one-call helpers is worse than one readable function.
- Avoid long parameter lists. Group related values into objects.
- Extract shared *code shape* at the second occurrence — two call sites already justify a shared helper. *Knowledge* — business rules, constants, schemas, thresholds — has one source of truth from the first occurrence; duplicating a fact is a bug, not a pending abstraction.
- Add comments sparingly, only to explain "why".

## Making Changes

- Reconsider the entire affected area when modifying features.
- Reduce entropy as you go: delete dead code and duplication in the area you touch, and never add a backwards compatibility layer, update every reference directly.

## Naming Conventions

- Use descriptive, domain-accurate names. No abbreviations.
- Boolean variables: `is`, `has`, `should` prefixes.
- Keep naming consistent across variables, types, DB columns, and API fields.

## TypeScript Practices

- Prefer type inference for locals; explicit types for exported APIs.
- Avoid `any`. Use `unknown` and narrow with type guards.
- Use `type` for unions/primitives; `interface` for extendable object shapes.
- Model data with literal unions instead of enums.
- Make impossible states unrepresentable with discriminated unions.
- Align runtime validation with types (Zod schemas for inputs).

## Data and State

- Prefer immutable data where practical.
- Keep transformations explicit. Avoid hidden mutations.
- Validate inputs early. Fail fast with helpful errors.

## Performance

- Avoid premature optimization. Optimize only for measured pain.
- Be mindful of N+1 queries and repeated API calls.
- Cache only when necessary and invalidate explicitly.

## Response Format

- Do NOT create unsolicited documentation.
- Only provide the changes requested.

## What to Avoid

- Over-engineering, clever tricks, unnecessary abstractions.
- Inline styling, long files, deeply nested logic.
- Storing secrets in code.
