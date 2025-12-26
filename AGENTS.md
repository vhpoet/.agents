# Coding Guidelines

Focus on elegant, modular code. Keep codebases simple and maintainable while ensuring production-quality standards.

## Core Principles

- Clarity over cleverness. Prefer obvious, boring solutions.
- Single responsibility. Functions and modules do one thing well.
- Consistent naming. Use full, descriptive names everywhere.
- Minimal surface area. Small, focused changes beat sweeping rewrites.
- Reduce entropy. Remove dead code and duplication as you touch areas.

## Workflow (Always Follow)

1. Understand the request and the broader context.
2. Read the relevant project docs and scan existing code patterns.
3. Identify duplication, leaky abstractions, or missing boundaries.
4. Propose a cleaner approach if the request creates technical debt.
5. Implement the smallest change that fits the architecture.
6. Verify behavior with tests or targeted checks when possible.

## Thoughtful Engineering Approach

Before implementing any request, **ALWAYS**:

1. **Understand the broader context**
    - What is the user really trying to achieve? (not just the literal request)
    - How does this change affect the overall product direction?
    - Are there related areas of the codebase that will be impacted?

2. **Consider architectural implications**
    - Does this change fit naturally with the current architecture?
    - Are we adding complexity that suggests a refactor is needed?
    - Is there a pattern emerging that we should address systematically?
    - Will this change make future related changes harder or easier?

3. **Propose better approaches when appropriate**
    - If you notice the request would create technical debt, **speak up**
    - If a small refactor would make this and future changes cleaner, **suggest it**
    - If you see a pattern that could be abstracted, **recommend it**
    - If the current approach is becoming unwieldy, **propose alternatives**

4. **Think like a senior engineer**
    - Don't just implement the literal request if there's a better way
    - Consider: "Would a good architect do it this way, or would they refactor first?"
    - Ask yourself: "Am I making this change in a way that will cause problems later?"
    - Look for opportunities to improve the codebase while making changes

**Example responses:**
- "I can make this change, but I notice we're duplicating similar logic in 3 places. Should we extract this into a shared utility first?"
- "This request suggests the user flow is changing. Should we reconsider the component structure in this domain?"
- "Adding this feature the direct way would work, but I notice a pattern. Would you like me to refactor the approach to make this and similar future features easier?"

## Design and Architecture

- Separate concerns by layer. Avoid mixing data access, business logic, and I/O in one place.
- Keep boundaries clean. Modules should have clear inputs/outputs and minimal side effects.
- Prefer composition over inheritance and deep nesting.
- Avoid hidden coupling. Make dependencies explicit through parameters or imports.
- Use guard clauses to reduce nesting and improve readability.
- Handle errors close to their source, with context for debugging.

## Code Structure and Readability

- Split files around ~300 lines or when they feel crowded.
- Prefer small, focused functions (usually 20-40 lines max).
- Avoid long parameter lists. Group related values into objects.
- Use helper functions for repeated logic, but avoid over-abstraction.
- Apply the "rule of three" before extracting utilities.
- Add comments sparingly, only to explain "why" or tricky logic.

## Making Changes & Refactoring

- When modifying or adding features, **reconsider the entire affected area**
- Before making changes, identify:
    - Code that will become unused or obsolete
    - Related functions/components that need updating
    - Opportunities to simplify or consolidate
- **Remove dead code immediately** - don't leave unused imports, functions, or components
- Think holistically about the change rather than making blind incremental additions
- For significant changes, consider if the overall architecture/approach needs rethinking
- **No backwards compatibility layers** - just update all references directly

## Naming Conventions

- Use descriptive, domain-accurate names. No abbreviations.
- **Boolean variables**: Use `is`, `has`, `should` prefixes (e.g., `isHidden`, `hasAccess`, `shouldUpdate`)
- Keep naming consistent across variables, types, DB columns, and API fields.
- Use full, descriptive names consistently everywhere - never shorten domain concepts.

## TypeScript Practices

- Prefer type inference for local variables; add explicit types for exported APIs.
- Avoid `any`. Use `unknown` and narrow with type guards.
- Use `type` for unions and primitives; use `interface` for object shapes that are extended.
- Model data with literal unions instead of enums when possible.
- Use `readonly` and `as const` for truly immutable values.
- Avoid unsafe type assertions. If you must assert, explain why.
- Make impossible states unrepresentable with discriminated unions.
- Add exhaustive checks on unions (e.g., `switch` with `never`).
- Align runtime validation with types (e.g., Zod schemas for inputs).

## Data and State

- Prefer immutable data where practical; mutate only when it clarifies intent.
- Keep transformations explicit. Avoid hidden mutations inside helpers.
- Validate inputs early. Fail fast with helpful errors.
- Keep data shaping and persistence close to each other.

## Performance and Reliability

- Avoid premature optimization. Optimize only for measured pain.
- Be mindful of N+1 queries and repeated API calls.
- Cache only when necessary and invalidate explicitly.
- Keep error handling consistent and observable.

## Response Format

- **Do NOT create unsolicited documentation** (change logs, summaries, or other documents not explicitly requested)
- Only provide the changes requested

## Change Checklist

- Did I scan for existing patterns or utilities to reuse?
- Is responsibility separated (controller/service/repo or UI/data)?
- Is the change small, focused, and easy to read?
- Did I remove or refactor now-dead code?
- Did I update or add tests where behavior changed?

## When to Ask Questions

- The request conflicts with existing architecture.
- The scope or expected behavior is ambiguous.
- A refactor would significantly improve long-term quality.

## What to Avoid

- Over-engineering, clever tricks, or unnecessary abstractions.
- Inline styling, long files, and deeply nested logic.
- Storing secrets in code or persisting sensitive data insecurely.
