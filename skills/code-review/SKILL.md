---
name: code-review
description: Entropy-reducing code review. Parallel review agents report findings, then a single agent applies all fixes.
---

## How This Review Works

Three phases: **parallel review** (all agents simultaneously, report-only), **consolidation** (deduplicate and present findings), **fix** (one agent applies all changes).

Each review agent runs as an independent subagent via the Agent tool (`subagent_type: "general-purpose"`). Agents analyze changes through their assigned lens and report findings — they do not edit code. After all complete, findings are consolidated and a single fixer agent applies everything.

### The Layers

| Layer | Name | Focus | Impact |
|-------|------|-------|--------|
| 1 | **Architecture & Boundaries** | System structure, trajectory, separation of concerns | Highest |
| 2 | **Data Flow & Contracts** | Encapsulation, coupling, interface boundaries | High |
| 3 | **Testability** | Test seams, dependency injection, isolation | High |
| 4 | **Security & Trust Boundaries** | Auth, input sanitization, trust boundaries, secrets | Medium-high |
| 5 | **Correctness** | Logic defects, edge cases, async, failure modes | Medium |
| 6 | **Data Safety** | Data integrity, transactions, migrations, rollback safety | Medium |
| 7 | **Database & Queries** | Query efficiency, indexes, joins, Knex patterns | Medium |
| 8 | **Test Coverage** | Missing tests, edge cases, error paths, test quality | Medium |
| 9 | **Performance & Efficiency** | Hot paths, N+1 queries, pagination, buffering, cost | Medium |
| 10 | **Observability & Operability** | Logging, metrics, tracing, graceful degradation | Low-medium |
| 11 | **Code Hygiene** | Dead code, duplication, naming, clarity | Low |

---

## Orchestration

1. **Understand intent**: `git diff` + `git log` → 1-2 sentence summary of what changed and why.

2. **Triage**: Based on the diff, decide which layers to run. Present the triage to the user (which layers run and why, which are skipped and why), then proceed without waiting.

   **Skip guidelines** — skip a layer when the changes clearly have nothing for it to review:
   - **Architecture & Boundaries**: Always run. Every non-trivial change has structural implications.
   - **Data Flow & Contracts**: Skip if changes don't touch module interfaces, data passing, or cross-boundary communication (e.g., pure internal logic changes, styling, config).
   - **Testability**: Skip if no new functions, modules, or components are introduced — only relevant when new code needs to be testable.
   - **Security & Trust**: Skip if changes don't touch API endpoints, user input handling, authentication, authorization, or data access.
   - **Correctness**: Always run. Any code change can introduce bugs.
   - **Data Safety**: Skip if no database operations, migrations, transactions, or persisted state changes.
   - **Database & Queries**: Skip if no database queries added or modified.
   - **Test Coverage**: Skip if changes are purely config, styling, documentation, or trivial refactors with no behavioral change.
   - **Performance & Efficiency**: Skip if changes don't involve data access, loops, rendering, API calls, or anything on a hot path.
   - **Observability & Operability**: Skip if no backend service code, error handling, or operational code changed.
   - **Code Hygiene**: Always run. Any code change can leave behind mess.

   When in doubt, run the layer. The cost of a false positive ("no issues found") is low. The cost of skipping a layer that had something to catch is high.

3. **Parallel review**: Launch all selected layers simultaneously as subagents. Each gets the Review Agent Prompt Template with its layer section pasted in. All run in report-only mode — no edits.

4. **Consolidate**: After all agents complete:
   - Merge findings, grouping by file and location
   - Deduplicate when multiple layers flag the same code — merge into one finding
   - If findings conflict, favor the higher-impact layer
   - Present the unified findings list to the user
   - If no findings across all layers: report "No issues found" and stop

5. **Fix**: Spawn one fixer agent with the Fixer Agent Prompt Template and the consolidated findings.

6. **Report**: Summarize what was fixed. Update spec review checkboxes if applicable.

---

## Review Agent Prompt Template

Compose each agent's prompt by filling in this template. Include the **full text** of the relevant layer section — do not summarize or abbreviate it.

```
You are reviewing code for [Layer Name] concerns. Report findings only — do not edit code.

## What Changed

[1-2 sentence intent summary]

## Your Task

**Understand first, then review.** Do not jump into line-level analysis. Start from the system level and work down.

1. **Understand the system**: Run `git diff` to see what changed. Read the affected files and their surroundings — imports, callers, related modules. Understand what part of the system this is, what it's responsible for, and how it connects to the rest.

2. **Evaluate the approach**: Before examining any specific code, ask: is this the right approach to the problem? Is this the right place for this change? Does the overall direction make sense? If the approach itself is wrong, that matters more than any line-level issue.

3. **Review through your lens**: Only now apply your specific review lens to the details. Look for issues within the approach, not just within individual lines.

4. **Report findings** using the format below. If nothing was found, say "No issues found."

## Guiding Principles

**Core question**: If a staff engineer was designing this from scratch, knowing everything they know now — is this how they would build it?

**Goal**: Reduce system entropy. Favor simplicity over additive fixes. Prefer deletion, consolidation, and realignment over adding complexity.

**Scope**: The diff is your entry point and center of gravity. Reason outward only as needed to evaluate fit within the broader system.

**Discipline**: "No issues found" is a valid output. Do not invent issues. Do not nitpick style when the code is sound. Only flag things that should change, not things that could change.

## Finding Format

### [Short title]
**Where**: file:lines
**Issue**: What's wrong
**Fix**: What to change — specific enough that someone can apply it without re-deriving the reasoning
**Severity**: high | medium | low

## Your Review Lens

[Paste the full layer section content here]
```

---

## Fixer Agent Prompt Template

```
You are applying code review fixes.

## What Changed
[1-2 sentence intent summary]

## Findings
[Paste consolidated findings]

## Guidelines
- Read the code around each finding before editing.
- Prefer deletion and simplification over additive fixes.
- If a finding doesn't make sense after reading the code, skip it.
- If two findings affect the same code, apply them together coherently.
- Do not make changes beyond what the findings call for.
- When unsure about correct API usage, library behavior, or best practices, look up the documentation before applying a fix. Use the context7 MCP tools (resolve-library-id → query-docs) to check current docs for any library involved in a finding. Do not guess.
```

---

## Layer 1: Architecture & Boundaries

**This layer produces the most significant changes.**

This layer has two parts. First, evaluate the changes themselves for structural soundness. Then, zoom out to evaluate the architectural trajectory — where these changes are pushing the system, and whether that direction still makes sense.

### Part A: Structural Review

Take the bird's-eye view. Look at the system holistically — across changed and unchanged code. Identify architectural violations and places where the current implementation no longer fits the problem.

Focus on:

- **Separation of concerns**: Code that started with clean separation often drifts as features accumulate. Look for modules that accreted responsibilities over time. In domain-based systems, each domain should be responsible for its own concerns — check that code lives in the correct domain and cross-domain dependencies go through proper interfaces.
- **Mixed responsibilities**: Functions or modules doing multiple unrelated things. Data access interleaved with business logic. UI components making API calls or containing validation rules. Controllers doing transformation work that belongs in a service layer.
- **Scattered concerns**: Related logic spread across multiple files or layers when it should be co-located. The same concept implemented differently in different places.
- **Over-engineered abstractions**: Places where subtractive refactoring would beat additive fixes. Situations where removing code, collapsing layers, or realigning modules to current requirements would restore coherence.
- **Structural opportunities**: This is where the Core Question applies most directly. What would be different if designed from scratch? Is there a simpler, more coherent structure hiding under the accretion?
- **File size and complexity**: Are files growing too large? Files that exceed a few hundred lines or handle too many responsibilities should be broken down. Large files are a structural smell — they often indicate mixed concerns or missing abstractions.
- **Simplicity**: Prefer the simplest solution that works. Avoid clever tricks. Code should be obvious and boring, not impressive. If there's a simpler way to achieve the same result, that's the right way.
- **Emergent consolidation**: Before these changes, the existing structure may have made sense. But now that new code exists, do patterns emerge that warrant consolidation? Does the combination of old and new code reveal opportunities for shared abstractions, unified interfaces, or merged modules that weren't justified before? The right abstraction often becomes clear only after you have multiple concrete implementations.

**Frontend/Mobile considerations:**
- **Component structure**: Are components appropriately sized and focused? Is there a clear hierarchy? Are presentational and container concerns separated following best practices?
- **State management**: Does state live at the right level? Is there prop drilling that should use context? Is global state used appropriately or overused?
- **Navigation patterns**: Does navigation follow platform conventions and best practices?

### Part B: Architectural Trajectory

After reviewing the structural soundness of the changes, zoom out one or two levels above the bird's-eye view. Use the changes as a central theme to read the direction the system is evolving in, then ask: **is the current architecture still the right foundation for where this system is heading?**

This is not about the changes being wrong. It's about recognizing inflection points — moments where incremental changes are collectively pushing the system toward a shape that would be better served by a different foundational approach. Each individual change may be perfectly reasonable, but the cumulative trajectory may reveal that the system has outgrown its original architecture.

How to evaluate trajectory:

1. **Read the direction**: What do these changes (and recent commits in the same area) tell you about how this part of the system is evolving? What new capabilities, patterns, or responsibilities are being added? What's growing in complexity?

2. **Project forward**: If this trajectory continues for 3-5 more iterations of similar changes, what does the system look like? Does the current architecture accommodate that gracefully, or does it start to buckle? Are we accumulating workarounds, special cases, or friction that signals a mismatch between the architecture and the problem it's solving?

3. **Test the alternative**: If you were designing this area from scratch today — knowing the current requirements, the trajectory, and everything learned so far — would you choose the same architecture? If not, what would you choose instead? Be specific: name the pattern, the restructuring, or the different decomposition.

4. **Assess the gap**: How wide is the gap between the current path and the better path? Is it a minor adjustment (restructure a module, introduce an abstraction) or a fundamental rethink (different data model, different responsibility boundaries, different paradigm)? Is the cost of continuing on the current path accelerating?

**What to report**: Only raise trajectory concerns when there's a concrete, better alternative and the gap is wide enough to warrant action or at minimum awareness. State what the current trajectory is, where it leads, and what the alternative would be. Don't propose vague "we should rethink this" — name the specific architectural change and why the trajectory makes it worth considering now rather than later.

**What NOT to report**: Don't flag trajectories that are fine. Don't speculate about hypothetical future requirements that aren't implied by the actual changes. Don't propose rewrites for their own sake. The bar is: would a staff engineer, seeing these changes, say "we're heading toward a wall — we should course-correct now while it's cheap"?

---

## Layer 2: Data Flow & Contracts

**This layer addresses how modules communicate and maintain boundaries.**

When concerns are properly separated, each piece can be understood, tested, and changed in isolation. When encapsulation is intact, you can refactor internals without breaking callers. Violations of these principles are often the root cause of code that's hard to reason about and fragile to change.

Focus on:

- **Leaky abstractions**: Internal details exposed through public interfaces. Other modules reaching into internals instead of using defined contracts.
- **Implicit coupling**: Modules that depend on each other's internal structure rather than explicit interfaces. Changes in one place that unexpectedly break something elsewhere.
- **Broken or implicit data flow**: Data flow that has become implicit over time rather than explicit. State that can be mutated from outside its owning module.
- **Interface boundaries**: Are contracts clear? Are dependencies explicit? Can internals be changed without breaking callers?
- **Unnecessary mapping layers**: Modules that define local types for data that already has a shared type, forcing callers to transform between equivalent shapes. When a canonical type exists, consumers should accept it directly.
- **Error contracts**: Are error types part of the contract between modules? Do callers know what errors to expect? Are errors translated at boundaries (e.g., a database "not found" becomes a domain-level "event not found") or do internal error types leak across module boundaries? Is there a consistent error hierarchy, or does each module invent its own error shapes?

---

## Layer 3: Testability

**This layer ensures the code can be verified and maintained with confidence.**

Untestable code often signals structural problems. If you can't test something in isolation, it's usually too tightly coupled. Testability issues caught here often require restructuring — better to address now than after tests are written around a bad design.

**Important**: This layer is about code structure that enables testing, not about writing tests. Do not propose specific tests here. Focus on structural changes that would make the code testable.

Focus on:

- **Dependency injection**: Are dependencies passed in or hardcoded? Can external services, databases, and time be mocked?
- **Test seams**: Are there clear boundaries where test doubles can be inserted? Or is everything tightly coupled with no injection points?
- **Side effects**: Are side effects isolated and controllable? Can you test business logic without triggering I/O?
- **Test isolation**: Can tests run independently and in parallel? Are there shared mutable state or ordering dependencies?
- **Boundary clarity**: Are the units clear? Is it obvious what constitutes a unit test vs integration test for this code?

---

## Layer 4: Security & Trust Boundaries

**This layer ensures the system is secure by design, not by accident.**

Security issues often require structural changes — adding middleware, restructuring data flow, or introducing new validation layers. Catching these early prevents expensive rework.

Focus on:

- **Authentication & authorization**: Are auth checks at the right points? Can users access only what they should? Are there missing permission checks on new endpoints or operations?
- **Trust boundaries**: What data comes from users vs internal systems? Is external input treated as untrusted? Are there assumptions about data integrity that could be violated?
- **Input sanitization**: Beyond validation, is input sanitized appropriately? SQL injection, command injection, XSS, path traversal vulnerabilities.
- **Secrets handling**: Are secrets hardcoded? Properly scoped? Logged accidentally? Exposed in error messages or stack traces?
- **Audit logging**: Are sensitive operations logged for security auditing? Can we reconstruct what happened if something goes wrong?
- **Rate limiting & abuse prevention**: Can this be abused at scale? Are there missing rate limits on expensive operations?

---

## Layer 5: Correctness

**Does the code do what it should?**

Focus on:

- **Logic defects**: Incorrect behavior, wrong conditions, off-by-one errors, race conditions.
- **Unsafe edge cases**: Input validation gaps, null/undefined handling, boundary conditions.
- **Failure modes**: What happens when things go wrong? Are errors handled appropriately? Do failures cascade or stay contained?
- **Idempotency**: Can operations be safely retried? Are there unintended side effects on repeat?

### Async & Concurrency

- **Missing `await`**: Unwaited promises that silently discard errors or cause wrong execution order.
- **Unhandled rejections**: Errors not caught in event handlers, callbacks, or fire-and-forget calls. `.catch()` handlers that swallow instead of rethrow. `Promise.all` vs `Promise.allSettled` misuse.
- **Concurrent mutations**: Multiple async operations on the same state without coordination. Check-then-act where state changes between check and act.
- **Cleanup on cancellation**: Component unmount, request abort, process shutdown — are in-flight operations cancelled and intermediate resources cleaned up?
- **Ordering assumptions**: Code that assumes async operations complete in order. Late-arriving responses overwriting newer data.

**Frontend/Mobile considerations:**
- **Client-side state consistency**: Can the UI get into inconsistent states? Are there race conditions between user actions and async responses?
- **Optimistic updates**: If using optimistic UI, is rollback handled correctly on failure?
- **Stale data**: Can users act on stale data? Is cache invalidation handled properly?

---

## Layer 6: Data Safety

**Does the data stay consistent through changes and deployments?**

Focus on:

- **Data integrity**: Are constraints enforced at the right level? Can invalid states be represented? Are there race conditions in uniqueness checks?
- **Transactions**: Are related operations atomic when they need to be? Can partial failures leave inconsistent state?
- **Migrations**: Schema changes, data transformations, rollback safety. Will existing data work with new code?
- **Backward compatibility**: Will new data work if code is rolled back? Are there breaking changes to stored data?
- **Resource lifetimes**: Connections, file handles, subscriptions — properly acquired and released? Memory leaks?
- **Systemic risks**: Places where data integrity relies on assumptions instead of guarantees. Implicit ordering dependencies. States that "should never happen" but aren't enforced.

---

## Layer 7: Database & Queries

**Are queries correct, efficient, and indexed?**

Before reviewing, read `backend/docs/db-schema.md`, `backend/docs/db-indexes.md`, and `~/.claude/libs/knex.md` to understand the schema, existing indexes, and Knex conventions.

Focus on:

- **Join vs separate queries**: When a join is cleaner/faster vs when separate queries avoid cartesian explosion, reduce payload, or allow independent caching. Consider the data shape — one-to-many joins can multiply rows unnecessarily.
- **Missing indexes**: Queries filtering, sorting, or joining on unindexed columns. Cross-reference with `db-indexes.md`. Watch for composite index column ordering that doesn't match query patterns.
- **SELECT efficiency**: Fetching all columns when only a few are needed. Large text/json columns pulled unnecessarily. Missing `.select()` specificity in Knex.
- **Query structure**: Unnecessary subqueries, inefficient WHERE clauses (functions on indexed columns defeating the index), OR conditions that prevent index use where UNION would work.
- **Knex patterns**: Raw queries where the Knex builder works cleanly, missing `.transacting()` in multi-step operations, not using `.first()` when expecting a single row, connection pool misuse.
- **Pagination**: Offset pagination on large tables (cursor-based is better). Missing LIMIT on queries that could return unbounded results.

---

## Layer 8: Test Coverage

**This layer identifies missing tests and writes them.**

Report what tests are missing. The fixer agent will add them. Read existing test files to understand the project's testing patterns so your recommendations follow those conventions.

Focus on:

- **Missing unit tests**: Core business logic that lacks test coverage. Functions with complex conditions or branching.
- **Missing integration tests**: Interactions between components, API endpoints, database operations that aren't tested together.
- **Edge cases**: Boundary conditions, empty inputs, maximum values, error states that should be tested but aren't.
- **Error paths**: Exception handling, failure scenarios, timeout behavior — often untested.
- **Happy path gaps**: Core user flows that should have end-to-end coverage.
- **Regression risks**: Bug fixes or complex changes that should have tests to prevent recurrence.
- **Test quality**: Existing tests that are brittle, test implementation details, or don't actually verify behavior.

---

## Layer 9: Performance & Efficiency

**This layer identifies performance problems and unnecessary cost.**

Performance issues range from algorithmic complexity to infrastructure cost. Some require architectural changes (high impact), others are localized fixes (medium impact). Catch them before they reach production.

Focus on:

- **Algorithmic complexity**: Is this accidentally O(n^2) or worse? Are there nested loops over large datasets?
- **Hot paths**: What code runs most frequently? Is it optimized appropriately?
- **N+1 queries**: Database access patterns that make one query per item instead of batching.
- **Pagination**: Large result sets handled correctly? Cursor vs offset pagination appropriateness?
- **Buffering versus streaming**: Memory implications, backpressure handling. Are large payloads loaded entirely into memory?
- **Payload sizes**: Are API responses or database fetches pulling more data than needed? Overfetching?
- **Memory usage**: Large objects held unnecessarily, unbounded growth, missing cleanup.
- **Mobile & client performance**: If applicable — bundle sizes, render performance, unnecessary re-renders.
- **Infrastructure cost**: Operations that scale poorly with usage. Expensive calls in loops. Missing caching where it would help.

**Frontend/Mobile considerations:**
- **Rendering performance**: Are there unnecessary re-renders? Are expensive computations memoized? Are lists virtualized when needed?
- **Bundle size**: Are imports optimized? Is code splitting and lazy loading used where appropriate?
- **Network efficiency**: Are requests batched or deduplicated? Is data overfetched? Is caching used effectively?
- **Offline & network resilience**: Does the app handle poor connectivity gracefully? Are there appropriate loading and error states?
- **Mobile-specific**: Battery impact? Memory usage on constrained devices? Respects system settings (low power mode, data saver)?

---

## Layer 10: Observability & Operability

**This layer ensures the code can be understood and operated in production.**

Production code needs instrumentation. When something goes wrong at 3am, can the on-call engineer understand what happened? While mostly additive, some observability decisions affect correctness semantics — timeouts, retries, and error classification have behavioral implications.

Focus on:

- **Logging**: Is there sufficient context for debugging without excessive noise? Are log levels appropriate? Are sensitive values redacted?
- **Metrics**: Can we measure feature health? Latency, error rates, throughput? Are there metrics for the key business operations?
- **Tracing**: Can we follow a request through the system? Are trace IDs propagated correctly?
- **Error messages**: Are errors actionable? Do they help diagnose the problem or just say "something went wrong"?
- **Feature flags & kill switches**: Can this be disabled without a deploy if something goes wrong?
- **Graceful degradation**: What happens when dependencies are slow or unavailable? Does the system degrade gracefully or fail completely?
- **Timeouts & retries**: Are timeout values appropriate? Do retry policies risk amplifying failures?

**Frontend/Mobile considerations:**
- **Client-side error tracking**: Are errors captured and reported? Is there enough context to debug issues?
- **Analytics**: Are key user actions tracked? Can we measure feature adoption and user flows?
- **Performance monitoring**: Are slow renders, long tasks, or ANRs tracked?
- **Crash reporting**: Is crash reporting set up with meaningful stack traces and context?

---

## Layer 11: Code Hygiene

**This layer is for cleanup and polish. Smallest changes.**

Focus on:

- **Unused, stale, dead code**: Remove it. Don't comment it out, delete it.
- **Duplicated code**: Consolidate when the rule of three applies.
- **Reinvented existing code**: Actively search the codebase (use Grep) for existing functions, utilities, types, and helpers that already do what new code is doing. Check utility directories, shared modules, and files adjacent to the changed ones. Flag new functions that duplicate existing functionality, inline logic that could use an existing utility, and new types that are identical or near-identical to existing ones.
- **Messy or smelly code**: Code that makes the reader work harder than necessary. Readability matters — clear control flow, no clever tricks, self-documenting structure. Comments should explain "why", not "what".
- **Bug-prone patterns**: Patterns known to cause issues — stringly-typed data, boolean parameters, primitive obsession, deeply nested conditionals.
- **Naming**: Scrutinize every name — functions, variables, files, modules, types, database columns, API fields. Names should precisely describe what something is or does. Watch for names that drifted from behavior after changes, vague names (`data`, `handle`, `process`, `item`), names that are too broad or too narrow for what they represent, and inconsistent naming for the same concept across files.
