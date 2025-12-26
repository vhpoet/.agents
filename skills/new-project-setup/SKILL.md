---
name: new-project-setup
description: Initialize new projects with monorepo structure, Yarn workspaces, Vite, Fastify, PostgreSQL/Knex, and Mantine UI.
---

# Project Setup

## Instructions

1. Ask what type of setup is needed (full project, new workspace package, or specific config)
2. Always install packages with `@latest`
3. Configure absolute imports with `@/` prefix

## Monorepo Structure

```
project-root/
├── package.json          # Workspace root with "workspaces": ["backend", "frontend", "shared", "mobile"]
├── backend/
│   ├── package.json
│   ├── jsconfig.json     # @/* paths
│   └── src/
├── frontend/
│   ├── package.json
│   ├── vite.config.ts    # @/ and shared aliases
│   └── src/
├── shared/
│   └── src/
└── mobile/
    └── src/
```

## Key Configurations

### .prettierrc

```json
{ "semi": true, "singleQuote": true, "trailingComma": "es5", "printWidth": 100, "tabWidth": 2 }
```

### Backend jsconfig.json

```json
{ "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["src/*"] } } }
```

### Frontend vite.config.ts

Use `@/` for local src and `shared` alias for `../shared/src`.

## Core Dependencies

### Backend

```bash
yarn add fastify@latest dotenv@latest get-port@latest
yarn add pg@latest knex@latest knex-stringcase@latest  # PostgreSQL
```

### Frontend

```bash
yarn add react@latest react-dom@latest react-router-dom@latest
yarn add @mantine/core@latest @mantine/hooks@latest classnames@latest
```

## Database (Knex + PostgreSQL)

Use `knex-stringcase` wrapper in knexfile.js. Migrations in `./src/db/migrations`.

## Server Pattern

- Use `get-port` for dynamic port allocation
- Write port to `../.ports.json` for frontend discovery
- Set terminal title with `\u001b]1;🚀 API - Name\u0007`
