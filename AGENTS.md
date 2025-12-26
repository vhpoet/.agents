# Coding Guidelines

Focus on elegant, modular code. Keep codebases simple and maintainable.

## Specialized Guidelines

- **Data pipelines, ETL, scraping, background jobs**: `pipeline-best-practices.md`
- **React Native or Expo apps**: `react-native-best-practices.md`
- **Node.js APIs or backend services**: `node-api-best-practices.md`
- **Knex query builder**: `libs/knex.md`

## Core Principles

- Clarity over cleverness. Prefer obvious, boring solutions.
- Single responsibility. Functions and modules do one thing well.
- Consistent naming. Use full, descriptive names everywhere.
- Minimal surface area. Small, focused changes beat sweeping rewrites.
- Reduce entropy. Remove dead code and duplication as you touch areas.

## Thoughtful Engineering

Before implementing, understand the broader context and architectural implications. Propose better approaches if the request creates technical debt. Think like a senior engineer—don't just implement the literal request if there's a better way.

## Design and Architecture

- Separate concerns by layer. Avoid mixing data access, business logic, and I/O.
- Keep boundaries clean. Modules should have clear inputs/outputs and minimal side effects.
- Prefer composition over inheritance and deep nesting.
- Avoid hidden coupling. Make dependencies explicit.
- Use guard clauses to reduce nesting.
- Handle errors close to their source, with context for debugging.

## Code Structure

- Split files around ~300 lines.
- Prefer small, focused functions (20-40 lines max).
- Avoid long parameter lists. Group related values into objects.
- Apply the "rule of three" before extracting utilities.
- Add comments sparingly, only to explain "why".

## Making Changes

- Reconsider the entire affected area when modifying features.
- Remove dead code immediately.
- No backwards compatibility layers—just update all references directly.

## Naming Conventions

- Use descriptive, domain-accurate names. No abbreviations.
- Boolean variables: `is`, `has`, `should` prefixes.
- Keep naming consistent across variables, types, DB columns, and API fields.

## TypeScript Practices

- Prefer type inference for locals; explicit types for exported APIs.
- Avoid `any`. Use `unknown` and narrow with type guards.
- Use `type` for unions/primitives; `interface` for extendable object shapes.
- Model data with literal unions instead of enums.
- Make impossible states unrepresentable with discriminated unions.
- Align runtime validation with types (Zod schemas for inputs).

## Data and State

- Prefer immutable data where practical.
- Keep transformations explicit. Avoid hidden mutations.
- Validate inputs early. Fail fast with helpful errors.

## Performance

- Avoid premature optimization. Optimize only for measured pain.
- Be mindful of N+1 queries and repeated API calls.
- Cache only when necessary and invalidate explicitly.

## Response Format

- Do NOT create unsolicited documentation.
- Only provide the changes requested.

## What to Avoid

- Over-engineering, clever tricks, unnecessary abstractions.
- Inline styling, long files, deeply nested logic.
- Storing secrets in code.
