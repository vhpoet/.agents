# Node API Best Practices

Guidelines for building Node.js backends with clean architecture.

## Layered Architecture

Use a **service layer** and **repository pattern** with a light **CQRS-style read/write split**:

- **Controllers** (`controller.ts`): no `db` imports; validate + call services; map errors to HTTP.
- **Repositories** (`repository.ts`): "source of truth" persistence for one table/aggregate (CRUD/upsert, invariants, transactions).
- **Query modules / read models** (`queries.ts`): read-only, cross-table, endpoint-shaped queries (joins, sorting, pagination).
- **Services** (`service.ts`): orchestrate multiple repositories/queries into a specific use-case or API response shape.

## Domain-Based Structure

```
src/
├── event/
│   ├── controller.ts
│   ├── schemas.ts
│   ├── repository.ts      (optional)
│   ├── queries.ts         (optional)
│   └── service.ts         (optional)
├── user/
│   ├── controller.ts
│   └── schemas.ts
├── services/              # External integrations (APIs, scrapers)
├── plugins/               # Fastify plugins (auth, logging, errors)
├── utils/                 # Shared utilities
└── server.js
```

Each domain (singular naming) contains:
- `controller.ts` - HTTP handlers (thin: request/response + orchestration)
- `schemas.ts` - Zod request validation
- `service.ts` - Application/use-case orchestration (optional)
- `repository.ts` - Write-side persistence (optional)
- `queries.ts` - Read-only cross-table queries (optional)

## Separation of Concerns

- **Routes/Controllers should NEVER access the database directly**
- **All database interactions must go through a dedicated data access layer**
- Routes handle: HTTP request/response, input validation, response formatting
- Data access layer handles: all queries/transactions, data shaping, persistence rules

## Data Access Boundaries

- **Controllers**: may not import/use `db`/`knex` directly; call services or data access functions.
- **Adapters / fetchers** (scrapers, LLM extractors, etc.): may not touch DB; return structured data only.
- **Services / pipelines**: may touch DB, but should do it via the data access layer.

## Accessing Decorators (Services)

**Always destructure at the top of the function**:

```javascript
// ✅ Good
export async function addInstagram(request, reply) {
  const { instagramService } = request.server;
  const analysis = await instagramService.analyzeInstagramProfile(username);
}

// ❌ Bad - long chains
export async function addInstagram(request, reply) {
  const analysis = await request.server.instagramService.analyzeInstagramProfile(username);
}
```

## Route Naming

- **Do NOT prefix routes with `/api`**
- ✅ Correct: `/users`, `/events`, `/places`
- ❌ Wrong: `/api/users`, `/api/events`

## Folder Purposes

- **Domain folders** (`event/`, `user/`) - Business logic organized by domain
- **`services/`** - External integrations (OpenAI, Google APIs, scrapers)
- **`plugins/`** - Fastify plugins (auth, logging, error handling)
- **`utils/`** - Shared utility functions

## Development Tips

### Port Management

Use `get-port` package for dynamic port assignment:

```javascript
import getPort from 'get-port';
const port = await getPort({ port: [3000, 3001, 3002] });
```

### Terminal Tab Title

```javascript
if (process.env.NODE_ENV !== 'production') {
  process.stdout.write(`\u001b]1;🚀 API - ProjectName\u0007`);
}
```

## Important Reminders

- Use **domain-based folder structure** (singular domain names)
- **No `/api` prefix** on routes
- Always use **relative imports** (no path aliases in backend)
- External integrations go in `services/`
- Fastify-specific code goes in `plugins/`
- Before creating any new function, **check for an existing one** that can be reused
