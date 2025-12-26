---
name: new-project-setup
description: Initialize new projects or workspaces with monorepo structure, Yarn workspaces, Vite, Fastify, PostgreSQL/Knex, and Mantine UI. Use when creating new projects or adding packages.
---

# Project Setup

Initialize projects following the established conventions.

## Instructions

1. Ask what type of setup is needed (full project, new workspace package, or specific config)
2. Use the templates below for each component
3. Always install packages with `@latest`
4. Configure absolute imports with `@/` prefix

## Monorepo Structure

```
project-root/
├── package.json          # Workspace root
├── .gitignore
├── .prettierrc
├── backend/
│   ├── package.json
│   ├── jsconfig.json
│   └── src/
├── frontend/
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
├── shared/
│   └── src/
└── mobile/
    └── src/
```

## Root package.json

```json
{
  "name": "project-name",
  "private": true,
  "workspaces": [
    "backend",
    "frontend",
    "shared",
    "mobile"
  ]
}
```

## Configuration Files

### .prettierrc

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
```

### .gitignore

```
# Dependencies
node_modules/
.yarn/
.pnp.*

# Environment
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
*.log

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Database
*.sqlite
*.sqlite3
*.db

# Port configuration
.ports.json
```

### Frontend vite.config.ts

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      'shared': path.resolve(__dirname, '../shared/src'),
    },
  },
});
```

### Backend jsconfig.json

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

## Core Dependencies

### Backend

```bash
yarn add fastify@latest dotenv@latest get-port@latest
yarn add pg@latest knex@latest knex-stringcase@latest  # If using PostgreSQL
```

### Frontend

```bash
yarn add react@latest react-dom@latest react-router-dom@latest
yarn add @mantine/core@latest @mantine/hooks@latest
yarn add classnames@latest
yarn add cmdk@latest react-hotkeys-hook@latest
yarn add @reduxjs/toolkit@latest react-redux@latest  # If using Redux
```

## Package.json Scripts

### Backend

```json
{
  "scripts": {
    "dev": "node src/server.js",
    "db:migrate": "knex migrate:latest",
    "db:rollback": "knex migrate:rollback"
  }
}
```

### Frontend

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

## Database Setup (PostgreSQL + Knex)

### knexfile.js

```javascript
import knexStringcase from 'knex-stringcase';

export default knexStringcase({
  development: {
    client: 'pg',
    connection: {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    },
    migrations: {
      directory: './src/db/migrations',
    },
    seeds: {
      directory: './src/db/seeds',
    },
  },
});
```

### Backend .env

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
```

## Server Setup

### Backend server.js

```javascript
import 'dotenv/config';
import Fastify from 'fastify';
import getPort from 'get-port';
import { writeFileSync } from 'fs';
import path from 'path';

const fastify = Fastify({ logger: true });

// Set terminal title
if (process.env.NODE_ENV !== 'production') {
  process.stdout.write(`\u001b]1;🚀 API - ProjectName\u0007`);
}

// Register routes, plugins, etc.

// Start server with dynamic port
const port = await getPort({ port: [3000, 3001, 3002, 3003] });

// Write port to .ports.json for frontend
const portsFile = path.join(process.cwd(), '../.ports.json');
writeFileSync(portsFile, JSON.stringify({ api: port }));

await fastify.listen({ port, host: '0.0.0.0' });
console.log(`Server running on http://localhost:${port}`);
```

## Mantine UI Setup

### Install packages

```bash
yarn add @mantine/core@latest @mantine/hooks@latest @mantine/dates@latest
yarn add @mantine/dropzone@latest @mantine/carousel@latest
yarn add @mantine/notifications@latest @mantine/modals@latest
```

### App wrapper

```javascript
import { MantineProvider } from '@mantine/core';
import '@mantine/core/styles.css';

function App() {
  return (
    <MantineProvider>
      {/* Your app */}
    </MantineProvider>
  );
}
```

## Checklist

When setting up a new project:

- [ ] Create monorepo structure
- [ ] Set up Yarn workspaces
- [ ] Configure Prettier
- [ ] Set up .gitignore
- [ ] Initialize git repository
- [ ] Configure absolute imports (@/ paths)
- [ ] Install core dependencies (latest versions)
- [ ] Set up PostgreSQL + Knex (if needed)
- [ ] Configure port management
- [ ] Set terminal tab titles
- [ ] Install Mantine UI components
