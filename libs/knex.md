# Knex Best Practices

Guidelines for using Knex query builder with PostgreSQL.

## knex-stringcase

When using **knex-stringcase**, it automatically converts between JavaScript `camelCase` and database `snake_case`.

### Critical Rules

1. **Always use camelCase in JavaScript code** - Never use snake_case in queries
2. **Never use `.pluck()`** - It's broken with knex-stringcase. Use `.select()` + `.map()` instead
3. **Use snake_case only in migrations** - When defining schemas

### Examples

```javascript
// ✅ CORRECT: camelCase everywhere in queries
await db('user').where({ firstName: 'John', isActive: true });
await db('user').select('userId', 'firstName', 'createdAt');

// ✅ CORRECT: Extract column values (NOT .pluck())
const rows = await db('user').select('userId');
const ids = rows.map(r => r.userId);

// ❌ WRONG: Don't use snake_case in queries
await db('user').where({ first_name: 'John' }); // NO

// ❌ WRONG: Don't use .pluck()
await db('user').pluck('userId'); // BROKEN - returns [undefined, ...]
```

## Migrations

### Snake Case in Schema Definitions

```javascript
// In migrations, use snake_case for column names
exports.up = function(knex) {
  return knex.schema.createTable('user', (table) => {
    table.increments('user_id').primary();
    table.string('first_name').notNullable();
    table.string('last_name');
    table.boolean('is_active').defaultTo(true);
    table.timestamps(true, true); // created_at, updated_at
  });
};
```

### Safe Migration Practices

- Migrations are **additive and safe** for schema changes
- Use direct SQL inserts for adding individual records
- **Never run seeds in production** - they typically wipe data
- Create migrations that add records without deleting existing ones

## Query Patterns

### Selecting Specific Columns

```javascript
// Select specific columns
const users = await db('user')
  .select('userId', 'firstName', 'email')
  .where({ isActive: true });
```

### Joins

```javascript
// Joins with camelCase
const events = await db('event')
  .join('venue', 'event.venueId', 'venue.venueId')
  .select('event.*', 'venue.name as venueName');
```

### Transactions

```javascript
await db.transaction(async (trx) => {
  const userId = await trx('user').insert({ firstName: 'John' }).returning('userId');
  await trx('profile').insert({ userId: userId[0], bio: 'Hello' });
});
```

## Important Reminders

- Use **camelCase** in all database queries (knex-stringcase handles conversion)
- Never use `.pluck()` - always `.select()` + `.map()`
- Keep schema reference docs up to date
- Use transactions for multi-table writes
