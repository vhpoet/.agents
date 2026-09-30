---
name: spec-review
description: Layered spec review before implementation. Catches architectural issues, missing concerns, and ambiguity before code is written. Pairs with the spec-lifecycle and code-review skills.
---

## Layered Review Process

This review proceeds in layers, starting with product concerns and moving to engineering. Each layer focuses on a specific concern and produces targeted feedback before moving to the next.

**When starting a review:**
1. Ask the user which layer to start at (default: Layer 1)
2. Complete that layer's review
3. Wait for user to say "next layer" or specify a layer number before proceeding

### The Layers

**Product Review (Layers 1-5)**

| Layer | Name | Focus |
|-------|------|-------|
| 1 | **Problem & Intent** | Is this solving the right problem? Are goals clear? |
| 2 | **User Value** | Is this valuable to users? Why would they care? |
| 3 | **User Experience** | Is the UX sound? Is it intuitive? |
| 4 | **Product Strategy** | How does this fit the product? Positioning? Differentiation? |
| 5 | **Growth & Adoption** | How will users discover and adopt this? |

**Engineering Review (Layers 6-12)**

| Layer | Name | Focus |
|-------|------|-------|
| 6 | **Scope & Boundaries** | Non-goals, constraints, what's excluded |
| 7 | **Architecture & Domains** | Where does functionality live? Domain ownership? |
| 8 | **Data Flow** | How data moves, component interactions |
| 9 | **Security & Trust** | Trust boundaries, auth, validation |
| 10 | **Testability & Observability** | Testing strategy, monitoring, debugging |
| 11 | **Performance & Scale** | Bottlenecks, pagination, caching |
| 12 | **Risks & Rollout** | What could go wrong? Phases, rollback? |

---

## Goal

Catch issues before code is written. A spec review is cheaper than a code review — product mistakes and architectural mistakes found in a spec cost minutes to fix; the same mistakes found in code cost hours or days.

The goal is to ensure the spec is valuable, clear, complete, and sound enough that implementation can proceed without major surprises.

---

# Product Review

---

## Layer 1: Problem & Intent

**This layer ensures we're solving the right problem.**

The most expensive mistake is building the wrong thing. Before evaluating the solution, evaluate the problem.

Focus on:

- **Problem clarity**: Is the problem clearly stated? Would two people reading this understand the same problem?
- **Problem validity**: Is this actually a problem worth solving? Is there evidence (research, user feedback, data)?
- **Goals alignment**: Do the stated goals actually solve the problem? Are there goals that don't connect to the problem?
- **Success criteria**: How will we know this worked? Are success criteria measurable?
- **Drift detection**: Has the solution drifted from the original problem? Are we solving adjacent problems that weren't asked for?

---

## Layer 2: User Value

**This layer ensures users will actually care.**

Features that don't deliver clear user value are wasted effort, no matter how well they're built.

Focus on:

- **Value proposition**: Why would a user want this? What's in it for them?
- **Pain relief**: What pain does this remove? What friction does it eliminate?
- **Benefit clarity**: Are the benefits concrete and tangible, or vague and abstract?
- **User priority**: Is this something users have asked for or demonstrated need for?
- **Alternatives**: What do users do today without this? Is the improvement meaningful?
- **Value vs effort**: Is the value proportional to the effort? Are we gold-plating something users barely need?

---

## Layer 3: User Experience

**This layer ensures the UX is sound before we build it.**

A confusing or frustrating UX will fail regardless of the underlying implementation.

Focus on:

- **Intuitiveness**: Will users understand how to use this? Is it self-explanatory?
- **Flow**: Is the user flow logical? Are there unnecessary steps or dead ends?
- **Discoverability**: Will users find this feature? Is it buried or prominent?
- **Consistency**: Does this match existing UX patterns in the product? Will it feel familiar?
- **Edge cases**: What happens in error states? Empty states? Unusual inputs?
- **Accessibility**: Are there accessibility considerations? Different devices, abilities, contexts?

---

## Layer 4: Product Strategy

**This layer ensures this fits the product vision.**

A feature can be valuable on its own but wrong for the product.

Focus on:

- **Strategic fit**: How does this advance the product strategy? Does it align with where the product is heading?
- **Positioning**: How does this position us relative to competitors? Does it differentiate or commoditize?
- **Coherence**: Does this make the product more coherent or more fragmented?
- **Prioritization**: Why this, why now? What's not getting built because we're building this?
- **Dependencies**: Does this create dependencies or unlock future capabilities?
- **Reversibility**: If this doesn't work, can we remove it? Or are we committed?

---

## Layer 5: Growth & Adoption

**This layer ensures users will actually discover and adopt this.**

A great feature that nobody uses is not a great feature.

Focus on:

- **Discovery**: How will users learn this exists? In-product, marketing, word of mouth?
- **Activation**: What does first-time usage look like? Is there friction to getting started?
- **Adoption path**: How do users go from trying it once to using it regularly?
- **Retention impact**: Does this improve retention? Does it give users a reason to come back?
- **Virality potential**: Does this encourage users to invite others or share?
- **Measurement**: How will we measure adoption? What metrics will we track?

---

# Engineering Review

---

## Layer 6: Scope & Boundaries

**This layer prevents scope creep and clarifies what we're NOT doing.**

Clear non-goals are as important as clear goals. Ambiguous scope leads to unbounded implementation.

Focus on:

- **Appetite stated?**: Does the spec have an `## Appetite` section — what must never happen (prevented by design), what may go wrong and be repaired by hand from an admin list, what isn't being built, and what may be used? **If it doesn't, that is the review's first finding**, and every scope and architecture judgement below stays provisional until the founder confirms one.
- **Non-goals**: Are non-goals explicitly stated? Is it clear what's out of scope?
- **Constraints are facts, not mechanisms**: "Constraints (fixed)" may hold only facts — contract terms, bank/rail behavior, legal requirements, data volumes, frozen wire contracts, founder product rulings. An approval record, a reservation table, a poller, a state machine is a *mechanism*: parked under constraints it slips past review as if it were given. Move any mechanism found there into the design, where it can be challenged, and review it on its merits.
- **Boundaries**: Where does this feature end? What's explicitly NOT included?
- **Future vs now**: Are there "future considerations" bleeding into the current scope? Flag them.
- **Overbuilding signals**: Does the scope feel larger than the problem requires? Mechanisms beyond the appetite, and edge cases handled that the appetite assigned to manual repair, are findings in their own right.

**Every finding in this layer carries a disposition** (see "Conducting the Review").

---

## Layer 7: Architecture & Domains

**This layer ensures the structural decisions are sound.**

Wrong architectural decisions in the spec become expensive restructuring during code review. Get this right before writing code.

Focus on:

- **Domain ownership**: Which domain owns this functionality? Is it clear?
- **Separation of concerns**: Are responsibilities clearly separated? Is each component doing one thing?
- **Placement**: Does new functionality live in the right place? Or is it shoehorned somewhere convenient?
- **Consolidation opportunities**: Does this new work reveal opportunities to consolidate existing code?
- **Simplicity**: Is this the simplest architecture that solves the problem? Are there unnecessary layers or abstractions?
- **Existing patterns**: Does this follow existing codebase patterns? If it deviates, is there a good reason?
- **Naming**: Does every new table, column, module, type, env var, and route follow the codebase's existing families and suffix conventions (read the schema's table list; table prefix = the entity the rows key on — e.g. in Esora `event_source_*` for organizer data, `organizer_*` is CRM-only)? A spec that names identifiers without a Naming table of precedents is not ready.
- **Greenfield model**: Does the spec carry a `## Greenfield model` section — primitives and composition, concept-count delta, what gets deleted, and a bridge register (owner, removal condition, removing slice) for any temporary structure? It is required whenever the spec introduces a concept, a state, a table or column family, or a special case in a shared path, and its absence is a blocking finding: the spec is not ready for review.
- **Retrofit**: Does the design branch an existing shape so one case fits — a `kind`/`mode`/state column added so one path can fork for one customer, a "compat" or "legacy" layer, a v2 kept beside a v1, a second way of doing something the system already does? Each is a **blocking** finding, not a trade-off; the fix is the convergence to the greenfield model and the deletion of the old shape. Doctrine: `~/.agents/greenfield-convergence.md` (project adoption records may add to it, e.g. Esora's `docs/vision/theses/greenfield-convergence.md`).
- **Machinery vs appetite**: Does every table, job, state machine, and background process earn its place against a specific appetite line? A design carrying mechanisms no appetite line justifies is over-engineered, and that is a finding.

**Every finding in this layer carries a disposition** (see "Conducting the Review"). Architecture findings are where "add a mechanism" is most tempting and most expensive — reach for it last.

---

## Layer 8: Data Flow

**This layer ensures we understand how data moves.**

Unclear data flow leads to integration bugs, implicit coupling, and confused ownership.

Focus on:

- **Flow clarity**: Is it clear how data moves through the system? What are inputs and outputs?
- **Component interactions**: What calls what? Are the interactions documented?
- **Ownership**: Who owns each piece of data? Where is it created, transformed, stored?
- **Boundaries**: Are the boundaries between components clear? Where do handoffs happen?
- **Dependencies**: What depends on what? Are there circular dependencies?

---

## Layer 9: Security & Trust

**This layer ensures security is designed in, not bolted on.**

Security decisions made in the spec are cheap. Security fixes in code are expensive. Security incidents in production are catastrophic.

Focus on:

- **Trust boundaries**: Is it clear what data comes from users vs internal systems?
- **Auth requirements**: Where do auth checks need to happen? Is this documented?
- **Validation needs**: What input needs validation? Where does validation happen?
- **Sensitive data**: Is there sensitive data involved? How is it protected?
- **Abuse vectors**: Could this be abused? Rate limiting, spam, unauthorized access?

---

## Layer 10: Testability & Observability

**This layer ensures we can verify the feature works and understand it in production.**

If you can't test it, you can't build it right. If you can't observe it, you can't operate it.

Focus on:

- **Testing strategy**: Is there a high-level testing approach? What are the test boundaries?
- **Verifiability**: Can success criteria actually be tested?
- **Edge cases**: Are important edge cases identified for testing?
- **Monitoring**: How will we know if this is working? What metrics matter?
- **Debugging**: When something goes wrong, how will we diagnose it?
- **Alerting**: What conditions should trigger alerts?

---

## Layer 11: Performance & Scale

**This layer catches performance issues before they're built.**

Performance problems found in specs are easy to address. Performance problems found in production are emergencies.

Focus on:

- **Scale considerations**: Will this work at expected scale? 10x scale? 100x?
- **Bottlenecks**: Are there obvious bottlenecks in the design?
- **Pagination**: Are there lists or queries that need pagination?
- **Caching**: Is there data that should be cached? Is caching strategy documented?
- **Hot paths**: Are hot paths identified? Are they appropriately simple?
- **Cost implications**: Are there infrastructure cost implications?

---

## Layer 12: Risks & Rollout

**This layer surfaces what could go wrong and ensures the execution plan is sound.**

Acknowledged risks can be mitigated. Hidden risks become surprises.

Focus on:

- **Technical risks**: What could go wrong technically? Dependencies, integrations, complexity?
- **Open questions**: Are there unresolved questions? Are they blocking?
- **Assumptions**: What assumptions is the spec making? Are they valid?
- **Deployable phases**: Can each phase be deployed independently?
- **Exit criteria**: Are exit criteria clear and measurable for each phase?
- **Rollback plan**: What happens if we need to roll back? Is it reversible?
- **Feature flags**: Should this be behind a feature flag?

---

## Knowing When to Stop

**"No issues found" is a valid output.** Not every layer will have problems. Good specs exist. If a layer is sound, say so and move on.

Do not:
- Invent issues to appear thorough
- Nitpick wording when the intent is clear
- Suggest additions that aren't necessary
- Pad output with minor observations

Do:
- State clearly: "**Layer N: No issues found.**" when appropriate
- Trust that clean layers build confidence in the review's credibility
- Reserve feedback for genuine concerns
- Distinguish between "this could be clearer" and "this is missing critical information"

A review that finds nothing wrong has done its job. The goal is accuracy, not volume.

---

## Conducting the Review

1. **Start by asking**: "Which layer would you like to start at? (1-12, default: 1)"
2. **State the layer**: Begin each review section with "**Reviewing Layer N: [Name]**"
3. **Stay focused**: Report only findings relevant to the current layer
4. **Report honestly**: If the layer is sound, say "No issues found" and move on
5. **Wait for signal**: After completing a layer, wait for "next layer" or a specific layer number
6. **Track progress**: Note which layers have been completed

**Read the appetite before Layer 1.** The spec's `## Appetite` section — must never happen / may go wrong and be repaired by hand / not being built, plus what may be used — is the yardstick the whole review measures against. If the spec doesn't state one, say so first (Layer 6's first finding) rather than inventing one.

**Every finding carries a disposition.** A review that can only add mechanisms will only ever produce a bigger system. Each finding proposes exactly **one** disposition, and the reviewer picks the simplest one that's consistent with the appetite:

| Disposition | Meaning |
|-------------|---------|
| **Prevent at the DB boundary** | A constraint, unique index, or generated column makes the bad state unrepresentable. |
| **Fail closed** | The operation refuses rather than proceeding into ambiguity. |
| **Detect + manual repair** | It surfaces in an admin list and a human fixes it. Legitimate for rare, visible, repairable failures. |
| **Accept as-is** | The appetite says this failure isn't worth preventing. |

"Add a mechanism / table / job / state" is **not** one of the four — it is the last resort, and proposing it requires an explicit argument for why each of the four fails. And **over-engineering is itself a finding**: mechanisms beyond the appetite, and edge cases handled that the appetite assigned to manual repair, are reported with the same weight as a bug.

**Findings that need a founder call go on a decision page.** Scope cuts, architecture routes, and any trade-off that is his to make are not prose questions in the terminal — present them via the `artifacts` skill's decision-page pattern: one lead sentence, one options or before→after visual, one option card per decision with pros/cons and the recommendation tagged, and a "Your decisions" line he copies back. Findings he doesn't need to arbitrate stay in the terminal.

**Typical flow:**
- Start with Product Review (Layers 1-5) to validate the "what" and "why"
- Then Engineering Review (Layers 6-12) to validate the "how"
- Skip layers that don't apply (e.g., skip Growth & Adoption for internal tooling)

Remember: The spec is the anchor. Evaluate whether it provides enough clarity and soundness for implementation to proceed without major surprises.
