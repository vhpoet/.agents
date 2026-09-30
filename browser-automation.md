# Browser automation — which Chrome to use

Two browser toolsets exist and they are NOT interchangeable:

- **Claude-in-Chrome extension (`mcp__claude-in-chrome__*`)** — the owner's real Chrome profile and real logins (Ahrefs, Meta, Eagle, Google…). It opens a new tab in the running Chrome. DEFAULT for any task that touches a logged-in site or the owner's sessions.
- **chrome-devtools MCP plugin (`mcp__plugin_chrome-devtools-mcp_*`)** — a separate automation Chrome with a throwaway profile (`~/.cache/chrome-devtools-mcp/chrome-profile`, no extensions, no logins; looks like an incognito window). Use ONLY for clean-profile work: local dev QA, mobile viewport emulation, performance traces, logged-out-state testing.

Rules:
1. Logged-in / real-session task → claude-in-chrome, always. If it reports "extension not connected", STOP and ask the owner to open Chrome or check the Claude extension. Do NOT fall back to the devtools browser for that task — it will hit login walls and Cloudflare bot checks.
2. Never log into any site inside the devtools browser; its profile is disposable and sites bot-check it.
