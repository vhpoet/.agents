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
yarn add fastify@latest dotenv@latest
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

- Pick a **fixed but obscure** host port in the dynamic range (49152–65535), never a common default (3000, 5432, 8080, …). Verify it's genuinely unclaimed before committing to it: nothing listening now (`lsof -iTCP:PORT -sTCP:LISTEN`) AND no other project's config already reserves it (grep nginx server blocks, docker-compose files, `.env`s for the number). Commit the chosen port so it's stable across restarts. Container-internal ports stay conventional — only the host-facing side is obscure. Full policy: Ports section in `~/.agents/AGENTS.local.md`.
- Set terminal title with `\u001b]1;🚀 API - Name\u0007`
