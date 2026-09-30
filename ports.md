# Ports

I run many projects at once, so common default ports collide constantly. Whenever a service binds an **external / host-published** port — docker-compose `ports:`, a dev server, an nginx upstream, any listener reachable from the host — default to a **fixed but obscure** port in the dynamic range (49152–65535), not a common default (3000, 4000, 5000, 5432, 6379, 8000, 8080, …). Pick one once and verify it's genuinely unclaimed — this is two checks, not one:
1. **Nothing is listening now:** `lsof -iTCP:PORT -sTCP:LISTEN`.
2. **No config already reserves it** (a stopped service still owns its port): grep the port number across nginx server blocks (e.g. `/opt/homebrew/etc/nginx/servers/*.conf`, `/etc/nginx/`), other projects' `docker-compose.yml`/`.env`/Procfiles, and any reverse-proxy configs. A port that's idle but wired into a config is NOT free.

Then commit it so it's stable across restarts. Keep **container-internal** ports at their conventional values — only the host-facing side needs to be obscure. When something else must point at the chosen port (nginx, env vars, another service), wire it through consistently.
