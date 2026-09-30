# Greenfield Convergence — architecture doctrine (all projects)

**Status:** adopted 2026-09-11 by the founder; applies to every project, not one codebase.
**Sources:** Meir Lehman, *Laws of Software Evolution*, law II "increasing complexity"; John Ousterhout, *A Philosophy of Software Design* (strategic programming, deep modules, "design it twice", "complexity is incremental"); Daniel Jackson, *The Essence of Software* (concept design); Martin Fowler, *Refactoring* (preparatory refactoring) and the strangler-fig migration; Kent Beck, "make the change easy, then make the easy change"; Werner Vogels, "primitives, not frameworks"; Frederick Brooks, *The Mythical Man-Month* (second-system effect).

## The law

**Every change leaves the architecture where a fresh team would have put it.** Not adapted to fit, not kept compatible. If the codebase after a change does not read as if it had been designed knowing that requirement from day one, the change is not finished.

Why now: retrofitting was rational when a refactor cost weeks and a bug-hunt. LLM-assisted refactors are cheap and the test suite catches regressions, so the only cost left is the one retrofits create: complexity that compounds until nothing can be changed safely. We pay the cheap cost on every change instead of the compounding one later.

## Trigger

Any change that adds a **concept** (a noun users or maintainers must learn), a **state** a record can be in, a **table or column family**, or a **special case** in a shared path.

## Rule 1 — Design the greenfield model, then converge to it

Ask: *knowing everything we know now, including this request and the next five like it, what would the model be if this system were written from scratch today?* Design that. Then migrate the whole codebase to it and delete the old shape in the same work. No compatibility layers, no legacy paths, no flag keeping both behaviours alive, no v2 beside v1.

- Ousterhout, **strategic programming**: the fastest working patch is tactical; investing in the design on every change is strategic. **Design it twice**: at least two candidate models before choosing.
- Fowler, **preparatory refactoring**; Beck, **make the change easy, then make the easy change**: reshaping the code to receive the feature is part of the feature.
- Fowler, **strangler fig**: when one slice cannot carry the migration, the new model grows around the old until the old is deleted. Coexistence has an owner, a removal condition and the slice that removes it. It is never permanent.
- A contract held by installed clients, stored data or an external party (mobile runtime versions and OTA updates, persisted QR, wallet and URL formats, partner APIs, column drops) retires through a labelled transition with a removal trigger, such as a minimum supported runtime or a second deploy for a column drop; this is the strangler clause applied, not an exception to the law.

## Rule 2 — Primitives, not features

Meet new needs by composing a few deep, orthogonal concepts with different parameters, never by an `if` in a service or a per-customer switch. Generality comes from fewer, deeper concepts, not from more options. If a request cannot be expressed as a composition of existing primitives, the primitive set is wrong; fix the set.

- Jackson, **concept design**: software is a composition of independent, single-purpose concepts, each understandable alone and reusable across products. Count concepts, not lines.
- Vogels, **primitives, not frameworks**: ship small general building blocks; a framework that anticipates use cases bets on the wrong future.
- Ousterhout, **deep modules**: small interface, a lot behind it. Many shallow modules with wide interfaces are complexity dressed as modularity.

## Rule 3 — The appetite governs

Greenfield thinking invites Brooks's **second-system effect**: designing for everything you might need. The target is the minimum sufficient set of primitives for the known and next-likely cases. Deferred concerns get an observable trigger and a paragraph of upgrade path, never an implementation. Every change reports its **concept-count delta** (added / changed / deleted); removal is shipped work.

- Lehman, **law of increasing complexity**: complexity grows unless work is done to reduce it. Here that work is part of every change, not maintenance.
- Ousterhout, **complexity is incremental**: no single special case seems worth refusing, so the refusal is a standing rule, not a judgment call each time.

## What it forbids

- A `kind`, `mode`, or state flag added so an existing path can branch for one customer.
- A second way of doing something the system already does, kept because the first is in use.
- "compat", "legacy", "formerly", "shim", "temporary" in a name, unless the structure is registered with an owner, a removal condition and the removing slice.
- A spec that introduces a concept without stating the greenfield model it belongs to and what it deletes.
- Speculative generality: a parameter, table or abstraction with no known case behind it.

## How a session applies it

1. On a triggering change, state the greenfield model in a paragraph before writing code: the primitives and their composition.
2. If the model differs from what exists, the work is the convergence, not the patch.
3. Report the concept-count delta in the spec and the final summary.
4. Before declaring done, sweep for leftovers of the superseded shape: names, types, routes, tests, docs, i18n keys, telemetry names. Rewrite or delete.
5. When the appetite defers a case, write its trigger and upgrade path, nothing else.

A project may keep its own adoption record (how the doctrine fits that project's other doctrines and skills); the law and rules live here.
