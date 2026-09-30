# Code written by agents — review card (all projects)

**Status:** adopted 2026-09-29 by the founder. Source: the deep-research result in esora `docs/engineering/2026-09-29-engineering-code-written-for-frontier-llm-agents-research.md`. This card is what a session applies to the next file; the research is the reasoning.

**The question every change answers:** what must remain true, where can a fresh agent discover it, and what outside this session's interpretation will object when it stops being true? Write code so the next agent can recover the meaning, make a bounded decision, and meet an independent objection when it is wrong. Never optimize for making code easy to generate.

## The card

- **Meaning.** Name the actual domain operation. Keep requested, confirmed, rejected and unknown as separate states; a requested refund is not a completed refund, a timeout is not a decline, an extracted date is not a confirmed date, a ticket that exists is not an entitlement to enter. One field never carries two authorities or lifecycles.
- **Types.** Spend the type budget on expensive confusions and closed internal alternatives (discriminated unions, distinct types for amounts that must not mix). Parse runtime inputs at real trust boundaries with schemas. Keep unsafe assertions at explicit boundaries. Never use types to imply concurrency, authorization or external facts they cannot prove.
- **Shape.** Keep the consequential workflow readable in one place; a 500-line cohesive flow beats fifty fragments. Isolate a pure decision when that makes it independently testable. Extract helpers for meaning or reuse, never for a line count. No speculative frameworks, no ambient side effects, no hidden authority.
- **Failure.** Failure is domain vocabulary, not a catch-all. A fallback that turns corruption into empty data or zero money is concealment; unexpected faults stay observable. "Unknown" (provider accepted, response lost) is a durable state with a reconciliation path, never an assumption either way.
- **Authority.** Non-obvious behaviour links to its rule, historical artifact or external contract. The nearest existing code is not an approved pattern; copy approved exemplars, and mark legacy exceptions so they are not copied.
- **Comments.** Explain the surprising constraint, the external obligation, the historical reason. Never narrate what the syntax says. Remove misleading and redundant comments; keep the intent.
- **Data.** Preserve financial and historical facts; store obligations, not optimistic stories. Transaction ownership is explicit. The database rejects impossible durable states where it can (constraints, not conventions). Timeouts and retries follow the provider's actual semantics.
- **Compatibility.** Old mobile builds, queued job payloads, stored JSON, issued QR bytes and requests already accepted by a provider are part of the specification. Current shared types prove nothing about deployed software.
- **Tests.** Tests are readable specifications with independently justified expected values, never derived from the implementation under test. Assert forbidden effects, duplicates, concurrency against a real database, failure boundaries and relevant old formats. Mock external transport to control conditions; never replace PostgreSQL with an object map.
- **Evidence.** Run the required checks on the exact candidate state and report unexecuted checks as unexecuted. A persuasive explanation is not an executed check. Weakening, skipping or re-expecting a test is a change to the definition of success and is stated as such.
- **Scope.** Reproduce a bug before repairing it. Treat a reported issue and a reviewer's finding as hypotheses that need an executable witness or a precise violated rule. No-change is a valid outcome. Do not expand "improve this" into abstractions and unrelated repairs.
- **Maintenance.** Leave a searchable source of truth, not a diary. Delete dead abstractions and superseded guidance; generation is cheap, so retaining an abstraction must lower the cost of the next change.

## The failures this defends against

Locally reasonable code that compiles, resembles nearby code, passes the tests it ran, and violates a fact outside the session's interpretation. Named classes: semantic substitution (`paid`, `active`, `available` meaning several things); incomplete impact discovery (a field also read by an old app, a job payload, an export); wrong inference from precedent; common-mode error (code and tests encode the same misunderstanding); false certainty about effects; missing temporal reasoning (races, restarts, late webhooks); unjustified work expansion; false issue acceptance; review feedback amplification between agents; evaluator modification; version-prior error (a pattern from another Next.js or Expo version); plausible concealment.

## What gains and loses value when the author is a model

Gains: explicit domain modelling, database constraints and transactional discipline, executable examples and characterization tests, reproducible environments, small public surfaces, a regression counterexample after every incident, deletion. Loses or harms when ritualized: documenting what syntax already says, mock-heavy isolation, universal micro-abstraction, speculative generality, textual DRY that erases real differences between wire versions or providers, coverage targets without fault sensitivity, walls of "always" and "never" instructions.
