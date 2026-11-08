# Architecture forces

The named forces that make a codebase clean or messy. Every architecture-line agent judges by these names instead of by taste: the scout scores the current shape on them, the architect designs against them, the simplifier and the judge test candidates against them, the builder reads its result against them and the reviewer scores the slice against them. A finding that no force here names is taste, and taste is not a finding.

The one question, from `~/.agents/greenfield-convergence.md`: **what is the smallest set of concepts this system could have while still accurately modeling the domain?**

## Scorecard format

Wherever a sheet asks for a forces scorecard, write this markdown table, one row per force with a finding. Forces with nothing to report are listed once under the table as "no finding". Scripts read the Severity column, so keep the five columns and the exact severity words.

```text
| Force | Finding | Evidence (files, symbols, commits, incidents) | Cost (what it makes slow, risky or wrong) | Severity |
```

Severity is one of:

- `local`: fixable in one ordinary change without changing the model
- `structural`: the model itself must change; a local fix would add a special case
- `none`: checked, nothing to report

The structural rows are what a reset exists to fix. Every later phase refers back to them: the brief restates them as required properties, the target answers them, the slice plan names the rows each slice closes, the reviewer checks they are closed.

## Engineering concept count

The concepts a maintainer must hold to change the area: types, states, tables, jobs, modules with their own vocabulary. List them, then count. Files, lines and layers are evidence inside a force row, never a count of their own. A reviewer or judge recounts instead of trusting the author's number.

## Risk tiers

- **Tier A, protect now**: money movement, inventory and entitlements, authorization, privacy, permanent data loss, legal obligations, irreversible external side effects. The design protects the invariant or fails closed and keeps enough evidence to repair. Database constraints, transactions, idempotency keys and one authoritative write path usually suffice; automatic recovery is not required when a visible failure plus manual repair is safe.
- **Tier B, visible and recoverable**: reversible user-visible failures that do not corrupt important state. Detect and surface them; a bounded manual repair or admin retry is acceptable at low frequency.
- **Tier C, best effort**: convenience, analytics, cosmetic behavior, rare low-impact cases. Degrade, reject, defer or record.

Nothing is Tier A because an enterprise system would automate it.

## Edge-case treatments

Every material edge case gets exactly one: `AUTOMATE NOW` (common, costly or hard to repair), `FAIL CLOSED` (protect an invariant, require explicit recovery), `DETECT + MANUAL REPAIR` (rare, visible, safely recoverable), `BEST EFFORT` (low impact), `EXPLICITLY UNSUPPORTED` (reject clearly at the boundary), `DEFER` (outside the horizon, with an observable trigger and a one-paragraph upgrade path, never an implementation). Ledger columns:

```text
| Scenario | Evidence | Frequency in horizon | Impact | Detectability | Manual recoverability | Automation cost | Treatment | Revisit trigger |
```

## Topology rungs

0. local code inside an existing module
1. one coherent module with explicit ownership in the existing application
2. an internal asynchronous workflow on existing infrastructure
3. a new persistent runtime component or separately deployed service
4. distributed resilience, multiple stores or high-availability topology

Design starts at rung 0 or 1 and climbs one rung at a time; each climb names the lower-rung failure against a Tier A obligation or an approved requirement. No named failure, no climb.

## Appetite

The yardstick of the architecture line: the scout fixes it when the scope's spec has no `## Appetite` section (`project-conventions.md`), and every architect, simplifier, judge, builder and reviewer measures against it. Four parts: what must never happen; what may go wrong and be repaired by hand; what is not built; what may be used. Beneath them the engineering budget: decision horizon and scale envelope from measured numbers, never hypothetical growth; new runtime primitives (services, stores, queues, schedulers, vendors, protocols, background workflows) defaulting to zero; the existing primitives to prefer, named as capabilities (relational database and transactions, the job runner, object storage, email, logging), never as modules; the topology ceiling at rung 1, rung 2 allowed on existing infrastructure, rung 3 needing the founder; one observable trigger with a one-paragraph upgrade path per deferred concern. The standing bias, in the founder's words: a simpler system beats handled edge cases; rare failures that are visible and manually repairable are a legitimate design, not an incomplete one.

## Structure and boundaries

- **Cohesion**: how strongly related the responsibilities inside a module are. Low cohesion is the usual reason to split a service.
- **Coupling**: how much one component depends on knowledge of another's internals.
- **Encapsulation**: implementation details sit behind a controlled interface. The caller should not know how a thing is stored.
- **Information hiding**: callers know only what they need. A database concept used outside the repository is a leak.
- **Boundary**: a deliberate separation between domains or components.
- **Seam**: a place where behavior can be substituted without editing the caller.
- **Ownership**: which module is authoritative for a concept. "Who owns the refund state?" must have exactly one answer.
- **Single source of truth**: one canonical authority for each piece of state; a second copy is a future disagreement.

## Elegance and simplicity

- **Orthogonality**: two concepts can change independently. If a pricing change forces a change in checkout, the two are not orthogonal enough.
- **Composability**: small pieces combine into larger behavior without special cases; rule 2 of the greenfield doctrine (primitives, not features).
- **Locality**: the knowledge needed to understand or change something lives close together. "To understand one button I inspect six files" is a locality failure.
- **Symmetry**: similar operations have similar shapes (create and delete, subscribe and unsubscribe). A property of a design, never a reason to add an abstraction.
- **Uniformity**: similar concepts are represented the same way throughout.
- **Minimal surface area**: the smallest API that does the job.
- **Conceptual integrity**: the system reads as one coherent set of ideas, not hundreds of isolated decisions.

## Complexity

- **Essential complexity** is inherent in the problem; **accidental complexity** is created by the implementation. Multi-currency pricing is complicated; four representations of a price is accidental.
- **Cognitive load**: how much a developer must hold in their head to work here.
- **Indirection**: another layer between caller and behavior; sometimes needed, often pointless.
- **Abstraction tax**: every abstraction costs; spend only where it removes more complexity than it adds.
- **Ceremony**: code or process that exists to satisfy an architecture rather than to accomplish behavior.

## Abstractions

- **Leaky abstraction**: details escape through the abstraction.
- **Wrong abstraction**: worse than duplication; two things looked similar, were generalized, then diverged.
- **Premature abstraction**: generalizing before learning what varies.
- **Compression**: a good abstraction compresses many concrete cases into one understandable concept.
- The test for all four: is this actually the same concept, or do these merely look similar right now?

## Dependencies

- **Dependency direction**: domain code must not import the payment provider; outer layers depend on inner ones, never the reverse. The graph is acyclic.
- **Fan-in**: how many things depend on a module (fine). **Fan-out**: how many things it depends on; high fan-out means it knows too much.

## State and correctness

- **Invariant**: what must always be true. "What is the invariant?" `refundedAmount <= capturedAmount`. An invariant that only a comment states is not enforced.
- **Canonical representation**: one normalized form, established at the boundary (canonicalize phone numbers on input, not at every use).
- **Idempotence**, **atomicity**, **consistency**: an irreversible action runs once; a transition completes or does not happen; a reader never sees a half-state.
- **Monotonicity**: state moves in one direction and never needs undoing, which makes it far easier to reason about.

## Changeability

- **Blast radius**: how much can be affected by one change.
- **Change surface**: how many locations must change for one conceptual change. **Shotgun surgery**: tiny edits everywhere for one idea.
- **Temporal coupling**: operations must happen in a sequence that the types do not enforce (initialize, then load, then set user, then start).
- **Spatial coupling**: related logic scattered across the codebase; the other face of locality.
- **Rigidity**: the system resists changes that should be simple. **Fragility**: changing one area breaks another.

## APIs and models

- **Semantic clarity**: names and types communicate the idea.
- **Illegal states unrepresentable**: a `PaidOrder` necessarily has `paidAt`; the type, not a runtime check, rules out the impossible combination.
- **Primitive obsession**: strings and numbers everywhere instead of `OrderId`, `Money`, `EmailAddress`.

## Smells

Each smell is a named failure of a force above; report it under that force.

- **God object**: one module owns too many concepts (cohesion).
- **Feature envy**: a function works mostly on another module's data (ownership, locality).
- **Boolean blindness**: `createOrder(true, false, true)` (semantic clarity).
- **Stringly typed**: a domain value carried as a free string (primitive obsession).
- **Action at a distance**: a change here alters behavior there with no visible link (hidden coupling).
- **Hidden coupling**: two components must change together and nothing says so.

## The fifteen to internalize

Cohesion, coupling, locality, invariant, boundary, ownership, canonical representation, conceptual integrity, accidental complexity, indirection, blast radius, composability, orthogonality, leaky abstraction, dependency direction.
