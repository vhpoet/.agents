# Knex Query Builder Guidelines

## knex-stringcase

The project uses `knex-stringcase`, which converts between database `snake_case` and JavaScript `camelCase` automatically for builder queries.

### Critical Rules

1. **Always use camelCase in JavaScript code** — never snake_case in queries.
2. **Never use `.pluck()`** — broken with knex-stringcase, returns `[undefined, ...]`. Use `.select()` + `.map()` instead.
3. **Use snake_case only in migrations** — when defining schemas.
4. **`db.raw()` results are NOT converted** — raw results return `{ rows: [...] }` where row keys stay in snake_case. Map manually:

```ts
// ✅ camelCase in builder queries
await db('user').where({ firstName: 'John' });

// ✅ Extract values with select + map (NOT .pluck())
const ids = (await db('user').select('userId')).map(r => r.userId);

// ✅ Raw results: map snake_case keys manually
const result = await db.raw(`SELECT event_id, start_date FROM ...`, params);
return result.rows.map((row) => ({
  eventId: row['event_id'],
  startDate: row['start_date'],
}));
```

## Prefer Builder Over Raw SQL

Use the Knex query builder instead of `db.raw()` whenever possible. Raw SQL bypasses knex-stringcase (results come back in snake_case, requiring manual mapping) and loses type safety.

**When raw is unavoidable** (e.g., pgvector operators like `<=>`), isolate it:
- Use `.whereRaw()` / `.selectRaw()` inside a builder query
- Use `knex.raw()` only for expressions that have no builder equivalent

```ts
// Prefer: builder with targeted raw expressions
db('event')
  .join('embedding', ...)
  .distinctOn('event.eventId')
  .select([
    ...EVENT_FIELDS.base.columns(),
    db.raw('1 - (embedding.embedding <=> ?::vector) as similarity', [vectorStr]),
  ])
  .where('event.cityId', cityId)
  .whereRaw('1 - (embedding.embedding <=> ?::vector) >= ?', [vectorStr, minSimilarity])

// Avoid: entire query as raw SQL
const result = await db.raw(`SELECT ... FROM event e JOIN ...`, [...params])
```

## DISTINCT ON

Knex supports PostgreSQL `DISTINCT ON` natively — no need for raw SQL:

```ts
db('event')
  .distinctOn('event.eventId')
  .orderBy([
    { column: 'event.eventId' },
    { column: 'similarity', order: 'desc' },
  ])
```

When you need the final result ordered by something other than the DISTINCT ON column, wrap in a subquery:
```ts
db.from(
  db('event')
    .distinctOn('event.eventId')
    .select('*')
    .orderBy([...])
    .as('sub')
)
.orderBy('similarity', 'desc')
.limit(10)
```

## Parameterization

- Use `?` for value bindings, `??` for identifier bindings
- Never interpolate user input into SQL strings
- For vector literals, build the string and pass as a binding: `[${embedding.join(',')}]`

## Migrations & Seeds

- Migrations are additive and safe for schema changes.
- Use snake_case for column names in migrations.
- **Never run seeds in production** — they wipe data.
