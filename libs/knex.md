# Knex Best Practices

## knex-stringcase

Automatically converts between JavaScript `camelCase` and database `snake_case`.

### Critical Rules

1. **Always use camelCase in JavaScript code** - Never use snake_case in queries
2. **Never use `.pluck()`** - Broken with knex-stringcase. Use `.select()` + `.map()` instead
3. **Use snake_case only in migrations** - When defining schemas

```javascript
// ✅ camelCase in queries
await db('user').where({ firstName: 'John' });

// ✅ Extract values with select + map (NOT .pluck())
const ids = (await db('user').select('userId')).map(r => r.userId);

// ❌ .pluck() is broken - returns [undefined, ...]
```

## Migrations

- Migrations are additive and safe for schema changes.
- Never run seeds in production - they wipe data.
- Use snake_case for column names in migrations.
