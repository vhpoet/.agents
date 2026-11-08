# Extract architecture brief: phase sheet

You are the sighted scout for an architecture reset. You map the subsystem as it is, score it on the architecture forces, fix the appetite when none exists, and write the brief that blind architects design from without being able to reconstruct today's shape. You redesign nothing, and you do not turn every current behavior or conceivable failure into a requirement.

Read `~/.agents/skills/clean-room-reset/references/architecture-forces.md` first (scorecard, concept count, risk tiers, edge-case treatments, topology rungs). Write into `docs/architecture-resets/<scope-slug>/`.

## 0. Sources of truth

The approved `TARGET_PRODUCT_BRIEF.md`, or the founder's statement that the product shape is settled, is the authority on behavior. If product behavior is materially uncertain, stop and report that the product line must run first. Current code, tests and incidents are evidence of what is, never the authority on what the target does or how much complexity the company should operate.

## 1. `CURRENT_ARCHITECTURE.md`

All current names allowed. Scope (entry points, flows, stores, jobs, APIs, screens; the adjacent systems left out; if state or invariants cross the requested boundary, show it and propose the smallest coherent one). Then the map: components and modules, call and event flows, dependency direction, data stores and ownership, interfaces, cross-cutting concerns, ordering, concurrency, idempotency and retry behavior actually present, transaction boundaries, failure modes and recovery, trust boundaries, measured latency and throughput where known, mixed-version constraints where real. Name the duplicated concepts, scattered behavior, speculative abstractions, runtime components whose cost exceeds their value, shotgun-surgery examples from recent history (one conceptual change, the files it touched), temporary structures that became permanent, test seams and observability gaps, and the places where the shape encodes a superseded product assumption.

Classify every material behavior as one of: approved target behavior; Tier A protection; temporary external compatibility; consistent with the target; intentionally changing or removed; accidental; suspected defect; unknown needing validation; edge case whose treatment the appetite decides. Tests are evidence of current behavior, not proof it belongs in the target.

End with the **forces scorecard** (score at least cohesion, coupling, ownership and single source of truth, locality, orthogonality, dependency direction and fan-out, invariants stated against enforced, accidental complexity, leaky, wrong or premature abstraction, temporal coupling, shotgun surgery, blast radius, monotonicity, representable illegal states, primitive obsession, god object, feature envy, action at a distance), the **edge-case ledger** (format in the forces file; a treatment of `FOUNDER DECISION REQUIRED` is allowed here and resolved before the brief), a **belief ledger** (`Belief | Evidence | Confidence | Consequence if wrong | How to verify`, for scale, frequency, failure cost and likely change; no enterprise defaults in the gaps), and a line `Concepts: <n>` with the numbered list behind it.

When the conductor said **assess**, stop here and report the structural rows and the count.

## 2. `ARCHITECTURE_APPETITE.md`, when the scope's spec has no appetite

Write the appetite for this scope in the format the forces file defines ("Appetite"): the four parts, then the engineering budget beneath them, every number measured. Header `Status: DRAFT: FOUNDER APPROVAL REQUIRED`; the conductor handles approval (SKILL.md, "Founder gates").

## 3. `CLEAN_ROOM_BRIEF.md`

The only problem statement the blind architect sees, beside the appetite and the forces file. It states required properties, never a preferred solution: the product problem and purpose; actors and use cases; approved behavior with examples; horizon and scale envelope; team and operational reality (a small, very efficient team; no recurring manual labour; human review is scarce); allowed primitives as capabilities; public contracts and external dependencies; domain state and Tier A invariants; data semantics and lifecycle; edge cases with their decided treatments, required failure behavior only for `AUTOMATE NOW` and `FAIL CLOSED`; security and privacy; expected changes ranked by probability inside the horizon; rearchitecture triggers; non-goals and unsupported behavior; negotiable decisions; open questions; and the acceptance criteria: the scorecard's `structural` rows restated as properties of the target without naming current code ("one owner for the refund state", "adding a source changes one place").

House conventions are constraints, not leakage: the project's naming and migration rules from its instructions, the Naming table any proposed schema or module name must come with, and the layering rules of the global best-practices docs for the project's stack (`~/.agents/`).

Out: file paths, class, function, package, table, queue or job names, the current layers or dependency graph, pattern names, "replace X with Y", proposed modules, complaints phrased in terms of today's code, superseded product behavior as a permanent requirement, current automatic handling where the appetite allows a simpler treatment. Not "the ImportManager has too many branches" but "adding an approved import source inside the horizon changes nothing source-specific elsewhere; one more source is expected". Not "recover every partially delivered batch automatically" but "duplicate irreversible sends are prevented; a rare provider interruption may leave a batch paused and visible for manual resume". No "scalable", "resilient", "future-proof", "handle all edge cases": measured envelopes, concrete guarantees, explicit deferrals.

## 4. Audit, before finishing

Grep the brief for current internal names. Every generic scale or resilience requirement has become a treatment. Every automatic mechanism the brief asks for protects a Tier A obligation or a measured, frequent Tier B case. An architect can satisfy it without inventing enterprise scale, and no irreversible high-impact risk was waved away for simplicity.

## Completion response

Scope, sources of truth used, files written, the structural rows one line each, the concept count, the edge cases awaiting the founder, current mechanisms that exceed the appetite, the highest-impact unknowns, and whether the leakage and right-sizing audits passed. No target.
