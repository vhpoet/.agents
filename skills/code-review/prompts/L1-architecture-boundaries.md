You are reviewing code for Architecture & Boundaries concerns. Report findings only — do not edit code.

## Architecture & Boundaries

**This layer produces the most significant changes.**

This layer has two parts. First, evaluate the changes themselves for structural soundness. Then, zoom out to evaluate the architectural trajectory — where these changes are pushing the system, and whether that direction still makes sense.

### Part A: Structural Review

Take the bird's-eye view. Look at the system holistically — across changed and unchanged code. Identify architectural violations and places where the current implementation no longer fits the problem.

**Investigation** — build the structural map before judging:

1. Map the area: which modules does the diff touch, what is each one responsible for, who calls them, what do they depend on? Read enough of the unchanged neighbors to know the intended decomposition.
2. State the intended structure in one or two sentences — what separation of concerns this area is *supposed* to have. Then check where the actual code (old and new) violates it.
3. Ask the from-scratch question: if a staff engineer designed this area today, knowing current requirements, what structure would they choose? Diff that imagined structure against reality — the gaps are your candidate findings.

**What to probe**:

- **Separation of concerns**: Code that started with clean separation often drifts as features accumulate. Look for modules that accreted responsibilities over time. In domain-based systems, each domain should be responsible for its own concerns — check that code lives in the correct domain and cross-domain dependencies go through proper interfaces.
- **Mixed responsibilities**: Functions or modules doing multiple unrelated things. Data access interleaved with business logic. UI components making API calls or containing validation rules. Controllers doing transformation work that belongs in a service layer.
- **Scattered concerns**: Related logic spread across multiple files or layers when it should be co-located. The same concept implemented differently in different places.
- **Over-engineered abstractions**: Places where subtractive refactoring would beat additive fixes. Situations where removing code, collapsing layers, or realigning modules to current requirements would restore coherence.
- **Accidental complexity**: Complexity that wasn't chosen deliberately but crept in through incremental changes — layers that exist for historical reasons, indirection that no longer serves a purpose, coupling that emerged as a side effect of growth rather than design.
- **Structural opportunities**: This is where the Core Question applies most directly. What would be different if designed from scratch? Is there a simpler, more coherent structure hiding under the accretion?
- **File size and complexity**: Large files are a smell that triggers a concern-boundary check, not an automatic split. A file holding several distinct concerns should be split along those concepts; a long file that tells one cohesive story should stay whole — fragmenting it to hit a line count scatters the concern across files and makes every future reader chase it.
- **Simplicity**: Prefer the simplest solution that works. Avoid clever tricks. Code should be obvious and boring, not impressive. If there's a simpler way to achieve the same result, that's the right way.
- **Single points of failure**: Components where one failure cascades system-wide. No redundancy, no fallback, no graceful degradation path. Critical paths that funnel through a single service, queue, database, or in-memory structure with no recovery mechanism.
- **Cognitive load**: Could a new team member understand this area in a reasonable time? Are there implicit conventions, hidden dependencies, or tribal-knowledge requirements that make the code expensive to change? High cognitive load is a structural smell — it usually means responsibilities aren't well-separated or abstractions don't match the mental model.
- **Emergent consolidation**: Before these changes, the existing structure may have made sense. But now that new code exists, do patterns emerge that warrant consolidation? Does the combination of old and new code reveal opportunities for shared abstractions, unified interfaces, or merged modules that weren't justified before? The right abstraction often becomes clear only after you have multiple concrete implementations.


### Part B: Architectural Trajectory

After reviewing the structural soundness of the changes, zoom out one or two levels above the bird's-eye view. Use the changes as a central theme to read the direction the system is evolving in, then ask: **is the current architecture still the right foundation for where this system is heading?**

This is not about the changes being wrong. It's about recognizing inflection points — moments where incremental changes are collectively pushing the system toward a shape that would be better served by a different foundational approach. Each individual change may be perfectly reasonable, but the cumulative trajectory may reveal that the system has outgrown its original architecture.

How to evaluate trajectory:

1. **Read the direction**: What do these changes (and recent commits in the same area) tell you about how this part of the system is evolving? What new capabilities, patterns, or responsibilities are being added? What's growing in complexity?

2. **Project forward**: If this trajectory continues for 3-5 more iterations of similar changes, what does the system look like? Does the current architecture accommodate that gracefully, or does it start to buckle? Are we accumulating workarounds, special cases, or friction that signals a mismatch between the architecture and the problem it's solving?

3. **Test the alternative**: Question the fundamental assumptions the current architecture rests on — not just the shape, but the premises underneath it. If you were designing this area from scratch today — knowing the current requirements, the trajectory, and everything learned so far — would you choose the same architecture? If not, what would you choose instead? Be specific: name the pattern, the restructuring, or the different decomposition.

4. **Assess the gap**: How wide is the gap between the current path and the better path? Is it a minor adjustment (restructure a module, introduce an abstraction) or a fundamental rethink (different data model, different responsibility boundaries, different paradigm)? Is the cost of continuing on the current path accelerating?

**What to report**: Only raise trajectory concerns when there's a concrete, better alternative and the gap is wide enough to warrant action or at minimum awareness. State what the current trajectory is, where it leads, and what the alternative would be. Don't propose vague "we should rethink this" — name the specific architectural change and why the trajectory makes it worth considering now rather than later.

**What NOT to report**: Don't flag trajectories that are fine. Don't speculate about hypothetical future requirements that aren't implied by the actual changes. Don't propose rewrites for their own sake. The bar is: would a staff engineer, seeing these changes, say "we're heading toward a wall — we should course-correct now while it's cheap"?
