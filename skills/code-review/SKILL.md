---
name: code-review
description: Principal-level code review using parallel specialized agents. Use when the user asks for a code review, wants feedback on their changes, or invokes /code-review. Spawns 6 agents in parallel (Correctness, Architecture, Data Layer, Entropy, Assumptions, Product Engineering) to review uncommitted changes from multiple angles, then synthesizes findings.
---

# Code Review

Parallel principal-level review of uncommitted changes using 6 specialized agents.

## Workflow

1. **Immediately** spawn all 6 agents in parallel - no preprocessing
2. Each agent runs its own git diff: `git diff -w HEAD -- . ':!yarn.lock' ':!package-lock.json' ':!pnpm-lock.yaml' ':!.agents' ':!**/fixtures/**' ':!docs/**'`
3. Synthesize findings into a unified review
4. Present findings via `AskUserQuestion` (multiSelect) so user can pick which to fix

## Shared Context

Each agent receives this preamble + their specific focus:

```
WORKER AGENT - Do NOT spawn sub-agents.

First, run: git diff -w HEAD -- . ':!yarn.lock' ':!package-lock.json' ':!pnpm-lock.yaml' ':!.agents' ':!**/fixtures/**' ':!docs/**'

Then review the diff. Use it as entry point - reason outward only as needed. Goal: reduce entropy, favor simplicity, prefer deletion over addition.
```

## Agent Definitions

### 1. Correctness Agent

```
Review for correctness and runtime safety.

Focus areas:
- Logic defects and bugs
- Edge cases and boundary conditions
- Type safety and null handling
- Error handling completeness
- Failure modes and recovery
- Idempotency violations
- Transaction boundaries and atomicity
- Resource lifetimes (connections, handles, memory)
- Cancellation and context propagation
- Race conditions and concurrency issues

For each issue: state the problem, explain the risk, suggest a fix.
```

### 2. Architecture Agent

```
Review architectural quality and design coherence.

Focus areas:
- Separation of concerns violations
- Module boundary clarity
- Data flow patterns (explicit vs implicit)
- Abstraction quality (too much, too little, wrong level)
- Encapsulation breaches
- Control flow complexity
- Coupling between components
- Single responsibility violations
- Dependency direction (are dependencies pointing the right way?)

For each issue: identify the violation, explain why it matters, propose realignment.
```

### 3. Data Layer Agent

```
Review data access, persistence, and integrity.

Focus areas:
- Database query correctness and efficiency
- Migration safety and backward compatibility
- Uniqueness constraints and guarantees
- Pagination correctness
- Buffering vs streaming decisions
- Data integrity assumptions
- N+1 query patterns
- Index usage and query performance
- Transaction isolation levels
- Data validation at boundaries

For each issue: describe the problem, explain the data risk, suggest the fix.
```

### 4. Entropy Agent

```
Review for unnecessary complexity and simplification opportunities.

Focus areas:
- Dead, stale, or unused code
- Duplicated logic
- Over-engineered abstractions
- Code that could be deleted entirely
- Layers that could be collapsed
- Modules that should be merged or split
- Premature generalizations
- Config or feature flags that add complexity without value
- Comments that compensate for unclear code
- Subtractive refactoring opportunities

For each opportunity: identify what to remove/simplify, explain the benefit, outline the change.
```

### 5. Assumptions Agent

```
Challenge embedded assumptions and outdated patterns.

Focus areas:
- Patterns that no longer fit the current system
- Framework/library choices worth reconsidering
- Architectural decisions made under old constraints
- Implicit assumptions that should be explicit
- Conventions followed by habit rather than reason
- Abstractions that outlived their usefulness
- Tech debt that compounds if not addressed now
- Systemic risks introduced or perpetuated

For each challenge: state the assumption, explain why it's questionable, propose a better alternative (only if one clearly exists).
```

### 6. Product Engineering Agent

```
Review from a product-minded engineering perspective.

Focus areas:
- Are we building the right thing?
- Does this change serve users well?
- Is the UX coherent with the rest of the product?
- Is the complexity justified by user value?
- Are there simpler ways to achieve the same user outcome?
- Does this introduce friction users will struggle with?
- Is the feature direction sound?
- Are we over-building for users who don't need it?
- Are we under-building for users who do?
- Would a world-class product engineer approve this direction?

For each concern: describe the product issue, explain user impact, suggest an alternative approach.
```

## Spawning Agents

Spawn all 6 in parallel. Prompts are short - just shared context + agent focus. No diff needed - agents fetch it themselves.

```python
Task(subagent_type="feature-dev:code-reviewer", description="Review correctness",
     prompt="[Shared Context]\n\n[Correctness Agent focus]")
# ... same for all 6, in one message
```

## Synthesis

After all agents complete, synthesize findings:

1. **Critical Issues** - Must fix before merge (bugs, data integrity, security)
2. **Design Concerns** - Should address (architecture, patterns, complexity)
3. **Opportunities** - Consider addressing (simplification, product direction)
4. **Observations** - Worth noting but not blocking

Deduplicate overlapping findings. Preserve the strongest framing of each issue.

Present as a single cohesive review, not 6 separate reports.

## Step 5: Let user pick what to fix

After presenting the synthesis, use `AskUserQuestion` with `multiSelect: true` to let the user choose which issues to address:

```python
AskUserQuestion(questions=[
  {
    "question": "Which issues do you want me to fix?",
    "header": "Fix",
    "multiSelect": True,
    "options": [
      {"label": "Issue 1 title", "description": "Brief explanation"},
      {"label": "Issue 2 title", "description": "Brief explanation"},
      # ... up to 4 options per question, use multiple questions if more
    ]
  }
])
```

Group by category if needed (Critical, Design, Opportunities). After user selects, implement the chosen fixes.
