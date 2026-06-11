## iTerm2 Badge

After your first response in a new conversation, set the iTerm2 badge so the user can identify this session. Run: `~/.claude/hooks/set-badge.sh "max 3 words"` where the text is a short label for what you're working on (e.g. "event pipeline", "mobile auth", "badge setup"). Update it if the task changes significantly.

# Machine-local context

@~/.agents/AGENTS.local.md

# Git & Branching

- **Work directly on `main`** (or whatever branch is already checked out). Do NOT create new branches, and do NOT create git worktrees, unless I explicitly ask for one.
- **Never commit automatically.** Make the edits and leave them in the working tree for me to review. Only run `git commit` when I explicitly tell you to commit.
- Staging and pushing are also opt-in: don't `git add`, `git push`, or open PRs unless I ask.

# Coding Guidelines

Focus on elegant, modular code. Keep codebases simple and maintainable.

## Specialized Guidelines

- **Data pipelines, ETL, scraping, background jobs**: `~/.agents/pipeline-best-practices.md`
- **React Native or Expo apps**: `~/.agents/react-native-best-practices.md`
- **Node.js APIs or backend services**: `~/.agents/node-api-best-practices.md`
- **Knex query builder**: `~/.claude/libs/knex.md`

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

- One concern per file. Growing size (300+ lines) is a signal to check for a second concern hiding inside — split along concept boundaries, never to hit a line count. A long file telling one cohesive story stays whole; fragmenting it scatters the concern across files.
- One responsibility and one level of abstraction per function. Extract when it clarifies the narrative or removes duplication — never to satisfy a length rule. A chain of one-call helpers is worse than one readable function.
- Avoid long parameter lists. Group related values into objects.
- Apply the "rule of three" before extracting shared *code shape*. But *knowledge* — business rules, constants, schemas, thresholds — has one source of truth from the first occurrence; duplicating a fact is a bug, not a pending abstraction.
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
