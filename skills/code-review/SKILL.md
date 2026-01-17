---
name: code-review
description: Entropy-reducing code review. Diff-anchored but context-aware. Favors deletion, consolidation, and simplification over additive fixes.
---

## Bird's-Eye View

You know how it goes. We build something and then we keep adding stuff to it. Little changes here and there, little bug fixes, features evolve, requirements shift, and we just keep iterating forward. Over time, correctness gets harder to reason about, boundaries blur, data flow becomes implicit, and small shortcuts compound. When you look back, if you were starting from scratch with what you know now, you would not design it this way. There is usually a simpler, more elegant, more coherent approach that got obscured by additive change.

What we need is to take a real step back, a true bird's-eye view of the whole system. Look at it holistically, across changed and unchanged code, and identify places where the current implementation no longer fits the problem. Places where separation of concerns or encapsulation broke down, where modules accreted responsibilities, where control flow became convoluted, where data integrity relies on assumptions instead of guarantees. Not just what we touched this time, but anything that, knowing what we know now, should be reshaped, collapsed, or removed if we had full freedom to refactor or start from scratch.

## Goal

The goal of this review is to actively reduce system entropy. Favor changes that make the system simpler to reason about over time, with clearer boundaries, more explicit data flow, fewer implicit assumptions, and fewer moving parts. Prefer deletion, consolidation, and realignment to current reality over additive fixes that increase complexity.

## Scope

Focus primarily on the changes since the last commit and the specific feature domains those changes touch or introduce. Use the diff as the entry point and center of gravity for the review. Reason outward only as needed to evaluate the correctness, design, and long-term fit of those changes, or when they clearly imply broader refactors elsewhere in the system. The diff and its affected domains are the anchor, not a hard boundary.

## Challenge Assumptions

In addition to reviewing correctness and design, explicitly challenge assumptions embedded in the diff and surrounding code. If the changes lean on paths, patterns, abstractions, frameworks, or architectural choices that are no longer a good fit, call that out and propose a clearly better alternative when one exists. Only raise challenges with a concrete payoff such as reduced complexity, stronger guarantees, or elimination of systemic risk, and tie them directly to the diff or its implications.

## Review Approach

Think like a world-class staff or principal engineer with a good intuition for what needs to be done when reviewing uncommitted changes in context of the entire codebase. Be diff-aware, but not diff-blind. Identify logic defects, architectural violations, broken or implicit data flow, unsafe edge cases, and systemic risks. Consider failure modes, idempotency, transactions, resource lifetimes, cancellation and context propagation. Look at data access and persistence critically: migrations, backward compatibility, uniqueness guarantees, pagination, buffering versus streaming.

## Separation of Concerns and Encapsulation

Pay close attention to boundaries. Code that started with clean separation often drifts as features accumulate. Look for:

- **Mixed responsibilities**: Functions or modules doing multiple unrelated things. Data access interleaved with business logic. UI components making API calls or containing validation rules. Controllers doing transformation work that belongs in a service layer.
- **Leaky abstractions**: Internal details exposed through public interfaces. Other modules reaching into internals instead of using defined contracts. State that can be mutated from outside its owning module.
- **Scattered concerns**: Related logic spread across multiple files or layers when it should be co-located. The same concept implemented differently in different places.
- **Implicit coupling**: Modules that depend on each other's internal structure rather than explicit interfaces. Changes in one place that unexpectedly break something elsewhere.

When concerns are properly separated, each piece can be understood, tested, and changed in isolation. When encapsulation is intact, you can refactor internals without breaking callers. Violations of these principles are often the root cause of code that's hard to reason about and fragile to change.

## Everything Is In Scope

Everything is in scope. Unused, stale, dead, or duplicated code. Messy or smelly code. Bug-prone paths. Over-engineered abstractions. Places where subtractive refactoring would beat additive fixes. Situations where removing code, collapsing layers, or realigning modules to current requirements would restore coherence.
