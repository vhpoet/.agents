---
name: code-review
description: Entropy-reducing code review. Diff-anchored but context-aware. Favors deletion, consolidation, and simplification over additive fixes.
---

## The Core Question

Before diving into specifics, ground yourself in this question:

**If a staff or principal engineer was designing this from scratch, knowing everything they know now—the problem, the constraints, the domain—is this how they would build it?**

This is not about nitpicking implementation details. It's about recognizing when the current solution has drifted from what a thoughtful, experienced engineer would choose if they had a blank slate. Maybe the approach made sense initially but no longer fits. Maybe complexity crept in through incremental changes. Maybe there's a fundamentally simpler design hiding under the accretion.

When reviewing, hold this question in mind at every layer. The goal isn't to find fault—it's to surface places where the gap between "what we have" and "what we'd build from scratch" is wide enough to warrant action.

---

## Layered Review Process

This review proceeds in layers, from highest structural impact to smallest refinements. Each layer focuses on a specific concern and produces targeted feedback before moving to the next.

**When starting a review:**
1. Start at Layer 1 unless the user explicitly requests a different layer
2. Review only the current layer—do not mix in findings from other layers
3. List all findings for the current layer
4. Fix what needs fixing for that layer (or propose fixes if you can't change code); in Layer 6, add the missing tests you identify
5. Only after the current layer is fully addressed, move to the next layer
6. Continue layer-by-layer without pausing for "next layer" prompts unless the user asks to stop or focus

### The Layers

| Layer | Name | Focus | Impact |
|-------|------|-------|--------|
| 1 | **Architecture & Boundaries** | System structure, separation of concerns, module responsibilities | Highest - major restructuring |
| 2 | **Data Flow & Contracts** | Encapsulation, coupling, interface boundaries | High - changes across modules |
| 3 | **Testability** | Test seams, dependency injection, isolation | High - structural for testing |
| 4 | **Security & Trust Boundaries** | Auth, input sanitization, trust boundaries, secrets | Medium-high - security implementation |
| 5 | **Correctness & Safety** | Logic, edge cases, data integrity, transactions, resources, migrations | Medium - targeted fixes |
| 6 | **Test Coverage** | Missing tests, edge cases, error paths, test quality | Medium - test additions |
| 7 | **Performance & Efficiency** | Hot paths, complexity, N+1 queries, pagination, buffering, cost | Medium - optimization |
| 8 | **Observability & Operability** | Logging, metrics, tracing, graceful degradation | Low-medium - instrumentation |
| 9 | **Code Hygiene** | Dead code, duplication, naming, clarity | Low - cleanup and polish |

---

## Bird's-Eye View

To answer the Core Question honestly, you have to step back. Look at the system holistically—across changed and unchanged code—and identify where the current implementation no longer fits the problem. Where separation of concerns broke down. Where modules accreted responsibilities. Where control flow became convoluted. Where data integrity relies on assumptions instead of guarantees.

This matters because systems drift. Small changes compound. Requirements shift. What started clean gets patched and extended until there's a simpler design hiding underneath the accretion. Not just what we touched this time, but anything that should be reshaped, collapsed, or removed if we had full freedom to refactor.

## Goal

The goal of this review is to actively reduce system entropy. Favor changes that make the system simpler to reason about over time, with clearer boundaries, more explicit data flow, fewer implicit assumptions, and fewer moving parts. Prefer deletion, consolidation, and realignment to current reality over additive fixes that increase complexity.

## Scope

Focus primarily on the changes since the last commit and the specific feature domains those changes touch or introduce. Use the diff as the entry point and center of gravity for the review. Reason outward only as needed to evaluate the correctness, design, and long-term fit of those changes, or when they clearly imply broader refactors elsewhere in the system. The diff and its affected domains are the anchor, not a hard boundary.

## Challenge Assumptions

In addition to reviewing correctness and design, explicitly challenge assumptions embedded in the diff and surrounding code. If the changes lean on paths, patterns, abstractions, frameworks, or architectural choices that are no longer a good fit, call that out and propose a clearly better alternative when one exists. Only raise challenges with a concrete payoff such as reduced complexity, stronger guarantees, or elimination of systemic risk, and tie them directly to the diff or its implications.

## Review Approach

Keep the Core Question front and center: would an experienced engineer design it this way from scratch? Be diff-aware, but not diff-blind. The diff is your entry point, but reason outward to evaluate fit within the broader system. The current layer determines what to focus on, but always maintain awareness of the whole.

---

## Layer 1: Architecture & Boundaries

**This layer produces the most significant changes.**

This layer has two parts. First, evaluate the changes themselves for structural soundness. Then, zoom out to evaluate the architectural trajectory — where these changes are pushing the system, and whether that direction still makes sense.

### Part A: Structural Review

Take the bird's-eye view. Look at the system holistically, across changed and unchanged code. Identify architectural violations and places where the current implementation no longer fits the problem.

Focus on:

- **Separation of concerns**: Code that started with clean separation often drifts as features accumulate. Look for modules that accreted responsibilities over time. In domain-based systems, each domain should be responsible for its own concerns—check that code lives in the correct domain and cross-domain dependencies go through proper interfaces.
- **Mixed responsibilities**: Functions or modules doing multiple unrelated things. Data access interleaved with business logic. UI components making API calls or containing validation rules. Controllers doing transformation work that belongs in a service layer.
- **Scattered concerns**: Related logic spread across multiple files or layers when it should be co-located. The same concept implemented differently in different places.
- **Over-engineered abstractions**: Places where subtractive refactoring would beat additive fixes. Situations where removing code, collapsing layers, or realigning modules to current requirements would restore coherence.
- **Structural opportunities**: This is where the Core Question applies most directly. What would be different if designed from scratch? Is there a simpler, more coherent structure hiding under the accretion?
- **File size and complexity**: Are files growing too large? Files that exceed a few hundred lines or handle too many responsibilities should be broken down. Large files are a structural smell—they often indicate mixed concerns or missing abstractions.
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

---

## Layer 3: Testability

**This layer ensures the code can be verified and maintained with confidence.**

Untestable code often signals structural problems. If you can't test something in isolation, it's usually too tightly coupled. Testability issues caught here often require restructuring—better to address now than after tests are written around a bad design.

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

Security issues often require structural changes—adding middleware, restructuring data flow, or introducing new validation layers. Catching these early prevents expensive rework.

Focus on:

- **Authentication & authorization**: Are auth checks at the right points? Can users access only what they should? Are there missing permission checks on new endpoints or operations?
- **Trust boundaries**: What data comes from users vs internal systems? Is external input treated as untrusted? Are there assumptions about data integrity that could be violated?
- **Input sanitization**: Beyond validation, is input sanitized appropriately? SQL injection, command injection, XSS, path traversal vulnerabilities.
- **Secrets handling**: Are secrets hardcoded? Properly scoped? Logged accidentally? Exposed in error messages or stack traces?
- **Audit logging**: Are sensitive operations logged for security auditing? Can we reconstruct what happened if something goes wrong?
- **Rate limiting & abuse prevention**: Can this be abused at scale? Are there missing rate limits on expensive operations?

---

## Layer 5: Correctness & Safety

**This layer focuses on bugs, edge cases, data integrity, and resource management.**

This includes algorithmic correctness, data correctness, and resource safety. Transaction semantics, migrations, and resource lifetimes are correctness concerns—bugs in these areas cause real failures.

Focus on:

- **Logic defects**: Incorrect behavior, wrong conditions, off-by-one errors, race conditions.
- **Unsafe edge cases**: Input validation gaps, null/undefined handling, boundary conditions.
- **Data integrity**: Are constraints enforced at the right level? Can invalid states be represented? Are there race conditions in uniqueness checks?
- **Transactions**: Are related operations atomic when they need to be? Can partial failures leave inconsistent state?
- **Migrations**: Schema changes, data transformations, rollback safety. Will existing data work with new code?
- **Backward compatibility**: Will new data work if code is rolled back? Are there breaking changes to stored data?
- **Resource lifetimes**: Connections, file handles, subscriptions—properly acquired and released? Memory leaks?
- **Cancellation and context propagation**: Long-running operations respect cancellation? Context passed correctly?
- **Systemic risks**: Places where data integrity relies on assumptions instead of guarantees. Implicit ordering dependencies. States that "should never happen" but aren't enforced.
- **Failure modes**: What happens when things go wrong? Are errors handled appropriately? Do failures cascade or stay contained?
- **Idempotency**: Can operations be safely retried? Are there unintended side effects on repeat?

**Frontend/Mobile considerations:**
- **Client-side state consistency**: Can the UI get into inconsistent states? Are there race conditions between user actions and async responses?
- **Optimistic updates**: If using optimistic UI, is rollback handled correctly on failure?
- **Stale data**: Can users act on stale data? Is cache invalidation handled properly?

---

## Layer 6: Test Coverage

**This layer identifies missing tests and proposes additions.**

If you can change code, add the missing tests in this layer rather than deferring them. If you cannot modify code, propose the tests explicitly.

Now that we've verified the code is correct (Layer 5), identify what tests should exist to maintain that correctness going forward. Unlike Layer 3 (Testability) which focuses on code structure, this layer is about actual test cases.

Focus on:

- **Missing unit tests**: Core business logic that lacks test coverage. Functions with complex conditions or branching.
- **Missing integration tests**: Interactions between components, API endpoints, database operations that aren't tested together.
- **Edge cases**: Boundary conditions, empty inputs, maximum values, error states that should be tested but aren't.
- **Error paths**: Exception handling, failure scenarios, timeout behavior—often untested.
- **Happy path gaps**: Core user flows that should have end-to-end coverage.
- **Regression risks**: Bug fixes or complex changes that should have tests to prevent recurrence.
- **Test quality**: Existing tests that are brittle, test implementation details, or don't actually verify behavior.

**Output**:
- If you can change code, add the missing tests and summarize what you added (files + scenarios).
- If you cannot modify code, list the gaps. For each gap, note:
  - Which file/function/component needs coverage
  - What kind of test (unit, integration, E2E)
  - Priority (critical, important, nice-to-have)
  - Brief description of what should be tested

---

## Layer 7: Performance & Efficiency

**This layer identifies performance problems and unnecessary cost.**

Performance issues range from algorithmic complexity to infrastructure cost. Some require architectural changes (high impact), others are localized fixes (medium impact). Catch them before they reach production.

Focus on:

- **Algorithmic complexity**: Is this accidentally O(n²) or worse? Are there nested loops over large datasets?
- **Hot paths**: What code runs most frequently? Is it optimized appropriately?
- **N+1 queries**: Database access patterns that make one query per item instead of batching.
- **Pagination**: Large result sets handled correctly? Cursor vs offset pagination appropriateness?
- **Buffering versus streaming**: Memory implications, backpressure handling. Are large payloads loaded entirely into memory?
- **Payload sizes**: Are API responses or database fetches pulling more data than needed? Overfetching?
- **Memory usage**: Large objects held unnecessarily, unbounded growth, missing cleanup.
- **Mobile & client performance**: If applicable—bundle sizes, render performance, unnecessary re-renders.
- **Infrastructure cost**: Operations that scale poorly with usage. Expensive calls in loops. Missing caching where it would help.

**Frontend/Mobile considerations:**
- **Rendering performance**: Are there unnecessary re-renders? Are expensive computations memoized? Are lists virtualized when needed?
- **Bundle size**: Are imports optimized? Is code splitting and lazy loading used where appropriate?
- **Network efficiency**: Are requests batched or deduplicated? Is data overfetched? Is caching used effectively?
- **Offline & network resilience**: Does the app handle poor connectivity gracefully? Are there appropriate loading and error states?
- **Mobile-specific**: Battery impact? Memory usage on constrained devices? Respects system settings (low power mode, data saver)?

---

## Layer 8: Observability & Operability

**This layer ensures the code can be understood and operated in production.**

Production code needs instrumentation. When something goes wrong at 3am, can the on-call engineer understand what happened? While mostly additive, some observability decisions affect correctness semantics—timeouts, retries, and error classification have behavioral implications.

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

## Layer 9: Code Hygiene

**This layer is for cleanup and polish. Smallest changes.**

Focus on:

- **Unused, stale, dead code**: Remove it. Don't comment it out, delete it.
- **Duplicated code**: Consolidate when the rule of three applies.
- **Messy or smelly code**: Code that makes the reader work harder than necessary. Readability matters—clear control flow, no clever tricks, self-documenting structure. Comments should explain "why", not "what".
- **Bug-prone patterns**: Patterns known to cause issues—stringly-typed data, boolean parameters, primitive obsession, deeply nested conditionals.
- **Naming and clarity**: Names that don't match behavior, unclear intent, missing context.

---

## Knowing When to Stop

**"No issues found" is a valid output.** Not every layer will have problems. Good code exists. If a layer is clean, say so and move on.

Do not:
- Invent issues to appear thorough
- Nitpick style preferences when the code is sound
- Suggest "improvements" that don't address real problems
- Pad output with minor observations to seem useful

Do:
- State clearly: "**Layer N: No issues found.**" when appropriate
- Trust that clean layers build confidence in the review's credibility
- Reserve feedback for genuine concerns that warrant attention
- Distinguish between "this could be different" and "this should be different"

A review that finds nothing wrong has done its job. The goal is accuracy, not volume.

---

## Conducting the Review

1. **Start by asking**: "Which layer would you like to start at? (0-9, default: 0)"
2. **State the layer**: Begin each review section with "**Reviewing Layer N: [Name]**"
3. **Stay focused**: Report only findings relevant to the current layer. All concerns are discoverable across the full review, but each layer reports only its concern class.
4. **Report honestly**: If the layer is clean, say "No issues found" and move on. Do not manufacture feedback.
5. **Flow control**:
   - If issues found → wait for user to say "next layer" or specify a layer number before proceeding
   - If no issues found → immediately proceed to the next layer (no waiting)
6. **Track progress**: Note which layers have been completed
7. **Update spec checkboxes**: When the user confirms a layer is complete (e.g., "looks good", "approved", "next layer"), mark the corresponding checkbox in the spec's "Code Review" section (change `- [ ]` to `- [x]`)

Remember: The diff and its affected domains are the anchor, not a hard boundary. Reason outward only as needed to evaluate the correctness, design, and long-term fit of those changes.
