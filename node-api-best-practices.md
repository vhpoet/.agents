# Node API Best Practices

Guidelines for building Node.js backends with clean architecture.

## Layered Architecture

Use a **service layer** and **repository pattern** with a light **CQRS-style read/write split**:

- **Controllers**: no `db` imports; validate + call services; map errors to HTTP.
- **Repositories**: write-side persistence for one table/aggregate.
- **Queries**: read-only, cross-table, endpoint-shaped queries.
- **Services**: orchestrate multiple repositories/queries into a use-case.

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
│   └── ...
├── services/              # External integrations
├── plugins/               # Framework plugins
└── utils/
```

## Separation of Concerns

- Controllers NEVER access the database directly.
- All database interactions go through a dedicated data access layer.
- Adapters/fetchers (scrapers, LLM extractors) may not touch DB; return structured data only.

## Key Rules

- Destructure services at the top of controller functions.
- No `/api` prefix on routes.
- Use relative imports (no path aliases in backend).
- Domain folders use singular naming.
